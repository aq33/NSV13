/datum/bounty/item/alien_organs
	name = "Alien Organs"
	description = "Nanotrasen chce badać biologię ksenomorfów. Wyślijcie zestaw narządów, a otrzymacie sowitą rekompensatę."
	reward = 25000
	required_count = 3
	wanted_types = list(/obj/item/organ/brain/alien, /obj/item/organ/alien, /obj/item/organ/body_egg/alien_embryo, /obj/item/organ/liver/alien, /obj/item/organ/tongue/alien, /obj/item/organ/eyes/night_vision/alien)

/datum/bounty/item/syndicate_documents
	name = "Syndicate Documents"
	description = "Informacje wywiadowcze o Syndykacie są w Centrali wysoko cenione. Jeśli znajdziecie dokumenty Syndykatu, wyślijcie je. Możecie ocalić życia."
	reward = 15000
	wanted_types = list(/obj/item/documents/syndicate, /obj/item/documents/photocopy)

/datum/bounty/item/syndicate_documents/applies_to(obj/O)
	if(!..())
		return FALSE
	if(istype(O, /obj/item/documents/photocopy))
		var/obj/item/documents/photocopy/Copy = O
		return (Copy.copy_type && ispath(Copy.copy_type, /obj/item/documents/syndicate))
	return TRUE

/datum/bounty/item/adamantine
	name = "Adamantine"
	description = "Dział materiałów anomalnych Nanotrasen desperacko potrzebuje adamantu. Wyślijcie im dużą przesyłkę, a opłaci się wam to."
	reward = 35000
	required_count = 10
	wanted_types = list(/obj/item/stack/sheet/mineral/adamantine)

/datum/bounty/item/trash
	name = "Trash"
	description = "Grupie woźnych skończyły się niedawno śmieci do sprzątania, a bez śmieci Centrala chce ich zwolnić, by obciąć koszty. Wyślijcie przesyłkę śmieci, by utrzymali pracę, a dadzą wam niewielką rekompensatę."
	reward = 1000
	required_count = 10
	wanted_types = list(/obj/item/trash)

/datum/bounty/more_bounties
	name = "More Bounties"
	description = "Wykonajcie dość zleceń, a Centrala wystawi nowe!"
	reward = 5 // number of bounties
	var/required_bounties = 5

/datum/bounty/more_bounties/can_claim()
	return ..() && completed_bounty_count() >= required_bounties

/datum/bounty/more_bounties/completion_string()
	return "[min(required_bounties, completed_bounty_count())]/[required_bounties] Bounties"

/datum/bounty/more_bounties/reward_string()
	return "Do [reward] nowych zleceń"

/datum/bounty/more_bounties/claim()
	if(can_claim())
		claimed = TRUE
		for(var/i = 0; i < reward; ++i)
			try_add_bounty(random_bounty())
