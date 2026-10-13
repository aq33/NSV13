// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)


/// AQUILA - pająki z tg: zdolności, dorastanie, sieci z wygładzaniem, kokon i jaja
/datum/unit_test/aquila_spiders

/datum/unit_test/aquila_spiders/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = get_step(start, EAST)

	// Każdy pająk olbrzymi dostaje sieć i swoje zdolności
	var/mob/living/simple_animal/hostile/spider/giant/midwife/mother = allocate(/mob/living/simple_animal/hostile/spider/giant/midwife)
	TEST_ASSERT(istype(mother.web_action, /datum/action/cooldown/spider/lay_web/sealer), "Matka nie ma sieci uszczelniającej")
	TEST_ASSERT(locate(/datum/action/cooldown/spider/lay_eggs/enriched) in mother.actions, "Matka nie umie składać wzbogaconych jaj")
	TEST_ASSERT(locate(/datum/action/cooldown/spider/wrap) in mother.actions, "Matka nie umie owijać")
	var/mob/living/simple_animal/hostile/spider/giant/tarantula/tarantula = allocate(/mob/living/simple_animal/hostile/spider/giant/tarantula)
	TEST_ASSERT(tarantula.charge, "Tarantula nie ma szarży")
	var/mob/living/simple_animal/hostile/spider/giant/tank/tank = allocate(/mob/living/simple_animal/hostile/spider/giant/tank)
	TEST_ASSERT(tank.mend_action, "Pająk czołg nie umie się leczyć")

	// Pajęczyny łączą się ze sobą
	// Pokój testowy ma ściany, z którymi sieć też się łączy, więc sprawdzamy tylko bity wschód/zachód
	var/obj/structure/spider/stickyweb/web_one = allocate(/obj/structure/spider/stickyweb, start)
	TEST_ASSERT(!(web_junction(web_one) & EAST), "Samotna sieć łączy się na wschód ([web_one.icon_state])")
	var/obj/structure/spider/stickyweb/web_two = allocate(/obj/structure/spider/stickyweb, east)
	TEST_ASSERT(web_junction(web_one) & EAST, "Sieć nie połączyła się z sąsiadem na wschodzie ([web_one.icon_state])")
	TEST_ASSERT(web_junction(web_two) & WEST, "Sieć nie połączyła się z sąsiadem na zachodzie ([web_two.icon_state])")
	qdel(web_two)
	TEST_ASSERT(!(web_junction(web_one) & EAST), "Sieć nie odświeżyła się po zniszczeniu sąsiada ([web_one.icon_state])")

	// Druga warstwa sieci uszczelniającej robi ścianę, która trzyma powietrze
	var/datum/action/cooldown/spider/lay_web/sealer/sealer = mother.web_action
	sealer.plant_web(start, web_one)
	var/obj/structure/spider/stickyweb/sealed/wall = locate() in start
	TEST_ASSERT(wall, "Druga warstwa nie zrobiła ściany")
	TEST_ASSERT(!wall.CanAtmosPass, "Ściana z sieci przepuszcza powietrze")
	TEST_ASSERT(!sealer.can_web_turf(start), "Na ścianę z sieci da się dalej snuć")
	qdel(wall)

	// Pajączek wyrasta na młodego pająka, młody na olbrzymiego
	var/mob/living/simple_animal/hostile/spider/growing/spiderling/hunter/baby = allocate(/mob/living/simple_animal/hostile/spider/growing/spiderling/hunter)
	baby.directive = "test"
	baby.grow_up()
	var/mob/living/simple_animal/hostile/spider/growing/young/hunter/young = locate() in start
	TEST_ASSERT(young, "Pajączek łowca nie wyrósł na młodego łowcę")
	TEST_ASSERT_EQUAL(young.directive, "test", "Młody pająk zgubił rozkaz")
	young.grow_up()
	var/mob/living/simple_animal/hostile/spider/giant/hunter/adult = locate() in start
	TEST_ASSERT(adult, "Młody łowca nie wyrósł na łowcę")
	allocated += adult

	// Owinięty człowiek trafia do kokonu i ładuje wzbogacone jaja
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, east)
	var/datum/action/cooldown/spider/wrap/wrap = locate() in mother.actions
	var/datum/action/cooldown/spider/lay_eggs/enriched/enriched = locate() in mother.actions
	wrap.wrap_target(victim)
	TEST_ASSERT(istype(victim.loc, /obj/structure/spider/cocoon), "Ofiara nie trafiła do kokonu")
	TEST_ASSERT_EQUAL(victim.stat, DEAD, "Ofiara przeżyła wyssanie")
	TEST_ASSERT_EQUAL(mother.egg_charges, 2, "Wyssanie nie dało dwóch ładunków na jaja")
	var/obj/structure/spider/cocoon/cocoon = victim.loc
	qdel(cocoon)
	TEST_ASSERT(isturf(victim.loc), "Zniszczony kokon nie wypuścił ofiary")

	// Jaja przekazują rozkaz i nie wykluwają się bez dojrzenia
	// Koszty jaj: zwykłe 1, nietypowe 2, wzbogacone 3
	var/datum/action/cooldown/spider/lay_eggs/abnormal/abnormal = locate() in mother.actions
	TEST_ASSERT(!enriched.has_charges(), "Wzbogacone jaja da się złożyć za 2 ładunki")
	TEST_ASSERT(abnormal.has_charges(), "Nietypowych jaj nie da się złożyć za 2 ładunki")
	mother.adjust_egg_charges(1)
	TEST_ASSERT(enriched.has_charges(), "Wzbogaconych jaj nie da się złożyć za 3 ładunki")
	enriched.lay_egg(start)
	var/obj/structure/spider/eggcluster/enriched/eggs = locate() in start
	TEST_ASSERT(eggs, "Nie złożono wzbogaconych jaj")
	allocated += eggs
	TEST_ASSERT_EQUAL(mother.egg_charges, 0, "Wzbogacone jaja nie zużyły 3 ładunków")
	for(var/datum/action/cooldown/spider/lay_eggs/egg_action in mother.actions)
		TEST_ASSERT(!egg_action.has_charges(), "[egg_action.name] da się złożyć bez ładunków")
	TEST_ASSERT(!eggs.ready, "Świeże jaja są od razu gotowe")

	// Bez duchów gniazdo matki wykluwa się samo: matka pod AI z eskortą
	allocated -= eggs
	qdel(eggs)
	var/obj/structure/spider/eggcluster/midwife/event_eggs = allocate(/obj/structure/spider/eggcluster/midwife, east)
	event_eggs.auto_hatch()
	TEST_ASSERT(QDELETED(event_eggs), "Gniazdo matki nie zniknęło po samoczynnym wykluciu")
	var/hatched = 0
	var/found_midwife = FALSE
	for(var/mob/living/simple_animal/hostile/spider/growing/spiderling/hatchling in east)
		hatched++
		allocated += hatchling
		if(istype(hatchling, /mob/living/simple_animal/hostile/spider/growing/spiderling/midwife))
			found_midwife = TRUE
		TEST_ASSERT_EQUAL(hatchling.directive, event_eggs.directive, "Pajączek z samoczynnego wyklucia nie dostał rozkazu")
	TEST_ASSERT_EQUAL(hatched, 3, "Z gniazda matki nie wykluły się trzy pajączki")
	TEST_ASSERT(found_midwife, "Z gniazda matki nie wykluła się matka")

	// Ładunki daje każda żywa istota, nie tylko człowiek
	mother.adjust_egg_charges(-mother.egg_charges)
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, east)
	wrap.wrap_target(monkey)
	TEST_ASSERT_EQUAL(mother.egg_charges, SPIDER_EGG_CHARGES_PER_BODY, "Wyssanie małpy nie dało ładunków")
	qdel(monkey.loc)

/// Bity połączeń z nazwy stanu ikony ("stickyweb-21" -> 21); N/S/E/W pokrywają się z kierunkami BYOND
/datum/unit_test/aquila_spiders/proc/web_junction(obj/structure/spider/web)
	var/dash = findlasttext(web.icon_state, "-")
	return text2num(copytext(web.icon_state, dash + 1))

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
