GLOBAL_VAR_INIT(curse_of_madness_triggered, FALSE)

/proc/curse_of_madness(mob/user, message)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, "<span class='warning'>Zsyłasz klątwę szaleństwa z wiadomością \"[message]\"!</span>")
		message_admins("[ADMIN_LOOKUPFLW(user)] sent a curse of madness with the message \"[message]\"!")
		log_game("[key_name(user)] sent a curse of madness with the message \"[message]\"!")

	GLOB.curse_of_madness_triggered = message // So latejoiners are also afflicted.

	deadchat_broadcast("<span class='deadsay'>Na stację spada <span class='name'>Klątwa Szaleństwa</span>, rozbijając umysły załogi straszliwym sekretem: \"<span class='big hypnophrase'>[message]</span>\"</span>")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(T && !is_station_level(T.z))
			continue
		if(H.anti_magic_check(TRUE, FALSE) || HAS_TRAIT(H, TRAIT_WARDED))
			to_chat(H, "<span class='notice'>Przez chwilę masz dziwne uczucie, ale to mija.</span>")
			continue
		if(istype(H.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			to_chat(H, "<span class='warning'>Twoje ochronne nakrycie głowy odbija fale mózgowe kontrolujące umysł!</span>")
			continue
		give_madness(H, message)

/proc/give_madness(mob/living/carbon/human/H, message)
	H.playsound_local(H,'sound/magic/curse.ogg',40,1)
	to_chat(H, "<span class='reallybig hypnophrase'>[message]</span>")
	to_chat(H, "<span class='warning'>Twój umysł się rozpada!</span>")
	switch(rand(1,10))
		if(1 to 3)
			H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
			H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
		if(4 to 6)
			H.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
		if(7 to 8)
			H.gain_trauma_type(BRAIN_TRAUMA_MAGIC, TRAUMA_RESILIENCE_LOBOTOMY)
		if(9 to 10)
			H.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_LOBOTOMY)
