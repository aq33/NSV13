// AQUILA - Thief objectives (tgstation#64144).

GLOBAL_LIST_INIT(hoarder_targets, list(
	/obj/item/clothing/gloves/color/yellow,
	/obj/item/clothing/suit/space/hardsuit,
	/obj/item/melee/baton,
))

/datum/objective/hoarder
	name = "chomikowanie"
	explanation_text = "Zgromadź jak najwięcej przedmiotów w jednym miejscu!"
	///what item we want to get many of
	var/atom/movable/target_type
	///how many we want for greentext
	var/amount = 7
	///and where do we want it roundend
	var/turf/hoarder_turf

/datum/objective/hoarder/find_target(list/dupe_search_range, list/blacklist)
	amount = rand(amount - 2, amount + 2)
	target_type = pick(GLOB.hoarder_targets)
	add_action()

/datum/objective/hoarder/proc/add_action()
	var/list/owners = get_owners()
	var/datum/mind/hoardpicker = owners[1]
	var/datum/action/declare_hoard/declare = new /datum/action/declare_hoard(hoardpicker.current)
	declare.weak_objective = WEAKREF(src)
	declare.Grant(hoardpicker.current)

/datum/objective/hoarder/update_explanation_text()
	var/obj/item/target_item = target_type
	explanation_text = "Zgromadź w technicznych jak najwięcej przedmiotów typu [initial(target_item.name)] (najpierw wyznacz miejsce na skrytkę)! Wystarczy co najmniej [amount]."

/datum/objective/hoarder/check_completion()
	. = ..()
	if(.)
		return TRUE
	var/stolen_amount = 0
	if(!hoarder_turf)
		return FALSE //they never set up their hoard spot, so they couldn't have done their objective
	for(var/atom/movable/in_target_turf in hoarder_turf.GetAllContents())
		if(istype(in_target_turf, target_type))
			if(!valid_target(in_target_turf))
				continue
			stolen_amount++
	return stolen_amount >= amount

/datum/objective/hoarder/proc/valid_target(atom/movable/target)
	//cattleprods are batons here, but anyone can craft them
	if(istype(target, /obj/item/melee/baton/cattleprod))
		return FALSE
	return TRUE

///for the deranged flavor
/datum/objective/hoarder/bodies
	name = "chomikowanie zwłok"
	explanation_text = "Zgromadź jak najwięcej zwłok w jednym miejscu!"
	amount = 5 //little less, bodies are hard when you can't kill like antags

/datum/objective/hoarder/bodies/find_target(list/dupe_search_range, list/blacklist)
	amount = rand(amount - 2, amount + 2)
	target_type = /mob/living/carbon/human
	add_action()

/datum/objective/hoarder/bodies/valid_target(mob/living/carbon/human/target)
	if(target.stat != DEAD)
		return FALSE
	return TRUE

/datum/objective/hoarder/bodies/update_explanation_text()
	explanation_text = "Zgromadź w technicznych jak najwięcej zwłok (najpierw wyznacz miejsce na skrytkę)! Wystarczy co najmniej [amount]."

/datum/action/declare_hoard
	name = "Wyznacz skrytkę"
	desc = "Wyznacza skrytkę na podłodze, na której stoisz. Przedmioty leżące na tym polu będą liczyć się do twojego celu."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "hoard"
	///weak reference to the objective this action targets, set by hoarder objective
	var/datum/weakref/weak_objective

/datum/action/declare_hoard/Trigger()
	if(!..())
		return FALSE
	if(owner.incapacitated())
		owner.balloon_alert(owner, "nie teraz!")
		return FALSE
	var/area/owner_area = get_area(owner)
	if(!istype(owner_area, /area/maintenance))
		owner.balloon_alert(owner, "skrytka musi być w technicznych!")
		return FALSE
	var/datum/objective/hoarder/objective = weak_objective?.resolve()
	if(objective)
		owner.balloon_alert(owner, "skrytka wyznaczona")
		objective.hoarder_turf = get_turf(owner)
		var/image/hoarder_marker = image('icons/mob/telegraphing/telegraph.dmi', objective.hoarder_turf, "hoarder_circle", layer = ABOVE_OPEN_TURF_LAYER)
		owner.client?.images |= hoarder_marker
	qdel(src)
	return TRUE

/datum/objective/chronicle //exactly what it sounds like, steal someone's heirloom.
	name = "kronika"
	explanation_text = "Ukradnij czyjąś rodzinną pamiątkę - oczywiście w celach kronikarskich."

/datum/objective/chronicle/check_completion()
	. = ..()
	if(.)
		return TRUE
	var/list/owners = get_owners()
	for(var/datum/mind/owner in owners)
		if(!isliving(owner.current))
			continue
		var/list/all_items = owner.current.GetAllContents() //this should get things in cheesewheels, books, etc.
		for(var/obj/possible_heirloom in all_items)
			var/datum/component/heirloom/found = possible_heirloom.GetComponent(/datum/component/heirloom)
			if(found && !(found.owner in owners))
				return TRUE
	return FALSE

/datum/objective/steal_five_of_type/summon_guns/thief
	explanation_text = "Ukradnij co najmniej trzy sztuki broni!"
	amount = 3

/datum/objective/steal_five_of_type/organs
	name = "ukradnij organy"
	explanation_text = "Ukradnij co najmniej pięć organicznych organów! Muszą być w dobrym stanie."
	wanted_items = list(/obj/item/organ)
	amount = 5 //i want this to be higher, but the organs must be fresh at roundend

/datum/objective/steal_five_of_type/organs/check_completion()
	var/stolen_count = 0
	for(var/datum/mind/mind as() in get_owners())
		if(!isliving(mind.current))
			continue
		var/list/all_items = mind.current.GetAllContents() //this should get things in cheesewheels, books, etc.
		for(var/obj/item/organ/wanted in all_items)
			if(wanted.owner) //still implanted, not harvested
				continue
			if(!(wanted.organ_flags & ORGAN_FAILING) && !(wanted.organ_flags & ORGAN_SYNTHETIC))
				stolen_count++
	return (stolen_count >= amount) || completed
