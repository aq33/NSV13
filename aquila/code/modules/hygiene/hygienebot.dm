// AQUILA - Hygienebot, ported from tgstation (#49613, constructible since #55089) and hooked into NSV13's hygiene.
// It hunts down people who stink or wear bloody clothes and hoses them down until they are clean.

/mob/living/simple_animal/bot/hygienebot
	name = "\improper Hygienebot"
	desc = "Latający robot sprzątający. Ściga każdego, kto nie umie porządnie się umyć!"
	icon = 'aquila/icons/mob/hygienebot.dmi'
	icon_state = "hygienebot"
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = HYGIENE_BOT
	model = "Hygienebot"
	bot_core_type = /obj/machinery/bot_core/hygienebot
	window_id = "autoclean"
	window_name = "Automatic Crew Cleaner X2"
	pass_flags = PASSMOB
	path_image_color = "#993299"
	allow_pai = FALSE
	layer = ABOVE_MOB_LAYER

	/// The human the bot is trying to wash
	var/mob/living/carbon/human/target
	/// Movement delay, drops the longer the target runs away
	var/currentspeed = 5
	/// Is the bot spraying water (or fire) on its own tile?
	var/washing = FALSE
	/// Has the target been running away long enough to make the bot swear?
	var/mad = FALSE
	/// When the previous or current target was last found
	var/last_found
	/// Name of the previous target, so the bot doesn't pick them again straight away
	var/oldtarget_name

/mob/living/simple_animal/bot/hygienebot/Initialize(mapload)
	. = ..()
	update_icon()
	var/datum/job/janitor/J = new /datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/hygienebot/Destroy()
	target = null
	return ..()

/mob/living/simple_animal/bot/hygienebot/set_custom_texts()
	text_hack = "You corrupt [name]'s water pump."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/hygienebot/explode()
	walk_to(src, 0)
	visible_message("<span class='boldannounce'>[src] rozpada się w pianowym wybuchu!</span>")
	do_sparks(3, TRUE, src)
	on = FALSE
	new /obj/effect/particle_effect/foam(loc)
	..()

/mob/living/simple_animal/bot/hygienebot/update_icon_state()
	. = ..() // Sets "hygienebot[on]", which this sprite sheet doesn't have
	icon_state = on ? "hygienebot-on" : "hygienebot"

/mob/living/simple_animal/bot/hygienebot/update_overlays()
	. = ..()
	if(on)
		. += mutable_appearance(icon, "hygienebot-flame")
	if(washing)
		. += mutable_appearance(icon, emagged == 2 ? "hygienebot-fire" : "hygienebot-water")

/mob/living/simple_animal/bot/hygienebot/turn_off()
	..()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/hygienebot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	walk_to(src, 0)
	last_found = world.time
	stop_washing()

/mob/living/simple_animal/bot/hygienebot/handle_automated_action()
	if(!..())
		return

	if(washing)
		do_wash(loc)
		for(var/atom/movable/AM in loc)
			if(AM != src)
				do_wash(AM)
		if(isopenturf(loc) && emagged != 2)
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

	switch(mode)
		if(BOT_IDLE)
			walk_to(src, 0)
			look_for_lowhygiene()
			if(!mode && auto_patrol)
				mode = BOT_START_PATROL

		if(BOT_HUNT)
			if(emagged == 2)
				currentspeed = 3.5
				start_washing()
				mad = TRUE
			else
				switch(frustration)
					if(0 to 4)
						currentspeed = 5
						mad = FALSE
					if(5 to INFINITY)
						currentspeed = 2.5
						mad = TRUE
			if(QDELETED(target) || is_clean(target))
				back_to_idle()
				return
			if(target.loc == loc && isturf(target.loc))
				start_washing()
				if(mad)
					speak(pick("No, kurwa, nareszcie.", "Wreszcie, dzięki Bogu.", "Nareszcie się zatrzymałeś, brudasie."))
					playsound(loc, 'aquila/sound/effects/hygienebot_angry.ogg', 60, TRUE)
					mad = FALSE
				mode = BOT_CLEANING
				return
			stop_washing()
			var/olddist = get_dist(src, target)
			if(olddist > 20 || frustration > 100) // Give up and look for someone else
				back_to_idle()
				return
			walk_to(src, target, 0, currentspeed)
			if(mad && prob(min(frustration * 2, 60)))
				playsound(loc, 'aquila/sound/effects/hygienebot_angry.ogg', 60, TRUE)
				speak(pick("Wracaj tu, ty śmierdzący gnoju!", "STÓJ ALBO PRZETNĘ CI TĘTNICE!", "Daj się, kurwa, umyć, dupku!", "STÓJ. NIE. UCIEKAJ.", "Albo się zatrzymasz, albo wywlekę cię przez śluzę.", "Chcę cię tylko, kurwa, umyć, troglodyto.", "Jak nie wrócisz, to otoczę cię zieloną chmurą."))
			if(get_dist(src, target) >= olddist)
				frustration++
			else
				frustration = 0

		if(BOT_CLEANING) // Hosing the target down
			if(QDELETED(target))
				back_to_idle()
				return
			if(is_clean(target))
				speak("Miłego, czystego dnia!")
				playsound(loc, 'aquila/sound/effects/hygienebot_happy.ogg', 60, TRUE)
				back_to_idle()
				return
			if(target.loc != loc || !isturf(target.loc))
				back_to_hunt()

		if(BOT_START_PATROL)
			look_for_lowhygiene()
			if(mode == BOT_START_PATROL)
				start_patrol()

		if(BOT_PATROL)
			look_for_lowhygiene()
			if(mode == BOT_PATROL)
				bot_patrol()

/mob/living/simple_animal/bot/hygienebot/proc/back_to_idle()
	mode = BOT_IDLE
	walk_to(src, 0)
	target = null
	frustration = 0
	last_found = world.time
	stop_washing()

/mob/living/simple_animal/bot/hygienebot/proc/back_to_hunt()
	frustration = 0
	mode = BOT_HUNT
	stop_washing()

/mob/living/simple_animal/bot/hygienebot/proc/look_for_lowhygiene()
	for(var/mob/living/carbon/human/H in view(7, src))
		if(H.name == oldtarget_name && world.time < last_found + 10 SECONDS)
			continue
		if(!needs_washing(H))
			continue
		target = H
		oldtarget_name = H.name
		speak("Wykryto niehigienicznego klienta. Proszę stać spokojnie, zaraz cię umyję.")
		playsound(loc, 'aquila/sound/effects/hygienebot_happy.ogg', 60, TRUE)
		visible_message("<b>[src]</b> wskazuje na [H.name]!")
		mode = BOT_HUNT
		return

/mob/living/simple_animal/bot/hygienebot/proc/start_washing()
	if(washing)
		return
	washing = TRUE
	update_icon()

/mob/living/simple_animal/bot/hygienebot/proc/stop_washing()
	if(!washing)
		return
	washing = FALSE
	update_icon()

/// Whether the bot should go after this person
/mob/living/simple_animal/bot/hygienebot/proc/needs_washing(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return FALSE
	if(emagged == 2)
		return TRUE
	if(H.hygiene <= HYGIENE_LEVEL_DIRTY && !HAS_TRAIT(H, TRAIT_ALWAYS_CLEAN))
		return TRUE
	return has_bloody_clothes(H)

/// Whether the bot is done with this person. Stricter than needs_washing(), so a target is washed back up to normal
/mob/living/simple_animal/bot/hygienebot/proc/is_clean(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return TRUE
	if(emagged == 2)
		return FALSE
	if(H.hygiene < HYGIENE_LEVEL_NORMAL && !HAS_TRAIT(H, TRAIT_ALWAYS_CLEAN))
		return FALSE
	return !has_bloody_clothes(H)

/mob/living/simple_animal/bot/hygienebot/proc/has_bloody_clothes(mob/living/carbon/human/H)
	for(var/slot in list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_FEET))
		var/obj/item/I = H.get_item_by_slot(slot)
		if(I && HAS_BLOOD_DNA(I))
			return TRUE
	return FALSE

/mob/living/simple_animal/bot/hygienebot/proc/do_wash(atom/A)
	if(emagged == 2)
		A.fire_act()
		return
	SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	A.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	if(isturf(A))
		for(var/obj/effect/E in A)
			if(is_cleanable(E))
				qdel(E)
		return
	if(!iscarbon(A))
		return
	var/mob/living/carbon/C = A
	C.wash_cream()
	var/cleaned_items = FALSE
	for(var/obj/item/I in C.get_equipped_items(TRUE) + C.held_items)
		if(SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
			cleaned_items = TRUE
	if(cleaned_items)
		C.regenerate_icons()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.adjust_hygiene(HYGIENEBOT_WASH_AMOUNT)

/mob/living/simple_animal/bot/hygienebot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Hygienebot X2 controls</B></TT><BR><BR>
Status: <A href='byond://?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [open ? "opened" : "closed"]"})
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "<BR>Auto Patrol: <A href='byond://?src=[REF(src)];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>"
	return dat

/obj/machinery/bot_core/hygienebot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

// Construction: 2 metal sheets -> weld a water hole -> proximity sensor -> 1 fluid duct
/obj/item/bot_assembly/hygienebot
	name = "incomplete hygienebot assembly"
	desc = "Koniec z bagnem raz na zawsze."
	icon = 'aquila/icons/mob/hygienebot.dmi'
	icon_state = "hygienebot"
	created_name = "Hygienebot"

/obj/item/bot_assembly/hygienebot/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/atom/Tsec = drop_location()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(I.tool_behaviour == TOOL_WELDER)
				if(I.use_tool(src, user, 0, volume = 40))
					to_chat(user, "<span class='notice'>Wypalasz otwór na wodę w [src]!</span>")
					build_step++
				return
			if(I.tool_behaviour == TOOL_WRENCH)
				if(I.use_tool(src, user, 0, volume = 40))
					new /obj/item/stack/sheet/iron(Tsec, 2)
					to_chat(user, "<span class='notice'>Rozkręcasz [src].</span>")
					qdel(src)
				return

		if(ASSEMBLY_SECOND_STEP)
			if(isprox(I))
				if(!user.temporarilyRemoveItemFromInventory(I))
					return
				build_step++
				to_chat(user, "<span class='notice'>Dodajesz [I] do [src].</span>")
				qdel(I)
				return
			if(I.tool_behaviour == TOOL_WELDER)
				if(I.use_tool(src, user, 0, volume = 30))
					to_chat(user, "<span class='notice'>Zaspawujesz otwór na wodę w [src].</span>")
					build_step--
				return

		if(ASSEMBLY_THIRD_STEP)
			if(istype(I, /obj/item/stack/ducts))
				if(istype(loc, /obj/item/storage/backpack))
					to_chat(user, "<span class='warning'>Najpierw wyjmij [src] z [loc]!</span>")
					return
				var/obj/item/stack/ducts/D = I
				to_chat(user, "<span class='notice'>Zaczynasz podłączać rurę do [src]...</span>")
				if(do_after(user, 4 SECONDS, target = src) && D.use(1))
					to_chat(user, "<span class='notice'>Podłączasz rurę do [src].</span>")
					var/mob/living/simple_animal/bot/hygienebot/H = new(drop_location())
					H.name = created_name
					qdel(src)
				return
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				new /obj/item/assembly/prox_sensor(Tsec)
				to_chat(user, "<span class='notice'>Odłączasz czujnik zbliżeniowy od [src].</span>")
				build_step--
				return
