/datum/test_chamber_kit/pr_434
	name = "Zlecenia cywilne i giełda"
	pr = "aq33/AquilaStation#434"
	description = "Zlecenia: włóż kartę do konsoli zleceń, weź nowe zlecenie i wybierz jedno z trzech. \
	Karta ochrony dostaje zwykle patrol - przejdź się z nią i patrz na komunikaty postępu. \
	Zakładka „Zlecenia statku” - pobierz listę i wydrukuj ją. \
	Kostka testowa: użyj jej w ręce z kartą, zeskanuj skanerem eksportu (napiwek), obejrzyj odliczanie premii. \
	Beacon: kliknij kilka razy szybko - ma zrzucić tylko jeden pad, a za drugim użyciem konsolę. \
	Giełda: kup arkusze z karty i (karta cargo) z budżetu zaopatrzenia, włóż złoto/żelazo do maszyny i obejrzyj stock block. \
	Jeden blok jest już płynny - jego wartość ma iść za ceną z rynku (ceny zmieniają się co minutę). \
	Krach: Fun -> Trigger Event -> Market Crash - automaty drożeją, rynek pokazuje ostrzeżenie i blokuje handel. \
	Nowe zlecenia: karty amunicji, pilota, górnika, mostka i woźnego dostają własne kategorie. \
	Zarobki: OOC -> Ranking zarobków; na koniec rundy raport najlepiej zarabiających."
	items = list(
		/obj/machinery/piratepad/civilian = 1,
		/obj/machinery/computer/piratepad_control/civilian = 1,
		/obj/machinery/materials_market = 1,
		/obj/item/export_scanner = 1,
		/obj/item/bounty_cube/debug_cube = 1,
		/obj/item/civ_bounty_beacon = 1,
	)

/datum/test_chamber_kit/pr_434/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]

	// Karty z kontami: ochrona (patrole), kucharz (zlecenia kuchni), zaopatrzenie (budżet cargo na giełdzie)
	test_card(drop, /datum/job/security_officer, list(ACCESS_SECURITY))
	test_card(drop, /datum/job/cook, list(ACCESS_KITCHEN))
	test_card(drop, /datum/job/cargo_technician, list(ACCESS_CARGO))
	// Prace NSV z własnymi kategoriami zleceń
	test_card(drop, /datum/job/munitions_tech, list())
	test_card(drop, /datum/job/pilot, list())
	test_card(drop, /datum/job/shaft_miner, list())
	test_card(drop, /datum/job/bridge, list())
	test_card(drop, /datum/job/janitor, list())

	// Materiały do sprzedaży na giełdzie - osobne pola, żeby stosy się nie połączyły z niczym w items
	new /obj/item/stack/sheet/mineral/gold/fifty(drop)
	new /obj/item/stack/sheet/iron/fifty(drop)

	// Stock blocki: jeden zamrożony, drugi od razu płynny
	var/gold_price = get_market_price(/datum/material/gold) || 125
	var/obj/item/stock_block/locked_block = new(drop)
	locked_block.set_up(/datum/material/gold, 10, gold_price)
	var/obj/item/stock_block/liquid_block = new(drop)
	liquid_block.set_up(/datum/material/gold, 10, gold_price)
	liquid_block.become_liquid()

/datum/test_chamber_kit/pr_434/proc/test_card(turf/drop, job_type, list/card_access)
	var/datum/job/job = SSjob.GetJobType(job_type)
	if(!job)
		return
	var/obj/item/card/id/card = new(drop)
	card.registered_name = "Tester ([job.title])"
	card.assignment = job.title
	card.access = card_access.Copy()
	var/datum/bank_account/account = new(card.registered_name, job)
	account.adjust_money(5000)
	card.registered_account = account
	account.bank_cards += card
	card.update_label()
