/*
	In this file:
		various vampire interactions and items
*/


/obj/item/clothing/suit/draculacoat
	name = "Vampire Coat"
	desc = "What is a man? A miserable little pile of secrets."
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	icon_state = "draculacoat"
	item_state = "draculacoat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slowdown = -0.2 //very minor speedboost
	allowed = null
	var/blood_regen_delay = 10 SECONDS
	COOLDOWN_DECLARE(regen_cooldown)
	var/dodge_delay = 10 SECONDS
	COOLDOWN_DECLARE(dodge_cooldown)

/obj/item/clothing/suit/draculacoat/Initialize()
	if(!allowed)
		allowed = GLOB.security_vest_allowed
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(owner.wear_suit != src || owner.incapacitated() || !COOLDOWN_FINISHED(src, dodge_cooldown) || !is_vampire(owner))
		return FALSE
	COOLDOWN_START(src, dodge_cooldown, dodge_delay)
	owner.balloon_alert_to_viewers("dodged!", "dodged!", COMBAT_MESSAGE_RANGE)
	owner.visible_message("<span class='danger'>With inhuman speed [owner] dodges [attack_text]!</span>", "<span class='userdanger'>You dodge [attack_text]!</span>", null, COMBAT_MESSAGE_RANGE)
	playsound(owner, 'sound/effects/space_wind_big.ogg', 50, 1)
	return TRUE

/obj/item/clothing/suit/draculacoat/process()
	var/mob/living/carbon/human/user = src.loc
	if(user && ishuman(user) && is_vampire(user) && (user.wear_suit == src))
		if(COOLDOWN_FINISHED(src, regen_cooldown))
			COOLDOWN_START(src, regen_cooldown, blood_regen_delay)
			var/datum/antagonist/vampire/vampire = is_vampire(user)
			if(vampire.total_blood >= 5 && vampire.usable_blood < vampire.total_blood)
				vampire.usable_blood = min(vampire.usable_blood + 5, vampire.total_blood) // 5 units every 10 seconds

/mob/living/carbon/human/handle_fire()
	. = ..()
	if(mind)
		var/datum/antagonist/vampire/L = mind.has_antag_datum(/datum/antagonist/vampire)
		if(on_fire && stat == DEAD && L && !L.get_ability(/datum/vampire_passive/full))
			dust()

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	. = ..()
	if(!(user.mind && user.mind.holy_role) && is_vampire(user))
		to_chat(user, "<span class='danger'>[deity_name] channels through \the [src] and sets you ablaze for your blasphemy!</span>")
		user.adjust_fire_stacks(5)
		user.IgniteMob()
		user.emote("scream", 1)
