// AQUILA - zlecenia cywilne z tgstation (konsola i pad zleceń, kostki zleceń)
// Rozszerza istniejące /datum/bounty o to, czego potrzebują zlecenia przypisane do kont załogi.
// Stare zlecenia zaopatrzenia (GLOB.bounties_list, konsola zleceń w zaopatrzeniu) działają dalej bez zmian.

/// Wspólne zlecenia dla całej załogi, widoczne na każdej konsoli zleceń cywilnych
GLOBAL_LIST_EMPTY(shared_crew_bounties)

/datum/bounty
	/// Czy ten typ może się powtórzyć na liście propozycji jednej osoby
	var/allow_duplicate = FALSE
	/// Nie trafia na globalną listę zleceń
	var/global_exempt = FALSE
	/// Konta, które dostarczyły coś do zlecenia; konto => udział
	var/list/contribution = list()
	/// Jednorazowe zlecenie specjalne, nie liczy się do limitu globalnej listy
	var/unique = FALSE

/// Nagroda za zlecenie cywilne, zanim zostanie podzielona między zaopatrzenie i wykonawców
/datum/bounty/proc/get_bounty_reward()
	var/high_priority_mult = high_priority ? 1.5 : 1
	return round(reward * (SSeconomy.bounty_modifier / CIV_BOUNTY_MODIFIER_BASE) * high_priority_mult)

/// Ile udziału w wypłacie daje wysłany przedmiot
/datum/bounty/proc/contribution_amount(obj/shipped)
	return 1

/// Postęp do wyświetlenia (np. „2/5”)
/datum/bounty/proc/print_required()
	return completion_string()

/// Czy zlecenie można zaproponować (np. patrol tylko w dostatecznie dużym obszarze)
/datum/bounty/proc/can_get()
	return TRUE

/// Wołane, gdy zlecenie zostaje przypięte do karty
/datum/bounty/proc/on_selected(obj/item/card/id/id_card)
	return

/// Wołane po odebraniu zlecenia na konsoli
/datum/bounty/proc/on_claimed(obj/item/card/id/id_card)
	return

/// Wołane, gdy zlecenie zostaje zdjęte z konta (odebrane albo zastąpione)
/datum/bounty/proc/on_reset(obj/item/card/id/id_card)
	return

/datum/bounty/proc/get_total()
	return 0

/datum/bounty/proc/get_max()
	return 1

/datum/bounty/item/get_total()
	return shipped_count

/datum/bounty/item/get_max()
	return required_count

/datum/bounty/reagent/get_total()
	return round(shipped_volume)

/datum/bounty/reagent/get_max()
	return required_volume

/datum/bounty/virus/get_total()
	return shipped ? 1 : 0

/// Zwraca typ zlecenia dla danej kategorii pracy (CIV_JOB_*)
/proc/get_random_civ_bounty_type(input_bounty_type)
	if(!input_bounty_type || input_bounty_type == CIV_JOB_RANDOM)
		input_bounty_type = rand(1, MAXIMUM_BOUNTY_JOBS)

	switch(input_bounty_type)
		if(CIV_JOB_BASIC)
			return pick(subtypesof(/datum/bounty/item/assistant))
		if(CIV_JOB_ROBO)
			return pick(subtypesof(/datum/bounty/item/mech))
		if(CIV_JOB_CHEF)
			return pick(subtypesof(/datum/bounty/item/chef))
		if(CIV_JOB_SEC)
			if(prob(75))
				return /datum/bounty/patrol
			return pick(subtypesof(/datum/bounty/item/security))
		if(CIV_JOB_DRINK)
			if(prob(50))
				return /datum/bounty/reagent/simple_drink
			return /datum/bounty/reagent/complex_drink
		if(CIV_JOB_CHEM)
			if(prob(50))
				return /datum/bounty/reagent/chemical_simple
			return /datum/bounty/reagent/chemical_complex
		if(CIV_JOB_MED_VIRO)
			if(prob(75))
				return pick(subtypesof(/datum/bounty/item/medical))
			return pick(subtypesof(/datum/bounty/virus))
		if(CIV_JOB_SCI)
			if(prob(50))
				return pick(subtypesof(/datum/bounty/item/science))
			return pick(subtypesof(/datum/bounty/item/slime))
		if(CIV_JOB_ENG)
			return pick(subtypesof(/datum/bounty/item/engineering))
		if(CIV_JOB_MED)
			return pick(subtypesof(/datum/bounty/item/medical))
		if(CIV_JOB_GROW)
			return pick(subtypesof(/datum/bounty/item/botany))
		if(CIV_JOB_MUNITIONS)
			return pick(subtypesof(/datum/bounty/item/munitions))
		if(CIV_JOB_PILOT)
			return pick(subtypesof(/datum/bounty/item/pilot))
		if(CIV_JOB_MINE)
			return pick(subtypesof(/datum/bounty/item/asteroid_mining))
		if(CIV_JOB_BRIDGE)
			return pick(subtypesof(/datum/bounty/item/bridge))
		if(CIV_JOB_JANITOR)
			return pick(subtypesof(/datum/bounty/item/janitor))

	stack_trace("Nie udało się wylosować zlecenia cywilnego dla kategorii [input_bounty_type]")
	return null

/// Losuje zlecenie cywilne z danej kategorii, aż trafi na takie, które da się dostać
/proc/random_civ_bounty(category)
	for(var/attempt in 1 to 20)
		var/bounty_type = get_random_civ_bounty_type(category)
		if(!bounty_type)
			return null
		var/datum/bounty/new_bounty = new bounty_type
		if(new_bounty.can_get())
			return new_bounty
		qdel(new_bounty)
	return null

/// Zlecenia specjalne dodawane raz na rundę do globalnej listy
/proc/civ_bounty_specials()
	return list(
		/datum/bounty/item/alien_organs,
		/datum/bounty/item/syndicate_documents,
		/datum/bounty/item/adamantine,
	)

/**
 * Lista propozycji zleceń dla danej kategorii pracy.
 *
 * * bounty_type - kategoria CIV_JOB_* z pracy
 * * bounty_rolls - ile propozycji
 * * assistant_failsafe - zawsze jedno łatwe zlecenie asystenckie na liście
 */
/proc/generate_civ_bounty_list(bounty_type = CIV_JOB_RANDOM, bounty_rolls = 3, assistant_failsafe = TRUE)
	var/list/rolling_list = list()
	if(assistant_failsafe)
		var/datum/bounty/assistant_bounty = random_civ_bounty(CIV_JOB_BASIC)
		if(assistant_bounty)
			rolling_list += assistant_bounty

	var/attempts = 20
	while(length(rolling_list) < bounty_rolls && attempts > 0)
		var/random_job = get_random_civ_bounty_type(attempts <= 5 ? CIV_JOB_BASIC : bounty_type)
		attempts -= 1
		if(!random_job)
			continue
		var/datum/bounty/job_bounty = new random_job()
		if(!job_bounty.can_get() || has_duplicate_civ_bounty(rolling_list, job_bounty))
			qdel(job_bounty)
			continue
		rolling_list += job_bounty

	return rolling_list

/proc/has_duplicate_civ_bounty(list/datum/bounty/bounty_list, datum/bounty/check_bounty)
	for(var/datum/bounty/existing as anything in bounty_list)
		if(existing.type != check_bounty.type)
			continue
		if(existing.allow_duplicate && check_bounty.allow_duplicate)
			continue
		return TRUE
	return FALSE

/datum/job
	/// Kategoria zleceń cywilnych dla tej pracy (CIV_JOB_*)
	var/bounty_types = CIV_JOB_BASIC

/datum/job/atmospheric_technician
	bounty_types = CIV_JOB_ENG

/datum/job/air_traffic_controller
	bounty_types = CIV_JOB_BRIDGE

/datum/job/bartender
	bounty_types = CIV_JOB_DRINK

/datum/job/bridge
	bounty_types = CIV_JOB_BRIDGE

/datum/job/botanist
	bounty_types = CIV_JOB_GROW

/datum/job/brig_physician
	bounty_types = CIV_JOB_MED

/datum/job/captain
	bounty_types = CIV_JOB_SEC

/datum/job/cargo_technician
	bounty_types = CIV_JOB_RANDOM

/datum/job/chaplain
	bounty_types = CIV_JOB_RANDOM

/datum/job/chemist
	bounty_types = CIV_JOB_CHEM

/datum/job/chief_engineer
	bounty_types = CIV_JOB_ENG

/datum/job/chief_medical_officer
	bounty_types = CIV_JOB_MED

/datum/job/clown
	bounty_types = CIV_JOB_RANDOM

/datum/job/cook
	bounty_types = CIV_JOB_CHEF

/datum/job/curator
	bounty_types = CIV_JOB_RANDOM

/datum/job/deck_tech
	bounty_types = CIV_JOB_PILOT

/datum/job/deputy
	bounty_types = CIV_JOB_SEC

/datum/job/detective
	bounty_types = CIV_JOB_SEC

/datum/job/exploration_crew
	bounty_types = CIV_JOB_MINE

/datum/job/geneticist
	bounty_types = CIV_JOB_SCI

/datum/job/head_of_personnel
	bounty_types = CIV_JOB_RANDOM

/datum/job/head_of_security
	bounty_types = CIV_JOB_SEC

/datum/job/janitor
	bounty_types = CIV_JOB_JANITOR

/datum/job/lawyer
	bounty_types = CIV_JOB_RANDOM

/datum/job/master_at_arms
	bounty_types = CIV_JOB_MUNITIONS

/datum/job/medical_doctor
	bounty_types = CIV_JOB_MED

/datum/job/mime
	bounty_types = CIV_JOB_RANDOM

/datum/job/munitions_tech
	bounty_types = CIV_JOB_MUNITIONS

/datum/job/paramedic
	bounty_types = CIV_JOB_MED

/datum/job/pilot
	bounty_types = CIV_JOB_PILOT

/datum/job/quartermaster
	bounty_types = CIV_JOB_RANDOM

/datum/job/research_director
	bounty_types = CIV_JOB_SCI

/datum/job/roboticist
	bounty_types = CIV_JOB_ROBO

/datum/job/scientist
	bounty_types = CIV_JOB_SCI

/datum/job/security_officer
	bounty_types = CIV_JOB_SEC

/datum/job/shaft_miner
	bounty_types = CIV_JOB_MINE

/datum/job/station_engineer
	bounty_types = CIV_JOB_ENG

/datum/job/virologist
	bounty_types = CIV_JOB_MED_VIRO

/datum/job/warden
	bounty_types = CIV_JOB_SEC

/datum/bank_account
	/// Aktualne zlecenie cywilne przypięte do konta
	var/datum/bounty/civilian_bounty
	/// Propozycje zleceń do wyboru (trzymane, żeby nie dało się ich przelosować przez UI)
	var/list/datum/bounty/bounties
	/// Nowe propozycje można brać raz na 5 minut
	COOLDOWN_DECLARE(bounty_timer)

/datum/bank_account/proc/bounty_num()
	return civilian_bounty?.print_required() || "Brak"

/datum/bank_account/proc/set_bounty(datum/bounty/new_bounty, obj/item/card/id/id_card)
	if(civilian_bounty)
		reset_bounty(id_card)
	civilian_bounty = new_bounty
	civilian_bounty.on_selected(id_card)

/// Sprząta po zleceniu po odebraniu albo zastąpieniu
/datum/bank_account/proc/reset_bounty(obj/item/card/id/id_card)
	if(civilian_bounty)
		civilian_bounty.on_reset(id_card)
		civilian_bounty = null
	COOLDOWN_RESET(src, bounty_timer)
