/**
 * Bitrunning tech disks which let you load full loadouts into the vdom on first avatar generation.
 */
/obj/item/disk/bitrunning/gimmick
	desc = "Dysk z kodem źródłowym. Pozwala wczytać tematyczny zestaw do domeny wirtualnej."
	/// The selected loadout that this grants
	var/datum/bitrunning_gimmick/granted_loadout
	/// The list of loadouts that this can grant
	var/list/datum/bitrunning_gimmick/selectable_loadouts

/obj/item/disk/bitrunning/gimmick/Destroy()
	QDEL_NULL(granted_loadout)
	return ..()

/obj/item/disk/bitrunning/gimmick/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	if(isnull(granted_loadout))
		return BITRUNNER_GEAR_LOAD_FAILED
	return granted_loadout.grant_loadout(neo, avatar, domain_flags)

/obj/item/disk/bitrunning/gimmick/attack_self(mob/user)
	if(granted_loadout)
		return

	var/list/names = list()
	for(var/datum/bitrunning_gimmick/loadout as anything in selectable_loadouts)
		names += initial(loadout.name)

	var/choice = tgui_input_list(user, "Wybierz zestaw", "Program bitrunnera", names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/datum/bitrunning_gimmick/loadout as anything in selectable_loadouts)
		if(initial(loadout.name) == choice)
			granted_loadout = new loadout()

	balloon_alert(user, "wybrano")
	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	choice_made = choice


/**
 * The datum used by the gimmick loadout disk to determine what a loadout actually spawns.
 */
/datum/bitrunning_gimmick
	/// Player readable name of the gimmick loadout
	var/name = "Zestaw"
	/// The list of spells that this will grant
	var/list/obj/effect/proc_holder/spell/granted_actions
	/// The list of items that this will grant
	var/list/obj/item/granted_items
	/// The item type we will use as a container for our granted items, given to the avatar
	var/obj/item/container_item_type = /obj/item/storage/secure/briefcase/digital_storage
	/// Prefix our name onto the container
	var/prefix_container_name = TRUE

/// Grants out loadout.
/datum/bitrunning_gimmick/proc/grant_loadout(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	var/return_flags = NONE
	return_flags |= grant_items(neo, avatar, domain_flags)
	return_flags |= grant_abilities(neo, avatar, domain_flags)
	return return_flags

/datum/bitrunning_gimmick/proc/grant_items(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	if(!length(granted_items))
		return NONE

	if(domain_flags & DOMAIN_FORBIDS_ITEMS)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	var/obj/item/container_item = new container_item_type(avatar.drop_location())
	if(prefix_container_name)
		container_item.name = "[lowertext(name)]: [initial(container_item.name)]"

	for(var/obj/item/granted_item as anything in granted_items)
		new granted_item(container_item)

	avatar.put_in_hands(container_item)

	return NONE

/datum/bitrunning_gimmick/proc/grant_abilities(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	if(!length(granted_actions))
		return NONE

	if(domain_flags & DOMAIN_FORBIDS_ABILITIES)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	var/return_flags = NONE

	for(var/obj/effect/proc_holder/spell/granted_action as anything in granted_actions)
		if(locate(granted_action) in avatar.mob_spell_list)
			return_flags |= BITRUNNER_GEAR_LOAD_FAILED
			continue

		avatar.AddSpell(new granted_action(null))

	return return_flags

/// Cyfrowa walizka, mieści cały zestaw
/obj/item/storage/secure/briefcase/digital_storage
	name = "cyfrowa walizka"
	desc = "Walizka wygenerowana w domenie wirtualnej. Zamek to tylko dekoracja."

/obj/item/storage/secure/briefcase/digital_storage/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 60
	STR.max_items = 14
	STR.locked = FALSE

/obj/item/storage/secure/briefcase/digital_storage/PopulateContents()
	return

/**
 * Bitrunning gimmick loadouts themed around dungeon crawling.
 * Mostly for fun, have niche but not insignificant advantages.
 */
/obj/item/disk/bitrunning/gimmick/dungeon
	name = "zestaw bitrunnera: łażenie po lochach"
	selectable_loadouts = list(
		/datum/bitrunning_gimmick/alchemist,
		/datum/bitrunning_gimmick/rogue,
		/datum/bitrunning_gimmick/healer,
		/datum/bitrunning_gimmick/wizard,
	)


/datum/bitrunning_gimmick/alchemist
	name = "Alchemik"

	granted_items = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/mask/gas/plaguedoctor,
		/obj/item/clothing/head/plaguedoctorhat,
		/obj/item/storage/box/alchemist_basic_chems,
		/obj/item/storage/box/alchemist_basic_chems,
		/obj/item/storage/box/alchemist_random_chems,
		/obj/item/storage/box/alchemist_chemistry_kit,
	)

/obj/item/storage/box/alchemist_basic_chems
	name = "pudełko z butelkami"
	desc = "Pudełko pełne nieopisanych butelek."

/obj/item/storage/box/alchemist_basic_chems/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/alchemist_basic(src)

/obj/item/storage/box/alchemist_random_chems
	name = "pudełko z dziwnymi butelkami"
	desc = "Pudełko pełne butelek z dziwnymi etykietami."

/obj/item/storage/box/alchemist_random_chems/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/alchemist_random(src)

/obj/item/storage/box/alchemist_chemistry_kit
	name = "zestaw alchemika"
	desc = "Wszystko, czego potrzeba do podejrzanej chemii."

/obj/item/storage/box/alchemist_chemistry_kit/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker/large(src)
	new /obj/item/reagent_containers/glass/beaker/large(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/lighter(src)

/obj/item/reagent_containers/glass/bottle/alchemist_basic
	name = "butelka bez etykiety"
	desc = "Mała butelka. Nie pamiętasz, co do niej wlałeś."

/obj/item/reagent_containers/glass/bottle/alchemist_basic/Initialize(mapload)
	. = ..()
	var/static/list/possible_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/consumable/coffee,
	)
	reagents.add_reagent(pick(possible_reagents), 30)

/obj/item/reagent_containers/glass/bottle/alchemist_random
	name = "butelka z czaszką"
	desc = "Mała butelka. Nie pamiętasz, co do niej wlałeś."

/obj/item/reagent_containers/glass/bottle/alchemist_random/Initialize(mapload)
	. = ..()
	var/static/list/possible_adjectives = list(
		"bez etykiety",
		"z czaszką",
		"z serduszkiem",
		"z wybuchem",
		"z rybką",
		"z uśmiechem",
		"ze smutną minką",
		"z kostką d20",
		"z nieczytelną etykietą",
		"pożółkła",
		"zakrwawiona",
		"popękana",
		"złowroga",
	)
	name = "butelka [pick(possible_adjectives)]"
	reagents.add_reagent(get_random_reagent_id(), rand(20, 30))

/datum/bitrunning_gimmick/rogue
	name = "Łotrzyk"

	granted_items = list(
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/clothing/mask/bandana/black,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/bedsheet/black,
		/obj/item/storage/belt/fannypack/black,
		/obj/item/kitchen/knife/combat/survival,
	)

/datum/bitrunning_gimmick/healer
	name = "Uzdrowiciel"

	granted_items = list(
		/obj/item/clothing/under/costume/singer/yellow,
		/obj/item/clothing/shoes/singery,
		/obj/item/rod_of_asclepius,
		/obj/item/storage/backpack/duffelbag/med/surgery,
		/obj/item/roller,
		/obj/item/reagent_containers/dropper,
	)


/datum/bitrunning_gimmick/wizard
	name = "Czarodziej"

	granted_items = list(
		/obj/item/clothing/head/wizard/fake,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/staff,
		/obj/item/toy/eightball,
		/obj/item/storage/fancy/cigarettes/cigpack_cannabis,
		/obj/item/storage/box/matches,
	)

	granted_actions = list(
		/obj/effect/proc_holder/spell/targeted/smoke/lesser,
	)

/**
 * Bitrunning gimmick loadouts themed around sports.
 * Mostly for fun, have niche or little advantages.
 */
/obj/item/disk/bitrunning/gimmick/sports
	name = "zestaw bitrunnera: sport"
	selectable_loadouts = list(
		/datum/bitrunning_gimmick/boxer,
		/datum/bitrunning_gimmick/skater,
		/datum/bitrunning_gimmick/archer,
		/datum/bitrunning_gimmick/gamer,
	)


/datum/bitrunning_gimmick/boxer
	name = "Bokser"

	granted_items = list(
		/obj/item/clothing/gloves/boxing,
		/obj/item/clothing/under/shorts/red,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull,
		/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull,
	)


/datum/bitrunning_gimmick/skater
	name = "Skater"

	granted_items = list(
		/obj/item/clothing/shoes/wheelys,
		/obj/item/melee/skateboard,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
	)

/datum/bitrunning_gimmick/archer
	name = "Łucznik"

	granted_items = list(
		/obj/item/clothing/under/costume/geisha,
		/obj/item/clothing/shoes/sandal,
		/obj/item/storage/belt/quiver,
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/gun/ballistic/bow,
	)


/datum/bitrunning_gimmick/gamer
	name = "Gracz"

	granted_items = list(
		/obj/item/clothing/under/suit/black_really,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/modular_computer/laptop/preset/civillian,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game,
	)
