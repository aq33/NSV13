// AQ EDIT - Smartwires (port BeeStation/BeeStation-Hornet#14275): cable coil moved out of cable.dm and rewritten

/obj/item/stack/cable_coil
	name = "cable coil"
	singular_name = "cable piece"
	desc = "A coil of insulated power cable."

	icon = 'aquila/icons/obj/cable_coil.dmi'
	icon_state = "omni-coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	gender = NEUTER //That's a cable coil sounds better than that's some cable coils

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("chłoszcze", "smaga", "dyscyplinuje", "chłoszcze")

	custom_price = 15

	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	novariants = TRUE // AQ EDIT - our stack update_icon() would add _2/_3 suffixes
	usesound = 'sound/items/deconstruct.ogg'

	materials = list(/datum/material/iron = 10, /datum/material/glass = 5)
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil

	var/cable_color = "white"
	var/omni = TRUE

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, merge = TRUE, mob/user = null, param_color = null, param_omni = FALSE)
	if (param_color && !param_omni)
		cable_color = param_color
		omni = FALSE
	. = ..()
	pixel_x = base_pixel_x + rand(-2,2)
	pixel_y = base_pixel_y + rand(-2,2)
	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)

/obj/item/stack/cable_coil/cyborg
	is_cyborg = 1
	materials = list()
	cost = 1

#define OMNI_CABLE "Omni"
#define CABLE_TIES "Cable Ties"

/obj/item/stack/cable_coil/attack_self(mob/living/user)
	// Crafting options
	var/mutable_appearance/cable_ties = mutable_appearance('icons/obj/items_and_weapons.dmi', "cuff", color = GLOB.cable_colors[omni ? "red" : cable_color])
	cable_ties.maptext = MAPTEXT("<font color='white'>[get_amount()]/15</font>")
	cable_ties.pixel_y = 4
	cable_ties.maptext_y = -2
	if(get_amount() < 15)
		cable_ties.color = COLOR_SONIC_SILVER

	var/list/options = list(
		OMNI_CABLE = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "omni-coil"),
		"Red" = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "coil", color = GLOB.cable_colors["red"]),
		"Yellow" = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "coil", color = GLOB.cable_colors["yellow"]),
		"Green" = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "coil", color = GLOB.cable_colors["green"]),
		"Pink" = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "coil", color = GLOB.cable_colors["pink"]),
		"Orange" = mutable_appearance('aquila/icons/obj/cable_coil.dmi', "coil", color = GLOB.cable_colors["orange"]),
		CABLE_TIES = cable_ties,
	)

	var/result = show_radial_menu(user, user, options, radius = 40, tooltips = TRUE)
	if(isnull(result))
		return

	switch(result)
		if(CABLE_TIES)
			if (!use(15))
				return
			var/obj/item/restraints/handcuffs/cable/created = new(user.loc)
			user.put_in_hands(created)
			return
		if(OMNI_CABLE)
			cable_color = "white"
			omni = TRUE
		else
			cable_color = lowertext(result)
			omni = FALSE

	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	return TRUE

#undef OMNI_CABLE
#undef CABLE_TIES

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] robi pętlę z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	else
		user.visible_message("<span class='suicide'>[user] dusi się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return(OXYLOSS)

///////////////////////////////////
// General procedures
///////////////////////////////////

//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && (!IS_ORGANIC_LIMB(affecting)))
		if(user == H)
			user.visible_message("<span class='notice'>[user] zaczyna naprawiać część przewodów w kończynie [H] ([strefa_pl(affecting.body_zone)]).</span>", "<span class='notice'>Zaczynasz naprawiać część przewodów w [H == user ? "swojej kończynie" : "kończynie [H]"] ([strefa_pl(affecting.body_zone)]).</span>")
			if(!do_mob(user, H, 50))
				return
		if(item_heal_robotic(H, user, 0, 15))
			use(1)
		return
	else
		return ..()

/obj/item/stack/cable_coil/update_name(updates)
	. = ..()
	name = "[omni ? "omni-" : ""]cable [amount < 3 ? "piece" : "coil"]"

/obj/item/stack/cable_coil/update_icon_state()
	. = ..()
	if (omni)
		icon_state = "omni-coil[amount < 3 ? amount : ""]"
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		icon_state = "coil[amount < 3 ? amount : ""]"
		add_atom_colour(GLOB.cable_colors[cable_color], FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/update_icon()
	. = ..()
	update_name()

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.cable_color = cable_color
		new_cable.omni = omni
		new_cable.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)

//add cables to the stack
/obj/item/stack/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/// Right click on anything lays the cable on the tile under it
/obj/item/stack/cable_coil/pre_attack(atom/target, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(modifiers[RIGHT_CLICK] && !isturf(target) && user.Adjacent(target))
		place_on_turf(get_turf(target), user)
		return TRUE
	return ..()

/**
 * Attempts to place a cable structure on a turf. Called when we attack a turf with cable
 * Returns TRUE if a cable was placed
 */
/obj/item/stack/cable_coil/proc/place_on_turf(turf/targeted_turf, mob/user)
	// Cannot be placing from within a locker
	if(!isturf(user.loc))
		return
	if(!isturf(targeted_turf))
		return

	if(targeted_turf.intact || !targeted_turf.can_have_cabling())
		to_chat(user, "<span class='warning'>Kable możesz kłaść tylko na zewnętrznych pomostach i poszyciu!</span>")
		return

	if(get_dist(targeted_turf, user) > 1) // Too far
		to_chat(user, "<span class='warning'>Nie możesz położyć kabla tak daleko!</span>")
		return

	// Check if cable already exists on the turf
	for (var/obj/structure/cable/wire in targeted_turf)
		if (wire.cable_color != cable_color && !omni && !wire.omni)
			continue

		var/obj/structure/cable/resolved_wire = wire.resolve_ambiguous_target(user)
		if (isnull(resolved_wire))
			return

		if (resolved_wire.forced_power_node)
			to_chat(user, "<span class='warning'>W tym miejscu już jest kabel!</span>")
			return
		if (!use(1))
			to_chat(user, "<span class='warning'>Nie został już żaden kabel!</span>")
			return

		to_chat(user, "<span class='notice'>Dodajesz węzeł do [resolved_wire], co pozwala podłączać do niego maszyny i konstrukcje postawione na nim!</span>")
		resolved_wire.add_power_node()
		return TRUE

	// Try and link two cables between z-levels
	if (istype(targeted_turf, /turf/open/openspace))
		var/turf/below_turf = SSmapping.get_turf_below(targeted_turf)
		if (isnull(below_turf))
			return

		// If there isn't a cable below us, make one
		if (locate(/obj/structure/cable) in below_turf)
			if (!use(1))
				to_chat(user, "<span class='warning'>Nie został już żaden kabel!</span>")
				return
		else
			if (!use(2))
				to_chat(user, "<span class='warning'>Do połączenia pokładów potrzebujesz przynajmniej 2 odcinków kabla!</span>")
				return
			if (omni)
				new /obj/structure/cable/omni(below_turf, cable_color)
			else
				new /obj/structure/cable(below_turf, cable_color)
		if (omni)
			new /obj/structure/cable/omni(targeted_turf, cable_color, TRUE)
		else
			new /obj/structure/cable(targeted_turf, cable_color, TRUE)
		to_chat(user, "<span class='notice'>Przesuwasz kabel w dół.</span>")
		return TRUE

	if(!use(1))
		to_chat(user, "<span class='warning'>Nie został już żaden kabel!</span>")
		return

	if (omni)
		new /obj/structure/cable/omni(targeted_turf, cable_color)
	else
		new /obj/structure/cable(targeted_turf, cable_color)
	return TRUE

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "omni-coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload, new_amount = null, merge = TRUE, mob/user = null, param_color = null, param_omni = FALSE)
	if(!amount)
		amount = rand(1, 2)
	return ..()

/obj/item/stack/cable_coil/one
	icon_state = "omni-coil1"
	amount = 1
