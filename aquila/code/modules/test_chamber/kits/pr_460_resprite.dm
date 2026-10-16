/datum/test_chamber_kit/pr_460
	name = "Struktury z Paradise"
	pr = "aq33/AquilaStation#460"
	description = "Pokój ze ścian 3/4: śluzy z przodu i z boku (zwykła, otwarta, zaryglowana, zespawana, szklana), okna z kratami, \
		fałszywa ściana, rozbierana ściana wzmocniona, drzwi przeciwpożarowe, grodzie, roleta, drzwi okienne, cienkie okna i dźwigar. \
		Sprawdź wygładzanie po rozebraniu ściany i postawieniu nowej, odkręcenie okna i animacje drzwi."

/datum/test_chamber_kit/pr_460/setup(list/spawned, list/turfs, turf/center, mob/user)
	// '#' ściana, 'R' wzmocniona, 'W' pełne okno z kratą, 'D' śluza, 'F' fałszywa ściana, 'd' rozbierana wzmocniona
	var/list/layout = list(
		"RRRWWWRRR",
		"#.......#",
		"D.......W",
		"#.......#",
		"#DdF#DD##")
	var/list/doors = list()
	for(var/row in 1 to length(layout))
		var/line = layout[row]
		for(var/col in 1 to length(line))
			var/turf/T = locate(center.x + col - 5, center.y + 3 - row, center.z)
			if(!T || !istype(T.loc, /area/test_chamber/arena))
				continue
			switch(copytext(line, col, col + 1))
				if("#")
					T.PlaceOnTop(/turf/closed/wall)
				if("R")
					T.PlaceOnTop(/turf/closed/wall/r_wall)
				if("d")
					var/turf/closed/wall/r_wall/RW = T.PlaceOnTop(/turf/closed/wall/r_wall)
					RW.d_state = COVER
					RW.update_icon()
				if("W")
					new /obj/structure/grille(T)
					new /obj/structure/window/reinforced/fulltile(T)
				if("F")
					new /obj/structure/falsewall(T)
				if("D")
					doors += T
	var/list/door_types = list(/obj/machinery/door/airlock/ship/engineering/glass, /obj/machinery/door/airlock/ship/maintenance, /obj/machinery/door/airlock/ship/command, /obj/machinery/door/airlock/ship/public/glass)
	for(var/i in 1 to length(doors))
		var/door_type = door_types[min(i, length(door_types))]
		var/obj/machinery/door/airlock/A = new door_type(doors[i])
		switch(i)
			if(2)
				A.open()
			if(3)
				A.bolt()
			if(4)
				A.welded = TRUE
				A.update_icon()
	// Wnętrze: drzwi przeciwpożarowe, grodzie, roleta, drzwi okienne, cienkie okna, dźwigar
	var/list/inside = list(
		list(-3, 1, /obj/machinery/door/firedoor),
		list(-2, 1, /obj/machinery/door/poddoor/ship),
		list(-1, 1, /obj/machinery/door/poddoor/shutters/ship),
		list(0, 1, /obj/machinery/door/window/southleft),
		list(1, 1, /obj/structure/window/reinforced/spawner/north),
		list(2, 1, /obj/structure/girder),
		list(-3, -1, /obj/machinery/door/firedoor/border_only/directional/south),
		list(2, -1, /obj/structure/window/reinforced/fulltile/unanchored))
	for(var/list/entry in inside)
		var/turf/T = locate(center.x + entry[1], center.y + entry[2], center.z)
		if(T && istype(T.loc, /area/test_chamber/arena))
			var/spawn_type = entry[3]
			var/obj/machinery/door/D = new spawn_type(T)
			if(istype(D, /obj/machinery/door/firedoor) || istype(D, /obj/machinery/door/poddoor))
				D.close()

/datum/test_chamber_kit/pr_460_podlogi
	name = "Podłogi i naklejki z Bee"
	pr = "aq33/AquilaStation#460"
	description = "Zielone naklejki płytek z Bee: pełna, połówka, antynarożnik, narożnik, rampy i przeciwległe rogi. \
		Sprawdź, czy są półprzezroczyste i czy rampy dają ukośne przejście. Na mapach zakręty kolorowych pasów mają teraz ukosy."
	/// Naklejki rozkładają się na podłogę i same znikają, więc nie idą przez items (test liczy obiekty)
	var/list/decals = list(
		/obj/effect/turf_decal/tile/green/fourcorners,
		/obj/effect/turf_decal/tile/green/half,
		/obj/effect/turf_decal/tile/green/anticorner,
		/obj/effect/turf_decal/tile/green,
		/obj/effect/turf_decal/tile/green/corner_ramp,
		/obj/effect/turf_decal/tile/green/anticorner_ramp,
		/obj/effect/turf_decal/tile/green/opposingcorners
	)

/datum/test_chamber_kit/pr_460_podlogi/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/i in 1 to min(length(decals), length(turfs)))
		var/decal_type = decals[i]
		new decal_type(turfs[i])
