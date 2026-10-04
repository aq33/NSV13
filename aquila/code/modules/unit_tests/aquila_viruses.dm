// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Symbiotic Regeneration (#236): only heals while the host stands still, thresholds, toxin lovers, cleanup on cure
/datum/unit_test/symbiotic_regeneration

/datum/unit_test/symbiotic_regeneration/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/virus = new
	virus.AddSymptom(new /datum/symptom/heal/symbiotic)
	virus.Refresh()
	host.ForceContractDisease(virus, FALSE, TRUE)
	TEST_ASSERT(virus in host.diseases, "Host was not infected")
	var/datum/symptom/heal/symbiotic/symptom = locate() in virus.symptoms
	TEST_ASSERT(symptom, "Disease has no Symbiotic Regeneration symptom")
	virus.stage = 5
	virus.stage_act() // starts processing, which calls Start()
	TEST_ASSERT(virus.processing, "Disease did not start processing")
	TEST_ASSERT_EQUAL(symptom.heal_delay, 3 SECONDS, "Default heal delay changed")
	TEST_ASSERT_EQUAL(symptom.power, 1, "Default power changed")

	host.adjustBruteLoss(20)
	host.adjustFireLoss(20)
	host.adjustToxLoss(20)

	// Moving resets the timer and blocks healing
	SEND_SIGNAL(host, COMSIG_MOB_CLIENT_PRE_MOVE, get_turf(host))
	TEST_ASSERT_EQUAL(symptom.last_moved, world.time, "Moving did not reset the regeneration timer")
	TEST_ASSERT(!symptom.CanHeal(virus), "Healing allowed right after moving")
	var/brute = host.getBruteLoss()
	symptom.next_activation = 0
	symptom.Activate(virus)
	TEST_ASSERT_EQUAL(host.getBruteLoss(), brute, "Host healed while moving")

	// Standing still long enough heals brute, burn and toxin damage
	symptom.last_moved = world.time - symptom.heal_delay - 1
	TEST_ASSERT_EQUAL(symptom.CanHeal(virus), symptom.power, "Healing not allowed after standing still")
	var/burn = host.getFireLoss()
	var/tox = host.getToxLoss()
	symptom.next_activation = 0
	symptom.Activate(virus)
	TEST_ASSERT(host.getBruteLoss() < brute, "Brute damage was not healed")
	TEST_ASSERT(host.getFireLoss() < burn, "Burn damage was not healed")
	TEST_ASSERT(host.getToxLoss() < tox, "Toxin damage was not healed")

	// Thresholds match the threshold description
	var/datum/symptom/heal/symbiotic/strong = new
	virus.stage_rate = 9
	virus.resistance = 9
	strong.Start(virus)
	TEST_ASSERT_EQUAL(strong.heal_delay, 1 SECONDS, "Stage speed 9 did not shorten the heal delay")
	TEST_ASSERT_EQUAL(strong.power, 3, "Resistance 9 did not increase healing")
	strong.End(virus)
	qdel(strong)

	// Toxin lovers are healed, not poisoned
	var/mob/living/carbon/human/slime = allocate(/mob/living/carbon/human)
	slime.set_species(/datum/species/jelly)
	slime.adjustToxLoss(20, forced = TRUE)
	var/slime_tox = slime.getToxLoss()
	symptom.Heal(slime, virus, 1)
	TEST_ASSERT(slime.getToxLoss() < slime_tox, "Toxin-loving host was poisoned instead of healed")

	// Curing removes the movement hook
	var/moved_before_cure = symptom.last_moved
	virus.cure(FALSE)
	TEST_ASSERT(!(virus in host.diseases), "Disease was not cured")
	SEND_SIGNAL(host, COMSIG_MOB_CLIENT_PRE_MOVE, get_turf(host))
	TEST_ASSERT_EQUAL(symptom.last_moved, moved_before_cure, "Movement hook still registered after the disease was cured")

/// AQUILA - teratoma monkey (#240): loot tables, spawning exactly one living tumor, welder destruction
/datum/unit_test/teratoma_monkey

/datum/unit_test/teratoma_monkey/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/list/already_there = spot.contents.Copy() // the test harness keeps its landmark here, never delete it
	// Major teratoma loot (overclocked Pituitary Disruption) contains the monkey again, the clown subtype does not
	var/obj/effect/spawner/lootdrop/teratoma/major/major = new(spot)
	TEST_ASSERT(major.loot[/obj/effect/mob_spawn/teratomamonkey], "Major teratoma loot does not contain the teratoma monkey")
	var/obj/effect/spawner/lootdrop/teratoma/major/clown/clown = new(spot)
	TEST_ASSERT(!clown.loot[/obj/effect/mob_spawn/teratomamonkey], "Clown teratoma loot got the teratoma monkey")
	for(var/atom/movable/spawned in spot) // whatever the two spawners dropped
		if(!(spawned in already_there))
			qdel(spawned)

	// The spawner makes exactly one living tumor and goes away
	var/obj/effect/mob_spawn/teratomamonkey/fleshy = new(spot)
	fleshy.create()
	var/tumors = 0
	for(var/mob/living/carbon/monkey/tumor/T in spot)
		tumors++
		TEST_ASSERT(T.stat != DEAD, "Living tumor spawned dead")
		qdel(T)
	TEST_ASSERT_EQUAL(tumors, 1, "Wrong number of living tumors spawned")
	TEST_ASSERT(QDELETED(fleshy), "Spawner was not used up")

	// Only a lit welder burns it away
	var/mob/living/carbon/human/welder_user = allocate(/mob/living/carbon/human)
	welder_user.a_intent = INTENT_HELP
	var/obj/item/weldingtool/welder = allocate(/obj/item/weldingtool)
	var/obj/effect/mob_spawn/teratomamonkey/mass = new(spot)
	mass.attackby(welder, welder_user)
	TEST_ASSERT(!QDELETED(mass), "Unlit welder destroyed the fleshy mass")
	welder.welding = TRUE
	mass.attackby(welder, welder_user)
	TEST_ASSERT(QDELETED(mass), "Lit welder did not destroy the fleshy mass")
	// Delete the gibs this tick: they streak away on a move loop, and drifting in the gravity-less test area
	// trips an unrelated upstream stack trace during whichever test runs next
	for(var/obj/effect/decal/cleanable/C in range(2, spot))
		if(!(C in already_there))
			qdel(C)

/// AQUILA - both features on one disease together with Pituitary Disruption: no runtimes over many activations
/datum/unit_test/aquila_viruses_together

/datum/unit_test/aquila_viruses_together/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/datum/disease/advance/virus = new
	virus.AddSymptom(new /datum/symptom/heal/symbiotic)
	virus.AddSymptom(new /datum/symptom/growth)
	virus.Refresh()
	host.ForceContractDisease(virus, FALSE, TRUE)
	virus.stage = 5
	var/runtimes_before = GLOB.total_runtimes
	for(var/i in 1 to 20)
		for(var/datum/symptom/S as anything in virus.symptoms)
			S.next_activation = 0
		virus.stage_act()
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes while both symptoms were active")
	virus.cure(FALSE)
	TEST_ASSERT(!(virus in host.diseases), "Combined disease was not cured")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes while curing the combined disease")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
