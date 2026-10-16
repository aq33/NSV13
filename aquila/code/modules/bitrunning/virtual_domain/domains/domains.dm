// Wszystkie domeny z tg. Mapy w _maps/virtual_domains (przeniesione skryptem z tools/bitrunning).

/datum/lazy_template/virtual_domain/abductor_ship
	name = "Statek Abduktorów"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Wejdź na pokład statku abduktorów i zabierz ich skarby."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/abductor = 1)
	help_text = "Statek-matka abduktorów nieświadomie wleciał we wrogi rejon. Załoga szykuje się do ucieczki ze sprzętem i łupami, \
	w tym ze skrzynią. Uważaj, słyną z zaawansowanej broni."
	is_modular = TRUE
	key = "abductor_ship"
	map_name = "abductor_ship"
	mob_modules = list(/datum/modular_mob_segment/abductor_agents)
	reward_points = BITRUNNER_REWARD_MEDIUM
	forced_outfit = /datum/outfit/bitductor

/datum/lazy_template/virtual_domain/ash_drake
	name = "Popielne Piekło"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Dom popielnego smoka, potężnej bestii, która przeczesuje powierzchnię Lavalandu."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	key = "ash_drake"
	map_name = "ash_drake"
	reward_points = BITRUNNER_REWARD_MEDIUM

/datum/lazy_template/virtual_domain/beach_bar
	name = "Bar na Plaży"
	desc = "Wesoła nadmorska przystań, w której przyjazne szkielety podają drinki. Hej, jak wy się tak zabiliście?"
	completion_loot = list(/obj/item/toy/beach_ball = 1)
	help_text = "Ten bar działa na szkieletowej obsadzie, która niechętnie zdradza szczegóły. \
	Może kilka drinków rozluźni atmosferę. Jak mówi przysłowie: jak nie możesz ich pokonać, przyłącz się."
	key = "beach_bar"
	map_name = "beach_bar"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/beach_bar/setup_domain(list/created_atoms)
	. = ..()
	for(var/obj/item/reagent_containers/food/drinks/drink in created_atoms)
		RegisterSignal(drink, COMSIG_DRINK_DRANK, PROC_REF(on_drink_drank))
	for(var/obj/machinery/vending/vending_machine in created_atoms)
		RegisterSignal(vending_machine, COMSIG_VENDING_DISPENSED, PROC_REF(on_vended_item))
	for(var/obj/structure/table/table in created_atoms)
		for(var/obj/item/reagent_containers/food/drinks/drink in table.loc)
			RegisterSignal(drink, COMSIG_DRINK_DRANK, PROC_REF(on_drink_drank), override = TRUE)

/datum/lazy_template/virtual_domain/beach_bar/proc/on_vended_item(obj/machinery/vending/vending_machine, obj/item/vended_item)
	SIGNAL_HANDLER
	if(istype(vended_item, /obj/item/reagent_containers/food/drinks))
		RegisterSignal(vended_item, COMSIG_DRINK_DRANK, PROC_REF(on_drink_drank))

/// Eventually reveal the cache
/datum/lazy_template/virtual_domain/beach_bar/proc/on_drink_drank(datum/source)
	SIGNAL_HANDLER
	add_points(0.5)

/datum/lazy_template/virtual_domain/blood_drunk_miner
	name = "Krwawe Wykopaliska"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Niewielu uchodzi z Lavalandu bez blizn. Niektórzy zostają, oszaleni od polowania."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/job/miner
	key = "blood_drunk_miner"
	map_name = "blood_drunk_miner"
	reward_points = BITRUNNER_REWARD_MEDIUM

/datum/lazy_template/virtual_domain/breeze_bay
	name = "Zatoka Bryzy"
	desc = "Nadmorskie miasteczko z wielkim lasem na północy."
	help_text = "To proste! Opalaj się i baw się dobrze! Tylko kraby ostatnio coś się panoszą: przetrzebienie ich odsłoni skrzynię."
	key = "breeze_bay"
	map_name = "breeze_bay"
	reward_points = BITRUNNER_REWARD_LOW
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/// AQUILA: u nas nie ma wędkowania, więc skrzynię odsłania przetrzebienie krabów
/datum/lazy_template/virtual_domain/breeze_bay/setup_domain(list/created_atoms)
	. = ..()
	for(var/mob/living/simple_animal/crab/crab in created_atoms)
		RegisterSignal(crab, COMSIG_MOB_DEATH, PROC_REF(on_crab_killed))

/// Eventually reveal the cache
/datum/lazy_template/virtual_domain/breeze_bay/proc/on_crab_killed(datum/source)
	SIGNAL_HANDLER
	add_points(2)

/datum/lazy_template/virtual_domain/bubblegum
	name = "Leże Zbroczone Krwią"
	cost = BITRUNNER_COST_HIGH
	desc = "Król demonów rzezi. Bubblegum to ogromna, masywna bestia z zamiłowaniem do przemocy."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	completion_loot = list(/obj/item/toy/plush/bubbleplush = 1)
	forced_outfit = /datum/outfit/job/miner
	key = "bubblegum"
	map_name = "bubblegum"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/clown_planet
	name = "Planeta Klaunów"
	cost = BITRUNNER_COST_LOW
	desc = "W głębokich, mrocznych zakątkach kosmosu jest tylko Honk."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/bikehorn = 1)
	forced_outfit = /datum/outfit/job/clown
	help_text = "Rozpoczęły się próby Honkitudy. W oddali zawodzą trąbki rowerowe. \
	Ta kraina, jakaś łamigłówka, od wieków uchodzi za ostateczny test tego, jak bardzo jesteś głupkowaty."
	key = "clown_planet"
	map_name = "clown_planet"
	reward_points = BITRUNNER_REWARD_LOW

/datum/lazy_template/virtual_domain/colossus
	name = "Niebiańska Próba"
	cost = BITRUNNER_COST_HIGH
	desc = "Ogromna, prastara bestia zwana Kolosem. Nadchodzi sąd."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "colossus"
	map_name = "colossus"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/fredingtonfastingbear
	name = "Impreza z Pizzą"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Słynna pizzeria, którą zniszczyło to, co miała w ofercie."
	completion_loot = list(/obj/item/food/pizzaslice/meat/pizzeria = 1)
	secondary_loot = list(/obj/item/instrument/accordion = 1)
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	help_text = "Weź latarkę i ruszaj. Twój ulubiony miś już na ciebie czeka..."
	key = "fredingtonfastingbear"
	map_name = "fredingtonfastingbear"
	reward_points = BITRUNNER_REWARD_MEDIUM

/obj/item/food/pizzaslice/meat/pizzeria
	name = "kawałek pizzy mięsnej z pizzerii"
	desc = "Mało pożywny kawałek pizzy mięsnej z dawno zamkniętej pizzerii. Twardy jak karton, raczej nie warto łamać sobie na nim zębów."
	food_reagents = list(/datum/reagent/consumable/nutriment = 1)
	bite_consumption = 0.1

/datum/lazy_template/virtual_domain/gondola_asteroid
	name = "Asteroida Gondoli"
	desc = "Asteroida z bujnym lasem pełnym gondoli. Spokojnie tu."
	help_text = "Jaki piękny las. Na środku mapy stoi skrzynia z łupem. \
	Hmm... Nie chce się ruszyć. Gondole jakoś nie mają z nią problemu. \
	Pewnie da się ją jakoś przesunąć samemu."
	key = "gondola_asteroid"
	map_name = "gondola_asteroid"
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/grasslands_hunt
	name = "Polowanie na Łąkach"
	desc = "Spokojne polowanie na łonie natury."
	help_text = "Myśliwy musi umieć wytropić i upolować zwierzynę. Udowodnij, że potrafisz."
	is_modular = TRUE
	key = "grasslands_hunt"
	map_name = "grasslands_hunt"
	mob_modules = list(/datum/modular_mob_segment/deer)
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/grasslands_hunt/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in created_atoms)
		RegisterSignal(landmark, COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED, PROC_REF(on_spawned))

/// The mob segment has concluded spawning
/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_spawned(datum/source, list/mobs)
	SIGNAL_HANDLER
	for(var/mob/living/fauna as anything in mobs)
		RegisterSignal(fauna, COMSIG_MOB_DEATH, PROC_REF(on_death))

/// Handles deer being slain
/datum/lazy_template/virtual_domain/grasslands_hunt/proc/on_death(datum/source)
	SIGNAL_HANDLER
	add_points(3.5)

/datum/lazy_template/virtual_domain/heretic_hunt
	name = "Heretyckie Łowy"
	cost = BITRUNNER_COST_LOW
	desc = "Zdradź bliźnich, żeby zdobyć potęgę."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	help_text = "Heretycy potrzebują ofiar do mrocznych rytuałów - przynoś zwłoki do miejsca rytuału! \
		Zwłoki wyżej postawionej załogi są cenniejsze i mogą mieć przydatny sprzęt."
	forced_outfit = /datum/outfit/virtual_domain_heretic
	key = "heretic_hunt"
	map_name = "heretic_hunt"
	reward_points = BITRUNNER_REWARD_LOW

/datum/lazy_template/virtual_domain/heretic_hunt/setup_domain(list/created_atoms)
	for(var/mob/living/carbon/human/ai_boarder/fake_crew/target in created_atoms)
		RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_crew_death))

/datum/lazy_template/virtual_domain/heretic_hunt/proc/on_crew_death(mob/living/carbon/human/source, gibbed)
	SIGNAL_HANDLER
	if(gibbed)
		return
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(check_loc))

/datum/lazy_template/virtual_domain/heretic_hunt/proc/check_loc(mob/living/carbon/human/ai_boarder/fake_crew/source, ...)
	SIGNAL_HANDLER
	var/obj/effect/heretic_rune/big/rune = locate() in source.loc
	if(isnull(rune))
		return

	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	add_points(source.sacrifice_value)
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, gib))

	if(locate(/obj/structure/closet/crate/secure/bitrunning/encrypted) in range(1, rune))
		rune.balloon_alert_to_viewers("rytuał ukończony")
	else
		rune.balloon_alert_to_viewers("ofiara przyjęta")
	playsound(rune, 'sound/magic/castsummon.ogg', 50, TRUE)

/datum/outfit/virtual_domain_heretic
	name = "Virtual Domain Heretic"
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	neck = /obj/item/clothing/neck/heretic_focus
	mask = /obj/item/clothing/mask/madness_mask

/datum/lazy_template/virtual_domain/hierophant
	name = "Arena Zelotów"
	cost = BITRUNNER_COST_HIGH
	desc = "Tańczcie, kukiełki, tańczcie!"
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "hierophant"
	map_name = "hierophant"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/island_brawl
	name = "Bójka na Wyspie"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_HIGH
	desc = "„Spokojna” wyspa gdzieś na końcu świata. Domena kończy się sama po pewnej liczbie zgonów."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/beachbum_combat
	help_text = "Na wyspie mogą czekać nagrody za głowy, ale najważniejsze to przeżyć. Każda śmierć na wyspie liczy się do wyniku."
	key = "island_brawl"
	map_name = "island_brawl"
	reward_points = BITRUNNER_REWARD_HIGH
	secondary_loot = list(
		/obj/item/toy/beach_ball = 2,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/disk/bitrunning/item/mini_uzi = 1,
	)

/datum/lazy_template/virtual_domain/island_brawl/setup_domain(list/created_atoms)
	for(var/obj/effect/mob_spawn/human/virtual_domain/islander/spawner in created_atoms)
		custom_spawns += spawner
		RegisterSignal(spawner, COMSIG_PARENT_QDELETING, PROC_REF(on_spawner_qdeleted))
		RegisterSignal(spawner, list(COMSIG_GHOSTROLE_SPAWNED, COMSIG_BITRUNNER_SPAWNED), PROC_REF(on_spawn))

/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawner_qdeleted(obj/effect/mob_spawn/human/virtual_domain/islander/source)
	SIGNAL_HANDLER
	if(custom_spawns)
		custom_spawns -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/// Someone has spawned in, so we check for their death
/datum/lazy_template/virtual_domain/island_brawl/proc/on_spawn(datum/source, mob/living/spawned_mob)
	SIGNAL_HANDLER
	RegisterSignal(spawned_mob, COMSIG_MOB_DEATH, PROC_REF(on_death))

/// Mob has died, so we add a point to the domain
/datum/lazy_template/virtual_domain/island_brawl/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	add_points(1)

/datum/lazy_template/virtual_domain/meta_central
	name = "Meta Central"
	cost = BITRUNNER_COST_LOW
	desc = "Co jakiś czas pracownicy żądają od Nanotrasen praw. To się nie opłaca."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	forced_outfit = /datum/outfit/job/security
	help_text = "Odpowiedz na żądania pracowników usankcjonowaną przemocą. Zbierz cenne materiały, które mogą tu leżeć. \
	Pamiętaj o szkoleniu: zawsze zakładaj winę, przyznać się mogą w ambulatorium. Czy jakoś tak."
	is_modular = TRUE
	key = "meta_central"
	map_name = "meta_central"
	mob_modules = list(/datum/modular_mob_segment/revolutionary)
	reward_points = BITRUNNER_REWARD_LOW
	announce_to_ghosts = TRUE

/datum/lazy_template/virtual_domain/pipedream
	name = "Fabryka Rur Zsypowych"
	cost = BITRUNNER_COST_LOW
	desc = "Opuszczona, zarobaczona fabryka rur zsypowych."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/stack/cable_coil/random/five = 1)
	help_text = "Niedawno wrzało tu od pracy. Robotnicy chyba wyszli w pośpiechu, a wydajność wylądowała w koszu. \
	Coś tu wszystko zdemolowało, ale co?"
	is_modular = TRUE
	key = "pipedream"
	map_name = "pipedream"
	mob_modules = list(
		/datum/modular_mob_segment/hivebots,
		/datum/modular_mob_segment/hivebots_strong
	)
	reward_points = BITRUNNER_REWARD_LOW

/datum/lazy_template/virtual_domain/pirates
	name = "Zatoka Korsarzy"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_MEDIUM
	desc = "Przebij się do ukrytego skarbu, zgarnij łup i uciekaj, zanim piraci odwrócą sytuację."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	help_text = "Załóż przygotowane stroje, żeby się wtopić w tłum, a potem przebij się przez wrogich piratów. \
	Zgarnij skarb i uciekaj, zanim cię otoczą!"
	key = "pirates"
	map_name = "pirates"
	reward_points = BITRUNNER_REWARD_MEDIUM

/datum/lazy_template/virtual_domain/psyker_shuffle
	name = "Chaos Skrzyń"
	cost = BITRUNNER_COST_LOW
	desc = "Zakradnij się do opuszczonego zakątka wirtualnego świata, gdzie trzymają wszystkie skrzynie. \
		Uwaga: domena nie obsługuje obrazu. Misję trzeba wykonać na echolokacji."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	forced_outfit = /datum/outfit/echolocator
	help_text = "Do echolokacji trudno się przyzwyczaić. Chodź powoli i uważnie sprawdzaj każdą skrzynię."
	key = "psyker_shuffle"
	map_name = "psyker_shuffle"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/psyker_zombies
	name = "Zainfekowana Domena"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Kolejny zapomniany zakątek wirtualnego świata. Ten porzucono przez wirusa zombie. \
		Uwaga: domena nie obsługuje obrazu. Misję trzeba wykonać na echolokacji."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/clothing/glasses/blindfold/white = 1)
	forced_outfit = /datum/outfit/echolocator
	help_text = "Ta kiedyś lubiana domena została zainfekowana wirusem: jest niestabilna, pełna dziur i pełna ZOMBIE! \
		Gdzieś w pobliżu powinna być Tajemnicza Skrzynia z bronią. Uzbrój się i dokończ to, co zaczęła cyber-policja."
	key = "psyker_zombies"
	map_name = "psyker_zombies"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/stairs_and_cliffs
	name = "Lodowcowa Harówka"
	cost = BITRUNNER_COST_LOW
	desc = "Zdradliwa wspinaczka, którą przeżyje niewiele łydek. Ale kardio świetne."
	help_text = "Znasz „Węże i drabiny”? To prawie to samo, tylko zamiast drabin są schody, \
	a zamiast węży stromy spadek z urwiska na ostre skały albo w ciekłą plazmę."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/clothing/suit/snowman = 2)
	secondary_loot = list(/obj/item/clothing/head/ushanka = 2, /obj/item/clothing/shoes/winterboots = 1)
	forced_outfit = /datum/outfit/job/virtual_domain_iceclimber
	key = "stairs_and_cliffs"
	map_name = "stairs_and_cliffs"
	reward_points = BITRUNNER_REWARD_MEDIUM
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/outfit/job/virtual_domain_iceclimber
	name = "Ice Climber"
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack/duffelbag
	shoes = /obj/item/clothing/shoes/winterboots

/datum/lazy_template/virtual_domain/syndicate_assault
	name = "Szturm na Syndykat"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_MEDIUM
	desc = "Wejdź na wrogi statek i odzyskaj skradziony ładunek."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plush/nukeplushie = 1)
	help_text = "Grupa agentów Syndykatu ukradła ze statku cenny ładunek. Weszli na swój okręt i próbują uciec. \
	Przeniknij na ich statek i odzyskaj skrzynię. Uważaj, są bardzo dobrze uzbrojeni."
	is_modular = TRUE
	key = "syndicate_assault"
	map_name = "syndicate_assault"
	mob_modules = list(/datum/modular_mob_segment/syndicate_team)
	reward_points = BITRUNNER_REWARD_MEDIUM

/// Used for unit tests only. Skipped in UI.
/datum/lazy_template/virtual_domain/test_only
	name = "Test Only"
	key = "test_only"
	map_name = "test_only"
	domain_flags = DOMAIN_TEST_ONLY

/datum/lazy_template/virtual_domain/test_only/expensive
	key = "test_only_expensive"
	cost = 3

/datum/lazy_template/virtual_domain/vaporwave
	name = "Kosmiczny Relikt"
	cost = BITRUNNER_COST_EXTREME
	desc = "Zawieszony w cichej pustce kosmosu Neonowy Relikt to niepokojące echo retrofuturystycznej epoki. Wyluzuj i podziwiaj widoki."
	difficulty = BITRUNNER_DIFFICULTY_NONE
	completion_loot = list(/obj/item/stack/spacecash/c500 = 4)
	key = "vaporwave"
	map_name = "vaporwave"
	reward_points = BITRUNNER_REWARD_EXTREME
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/datum/lazy_template/virtual_domain/wendigo
	name = "Lodowy Pożeracz"
	cost = BITRUNNER_COST_HIGH
	desc = "Legendy mówią o żarłocznym Wendigo ukrytym głęboko w jaskiniach lodowego księżyca."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	forced_outfit = /datum/outfit/job/miner
	key = "wendigo"
	map_name = "wendigo"
	reward_points = BITRUNNER_REWARD_HIGH

/datum/lazy_template/virtual_domain/xeno_nest
	name = "Plaga Ksenomorfów"
	cost = BITRUNNER_COST_LOW
	desc = "Skanery statku wykryły formy życia nieznanego pochodzenia. Przyjazne próby kontaktu zawiodły."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/toy/plush/rouny = 1)
	help_text = "Jesteś na jałowej planecie pełnej wrogich stworzeń. Jest tu skrzynia, nie ukryta, \
	po prostu pilnie strzeżona. Spodziewaj się oporu."
	is_modular = TRUE
	key = "xeno_nest"
	map_name = "xeno_nest"
	mob_modules = list(/datum/modular_mob_segment/xenos)
	reward_points = BITRUNNER_REWARD_LOW
