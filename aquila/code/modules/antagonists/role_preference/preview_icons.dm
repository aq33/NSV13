// Port BeeStation #8776: ikony ról w oknie antagonistów jako postać w stroju roli (jak u Bee).
// Role bez stroju (potwory, blob, ksenomorf...) mają ikonę z get_preview_source() w preferences_menu/middleware.dm.

/// Strój podglądowy dla roli, null gdy rola nie jest człowiekiem
/datum/role_preference/proc/get_preview_outfit()
	// Podtypy przed rodzicami: wygrywa pierwsze dopasowanie
	var/static/list/outfits = list(
		/datum/antagonist/traitor/internal_affairs = /datum/outfit/aquila_preview/internal_affairs,
		/datum/antagonist/traitor/excommunicate = /datum/outfit/aquila_preview/excommunicate,
		/datum/antagonist/traitor/boarder = /datum/outfit/syndicate/no_crystals/syndi_crew/marine,
		/datum/antagonist/traitor = /datum/outfit/aquila_preview/traitor,
		/datum/antagonist/nukeop/syndi_crew = /datum/outfit/syndicate/no_crystals/syndi_crew/marine,
		/datum/antagonist/nukeop = /datum/outfit/syndicate,
		/datum/antagonist/changeling = /datum/outfit/aquila_preview/changeling,
		/datum/antagonist/cult = /datum/outfit/aquila_preview/blood_cult,
		/datum/antagonist/servant_of_ratvar = /datum/outfit/clockcult,
		/datum/antagonist/rev = /datum/outfit/aquila_preview/revolutionary,
		/datum/antagonist/heretic = /datum/outfit/heretic,
		/datum/antagonist/wizard = /datum/outfit/wizard,
		/datum/antagonist/ninja = /datum/outfit/ninja_preview,
		/datum/antagonist/pirate = /datum/outfit/pirate/space,
		/datum/antagonist/infiltrator = /datum/outfit/aquila_preview/infiltrator,
		/datum/antagonist/chrono_legionnaire = /datum/outfit/chrono_legionnaire,
		/datum/antagonist/fugitive_hunter = /datum/outfit/bountyarmor,
		/datum/antagonist/vampire = /datum/outfit/aquila_preview/vampire,
		/datum/antagonist/brother = /datum/outfit/aquila_preview/brother,
	)
	for(var/antag_type in outfits)
		if(ispath(antag_datum, antag_type))
			return outfits[antag_type]
	return null

/// Postać w stroju roli, przycięta do głowy i tułowia jak w Bee
/datum/role_preference/proc/get_outfit_preview_icon()
	var/outfit = get_preview_outfit()
	if(!outfit)
		return null
	var/mob/living/carbon/human/dummy/dummy = new
	dummy.equipOutfit(outfit, TRUE)
	COMPILE_OVERLAYS(dummy)
	var/icon/preview = getFlatIcon(dummy)
	qdel(dummy)
	preview.Scale(115, 115)
	preview.Shift(WEST, 8)
	preview.Shift(SOUTH, 30)
	preview.Crop(1, 1, 96, 96)
	return preview

// Stroje tylko do podglądu (nie do gry)

/datum/outfit/aquila_preview
	name = "Preview (Aquila)"

/datum/outfit/aquila_preview/traitor
	uniform = /obj/item/clothing/under/syndicate
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/transforming/energy/sword/saber/red
	r_hand = /obj/item/gun/energy/kinetic_accelerator/crossbow

/datum/outfit/aquila_preview/internal_affairs
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/black
	shoes = /obj/item/clothing/shoes/laceup
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/storage/briefcase

/datum/outfit/aquila_preview/excommunicate
	uniform = /obj/item/clothing/under/syndicate
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/balaclava
	r_hand = /obj/item/card/emag

/datum/outfit/aquila_preview/changeling
	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/toggle/labcoat
	r_hand = /obj/item/melee/arm_blade

/datum/outfit/aquila_preview/blood_cult
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/cultrobes
	head = /obj/item/clothing/head/culthood
	r_hand = /obj/item/melee/cultblade

/datum/outfit/aquila_preview/revolutionary
	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/ushanka
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/spear
	r_hand = /obj/item/assembly/flash

/datum/outfit/aquila_preview/vampire
	uniform = /obj/item/clothing/under/suit/black
	suit = /obj/item/clothing/suit/draculacoat

/datum/outfit/aquila_preview/brother
	uniform = /obj/item/clothing/under/color/grey
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas
	r_hand = /obj/item/assembly/flash

/// Gotowy strój infiltratora wszczepia implant także przy samym podglądzie
/datum/outfit/aquila_preview/infiltrator
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/black
	head = /obj/item/clothing/head/helmet/space/syndicate/black
	mask = /obj/item/clothing/mask/gas/syndicate
	r_hand = /obj/item/gun/ballistic/automatic/pistol
