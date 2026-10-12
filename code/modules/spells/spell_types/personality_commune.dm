/obj/effect/proc_holder/spell/targeted/personality_commune
	name = "Personality Commune"
	desc = "Sends thoughts to your alternate consciousness."
	charge_max = 0
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "telepathy"
	action_background_icon_state = "bg_spell"
	var/datum/brain_trauma/severe/split_personality/trauma
	var/flufftext = "Słyszysz w głowie odbijający się echem głos..."

/obj/effect/proc_holder/spell/targeted/personality_commune/New(datum/brain_trauma/severe/split_personality/T)
	. = ..()
	trauma = T

// Pillaged and adapted from telepathy code
/obj/effect/proc_holder/spell/targeted/personality_commune/cast(list/targets, mob/user)
	if(!istype(trauma))
		to_chat(user, "<span class='warning'>Coś jest nie tak; przez błąd albo adminowe żarty próbujesz rzucić to zaklęcie bez rozszczepionej osobowości!</span>")
		return
	var/msg = stripped_input(usr, "Co chcesz przekazać swojemu drugiemu ja?", null , "")
	if(!msg)
		charge_counter = charge_max
		return
	if(CHAT_FILTER_CHECK(msg))
		to_chat(usr, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return
	msg = user.treat_message_min(msg)
	to_chat(user, "<span class='boldnotice'>Skupiasz się i przesyłasz myśli swojemu drugiemu ja:</span> <span class='notice'>[msg]</span>")
	to_chat(trauma.owner, "<span class='boldnotice'>[flufftext]</span> <span class='notice'>[msg]</span>")
	log_directed_talk(user, trauma.owner, msg, LOG_SAY ,"[name]")
	for(var/ded in GLOB.dead_mob_list)
		if(!isobserver(ded))
			continue
		to_chat(ded, "[FOLLOW_LINK(ded, user)] <span class='boldnotice'>[user] [name]:</span> <span class='notice'>\"[msg]\" to</span><span class='name'>[trauma]</span>")
