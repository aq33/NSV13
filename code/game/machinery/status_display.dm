// Status display
// (formerly Countdown timer display)
// Aquila: text rendering ported from tgstation/tgstation (#64828, #64858, #69153, #76356, #78242) -
// pixel font overlays that scroll smoothly on the client instead of a server-side character marquee.

#define MAX_STATIC_WIDTH 22
#define FONT_STYLE "12pt 'TinyUnicode'"
#define SCROLL_RATE (0.04 SECONDS) // time per pixel
#define SCROLL_PADDING 2 // how many pixels we chop to make a smooth loop
#define LINE1_X 1
#define LINE1_Y -4
#define LINE2_X 1
#define LINE2_Y -11
#define STATUS_DISPLAY_FONT_DATUM /datum/font/tiny_unicode/size_12pt

#define SD_BLANK 0  // 0 = Blank
#define SD_EMERGENCY 1  // 1 = Emergency Shuttle timer
#define SD_MESSAGE 2  // 2 = Arbitrary message(s)
#define SD_PICTURE 3  // 3 = alert picture

#define SD_AI_EMOTE 1  // 1 = AI emoticon
#define SD_AI_BSOD 2  // 2 = Blue screen of death

/// Status display which can show images and scrolling text.
/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	layer = ABOVE_WINDOW_LAYER

	var/obj/effect/overlay/status_display_text/message1_overlay
	var/obj/effect/overlay/status_display_text/message2_overlay
	var/current_picture = ""
	var/current_mode = SD_BLANK
	var/message1 = ""
	var/message2 = ""

	/// Normal text color
	var/text_color = "#09F"
	/// Color for headers, eg. "- ETA -"
	var/header_text_color = "#2CF"

/obj/machinery/status_display/Initialize(mapload, ndir, building)
	. = ..()
	update_appearance()

/obj/machinery/status_display/Destroy()
	remove_messages()
	return ..()

/obj/machinery/status_display/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "nie wymaga naprawy!")
		return TRUE
	balloon_alert(user, "naprawiasz...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume = 50))
		return TRUE
	balloon_alert(user, "naprawiono")
	obj_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/// Immediately blank the display.
/obj/machinery/status_display/proc/remove_display()
	current_picture = ""
	set_messages("", "")
	update_appearance()

/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	current_picture = state
	set_messages("", "")
	update_appearance()

/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/set_messages(line1, line2)
	line1 = display_text(line1)
	line2 = display_text(line2)

	var/message_changed = FALSE
	if(line1 != message1)
		message1 = line1
		message_changed = TRUE

	if(line2 != message2)
		message2 = line2
		message_changed = TRUE

	if(message_changed)
		if(message1 != "" || message2 != "")
			current_picture = ""
		update_appearance()

/// Kept for old callers: the overlays scroll by themselves, so this just sets the lines.
/obj/machinery/status_display/proc/set_message(m1, m2)
	set_messages(m1, m2)

/// Kept for old callers.
/obj/machinery/status_display/proc/update_display(line1, line2)
	set_messages(line1, line2)

/// Uppercase text for the display. TinyUnicode has no glyphs for Ń, Ś and Ż, so those lose their accents.
/obj/machinery/status_display/proc/display_text(text)
	text = uppertext("[text]")
	text = replacetext(text, "Ń", "N")
	text = replacetext(text, "Ś", "S")
	text = replacetext(text, "Ż", "Z")
	return text

/**
 * Remove both message objs and null the fields.
 * Don't call this in subclasses.
 */
/obj/machinery/status_display/proc/remove_messages()
	if(message1_overlay)
		vis_contents -= message1_overlay
		QDEL_NULL(message1_overlay)
	if(message2_overlay)
		vis_contents -= message2_overlay
		QDEL_NULL(message2_overlay)

/**
 * Create/update message overlay.
 * They must be handled as real objects for the animation to run.
 * Don't call this in subclasses.
 * Returns new /obj/effect/overlay/status_display_text or null if unchanged.
 */
/obj/machinery/status_display/proc/update_message(obj/effect/overlay/status_display_text/overlay, line_y, message, x_offset, line_pair)
	if(overlay && message == overlay.message)
		return null

	if(overlay)
		vis_contents -= overlay
		qdel(overlay)

	var/obj/effect/overlay/status_display_text/new_status_display_text = new(src, line_y, message, text_color, header_text_color, x_offset, line_pair)
	vis_contents += new_status_display_text
	return new_status_display_text

/obj/machinery/status_display/update_appearance(updates = ALL)
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || (current_picture == "" && message1 == "" && message2 == ""))
		set_light(0)
		return
	set_light(1.5, 0.7, LIGHT_COLOR_BLUE)

/obj/machinery/status_display/update_overlays()
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		remove_messages()
		return

	if(current_picture != "")
		remove_messages()
		. += mutable_appearance(icon, current_picture)
		if(current_picture == "ai_off")
			return
	else
		if(message1 == "" && message2 == "")
			remove_messages()
			return
		var/datum/font/display_font = new STATUS_DISPLAY_FONT_DATUM()
		var/line_pair = max(display_font.get_metrics(message1), display_font.get_metrics(message2))

		var/overlay = update_message(message1_overlay, LINE1_Y, message1, LINE1_X, line_pair)
		if(overlay)
			message1_overlay = overlay
		overlay = update_message(message2_overlay, LINE2_Y, message2, LINE2_X, line_pair)
		if(overlay)
			message2_overlay = overlay

	. += emissive_appearance(icon, "outline", alpha = alpha)

// Timed process - performs nothing in the base class
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
	return PROCESS_KILL

/// Update the display and, if necessary, re-enable processing.
/obj/machinery/status_display/proc/update()
	if (process(SSMACHINES_DT) != PROCESS_KILL)
		START_PROCESSING(SSmachines, src)

/obj/machinery/status_display/power_change()
	. = ..()
	update()

/obj/machinery/status_display/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return
	set_picture("ai_bsod")

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if (message1 || message2)
		. += "Wyświetlacz pokazuje:"
		if (message1)
			. += "\t<tt>[html_encode(message1)]</tt>"
		if (message2)
			. += "\t<tt>[html_encode(message2)]</tt>"

// Helper procs for child display types.
/obj/machinery/status_display/proc/display_shuttle_status(obj/docking_port/mobile/shuttle)
	if(!shuttle)
		// the shuttle is missing - no processing
		set_messages("shutl", "nie działa")
		return PROCESS_KILL
	else if(shuttle.timer)
		set_messages("-[shuttle.getModeStr()]-", shuttle.getTimerStr())
	else
		// don't kill processing, the timer might turn back on
		set_messages("", "")

/obj/machinery/status_display/proc/examine_shuttle(mob/user, obj/docking_port/mobile/shuttle)
	if (shuttle)
		var/modestr = shuttle.getModeStr()
		if (modestr)
			if (shuttle.timer)
				modestr = "<br>\t<tt>[modestr]: [shuttle.getTimerStr()]</tt>"
			else
				modestr = "<br>\t<tt>[modestr]</tt>"
		return "Wyświetlacz pokazuje:<br>\t<tt>[shuttle.name]</tt>[modestr]"
	else
		return "Wyświetlacz pokazuje:<br>\t<tt>Brak promu!</tt>"

/**
 * Nice overlay to make text smoothly scroll with no client updates after setup.
 */
/obj/effect/overlay/status_display_text
	icon = 'icons/obj/status_display.dmi'
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

	/// The message this overlay is displaying.
	var/message

	// If the line is short enough to not marquee, and it matches this, it's a header.
	var/static/regex/header_regex = regex("^-.*-$")

/obj/effect/overlay/status_display_text/Initialize(mapload, yoffset, line, text_color, header_text_color, xoffset = 0, line_pair)
	. = ..()

	maptext_y = yoffset
	message = line

	var/datum/font/display_font = new STATUS_DISPLAY_FONT_DATUM()
	var/line_width = display_font.get_metrics(line)

	if(line_width > MAX_STATIC_WIDTH)
		// Marquee text
		var/marquee_message = "[line]    [line]    [line]"

		// Width of full content. Most of this is never revealed unless the user inputted a single character.
		var/full_marquee_width = display_font.get_metrics("[marquee_message]    ")
		// We loop after only this much has passed.
		var/looping_marquee_width = (display_font.get_metrics("[line]    ]") - SCROLL_PADDING)

		maptext = generate_text(marquee_message, center = FALSE, text_color = text_color)
		maptext_width = full_marquee_width
		maptext_x = 0

		// Mask off to fit in screen.
		add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "outline")))

		// Scroll.
		var/time = line_pair * SCROLL_RATE
		animate(src, maptext_x = (-looping_marquee_width) + MAX_STATIC_WIDTH, time = time, loop = -1)
		animate(maptext_x = MAX_STATIC_WIDTH, time = 0)
	else
		// Centered text
		var/color = header_regex.Find(line) ? header_text_color : text_color
		maptext = generate_text(line, center = TRUE, text_color = color)
		maptext_x = xoffset //Defaults to 0, this would be centered unless overided

/**
 * Generate the actual maptext.
 * Arguments:
 * * text - the text to display
 * * center - center the text if TRUE, otherwise right-align (the direction the text is coming from)
 * * text_color - the text color
 */
/obj/effect/overlay/status_display_text/proc/generate_text(text, center, text_color)
	return {"<div style="color:[text_color];font:[FONT_STYLE];[center ? "text-align:center" : "text-align:right"]" valign="top">[text]</div>"}

/// Evac display which shows shuttle timer or message set by Command.
/obj/machinery/status_display/evac
	current_mode = SD_EMERGENCY
	var/frequency = FREQ_STATUS_DISPLAYS
	var/friendc = FALSE      // track if Friend Computer mode
	var/last_picture  // For when Friend Computer mode is undone

/obj/machinery/status_display/evac/Initialize(mapload)
	. = ..()
	// register for radio system
	SSradio.add_object(src, frequency)

/obj/machinery/status_display/evac/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/status_display/evac/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	if(friendc) //Makes all status displays except supply shuttle timer display the eye -- Urist
		set_picture("ai_friend")
		return PROCESS_KILL

	switch(current_mode)
		if(SD_BLANK)
			remove_display()
			return PROCESS_KILL

		if(SD_EMERGENCY)
			return display_shuttle_status(SSshuttle.emergency)

		if(SD_MESSAGE)
			return PROCESS_KILL

		if(SD_PICTURE)
			set_picture(last_picture)
			return PROCESS_KILL

/obj/machinery/status_display/evac/examine(mob/user)
	. = ..()
	if(current_mode == SD_EMERGENCY)
		. += examine_shuttle(user, SSshuttle.emergency)
	else if(!message1 && !message2)
		. += "Wyświetlacz jest pusty."

/obj/machinery/status_display/evac/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			current_mode = SD_BLANK
			remove_display()
		if("shuttle")
			current_mode = SD_EMERGENCY
			current_picture = ""
			set_messages("", "")
		if("message")
			current_mode = SD_MESSAGE
			set_messages(signal.data["msg1"] || signal.data["top_text"] || "", signal.data["msg2"] || signal.data["bottom_text"] || "")
		if("alert")
			current_mode = SD_PICTURE
			last_picture = signal.data["picture_state"]
			set_picture(last_picture)
		if("friendcomputer")
			friendc = !friendc
	update()


/// Supply display which shows the status of the supply shuttle.
/obj/machinery/status_display/supply
	name = "supply display"
	current_mode = SD_MESSAGE
	text_color = "#F90"
	header_text_color = "#FC2"

/obj/machinery/status_display/supply/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	var/line1
	var/line2
	if(!SSshuttle.supply)
		// Might be missing in our first update on initialize before shuttles
		// have loaded. Cross our fingers that it will soon return.
		line1 = "CARGO"
		line2 = "shutl?"
	else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(is_station_level(SSshuttle.supply.z))
			line1 = "CARGO"
			line2 = "Docked"
		else
			line1 = ""
			line2 = ""
	else
		line1 = SSshuttle.supply.getModeStr()
		line2 = SSshuttle.supply.getTimerStr()
	set_messages(line1, line2)

/obj/machinery/status_display/supply/examine(mob/user)
	. = ..()
	var/obj/docking_port/mobile/shuttle = SSshuttle.supply
	if(!shuttle)
		. += "Wyświetlacz jest pusty."
		return
	var/shuttleMsg = null
	if (shuttle.mode == SHUTTLE_IDLE)
		if (is_station_level(shuttle.z))
			shuttleMsg = "Docked"
	else
		shuttleMsg = "[shuttle.getModeStr()]: [shuttle.getTimerStr()]"
	if (shuttleMsg)
		. += "Wyświetlacz pokazuje:<br>\t<tt>[shuttleMsg]</tt>"
	else
		. += "Wyświetlacz jest pusty."


/// General-purpose shuttle status display.
/obj/machinery/status_display/shuttle
	name = "shuttle display"
	current_mode = SD_MESSAGE
	var/shuttle_id

	text_color = "#0F5"
	header_text_color = "#2FC"

/obj/machinery/status_display/shuttle/process()
	if(!shuttle_id || (machine_stat & NOPOWER))
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	return display_shuttle_status(SSshuttle.getShuttle(shuttle_id))

/obj/machinery/status_display/shuttle/examine(mob/user)
	. = ..()
	if(shuttle_id)
		. += examine_shuttle(user, SSshuttle.getShuttle(shuttle_id))
	else
		. += "Wyświetlacz jest pusty."

/obj/machinery/status_display/shuttle/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, shuttle_id))
			update()

/obj/machinery/status_display/shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	if (port && (shuttle_id == initial(shuttle_id) || override))
		shuttle_id = port.id
	update()


/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai
	name = "\improper AI display"
	desc = "A small screen which the AI can use to present itself."

	var/mode = SD_BLANK
	var/emotion = "Neutral"

/obj/machinery/status_display/ai/Initialize(mapload)
	. = ..()
	GLOB.ai_status_displays.Add(src)

/obj/machinery/status_display/ai/Destroy()
	GLOB.ai_status_displays.Remove(src)
	. = ..()

/obj/machinery/status_display/ai/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.ai_statuschange()

/obj/machinery/status_display/ai/process()
	if(mode == SD_BLANK || (machine_stat & NOPOWER))
		remove_display()
		return PROCESS_KILL

	if(mode == SD_AI_EMOTE)
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Dorfy")
				set_picture("ai_urist")
			if("Thinking")
				set_picture("ai_thinking")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
			if("Blue Glow")
				set_picture("ai_sal")
			if("Red Glow")
				set_picture("ai_hal")
		return PROCESS_KILL

	if(mode == SD_AI_BSOD)
		set_picture("ai_bsod")
		return PROCESS_KILL


/obj/machinery/status_display/evac/north //NSV13 - Directional status displays for mapping
	pixel_y = 32

/obj/machinery/status_display/evac/south
	pixel_y = -32

/obj/machinery/status_display/evac/west
	pixel_x = -32

/obj/machinery/status_display/evac/east
	pixel_x = 32

/obj/machinery/status_display/ai/north
	pixel_y = 32

/obj/machinery/status_display/ai/south
	pixel_y = -32

/obj/machinery/status_display/ai/west
	pixel_x = -32

/obj/machinery/status_display/ai/east
	pixel_x = 32

/obj/machinery/status_display/supply/north
	pixel_y = 32

/obj/machinery/status_display/supply/south
	pixel_y = -32

/obj/machinery/status_display/supply/west
	pixel_x = -32

/obj/machinery/status_display/supply/east
	pixel_x = 32

/obj/machinery/status_display/shuttle/north
	pixel_y = 32

/obj/machinery/status_display/shuttle/south
	pixel_y = -32

/obj/machinery/status_display/shuttle/west
	pixel_x = -32

/obj/machinery/status_display/shuttle/east
	pixel_x = 32 //NSV13 End

#undef MAX_STATIC_WIDTH
#undef FONT_STYLE
#undef SCROLL_RATE
#undef SCROLL_PADDING
#undef LINE1_X
#undef LINE1_Y
#undef LINE2_X
#undef LINE2_Y
#undef STATUS_DISPLAY_FONT_DATUM
