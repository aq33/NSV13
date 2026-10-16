#define ORE_MULTIPLIER_IRON 3
#define ORE_MULTIPLIER_GLASS 2
#define ORE_MULTIPLIER_PLASMA 1
#define ORE_MULTIPLIER_SILVER 0.7
#define ORE_MULTIPLIER_GOLD 0.6
#define ORE_MULTIPLIER_TITANIUM 0.5
#define ORE_MULTIPLIER_URANIUM 0.4
#define ORE_MULTIPLIER_DIAMOND 0.3
#define ORE_MULTIPLIER_BLUESPACE_CRYSTAL 0.2

/obj/structure/closet/crate/secure/bitrunning // Base class. Do not spawn this.
	name = "base class cache"
	desc = "Zgłoś to koderowi."
	icon = 'aquila/icons/obj/bitrunning_crates.dmi'
	icon_state = "bitrunning"
	icon_door = null
	icon_door_override = FALSE
	door_anim_time = 0

/// tg sprite ma skrzynię zamkniętą i otwartą jako dwa stany, bez osobnej klapy
/obj/structure/closet/crate/secure/bitrunning/update_icon()
	cut_overlays()
	icon_state = opened ? "bitrunningopen" : "bitrunning"
	layer = opened ? BELOW_OBJ_LAYER : OBJ_LAYER
	if(opened)
		return
	if(broken)
		add_overlay("securecrateemag")
	else if(locked)
		add_overlay("securecrater")
	else
		add_overlay("securecrateg")

/// The virtual domain - side of the bitrunning crate. Deliver to the send location.
/obj/structure/closet/crate/secure/bitrunning/encrypted
	name = "zaszyfrowana skrzynia"
	desc = "Trzeba ją odszyfrować w kryjówce, żeby się otworzyła."
	locked = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/crate/secure/bitrunning/encrypted/togglelock(mob/living/user, silent)
	if(!silent)
		to_chat(user, span_warning("Tej skrzyni nie da się otworzyć tutaj. Zanieś ją do kryjówki."))
	return

/obj/structure/closet/crate/secure/bitrunning/encrypted/emag_act(mob/user)
	return

/// Very pushy gondolas, great for moving loot crates.
/obj/structure/closet/crate/secure/bitrunning/encrypted/gondola
	move_resist = MOVE_FORCE_STRONG

/// The bitrunner den - side of the bitrunning crate. Appears in the receive location.
/obj/structure/closet/crate/secure/bitrunning/decrypted
	name = "odszyfrowana skrzynia"
	desc = "Skompilowana z domeny wirtualnej. Nagroda dla udanego bitrunnera."
	locked = FALSE

/obj/structure/closet/crate/secure/bitrunning/decrypted/Initialize(mapload, datum/lazy_template/virtual_domain/completed_domain, rewards_multiplier = 1)
	. = ..()
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)

	if(isnull(completed_domain))
		return

	spawn_loot(completed_domain.completion_loot)
	spawn_ores(completed_domain.reward_points, rewards_multiplier)

/// Rudy w nagrodę
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/spawn_ores(reward_points, rewards_multiplier)
	new /obj/item/stack/ore/iron(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_IRON))
	new /obj/item/stack/ore/glass(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GLASS))

	if(reward_points > 1)
		new /obj/item/stack/ore/silver(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_SILVER))
		new /obj/item/stack/ore/titanium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_TITANIUM))

	if(reward_points > 2)
		new /obj/item/stack/ore/plasma(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_PLASMA))
		new /obj/item/stack/ore/gold(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_GOLD))
		new /obj/item/stack/ore/uranium(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_URANIUM))

	if(reward_points > 3)
		new /obj/item/stack/ore/diamond(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_DIAMOND))
		new /obj/item/stack/ore/bluespace_crystal(src, calculate_loot(reward_points, rewards_multiplier, ORE_MULTIPLIER_BLUESPACE_CRYSTAL))

/// Handles generating random numbers & calculating loot totals
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/calculate_loot(reward_points, rewards_multiplier, ore_multiplier)
	var/base = rewards_multiplier + reward_points
	var/random_sum = (rand() + 0.5) * base
	return max(ROUND_UP(random_sum * ore_multiplier), 1)

/// Handles spawning completion loot. This tries to handle bad flat and assoc lists
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/spawn_loot(list/completion_loot)
	for(var/path in completion_loot)
		if(!ispath(path))
			return FALSE

		if(isnull(completion_loot[path]))
			return FALSE

		for(var/i in 1 to completion_loot[path])
			new path(src)

	return TRUE

#undef ORE_MULTIPLIER_IRON
#undef ORE_MULTIPLIER_GLASS
#undef ORE_MULTIPLIER_PLASMA
#undef ORE_MULTIPLIER_SILVER
#undef ORE_MULTIPLIER_GOLD
#undef ORE_MULTIPLIER_TITANIUM
#undef ORE_MULTIPLIER_URANIUM
#undef ORE_MULTIPLIER_DIAMOND
#undef ORE_MULTIPLIER_BLUESPACE_CRYSTAL


/obj/item/storage/lockbox/bitrunning
	name = "base class curiosity"
	desc = "Zgłoś to koderowi."
	req_access = list(ACCESS_CENT_CAPTAIN)
	icon = 'aquila/icons/obj/bitrunning_items.dmi'
	icon_state = "bitrunning+l"
	item_state = "lockbox+l"
	base_icon_state = "bitrunning"

/obj/item/storage/lockbox/bitrunning/encrypted
	name = "zaszyfrowana ciekawostka"
	desc = "Trzeba ją odszyfrować w kryjówce, żeby się otworzyła."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/lockbox/bitrunning/encrypted/emag_act(mob/user)
	return FALSE

/obj/item/storage/lockbox/bitrunning/decrypted
	name = "odszyfrowana ciekawostka"
	desc = "Skompilowana z domeny wirtualnej. Dodatkowa nagroda dla udanego bitrunnera."
	icon_state = "bitrunning"
	item_state = "lockbox"
	/// What virtual domain did we come from.
	var/datum/lazy_template/virtual_domain/source_domain

/obj/item/storage/lockbox/bitrunning/decrypted/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.max_combined_w_class = 3
	STR.locked = FALSE

/obj/item/storage/lockbox/bitrunning/decrypted/Initialize(mapload, datum/lazy_template/virtual_domain/completed_domain)
	if(isnull(completed_domain))
		log_runtime("Decrypted curiosity was created with no source domain.")
		return INITIALIZE_HINT_QDEL
	source_domain = completed_domain
	. = ..()
	var/selected_path = SSbitrunning.pick_secondary_loot(source_domain)
	new selected_path(src)
	source_domain = null
