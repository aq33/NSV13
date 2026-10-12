// -------------------------
//  SmartFridge.  Much todo
// -------------------------
/obj/machinery/smartfridge
	name = "smartfridge"
	desc = "Keeps cold things cold and hot things cold."
	icon = 'aquila/icons/obj/smartfridge.dmi' // AQ EDIT - port BeeStation #13072: new sprites
	icon_state = "smartfridge-icon"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/smartfridge



	var/max_n_of_items = 1500
	var/allow_ai_retrieve = FALSE
	var/list/initial_contents
	var/visible_contents = TRUE
	// AQ EDIT START - port BeeStation #13072
	layout_prefs_used = "tgui_layout_smartfridge"
	/// Sprite base, icon states are built from it
	var/base_icon_state = "smartfridge"
	/// Which contents overlay is shown when the fridge is filled: [base_icon_state]-[contents_overlay_icon]-1/2/3
	var/contents_overlay_icon = "plant"
	/// Whether the fridge glows when powered
	var/has_emissive = TRUE
	// AQ EDIT END

/obj/machinery/smartfridge/Initialize(mapload)
	. = ..()
	create_reagents(100, NO_REACT)

	if(islist(initial_contents))
		for(var/typekey in initial_contents)
			var/amount = initial_contents[typekey]
			if(isnull(amount))
				amount = 1
			for(var/i in 1 to amount)
				load(new typekey(src))

/obj/machinery/smartfridge/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: to urządzenie mieści maksymalnie <b>[max_n_of_items]</b> przedmiotów.</span>"

/obj/machinery/smartfridge/power_change()
	..()
	update_icon()

// AQ EDIT START - port BeeStation #13072: sprites with contents levels, glass, light and broken states
/obj/machinery/smartfridge/update_icon_state()
	icon_state = "[base_icon_state]"
	if(machine_stat & BROKEN)
		icon_state += "-broken"
	return ..()

/// Returns the number of items visible in the fridge
/obj/machinery/smartfridge/proc/visible_items()
	return length(contents) - length(component_parts)

/obj/machinery/smartfridge/update_overlays()
	. = ..()
	var/shown_contents_length = visible_items()
	if(visible_contents && shown_contents_length > 0)
		var/content_level = "[base_icon_state]-[contents_overlay_icon]"
		switch(shown_contents_length)
			if(1 to 25)
				content_level += "-1"
			if(26 to 75)
				content_level += "-2"
			else
				content_level += "-3"
		. += mutable_appearance(icon, content_level)
	if(visible_contents)
		. += mutable_appearance(icon, "[base_icon_state]-glass[(machine_stat & BROKEN) ? "-broken" : ""]")
	if(has_emissive && powered() && !(machine_stat & BROKEN))
		. += mutable_appearance(icon, "[base_icon_state]-powered")
		. += emissive_appearance(icon, "[base_icon_state]-light-mask", layer, alpha = src.alpha)
	if(panel_open)
		. += mutable_appearance(icon, "[base_icon_state]-panel")
// AQ EDIT END



/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, O))
		update_appearance() // AQ EDIT - the panel overlay is in update_overlays()
		ui_update()
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(default_deconstruction_crowbar(O))
		return

	if(!machine_stat)

		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='warning'>[src] jest pełna!</span>")
			return FALSE

		if(accept_check(O))
			load(O, user)
			user.visible_message("[user] dodaje [O] do [src].", "<span class='notice'>Dodajesz [O] do [src].</span>")
			if (visible_contents)
				update_icon()
			return TRUE

		if(istype(O, /obj/item/storage/bag))
			var/obj/item/storage/P = O
			var/loaded = 0
			for(var/obj/G in P.contents)
				if(contents.len >= max_n_of_items)
					break
				if(accept_check(G))
					load(G, user)
					loaded++

			if(loaded)
				if(contents.len >= max_n_of_items)
					user.visible_message("[user] ładuje [O] do [src].", \
									 "<span class='notice'>Napełniasz [src] zawartością [O].</span>")
				else
					user.visible_message("[user] ładuje [O] do [src].", \
										 "<span class='notice'>Ładujesz [O] do [src].</span>")
				if(O.contents.len > 0)
					to_chat(user, "<span class='warning'>Niektóre przedmioty zostały odrzucone.</span>")
				if (visible_contents)
					update_icon()
				return TRUE
			else
				to_chat(user, "<span class='warning'>W [O] nie ma niczego, co można włożyć do [src]!</span>")
				return FALSE

		if(istype(O, /obj/item/organ_storage))
			var/obj/item/organ_storage/S = O
			if(S.contents.len)
				var/obj/item/I = S.contents[1]
				if(accept_check(I))
					load(I)
					user.visible_message("[user] wkłada [I] do [src].", \
									 "<span class='notice'>Wkładasz [I] do [src].</span>")
					O.cut_overlays()
					O.icon_state = "evidenceobj"
					O.desc = "A container for holding body parts."
					if(visible_contents)
						update_icon()
					return TRUE
				else
					to_chat(user, "<span class='warning'>[src] nie przyjmuje [I]!</span>")
					return FALSE
			else
				to_chat(user, "<span class='warning'>W [O] nie ma niczego, co można włożyć do [src]!</span>")
				return FALSE

	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>[src] sprytnie odrzuca [O].</span>")
		return FALSE
	else
		return ..()


/obj/machinery/smartfridge/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!machine_stat)
		if (istype(AM, /obj/item))
			var/obj/item/O = AM
			if(contents.len < max_n_of_items && accept_check(O))
				load(O)
				if (visible_contents)
					update_icon()
				return TRUE
	return ..()


/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O, /obj/item/food/grown/) || istype(O, /obj/item/seeds/) || istype(O, /obj/item/grown/) || istype(O, /obj/item/food/seaweed_sheet))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/proc/load(obj/item/O, mob/user)
	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			to_chat(usr, "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return FALSE
		else
			. = TRUE
	else
		if(SEND_SIGNAL(O.loc, COMSIG_CONTAINS_STORAGE))
			. = SEND_SIGNAL(O.loc, COMSIG_TRY_STORAGE_TAKE, O, src)
		else
			O.forceMove(src)
			. = TRUE

	if(.)
		ui_update()

///Really simple proc, just moves the object "O" into the hands of mob "M" if able, done so I could modify the proc a little for the organ fridge
/obj/machinery/smartfridge/proc/dispense(obj/item/O, var/mob/M)
	if(!M.put_in_hands(O))
		O.forceMove(drop_location())
		adjust_item_drop_location(O)



/obj/machinery/smartfridge/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/smartfridge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartVend")
		ui.set_autoupdate(FALSE)
		ui.open()

// AQ EDIT START - port BeeStation #13072: data for the SmartVend window from Bee (grid with item icons)
/obj/machinery/smartfridge/ui_data(mob/user)
	. = list()
	var/list/listofitems = list()
	for(var/atom/movable/stored in src)
		// We do not vend our own components
		if(stored in component_parts)
			continue
		if(QDELETED(stored))
			continue
		var/key = smartfridge_item_key(stored)
		if(listofitems[key])
			listofitems[key]["amount"]++
		else
			listofitems[key] = list(
				"path" = key,
				"name" = capitalize(stored.name),
				"icon" = stored.icon,
				"icon_state" = stored.icon_state,
				"amount" = 1,
			)
	.["contents"] = sortList(listofitems)
	.["name"] = name
	.["isdryer"] = FALSE

/// Groups the same items in the window: type and name, without the \proper and \improper markers
/obj/machinery/smartfridge/proc/smartfridge_item_key(atom/movable/stored)
	return "[stored.type]-[replacetext(replacetext(stored.name, "\proper", ""), "\improper", "")]"
// AQ EDIT END


/obj/machinery/smartfridge/handle_atom_del(atom/A) // Update the UIs in case something inside gets deleted
	SStgui.update_uis(src)

/obj/machinery/smartfridge/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("Release")
			var/desired = 0

			if(!allow_ai_retrieve && isAI(usr))
				to_chat(usr, "<span class='warning'>Wygląda na to, że [src] nie jest skonfigurowana, by respektować twój autorytet!</span>")
				return

			if (params["amount"])
				desired = text2num(params["amount"])
			else
				desired = input("Ile przedmiotów?", "Ile przedmiotów chcesz wyjąć?", 1) as null|num

			if(!isnum_safe(desired) || desired <= 0)
				return

			if(QDELETED(src) || QDELETED(usr) || !usr.Adjacent(src)) // Sanity checkin' in case stupid stuff happens while we wait for input()
				return

			for(var/obj/item/O in src)
				if(O in component_parts) // AQ EDIT - never hand out our own parts
					continue
				if(params["path"] ? (smartfridge_item_key(O) == params["path"]) : (O.name == params["name"])) // AQ EDIT - port BeeStation #13072: the window sends a type-name key
					dispense(O, usr)
					desired--
					. = TRUE
					if(desired <= 0)
						break
			if (visible_contents && .)
				update_icon()


// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and leather."
	icon_state = "drying-rack" // AQ EDIT - port BeeStation #13072: new sprite
	base_icon_state = "drying-rack"
	use_power = NO_POWER_USE
	visible_contents = FALSE
	has_emissive = FALSE
	var/drying = FALSE
	/// The reference to the last user's mind. Needed for the chef made trait to be properly applied correctly to dried food.
	var/datum/weakref/current_user

/obj/machinery/smartfridge/drying_rack/Initialize(mapload)
	. = ..()
	if(component_parts?.len)
		component_parts.Cut()
	component_parts = null

/obj/machinery/smartfridge/drying_rack/Destroy()
	current_user = null
	return ..()

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	..()

/obj/machinery/smartfridge/drying_rack/RefreshParts()
/obj/machinery/smartfridge/drying_rack/default_deconstruction_screwdriver()
/obj/machinery/smartfridge/drying_rack/exchange_parts()
/obj/machinery/smartfridge/drying_rack/spawn_frame()

/obj/machinery/smartfridge/drying_rack/default_deconstruction_crowbar(obj/item/crowbar/C, ignore_panel = 1)
	..()

/obj/machinery/smartfridge/drying_rack/ui_data(mob/user)
	. = ..()
	.["isdryer"] = TRUE
	.["verb"] = "Take"
	.["drying"] = drying


/obj/machinery/smartfridge/drying_rack/ui_act(action, params)
	. = ..()
	if(.)
		update_icon() // This is to handle a case where the last item is taken out manually instead of through drying pop-out
		return
	switch(action)
		if("Dry")
			toggle_drying(FALSE, usr)
			return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/powered()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/smartfridge/drying_rack/power_change()
	. = ..()
	if(!powered())
		toggle_drying(TRUE)

/obj/machinery/smartfridge/drying_rack/load(obj/item/dried_object, mob/user) //For updating the filled overlay
	. = ..()
	if(!.)
		return
	update_appearance()
	if(drying && user?.mind)
		current_user = WEAKREF(user.mind)

// AQ EDIT START - port BeeStation #13072
/obj/machinery/smartfridge/drying_rack/update_icon_state()
	. = ..()
	icon_state = base_icon_state // no broken sprite for the rack

/obj/machinery/smartfridge/drying_rack/update_overlays()
	. = ..()
	if(drying)
		. += "[base_icon_state]-drying"
	if(contents.len)
		. += "[base_icon_state]-filled"
// AQ EDIT END

/obj/machinery/smartfridge/drying_rack/process()
	..()
	if(drying)
		for(var/obj/item/item_iterator in src)
			if(!accept_check(item_iterator))
				continue
			rack_dry(item_iterator)

		SStgui.update_uis(src)
		update_icon()

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(HAS_TRAIT(O, TRAIT_DRYABLE)) //set on dryable element
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff, mob/user)
	if(drying || forceoff)
		drying = FALSE
		current_user = FALSE
	else
		drying = TRUE
		if(user?.mind)
			current_user = WEAKREF(user.mind)
	update_appearance()

/obj/machinery/smartfridge/drying_rack/proc/rack_dry(obj/item/target)
	SEND_SIGNAL(target, COMSIG_ITEM_DRIED, current_user)

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	atmos_spawn_air("TEMP=1000")


// ----------------------------
//  Bar drink smartfridge
// ----------------------------
/obj/machinery/smartfridge/drinks
	name = "drink showcase"
	contents_overlay_icon = "drink" // AQ EDIT - port BeeStation #13072
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT) || !O.reagents || !O.reagents.reagent_list.len)
		return FALSE
	if(istype(O, /obj/item/reagent_containers/glass) || istype(O, /obj/item/reagent_containers/food/drinks) || istype(O, /obj/item/reagent_containers/food/condiment))
		return TRUE

// ----------------------------
//  Food smartfridge
// ----------------------------
/obj/machinery/smartfridge/food
	desc = "A refrigerated storage unit for food."
	contents_overlay_icon = "food" // AQ EDIT - port BeeStation #13072

/obj/machinery/smartfridge/food/accept_check(obj/item/O)
	if(IS_EDIBLE(O))
		return TRUE
	return FALSE

// -------------------------------------
// Xenobiology Slime-Extract Smartfridge
// -------------------------------------
/obj/machinery/smartfridge/extract
	name = "smart slime extract storage"
	contents_overlay_icon = "slime" // AQ EDIT - port BeeStation #13072
	desc = "A refrigerated storage unit for slime extracts."

/obj/machinery/smartfridge/extract/accept_check(obj/item/O)
	if(istype(O, /obj/item/slime_extract))
		return TRUE
	if(istype(O, /obj/item/slime_scanner))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/extract/preloaded
	initial_contents = list(/obj/item/slime_scanner = 2)

// -------------------------
// Organ Surgery Smartfridge
// -------------------------
/obj/machinery/smartfridge/organ
	name = "smart organ storage"
	contents_overlay_icon = "organ" // AQ EDIT - port BeeStation #13072
	desc = "A refrigerated storage unit for organ storage."
	max_n_of_items = 20	//vastly lower to prevent processing too long
	var/repair_rate = 0

/obj/machinery/smartfridge/organ/accept_check(obj/item/O)
	if(istype(O, /obj/item/organ))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/organ/load(obj/item/item, mob/user)
	. = ..()
	if(!.)	//if the item loads, clear can_decompose
		return
	if(isorgan(item))
		var/obj/item/organ/organ = item
		organ.organ_flags |= ORGAN_FROZEN
	if(isbodypart(item))
		var/obj/item/bodypart/bodypart = item
		for(var/obj/item/organ/stored in bodypart.contents)
			stored.organ_flags |= ORGAN_FROZEN

/obj/machinery/smartfridge/organ/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 20 * B.rating
		repair_rate = max(0, STANDARD_ORGAN_HEALING * (B.rating - 1) * 0.5)

/obj/machinery/smartfridge/organ/process(delta_time)
	for(var/organ in contents)
		var/obj/item/organ/O = organ
		if(!istype(O))
			return
		O.applyOrganDamage(-repair_rate * delta_time)

/obj/machinery/smartfridge/organ/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone))
		var/obj/item/organ/organ = gone
		organ.organ_flags &= ~ORGAN_FROZEN

// -----------------------------
// Chemistry Medical Smartfridge
// -----------------------------
/obj/machinery/smartfridge/chemistry
	name = "smart chemical storage"
	contents_overlay_icon = "chem" // AQ EDIT - port BeeStation #13072
	desc = "A refrigerated storage unit for medicine storage."

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O)
	if(istype(O, /obj/item/storage/pill_bottle))
		if(O.contents.len)
			for(var/obj/item/I in O)
				if(!accept_check(I))
					return FALSE
			return TRUE
		return FALSE
	if(!istype(O, /obj/item/reagent_containers) || (O.item_flags & ABSTRACT))
		return FALSE
	if(istype(O, /obj/item/reagent_containers/pill)) // empty pill prank ok
		return TRUE
	if(!O.reagents || !O.reagents.reagent_list.len) // other empty containers not accepted
		return FALSE
	if(istype(O, /obj/item/reagent_containers/syringe) || istype(O, /obj/item/reagent_containers/glass/bottle) || istype(O, /obj/item/reagent_containers/glass/beaker) || istype(O, /obj/item/reagent_containers/spray) || istype(O, /obj/item/reagent_containers/medspray))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/chemistry/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/pill/epinephrine = 12,
		/obj/item/reagent_containers/pill/charcoal = 5,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/glass/bottle/charcoal = 1)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/chemistry/virology
	name = "smart virus storage"
	contents_overlay_icon = "viro" // AQ EDIT - port BeeStation #13072
	desc = "A refrigerated storage unit for volatile sample storage."

/obj/machinery/smartfridge/chemistry/virology/preloaded
	initial_contents = list(
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/glass/bottle/cold = 1,
		/obj/item/reagent_containers/glass/bottle/flu_virion = 1,
		/obj/item/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/reagent_containers/glass/bottle/plasma = 1,
		/obj/item/reagent_containers/glass/bottle/synaptizine = 1,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/glass/bottle/cryostylane = 1)

/obj/machinery/smartfridge/chemistry/virology/preloaded/debug
	name = "debug virus storage"
	desc = "Oh boy, badmin at it again with the Toxoplasmosis!"

/obj/machinery/smartfridge/chemistry/virology/preloaded/debug/Initialize(mapload)
	. = ..()
	for(var/symptom in subtypesof(/datum/symptom))
		var/datum/symptom/S = new symptom
		var/datum/disease/advance/symptomholder = new
		symptomholder.name = S.name
		symptomholder.symptoms += S
		symptomholder.Finalize()
		symptomholder.Refresh()
		var/list/data = list("viruses" = list(symptomholder))
		var/obj/item/reagent_containers/glass/bottle/B = new
		B.name = "[symptomholder.name] culture bottle"
		B.desc = "A small bottle. Contains [symptomholder.agent] culture in synthblood medium."
		B.reagents.add_reagent(/datum/reagent/blood, 20, data)
		B.forceMove(src)
	for(var/disease in subtypesof(/datum/disease))
		if(!istype(disease, /datum/disease/advance))
			var/datum/disease/target = new disease
			var/list/data = list("viruses" = list(target))
			var/obj/item/reagent_containers/glass/bottle/B = new
			B.name = "[target.name] culture bottle"
			B.desc = "A small bottle. Contains [target.agent] culture in synthblood medium."
			B.reagents.add_reagent(/datum/reagent/blood, 20, data)
			B.forceMove(src)



// ----------------------------
// Disk """fridge"""
// ----------------------------
/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	base_icon_state = "disktoaster" // AQ EDIT - port BeeStation #13072
	pass_flags = PASSTABLE
	visible_contents = FALSE

/obj/machinery/smartfridge/disks/accept_check(obj/item/O)
	if(istype(O, /obj/item/disk/))
		return TRUE
	else
		return FALSE
