/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING

/datum/martial_art/boxing/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Podczas boksu nie można rozbrajać!</span>")
	return 1

/datum/martial_art/boxing/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>Podczas boksu nie można chwytać!</span>")
	return 1

/datum/martial_art/boxing/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("lewym sierpowym","prawym sierpowym","prostym ciosem")

	var/damage = 6 + A.dna.species.punchdamage
	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] chybia [atk_verb], celując w [D]!</span>", \
			"<span class='userdanger'>[A] chybia [atk_verb], celując w ciebie!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to hit", atk_verb)
		return 0


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)

	D.visible_message("<span class='danger'>[A] trafia [D] [atk_verb]!</span>", \
			"<span class='userdanger'>[A] trafia cię [atk_verb]!</span>", null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ")
	if(D.getStaminaLoss() > 50 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] nokautuje [D] potężnym zamachem!</span>", \
								"<span class='userdanger'>[A] nokautuje cię potężnym zamachem!</span>")
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
			D.force_say(A)
			log_combat(A, D, "knocked out (boxing) ")
		else if(!(D.mobility_flags & MOBILITY_STAND))
			D.force_say(A)
	return 1

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)
	return
