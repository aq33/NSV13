/datum/orbital_objective/assassination
	name = "Assassination"
	var/generated = FALSE
	var/mob/mob_to_kill
	var/suit_type = /obj/item/clothing/suit/space/hardsuit/ancient
	var/tank_type = /obj/item/tank/internals/oxygen
	var/mask_type = /obj/item/clothing/mask/gas
	var/belt_type = /obj/item/storage/belt/utility/full
	min_payout = 10000
	max_payout = 30000

/datum/orbital_objective/assassination/get_text()
	return "Zlokalizowaliśmy wrogiego agenta, który utknął na [station_name]. Musicie wysłać zespół i wyeliminować cel. Nasz wywiad sugeruje, że cel będzie uzbrojony i niebezpieczny, dlatego w tej misji zalecany jest zespół ochrony. Pamiętajcie, że zatwierdzony przez Nanotrasen ręczny laser eksploracyjny nie radzi sobie z celami ludzkimi."

//If nobody takes up the ghost role, then we dont care if they died.
//I know, its a bit sad.
/datum/orbital_objective/assassination/check_failed()
	if(generated)
		//Deleted
		if(QDELETED(mob_to_kill))
			complete_objective()
			return FALSE
		//Left behind
		if(mob_to_kill in SSzclear.nullspaced_mobs)
			complete_objective()
			return FALSE
		//Recovered and alive
		if(mob_to_kill.stat == DEAD)
			complete_objective()
			return FALSE
	return FALSE

/datum/orbital_objective/assassination/generate_objective_stuff(turf/chosen_turf)
	var/mob/living/carbon/human/created_human = new(chosen_turf)
	//Maybe polling ghosts would be better than the shintience code
	created_human.set_playable(ROLE_SURVIVALIST)
	created_human.mind_initialize()
	//Remove nearby dangers
	for(var/mob/living/simple_animal/hostile/SA in range(10, created_human))
		qdel(SA)
	switch(pickweight(list("secretagentman" = 1, "dictator" = 1, "operative" = 1, "greytide" = 3, "funnyman" = 2)))
		if("secretagentman")
			created_human.flavor_text = "W imieniu swoich Dobroczyńców wiedziesz niebezpieczne życie – dla każdego, kogo spotkasz, pozostajesz obcym. Ale ruszałeś się za dużo, ryzykowałeś za często – skoro Nanotrasen cię namierzył, pewnie nie dożyjesz jutra."
			created_human.equipOutfit(/datum/outfit/vip_target/super_spy)
		if("dictator")
			created_human.flavor_text = "Minęły miesiące od upadku twojego reżimu. Niegdyś bohater, teraz jesteś tylko kimś, kto ma nadzieję zobaczyć kolejny wschód słońca. Wiesz, że te świnie z Nanotrasen cię ścigają i nie cofną się przed niczym, by cię schwytać. Chcesz już tylko uciec i przeżyć, ale najpewniej nigdy się stąd nie wydostaniesz, nie dając się schwytać, albo gorzej..."
			created_human.equipOutfit(/datum/outfit/vip_target/vip_dictator)
		if("greytide")
			created_human.flavor_text = "Jesteś tylko asystentem na samotnej, opuszczonej stacji. Marzysz o powrocie do domu, ale rozwaliłeś niewłaściwą śluzę – teraz twój były pracodawca, Nanotrasen, cię ściga..."
			created_human.equipOutfit(/datum/outfit/vip_target/greytide)
		if("operative")
			created_human.flavor_text = "Jesteś agentem Syndykatu zatrudnionym przez Cybersun Industries, obecnie przeszukującym wraki opuszczonych placówek Nanotrasen w poszukiwaniu cennych zasobów. Jednak po wysadzeniu cię na zmianę prom, który cię przywiózł, został zestrzelony przez siły Nanotrasen. Wiesz, że to tylko kwestia czasu, zanim cię znajdą..."
			created_human.equipOutfit(/datum/outfit/vip_target/vip_operative)
			suit_type = /obj/item/clothing/head/helmet/space/hardsuit/cybersun //On par with the explorer suit, nothing too wacky.
			mask_type = /obj/item/clothing/mask/gas/syndicate
		if("funnyman")
			created_human.flavor_text = "Poślizg, poślizg, poślizg! Twoje PDA przyniosło tej załodze wiele śmiechu, ale teraz, gdy jej – i jego – już nie ma, w twojej głowie odbijają się echem groźby szefa ochrony..."
			created_human.equipOutfit(/datum/outfit/vip_target/clown)
	created_human.mind.store_memory("[created_human.flavor_text] – Ktoś chce cię zabić... Przeżyj.")
	created_human.mind.add_antag_datum(/datum/antagonist/survivalist)
	mob_to_kill = created_human
	//Give them space-worthy suit and other equipment
	var/turf/open/T = locate() in shuffle(view(1, created_human))
	if(T)
		new suit_type(T)
		new tank_type(T)
		new mask_type(T)
		new belt_type(T)
	generated = TRUE

//=====================
// Operative
//=====================

/datum/outfit/vip_target/vip_operative
	name = "Operative (VIP Target)"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/bulletproof
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/storage/belt/military
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/grenade/smokebomb
	id = /obj/item/card/id/syndicate_command

//=====================
// Martyr Dictator
//=====================

/datum/outfit/vip_target/vip_dictator
	name = "Dictator (VIP Target)"

	uniform = /obj/item/clothing/under/rank/security/head_of_security/white
	suit = /obj/item/clothing/suit/armor/hos
	suit_store = /obj/item/gun/ballistic/automatic/pistol/m1911
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	belt = /obj/item/storage/belt/sabre
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/grenade/smokebomb
	id = /obj/item/card/id/away/old
	neck = /obj/item/clothing/neck/crucifix
	head = /obj/item/clothing/head/HoS/beret/syndicate

//=====================
// Super Spy
//=====================

/datum/outfit/vip_target/super_spy
	name = "Super Spy (VIP Target)"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	gloves = /obj/item/clothing/gloves/chameleon
	ears = /obj/item/radio/headset/chameleon
	glasses = /obj/item/clothing/glasses/chameleon
	belt = /obj/item/storage/belt/chameleon
	l_pocket = /obj/item/stamp/chameleon
	r_pocket = /obj/item/modular_computer/tablet/pda/chameleon
	id = /obj/item/card/id/syndicate/anyone
	neck = /obj/item/clothing/neck/chameleon
	head = /obj/item/clothing/head/chameleon
	back = /obj/item/storage/backpack/chameleon

//=====================
// Clown
//=====================

/datum/outfit/vip_target/clown
	name = "Clown (VIP Target)"

	id = /obj/item/card/id/job/clown
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/vip_target/clown/post_equip(mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names))
	H.dna.add_mutation(CLOWNMUT)
