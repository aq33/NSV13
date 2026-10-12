#define SOLAR_MAX_DIST 40
#define SOLARGENRATE 1500

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	integrity_failure = 0.33

	var/id = 0
	max_integrity = 150
	integrity_failure = 50
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH // actual dir
	var/ndir = SOUTH // target dir
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/solar/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	Make(S)
	connect_to_network()

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the panel to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/solar/proc/set_control(obj/machinery/power/solar_control/SC)
	if(!SC || (get_dist(src, SC) > SOLAR_MAX_DIST))
		return 0
	control = SC
	SC.connected_panels |= src
	return 1

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels.Remove(src)
	control = null

/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.anchored = TRUE
	else
		S.forceMove(src)
	if(S.glass_type == /obj/item/stack/sheet/rglass) //if the panel is in reinforced glass
		max_integrity *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
		obj_integrity = max_integrity
	update_icon()

/obj/machinery/power/solar/crowbar_act(mob/user, obj/item/I)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	user.visible_message("[user] zaczyna zdejmować szkło z [src].", "<span class='notice'>Zaczynasz zdejmować szkło z [src]...</span>")
	if(I.use_tool(src, user, 50))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.visible_message("[user] zdejmuje szkło z [src].", "<span class='notice'>Zdejmujesz szkło z [src].</span>")
		deconstruct(TRUE)
	return TRUE

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, 1)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/power/solar/obj_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		unset_control()

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(machine_stat & BROKEN)
		else
			playsound(src, "shatter", 70, 1)
			new /obj/item/shard(src.loc)
			new /obj/item/shard(src.loc)
	qdel(src)


/obj/machinery/power/solar/update_icon()
	..()
	cut_overlays()
	if(machine_stat & BROKEN)
		add_overlay(mutable_appearance(icon, "solar_panel-b", FLY_LAYER))
	else
		add_overlay(mutable_appearance(icon, "solar_panel", FLY_LAYER))
		src.setDir(angle2dir(adir))

//calculates the fraction of the sunlight that the panel receives
/obj/machinery/power/solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return

	//find the smaller angle between the direction the panel is facing and the direction of the sun (the sign is not important here)
	var/p_angle = min(abs(adir - SSsun.angle), 360 - abs(adir - SSsun.angle))

	if(p_angle > 90)			// if facing more than 90deg from sun, zero output
		sunfrac = 0
		return

	sunfrac = cos(p_angle) ** 2
	//isn't the power received from the incoming light proportionnal to cos(p_angle) (Lambert's cosine law) rather than cos(p_angle)^2 ?

/obj/machinery/power/solar/process()//TODO: remove/add this from machines to save on processing as needed ~Carn PRIORITY
	if(machine_stat & BROKEN)
		return
	if(!control) //if there's no sun or the panel is not linked to a solar control computer, no need to proceed
		return

	if(powernet)
		if(powernet == control.powernet)//check if the panel is still connected to the computer
			if(obscured) //get no light from the sun, so don't generate power
				return
			var/sgen = SOLARGENRATE * sunfrac
			add_avail(sgen)
			control.gen += sgen
		else //if we're no longer on the same powernet, remove from control computer
			unset_control()


/obj/machinery/power/solar/fake/New(var/turf/loc, var/obj/item/solar_assembly/S)
	..(loc, S, 0)

/obj/machinery/power/solar/fake/process()
	. = PROCESS_KILL
	return

//trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion()

	var/ax = x		// start at the solar panel
	var/ay = y
	var/turf/T = null
	var/dx = SSsun.dx
	var/dy = SSsun.dy

	for(var/i = 1 to 20)		// 20 steps is enough
		ax += dx	// do step
		ay += dy

		T = locate( round(ax,0.5),round(ay,0.5),z)

		if(T.x == 1 || T.x==world.maxx || T.y==1 || T.y==world.maxy)		// not obscured if we reach the edge
			break

		if(T.density)			// if we hit a solid turf, panel is obscured
			obscured = 1
			return

	obscured = 0		// if hit the edge or stepped 20 times, not obscured
	update_solar_exposure()


//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	anchored = FALSE
	var/tracker = 0
	var/glass_type = null

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass(device_broken)
	var/atom/Tsec = drop_location()
	if(device_broken)
		new /obj/item/shard(Tsec)
		new /obj/item/shard(Tsec)
	else if(glass_type)
		new glass_type(Tsec, 2)
	glass_type = null


/obj/item/solar_assembly/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && isturf(loc))
		if(isinspace())
			to_chat(user, "<span class='warning'>Nie możesz tu zamocować [src].</span>")
			return
		anchored = !anchored
		if(anchored)
			user.visible_message("[user] przykręca zespół panelu słonecznego.", "<span class='notice'>Przykręcasz zespół panelu słonecznego.</span>")
			W.play_tool_sound(src, 75)
		else
			user.visible_message("[user] odkręca zespół panelu słonecznego.", "<span class='notice'>Odkręcasz zespół panelu słonecznego.</span>")
			W.play_tool_sound(src, 75)
		return 1

	if(istype(W, /obj/item/stack/sheet/glass) || istype(W, /obj/item/stack/sheet/rglass))
		if(!anchored)
			to_chat(user, "<span class='warning'>Zanim dodasz szkło, musisz zamocować zespół.</span>")
			return
		var/obj/item/stack/sheet/S = W
		if(S.use(2))
			glass_type = W.type
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user.visible_message("[user] kładzie szkło na zespole panelu słonecznego.", "<span class='notice'>Kładziesz szkło na zespole panelu słonecznego.</span>")
			if(tracker)
				new /obj/machinery/power/tracker(get_turf(src), src)
			else
				new /obj/machinery/power/solar(get_turf(src), src)
		else
			to_chat(user, "<span class='warning'>Do panelu słonecznego potrzebujesz dwóch arkuszy szkła!</span>")
			return
		return 1

	if(!tracker)
		if(istype(W, /obj/item/electronics/tracker))
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			tracker = 1
			qdel(W)
			user.visible_message("[user] wkłada elektronikę do zespołu panelu słonecznego.", "<span class='notice'>Wkładasz elektronikę do zespołu panelu słonecznego.</span>")
			return 1
	else
		if(W.tool_behaviour == TOOL_CROWBAR)
			new /obj/item/electronics/tracker(src.loc)
			tracker = 0
			user.visible_message("[user] wyjmuje elektronikę z zespołu panelu słonecznego.", "<span class='notice'>Wyjmujesz elektronikę z zespołu panelu słonecznego.</span>")
			return 1
	return ..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	max_integrity = 200
	integrity_failure = 100
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/id = 0
	var/currentdir = 0
	var/targetdir = 0		// target angle in manual tracking (since it updates every game minute)
	var/gen = 0
	var/lastgen = 0
	var/track = 0			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/nexttime = 0		// time for a panel to rotate of 1 degree in manual tracking
	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

/obj/machinery/power/solar_control/Initialize(mapload)
	. = ..()
	if(powernet)
		set_panels(currentdir)
	connect_to_network()

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

/obj/machinery/power/solar_control/disconnect_from_network()
	..()
	SSsun.solars.Remove(src)

/obj/machinery/power/solar_control/connect_to_network()
	var/to_return = ..()
	if(powernet) //if connected and not already in solar_list...
		SSsun.solars |= src //... add it
	return to_return

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					S.set_control(src)
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						T.set_control(src)

//called by the sun controller, update the facing angle (either manually or via tracking) and rotates the panels accordingly
/obj/machinery/power/solar_control/proc/update()
	if(machine_stat & (NOPOWER | BROKEN))
		return

	switch(track)
		if(1)
			if(trackrate) //we're manual tracking. If we set a rotation speed...
				currentdir = targetdir //...the current direction is the targetted one (and rotates panels to it)
		if(2) // auto-tracking
			if(connected_tracker)
				connected_tracker.set_angle(SSsun.angle)

	set_panels(currentdir)
	updateDialog()

/obj/machinery/power/solar_control/update_icon()
	cut_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	if(machine_stat & NOPOWER)
		add_overlay("[icon_keyboard]_off")
		return
	add_overlay(icon_keyboard)
	if(machine_stat & BROKEN)
		add_overlay("[icon_state]_broken")
	else
		SSvis_overlays.add_vis_overlay(src, icon, icon_screen, layer, plane, dir)
		SSvis_overlays.add_vis_overlay(src, icon, icon_screen, layer, EMISSIVE_PLANE, dir)


/obj/machinery/power/solar_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/solar_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SolarControl")
		ui.open()
		ui.set_autoupdate(TRUE) // Power output, solar panel direction

/obj/machinery/power/solar_control/ui_data()
	var/data = list()

	data["generated"] = round(lastgen)
	data["angle"] = currentdir
	data["direction"] = angle2text(currentdir)

	data["tracking_state"] = track
	data["tracking_rate"] = trackrate
	data["rotating_way"] = (trackrate<0 ? "CCW" : "CW")

	data["connected_panels"] = connected_panels.len
	data["connected_tracker"] = (connected_tracker ? 1 : 0)
	return data

/obj/machinery/power/solar_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("angle")
			var/adjust = text2num(params["adjust"])
			var/value = text2num(params["value"])
			if(adjust)
				value = currentdir + adjust
			if(value != null)
				currentdir = CLAMP((360 + value) % 360, 0, 359)
				targetdir = currentdir
				set_panels(currentdir)
				. = TRUE
		if("rate")
			var/adjust = text2num(params["adjust"])
			var/value = text2num(params["value"])
			if(adjust)
				value = trackrate + adjust
			if(value != null)
				trackrate = CLAMP(value, -7200, 7200)
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				. = TRUE
		if("tracking")
			var/mode = text2num(params["mode"])
			track = mode
			if(mode == 2 && connected_tracker)
				connected_tracker.set_angle(SSsun.angle)
				set_panels(currentdir)
			else if(mode == 1)
				targetdir = currentdir
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				set_panels(targetdir)
			. = TRUE
		if("refresh")
			search_for_connected()
			if(connected_tracker && track == 2)
				connected_tracker.set_angle(SSsun.angle)
			set_panels(currentdir)
			. = TRUE

/obj/machinery/power/solar_control/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(I.use_tool(src, user, 20, volume=50))
			if (src.machine_stat & BROKEN)
				to_chat(user, "<span class='notice'>Rozbite szkło wypada.</span>")
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				new /obj/item/shard( src.loc )
				var/obj/item/circuitboard/computer/solar_control/M = new /obj/item/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(drop_location())
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = TRUE
				qdel(src)
			else
				to_chat(user, "<span class='notice'>Odłączasz monitor.</span>")
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				var/obj/item/circuitboard/computer/solar_control/M = new /obj/item/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(drop_location())
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = TRUE
				qdel(src)
	else if(!user.combat_mode && !(I.item_flags & NOBLUDGEON))
		attack_hand(user)
	else
		return ..()

/obj/machinery/power/solar_control/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/power/solar_control/obj_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0

	if(machine_stat & (NOPOWER | BROKEN))
		return

	if(connected_tracker) //NOTE : handled here so that we don't add trackers to the processing list
		if(connected_tracker.powernet != powernet)
			connected_tracker.unset_control()

	if(track==1 && trackrate) //manual tracking and set a rotation speed
		if(nexttime <= world.time) //every time we need to increase/decrease the angle by 1°...
			targetdir = (targetdir + trackrate/abs(trackrate) + 360) % 360 	//... do it
			nexttime += 36000/abs(trackrate) //reset the counter for the next 1°

//rotates the panel to the passed angle
/obj/machinery/power/solar_control/proc/set_panels(currentdir)

	for(var/obj/machinery/power/solar/S in connected_panels)
		S.adir = currentdir //instantly rotates the panel
		S.occlusion()//and
		S.update_icon() //update it

	update_icon()


/obj/machinery/power/solar_control/power_change()
	..()
	update_icon()




//
// MISC
//

/obj/item/paper/guides/jobs/engi/solars
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	default_raw_text = "<h1>Witamy</h1><p>W greencorps kochamy środowisko i kosmos. Dzięki temu zestawowi możesz pomóc matce naturze i wytwarzać energię bez paliw kopalnych ani plazmy! Energia z osobliwości jest niebezpieczna, a słoneczna bezpieczna, dlatego jest lepsza. Oto jak zbudować własne pole paneli słonecznych.</p><p>Panel słoneczny zrobisz, przykręcając zespół panelu do węzła kabla. Dodanie tafli szkła, zbrojonego lub zwykłego, zakończy budowę panelu. To takie proste!</p><p>Po zbudowaniu kolejnych 19 paneli zbuduj tracker słoneczny, by śledzić dar matki natury – słońce. Kroki są takie same jak wcześniej, tylko przed ostatnim etapem, czyli dodaniem szkła, wkładasz do zespołu obwód trackera. Masz tracker! Ostatni krok to dodanie komputera, który oblicza ruch słońca i wysyła panelom polecenia, by obracały się za nim. Budowa komputera słonecznego wygląda jak budowa każdego innego komputera, więc nie powinieneś mieć z tym problemu. Pod komputerem musi jednak być węzeł przewodu, a przewód musi być podłączony do trackera.</p><p>Gratulacje, powinieneś mieć działające pole paneli słonecznych. Jeśli masz problemy, oto kilka wskazówek. Upewnij się, że cały sprzęt słoneczny stoi na węzłach kabla, nawet komputer. Jeśli się pomylisz, zawsze możesz rozebrać swoje konstrukcje.</p><p>To wszystko, bądź bezpieczny, bądź eko!</p>"
