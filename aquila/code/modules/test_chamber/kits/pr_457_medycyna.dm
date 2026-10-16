/datum/test_chamber_kit/pr_457
	name = "Medycyna"
	pr = "aq33/AquilaStation#457"
	description = "Ranny człowiek ma złamaną nogę, przerwaną tętnicę w ręce i oparzenie III stopnia: zbadaj go analizatorem (okno), opatrz gazą, nićmi i siatką, zrób operacje nastawienia kości i usunięcia martwej tkanki. \
Świeży trup: defibrylator i powody odmowy, autopsja skanerem. Worek ze zwłokami: przeczytaj kartę i ożyw (duch przejmuje ciało). \
Kroplówka z wiązką, monitor funkcji życiowych (przykręć do ściany, multitool na stół), konsola akt medycznych (TGUI, przyczyna zgonu). \
Nóż, kij i laser na króliki doświadczalne: krwawienie, kolor krwi, rany. Przytomny pacjent krzyczy przy operacji."
	items = list(
		/obj/structure/table/optable = 1,
		/obj/machinery/stasis = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/autopsy_scanner = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/storage/firstaid/medical = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/mesh = 1,
		/obj/machinery/iv_drip = 1,
		/obj/item/reagent_containers/blood/OMinus = 2,
		/obj/item/wallframe/vitals/advanced = 1,
		/obj/item/multitool = 1,
		/obj/machinery/computer/med_data/laptop = 1,
		/obj/structure/closet/body_bag/lost_crew/with_body = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/melee/baseball_bat = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/lighter = 1,
	)

/datum/test_chamber_kit/pr_457/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Wounded patient with one wound of every kind
	var/mob/living/carbon/human/wounded = new(center)
	wounded.real_name = "Ranny pacjent"
	wounded.name = wounded.real_name
	var/datum/wound/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(wounded.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	var/datum/wound/artery = new /datum/wound/slash/artery()
	artery.apply_wound(wounded.get_bodypart(BODY_ZONE_R_ARM), silent = TRUE)
	var/datum/wound/burn = new /datum/wound/burn/third_degree()
	burn.apply_wound(wounded.get_bodypart(BODY_ZONE_CHEST), silent = TRUE)
	wounded.adjustBruteLoss(30)
	wounded.adjustFireLoss(20)

	// Fresh corpse for the defibrillator and the autopsy
	var/turf/corpse_turf = turfs[min(length(items) + 1, length(turfs))]
	var/mob/living/carbon/human/corpse = new(corpse_turf)
	corpse.real_name = "Świeży trup"
	corpse.name = corpse.real_name
	corpse.adjustBruteLoss(60)
	corpse.death()
