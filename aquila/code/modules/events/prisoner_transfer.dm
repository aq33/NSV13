// AQUILA - Prisoner Transfer: a ghost becomes a convict that CentCom drops into the permabrig with a supply pod.
// The whole ship is told who is coming and what for, so security can pick them up.

/// What CentCom convicted the transferred prisoner of, one is picked per transfer
GLOBAL_LIST_INIT(aquila_prisoner_crimes, list(
	"kradzież mienia Nanotrasen",
	"przemyt kontrabandy",
	"napaść na członka załogi",
	"dezercję",
	"sabotaż",
	"posiadanie nielegalnych substancji",
	"włamanie do zbrojowni",
	"fałszowanie dokumentów",
	"podżeganie do buntu",
	"nielegalne klonowanie",
	"kłusownictwo na kosmicznych karpiach",
	"obrazę kapitana",
))

/datum/round_event_control/aquila_prisoner_transfer
	name = "Prisoner Transfer"
	typepath = /datum/round_event/ghost_role/aquila_prisoner_transfer
	weight = 10
	max_occurrences = 1
	min_players = 10
	earliest_start = 15 MINUTES
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/aquila_prisoner_transfer/canSpawnEvent(players_amt, gamemode)
	if(!length(aquila_prisoner_transfer_turfs()))
		return FALSE
	return ..()

/datum/round_event/ghost_role/aquila_prisoner_transfer
	minimum_required = 1
	role_name = "Transferred Prisoner"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_prisoner_transfer/spawn_role()
	var/list/candidates = get_candidates(BAN_ROLE_ALL_GHOST, null)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	// The poll takes a while, pick the landing spot afterwards so it is still free
	var/list/turfs = aquila_prisoner_transfer_turfs()
	if(!length(turfs))
		return MAP_ERROR
	var/turf/landing = pick(turfs)

	var/mob/dead/selected = pick(candidates)
	var/crime = pick(GLOB.aquila_prisoner_crimes)
	var/sentence_minutes = rand(15, 30)

	var/obj/structure/closet/supplypod/centcompod/pod = new()
	var/mob/living/carbon/human/prisoner = new(pod)
	randomize_human(prisoner)
	prisoner.dna.update_dna_identity()

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	player_mind.transfer_to(prisoner)
	player_mind.assigned_role = JOB_NAME_PRISONER

	prisoner.equipOutfit(/datum/outfit/aquila_transferred_prisoner)
	// The prisoner card counts the sentence down by itself and gives prisoner access once it is served
	var/obj/item/card/id/prisoner/card = new(prisoner, sentence_minutes * 60, crime, prisoner.real_name)
	prisoner.equip_to_slot_or_del(card, ITEM_SLOT_ID)

	new /obj/effect/pod_landingzone(landing, pod)

	to_chat(prisoner, "<span class='big bold'>Jesteś więźniem przeniesionym na statek przez Centralę.</span>")
	to_chat(prisoner, "<span class='notice'>Skazano cię za <b>[crime]</b> na <b>[sentence_minutes] minut</b> odsiadki. \
		Kapsuła zaraz wyląduje w celi. Twoja karta więźnia odlicza wyrok, a po jego odbyciu jesteś wolny. \
		Nie jesteś antagonistą: możesz próbować ucieczki, ale nie zabijaj ani nie sabotuj bez powodu.</span>")
	player_mind.store_memory("Skazano cię za [crime] na [sentence_minutes] minut odsiadki.")

	priority_announce("Centrala przekazuje na pokład osadzonego [prisoner.real_name], skazanego za [crime]. \
		Wyrok: [sentence_minutes] minut. Kapsuła z więźniem wyląduje w obszarze [get_area_name(landing, TRUE)]. \
		Ochrona proszona jest o przejęcie osadzonego.", "Transfer więźnia")

	message_admins("[ADMIN_LOOKUPFLW(prisoner)] has been made into a transferred prisoner by an event.")
	log_game("[key_name(prisoner)] was spawned as a transferred prisoner by an event at [AREACOORD(landing)].")
	spawned_mobs += prisoner
	return SUCCESSFUL_SPAWN

/datum/outfit/aquila_transferred_prisoner
	name = "Transferred Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange

/// Free floor turfs in the permabrig, or in the brig on maps that have no permabrig
/proc/aquila_prisoner_transfer_turfs()
	for(var/areatype in list(/area/security/prison, /area/security/brig))
		. = list()
		for(var/turf/open/floor/T in get_area_turfs(areatype, subtypes = TRUE))
			if(!is_station_level(T.z) || is_blocked_turf(T, TRUE))
				continue
			. += T
		if(length(.))
			return
