// AQUILA - łupy po wędrowcu pustki (tg: voidwalker_loot.dm)

/// Daje stabilne oświecenie, a oświeconym ramię pożerające szkło
/obj/item/clothing/head/helmet/skull/cosmic
	name = "cosmic skull"
	desc = "Widać i czuć, jak pulsuje przez nią kosmos..."
	icon = 'aquila/icons/obj/voidwalker_items.dmi'
	icon_state = "cosmic_skull_charged"
	light_color = "#CC00CC"
	light_range = 3
	light_power = 1
	/// Stan ikony po wyczerpaniu
	var/drained_icon_state = "cosmic_skull_drained"
	/// Ile razy jeszcze zadziała
	var/uses = 1

/obj/item/clothing/head/helmet/skull/cosmic/attack_self(mob/user, modifiers)
	. = ..()
	if(istype(user, /mob/living/simple_animal/hostile/voidwalker))
		to_chat(user, "<span class='userdanger'>O NIE!!! DLACZEGOOO??!!! KTO MÓGŁ TO ZROBIĆ?!!</span>")
		return
	if(!uses || !ishuman(user))
		return
	to_chat(user, "<span class='purple'>Zaczynasz wpatrywać się w [src]...</span>")
	if(!do_after(user, 10 SECONDS, TRUE, src))
		return
	if(!uses)
		return
	uses--
	if(uses <= 0)
		icon_state = drained_icon_state
		set_light(0)

	var/mob/living/carbon/human/starer = user
	if(starer.has_trauma_type(/datum/brain_trauma/voided/stable))
		starer.put_in_hands(new /obj/item/void_eater, TRUE, forced = TRUE)
		playsound(starer, 'sound/effects/blobattack.ogg', 60, TRUE)
	else
		starer.cure_trauma_type(/datum/brain_trauma/voided, TRAUMA_RESILIENCE_LOBOTOMY) // to już nie miałoby sensu
		starer.gain_trauma(/datum/brain_trauma/voided/stable, TRAUMA_RESILIENCE_LOBOTOMY)
	to_chat(user, "<span class='purple'>I otwiera się przed tobą cały świat.</span>")
	playsound(get_turf(user), 'sound/effects/curse5.ogg', 60)
	log_game("[key_name(user)] used a cosmic skull at [AREACOORD(user)]")

/// Ramię, które rozbija każde szkło i każde ciało
/obj/item/void_eater
	name = "void eater"
	desc = "Zdeformowana kończyna, która roztrzaska każde szkło i każde ciało."
	icon = 'aquila/icons/obj/voidwalker_items.dmi'
	icon_state = "tentacle"
	item_state = "tentacle"
	lefthand_file = 'aquila/icons/mob/inhands/voidwalker_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/voidwalker_righthand.dmi'
	force = 25
	armour_penetration = 35
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	tool_behaviour = TOOL_MINING
	toolspeed = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("rozcina", "tnie", "rozrywa")
	sharpness = IS_SHARP

/obj/item/void_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/void_eater/pre_attack(atom/target, mob/living/user, params)
	if(!(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
		return ..()
	var/obj/structure/grille/grille = istype(target, /obj/structure/grille) ? target : locate(/obj/structure/grille) in get_turf(target)
	if(grille && voidwalker_grille_shocked(grille))
		target.balloon_alert(user, "pod prądem!")
	else
		voidwalker_temporary_shatter(get_turf(target))
	return FALSE // u nas FALSE przerywa atak

/// Szkło na polu na chwilę rozpada się w odłamki i znika, a potem odrasta
/proc/voidwalker_temporary_shatter(turf/target_turf, duration = 10 SECONDS)
	var/shattered = FALSE
	for(var/obj/structure/structure in target_turf)
		if(!structure.density || !(istype(structure, /obj/structure/window) || istype(structure, /obj/structure/grille)))
			continue
		structure.density = FALSE
		structure.alpha = 0
		structure.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		structure.air_update_turf(TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(voidwalker_unshatter), structure), duration)
		shattered = TRUE
	if(shattered)
		playsound(target_turf, "shatter", 70, TRUE)
		new /obj/effect/decal/cleanable/glass(target_turf)

/proc/voidwalker_unshatter(obj/structure/structure)
	if(QDELETED(structure))
		return
	structure.alpha = initial(structure.alpha)
	structure.mouse_opacity = initial(structure.mouse_opacity)
	voidwalker_undeform_glass(structure)
	structure.air_update_turf(TRUE)

/// Odłamki szkła, które sypią się z wędrowca
/obj/effect/spawner/lootdrop/voidwalker_shards
	loot = list(/obj/item/shard = 3, /obj/item/shard/plasma = 1)
	fan_out_items = TRUE
	/// Najmniej odłamków
	var/min_spawn = 4
	/// Najwięcej odłamków
	var/max_spawn = 6

/obj/effect/spawner/lootdrop/voidwalker_shards/Initialize(mapload)
	lootcount = rand(min_spawn, max_spawn)
	return ..()

/obj/effect/spawner/lootdrop/voidwalker_shards/mini
	min_spawn = 1
	max_spawn = 2
