/obj/effect/proc_holder/spell/targeted/shapeshift/demon/wrath //emergency get out of jail card, but better.
	name = "Wrath Demon Form"
	shapeshift_type = /mob/living/simple_animal/lesserdemon/wrath

/mob/living/simple_animal/lesserdemon/wrath //slightly more damage.
	name = "wrathful demon"
	real_name = "wrathful demon"
	melee_damage = 28
	//melee_damage_lower = 28
	//melee_damage_upper = 28 Chyba to z woundów jest
	icon_state = "lesserdaemon_wrath"
	icon_living = "lesserdaemon_wrath"

/obj/effect/proc_holder/spell/pointed/trigger/ignite
	name = "Ignite"
	desc = "This ranged spell sets a person on fire."
	school = "transmutation"
	charge_max = 600
	clothes_req = FALSE
	invocation = "PŁOŃ!!"
	invocation_type = "shout"
	message = "<span class='notice'Ogień Piekielny spowija Cię!</span>"
	cooldown_min = 75
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/throw_target.dmi'
	action_icon = 'aquila/icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "sacredflame"
	active_msg = "You prepare to ignite a target..."

/obj/effect/proc_holder/spell/targeted/inflict_handler/ignite
	name = "Ignite"
	desc = "This spell sets a person on fire from range."
	school = "transmutation"
	invocation = "PŁOŃ!!"
	invocation_type = "shout"
	charge_max = 600
	clothes_req = FALSE
	action_icon = 'aquila/icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "sacredflame"
	amt_firestacks = 5
	ignites = TRUE
	sound = 'sound/magic/fireball.ogg'
