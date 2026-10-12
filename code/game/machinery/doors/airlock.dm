/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	id_scan_hacked - Whether the AI has disabled the ID scanner, or the wire has been cut.
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

/// Overlay cache.  Why isn't this just in /obj/machinery/door/airlock?  Because its used just a
/// tiny bit in door_assembly.dm  Refactored so you don't have to make a null copy of airlock
/// to get to the damn thing
/// Someone, for the love of god, profile this.  Is there a reason to cache mutable_appearance
/// if so, why are we JUST doing the airlocks when we can put this in mutable_appearance.dm for
/// everything
/proc/get_airlock_overlay(icon_state, icon_file)
	var/static/list/airlock_overlays = list()
	var/iconkey = "[icon_state][icon_file]"
	if((!(. = airlock_overlays[iconkey])))
		. = airlock_overlays[iconkey] = mutable_appearance(icon_file, icon_state)
// Before you say this is a bad implmentation, look at what it was before then ask yourself
// "Would this be better with a global var"

// Wires for the airlock are located in the datum folder, inside the wires datum folder.

#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_SECURITY_NONE			0 //Normal airlock				//Wires are not secured
#define AIRLOCK_SECURITY_IRON			1 //Medium security airlock		//There is a simple iron over wires (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2 								//Sliced inner plating (use crowbar), jumps to 0
#define AIRLOCK_SECURITY_PLASTEEL_I		3 								//Removed outer plating, second layer here (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4 								//Sliced outer plating (use crowbar)
#define AIRLOCK_SECURITY_PLASTEEL_O		5 								//There is first layer of plasteel (use welder)
#define AIRLOCK_SECURITY_PLASTEEL		6 //Max security airlock		//Fully secured wires (use wirecutters to remove grille, that is electrified)

#define AIRLOCK_INTEGRITY_N			 300 // Normal airlock integrity
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5 // How much reinforced doors health increases
#define AIRLOCK_DAMAGE_DEFLECTION_N  21  // Normal airlock damage deflection
#define AIRLOCK_DAMAGE_DEFLECTION_R  30  // Reinforced airlock damage deflection

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER
	max_integrity = 300
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	secondsElectrified = MACHINE_NOT_ELECTRIFIED //How many seconds remain until the door is no longer electrified. -1/MACHINE_ELECTRIFIED_PERMANENT = permanently electrified until someone fixes it.
	assemblytype = /obj/structure/door_assembly
	normalspeed = 1
	explosion_block = 1
	hud_possible = list(DIAG_AIRLOCK_HUD)
	flags_1 = PREVENT_CLICK_UNDER_1 & HTML_USE_INITAL_ICON_1
	var/allow_repaint = TRUE //Set to FALSE if the airlock should not be allowed to be repainted.

	FASTDMM_PROP(\
		pinned_vars = list("req_access_txt", "req_one_access_txt", "name")\
	)

	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = FALSE // if true, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = FALSE
	var/lights = TRUE // bolt lights show by default
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/closeOtherId //Cyclelinking for airlocks that aren't on the same x or y coord as the target.
	var/obj/machinery/door/airlock/closeOther
	var/justzap = FALSE
	var/obj/item/electronics/airlock/electronics
	COOLDOWN_DECLARE(shockCooldown) //Prevents multiple shocks from happening
	var/obj/item/doorCharge/charge //If applied, causes an explosion upon opening the door
	var/obj/item/note //Any papers pinned to the airlock
	var/detonated = FALSE
	var/abandoned = FALSE
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/airlockclose.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/noPower = 'sound/machines/doorclick.ogg'
	var/previous_airlock = /obj/structure/door_assembly //what airlock assembly mineral plating was applied to
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock
	/* Note mask_file needed some change due to the change from 513 to 514(the behavior of alpha filters seems to have changed) thats the reason why the mask
	dmi file for normal airlocks is not 32x32 but 64x64 and for the large airlocks instead of 64x32 its now 96x64 due to the fix to this problem*/
	var/mask_file = 'icons/obj/doors/airlocks/mask_32x32_airlocks.dmi' // because filters aren't allowed to have icon_states :(
	var/mask_x = 0
	var/mask_y = 0
	var/anim_parts = "left=-14,0;right=13,0" //format is "airlock_part=open_px,open_py,move_start_time,move_end_time,aperture_angle"
	var/list/part_overlays
	var/panel_attachment = "right"
	var/note_attachment = "left"

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0
	var/delayed_close_requested = FALSE // TRUE means the door will automatically close the next time it's opened.

	var/prying_so_hard = FALSE
	var/protected_door = FALSE // Protects the door against any form of power outage, AI control, screwdrivers and welders.
	var/door_animation_speed = 4 //nsv13 if you want a door that snaps open QUICKLY like on turbolifts

	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_MEDIUM_INSULATION

	var/electrification_timing // Set to true while electrified_loop is running, to prevent multiple being started

	var/LEGACY_OVERLAYS = FALSE //NSV13 - I don't know how to do some of these door animations with anim_parts

	network_id = NETWORK_DOOR_AIRLOCKS

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/airlock(src)
	if(frequency)
		set_frequency(frequency)

	if(closeOtherId != null)
		addtimer(CALLBACK(PROC_REF(update_other_id)), 5)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_IRON)
		obj_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		obj_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_IRON)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_electrified()

	rebuild_parts()

	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, PROC_REF(ntnet_receive))
	RegisterSignal(src, COMSIG_MACHINERY_BROKEN, PROC_REF(on_break))

	// Click on the floor to close airlocks
	var/static/list/connections = list(
		COMSIG_ATOM_ATTACK_HAND = PROC_REF(on_attack_hand)
	)
	AddElement(/datum/element/connect_loc, src, connections)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/LateInitialize()
	. = ..()
	if (cyclelinkeddir)
		cyclelinkairlock()
	if(abandoned)
		var/outcome = rand(1,100)
		switch(outcome)
			if(1 to 5)
				var/turf/here = get_turf(src)
				for(var/turf/closed/T in spiral_range_turfs(2, here))
					here.PlaceOnTop(T.type)
					qdel(src)
					return
				here.PlaceOnTop(/turf/closed/wall)
				qdel(src)
				return
			if(5 to 6)
				lights = FALSE
				locked = TRUE
			if(6 to 8)
				locked = TRUE
			if(8 to 10)
				welded = TRUE
			if(10 to 30)
				panel_open = TRUE
	update_icon()


/obj/machinery/door/airlock/proc/rebuild_parts()
	if(part_overlays)
		vis_contents -= part_overlays
		QDEL_LIST(part_overlays)
	else
		part_overlays = list()
	var/list/parts_desc = params2list(anim_parts)
	var/list/door_time = list()
	for(var/part_id in parts_desc)
		var/obj/effect/overlay/airlock_part/P = new
		P.side_id = part_id
		var/list/open_offset = splittext(parts_desc[part_id], ",")
		P.open_px = text2num(open_offset[1])
		P.open_py = text2num(open_offset[2])
		if(open_offset.len >= 3)
			P.move_start_time = text2num(open_offset[3])
		if(open_offset.len >= 4)
			P.move_end_time = text2num(open_offset[4])
		if(open_offset.len >= 5)
			P.aperture_angle = text2num(open_offset[5])
		vis_contents += P
		part_overlays += P
		P.icon = icon
		P.icon_state = part_id
		P.name = name
		door_time += P.move_end_time
	open_speed = max(door_time) //open_speed is max animation time
	add_filter("mask_filter", 1, list(type="alpha",icon=mask_file,x=mask_x,y=mask_y))

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.closeOtherId == closeOtherId && A != src)
			closeOther = A
			break

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	var/limit = 15
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		log_mapping("[src] at [AREACOORD(src)] failed to find a valid airlock to cyclelink with!")
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/vv_edit_var(var_name, vval)
	. = ..()
	switch (var_name)
		if (NAMEOF(src, cyclelinkeddir))
			cyclelinkairlock()
		if (NAMEOF(src, secondsElectrified))
			set_electrified(vval < MACHINE_NOT_ELECTRIFIED ? MACHINE_ELECTRIFIED_PERMANENT : vval) //negative values are bad mkay (unless they're the intended negative value!)

/obj/machinery/door/airlock/check_access_ntnet(datum/netdata/data)
	// Cutting WIRE_IDSCAN grants remote access
	return id_scan_hacked() || ..()

/obj/machinery/door/airlock/proc/ntnet_receive(datum/source, datum/netdata/data)
	// Check if the airlock is powered and can accept control packets.
	if(!hasPower() || !canAIControl())
		return

	//Check radio signal jamming
	if(is_jammed())
		return


	// Handle received packet.
	var/command = data.data["data"]
	var/command_value = data.data["data_secondary"]
	switch(command)
		if("open")
			if(command_value == "on" && !density)
				return

			if(command_value == "off" && density)
				return

			if(density)
				INVOKE_ASYNC(src, PROC_REF(open))
			else
				INVOKE_ASYNC(src, PROC_REF(close))

		if("bolt")
			if(command_value == "on" && locked)
				return

			if(command_value == "off" && !locked)
				return

			if(locked)
				unbolt()
			else
				bolt()

		if("emergency")
			if(command_value == "on" && emergency)
				return

			if(command_value == "off" && !emergency)
				return

			emergency = !emergency
			update_icon()

/obj/machinery/door/airlock/lock()
	bolt()

/obj/machinery/door/airlock/proc/bolt()
	if(locked || protected_door)
		return
	set_bolt(TRUE)
	playsound(src, boltDown, 30, 0, 3)
	audible_message("<span class='italics'>Słyszysz kliknięcie z dołu drzwi.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/proc/set_bolt(should_bolt)
	if(locked == should_bolt)
		return
	SEND_SIGNAL(src, COMSIG_AIRLOCK_SET_BOLT, should_bolt)
	ui_update()
	. = locked
	locked = should_bolt

/obj/machinery/door/airlock/unlock()
	unbolt()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	set_bolt(FALSE)
	playsound(src,boltUp,30,0,3)
	audible_message("<span class='italics'>Słyszysz kliknięcie z dołu drzwi.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/cult/A
	if(GLOB.cult_narsie)
		var/runed = prob(20)
		if(glass)
			if(runed)
				A = new/obj/machinery/door/airlock/cult/glass(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned/glass(T)
		else
			if(runed)
				A = new/obj/machinery/door/airlock/cult(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned(T)
		A.name = name
	else
		A = new /obj/machinery/door/airlock/cult/weak(T)
	qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	var/obj/machinery/door/airlock/clockwork/A
	if(glass)
		A = new/obj/machinery/door/airlock/clockwork/glass(get_turf(src))
	else
		A = new/obj/machinery/door/airlock/clockwork(get_turf(src))
	A.name = name
	qdel(src)

/obj/machinery/door/airlock/eminence_act(mob/living/simple_animal/eminence/eminence)
	..()
	to_chat(usr, "<span class='brass'>Zaczynasz majstrować przy [src]!</span>")
	if(do_after(eminence, 20, target=get_turf(eminence)))
		if(welded)
			to_chat(eminence, text("Śluza została zaspawana!"))
		else if(locked)
			to_chat(eminence, text("Rygle drzwi są opuszczone!"))
		else if(!density)
			close()
		else
			open()

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	if(charge)
		qdel(charge)
		charge = null
	QDEL_NULL(electronics)
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if(id_tag)
		for(var/obj/machinery/doorButtons/D in GLOB.machines)
			D.removeMe(src)
	qdel(note)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_icon()

/obj/machinery/door/airlock/Bumped(atom/movable/AM)
	if(operating || (obj_flags & EMAGGED))
		return
	if(ismecha(AM))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant)
				if(world.time - mecha.occupant.last_bumped <= 10)
					return
				mecha.occupant.last_bumped = world.time
			if(locked && (allowed(mecha.occupant) || check_access_list(mecha.operation_req_access)) && aac)
				aac.request_from_door(src)
				return
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
				open()
			else
				do_animate("deny")
		return
	. = ..()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(isElectrified() && shock(user, 100))
			return
		else if(user.hallucinating() && iscarbon(user) && prob(1) && !operating)
			var/mob/living/carbon/C = user
			if(!C.wearing_shock_proof_gloves())
				new /datum/hallucination/shock(C)
				return
	if(SEND_SIGNAL(src, COMSIG_AIRLOCK_TOUCHED, user) & COMPONENT_PREVENT_OPEN)
		return
	if (cyclelinkedairlock)
		if (!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency && allowed(user))
			if(cyclelinkedairlock.operating)
				cyclelinkedairlock.delayed_close_requested = TRUE
			else
				addtimer(CALLBACK(cyclelinkedairlock, PROC_REF(close)), 2)
	if(locked && allowed(user) && aac)
		aac.request_from_door(src)
		return
	..()

/obj/machinery/door/airlock/proc/isElectrified()
	return (secondsElectrified != MACHINE_NOT_ELECTRIFIED)

/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	if(protected_door)
		return FALSE
	if(is_jammed())
		return FALSE
	return ((aiControlDisabled != 1) && !isAllPowerCut())

/obj/machinery/door/airlock/proc/canAIHack()
	if(protected_door)
		return FALSE
	if(is_jammed())
		return FALSE
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	if(protected_door)
		return TRUE
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(machine_stat & NOPOWER))

/obj/machinery/door/airlock/id_scan_hacked()
	return wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if(protected_door)
		return FALSE
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(secondsMainPowerLost > 0)
		secondsMainPowerLost = 0
	update_icon()

/obj/machinery/door/airlock/proc/handlePowerRestore()
	var/cont = TRUE
	while (cont)
		sleep(10)
		if(QDELETED(src))
			return
		cont = FALSE
		if(secondsMainPowerLost>0)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				secondsMainPowerLost -= 1
			cont = TRUE
		if(secondsBackupPowerLost>0)
			if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
				secondsBackupPowerLost -= 1
			cont = TRUE
	spawnPowerRestoreRunning = FALSE
	ui_update()
	update_icon()

/obj/machinery/door/airlock/proc/loseMainPower()
	if(secondsMainPowerLost <= 0)
		secondsMainPowerLost = 60
		if(secondsBackupPowerLost < 10)
			secondsBackupPowerLost = 10
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, PROC_REF(handlePowerRestore))
	update_icon()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(secondsBackupPowerLost < 60)
		secondsBackupPowerLost = 60
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, PROC_REF(handlePowerRestore))
	update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(secondsBackupPowerLost > 0)
		secondsBackupPowerLost = 0
	update_icon()

// shock user with probability prb (if all connections & power are working)
// returns TRUE if shocked, FALSE otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return FALSE
	if(!COOLDOWN_FINISHED(src, shockCooldown))
		return FALSE	//Already shocked someone recently?
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 1, check_range))
		COOLDOWN_START(src, shockCooldown, 1 SECONDS)
		return TRUE
	else
		return FALSE

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	cut_overlays() // Needed without it you get like 300 unres indicator overlayers over time
	if(operating && !override)
		return
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS
	if(LEGACY_OVERLAYS) //NSV13 - I don't know how to do some of these animations with anim_parts
		legacy_set_airlock_overlays(state)
	else
		set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_side_overlays(obj/effect/overlay/airlock_part/base, show_lights = FALSE)
	var/side = base.side_id
	base.icon = icon
	base.cut_overlays()
	if(airlock_material)
		base.add_overlay(get_airlock_overlay("[airlock_material]_[side]", overlays_file))
	else
		base.add_overlay(get_airlock_overlay("fill_[side]", icon))
	if(panel_open && panel_attachment == side)
		if(security_level)
			base.add_overlay(get_airlock_overlay("panel_closed_protected", overlays_file))
		else
			base.add_overlay(get_airlock_overlay("panel_closed", overlays_file))
	if(show_lights && lights && hasPower())
		base.add_overlay(get_airlock_overlay("lights_[side]", overlays_file))

	if(note && note_attachment == side)
		var/notetype = note_type()
		base.add_overlay(get_airlock_overlay(notetype, note_overlay_file))

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	for(var/obj/effect/overlay/airlock_part/part as() in part_overlays)
		set_side_overlays(part, state == AIRLOCK_CLOSING || state == AIRLOCK_OPENING)
		if(part.aperture_angle)
			var/matrix/T
			if(state == AIRLOCK_OPEN || state == AIRLOCK_OPENING || state == AIRLOCK_CLOSING)
				T = matrix()
				T.Translate(-part.open_px,-part.open_py)
				T.Turn(part.aperture_angle)
				T.Translate(part.open_px,part.open_py)
			switch(state)
				if(AIRLOCK_CLOSED, AIRLOCK_DENY, AIRLOCK_EMAG)
					part.transform = matrix()
				if(AIRLOCK_OPEN)
					part.transform = T
				if(AIRLOCK_CLOSING)
					part.transform = T
					animate(part, transform = T, time = open_speed - part.move_end_time, flags = ANIMATION_LINEAR_TRANSFORM)
					animate(transform = matrix(), time = part.move_end_time - part.move_start_time, flags = ANIMATION_LINEAR_TRANSFORM)
				if(AIRLOCK_OPENING)
					part.transform = matrix()
					animate(part, transform = matrix(), time = part.move_start_time, flags = ANIMATION_LINEAR_TRANSFORM)
					animate(transform = T, time = part.move_end_time - part.move_start_time, flags = ANIMATION_LINEAR_TRANSFORM)
		else
			switch(state)
				if(AIRLOCK_CLOSED, AIRLOCK_DENY, AIRLOCK_EMAG)
					part.pixel_x = 0
					part.pixel_y = 0
				if(AIRLOCK_OPEN)
					part.pixel_x = part.open_px
					part.pixel_y = part.open_py
				if(AIRLOCK_CLOSING)
					part.pixel_x = part.open_px
					part.pixel_y = part.open_py
					animate(part, pixel_x = part.open_px, pixel_y = part.open_py, time = open_speed - part.move_end_time)
					animate(pixel_x = 0, pixel_y = 0, time = part.move_end_time - part.move_start_time)
				if(AIRLOCK_OPENING)
					part.pixel_x = 0
					part.pixel_y = 0
					animate(part, pixel_x = 0, pixel_y = 0, time = part.move_start_time)
					animate(pixel_x = part.open_px, pixel_y = part.open_py, time = part.move_end_time - part.move_start_time)

	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

	SSvis_overlays.add_vis_overlay(src, overlays_file, "frame", FLOAT_LAYER, FLOAT_PLANE, dir)

	switch(state)
		if(AIRLOCK_CLOSED)
			if(lights && hasPower())
				if(locked)
					SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_bolts", FLOAT_LAYER, FLOAT_PLANE, dir)
				else if(emergency)
					SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_emergency", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(obj_integrity <integrity_failure)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(obj_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_denied", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(obj_integrity <integrity_failure)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(obj_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_EMAG)
			if(welded)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "welded", FLOAT_LAYER, FLOAT_PLANE, dir)
			SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks", FLOAT_LAYER, FLOAT_PLANE, dir)
			if(obj_integrity <integrity_failure)
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_broken", FLOAT_LAYER, FLOAT_PLANE, dir)
			else if(obj_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_damaged", FLOAT_LAYER, FLOAT_PLANE, dir)
		if(AIRLOCK_CLOSING)
			if(lights && hasPower())
				SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_closing", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_OPEN)
			if(obj_integrity < (0.75 * max_integrity))
				SSvis_overlays.add_vis_overlay(src, overlays_file, "sparks_open", FLOAT_LAYER, FLOAT_PLANE, dir)

		if(AIRLOCK_OPENING)
			if(lights && hasPower())
				SSvis_overlays.add_vis_overlay(src, overlays_file, "lights_opening", FLOAT_LAYER, FLOAT_PLANE, dir)
	check_unres()


/obj/machinery/door/airlock/proc/check_unres() //unrestricted sides. This overlay indicates which directions the player can access even without an ID
	if(hasPower() && unres_sides)
		if(unres_sides & NORTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_n")
			I.appearance_flags |= KEEP_APART
			I.pixel_y = 32
			set_light(l_range = 2, l_power = 1)
			add_overlay(I)
		if(unres_sides & SOUTH)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_s")
			I.appearance_flags |= KEEP_APART
			I.pixel_y = -32
			set_light(l_range = 2, l_power = 1)
			add_overlay(I)
		if(unres_sides & EAST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_e")
			I.appearance_flags |= KEEP_APART
			I.pixel_x = 32
			set_light(l_range = 2, l_power = 1)
			add_overlay(I)
		if(unres_sides & WEST)
			var/image/I = image(icon='icons/obj/doors/airlocks/station/overlays.dmi', icon_state="unres_w")
			I.appearance_flags |= KEEP_APART
			I.pixel_x = -32
			set_light(l_range = 2, l_power = 1)
			add_overlay(I)
	else
		set_light(0)

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!machine_stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += "<span class='warning'>Panel dostępu lekko dymi.</span>"
	if(charge && !panel_open && in_range(user, src))
		. += "<span class='warning'>Panel serwisowy wygląda na niedbale przykręcony.</span>"
	if(charge && panel_open)
		. += "<span class='warning'>Coś jest podłączone do elektroniki śluzy!</span>"
	if(note)
		if(!in_range(user, src))
			. += "Z przodu przypięto [note.name]. Stąd nie da się tego przeczytać."
		else
			. += "Z przodu przypięto [note.name]..."
			. += note.examine(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				. += "Przewody są odsłonięte!"
			if(AIRLOCK_SECURITY_IRON)
				. += "Przewody są ukryte za przyspawaną metalową osłoną."
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				. += "W środku jest trochę poszarpanej plastali."
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				. += "Przewody są za wewnętrzną warstwą plastali."
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				. += "W środku jest trochę poszarpanej plastali."
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				. += "Przewody zasłania przyspawana osłona z plastali."
			if(AIRLOCK_SECURITY_PLASTEEL)
				. += "Na panelu jest ochronna krata."
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_IRON)
			. += "Wygląda na nieco wzmocnioną."
		else
			. += "Wygląda na bardzo solidną."

	if(issilicon(user) && !(machine_stat & BROKEN))
		. += "<span class='notice'>Shift-kliknij [src], by [ density ? "otworzyć" : "zamknąć"].</span>"
		. += "<span class='notice'>Ctrl-kliknij [src], by [ locked ? "podnieść" : "opuścić"] rygle.</span>"
		. += "<span class='notice'>Alt-kliknij [src], by [ secondsElectrified ? "wyłączyć elektryfikację" : "trwale zelektryfikować"].</span>"
		. += "<span class='notice'>Ctrl-Shift-kliknij [src], by [ emergency ? "wyłączyć" : "włączyć"] dostęp awaryjny.</span>"

/obj/machinery/door/airlock/attack_ai(mob/user)
	if(!canAIControl(user))
		if(canAIHack())
			hack(user)
			return
		else
			to_chat(user, "<span class='warning'>Sterowanie śluzą przez SI zostało zablokowane zaporą. Nie można zhakować.</span>")
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Nie można połączyć: śluza nie reaguje.</span>")
		return
	if(detonated)
		to_chat(user, "<span class='warning'>Nie można połączyć. Panel sterowania śluzy uszkodzony.</span>")
		return
	if(is_jammed())
		to_chat(user, "<span class='warning'>Nie można połączyć. Komunikacja zdalna nie odpowiada.</span>")
		return

	ui_interact(user)

/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Sterowanie śluzą przez SI zostało zablokowane. Rozpoczynanie wykrywania usterek.")
		sleep(50)
		if(canAIControl(user))
			to_chat(user, "Alarm odwołany. Sterowanie śluzą zostało przywrócone bez naszej pomocy.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Utracono połączenie! Nie można zhakować śluzy.")
			aiHacking = FALSE
			return
		to_chat(user, "Usterka potwierdzona: przewód sterujący śluzy wyłączony lub przecięty.")
		sleep(20)
		to_chat(user, "Próba zhakowania śluzy. Może to chwilę potrwać.")
		sleep(200)
		if(canAIControl(user))
			to_chat(user, "Alarm odwołany. Sterowanie śluzą zostało przywrócone bez naszej pomocy.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Utracono połączenie! Nie można zhakować śluzy.")
			aiHacking = FALSE
			return
		to_chat(user, "Potwierdzono dostęp do wgrywania. Wgrywanie programu sterującego do oprogramowania śluzy.")
		sleep(170)
		if(canAIControl(user))
			to_chat(user, "Alarm odwołany. Sterowanie śluzą zostało przywrócone bez naszej pomocy.")
			aiHacking = FALSE
			return
		else if(!canAIHack())
			to_chat(user, "Utracono połączenie! Nie można zhakować śluzy.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer zakończony. Wymuszanie wykonania programu przez śluzę.")
		sleep(50)
		//disable blocked control
		aiControlDisabled = 2
		to_chat(user, "Odbieranie informacji sterujących ze śluzy.")
		sleep(10)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			attack_ai(user)

/obj/machinery/door/airlock/attack_animal(mob/user)
	if(isElectrified() && shock(user, 100))
		return
	return ..()

/obj/machinery/door/airlock/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/door/airlock/proc/on_attack_hand(atom/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, /atom/proc/attack_hand, user, modifiers)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/door/airlock/attack_hand(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_AIRLOCK_TOUCHED, user) & COMPONENT_PREVENT_OPEN)
		. = TRUE
	else if(locked && allowed(user) && aac)
		aac.request_from_door(src)
		. = TRUE
	else
		. = ..()
	if(.)
		return
	if(!(issilicon(user) || IsAdminGhost(user)))
		if(isElectrified() && shock(user, 100))
			return

	if(ishuman(user) && prob(40) && density)
		var/mob/living/carbon/human/H = user
		if((HAS_TRAIT(H, TRAIT_DUMB)) && Adjacent(user))
			playsound(src, 'sound/effects/bang.ogg', 25, TRUE)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.visible_message("<span class='danger'>[user] uderza głową w śluzę.</span>", \
									"<span class='userdanger'>Uderzasz głową w śluzę!</span>")
				H.Paralyze(100)
				H.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
			else
				visible_message("<span class='danger'>[user] uderza głową w śluzę. Dobrze, że ma hełm.</span>")

/obj/machinery/door/airlock/attempt_wire_interaction(mob/user)
	if(security_level)
		to_chat(user, "<span class='warning'>Przewody są zabezpieczone!</span>")
		return WIRE_INTERACTION_FAIL
	return ..()

/obj/machinery/door/airlock/proc/electrified_loop()
	if(electrification_timing)
		return // Don't start another timer if one is already running

	electrification_timing = TRUE
	while (secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		secondsElectrified--

		sleep(10)
		if(QDELETED(src))
			return
	electrification_timing = FALSE

	// This is to protect against changing to permanent, mid loop.
	if(secondsElectrified == MACHINE_NOT_ELECTRIFIED)
		set_electrified(MACHINE_NOT_ELECTRIFIED)
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)
	ui_update()

//This code might be completely unused, but I'm too afraid to touch it.
//That said, commenting it out didn't seem to break anything.
/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(!usr.canUseTopic(src) && !IsAdminGhost(usr))
		return
	add_fingerprint(usr)

	if((in_range(src, usr) && isturf(loc)) && panel_open)
		usr.set_machine(src)

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()
	else
		updateDialog()

/obj/machinery/door/airlock/screwdriver_act(mob/living/user, obj/item/tool)
	if((panel_open && detonated) || protected_door)
		to_chat(user, span_warning("[src] has no maintenance panel!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of the airlock."))
	tool.play_tool_sound(src)
	update_icon()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open && security_level == AIRLOCK_SECURITY_PLASTEEL)
		. = TOOL_ACT_TOOLTYPE_SUCCESS  // everything after this shouldn't result in attackby
		if(hasPower() && shock(user, 60)) // Protective grille of wiring is electrified
			return .
		to_chat(user, span_notice("You start cutting through the outer grille."))
		if(!tool.use_tool(src, user, 10, volume=100))
			return .
		if(!panel_open)  // double check it wasn't closed while we were trying to snip
			return .
		user.visible_message(span_notice("[user] cut through [src]'s outer grille."),
							span_notice("You cut through [src]'s outer grille."))
		security_level = AIRLOCK_SECURITY_PLASTEEL_O
		return .
	if(note)
		if(user.CanReach(src))
			user.visible_message(span_notice("[user] cuts down [note] from [src]."), span_notice("You remove [note] from [src]."))
		else //telekinesis
			visible_message(span_notice("[tool] cuts down [note] from [src]."))
		tool.play_tool_sound(src)
		note.forceMove(tool.drop_location())
		note = null
		update_icon()
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/crowbar_act(mob/living/user, obj/item/tool)

	if(!panel_open || security_level == AIRLOCK_SECURITY_NONE)
		return ..()

	var/layer_flavor
	var/next_level
	var/starting_level = security_level

	switch(security_level)
		if(AIRLOCK_SECURITY_PLASTEEL_O_S)
			layer_flavor = "outer layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_I

		if(AIRLOCK_SECURITY_PLASTEEL_I_S)
			layer_flavor = "inner layer of shielding"
			next_level = AIRLOCK_SECURITY_NONE
		else
			return TOOL_ACT_TOOLTYPE_SUCCESS

	user.visible_message(span_notice("You start prying away [src]'s [layer_flavor]."))
	if(!tool.use_tool(src, user, 40, volume=100))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!panel_open || security_level != starting_level)
		// if the plating's already been broken, don't break it again
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.visible_message(span_notice("[user] removes [src]'s shielding."),
							span_notice("You remove [src]'s [layer_flavor]."))
	security_level = next_level
	spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
	if(next_level == AIRLOCK_SECURITY_NONE)
		modify_max_integrity(normal_integrity)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
		update_icon()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/welder_act(mob/living/user, obj/item/tool)

	if(!panel_open || security_level == AIRLOCK_SECURITY_NONE)
		return ..()

	var/layer_flavor
	var/next_level
	var/starting_level = security_level

	var/material_to_spawn
	var/amount_to_spawn

	switch(security_level)
		if(AIRLOCK_SECURITY_IRON)
			layer_flavor = "panel's shielding"
			next_level = AIRLOCK_SECURITY_NONE
			material_to_spawn = /obj/item/stack/sheet/iron
			amount_to_spawn = 2
		if(AIRLOCK_SECURITY_PLASTEEL_O)
			layer_flavor = "outer layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_O_S
		if(AIRLOCK_SECURITY_PLASTEEL_I)
			layer_flavor = "inner layer of shielding"
			next_level = AIRLOCK_SECURITY_PLASTEEL_I_S
		else
			return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!tool.tool_start_check(user, amount=2))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	to_chat(user, span_notice("You begin cutting the [layer_flavor]..."))

	if(!tool.use_tool(src, user, 4 SECONDS, volume=50, amount=2))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!panel_open || security_level != starting_level)
		// see if anyone's screwing with us
		return TOOL_ACT_TOOLTYPE_SUCCESS

	user.visible_message(
		span_notice("[user] cuts through [src]'s shielding."),  // passers-by don't get the full picture
		span_notice("You cut through [src]'s [layer_flavor]."),
		span_hear("You hear welding.")
	)

	security_level = next_level

	if(material_to_spawn)
		spawn_atom_to_turf(material_to_spawn, user.loc, amount_to_spawn)

	if(security_level == AIRLOCK_SECURITY_NONE)
		update_icon()

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/door/airlock/proc/try_reinforce(mob/user, obj/item/stack/sheet/material, amt_required, new_security_level)
	if(material.get_amount() < amt_required)
		to_chat(user, span_warning("You need at least [amt_required] sheets of [material] to reinforce [src]."))
		return FALSE
	to_chat(user, span_notice("You start reinforcing [src]."))
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	if(!panel_open || !material.use(amt_required))
		return FALSE
	user.visible_message(span_notice("[user] reinforces [src] with [material]."),
						span_notice("You reinforce [src] with [material]."))
	security_level = new_security_level
	update_icon()
	return TRUE

/obj/machinery/door/airlock/attackby(obj/item/C, mob/living/user, params)
	if(!issilicon(user) && !IsAdminGhost(user))
		if(isElectrified() && C?.siemens_coefficient && shock(user, 75))
			return
	add_fingerprint(user)

	if(is_wire_tool(C) && panel_open)
		attempt_wire_interaction(user)
		return
	else if(panel_open && security_level == AIRLOCK_SECURITY_NONE && istype(C, /obj/item/stack/sheet))
		if(istype(C, /obj/item/stack/sheet/iron))
			return try_reinforce(user, C, 2, AIRLOCK_SECURITY_IRON)

		else if(istype(C, /obj/item/stack/sheet/plasteel))
			if(!try_reinforce(user, C, 2, AIRLOCK_SECURITY_PLASTEEL))
				return FALSE
			modify_max_integrity(normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
			damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
			update_icon()
			return TRUE

	else if(istype(C, /obj/item/pai_cable))
		var/obj/item/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/doorCharge))
		if(!panel_open || security_level)
			to_chat(user, "<span class='warning'>Panel serwisowy musi być otwarty, by założyć [C]!</span>")
			return
		if(obj_flags & EMAGGED)
			return
		if(charge && !detonated)
			to_chat(user, "<span class='warning'>Do tych drzwi jest już podłączony ładunek!</span>")
			return
		if(detonated)
			to_chat(user, "<span class='warning'>Panel serwisowy jest zniszczony!</span>")
			return
		to_chat(user, "<span class='warning'>Zakładasz [C]. Gdy ktoś następnym razem otworzy drzwi, wybuchną.</span>")
		panel_open = FALSE
		update_icon()
		user.transferItemToLoc(C, src, TRUE)
		charge = C
	else if(istype(C, /obj/item/paper) || istype(C, /obj/item/photo))
		if(note)
			to_chat(user, "<span class='warning'>Do tej śluzy jest już coś przypięte! Użyj nożyc do drutu, by to zdjąć.</span>")
			return
		if(!user.transferItemToLoc(C, src))
			to_chat(user, "<span class='warning'>Z jakiegoś powodu nie możesz przymocować [C]!</span>")
			return
		user.visible_message("<span class='notice'>[user] przypina [C] do [src].</span>", "<span class='notice'>Przypinasz [C] do [src].</span>")
		note = C
		update_icon()
	// AQ EDIT - port Bee #11899: przedmioty-wytrychy, które nie są łomami (ostrza itp.), dalej podważają drzwi
	else if(HAS_TRAIT(C, TRAIT_DOOR_PRYER) && C.tool_behaviour != TOOL_CROWBAR && !user.combat_mode)
		try_to_crowbar(C, user, TRUE)
	else
		return ..()

/obj/machinery/door/airlock/try_to_weld(obj/item/weldingtool/W, mob/living/user)
	if(!operating && density)

		if(obj_integrity < max_integrity)
			if(!W.tool_start_check(user, amount=0))
				return
			user.visible_message(span_notice("[user] begins welding the airlock."), \
							span_notice("You begin repairing the airlock..."), \
							span_hear("Słyszysz spawanie."))
			if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, PROC_REF(weld_checks), W, user)))
				obj_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				user.visible_message(span_notice("[user] finishes welding [src]."), \
									span_notice("You finish repairing the airlock."))
				update_icon()
		else
			to_chat(user, span_notice("The airlock doesn't need repairing."))

/obj/machinery/door/airlock/try_to_weld_secondary(obj/item/weldingtool/tool, mob/user)
	if(operating || !density)
		return
	if(protected_door || !tool.tool_start_check(user, amount=0))
		return
	user.visible_message(span_notice("[user] begins [welded ? "unwelding":"welding"] śluzę."), \
		span_notice("You begin [welded ? "unwelding":"welding"] the airlock..."), \
		span_hear("Słyszysz spawanie."))
	if(!tool.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, PROC_REF(weld_checks), tool, user)))
		return
	welded = !welded
	user.visible_message(span_notice("[user] [welded? "welds shut":"unwelds"] [src]."), \
		span_notice("You [welded ? "weld the airlock shut":"unweld the airlock"]."))
	log_combat(user, src, welded? "welded shut":"unwelded", tool)
	update_icon()

/obj/machinery/door/airlock/proc/weld_checks(obj/item/weldingtool/W, mob/user)
	return !operating && density

/// Returns if a crowbar would remove the airlock electronics
/obj/machinery/door/airlock/proc/should_try_removing_electronics()
	if (security_level != 0)
		return FALSE

	if (!panel_open)
		return FALSE

	if (obj_flags & EMAGGED) // NSV13 - emagged doors can always have their electronics pulled
		return TRUE

	if (!density)
		return FALSE

	if (!welded)
		return FALSE

	if (hasPower())
		return FALSE

	if (locked)
		return FALSE

	return TRUE

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/living/user, forced = FALSE)
	//Airlock Charges
	if(panel_open && charge)
		to_chat(user, span_notice("You carefully start removing [charge] from [src]..."))
		if(!I.use_tool(src, user, 150, volume=50))
			to_chat(user, span_warning("You slip and [charge] detonates!"))
			charge.ex_act(EXPLODE_DEVASTATE)
			user.Paralyze(60)
			return
		user.visible_message(span_notice("[user] removes [charge] from [src]."), \
							span_notice("You gently pry out [charge] from [src] and unhook its wires."))
		charge.forceMove(get_turf(user))
		charge = null
		return
	//End Airlock Charges
	if(I?.tool_behaviour == TOOL_CROWBAR && should_try_removing_electronics() && !operating)
		user.visible_message("[user] wyjmuje elektronikę z zespołu śluzy.", \
			span_notice("You start to remove electronics from the airlock assembly..."))
		if(I.use_tool(src, user, 40, volume=100))
			deconstruct(TRUE, user)
			return TRUE
	if(locked)
		to_chat(user, span_warning("The airlock's bolts prevent it from being forced!"))
		return
	if(welded)
		to_chat(user, span_warning("It's welded, it won't budge!"))
		return
	if(hasPower())
		if(forced)
			var/check_electrified = isElectrified() //setting this so we can check if the mob got shocked during the do_after below
			if(check_electrified && shock(user,100))
				return //it's like sticking a fork in a power socket

			if(!density)//already open
				return

			if(!prying_so_hard)
				var/time_to_open = 50
				playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE) //is it aliens or just the CE being a dick?
				prying_so_hard = TRUE
				to_chat(user, span_warning("You begin prying open the airlock..."))
				if(do_after(user, time_to_open, TRUE, src))
					if(check_electrified && shock(user,100))
						prying_so_hard = FALSE
						return
					if(density && !open(2))
						to_chat(user, span_warning("Despite your attempts, [src] refuses to open."))
				prying_so_hard = FALSE
				return
		to_chat(user, span_warning("The airlock's motors resist your efforts to force it!"))
		return

	if(!operating)
		if(istype(I, /obj/item/fireaxe) && !ISWIELDED(I)) //being fireaxe'd
			to_chat(user, span_warning("You need to be wielding the fire axe to do that!"))
			return
		INVOKE_ASYNC(src, (density ? PROC_REF(open) : PROC_REF(close)), 2)

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked )
		return FALSE

	if(!forced)
		if(!hasPower() || (wires && wires.is_cut(WIRE_OPEN)))	//NSV13 edit: Checks for wires before looking at is_cut as a sanity check, due to turbolifts.
			return FALSE
	if(charge && !detonated)
		panel_open = TRUE
		update_icon(AIRLOCK_OPENING)
		visible_message("<span class='warning'>Panel [src] wylatuje w powietrze w fontannie śmiercionośnych odłamków!</span>")
		charge.forceMove(drop_location())
		charge.ex_act(EXPLODE_DEVASTATE)
		detonated = 1
		charge = null
		for(var/mob/living/carbon/human/H in orange(2,src))
			H.Unconscious(160)
			H.adjust_fire_stacks(20)
			H.IgniteMob() //Guaranteed knockout and ignition for nearby people
			H.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		return
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return FALSE
		if(!protected_door)
			use_power(50)
		playsound(src, doorOpen, 30, 1)
		if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
			closeOther.close()
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	if(autoclose)
		autoclose_in(normalspeed ? 150 : 15)

	if(!density)
		return TRUE
	ui_update()

	SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, forced)
	operating = TRUE
	update_icon(AIRLOCK_OPENING, 1)
	sleep(1)
	set_opacity(0)
	update_freelook_sight()
	sleep(door_animation_speed) //Nsv13 - SPEEDY DOORS
	density = FALSE
	flags_1 &= ~PREVENT_CLICK_UNDER_1//NSV make it so prevent_click_under doesn't need density
	air_update_turf()
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	operating = FALSE
	ui_update()
	if(delayed_close_requested)
		delayed_close_requested = FALSE
		addtimer(CALLBACK(src, PROC_REF(close)), 1)
	return TRUE


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(density)
		return TRUE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && !(M.flags_1 & ON_BORDER_1) && M != src) //something is blocking the door
				autoclose_in(60)
				return

	if(forced < 2)
		if(obj_flags & EMAGGED)
			return
		if(!protected_door)
			use_power(50)
		playsound(src, doorClose, 30, TRUE)
	else
		playsound(src, 'sound/machines/airlockforced.ogg', 30, TRUE)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		SSexplosions.med_mov_atom += killthis

	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE, forced)
	ui_update()
	operating = TRUE
	update_icon(AIRLOCK_CLOSING, 1)
	layer = CLOSED_DOOR_LAYER
	if(air_tight)
		density = TRUE
		if(!(flags_1 & ON_BORDER_1))//NSV but not border firelocks
			flags_1 |= PREVENT_CLICK_UNDER_1//NSV make it so prevent_click_under doesn't need density
		air_update_turf()
	sleep(1)
	if(!air_tight)
		density = TRUE
		if(!(flags_1 & ON_BORDER_1))//NSV but not border firelocks
			flags_1 |= PREVENT_CLICK_UNDER_1//NSV make it so prevent_click_under doesn't need density
		air_update_turf()
	sleep(door_animation_speed) //Nsv13 - SPEEDY DOORS
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, 1)
	operating = FALSE
	delayed_close_requested = FALSE
	ui_update()
	if(safe)
		CheckForMobs()
	ui_update()
	return TRUE

/obj/machinery/door/airlock/proc/prison_open()
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	open()
	locked = TRUE
	return


/obj/machinery/door/airlock/proc/change_paintjob(obj/item/airlock_painter/painter, mob/user)
	if(!allow_repaint)
		to_chat(user, "<span class='warning'>Malarz śluz nie obsługuje tej śluzy.</span>")
		return

	if((!in_range(src, user) && loc != user) || !painter.can_use(user)) // user should be adjacent to the airlock, and the painter should have a toner cartridge that isn't empty
		return

	// reads from the airlock painter's `available paintjob` list. lets the player choose a paint option, or cancel painting
	var/current_paintjob = input(user, "Wybierz malowanie dla tej śluzy.") as null|anything in sortList(painter.available_paint_jobs)
	if(!current_paintjob) // if the user clicked cancel on the popup, return
		return

	var/airlock_type = painter.available_paint_jobs["[current_paintjob]"] // get the airlock type path associated with the airlock name the user just chose
	var/obj/machinery/door/airlock/airlock = airlock_type // we need to create a new typed variable of the airlock and assembly to read initial values from them
	var/obj/structure/door_assembly/assembly = initial(airlock.assemblytype)
	if(airlock_material == "glass" && initial(assembly.noglass)) // prevents painting glass airlocks with a paint job that doesn't have a glass version, such as the freezer
		to_chat(user, "<span class='warning'>To malowanie można nałożyć tylko na śluzy bez szyb.</span>")
		return
	// applies the user-chosen airlock's icon, overlays, assemblytype anim_parts, panel_attachement and note_attachment to the src airlock
	painter.use_paint(user)
	icon = initial(airlock.icon)
	overlays_file = initial(airlock.overlays_file)
	note_overlay_file = initial(airlock.note_overlay_file)
	assemblytype = initial(airlock.assemblytype)
	anim_parts = initial(airlock.anim_parts)
	panel_attachment = initial(airlock.panel_attachment)
	note_attachment = initial(airlock.note_attachment)
	rebuild_parts()
	update_icon()

/obj/machinery/door/airlock/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut or powered off)
	return !density || (check_access(ID) && !locked && hasPower())

/obj/machinery/door/airlock/emag_act(mob/user)
	if(protected_door)
		to_chat(user, "<span class='warning'>[src] nie ma panelu serwisowego!</span>")
		return
	if(!operating && density && hasPower() && !(obj_flags & EMAGGED))
		operating = TRUE
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		operating = FALSE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		obj_flags |= EMAGGED
		lights = FALSE
		locked = TRUE
		loseMainPower()
		loseBackupPower()

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified() && shock(user, 100)) //Mmm, fried xeno!
		add_fingerprint(user)
		return
	if(!density) //Already open
		return ..()
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		if(user.combat_mode)
			return ..()
		to_chat(user, "<span class='warning'>[src] ani drgnie!</span>")
		return
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] zaczyna wyważać [src].</span>",\
						"<span class='noticealien'>Z całej siły wbijasz pazury w [src]!</span>",\
						"<span class='warning'>Słyszysz jęk metalu...</span>")
	var/time_to_open = 5
	if(hasPower())
		time_to_open = 5 SECONDS //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)


	if(do_after(user, time_to_open, TRUE, src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, "<span class='warning'>Mimo twoich wysiłków [src] opiera się próbom otwarcia!</span>")

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !machine_stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		bolt() //Bolt it!
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)  //Shock it!
		if(origin)
			LAZYADD(shockedby, "\[[time_stamp()]\] [key_name(origin)]")


/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !machine_stat)
		unbolt()
		set_electrified(MACHINE_NOT_ELECTRIFIED)
		open()
		safe = TRUE

/obj/machinery/door/airlock/proc/on_break()
	if(!panel_open)
		panel_open = TRUE
	wires.cut_all()

/obj/machinery/door/airlock/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(prob(severity*10 - 20) && (secondsElectrified < 30) && (secondsElectrified != MACHINE_ELECTRIFIED_PERMANENT))
		set_electrified(30)
		LAZYADD(shockedby, "\[[time_stamp()]\]EM Pulse")

/obj/machinery/door/airlock/proc/set_electrified(seconds, mob/user)
	secondsElectrified = seconds
	diag_hud_set_electrified()
	ui_update()
	if(secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		INVOKE_ASYNC(src, PROC_REF(electrified_loop))

	if(user)
		var/message
		switch(secondsElectrified)
			if(MACHINE_ELECTRIFIED_PERMANENT)
				message = "trwale pod napięciem"
			if(MACHINE_NOT_ELECTRIFIED)
				message = "unshocked"
			else
				message = "pod napięciem przez [secondsElectrified] s"
		LAZYADD(shockedby, text("\[[time_stamp()]\] [key_name(user)] - ([uppertext(message)])"))
		log_combat(user, src, message)
		add_hiddenprint(user)

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(obj_integrity < (0.75 * max_integrity))
		update_icon()

/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/door_assembly/A
		if(assemblytype)
			A = new assemblytype(loc)
		else
			A = new /obj/structure/door_assembly(loc)
			//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.
		A.heat_proof_finished = heat_proof //tracks whether there's rglass in
		A.setAnchored(TRUE)
		A.glass = glass
		A.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		A.created_name = name
		A.previous_assembly = previous_airlock
		A.update_name()
		A.update_icon()

		if(!disassembled)
			if(A)
				A.obj_integrity = A.max_integrity * 0.5
		else if(obj_flags & EMAGGED)
			if(user)
				to_chat(user, "<span class='warning'>Wyrzucasz uszkodzoną elektronikę.</span>")
		else
			if(user)
				to_chat(user, "<span class='notice'>Wyjmujesz elektronikę śluzy.</span>")

			var/obj/item/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/electronics/airlock(loc)
				gen_access()
				if(req_one_access.len)
					ae.one_access = 1
					ae.accesses = req_one_access
				else
					ae.accesses = req_access
			else
				ae = electronics
				electronics = null
				ae.forceMove(drop_location())
	qdel(src)

/obj/machinery/door/airlock/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			if(security_level != AIRLOCK_SECURITY_NONE)
				to_chat(user, "<span class='notice'>Najpierw trzeba usunąć wzmocnienie [src].</span>")
				return FALSE
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/airlock/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>Rozbierasz śluzę.</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	else if(istype(note, /obj/item/paper))
		return "note"
	else if(istype(note, /obj/item/photo))
		return "photo"


/obj/machinery/door/airlock/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(secondsMainPowerLost || secondsBackupPowerLost || secondsElectrified)
		. = TRUE // Autoupdate while counters are counting down

/obj/machinery/door/airlock/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/door/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiAirlock")
		ui.open()
	return TRUE

/obj/machinery/door/airlock/ui_data()
	var/list/data = list()

	var/list/power = list()
	power["main"] = secondsMainPowerLost ? 0 : 2 // boolean
	power["main_timeleft"] = secondsMainPowerLost
	power["backup"] = secondsBackupPowerLost ? 0 : 2 // boolean
	power["backup_timeleft"] = secondsBackupPowerLost
	data["power"] = power

	data["shock"] = secondsElectrified == MACHINE_NOT_ELECTRIFIED ? 2 : 0
	data["shock_timeleft"] = secondsElectrified
	data["id_scanner"] = !aiDisabledIdScanner
	data["emergency"] = emergency // access
	data["locked"] = locked // bolted
	data["lights"] = lights // bolt lights
	data["safe"] = safe // safeties
	data["speed"] = normalspeed // safe speed
	data["welded"] = welded // welded
	data["opened"] = !density // opened

	var/list/wire = list()
	wire["main_1"] = !wires.is_cut(WIRE_POWER1)
	wire["main_2"] = !wires.is_cut(WIRE_POWER2)
	wire["backup_1"] = !wires.is_cut(WIRE_BACKUP1)
	wire["backup_2"] = !wires.is_cut(WIRE_BACKUP2)
	wire["shock"] = !wires.is_cut(WIRE_SHOCK)
	wire["id_scanner"] = !wires.is_cut(WIRE_IDSCAN)
	wire["bolts"] = !wires.is_cut(WIRE_BOLTS)
	wire["lights"] = !wires.is_cut(WIRE_LIGHT)
	wire["safe"] = !wires.is_cut(WIRE_SAFETY)
	wire["timing"] = !wires.is_cut(WIRE_TIMING)

	data["wires"] = wire
	return data

/obj/machinery/door/airlock/ui_act(action, params)
	if(..())
		return
	if(!user_allowed(usr))
		return
	switch(action)
		if("disrupt-main")
			if(!secondsMainPowerLost)
				loseMainPower()
				update_icon()
			else
				to_chat(usr, "Zasilanie główne jest już wyłączone.")
			. = TRUE
		if("disrupt-backup")
			if(!secondsBackupPowerLost)
				loseBackupPower()
				update_icon()
			else
				to_chat(usr, "Zasilanie zapasowe jest już wyłączone.")
			. = TRUE
		if("shock-restore")
			shock_restore(usr)
			. = TRUE
		if("shock-temp")
			shock_temp(usr)
			. = TRUE
		if("shock-perm")
			shock_perm(usr)
			. = TRUE
		if("idscan-toggle")
			aiDisabledIdScanner = !aiDisabledIdScanner
			. = TRUE
		if("emergency-toggle")
			toggle_emergency(usr)
			. = TRUE
		if("bolt-toggle")
			toggle_bolt(usr)
			. = TRUE
		if("light-toggle")
			lights = !lights
			update_icon()
			. = TRUE
		if("safe-toggle")
			safe = !safe
			. = TRUE
		if("speed-toggle")
			normalspeed = !normalspeed
			. = TRUE
		if("open-close")
			user_toggle_open(usr)
			. = TRUE

/obj/machinery/door/airlock/proc/user_allowed(mob/user)
	return (issilicon(user) && allowed(user) && canAIControl(user)) || IsAdminGhost(user)

/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "Nie można wyłączyć napięcia na śluzie - przewód elektryfikacji jest przecięty.")
	else if(isElectrified())
		set_electrified(MACHINE_NOT_ELECTRIFIED, user)

/obj/machinery/door/airlock/proc/shock_temp(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "Przewód elektryfikacji został przecięty")
	else
		set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, user)

/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "Przewód elektryfikacji został przecięty")
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)

/obj/machinery/door/airlock/proc/toggle_bolt(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, "<span class='warning'>Przewód opuszczania rygli jest przecięty - nie możesz przełączać rygli.</span>")
		return
	if(locked)
		if(!hasPower())
			to_chat(user, "<span class='warning'>Drzwi nie mają zasilania - nie możesz podnieść rygli.</span>")
		else
			unbolt()
			log_combat(user, src, "unbolted")
	else
		bolt()
		log_combat(user, src, "bolted")
/obj/machinery/door/airlock/proc/toggle_emergency(mob/user)
	if(!user_allowed(user))
		return
	emergency = !emergency
	update_icon()
	ui_update()

/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if(!user_allowed(user))
		return
	if(welded)
		to_chat(user, text("Śluza została zaspawana!"))
	else if(locked)
		to_chat(user, text("Rygle drzwi są opuszczone!"))
	else if(!density)
		close()
	else
		open()

//NSV13 start
/obj/machinery/door/airlock/proc/legacy_set_airlock_overlays(state)
	var/mutable_appearance/frame_overlay
	var/mutable_appearance/filling_overlay
	var/mutable_appearance/lights_overlay
	var/mutable_appearance/panel_overlay
	var/mutable_appearance/weld_overlay
	var/mutable_appearance/damag_overlay
	var/mutable_appearance/sparks_overlay
	var/mutable_appearance/note_overlay
	var/notetype = note_type()

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	cut_overlays()
	add_overlay(frame_overlay)
	add_overlay(filling_overlay)
	add_overlay(lights_overlay)
	add_overlay(panel_overlay)
	add_overlay(weld_overlay)
	add_overlay(sparks_overlay)
	add_overlay(damag_overlay)
	add_overlay(note_overlay)
	check_unres()
//NSV13 end

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG

#undef AIRLOCK_SECURITY_NONE
#undef AIRLOCK_SECURITY_IRON
#undef AIRLOCK_SECURITY_PLASTEEL_I_S
#undef AIRLOCK_SECURITY_PLASTEEL_I
#undef AIRLOCK_SECURITY_PLASTEEL_O_S
#undef AIRLOCK_SECURITY_PLASTEEL_O
#undef AIRLOCK_SECURITY_PLASTEEL

#undef AIRLOCK_INTEGRITY_N
#undef AIRLOCK_INTEGRITY_MULTIPLIER
#undef AIRLOCK_DAMAGE_DEFLECTION_N
#undef AIRLOCK_DAMAGE_DEFLECTION_R
