/// Attempts to spawn a crate twice based on the list of available locations
/obj/machinery/quantum_server/proc/attempt_spawn_cache(list/possible_turfs)
	if(!length(possible_turfs))
		return TRUE

	shuffle_inplace(possible_turfs)
	var/turf/chosen_turf = validate_turf(pick(possible_turfs))

	if(isnull(chosen_turf))
		possible_turfs.Remove(chosen_turf)
		chosen_turf = validate_turf(pick(possible_turfs))
		if(isnull(chosen_turf))
			stack_trace("vdom: after two attempts, could not find a valid turf for cache")
			return FALSE

	new /obj/structure/closet/crate/secure/bitrunning/encrypted(chosen_turf)
	return TRUE


/// Attempts to spawn a lootbox
/obj/machinery/quantum_server/proc/attempt_spawn_curiosity(list/possible_turfs)
	if(!length(possible_turfs)) // Out of turfs to place a curiosity
		return FALSE

	if(generated_domain.secondary_loot_generated >= counterlist_sum(generated_domain.secondary_loot)) // Out of curiosities to place
		return FALSE

	shuffle_inplace(possible_turfs)
	var/turf/chosen_turf = validate_turf(pick(possible_turfs))

	if(isnull(chosen_turf))
		possible_turfs.Remove(chosen_turf)
		chosen_turf = validate_turf(pick(possible_turfs))
		if(isnull(chosen_turf))
			stack_trace("vdom: after two attempts, could not find a valid turf for curiosity")
			return FALSE

	new /obj/item/storage/lockbox/bitrunning/encrypted(chosen_turf)
	return chosen_turf


/// Generates a new avatar for the bitrunner.
/obj/machinery/quantum_server/proc/generate_avatar(turf/destination, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(destination)

	var/outfit_path = generated_domain.forced_outfit || netsuit
	var/datum/outfit/to_wear = new outfit_path()

	to_wear.belt = /obj/item/bitrunning_host_monitor
	to_wear.ears = null
	to_wear.glasses = null
	to_wear.gloves = null
	to_wear.l_pocket = null
	to_wear.r_pocket = null
	to_wear.suit = null
	to_wear.suit_store = null
	if(!generated_domain.forced_outfit)
		to_wear.l_hand = null
		to_wear.r_hand = null

	avatar.equipOutfit(to_wear, TRUE)

	var/obj/item/clothing/under/jumpsuit = avatar.w_uniform
	if(istype(jumpsuit))
		jumpsuit.armor = getArmor()

	var/obj/item/clothing/head/hat = avatar.head
	if(istype(hat))
		hat.armor = getArmor()

	var/obj/item/storage/backpack/bag = avatar.back
	if(istype(bag))
		QDEL_LIST(bag.contents)

		new /obj/item/storage/box/survival(bag)
		new /obj/item/storage/firstaid/regular(bag)
		new /obj/item/flashlight(bag)

	var/obj/item/card/id/outfit_id = avatar.wear_id
	if(istype(outfit_id))
		outfit_id.assignment = "Awatar Bitowy"
		outfit_id.hud_state = JOB_HUD_BITAVATAR
		outfit_id.registered_account = null // awatar nie dostaje pensji ani konta
		outfit_id.update_label()

	avatar.AddComponent(/datum/component/simple_bodycam, \
		camera_name = "kamera awatara", \
		c_tag = "Awatar [avatar.real_name]", \
		network = BITRUNNER_CAMERA_NET, \
	)

	return avatar


/// Loads in any mob segments of the map
/obj/machinery/quantum_server/proc/load_mob_segments()
	if(!length(generated_domain.mob_modules))
		return TRUE

	var/current_index = 1
	shuffle_inplace(generated_domain.mob_modules)

	for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in loaded_atoms)
		if(QDELETED(landmark))
			continue
		if(current_index > length(generated_domain.mob_modules))
			stack_trace("vdom: mobs segments are set to unique, but there are more landmarks than available segments")
			return FALSE

		var/path
		if(generated_domain.modular_unique_mobs)
			path = generated_domain.mob_modules[current_index]
			current_index += 1
		else
			path = pick(generated_domain.mob_modules)

		var/datum/modular_mob_segment/segment = new path()

		var/list/mob_spawns = landmark.spawn_mobs(get_turf(landmark), segment)
		if(length(mob_spawns))
			mutation_candidate_refs += mob_spawns

		qdel(landmark)
		qdel(segment)

	return TRUE


/// Scans over neo's contents for bitrunning tech disks. Loads the items or abilities onto the avatar.
/obj/machinery/quantum_server/proc/stock_gear(mob/living/carbon/human/avatar, mob/living/carbon/human/neo, datum/lazy_template/virtual_domain/generated_domain)
	var/domain_forbids_flags = generated_domain.domain_flags

	var/list/import_ban = list()
	var/list/disk_ban = list()
	if(domain_forbids_flags & DOMAIN_FORBIDS_ITEMS)
		import_ban += "przemycanego sprzętu cyfrowego"
		disk_ban += "przedmioty"
	if(domain_forbids_flags & DOMAIN_FORBIDS_ABILITIES)
		import_ban += "importowanych zdolności"
		disk_ban += "moce"

	if(length(import_ban))
		to_chat(neo, span_warning("Ta domena zabrania [english_list(import_ban, and_text = " i ")]. Twoje zewnętrznie ładowane [english_list(disk_ban, and_text = " i ")] nie zostaną przyznane!"))

	var/return_flags = NONE
	for(var/obj/item/disk/bitrunning/disk in neo.GetAllContents())
		return_flags |= disk.load_onto_avatar(neo, avatar, domain_forbids_flags)
	return_flags |= SEND_SIGNAL(neo, COMSIG_BITRUNNER_STOCKING_GEAR, avatar, domain_forbids_flags)

	if(return_flags & BITRUNNER_GEAR_LOAD_FAILED)
		to_chat(neo, span_warning("Co najmniej jedno z zewnętrznych źródeł danych nie załadowało się. Sprawdź, czy dyski się nie nakładają i czy są aktywne."))
	if(return_flags & BITRUNNER_GEAR_LOAD_BLOCKED)
		to_chat(neo, span_warning("Co najmniej jedno z zewnętrznych źródeł danych zostało zablokowane. Sprawdź ograniczenia domeny."))
