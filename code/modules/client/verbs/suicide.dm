/mob/var/suiciding = 0

/mob/proc/set_suicide(suicide_state)
	suiciding = suicide_state
	if(suicide_state)
		add_to_mob_suicide_list()
	else
		remove_from_mob_suicide_list()

/mob/living/carbon/set_suicide(suicide_state) //you thought that box trick was pretty clever, didn't you? well now hardmode is on, boyo.
	. = ..()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		B.suicided = suicide_state

/mob/living/silicon/robot/set_suicide(suicide_state)
	. = ..()
	if(mmi)
		if(mmi.brain)
			mmi.brain.suicided = suicide_state
		if(mmi.brainmob)
			mmi.brainmob.suiciding = suicide_state

/mob/living/carbon/human/virtual_reality/set_suicide(suicide_state)
	return

/mob/living/carbon/human/virtual_reality/canSuicide()
	to_chat(src, "<span class='warning'>Przykro mi, [first_name()], obawiam się, że nie mogę na to pozwolić.</span>")
	return

/mob/living/carbon/human/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/oldkey = ckey
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(ckey != oldkey)
		return
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE) //need to be called before calling suicide_act as fuck knows what suicide_act will do with your suicider
		var/obj/item/held_item = get_active_held_item()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					set_suicide(FALSE)
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "shameful_suicide", /datum/mood_event/shameful_suicide)
					return

				if(damagetype & MANUAL_SUICIDE_NONLETHAL) //Make sure to call the necessary procs if it does kill later
					set_suicide(FALSE)
					return

				suicide_log()

				var/damage_mod = 0
				for(var/T in list(BRUTELOSS, FIRELOSS, TOXLOSS, OXYLOSS))
					damage_mod += (T & damagetype) ? 1 : 0
				damage_mod = max(1, damage_mod)

				//Do 200 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(200/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(200/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(200/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(200/damage_mod)

				if(damagetype & MANUAL_SUICIDE)	//Assume the object will handle the death.
					return

				//If something went wrong, just do normal oxyloss
				if(!(damagetype & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
					adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				death(FALSE)
				ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

				return

		var/suicide_message

		if(!combat_mode)
			suicide_message = pick(
				"[src] przytula się na śmierć! Wygląda na to, że próbuje popełnić samobójstwo.", \
				"[src] przybija sobie piątkę na śmierć! Wygląda na to, że próbuje popełnić samobójstwo.", \
				"[src] za bardzo odlatuje na haju życia! Wygląda na to, że próbuje popełnić samobójstwo.")
		else
			suicide_message = pick("[src] próbuje odgryźć sobie język! Wygląda na to, że próbuje popełnić samobójstwo.", \
				"[src] wbija sobie kciuki w oczodoły! Wygląda na to, że próbuje popełnić samobójstwo.", \
				"[src] skręca sobie kark! Wygląda na to, że próbuje popełnić samobójstwo.", \
				"[src] wstrzymuje oddech! Wygląda na to, że próbuje popełnić samobójstwo.")

		visible_message("<span class='danger'>[suicide_message]</span>", "<span class='userdanger'>[suicide_message]</span>")

		suicide_log()

		adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/brain/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>Mózg [src] staje się tępy i bez życia. Wygląda na to, że stracił wolę życia.</span>", \
						"<span class='userdanger'>Mózg [src] staje się tępy i bez życia. Wygląda na to, że stracił wolę życia.</span>")

		suicide_log()

		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>[src] próbuje przegryźć sobie język. Wygląda na to, że próbuje popełnić samobójstwo.</span>", \
				"<span class='userdanger'>[src] próbuje przegryźć sobie język. Wygląda na to, że próbuje popełnić samobójstwo.</span>")

		suicide_log()

		adjustOxyLoss(max(200- getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>[src] się wyłącza. Wygląda na to, że próbuje popełnić samobójstwo.</span>", \
				"<span class='userdanger'>[src] się wyłącza. Wygląda na to, że próbuje popełnić samobójstwo.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>[src] się wyłącza. Wygląda na to, że próbuje popełnić samobójstwo.</span>", \
				"<span class='userdanger'>[src] się wyłącza. Wygląda na to, że próbuje popełnić samobójstwo.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/silicon/pai/verb/suicide()
	set hidden = 1
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(confirm == "Yes")
		var/turf/T = get_turf(src.loc)
		T.visible_message("<span class='notice'>Na ekranie [src] wyświetla się komunikat: \"Wymazywanie plików rdzenia. Aby dalej korzystać z funkcji urządzenia pAI, pozyskaj nową osobowość.\"</span>", null, \
		 "<span class='notice'>[src] elektronicznie piszczy.</span>")

		suicide_log()

		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind
	else
		to_chat(src, "Przerywanie próby samobójczej.")

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>[src] miota się dziko! Wygląda na to, że próbuje popełnić samobójstwo.</span>", \
				"<span class='userdanger'>[src] miota się dziko! Wygląda na to, że próbuje popełnić samobójstwo.</span>", \
				"<span class='italics'>Słyszysz, jak coś się miota.</span>")

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(200 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/simple_animal/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert("Na pewno chcesz popełnić samobójstwo?", "Potwierdź samobójstwo", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message("<span class='danger'>[src] zaczyna się przewracać. Wygląda na to, że stracił wolę życia.</span>", \
						"<span class='userdanger'>[src] zaczyna się przewracać. Wygląda na to, że stracił wolę życia.</span>")

		suicide_log()

		death(FALSE)
		ghostize(FALSE,SENTIENCE_ERASE)	// Disallows reentering body and disassociates mind

/mob/living/proc/suicide_log()
	log_game("[key_name(src)] committed suicide at [AREACOORD(src)] as [src.type].")
	if(CONFIG_GET(flag/restricted_suicide))
		message_admins("[key_name(src)] committed suicide at [AREACOORD(src)] as [src.type].")

/mob/living/carbon/human/suicide_log()
	log_game("[key_name(src)] (job: [src.job ? "[src.job]" : "None"]) committed suicide at [AREACOORD(src)].")
	if(CONFIG_GET(flag/restricted_suicide))
		message_admins("[key_name(src)] (job: [src.job ? "[src.job]" : "None"]) committed suicide at [AREACOORD(src)].")

/mob/living/proc/canSuicide()
	switch(stat)
		if(CONSCIOUS)
			return TRUE
		if(SOFT_CRIT)
			to_chat(src, "Nie możesz popełnić samobójstwa w stanie krytycznym!")
		if(UNCONSCIOUS)
			to_chat(src, "Musisz być przytomny, żeby popełnić samobójstwo!")
		if(DEAD)
			to_chat(src, "Już nie żyjesz!")
	return

/mob/living/carbon/canSuicide()
	if(!..())
		return
	if(!(mobility_flags & MOBILITY_USE))	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, "Nie możesz popełnić samobójstwa, gdy nie możesz się ruszać! ((Możesz za to wpisać Ghost.))")
		return
	if(has_horror_inside()) // AQ EDIT - Yogstation#13033
		to_chat(src, "Coś w twojej głowie powstrzymuje cię przed tym!")
		return
	if(CONFIG_GET(flag/restricted_suicide))
		if(alert("Samobójstwo jest mocno odradzane, a w niektórych przypadkach łamie zasady. Rozważ wejście do kriokapsuły albo kontakt z adminami. Na pewno chcesz kontynuować?",,"Confirm","Cancel") != "Confirm")
			return
		if(world.time < (SSticker.round_start_time + (15 MINUTES)))
			var/timeleft = ((SSticker.round_start_time + (15 MINUTES)) - world.time)
			to_chat(src, "<span class='boldannounce'>Popełnianie samobójstwa na początku rundy jest zabronione. Czas do możliwości samobójstwa: [DisplayTimeText(timeleft)].</span>")
			if(src.job)
				message_admins("[key_name(src)] (job: [src.job]) attempted to commit suicide at [AREACOORD(src)]. Time until suicide is possible: [DisplayTimeText(timeleft)].")
			return

	return TRUE
