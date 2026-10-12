/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("rzuca")
	var/dumped = FALSE

/obj/item/suspiciousphone/attack_self(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>To urządzenie jest dla ciebie zbyt zaawansowane!</span>")
		return
	if(dumped)
		to_chat(user, "<span class='warning'>Protokół CRAB-17 jest już aktywny.</span>")
		return FALSE
	if(alert(user, "Na pewno chcesz zrujnować ten rynek bez ocalałych?", "Protokół CRAB-17", "Yes", "No") == "Yes")
		if(dumped || QDELETED(src)) //Prevents fuckers from cheesing alert
			return FALSE
		var/turf/targetturf = get_safe_random_station_turfs()
		if (!targetturf)
			return FALSE
		new /obj/effect/dumpeetTarget(targetturf, user)
		dumped = TRUE

/obj/structure/checkoutmachine
	name = "\improper Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80, "stamina" = 0, "bleed" = 0)
	density = TRUE
	pixel_z = -8
	layer = LARGE_MOB_LAYER
	max_integrity = 600
	var/list/accounts_to_rob
	var/mob/living/carbon/human/bogdanoff
	var/canwalk = FALSE

/obj/structure/checkoutmachine/examine(mob/living/user)
	. = ..()
	. += "<span class='info'>Wbudowany miernik integralności pokazuje: <b>STAN: [obj_integrity]</b>.</span>"

/obj/structure/checkoutmachine/proc/check_if_finished()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if (B.being_dumped)
			return FALSE
	return TRUE

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(check_if_finished())
		qdel(src)
		return
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			to_chat(user, "<span class='warning'>Ta karta nie ma zarejestrowanego konta!</span>")
			return
		if(!card.registered_account.being_dumped)
			to_chat(user, "<span class='warning'>Wygląda na to, że twoje środki są bezpieczne!</span>")
			return
		if(do_after(user, 40, target = src))
			if(!card.registered_account.being_dumped)
				return
			to_chat(user, "<span class='warning'>Szybko przelewasz swoje środki do bezpieczniejszego banku. Środki są bezpieczne.</span>") // This is a reference and not a typo
			card.registered_account.being_dumped = FALSE
			card.registered_account.withdrawDelay = 0
			if(check_if_finished())
				qdel(src)
				return
	else
		return ..()

/obj/structure/checkoutmachine/Initialize(mapload, mob/living/user)
	. = ..()
	bogdanoff = user
	add_overlay("flaps")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, PROC_REF(startUp)), 50)
	QDEL_IN(WEAKREF(src), 8 MINUTES) //Self destruct after 8 min


/obj/structure/checkoutmachine/proc/startUp() //very VERY snowflake code that adds a neat animation when the pod lands.
	start_dumping() //The machine doesnt move during this time, giving people close by a small window to grab their funds before it starts running around
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("flaps")
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("hatch")
	sleep(30)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	add_overlay("legs_extending")
	cut_overlay("legs_retracted")
	pixel_z += 4
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("legs_extended")
	cut_overlay("legs_extending")
	pixel_z += 4
	sleep(20)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	cut_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	add_overlay("screen")
	sleep(5)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	add_overlay("text")
	sleep(10)
	if(QDELETED(src))
		return
	add_overlay("legs")
	cut_overlay("legs_extended")
	cut_overlay("screen")
	add_overlay("screen")
	cut_overlay("screen_lines")
	add_overlay("screen_lines")
	cut_overlay("text")
	add_overlay("text")
	canwalk = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/structure/checkoutmachine/Destroy()
	stop_dumping()
	STOP_PROCESSING(SSfastprocess, src)
	priority_announce("Wpłatomat kredytów w [get_area(src)] został zniszczony. Środki stacji przestały wyciekać!", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = "CRAB-17 Protocol", )
	explosion(src, 0,0,1, flame_range = 2)
	return ..()

/obj/structure/checkoutmachine/proc/start_dumping()
	accounts_to_rob = SSeconomy.bank_accounts.Copy()
	accounts_to_rob -= bogdanoff.get_bank_account()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.dumpeet()
	dump()

/obj/structure/checkoutmachine/proc/dump()
	var/percentage_lost = (rand(1, 10) / 100)
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		if(!B.being_dumped)
			continue
		var/amount = B.account_balance * percentage_lost
		var/datum/bank_account/account = bogdanoff.get_bank_account()
		if (account) // get_bank_account() may return FALSE
			account.transfer_money(B, amount)
			B.bank_card_talk("Tracisz [percentage_lost * 100]% swoich środków! Wpłatomat spacecoinów znajduje się w: [get_area(src)].")
	addtimer(CALLBACK(src, PROC_REF(dump)), 150) //Drain every 15 seconds

/obj/structure/checkoutmachine/process()
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

/obj/structure/checkoutmachine/proc/stop_dumping()
	for(var/i in accounts_to_rob)
		var/datum/bank_account/B = i
		B.being_dumped = FALSE

/obj/effect/dumpeetFall //Falling pod
	name = ""
	icon = 'icons/obj/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasn't flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeetTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeetFall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/carbon/human/bogdanoff

/obj/effect/ex_act()
	return

/obj/effect/dumpeetTarget/Initialize(mapload, user)
	. = ..()
	bogdanoff = user
	addtimer(CALLBACK(src, PROC_REF(startLaunch)), 100)
	sound_to_playing_players('sound/items/dump_it.ogg', 20)
	deadchat_broadcast("<span class='deadsay'>Aktywowano Protokół CRAB-17. Na stacji uruchomiono rynek spacecoinów!</span>", turf_target = get_turf(src))

/obj/effect/dumpeetTarget/proc/startLaunch()
	DF = new /obj/effect/dumpeetFall(drop_location())
	dump = new /obj/structure/checkoutmachine(null, bogdanoff)
	priority_announce("Bańka spacecoinów pękła! Dotrzyj do wpłatomatu w [get_area(src)] i wypłać środki, zanim stracisz wszystko!", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = "CRAB-17 Protocol")
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 70, 1, 6)
	addtimer(CALLBACK(src, PROC_REF(endLaunch)), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation



/obj/effect/dumpeetTarget/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, 1)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now
