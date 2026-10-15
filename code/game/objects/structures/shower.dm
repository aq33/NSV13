#define SHOWER_FREEZING "freezing"
#define SHOWER_NORMAL "normal"
#define SHOWER_BOILING "boiling"

// AQ EDIT START - plumbing port from tg
/// Run the shower until we run out of reagents.
#define SHOWER_MODE_UNTIL_EMPTY 0
/// Run the shower for SHOWER_TIMED_LENGTH time, or until we run out of reagents.
#define SHOWER_MODE_TIMED 1
/// Run the shower forever, pausing when we run out of liquid, and then resuming later.
#define SHOWER_MODE_FOREVER 2
/// Number of modes to cycle through
#define SHOWER_MODE_COUNT 3
/// How long we run in TIMED mode
#define SHOWER_TIMED_LENGTH (15 SECONDS)
/// How much the volume of the shower's spay reagents are amplified by when it sprays something.
#define SHOWER_EXPOSURE_MULTIPLIER 2

GLOBAL_LIST_INIT(shower_mode_descriptions, list(
	"[SHOWER_MODE_UNTIL_EMPTY]" = "leci, aż skończy się woda",
	"[SHOWER_MODE_TIMED]" = "leci 15 sekund albo do końca wody",
	"[SHOWER_MODE_FOREVER]" = "leci bez końca i sam włącza się po uzupełnieniu wody",
))
// AQ EDIT END

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	use_power = NO_POWER_USE
	processing_flags = START_PROCESSING_MANUALLY
	var/on = FALSE //Is the shower actually spitting out water currently
	var/current_temperature = SHOWER_NORMAL
	var/datum/looping_sound/showering/soundloop
	var/reagent_id = /datum/reagent/water
	var/reaction_volume = SHOWER_CAPACITY // AQ EDIT - how much reagent the shower can hold
	// AQ EDIT START - plumbing port from tg
	///Does the user want the shower on or off?
	var/intended_on = FALSE
	///How much reagent capacity should the shower refill per second.
	var/refill_rate = WATER_RECLAIM_RATE
	///Does the shower have a water recycler to recollect its water supply?
	var/has_water_reclaimer = TRUE
	///Which mode the shower is operating in.
	var/mode = SHOWER_MODE_UNTIL_EMPTY
	///Cooldown for SHOWER_MODE_TIMED
	COOLDOWN_DECLARE(timed_cooldown)
	// AQ EDIT END

/obj/structure/showerframe
	name = "shower frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower_frame"
	desc = "A shower frame, that needs 2 plastic sheets to finish construction into a basic shower, or can be made into a blast shower by adding a sheet of titanium instead." //NSV13 - blast shower construction info.
	anchored = FALSE

/obj/structure/showerframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/showerframe/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/plastic))
		balloon_alert(user, "Zaczynasz budować prysznic...")
		if(do_after(user, 4 SECONDS, target = src))
			I.use(1)
			balloon_alert(user, "Tworzysz prysznic.")
			var/obj/machinery/shower/new_shower = new /obj/machinery/shower(loc)
			new_shower.setDir(dir)
			qdel(src)
			return
	return ..()


/obj/machinery/shower/Initialize(mapload)
	. = ..()
	create_reagents(reaction_volume)
	// AQ EDIT START - plumbing port from tg
	if(has_water_reclaimer)
		reagents.add_reagent(reagent_id, reaction_volume)
	AddComponent(/datum/component/plumbing/fixture)
	// AQ EDIT END

	soundloop = new(src, FALSE)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(reagents)
	return ..()

// AQ EDIT START - plumbing port from tg
/obj/machinery/shower/interact(mob/M)
	add_fingerprint(M)
	intended_on = !intended_on
	if(!update_actually_on(intended_on))
		balloon_alert(M, "[src] jest suchy!")
		intended_on = FALSE
		return FALSE

	balloon_alert(M, intended_on ? "włączony" : "wyłączony")
	return TRUE

/**
 * Toggle whether shower is actually on and outputting water.
 * May not match what user asked to happen by clicking.
 * Returns TRUE if the state was changed.
 */
/obj/machinery/shower/proc/update_actually_on(new_on_state)
	if(new_on_state == on)
		return new_on_state ? TRUE : FALSE

	// Check if we have enough reagents to actually turn on.
	if(new_on_state && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		return FALSE

	on = new_on_state

	update_icon()
	handle_mist()
	begin_processing()
	if(on)
		soundloop.start()
		COOLDOWN_START(src, timed_cooldown, SHOWER_TIMED_LENGTH)
		process(SSMACHINES_DT)
	else
		soundloop.stop()
		if(isopenturf(loc))
			var/turf/open/tile = loc
			tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)
	return TRUE

/obj/machinery/shower/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Temperaturę wody ustawisz <b>kluczem</b>, a tryb wyłączania <b>multitoolem</b>.</span>"
	. += "<span class='notice'>Tryb: [GLOB.shower_mode_descriptions["[mode]"]].</span>"
	if(has_water_reclaimer)
		. += "<span class='notice'>Ma zamontowany odzysk wody. Można go wyważyć <b>łomem</b>.</span>"
	. += "<span class='notice'>Zostało [round(reagents.total_volume)]/[reagents.maximum_volume] j. wody.</span>"

/obj/machinery/shower/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("zajadle przepycha...")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	user.balloon_alert_to_viewers("przepchane")
	reagents.reaction(get_turf(src), TOUCH) //splash on the floor
	reagents.clear_reagents()
	begin_processing()
	return TRUE

/obj/machinery/shower/multitool_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	mode = (mode + 1) % SHOWER_MODE_COUNT
	begin_processing()
	to_chat(user, "<span class='notice'>Przestawiasz automatyczne wyłączanie prysznica: [GLOB.shower_mode_descriptions["[mode]"]].</span>")
	return TRUE

/obj/machinery/shower/crowbar_act(mob/living/user, obj/item/tool)
	if(!has_water_reclaimer)
		to_chat(user, "<span class='warning'>[src] nie ma odzysku wody.</span>")
		return TRUE

	tool.play_tool_sound(src)
	has_water_reclaimer = FALSE
	new /obj/item/stock_parts/water_recycler(drop_location())
	to_chat(user, "<span class='notice'>Wyważasz odzysk wody z [src].</span>")
	return TRUE
// AQ EDIT END

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Temperatura wody wydaje się: [current_temperature].</span>")
	// AQ EDIT START - plumbing port from tg
	else if(istype(I, /obj/item/stock_parts/water_recycler))
		if(has_water_reclaimer)
			to_chat(user, "<span class='warning'>[src] ma już odzysk wody.</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		playsound(src, 'sound/machines/click.ogg', 20, TRUE)
		qdel(I)
		has_water_reclaimer = TRUE
		begin_processing()
		to_chat(user, "<span class='notice'>Montujesz odzysk wody w [src].</span>")
	// AQ EDIT END
	else
		return ..()

/obj/machinery/shower/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Zaczynasz regulować zawór temperatury za pomocą [I]...</span>")
	if(I.use_tool(src, user, 50))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message("<span class='notice'>[user] reguluje prysznic za pomocą [I].</span>", "<span class='notice'>Ustawiasz temperaturę prysznica za pomocą [I] na: [current_temperature].</span>")
		user.log_message("has wrenched a shower at [AREACOORD(src)] to [current_temperature].", LOG_ATTACK)
		add_hiddenprint(user)
	handle_mist()
	return TRUE


/obj/machinery/shower/update_icon()
	cut_overlays()

	if(on)
		// AQ EDIT - plumbing port from tg, the water takes the color of what we spray
		var/mutable_appearance/water_falling = mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER)
		water_falling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(water_falling)

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, PROC_REF(make_mist)), 5 SECONDS)

	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		addtimer(CALLBACK(src, PROC_REF(clear_mist)), 25 SECONDS)

/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		new /obj/effect/mist(loc)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)


/obj/machinery/shower/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(on)
		INVOKE_ASYNC(src, PROC_REF(wash_atom), AM)

/obj/machinery/shower/proc/wash_atom(atom/A)
	// AQ EDIT START - plumbing port from tg
	if(!reagents.total_volume)
		return
	reagents.reaction(A, TOUCH, SHOWER_EXPOSURE_MULTIPLIER * SHOWER_SPRAY_VOLUME / max(reagents.total_volume, SHOWER_SPRAY_VOLUME))
	// Only mostly water actually cleans anything
	if(!reagents.has_reagent(/datum/reagent/water, reagents.total_volume * 0.7))
		if(isliving(A))
			check_heat(A)
		return
	SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	// AQ EDIT END

	if(isobj(A))
		wash_obj(A)
	else if(isturf(A))
		wash_turf(A)
	else if(isliving(A))
		wash_mob(A)
		check_heat(A)

	contamination_cleanse(A)

/obj/machinery/shower/proc/wash_obj(obj/O)
	. = SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)


/obj/machinery/shower/proc/wash_turf(turf/tile)
	SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	tile.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	for(var/obj/effect/E in tile)
		if(is_cleanable(E))
			qdel(E)


/obj/machinery/shower/proc/wash_mob(mob/living/L)
	SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	L.wash_cream()
	L.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	//NSV13 - you can't shower with clothes on. This is handled later.
	//SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)
	if(iscarbon(L))
		var/mob/living/carbon/M = L
		. = TRUE

		for(var/obj/item/I in M.held_items)
			wash_obj(I)

		if(M.back && wash_obj(M.back))
			M.update_inv_back(0)

		var/obscured = M.check_obscured_slots()

		if(M.head && wash_obj(M.head))
			M.update_inv_head()

		if(M.glasses && !(obscured & ITEM_SLOT_EYES) && wash_obj(M.glasses))
			M.update_inv_glasses()

		if(M.wear_mask && !(obscured & ITEM_SLOT_MASK) && wash_obj(M.wear_mask))
			M.update_inv_wear_mask()

		if(M.ears && !(obscured & ITEM_SLOT_EARS) && wash_obj(M.ears))
			M.update_inv_ears()

		if(M.wear_neck && !(obscured & ITEM_SLOT_NECK) && wash_obj(M.wear_neck))
			M.update_inv_neck()

		if(M.shoes && !(obscured & ITEM_SLOT_FEET) && wash_obj(M.shoes))
			M.update_inv_shoes()

		var/washgloves = FALSE
		if(M.gloves && !(obscured & ITEM_SLOT_GLOVES))
			washgloves = TRUE

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			// NSV13 - kept hygiene
			if(check_clothes(L))
				if(H.hygiene <= 75)
					to_chat(H, "<span class='warning'>Musisz zdjąć ubranie, żeby się umyć!</span>")
			else
				H.set_hygiene(HYGIENE_LEVEL_CLEAN)
				if (iscatperson(H)) //NSV felinids hate showers (all this really does is turn the +3 from neat into a +1, and doesn't give the +4 from a nice shower)
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/hate_shower)
				else
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower)

			if(H.wear_suit && wash_obj(H.wear_suit))
				H.update_inv_wear_suit()
			else if(H.w_uniform && wash_obj(H.w_uniform))
				H.update_inv_w_uniform()

			if(washgloves)
				SEND_SIGNAL(H, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

			if(!H.is_mouth_covered())
				H.lip_style = null
				H.update_body()

			if(H.belt && wash_obj(H.belt))
				H.update_inv_belt()
		else
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower) //NSV13 - handled mood separately due to clothes
	else
		SEND_SIGNAL(L, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "shower", /datum/mood_event/nice_shower) //NSV13 - handled mood separately due to clothes

/obj/machinery/shower/proc/contamination_cleanse(atom/thing)
	var/datum/component/radioactive/healthy_green_glow = thing.GetComponent(/datum/component/radioactive)
	if(!healthy_green_glow || QDELETED(healthy_green_glow))
		return
	var/strength = healthy_green_glow.strength
	if(strength <= RAD_BACKGROUND_RADIATION)
		qdel(healthy_green_glow)
		return
	healthy_green_glow.strength -= max(0, healthy_green_glow.strength * 0.2) //NSV13 - Now removes rads towards 0, instead of towards (background radiation * 2).
// AQ EDIT START - plumbing port from tg
/obj/machinery/shower/process(delta_time)
	// the TIMED mode cutoff feature. User has to manually reactivate.
	if(intended_on && mode == SHOWER_MODE_TIMED && COOLDOWN_FINISHED(src, timed_cooldown))
		intended_on = FALSE

	// Out of water.
	if(on && reagents.total_volume < SHOWER_SPRAY_VOLUME)
		update_actually_on(FALSE)

		// Don't turn back on.
		if(mode != SHOWER_MODE_FOREVER)
			intended_on = FALSE
	else
		// Cycle: update_actually_on() will only change state if appropriate.
		update_actually_on(intended_on)

	// Reclaim water
	if(!on)
		if(has_water_reclaimer && !reagents.holder_full())
			reagents.add_reagent(reagent_id, refill_rate * delta_time)
			return

		// FOREVER mode stays processing so it can cycle back on.
		return mode == SHOWER_MODE_FOREVER ? null : PROCESS_KILL

	wash_atom(loc)
	for(var/AM in loc)
		wash_atom(AM)
	reagents.remove_all(SHOWER_SPRAY_VOLUME * delta_time)

/obj/machinery/shower/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 3)
	if(has_water_reclaimer)
		new /obj/item/stock_parts/water_recycler(drop_location())
	qdel(src)
// AQ EDIT END

/obj/machinery/shower/proc/check_heat(mob/living/L)
	var/mob/living/carbon/C = L

	if(current_temperature == SHOWER_FREEZING)
		if(iscarbon(L))
			C.adjust_bodytemperature(-80, 80)
		to_chat(L, "<span class='warning'>[src] jest lodowaty!</span>")
	else if(current_temperature == SHOWER_BOILING)
		if(iscarbon(L))
			C.adjust_bodytemperature(35, 0, 500)
		L.adjustFireLoss(5)
		to_chat(L, "<span class='danger'>[src] parzy!</span>")

// NSV13 - kept hygiene
/obj/machinery/shower/proc/check_clothes(mob/living/carbon/human/H)
	if(H.wear_suit && (H.wear_suit.clothing_flags & SHOWEROKAY))
		// Do not check underclothing if the over-suit is suitable.
		// This stops people feeling dumb if they're showering
		// with a radiation suit on.
		return FALSE

	. = FALSE
	if(H.wear_suit && !(H.wear_suit.clothing_flags & SHOWEROKAY))
		. = TRUE
	else if(H.w_uniform && !(H.w_uniform.clothing_flags & SHOWEROKAY))
		. = TRUE
	else if(H.wear_mask && !(H.wear_mask.clothing_flags & SHOWEROKAY))
		. = TRUE
	else if(H.head && !(H.head.clothing_flags & SHOWEROKAY))
		. = TRUE


// AQ EDIT START - plumbing port from tg
#undef SHOWER_MODE_UNTIL_EMPTY
#undef SHOWER_MODE_TIMED
#undef SHOWER_MODE_FOREVER
#undef SHOWER_MODE_COUNT
#undef SHOWER_TIMED_LENGTH
#undef SHOWER_EXPOSURE_MULTIPLIER
// AQ EDIT END

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
