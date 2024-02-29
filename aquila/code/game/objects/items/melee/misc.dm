/obj/item/melee/classic_baton/police/tonfa
	name = "Milicyjna Tonfa"
	desc = "Milicyjna, biała, gumowa pała z twardym rdzeniem. Obowiązkowe wyposażenie każdego zwyrodniałego milicjanta, który uwielbia odgłos łamanych kości - u niektórych wywołuje nawet pewien rodzaj nostalgii."
	icon_state = "beater"
	item_state = "beater"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	force = 8
	throwforce = 7
	cooldown = 0
	stamina_damage = 25 // 4 hits to stamcrit
	stun_animation = TRUE
	/// Per-mob sleep cooldowns.
	/// [mob] = [world.time where the cooldown ends]
	var/static/list/sleep_cooldowns = list()
	/// Per-mob trip cooldowns.
	/// [mob] = [world.time where the cooldown ends]
	var/static/list/trip_cooldowns = list()

/obj/item/melee/classic_baton/police/tonfa/attack(mob/living/target, mob/living/user)
	var/def_check = target.getarmor(type = "melee", penetration = "armour_penetration")

	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='danger'>You hit yourself over the head.</span>")
		user.adjustStaminaLoss(stamina_damage)

		additional_effects_carbon(user) // user is the target here
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(!isliving(target))
		return
	if(iscyborg(target))
		if (user.a_intent != INTENT_HARM)
			playsound(get_turf(src), on_stun_sound, 75, 1, -1)
			user.do_attack_animation(target) // The attacker cuddles the Cyborg, awww. No damage here.
			return
		return ..()
	if (user.a_intent == INTENT_HARM)
		if(!..())
			target.apply_damage(force, STAMINA, blocked = def_check)
			return
	else if(cooldown_check > world.time)
		var/wait_desc = get_wait_description()
		if (wait_desc)
			to_chat(user, wait_desc)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return
		if(check_martial_counter(H, user))
			return

			if (stun_animation)
				user.do_attack_animation(target)
			playsound(get_turf(src), on_stun_sound, 75, 1, -1)
			additional_effects_carbon(target, user)
			if((user.zone_selected == BODY_ZONE_CHEST))
				target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST, def_check)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])

			if((user.zone_selected == BODY_ZONE_HEAD))
				target.apply_damage(14, STAMINA, BODY_ZONE_HEAD, def_check)
				if(target.staminaloss > 89 && !target.has_status_effect(STATUS_EFFECT_SLEEPING) && (!sleep_cooldowns[target] || COOLDOWN_FINISHED(src, sleep_cooldowns[target])))
					if(!target.has_status_effect(STATUS_EFFECT_SLEEPING))
						target.Sleeping(80)
						target.setStaminaLoss(0)
						playsound(usr.loc, "sound/machines/bellsound.ogg", 15, 1)
						log_combat(user, target, "Knocked-Out", src)
				COOLDOWN_START(src, sleep_cooldowns[target], 16 SECONDS)
			else
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])

		else if(user.zone_selected == BODY_ZONE_L_LEG)
			log_combat(user, target, "stunned", src)
			target.visible_message(desc["visibleleg"], desc["localleg"])
			if (target.getStaminaLoss())
				target.apply_damage(25, STAMINA, BODY_ZONE_L_LEG, def_check)
			else
				target.apply_damage(10, STAMINA, BODY_ZONE_L_LEG, def_check)
			if (target.getStaminaLoss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_CHEST, def_check)

			if(target.getStaminaLoss() == 50 && CHECK_BITFIELD(target.mobility_flags, MOBILITY_STAND) && (!trip_cooldowns[target] || COOLDOWN_FINISHED(src, trip_cooldowns[target])))
				target.Knockdown(7)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
				playsound(usr.loc, "sound/misc/slip.ogg", 30, 1)
				COOLDOWN_START(src, trip_cooldowns[target], 3 SECONDS)

		else if(user.zone_selected == BODY_ZONE_R_LEG)
			log_combat(user, target, "stunned", src)
			target.visible_message(desc["visibleleg"], desc["localleg"])
			if (target.getStaminaLoss() < 26)
				target.apply_damage(25, STAMINA, BODY_ZONE_R_LEG, def_check)
			else
				target.apply_damage(10, STAMINA, BODY_ZONE_R_LEG, def_check)
			if (target.getStaminaLoss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_CHEST, def_check)

			if(target.getStaminaLoss() == 50 && CHECK_BITFIELD(target.mobility_flags, MOBILITY_STAND) && (!trip_cooldowns[target] || COOLDOWN_FINISHED(src, trip_cooldowns[target])))
				target.Knockdown(7)
				log_combat(user, target, "tripped", src)
				playsound(usr.loc, "sound/misc/slip.ogg", 30, 1)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
				COOLDOWN_START(src, trip_cooldowns[target], 3 SECONDS)

		else if(user.zone_selected == BODY_ZONE_L_ARM)
			if(!target.getStaminaLoss() == 50)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblearm"], desc["localarm"])
			else
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if (target.getStaminaLoss() < 26)
				target.apply_damage(20, STAMINA, BODY_ZONE_L_ARM, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_L_ARM, def_check)
			if (target.getStaminaLoss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(4, STAMINA, BODY_ZONE_CHEST, def_check)

		else if(user.zone_selected == BODY_ZONE_R_ARM)
			if(!target.getStaminaLoss() == 50)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblearm"], desc["localarm"])
			else
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if (target.getStaminaLoss())
				target.apply_damage(20, STAMINA, BODY_ZONE_R_ARM, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_R_ARM, def_check)
			if (target.getStaminaLoss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(4, STAMINA, BODY_ZONE_CHEST, def_check)

		add_fingerprint(user)

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = WEAKREF(user)
		COOLDOWN_START(src, cooldown_check, cooldown)
