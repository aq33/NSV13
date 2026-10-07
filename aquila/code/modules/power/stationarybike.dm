// AQUILA - Port Yogstation #9163 (Adds treadmill engine) z nazwą z Yogstation #11142. Rower stacjonarny, który generuje prąd, gdy ktoś jest do niego przypięty.

/obj/machinery/power/stationarybike
	name = "rower stacjonarny"
	desc = "Piętnaście Milionów Zasług."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "bicycle"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	can_buckle = TRUE
	buckle_lying = 0

	var/operating = 0 // On or off, also tracks what type of power being generated
	var/generating = 0 // Actual power being generated for the examine text
	var/power_exponent = 1000
	var/simple_power = 15 // Monkeys and other simple animals
	var/no_mind_power = 25 // Braindeads and Catatonics
	var/slave_power = 50 // Living, non-braindead, non-catatonic
	var/lifeweb = FALSE // Emagged or not

/obj/machinery/power/stationarybike/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/stationarybike/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Generuje [generating] kW mocy.</span>"

/obj/machinery/power/stationarybike/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	lifeweb = TRUE
	to_chat(user, "<span class='warning'>Wyłączasz zabezpieczenia.</span>")

/obj/machinery/power/stationarybike/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			connect_to_network()
			to_chat(user, "<span class='notice'>Przykręcasz rower do podłogi.</span>")
			anchored = TRUE
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(operating)
			to_chat(user, "<span class='warning'>Nie możesz odkręcić roweru od podłogi, kiedy się kręci!</span>")
			return TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			disconnect_from_network()
			to_chat(user, "<span class='notice'>Odkręcasz rower od podłogi.</span>")
			anchored = FALSE
			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	return TRUE

/obj/machinery/power/stationarybike/crowbar_act(mob/living/user, obj/item/I)
	for(var/mob/living/BM in buckled_mobs)
		if(lifeweb)
			to_chat(user, "<span class='notice'>Z całej siły szarpiesz hamulec awaryjny.</span>")
			unbuckle_mob(BM)
			check_buckled()
	return TRUE

/obj/machinery/power/stationarybike/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/power/stationarybike/attack_hand(mob/user)
	if(lifeweb)
		to_chat(user, "<span class='danger'>Kręci się za szybko! Możesz zrobić sobie krzywdę, jeśli spróbujesz kogoś z niego zdjąć!</span>")
		return
	. = ..()

/obj/machinery/power/stationarybike/process()
	if(!operating)
		return
	if(lifeweb)
		check_buckled()
		life_drain()
		add_avail((operating * power_exponent) * 1.5)
		generating = (operating * 1.5)
		return
	check_buckled()
	add_avail(operating * power_exponent)
	generating = (operating)

//BUCKLE HOOKS

/obj/machinery/power/stationarybike/post_unbuckle_mob(mob/living/M)
	. = ..()
	operating = 0
	generating = 0

/obj/machinery/power/stationarybike/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!iscarbon(user) || user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density && (A != src && A != M))
			return
	M.forceMove(get_turf(src))
	. = ..()
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	check_buckled()

/obj/machinery/power/stationarybike/proc/check_buckled()
	if(!has_buckled_mobs())
		operating = 0
		return
	for(var/mob/living/BM in buckled_mobs)
		if(BM.stat == DEAD)
			operating = 0
			return
		else if(ismonkey(BM) || isanimal(BM))
			operating = simple_power
		else if(ishuman(BM))
			if(!BM.mind)
				operating = no_mind_power
				return
			operating = slave_power

/obj/machinery/power/stationarybike/proc/life_drain()
	for(var/mob/living/BM in buckled_mobs)
		BM.adjustBruteLoss(5)
		BM.Paralyze(30)
