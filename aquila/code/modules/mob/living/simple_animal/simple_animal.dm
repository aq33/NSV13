/mob/living/simple_animal
	var/should_talk = TRUE //Should it be able to talk?

/mob/living/simple_animal/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(should_talk)
		. = ..()
	else
		return

/mob/living/simple_animal/proc/find_candidates()
	if(!mind && level == 2)
		notify_ghosts("Można sterować: [src]", null, enter_link="<a href=byond://?src=[REF(src)];activate=1>(Kliknij, by zagrać)</a>", source=src, action=NOTIFY_ATTACK, ignore_key = POLL_IGNORE_SPIDER)

/mob/living/simple_animal/proc/give_to_ghost(mob/dead/observer/user, bypass_level = FALSE)
	if(QDELETED(src) || QDELETED(user) || !src.playable || level != 2)
		if(!bypass_level)
			return
	if(!SSticker.mode)
		to_chat(user, "Nie możesz zostać [src] przed rozpoczęciem gry.")
		return
	var/be_mob = alert("Zostać [src]? (Uwaga: nie będzie można cię sklonować!)",,"Yes","No")
	if(be_mob == "No" || QDELETED(src) || !isobserver(user) || src.mind)
		return

	src.should_talk = FALSE
	src.playable = FALSE
	src.key = user.key
	sentience_act() // prevent weirdness such as AI still doing its thing
	src.stop_automated_movement = TRUE // bo sie borowik rusza

	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
