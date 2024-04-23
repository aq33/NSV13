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
	name = "Naprawa"
	desc = "Łaska i odrodzenie przechodzi przez twoje palce"
	invocation = "COWER, MORTALS!!"
	action_icon = 'icons/obj/items_and_weapons.dmi'
	action_icon_state = "zapper"
	action_background_icon_state = "bg_demon"
	clothes_req = FALSE
	school = "transmutation"
	charge_max = 600
	cooldown_min = 200
	hand_path = /obj/item/melee/touch_attack/mend
	sound = 'sound/magic/fleshtostone.ogg'


/obj/item/melee/touch_attack/mend
	name = "Mending Hand"
	desc = "A seemingly pleasant mass of mending energy, ready to heal."
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/mend/afterattack(mob/living/carbon/victim, mob/caster, proximity)
	if(victim.anti_magic_check())
		to_chat(caster, span_warning("[victim] resists your pride!"))
		to_chat(victim, span_warning("A deceptive feeling of pleasre dances around your mind before being suddenly dispelled."))
		return TRUE
	playsound(caster, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.adjustBruteLoss(-20)
	victim.adjustFireLoss(-20)
	victim.visible_message(span_bold("[victim] appears to flash colors of red, before seemingly appearing healthier!"))
	to_chat(victim, span_warning("You feel a sinister feeling of recovery."))
	return TRUE
