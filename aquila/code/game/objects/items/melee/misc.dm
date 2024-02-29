
/obj/item/melee/classic_baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visibletrip"] =  "<span class ='danger'>[user] skosił [target] używając [src]! To musiało boleć.</span>"
	.["localtrip"] = "<span class ='danger'>[user] skosił cię używając [src]! Chryste Panie, jak to boli...</span>"
	.["visibleknockout"] =  "<span class ='danger'>[user] przyładował w łeb [target] za pomocą [src]! [target] pada nieprzytomny na glebę.</span>"
	.["localknockout"] = "<span class ='danger'>[user] przyładował ci w łeb [src] z taką siłą, że straciłeś przytomność...</span>"
	.["visibledisarm"] =  "<span class ='danger'>[user] celnym uderzeniem rozbroił [target] używając [src]!</span>"
	.["localdisarm"] = "<span class ='danger'>[user] pogruchotał ci rękę używając [src]! Z bólu upuściłeś wszystko z rąk.</span>"
	.["visiblestun"] =  "<span class ='danger'>[user] uderzył [target] przy użyciu [src]!</span>"
	.["localstun"] = "<span class ='danger'>[user] uderzył cię przy użyciu [src]!</span>"
	.["visibleshead"] =  "<span class ='danger'>[user] pieprznął [target] w łeb używając [src]!</span>"
	.["localhead"] = "<span class ='danger'>[user] pieprznął cię w łeb używając [src]!</span>"
	.["visiblearm"] =  "<span class ='danger'>[user] uderzył w rękę [target] używając [src]!</span>"
	.["localarm"] = "<span class ='danger'>[user] uderzył w twoją rękę przy użyciu [src]!</span>"
	.["visibleleg"] =  "<span class ='danger'>[user] uderzył w nogę [target] używając [src]!</span>"
	.["localleg"] = "<span class ='danger'>[user] uderzył cię w nogę używając [src]!</span>"

	return .

//Former Wooden Baton
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
	var/def_check = target.getarmor(type = melee, penetration = armour_penetration)

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

		var/list/desc = get_stun_description(target, user)
		var/obj/item/bodypart/La = target.get_bodypart(BODY_ZONE_L_ARM)
		var/obj/item/bodypart/Ra = target.get_bodypart(BODY_ZONE_R_ARM)
		var/obj/item/bodypart/Ll = target.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/Rl = target.get_bodypart(BODY_ZONE_R_LEG)
		var/mob/living/carbon/human/T = target

		user.do_attack_animation(target)
		playsound(get_turf(src), on_stun_sound, 75, 1, -1)
		additional_effects_carbon(target, user)
		if(user.zone_selected(BODY_ZONE_CHEST) || user.zone_selected(BODY_ZONE_PRECISE_GROIN))
			target.apply_damage(stamina_damage, STAMINA, BODY_ZONE_CHEST, def_check)
			log_combat(user, target, "stunned", src)
			target.visible_message(desc["visiblestun"], desc["localstun"])

		else if(user.zone_selected(BODY_ZONE_HEAD) || user.zone_selected(BODY_ZONE_PRECISE_EYES) || user.zone_selected(BODY_ZONE_PRECISE_MOUTH))
			target.apply_damage(18, STAMINA, BODY_ZONE_HEAD, def_check) // 90 : 5 = 18 , 5 hits to KnockOut

			if(target.staminaloss > 89 && !target.has_status_effect(STATUS_EFFECT_SLEEPING) && (!sleep_cooldowns[target] || COOLDOWN_FINISHED(src, sleep_cooldowns[target])))
				T.force_say(user)
				target.balloon_alert_to_viewers("Knock-Out!")
				if(!target.has_status_effect(STATUS_EFFECT_SLEEPING))
					target.Sleeping(80)
					target.setStaminaLoss(0)
					playsound(usr.loc, "sound/machines/bellsound.ogg", 15, 1)
					log_combat(user, target, "Knocked-Out", src)
				if(CHECK_BITFIELD(target.mobility_flags, MOBILITY_STAND)) //this is here so the "falls" message doesn't appear if the target is already on the floor
					target.visible_message("<span class='emote'><b>[T]</b> [pick(list("falls unconscious.","falls limp like a bag of bricks.","falls to the ground, unresponsive.","lays down on the ground for a little nap.","got [T.p_their()] dome rung in."))]</span>")
				else
					target.visible_message("<span class='emote'><b>[T]</b> [pick(list("falls unconscious.","falls into a deep sleep.","was sent to dreamland.","closes [T.p_their()] and prepares for a little nap."))]</span>")
				COOLDOWN_START(src, sleep_cooldowns[target], 16 SECONDS)
			else
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblestun"], desc["localstun"])

		else if(user.zone_selected(BODY_ZONE_L_LEG))
			log_combat(user, target, "stunned", src)
			target.visible_message(desc["visibleleg"], desc["localleg"])
			if (Rl.get_staminaloss() < 26 && Ra.get_staminaloss() < 26 && La.get_staminaloss() < 26)
				target.apply_damage(25, STAMINA, BODY_ZONE_L_LEG, def_check)
			else
				target.apply_damage(10, STAMINA, BODY_ZONE_L_LEG, def_check)
			if (Ll.get_staminaloss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_CHEST, def_check)

			if(Ll.get_staminaloss() == 50 && CHECK_BITFIELD(target.mobility_flags, MOBILITY_STAND) && (!trip_cooldowns[target] || COOLDOWN_FINISHED(src, trip_cooldowns[target])))
				target.visible_message("<span class='emote'><b>[T]</b> [pick(list("falls down.","falls face first into the floor.","gets viciously tripped.","got clumsy."))]</span>")
				target.balloon_alert_to_viewers("Tripped!")
				target.Knockdown(7)
				log_combat(user, target, "tripped", src)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
				playsound(usr.loc, "sound/misc/slip.ogg", 30, 1)
				COOLDOWN_START(src, trip_cooldowns[target], 3 SECONDS)

		else if(user.zone_selected(BODY_ZONE_R_LEG))
			log_combat(user, target, "stunned", src)
			target.visible_message(desc["visibleleg"], desc["localleg"])
			if (Ll.get_staminaloss() < 26 && Ra.get_staminaloss() < 26 && La.get_staminaloss() < 26)
				target.apply_damage(25, STAMINA, BODY_ZONE_R_LEG, def_check)
			else
				target.apply_damage(10, STAMINA, BODY_ZONE_R_LEG, def_check)
			if (Rl.get_staminaloss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_CHEST, def_check)

			if(Rl.get_staminaloss() == 50 && CHECK_BITFIELD(target.mobility_flags, MOBILITY_STAND) && (!trip_cooldowns[target] || COOLDOWN_FINISHED(src, trip_cooldowns[target])))
				target.visible_message("<span class='emote'><b>[T]</b> [pick(list("falls down.","falls face first into the floor.","gets viciously tripped.","got clumsy."))]</span>")
				target.balloon_alert_to_viewers("Tripped!")
				target.Knockdown(7)
				log_combat(user, target, "tripped", src)
				playsound(usr.loc, "sound/misc/slip.ogg", 30, 1)
				target.visible_message(desc["visibletrip"], desc["localtrip"])
				COOLDOWN_START(src, trip_cooldowns[target], 3 SECONDS)

		else if(user.zone_selected(BODY_ZONE_L_ARM))
			if(!La.get_staminaloss() == 50)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblearm"], desc["localarm"])
			else
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if (Ra.get_staminaloss() < 26 && Ll.get_staminaloss() < 26 && Rl.get_staminaloss() < 26)
				target.apply_damage(20, STAMINA, BODY_ZONE_L_ARM, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_L_ARM, def_check)
			if (La.get_staminaloss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(4, STAMINA, BODY_ZONE_CHEST, def_check)

		else if(user.zone_selected(BODY_ZONE_R_ARM))
			if(!Ra.get_staminaloss() == 50)
				log_combat(user, target, "stunned", src)
				target.visible_message(desc["visiblearm"], desc["localarm"])
			else
				log_combat(user, target, "disarmed", src)
				target.visible_message(desc["visibledisarm"], desc["localdisarm"])
			if (La.get_staminaloss() < 26 && Ll.get_staminaloss() < 26 && Rl.get_staminaloss() < 26)
				target.apply_damage(20, STAMINA, BODY_ZONE_R_ARM, def_check)
			else
				target.apply_damage(5, STAMINA, BODY_ZONE_R_ARM, def_check)
			if (Ra.get_staminaloss() == 50)
				target.apply_damage(10, STAMINA, BODY_ZONE_CHEST, def_check)
			else
				target.apply_damage(4, STAMINA, BODY_ZONE_CHEST, def_check)

		add_fingerprint(user)

		if(!iscarbon(user))
			target.LAssailant = null
		else
			target.LAssailant = WEAKREF(user)
		COOLDOWN_START(src, cooldown_check, cooldown)
