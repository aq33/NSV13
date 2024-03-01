
/obj/item/melee/classic_baton/police/tonfa
	name = "milicyjna tonfa"
	desc = "Milicyjna, biała, gumowa pała z twardym rdzeniem. Obowiązkowe wyposażenie każdego zwyrodniałego milicjanta, który uwielbia odgłos łamanych kości - u niektórych wywołuje nawet pewien rodzaj nostalgii."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "tonfa"
	item_state = "tonfa"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 8
	throwforce = 7
	cooldown = 0
	stamina_damage = 25 // 4 hits to stamcrit
	slot_flags = ITEM_SLOT_BELT
	stun_animation = TRUE
	/// Per-mob sleep cooldowns.
	/// [mob] = [world.time where the cooldown ends]
	var/static/list/sleep_cooldowns = list()
	/// Per-mob trip cooldowns.
	/// [mob] = [world.time where the cooldown ends]
	var/static/list/trip_cooldowns = list()

/obj/item/melee/classic_baton/police/tonfa/attack(mob/living/target, mob/living/user)
	if(!on)
		return ..()
	var/def_check = target.getarmor(type = "melee")

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>Przydzwoniłeś sobie w łeb.</span>")
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return
	if(!isliving(target))
		return
	if (user.a_intent == INTENT_HARM)
		if(!..())
			target.apply_damage(force, STAMINA, blocked = def_check)
			return
		if(!iscyborg(target))
			return
	else
		if(cooldown_check <= world.time)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
					return
				if(check_martial_counter(H, user))
					return

			var/list/desc = get_stun_description(target, user)

			if (stun_animation)
				user.do_attack_animation(target)
			playsound(get_turf(src), on_stun_sound, 75, 1, -1)
			additional_effects_carbon(target, user)
			if((user.zone_selected == BODY_ZONE_CHEST))
				target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)
			if((user.zone_selected == BODY_ZONE_HEAD))
				target.apply_damage(12, STAMINA, BODY_ZONE_HEAD, def_check)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])
				if(target.staminaloss > 89 && !target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.Sleeping(80)
					target.setStaminaLoss(0)
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)
			if(user.zone_selected == BODY_ZONE_L_LEG)
				target.apply_damage(15, STAMINA, BODY_ZONE_L_LEG, def_check)
				target.apply_damage(8, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibleleg"], desc["localleg"])
				if(prob(20))
					target.Knockdown(7)
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)
			if(user.zone_selected == BODY_ZONE_R_LEG)
				target.apply_damage(15, STAMINA, BODY_ZONE_R_LEG, def_check)
				target.apply_damage(8, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibleleg"], desc["localleg"])
				if(prob(20))
					target.Knockdown(7)
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)
			if(user.zone_selected == BODY_ZONE_L_ARM)
				target.apply_damage(15, STAMINA, BODY_ZONE_L_ARM, def_check)
				target.apply_damage(7, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)
			if(user.zone_selected == BODY_ZONE_R_ARM)
				target.apply_damage(15, STAMINA, BODY_ZONE_R_ARM, def_check)
				target.apply_damage(7, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
				if(target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.setStaminaLoss(0)

			add_fingerprint(user)

			if(!iscarbon(user))
				target.LAssailant = null
			else
				target.LAssailant = WEAKREF(user)
			cooldown_check = world.time + cooldown
		else
			var/wait_desc = get_wait_description()
			if (wait_desc)
				to_chat(user, wait_desc)
