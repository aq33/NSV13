#define CALL_BOT_COOLDOWN 900

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in GLOB.ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = JOB_NAME_AI
	real_name = JOB_NAME_AI
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	move_resist = MOVE_FORCE_VERY_STRONG
	density = TRUE
	mobility_flags = ALL
	status_flags = CANSTUN|CANPUSH
	combat_mode = TRUE //so we always get pushed instead of trying to swap
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_in_dark = 8
	hud_type = /datum/hud/ai
	med_hud = DATA_HUD_MEDICAL_BASIC
	sec_hud = DATA_HUD_SECURITY_BASIC
	d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED
	mob_size = MOB_SIZE_LARGE
	var/battery = 200 //emergency power if the AI's APC is off
	var/list/network = list("ss13")
	var/obj/machinery/camera/current
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/requires_power = POWER_REQ_ALL
	var/can_be_carded = TRUE
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list(), "Burglar"=list())
	var/datum/weakref/alerts_popup = null
	var/icon/holo_icon //Default is assigned when AI is created.
	var/obj/mecha/controlled_mech //For controlled_mech a mech, to determine whether to relaymove or use the AI eye.
	var/obj/controlled_equipment //A non-mech piece of equipment the AI is inside of, like a MODsuit
	var/radio_enabled = TRUE //Determins if a carded AI can speak with its built in radio or not.
	radiomod = ";" //AIs will, by default, state their laws on the internal radio.
	var/obj/item/multitool/aiMulti
	var/mob/living/simple_animal/bot/Bot
	var/mob/living/ai_tracking_target = null //current tracking target
	var/reacquire_timer = null //saves the timer id for the tracking reacquire so we can delete it/check for its existence
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/list/datum/AI_Module/current_modules = list()
	var/can_dominate_mechs = FALSE
	var/shunted = FALSE	//1 if the AI is currently shunted. Used to differentiate between shunted and ghosted/braindead

	var/control_disabled = FALSE	// Set to 1 to stop AI from interacting via Click()
	var/malfhacking = FALSE		// More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite
	var/malf_cooldown = 0		//Cooldown var for malf modules, stores a worldtime + cooldown

	var/obj/machinery/power/apc/malfhack
	var/explosive = FALSE		//does the AI explode when it dies?

	var/mob/living/silicon/ai/parent
	var/camera_light_on = FALSE
	var/list/obj/machinery/camera/lit_cameras = list()

	var/datum/trackable/track = new

	var/last_tablet_note_seen = null
	var/can_shunt = TRUE
	var/last_announcement = "" 		// For AI VOX, if enabled
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = FALSE		//Waypoint mode is for selecting a turf via clicking.
	var/call_bot_cooldown = 0		//time of next call bot command
	var/apc_override = FALSE		//hack for letting the AI use its APC even when visionless
	var/nuking = FALSE
	var/obj/machinery/doomsday_device/doomsday_device

	var/mob/camera/ai_eye/eyeobj
	var/sprint = 10
	var/cooldown = 0
	//Default value of camera acceleration
	var/acceleration = 0

	var/obj/structure/AIcore/deactivated/linked_core //For exosuit control
	var/mob/living/silicon/robot/deployed_shell = null //For shell control
	var/datum/action/innate/deploy_shell/deploy_action = new
	var/datum/action/innate/deploy_last_shell/redeploy_action = new
	var/chnotify = 0

	var/multicam_on = FALSE
	var/atom/movable/screen/movable/pic_in_pic/ai/master_multicam
	var/list/multicam_screens = list()
	var/list/all_eyes = list()
	var/max_multicams = 6
	var/display_icon_override

	var/list/cam_hotkeys = new/list(9)
	var/cam_prev

	var/atom/movable/screen/ai/modpc/interfaceButton

	var/datum/robot_control/robot_control //NSV13

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	default_access_list = get_all_accesses()
	. = ..()
	if(!target_ai) //If there is no player/brain inside.
		new/obj/structure/AIcore/deactivated(loc) //New empty terminal.
		return INITIALIZE_HINT_QDEL //Delete AI.

	if(L && istype(L, /datum/ai_laws))
		laws = L
		laws.associate(src)
	else
		make_laws()

	if(target_ai.mind)
		target_ai.mind.transfer_to(src)
		if(mind.special_role)
			mind.store_memory("Jako SI musisz przede wszystkim przestrzegać swoich praw. Twoje cele uznają cię za martwego.")
			to_chat(src, "<span class='userdanger'>Zostajesz zainstalowany jako SI!</span>")
			to_chat(src, "<span class='danger'>Musisz przede wszystkim przestrzegać swoich praw. Twoje cele uznają cię za martwego.</span>")

	to_chat(src, "<B>Grasz jako SI stacji. SI nie może się poruszać, ale może wchodzić w interakcje z wieloma obiektami, które widzi (przez kamery).</B>")
	to_chat(src, "<B>Aby zobaczyć inne części stacji, kliknij na siebie, by otworzyć menu kamer.</B>")
	to_chat(src, "<B>Obserwując przez kamerę, możesz używać większości (podłączonych do sieci) urządzeń, które widzisz, takich jak komputery, APC, interkomy, drzwi itp.</B>")
	to_chat(src, "Aby czegoś użyć, po prostu to kliknij.")
	to_chat(src, "Użyj :b, by rozmawiać ze swoimi cyborgami w kodzie binarnym.")
	to_chat(src, "Kanały działów obsługujesz następującymi prefiksami:")
	to_chat(src, ":o - prywatny SI, :c - dowództwo, :s - ochrona, :e - inżynieria, :u - zaopatrzenie, :v - serwis, :m - medyczny, :n - naukowy.")
	show_laws()
	to_chat(src, "<b>Te prawa mogą zostać zmienione przez innych graczy lub przez ciebie, jeśli jesteś zdrajcą.</b>")

	job = JOB_NAME_AI

	create_modularInterface()
	create_eye()
	if(client)
		apply_pref_name("ai",client)

	INVOKE_ASYNC(src, PROC_REF(set_core_display_icon))


	holo_icon = getHologramIcon(icon('icons/mob/ai.dmi',"default"))

	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_verb(/mob/living/silicon/ai/proc/show_laws_verb)

	aiMulti = new(src)
	radio = new /obj/item/radio/headset/silicon/ai(src)
	aicamera = new/obj/item/camera/siliconcam/ai_camera(src)

	deploy_action.Grant(src)

	if(isturf(loc))
		add_verb(list(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, /mob/living/silicon/ai/proc/ai_hologram_change, \
		/mob/living/silicon/ai/proc/botcall, /mob/living/silicon/ai/proc/control_integrated_radio, \
		/mob/living/silicon/ai/proc/set_automatic_say_channel))

	GLOB.ai_list += src
	GLOB.shuttle_caller_list += src

	builtInCamera = new (src)
	builtInCamera.network = list("ss13")
	//Nsv13
	AddComponent(/datum/component/holomap)
	for(var/stype in subtypesof(/datum/component/simple_teamchat/radio_dependent/squad))
		AddComponent(stype, override = TRUE)
	update_overmap() //AIs don't move, so we do this here.

	//Nsv13 end

/mob/living/silicon/ai/key_down(_key, client/user)
	if(findtext(_key, "numpad")) //if it's a numpad number, we can convert it to just the number
		_key = _key[7] //strings, lists, same thing really
	switch(_key)
		if("`", "0")
			if(cam_prev)
				eyeobj.setLoc(cam_prev)
			return
		if("1", "2", "3", "4", "5", "6", "7", "8", "9")
			_key = text2num(_key)
			if(client.keys_held["Ctrl"]) //do we assign a new hotkey?
				cam_hotkeys[_key] = eyeobj.loc
				to_chat(src, "Lokalizacja zapisana w grupie kamer [_key].")
				return
			if(cam_hotkeys[_key]) //if this is false, no hotkey for this slot exists.
				cam_prev = eyeobj.loc
				eyeobj.setLoc(cam_hotkeys[_key])
				return
	return ..()

/mob/living/silicon/ai/Destroy()
	GLOB.ai_list -= src
	GLOB.shuttle_caller_list -= src
	SSshuttle.autoEvac()
	qdel(eyeobj) // No AI, no Eye
	malfhack = null
	ShutOffDoomsdayDevice()
	. = ..()

/mob/living/silicon/ai/IgniteMob()
	fire_stacks = 0
	. = ..()

/mob/living/silicon/ai/proc/set_core_display_icon(input, client/C)
	if(client && !C)
		C = client
	if(!input && !C?.prefs?.active_character.preferred_ai_core_display)
		icon_state = initial(icon_state)
	else
		var/preferred_icon = input ? input : C.prefs.active_character.preferred_ai_core_display
		icon_state = resolve_ai_icon(preferred_icon)

/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(incapacitated())
		return
	icon = initial(icon)
	icon_state = "ai"
	cut_overlays()
	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-random")
			continue
		if(option == "Portrait")
			iconstates[option] = image(icon = src.icon, icon_state = "ai-portrait")
			continue
		iconstates[option] = image(icon = src.icon, icon_state = resolve_ai_icon(option))

	view_core()
	var/ai_core_icon = show_radial_menu(src, src , iconstates, radius = 42)

	if(!ai_core_icon || incapacitated())
		return

	display_icon_override = ai_core_icon
	set_core_display_icon(ai_core_icon)

/mob/living/silicon/ai/get_stat_tab_status()
	var/list/tab_data = ..()
	if(!stat)
		tab_data["Integralność systemu"] = GENERATE_STAT_TEXT("[(health+100)/2]%")
		if(isturf(loc)) //only show if we're "in" a core
			tab_data["Zasilanie awaryjne"] = GENERATE_STAT_TEXT("[battery/2]%")
		tab_data["Podłączone cyborgi"] = GENERATE_STAT_TEXT("[connected_robots.len]")
		var/index = 0
		for(var/mob/living/silicon/robot/R in connected_robots)
			var/robot_status = "Nominal"
			if(R.shell)
				robot_status = "AI SHELL"
			else if(R.stat || !R.client)
				robot_status = "OFFLINE"
			else if(!R.cell || R.cell.charge <= 0)
				robot_status = "DEPOWERED"
			//Name, Health, Battery, Module, Area, and Status! Everything an AI wants to know about its borgies!
			index++
			tab_data["[R.name] (Connection [index])"] = list(
				text="S.Integrity: [R.health]% | Cell: [R.cell ? "[R.cell.charge]/[R.cell.maxcharge]" : "Empty"] | \
					Module: [R.designation] | Loc: [get_area_name(R, TRUE)] | Status: [robot_status]",
				type=STAT_TEXT)
		tab_data["Wykryte powłoki SI"] = GENERATE_STAT_TEXT("[LAZYLEN(GLOB.available_ai_shells)]") //Count of total AI shells
	else
		tab_data["Systemy"] = GENERATE_STAT_TEXT("niesprawne")
	return tab_data

/mob/living/silicon/ai/proc/update_ai_alerts()
	if(!alerts_popup || !alerts_popup.resolve())
		return
	var/dat
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=byond://?src=[REF(src)];switchcamera=[REF(I)]>[]</A>", (dat2=="") ? "" : " | ", I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "Brak kamery")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=byond://?src=[REF(src)];switchcamera=[REF(C)]>[]</A>)", A.name, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- Wszystkie systemy działają prawidłowo<BR>\n"
		dat += "<BR>\n"
	var/datum/browser/popup = alerts_popup.resolve()
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/ai/proc/ai_alerts()
	var/datum/browser/popup
	if(!alerts_popup || !alerts_popup.resolve())
		popup = new(src, "aialerts", "Aktualne alarmy stacji", 387, 420, src) // additional src argument allows calls to our Topic() proc via onclose - is wrapped internally as weakref
		alerts_popup = WEAKREF(popup) // wrap to prevent harddel
	update_ai_alerts()
	popup = alerts_popup.resolve()
	popup.open()

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(control_disabled)
		to_chat(usr, "<span class='warning'>Sterowanie bezprzewodowe jest wyłączone!</span>")
		return

	var/can_evac_or_fail_reason = SSshuttle.canEvac(src)
	if(can_evac_or_fail_reason != TRUE)
		to_chat(usr, "<span class='alert'>[can_evac_or_fail_reason]</span>")
		return

	var/reason = input(src, "Jaki jest charakter sytuacji awaryjnej? (wymagane znaki: [CALL_SHUTTLE_REASON_LENGTH])", "Potwierdź wezwanie promu") as null|text

	if(incapacitated())
		return

	if(trim(reason))
		SSshuttle.requestEvac(src, reason)

	// hack to display shuttle timer
	if(!EMERGENCY_IDLE_OR_RECALLED)
		var/obj/machinery/computer/communications/C = locate() in GLOB.machines
		if(C)
			C.post_status("shuttle")

/mob/living/silicon/ai/can_interact_with(atom/A)
	. = ..()
	var/turf/ai = get_turf(src)
	var/turf/target = get_turf(A)
	if (.)
		return

	if(!target)
		return

	if ((ai.get_virtual_z_level() != target.get_virtual_z_level()) && !is_station_level(ai.z))
		return FALSE

	if(A.is_jammed())
		return FALSE

	//NSV13 - don't let AI control hostile ship equipment
	var/obj/structure/overmap/otherOM = A.get_overmap()
	var/obj/structure/overmap/aiOM = get_overmap()
	if(otherOM && (!aiOM || (otherOM.faction != aiOM.faction)))
		return FALSE
	//end NSV13

	if (istype(loc, /obj/item/aicard))
		if (!ai || !target)
			return FALSE
		return ISINRANGE(target.x, ai.x - interaction_range, ai.x + interaction_range) && ISINRANGE(target.y, ai.y - interaction_range, ai.y + interaction_range)
	else
		return GLOB.cameranet.checkTurfVis(get_turf(A))

/mob/living/silicon/ai/cancel_camera()
	view_core()

/mob/living/silicon/ai/verb/wipe_core()
	set name = "Wipe Core"
	set category = "OOC"
	set desc = "Wipe your core. This is functionally equivalent to cryo, freeing up your job slot."

	if(stat)
		return

	// Guard against misclicks, this isn't the sort of thing we want happening accidentally
	if(alert("OSTRZEŻENIE: to natychmiast wyczyści twój rdzeń i zamieni cię w ducha, trwale usuwając twoją postać z rundy (podobnie jak kriokomora, więc najpierw napisz ahelp). Czy na pewno chcesz to zrobić?",
					"Wyczyść rdzeń", "No", "No", "Yes") != "Yes")
		return

	// We warned you.
	var/obj/structure/AIcore/latejoin_inactive/inactivecore = new(loc)
	transfer_fingerprints_to(inactivecore)

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("AIWIPE", real_name, mind.assigned_role, list())

	SSjob.FreeRole(mind.assigned_role)

	if(!get_ghost(1))
		if(world.time < 30 * 600)//before the 30 minute mark
			ghostize(FALSE,SENTIENCE_ERASE) // Players despawned too early may not re-enter the game
	else
		ghostize(TRUE,SENTIENCE_ERASE)

	SEND_SIGNAL(mind, COMSIG_MIND_CRYOED)
	QDEL_NULL(src)

/mob/living/silicon/ai/verb/toggle_anchor()
	set category = "AI Commands"
	set name = "Toggle Floor Bolts"
	if(!isturf(loc)) // if their location isn't a turf
		return // stop
	if(stat)
		return
	if(incapacitated())
		if(battery < 50)
			to_chat(src, "<span class='warning'>Niewystarczająca moc zapasowa!</span>")
			return
		battery = battery - 50
		to_chat(src, "<span class='notice'>Kierujesz moc z baterii zapasowej, by poruszyć rygle.</span>")
	var/is_anchored = FALSE
	if(move_resist == MOVE_FORCE_VERY_STRONG)
		move_resist = MOVE_FORCE_NORMAL
	else
		is_anchored = TRUE
		move_resist = MOVE_FORCE_VERY_STRONG

	to_chat(src, "<b>[is_anchored ? "Kotwiczysz się" : "Odkotwiczasz się"].</b>")
	// the message in the [] will change depending whether or not the AI is anchored

/mob/living/silicon/ai/cancel_camera()
	..()
	if(ai_tracking_target)
		ai_stop_tracking()

/mob/living/silicon/ai/update_mobility() //If the AI dies, mobs won't go through it anymore
	if(stat != CONSCIOUS)
		mobility_flags = NONE
	else
		mobility_flags = ALL

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "Malfunction"
	if(control_disabled)
		to_chat(src, "<span class='warning'>Sterowanie bezprzewodowe jest wyłączone!</span>")
		return
	SSshuttle.cancelEvac(src)

/mob/living/silicon/ai/restrained(ignore_grab)
	. = 0

/mob/living/silicon/ai/Topic(href, href_list)
	..()
	if(usr != src)
		return
	if (href_list["close"])
		alerts_popup = null
	if (incapacitated())
		return
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"]) in GLOB.cameranet.cameras)
	if (href_list["showalerts"])
		ai_alerts()
#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif
	if(href_list["show_tablet_note"])
		if(last_tablet_note_seen)
			src << browse(last_tablet_note_seen, "window=show_tablet")
	//Carn: holopad requests
	if(href_list["jumptoholopad"])
		var/obj/machinery/holopad/H = locate(href_list["jumptoholopad"]) in GLOB.machines
		if(H)
			H.attack_ai(src) //may as well recycle
		else
			to_chat(src, "<span class='notice'>Nie można zlokalizować holopadu.</span>")
	if(href_list["track"])
		var/string = href_list["track"]
		trackable_mobs()
		var/list/trackeable = list()
		trackeable += track.humans + track.others
		var/list/target = list()
		for(var/I in trackeable)
			var/datum/weakref/to_resolve = trackeable[I]
			var/mob/to_track = to_resolve.resolve()
			if(!to_track || to_track.name != string)
				continue
			target += to_track
		if(name == string)
			target += src
		if(target.len)
			ai_start_tracking(pick(target))
		else
			to_chat(src, "Cel nie znajduje się w zasięgu żadnej aktywnej kamery na stacji.")
		return
	/* NSV13 CHANGES START - Robot Remote Control TGUI Update
	if(href_list["callbot"]) //Command a bot to move to a selected location.
		if(call_bot_cooldown > world.time)
			to_chat(src, "<span class='danger'>Error: Your last call bot command is still processing, please wait for the bot to finish calculating a route.</span>")
			return
		Bot = locate(href_list["callbot"]) in GLOB.alive_mob_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = 1
		to_chat(src, "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>")
		return
	if(href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in GLOB.alive_mob_list
		if(!Bot || Bot.remote_disabled || control_disabled)
			return
		Bot.attack_ai(src)
	if(href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return
	NSV13 CHANGES END FOR NOW */

	if (href_list["ai_take_control"]) //Mech domination
		var/obj/mecha/M = locate(href_list["ai_take_control"]) in GLOB.mechas_list
		if (!M)
			return

		var/mech_has_controlbeacon = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in M.trackers)
			mech_has_controlbeacon = TRUE
			break
		if(!can_dominate_mechs && !mech_has_controlbeacon)
			message_admins("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			log_game("Warning: possible href exploit by [key_name(usr)] - attempted control of a mecha without can_dominate_mechs or a control beacon in the mech.")
			return

		if(controlled_mech)
			to_chat(src, "<span class='warning'>Już jesteś wczytany do komputera pokładowego!</span>")
			return
		if(!GLOB.cameranet.checkCameraVis(M))
			to_chat(src, "<span class='warning'>Egzoszkielet nie jest już w zasięgu aktywnych kamer.</span>")
			return
		if(!isturf(loc))
			to_chat(src, "<span class='warning'>Nie jesteś w swoim rdzeniu!</span>")
			return
		if(M)
			M.transfer_ai(AI_MECH_HACK, src, usr) //Called om the mech itself.
	if(href_list["show_paper_note"])
		var/obj/item/paper/paper_note = locate(href_list["show_paper_note"])
		if(!paper_note)
			return

		paper_note.show_through_camera(usr)

/mob/living/silicon/ai/proc/switchCamera(obj/machinery/camera/C)
	if(QDELETED(C))
		return FALSE

	if(ai_tracking_target)
		ai_stop_tracking()

	if(QDELETED(eyeobj))
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	return TRUE

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	/* NSV13 CHANGES START -- Robot Remote Control TGUI Update
	if(incapacitated())
		return

	if(control_disabled)
		to_chat(src, "<span class='warning'>Wireless control is disabled.</span>")
		return
	// NSV13 start -- checks if bot is in any occupied z level in the occupied overmap
	var/turf/ai_current_turf = get_turf(src)
	var/ai_Zlevel = ai_current_turf.get_virtual_z_level()
	var/valid_z = get_level_trait(ai_Zlevel)
	var/d
	d += "<A HREF=byond://?src=[REF(src)];botrefresh=1>Query network status</A><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"
	for (Bot in GLOB.alive_mob_list)
		if((Bot.get_virtual_z_level() in SSmapping.levels_by_trait(valid_z)) && !Bot.remote_disabled) // NSV13 end
			var/bot_mode = Bot.get_mode()
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!)</span>" : ""] [Bot.name]</A> ([Bot.model])</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='30%'>[bot_mode]</td>"
			d += "<td width='30%'>[get_area_name(Bot, TRUE)]</td>"
			d += "<td width='10%'><A HREF=byond://?src=[REF(src)];interface=[REF(Bot)]>Interface</A></td>"
			d += "<td width='10%'><A HREF=byond://?src=[REF(src)];callbot=[REF(Bot)]>Call</A></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Remote Robot Control", 700, 400)
	popup.set_content(d)
	popup.open()

	NSV13 CHANGES STOP */
	if(!robot_control) //NSV13
		robot_control = new(src) //NSV13

	robot_control.ui_interact(src) //NSV13

/mob/living/silicon/ai/proc/set_waypoint(atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(GLOB.cameranet && GLOB.cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		to_chat(src, "<span class='danger'>Wybrane miejsce nie jest widoczne.</span>")

/mob/living/silicon/ai/proc/call_bot(turf/waypoint)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		to_chat(src, "<span class='danger'>Błąd interfejsu. Jednostka jest już w użyciu.</span>")
		return
	to_chat(src, "<span class='notice'>Wysyłanie polecenia do bota...</span>")
	call_bot_cooldown = world.time + CALL_BOT_COOLDOWN
	Bot.call_bot(src, waypoint)
	call_bot_cooldown = 0

/mob/living/silicon/ai/triggerAlarm(class, area/home, cameras, obj/source)
	if(source.get_virtual_z_level() != get_virtual_z_level())
		return
	var/list/our_sort = alarms[class]
	for(var/areaname in our_sort)
		if (areaname == home.name)
			var/list/alarm = our_sort[areaname]
			var/list/sources = alarm[3]
			if (!(source in sources))
				sources += source
			return TRUE

	var/obj/machinery/camera/cam = null
	var/list/our_cams = null
	if(cameras && islist(cameras))
		our_cams = cameras
		if (our_cams.len == 1)
			cam = our_cams[1]
	else if(cameras && istype(cameras, /obj/machinery/camera))
		cam = cameras
	our_sort[home.name] = list(home, (cam ? cam : cameras), list(source))

	if (cameras)
		if (cam?.can_use())
			queueAlarm("--- Alarm ([class]) wykryty w [home.name]! (<A HREF=byond://?src=[REF(src)];switchcamera=[REF(cam)]>[cam.c_tag]</A>)", class)
		else if (our_cams?.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in our_cams)
				dat2 += text("[]<A HREF=byond://?src=[REF(src)];switchcamera=[REF(I)]>[]</A>", (!foo) ? "" : " | ", I.c_tag) //I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, home.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, home.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, home.name), class)
	update_ai_alerts()
	return 1

/mob/living/silicon/ai/freeCamera(area/home, obj/machinery/camera/cam)
	for(var/class in alarms)
		var/our_area = alarms[class][home.name]
		if(!our_area)
			continue
		var/cams = our_area[2] //Get the cameras
		if(!cams)
			continue
		if(islist(cams))
			cams -= cam
			if(length(cams) == 1)
				our_area[2] = cams[1]
		else
			our_area[2] = null

/mob/living/silicon/ai/cancelAlarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		queueAlarm("--- Alarm ([class]) w [A.name] został odwołany.", class, 0)
		update_ai_alerts()
	return !cleared

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	var/cameralist[0]

	if(incapacitated())
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		var/list/tempnetwork = C.network
		//Nsv13 - AIs need to see the Rocinante.
		if(!(SHARES_OVERMAP_ALLIED(C, src) || ("ss13" in tempnetwork)))
			continue
		if(!C.can_use())
			continue

		tempnetwork.Remove("rd", "toxins", "prison")
		if(tempnetwork.len)
			for(var/i in C.network)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Którą sieć chcesz oglądać?") as null|anything in sortList(cameralist)
	if(ai_tracking_target)
		ai_stop_tracking()
	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	to_chat(src, "<span class='notice'>Przełączono na sieć kamer \"[uppertext(network)]\".</span>")
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(incapacitated())
		return
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Thinking", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow")
	var/emote = input("Wybierz status!", "Status SI", null, null) in sortList(ai_emotions)
	for (var/each in GLOB.ai_status_displays) //change status of displays
		var/obj/machinery/status_display/ai/M = each
		M.emotion = emote
		M.update()
	if (emote == "Friend Computer")
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

		if(!frequency)
			return

		var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
		frequency.post_signal(src, status_signal)
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	if(incapacitated())
		return
	var/input
	switch(alert("Chcesz wybrać hologram oparty na członku załogi, zwierzęciu, czy unikalny awatar?",,"Crew Member","Unique","Animal"))
		if("Crew Member")
			var/list/personnel_list = list()

			for(var/datum/data/record/t in GLOB.data_core.locked)//Look in data core locked.
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

			if(personnel_list.len)
				input = input("Wybierz członka załogi:") as null|anything in sortList(personnel_list)
				var/icon/character_icon = personnel_list[input]
				if(character_icon)
					qdel(holo_icon)//Clear old icon so we're not storing it in memory.
					holo_icon = getHologramIcon(icon(character_icon))
			else
				alert("Nie znaleziono odpowiednich akt. Przerwano.")

		if("Animal")
			var/list/icon_list = list(
			"bear" = 'icons/mob/animal.dmi',
			"carp" = 'icons/mob/animal.dmi',
			"chicken" = 'icons/mob/animal.dmi',
			"corgi" = 'icons/mob/pets.dmi',
			"cow" = 'icons/mob/animal.dmi',
			"crab" = 'icons/mob/animal.dmi',
			"fox" = 'icons/mob/pets.dmi',
			"goat" = 'icons/mob/animal.dmi',
			"cat" = 'icons/mob/pets.dmi',
			"cat2" = 'icons/mob/pets.dmi',
			"poly" = 'icons/mob/animal.dmi',
			"pug" = 'icons/mob/pets.dmi',
			"spider" = 'icons/mob/animal.dmi'
			)

			input = input("Wybierz hologram:") as null|anything in sortList(icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					if("poly")
						holo_icon = getHologramIcon(icon(icon_list[input],"parrot_fly"))
					if("chicken")
						holo_icon = getHologramIcon(icon(icon_list[input],"chicken_brown"))
					if("spider")
						holo_icon = getHologramIcon(icon(icon_list[input],"guard"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))
		else
			var/list/icon_list = list(
				"default" = 'icons/mob/ai.dmi',
				"floating face" = 'icons/mob/ai.dmi',
				"xeno queen" = 'icons/mob/alien.dmi',
				"horror" = 'icons/mob/ai.dmi',
				"clock" = 'nsv13/icons/mob/ai_holo.dmi',
				"custom"
				) //NSV13 - Added Clockwork Hologram and Custom Hologram

			input = input("Wybierz hologram:") as null|anything in sortList(icon_list)
			if(input)
				qdel(holo_icon)
				switch(input)
					//NSV13 - AI Custom Holographic Form - Start
					if("custom")
						if(client?.prefs?.custom_holoform_icon)
							holo_icon = client.prefs.get_filtered_holoform(HOLOFORM_FILTER_AI)
						else
							holo_icon = getHologramIcon(icon('icons/mob/ai.dmi', "default"))
					//NSV13 - AI Custom Holographic Form - Stop
					if("xeno queen")
						holo_icon = getHologramIcon(icon(icon_list[input],"alienq"))
					else
						holo_icon = getHologramIcon(icon(icon_list[input], input))
	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		to_chat(src, "<span class='notice'>Już jesteś w swoim głównym rdzeniu.</span>")
		return
	apc.malfvacate()

/mob/living/silicon/ai/proc/toggle_camera_light()
	camera_light_on = !camera_light_on

	if (!camera_light_on)
		to_chat(src, "Światła kamer wyłączone.")

		for (var/obj/machinery/camera/C in lit_cameras)
			C.set_light(0)
			lit_cameras = list()

		return

	light_cameras()

	to_chat(src, "Światła kamer włączone.")

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if (!C.can_use() || get_dist(C, eyeobj) > 7 || !C.internal_light)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		lit_cameras -= C //Removed from list before turning off the light so that it doesn't check the AI looking away.
		C.Togglelight(0)
	for (var/obj/machinery/camera/C in add)
		C.Togglelight(1)
		lit_cameras |= C

/mob/living/silicon/ai/proc/control_integrated_radio()
	set name = "Transceiver Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	if(incapacitated())
		return

	to_chat(src, "Uzyskiwanie dostępu do sterowania nadajnikiem podprzestrzennym...")
	if (radio)
		radio.interact(src)

/mob/living/silicon/ai/proc/set_syndie_radio()
	if(radio)
		radio.make_syndie()

/mob/living/silicon/ai/proc/set_automatic_say_channel()
	set name = "Set Auto Announce Mode"
	set desc = "Modify the default radio setting for your automatic announcements."
	set category = "AI Commands"

	if(incapacitated())
		return
	set_autosay()

/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	if(interaction == AI_TRANS_TO_CARD)//The only possible interaction. Upload AI mob to a card.
		if(!can_be_carded)
			to_chat(user, "<span class='boldwarning'>Transfer nieudany.</span>")
			return
		disconnect_shell() //If the AI is controlling a borg, force the player back to core!
		if(!mind)
			to_chat(user, "<span class='warning'>Nie wykryto wzorców inteligencji.</span>"    )
			return
		ShutOffDoomsdayDevice()
		var/obj/structure/AIcore/new_core = new /obj/structure/AIcore/deactivated(loc)//Spawns a deactivated terminal at AI location.
		new_core.circuit.battery = battery
		ai_restore_power()//So the AI initially has power.
		control_disabled = TRUE //Can't control things remotely if you're stuck in a card!
		radio_enabled = FALSE 	//No talking on the built-in radio for you either!
		forceMove(card)
		card.AI = src
		to_chat(src, "Zostajesz pobrany na przenośne urządzenie pamięci. Połączenie ze zdalnym urządzeniem zerwane.")
		to_chat(user, "<span class='boldnotice'>Transfer zakończony sukcesem</span>: [name] ([rand(1000,9999)].exe) usunięto z terminala i zapisano w pamięci lokalnej.")

/mob/living/silicon/ai/can_buckle()
	return 0

/mob/living/silicon/ai/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, check_immobilized = FALSE, ignore_stasis = FALSE)
	if(aiRestorePowerRoutine)
		return TRUE
	return ..()

/mob/living/silicon/ai/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(control_disabled || incapacitated())
		to_chat(src, "<span class='warning'>Nie możesz teraz tego zrobić!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>Jesteś za daleko!</span>")
		return FALSE
	return can_see(M) //stop AIs from leaving windows open and using then after they lose vision

/mob/living/silicon/ai/proc/can_see(atom/A)
	if(isturf(loc)) //AI in core, check if on cameras
		//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
		//apc_override is needed here because AIs use their own APC when depowered
		return (GLOB.cameranet && GLOB.cameranet.checkTurfVis(get_turf_pixel(A))) || apc_override == A
	//AI is carded/shunted
	//view(src) returns nothing for carded/shunted AIs and they have X-ray vision so just use get_dist
	var/list/viewscale = getviewsize(client.view)
	return get_dist(src, A) <= max(viewscale[1]*0.5,viewscale[2]*0.5)

/mob/living/silicon/ai/proc/relay_speech(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	var/treated_message = lang_treat(speaker, message_language, raw_message, spans, message_mods)
	var/start = "Przekazana mowa: "
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	var/hrefpart = "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	var/jobpart = "Unknown"

	if (ishuman(speaker))
		var/mob/living/carbon/human/S = speaker
		if(S.wear_id)
			var/obj/item/card/id/I = S.wear_id.GetID()
			if(I)
				jobpart = "[I.assignment]"

	var/rendered = "<i><span class='game say'>[start]<span class='name'>[hrefpart][namepart] ([jobpart])</a> </span><span class='message'>[treated_message]</span></span></i>"

	show_message(rendered, 2)

/mob/living/silicon/ai/fully_replace_character_name(oldname,newname)
	..()
	if(oldname != real_name)
		if(eyeobj)
			eyeobj.name = "[newname] (AI Eye)"
			modularInterface.saved_identification = real_name

		// Notify Cyborgs
		for(var/mob/living/silicon/robot/Slave in connected_robots)
			Slave.show_laws()

/mob/living/silicon/ai/proc/add_malf_picker()
	to_chat(src, "W prawym górnym rogu ekranu znajdziesz zakładkę Malfunctions, w której możesz kupować różne zdolności, od ulepszonej inwigilacji po urządzenia zagłady niszczące stację.")
	to_chat(src, "Możesz też hakować APC, co daje ci więcej punktów na zdolności awarii. Wadą jest to, że zhakowane APC zdradzi cię, jeśli załoga je zauważy. Hakowanie APC trwa 60 sekund.")
	view_core() //A BYOND bug requires you to be viewing your core before your verbs update
	add_verb(/mob/living/silicon/ai/proc/choose_modules)
	malf_picker = new /datum/module_picker


/mob/living/silicon/ai/reset_perspective(atom/A)
	if(camera_light_on)
		light_cameras()
	if(istype(A, /obj/machinery/camera))
		current = A
	if(client)
		if(ismovableatom(A))
			if(A != GLOB.ai_camera_room_landmark)
				end_multicam()
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			end_multicam()
			if(isturf(loc))
				if(eyeobj)
					client.eye = eyeobj
					client.perspective = EYE_PERSPECTIVE
				else
					client.eye = client.mob
					client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
		update_sight()
		if(client.eye != src)
			var/atom/AT = client.eye
			AT.get_remote_view_fullscreens(src)
		else
			clear_fullscreen("remote_view", 0)

/mob/living/silicon/ai/revive(full_heal = 0, admin_revive = 0)
	. = ..()
	if(.) //successfully ressuscitated from death
		set_core_display_icon(display_icon_override)
		set_eyeobj_visible(TRUE)

/mob/living/silicon/ai/proc/malfhacked(obj/machinery/power/apc/apc)
	malfhack = null
	malfhacking = 0
	clear_alert("hackingapc")

	if(!istype(apc) || QDELETED(apc) || apc.machine_stat & BROKEN)
		to_chat(src, "<span class='danger'>Hakowanie przerwane. Wskazane APC nie istnieje już w sieci energetycznej.</span>")
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', 50, 1, ignore_walls = FALSE)
	else if(apc.aidisabled)
		to_chat(src, "<span class='danger'>Hakowanie przerwane. [apc] nie odpowiada już naszym systemom.</span>")
		playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1, ignore_walls = FALSE)
	else
		malf_picker.processing_time += 10

		apc.malfai = parent || src
		apc.malfhack = TRUE
		apc.locked = TRUE
		apc.coverlocked = TRUE

		playsound(get_turf(src), 'sound/machines/ding.ogg', 50, 1, ignore_walls = FALSE)
		to_chat(src, "Hakowanie zakończone. [apc] jest teraz pod twoją wyłączną kontrolą.")
		apc.update_icon()

/mob/living/silicon/ai/verb/deploy_to_shell(var/mob/living/silicon/robot/target)
	set category = "AI Commands"
	set name = "Deploy to Shell"

	if(incapacitated())
		return
	if(control_disabled)
		to_chat(src, "<span class='warning'>Moduł sieci bezprzewodowej jest wyłączony.</span>")
		return

	var/list/possible = list()

	for(var/borgie in GLOB.available_ai_shells)
		var/mob/living/silicon/robot/R = borgie
		if(R.shell && !R.deployed && (R.stat != DEAD) && (!R.connected_ai ||(R.connected_ai == src)) || (R.ratvar && !is_servant_of_ratvar(src)))
			possible += R

	if(!LAZYLEN(possible))
		to_chat(src, "Nie wykryto żadnych użytecznych nadajników powłok SI.")

	if(!target || !(target in possible)) //If the AI is looking for a new shell, or its pre-selected shell is no longer valid
		target = input(src, "Którym ciałem sterować?") as null|anything in sortNames(possible)

	if (!target || target.stat || target.deployed || !(!target.connected_ai ||(target.connected_ai == src)) || (target.ratvar && !is_servant_of_ratvar(src)))
		return

	if(target.is_jammed())
		to_chat(src, "<span class='warning robot'>Nie można nawiązać łączności z celem.</span>")
		return

	else if(mind)
		soullink(/datum/soullink/sharedbody, src, target)
		deployed_shell = target
		if(is_servant_of_ratvar(src) && !deployed_shell.ratvar)
			deployed_shell.SetRatvar(TRUE)
		target.deploy_init(src)
		mind.transfer_to(target)
	diag_hud_set_deployed()

/datum/action/innate/deploy_shell
	name = "Deploy to AI Shell"
	desc = "Wirelessly control a specialized cyborg shell."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_shell"

/datum/action/innate/deploy_shell/Trigger()
	var/mob/living/silicon/ai/AI = owner
	if(!AI)
		return
	AI.deploy_to_shell()

/datum/action/innate/deploy_last_shell
	name = "Reconnect to shell"
	desc = "Reconnect to the most recently used AI shell."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_last_shell"
	var/mob/living/silicon/robot/last_used_shell

/datum/action/innate/deploy_last_shell/Trigger()
	if(!owner)
		return
	if(last_used_shell)
		var/mob/living/silicon/ai/AI = owner
		AI.deploy_to_shell(last_used_shell)
	else
		Remove(owner) //If the last shell is blown, destroy it.

/mob/living/silicon/ai/proc/disconnect_shell()
	if(deployed_shell) //Forcibly call back AI in event of things such as damage, EMP or power loss.
		to_chat(src, "<span class='danger'>Twoje zdalne połączenie zostało zresetowane!</span>")
		deployed_shell.undeploy()
	diag_hud_set_deployed()

/mob/living/silicon/ai/resist()
	return

/mob/living/silicon/ai/spawned/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	if(!target_ai)
		target_ai = src //cheat! just give... ourselves as the spawned AI, because that's technically correct
	. = ..() //This needs to be lower so we have a chance to actually update the assigned target_ai.

/mob/living/silicon/ai/proc/camera_visibility(mob/camera/ai_eye/moved_eye)
	GLOB.cameranet.visibility(moved_eye, client, all_eyes, TRUE)

/mob/living/silicon/ai/forceMove(atom/destination)
	. = ..()
	if(.)
		end_multicam()

/mob/living/silicon/ai/zMove(dir, feedback = FALSE)
	. = eyeobj.zMove(dir, feedback)

