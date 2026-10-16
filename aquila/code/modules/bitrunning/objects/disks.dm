/**
 * Bitrunning tech disks which let you load items or programs into the vdom on first avatar generation.
 * For the record: Balance shouldn't be a primary concern.
 * You can make the custom cheese spells you've always wanted.
 * Just make it fun and engaging, it's PvE content.
 */
/obj/item/disk/bitrunning
	name = "ogólny program bitrunnera"
	desc = "Dysk z kodem źródłowym."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk0"
	/// Name of the choice made
	var/choice_made

/obj/item/disk/bitrunning/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0, 7)]"

/obj/item/disk/bitrunning/examine(mob/user)
	. = ..()
	. += span_infoplain("Żeby zadziałał, musisz mieć ten dysk przy sobie, gdy wchodzisz do netpoda.")

	if(isnull(choice_made))
		. += span_notice("Żeby dokonać wyboru, użyj dysku w dłoni.")
		return

	. += span_info("Wybrano: <b>[choice_made]</b>.")
	. += span_notice("Nie da się już zmienić wyboru.")

/// Handles loading our stuff onto avatars
/obj/item/disk/bitrunning/proc/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	return NONE

/obj/item/disk/bitrunning/ability
	desc = "Dysk z kodem źródłowym. Pozwala wczytać zdolności do domeny wirtualnej. Powtórzone zdolności zostaną pominięte."
	/// The selected ability that this grants
	var/obj/effect/proc_holder/spell/granted_action
	/// The list of actions that this can grant
	var/list/obj/effect/proc_holder/spell/selectable_actions = list()

/obj/item/disk/bitrunning/ability/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	if(domain_flags & DOMAIN_FORBIDS_ABILITIES)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	if(isnull(granted_action))
		return BITRUNNER_GEAR_LOAD_FAILED

	if(locate(granted_action) in avatar.mob_spell_list)
		return BITRUNNER_GEAR_LOAD_FAILED

	avatar.AddSpell(new granted_action(null))
	return NONE

/obj/item/disk/bitrunning/ability/attack_self(mob/user)
	if(choice_made)
		return

	var/list/names = list()
	for(var/obj/effect/proc_holder/spell/thing as anything in selectable_actions)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, "Wybierz zdolność", "Program bitrunnera", names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/obj/effect/proc_holder/spell/thing as anything in selectable_actions)
		if(initial(thing.name) == choice)
			granted_action = thing

	if(isnull(granted_action))
		return

	balloon_alert(user, "wybrano")
	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 programs. Simple, funny, or helpful.
/obj/item/disk/bitrunning/ability/tier1
	name = "program bitrunnera: podstawowy"
	selectable_actions = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/cheese,
		/obj/effect/proc_holder/spell/self/basic_heal,
	)

/// Tier 2 programs. More complex, powerful, or useful.
/obj/item/disk/bitrunning/ability/tier2
	name = "program bitrunnera: złożony"
	selectable_actions = list(
		/obj/effect/proc_holder/spell/aimed/fireball,
		/obj/effect/proc_holder/spell/aimed/lightningbolt,
		/obj/effect/proc_holder/spell/targeted/forcewall,
	)

/// Tier 3 abilities. Very powerful, game breaking.
/obj/item/disk/bitrunning/ability/tier3
	name = "program bitrunnera: elitarny"
	selectable_actions = list(
		/obj/effect/proc_holder/spell/targeted/shapeshift/dragon,
		/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear,
	)

/obj/effect/proc_holder/spell/aoe_turf/conjure/cheese
	name = "Przywołaj ser"
	desc = "Przywołuje stos sera. Nie pytaj."
	school = "conjuration"
	charge_max = 60 SECONDS
	clothes_req = FALSE
	invocation = "SER!"
	invocation_type = INVOCATION_SHOUT
	range = 0
	summon_type = list(/obj/item/food/cheese)
	summon_amt = 9
	action_icon_state = "spell_default"

/obj/effect/proc_holder/spell/targeted/shapeshift/polar_bear
	name = "Postać niedźwiedzia polarnego"
	desc = "Przybierz postać niedźwiedzia polarnego."
	invocation = "RAWR!"
	shapeshift_type = /mob/living/simple_animal/hostile/bear/snow
	clothes_req = FALSE


/obj/item/disk/bitrunning/item
	desc = "Dysk z kodem źródłowym. Pozwala wczytać przedmioty do domeny wirtualnej."
	/// The selected item that this grants
	var/obj/granted_item
	/// The list of actions that this can grant
	var/list/obj/selectable_items = list()

/obj/item/disk/bitrunning/item/load_onto_avatar(mob/living/carbon/human/neo, mob/living/carbon/human/avatar, domain_flags)
	if(domain_flags & DOMAIN_FORBIDS_ITEMS)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	if(isnull(granted_item))
		return BITRUNNER_GEAR_LOAD_FAILED

	avatar.put_in_hands(new granted_item(avatar.drop_location()))
	return NONE

/obj/item/disk/bitrunning/item/attack_self(mob/user)
	if(choice_made)
		return

	var/list/names = list()
	for(var/obj/thing as anything in selectable_items)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, "Wybierz przedmiot", "Program bitrunnera", names)
	if(isnull(choice) || !user.is_holding(src))
		return

	for(var/obj/thing as anything in selectable_items)
		if(initial(thing.name) == choice)
			granted_item = thing

	if(isnull(granted_item))
		return

	balloon_alert(user, "wybrano")
	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 items. Simple, funny, or helpful.
/obj/item/disk/bitrunning/item/tier1
	name = "sprzęt bitrunnera: prosty"
	selectable_items = list(
		/obj/item/pizzabox/infinite,
		/obj/item/gun/medbeam,
		/obj/item/grenade/plastic/c4,
	)

/// Tier 2 items. More complex, powerful, or useful.
/obj/item/disk/bitrunning/item/tier2
	name = "sprzęt bitrunnera: złożony"
	selectable_items = list(
		/obj/item/reagent_containers/hypospray/medipen/survival,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/clothing/suit/armor/vest,
	)

/// Tier 3 items. Very powerful, game breaking.
/obj/item/disk/bitrunning/item/tier3
	name = "sprzęt bitrunnera: zaawansowany"
	selectable_items = list(
		/obj/item/gun/energy/e_gun/nuclear,
		/obj/item/dualsaber/green,
		/obj/item/grenade/syndieminibomb,
	)

///proto-kinetic accelerator mods, to be applied to pka's given inside domains
/obj/item/disk/bitrunning/item/pka_mods
	name = "sprzęt bitrunnera: moduły kinetycznego akceleratora"
	selectable_items = list(
		/obj/item/borg/upgrade/modkit/range,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/aoe/mobs,
	)

/obj/item/disk/bitrunning/item/pka_mods/premium
	name = "sprzęt bitrunnera: lepsze moduły kinetycznego akceleratora"
	selectable_items = list(
		/obj/item/borg/upgrade/modkit/cooldown/repeater,
		/obj/item/borg/upgrade/modkit/lifesteal,
		/obj/item/borg/upgrade/modkit/resonator_blasts,
		/obj/item/borg/upgrade/modkit/bounty,
		/obj/item/borg/upgrade/modkit/indoors,
	)

///proto-kinetic crusher trophies, to be applied to pkc's given inside domains
/obj/item/disk/bitrunning/item/pkc_mods
	name = "sprzęt bitrunnera: trofea kinetycznego miażdżyciela"
	selectable_items = list(
		/obj/item/crusher_trophy/watcher_wing,
		/obj/item/crusher_trophy/legion_skull,
		/obj/item/crusher_trophy/goliath_tentacle,
	)

/obj/item/disk/bitrunning/item/pkc_mods/premium
	name = "sprzęt bitrunnera: lepsze trofea kinetycznego miażdżyciela"
	selectable_items = list(
		/obj/item/crusher_trophy/blaster_tubes,
		/obj/item/crusher_trophy/miner_eye,
		/obj/item/crusher_trophy/tail_spike,
		/obj/item/crusher_trophy/demon_claws,
		/obj/item/crusher_trophy/vortex_talisman,
	)

/obj/item/disk/bitrunning/item/mini_uzi
	name = "sprzęt bitrunnera: mini-uzi"
	selectable_items = list(
		/obj/item/gun/ballistic/automatic/mini_uzi,
	)
