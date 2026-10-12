/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A spell that heals your wounds while damaging the enemy."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	action_background_icon_state = "bg_ecult"
	invocation = "FL'MS O'ET'RN'ITY"
	invocation_type = INVOCATION_WHISPER
	charge_max = 150
	clothes_req = FALSE
	range = 9

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(list/targets, mob/user)
	if(!isliving(user))
		return

	var/mob/living/real_target = targets[1]
	var/mob/living/living_user = user
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(real_target.anti_magic_check())
		user.balloon_alert(user, "Zaklęcie zablokowane")
		real_target.visible_message(
			"<span class='danger'>Zaklęcie odbija się od [real_target]!</span>",
			"<span class='danger'>Zaklęcie odbija się od ciebie!</span>",
		)
		return

	real_target.visible_message(
		"<span class='danger'>[real_target] blednie, gdy otacza go czerwona poświata!</span>",
		"<span class='danger'>Bledniesz, gdy otacza cię czerwona poświata!</span>",
	)

	real_target.adjustBruteLoss(20)
	living_user.adjustBruteLoss(-20)

	if(!living_user.blood_volume)
		return

	real_target.blood_volume -= 20
	if(living_user.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_user.blood_volume += 20

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		if(!silent)
			target.balloon_alert(user, "Nieprawidłowy cel")
		return FALSE
	return TRUE
