/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu")
		ui.open()
		// AQ EDIT - spawners get taken/deleted through paths that never call SSmobs.update_spawners(), so keep the list live
		ui.set_autoupdate(TRUE)

/// AQ EDIT - is this spawner entry still usable? Taken, dead or deleted entries used to stay in the menu for the whole round.
/datum/spawners_menu/proc/is_spawner_valid(atom/movable/spawner_obj)
	if(QDELETED(spawner_obj) || !spawner_obj.loc)
		return FALSE
	if(istype(spawner_obj, /obj/effect/mob_spawn))
		var/obj/effect/mob_spawn/MS = spawner_obj
		return MS.ghost_usable && MS.uses != 0
	if(isliving(spawner_obj))
		var/mob/living/L = spawner_obj
		if(L.key || L.stat == DEAD)
			return FALSE
		// Slimes are offered by their master without being flagged playable
		return L.playable || isslime(L)
	return TRUE

/// AQ EDIT - drops stale entries from GLOB.mob_spawners
/datum/spawners_menu/proc/prune_spawners()
	for(var/spawner in GLOB.mob_spawners.Copy())
		var/list/spawner_objs = GLOB.mob_spawners[spawner]
		for(var/spawner_obj in spawner_objs?.Copy())
			if(!is_spawner_valid(spawner_obj))
				spawner_objs -= spawner_obj
				if(!istype(spawner_obj, /obj/effect/mob_spawn)) // permanent spawners keep their POI
					GLOB.poi_list -= spawner_obj
		if(!length(spawner_objs))
			GLOB.mob_spawners -= spawner

/datum/spawners_menu/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	prune_spawners()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["short_desc"] = ""
		this["flavor_text"] = ""
		this["important_warning"] = ""
		this["refs"] = list()
		var/amount_left = 0
		for(var/spawner_obj in GLOB.mob_spawners[spawner])
			this["refs"] += "[REF(spawner_obj)]"
			if(istype(spawner_obj, /obj/effect/mob_spawn))
				var/obj/effect/mob_spawn/spawn_point = spawner_obj
				amount_left += spawn_point.uses > 0 ? spawn_point.uses : 1
			else
				amount_left++
			if(!this["desc"])
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["short_desc"] = MS.short_desc
					this["flavor_text"] = MS.flavour_text
					this["important_info"] = MS.important_info
				else
					var/atom/movable/O = spawner_obj
					if(isslime(O))
						this["short_desc"] = O.get_spawner_desc()
						this["flavor_text"] = O.get_spawner_flavour_text()
					else
						this["desc"] = O.desc

		this["amount_left"] = amount_left
		data["spawners"] += list(this)

	return data

/datum/spawners_menu/ui_act(action, params)
	if(..())
		return

	var/group_name = params["name"]
	if(!group_name || !(group_name in GLOB.mob_spawners))
		return
	prune_spawners()
	var/list/spawnerlist = GLOB.mob_spawners[group_name]
	if(!LAZYLEN(spawnerlist))
		return
	var/atom/movable/MS = pick(spawnerlist)
	if(!istype(MS) || !(MS in GLOB.poi_list))
		return
	switch(action)
		if("jump")
			if(MS)
				usr.forceMove(get_turf(MS))
				. = TRUE
		if("spawn")
			if(MS)
				MS.attack_ghost(usr)
				. = TRUE
