// Zaklejanie ust taśmą: celuj w usta i kliknij osobę taśmą (bez intencji harm)
/obj/item/stack/sticky_tape/attack(mob/living/M, mob/living/user)
	if(iscarbon(M) && user.zone_selected == BODY_ZONE_PRECISE_MOUTH && user.a_intent != INTENT_HARM)
		tape_mouth(M, user)
		return
	return ..()

/obj/item/stack/sticky_tape/proc/tape_mouth(mob/living/carbon/target, mob/living/user)
	if(!target.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, "<span class='warning'>[target] nie ma głowy, którą można by okleić!</span>")
		return
	if(target.wear_mask)
		to_chat(user, "<span class='warning'>[target == user ? "Twoje usta zakrywa" : "Usta [target] zakrywa"] [target.wear_mask]!</span>")
		return
	if(target == user)
		user.visible_message("<span class='notice'>[user] zaczyna zaklejać sobie usta taśmą.</span>", "<span class='notice'>Zaczynasz zaklejać sobie usta taśmą.</span>")
	else
		user.visible_message("<span class='warning'>[user] zaczyna zaklejać [target] usta taśmą!</span>", "<span class='warning'>Zaczynasz zaklejać [target] usta taśmą!</span>")
	if(!do_mob(user, target, target == user ? 1 SECONDS : 3 SECONDS))
		return
	if(target.wear_mask || !use(1))
		return
	var/obj/item/clothing/mask/muzzle/tape/gag = new(get_turf(target))
	if(!target.equip_to_slot_if_possible(gag, ITEM_SLOT_MASK, qdel_on_fail = TRUE, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		return
	user.visible_message("<span class='warning'>[user] zakleja [target == user ? "sobie" : "[target]"] usta taśmą!</span>")
	log_combat(user, target, "taped mouth shut", src)

/obj/item/clothing/mask/muzzle/tape
	name = "tape gag"
	desc = "Pasek lepkiej taśmy przyklejony komuś na usta. Zrywanie go nie będzie przyjemne."
	icon = 'aquila/icons/obj/clothing/tape_gag.dmi'
	worn_icon = 'aquila/icons/mob/tape_gag.dmi'
	icon_state = "tape_gag"
	item_state = null
	gas_transfer_coefficient = 1
	equip_delay_other = 0
	strip_delay = 2 SECONDS

/obj/item/clothing/mask/muzzle/tape/dropped(mob/user)
	. = ..()
	if(QDELETED(src))
		return
	if(user)
		to_chat(user, "<span class='warning'>Zerwana taśma zwija się w kulkę.</span>")
	playsound(get_turf(src), 'sound/items/poster_ripped.ogg', 40, TRUE)
	QDEL_IN(src, 0)
