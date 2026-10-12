/*****************************\
|********** MEDICAL **********|
\*****************************/
/datum/techweb_node/experimental_cloning
	id = "experimental_cloning"
	display_name = "Experimental Cloning"
	description = "Atak klonów."
	prereq_ids = list("adv_surgery")
	design_ids = list("clonecontrol_prototype", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/autodoc
	id = "autodoc"
	display_name = "Autodoc"
	description = "Maszyna, która potrafi automatycznie przeprowadzać operacje i inne procedury medyczne."
	prereq_ids = list("exp_surgery")
	design_ids = list("autodoc")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 3000

/*****************************\
|*********** NANITE **********|
\*****************************/
/datum/techweb_node/experimental_cloning
	id = "experimental_cloning"
	display_name = "Experimental Cloning"
	description = "Atak klonów."
	prereq_ids = list("adv_surgery")
	design_ids = list("clonecontrol_prototype", "clonepod_experimental")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/nanite_smart
	id = "nanite_smart"
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Programy nanitów, które wymagają od nanitów wykonywania złożonych działań, samodzielnego działania, wędrowania lub szukania celów."
	prereq_ids = list("nanite_base","robotics")
	design_ids = list("metabolic_nanites", "stealth_nanites", "memleak_nanites", "sensor_voice_nanites", "sensor_impact_nanites", "voice_nanites", "cloud_change_nanites", "nanolink_nanites") // AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 4000

/datum/techweb_node/nanite_bio
	id = "nanite_bio"
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Programy nanitów wymagające złożonej interakcji biologicznej."
	prereq_ids = list("nanite_base","biotech")
	design_ids = list("regenerative_nanites", "bloodheal_nanites", "coagulating_nanites", "poison_nanites", "flesheating_nanites",\
					"sensor_crit_nanites", "sensor_death_nanites", "sensor_health_nanites", "sensor_damage_nanites", "sensor_species_nanites", "nutrition_nanites") // AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Programy nanitów działające na nerwy i tkankę mózgową."
	prereq_ids = list("nanite_bio")
	design_ids = list("nervous_nanites", "brainheal_nanites", "paralyzing_nanites", "stun_nanites", "selfscan_nanites", "good_mood_nanites", "bad_mood_nanites", "movement_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Programy nanitów działające na umysł i myśli."
	prereq_ids = list("nanite_neural","neural_programming")
	design_ids = list("mindshield_nanites", "pacifying_nanites", "blinding_nanites", "sleep_nanites", "mute_nanites", "speech_nanites", "hallucination_nanites", "nanojutsu_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Programy nanitów wymagające płynnej integracji nanitów z biologią."
	prereq_ids = list("nanite_bio","nanite_smart","nanite_mesh")
	design_ids = list("fakedeath_nanites", "aggressive_nanites", "defib_nanites", "regenerative_plus_nanites", "brainheal_plus_nanites", "purging_plus_nanites", "adrenaline_nanites", "camo_nanites") //AQUILA EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000, TECHWEB_POINT_TYPE_NANITES = 2000)
	export_price = 8000

/datum/techweb_node/nanite_illegal
	id = "nanite_illegal"
	tech_tier = 5
	display_name = "Illegal Nanite Programming"
	description = "Niezwykle niebezpieczne programy nanitów zdolne do masowego zniszczenia."
	prereq_ids = list("nanite_harmonic", "syndicate_basic")
	design_ids = list("explosive_nanites", "pyro_nanites", "meltdown_nanites", "viral_nanites", "nanite_sting_nanites", "kunai_nanites", "nanoswarm_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)
	export_price = 12500

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	tech_tier = 5
	display_name = "Hazardous Nanite Programming"
	description = "Niezwykle zaawansowane programy nanitów, które mogą być skrajnie niebezpieczne."
	prereq_ids = list("nanite_harmonic", "alientech")
	design_ids = list("spreading_nanites", "mindcontrol_nanites", "mitosis_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000

/datum/techweb_node/nanite_replication_protocols
	id = "nanite_replication_protocols"
	tech_tier = 5
	display_name = "Nanite Replication Protocols"
	description = "Zaawansowane zachowania pozwalające nanitom wykorzystywać pewne okoliczności do szybszej replikacji."
	prereq_ids = list("nanite_harmonic")
	design_ids = list("kickstart_nanites", "factory_nanites", "tinker_nanites", "offline_nanites", "free_range_nanites", "zip_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000

/*******************************\
|*********** MACHINES **********|
\*******************************/
/datum/techweb_node/bluespace_mining
	id = "bluespace_mining"
	hidden = TRUE
	display_name = "Bluespace Mining Technology"
	description = "Wykorzystaj moc bluespace, by tworzyć materiały z niczego. Powoli."
	prereq_ids = list("practical_bluespace", "adv_mining")
	design_ids = list("bluespace_miner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bluespace_mining/New() //Techweb nodes don't have an init,
	. = ..()

	hidden = !CONFIG_GET(flag/bsminer_researchable)
/*******************************\
|*********** WEAPONS  **********|
\*******************************/
//najtańsze, słabe i kosztowne
/datum/techweb_node/prototype_beam_weapons
	id = "prototype_beam_weapons"
	tech_tier = 2
	display_name = "Prototype Beam Weapons"
	description = "Pierwsza generacja broni energetycznej; używa specjalnych soczewek do skupiania światła i zamieniania go w wysokoenergetyczną platformę bojową, droga i nieefektywna energetycznie."
	prereq_ids = list("engineering")
	design_ids = list("firstgenegun", "firstgenlasergun")
//średnia półka
/datum/techweb_node/improved_beam_weapons
	id = "improved_beam_weapons"
	tech_tier = 3
	display_name = "Advanced Energy weapons"
	description = "Ulepszona broń wiązkowa, wykorzystująca standaryzowane stopy i lepsze zużycie energii."
	prereq_ids = list("prototype_beam_weapons", "weaponry", "electronic_weapons")
	design_ids = list("lasergun", "energy_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
//powrót armatki laserowej
/datum/techweb_node/powerful_beam_weapons
	id = "powerful_beam_weapons"
	tech_tier = 4
	display_name = "Heavy Laser Weapons"
	description = "Wystawianie stopów na próbę dzięki ulepszonej entropii energii"
	prereq_ids = list("improved_beam_weapons", "adv_engi", "adv_weaponry")
	design_ids = list("lasercannon")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	export_price = 9000
//taktyczny karabinek energetyczny
/datum/techweb_node/tactical_beam_weapons
	id = "tactical_beam_weapons"
	tech_tier = 4
	display_name = "Tactical Energy Weapons"
	description = "Taktyczne zastosowanie broni wiązkowej."
	prereq_ids = list("improved_beam_weapons", "adv_engi", "adv_weaponry")
	design_ids = list("tacticalegun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000
//bydle broni energetycznych
/datum/techweb_node/destructive_beam_weapons
	id = "destructive_beam_weapons"
	tech_tier = 5
	display_name = "High-frequency multilayered beam weapons"
	description = "This is the closest we can get in making handheld particle lance, able to destroy even thickest of alloyed armors with extreme, high-frequency pulses."
	prereq_ids = list("tactical_beam_weapons", "powerful_beam_weapons", "adv_weaponry", "explosive_weapons", "bluespace_power", "adv_beam_weapons") //gratulacje jak uda się to wynaleźć i runda dalej trwa
	design_ids = list("pulsegun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 100 //jajko wielkanocne bo defacto Centrala i ich mało znani specjalisci od spraw wewnętrznych mają to

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	tech_tier = 4
	display_name = "Electric Weapons"
	description = "Broń wykorzystująca technologię elektryczną"
	prereq_ids = list("weaponry", "adv_power"  , "emp_basic")
	design_ids = list("stunrevolver", "stunshell", "ioncarbine", "disabler") //NSV13 - readded stunshell //AQ - added disabler
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyborg_upg_borgi
	id = "cyborg_upg_borgi"
	display_name = "Cyborg Upgrades: Borgi"
	description = "Hau hau szczek!"
	prereq_ids = list("adv_robotics")
	design_ids = list("borg_transform_borgi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 1500

/datum/techweb_node/syndicate_basic/New()		//Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	boost_item_paths = list()
	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/UI = new path
		if(!UI.item || !UI.illegal_tech)
			continue
		boost_item_paths |= UI.item	//allows deconning to unlock.

/*****************************\
|********* BLUESPACE *********|
\*****************************/
/datum/techweb_node/bluespace_travel/New() // bluespace pipes, appended so upstream changes to this node's designs still apply
	. = ..()
	design_ids += "bluespace_pipe"
