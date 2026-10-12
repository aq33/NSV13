#define PARTY_COOLDOWN_LENGTH_MIN 6 MINUTES
#define PARTY_COOLDOWN_LENGTH_MAX 12 MINUTES


/datum/station_trait/lucky_winner
	name = "Lucky winner"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	show_in_report = TRUE
	report_message = "Wasza stacja wygrała główną nagrodę w corocznej akcji charytatywnej stacji. Do baru co jakiś czas będą dostarczane darmowe przekąski."
	trait_processes = TRUE
	COOLDOWN_DECLARE(party_cooldown)

/datum/station_trait/lucky_winner/on_round_start()
	. = ..()
	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

/datum/station_trait/lucky_winner/process(delta_time)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

	var/area/area_to_spawn_in = pick(GLOB.bar_areas)
	var/turf/T = get_safe_random_station_turfs(area_to_spawn_in)

	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	var/obj/item/pizzabox/pizza_to_spawn = pick(list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/mushroom, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable)) //no pineapple pizza you monster
	new pizza_to_spawn(toLaunch)
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/drinks/beer(toLaunch)
	new /obj/effect/pod_landingzone(T, toLaunch)

/datum/station_trait/galactic_grant
	name = "Galactic grant"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Wasza stacja została wybrana do specjalnego grantu. Dział zaopatrzenia otrzymał dodatkowe fundusze."

/datum/station_trait/galactic_grant/on_round_start()
	var/datum/bank_account/cargo_bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_bank.adjust_money(rand(2000, 5000))

/datum/station_trait/premium_internals_box
	name = "Premium internals boxes"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 10
	show_in_report = TRUE
	report_message = "Pudełka z wyposażeniem oddechowym dla waszej załogi zostały wypełnione dodatkowym sprzętem."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/bountiful_bounties
	name = "Bountiful bounties"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Wygląda na to, że kolekcjonerzy w tym układzie szczególnie interesują się zleceniami i zapłacą więcej za ich wykonanie."

/datum/station_trait/bountiful_bounties/on_round_start()
	SSeconomy.bounty_modifier *= 1.2

/datum/station_trait/strong_supply_lines
	name = "Strong supply lines"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Ceny w tym układzie są niskie, KUPUJCIE, KUPUJCIE, KUPUJCIE!"
	blacklist = list(/datum/station_trait/distant_supply_lines)
	trait_to_give = STATION_TRAIT_STRONG_SUPPLY_LINES

/datum/station_trait/scarves
	name = "Scarves"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	var/list/scarves

/datum/station_trait/scarves/New()
	. = ..()
	report_message = pick(
		"Nanotrasen sprawdza w ramach eksperymentu, czy ciepła szyja poprawia morale pracowników.",
		"Po Kosmicznym Tygodniu Mody szaliki to najmodniejszy dodatek.",
		"Wszystkim było trochę zimno, gdy pakowali się na stację.",
		"Stacja na pewno nie jest atakowana przez duszących obcych udających wełnę. Na pewno nie.",
		"Wszyscy dostajecie darmowe szaliki. Nie pytajcie dlaczego.",
		"Na stację dostarczono dostawę szalików.",
	)
	scarves = typesof(/obj/item/clothing/neck/scarf) + list(
		/obj/item/clothing/neck/stripedredscarf,
		/obj/item/clothing/neck/stripedgreenscarf,
		/obj/item/clothing/neck/stripedbluescarf,
	)

	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/scarves/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/M, joined_late)
	SIGNAL_HANDLER

	var/scarf_type = pick(scarves)

	living_mob.equip_to_slot_or_del(new scarf_type(living_mob), ITEM_SLOT_NECK)

/datum/station_trait/filled_maint
	name = "Filled up maintenance"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Nasi pracownicy przez przypadek zostawili więcej swoich rzeczy osobistych w tunelach technicznych."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT

/datum/station_trait/quick_shuttle
	name = "Quick Shuttle"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Ze względu na bliskość naszej stacji zaopatrzeniowej prom zaopatrzenia będzie szybciej docierał do waszego działu zaopatrzenia."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5
