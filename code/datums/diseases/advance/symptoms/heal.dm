#define TELEPORT_COOLDOWN 60 SECONDS

/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "Nie powinieneś tego widzieć."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmission = 0
	level = -1 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_desc = "<b>Ukrycie 4:</b> leczenie nie będzie już widoczne dla obserwatorów."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	return TRUE //For super calls of subclasses

/datum/symptom/heal/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmission = -2
	level = 6
	power = 2
	prefixes = list("Toxo")
	var/food_conversion = FALSE
	desc = "Wirus szybko rozkłada wszelkie obce substancje w krwiobiegu."
	threshold_desc = "<b>Odporność 7:</b> zwiększa szybkość usuwania substancji.<br><b>Szybkość stadiów 6:</b> zużyte substancje odżywiają nosiciela."

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		food_conversion = TRUE
	if(A.resistance >= 7)
		power = 4

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2))
			to_chat(M, "<span class='notice'>Czujesz łagodne ciepło, gdy twoja krew sama się oczyszcza.</span>")
	return 1

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "Wirus sprawia, że przy ciężkich obrażeniach nosiciel zapada w śpiączkę przypominającą śmierć, a potem szybko naprawia obrażenia. Leczy tylko oparzenia i obrażenia fizyczne."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmission = -3
	level = 8
	severity = -2
	passive_message = "<span class='notice'>Ból ran sprawia, że robi ci się dziwnie sennie.</span>"
	prefixes = list("Sleeping ", "Regenerative ")
	suffixes = list(" Coma")
	var/deathgasp = FALSE
	var/stabilize = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_desc = "<b>Ukrycie 2:</b> zapadając w śpiączkę, nosiciel wygląda na martwego, co uruchamia objawy aktywowane śmiercią.<br><b>Odporność 4:</b> wirus stabilizuje też nosiciela w stanie krytycznym.<br><b>Szybkość stadiów 7:</b> zwiększa szybkość leczenia."

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		power = 1.5
	if(A.resistance >= 4)
		stabilize = TRUE
	if(A.stealth >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/on_stage_change(new_stage, datum/disease/advance/A)  //mostly copy+pasted from the code for self-respiration's TRAIT_NOBREATH stuff
	if(!..())
		return FALSE
	if(A.stage <= 3)
		REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	return TRUE

/datum/symptom/heal/coma/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(stabilize)
		ADD_TRAIT(M, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	if(HAS_TRAIT(M, TRAIT_DEATHCOMA))
		return power
	else if(M.IsUnconscious() || M.stat == UNCONSCIOUS)
		return power * 0.9
	else if(M.stat == SOFT_CRIT)
		return power * 0.5
	else if(M.IsSleeping())
		return power * 0.25
	else if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, "<span class='warning'>Czujesz, jak zapadasz w głęboki, regenerujący sen.</span>")
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), M), 60)

/datum/symptom/heal/coma/proc/coma(mob/living/M)
	if(deathgasp)
		M.fakedeath(TRAIT_REGEN_COMA)
	else
		M.Unconscious(300, TRUE, TRUE)
	M.update_stat()
	M.update_mobility()
	addtimer(CALLBACK(src, PROC_REF(uncoma), M), 300)

/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(!active_coma)
		return
	active_coma = FALSE
	if(deathgasp)
		M.cure_fakedeath(TRAIT_REGEN_COMA)
	else
		M.SetUnconscious(0)
	M.update_stat()
	M.update_mobility()

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYTYPE_ORGANIC))
			M.update_damage_overlays()

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)

	return 1

/datum/symptom/heal/coma/passive_message_condition(mob/living/M)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/symptom/heal/surface
	name = "Superficial Healing"
	desc = "Wirus przyspiesza naturalne gojenie, przez co drobne rany szybko się goją. Powoduje mocne bliznowacenie."
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmission = 0
	severity = -1
	level = 8
	passive_message = "<span class='notice'>Mrowi cię skóra.</span>"
	prefixes = list("Healing ", "Minor ")
	var/threshhold = 15
	var/scarcounter = 0

	threshold_desc = "<b>Szybkość stadiów 8:</b> podwaja szybkość leczenia.<br><b>Odporność 10:</b> poprawia próg leczenia."

/datum/symptom/heal/surface/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8) //stronger healing
		power = 2
	if(A.resistance >= 10)
		threshhold = 30

/datum/symptom/heal/surface/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/healed = FALSE

	if(M.getBruteLoss() && M.getBruteLoss() <= threshhold)
		M.heal_overall_damage(power, required_status = BODYTYPE_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getFireLoss() && M.getFireLoss() <= threshhold)
		M.heal_overall_damage(burn = power, required_status = BODYTYPE_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getToxLoss() && M.getToxLoss() <= threshhold)
		M.adjustToxLoss(-power, FALSE, TRUE)

	if(healed)
		if(prob(10))
			to_chat(M, "<span class='notice'>Twoje rany się goją, zostawiając ci nową bliznę.</span>")
		if(scarcounter >= 200 && !HAS_TRAIT(M, TRAIT_DISFIGURED))
			ADD_TRAIT(M, TRAIT_DISFIGURED, DISEASE_TRAIT)
			M.visible_message("<span class='warning'>Twarz [M] staje się nie do poznania.</span>", "<span class='userdanger'>Przez blizny twoja twarz jest nie do poznania.</span>")
	return healed


/datum/symptom/heal/surface/passive_message_condition(mob/living/M)
	return M.getBruteLoss() <= threshhold || M.getFireLoss() <= threshhold

/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmission = 1
	level = 6
	prefixes = list("Metabolic ", "Junkie's ", "Chemical ")
	bodies = list("Hunger")
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "Wirus gwałtownie przyspiesza metabolizm nosiciela, przez co przetwarza on substancje dwa razy szybciej, ale też jest bardziej głodny."
	threshold_desc = "<b>Ukrycie 3:</b> zmniejsza tempo głodnienia.<br><b>Szybkość stadiów 10:</b> metabolizm substancji jest potrojony zamiast podwojony."

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 10)
		triple_metabolism = TRUE
	if(A.stealth >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	C.reagents.metabolize(C, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	if(triple_metabolism)
		C.reagents.metabolize(C, can_overdose=TRUE)
	C.overeatduration = max(C.overeatduration - 2, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.adjust_nutrition(-lost_nutrition * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2))
		to_chat(C, "<span class='notice'>Czujesz dziwne bulgotanie w żołądku, jakby pracował o wiele szybciej niż zwykle.</span>")
	return 1

/*
//////////////////////////////////////
im not even gonna bother with these for the following symptoms. typed em out, code was deleted, had to start over, read the symptoms yourself.

//////////////////////////////////////
*/

/datum/symptom/EMP
	name = "Organic Flux Induction"
	desc = "Wywołuje zakłócenia elektromagnetyczne wokół nosiciela"
	stealth = 0
	resistance = -1
	stage_speed = -1
	transmission = -2
	level = 6
	severity = 2
	symptom_delay_min = 15
	symptom_delay_max = 40
	prefixes = list("Magnetic ", "Electro")
	bodies = list("Magnet")
	var/bigemp = FALSE
	var/cellheal = FALSE
	threshold_desc = "<b>Ukrycie 2:</b> choroba resetuje DNA komórek, szybko lecząc uszkodzenia komórkowe i mutacje.<br><b>Transmisja 8:</b> EMP działa też na elektronikę obok nosiciela."

/datum/symptom/EMP/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 2) //if you combine this with pituitary disruption, you have the two most downside-heavy symptoms available
		severity -= 1
	if(A.transmission >= 8)
		severity += 1

/datum/symptom/EMP/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2)
		cellheal = TRUE
	if(A.transmission >= 8)
		bigemp = TRUE

/datum/symptom/EMP/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.emp_act(EMP_HEAVY)
			if(cellheal)
				M.adjustCloneLoss(-30)
				M.reagents.add_reagent(/datum/reagent/medicine/mutadone = 1)
			if(bigemp)
				empulse(M.loc, 0, 1)
			to_chat(M, "<span class='userdanger'>[pick("Your mind fills with static!", "You feel a jolt!", "Your sense of direction flickers out!")]</span>")
		else
			to_chat(M, "<span class='notice'>[pick("You feel a slight tug toward the station's wall.", "Nearby electronics flicker.", "Your hair stands on end.")]</span>")
	return

/datum/symptom/sweat
	name = "Hyperperspiration"
	desc = "Sprawia, że nosiciel obficie się poci, zostawiając małe kałuże wody i gasząc małe pożary"
	stealth = 1
	resistance = -1
	stage_speed = 0
	transmission = 1
	level = 6
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Sweaty ", "Moist ", "Mister ")
	bodies = list("Perspiration")
	var/bigsweat = FALSE
	var/toxheal = FALSE
	var/ammonia = FALSE
	threshold_desc = "<b>Transmisja 4:</b> produkcja potu rośnie do tego stopnia, że gasi pożary w okolicy.<br><b>Transmisja 6:</b> objaw leczy obrażenia od toksyn i usuwa substancje.<br><b>Szybkość stadiów 6:</b> pot nosiciela zawiera ślady amoniaku."

/datum/symptom/sweat/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 6)
		severity -= 1

/datum/symptom/sweat/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 6)
		toxheal = TRUE
	if(A.transmission >= 4)
		bigsweat = TRUE
	if(A.stage_rate >= 6)
		ammonia = TRUE

/datum/symptom/sweat/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjust_fire_stacks(-5)
			if(!ammonia && prob(30))
				var/turf/open/OT = get_turf(M)
				if(istype(OT))
					to_chat(M, "<span class='danger'>Pot zbiera się w kałużę!</span>")
					OT.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
			if(bigsweat)
				var/obj/effect/sweatsplash/S = new(M.loc)
				if(toxheal)
					for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
						M.reagents.remove_reagent(R.type, 5)
						S.reagents.add_reagent(R.type, 5)
					M.adjustToxLoss(-20, forced = TRUE)
				if(ammonia)
					S.reagents.add_reagent(/datum/reagent/space_cleaner, 5)
				S.splash()
				to_chat(M, "<span class='userdanger'>Wypacasz z siebie prawie wszystko!</span>")
		else
			to_chat(M, "<span class='notice'>[pick("You feel moist.", "Your clothes are soaked.", "You're sweating buckets!")]</span>")
	return

/obj/effect/sweatsplash
	name = "Sweatsplash"

/obj/effect/sweatsplash/Initialize(mapload)
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 10)

/obj/effect/sweatsplash/proc/splash()
	chem_splash(loc, 2, list(reagents))
	qdel(src)

/datum/symptom/teleport
	name = "Thermal Retrostable Displacement"
	desc = "Gdy jest za gorąco lub za zimno, nosiciel wraca do niedawnego miejsca, w którym doświadczył bezpiecznej homeostazy."
	stealth = 1
	resistance = 2
	stage_speed = -2
	transmission = -3
	level = 8
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Quantum ", "Thermal ")
	bodies = list("Teleport")
	var/telethreshold = 15
	var/burnheal = FALSE
	var/turf/open/location_return = null
	COOLDOWN_DECLARE(teleport_cooldown)
	threshold_desc = "<b>Odporność 6:</b> choroba działa na mniejszą skalę, przywracając spaloną tkankę do zdrowia.<br><b>Transmisja 8:</b> choroba staje się aktywniejsza, aktywując się w węższym zakresie temperatur."

/datum/symptom/teleport/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6)
		severity -= 1
		if(A.transmission >= 8)
			severity -= 1

/datum/symptom/teleport/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 6)
		burnheal = TRUE
	if(A.transmission >= 8)
		telethreshold = -10
		power = 2

/datum/symptom/teleport/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(burnheal)
				M.heal_overall_damage(0, 1.5 * power) //no required_status checks here, this does all bodyparts equally

			if(COOLDOWN_FINISHED(src, teleport_cooldown) && (M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT || M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT))
				location_return = get_turf(M)	//sets up return point
				to_chat(M, "<span class='warning'>Letnia temperatura sprawia, że czujesz się dziwnie!</span>")
				COOLDOWN_START(src, teleport_cooldown, (TELEPORT_COOLDOWN * 5) + (rand(1, 300) * 10))
			if(location_return)
				if(location_return.z != M.loc.z)
					location_return = null
					COOLDOWN_RESET(src, teleport_cooldown)
				else if(((M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT + telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTHEAT)) || (M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT - telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTCOLD)) || (burnheal && M.getFireLoss() > 60 + telethreshold)))
					do_sparks(5, FALSE, M)
					to_chat(M, "<span class='userdanger'>Zmiana temperatury przywraca cię do poprzedniego stanu przestrzennego!</span>")
					do_teleport(M, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
					do_sparks(5, FALSE, M)
					if(burnheal)
						M.adjust_fire_stacks(-10)
					location_return = null
					COOLDOWN_START(src, teleport_cooldown, TELEPORT_COOLDOWN)
			if(COOLDOWN_FINISHED(src, teleport_cooldown))
				location_return = null
		else
			if(prob(7))
				to_chat(M, "<span class='notice'>[pick("Your warm breath fizzles out of existence.", "You feel attracted to temperate climates", "You feel like you're forgetting something")]</span>")
	return

/datum/symptom/growth
	name = "Pituitary Disruption"
	desc = "Powoduje niekontrolowany wzrost nosiciela."
	stealth = -3
	resistance = -2
	stage_speed = 1
	transmission = -2
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Blood ", "Meat ", "Flesh ")
	bodies = list("Giant")
	var/current_size = 1
	var/tetsuo = FALSE
	var/bruteheal = FALSE
	var/sizemult = 1
	var/datum/mind/ownermind
	threshold_desc = "<b>Szybkość stadiów 6:</b> choroba szybko leczy obrażenia fizyczne, ale powoduje wydalanie łagodnych guzów.<br><b>Szybkość stadiów 12:</b> choroba niewiarygodnie szybko leczy obrażenia fizyczne, ale pogarsza zdrowie komórek i sprawia, że guzy stają się bardziej zaawansowane. Choroba odtwarza też utracone kończyny."

/datum/symptom/growth/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 6)
		severity -= 1
		if(A.stage_rate >= 12)
			severity += 3

/datum/symptom/growth/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		bruteheal = TRUE
		if(A.stage_rate >= 12)
			tetsuo = TRUE
			power = 3 //should make this symptom actually worth it
	var/mob/living/carbon/M = A.affected_mob
	ownermind = M.mind
	if(!A.carrier && !A.dormant)
		sizemult = CLAMP((0.5 + A.stage_rate / 10), 1.1, 1.5)
		M.resize = sizemult
		M.update_transform()

/datum/symptom/growth/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(prob(5) && bruteheal)
				to_chat(M, "<span class='userdanger'>Wymiotujesz, a z twojego gardła tryska krwawa breja!</span>")
				M.Immobilize(5)
				M.add_splatter_floor()
				playsound(get_turf(M), 'sound/effects/splat.ogg', 50, 1)
				if(prob(60) && M.mind && ishuman(M))
					if(tetsuo && prob(15))
						if(A.affected_mob.job == JOB_NAME_CLOWN)
							new /obj/effect/spawner/lootdrop/teratoma/major/clown(M.loc)
						if(MOB_ROBOTIC in A.infectable_biotypes)
							new /obj/effect/decal/cleanable/robot_debris(M.loc)
							new /obj/effect/spawner/lootdrop/teratoma/robot(M.loc)
					new /obj/effect/spawner/lootdrop/teratoma/minor(M.loc)
				if(tetsuo)
					var/list/missing = M.get_missing_limbs()
					if(prob(35)) // AQUILA EDIT - as before BeeStation#7421, any host can drop major teratoma loot (and its teratoma monkey) again
						new /obj/effect/decal/cleanable/blood/gibs(M.loc) //yes. this is very messy. very, very messy.
						new /obj/effect/spawner/lootdrop/teratoma/major(M.loc)
					if(missing.len) //we regrow one missing limb
						for(var/Z in missing) //uses the same text and sound a ling's regen does. This can false-flag the host as a changeling.
							if(M.regenerate_limb(Z, TRUE))
								playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
								M.visible_message("<span class='warning'>Brakujące kończyny [M] odrastają z głośnym, groteskowym dźwiękiem!</span>",
									"<span class='userdanger'>Twoje kończyny odrastają z głośnym chrzęstem, sprawiając ci ogromny ból!</span>",
									"<span class='italics'>Słyszysz rozrywanie i szarpanie organicznej materii!</span>")
								M.emote("scream")
								if(Z == BODY_ZONE_HEAD) //if we regenerate the head, make sure the mob still owns us
									if(isliving(ownermind.current))
										var/mob/living/owner = ownermind.current
										if(owner.stat != DEAD)//if they have a new mob, forget they exist
											ownermind = null
											break
										if(owner == M) //they're already in control of this body, probably because their brain isn't in the head!
											break
									if(ishuman(M))
										var/mob/living/carbon/human/H = M
										H.dna.species.regenerate_organs(H, replace_current = FALSE) //get head organs, including the brain, back
									ownermind.transfer_to(M)
									M.grab_ghost()
								break
			if(bruteheal)
				M.heal_overall_damage(2 * power, required_status = BODYTYPE_ORGANIC)
				if(prob(33) && tetsuo)
					M.adjustCloneLoss(1)
		else
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("You feel bloated.", "The station seems small.", "You are the strongest.")]</span>")
	return

/datum/symptom/growth/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, "<span class='notice'>Kurcząc się, tracisz równowagę i potykasz się, a nogi się pod tobą uginają!</span>")
	M.resize = 1/sizemult
	M.update_transform()

#undef TELEPORT_COOLDOWN

/datum/symptom/vampirism
	name = "Hemetophagy"
	desc = "Nosiciel wchłania krew z zewnętrznych źródeł i bezproblemowo włącza ją do własnego krwiobiegu, bez względu na grupę krwi i sposób przyjęcia. Wirus jednak powoli pochłania krew nosiciela"
	stealth = 1
	resistance = -2
	stage_speed = 1
	transmission = 2
	level = 9
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Porphyric ", "Hemo")
	bodies = list("Blood")
	var/bloodpoints = 0
	var/maxbloodpoints = 50
	var/bloodtypearchive
	var/bruteheal = FALSE
	var/aggression = FALSE
	var/vampire = FALSE
	var/mob/living/carbon/human/bloodbag
	threshold_desc = "<b>Transmisja 4:</b> wirus przetwarza nadmiar wchłoniętej krwi na regenerującą biomasę, lecząc obrażenia fizyczne.<br><b>Szybkość stadiów 7:</b> wirus staje się agresywniejszy, przyswajając krew i lecząc szybciej, ale też szybciej wysysając krew nosiciela<br><b>Transmisja 6:</b> wirus agresywnie przyswaja krew, wchłaniając przylegające kałuże krwi oraz wysysając krew z otwartych ran osób w fizycznym kontakcie z nosicielem."

/datum/symptom/vampirism/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 4)
		severity -= 1
	if((A.stealth >= 2) && (A.transmission >= 6) && A.process_dead)
		severity -= 1
		bodies = list("Vampir", "Blood")

/datum/symptom/vampirism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 4)
		bruteheal = TRUE
	if(A.transmission >= 6)
		aggression = TRUE
		maxbloodpoints += 50
	if(A.stage_rate >= 7)
		power += 1
	if((A.stealth >= 2) && (A.transmission >= 6) && A.process_dead) //this is low transmission for 2 reasons: transmission is hard to raise, especially with stealth, and i dont want this to be obligated to be transmittable
		vampire = TRUE
		maxbloodpoints += 50
		power += 1
	if(ishuman(A.affected_mob) && A.affected_mob.get_blood_id() == /datum/reagent/blood)
		var/mob/living/carbon/human/H = A.affected_mob
		bloodtypearchive = H.dna.blood_type
		H.dna.blood_type = "U"

/datum/symptom/vampirism/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1 to 4)
			if(prob(5))
				to_chat(M, "<span class='warning'>[pick("You feel cold...", "You feel a bit thirsty", "It dawns upon you that every single human on this station has warm blood pulsing through their veins.")]</span>")
		if(5)
			ADD_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
			var/grabbedblood = succ(M) //before adding sucked blood to bloodpoints, immediately try to heal bloodloss
			if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood)
				var/missing = BLOOD_VOLUME_NORMAL - M.blood_volume
				var/inflated = grabbedblood * 4
				M.blood_volume = min(M.blood_volume + inflated, BLOOD_VOLUME_NORMAL)
				bloodpoints += round(max(0, (inflated - missing)/4))
			else if((M.blood_volume >= BLOOD_VOLUME_NORMAL + 4) && (bloodpoints < maxbloodpoints))//so drinking blood accumulates bloodpoints
				M.blood_volume = (M.blood_volume - 4)
				bloodpoints += 1
			else
				bloodpoints += max(0, grabbedblood)
			for(var/I in 1 to power)//power doesnt increase efficiency, just usage.
				if(bloodpoints > 0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.bleed_rate >= 2 && bruteheal && bloodpoints)
							bloodpoints -= 1
							H.bleed_rate = max(0, (H.bleed_rate - 2))
					if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood) //bloodloss is prioritized over healing brute
						bloodpoints -= 1
						M.blood_volume = max((M.blood_volume + 3 * power), BLOOD_VOLUME_NORMAL) //bloodpoints are valued at 4 units of blood volume per point, so this is diminished
					else if(bruteheal && M.getBruteLoss())
						bloodpoints -= 1
						M.heal_overall_damage(2, required_status = BODYTYPE_ORGANIC)
					if(prob(60) && !M.stat)
						bloodpoints -- //you cant just accumulate blood and keep it as a battery of healing. the quicker the symptom is, the faster your bloodpoints decay
				else if(prob(20) && M.blood_volume >= BLOOD_VOLUME_BAD)//the virus continues to extract blood if you dont have any stored up. higher probability due to BP value
					M.blood_volume = (M.blood_volume - 1)

			if(!bloodpoints && prob(3))
				to_chat(M, "<span class='warning'>[pick("You feel a pang of thirst.", "No food can sate your hunger", "Blood...")]</span>")

/datum/symptom/vampirism/End(datum/disease/advance/A)
	. = ..()
	REMOVE_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
	if(bloodtypearchive && ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.dna.blood_type = bloodtypearchive

/datum/symptom/vampirism/proc/succ(mob/living/carbon/M) //you dont need the blood reagent to suck blood. however, you need to have blood, or at least a shared blood reagent, for most of the other uses
	var/gainedpoints = 0
	if(bloodbag && !bloodbag.blood_volume) //we've exsanguinated them!
		bloodbag = null
	if(ishuman(M) && M.stat == DEAD && vampire)
		var/mob/living/carbon/human/H = M
		var/possibledist = power + 1
		if(M.get_blood_id() != /datum/reagent/blood)
			possibledist = 1
		if(!(NOBLOOD in H.dna.species.species_traits)) //if you dont have blood, well... sucks to be you
			H.setOxyLoss(0,0) //this is so a crit person still revives if suffocated
			if(bloodpoints >= 200 && H.health > 0 && H.blood_volume >= BLOOD_VOLUME_NORMAL) //note that you need to actually need to heal, so a maxed out virus won't be bringing you back instantly in most cases. *even so*, if this needs to be nerfed ill do it in a heartbeat
				H.revive(0)
				H.visible_message("<span class='warning'>Skóra [H.name] nabiera różowego odcienia i zaczyna się poruszać. Znów żyje!</span>", "<span class='userdanger'>Gdy twoje ciało wypełnia się świeżą krwią, znów czujesz kończyny, a wraz z nimi nienasycone pragnienie krwi.</span>")
				bloodpoints = 0
				return 0
			else if(bloodbag && bloodbag.blood_volume && (bloodbag.stat || bloodbag.bleed_rate))
				if(get_dist(bloodbag, H) <= 1 && bloodbag.z == H.z)
					var/amt = ((bloodbag.stat * 2) + 2) * power
					var/excess = max(((min(amt, bloodbag.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 2), 0)
					H.blood_volume = min(H.blood_volume + min(amt, bloodbag.blood_volume), BLOOD_VOLUME_NORMAL)
					bloodbag.blood_volume = max(bloodbag.blood_volume - amt, 0)
					bloodpoints += max(excess, 0)
					playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 10, 1)
					bloodbag.visible_message("<span class='warning'>Krew wypływa z ran [bloodbag.name] do zwłok [H.name]!</span>", "<span class='userdanger'>Krew wypływa z twoich ran do zwłok [H.name]!</span>")
				else if(get_dist(bloodbag, H) >= possibledist) //they've been taken out of range.
					bloodbag = null
					return
				else if(bloodpoints >= 2)
					var/turf/T = H.loc
					var/obj/effect/decal/cleanable/blood/influenceone = (locate(/obj/effect/decal/cleanable/blood) in H.loc)
					if(!influenceone && bloodpoints >= 2)
						H.add_splatter_floor(T)
						playsound(T, 'sound/effects/splat.ogg', 50, 1)
						bloodpoints -= 2
						return 0
					else
						var/todir = get_dir(H, bloodbag)
						var/targetloc = bloodbag.loc
						var/dist = get_dist(H, bloodbag)
						for(var/i=0 to dist)
							T = get_step(T, todir)
							todir = get_dir(T, bloodbag)
							var/obj/effect/decal/cleanable/blood/influence = (locate(/obj/effect/decal/cleanable/blood) in T)
							if(!influence && bloodpoints >= 2)
								H.add_splatter_floor(T)
								playsound(T, 'sound/effects/splat.ogg', 50, 1)
								bloodpoints -= 2
								return 0
							else if(T == targetloc && bloodpoints >= 2)
								bloodbag.throw_at(H, 1, 1)
								bloodpoints -= 2
								bloodbag.visible_message("<span class='warning'>Strumień krwi popycha [bloodbag.name] w stronę zwłok [H.name]!</span>")
								playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 25, 1)
								return 0
			else
				var/list/candidates = list()
				for(var/mob/living/carbon/human/C in ohearers(min(bloodpoints/4, possibledist), H))
					if(NOBLOOD in C.dna.species.species_traits)
						continue
					if(C.stat && C.blood_volume && C.get_blood_id() == H.get_blood_id())
						candidates += C
				for(var/prospect in candidates)
					candidates[prospect] = 1
					if(ishuman(prospect))
						var/mob/living/carbon/human/candidate = prospect
						candidates[prospect] += (candidate.stat - 1)
						candidates[prospect] += (3 - get_dist(candidate, H)) * 2
						candidates[prospect] += round(candidate.blood_volume / 150)
				bloodbag = pickweight(candidates) //dont return here

	if(bloodpoints >= maxbloodpoints)
		return 0
	if(ishuman(M) && aggression) //first, try to suck those the host is actively grabbing
		var/mob/living/carbon/human/H = M
		if(H.pulling && ishuman(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
			var/mob/living/carbon/human/C = H.pulling
			if(!C.bleed_rate && vampire && C.can_inject() && H.grab_state && C.get_blood_id() == H.get_blood_id() && !(NOBLOOD in C.dna.species.species_traits))//aggressive grab as a "vampire" starts the target bleeding
				C.bleed_rate += 1
				C.visible_message("<span class='warning'>Na skórze [C.name] otwierają się rany, gdy [H.name] mocno go ściska!</span>", "<span class='userdanger'>Pod dotykiem [H.name] zaczynasz krwawić!</span>")
			if(C.blood_volume && C.can_inject() &&(C.bleed_rate && (!C.bleedsuppress || vampire )) && C.get_blood_id() == H.get_blood_id() && !(NOBLOOD in C.dna.species.species_traits))
				var/amt = (H.grab_state + C.stat + 2) * power
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints = CLAMP(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message("<span class='warning'>Krew wypływa z ran [C.name] do [H.name]!</span>", "<span class='userdanger'>Krew wypływa z twoich ran do [H.name]!</span>")
					playsound(C.loc, 'sound/magic/exit_blood.ogg', 25, 1)
					return gainedpoints
	if(locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/obj/effect/decal/cleanable/blood/initialstain = (locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/list/stains = list()
		var/suckamt = power + 1
		if(aggression)
			for(var/obj/effect/decal/cleanable/blood/contiguousstain in orange(1, M))
				if(suckamt)
					suckamt --
					stains += contiguousstain
			if(suckamt)
				suckamt --
				stains += initialstain
		for(var/obj/effect/decal/cleanable/blood/stain in stains) //this doesnt use switch(type) because that doesnt check subtypes
			if(istype(stain, /obj/effect/decal/cleanable/blood/gibs/old))
				gainedpoints += 3
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/old))
				gainedpoints += 1
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/gibs))
				gainedpoints += 5
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/footprints) || istype(stain, /obj/effect/decal/cleanable/blood/tracks) || istype(stain, /obj/effect/decal/cleanable/blood/drip))
				qdel(stain)//these types of stain are generally very easy to make, we don't use these
			else if(istype(stain, /obj/effect/decal/cleanable/blood))
				gainedpoints += 2
				qdel(stain)
		if(gainedpoints)
			playsound(M.loc, 'sound/magic/exit_blood.ogg', 50, 1)
			M.visible_message("<span class='warning'>Krew z podłogi wpływa do [M.name]!</span>", "<span class='warning'>Pochłaniasz rozlaną krew</span>")
		return CLAMP(gainedpoints, 0, maxbloodpoints - bloodpoints)
	if(ishuman(M) && aggression)//finally, attack mobs touching the host.
		var/mob/living/carbon/human/H = M
		for(var/mob/living/carbon/human/C in ohearers(1, H))
			if(NOBLOOD in C.dna.species.species_traits)
				continue
			if((C.pulling && C.pulling == H) || (C.loc == H.loc) && C.bleed_rate && C.get_blood_id() == H.get_blood_id())
				var/amt = (2 * power)
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4 * power), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints += CLAMP(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message("<span class='warning'>Krew wypływa z ran [C.name] do [H.name]!</span>", "<span class='userdanger'>Krew wypływa z twoich ran do [H.name]!</span>")
		return CLAMP(gainedpoints, 0, maxbloodpoints - bloodpoints)


/datum/symptom/parasite
	name = "Xenobiological Symbiosis"
	desc = "Wirus zawiera utajone plany DNA do stworzenia jaja robaka pożerającego toksyny, który pasożytuje na szlamach i ludziach-szlamach. Jego normalnie toksyczne, zakaźne mięso po ugotowaniu staje się bezpieczne i pyszne."
	stealth = 1
	resistance = 2
	stage_speed = 2
	transmission = -1
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Parasitic ")
	bodies = list("Cytoplasm", "Slime")
	var/list/grubs = list()
	var/toxheal = FALSE
	threshold_desc = "<b>Ukrycie 2:</b> rozwijające się larwy mogą pochłaniać toksyny z krwiobiegu nosiciela.<br><b>Szybkość stadiów 6:</b> rodzi się więcej larw i szybciej opuszczają nosiciela."

/datum/symptom/parasite/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 2)
		severity -= 2
		prefixes = list("Symbiotic ")
	if(A.stage_rate >= 6)
		severity = (severity * 2)

/datum/symptom/parasite/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2)
		toxheal = TRUE
	if(A.stage_rate >= 6)
		power += 1

/datum/symptom/parasite/proc/isslimetarget(var/mob/living/carbon/M)
	if(isslimeperson(M) || isluminescent(M) || isjellyperson(M) || isoozeling(M) || isstargazer(M))
		return TRUE
	else
		return FALSE

/datum/symptom/parasite/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			to_chat(M, "<span class='warning'>[pick("You feel something crawling in your veins!", "You feel an unpleasant throbbing.", "You hear something squishy in your ear.")]</span>")
		if(3 to 5)
			var/slowdown = 0
			for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)//check if grubs need to be born, then feed existing grubs, or get them closer to hatching
				var/efficacy = grub.growthstage / 2
				if(grub.growthstage >= 3 || grub.patience <= 0 || grub.stat)
					M.visible_message("<span class='warning'>[M] wymiotuje obrzydliwym robakiem!</span>", \
							"<span class='userdanger'>Wymiotujesz dużym, wijącym się robakiem!</span>")
					M.Stun((grub.growthstage * 10))
					playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)
					grub.forceMove(M.loc)
					grub.togglehibernation()
					grubs -= grub
					continue
				slowdown = (min(3, slowdown + efficacy))
				if((M.getToxLoss() && toxheal) || isslimetarget(M))
					M.adjustToxLoss(-efficacy)
					if(grub.growthstage < (A.stage - 2))
						grub.food += 1 * power
					grub.patience = (rand(60, 120) / power)
				else
					grub.patience --
			if(((M.getToxLoss() > (LAZYLEN(grubs) * (30/power))) || isslimetarget(M)) && prob(10 * power) && (LAZYLEN(grubs) < power * 2))
				var/mob/living/simple_animal/hostile/redgrub/grub = new(src)// add new grubs if there's enough toxin for them
				grub.food = 10
				grubs += grub
				grub.togglehibernation()
				grub.grubdisease = list(A)
			if(prob(LAZYLEN(grubs) * (6/power)))// so you know its working. power lowers this so it doesnt spam you at high grub counts
				to_chat(M, "<span class='warning'>Czujesz, jak coś wije się w twoim wnętrzu!</span>")
			M.add_movespeed_modifier(MOVESPEED_ID_GRUB_VIRUS_SLOWDOWN, override = TRUE, multiplicative_slowdown = max(slowdown - 0.5, 0))

/datum/symptom/parasite/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	M.remove_movespeed_modifier(MOVESPEED_ID_GRUB_VIRUS_SLOWDOWN, TRUE)
	for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)
		M.visible_message("<span class='warning'>[M] wymiotuje obrzydliwym robakiem!</span>", \
				"<span class='userdanger'>Wymiotujesz dużym, wijącym się robakiem!</span>")
		M.Stun((grub.growthstage * 10))
		grub.forceMove(M.loc)
		grub.togglehibernation()
		playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)

/datum/symptom/parasite/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)
		grub.forceMove(M.loc)
		grub.togglehibernation()
		playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)
	if(isslimetarget(M) && A.stage >= 3)
		for(var/I in 1 to (rand(1, A.stage)))
			var/mob/living/simple_animal/hostile/redgrub/grub = new(M.loc)
			grub.grubdisease = list(A)
		M.gib()
		M.visible_message("<span class='warning'>Rój czerwonych robaków zjada [M] żywcem!</span>")

/datum/symptom/jitters
	name = "Hyperactivity"
	desc = "Wirus powoduje niepokój, nerwowość i nadpobudliwość, zwiększając tempo, w jakim nosiciel musi jeść, ale sprawiając, że trudniej go zmęczyć"
	stealth = -4
	resistance = 0
	stage_speed = 2
	transmission = -3
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Gray ", "Amped ", "Nervous ")
	var/clearcc = FALSE
	threshold_desc = "<b>Odporność 8:</b> wirus powoduje jeszcze szybszą utratę składników odżywczych, mogąc doprowadzić do zagłodzenia, ale znacznie zwiększa zysk energii<br><b>Szybkość stadiów 8:</b> wirus powoduje skrajną nerwowość i paranoję, a w efekcie okazjonalne halucynacje i skrajny niepokój, ale ogólnie więcej energii i szybsze otrząsanie się z ogłuszenia."

/datum/symptom/jitters/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 8)
		severity -= 1
	if(A.stage_rate >= 8)
		severity -= 1
		prefixes = list("Gray ", "Amped ", "Paranoid ")
		suffixes = list(" Madness", " Insanity")

/datum/symptom/jitters/Start(datum/disease/advance/A)
	if(!..())
		return
	power = initial(power)
	if(A.resistance >= 8)
		power += 2
	if(A.stage_rate >= 8)
		power += 1
		clearcc = TRUE

/datum/symptom/jitters/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(2 to 3)
			if(prob(power) && M.stat)
				M.Jitter(2 * power)
				M.emote("twitch")
				to_chat(M, "<span class='notice'>[pick("You feel energetic!", "You feel well-rested.", "You feel great!")]</span>")
		if(4 to 5)
			M.adjustStaminaLoss((-5 * power), 0)
			M.drowsyness = max(0, M.drowsyness - 10 * power)
			M.AdjustSleeping(-10 * power)
			M.AdjustUnconscious(-10 * power)
			if(prob(power) && prob(50))
				if(M.stat)
					M.emote("twitch")
					M.Jitter(2 * power)
				to_chat(M, "<span class='notice'>[pick("You feel nervous...", "You feel anxious.", "You feel like everything is moving in slow motion.")]</span>")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "hyperactivity", /datum/mood_event/nervous)
			if(M.satiety > NUTRITION_LEVEL_HUNGRY - (30 * power))
				M.satiety = max(NUTRITION_LEVEL_HUNGRY - (30 * power), M.satiety - (2 * power))
			if(prob(25))
				M.Jitter(2 * power)
			if(clearcc)
				var/realpower = power
				if(prob(power) && prob(50))
					realpower = power + 10
					if(M.stat)
						M.emote("scream")
					M.hallucination = min(40, M.hallucination + (5 * power))
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "hyperactivity", /datum/mood_event/paranoid)
				M.AdjustAllImmobility((realpower * -10),TRUE)
