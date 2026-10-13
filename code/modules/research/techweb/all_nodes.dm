
//Current rate: 135000 research points in 90 minutes

//Base Nodes
/datum/techweb_node/base
	id = "base"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Podstawowe technologie badawcze"
	description = "Domyślne technologie badawcze NT."
	// Default research tech, prevents bricking
	//NSV13 Added 3 ids for NSV13 hull materials
	design_ids = list("basic_matter_bin", "basic_cell", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani", "dest_tagger", "handlabel", "larry", "package_wrap",
	"destructive_analyzer", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk", "rdserver", "rdservercontrol", "mechfab", "paystand",
	"space_heater", "beaker", "large_beaker", "bucket", "oven_tray", "xlarge_beaker", "sec_rshot", "sec_beanbag_slug", "sec_bshot", "sec_slug", "sec_Islug", "sec_Brslug", "sec_dart", "sec_38", "sec_38b",
	"rglass","plasteel","plastitanium","plasmaglass","plasmareinforcedglass","titaniumglass","plastitaniumglass","plumbing_rcd", "antivirus", "glasses_prescription", "light_replacer", "xenoa_labeler", "nanocarbon_glass", "durasteel", "duranium", "coffeemaker", "coffeepot", "coffee_cartridge", "syrup_bottle", "fax") //NSV13 - BLOOD FOR THE BLOOD GOD, COFFEE FOR THE NAVY!!

/datum/techweb_node/mmi
	id = "mmi"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Interfejs człowiek-maszyna"
	description = "Nieco frankensteinowskie urządzenie, które pozwala ludzkim mózgom natywnie łączyć się z interfejsami API oprogramowania."
	design_ids = list("mmi")

/datum/techweb_node/cyborg
	id = "cyborg"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Budowa cyborgów"
	description = "Rozumne roboty z wgranymi modułami narzędzi i programowalnymi prawami."
	design_ids = list("robocontrol", "sflash", "borg_suit", "borg_head", "borg_chest", "borg_r_arm", "borg_l_arm", "borg_r_leg", "borg_l_leg", "borgupload",
	"cyborgrecharger", "borg_upgrade_restart", "borg_upgrade_rename")

/datum/techweb_node/mech
	id = "mecha"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Egzoszkielety mechaniczne"
	description = "Zmechanizowane egzoszkielety, o kilka rzędów wielkości silniejsze i potężniejsze od przeciętnego człowieka."
	design_ids = list("mecha_tracking", "mechacontrol", "mechapower", "mech_recharger", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg",
	"ripley_main", "ripley_peri", "ripleyupgrade", "mech_hydraulic_clamp")

//Has NSV-related change
/datum/techweb_node/mech_tools
	id = "mech_tools"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Podstawowe wyposażenie egzoszkieletów"
	description = "Różne narzędzia odpowiednie dla podstawowych mechów"
	design_ids = list("mech_drill", "mech_mscanner", "mech_extinguisher", "mech_foam_extinguisher", "mech_smart_foam_launcher")

/datum/techweb_node/basic_tools
	id = "basic_tools"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Podstawowe narzędzia"
	description = "Podstawowe narzędzia mechaniczne, elektroniczne, chirurgiczne i botaniczne."
	design_ids = list("discovery_scanner", "screwdriver", "wrench", "wirecutters", "crowbar", "multitool", "welding_tool", "wirebrush", "tscanner", "analyzer", "cable_coil", "pipe_painter", "airlock_painter", "decal_painter", "tile_sprayer", "scalpel", "circular_saw", "surgicaldrill", "retractor", "cautery", "blood_filter", "hemostat", "surgical_drapes", "syringe", "cultivator", "plant_analyzer", "shovel", "spade", "hatchet",  "mop")

/datum/techweb_node/basic_circuitry
	id = "basic_circuitry"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Podstawowe układy scalone"
	description = "Badania nad pełnym wykorzystaniem mocy układów scalonych"
	design_ids = list("integrated_circuit", "circuit_multitool", "comp_arithmetic", "comp_clock", "comp_combiner", "comp_comparison", "comp_delay",
		"comp_direction", "comp_get_column", "comp_gps", "comp_health", "comp_hear", "comp_light", "comp_logic", "comp_index_table", "comp_mmi", "comp_multiplexer", "comp_not", "comp_ram",
		"comp_random", "comp_round", "comp_select_query", "comp_species", "comp_textcase", "comp_trig", "comp_speech", "comp_concat", "comp_concat_list", "comp_speech", "comp_self", "comp_soundemitter", "comp_radio", "comp_tostring",
		"comp_typecast", "compact_remote_shell", "component_printer", "comp_string_contains", "usb_cable")

/////////////////////////Biotech/////////////////////////
/datum/techweb_node/biotech
	id = "biotech"
	tech_tier = 1
	display_name = "Technologia biologiczna"
	description = "Co sprawia, że działamy."	//the MC, silly!
	prereq_ids = list("base")
	// NSV13 - added design for refillable chem dispenser
	design_ids = list("chem_heater", "chem_master", "chem_dispenser", "refillable_chem_dispenser", "pandemic", "sleeper", "defibrillator", "defibmount", "operating", "soda_dispenser", "beer_dispenser", "healthanalyzer", "medspray","genescanner", "medipen_epi", "medipen_dex", "medipen_atropine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	tech_tier = 2
	display_name = "Zaawansowana biotechnologia"
	description = "Zaawansowana biotechnologia"
	prereq_ids = list("biotech")
	design_ids = list("piercesyringe", "crewpinpointer", "smoke_machine", "plasmarefiller", "limbgrower", "meta_beaker", "healthanalyzer_advanced", "harvester", "holobarrier_med", "defibrillator_compact")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bio_process
	id = "bio_process"
	tech_tier = 1
	display_name = "Przetwarzanie biologiczne"
	description = "Od szlamów po kuchnie."
	prereq_ids = list("biotech")
	design_ids = list("smartfridge", "gibber", "deepfryer", "monkey_recycler", "processor", "gibber", "microwave", "reagentgrinder", "dish_drive", "fat_sucker", "griddle", "oven")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Advanced Surgery/////////////////////////
/datum/techweb_node/imp_wt_surgery
	id = "imp_wt_surgery"
	tech_tier = 2
	display_name = "Ulepszona chirurgia opatrywania ran"
	description = "Kto by pomyślał, że delikatniejsze obchodzenie się z hemostatem zmniejsza ból pacjenta?"
	prereq_ids = list("adv_biotech")
	design_ids = list("surgery_heal_brute_upgrade","surgery_heal_burn_upgrade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 1000


/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	tech_tier = 3
	display_name = "Zaawansowana chirurgia"
	description = "Gdy zwykła medycyna nie wystarcza."
	prereq_ids = list("imp_wt_surgery")
	design_ids = list("surgery_lobotomy","surgery_heal_brute_upgrade_femto","surgery_heal_burn_upgrade_femto","surgery_heal_combo","surgery_exp_dissection")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 4000

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	tech_tier = 4
	display_name = "Chirurgia eksperymentalna"
	description = "Gdy ewolucja jest zbyt wolna."
	prereq_ids = list("adv_surgery")
	design_ids = list("surgery_revival","surgery_pacify","surgery_vein_thread","surgery_muscled_veins","surgery_nerve_splice","surgery_nerve_ground","surgery_ligament_hook","surgery_ligament_reinforcement","surgery_viral_bond", "surgery_heal_combo_upgrade","surgery_cortex_imprint","surgery_cortex_folding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	tech_tier = 5
	display_name = "Chirurgia obcych"
	description = "Abduktorzy nie zrobili nic złego."
	prereq_ids = list("exp_surgery", "alientech")
	design_ids = list("surgery_brainwashing","surgery_zombie","surgery_heal_combo_upgrade_femto")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/////////////////////////data theory tech/////////////////////////
/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	tech_tier = 1
	display_name = "Teoria danych"
	description = "Big Data w kosmosie!"
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////engineering tech/////////////////////////
/datum/techweb_node/engineering
	id = "engineering"
	tech_tier = 1
	display_name = "Inżynieria przemysłowa"
	description = "Kurs odświeżający z nowoczesnej technologii inżynieryjnej."
	prereq_ids = list("base")
	design_ids = list("solarcontrol", "recharger", "powermonitor", "rped", "pacman", "adv_capacitor", "adv_scanning", "emitter", "high_cell", "adv_matter_bin", "scanner_gate",
	"atmosalerts", "atmos_control", "recycler", "autolathe", "high_micro_laser", "nano_mani", "mesons", "thermomachine", "rad_collector", "machine_igniter", "mass_driver", "tesla_coil", "grounding_rod",
	"apc_control", "cell_charger", "power control", "airlock_board", "firelock_board", "aac_electronics", "airalarm_electronics", "firealarm_electronics", "cell_charger", "stack_console", "stack_machine",
	"oxygen_tank", "plasma_tank", "emergency_oxygen", "emergency_oxygen_engi", "plasmaman_tank_belt", "plasmaman_tank", "antivirus2", "researchdisk_locator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	tech_tier = 2
	display_name = "Zaawansowana inżynieria"
	description = "Przesuwanie granic fizyki, jedna pięść-piła łańcuchowa naraz."
	prereq_ids = list("engineering", "emp_basic")
	design_ids = list("engine_goggles", "magboots", "forcefield_projector", "weldingmask", "rcd_loaded", "rpd_loaded", "ranged_analyzer", "multi_cell_charger") //NSV13 - kept atmos holofan
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/anomaly
	id = "anomaly_research"
	tech_tier = 4
	display_name = "Badania anomalii"
	description = "Uwolnij potencjał tajemniczych anomalii pojawiających się na stacji."
	prereq_ids = list("adv_engi", "practical_bluespace")
	design_ids = list("reactive_armour", "anomaly_neutralizer", "xenoa_list_console", "xenoa_list_pad", "xenoa_gloves")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	tech_tier = 3
	display_name = "Części o wysokiej wydajności"
	description = "Precyzyjne techniki produkcji pozwalające na dokładność co do pikometra."
	prereq_ids = list("engineering", "datatheory")
	design_ids = list("pico_mani", "super_matter_bin")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_power
	id = "adv_power"
	tech_tier = 3
	display_name = "Zaawansowana manipulacja energią"
	description = "Jak uzyskać więcej prądu."
	prereq_ids = list("engineering")
	design_ids = list("smes", "super_cell", "hyper_cell", "super_capacitor", "superpacman", "mrspacman", "power_turbine", "power_turbine_console", "power_compressor", "circulator", "export_battery", "teg") //AQ EDIT
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Bluespace tech/////////////////////////
/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	tech_tier = 4
	display_name = "Podstawy teorii bluespace"
	description = "Podstawowe badania nad tajemniczym alternatywnym wymiarem zwanym bluespace."
	prereq_ids = list("base")
	design_ids = list("beacon", "dragnetbeacon", "xenobioconsole", "telesci_gps", "bluespace_crystal")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	tech_tier = 5
	display_name = "Podróże przez bluespace"
	description = "Zastosowanie bluespace w technologii statycznej teleportacji."
	prereq_ids = list("practical_bluespace")
	design_ids = list("tele_station", "tele_hub", "teleconsole", "quantumpad", "launchpad", "launchpad_console", "bluespace_pod")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/micro_bluespace
	id = "micro_bluespace"
	tech_tier = 5
	display_name = "Badania nad miniaturyzacją bluespace"
	description = "Ogromne zmniejszenie miejsca potrzebnego dla silników bluespace, prowadzące do przenośnej technologii bluespace."
	prereq_ids = list("bluespace_travel", "practical_bluespace", "high_efficiency")
	design_ids = list("bluespace_matter_bin", "femto_mani", "triphasic_scanning", "quantum_keycard", "antivirus4")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/bag_of_holding
	id = "bagofholding"
	tech_tier = 5
	display_name = "Torba przechowywania"
	description = "Przenośna technologia bluespace pozwala produkować plecaki, które mieszczą więcej przedmiotów, niż wynosi objętość torby."
	prereq_ids = list("micro_bluespace")
	design_ids = list("bag_holding")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/wormhole_gun
	id = "wormholegun"
	tech_tier = 5
	display_name = "Projektor tuneli bluespace"
	description = "Przeprowadź badania potrzebne do stworzenia zminiaturyzowanego projektora tuneli bluespace, który pozwala natychmiast przeskakiwać między dwoma miejscami."
	prereq_ids = list("micro_bluespace")
	design_ids = list("wormholeprojector")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/quantum_spin
	id = "qswapper"
	tech_tier = 5
	display_name = "Kwantowy odwracacz spinu"
	description = "Zbadaj możliwość stworzenia eksperymentalnego urządzenia, które zamienia położenie dwóch istot, przełączając wartości spinu ich cząstek. Do działania musi być połączone z drugim urządzeniem."
	prereq_ids = list("micro_bluespace")
	design_ids = list("swapper")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	tech_tier = 4
	display_name = "Stosowane badania bluespace"
	description = "Wykorzystanie bluespace, by wszystko było szybsze i lepsze."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list("bs_rped","minerbag_holding", "bluespacebeaker", "bluespacesyringe", "bluespacebodybag", "phasic_scanning", "roastingstick", "ore_silo", "antivirus3", "bluespace_coffeepot") //NSV13 - added bluespace coffeepot
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	tech_tier = 4
	display_name = "Technologia zasilania bluespace"
	description = "Jeszcze potężniejsza... moc!"
	prereq_ids = list("adv_power", "practical_bluespace")
	design_ids = list("bluespace_cell", "quadratic_capacitor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/unregulated_bluespace
	id = "unregulated_bluespace"
	tech_tier = 5
	display_name = "Nieuregulowane badania bluespace"
	description = "Technologia bluespace oparta na niestabilnych lub niezrównoważonych procedurach, skłonna do uszkadzania tkanki bluespace. Zakazana przez konwencje galaktyczne."
	prereq_ids = list("bluespace_travel", "syndicate_basic")
	design_ids = list("desynchronizer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500


/////////////////////////plasma tech/////////////////////////
/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	tech_tier = 1
	display_name = "Podstawowe badania plazmy"
	description = "Badania nad tajemniczą i niebezpieczną substancją – plazmą."
	prereq_ids = list("engineering")
	design_ids = list("mech_generator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	tech_tier = 2
	display_name = "Zaawansowane badania plazmy"
	description = "Badania nad pełnym wykorzystaniem mocy plazmy."
	prereq_ids = list("basic_plasma")
	design_ids = list("mech_plasma_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////shuttle tech/////////////////////////
/datum/techweb_node/basic_shuttle_tech
	id = "basic_shuttle"
	tech_tier = 3
	display_name = "Podstawowe badania promów"
	description = "Zbadaj technologię potrzebną do budowy i używania podstawowych promów."
	prereq_ids = list("bluespace_travel", "adv_engi")
	design_ids = list("shuttle_creator", "engine_plasma", "engine_heater", "shuttle_control", "wingpack")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/nullspacebreaching
	id = "nullspacebreaching"
	display_name = "Przełamywanie nullspace"
	description = "Badania nad tunelowaniem przez pustkę, pozwalające znacznie skrócić czas lotu."
	prereq_ids = list("basic_shuttle", "alientech")
	design_ids = list("engine_void", "wingpack_ayy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)
	export_price = 5000

/datum/techweb_node/plasma_refiner
	id = "plasmarefiner"
	tech_tier = 4
	display_name = "Rafinacja plazmy"
	description = "Opracowanie maszyny zdolnej bezpiecznie i wydajnie przekształcać plazmę ze stanu stałego w gazowy."
	prereq_ids = list("basic_shuttle")
	design_ids = list("plasma_refiner")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = TRUE

/////////////////////////integrated circuits tech/////////////////////////

/datum/techweb_node/math_circuits
	id = "math_circuits"
	tech_tier = 1
	display_name = "Układy matematyczne"
	description = "Opracowanie bardziej złożonych komponentów matematycznych na wszelkie potrzeby manipulowania liczbami"
	prereq_ids = list("basic_circuitry", "datatheory")
	design_ids = list("comp_adv_trig","comp_hyper_trig", "comp_bitwise", "comp_bitflag")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/list_circuits
	id = "list_circuits"
	tech_tier = 1
	display_name = "Układy list"
	description = "Konfiguruje nowe komponenty układów scalonych zdolne do reprezentowania jednowymiarowych struktur danych, takich jak tablice, stosy i kolejki."
	prereq_ids = list("basic_circuitry", "datatheory")
	design_ids = list("comp_index", "comp_write", "comp_append", "comp_pop", "comp_length", "comp_list_constructor", "comp_list_length_constructor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/adv_shells
	id = "adv_shells"
	tech_tier = 2
	display_name = "Zaawansowane badania obudów"
	description = "Daje dostęp do bardziej skomplikowanych projektów obudów."
	prereq_ids = list("basic_circuitry", "engineering")
	design_ids = list("controller_shell", "scanner_shell", "bot_shell", "door_shell", "money_bot_shell", "assembly_shell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/movable_shells_tech
	id = "movable_shells"
	tech_tier = 2
	display_name = "Badania ruchomych obudów"
	description = "Daje dostęp do ruchomych obudów."
	prereq_ids = list("adv_shells", "robotics")
	design_ids = list("comp_pull", "drone_shell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/server_shell_tech
	id = "server_shell"
	tech_tier = 2
	display_name = "Badania technologii serwerowej"
	description = "Daje dostęp do obudowy serwerowej o bardzo dużej pojemności na komponenty."
	prereq_ids = list("adv_shells", "computer_hardware_basic")
	design_ids = list("server_shell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/////////////////////////robotics tech/////////////////////////
/datum/techweb_node/robotics
	id = "robotics"
	tech_tier = 2
	display_name = "Podstawowe badania robotyki"
	description = "Programowalne maszyny, które czynią nasze życie leniwszym."
	prereq_ids = list("base")
	design_ids = list("paicard","botnavbeacon") //NSV13 - Navbeacon Refactoring
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	tech_tier = 3
	display_name = "Zaawansowane badania robotyki"
	description = "Potrafi nawet zmywać naczynia!"
	prereq_ids = list("robotics")
	design_ids = list("borg_upgrade_diamonddrill", "borg_upgrade_trashofholding", "borg_upgrade_advancedmop", "borg_upgrade_clamp") //NSV13 - Cargo Borgs
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/neural_programming
	id = "neural_programming"
	tech_tier = 2
	display_name = "Programowanie neuronowe"
	description = "Badania nad sieciami jednostek przetwarzających, które naśladują nasze mózgi."
	prereq_ids = list("biotech", "datatheory")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Mózg pozytronowy"
	description = "Praktyczne zastosowanie technologii neuronowej, pozwalające tworzyć autonomiczne jednostki SI oparte na specjalnych metalowych kostkach z obwodami przewodzącymi i przetwarzającymi."
	prereq_ids = list("neural_programming")
	design_ids = list("mmi_posi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	tech_tier = 3
	display_name = "Ulepszenia cyborgów: użytkowe"
	description = "Ulepszenia użytkowe dla cyborgów."
	prereq_ids = list("engineering")
	design_ids = list("borg_upgrade_holding", "borg_upgrade_lavaproof", "borg_upgrade_thrusters", "borg_upgrade_selfrepair", "borg_upgrade_expand", "borg_upgrade_rped", "borg_upgrade_circuitapp")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_med
	id = "cyborg_upg_med"
	tech_tier = 3
	display_name = "Ulepszenia cyborgów: medyczne"
	description = "Ulepszenia medyczne dla cyborgów."
	prereq_ids = list("adv_biotech")
	design_ids = list("borg_upgrade_defibrillator", "borg_upgrade_piercinghypospray", "borg_upgrade_expandedsynthesiser", "borg_upgrade_pinpointer", "borg_upgrade_surgicalprocessor", "borg_upgrade_beakerapp")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_combat
	id = "cyborg_upg_combat"
	tech_tier = 3
	display_name = "Ulepszenia cyborgów: bojowe"
	description = "Ulepszenia wojskowej klasy dla cyborgów."
	prereq_ids = list("adv_robotics", "adv_engi" , "weaponry")
	design_ids = list("borg_upgrade_vtec")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_service
	id = "cyborg_upg_service"
	tech_tier = 3
	display_name = "Ulepszenia cyborgów: usługowe"
	description = "Pozwala borgom usługowym specjalizować się dzięki różnym modułom."
	prereq_ids = list("cyborg_upg_util")
	design_ids = list("borg_upgrade_casino", "borg_upgrade_kitchen", "borg_upgrade_botany", "borg_upgrade_party")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 1000

/datum/techweb_node/cyborg_upg_security
	id = "cyborg_upg_security"
	tech_tier = 4
	display_name = "Ulepszenia cyborgów: ochrona"
	description = "Ulepszenia klasy milicyjnej dla cyborgów."
	prereq_ids = list("adv_robotics", "adv_engi" , "weaponry")
	design_ids = list("borg_transform_security", "borg_upgrade_disablercooler")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_security/New() //Techweb nodes don't have an init,
	. = ..()
	hidden = CONFIG_GET(flag/disable_secborg)

/datum/techweb_node/ai
	id = "ai"
	tech_tier = 3
	display_name = "Sztuczna inteligencja"
	description = "Badania nad jednostkami SI."
	prereq_ids = list("robotics", "posibrain")
	design_ids = list("aifixer", "aicore", "safeguard_module", "onehuman_module", "protectstation_module", "quarantine_module", "oxygen_module", "freeform_module",
	"reset_module", "purge_module", "remove_module", "freeformcore_module", "asimov_module", "paladin_module", "tyrant_module", "overlord_module", "corporate_module",
	"dungeonmaster_module", "boomer_module", "zoomer_module", "science_module", "service_module", "weeb_module", "gamer_module", "lizardimov_module",
	"corgi_module", "cowboy_module", "dean_module", "default_module", "borg_ai_control", "mecha_tracking_ai_control", "aiupload", "intellicard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////EMP tech/////////////////////////
/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	tech_tier = 2
	display_name = "Teoria elektromagnetyczna"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list("holosign", "holosignsec", "holosignengi", "holosignatmos", "inducer", "inducersci", "tray_goggles", "holopad")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/emp_adv
	id = "emp_adv"
	tech_tier = 3
	display_name = "Zaawansowana teoria elektromagnetyczna"
	description = "Ustalanie, czy odwrócenie polaryzacji naprawdę pomoże w danej sytuacji."
	prereq_ids = list("emp_basic")
	design_ids = list("ultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/datum/techweb_node/emp_super
	id = "emp_super"
	tech_tier = 4
	display_name = "Kwantowa technologia elektromagnetyczna"	//bs
	description = "Jeszcze lepsza technologia elektromagnetyczna."
	prereq_ids = list("emp_adv")
	design_ids = list("quadultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/////////////////////////Clown tech/////////////////////////
/datum/techweb_node/clown
	id = "clown"
	tech_tier = 2
	display_name = "Technologia klaunów"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list("air_horn", "honker_main", "honker_peri", "honker_targ", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm",
	"honk_left_leg", "honk_right_leg", "mech_banana_mortar", "mech_mousetrap_mortar", "mech_honker", "mech_punching_face", "implant_trombone", "borg_transform_clown", "clown_mine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////Computer tech////////////////////////
/datum/techweb_node/comptech
	id = "comptech"
	tech_tier = 1
	display_name = "Konsole komputerowe"
	description = "Komputery i to, jak działają."
	prereq_ids = list("datatheory")
	design_ids = list("cargo", "cargorequest", "objective", "libraryconsole", "mining", "crewconsole", "rdcamera", "comconsole", "idcardconsole", "seccamera")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	tech_tier = 1
	display_name = "Sprzęt komputerowy"
	description = "Jak powstaje sprzęt komputerowy."
	prereq_ids = list("comptech")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)  //they are really shitty
	export_price = 2000
	design_ids = list("hdd_basic", "hdd_advanced", "hdd_super", "hdd_cluster", "ssd_small", "ssd_micro", "netcard_basic", "netcard_advanced", "netcard_wired",
	"portadrive_basic", "portadrive_advanced", "portadrive_super", "cardslot", "aislot", "miniprinter", "APClink", "bat_control", "bat_normal", "bat_advanced",
	"bat_super", "bat_micro", "bat_nano", "cpu_normal", "pcpu_normal", "cpu_small", "pcpu_small", "sensorpackage")

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	tech_tier = 1
	display_name = "Gry zręcznościowe"
	description = "Dla obiboków na stacji."
	prereq_ids = list("comptech")
	design_ids = list("arcade_battle", "arcade_orion", "slotmachine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	tech_tier = 2
	display_name = "Skomputeryzowana ewidencja"
	description = "Uporządkowane bazy danych z kartotekami i ich użycie."
	prereq_ids = list("comptech")
	design_ids = list("secdata", "med_data", "prisonmanage", "vendor", "automated_announcement")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/datum/techweb_node/telecomms
	id = "telecomms"
	tech_tier = 3
	display_name = "Technologia telekomunikacyjna"
	description = "Technologia transmisji podprzestrzennej dla urządzeń łączności niemal natychmiastowej."
	prereq_ids = list("comptech", "bluespace_basic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	design_ids = list("s-receiver", "s-bus", "s-broadcaster", "s-processor", "s-hub", "s-server", "s-relay", "comm_monitor", "comm_server",
	"s-ansible", "s-filter", "s-amplifier", "ntnet_relay", "s-treatment", "s-analyzer", "s-crystal", "s-transmitter", "s-messaging")

/datum/techweb_node/integrated_HUDs
	id = "integrated_HUDs"
	tech_tier = 3
	display_name = "Zintegrowane HUD-y"
	description = "Użyteczność skomputeryzowanych kartotek, wyświetlanych prosto na okular!"
	prereq_ids = list("comp_recordkeeping", "emp_basic")
	design_ids = list("health_hud", "security_hud", "diagnostic_hud", "scigoggles")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	tech_tier = 3
	display_name = "Technologia noktowizji"
	description = "Pozwala widzieć w ciemności bez prawdziwego światła!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list("health_hud_night", "security_hud_night", "diagnostic_hud_night", "night_visision_goggles", "nvgmesons")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	tech_tier = 3
	display_name = "Inżynieria genetyczna"
	description = "Mamy technologię, by go stworzyć."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "scan_console", "cloning_disk")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cryotech
	id = "cryotech"
	tech_tier = 3
	display_name = "Technologia kriostazy"
	description = "Inteligentne zamrażanie przedmiotów, by je zakonserwować!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("splitbeaker", "noreactsyringe", "cryotube", "cryo_Grenade", "stasis")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 4000

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	tech_tier = 4
	display_name = "Implanty podskórne"
	description = "Elektroniczne implanty umieszczane pod skórą."
	prereq_ids = list("biotech")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_security_down", "implant_tracking", "locator", "c38_trac") // AQ EDIT: implant_security_down
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	tech_tier = 4
	display_name = "Organy cybernetyczne"
	description = "Mamy technologię, by go odbudować."
	prereq_ids = list("adv_biotech")
	design_ids = list("cybernetic_heart", "cybernetic_liver", "cybernetic_lungs", "cybernetic_stomach")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	tech_tier = 5
	display_name = "Ulepszone organy cybernetyczne"
	description = "Mamy technologię, by go ulepszyć."
	prereq_ids = list("cyber_organs")
	design_ids = list("cybernetic_heart_u", "cybernetic_liver_u", "cybernetic_lungs_u", "cybernetic_stomach_u")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/ipc_organs
	id = "ipc_organs"
	tech_tier = 3
	display_name = "Części IPC"
	description = "Mamy technologię, by go zastąpić."
	prereq_ids = list("cyber_organs","robotics")
	design_ids = list("robotic_liver", "robotic_eyes", "robotic_tongue", "robotic_stomach", "robotic_ears", "power_cord")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	tech_tier = 4
	display_name = "Implanty cybernetyczne"
	description = "Elektroniczne implanty ulepszające ludzi."
	prereq_ids = list("adv_biotech", "datatheory")
	design_ids = list("ci-nutriment", "ci-breather", "ci-gloweyes", "ci-welding", "ci-medhud", "ci-sechud", "ci-diaghud")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	tech_tier = 5
	display_name = "Zaawansowane implanty cybernetyczne"
	description = "Ulepszone i potężniejsze implanty cybernetyczne."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list("ci-toolset", "ci-surgery","ci-janitor", "ci-botany", "ci-reviver", "ci-nutrimentplus")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	tech_tier = 5
	display_name = "Bojowe implanty cybernetyczne"
	description = "Wojskowe implanty bojowe poprawiające sprawność."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list("ci-xray", "ci-thermals", "ci-antidrop", "ci-antistun", "ci-thrusters")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/adv_combat_cyber_implants
	id = "adv_combat_cyber_implants"
	tech_tier = 5
	display_name = "Zaawansowane bojowe implanty cybernetyczne"
	description = "Eksperymentalna wojskowa broń cybernetyczna."
	prereq_ids = list("adv_cyber_implants", "syndicate_basic")
	design_ids = list("hydraulic_blade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 10000
	hidden = TRUE

/datum/techweb_node/linkedsurgery_implant
	id = "linkedsurgery_implant"
	tech_tier = 5
	display_name = "Chirurgiczny implant mózgowy z łączem serwerowym"
	description = "Implant bluespace, dzięki któremu nosiciel może odczytywać programy chirurgiczne ze swojego serwera."
	prereq_ids = list("exp_surgery", "micro_bluespace")
	design_ids = list("ci-linkedsurgery")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 10000
	hidden = TRUE

////////////////////////Tools////////////////////////

/datum/techweb_node/basic_mining
	id = "basic_mining"
	tech_tier = 1
	display_name = "Technologia górnicza"
	description = "Lepsze niż Efficiency V."
	prereq_ids = list("engineering")
	design_ids = list("drill", "superresonator", "triggermod", "damagemod", "cooldownmod", "rangemod", "hypermod", "plasmacutter", "ore_redemption", "mining_equipment_vendor", "exploration_equipment_vendor", "cargoexpress", "furnace", "furnace_console")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_mining
	id = "adv_mining"
	tech_tier = 3
	display_name = "Zaawansowana technologia górnicza"
	description = "Poziom wydajności 127"	//dumb mc references
	prereq_ids = list("basic_mining", "adv_engi", "adv_power", "adv_plasma")
	design_ids = list("drill_diamond", "jackhammer", "hypermod", "plasmacutter_adv", "borg_upgrade_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/janitor
	id = "janitor"
	tech_tier = 1
	display_name = "Zaawansowana technologia sanitarna"
	description = "Sprzątaj lepiej, szybciej, mocniej i dokładniej!"
	prereq_ids = list("adv_engi")
	design_ids = list("advmop", "buffer", "blutrash", "light_replacer_bluespace", "spraybottle", "beartrap")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/botany
	id = "botany"
	tech_tier = 1
	display_name = "Inżynieria botaniczna"
	description = "Narzędzia botaniczne"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("diskplantgene", "portaseeder", "plantgenes", "flora_gun", "hydro_tray", "biogenerator", "seed_extractor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exp_tools
	id = "exp_tools"
	tech_tier = 3
	display_name = "Narzędzia eksperymentalne"
	description = "Bardzo zaawansowane narzędzia."
	design_ids = list("exwelder", "jawsoflife", "handdrill", "laserscalpel", "mechanicalpinches", "searingtool", "wirebrush_adv")
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/sec_basic
	id = "sec_basic"
	tech_tier = 1
	display_name = "Podstawowe wyposażenie ochrony"
	description = "Standardowe wyposażenie używane przez ochronę."
	design_ids = list("seclite", "pepperspray", "bola_energy", "gulagpack", "zipties", "evidencebag", "flashbulb", "turnstile", "genpop_interface") //NSV13 added gulagpack
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/rcd_upgrade
	id = "rcd_upgrade"
	tech_tier = 3
	display_name = "Ulepszenie projektów RCD"
	description = "Odblokowuje nowe projekty RCD."
	design_ids = list("rcd_upgrade_frames", "rcd_upgrade_simple_circuits")
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_rcd_upgrade
	id = "adv_rcd_upgrade"
	tech_tier = 4
	display_name = "Ulepszenie zaawansowanych projektów RCD"
	description = "Odblokowuje nowe projekty RCD."
	design_ids = list("rcd_upgrade_silo_link")
	prereq_ids = list("rcd_upgrade", "bluespace_travel")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000


/////////////////////////weaponry tech/////////////////////////

/datum/techweb_node/landmine
	id = "nonlethal_mines"
	tech_tier = 3
	display_name = "Technologia nieśmiercionośnych min"
	description = "Nasi technicy uzbrojenia mogliby opracować metody tworzenia nieśmiercionośnych min dla zespołów ochrony."
	prereq_ids = list("sec_basic")
	design_ids = list("stunmine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/weaponry
	id = "weaponry"
	tech_tier = 3
	display_name = "Technologia rozwoju broni"
	description = "Nasi badacze znaleźli nowe sposoby, by uzbroić niemal wszystko."
	prereq_ids = list("engineering")
	design_ids = list("pin_testing", "tele_shield", "sleepy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/smartmine
	id = "smart_mines"
	tech_tier = 4
	display_name = "Technologia inteligentnych min"
	description = "Dzięki technologii IFF moglibyśmy opracować inteligentne miny, które nie aktywują się dla osób z mindshieldem."
	prereq_ids = list("weaponry", "nonlethal_mines", "engineering")
	design_ids = list("stunmine_adv")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	tech_tier = 4
	display_name = "Zaawansowana technologia rozwoju broni"
	description = "Nasza broń łamie już zasady rzeczywistości."
	prereq_ids = list("adv_engi", "weaponry")
	design_ids = list("pin_loyalty", "borg_transform_security")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/advmine
	id = "adv_mines"
	tech_tier = 4
	display_name = "Zaawansowana technologia min"
	description = "Możemy dalej rozwijać nasze inteligentne miny, budując niezwykle skuteczne konstrukcje."
	prereq_ids = list("weaponry", "smart_mines", "adv_engi")
	design_ids = list("stunmine_rapid", "stunmine_heavy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	tech_tier = 4
	display_name = "Broń elektryczna"
	description = "Broń wykorzystująca technologię elektryczną"
	prereq_ids = list("weaponry", "adv_power"  , "emp_basic")
	design_ids = list("stunrevolver", "stunshell", "ioncarbine") //NSV13 - readded stunshell
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	tech_tier = 5
	display_name = "Broń radioaktywna"
	description = "Broń wykorzystująca technologię radioaktywną."
	prereq_ids = list("adv_engi", "adv_weaponry")
	design_ids = list("nuclear_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/medical_weapons
	id = "medical_weapons"
	tech_tier = 4
	display_name = "Broń medyczna"
	description = "Broń wykorzystująca technologię medyczną."
	prereq_ids = list("adv_biotech", "weaponry")
	design_ids = list("rapidsyringe")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	tech_tier = 4
	display_name = "Broń wiązkowa"
	description = "Różne podstawowe bronie wiązkowe"
	prereq_ids = list("adv_weaponry")
	design_ids = list("temp_gun", "xray_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	tech_tier = 5
	display_name = "Zaawansowana broń wiązkowa"
	description = "Różne zaawansowane bronie wiązkowe"
	prereq_ids = list("adv_weaponry")
	design_ids = list("beamrifle")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	tech_tier = 3
	display_name = "Broń wybuchowa i pirotechniczna"
	description = "Gdy lżejsze rzeczy nie wystarczają."
	prereq_ids = list("adv_weaponry")
	design_ids = list("large_Grenade", "pyro_Grenade", "adv_Grenade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/ballistic_weapons // NSV13 - glock additions
	id = "ballistic_weapons"
	tech_tier = 3
	display_name = "Broń balistyczna"
	description = "To nie są badania... to inżynieria wsteczna!"
	prereq_ids = list("weaponry")
	design_ids = list("mag_oldsmg", "mag_oldsmg_ap", "mag_oldsmg_ic", "mag_oldsmg_rubber", "glock_lethalmag", "glock_rubbermag", "glock_apmag", "glock_incmag", "glock_lethalammo", "glock_rubberammo", "glock_apammo", "glock_incammo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exotic_ammo
	id = "exotic_ammo"
	tech_tier = 4
	display_name = "Amunicja egzotyczna"
	description = "Nawet nie będą wiedzieć, co ich trafiło."
	prereq_ids = list("adv_weaponry", "medical_weapons")
	design_ids = list("techshotshell", "c38_hotshot", "c38_iceblox", "shotgundartcryostasis")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/gravity_gun
	id = "gravity_gun"
	tech_tier = 5
	display_name = "Jednopunktowy grawitacyjny manipulator bluespace"
	description = "Wymyślna nazwa na pistolet grawitacyjny."
	prereq_ids = list("adv_weaponry", "bluespace_travel")
	design_ids = list("gravitygun", "mech_gravcatapult")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

//MODsuit tech

/datum/techweb_node/mod_basic
	id = "mod"
	tech_tier = 1
	starting_node = TRUE
	display_name = "Basic Modular Suits"
	description = "Specialized back mounted power suits with various different modules."
	design_ids = list(
		"mod_boots",
		"mod_chestplate",
		"mod_gauntlets",
		"mod_helmet",
		"mod_paint_kit",
		"mod_shell",
		"mod_plating_standard",
		"mod_plating_civilian",
		"mod_storage",
		"mod_welding",
		"mod_mouthhole",
		"mod_flashlight",
		"mod_longfall",
		"mod_thermal_regulator",
		"mod_plasma",
	)

/datum/techweb_node/mod_advanced
	id = "mod_advanced"
	tech_tier = 2
	display_name = "Advanced Modular Suits"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list("robotics")
	design_ids = list(
		"mod_visor_diaghud",
		"mod_gps",
		"mod_reagent_scanner",
		"mod_clamp",
		"mod_drill",
		"mod_orebag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_engineering
	id = "mod_engineering"
	tech_tier = 2
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list("mod_advanced", "engineering")
	design_ids = list(
		"mod_plating_engineering",
		"mod_visor_meson",
		"mod_t_ray",
		"mod_magboot",
		"mod_tether",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_advanced_engineering
	id = "mod_advanced_engineering"
	tech_tier = 4
	display_name = "Advanced Engineering Modular Suits"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list("mod_engineering", "adv_engi")
	design_ids = list(
		"mod_plating_atmospheric",
		"mod_jetpack",
		"mod_rad_protection",
		"mod_emp_shield",
		"mod_storage_expanded",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	export_price = 5000

/datum/techweb_node/mod_medical
	id = "mod_medical"
	tech_tier = 3
	display_name = "Medical Modular Suits"
	description = "Medical suits for quick rescue purposes."
	prereq_ids = list("mod_advanced", "biotech")
	design_ids = list(
		"mod_plating_medical",
		"mod_visor_medhud",
		"mod_health_analyzer",
		"mod_quick_carry",
		"mod_injector",
		"mod_organ_thrower",
		"mod_dna_lock",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_advanced_medical
	id = "mod_advanced_medical"
	tech_tier = 4
	display_name = "Advanced Medical Modular Suits"
	description = "Advanced medical suits for quicker rescue purposes."
	prereq_ids = list("mod_medical", "adv_biotech")
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	export_price = 5000

/datum/techweb_node/mod_security
	id = "mod_security"
	tech_tier = 3
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list("mod_advanced", "sec_basic")
	design_ids = list(
		"mod_plating_security",
		"mod_visor_sechud",
		"mod_stealth",
		"mod_mag_harness",
		"mod_pathfinder",
		"mod_holster",
		"mod_sonar",
		"mod_projectile_dampener",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_entertainment
	id = "mod_entertainment"
	tech_tier = 2
	display_name = "Entertainment Modular Suits"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list("mod_advanced", "clown")
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_anomaly
	id = "mod_anomaly"
	tech_tier = 4
	display_name = "Anomalock Modular Suits"
	description = "Modules for modular suits that require anomaly cores to function."
	prereq_ids = list("mod_advanced", "anomaly_research")
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mod_anomaly_engi
	id = "mod_anomaly_engi"
	tech_tier = 5
	display_name = "Engineering Anomalock Modular Suits"
	description = "Advanced modules for modular suits, using anomaly cores to become even better engineers."
	prereq_ids = list("mod_advanced_engineering", "mod_anomaly")
	design_ids = list(
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/datum/techweb_node/mod_experimental
	id = "mod_experimental"
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits has created these..."
	prereq_ids = list("base")
	design_ids = list(
		"mod_disposal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500
	hidden = TRUE

////////////////////////mech technology////////////////////////
/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	tech_tier = 3
	display_name = "Zaawansowane egzoszkielety"
	description = "Na wypadek, gdy po prostu nie jesteś wystarczająco Gundamem."
	prereq_ids = list("adv_robotics")
	design_ids = list("mech_repair_droid")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	tech_tier = 3
	display_name = "EGZOSZKIELET: Odysseus"
	description = "Projekty egzoszkieletu Odysseus"
	prereq_ids = list("base")
	design_ids = list("odysseus_chassis", "odysseus_torso", "odysseus_head", "odysseus_left_arm", "odysseus_right_arm" ,"odysseus_left_leg", "odysseus_right_leg",
	"odysseus_main", "odysseus_peri")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/gygax
	id = "mech_gygax"
	tech_tier = 4
	display_name = "EGZOSZKIELET: Gygax"
	description = "Projekty egzoszkieletu Gygax"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("gygax_chassis", "gygax_torso", "gygax_head", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_main",
	"gygax_peri", "gygax_targ", "gygax_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/durand
	id = "mech_durand"
	tech_tier = 4
	display_name = "EGZOSZKIELET: Durand"
	description = "Projekty egzoszkieletu Durand"
	prereq_ids = list("adv_mecha", "adv_weaponry")
	design_ids = list("durand_chassis", "durand_torso", "durand_head", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_main",
	"durand_peri", "durand_targ", "durand_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/phazon
	id = "mecha_phazon"
	tech_tier = 5
	display_name = "EGZOSZKIELET: Phazon"
	description = "Projekty egzoszkieletu Phazon"
	prereq_ids = list("adv_mecha", "weaponry" , "micro_bluespace")
	design_ids = list("phazon_chassis", "phazon_torso", "phazon_head", "phazon_left_arm", "phazon_right_arm", "phazon_left_leg", "phazon_right_leg", "phazon_main",
	"phazon_peri", "phazon_targ", "phazon_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	hidden = FALSE //NSV13 - unhide

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	tech_tier = 3
	display_name = "Zaawansowane wyposażenie egzoszkieletów"
	description = "Narzędzia dla zaawansowanych mechów"
	prereq_ids = list("adv_mecha")
	design_ids = list("mech_rcd", "mech_thrusters")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	tech_tier = 3
	display_name = "Medyczne wyposażenie egzoszkieletów"
	description = "Narzędzia dla zaawansowanych mechów"
	prereq_ids = list("adv_biotech")
	design_ids = list("mech_sleeper", "mech_syringe_gun", "mech_medi_beam")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_modules
	id = "adv_mecha_modules"
	tech_tier = 3
	display_name = "Proste moduły egzoszkieletów"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("adv_mecha", "bluespace_power")
	design_ids = list("mech_energy_relay", "mech_ccw_armor", "mech_proj_armor", "mech_generator_nuclear")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_scattershot
	id = "mecha_tools"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (LBX AC 10 \"Scattershot\")"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_scattershot")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (karabinek FNX-99 \"Hades\")"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_carbine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (ciężkie działo jonowe MKIV)"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("electronic_weapons", "emp_adv")
	design_ids = list("mech_ion")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (działo Tesli MKI)"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("electronic_weapons", "adv_power")
	design_ids = list("mech_tesla")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser
	id = "mech_laser"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (laser CH-PS \"Immolator\")"
	description = "Podstawowa broń do mechów"
	prereq_ids = list("beam_weapons")
	design_ids = list("mech_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (działo laserowe CH-LC \"Solaris\")"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("adv_beam_weapons")
	design_ids = list("mech_laser_heavy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_disabler
	id = "mech_disabler"
	tech_tier = 4
	display_name =  "Broń egzoszkieletu (montowany paralizator CH-DS \"Peacemaker\")"
	description = "Podstawowa broń do mechów"
	prereq_ids = list("beam_weapons")
	design_ids = list("mech_disabler")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (granatnik SGL-6)"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("explosive_weapons")
	design_ids = list("mech_grenade_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	tech_tier = 4
	display_name = "Moduł egzoszkieletu (wyrzutnia clusterbangów SOB-3)"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("explosive_weapons")
	design_ids = list("clusterbang_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	tech_tier = 4
	display_name = "Moduł egzoszkieletu (moduł teleportera)"
	description = "Zaawansowane wyposażenie do mechów"
	prereq_ids = list("micro_bluespace")
	design_ids = list("mech_teleporter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	tech_tier = 4
	display_name = "Moduł egzoszkieletu (lokalny generator tuneli)"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("bluespace_travel")
	design_ids = list("mech_wormhole_gen")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	tech_tier = 4
	display_name = "Broń egzoszkieletu (lekki karabin maszynowy \"Ultra AC 2\")"
	description = "Zaawansowana broń do mechów"
	prereq_ids = list("ballistic_weapons")
	design_ids = list("mech_lmg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	tech_tier = 3
	display_name =  "Diamentowe wiertło egzoszkieletu"
	description = "Diamentowe wiertło odpowiednie dla dużego egzoszkieletu"
	prereq_ids = list("adv_mining")
	design_ids = list("mech_diamond_drill")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Nanites/////////////////////////
/datum/techweb_node/nanite_base
	id = "nanite_base"
	tech_tier = 2
	display_name = "Podstawy programowania nanitów"
	description = "Podstawy budowy i programowania nanitów."
	prereq_ids = list("datatheory")
	design_ids = list("nanite_disk","nanite_remote","nanite_scanner",\
						"nanite_chamber","public_nanite_chamber","nanite_chamber_control","nanite_programmer","nanite_program_hub","nanite_cloud_control",\
						"relay_nanites", "monitoring_nanites", "research_nanites" ,"researchplus_nanites", "access_nanites", "repairing_nanites","sensor_nanite_volume", "repeater_nanites", "relay_repeater_nanites","red_diag_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000

/*/datum/techweb_node/nanite_smart //AQUILA EDIT START
	id = "nanite_smart"
	tech_tier = 2
	display_name = "Smart Nanite Programming"
	description = "Nanite programs that require nanites to perform complex actions, act independently, roam or seek targets."
	prereq_ids = list("nanite_base","robotics")
	design_ids = list("purging_nanites", "metabolic_nanites", "stealth_nanites", "memleak_nanites","sensor_voice_nanites", "voice_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 4000 */ //AQUILA EDIT END

/datum/techweb_node/nanite_mesh
	id = "nanite_mesh"
	tech_tier = 2
	display_name = "Siatkowe programowanie nanitów"
	description = "Programy nanitów wymagające statycznych struktur i membran."
	prereq_ids = list("nanite_base","engineering")
	design_ids = list("hardening_nanites", "dermal_button_nanites", "refractive_nanites", "cryo_nanites", "conductive_nanites", "shock_nanites", "emp_nanites", "temperature_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/*/datum/techweb_node/nanite_bio //AQUILA EDIT START
	id = "nanite_bio"
	tech_tier = 3
	display_name = "Biological Nanite Programming"
	description = "Nanite programs that require complex biological interaction."
	prereq_ids = list("nanite_base","biotech")
	design_ids = list("regenerative_nanites", "bloodheal_nanites", "coagulating_nanites","poison_nanites","flesheating_nanites",\
					"sensor_crit_nanites","sensor_death_nanites", "sensor_health_nanites", "sensor_damage_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500, TECHWEB_POINT_TYPE_NANITES = 500)
	export_price = 5000

/datum/techweb_node/nanite_neural
	id = "nanite_neural"
	tech_tier = 3
	display_name = "Neural Nanite Programming"
	description = "Nanite programs affecting nerves and brain matter."
	prereq_ids = list("nanite_bio")
	design_ids = list("nervous_nanites", "brainheal_nanites", "paralyzing_nanites", "stun_nanites", "selfscan_nanites","good_mood_nanites","bad_mood_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_synaptic
	id = "nanite_synaptic"
	tech_tier = 4
	display_name = "Synaptic Nanite Programming"
	description = "Nanite programs affecting mind and thoughts."
	prereq_ids = list("nanite_neural","neural_programming")
	design_ids = list("mindshield_nanites", "pacifying_nanites", "blinding_nanites", "sleep_nanites", "mute_nanites", "speech_nanites","hallucination_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000, TECHWEB_POINT_TYPE_NANITES = 1000)
	export_price = 5000

/datum/techweb_node/nanite_harmonic
	id = "nanite_harmonic"
	tech_tier = 4
	display_name = "Harmonic Nanite Programming"
	description = "Nanite programs that require seamless integration between nanites and biology."
	prereq_ids = list("nanite_bio","nanite_smart","nanite_mesh")
	design_ids = list("fakedeath_nanites","aggressive_nanites","defib_nanites","regenerative_plus_nanites","brainheal_plus_nanites","purging_plus_nanites", "sensor_species_nanites","adrenaline_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000, TECHWEB_POINT_TYPE_NANITES = 2000)
	export_price = 8000

/datum/techweb_node/nanite_combat
	id = "nanite_military"
	tech_tier = 5
	display_name = "Military Nanite Programming"
	description = "Nanite programs that perform military-grade functions."
	prereq_ids = list("nanite_harmonic", "syndicate_basic")
	design_ids = list("explosive_nanites","pyro_nanites","meltdown_nanites","viral_nanites","nanite_sting_nanites", "haste_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500, TECHWEB_POINT_TYPE_NANITES = 2500)
	export_price = 12500

/datum/techweb_node/nanite_hazard
	id = "nanite_hazard"
	tech_tier = 5
	display_name = "Hazard Nanite Programs"
	description = "Extremely advanced Nanite programs with the potential of being extremely dangerous."
	prereq_ids = list("nanite_harmonic", "alientech")
	design_ids = list("spreading_nanites","mindcontrol_nanites","mitosis_nanites")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000, TECHWEB_POINT_TYPE_NANITES = 4000)
	export_price = 15000 */ //AQUILA EDIT END

////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	tech_tier = 5
	display_name = "Technologia obcych"
	description = "Rzeczy używane przez szaraków."
	prereq_ids = list("biotech","engineering")
	boost_item_paths = list(/obj/item/gun/energy/alien, /obj/item/scalpel/alien, /obj/item/hemostat/alien, /obj/item/retractor/alien, /obj/item/circular_saw/alien,
	/obj/item/cautery/alien, /obj/item/surgicaldrill/alien, /obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor/baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 20000
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alientech/on_research() //Unlocks the Zeta shuttle for purchase
		SSshuttle.shuttle_purchase_requirements_met |= SHUTTLE_UNLOCK_ALIENTECH

/datum/techweb_node/alien_bio
	id = "alien_bio"
	tech_tier = 5
	display_name = "Biologiczne narzędzia obcych"
	description = "Zaawansowane narzędzia biologiczne."
	prereq_ids = list("alientech", "adv_biotech")
	design_ids = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_cautery")
	boost_item_paths = list(/obj/item/gun/energy/alien, /obj/item/scalpel/alien, /obj/item/hemostat/alien, /obj/item/retractor/alien, /obj/item/circular_saw/alien,
	/obj/item/cautery/alien, /obj/item/surgicaldrill/alien, /obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor/baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	tech_tier = 5
	display_name = "Inżynieria obcych"
	description = "Narzędzia inżynieryjne obcych"
	prereq_ids = list("alientech", "adv_engi")
	design_ids = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool")
	boost_item_paths = list(/obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor/baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	tech_tier = 4
	display_name = "Nielegalna technologia"
	description = "Niebezpieczne badania służące do tworzenia niebezpiecznych przedmiotów."
	prereq_ids = list("adv_engi", "adv_weaponry", "explosive_weapons")
	design_ids = list("decloner", "borg_syndicate_module", "ai_cam_upgrade", "suppressor", "largecrossbow", "donksofttoyvendor", "donksoft_refill", "advanced_camera" , "arcade_amputation")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/sticky_basic
	id = "sticky_basic"
	tech_tier = 3
	display_name = "Podstawowa technologia klejąca"
	description = "Po zbadaniu tej technologii pozostaje tylko zacząć drukować masę kartek „kopnij mnie”."
	prereq_ids = list("syndicate_basic", "adv_engi")
	design_ids = list("sticky_tape")

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500
	hidden = TRUE

/datum/techweb_node/sticky_advanced
	id = "sticky_advanced"
	tech_tier = 4
	display_name = "Zaawansowana technologia klejąca"
	description = "Przeciąganie dobrego żartu? Bzdura!"
	prereq_ids = list("sticky_basic")
	design_ids = list("super_sticky_tape", "pointy_tape")

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 2500
	hidden = TRUE

//Helpers for debugging/balancing the techweb in its entirety!
/proc/total_techweb_exports()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	. = 0
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		. += TN.export_price

/proc/total_techweb_points()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.research_points

/proc/total_techweb_points_printout()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.printout_points()
