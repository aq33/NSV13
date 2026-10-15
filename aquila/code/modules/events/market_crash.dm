// AQUILA - krach rynku, port eventu z tgstation (code/modules/events/market_crash.dm)
// Na kilka minut ceny w automatach rosną (inflacja z logarytmem czasu trwania), a giełda materiałów spada na dno.

/datum/round_event_control/aquila_market_crash
	name = "Market Crash"
	typepath = /datum/round_event/aquila_market_crash
	weight = 10
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_market_crash
	announceWhen = 2
	/// Co który tick przeliczać ceny automatów (bez tego co 2 sekundy szłoby po wszystkich automatach)
	var/tick_counter = 1

/datum/round_event/aquila_market_crash/setup()
	startWhen = 1
	endWhen = rand(50, 100)

/datum/round_event/aquila_market_crash/announce(fake)
	var/list/possible_reasons = list(
		"układu księżyca i słońca",
		"ryzykownych wyników na rynku nieruchomości",
		"niespodziewanego upadku zespołu B.E.P.I.S.",
		"nietrafionych spekulacyjnych grantów SolGov",
		"mocno przesadzonych doniesień o zwolnieniach w księgowości Nanotrasen",
		"„świetnej inwestycji” w „niewymienialne tokeny” przez „geniusza”",
		"serii nalotów agentów Tiger Cooperative",
		"braków w łańcuchu dostaw",
		"niefortunnego upadku sieci społecznościowej Nanotrasen+",
		"no, pecha, chyba",
	)
	priority_announce("Z powodu [pick(possible_reasons)] ceny w automatach na statku przez krótki czas wzrosną.", "Dział Księgowości Nanotrasen")

/datum/round_event/aquila_market_crash/start()
	SSeconomy.market_crashing = TRUE
	SSeconomy.inflation_value = 1
	SSeconomy.update_vending_prices()
	SSstock_market.handle_market_crash()

/datum/round_event/aquila_market_crash/tick()
	SSeconomy.inflation_value = max(5.5 * log(activeFor + 1), 1)
	tick_counter++
	if(tick_counter >= 5)
		tick_counter = 1
		SSeconomy.update_vending_prices()

/datum/round_event/aquila_market_crash/end()
	SSeconomy.market_crashing = FALSE
	SSeconomy.inflation_value()
	SSeconomy.update_vending_prices()
	SSeconomy.price_update()
	priority_announce("Ceny w automatach na statku ustabilizowały się.", "Dział Księgowości Nanotrasen")
