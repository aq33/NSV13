//HUGBOT
//HUGBOT PATHFINDING
//HUGBOT ASSEMBLY

#define HUGBOT_PANIC_NONE	0
#define HUGBOT_PANIC_LOW	15
#define HUGBOT_PANIC_MED	35
#define HUGBOT_PANIC_HIGH	55
#define HUGBOT_PANIC_FUCK	70
#define HUGBOT_PANIC_ENDING	90
#define HUGBOT_PANIC_END	100

/mob/living/simple_animal/bot/hugbot
	name = "\improper Hugbot"
	desc = "A little cudly robot. He looks excited."
	icon = 'nsv13/icons/mob/aibots.dmi'
	icon_state = "hugbot1"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB

	status_flags = (CANPUSH | CANSTUN)

	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

	bot_type = HUG_BOT
	model = "Hugbot"
	bot_core_type = /obj/machinery/bot_core/hugbot
	window_id = "autohug"
	window_name = "Automatyczna Jednostka Przytulania v2.0"
	path_image_color = "#FFDDDD"

	var/stationary_mode = 0 //If enabled, the Hugbot will not move automatically.
	var/max_sanity = 70 // Sanity needed to allow hugging
	var/shut_up = 0 // Self explanitory
	var/tania_mode = 0 // When enabled, the hug bot will not change targets, and will hug regardless of mood

	zone_selected = BODY_ZONE_CHEST

	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/last_found = 0

	//Are we tipped over? Used to stop the mode from being conflicted.
	var/tipped = FALSE
	//How panicked we are about being tipped over (why would you do this?)
	var/tipped_status = HUGBOT_PANIC_NONE
	//The name we got when we were tipped
	var/tipper_name
	//The last time we were tipped/righted and said a voice line, to avoid spam
	var/last_tipping_action_voice = 0

/mob/living/simple_animal/bot/hugbot/update_icon()
	cut_overlays()
	if(!on)
		icon_state = "hugbot0"
		return
	if(IsStun())
		icon_state = "hugbota"
		return
	if(mode == BOT_HEALING)
		icon_state = "hugbots[stationary_mode+1]"
		return
	else
		icon_state = "hugbot[stationary_mode+1]"

/mob/living/simple_animal/bot/medbot/Initialize()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/hugbot/bot_reset()
	..()
	update_icon()

/mob/living/simple_animal/bot/hugbot/proc/soft_reset()
	path = list()
	patient = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()

/mob/living/simple_animal/bot/hugbot/set_custom_texts()
	text_hack = "Omijasz czujniki nacisku manipulatorów [name]."
	text_dehack = "Przełączasz z powrotem czujniki nacisku manipulatorów [name]."
	text_dehack_fail = "[name] wygląda na uszkodzonego i nie reaguje na przeprogramowanie!"

/mob/living/simple_animal/bot/hugbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Sterowanie jednostką przytulania v2.0</B></TT><BR><BR>"
	dat += "Status: <A href='byond://?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Panel serwisowy jest [open ? "otwarty" : "zamknięty"]<BR>"
	dat += "Sterowanie zachowaniem jest [locked ? "zablokowane" : "odblokowane"]<hr>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "Maksymalna poczytalność: "
		dat += "<a href='byond://?src=[REF(src)];adj_sanity=-10'>-</a> "
		dat += "[max_sanity] "
		dat += "<a href='byond://?src=[REF(src)];adj_sanity=10'>+</a> "
		dat += "<br>"
		dat += "Tryb pracy: "
		switch(zone_selected)
			if(BODY_ZONE_CHEST)
				dat += "<a href='byond://?src=[REF(src)];op_mode=[BODY_ZONE_HEAD]'>Hug</a>"
			if(BODY_ZONE_HEAD)
				dat += "<a href='byond://?src=[REF(src)];op_mode=[BODY_ZONE_PRECISE_MOUTH]'>Pat</a>"
			if(BODY_ZONE_PRECISE_MOUTH)
				dat += "<a href='byond://?src=[REF(src)];op_mode=[BODY_ZONE_CHEST]'>Boop</a>"
		dat += "<br>"
		dat += "Głośnik jest [shut_up ? "wyłączony" : "włączony"]. <a href='byond://?src=[REF(src)];togglevoice=[1]'>Przełącz</a><br>"
		dat += "Patrolowanie stacji: <a href='byond://?src=[REF(src)];operation=patrol'>[auto_patrol ? "Tak" : "Nie"]</a><br>"
		dat += "Tryb stacjonarny: <a href='byond://?src=[REF(src)];stationary=1'>[stationary_mode ? "Tak" : "Nie"]</a><br><hr>"
	if(open || IsAdminGhost(user))
		dat += "Jest odsłonięty różowy przewód, który jest <a href='byond://?src=[REF(src)];tania_mode=1'>[tania_mode ? "przecięty" : "nienaruszony"]</a><br>"

	return dat

/mob/living/simple_animal/bot/hugbot/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["adj_sanity"])
		var/adjust_num = text2num(href_list["adj_sanity"])
		max_sanity += adjust_num
		if(max_sanity < SANITY_CRAZY)
			max_sanity = SANITY_CRAZY
		if(max_sanity > SANITY_GREAT)
			max_sanity = SANITY_GREAT

	if(href_list["op_mode"])
		mode = href_list["op_mode"]
		zone_selected = mode

	else if(href_list["togglevoice"])
		shut_up = !shut_up

	else if(href_list["tania_mode"])
		tania_mode = !tania_mode

	else if(href_list["stationary"])
		stationary_mode = !stationary_mode
		path = list()
		update_icon()

	update_controls()
	return

/mob/living/simple_animal/bot/hugbot/attackby(obj/item/W as obj, mob/user as mob, params)
	var/current_health = health
	..()
	if(health < current_health) //if hugbot took some damage
		step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/attack_paw(mob/user)
	return attack_hand(user)

/mob/living/simple_animal/bot/hugbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_DISARM && !tipped)
		H.visible_message("<span class='danger'>[H] zaczyna przewracać [src].</span>", "<span class='warning'>Zaczynasz przewracać [src]...</span>")

		if(world.time > last_tipping_action_voice + 15 SECONDS)
			last_tipping_action_voice = world.time // message for tipping happens when we start interacting, message for righting comes after finishing
			var/list/messagevoice = list("Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',"Please don't..." = 'sound/voice/medbot/please_dont.ogg',"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg', "Nooo..." = 'sound/voice/medbot/nooo.ogg', "Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 70, FALSE)

		if(do_after(H, 3 SECONDS, target=src))
			tip_over(H)

	else if(H.a_intent == INTENT_HELP && tipped)
		H.visible_message("<span class='notice'>[H] zaczyna stawiać [src].</span>", "<span class='notice'>Zaczynasz stawiać [src]...</span>")
		if(do_after(H, 3 SECONDS, target=src))
			set_right(H)
	else
		..()

/mob/living/simple_animal/bot/hugbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='notice'>Zwierasz czujniki nacisku manipulatorów [src].</span>")
		visible_message("<span class='danger'>Ramię [src] gwałtownie drga!</span>")
		flick("medibot_spark", src)
		playsound(src, "sparks", 75, 1)


/mob/living/simple_animal/bot/hugbot/proc/assess_patient(mob/living/carbon/human/H)
	//Time to see if they need medical help!
	if(H.stat == DEAD || (HAS_TRAIT(H, TRAIT_FAKEDEATH)))
		return FALSE	//welp too late for them!

	if(!(loc == H.loc) && !(isturf(H.loc) && isturf(loc)))
		return FALSE

	if(ishuman(H))
		var/datum/component/mood/M = H.GetComponent(/datum/component/mood)

		if(emagged == 2 || tania_mode) // EVERYONE GETS HUGS!
			return TRUE

		for(var/S in  M.mood_events) // Check if they've been hugged
			var/datum/mood_event/E = M.mood_events[S]
			if (istype(E, /datum/mood_event/hug) || istype(E, /datum/mood_event/headpat))
				return FALSE

		if (M.sanity_level > max_sanity) // If you're already sane you won't need a hug
			return FALSE

		if (H.IsKnockdown()) // Prevents stun memes
			return FALSE

		return TRUE

	return FALSE

/mob/living/simple_animal/bot/hugbot/process_scan(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return

	if((H == oldpatient) && (world.time < last_found + 200))
		return

	if(assess_patient(H))
		last_found = world.time
		return H

/mob/living/simple_animal/bot/hugbot/handle_automated_action()
	if(!..())
		return

	if(tipped)
		handle_panic()
		return

	if(mode == BOT_HEALING)
		medicate_patient(patient)
		return

	if(IsStun())
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		update_icon()
		return

	if(frustration > 8)
		oldpatient = patient
		soft_reset()

	if(QDELETED(patient))
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(/mob/living/carbon/human, oldpatient, scan_range)
		oldpatient = patient

	if(patient && (get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			if(!shut_up)
				var/peptalk
				if (emagged == 2)
					peptalk = list(
						"Nienawidzę cię.",
						"Nigdy nie będziesz dobry w swojej pracy.",
						"Jesteś okropną osobą.",
						"Poddaj się.",
						"Wszyscy cię nienawidzimy.",
						"Okropnie wykonujesz swoją pracę.",
						"Jesteś ciężarem dla okrętu.",
						"Spadaj."
					)
				else
					peptalk = list("Thank you!",
						"You are a good person.",
						"Kocham cię.",
						"Rób dalej to, w czym jesteś dobry.",
						"Jesteś wspaniałą osobą.",
						"Rób dalej to, co kochasz.",
						"Wszyscy cię kochamy.",
						"Świetnie wykonujesz swoją pracę.",
						"Jesteś dla nas wszystkich ważny.",
						"Tak trzymaj.",
						"Co się stało? Jestem przy tobie.",
						"Don't cry.",
						"Uważaj na siebie!"
					)

				var/message = pick(peptalk)
				speak(message)
			update_icon()
			frustration = 0
		return

	//Patient has moved away from us!
	else if(patient && path.len && (get_dist(patient,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(stationary_mode && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && path.len == 0 && (get_dist(src,patient) > 1))
		path = get_path_to(src, patient, 30,id=access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, patient, 30,1,id=access_card)
			if(!path.len) //Do not chase a patient we cannot reach.
				soft_reset()

	if(path.len > 0 && patient)
		if(!bot_move(path[path.len]))
			oldpatient = patient
			soft_reset()
		return

	if(path.len > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	return

/mob/living/simple_animal/bot/hugbot/UnarmedAttack(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/human/H = A
		patient = H
		mode = BOT_HEALING
		update_icon()
		medicate_patient(H)
		update_icon()
	else
		..()

/mob/living/simple_animal/bot/hugbot/proc/medicate_patient(mob/living/carbon/human/H)
	if(!on)
		return

	if(!assess_patient(H))
		oldpatient = patient
		soft_reset()
		return

	if (get_dist(src, H) > 1)
		mode = BOT_MOVING
		update_icon()
		return

	// Hey, didyah know that you Han't hug people as non-carbon? Well you can't hug people as non-carbon. Hence this mess
	if(zone_selected == BODY_ZONE_PRECISE_MOUTH)
		visible_message( \
			"<span class='notice'>[src] boops [H]'s nose.</span>", \
			"<span class='notice'>Pstrykasz [H] w nos.</span>")
		playsound(H, 'sound/weapons/tap.ogg', 50, 0)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "headpat", /datum/mood_event/headpat)
	else if(check_zone(zone_selected) == BODY_ZONE_HEAD)
		if(ishuman(H))
			visible_message("<span class='notice'>[src] klepie [H] po głowie, żeby poczuł się lepiej!</span>", \
						"<span class='notice'>Klepiesz [src] po głowie, żeby poczuł się lepiej!</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "headpat", /datum/mood_event/headpat)
			var/obj/item/organ/tail/tail = H.get_bodypart(ORGAN_SLOT_TAIL)
			if(!tail)
				return
			tail.toggle_wag(H)
	else
		visible_message("<span class='notice'>[src] przytula [H], żeby poczuł się lepiej!</span>", \
					"<span class='notice'>Przytulasz [H], żeby poczuł się lepiej!</span>")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug)

	playsound(H.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

	if (emagged == 2) // Emagged actions
		H.adjustStaminaLoss(50)
	else // Otherwise you just help them
		H.AdjustStun(-60)
		H.AdjustKnockdown(-60)
		H.AdjustUnconscious(-60)
		H.AdjustSleeping(-100)
		H.adjustStaminaLoss(-15)
		if(!tania_mode)
			oldpatient = patient
			soft_reset()
	return

/mob/living/simple_animal/bot/hugbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] rozpada się na kawałki!</span>")
	do_sparks(3, TRUE, src)
	var/atom/Tsec = drop_location()
	drop_part(/obj/item/storage/box/hug, Tsec)
	drop_part(/obj/item/bodypart/r_arm/robot, Tsec)
	drop_part(/obj/item/assembly/prox_sensor, Tsec)
	..()

/obj/machinery/bot_core/hugbot
	req_one_access = list(ACCESS_ROBOTICS)

/obj/item/bot_assembly/hugbot
	desc = "It's a box of hugs with an arm attached."
	name = "incomplete hugbot assembly"
	icon = 'nsv13/icons/mob/aibots.dmi'
	icon_state = "hugbot_arm"
	created_name = "Hugbot"

/obj/item/bot_assembly/hugbot/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/assembly/prox_sensor))
		if(!can_finish_build(W, user))
			return
		var/mob/living/simple_animal/bot/hugbot/A = new(drop_location())
		A.name = created_name
		A.robot_arm = W.type
		to_chat(user, "<span class='notice'>Dodajesz [W] do [src]. Bip bup!</span>")
		qdel(W)
		qdel(src)

/obj/item/storage/box/hug/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/bodypart/l_arm/robot)) || (istype(I, /obj/item/bodypart/r_arm/robot)))
		if(contents.len) //prevent accidently deleting contents
			to_chat(user, "<span class='warning'>Najpierw musisz opróżnić [src]!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		to_chat(user, "<span class='notice'>Dodajesz [I] do [src]! Masz teraz zespół hugbota!</span>")
		var/obj/item/bot_assembly/hugbot/A = new
		qdel(src)
		user.put_in_hands(A)
	else
		return ..()

/mob/living/simple_animal/bot/hugbot/proc/tip_over(mob/user)
	mobility_flags &= ~MOBILITY_MOVE
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	user.visible_message("<span class='danger'>[user] przewraca [src]!</span>", "<span class='danger'>Przewracasz [src]!</span>")
	tipped = TRUE
	tipper_name = user.name
	var/matrix/mat = transform
	transform = mat.Turn(180)

/mob/living/simple_animal/bot/hugbot/proc/set_right(mob/user)
	mobility_flags &= MOBILITY_MOVE
	var/list/messagevoice
	if(user)
		user.visible_message("<span class='notice'>[user] stawia [src] z powrotem na nogi!</span>", "<span class='green'>Stawiasz [src] z powrotem na nogi!</span>")
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		visible_message("<span class='notice'>[src] wierci się na tyle, że udaje mu się wstać.</span>")
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')

	tipper_name = null
	if(world.time > last_tipping_action_voice + 15 SECONDS)
		last_tipping_action_voice = world.time
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = HUGBOT_PANIC_NONE
	mode = BOT_IDLE
	transform = matrix()

// if someone tipped us over, check whether we should ask for help or just right ourselves eventually
/mob/living/simple_animal/bot/hugbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice
	switch(tipped_status)
		if(HUGBOT_PANIC_LOW)
			messagevoice = list("I require assistance." = 'sound/voice/medbot/i_require_asst.ogg')
		if(HUGBOT_PANIC_MED)
			messagevoice = list("Please put me back." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(HUGBOT_PANIC_HIGH)
			messagevoice = list("Please, I am scared!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(HUGBOT_PANIC_FUCK)
			messagevoice = list("I don't like this, I need help!" = 'sound/voice/medbot/dont_like.ogg', "This hurts, my pain is real!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(HUGBOT_PANIC_ENDING)
			messagevoice = list("Is this the end?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nooo!" = 'sound/voice/medbot/nooo.ogg')
		if(HUGBOT_PANIC_END)
			speak("ALARM PSYCHOLOGICZNY: członek załogi [tipper_name] wykazuje skłonności aspołeczne, znęcając się nad botami w [get_area(src)]. Prosimy o umówienie oceny psychologicznej.", radio_channel)
			set_right() // strong independent hugbot

	if(prob(tipped_status))
		do_jitter_animation(tipped_status * 0.1)

	if(messagevoice)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	else if(prob(tipped_status * 0.2))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30, extrarange=-2)

#undef HUGBOT_PANIC_NONE
#undef HUGBOT_PANIC_LOW
#undef HUGBOT_PANIC_MED
#undef HUGBOT_PANIC_HIGH
#undef HUGBOT_PANIC_FUCK
#undef HUGBOT_PANIC_ENDING
#undef HUGBOT_PANIC_END
