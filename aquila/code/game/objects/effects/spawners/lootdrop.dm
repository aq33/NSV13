/obj/effect/spawner/lootdrop/xenobiology_fun_spawner
	name = "xenobiology fun spawner"
	loot = list(
		/obj/effect/spawner/xeno_egg_delivery = 1,
		/obj/effect/spawner/infectious_zombie_delivery = 1,
		/obj/effect/spawner/swarmer_fabricator_delivery = 1,
		/obj/effect/spawner/spider_egg_delivery = 1,
		/obj/effect/spawner/infected_monkey_delivery = 1,
//		/obj/effect/spawner/hivebot_delivery = 1, // na tą chwile chyba zepsute
		/obj/effect/spawner/morph_delivery = 1,
		/obj/effect/mob_spawn/teratomamonkey = 1,)

/obj/effect/spawner/lootdrop/xenobiology_fun_spawner/Initialize(mapload)
	new /obj/effect/xenobio_specimen_monitor(get_turf(src))
	return ..()

/// Niewidzialny obiekt w klatce xenobio, który daje pasywnie punkty badań za żywe okazy trzymane w środku.
/obj/effect/xenobio_specimen_monitor
	name = "xenobiology specimen monitor"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	/// Punkty General Research na sekundę za jeden okaz
	var/points_per_specimen = 25
	/// Ile okazów naraz liczy się do przychodu
	var/max_specimens = 5
	/// Maksymalny rozmiar klatki wyznaczanej flood fillem
	var/max_cell_size = 150
	/// Pola klatki, wyznaczane przy pierwszym process() po starcie rundy
	var/list/turf/cell_turfs
	/// Obiekty liczone jako okazy, choć nie są mobami (jaja, gniazda, fabrykatory)
	var/static/list/specimen_objects = typecacheof(list(
		/obj/structure/alien/egg,
		/obj/structure/spider/eggcluster,
		/obj/machinery/droneDispenser/swarmer,
		/obj/effect/mob_spawn/teratomamonkey,
	))

/obj/effect/xenobio_specimen_monitor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/xenobio_specimen_monitor/Destroy()
	STOP_PROCESSING(SSobj, src)
	cell_turfs = null
	return ..()

/obj/effect/xenobio_specimen_monitor/singularity_act()
	return

/obj/effect/xenobio_specimen_monitor/singularity_pull()
	return

/obj/effect/xenobio_specimen_monitor/ex_act(severity, target)
	return

/obj/effect/xenobio_specimen_monitor/process(delta_time)
	if(!SSticker.HasRoundStarted())
		return
	if(!cell_turfs)
		find_cell()
	var/specimens = count_specimens()
	if(!specimens)
		return
	var/points = min(specimens, max_specimens) * points_per_specimen * delta_time
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/// Wyznacza pola klatki: od pola startowego po sąsiadach w tej samej strefie, zatrzymując się na ścianach, oknach i drzwiach.
/obj/effect/xenobio_specimen_monitor/proc/find_cell()
	var/turf/start = get_turf(src)
	var/area/cell_area = get_area(start)
	cell_turfs = list(start)
	var/list/queue = list(start)
	while(queue.len && cell_turfs.len < max_cell_size)
		var/turf/current = queue[1]
		queue.Cut(1, 2)
		for(var/dir in GLOB.cardinals)
			var/turf/next = get_step(current, dir)
			if(!next || (next in cell_turfs) || next.density || get_area(next) != cell_area)
				continue
			if(is_cell_boundary(next))
				continue
			cell_turfs += next
			queue += next

/obj/effect/xenobio_specimen_monitor/proc/is_cell_boundary(turf/T)
	for(var/obj/O in T)
		if(O.density && O.anchored)
			return TRUE
	return FALSE

/obj/effect/xenobio_specimen_monitor/proc/count_specimens()
	. = 0
	for(var/turf/T as anything in cell_turfs)
		for(var/atom/movable/AM as anything in T)
			if(isliving(AM))
				var/mob/living/L = AM
				if(L.stat != DEAD && !ishuman(L) && !issilicon(L) && !isslime(L))
					.++
			else if(is_type_in_typecache(AM, specimen_objects))
				.++
