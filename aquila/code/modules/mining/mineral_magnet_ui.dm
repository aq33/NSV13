// Okno magnesu na asteroidy w TGUI (zamiast HTML i input() z nsv13/code/modules/mining/asteroid.dm).
// Asteroidy w zasięgu są w oknie razem ze składem rdzenia, wypchnięcie potwierdza się w oknie.

/obj/machinery/computer/ship/mineral_magnet/attack_hand(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	if(!target_location)
		to_chat(user, "<span class='warning'>[src] nie ma przypisanej klatki na asteroidy.</span>")
		return
	ui_interact(user)

/obj/machinery/computer/ship/mineral_magnet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	if(!..())
		return
	ui = new(user, src, "AsteroidMagnet", name)
	ui.open()

/obj/machinery/computer/ship/mineral_magnet/ui_data(mob/user)
	var/list/data = list()
	data["cooldown"] = cooldown
	data["has_asteroid"] = !!current_asteroid
	var/list/asteroids = list()
	if(linked && !current_asteroid)
		for(var/obj/structure/overmap/asteroid/asteroid in orange(5, linked))
			var/list/ores = list()
			for(var/turf/closed/mineral/mineral_type as anything in asteroid.core_composition)
				var/obj/item/stack/ore/ore_type = initial(mineral_type.mineralType)
				ores += ore_type ? initial(ore_type.name) : initial(mineral_type.name)
			asteroids += list(list("name" = asteroid.name, "ref" = REF(asteroid), "ores" = ores))
	data["asteroids"] = asteroids
	return data

/obj/machinery/computer/ship/mineral_magnet/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		return
	switch(action)
		if("pull")
			if(current_asteroid)
				return
			var/obj/structure/overmap/asteroid/target = locate(params["ref"]) in orange(5, linked)
			if(target)
				pull_in_asteroid(usr, target)
			return TRUE
		if("push")
			if(current_asteroid)
				start_push()
			return TRUE

/// Z celem wybranym w oknie: przyciąga od razu ten, bez listy input(); bez celu działa jak dawniej
/obj/machinery/computer/ship/mineral_magnet/pull_in_asteroid(mob/user, obj/structure/overmap/asteroid/target)
	if(!target)
		return ..()
	if(cooldown)
		say("ERROR: Magnetisation circuits recharging...")
		return FALSE
	if(!has_overmap() || !length(target.core_composition))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		return FALSE
	linked.relay('nsv13/sound/effects/ship/tractor.ogg', "<span class='warning'>DANGER: Magnet has locked on to an asteroid. Vacate the asteroid cage immediately.</span>")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
	if(prob(20))
		var/list/potential_ruins = flist("_maps/map_files/Mining/nsv13/ruins/")
		current_asteroid = new /datum/map_template/asteroid("_maps/map_files/Mining/nsv13/ruins/[pick(potential_ruins)]", null, FALSE, target.core_composition)
	else
		var/list/potential_asteroids = flist("_maps/map_files/Mining/nsv13/asteroids/")
		current_asteroid = new /datum/map_template/asteroid("_maps/map_files/Mining/nsv13/asteroids/[pick(potential_asteroids)]", null, FALSE, target.core_composition)
	addtimer(CALLBACK(src, PROC_REF(load_asteroid)), 10 SECONDS)
	qdel(target)
	return TRUE
