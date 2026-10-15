// Port of BeeStation/BeeStation-Hornet#10232 and #14152 - wall-mounted digital clock showing station time.

/// The subsystem used to tick digital clocks
PROCESSING_SUBSYSTEM_DEF(digital_clock)
	name = "Digital Clocks"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_KEEP_TIMING
	wait = 1 SECONDS

#define COOLDOWN_CLOCK_WMCHIMES "clock_wmchimes"

/obj/machinery/digital_clock
	name = "zegar cyfrowy"
	desc = "Nowoczesny, zwyczajny zegar cyfrowy pokazujący czas pokładowy. <i>Nie myl go z czasem zmiany!</i>"
	icon_state = "digital_clock_base"
	icon = 'aquila/icons/obj/digital_clock.dmi'
	verb_say = "pika"
	verb_ask = "popiskuje"
	verb_exclaim = "wyje"
	max_integrity = 250
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	subsystem_type = /datum/controller/subsystem/processing/digital_clock
	var/station_minutes
	var/station_hours
	/// The time the overlays show now, so they are only rebuilt when it changes
	var/shown_time

/obj/machinery/digital_clock/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/wallframe/digital_clock
	name = "rama zegara cyfrowego"
	desc = "Służy do budowy zegarów cyfrowych. Wystarczy przymocować do ściany."
	icon_state = "digital_clock"
	icon = 'aquila/icons/obj/digital_clock_frame.dmi'
	custom_materials = list(/datum/material/iron = 700, /datum/material/glass = 400)
	result_path = /obj/machinery/digital_clock
	pixel_shift = -28

/datum/design/digital_clock_frame
	name = "Digital Clock Frame"
	id = "digital_clock_frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 700, /datum/material/glass = 400)
	build_path = /obj/item/wallframe/digital_clock
	category = list("initial", "Construction")

/obj/machinery/digital_clock/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz odkręcać [name]...</span>")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		to_chat(user, "<span class='notice'>Odkręcasz [name].</span>")
		deconstruct()
	return TRUE

/obj/machinery/digital_clock/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "nie wymaga naprawy!")
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz naprawiać [name]...</span>")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume = 50))
		return TRUE
	to_chat(user, "<span class='notice'>Kończysz naprawiać [name].</span>")
	obj_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/machinery/digital_clock/multitool_act(mob/living/user, obj/item/tool)
	if(user.combat_mode || !(obj_flags & EMAGGED))
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz resetować [name]...</span>")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		to_chat(user, "<span class='notice'>Resetujesz [name].</span>")
		obj_flags &= ~EMAGGED
	return TRUE

/obj/machinery/digital_clock/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>Zwierasz układ czasomierza zegara!</span>")
	playsound(src, "sparks", 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)

/obj/machinery/digital_clock/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new /obj/item/wallframe/digital_clock(loc)
		else
			new /obj/item/stack/sheet/iron(loc, 2)
			new /obj/item/shard(loc)
			new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/digital_clock/power_change()
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)))
		update_time()
	update_appearance()

/obj/machinery/digital_clock/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	update_time()
	if((station_hours == 0 || station_hours == 12) && station_minutes == 0 && !(obj_flags & EMAGGED))
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_CLOCK_WMCHIMES))
			playsound(loc, 'aquila/sound/machines/westminister_chimes.ogg', 75)
			TIMER_COOLDOWN_START(src, COOLDOWN_CLOCK_WMCHIMES, 70 SECONDS)
	var/new_time = "[station_hours]:[station_minutes]"
	if(new_time != shown_time)
		shown_time = new_time
		update_appearance()

/obj/machinery/digital_clock/update_appearance(updates = ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(l_range = 1.5, l_power = 0.7, l_color = LIGHT_COLOR_BLUE)

/obj/machinery/digital_clock/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(isnull(station_hours))
		update_time()
	. += time_overlays()

/obj/machinery/digital_clock/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += "<span class='warning'>Coś jest nie tak z tą godziną!</span>"
	else
		. += "<span class='notice'>Czas pokładowy: [station_time_timestamp("hh:mm")].</span>"

/obj/machinery/digital_clock/proc/update_time()
	if(obj_flags & EMAGGED)
		station_hours = rand(0, 99)
		station_minutes = rand(0, 99)
	else
		station_hours = text2num(station_time_timestamp("hh"))
		station_minutes = text2num(station_time_timestamp("mm"))

/obj/machinery/digital_clock/proc/time_overlays()
	. = list()
	// Digits from right to left: minute ones, minute tens, separator, hour ones, hour tens
	. += clock_digit(station_minutes % 10, 0)
	. += clock_digit(round(station_minutes / 10), -4)
	. += mutable_appearance(icon, "+separator")
	. += clock_digit(station_hours % 10, -10)
	. += clock_digit(round(station_hours / 10), -14)

/obj/machinery/digital_clock/proc/clock_digit(digit, offset)
	var/mutable_appearance/digit_overlay = mutable_appearance(icon, "+[digit]")
	digit_overlay.pixel_x = offset
	return digit_overlay

/obj/machinery/digital_clock/directional/north
	dir = SOUTH
	pixel_y = 28

/obj/machinery/digital_clock/directional/south
	dir = NORTH
	pixel_y = -28

/obj/machinery/digital_clock/directional/east
	dir = WEST
	pixel_x = 28

/obj/machinery/digital_clock/directional/west
	dir = EAST
	pixel_x = -28

#undef COOLDOWN_CLOCK_WMCHIMES
