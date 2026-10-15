#define SLAM_COMBO "GH"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "DDH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	block_chance = 75
	var/just_a_cook = FALSE
	smashes_tables = TRUE
	display_combos = TRUE

	Move1 = "Rzut: chwyt, cios. Rzuca przeciwnika o ziemię, przewracając go."
	Move2 = "Kopnięcie CQC: cios, cios. Odrzuca przeciwnika. Nokautuje ogłuszonych lub powalonych przeciwników."
	Move3 = "Dźwignia: chwyt, chwyt. Unieruchamia przeciwnika w dźwigni; pchnięcie nokautuje go duszeniem."
	Move4 = "Ucisk: pchnięcie, chwyt. Spore obrażenia wytrzymałości."
	Move5 = "Seria CQC: pchnięcie, pchnięcie, cios. Głównie ofensywny ruch, ogromne obrażenia i spore obrażenia wytrzymałości."

	AdditionText = "Ponadto, mając włączony tryb rzucania podczas ataku, wchodzisz w aktywną obronę, w której masz szansę zablokować, a czasem nawet skontrować wymierzone w ciebie ataki."

	var/old_grab_state = null
	var/mob/restraining_mob

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	just_a_cook = TRUE

/datum/martial_art/cqc/reset_streak(mob/living/new_target, update_icon = TRUE)
	if(new_target && new_target != restraining_mob)
		restraining_mob = null
	return ..()

/datum/martial_art/cqc/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(just_a_cook && !(istype(A, /area/crew_quarters/kitchen)))
		return FALSE
	return ..()

/datum/martial_art/cqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,SLAM_COMBO))
		reset_streak()
		return Slam(A,D)
	if(findtext(streak,KICK_COMBO))
		reset_streak()
		return Kick(A,D)
	if(findtext(streak,RESTRAIN_COMBO))
		reset_streak()
		return Restrain(A,D)
	if(findtext(streak,PRESSURE_COMBO))
		reset_streak()
		return Pressure(A,D)
	if(findtext(streak,CONSECUTIVE_COMBO))
		reset_streak()
		return Consecutive(A,D)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	if(D.mobility_flags & MOBILITY_STAND)
		D.visible_message("<span class='warning'>[A] rzuca [D] o ziemię!</span>", \
						  	"<span class='userdanger'>[A] rzuca cię o ziemię!</span>")
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE, blocked = def_check)
		D.Paralyze(12 SECONDS)
		log_combat(A, D, "slammed (CQC)")
		return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	if(!D.stat || !D.IsParalyzed())
		D.visible_message("<span class='warning'>[A] odrzuca [D] kopnięciem!</span>", \
							"<span class='userdanger'>[A] odrzuca cię kopnięciem!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, A.dna.species.attack_type, blocked = def_check)
		log_combat(A, D, "kicked (CQC)")
		. = TRUE
	if(D.IsParalyzed() && !D.stat)
		log_combat(A, D, "knocked out (Head kick)(CQC)")
		D.visible_message("<span class='warning'>[A] kopie [D] w głowę, nokautując go!</span>", \
					  		"<span class='userdanger'>[A] kopie cię w głowę, nokautując cię!</span>")
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		D.SetSleeping(300)
		D.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
		. = TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "pressured (CQC)")
	D.visible_message("<span class='danger'>[A] punches [D]'s neck!</span>", \
					"<span class='userdanger'>[A] uderza cię w szyję!</span>", null, COMBAT_MESSAGE_RANGE)
	D.adjustStaminaLoss(60)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(restraining_mob)
		return
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "restrained (CQC)")
		D.visible_message("<span class='warning'>[A] unieruchamia [D] w dźwigni!</span>", \
							"<span class='userdanger'>[A] unieruchamia cię w dźwigni!</span>")
		D.adjustStaminaLoss(20)
		D.Stun(10 SECONDS)
		restraining_mob = D
		addtimer(VARSET_CALLBACK(src, restraining_mob, null), 50, TIMER_UNIQUE)
		return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "consecutive CQC'd (CQC)")
		D.visible_message("<span class='warning'>[A] uderza kolejno w brzuch, szyję i plecy [D].</span>", \
							"<span class='userdanger'>[A] uderza cię kolejno w brzuch, szyję i plecy!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		var/obj/item/I = D.get_active_held_item()
		if(I && D.temporarilyRemoveItemFromInventory(I))
			A.put_in_hands(I)
		D.adjustStaminaLoss(50)
		D.apply_damage(25, A.dna.species.attack_type, blocked = def_check)
		return TRUE

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A != D && can_use(A)) // A != D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = A.grab_state
		D.grabbedby(A, 1)
		if(old_grab_state == GRAB_PASSIVE)
			D.drop_all_held_items()
			A.setGrabState(GRAB_AGGRESSIVE) //Instant agressive grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively")
			D.visible_message("<span class='warning'>[A] brutalnie chwyta [D]!</span>", \
								"<span class='userdanger'>[A] brutalnie cię chwyta!</span>")
		return TRUE
	else
		return FALSE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "attacked (CQC)")
	A.do_attack_animation(D)
	var/picked_hit_type = pick("załatwia CQC", "załatwia jak Big Boss")
	var/bonus_damage = 13
	if(!(D.mobility_flags & MOBILITY_STAND))
		bonus_damage += 5
		picked_hit_type = "depcze"
	D.apply_damage(bonus_damage, BRUTE, blocked = def_check)
	if(picked_hit_type == "kopie" || picked_hit_type == "depcze")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] cię!</span>", null, COMBAT_MESSAGE_RANGE)
	log_combat(A, D, "[picked_hit_type] (CQC)")
	if(A.resting && !D.stat && !D.IsParalyzed())
		D.visible_message("<span class='warning'>[A] podcina [D]!", \
							"<span class='userdanger'>[A] cię podcina!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE, blocked = def_check)
		D.Paralyze(6 SECONDS)
		log_combat(A, D, "sweeped (CQC)")
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	var/obj/item/I = null
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "disarmed (CQC)", "[I ? " grabbing \the [I]" : ""]")
	if(restraining_mob && A.pulling == restraining_mob)
		log_combat(A, D, "knocked out (Chokehold)(CQC)")
		D.visible_message("<span class='danger'>[A] zakłada [D] duszenie!</span>", \
							"<span class='userdanger'>[A] zakłada ci duszenie!</span>")
		D.SetSleeping(40 SECONDS)
		restraining_mob = null
		if(A.grab_state < GRAB_NECK && !HAS_TRAIT(A, TRAIT_PACIFISM))
			A.setGrabState(GRAB_NECK)
		return TRUE
	if(prob(65))
		if(!D.stat || !D.IsParalyzed() || !restraining_mob)
			I = D.get_active_held_item()
			D.visible_message("<span class='warning'>[A] uderza [D] dłonią w szczękę!</span>", \
								"<span class='userdanger'>[A] uderza cię w szczękę, dezorientując cię!</span>", null, COMBAT_MESSAGE_RANGE)
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, A.dna.species.attack_type, blocked = def_check)
	else
		D.visible_message("<span class='danger'>[A] nie udaje się rozbroić [D]!</span>", \
							"<span class='userdanger'>[A] nie udaje się cię rozbroić!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	return FALSE

#undef SLAM_COMBO
#undef KICK_COMBO
#undef RESTRAIN_COMBO
#undef PRESSURE_COMBO
#undef CONSECUTIVE_COMBO
