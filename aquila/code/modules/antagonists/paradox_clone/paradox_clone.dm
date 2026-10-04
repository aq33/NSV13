// AQUILA - port of the Paradox Clone ghost antagonist (tgstation#71141),
// including the upstream follow-up fixes tgstation#73567 (plasmamen) and tgstation#74989 (no duplicate_object).

/datum/antagonist/paradox_clone
	name = "Paradox Clone"
	roundend_category = "Paradox Clones"
	antagpanel_category = "Paradox Clone"
	banning_key = ROLE_PARADOX_CLONE
	show_in_antagpanel = FALSE // needs an original and a freshly copied body, spawned by the event/ruleset only
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	count_against_dynamic_roll_chance = FALSE
	///Weakref to the mind of the original, the clone's target.
	var/datum/weakref/original_ref

/datum/antagonist/paradox_clone/on_gain()
	owner.special_role = ROLE_PARADOX_CLONE
	return ..()

/datum/antagonist/paradox_clone/on_removal()
	//don't null it if we got a different one added on top, somehow.
	if(owner.special_role == ROLE_PARADOX_CLONE)
		owner.special_role = null
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/Destroy()
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/apply_innate_effects(mob/living/mob_override)
	var/mob/living/clone = mob_override || owner.current
	add_antag_hud(ANTAG_HUD_PARADOX_CLONE, "paradox_clone", clone)

/datum/antagonist/paradox_clone/remove_innate_effects(mob/living/mob_override)
	var/mob/living/clone = mob_override || owner.current
	remove_antag_hud(ANTAG_HUD_PARADOX_CLONE, clone)

/datum/antagonist/paradox_clone/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/weapons/zapbang.ogg', 50, FALSE, pressure_affected = FALSE)
	to_chat(owner, "<span class='userdanger'>Jesteś Klonem Paradoksu!</span>")
	to_chat(owner, "<B>Anomalia czasoprzestrzenna przeniosła cię do innej rzeczywistości. Twój odpowiednik wciąż tu żyje - i jest tu miejsce tylko dla jednego z was.</B>")
	to_chat(owner, "<B>Znajdź swojego odpowiednika, zabij go i zajmij jego miejsce. Nikt nie może się zorientować, że jest was dwóch.</B>")

/datum/antagonist/paradox_clone/proc/setup_clone()
	var/datum/mind/original_mind = original_ref?.resolve()

	var/datum/objective/assassinate/paradox_clone/kill = new
	kill.owner = owner
	kill.set_target(original_mind)
	kill.update_explanation_text()
	objectives += kill
	log_objective(owner, kill.explanation_text)

	owner.assigned_role = ROLE_PARADOX_CLONE

	var/mob/living/carbon/human/clone_human = owner.current
	if(istype(clone_human))
		//clone doesnt show up on message lists
		for(var/obj/item/modular_computer/messenger in clone_human.GetAllContents())
			messenger.messenger_invisible = TRUE

		//dont want anyone noticing there's two now
		var/obj/item/clothing/under/sensor_clothes = clone_human.w_uniform
		if(istype(sensor_clothes))
			sensor_clothes.sensor_mode = SENSOR_OFF
			clone_human.update_suit_sensors()

	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Klon Paradoksu",
		"Zabij i zastąp [original_mind ? original_mind.name : "swojego odpowiednika"]. Wtop się w tłum.")

/datum/antagonist/paradox_clone/roundend_report_header()
	return "<span class='header'>Na pokładzie pojawił się klon paradoksu!</span><br>"

/**
 * Paradox clone assassinate objective
 * Similar to the original, but with a different flavortext.
 */
/datum/objective/assassinate/paradox_clone
	name = "clone assassinate"

/datum/objective/assassinate/paradox_clone/update_explanation_text()
	..()
	if(!target?.current)
		explanation_text = "Cel dowolny"
		if(owner)
			message_admins("WARNING! [ADMIN_LOOKUPFLW(owner.current)] paradox clone objectives forged without an original!")
		return
	explanation_text = "Zabij i zastąp [target.name], [!target_role_type ? target.assigned_role : target.special_role]. Pamiętaj, masz się wtopić w tłum - nie zabijaj nikogo innego, chyba że musisz!"

/**
 * Makes a full copy of src and returns it.
 * Attempts to copy as much as possible to be a close to the original.
 * This includes the job outfit (plasmamen get their envirosuit through the job), quirks, and mutations.
 * We do not set a mind here, so this is purely the body.
 * Args:
 * location - The turf the human will be spawned on.
 */
/mob/living/carbon/human/proc/make_full_human_copy(turf/location)
	RETURN_TYPE(/mob/living/carbon/human)

	var/mob/living/carbon/human/clone = new(location)

	clone.fully_replace_character_name(null, dna.real_name)
	copy_clothing_prefs(clone)
	clone.age = age
	dna.transfer_identity(clone, transfer_SE = TRUE)
	clone.updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)
	clone.domutcheck()

	var/datum/job/original_job = SSjob.GetJob(mind?.assigned_role || job)
	if(original_job)
		clone.job = original_job.title
		original_job.equip(clone, announce = FALSE)

	for(var/datum/quirk/original_quirk in roundstart_quirks)
		clone.add_quirk(original_quirk.type, TRUE)

	return clone

/// Picks a living, connected crew member to be the original of a paradox clone. Returns null if there is nobody.
/proc/paradox_clone_find_original()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.client || !player.mind || player.stat != CONSCIOUS)
			continue
		if(!SSjob.GetJob(player.mind.assigned_role)) // crew only
			continue
		if(player.mind.has_antag_datum(/datum/antagonist/paradox_clone))
			continue
		possible_targets += player
	if(length(possible_targets))
		return pick(possible_targets)
	return null

/// Turfs a paradox clone can appear on: xeno spawns in maintenance, or any xeno spawn if the map has none there.
/proc/paradox_clone_spawn_locations()
	var/list/possible_spawns = list()
	for(var/turf/warp_point in GLOB.xeno_spawn)
		if(istype(warp_point.loc, /area/maintenance))
			possible_spawns += warp_point
	if(!length(possible_spawns))
		for(var/turf/warp_point in GLOB.xeno_spawn)
			possible_spawns += warp_point
	return possible_spawns

/**
 * Creates a paradox clone of original for the player with the given key.
 * Shared by the random event and the dynamic ruleset.
 * Returns the clone mob.
 */
/proc/create_paradox_clone(player_key, mob/living/carbon/human/original, turf/spawn_location, source = "an event")
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/clone = original.make_full_human_copy(spawn_location)
	player_mind.transfer_to(clone)

	var/datum/antagonist/paradox_clone/new_datum = player_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	new_datum.original_ref = WEAKREF(original.mind)
	new_datum.setup_clone()

	playsound(clone, 'sound/weapons/zapbang.ogg', 30, TRUE)
	new /obj/item/storage/toolbox/mechanical(clone.loc) //so they dont get stuck in maints

	message_admins("[ADMIN_LOOKUPFLW(clone)] has been made into a Paradox Clone of [ADMIN_LOOKUPFLW(original)] by [source].")
	log_game("[key_name(clone)] was spawned as a Paradox Clone of [key_name(original)] by [source].")
	return clone
