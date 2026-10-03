// AQUILA - strój Kapitana Bomby (aq33/NSV13#304). Sam antagonista nie jest portowany; strój jest do wyboru przez adminów.
/datum/outfit/kapitanbomba
	name = "Kapitan Bomba"

	l_hand = /obj/item/gun/ballistic/automatic/l6_saw/blaster
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/kapitanbomba
	shoes = /obj/item/clothing/shoes/aquila/kapitanbomba
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	id = /obj/item/card/id/ert
	head = /obj/item/clothing/head/helmet/space/kapitanbomba
	belt = /obj/item/modular_computer/tablet/pda

/datum/outfit/kapitanbomba/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	var/obj/item/implant/weapons_auth/W = new(H)
	var/obj/item/implant/storage/S = new(H) //Każdy wie że kapitan bomba amunicje w dupie trzyma
	W.implant(H)
	S.implant(H)
	H.fully_replace_character_name(H.real_name, "Tytus Bomba")

	var/obj/item/card/id/card = H.wear_id
	if(istype(card))
		card.registered_name = H.real_name
		card.assignment = "Kapitan Bomba"
		card.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_CAPTAIN)
		card.update_label()

	var/obj/item/modular_computer/tablet/pda/PDA = H.get_item_by_slot(ITEM_SLOT_BELT)
	if(istype(PDA) && istype(card))
		PDA.saved_identification = card.registered_name
		PDA.saved_job = card.assignment
		PDA.update_id_display()
