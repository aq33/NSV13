#define DISCONNECTED 0
#define CLAMPED_OFF 1
#define OPERATING 2

// Powersink - used to drain station power

/obj/item/powersink
	name = "power sink"
	desc = "A nulling power sink which drains energy from electrical systems."
	icon = 'icons/obj/device.dmi'
	icon_state = "powersink0"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	materials = list(/datum/material/iron=750)
	var/drain_rate = 2000000	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 6e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating
	var/admins_warned = FALSE // stop spam, only warn the admins once that we are about to boom

	var/obj/structure/cable/attached		// the attached cable
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/powersink/update_icon()
	icon_state = "powersink[mode == OPERATING]"

/obj/item/powersink/proc/set_mode(value)
	if(value == mode)
		return
	switch(value)
		if(DISCONNECTED)
			attached = null
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = FALSE
			density = FALSE

		if(CLAMPED_OFF)
			if(!attached)
				return
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = TRUE
			density = TRUE

		if(OPERATING)
			if(!attached)
				return
			START_PROCESSING(SSobj, src)
			anchored = TRUE
			density = TRUE

	mode = value
	update_icon()
	set_light(0)

/obj/item/powersink/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		if(mode == DISCONNECTED)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					to_chat(user, "<span class='warning'>[src] musi zostać umieszczony nad odsłoniętym, zasilanym węzłem kabla!</span>")
				else
					set_mode(CLAMPED_OFF)
					user.visible_message( \
						"[user] podłącza [src] do kabla.", \
						"<span class='notice'>Przykręcasz [src] do podłogi i podłączasz go do kabla.</span>",
						"<span class='italics'>Słyszysz, jak jakieś przewody zostają do czegoś podłączone.</span>")
			else
				to_chat(user, "<span class='warning'>[src] musi zostać umieszczony nad odsłoniętym, zasilanym węzłem kabla!</span>")
		else
			set_mode(DISCONNECTED)
			user.visible_message( \
				"[user] odłącza [src] od kabla.", \
				"<span class='notice'>Odkręcasz [src] od podłogi i odłączasz go od kabla.</span>",
				"<span class='italics'>Słyszysz, jak jakieś przewody zostają od czegoś odłączone.</span>")

	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		user.visible_message( \
			"[user] przez chwilę grzebie przy [src].", \
			"<span class='notice'>Śrubokręt nie pasuje do śrub [src]! Spróbuj klucza.</span>")
	else
		return ..()

/obj/item/powersink/attack_paw()
	return

/obj/item/powersink/attack_ai()
	return

/obj/item/powersink/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	switch(mode)
		if(DISCONNECTED)
			..()

		if(CLAMPED_OFF)
			user.visible_message( \
				"[user] aktywuje [src]!", \
				"<span class='notice'>Włączasz [src].</span>",
				"<span class='italics'>Słyszysz kliknięcie.</span>")
			message_admins("Power sink activated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(src)]")
			log_game("Power sink activated by [key_name(user)] at [AREACOORD(src)]")
			set_mode(OPERATING)

		if(OPERATING)
			user.visible_message( \
				"[user] dezaktywuje [src]!", \
				"<span class='notice'>Wyłączasz [src].</span>",
				"<span class='italics'>Słyszysz kliknięcie.</span>")
			set_mode(CLAMPED_OFF)

/obj/item/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)
		return

	var/datum/powernet/PN = attached.powernet
	if(PN)
		set_light(5)

		// found a powernet, so drain up to max power from it

		var/drained = min ( drain_rate, attached.newavail() )
		attached.add_delayedload(drained)
		power_drained += drained
		on_drain(drained) // AQ EDIT - APC cell draining (and infiltrator objective tracking) lives in aquila/code/game/objects/items/devices/powersink.dm

	if(power_drained > max_power * 0.98)
		if (!admins_warned)
			admins_warned = TRUE
			message_admins("Power sink at ([x],[y],[z] - <A HREF='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is 95% full. Explosion imminent.")
		playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)

	if(power_drained >= max_power)
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc, 4,8,16,32)
		qdel(src)

#undef DISCONNECTED
#undef CLAMPED_OFF
#undef OPERATING
