// The mawed crucible, a heretic structure that can create potions from bodyparts and organs.
/obj/structure/destructible/eldritch_crucible
	name = "mawed crucible"
	desc = "A deep basin made of cast iron, immortalized by steel-like teeth holding it in place. \
		Staring at the vile extract within fills your mind with terrible ideas."
	icon = 'icons/obj/heretic.dmi'
	icon_state = "crucible"
	var/base_icon = "crucible"
	break_sound = 'sound/hallucinations/wail.ogg'
	light_power = 1
	anchored = FALSE
	density = TRUE
	///How much mass this currently holds
	var/current_mass = 5
	///Maximum amount of mass
	var/max_mass = 5
	///Check to see if it is currently being used.
	var/in_use = FALSE

/obj/structure/destructible/eldritch_crucible/Initialize(mapload)
	. = ..()
	break_message = "<span class='warning'>[src] rozpada się z łoskotem!</span>"

/obj/structure/destructible/eldritch_crucible/deconstruct(disassembled = TRUE)

	// Create a spillage if we were destroyed with leftover mass
	if(current_mass)
		break_message = "<span class='warning'>[src] rozpada się z łoskotem, rozlewając wszędzie lśniący ekstrakt!</span>"
		var/turf/our_turf = get_turf(src)

		new /obj/effect/decal/cleanable/greenglow(our_turf)
		for(var/turf/nearby_turf as anything in get_adjacent_open_turfs(our_turf))
			if(prob(10 * current_mass))
				new /obj/effect/decal/cleanable/greenglow(nearby_turf)
		playsound(our_turf, 'sound/effects/bubbles2.ogg', 50, TRUE)

	return ..()

/obj/structure/destructible/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	if(current_mass < max_mass)
		var/to_fill = max_mass - current_mass
		. += "<span class='notice'>[src] potrzebuje jeszcze <b>[to_fill]</b> organów lub części ciała.</span>"
	else
		. += "<span class='boldnotice'>[src] bulgocze po brzegi lepkim płynem i jest gotowy do użycia.</span>"

	. += "<span class='notice'>[src] można <b>[anchored ? "odczepić i przenieść":"przytwierdzić na miejscu"]</b> za pomocą <b>Codex Cicatrix</b> albo <b>Uchwytu Mansusa</b>.</span>"
	. += "<span class='info'>Można uwarzyć następujące mikstury:</span>"
	for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
		var/potion_string = "<span class='info'>\tThe " + initial(potion.name) + " - " + initial(potion.crucible_tip) + "</span>"
		. += potion_string

/obj/structure/destructible/eldritch_crucible/examine_status(mob/user)
	if(IS_HERETIC_OR_MONSTER(user) || isobserver(user))
		return "<span class='notice'>Stabilność: <b>[round(obj_integrity * 100 / max_integrity)]%</b>.</span>"
	return ..()

/obj/structure/destructible/eldritch_crucible/attacked_by(obj/item/weapon, mob/living/user)
	if(!iscarbon(user))
		return ..()

	if(!IS_HERETIC_OR_MONSTER(user))
		bite_the_hand(user)
		return TRUE

	if(istype(weapon, /obj/item/codex_cicatrix) || istype(weapon, /obj/item/melee/touch_attack/mansus_fist))
		playsound(src, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
		anchored = !anchored
		balloon_alert(user, "[anchored ? "":"un"]anchored")
		return TRUE

	if(istype(weapon, /obj/item/bodypart))
		consume_fuel(user, weapon)
		return TRUE

	if(istype(weapon, /obj/item/organ))
		var/obj/item/organ/consumed = weapon
		if(consumed.status != ORGAN_ORGANIC || (consumed.organ_flags & ORGAN_SYNTHETIC))
			balloon_alert(user, "To nie jest organiczne")
			return
		if(consumed.organ_flags & ORGAN_VITAL) // Basically, don't eat organs like brains
			balloon_alert(user, "Nieprawidłowy organ")
			return

		consume_fuel(user, consumed)
		return TRUE

	return ..()

/obj/structure/destructible/eldritch_crucible/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!isliving(user))
		return

	if(!IS_HERETIC_OR_MONSTER(user))
		if(iscarbon(user))
			bite_the_hand(user)
		return TRUE

	if(in_use)
		balloon_alert(user, "W użyciu")
		return TRUE

	if(current_mass < max_mass)
		balloon_alert(user, "Za mało wypełniony")
		return TRUE

	INVOKE_ASYNC(src, PROC_REF(show_radial), user)
	return TRUE

/*
 * Wrapper for show_radial() to ensure in_use is enabled and disabled correctly.
 */
/obj/structure/destructible/eldritch_crucible/proc/show_radial(mob/living/user)
	in_use = TRUE
	create_potion(user)
	in_use = FALSE

/*
 * Shows the user of radial of possible potions,
 * and create the potion they chose.
 */
/obj/structure/destructible/eldritch_crucible/proc/create_potion(mob/living/user)

	// Assoc list of [name] to [image] for the radial
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial, to spawn it
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
			names_to_path[initial(potion.name)] = potion
			choices[initial(potion.name)] = image(icon = initial(potion.icon), icon_state = initial(potion.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/spawned_type = names_to_path[picked_choice]
	if(!ispath(spawned_type, /obj/item/eldritch_potion))
		CRASH("[type] attempted to create a potion that wasn't an eldritch potion! (got: [spawned_type])")

	var/obj/item/spawned_pot = new spawned_type(drop_location())

	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	visible_message("<span class='notice'>Lśniący płyn z [src] spływa do fiolki, tworząc: [spawned_pot.name]!</span>")
	balloon_alert(user, "Mikstura gotowa")

	current_mass = 0
	update_icon_state()

/*
 * "Bites the hand that feeds it", except more literally.
 * Called when a non-heretic interacts with the crucible,
 * causing them to lose their active hand to it.
 */
/obj/structure/destructible/eldritch_crucible/proc/bite_the_hand(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return

	var/obj/item/bodypart/arm = user.get_active_hand()
	if(QDELETED(arm))
		return

	to_chat(user, "<span class='userdanger'>[src] chwyta cię za [arm.name]!</span>")
	arm.dismember()
	consume_fuel(consumed = arm)

/*
 * Consumes an organ or bodypart and increases the mass of the crucible.
 * If feeder is supplied, gives some feedback.
 */
/obj/structure/destructible/eldritch_crucible/proc/consume_fuel(mob/living/feeder, obj/item/consumed)
	if(current_mass >= max_mass)
		if(feeder)
			balloon_alert(feeder, "Tygiel pełny")
		return

	current_mass++
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	visible_message("<span class='notice'>[src] pożera [consumed] i napełnia się odrobiną płynu!</span>")

	if(feeder)
		balloon_alert(feeder, "Tygiel nakarmiony ([current_mass] / [max_mass])")

	update_icon_state()
	qdel(consumed)

/obj/structure/destructible/eldritch_crucible/update_icon_state()
	icon_state = "[base_icon][(current_mass == max_mass) ? null : "_empty"]"
	return ..()

// Potions created by the mawed crucible.
/obj/item/eldritch_potion
	name = "brew of open a github issue"
	desc = "You should never see this"
	icon = 'icons/obj/heretic.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// When a heretic examines a mawed crucible, shows a list of possible potions by name + includes this tip to explain what it does.
	var/crucible_tip = "Nic nie robi."
	/// Typepath to the status effect this applies
	var/status_effect

/obj/item/eldritch_potion/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += "<span class='notice'>[crucible_tip]</span>"

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!iscarbon(user))
		return

	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)

	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, "<span class='danger'>Wypijasz trochę płynu z [src]. Od smaku zbiera ci się na wymioty, a szkło znika.</span>")
		user.reagents?.add_reagent(/datum/reagent/eldritch, 10)
		user.adjust_disgust(50)
		qdel(src)
		return TRUE

	to_chat(user, "<span class='notice'>Wypijasz lepki płyn z [src], a szkło się dematerializuje.</span>")
	potion_effect(user)
	qdel(src)
	return TRUE

/**
 * The effect of the potion, if it has any special one.
 * In general try not to override this
 * and utilize the status_effect var to make custom effects.
 */
/obj/item/eldritch_potion/proc/potion_effect(mob/user)
	var/mob/living/carbon/carbon_user = user
	carbon_user.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "brew of the crucible soul"
	desc = "A glass bottle containing a bright orange, translucent liquid."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul
	crucible_tip = "Pozwala przechodzić przez ściany. Po zakończeniu teleportuje cię do miejsca startu. Trwa 15 sekund."

/obj/item/eldritch_potion/duskndawn
	name = "brew of dusk and dawn"
	desc = "A glass bottle containing a dull yellow liquid. It seems to fade in and out with regularity."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn
	crucible_tip = "Pozwala widzieć przez ściany i przedmioty. Trwa 60 sekund."
