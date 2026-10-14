#define ARM_ACTION_COOLDOWN (5 SECONDS)

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF




	var/timer_set = 90
	var/minimum_timer_set = 90
	var/maximum_timer_set = 3600

	var/numeric_input = ""
	var/ui_mode = NUKEUI_AWAIT_DISK

	var/timing = FALSE
	var/exploding = FALSE
	var/exploded = FALSE
	var/detonation_timer = null
	var/r_code = "ADMIN"
	var/yes_code = FALSE
	var/safety = TRUE
	var/obj/item/disk/nuclear/auth = null
	use_power = NO_POWER_USE
	var/previous_level = ""
	var/obj/item/nuke_core/core = null
	var/deconstruction_state = NUKESTATE_INTACT
	var/lights = ""
	var/interior = ""
	var/proper_bomb = TRUE //Please
	var/obj/effect/countdown/nuclearbomb/countdown
	var/sound/countdown_music = null
	COOLDOWN_DECLARE(arm_cooldown)

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	countdown = new(src)
	GLOB.nuke_list += src
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_icon()
	GLOB.poi_list |= src
	previous_level = get_security_level()

/obj/machinery/nuclearbomb/Destroy()
	safety = FALSE
	if(!exploding)
		// If we're not exploding, set the alert level back to normal
		set_safety()
	GLOB.poi_list -= src
	GLOB.nuke_list -= src
	QDEL_NULL(countdown)
	QDEL_NULL(core)
	. = ..()

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(exploding)
		to_chat(user, "Właśnie wybucha. Może warto uporządkować swoje sprawy.")
	if(timing)
		to_chat(user, "Do detonacji pozostało [get_time_left()] s.")

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = TRUE //stops it being moved

/obj/machinery/nuclearbomb/syndicate
	// actually the nuke op bomb is a stole nt bomb

/obj/machinery/nuclearbomb/syndicate/get_cinematic_type(off_station)
	var/datum/game_mode/nuclear/NM = SSticker.mode
	switch(off_station)
		if(0)
			if(istype(NM) && !NM.nuke_team.syndies_escaped())
				return CINEMATIC_ANNIHILATION
			else
				return CINEMATIC_NUKE_WIN
		if(1)
			return CINEMATIC_NUKE_MISS
		if(2)
			return CINEMATIC_NUKE_FAR
	return CINEMATIC_NUKE_FAR

/obj/machinery/nuclearbomb/proc/disk_check(obj/item/disk/nuclear/D)
	if(D.fake)
		say("Błąd uwierzytelniania; nie rozpoznano dysku.")
		return FALSE
	else
		return TRUE

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/disk/nuclear))
		if(!disk_check(I))
			return
		if(!user.transferItemToLoc(I, src))
			return
		auth = I
		update_ui_mode()
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		add_fingerprint(user)
		ui_update()
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/screwdriver/nuke))
				to_chat(user, "<span class='notice'>Zaczynasz odkręcać śruby przedniego panelu [src]...</span>")
				if(I.use_tool(src, user, 60, volume=100))
					deconstruction_state = NUKESTATE_UNSCREWED
					to_chat(user, "<span class='notice'>Odkręcasz śruby przedniego panelu [src].</span>")
					update_icon()
				return

		if(NUKESTATE_PANEL_REMOVED)
			if(I.tool_behaviour == TOOL_WELDER)
				if(!I.tool_start_check(user, amount=1))
					return
				to_chat(user, "<span class='notice'>Zaczynasz przecinać wewnętrzną płytę [src]...</span>")
				if(I.use_tool(src, user, 80, volume=100, amount=1))
					to_chat(user, "<span class='notice'>Przecinasz wewnętrzną płytę [src].</span>")
					deconstruction_state = NUKESTATE_WELDED
					update_icon()
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				to_chat(user, "<span class='notice'>Zaczynasz ładować rdzeń plutonowy do [core_box]...</span>")
				if(do_after(user,50,target=src))
					if(core_box.load(core, user))
						to_chat(user, "<span class='notice'>Ładujesz rdzeń plutonowy do [core_box].</span>")
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_icon()
						core = null
					else
						to_chat(user, "<span class='warning'>Nie udaje ci się załadować rdzenia plutonowego do [core_box]. [core_box] był już użyty!</span>")
				return
			if(istype(I, /obj/item/stack/sheet/iron))
				if(!I.tool_start_check(user, amount=20))
					return

				to_chat(user, "<span class='notice'>Zaczynasz naprawiać wewnętrzną metalową płytę [src]...</span>")
				if(I.use_tool(src, user, 100, amount=20))
					to_chat(user, "<span class='notice'>Naprawiasz wewnętrzną metalową płytę [src]. Promieniowanie zostało powstrzymane.</span>")
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					STOP_PROCESSING(SSobj, core)
					update_icon()
				return
	. = ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			to_chat(user, "<span class='notice'>Zaczynasz zdejmować przedni panel [src]...</span>")
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, "<span class='notice'>Zdejmujesz przedni panel [src].</span>")
				deconstruction_state = NUKESTATE_PANEL_REMOVED
				update_icon()
			return TRUE
		if(NUKESTATE_WELDED)
			to_chat(user, "<span class='notice'>Zaczynasz podważać wewnętrzną płytę [src]...</span>")
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, "<span class='notice'>Podważasz wewnętrzną płytę [src]. Widzisz zieloną poświatę rdzenia!</span>")
				deconstruction_state = NUKESTATE_CORE_EXPOSED
				update_icon()
				START_PROCESSING(SSobj, core)
			return TRUE

/obj/machinery/nuclearbomb/can_interact(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/ui_state(mob/user)
	if(HAS_TRAIT(user, TRAIT_CAN_USE_NUKE))
		return GLOB.conscious_state
	return ..()

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(exploding)
		return NUKE_ON_EXPLODING
	if(timing)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "nuclearbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "nuclearbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "nuclearbomb_exploding"
	else
		icon_state = "nuclearbomb_base"
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/proc/update_icon_interior()
	cut_overlay(interior)
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			interior = "panel-unscrewed"
		if(NUKESTATE_PANEL_REMOVED)
			interior = "panel-removed"
		if(NUKESTATE_WELDED)
			interior = "plate-welded"
		if(NUKESTATE_CORE_EXPOSED)
			interior = "plate-removed"
		if(NUKESTATE_CORE_REMOVED)
			interior = "core-removed"
		if(NUKESTATE_INTACT)
			return
	add_overlay(interior)

/obj/machinery/nuclearbomb/proc/update_icon_lights()
	if(lights)
		cut_overlay(lights)
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = ""
			return
		if(NUKE_OFF_UNLOCKED)
			lights = "lights-safety"
		if(NUKE_ON_TIMING)
			lights = "lights-timing"
		if(NUKE_ON_EXPLODING)
			lights = "lights-exploding"
	add_overlay(lights)

/obj/machinery/nuclearbomb/process()
	if(timing && !exploding)
		if(detonation_timer < world.time)
			explode()
		else
			var/volume = (get_time_left() <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, FALSE)

/obj/machinery/nuclearbomb/proc/update_ui_mode()
	if(exploded)
		ui_mode = NUKEUI_EXPLODED
		return

	if(!auth)
		ui_mode = NUKEUI_AWAIT_DISK
		return

	if(timing)
		ui_mode = NUKEUI_TIMING
		return

	if(!safety)
		ui_mode = NUKEUI_AWAIT_ARM
		return

	if(!yes_code)
		ui_mode = NUKEUI_AWAIT_CODE
		return

	ui_mode = NUKEUI_AWAIT_TIMER

/obj/machinery/nuclearbomb/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(timing)
		. = TRUE // Autoupdate while counting down

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui=null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb")
		ui.open()

/obj/machinery/nuclearbomb/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth

	var/hidden_code = (ui_mode == NUKEUI_AWAIT_CODE && numeric_input != "ERROR")

	var/current_code = ""
	if(hidden_code)
		while(length(current_code) < length(numeric_input))
			current_code = "[current_code]*"
	else
		current_code = numeric_input
	while(length(current_code) < 5)
		current_code = "[current_code]-"

	var/first_status
	var/second_status
	switch(ui_mode)
		if(NUKEUI_AWAIT_DISK)
			first_status = "URZĄDZENIE ZABLOKOWANE"
			if(timing)
				second_status = "CZAS: [get_time_left()]"
			else
				second_status = "OCZEKUJĘ NA DYSK"
		if(NUKEUI_AWAIT_CODE)
			first_status = "WPROWADŹ KOD"
			second_status = "KOD: [current_code]"
		if(NUKEUI_AWAIT_TIMER)
			first_status = "WPROWADŹ CZAS"
			second_status = "CZAS: [current_code]"
		if(NUKEUI_AWAIT_ARM)
			first_status = "URZĄDZENIE GOTOWE"
			second_status = "CZAS: [get_time_left()]"
		if(NUKEUI_TIMING)
			first_status = "URZĄDZENIE UZBROJONE"
			second_status = "CZAS: [get_time_left()]"
		if(NUKEUI_EXPLODED)
			first_status = "URZĄDZENIE ROZSTAWIONE"
			second_status = "DZIĘKUJĘ"

	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	if(..())
		return
	playsound(src, "terminal_type", 20, FALSE)
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
					playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					auth = I
					. = TRUE
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("C")
						if(auth && ui_mode == NUKEUI_AWAIT_ARM)
							set_safety()
							yes_code = FALSE
							playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
						else
							playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
						numeric_input = ""
						. = TRUE
					if("E")
						switch(ui_mode)
							if(NUKEUI_AWAIT_CODE)
								if(numeric_input == r_code)
									numeric_input = ""
									yes_code = TRUE
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									. = TRUE
								else
									playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
									numeric_input = "ERROR"
							if(NUKEUI_AWAIT_TIMER)
								var/number_value = text2num(numeric_input)
								if(number_value)
									timer_set = clamp(number_value, minimum_timer_set, maximum_timer_set)
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									set_safety()
									. = TRUE
							else
								playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
					if("0","1","2","3","4","5","6","7","8","9")
						if(numeric_input != "ERROR")
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							else
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
							. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("arm")
			if(auth && yes_code && !safety && !exploded)
				if(!COOLDOWN_FINISHED(src, arm_cooldown))
					return
				playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
				set_active()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("anchor")
			if(auth && yes_code)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				set_anchor()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)

	if(.)
		update_ui_mode()

/obj/machinery/nuclearbomb/proc/set_anchor()
	if(isinspace() && !anchored)
		to_chat(usr, "<span class='warning'>Nie ma się do czego przymocować!</span>")
	else
		anchored = !anchored

/obj/machinery/nuclearbomb/proc/set_safety()
	safety = !safety
	if(safety)
		if(timing)
			set_security_level(previous_level)
			stop_soundtrack_music()
			for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
				S.switch_mode_to(initial(S.mode))
				S.alert = FALSE
		timing = FALSE
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/proc/set_active()
	if(safety)
		to_chat(usr, "<span class='danger'>Bezpiecznik jest wciąż włączony.</span>")
		return
	timing = !timing
	if(timing)
		previous_level = get_security_level()
		detonation_timer = world.time + (timer_set * 10)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(TRACK_INFILTRATOR)
		countdown.start()
		set_security_level(SEC_LEVEL_DELTA)

		if (proper_bomb) // Why does this exist
			countdown_music = play_soundtrack_music(/datum/soundtrack_song/bee/countdown, only_station = TRUE)

	else
		detonation_timer = null
		set_security_level(previous_level)
		stop_soundtrack_music()

		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(initial(S.mode))
			S.alert = FALSE
		countdown.stop()
	COOLDOWN_START(src, arm_cooldown, ARM_ACTION_COOLDOWN)
	update_icon()

/obj/machinery/nuclearbomb/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(exploding)
		return
	qdel(src)

/obj/machinery/nuclearbomb/tesla_act(power, tesla_flags)
	..()
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 127
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_icon()
	if(proper_bomb)
		sound_to_playing_players('sound/machines/alarm.ogg')
	if(SSticker?.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, PROC_REF(actually_explode)), 100)

/obj/machinery/nuclearbomb/proc/actually_explode()
	if(!core)
		Cinematic(CINEMATIC_NUKE_NO_CORE,world)
		SSticker.roundend_check_paused = FALSE
		return

	GLOB.enter_allowed = FALSE

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	var/area/A = get_area(bomb_location)

	if(bomb_location && is_station_level(bomb_location.z))
		if(istype(A, /area/space))
			off_station = NUKE_NEAR_MISS
		if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = NUKE_NEAR_MISS
	else if(bomb_location.onSyndieBase())
		off_station = NUKE_SYNDICATE_BASE
	else
		off_station = NUKE_MISS_STATION

	if(off_station < 2)
		SSshuttle.registerHostileEnvironment(src)
		SSshuttle.lockdown = TRUE

	//Cinematic
	SSticker.mode.OnNukeExplosion(off_station)
	really_actually_explode(off_station)
	SSticker.roundend_check_paused = FALSE

/obj/machinery/nuclearbomb/proc/really_actually_explode(off_station)
	Cinematic(get_cinematic_type(off_station),world,CALLBACK(SSticker, TYPE_PROC_REF(/datum/controller/subsystem/ticker, station_explosion_detonation),src))
	INVOKE_ASYNC(GLOBAL_PROC,PROC_REF(KillEveryoneOnZLevel), get_virtual_z_level())

/obj/machinery/nuclearbomb/proc/get_cinematic_type(off_station)
	if(off_station < 2)
		return CINEMATIC_SELFDESTRUCT
	else
		return CINEMATIC_SELFDESTRUCT_MISS

/obj/machinery/nuclearbomb/beer
	name = "\improper Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	var/obj/structure/reagent_dispensers/beerkeg/keg

/obj/machinery/nuclearbomb/beer/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)

/obj/machinery/nuclearbomb/beer/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		to_chat(user, "<span class='notice'>Zostało [keg.reagents.total_volume] jedn.</span>")
	else
		to_chat(user, "<span class='danger'>Jest pusty.</span>")

/obj/machinery/nuclearbomb/beer/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		W.afterattack(keg, user, TRUE) 	// redirect refillable containers to the keg, allowing them to be filled
		return TRUE 										// pretend we handled the attack, too.
	if(istype(W, /obj/item/nuke_core_container))
		to_chat(user, "<span class='notice'>[src] ma usunięty rdzeń plutonowy w ramach wycofania ze służby.</span>")
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm()
		return
	if(is_station_level(bomb_location.z))
		var/datum/round_event_control/beer_clog/beer_event = new()
		beer_event.runEvent()
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 110)
	else
		visible_message("<span class='notice'>[src] złowieszczo syczy.</span>")
		addtimer(CALLBACK(src, PROC_REF(fizzbuzz)), 110)

/obj/machinery/nuclearbomb/beer/proc/disarm()
	detonation_timer = null
	exploding = FALSE
	exploded = TRUE
	set_security_level(previous_level)
	for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
		S.switch_mode_to(initial(S.mode))
		S.alert = FALSE
	countdown.stop()
	update_icon()
	update_ui_mode()
	ui_update()

/obj/machinery/nuclearbomb/beer/proc/fizzbuzz()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(200, get_turf(src), R)
	foam.start()
	disarm()

/obj/machinery/nuclearbomb/beer/really_actually_explode()
	disarm()

/proc/KillEveryoneOnZLevel(z)
	if(!z)
		return
	for(var/mob/M in GLOB.mob_list)
		if(M.stat != DEAD && M.get_virtual_z_level() == z)
			M.gib()

/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/set_anchor()
	return

/obj/machinery/nuclearbomb/selfdestruct/set_active()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

/obj/machinery/nuclearbomb/selfdestruct/set_safety()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

//==========DAT FUKKEN DISK===============
/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound =  'sound/items/handling/disk_pickup.ogg'

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	persistence_replacement = /obj/item/disk/nuclear/fake
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/fake = FALSE
	var/turf/lastlocation
	var/last_disk_move
	var/process_tick = 0
	investigate_flags = ADMIN_INVESTIGATE_TARGET
	COOLDOWN_DECLARE(weight_increase_cooldown)

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 6, -6, 0)
	if(!fake)
		GLOB.poi_list |= src
		last_disk_move = world.time
		START_PROCESSING(SSobj, src)

/obj/item/disk/nuclear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, !fake)
	if(!fake)
		//Global teamfinder signal trackable on the synd frequency.
		AddComponent(/datum/component/tracking_beacon, "synd", null, null, TRUE, "#ebeca1", TRUE, TRUE)

/obj/item/disk/nuclear/process()
	++process_tick
	if(fake)
		STOP_PROCESSING(SSobj, src)
		CRASH("A fake nuke disk tried to call process(). Who the fuck and how the fuck")
	var/turf/newturf = get_turf(src)
	if(newturf && lastlocation == newturf)
		/// How comfy is our disk?
		var/disk_comfort_level = 0

		//Go through and check for items that make disk comfy
		for(var/comfort_item in loc)
			if(istype(comfort_item, /obj/item/bedsheet) || istype(comfort_item, /obj/structure/bed))
				disk_comfort_level++

		if(COOLDOWN_FINISHED(src, weight_increase_cooldown) && last_disk_move < world.time - (5 MINUTES) && world.time > (30 MINUTES))
			var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
			if(istype(loneop) && loneop.occurrences < loneop.max_occurrences)
				loneop.weight += 5
				COOLDOWN_START(src, weight_increase_cooldown, (5 MINUTES))
				message_admins("[src] is stationary in [ADMIN_VERBOSEJMP(newturf)]. The weight of Lone Operative is now [loneop.weight].")
				log_game("[src] is stationary for too long in [loc_name(newturf)], and has increased the weight of the Lone Operative event to [loneop.weight].")
				if(disk_comfort_level >= 2 && (process_tick % 30) == 0)
					visible_message("<span class='notice'>[src] śpi smacznie. Śpij dobrze, dysku.</span>")

	else
		lastlocation = newturf
		last_disk_move = world.time
		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
		if(istype(loneop) && loneop.occurrences < loneop.max_occurrences && prob(loneop.weight))
			loneop.weight = max(loneop.weight - 1, 0)
			if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
				message_admins("[src] is on the move (currently in [ADMIN_VERBOSEJMP(newturf)]). The weight of Lone Operative is now [loneop.weight].")
			log_game("[src] being on the move has reduced the weight of the Lone Operative event to [loneop.weight].")

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || HAS_TRAIT(user.mind, TRAIT_DISK_VERIFIER))
		. += "<span class='warning'>Numery seryjne na [src] są nieprawidłowe.</span>"

/obj/item/disk/nuclear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/H = I
		if(H.nuke_disk)
			to_chat(user, "<span class='notice'>Chwila... co?</span>")
			qdel(H.nuke_disk)
			H.nuke_disk = null
			return
		user.visible_message("<span class='warning'>[user] przejmuje [src]!</span>", "<span class='userdanger'>Masz dysk! Broń go za cenę życia!</span>")
		forceMove(H)
		H.nuke_disk = src
		return TRUE
	return ..()

/obj/item/disk/nuclear/Destroy(force=FALSE)
	// respawning is handled in /obj/Destroy()
	if(force)
		GLOB.poi_list -= src
	. = ..()

/obj/item/disk/nuclear/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] ogłasza deltę! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, add_atom_colour), (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message("<span class='suicide'>Wybuch nuklearny unicestwia [user]!</span>")
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
