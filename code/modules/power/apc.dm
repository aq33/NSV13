//update_state
#define UPSTATE_CELL_IN		(1<<2)
#define UPSTATE_MAINT		(1<<3)
#define UPSTATE_BROKE		(1<<4)
#define UPSTATE_BLUESCREEN	(1<<5)
#define UPSTATE_WIREEXP		(1<<6)
#define UPSTATE_ALLGOOD		(1<<7)

#define APC_RESET_EMP "emp"

//update_overlay
#define APC_UPOVERLAY_CHARGEING0	(1<<0)
#define APC_UPOVERLAY_CHARGEING1	(1<<1)
#define APC_UPOVERLAY_CHARGEING2	(1<<2)
#define APC_UPOVERLAY_EQUIPMENT0	(1<<3)
#define APC_UPOVERLAY_EQUIPMENT1	(1<<4)
#define APC_UPOVERLAY_EQUIPMENT2	(1<<5)
#define APC_UPOVERLAY_LIGHTING0		(1<<6)
#define APC_UPOVERLAY_LIGHTING1		(1<<7)
#define APC_UPOVERLAY_LIGHTING2		(1<<8)
#define APC_UPOVERLAY_ENVIRON0		(1<<9)
#define APC_UPOVERLAY_ENVIRON1		(1<<10)
#define APC_UPOVERLAY_ENVIRON2		(1<<11)
#define APC_UPOVERLAY_LOCKED		(1<<12)
#define APC_UPOVERLAY_OPERATING		(1<<13)

#define APC_ELECTRONICS_MISSING 0 // None
#define APC_ELECTRONICS_INSTALLED 1 // Installed but not secured
#define APC_ELECTRONICS_SECURED 2 // Installed and secured

#define APC_COVER_CLOSED 0
#define APC_COVER_OPENED 1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING 0
#define APC_CHARGING 1
#define APC_FULLY_CHARGED 2

//NSV13 added ethereal power drain defines
#define APC_DRAIN_TIME 80
#define APC_POWER_GAIN 250

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire connection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area's electrical systems."

	icon_state = "apc0"
	use_power = NO_POWER_USE
	req_access = null
	max_integrity = 200
	integrity_failure = 50
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	clicksound = 'sound/machines/terminal_select.ogg'
	layer = ABOVE_WINDOW_LAYER



	FASTDMM_PROP(\
		set_instance_vars(\
			pixel_x = dir == EAST ? 24 : (dir == WEST ? -24 : INSTANCE_VAR_DEFAULT),\
			pixel_y = dir == NORTH ? 24 : (dir == SOUTH ? -24 : INSTANCE_VAR_DEFAULT)\
		),\
		dir_amount = 4\
    )

	var/lon_range = 2
	var/area/area
	var/areastring = null
	var/obj/item/stock_parts/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = /obj/item/stock_parts/cell/upgraded		//Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	var/opened = APC_COVER_CLOSED
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = TRUE
	var/charging = APC_NOT_CHARGING
	var/chargemode = 1
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/has_electronics = APC_ELECTRONICS_MISSING // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupier = null
	var/transfer_in_progress = FALSE //Is there an AI being transferred out of us?
	var/longtermpower = 10
	var/auto_name = FALSE
	var/failure_timer = 0
	var/force_update = 0
	var/emergency_lights = FALSE
	var/nightshift_lights = FALSE
	var/last_nightshift_switch = 0
	var/update_state = -1
	var/update_overlay = -1
	var/icon_update_needed = FALSE
	var/obj/machinery/computer/apc_control/remote_control = null

	var/clock_cog_rewarded = FALSE	//Clockcult - Has the reward for converting an APC been given?
	var/integration_cog = null		//Clockcult - The integration cog inserted inside of us

/obj/machinery/power/apc/unlocked
	locked = FALSE

/obj/machinery/power/apc/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/power/apc/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

/obj/machinery/power/apc/highcap/five_k
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/machinery/power/apc/highcap/ten_k
	cell_type = /obj/item/stock_parts/cell/high

/obj/machinery/power/apc/highcap/fifteen_k
	cell_type = /obj/item/stock_parts/cell/high/plus

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

/obj/machinery/power/apc/auto_name/north //Pixel offsets get overwritten on New()
	dir = NORTH
	pixel_y = 23

/obj/machinery/power/apc/auto_name/south
	dir = SOUTH
	pixel_y = -23

/obj/machinery/power/apc/auto_name/east
	dir = EAST
	pixel_x = 24

/obj/machinery/power/apc/auto_name/west
	dir = WEST
	pixel_x = -25

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=0)
	if (!req_access)
		req_access = list(ACCESS_ENGINE_EQUIP)
	if (!armor)
		armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 100, "bomb" = 30, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 50, "stamina" = 0)
	..()
	GLOB.apcs_list += src

	wires = new /datum/wires/apc(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		setDir(ndir)
	tdir = dir		// to fix Vars bug
	setDir(SOUTH)

	switch(tdir)
		if(NORTH)
			if((pixel_y != initial(pixel_y)) && (pixel_y != 23))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_y value ([pixel_y] - should be 23.)")
			pixel_y = 23
		if(SOUTH)
			if((pixel_y != initial(pixel_y)) && (pixel_y != -23))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_y value ([pixel_y] - should be -23.)")
			pixel_y = -23
		if(EAST)
			if((pixel_y != initial(pixel_x)) && (pixel_x != 24))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_x value ([pixel_x] - should be 24.)")
			pixel_x = 24
		if(WEST)
			if((pixel_y != initial(pixel_x)) && (pixel_x != -25))
				log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([tdir] | [uppertext(dir2text(tdir))]) has pixel_x value ([pixel_x] - should be -25.)")
			pixel_x = -25
	if (building)
		area = get_area(src)
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [get_area_name(area, TRUE)] APC"
		set_machine_stat(machine_stat | MAINT)
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	if(malfai && operating)
		malfai.malf_picker.processing_time = CLAMP(malfai.malf_picker.processing_time - 10,0,1000)
	if(area)
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
		area.power_change()
		area.poweralert(FALSE, src)
	if(occupier)
		malfvacate(1)
	qdel(wires)
	wires = null
	if(cell)
		qdel(cell)
	if(terminal)
		disconnect_terminal()
	. = ..()

/obj/machinery/power/apc/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_appearance()
		updateUsrDialog()

/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(loc)
	terminal.setDir(tdir)
	terminal.master = src

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	has_electronics = APC_ELECTRONICS_SECURED
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		cell = new cell_type
		cell.charge = start_charge * cell.maxcharge / 100 		// (convert percentage to actual value)

	var/area/A = loc.loc

	//if area isn't specified use current
	if(areastring)
		area = get_area_instance_from_text(areastring)
		if(!area)
			area = A
			stack_trace("Bad areastring path for [src], [areastring]")
	else if(isarea(A) && areastring == null)
		area = A

	if(auto_name)
		name = "\improper [get_area_name(area, TRUE)] APC"

	update_appearance()

	make_terminal()

	addtimer(CALLBACK(src, PROC_REF(update)), 5)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		return
	if(opened)
		if(has_electronics && terminal)
			. += "Pokrywa jest [opened==APC_COVER_REMOVED?"zdjęta":"otwarta"], a ogniwo zasilające [ cell ? "jest zainstalowane" : "jest nieobecne"]."
		else
			. += "[ !terminal ? "Nie jest" : "Jest" ] podłączony.\n"+\
			"Elektronika [!has_electronics?"nie jest":"jest"] zainstalowana."
		if(integration_cog || (user.hallucinating() && prob(20)))
			. += "W środku jest mała zębatka."

	else
		if (machine_stat & MAINT)
			. += "Pokrywa jest zamknięta. Coś jest z nią nie tak. Nie działa."
		else if (malfhack)
			. += "Pokrywa jest uszkodzona. Może być trudno ją sforsować."
		else
			. += "Pokrywa jest zamknięta."

	. += "<span class='notice'>Alt-kliknij APC, by [ locked ? "odblokować" : "zablokować"] interfejs.</span>"

	if(issilicon(user))
		. += "<span class='notice'>Ctrl-kliknij APC, by [ operating ? "wyłączyć" : "włączyć"] wyłącznik.</span>"

// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_appearance(updates=check_updates())
	icon_update_needed = FALSE
	if(!updates)
		return

	. = ..()
	// And now, separately for cleanness, the lighting changing
	if(!update_state)
		switch(charging)
			if(APC_NOT_CHARGING)
				set_light_color(LIGHT_COLOR_RED)
			if(APC_CHARGING)
				set_light_color(LIGHT_COLOR_BLUE)
			if(APC_FULLY_CHARGED)
				set_light_color(LIGHT_COLOR_GREEN)
		set_light(lon_range)
		return

	if(update_state & UPSTATE_BLUESCREEN)
		set_light_color(LIGHT_COLOR_BLUE)
		set_light(lon_range)
		return

	set_light(0)

/obj/machinery/power/apc/update_icon_state()
	if(!update_state)
		icon_state = "apc0"
		return ..()
	if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
		var/basestate = "apc[cell ? 2 : 1]"
		if(update_state & UPSTATE_OPENED1)
			icon_state = (update_state & (UPSTATE_MAINT|UPSTATE_BROKE)) ? "apcmaint" : basestate
		else if(update_state & UPSTATE_OPENED2)
			icon_state = "[basestate][((update_state & UPSTATE_BROKE) || malfhack) ? "-b" : null]-nocover"
		return ..()
	if(update_state & UPSTATE_BROKE)
		icon_state = "apc-b"
		return ..()
	if(update_state & UPSTATE_BLUESCREEN)
		icon_state = "apcemag"
		return ..()
	if(update_state & UPSTATE_WIREEXP)
		icon_state = "apcewires"
		return ..()
	if(update_state & UPSTATE_MAINT)
		icon_state = "apc0"
	return ..()

/obj/machinery/power/apc/update_overlays()
	. = ..()
	if((machine_stat & (BROKEN|MAINT)) || update_state)
		return

	. += mutable_appearance(icon, "apcox-[locked]")
	. += emissive_appearance(icon, "apcox-[locked]")
	. += mutable_appearance(icon, "apco3-[charging]")
	. += emissive_appearance(icon, "apco3-[charging]")
	if(!operating)
		return

	. += mutable_appearance(icon, "apco0-[equipment]")
	. += emissive_appearance(icon, "apco0-[equipment]")
	. += mutable_appearance(icon, "apco1-[lighting]")
	. += emissive_appearance(icon, "apco1-[lighting]")
	. += mutable_appearance(icon, "apco2-[environ]")
	. += emissive_appearance(icon, "apco2-[environ]")

/// Checks for what icon updates we will need to handle
/obj/machinery/power/apc/proc/check_updates()
	SIGNAL_HANDLER
	. = NONE

	// Handle icon status:
	var/new_update_state = NONE
	if(machine_stat & BROKEN)
		new_update_state |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		new_update_state |= UPSTATE_MAINT

	if(opened)
		new_update_state |= (opened << UPSTATE_COVER_SHIFT)
		if(cell)
			new_update_state |= UPSTATE_CELL_IN

	else if((obj_flags & EMAGGED) || malfai)
		new_update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		new_update_state |= UPSTATE_WIREEXP

	if(new_update_state != update_state)
		update_state = new_update_state
		. |= UPDATE_ICON_STATE

	// Handle overlay status:
	var/new_update_overlay = NONE
	if(operating)
		new_update_overlay |= UPOVERLAY_OPERATING

	if(!update_state)
		if(locked)
			new_update_overlay |= UPOVERLAY_LOCKED

		new_update_overlay |= (charging << UPOVERLAY_CHARGING_SHIFT)
		new_update_overlay |= (equipment << UPOVERLAY_EQUIPMENT_SHIFT)
		new_update_overlay |= (lighting << UPOVERLAY_LIGHTING_SHIFT)
		new_update_overlay |= (environ << UPOVERLAY_ENVIRON_SHIFT)

	if(new_update_overlay != update_overlay)
		update_overlay = new_update_overlay
		. |= UPDATE_OVERLAYS

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/W)
	. = TRUE
	if (opened)
		if(integration_cog)
			to_chat(user, "<span class='notice'>Zaczynasz coś wyważać z APC.</span>")
			W.play_tool_sound(src)
			if(W.use_tool(src, user, 50))
				to_chat(user, "<span class='warning'>Partaczysz, niszcząc to, co było w środku!</span>")
				QDEL_NULL(integration_cog)
		else if (has_electronics == APC_ELECTRONICS_INSTALLED)
			if (terminal)
				to_chat(user, "<span class='warning'>Najpierw odłącz przewody!</span>")
				return
			W.play_tool_sound(src)
			to_chat(user, "<span class='notice'>Próbujesz wyjąć płytkę sterowania zasilaniem.</span>" )
			if(W.use_tool(src, user, 50))
				if (has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if (machine_stat & BROKEN)
						user.visible_message(\
							"[user.name] łamie płytkę sterowania zasilaniem w [src.name]!",\
							"<span class='notice'>Łamiesz zwęgloną płytkę sterowania zasilaniem i wyjmujesz resztki.</span>",
							"<span class='italics'>Słyszysz trzask.</span>")
						return
					else if (obj_flags & EMAGGED)
						obj_flags &= ~EMAGGED
						user.visible_message(\
							"[user.name] wyrzuca zemagowaną płytkę sterowania zasilaniem z [src.name]!",\
							"<span class='notice'>Wyrzucasz zemagowaną płytkę sterowania zasilaniem.</span>")
						return
					else if (malfhack)
						user.visible_message(\
							"[user.name] wyrzuca dziwnie zaprogramowaną płytkę sterowania zasilaniem z [src.name]!",\
							"<span class='notice'>Wyrzucasz dziwnie zaprogramowaną płytkę.</span>")
						malfai = null
						malfhack = 0
						return
					else
						user.visible_message(\
							"[user.name] wyjmuje płytkę sterowania zasilaniem z [src.name]!",\
							"<span class='notice'>Wyjmujesz płytkę sterowania zasilaniem.</span>")
						new /obj/item/electronics/apc(loc)
						return
		else if (opened!=APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_appearance()
			return
	else if (!(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			to_chat(user, "<span class='warning'>Pokrywa jest zablokowana i nie da się jej otworzyć!</span>")
			return
		else if (panel_open)
			to_chat(user, "<span class='warning'>Odsłonięte przewody uniemożliwiają otwarcie!</span>")
			return
		else
			opened = APC_COVER_OPENED
			update_appearance()
			return

/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			user.visible_message("[user] wyjmuje [cell] z [src]!","<span class='notice'>Wyjmujesz [cell].</span>")
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_appearance()
			cell = null
			charging = APC_NOT_CHARGING
			update_appearance()
			return
		else
			switch (has_electronics)
				if (APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					set_machine_stat(machine_stat & ~MAINT)
					W.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Przykręcasz elektronikę.</span>")
				if (APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					set_machine_stat(machine_stat | MAINT)
					W.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Odkręcasz elektronikę.</span>")
				else
					to_chat(user, "<span class='warning'>Nie ma czego mocować!</span>")
					return
			update_appearance()
	else if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Interfejs jest zepsuty!</span>")
		return
	else
		panel_open = !panel_open
		to_chat(user, "Przewody zostały [panel_open ? "odsłonięte" : "zakryte"].")
		update_appearance()

/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/W)
	if (terminal && opened)
		terminal.dismantle(user, W)
		return TRUE


/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/W)
	if (opened && !has_electronics && !terminal)
		if(!W.tool_start_check(user, amount=3))
			return
		user.visible_message("[user.name] welds [src].", \
							"<span class='notice'>Zaczynasz spawać ramę APC.</span>", \
							"<span class='italics'>Słyszysz spawanie.</span>")
		if(W.use_tool(src, user, 50, volume=50, amount=3))
			if ((machine_stat & BROKEN) || opened==APC_COVER_REMOVED)
				new /obj/item/stack/sheet/iron(loc)
				user.visible_message(\
					"[user.name] rozcina [src] za pomocą [W].",\
					"<span class='notice'>Rozbierasz zniszczoną ramę APC.</span>")
			else
				new /obj/item/wallframe/apc(loc)
				user.visible_message(\
					"[user.name] odcina [src] od ściany za pomocą [W].",\
					"<span class='notice'>Odcinasz ramę APC od ściany.</span>")
			qdel(src)
			return TRUE

/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user, params)

	if(issilicon(user) && get_dist(src,user)>1)
		return attack_hand(user)

	if	(istype(W, /obj/item/stock_parts/cell) && opened)
		if(cell)
			to_chat(user, "<span class='warning'>Ogniwo zasilające jest już zainstalowane!</span>")
			return
		else
			if (machine_stat & MAINT)
				to_chat(user, "<span class='warning'>Nie ma złącza na twoje ogniwo zasilające!</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			user.visible_message(\
				"[user.name] wkłada ogniwo zasilające do [src.name]!",\
				"<span class='notice'>Wkładasz ogniwo zasilające.</span>")
			chargecount = 0
			update_appearance()
	else if (W.GetID())
		togglelock(user)
	else if (istype(W, /obj/item/stack/cable_coil) && opened)
		var/turf/host_turf = get_turf(src)
		if(!host_turf)
			CRASH("attackby on APC when it's not on a turf")
		if (host_turf.intact)
			to_chat(user, "<span class='warning'>Najpierw musisz zdjąć poszycie podłogi przed APC!</span>")
			return
		else if (terminal)
			to_chat(user, "<span class='warning'>To APC jest już okablowane!</span>")
			return
		else if (!has_electronics)
			to_chat(user, "<span class='warning'>Nie ma czego okablować!</span>")
			return

		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>Do APC potrzebujesz dziesięciu odcinków kabla!</span>")
			return
		user.visible_message("[user.name] podłącza kable do ramy APC.", \
							"<span class='notice'>Zaczynasz podłączać kable do ramy APC.</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			if (C.get_amount() < 10 || !C)
				return
			if (C.get_amount() >= 10 && !terminal && opened && has_electronics)
				var/turf/T = get_turf(src)
				var/obj/structure/cable/N = T.get_cable_node()
				if (prob(50) && electrocute_mob(usr, N, N, 1, TRUE))
					do_sparks(5, TRUE, src)
					return
				C.use(10)
				to_chat(user, "<span class='notice'>Podłączasz kable do ramy APC.</span>")
				make_terminal()
				terminal.connect_to_network()
	else if (istype(W, /obj/item/electronics/apc) && opened)
		if (has_electronics)
			to_chat(user, "<span class='warning'>W [src] jest już płytka!</span>")
			return
		else if (machine_stat & BROKEN)
			to_chat(user, "<span class='warning'>Nie możesz włożyć płytki, rama jest uszkodzona!</span>")
			return

		user.visible_message("[user.name] wkłada płytkę sterowania zasilaniem do [src].", \
							"<span class='notice'>Zaczynasz wkładać płytkę sterowania zasilaniem do ramy.</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		if(do_after(user, 10, target = src))
			if(!has_electronics)
				has_electronics = APC_ELECTRONICS_INSTALLED
				locked = FALSE
				wires.ui_update()
				to_chat(user, "<span class='notice'>Umieszczasz płytkę sterowania zasilaniem w ramie.</span>")
				qdel(W)
	else if(istype(W, /obj/item/electroadaptive_pseudocircuit) && opened)
		var/obj/item/electroadaptive_pseudocircuit/P = W
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>Rama [src] jest zbyt uszkodzona, by utrzymać płytkę.</span>")
				return
			if(!P.adapt_circuit(user, 50))
				return
			user.visible_message("<span class='notice'>[user] wytwarza płytkę i umieszcza ją w [src].</span>", \
			"<span class='notice'>Dostosowujesz płytkę sterowania zasilaniem i wpinasz ją we wnętrzności [src].</span>")
			has_electronics = APC_ELECTRONICS_INSTALLED
			locked = FALSE
			wires.ui_update()
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, "<span class='warning'>Nie ma złącza na ogniwo zasilające.</span>")
				return
			if(!P.adapt_circuit(user, 500))
				return
			var/obj/item/stock_parts/cell/crap/empty/C = new(src)
			C.forceMove(src)
			cell = C
			chargecount = 0
			user.visible_message("<span class='notice'>[user] wytwarza słabe ogniwo zasilające i umieszcza je w [src].</span>", \
			"<span class='warning'>[P.name] buczy z wysiłku, gdy tworzysz słabe ogniwo zasilające i umieszczasz je w [src]!</span>")
			update_appearance()
		else
			to_chat(user, "<span class='warning'>[src] ma już elektronikę i ogniwo.</span>")
			return
	else if (istype(W, /obj/item/wallframe/apc) && opened)
		if (!(machine_stat & BROKEN || opened==APC_COVER_REMOVED || obj_integrity < max_integrity)) // There is nothing to repair
			to_chat(user, "<span class='warning'>Nie widzisz powodu, by naprawiać to APC.</span>")
			return
		if (!(machine_stat & BROKEN) && opened==APC_COVER_REMOVED) // Cover is the only thing broken, we do not need to remove elctronicks to replace cover
			user.visible_message("[user.name] zakłada brakującą pokrywę APC.",\
							"<span class='notice'>Zaczynasz zakładać pokrywę APC.</span>")
			if(do_after(user, 20, target = src)) // replacing cover is quicker than replacing whole frame
				to_chat(user, "<span class='notice'>Zakładasz brakującą pokrywę APC.</span>")
				qdel(W)
				opened = APC_COVER_OPENED
				update_appearance()
			return
		if (has_electronics)
			to_chat(user, "<span class='warning'>Nie możesz naprawić tego APC, dopóki nie wyjmiesz elektroniki ze środka!</span>")
			return
		user.visible_message("[user.name] wymienia uszkodzoną ramę APC na nową.",\
							"<span class='notice'>Zaczynasz wymieniać uszkodzoną ramę APC.</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>Wymieniasz uszkodzoną ramę APC na nową.</span>")
			qdel(W)
			set_machine_stat(machine_stat & ~BROKEN)
			obj_integrity = max_integrity
			if (opened==APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_appearance()

	else if(istype(W, /obj/item/apc_powercord))
		return //because we put our fancy code in the right places, and this is all in the powercord's afterattack()

	else if(panel_open && !opened && is_wire_tool(W))
		wires.interact(user)
	else
		return ..()

/obj/machinery/power/apc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		if(!has_electronics)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>Rama [src] jest zbyt uszkodzona, by utrzymać płytkę.</span>")
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
		else if(!cell)
			if(machine_stat & MAINT)
				to_chat(user, "<span class='warning'>Nie ma złącza na ogniwo zasilające.</span>")
				return FALSE
			return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 50, "cost" = 10) //16 for a wall
		else
			to_chat(user, "<span class='warning'>[src] ma już elektronikę i ogniwo.</span>")
			return FALSE
	return FALSE

/obj/machinery/power/apc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			if(!has_electronics)
				if(machine_stat & BROKEN)
					to_chat(user, "<span class='warning'>Rama [src] jest zbyt uszkodzona, by utrzymać płytkę.</span>")
					return
				user.visible_message("<span class='notice'>[user] wytwarza płytkę i umieszcza ją w [src].</span>", \
				"<span class='notice'>Dostosowujesz płytkę sterowania zasilaniem i wpinasz ją we wnętrzności [src].</span>")
				has_electronics = TRUE
				locked = FALSE
				return TRUE
			else if(!cell)
				if(machine_stat & MAINT)
					to_chat(user, "<span class='warning'>Nie ma złącza na ogniwo zasilające.</span>")
					return FALSE
				var/obj/item/stock_parts/cell/crap/empty/C = new(src)
				C.forceMove(src)
				cell = C
				chargecount = 0
				user.visible_message("<span class='notice'>[user] wytwarza słabe ogniwo zasilające i umieszcza je w [src].</span>", \
				"<span class='warning'>[the_rcd.name] buczy z wysiłku, gdy tworzysz słabe ogniwo zasilające i umieszczasz je w [src]!</span>")
				update_appearance()
				return TRUE
			else
				to_chat(user, "<span class='warning'>[src] ma już elektronikę i ogniwo.</span>")
				return FALSE
	return FALSE

/obj/machinery/power/apc/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	else
		togglelock(user)

/obj/machinery/power/apc/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Interfejs jest zepsuty!</span>")
	else if(opened)
		to_chat(user, "<span class='warning'>Musisz zamknąć pokrywę, by przeciągnąć kartę ID!</span>")
	else if(panel_open)
		to_chat(user, "<span class='warning'>Musisz zamknąć panel!</span>")
	else if(machine_stat & (BROKEN|MAINT))
		to_chat(user, "<span class='warning'>Nic się nie dzieje!</span>")
	else
		if(allowed(usr) && !wires.is_cut(WIRE_IDSCAN) && !malfhack)
			locked = !locked
			wires.ui_update()
			to_chat(user, "<span class='notice'>[ locked ? "Blokujesz" : "Odblokowujesz"] interfejs APC.</span>")
			update_appearance()
			updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")

/obj/machinery/power/apc/proc/toggle_nightshift_lights(mob/living/user)
	if(last_nightshift_switch > world.time - 100) //~10 seconds between each toggle to prevent spamming
		to_chat(usr, "<span class='warning'>Wyłącznik nocnego oświetlenia [src] wciąż się przełącza!</span>")
		return
	last_nightshift_switch = world.time
	set_nightshift(!nightshift_lights)

/obj/machinery/power/apc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 10 && (!(machine_stat & BROKEN) || malfai))
		return 0
	. = ..()


/obj/machinery/power/apc/obj_break(damage_flag)
	. = ..()
	if(.)
		set_broken()

/obj/machinery/power/apc/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat & BROKEN))
			set_broken()
		if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_REMOVED
			coverlocked = FALSE
			visible_message("<span class='warning'>Pokrywa APC zostaje strącona!</span>")
			update_appearance()

/obj/machinery/power/apc/emag_act(mob/user)
	if(!(obj_flags & EMAGGED) && !malfhack)
		if(opened)
			to_chat(user, "<span class='warning'>Musisz zamknąć pokrywę, by przeciągnąć kartę ID!</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>Najpierw musisz zamknąć panel!</span>")
		else if(machine_stat & (BROKEN|MAINT))
			to_chat(user, "<span class='warning'>Nic się nie dzieje!</span>")
		else
			flick("apc-spark", src)
			playsound(src, "sparks", 75, 1)
			obj_flags |= EMAGGED
			locked = FALSE
			wires.ui_update()
			to_chat(user, "<span class='notice'>Emagujesz interfejs APC.</span>")
			update_appearance()


//NSV13 changed numbers to defines
// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(isethereal(user))
		var/mob/living/carbon/human/H = user
		var/datum/species/ethereal/E = H.dna.species
		if(E.drain_time > world.time)
			return
		var/obj/item/organ/stomach/battery/stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
		if(H.combat_mode)
			if(!istype(stomach))
				to_chat(H, "<span class='warning'>Nie możesz przyjąć ładunku!</span>")
				return
			if(H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
				to_chat(user, "<span class='warning'>Już jesteś w pełni naładowany!</span>")
				return
			if(cell.charge <= cell.maxcharge/4) // if charge is under 25% you shouldn't drain it
				to_chat(H, "<span class='warning'>APC nie ma zbyt dużo energii, chyba nie powinieneś go dalej drenować.</span>")
				return

			E.drain_time = world.time + APC_DRAIN_TIME //NSV13 - Ethereal charging changes (APC_DRAIN_TIME and APC_POWER_GAIN)
			to_chat(H, "<span class='notice'>Zaczynasz przepuszczać trochę energii z APC do swojego ciała.</span>")
			while(do_after(user, APC_DRAIN_TIME, target = src))
				if(!istype(stomach))
					to_chat(H, "<span class='warning'>Nie możesz przyjąć ładunku!</span>")
					return
				if(cell.charge <= cell.maxcharge/4)
					to_chat(H, "<span class='warning'>APC nie ma zbyt dużo energii, chyba nie powinieneś go dalej drenować.</span>")
					E.drain_time = 0
					return
				E.drain_time = world.time + APC_DRAIN_TIME //NSV13
				if(cell.charge > cell.maxcharge/4 + 250)
					stomach.adjust_charge(APC_POWER_GAIN)
					cell.charge -= APC_POWER_GAIN
					to_chat(H, "<span class='notice'>Otrzymujesz trochę ładunku z APC.</span>")
				else
					stomach.adjust_charge(cell.charge - cell.maxcharge/4)
					cell.charge = cell.maxcharge/4
					to_chat(H, "<span class='warning'>APC nie ma zbyt dużo energii, chyba nie powinieneś go dalej drenować.</span>")
					E.drain_time = 0
					return
				if(stomach.charge >= stomach.max_charge)
					to_chat(H, "<span class='notice'>Jesteś teraz w pełni naładowany.</span>")
					E.drain_time = 0
					return
			to_chat(H, "<span class='warning'>Nie udaje ci się pobrać ładunku z APC!</span>")
			E.drain_time = 0
			return
		else if(LAZYACCESS(modifiers, RIGHT_CLICK)) // AQ EDIT - port Bee #11899: dawniej intencja grab
			if(!istype(stomach))
				to_chat(H, "<span class='warning'>Nie możesz przekazać ładunku!</span>")
				return
			E.drain_time = world.time + APC_DRAIN_TIME //NSV13 - Ethereal charging changes (APC_DRAIN_TIME and APC_POWER_GAIN)
			to_chat(H, "<span class='notice'>Zaczynasz przepuszczać energię ze swojego ciała do APC.</span>")
			while(do_after(user, 75, target = src))
				if(!istype(stomach))
					to_chat(H, "<span class='warning'>Nie możesz przekazać ładunku!</span>")
					return
				E.drain_time = world.time + APC_DRAIN_TIME //NSV13
				if(stomach.charge > APC_POWER_GAIN)
					to_chat(H, "<span class='notice'>Przekazujesz trochę energii do APC.</span>")
					stomach.adjust_charge(-APC_POWER_GAIN)
					cell.charge = min(cell.charge + APC_POWER_GAIN, cell.maxcharge)
				else
					to_chat(H, "<span class='notice'>Przekazujesz resztkę swojego ładunku do APC.</span>")
					cell.charge = min(cell.charge + stomach.charge, cell.maxcharge)
					stomach.set_charge(0)
					E.drain_time = 0
					return
				if(cell.charge >= cell.maxcharge)
					to_chat(H, "<span class='notice'>APC jest teraz w pełni naładowane.</span>")
					E.drain_time = 0
					return
			to_chat(H, "<span class='warning'>Nie udaje ci się przekazać energii do APC!</span>")
			E.drain_time = 0
			return

	if(opened && (!issilicon(user)))
		if(cell)
			user.visible_message("[user] wyjmuje [cell] z [src]!","<span class='notice'>Wyjmujesz [cell].</span>")
			user.put_in_hands(cell)
			cell.update_appearance()
			src.cell = null
			charging = APC_NOT_CHARGING
			src.update_appearance()
		return
	if((machine_stat & MAINT) && !opened) //no board; no interface
		return

/obj/machinery/power/apc/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	ui_interact(eminence)

/obj/machinery/power/apc/ui_state(mob/user)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		if(AI.apc_override == src)
			return GLOB.conscious_state
	if(iseminence(user) && integration_cog)
		return GLOB.conscious_state
	return GLOB.default_state

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Apc")
		ui.open()
		ui.set_autoupdate(TRUE) // Power level, reboot timer

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = display_power(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = user.has_unlimited_silicon_privilege || user.using_power_flow_console(),
		"malfStatus" = get_malf_status(user),
		"emergencyLights" = !emergency_lights,
		"nightshiftLights" = nightshift_lights,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = display_power(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = display_power(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = display_power(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)
	return data


/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(istype(malf) && malf.malf_picker)
		if(malfai == (malf.parent || malf))
			if(occupier == malf)
				return 3 // 3 = User is shunted in this APC
			else if(istype(malf.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted && !failure_timer)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = FALSE
		area.power_equip = FALSE
		area.power_environ = FALSE
	area.power_change()

/obj/machinery/power/apc/proc/can_use(mob/user, loud = 0) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(user.has_unlimited_silicon_privilege)
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if(!allowed(user))
			return FALSE
		if (                                                             \
			src.aidisabled ||                                            \
			malfhack && istype(malfai) &&                                \
			(                                                            \
				(istype(AI) && (malfai!=AI && malfai != AI.parent)) ||   \
				(istype(robot) && (robot in malfai.connected_robots))    \
			)                                                            \
		)
			if(!loud)
				to_chat(user, "<span class='danger'>[src] zostaje wyłączony!</span>")
			return FALSE
	return TRUE

/obj/machinery/power/apc/can_interact(mob/user)
	. = ..()
	if (!. && !QDELETED(remote_control))
		. = remote_control.can_interact(user)

/obj/machinery/power/apc/ui_status(mob/user)
	. = ..()
	if (!QDELETED(remote_control) && user == remote_control.operator)
		. = UI_INTERACTIVE

/obj/machinery/power/apc/ui_act(action, params)
	if(..() || !can_use(usr, 1))
		return

	switch(action)
		if("reboot")
			if(failure_timer)
				failure_timer = 0
				update_appearance()
				update()
				. = TRUE

	if(locked && !usr.has_unlimited_silicon_privilege)
		return

	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((obj_flags & EMAGGED) || (machine_stat & (BROKEN|MAINT)))
					to_chat(usr, "APC nie reaguje na polecenie.")
				else
					locked = !locked
					update_appearance()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("toggle_nightshift")
			toggle_nightshift_lights()
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_appearance()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_appearance()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_appearance()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_appearance()
				update()
			else
				return FALSE
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
		if("hack")
			if(get_malf_status(usr))
				malfhack(usr)
				. = TRUE
		if("occupy")
			if(get_malf_status(usr))
				malfoccupy(usr)
				. = TRUE
		if("deoccupy")
			if(get_malf_status(usr))
				malfvacate()
				. = TRUE
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/L in area)
				if(!initial(L.no_emergency)) //If there was an override set on creation, keep that override
					L.no_emergency = emergency_lights
					INVOKE_ASYNC(L, TYPE_PROC_REF(/obj/machinery/light, update), FALSE)
				CHECK_TICK
			. = TRUE

	if(.)
		wires.ui_update() // I don't know why this would be here, but I'm too scared to remove it

/obj/machinery/power/apc/ui_close(mob/user, datum/tgui/tgui)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		if(AI.apc_override == src)
			AI.apc_override = null

/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(!is_operational || failure_timer)
		return
	operating = !operating
	add_hiddenprint(user)
	log_game("[key_name(user)] turned [operating ? "on" : "off"] the [src] in [AREACOORD(src)]")
	update()
	update_appearance()

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != 1)
		return
	if(malf.malfhacking)
		to_chat(malf, "Już hakujesz jakieś APC.")
		return
	to_chat(malf, "Rozpoczynanie nadpisywania systemów APC. Zajmie to trochę czasu, a w tym czasie nie możesz wykonywać innych czynności.")
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai, malfhacked), src), 600, TIMER_STOPPABLE)

	var/atom/movable/screen/alert/hackingapc/A
	A = malf.throw_alert("hackingapc", /atom/movable/screen/alert/hackingapc)
	A.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>Najpierw musisz opuścić obecne APC!</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>Nie możesz się przenieść!</span>")
		return
	if(!is_station_level(z))
		return
	occupier = new /mob/living/silicon/ai(src, malf.laws, malf) //DEAR GOD WHY?	//IKR????
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "Kopia APC"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = 1
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	occupier.add_verb(/mob/living/silicon/ai/proc/corereturn)
	occupier.cancel_camera()


/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = 0
		occupier.parent.setOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		occupier.parent.remove_verb(/mob/living/silicon/ai/proc/corereturn)
		qdel(occupier)
	else
		to_chat(occupier, "<span class='danger'>Rdzeń główny uszkodzony, nie można przywrócić procesów rdzenia.</span>")
		if(forced)
			occupier.forceMove(drop_location())
			occupier.death()
			occupier.gib()
			for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
				P.switch_mode_to(TRACK_NUKE_DISK) //Pinpointers go back to tracking the nuke disk
				P.alert = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(card.AI)
		to_chat(user, "<span class='warning'>[card] jest już zajęta!</span>")
		return
	if(!occupier)
		to_chat(user, "<span class='warning'>W [src] nie ma niczego do przeniesienia!</span>")
		return
	if(!occupier.mind || !occupier.client)
		to_chat(user, "<span class='warning'>[occupier] jest nieaktywna lub zniszczona!</span>")
		return
	if(!occupier.parent.stat)
		to_chat(user, "<span class='warning'>[occupier] odrzuca wszelkie próby przeniesienia!</span>" )
		return
	if(transfer_in_progress)
		to_chat(user, "<span class='warning'>Transfer już trwa!</span>")
		return
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return
	var/turf/T = get_turf(user)
	if(!T)
		return
	transfer_in_progress = TRUE
	user.visible_message("<span class='notice'>[user] wsuwa [card] do [src]...</span>", "<span class='notice'>Rozpoczęto proces transferu. Wysyłanie prośby o zgodę SI...</span>")
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	SEND_SOUND(occupier, sound('sound/misc/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(alert(occupier, "[user] próbuje przenieść cię do [card.name]. Czy wyrażasz zgodę?", "Transfer z APC", "Yes - Transfer Me", "No - Keep Me Here") == "No - Keep Me Here")
		to_chat(user, "<span class='danger'>SI odrzuciła prośbę o transfer. Proces przerwany.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
		transfer_in_progress = FALSE
		return
	if(user.loc != T)
		to_chat(user, "<span class='danger'>Zmieniono lokalizację. Proces przerwany.</span>")
		to_chat(occupier, "<span class='warning'>[user] odszedł! Transfer anulowany.</span>")
		transfer_in_progress = FALSE
		return
	to_chat(user, "<span class='notice'>SI zaakceptowała prośbę. Przenoszenie przechowywanej inteligencji do [card].</span>")
	to_chat(occupier, "<span class='notice'>Rozpoczęcie transferu. Wkrótce zostaniesz przeniesiony do [card].</span>")
	if(!do_after(user, 50, target = src))
		to_chat(occupier, "<span class='warning'>[user] został przerwany! Transfer anulowany.</span>")
		transfer_in_progress = FALSE
		return
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return
	user.visible_message("<span class='notice'>[user] przenosi [occupier] do [card]!</span>", "<span class='notice'>Transfer zakończony! [occupier] jest teraz przechowywana w [card].</span>")
	to_chat(occupier, "<span class='notice'>Transfer zakończony! Zostajesz zapisany w [card.name] należącej do [user].</span>")
	occupier.forceMove(card)
	card.AI = occupier
	occupier.parent.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.add_load(amount)

/obj/machinery/power/apc/avail(amount)
	if(terminal)
		return terminal.avail(amount)
	else
		return 0

/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_appearance()
	if(machine_stat & (BROKEN|MAINT))
		return
	if(!area?.requires_power)
		return
	if(failure_timer)
		update()
		queue_icon_update()
		failure_timer--
		force_update = 1
		return

	lastused_light = area.power_usage[AREA_USAGE_LIGHT] + area.power_usage[AREA_USAGE_STATIC_LIGHT]
	lastused_equip = area.power_usage[AREA_USAGE_EQUIP] + area.power_usage[AREA_USAGE_STATIC_EQUIP]
	lastused_environ = area.power_usage[AREA_USAGE_ENVIRON] + area.power_usage[AREA_USAGE_STATIC_ENVIRON]
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		var/power_alert_fine = TRUE

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			power_alert_fine = FALSE
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			power_alert_fine = FALSE
		else if(cell.percent() < 30 && longtermpower < 0)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			power_alert_fine = FALSE
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)

		if(integration_cog)
			power_alert_fine = TRUE
		area.poweralert(power_alert_fine, src)

		// now trickle-charge the cell
		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else // chargemode off
			charging = 0
			chargecount = 0

		//=====Clock Cult=====
		if(integration_cog && cell.charge >= cell.maxcharge/2)
			var/power_delta = CLAMP(cell.charge - 20, 0, 20)
			GLOB.clockcult_power += power_delta
			cell.charge -= power_delta

	else // no cell, switch everything off

		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = 0
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/obj/machinery/power/apc/proc/autoset(val, on)
	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1
	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3
	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1
	return val

/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
			update_appearance()
			update()
	wires.ui_update()

// damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_CONTENTS))
		if(cell)
			cell.emp_act(severity)
		if(occupier)
			occupier.emp_act(severity)
	if(. & EMP_PROTECT_SELF)
		return
	lighting = 0
	equipment = 0
	environ = 0
	update_appearance()
	update()
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), 600)

/obj/machinery/power/apc/blob_act(obj/structure/blob/B)
	set_broken()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		malfai.malf_picker.processing_time = CLAMP(malfai.malf_picker.processing_time - 10,0,1000)
	machine_stat |= BROKEN
	operating = FALSE
	if(occupier)
		malfvacate(1)
	update_appearance()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in area)
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	do_sparks(5, TRUE, src)
	if(isalien(user))
		return 0
	if(electrocute_mob(user, src, src, 1, TRUE))
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0


/obj/machinery/power/apc/proc/energy_fail(duration)
	for(var/obj/machinery/M in area.contents)
		if(M.critical_machine)
			return
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/I = A
		if(get_area(I) == area)
			return

	failure_timer = max(failure_timer, round(duration))

/obj/machinery/power/apc/proc/set_nightshift(on)
	set waitfor = FALSE
	nightshift_lights = on
	for(var/obj/machinery/light/L in area)
		if(L.nightshift_allowed)
			L.nightshift_enabled = nightshift_lights
			L.update(FALSE)
		CHECK_TICK

#undef UPSTATE_CELL_IN
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_BLUESCREEN
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_RESET_EMP

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED

#undef APC_DRAIN_TIME
#undef APC_POWER_GAIN

//update_overlay
#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
#undef APC_UPOVERLAY_OPERATING

/*Power module, used for APC construction*/
/obj/item/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	custom_price = 5
	desc = "Heavy-duty switching circuits for power control."
