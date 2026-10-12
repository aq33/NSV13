//missile construction//

/obj/item/ship_weapon/ammunition/missile/missile_casing
	name = "prebuilt missile-casing"
	icon_state = "missile_case"
	desc = "The outer casing of a 30mm missile."
	density = TRUE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	claimable_gulag_points = 0
	volatility = 0
	var/state = 0
	var/obj/item/ship_weapon/parts/missile/warhead/wh = null
	var/obj/item/ship_weapon/parts/missile/guidance_system/gs = null
	var/obj/item/ship_weapon/parts/missile/propulsion_system/ps = null
	var/obj/item/ship_weapon/parts/missile/iff_card/iff = null
	projectile_type = /obj/item/projectile/guided_munition/missile/dud //Forget to finish your missile? You get a dud missile that doesn't do anything

/obj/item/ship_weapon/ammunition/missile/missile_casing/examine(mob/user) //No better guide than an in-game play-by-play guide
	. = ..()
	switch(state)
		if(0)
			. += "<span class='notice'>Obudowa jest pusta, czeka na instalację układu napędowego.</span>"
		if(1)
			. += "<span class='notice'>Układ napędowy leży luźno w obudowie. Są śruby, by go zamocować.</span>"
		if(2)
			. += "<span class='notice'>Układ napędowy jest zamocowany w tylnej połowie obudowy, teraz kolej na układ naprowadzania.</span>"
		if(3)
			. += "<span class='notice'>Układ naprowadzania leży luźno w obudowie obok układu napędowego. Są miejsca na wkręty, by przymocować go do obudowy. </span>"
		if(4)
			. += "<span class='notice'>Układy napędowy i naprowadzania są zamocowane w obudowie. Układ naprowadzania ma obecnie puste gniazdo na kartę IFF.</span>"
		if(5)
			. += "<span class='notice'>Karta IFF leży luźno w gnieździe układu naprowadzania. W każdym rogu gniazda są otwory na wkręty.</span>"
		if(6)
			. += "<span class='notice'>Układ napędowy, układ naprowadzania i karta IFF są zamocowane. Na przednim końcu jest miejsce na głowicę bojową.</span>"
		if(7)
			. += "<span class='notice'>Głowica bojowa ciasno siedzi na przednim końcu obudowy. Śruby mogłyby być mocniej dokręcone.</span>"
		if(8)
			. += "<span class='notice'>Obudowa zawiera głowicę, chip IFF, układy naprowadzania i napędowy. Nie są jeszcze połączone przewodami.</span>"
		if(9)
			. += "<span class='notice'>W obudowie zainstalowano następujące komponenty: [wh?.name], [iff?.name], [gs?.name], [ps?.name]. Wygląda na gotową do zamknięcia i skręcenia. </span>"
		if(10)
			. += "<span class='notice'>Obudowa została zamknięta i skręcona. Wymaga już tylko zaspawania, by była gotowa do akcji.</span>"

/obj/item/ship_weapon/ammunition/missile/missile_casing/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/ship_weapon/parts/missile/warhead))
		var/obj/item/ship_weapon/parts/missile/warhead/WW = W
		if(WW.fits_type && !istype(src, WW.fits_type))
			to_chat(user, "<span class='notice'>Ta głowica nie pasuje do [src].</span>")
			return FALSE
		if(state == 6)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
			wh = W
			state = 7
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/guidance_system))
		if(state == 2)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
			gs = W
			state = 3
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/propulsion_system))
		if(state == 0)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
			ps = W
			state = 1
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/ship_weapon/parts/missile/iff_card))
		if(state == 4)
			to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
			iff = W
			state = 5
			update_icon()
			W.forceMove(src)
		return TRUE
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(state == 8)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>Do okablowania [src] potrzebujesz przynajmniej trzech kawałków kabla!</span>") //for 'realistic' wire spaghetti
				return
			to_chat(user, "<span class='notice'>Zaczynasz okablowywać [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.use(3)
			to_chat(user, "<span class='notice'>Okablowujesz [src].</span>")
			state = 9
			update_icon()
		return TRUE

/obj/item/ship_weapon/ammunition/missile/missile_casing/wrench_act(mob/user, obj/item/tool)
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>Zaczynasz mocować [ps.name] w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Mocujesz [ps.name] w [src]. </span>")
				state = 2
				update_icon()
			return TRUE
		if(2)
			to_chat(user, "<span class='notice'>Zaczynasz odczepiać [ps.name] od [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odczepiasz [ps.name] od [src]. </span>")
				state = 1
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>Zaczynasz mocować [wh.name] w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Mocujesz [wh.name] w [src]. </span>")
				state = 8
				update_icon()
			return TRUE
		if(8)
			to_chat(user, "<span class='notice'>Zaczynasz odczepiać [wh.name] od [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odczepiasz [wh.name] od [src]. </span>")
				state = 7
				update_icon()
			return TRUE
		if(9)
			to_chat(user, "<span class='notice'>Zaczynasz zamykać obudowę i zabezpieczać [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Zamykasz obudowę i zabezpieczasz [src]. </span>")
				state = 10
				update_icon()
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>Zaczynasz odbezpieczać [src] i otwierać obudowę...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odbezpieczasz [src] i otwierasz obudowę. </span>")
				state = 9
				update_icon()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/screwdriver_act(mob/user, obj/item/tool)
	switch(state)
		if(3)
			to_chat(user, "<span class='notice'>Zaczynasz mocować [gs.name] w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Mocujesz [gs.name] w [src]. </span>")
				state = 4
				projectile_type = /obj/item/projectile/guided_munition/missile/dud/homing
				update_icon()
			return TRUE
		if(4)
			to_chat(user, "<span class='notice'>Zaczynasz odczepiać [gs.name]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odczepiasz [gs.name]. </span>")
				state = 3
				update_icon()
				projectile_type = /obj/item/projectile/guided_munition/missile/dud
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>Zaczynasz mocować [iff.name] w [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Mocujesz [iff.name] w [src]. </span>")
				state = 6
				update_icon()
			return TRUE
		if(6)
			to_chat(user, "<span class='notice'>Zaczynasz odczepiać [iff.name]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Odczepiasz [iff.name]. </span>")
				state = 5
				update_icon()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/wirecutter_act(mob/user, obj/item/tool)
	if(state == 9)
		to_chat(user, "<span class='notice'>Zaczynasz przecinać okablowanie w [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Przecinasz okablowanie w [src].</span>")
			var/obj/item/stack/cable_coil/C = new (loc, 3)
			C.add_fingerprint(user)
			state = 8
			update_icon()
		return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/proc/check_completion()
	update_icon()
	if(state >= 11)
		new_missile(wh, gs, ps, iff)
		return TRUE

/obj/item/ship_weapon/ammunition/missile/missile_casing/welder_act(mob/user, obj/item/tool)
	switch(state)
		if(0)
			to_chat(user, "<span class='notice'>Zaczynasz rozbierać [src]...</span>")
			if(tool.use_tool(src, user, 40, amount=1, volume=100))
				to_chat(user, "<span class='notice'>Rozbierasz [src].</span>")
				new /obj/item/stack/sheet/iron(loc, 5)
				add_fingerprint(user)
				qdel(src)
			return TRUE
		if(10)
			to_chat(user, "<span class='notice'>Zaczynasz zaspawywać obudowę [src]...</span>")
			if(tool.use_tool(src, user, 40, amount=1, volume=100))
				to_chat(user, "<span class='notice'Zaspawujesz obudowę [src].</span>")
				state = 11
				check_completion()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/crowbar_act(mob/user, obj/item/tool)
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>Zaczynasz wyjmować [ps.name] z [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Wyjmujesz [ps.name] z [src].</span>")
				ps?.forceMove(get_turf(src))
				ps = null
				state = 0
				update_icon()
			return TRUE
		if(3)
			to_chat(user, "<span class='notice'>Zaczynasz wyjmować [gs.name] z [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Wyjmujesz [gs.name] z [src].</span>")
				gs?.forceMove(get_turf(src))
				gs = null
				state = 2
				update_icon()
			return TRUE
		if(5)
			to_chat(user, "<span class='notice'>Zaczynasz wyjmować [iff.name] z [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Wyjmujesz [iff.name] z [src].</span>")
				iff?.forceMove(get_turf(src))
				iff = null
				state = 4
				update_icon()
			return TRUE
		if(7)
			to_chat(user, "<span class='notice'>Zaczynasz wyjmować [wh.name] z [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>Wyjmujesz [wh.name] z [src].</span>")
				wh?.forceMove(get_turf(src))
				wh = null
				state = 6
				update_icon()
			return TRUE
	. = ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/update_icon()
	cut_overlays()
	switch(state)
		if(1)
			icon_state = "missile_case_prop"
		if(2)
			icon_state = "missile_case_prop_bolt"
		if(3)
			icon_state = "missile_case_guide"
		if(4)
			icon_state = "missile_case_guide_screw"
		if(5)
			icon_state = "missile_case_iff"
		if(6)
			icon_state = "missile_case_iff_screw"
		if(7)
			icon_state = "missile_case_warhead"
		if(8)
			icon_state = "missile_case_warhead_screw"
		if(9)
			icon_state = "missile_case_warhead_wired"
		if(10)
			icon_state = "missile_case_warhead_complete"

/obj/item/ship_weapon/ammunition/missile/missile_casing/proc/new_missile(
			obj/item/ship_weapon/parts/missile/warhead,
			obj/item/ship_weapon/parts/missile/guidance_system,
			obj/item/ship_weapon/parts/missile/propulsion_system,
			obj/item/ship_weapon/parts/missile/iff_card)


	wh = locate(/obj/item/ship_weapon/parts/missile/warhead) in src
	new wh.build_path(get_turf(src))
	for(var/I in contents)
		qdel(I) //Change this if we ever need to add more component factoring in to performance. This avoids infinite torpedo parts because the torpedo gets Qdel'd
	qdel(src)

