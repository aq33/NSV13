/obj/item/energy_harvester
	desc = "A Device which upon connection to a node, will harvest the energy and send it to engineerless stations in return for credits, derived from a syndicate powersink model."
	name = "Energy Harvesting Module"
	icon_state = "powersink0"
	icon = 'icons/obj/device.dmi'
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class= WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	throwforce = 1
	throw_speed = 1
	throw_range = 1
	materials = list(MAT_METAL=750)
	var/drain_rate = 100000000
	var/power_drained = 0

	var/obj/structure/cable/attached


/obj/item/energy_harvester/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!anchored)
			var/turf/T = loc
			if(isturf(T) && !T.intact)
				attached = locate() in T
				if(!attached)
					to_chat(user, "<span class='warning'>To urządzenie musi zostać umieszczone nad odsłoniętym, zasilanym węzłem kabla!</span>")
				else
					START_PROCESSING(SSobj, src)
					anchored = 1
					density = 1
					user.visible_message( \
						"[user] podłącza [src] do kabla.", \
						"<span class='notice'>Podłączasz [src] do kabla.</span>",
						"<span class='italics'>Słyszysz, jak jakieś przewody zostają do czegoś podłączone.</span>")
			else
				to_chat(user, "<span class='warning'>To urządzenie musi zostać umieszczone nad odsłoniętym, zasilanym węzłem kabla!</span>")
		else
			STOP_PROCESSING(SSobj, src)
			anchored = 0
			density = 0
			user.visible_message( \
				"[user] odłącza [src] od kabla.", \
				"<span class='notice'>Odłączasz [src] od kabla.</span>",
				"<span class='italics'>Słyszysz, jak jakieś przewody zostają od czegoś odłączone.</span>")

/obj/item/energy_harvester/process()
	if(!attached || !anchored)
		return PROCESS_KILL

	var/datum/powernet/PN = attached.powernet
	if(PN)
		set_light(5)
		var/power_avaliable =  PN.netexcess
		if(power_avaliable <= 0)
			return
		power_avaliable = min(power_avaliable, drain_rate)
		attached.add_delayedload(power_avaliable)
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_ENG)
		if(D)
			D.adjust_money(power_avaliable * 0.000005)
