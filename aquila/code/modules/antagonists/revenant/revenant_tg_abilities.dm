// AQUILA - moce rewenanta z tg: Haunt Object, Vortex i Scatter
// (tgstation code/modules/mob/living/basic/space_fauna/revenant/revenant_abilities.dm), liczby jak w tg

/// Rewenant nie rusza się sam od wiru, duchy i efekty też nie
/proc/revenant_vortex(turf/center, push, range, mob/living/caster)
	for(var/atom/movable/thing in orange(range, center))
		if(thing == caster || thing.anchored)
			continue
		if(iseffect(thing) || iscameramob(thing) || isdead(thing) || isrevenant(thing))
			continue
		var/distance = get_dist(thing, center)
		var/moving_power = max(range - distance, 1)
		if(moving_power > 2) // blisko silnego wiru rzuca
			if(push)
				thing.throw_at(get_edge_target_turf(thing, get_dir(center, thing)), moving_power, 1)
			else
				thing.throw_at(center, moving_power, 1)
		else if(push)
			if(step_away(thing, center) && moving_power > 1)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_away), thing, center), 2)
		else
			if(step_towards(thing, center) && moving_power > 1)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step_towards), thing, center), 2)

//Haunt Object: nawiedza pobliskie przedmioty, które rzucają się na ludzi
/obj/effect/proc_holder/spell/aoe_turf/revenant/haunt_object
	name = "Haunt Object"
	desc = "Empower nearby objects with ghostly energy, causing them to attack nearby mortals. Items closer to you are more likely to be haunted."
	action_icon = 'aquila/icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_haunt"
	range = 5
	stun = 30
	reveal = 60
	unlock_amount = 30 // jak Overload Lights
	cast_amount = 50 // ale działa dłużej
	/// Ile przedmiotów najwyżej bierze pod uwagę
	var/max_targets = 7

/obj/effect/proc_holder/spell/aoe_turf/revenant/haunt_object/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return
	// range() nie sortuje po odległości, więc kandydaci idą do kubełków według dystansu, a limit bierze najbliższych
	var/list/by_distance = list()
	for(var/i in 0 to range)
		by_distance += list(list())
	var/turf/user_turf = get_turf(user)
	for(var/obj/item/nearby_item in range(range, user))
		// Bez przykręconych, gęstych i schowanych w czymś
		if(nearby_item.anchored || nearby_item.density || !isturf(nearby_item.loc))
			continue
		if(nearby_item.item_flags & ABSTRACT)
			continue
		// Bez rzeczy, których nie widać
		if(nearby_item.invisibility >= INVISIBILITY_REVENANT)
			continue
		// Bez tych, które już straszą
		if(istype(nearby_item.ai_controller, /datum/ai_controller/haunted))
			continue
		var/list/bucket = by_distance[min(get_dist(nearby_item, user_turf), range) + 1]
		bucket += nearby_item
	var/list/candidates = list()
	for(var/list/bucket as anything in by_distance)
		candidates += bucket
	if(length(candidates) > max_targets)
		candidates.Cut(max_targets + 1)
	for(var/obj/item/victim as anything in candidates)
		var/distance_from_caster = max(get_dist(get_turf(victim), user_turf), 1)
		if(!prob(150 / distance_from_caster))
			continue
		new /obj/effect/temp_visual/revenant(get_turf(victim))
		victim.AddComponent(/datum/component/haunted_item, \
			haunt_color = "#823abb", \
			haunt_duration = rand(1 MINUTES, 3 MINUTES), \
			aggro_radius = range - 1, \
			spawn_message = "<span class='revenwarning'>[victim] unosi się i wiruje w powietrzu, świecąc upiornym fioletem!</span>", \
			despawn_message = "<span class='revenwarning'>[victim] opada na ziemię i znowu nieruchomieje.</span>", \
		)

//Vortex: opróżnia pobliskie pojemniki i wciąga przedmioty do rewenanta
/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex
	name = "Vortex"
	desc = "Causes nearby objects to dump their contents and get sucked towards your location."
	action_icon = 'aquila/icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_vortex"
	charge_max = 150
	range = 1 // pojemniki opróżnia tylko tuż obok
	stun = 20
	reveal = 50
	unlock_amount = 45
	cast_amount = 30
	/// Zasięg wiru
	var/vortex_range = 3
	/// TRUE odpycha zamiast przyciągać
	var/push = FALSE
	var/vortex_sound = 'sound/machines/woosh.ogg'

/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return
	var/turf/center = get_turf(user)
	revenant_vortex(center, push, vortex_range, user)
	playsound(center, vortex_sound, 50, TRUE)
	for(var/turf/T in targets)
		for(var/obj/item/storage/cursed_storage in T)
			var/datum/component/storage/storage = cursed_storage.GetComponent(/datum/component/storage)
			if(!storage || storage.locked)
				continue
			storage.do_quick_empty()
			new /obj/effect/temp_visual/revenant(T)

//Scatter: to samo, ale rozrzuca przedmioty na boki
/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/scatter
	name = "Scatter"
	desc = "Causes nearby objects to dump their contents and get thrown away from your location."
	action_icon_state = "r_scatter"
	charge_max = 250
	stun = 30
	reveal = 50
	unlock_amount = 60
	cast_amount = 55
	vortex_range = 5 // odpychanie jest dużo silniejsze niż przyciąganie
	push = TRUE
	vortex_sound = 'sound/machines/hiss.ogg'
