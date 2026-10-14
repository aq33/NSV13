/datum/test_chamber_kit/pr_436
	name = "Wiszące iskry"
	pr = "aq33/AquilaStation#436"
	description = "Na środku sypią się iskry, a lampa podłogowa obok jest zbita i co chwilę iskrzy. Iskry mają znikać po ~2 s, także gdy w tym czasie zresetujesz komorę (nakładające się ładowanie szablonu). Poza komorą: bramka brigu na Atlasie (wolne wyjście, wejście z dostępem) i sloty w oknie dołączania."
	items = list(
		/obj/machinery/light/floor = 1
	)

/datum/test_chamber_kit/pr_436/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/machinery/light/floor/L in spawned)
		L.break_light_tube()
	do_sparks(10, FALSE, center)
