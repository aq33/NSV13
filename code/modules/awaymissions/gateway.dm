GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/centerstation)

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/active = 0
	var/checkparts = TRUE
	var/list/obj/effect/landmark/randomspawns = list()
	var/calibrated = TRUE
	var/list/linked = list()
	var/can_link = FALSE	//Is this the centerpiece?

/obj/machinery/gateway/Initialize(mapload)
	randomspawns = GLOB.awaydestinations
	update_icon()
	if(!istype(src, /obj/machinery/gateway/centerstation) && !istype(src, /obj/machinery/gateway/centeraway))
		switch(dir)
			if(SOUTH,SOUTHEAST,SOUTHWEST)
				density = FALSE
	return ..()

/obj/machinery/gateway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()

/obj/machinery/gateway/proc/detect()
	if(!can_link)
		return FALSE
	linked = list()	//clear the list
	var/turf/T = loc
	var/ready = FALSE

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if((linked.len == 8) || !checkparts)
		ready = TRUE
	return ready

/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"

/obj/machinery/gateway/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!detect())
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

/obj/machinery/gateway/proc/toggleon(mob/user)
	return FALSE

/obj/machinery/gateway/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG)
	return

/obj/machinery/gateway/centerstation/Initialize(mapload)
	. = ..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src
	update_icon()
	wait = world.time + CONFIG_GET(number/gateway_delay)	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/centeraway)

/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	use_power = IDLE_POWER_USE

	//warping vars
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null
	can_link = TRUE

/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centerstation/process()
	if((machine_stat & (NOPOWER)) && use_power)
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/centerstation/toggleon(mob/user)
	if(!detect())
		return
	if(!powered())
		return
	if(!awaygate)
		to_chat(user, "<span class='notice'>Błąd: nie znaleziono celu.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Błąd: trwa triangulacja przestrzeni warp. Szacowany czas do zakończenia: [DisplayTimeText(wait - world.time)].</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/AM)
	if(!active)
		return
	if(!detect())
		return
	if(!awaygate || QDELETED(awaygate))
		return

	if(awaygate.calibrated)
		AM.forceMove(get_step(awaygate.loc, SOUTH))
		AM.setDir(SOUTH)
		if (ismob(AM))
			var/mob/M = AM
			if (M.client)
				M.client.move_delay = max(world.time + 5, M.client.move_delay)
		return
	else
		var/obj/effect/landmark/dest = pick(randomspawns)
		if(dest)
			AM.forceMove(get_turf(dest))
			AM.setDir(SOUTH)
			use_power(5000)
		return

/obj/machinery/gateway/centeraway/multitool_act(mob/living/user, obj/item/I)
	if(calibrated)
		to_chat(user, "\black Brama jest już skalibrowana, nie masz tu nic do zrobienia.")
	else
		to_chat(user, "<span class='boldnotice'>Rekalibracja udana!</span>: \black Systemy tej bramy zostały precyzyjnie dostrojone. Podróże do tej bramy będą teraz trafiać w cel.")
		calibrated = TRUE
	return TRUE

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	use_power = NO_POWER_USE
	var/obj/machinery/gateway/centerstation/stationgate = null
	can_link = TRUE


/obj/machinery/gateway/centeraway/Initialize(mapload)
	. = ..()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centeraway/toggleon(mob/user)
	if(!detect())
		return
	if(!stationgate)
		to_chat(user, "<span class='notice'>Błąd: nie znaleziono celu.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/centeraway/proc/check_exile_implant(mob/living/L)
	for(var/obj/item/implant/exile/E in L.implants)//Checking that there is an exile implant
		to_chat(L, "\black Brama stacji wykryła twój implant wygnania i blokuje ci wejście.")
		return TRUE
	return FALSE

/obj/machinery/gateway/centeraway/Bumped(atom/movable/AM)
	if(!detect())
		return
	if(!active)
		return
	if(!stationgate || QDELETED(stationgate))
		return
	if(isliving(AM))
		if(check_exile_implant(AM))
			return
	else
		for(var/mob/living/L in AM.contents)
			if(check_exile_implant(L))
				say("Odrzucanie [AM]: wykryto implant wygnania w przewożonej formie życia.")
				return
	if(AM.has_buckled_mobs())
		for(var/mob/living/L in AM.buckled_mobs)
			if(check_exile_implant(L))
				say("Odrzucanie [AM]: wykryto implant wygnania w pobliskiej formie życia.")
				return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.setDir(SOUTH)
	if (ismob(AM))
		var/mob/M = AM
		if (M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)


/obj/machinery/gateway/centeraway/admin
	desc = "A mysterious gateway built by unknown hands, this one seems more compact."

/obj/machinery/gateway/centeraway/admin/Initialize(mapload)
	. = ..()
	if(stationgate && !stationgate.awaygate)
		stationgate.awaygate = src

/obj/machinery/gateway/centeraway/admin/detect()
	return TRUE


/obj/item/paper/fluff/gateway
	default_raw_text = "Gratulacje,<br><br>Wasza stacja została wybrana do realizacji Projektu Brama.<br><br>Sprzęt zostanie do was wysłany na początku następnego kwartału.<br> Macie przygotować bezpieczne miejsce na sprzęt, zgodnie z załączonymi dokumentami.<br><br>--Badania Bluespace Nanotrasen"
	name = "Confidential Correspondence, Pg 1"

/obj/item/paper/fluff/itemnotice
	default_raw_text = "Uwaga: w ostatnich tygodniach coraz częściej zgłaszano znajdowanie w produktach Kapsuł Bluespace zbędnych śmieci, takich jak opakowania. Jeśli w tym obozie znajdują się takie przedmioty, wyrzućcie je do kosza lub dostarczonego ogniska, zwłaszcza jeśli są to rzeczy frywolne, szczerze mówiąc żenujące. Przepraszamy za niedogodności. Dziękujemy. -- Nanotrasen BS Productions"
	name = "Surplus Item Removal Notice"

/obj/item/paper/fluff/encampmentwelcome
	default_raw_text = "Witaj! Jeśli to czytasz, kupiłeś i rozłożyłeś nową linię schronień z kapsuł bluespace – obóz górniczy! Ta kapsuła zapewnia standardowe wyposażenie schronienia i więcej, w tym rozszerzony automat z jedzeniem, sejf w podłodze, toaletę, schowek na skafandry, zapasowy sprzęt i osobisty automat z zamówieniami! Na zewnątrz wyłożyliśmy nawet płytki z bazaltu, by żadne kamienie nie przeszkadzały na przytulnym dziedzińcu! Mamy nadzieję, że będziesz bezpieczny i docenisz udogodnienia! - Nanotrasen BS Productions"
	name = "Welcome!"

/obj/item/paper/fluff/shuttlenotice
	default_raw_text = "Do pełniącego obowiązki kapitana Stacji Badawczej Nanotrasen SS13. Ze względu na charakter waszej sytuacji awaryjnej musieliśmy niestety przyspieszyć budowę tego promu, przez co nie spełnia on standardowych przepisów sanitarnych. Dziękujemy za zakup i przepraszamy za niedogodności. Dziękujemy i bezpiecznego lotu! -- Zespół Inżynieryjny Nanotrasen BS Productions"
	name = "Shuttle Notice"
