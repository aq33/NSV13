///Haste makes the eater move and act faster
/datum/status_effect/food/haste

//NSV13 - our movespeed modifiers are id based, not datum based
#define MOVESPEED_ID_FOOD_HASTE "food_haste"

/datum/status_effect/food/haste/on_apply()
	owner.add_movespeed_modifier(MOVESPEED_ID_FOOD_HASTE, TRUE, 100, override = TRUE, multiplicative_slowdown = -0.04 * strength)
	var/datum/actionspeed_modifier/status_effect/food_haste/action_mod = new()
	action_mod.multiplicative_slowdown = -0.06 * strength
	owner.add_actionspeed_modifier(action_mod, update = TRUE)
	return ..()

/datum/status_effect/food/haste/be_replaced()
	owner.remove_movespeed_modifier(MOVESPEED_ID_FOOD_HASTE)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/food_haste)
	return ..()

/datum/status_effect/food/haste/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_FOOD_HASTE, TRUE)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/status_effect/food_haste, update = TRUE)
	return ..()

#undef MOVESPEED_ID_FOOD_HASTE

/datum/actionspeed_modifier/status_effect/food_haste
	multiplicative_slowdown = -0.06
