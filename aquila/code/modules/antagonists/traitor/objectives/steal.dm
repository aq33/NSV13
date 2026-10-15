// AQUILA - steal objectives.
// Departmental items: tgstation/tgstation objective_items.dm (steal/traitor), master R&D server HDD: yogstation13/Yogstation#20268,
// heirloom: Skyrat-SS13/Skyrat13#157 hoard/heirloom merged with the thief chronicle, the rest came with the thief (tgstation#64144).

/datum/objective_item
	/// Jobs that carry this item. If set, the item is only picked when someone with one of these jobs is on the ship.
	var/list/item_owner
	/// The item only spawns from the map. If set, one of these types must exist on the ship.
	var/list/map_check_types

/// FALSE if nobody who would carry the item (or no mapped container of it) is on the ship
/datum/objective_item/proc/owner_present()
	if(length(map_check_types) && !objective_type_on_station(map_check_types))
		return FALSE
	if(!length(item_owner))
		return TRUE
	for(var/datum/mind/crew_mind as anything in SSticker.minds)
		if((crew_mind.assigned_role in item_owner) && considered_alive(crew_mind))
			return TRUE
	return FALSE

/// Typecache of every map_check_types entry that exists on the ship. Built once, on the first lookup.
GLOBAL_LIST(objective_map_types_present)

/proc/objective_type_on_station(list/types)
	if(!GLOB.objective_map_types_present)
		var/list/wanted = list()
		for(var/item_type in subtypesof(/datum/objective_item))
			var/datum/objective_item/item = item_type
			var/list/checks = initial(item.map_check_types)
			if(length(checks))
				wanted |= checks
		var/list/wanted_cache = typecacheof(wanted)
		GLOB.objective_map_types_present = list()
		for(var/obj/O in world)
			if(!is_type_in_typecache(O, wanted_cache))
				continue
			var/turf/object_turf = get_turf(O) // mapped items can sit in lockers and safes
			if(object_turf && is_station_level(object_turf.z))
				GLOB.objective_map_types_present[O.type] = TRUE
	for(var/present_type in GLOB.objective_map_types_present)
		for(var/wanted_type in types)
			if(ispath(present_type, wanted_type))
				return TRUE
	return FALSE

// Departmental items, mostly found on the person of their owner

/datum/objective_item/steal/traitor_bartender_shotgun
	name = "dwururkę barmana."
	targetitem = /obj/item/gun/ballistic/shotgun/doublebarrel
	excludefromjob = list(JOB_NAME_BARTENDER)
	map_check_types = list(/obj/item/gun/ballistic/shotgun/doublebarrel)
	difficulty = 2

/datum/objective_item/steal/traitor_fireaxe
	name = "topór strażacki."
	targetitem = /obj/item/fireaxe
	excludefromjob = list(JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_BRIDGESTAFF)
	map_check_types = list(/obj/structure/fireaxecabinet)
	difficulty = 3

/datum/objective_item/steal/traitor_nullrod
	name = "święty kij kapłana (null rod)."
	targetitem = /obj/item/nullrod
	excludefromjob = list(JOB_NAME_CHAPLAIN)
	item_owner = list(JOB_NAME_CHAPLAIN)
	difficulty = 2

/datum/objective_item/steal/traitor_clown_shoes
	name = "buty klauna."
	targetitem = /obj/item/clothing/shoes/clown_shoes
	excludefromjob = list(JOB_NAME_CLOWN, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_QUARTERMASTER)
	item_owner = list(JOB_NAME_CLOWN)
	difficulty = 1

/datum/objective_item/steal/traitor_mime_mask
	name = "maskę mima."
	targetitem = /obj/item/clothing/mask/gas/mime
	excludefromjob = list(JOB_NAME_MIME, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_QUARTERMASTER)
	item_owner = list(JOB_NAME_MIME)
	difficulty = 1

/datum/objective_item/steal/traitor_pka
	name = "protokinetyczny akcelerator górnika."
	targetitem = /obj/item/gun/energy/kinetic_accelerator
	excludefromjob = list(JOB_NAME_SHAFTMINER, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_QUARTERMASTER)
	item_owner = list(JOB_NAME_SHAFTMINER)
	difficulty = 1

/datum/objective_item/steal/traitor_chef_moustache
	name = "sztuczne włoskie wąsy kucharza."
	targetitem = /obj/item/clothing/mask/fakemoustache/italian
	excludefromjob = list(JOB_NAME_COOK, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_QUARTERMASTER)
	item_owner = list(JOB_NAME_COOK)
	difficulty = 1

/datum/objective_item/steal/traitor_det_revolver
	name = "rewolwer detektywa."
	targetitem = /obj/item/gun/ballistic/revolver/detective
	excludefromjob = list(JOB_NAME_DETECTIVE)
	item_owner = list(JOB_NAME_DETECTIVE)
	difficulty = 3

/datum/objective_item/steal/traitor_lawyers_badge
	name = "odznakę prawnika."
	targetitem = /obj/item/clothing/accessory/lawyers_badge
	excludefromjob = list(JOB_NAME_LAWYER)
	item_owner = list(JOB_NAME_LAWYER)
	difficulty = 1

/datum/objective_item/steal/traitor_chief_engineer_belt
	name = "pas z narzędziami Głównego Inżyniera."
	targetitem = /obj/item/storage/belt/utility/chief
	excludefromjob = list(JOB_NAME_CHIEFENGINEER)
	item_owner = list(JOB_NAME_CHIEFENGINEER)
	difficulty = 2

/datum/objective_item/steal/traitor_telebaton
	name = "teleskopową pałkę jednego z oficerów dowództwa."
	targetitem = /obj/item/melee/classic_baton/police/telescopic
	excludefromjob = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_MASTERATARMS)
	item_owner = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_MASTERATARMS)
	difficulty = 3

/datum/objective_item/steal/traitor_cargo_budget
	name = "kartę budżetu działu zaopatrzenia."
	targetitem = /obj/item/card/id/departmental_budget/car
	excludefromjob = list(JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN)
	map_check_types = list(/obj/structure/closet/secure_closet/quartermaster, /obj/item/card/id/departmental_budget/car)
	difficulty = 2

/datum/objective_item/steal/traitor_captain_spare
	name = "zapasową kartę identyfikacyjną kapitana."
	targetitem = /obj/item/card/id/captains_spare
	excludefromjob = list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL)
	map_check_types = list(/obj/item/storage/secure/safe/caps_spare, /obj/item/card/id/captains_spare)
	difficulty = 4

/datum/objective_item/steal/traitor_maa_hat
	name = "czapkę Mistrza Broni."
	targetitem = /obj/item/clothing/head/ship/maa_hat
	excludefromjob = list(JOB_NAME_MASTERATARMS)
	item_owner = list(JOB_NAME_MASTERATARMS)
	difficulty = 2

/datum/objective_item/steal/traitor_atc_sticks
	name = "pałki sygnalizacyjne Kontrolera Lotów."
	targetitem = /obj/item/flashlight/atc_wavy_sticks
	excludefromjob = list(JOB_NAME_AIRTRAFFICCONTROLLER)
	item_owner = list(JOB_NAME_AIRTRAFFICCONTROLLER)
	difficulty = 1

// The master R&D server HDD (yogstation13/Yogstation#20268)

/datum/objective_item/steal/hdd_extraction
	name = "kod źródłowy Projektu Aquila z głównego serwera B+R."
	targetitem = /obj/item/computer_hardware/hard_drive/cluster/hdd_theft
	difficulty = 10
	excludefromjob = list(JOB_NAME_SCIENTIST, JOB_NAME_RESEARCHDIRECTOR) // a scientist isn't sus in that room, a geneticist or roboticist is
	special_equipment = list(/obj/item/paper/guides/antag/hdd_extraction)

/datum/objective_item/steal/hdd_extraction/owner_present()
	for(var/obj/machinery/rnd/server/master/master_server as anything in SSresearch.master_servers)
		if(master_server.source_code_hdd)
			return TRUE
	return FALSE

/// Steal objective that always targets the master server HDD. Rolled on its own, so it keeps the weight the old research download had.
/datum/objective/steal/hdd
	name = "kradzież kodu źródłowego"

/datum/objective/steal/hdd/find_target(list/dupe_search_range, list/blacklist)
	var/datum/objective_item/steal/hdd_extraction/hdd = locate() in GLOB.possible_items
	if(!hdd || !hdd.owner_present() || !is_unique_objective(hdd.targetitem, dupe_search_range || get_owners()))
		return null
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(owner_mind.assigned_role in hdd.excludefromjob)
			return null
	return set_steal_target(hdd)

/datum/objective/steal/hdd/traitor_roll_setup(datum/antagonist/traitor/rolling)
	return !!find_target()

// Heirloom - steal the family heirloom of a crew member and keep it (Skyrat hoard/heirloom + thief chronicle)

/datum/objective/steal/heirloom
	name = "kradzież pamiątki"
	/// The exact item, not just its type
	var/obj/item/heirloom
	/// Whose heirloom it is
	var/datum/mind/heirloom_owner

/datum/objective/steal/heirloom/find_target(list/dupe_search_range, list/blacklist)
	var/list/candidates = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		if((crew_mind in get_owners()) || (crew_mind in blacklist) || !ishuman(crew_mind.current))
			continue
		var/mob/living/carbon/human/crew = crew_mind.current
		for(var/datum/quirk/family_heirloom/quirk in crew.roundstart_quirks)
			if(!QDELETED(quirk.heirloom))
				candidates[quirk.heirloom] = crew_mind
	if(!length(candidates))
		return null
	heirloom = pick(candidates)
	heirloom_owner = candidates[heirloom]
	steal_target = heirloom.type
	update_explanation_text()
	return heirloom

/datum/objective/steal/heirloom/traitor_roll_setup(datum/antagonist/traitor/rolling)
	return !!find_target()

/datum/objective/steal/heirloom/update_explanation_text()
	if(heirloom && heirloom_owner)
		explanation_text = "Ukradnij rodzinną pamiątkę [heirloom_owner.name] ([heirloom.name]) i miej ją przy sobie do końca zmiany."
	else
		explanation_text = "Ukradnij czyjąś rodzinną pamiątkę i miej ją przy sobie do końca zmiany."

/datum/objective/steal/heirloom/check_completion()
	if(completed)
		return TRUE
	var/list/owners = get_owners()
	for(var/datum/mind/owner_mind as anything in owners)
		if(!isliving(owner_mind.current))
			continue
		for(var/obj/item/possible_heirloom in owner_mind.current.GetAllContents())
			if(heirloom && !QDELETED(heirloom))
				if(possible_heirloom == heirloom)
					return TRUE
				continue
			// The heirloom got destroyed or never existed, any heirloom of someone else counts
			var/datum/component/heirloom/found = possible_heirloom.GetComponent(/datum/component/heirloom)
			if(found && !(found.owner in owners))
				return TRUE
	return FALSE

// Thief objectives (tgstation#64144), now part of the traitor pool

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

/datum/objective/hoarder/traitor_roll_setup(datum/antagonist/traitor/rolling)
	find_target()
	update_explanation_text()
	return TRUE

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
	amount = 5 //little less, bodies are hard to come by

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

/datum/objective/steal_five_of_type/summon_guns/thief
	explanation_text = "Ukradnij co najmniej trzy sztuki broni i miej je przy sobie do końca zmiany!"
	amount = 3

/datum/objective/steal_five_of_type/organs
	name = "ukradnij organy"
	explanation_text = "Ukradnij co najmniej pięć organicznych organów i miej je przy sobie do końca zmiany! Muszą być w dobrym stanie."
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
