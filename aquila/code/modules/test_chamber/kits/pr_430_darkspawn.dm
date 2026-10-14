// Zestawy do sprawdzenia darkspawna (aq33/AquilaStation#430). Usunąć razem z #include po przetestowaniu.

/datum/test_chamber_kit/pr_430
	name = "Darkspawn: ofiary i sprzęt załogi"
	pr = "aq33/AquilaStation#430"
	description = "Trzy osoby z umysłem do Pożarcia woli i zamiany w thralle, a do tego sprzęt załogi: latarki, flary, granaty hukowe, \
		laser, kajdanki, wymiana żarówek i implanter ochrony umysłu. Sprawdź, czy światło parzy darkspawna, \
		czy flary i latarki go odpychają, a ochrona umysłu uwalnia thralla."
	items = list(
		/mob/living/carbon/human = 3,
		/obj/item/flashlight/seclite = 2,
		/obj/item/flashlight/flare = 3,
		/obj/item/grenade/flashbang = 2,
		/obj/item/gun/energy/laser = 1,
		/obj/item/restraints/handcuffs = 2,
		/obj/item/lightreplacer = 1,
		/obj/item/implanter/mindshield = 2,
	)

/datum/test_chamber_kit/pr_430/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Pożarcie woli i thralle działają tylko na kimś z umysłem
	for(var/mob/living/carbon/human/H in spawned)
		H.mind_initialize()

/datum/test_chamber_kit/pr_430_self
	name = "Darkspawn: zrób ze mnie darkspawna"
	pr = "aq33/AquilaStation#430"
	description = "Dostajesz rolę darkspawna z 30 woli, miejscem na 3 thralle i Sakramentem dostępnym po 1 pożarciu. \
		Światła w komorze gasną, żeby dało się zrzucić skórę (Objawienie). Najpierw wybierz klasę w oknie antagonisty, \
		potem zrzuć skórę i kupuj w Psi Web. Zestaw z ofiarami zrzuć osobno. \
		Rola zostaje po resecie komory, zdejmij ją w Traitor Panelu. Sakrament kończy rundę."

/datum/test_chamber_kit/pr_430_self/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user?.mind || !ishuman(user))
		to_chat(user, "<span class='warning'>Ten zestaw działa tylko na ludzkim ciele z umysłem.</span>")
		return
	var/datum/antagonist/darkspawn/antag = user.mind.has_antag_datum(/datum/antagonist/darkspawn)
	if(!antag)
		antag = user.mind.add_antag_datum(/datum/antagonist/darkspawn)
	antag.willpower = 30
	antag.team.max_thralls = 3
	antag.team.required_succs = 1
	antag.team.update_objectives()
	// Ciemność do Objawienia; reset komory odtwarza lampy z szablonu
	var/datum/test_chamber/chamber = GLOB.test_chamber
	for(var/turf/T as anything in chamber?.reservation?.reserved_turfs)
		for(var/obj/machinery/light/light in T)
			light.break_light_tube(TRUE)
