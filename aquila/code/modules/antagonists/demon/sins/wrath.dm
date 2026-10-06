/obj/effect/proc_holder/spell/targeted/shapeshift/demon/wrath //emergency get out of jail card, but better.
	name = "Wrath Demon Form"
	shapeshift_type = /mob/living/simple_animal/lesserdemon/wrath

/mob/living/simple_animal/lesserdemon/wrath //slightly more damage.
	name = "wrathful demon"
	real_name = "wrathful demon"
	melee_damage = 24
	icon_state = "lesserdaemon_wrath"
	icon_living = "lesserdaemon_wrath"

/obj/effect/proc_holder/spell/targeted/inflict_handler/ignite
	name = "Ignite"
	desc = "This spell sets a person on fire from range."
	school = "transmutation"
	invocation = "PŁOŃ!!"
	invocation_type = "shout"
	charge_max = 600
	clothes_req = FALSE
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ignite"
	action_background_icon_state = "bg_demon"
	amt_firestacks = 5
	ignites = TRUE
	sound = 'sound/magic/fireball.ogg'

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/sin/wrath
	name = "Greater Demonic Jaunt"
	desc = "Briefly turn to cinder and ash, allowing you to freely pass through objects. Lasts slightly shorter than normal, but is more easily used."
	charge_max = 25 SECONDS
	cooldown_min = 25 SECONDS
	jaunt_duration = 2 SECONDS
	jaunt_in_time = 0
