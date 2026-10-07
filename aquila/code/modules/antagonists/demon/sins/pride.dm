/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_mirror
	name = "Summon Mirror"
	desc = "Summon forth a temporary mirror of sin that will allow you and others to change anything they want about themselves."
	invocation = "Czyż nie jestem wspaniały?"
	invocation_type = "whisper"
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/mirror/magic/lesser)
	summon_lifespan = 60 SECONDS
	range = 1
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "magic_mirror"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/targeted/touch/mend
	name = "Mend"
	desc = "Engulfs your arm in a healing powers. Striking someone with it will heal them a moderate amount. Can't target yourself."
	hand_path = /obj/item/melee/touch_attack/mend
	school = "evocation"
	charge_max = 12 SECONDS
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "fleshmend"
	action_background_icon_state = "bg_demon"

/obj/item/melee/touch_attack/mend
	name = "Mending Hand"
	desc = "A seemingly pleasant mass of mending energy, ready to heal."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = "#d4a017"
	catchphrase = "Smak Grzechu"

/obj/item/melee/touch_attack/mend/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !isliving(target) || target == user)
		return
	var/mob/living/victim = target
	if(victim.anti_magic_check())
		to_chat(user, span_warning("[victim] resists your pride!"))
		to_chat(victim, span_warning("A deceptive feeling of pleasure dances around your mind before being suddenly dispelled."))
		return ..()
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.adjustBruteLoss(-20)
	victim.adjustFireLoss(-20)
	victim.visible_message(span_bold("[victim] appears to flash colors of red, before seemingly appearing healthier!"))
	to_chat(victim, span_warning("You feel a sinister feeling of recovery."))
	return ..()
