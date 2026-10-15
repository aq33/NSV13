// AQUILA - inflacja i raport ekonomiczny, port z tgstation (SSeconomy)
// Inflacja liczy, ile pieniędzy ma załoga względem rosnącego celu. Na co dzień trafia tylko do raportu w newscasterze;
// ceny w automatach mnoży dopiero krach rynku (event market_crash), tak jak w tg.

/// O ile co wypłatę rośnie bufor celu majątku załogi (łagodzi inflację w dalszej części zmiany)
#define STATION_TARGET_BUFFER 25

/datum/controller/subsystem/economy
	/// Suma pieniędzy na kontach załogi przy ostatnim przeliczeniu
	var/station_total = 0
	/// Docelowa średnia kwota na członka załogi
	var/station_target = 1
	/// Bufor celu, rośnie co wypłatę
	var/station_target_buffer = 0
	/// Ostatnio policzona inflacja (1 = brak)
	var/inflation_value = 1
	/// Trwa krach rynku - ceny automatów idą w górę, giełda leci na dno
	var/market_crashing = FALSE
	/// Ostatni raport ekonomiczny wysłany do newscastera
	var/earning_report

/datum/controller/subsystem/economy/fire(resumed = 0)
	. = ..()
	update_station_total()
	station_target_buffer += STATION_TARGET_BUFFER
	station_target = max(round(station_total / max(length(bank_accounts) * 2, 1)) + station_target_buffer, 1)
	if(!market_crashing)
		price_update()

/// Liczy, ile pieniędzy ma załoga na kontach
/datum/controller/subsystem/economy/proc/update_station_total()
	station_total = 0
	for(var/datum/bank_account/account as anything in bank_accounts)
		station_total += account.account_balance
	return station_total

/// Zwraca inflację: ile razy średni majątek załogi przekracza cel (nigdy poniżej 1)
/datum/controller/subsystem/economy/proc/inflation_value()
	if(market_crashing)
		return inflation_value
	if(!length(bank_accounts))
		return 1
	inflation_value = max(round((station_total / length(bank_accounts)) / station_target, 0.1), 1)
	return inflation_value

/// Wysyła raport ekonomiczny (z wiadomościami giełdowymi) do newscastera
/datum/controller/subsystem/economy/proc/price_update()
	var/fluff_string = market_crashing \
		? ", a zabezpieczenia firmy <b>nie chronią</b> was przed skutkami. Wszyscy zginiemy!" \
		: ", ale zabezpieczenia firmy chronią <b>WAS</b> przed skutkami!"
	var/list/report = list()
	report += "<b>Raport ekonomiczny sektora</b><br><br>"
	report += "Ceny w automatach sektora wynoszą <b>[round(inflation_value() * 100)]%</b>[fluff_string]<br><br>"
	report += "Siła nabywcza załogi to <b>[station_total] kr</b>, a docelowy przydział na członka załogi to <b>[station_target] kr</b>.<br><br>"
	if(SSstock_market.news_string)
		report += "<b>Z giełdy materiałów:</b><br>[SSstock_market.news_string]<br>"
		SSstock_market.news_string = ""

	var/datum/bank_account/moneybags
	for(var/datum/bank_account/account as anything in bank_accounts)
		if(!moneybags || moneybags.account_balance < account.account_balance)
			moneybags = account
	if(moneybags?.account_balance && living_player_count() > 1)
		report += "Najbogatszy członek załogi to <b>[moneybags.account_holder]</b> z oszczędnościami [moneybags.account_balance] kr. "
	report += "To wszystko od <i>Działu Ekonomistów Nanotrasen</i>."
	earning_report = report.Join("")
	GLOB.news_network.submit_article(earning_report, "Raport ekonomiczny", "Ogłoszenia stacji", null, allow_comments = FALSE, update_alert = FALSE)
	return TRUE

/// Przelicza ceny wszystkich automatów na statku (bez automatów graczy)
/datum/controller/subsystem/economy/proc/update_vending_prices()
	for(var/obj/machinery/vending/vending in GLOB.machines)
		if(istype(vending, /obj/machinery/vending/custom))
			continue
		vending.reset_prices()

/// Mnożnik cen w automatach - tylko podczas krachu rynku
/obj/machinery/vending/proc/inflation_multiplier()
	return SSeconomy.market_crashing ? SSeconomy.inflation_value() : 1

/// Ustawia ceny automatu na bazowe razy mnożnik inflacji
/obj/machinery/vending/proc/reset_prices()
	var/multiplier = inflation_multiplier()
	default_price = round(initial(default_price) * multiplier)
	extra_price = round(initial(extra_price) * multiplier)
	for(var/datum/data/vending_product/record as anything in product_records + hidden_records + coin_records)
		var/obj/item/product = record.product_path
		record.custom_price = initial(product.custom_price) ? round(initial(product.custom_price) * multiplier) : null
		record.custom_premium_price = initial(product.custom_premium_price) ? round(initial(product.custom_premium_price) * multiplier) : null

/// Uzupełnienie automatu odbudowuje rekordy po cenach bazowych, więc podczas krachu trzeba je przeliczyć
/obj/machinery/vending/build_inventory(list/productlist, list/recordlist, start_empty = FALSE)
	. = ..()
	if(SSeconomy.market_crashing && !istype(src, /obj/machinery/vending/custom))
		reset_prices()

#undef STATION_TARGET_BUFFER
