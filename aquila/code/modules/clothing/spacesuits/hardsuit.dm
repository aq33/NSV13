/*************************************\
|*********** kombinezon HEV **********|
\*************************************/
/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit
	name = "HEV suit helmet"
	desc = "A Hazardous Environment Helmet. It fits snug over the suit and has a heads-up display for researchers."
	icon_state = "hardsuit0-hev"
	hardsuit_type = "hev"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor = list("melee" = 30, "bullet" = 10, "laser" = 10, "energy" = 15, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "stamina" = 30)
	clothing_flags =  SHOWEROKAY | SCAN_REAGENTS //te borowiki z bee zrobily burdel w hardsuit.dm, w przyszlosci bedzie trzeba zrobic refactor i sanitisation
	var/obj/machinery/doppler_array/integrated/bomb_radar
	actions_types = list(/datum/action/item_action/toggle_research_scanner, /datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit/Initialize(mapload)
	. = ..()
	bomb_radar = new /obj/machinery/doppler_array/integrated(src)

/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.remove_hud_from(user)

/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit
	name = "HEV Suit"
	desc = "A Hazardous Environment suit, often called the Hazard suit. It was designed to protect scientists from the blunt trauma, radiation, energy discharge that hazardous materials might produce or entail. Fits you like a glove. The automatic medical system seems broken."
	item_state = "hardsuit-hev"
	icon_state = "hardsuit-hev"
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON //jak ci sie nie podoba to dostosuj sprite i zmien var na DIGITIGRADE_VARIATION
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	armor = list("melee" = 30, "bullet" = 10, "laser" = 10, "energy" = 15, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "stamina" = 30)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit
	var/morphine_cooldown = 0
	var/morphine_cooldown_duration = 500

/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_OCLOTHING)
		to_chat("Welcome to the H.E.V. mark IV protective system, for use in hazardous environment conditions.")
		user.client << 'aquila/sound/items/hardsuit/hev_logon.ogg'
	return

/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(world.time > morphine_cooldown)
		if(owner.health < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 10)
			to_chat(owner, "<span class='warning'>You feel a tiny prick!</span>")
			say("Adrenaline administered.")
			playsound(src, 'aquila/sound/items/hardsuit/hev_morphine.ogg', 50, 0)
			morphine_cooldown = world.time + morphine_cooldown_duration
	. = ..()

/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100) //skopiowane od rd hardsuita od nich, nie wiem po co to -sandmann

/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.civilian_hardsuit_allowed

// Kapitan Bomba!!!!!!!

/obj/item/clothing/head/helmet/space/kapitanbomba
	name = "Kosmo-hełm"
	icon = 'aquila/icons/mob/head.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	icon_state = "kpt_kask"
	worn_icon_state = "kpt_kask"
	desc = "Kosmiczny Hełm Kapitana Kosmicznego Statku Orzeł 1."
	item_state = "kpt_kask"
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 40, "bomb" = 30, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/suit/kapitanbomba
	name = "Kosmo-kombinezon"
	desc = "Kosmiczny kombinezon Kapitana Kosmicznego Statku Orzeł 1"
	icon_state = "kpt_kurtka"
	item_state = "kpt_kurtka"
	worn_icon_state = "kpt_kurtka"
	worn_icon = 'aquila/icons/mob/suit.dmi'
	icon = 'aquila/icons/mob/suit.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE | THICKMATERIAL | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/ammo_box/magazine, /obj/item/gun)
	slowdown = 0.1 // Malutko bo to Kapitan bomba jest tępe chuje
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40,"energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)
	resistance_flags = FIRE_PROOF | ACID_PROOF
