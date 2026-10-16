#define REDACTED "???"

/// Assoc list of bitrunning grades in ascending order and their associated fontawesome icons.
GLOBAL_LIST_INIT(bitrunning_grades, list(
	BITRUNNING_GRADE_NONE = "minus",
	BITRUNNING_GRADE_D = "d",
	BITRUNNING_GRADE_C = "c",
	BITRUNNING_GRADE_B = "b",
	BITRUNNING_GRADE_A = "a",
	BITRUNNING_GRADE_S = "s",
))

SUBSYSTEM_DEF(bitrunning)
	name = "Bitrunning"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DEFAULT

	/// Wzorcowe egzemplarze wszystkich domen (do UI i ocen). Serwery ładują własne kopie.
	var/list/datum/lazy_template/virtual_domain/all_domains = list()

/datum/controller/subsystem/bitrunning/Initialize(start_timeofday)
	InitializeDomains()
	return ..()

/datum/controller/subsystem/bitrunning/proc/InitializeDomains()
	for(var/path in subtypesof(/datum/lazy_template/virtual_domain))
		all_domains += new path()

/// Zwraca wzorcowy egzemplarz domeny o danym kluczu
/datum/controller/subsystem/bitrunning/proc/get_domain(key)
	for(var/datum/lazy_template/virtual_domain/domain as anything in all_domains)
		if(domain.key == key)
			return domain

/// Compiles a list of available domains.
/datum/controller/subsystem/bitrunning/proc/get_available_domains(scanner_tier, points)
	var/list/levels = list()

	for(var/datum/lazy_template/virtual_domain/domain as anything in all_domains)
		if(domain.domain_flags & DOMAIN_TEST_ONLY)
			continue
		var/can_view = domain.can_view_name(scanner_tier, points)
		var/can_view_reward = domain.can_view_reward(scanner_tier, points)

		var/grade_symbol = GLOB.bitrunning_grades[domain.best_grade]

		levels += list(list(
			"announce_ghosts" = domain.announce_to_ghosts,
			"cost" = domain.cost,
			"desc" = can_view ? domain.desc : "Ograniczone możliwości skanowania. Nie można ustalić szczegółów domeny.",
			"difficulty" = domain.difficulty,
			"id" = domain.key,
			"is_modular" = domain.is_modular,
			"has_secondary_objectives" = counterlist_sum(domain.secondary_loot) ? TRUE : FALSE,
			"name" = can_view ? domain.name : REDACTED,
			"reward" = can_view_reward ? domain.reward_points : REDACTED,
			"grade_symbol" = grade_symbol,
		))

	return levels

/datum/controller/subsystem/bitrunning/proc/pick_secondary_loot(completed_domain)
	var/datum/lazy_template/virtual_domain/domain = completed_domain
	var/choice

	if(counterlist_sum(domain.secondary_loot))
		choice = pickweight(domain.secondary_loot)
		domain.secondary_loot[choice] -= 1
	else
		choice = /obj/item/paper/paperslip/bitrunning_error
		stack_trace("Virtual domain [domain.name] tried to pick secondary objective loot, but secondary_loot list was empty.")
	return choice

/obj/item/paper/paperslip/bitrunning_error
	name = "list z przeprosinami"
	desc = "Coś tu poszło nie tak."

/obj/item/paper/paperslip/bitrunning_error/Initialize(mapload)
	default_raw_text = "Nagroda za zebranie zaszyfrowanej ciekawostki nie dotarła. Prosimy zgłosić to do pomocy technicznej."
	return ..()

#undef REDACTED
