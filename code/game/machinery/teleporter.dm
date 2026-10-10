/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/machines/teleporter.dmi'
	density = TRUE

/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 3000
	circuit = /obj/item/circuitboard/machine/teleporter_hub
	var/accuracy = 0
	var/obj/machinery/teleport/station/power_station
	var/calibrated //Calibration prevents mutation

/obj/machinery/teleport/hub/Initialize(mapload)
	. = ..()
	link_power_station()

/obj/machinery/teleport/hub/Destroy()
	if (power_station)
		if(power_station.teleporter_console)
			power_station.teleporter_console.ui_update()
		power_station?.teleporter_hub = null
		power_station = null
	return ..()

/obj/machinery/teleport/hub/RefreshParts()
	var/A = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		A += M.rating
	accuracy = A

/obj/machinery/teleport/hub/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: prawdopodobieństwo awarii zmniejszone o <b>[(accuracy-1)*100/3]%</b>.</span>"

/obj/machinery/teleport/hub/proc/link_power_station()
	if(power_station)
		return
	for(var/direction in GLOB.cardinals)
		power_station = locate(/obj/machinery/teleport/station, get_step(src, direction))
		if(power_station)
			break
	return power_station

/obj/machinery/teleport/hub/Bumped(atom/movable/AM)
	if(is_centcom_level(z))
		to_chat(AM, "Nie możesz tego tu użyć.")
		return
	if(is_ready())
		teleport(AM)

/obj/machinery/teleport/hub/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "tele-o", "tele0", W))
		if(power_station?.engaged)
			power_station.engaged = 0 //hub with panel open is off, so the station must be informed.
			update_icon()
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj, turf/T)
	var/obj/machinery/computer/teleporter/com = power_station.teleporter_console
	if (QDELETED(com))
		return
	var/atom/target
	if(com.target_ref)
		target = com.target_ref.resolve()
	if (!target)
		com.target_ref = null
		visible_message("<span class='alert'>Nie można uwierzytelnić namierzonych współrzędnych. Przywróć matrycę współrzędnych.</span>")
		return
	if (ismovableatom(M))
		if(do_teleport(M, target, channel = TELEPORT_CHANNEL_BLUESPACE))
			use_power(7500)
			if(!calibrated && prob(40 - ((accuracy) * 10))) //oh dear a problem
				if(ishuman(M))//don't remove people from the round randomly you jerks
					var/mob/living/carbon/human/human = M
					if(human.dna && !isflyperson(human) && !HAS_TRAIT(M, TRAIT_RADIMMUNE))
						log_game("[M] ([key_name(M)]) was turned into a fly person")
						to_chat(M, "<span class='italics'>Słyszysz brzęczenie w uszach.</span>")
						human.set_species(/datum/species/fly)

					human.apply_effect((rand(160 - accuracy * 40, 240 - accuracy * 60)), EFFECT_IRRADIATE, 0)
			calibrated = 0
	return

/obj/machinery/teleport/hub/update_icon()
	if(panel_open)
		icon_state = "tele-o"
	else if(is_ready())
		icon_state = "tele1"
	else
		icon_state = "tele0"

/obj/machinery/teleport/hub/power_change()
	..()
	update_icon()

/obj/machinery/teleport/hub/proc/is_ready()
	. = !panel_open && !(machine_stat & (BROKEN|NOPOWER)) && power_station && power_station.engaged && !(power_station.machine_stat & (BROKEN|NOPOWER))

/obj/machinery/teleport/hub/syndicate/Initialize(mapload)
	. = ..()
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	RefreshParts()


/obj/machinery/teleport/station
	name = "teleporter station"
	desc = "The power control station for a bluespace teleporter. Used for toggling power, and can activate a test-fire to prevent malfunctions."
	icon_state = "controller"
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/teleporter_station
	var/engaged = FALSE
	var/obj/machinery/computer/teleporter/teleporter_console
	var/obj/machinery/teleport/hub/teleporter_hub
	var/list/linked_stations = list()
	var/efficiency = 0

/obj/machinery/teleport/station/Initialize(mapload)
	. = ..()
	link_console_and_hub()

/obj/machinery/teleport/station/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E - 1

/obj/machinery/teleport/station/examine(mob/user)
	. = ..()
	if(!panel_open)
		. += "<span class='notice'>Panel jest <i>przykręcony</i>, zasłaniając urządzenie łączące i panel przewodów.</span>"
	else
		. += "<span class='notice'>Urządzenie <i>łączące</i> można teraz <i>zeskanować</i> multitoolem.<br><i>Okablowanie</i> można <i>połączyć</i> z pobliską konsolą i hubem za pomocą nożyc do drutu.</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: tę stację można połączyć z <b>[efficiency]</b> innymi stacjami.</span>"

/obj/machinery/teleport/station/proc/link_console_and_hub()
	for(var/direction in GLOB.cardinals)
		teleporter_hub = locate(/obj/machinery/teleport/hub, get_step(src, direction))
		if(teleporter_hub)
			teleporter_hub.link_power_station()
			break
	for(var/direction in GLOB.cardinals)
		teleporter_console = locate(/obj/machinery/computer/teleporter, get_step(src, direction))
		if(teleporter_console)
			teleporter_console.link_power_station()
			teleporter_console.ui_update()
			break
	return teleporter_hub && teleporter_console


/obj/machinery/teleport/station/Destroy()
	if(teleporter_hub)
		teleporter_hub.power_station = null
		teleporter_hub.update_icon()
		teleporter_hub = null
	if (teleporter_console)
		teleporter_console.ui_update()
		teleporter_console.power_station = null
		teleporter_console = null
	return ..()

/obj/machinery/teleport/station/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/M = W
		if(panel_open)
			M.buffer = src
			to_chat(user, "<span class='caution'>Pobierasz dane do bufora [W.name].</span>")
		else
			if(M.buffer && istype(M.buffer, /obj/machinery/teleport/station) && M.buffer != src)
				if(linked_stations.len < efficiency)
					linked_stations.Add(M.buffer)
					M.buffer = null
					to_chat(user, "<span class='caution'>Wgrywasz dane z bufora [W.name].</span>")
				else
					to_chat(user, "<span class='alert'>Ta stacja nie pomieści więcej informacji, spróbuj użyć lepszych części.</span>")
		return
	else if(default_deconstruction_screwdriver(user, "controller-o", "controller", W))
		update_icon()
		return

	else if(default_deconstruction_crowbar(W))
		return

	else if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(panel_open)
			link_console_and_hub()
			to_chat(user, "<span class='caution'>Ponownie łączysz stację z pobliskimi urządzeniami.</span>")
			return
	else
		return ..()

/obj/machinery/teleport/station/interact(mob/user)
	toggle(user)

/obj/machinery/teleport/station/proc/toggle(mob/user)
	if(machine_stat & (BROKEN|NOPOWER) || !teleporter_hub || !teleporter_console )
		return
	if(teleporter_hub.panel_open || teleporter_hub.machine_stat & (BROKEN|NOPOWER))
		to_chat(user, "<span class='alert'>Hub teleportera nie odpowiada.</span>")
		return
	if (teleporter_console.target_ref?.resolve())
		engaged = !engaged
		use_power(5000)
		to_chat(user, "<span class='notice'>Teleporter [engaged ? "włączony" : "wyłączony"]!</span>")
	else
		teleporter_console.target_ref = null
		to_chat(user, "<span class='alert'>Nie wykryto celu.</span>")
		engaged = FALSE
	teleporter_hub.update_icon()
	add_fingerprint(user)

/obj/machinery/teleport/station/power_change()
	..()
	update_icon()
	if(teleporter_hub)
		teleporter_hub.update_icon()

/obj/machinery/teleport/station/update_icon()
	if(panel_open)
		icon_state = "controller-o"
	else if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "controller-p"
	else if(teleporter_console && teleporter_console.calibrating)
		icon_state = "controller-c"
	else
		icon_state = "controller"
