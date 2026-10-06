/obj/effect/proc_holder/spell/targeted/touch/envy
	name = "Vanity Steal"
	desc = "Engulfs your arm in a jealous might, allowing you to steal the look of the first human-like struck with it, along with the access of their ID. Note, the form change is not reversible."
	hand_path = /obj/item/melee/touch_attack/envy
	school = "evocation"
	charge_max = 150
	clothes_req = FALSE
	human_req = TRUE
	invocation = "WIECZNE PŁOMIENIE"
	invocation_type = "whisper"
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "transform"
	action_background_icon_state = "bg_demon"

/obj/item/melee/touch_attack/envy
	name = "Envious Hand"
	desc = "A writhing, burning aura of jealousy, ready to be unleashed."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	color = "#3fa33f"
	catchphrase = "I'M BETTER THAN YOU!!"

/obj/item/melee/touch_attack/envy/afterattack(atom/target, mob/living/carbon/human/user, proximity)
	if(!proximity || !ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/H = target
	if(H.anti_magic_check())
		to_chat(user, span_warning("[H] resists your unholy jealousy!"))
		to_chat(H, span_warning("A creeping feeling of jealousy dances around your mind before being suddenly dispelled."))
		return
	if(user.real_name == H.dna.real_name)
		user.balloon_alert(user, "you are already [H]!")
		return
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	var/datum/antagonist/sinfuldemon/demon = user.mind?.has_antag_datum(/datum/antagonist/sinfuldemon)
	if(demon)
		var/obj/item/card/id/ID = H.get_idcard()
		demon.stolen_access = ID ? ID.access.Copy() : null
	user.fully_replace_character_name(user.real_name, H.dna.real_name)
	H.dna.transfer_identity(user, transfer_SE=1)
	user.updateappearance(mutcolor_update=1)
	user.domutcheck()
	user.visible_message(span_warning("[user]'s appearance shifts into [H]'s!"), \
	span_boldannounce("[H.p_they(TRUE)] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't."))
	return ..()
