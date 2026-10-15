/obj/effect/proc_holder/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	action_background_icon_state = "bg_ecult"
	invocation = "CL'VE"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	charge_max = 350
	clothes_req = FALSE
	range = 9

/obj/effect/proc_holder/spell/pointed/cleave/cast(list/targets, mob/user)
	if(!targets.len)
		user.balloon_alert(user, "Brak celów")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	for(var/mob/living/carbon/human/nearby_human in range(1, targets[1]))
		targets |= nearby_human

	for(var/mob/living/carbon/human/victim as anything in targets)
		if(victim == user)
			continue
		if(victim.anti_magic_check())
			victim.visible_message(
				"<span class='danger'>Ciało [victim] rozbłyska ognistą poświatą, ale odpiera płomienie!</span>",
				"<span class='danger'>Twoje ciało rozbłyska ognistą poświatą, ale jesteś chroniony!</span>"
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			"<span class='danger'>Żyły [victim] rozrywają się od środka, a z krwi wybucha nieświęty płomień!</span>",
			"<span class='danger'>Twoje żyły pękają od środka, a z krwi wybucha nieświęty płomień!</span>"
		)

		victim.add_bleeding(BLEED_DEEP_WOUND)
		victim.adjustFireLoss(20)
		new /obj/effect/temp_visual/cleave(victim.drop_location())

/obj/effect/proc_holder/spell/pointed/cleave/can_target(atom/target, mob/user, silent)
	if(!ishuman(target))
		if(!silent)
			target.balloon_alert(user, "Nieprawidłowy cel")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/cleave/long
	charge_max = 650

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/heretic.dmi'
	icon_state = "cleave"
	duration = 6
