/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)


/datum/keybinding/living/resist
	key = "B"
	name = "resist"
	full_name = "Opieraj się"
	description = "Uwolnij się z obecnego stanu. Kajdanki, płomienie, uwięzienie w gnieździe obcych? Stawiaj opór!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	if (!isliving(user.mob)) return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE


/datum/keybinding/living/rest
	key = "V"
	name = "rest"
	full_name = "Połóż się/wstań"
	description = "Połóż się albo wstań."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return
	if(!isliving(user.mob))
		return
	var/mob/living/L = user.mob
	L.lay_down()
	return TRUE


/datum/keybinding/living/toggle_combat_mode
	key = "F"
	name = "toggle_combat_mode"
	full_name = "Przełącz tryb walki"
	description = "Przełącza tryb walki (w starym trybie intencji: help/harm)."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_COMBAT_DOWN

/datum/keybinding/living/toggle_combat_mode/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/user_mob = user.mob
	// AQ EDIT - F przy sterach lub broni okrętu to akcja specjalna broni (nsv13/code/datums/keybinding/overmap.dm)
	var/obj/structure/overmap/ship = user_mob.overmap_ship
	if(ship && (user_mob == ship.gunner || user_mob == ship.pilot))
		return FALSE
	// AQ EDIT END
	user_mob.set_combat_mode(!user_mob.combat_mode, FALSE)
	return TRUE
