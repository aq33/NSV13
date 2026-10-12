#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	deflection_chance = 100
	reroute_deflection = TRUE
	no_guns = TRUE
	allow_temp_override = FALSE
	smashes_tables = TRUE
	display_combos = TRUE
	var/old_grab_state = null

	Move1 = "Wrist Wrench: Disarm Disarm. Forces opponent to drop item in hand."
	Move2 = "Back Kick: Harm Grab. Opponent must be facing away. Knocks down."
	Move3 = "Stomach Knee: Grab Harm. Knocks the wind out of opponent and stuns."
	Move4 = "Head Kick: Disarm Harm Harm. Decent damage, forces opponent to drop item in hand."
	Move5 = "Elbow Drop: Harm Disarm Harm Disarm Harm. Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition."

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		reset_streak()
		wristWrench(A,D)
		return 1
	if(findtext(streak,BACK_KICK_COMBO))
		reset_streak()
		backKick(A,D)
		return 1
	if(findtext(streak,STOMACH_KNEE_COMBO))
		reset_streak()
		kneeStomach(A,D)
		return 1
	if(findtext(streak,HEAD_KICK_COMBO))
		reset_streak()
		headKick(A,D)
		return 1
	if(findtext(streak,ELBOW_DROP_COMBO))
		reset_streak()
		elbowDrop(A,D)
		return 1
	return 0

/datum/martial_art/the_sleeping_carp/proc/wristWrench(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "wrist wrenched (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] chwyta [D] za nadgarstek i wykręca go w bok!</span>", \
						  "<span class='userdanger'>[A] chwyta cię za nadgarstek i gwałtownie wykręca go w bok!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		D.Stun(60)
		return 1
	
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/backKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		if(A.dir == D.dir)
			log_combat(A, D, "back-kicked (Sleeping Carp)")
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			D.visible_message("<span class='warning'>[A] kopie [D] w plecy!</span>", \
								"<span class='userdanger'>[A] kopie cię w plecy, przez co się potykasz i przewracasz!</span>")
			step_to(D,get_step(D,D.dir),1)
			D.Paralyze(80)
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
			return 1
		else
			log_combat(A, D, "missed a back-kick (Sleeping Carp) on")
			D.visible_message("<span class='warning'>[A] próbuje kopnąć [D] w plecy, ale chybia!</span>", \
								"<span class='userdanger'>[A] próbuje kopnąć cię w plecy, ale chybia!</span>")
			return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/kneeStomach(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "stomach kneed (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] wbija [D] kolano w brzuch!</span>", \
						  "<span class='userdanger'>[A] pozbawia cię tchu kolanem w brzuch!</span>")
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(40)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/headKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "head kicked (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] kopie [D] w głowę!</span>", \
						  "<span class='userdanger'>[A] kopie cię w szczękę!</span>")
		D.apply_damage(20, A.dna.species.attack_type, BODY_ZONE_HEAD, blocked = def_check)
		D.drop_all_held_items()
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Stun(80)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/elbowDrop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!(D.mobility_flags & MOBILITY_STAND))
		log_combat(A, D, "elbow dropped (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] spada łokciem na [D]!</span>", \
							"<span class='userdanger'>[A] wbija cię w ziemię łokciem!</span>")
		if(D.stat)
			D.death() //FINISH HIM!
		D.apply_damage(50, A.dna.species.attack_type, BODY_ZONE_CHEST, blocked = def_check)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A==D)
		return FALSE //prevents grabbing yourself
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

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("uderza", "kopie", "tnie kantem dłoni", "wali", "grzmoci")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] cię!</span>")
	D.apply_damage(15, BRUTE, blocked = def_check)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	log_combat(A, D, "[atk_verb] (Sleeping Carp)")
	return 1


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "disarmed (Sleeping Carp)")
	return ..()

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb = list("rozbija", "grzmoci", "wali", "trzaska")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_level = 1
	block_upgrade_walk = 1
	block_power = 25

/obj/item/staff/bostaff/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=24, block_power_unwielded=25, block_power_wielded=50, icon_wielded="bostaff1")

/obj/item/staff/bostaff/update_icon_state()
	icon_state = "bostaff0"
	..()

/obj/item/staff/bostaff/attack(mob/target, mob/living/user, params)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>Walisz się w głowę [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>Atakowanie wroga, który nie może oddać, byłoby niehonorowe.</span>")
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(!ISWIELDED(src))
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] okłada [H] za pomocą [src]!", \
									  "[user] uderza [H] trzonkiem [src]!", \
									  "[user] wali [H] płazem [src]!", \
									  "[user] rozbija [H] głowę za pomocą [src]!", \
									  "[user] bije [H] przodem [src]!", \
									  "[user] obraca się i grzmoci [H] za pomocą [src]!")
		H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
							   "<span class='userdanger'>[pick(fluffmessages)]</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
								   "<span class='userdanger'>Nogi odmawiają ci posłuszeństwa!</span>")
			H.Paralyze(80)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] zadaje potężny cios w głowę [H], nokautując go!</span>", \
									   "<span class='userdanger'>[user] pozbawia cię przytomności!</span>")
				H.SetSleeping(600)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!ISWIELDED(src))
		return ..()
	return 0
