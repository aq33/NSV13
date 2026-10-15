/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Prosimy, bądźcie dla niego mili."
	blacklist = list(/datum/station_trait/announcement_medbot,
	/datum/station_trait/announcement_baystation
	)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/carp_infestation
	name = "Carp infestation"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "W okolicy tej stacji występuje niebezpieczna fauna."
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Distant supply lines"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Ze względu na odległość od naszych zwykłych linii zaopatrzenia zamówienia zaopatrzenia są droższe."
	blacklist = list(/datum/station_trait/strong_supply_lines)
	trait_to_give = STATION_TRAIT_DISTANT_SUPPLY_LINES

/datum/station_trait/late_arrivals
	name = "Late Arrivals"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Przepraszamy, nie spodziewaliśmy się, że w drodze na waszą nową stację wlecimy w wymiotującą gęś."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/random_spawns, /datum/station_trait/hangover)
	possible_announcements = list("Znowu się spóźniacie. Ogarnijcie się, albo wszyscy jesteście zwolnieni.",
								"Nasze obliczenia trochę się nie zgadzały. Prom będzie za kilka sekund.")

/datum/station_trait/random_spawns
	name = "Drive-by landing"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Przepraszamy, minęliśmy waszą stację o kilka mil, więc po prostu wystrzeliliśmy was w jej stronę w kapsułach. Mamy nadzieję, że nie macie nic przeciwko!"
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/hangover)
	possible_announcements = list("Przelecieliśmy waszą stację o kilka mil. Przygotujcie się na zrzut kapsułami.",
								"Minęliśmy waszą stację, przepraszamy. Wkrótce zostaniecie na nią wystrzeleni.")

/datum/station_trait/hangover
	name = "Hangover"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Ooo... Stary... Ta obowiązkowa impreza firmowa z ostatniej zmiany... Boże, ale było super... Obudziłem się w jakiejś przypadkowej toalecie 3 sektory stąd..."
	trait_to_give = STATION_TRAIT_HANGOVER
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/random_spawns)
	possible_announcements = list("Ale to była noc. A teraz wracajcie do pracy.",
								"Impreza skończona. Wracajcie do pracy.")

/datum/station_trait/hangover/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))
	RegisterSignal(SSmapping, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(create_spawners))

/datum/station_trait/hangover/proc/create_spawners()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(pick_turfs_and_spawn))
	UnregisterSignal(SSmapping, COMSIG_SUBSYSTEM_POST_INITIALIZE)

/datum/station_trait/hangover/proc/pick_turfs_and_spawn()
	var/list/turf/turfs = get_safe_random_station_turfs(typesof(/area/hallway) | typesof(/area/crew_quarters/bar) | typesof(/area/crew_quarters/dorms), rand(200, 300))
	for(var/turf/T as() in turfs)
		new /obj/effect/spawner/hangover_spawn(T)

/datum/station_trait/hangover/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/spawned_mob, joined_late)
	SIGNAL_HANDLER

	if(joined_late || !iscarbon(living_mob))
		return

	var/mob/living/carbon/spawned_carbon = living_mob
	spawned_carbon.set_resting(TRUE, silent = TRUE)
	if(prob(50))
		spawned_carbon.adjust_drugginess(rand(15, 20))
	else
		spawned_carbon.drunkenness += rand(15, 25)
	spawned_carbon.adjust_disgust(rand(5, 55)) //How hungover are you?

	if(prob(35) && !spawned_carbon.head)
		var/obj/item/hat = pick(list(/obj/item/clothing/head/sombrero, /obj/item/clothing/head/fedora, /obj/item/clothing/mask/balaclava, /obj/item/clothing/head/ushanka, /obj/item/clothing/head/cardborg, /obj/item/clothing/head/pirate, /obj/item/clothing/head/cone))
		hat = new hat(spawned_mob)
		spawned_mob.equip_to_slot(hat, ITEM_SLOT_HEAD)

/datum/station_trait/blackout
	name = "Blackout"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Oświetlenie stacji wydaje się uszkodzone, uważajcie, zaczynając dzisiejszą zmianę."

/datum/station_trait/blackout/on_round_start()
	. = ..()
	for(var/a in GLOB.apcs_list)
		var/obj/machinery/power/apc/current_apc = a
		if(prob(60))
			current_apc.overload_lighting()

/datum/station_trait/empty_maint
	name = "Cleaned out maintenance"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Nasi pracownicy usunęli większość śmieci z tuneli technicznych."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT


/datum/station_trait/overflow_job_bureacracy
	name = "Overflow bureacracy mistake"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	var/list/jobs_to_use = list(JOB_NAME_CLOWN, JOB_NAME_BARTENDER, JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_MIME, JOB_NAME_JANITOR)
	var/chosen_job

/datum/station_trait/overflow_job_bureacracy/New()
	. = ..()
	chosen_job = pick(jobs_to_use)
	RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(set_overflow_job_override))

/datum/station_trait/overflow_job_bureacracy/get_report()
	return "[name] - Z jakiegoś powodu na tę zmianę opublikowaliśmy złe ogłoszenie o pracę dla roli nadmiarowej... Mamy nadzieję, że lubicie: [chosen_job]."

/datum/station_trait/overflow_job_bureacracy/proc/set_overflow_job_override(datum/source, new_overflow_role)
	SIGNAL_HANDLER

	SSjob.set_overflow_role(chosen_job)

/datum/station_trait/slow_shuttle
	name = "Slow Shuttle"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Ze względu na odległość od naszej stacji zaopatrzeniowej prom zaopatrzenia będzie dłużej leciał do waszego działu zaopatrzenia."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/bot_languages
	name = "Bot Language Matrix Malfunction"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Z powodu pewnego zdarzenia matryce językowe przyjaznych botów waszej stacji się przepaliły, przez co mówią w dziwny i nieznany sposób."

/datum/station_trait/bot_languages/New()
	. = ..()
	/// What "caused" our robots to go haywire (fluff)
	var/event_source = pick(list("burzy jonowej", "próby włamania Syndykatu", "a malfunction", "problemów z pokładową SI", "błędów stażysty", "cięć budżetowych"))
	report_message = "Z powodu [event_source] matryce językowe przyjaznych botów waszej stacji się przepaliły, przez co mówią w dziwny i nieznany sposób."

/datum/station_trait/bot_languages/on_round_start()
	. = ..()
	//All bots that exist round start have their set language randomized.
	for(var/mob/living/simple_animal/bot/found_bot in GLOB.alive_mob_list)
		/// The bot's language holder - so we can randomize and change their language
		var/datum/language_holder/bot_languages = found_bot.get_language_holder()
		bot_languages.selected_language = bot_languages.get_random_spoken_language()
