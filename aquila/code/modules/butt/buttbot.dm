// Buttbot, ported from HippieStation13 (code/modules/hippie/mobs/simple/buttbot.dm).
// Build one by hitting a butt with a robotic arm.

/mob/living/simple_animal/bot/buttbot
	name = "buttbot"
	desc = "It's a robotic butt. Are you dense or something??"
	icon = 'aquila/icons/mob/buttbot.dmi'
	icon_state = "buttbot"
	density = FALSE
	health = 25
	maxHealth = 25
	window_name = "Buttbot v1.0"
	/// Do we hiss when buttspeech?
	var/xeno = FALSE
	var/cooldown = 0
	var/list/speech_buffer = list()
	var/list/speech_list = list("butt.", "butts.", "ass.", "fart.", "assblast usa", "woop get an ass inspection", "woop") //Hilarious.

/mob/living/simple_animal/bot/buttbot/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/mob/living/simple_animal/bot/buttbot/update_icon_state()
	. = ..()
	icon_state = xeno ? "buttbot_xeno" : "buttbot"

/mob/living/simple_animal/bot/buttbot/proc/make_xeno()
	xeno = TRUE
	speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")
	update_icon()

/mob/living/simple_animal/bot/buttbot/explode()
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/T = get_turf(src)
	if(prob(50))
		new /obj/item/bodypart/l_arm/robot(T)
	if(xeno)
		new /obj/item/organ/butt/xeno(T)
	else
		new /obj/item/organ/butt(T)
	do_sparks(3, TRUE, src)
	return ..()

/mob/living/simple_animal/bot/buttbot/handle_automated_action()
	if(!..())
		return

	if(isturf(loc))
		var/anydir = pick(GLOB.cardinals)
		if(Process_Spacemove(anydir))
			Move(get_step(src, anydir), anydir)

	if(prob(5) && cooldown < world.time)
		cooldown = world.time + 20 SECONDS
		if(xeno) //Hiss like a motherfucker
			playsound(loc, "hiss", 15, TRUE, 1)
		var/phrase
		if(prob(70) && speech_buffer.len)
			phrase = buttificate(pick(speech_buffer))
			if(prob(5))
				speech_buffer -= pick(speech_buffer) //so they're not magic wizard guru buttbots that hold arcane information collected during an entire round.
		speak(phrase || pick(speech_list))

/mob/living/simple_animal/bot/buttbot/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	//Also dont imitate ourselves. Imitate other buttbots though heheh
	if(speaker != src && raw_message && prob(40))
		if(speech_buffer.len >= 20)
			speech_buffer -= pick(speech_buffer)
		speech_buffer |= html_decode(raw_message)

/// Randomly replaces words with "butt". Returns null if nothing got buttified.
/proc/buttificate(phrase)
	var/list/words = splittext(phrase, " ")
	var/list/out = list()
	var/buttified = FALSE
	for(var/word in words)
		if(prob(20))
			word = "butt"
			buttified = TRUE
		out += word
	if(!buttified)
		return
	return jointext(out, " ")
