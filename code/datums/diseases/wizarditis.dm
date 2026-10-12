/datum/disease/wizarditis
	name = "Wizarditis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "The Manly Dorf"
	cures = list(/datum/reagent/consumable/ethanol/manly_dorf)
	cure_chance = 100
	agent = "Rincewindus Vulgaris"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	desc = "Niektórzy spekulują, że ten wirus jest przyczyną istnienia Kosmicznej Federacji Czarodziejów. Chorzy wykazują objawy niepełnosprawności intelektualnej, wykrzykując niezrozumiałe zdania lub zupełny bełkot. W późnych stadiach chorzy czasem wyrażają poczucie wewnętrznej mocy i, cytuję, „zdolność sterowania samymi siłami kosmosu!”. Łyk mocnego, męskiego trunku zwykle przywraca ich do normalnego, ludzkiego stanu."
	danger = DISEASE_HARMFUL
	required_organs = list(/obj/item/bodypart/head)

/*
BIRUZ BENNAR
SCYAR NILA - teleport
NEC CANTIO - dis techno
EI NATH - shocking grasp
AULIE OXIN FIERA - knock
TARCOL MINTI ZHERI - forcewall
STI KALY - blind
*/

/datum/disease/wizarditis/stage_act()
	..()

	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.say(pick("Nie przejdziesz!", "Expelliarmus!", "Na brodę Merlina!", "Poczuj moc Ciemnej Strony!"), forced = "wizarditis")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Czujesz, [pick("że brakuje ci many", "że wiatry magii zniknęły", "chęć przywołania chowańca")].</span>")


		if(3)
			if(prob(1))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"), forced = "wizarditis")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Czujesz [pick("bulgoczącą w żyłach magię","że to miejsce daje ci +1 do INT","chęć przywołania chowańca")].</span>")

		if(4)

			if(prob(1))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"), forced = "wizarditis")
				return
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Czujesz [pick("narastającą w tobie przypływową falę surowej mocy","że to miejsce daje ci +2 do INT i +1 do MDR","chęć teleportacji")].</span>")
				spawn_wizard_clothes(50)
			if(prob(1))
				wizarditis_teleport(affected_mob)
	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(chance = 0)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.dropItemToGround(H.head))
					qdel(H.head)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/fake(H), ITEM_SLOT_HEAD)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.dropItemToGround(H.wear_suit))
					qdel(H.wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/fake(H), ITEM_SLOT_OCLOTHING)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(!H.dropItemToGround(H.shoes))
					qdel(H.shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_FEET)
			return
