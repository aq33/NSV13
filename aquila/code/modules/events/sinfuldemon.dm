/datum/round_event_control/sinfuldemon
	name = "Create Demon of Sin"
	typepath = /datum/round_event/ghost_role/sinfuldemon
	max_occurrences = 2 //misery loves company
	min_players = 15
	weight = 10 //zmienić to by zwiększyć szansę na Grzech Demon

/datum/round_event/ghost_role/sinfuldemon
	var/success_spawn = 0
	minimum_required = 1
	role_name = "demon of sin"
	fakeable = FALSE

/datum/round_event/ghost_role/sinfuldemon/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()

/datum/round_event/ghost_role/sinfuldemon/spawn_role()
	//selecting a spawn_loc
	if(!SSjob.latejoin_trackers.len)
		return MAP_ERROR

	//selecting a candidate player
	var/list/candidates = get_candidates(ROLE_SINFULDEMON, /datum/role_preference/midround_ghost/sinfuldemon)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected_candidate = pick_n_take(candidates)
	var/key = selected_candidate.key

	var/datum/mind/Mind = create_sinfuldemon_mind(key)
	Mind.active = TRUE

	var/mob/living/carbon/human/sinfuldemon = create_event_sinfuldemon()
	Mind.transfer_to(sinfuldemon)
	Mind.add_antag_datum(/datum/antagonist/sinfuldemon)

	spawned_mobs += sinfuldemon
	message_admins("[ADMIN_LOOKUPFLW(sinfuldemon)] has been made into a demon of sin by an event.")
	log_game("[key_name(sinfuldemon)] was spawned as a demon of sin by an event.")
	var/datum/job/jobdatum = SSjob.GetJob(JOB_NAME_ASSISTANT)
	if(SSshuttle.arrivals)
		SSshuttle.arrivals.QueueAnnounce(sinfuldemon, jobdatum.title)
	Mind.assigned_role = jobdatum.title //sets up the manifest properly
	jobdatum.equip(sinfuldemon)
	var/obj/item/card/id/id = sinfuldemon.get_idcard()
	if(istype(id))
		id.assignment = jobdatum.title
		id.update_label()
	GLOB.data_core.manifest_inject(sinfuldemon)
	return SUCCESSFUL_SPAWN


/proc/create_event_sinfuldemon(spawn_loc)
	var/mob/living/carbon/human/new_sinfuldemon = new(spawn_loc)
	if(!spawn_loc)
		SSjob.SendToLateJoin(new_sinfuldemon)
	var/datum/character_save/CS = new() //Randomize appearance for the demon.
	CS.copy_to(new_sinfuldemon)
	new_sinfuldemon.dna.update_dna_identity()
	return new_sinfuldemon

/proc/create_sinfuldemon_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.special_role = ROLE_SINFULDEMON
	return Mind
