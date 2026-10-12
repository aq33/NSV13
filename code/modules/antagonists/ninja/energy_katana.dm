/obj/item/energy_katana
	name = "energy katana"
	desc = "Katana nasycona potężną energią. Prawy przycisk myszy, by wykonać zryw."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	worn_icon_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 40
	throwforce = 20
	block_power = 50
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = IS_SHARP
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/ninja/jaunt

/obj/item/energy_katana/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/list/modifiers = params2list(click_parameters)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && !target.density)
		jaunt.Teleport(user, target)
	if(proximity_flag && (isobj(target) || issilicon(target)))
		spark_system.start()
		playsound(user, "sparks", 50, 1)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
		target.emag_act(user)

/obj/item/energy_katana/pickup(mob/living/user)
	..()
	jaunt.Grant(user, src)
	user.update_icons()
	playsound(src, 'sound/items/unsheath.ogg', 25, 1)

/obj/item/energy_katana/dropped(mob/user)
	..()
	jaunt.Remove(user)
	user.update_icons()

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(IS_SPACE_NINJA(H))
			returnToOwner(H, 0, 1)
			return

	..()

/obj/item/energy_katana/proc/returnToOwner(mob/living/carbon/human/user, doSpark = 1, caught = 0)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Twoja energetyczna katana teleportuje się do twojej dłoni!"
	else if(user.equip_to_slot_if_possible(src, ITEM_SLOT_BELT, 0, 1, 1))
		msg = "Twoja energetyczna katana teleportuje się z powrotem do ciebie, chowając się przy tym do pochwy!</span>"
	else
		msg = "Twoja energetyczna katana teleportuje się do twojego położenia!"

	if(caught)
		if(loc == user)
			msg = "Łapiesz swoją energetyczną katanę!"
		else
			msg = "Twoja energetyczna katana ląduje u twoich stóp!"

	if(msg)
		to_chat(user, "<span class='notice'>[msg]</span>")


/obj/item/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/datum/action/innate/dash/ninja
	current_charges = 3
	max_charges = 3
	charge_rate = 30
	recharge_sound = null
