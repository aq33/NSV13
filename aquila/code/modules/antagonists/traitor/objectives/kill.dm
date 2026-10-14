// AQUILA - kill objectives with a twist.
// once: Skyrat-SS13/Skyrat13#157 (+ command only from #1115), behead/calling card: tgstation progression traitors (via DaedalusDock),
// photo: yogstation13/Yogstation minor objective, traitor on traitor: ParadiseSS13/Paradise, blackmail: Skyrat-SS13/Skyrat13#1115

/// Kill a head of staff once, it's still a success if they get revived later.
/datum/objective/assassinate/once
	name = "zabij raz"
	/// Latched the moment the target died
	var/won = FALSE

/datum/objective/assassinate/once/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(!(possible_target.assigned_role in GLOB.command_positions))
			continue
		if(!is_valid_target(possible_target) || !is_unique_objective(possible_target, dupe_search_range) || (possible_target in blacklist))
			continue
		possible_targets += possible_target
	set_target(length(possible_targets) ? pick(possible_targets) : null)
	update_explanation_text()
	return target

/datum/objective/assassinate/once/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Daj nauczkę [target.name], [!target_role_type ? target.assigned_role : target.special_role]. Wystarczy zabić tę osobę raz - jeśli wróci do życia, i tak liczy się sukces."
		START_PROCESSING(SSprocessing, src)
	else
		explanation_text = "Cel dowolny"

/datum/objective/assassinate/once/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/objective/assassinate/once/process()
	if(won || !target)
		return PROCESS_KILL
	if(!considered_alive(target))
		won = TRUE
		return PROCESS_KILL

/datum/objective/assassinate/once/check_completion()
	return won || ..()

/// Cut off the target's head and keep it.
/datum/objective/assassinate/behead
	name = "zetnij głowę"
	martyr_compatible = FALSE

/datum/objective/assassinate/behead/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Zetnij głowę [target.name], [!target_role_type ? target.assigned_role : target.special_role], i miej ją przy sobie do końca zmiany."
	else
		explanation_text = "Cel dowolny"

/datum/objective/assassinate/behead/check_completion()
	if(completed)
		return TRUE
	if(!target)
		return TRUE
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(!isliving(owner_mind.current))
			continue
		for(var/obj/item/bodypart/head/head in owner_mind.current.GetAllContents())
			if(head.brainmob?.mind == target || head.brain?.brainmob?.mind == target || head.real_name == target.name)
				return TRUE
	return FALSE

/// Kill the target and leave a calling card on their body.
/datum/objective/assassinate/calling_card
	name = "wizytówka"
	martyr_compatible = TRUE

/datum/objective/assassinate/calling_card/traitor_roll_setup(datum/antagonist/traitor/rolling)
	. = ..()
	if(.)
		give_special_equipment(list(/obj/item/paper/calling_card))

/datum/objective/assassinate/calling_card/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Zabij [target.name], [!target_role_type ? target.assigned_role : target.special_role], i zostaw przy zwłokach wizytówkę Syndykatu (włóż ją do kieszeni albo plecaka ofiary)."
	else
		explanation_text = "Cel dowolny"

/datum/objective/assassinate/calling_card/check_completion()
	if(completed || !target)
		return TRUE
	if(!..())
		return FALSE
	var/mob/living/body = target.current
	if(!body)
		return FALSE
	return !!(locate(/obj/item/paper/calling_card) in body.GetAllContents())

/obj/item/paper/calling_card
	name = "wizytówka"
	icon_state = "papersyndicate"
	desc = "Mała, elegancka kartka z czerwonym logo Syndykatu."
	default_raw_text = "<center><b>Syndykat pozdrawia.</b></center>"
	show_written_words = FALSE // there is no "papersyndicate_words" state

/// Kill the target and escape with a photo of their corpse.
/datum/objective/assassinate/photo
	name = "zdjęcie zwłok"
	martyr_compatible = FALSE

/datum/objective/assassinate/photo/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Zabij [target.name], [!target_role_type ? target.assigned_role : target.special_role], i miej przy sobie zdjęcie jego zwłok do końca zmiany."
	else
		explanation_text = "Cel dowolny"

/datum/objective/assassinate/photo/check_completion()
	if(completed || !target)
		return TRUE
	if(!..())
		return FALSE
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(!isliving(owner_mind.current))
			continue
		for(var/obj/item/photo/photo in owner_mind.current.GetAllContents())
			for(var/mob/seen in photo.picture?.dead_seen)
				if(seen.real_name == target.name || seen.mind == target)
					return TRUE
	return FALSE

/// Another traitor is the target. They get warned that someone might be coming for them.
/datum/objective/assassinate/traitor
	name = "zdrajca na zdrajcę"

/datum/objective/assassinate/traitor/find_target(list/dupe_search_range, list/blacklist)
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/possible_targets = list()
	for(var/datum/antagonist/traitor/other in GLOB.antagonists)
		var/datum/mind/other_mind = other.owner
		if(!other_mind || other.type != /datum/antagonist/traitor || other.traitor_kind != TRAITOR_HUMAN)
			continue
		if(!is_valid_target(other_mind) || !is_unique_objective(other_mind, dupe_search_range) || (other_mind in blacklist))
			continue
		possible_targets += other_mind
	set_target(length(possible_targets) ? pick(possible_targets) : null)
	update_explanation_text()
	return target

/datum/objective/assassinate/traitor/traitor_roll_setup(datum/antagonist/traitor/rolling)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/traitor/victim = target.has_antag_datum(/datum/antagonist/traitor)
	if(victim && !(locate(/datum/objective/potentially_backstabbed) in victim.objectives))
		var/datum/objective/potentially_backstabbed/warning = new
		warning.owner = target
		victim.add_objective(warning)
		to_chat(target.current, "<span class='userdanger'>Wywiad Syndykatu ostrzega: ktoś z naszych może mieć cię na celowniku.</span>")
		target.announce_objectives()

/datum/objective/assassinate/traitor/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Zabij [target.name], agenta Syndykatu działającego pod przykrywką jako [target.assigned_role]. Przestał być dla nas użyteczny."
	else
		explanation_text = "Cel dowolny"

/// Given to the victim of /datum/objective/assassinate/traitor. Done when every other objective of theirs is done.
/datum/objective/potentially_backstabbed
	name = "możliwa zdrada"
	explanation_text = "Nasz wywiad sugeruje, że możesz być celem rywalizującego agenta Syndykatu. Bądź czujny - wie, kim jesteś i co potrafisz. Wykonaj resztę zadań mimo to."
	martyr_compatible = TRUE

/datum/objective/potentially_backstabbed/check_completion()
	if(completed)
		return TRUE
	for(var/datum/mind/owner_mind as anything in get_owners())
		for(var/datum/antagonist/antag as anything in owner_mind.antag_datums)
			for(var/datum/objective/other_objective as anything in antag.objectives)
				if(other_objective == src || other_objective.optional || istype(other_objective, /datum/objective/potentially_backstabbed))
					continue
				if(!other_objective.check_completion())
					return FALSE
	return TRUE

/// Make sure the target escapes alive and out of custody (Skyrat-SS13/Skyrat13#157)
/datum/objective/breakout
	name = "ucieczka celu"
	martyr_compatible = TRUE

/datum/objective/breakout/traitor_roll_setup(datum/antagonist/traitor/rolling)
	find_target()
	return !!target

/datum/objective/breakout/check_completion()
	return completed || !target || considered_escaped(target)

/datum/objective/breakout/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Dopilnuj, by [target.name], [target.assigned_role], uciekł promem albo kapsułą żywy i nie w areszcie. Nie musi wiedzieć, że mu pomagasz."
	else
		explanation_text = "Cel dowolny"

/datum/objective/breakout/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/// Admin only: implant the target with a blackmail implant (Skyrat-SS13/Skyrat13#1115)
/datum/objective/blackmail_implant
	name = "szantaż"
	martyr_compatible = TRUE

/datum/objective/blackmail_implant/check_completion()
	if(completed)
		return TRUE
	if(!target || !considered_alive(target))
		return FALSE
	return !!(locate(/obj/item/implant/blackmail) in target.current.implants)

/datum/objective/blackmail_implant/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Twój pracodawca chce szantażować [target.name], [target.assigned_role]. Wszczep tej osobie dostarczony implant i dopilnuj, by przeżyła."
	else
		explanation_text = "Cel dowolny"

/datum/objective/blackmail_implant/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
	give_special_equipment(list(/obj/item/implanter/blackmail))

/obj/item/implant/blackmail
	name = "implant szantażu"
	desc = "Do szantażowania."
	activated = FALSE

/obj/item/implant/blackmail/Initialize(mapload)
	. = ..()
	create_reagents(50, NO_REACT) // so it doesn't react until it's injected
	if(prob(65)) // mostly poison, sometimes an explosive mix, so doctors can't meta it
		reagents.add_reagent_list(list(/datum/reagent/toxin/amatoxin = 15, /datum/reagent/toxin/formaldehyde = 15, /datum/reagent/toxin/cyanide = 10, /datum/reagent/toxin/anacea = 10))
	else
		reagents.add_reagent_list(list(/datum/reagent/water = 25, /datum/reagent/potassium = 25))

/obj/item/implant/blackmail/removed(mob/living/source, silent = FALSE, special = 0)
	if(!special && iscarbon(source) && reagents?.total_volume)
		reagents.trans_to(source, reagents.total_volume)
		to_chat(source, "<span class='italics'>Słyszysz cichy pisk.</span>")
	return ..()

/obj/item/implanter/blackmail
	name = "implanter (szantaż)"
	desc = "Sterylny automatyczny wstrzykiwacz implantów. Mała etykieta ostrzega, by nie ruszać implantu po wszczepieniu."
	imp_type = /obj/item/implant/blackmail
