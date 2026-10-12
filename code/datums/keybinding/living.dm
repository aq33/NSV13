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
