/datum/martial_art/psychotic_brawling
	name = "Psychotic Brawling"
	id = MARTIALART_PSYCHOBRAWL

/datum/martial_art/psychotic_brawling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(HAS_TRAIT(A, TRAIT_PACIFISM))
		return FALSE
	return psycho_attack(A,D)

/datum/martial_art/psychotic_brawling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(HAS_TRAIT(A, TRAIT_PACIFISM))
		return FALSE
	return psycho_attack(A,D, TRUE)

/datum/martial_art/psychotic_brawling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_attack(A,D)

/datum/martial_art/psychotic_brawling/proc/psycho_attack(mob/living/carbon/human/A, mob/living/carbon/human/D, grab_attack)
	var/atk_verb
	switch(rand(1,8))
		if(1)
			D.help_shake_act(A)
			atk_verb = "pomaga"
		if(2)
			A.emote("cry")
			A.Stun(20)
			atk_verb = "płacze, patrząc na"
		if(3)
			if(A.grab_state >= GRAB_AGGRESSIVE)
				D.grabbedby(A, 1)
			else
				A.start_pulling(D, supress_message = TRUE)
				if(A.pulling)
					D.drop_all_held_items()
					D.stop_pulling()
					if(grab_attack)
						log_combat(A, D, "grabbed", addition="aggressively")
						D.visible_message("<span class='warning'>[A] brutalnie chwyta [D]!</span>", \
										"<span class='userdanger'>[A] brutalnie cię chwyta!</span>", "<span class='hear'>Słyszysz odgłosy agresywnego obmacywania!</span>", null, A)
						to_chat(A, "<span class='danger'>Brutalnie chwytasz [D]!</span>")
						A.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab
					else
						log_combat(A, D, "grabbed", addition="passively")
						A.setGrabState(GRAB_PASSIVE)
		if(4)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = "uderza głową"
			D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] cię!</span>")
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 40, 1, -1)
			D.apply_damage(rand(5,10), A.dna.species.attack_type, BODY_ZONE_HEAD)
			A.apply_damage(rand(5,10), A.dna.species.attack_type, BODY_ZONE_HEAD)
			if(!istype(D.head,/obj/item/clothing/head/helmet/) && !istype(D.head,/obj/item/clothing/head/hardhat))
				D.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			A.Stun(rand(10,45))
			D.Stun(rand(5,30))
		if(5,6)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = pick("uderza", "kopie", "wali", "wbija się w")
			D.visible_message("<span class='danger'>[A] [atk_verb] [D] z nieludzką siłą, posyłając go w powietrze!</span>", \
							  "<span class='userdanger'>[A] [atk_verb] cię z nieludzką siłą, posyłając cię w powietrze!</span>")
			D.apply_damage(rand(15,30), A.dna.species.attack_type)
			playsound(get_turf(D), 'sound/effects/meteorimpact.ogg', 25, 1, -1)
			var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
			D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
			D.Paralyze(60)
		if(7,8)
			return FALSE //Resume default behaviour

	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Psychotic Brawling)")
	return 1
