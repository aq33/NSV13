// AQUILA - giełda materiałów z tgstation (SSstock_market)
// Ceny materiałów zmieniają się co minutę według trendów i losowych wydarzeń.
// Z giełdy korzysta maszyna „galactic materials market” i eksport materiałów promem zaopatrzenia.

SUBSYSTEM_DEF(stock_market)
	name = "Stock Market"
	wait = 60 SECONDS
	runlevels = RUNLEVEL_GAME

	/// Typ materiału => cena za arkusz
	var/list/materials_prices = list()
	/// Typ materiału => trend (1 w górę, 0 stabilnie, -1 w dół)
	var/list/materials_trends = list()
	/// Typ materiału => ile ticków jeszcze trwa obecny trend
	var/list/materials_trend_life = list()
	/// Typ materiału => dostępna liczba arkuszy
	var/list/materials_quantity = list()
	/// Trwające wydarzenia giełdowe
	var/list/active_events = list()
	/// Wiadomości o wydarzeniach czekające na publikację w newscasterze
	var/news_string = ""
	/// Kiedy wysłać zebrane wiadomości do newscastera
	COOLDOWN_DECLARE(news_cooldown)

/datum/controller/subsystem/stock_market/Initialize(timeofday)
	for(var/datum/material/possible_market as anything in subtypesof(/datum/material))
		if(!initial(possible_market.tradable))
			continue
		var/base_quantity = initial(possible_market.tradable_base_quantity)
		materials_prices[possible_market] = initial(possible_market.market_value)
		materials_trends[possible_market] = rand(MARKET_TREND_DOWNWARD, MARKET_TREND_UPWARD)
		materials_trend_life[possible_market] = rand(1, 3)
		materials_quantity[possible_market] = round(base_quantity + rand(-base_quantity * 0.5, base_quantity * 0.5))
	COOLDOWN_START(src, news_cooldown, 10 MINUTES)
	return ..()

/datum/controller/subsystem/stock_market/stat_entry(msg)
	msg = "M:[length(materials_prices)]|E:[length(active_events)]"
	return ..()

/datum/controller/subsystem/stock_market/fire(resumed)
	for(var/market in materials_prices)
		handle_trends_and_price(market)
	for(var/datum/stock_market_event/event as anything in active_events)
		event.handle()
	if(news_string && COOLDOWN_FINISHED(src, news_cooldown))
		publish_news()

/// Cena bazowa materiału (za arkusz)
/datum/controller/subsystem/stock_market/proc/price_baseline(datum/material/mat)
	return initial(mat.market_value)

/// Najniższa cena materiału
/datum/controller/subsystem/stock_market/proc/price_minimum(datum/material/mat)
	var/override = initial(mat.market_minimum_override)
	if(!isnull(override))
		return round(override)
	return round(initial(mat.market_value) * 0.5)

/// Najwyższa cena materiału
/datum/controller/subsystem/stock_market/proc/price_maximum(datum/material/mat)
	return round(initial(mat.market_value) * 3)

/// Zmienia cenę materiału (kupno albo sprzedaż), pilnując granic
/datum/controller/subsystem/stock_market/proc/adjust_material_price(datum/material/mat, delta)
	if(isnull(materials_prices[mat]))
		return
	materials_prices[mat] = round(clamp(materials_prices[mat] + delta, price_minimum(mat), price_maximum(mat)))

/// Zmienia podaż materiału (kupno albo sprzedaż), pilnując granic
/datum/controller/subsystem/stock_market/proc/adjust_material_quantity(datum/material/mat, delta)
	if(isnull(materials_quantity[mat]))
		return
	materials_quantity[mat] = round(clamp(materials_quantity[mat] + delta, 0, initial(mat.tradable_base_quantity) * 2))

/// Przesuwa cenę i podaż materiału zgodnie z trendem, czasem odpala wydarzenie
/datum/controller/subsystem/stock_market/proc/handle_trends_and_price(datum/material/mat)
	if(prob(MARKET_EVENT_PROBABILITY))
		handle_market_event(mat)
	var/trend = materials_trends[mat]
	var/trend_life = materials_trend_life[mat]

	var/price_units = materials_prices[mat]
	var/price_minimum = price_minimum(mat)
	var/price_maximum = price_maximum(mat)
	var/price_baseline = price_baseline(mat)
	var/quantity_baseline = initial(mat.tradable_base_quantity)
	var/stock_quantity = materials_quantity[mat]

	if(trend_life <= 0)
		// im bliżej granicy ceny, tym większa szansa na odbicie w drugą stronę
		if(price_units < price_baseline)
			var/chance_swap = 100 - ((clamp(price_units - price_minimum, 1, 1000) / max(price_baseline - price_minimum, 1)) * 100)
			materials_trends[mat] = prob(chance_swap) ? MARKET_TREND_UPWARD : MARKET_TREND_STABLE
		else if(price_units > price_baseline)
			var/chance_swap = 100 - ((clamp(price_maximum - price_units, 1, 1000) / max(price_maximum - price_baseline, 1)) * 100)
			materials_trends[mat] = prob(chance_swap) ? MARKET_TREND_DOWNWARD : MARKET_TREND_STABLE
		else
			materials_trends[mat] = rand(MARKET_TREND_DOWNWARD, MARKET_TREND_UPWARD)
		materials_trend_life[mat] = rand(1, 3)
	else
		materials_trend_life[mat] -= 1

	var/price_change = 0
	var/quantity_change = 0
	switch(trend)
		if(MARKET_TREND_UPWARD)
			price_change = CEILING(gaussian(price_units * 0.3, price_baseline * 0.15), 1)
			quantity_change = -round(gaussian(quantity_baseline * 0.15, quantity_baseline * 0.15))
		if(MARKET_TREND_STABLE)
			price_change = round(gaussian(0, price_baseline * 0.01))
			quantity_change = round(gaussian(0, quantity_baseline * 0.5))
		if(MARKET_TREND_DOWNWARD)
			price_change = -CEILING(gaussian(price_units * 0.3, price_baseline * 0.15), 1)
			quantity_change = round(gaussian(quantity_baseline * 0.15, quantity_baseline * 0.15))
	materials_prices[mat] = round(clamp(price_units + price_change, price_minimum, price_maximum))
	materials_quantity[mat] = round(clamp(stock_quantity + quantity_change, 0, quantity_baseline * 2))

/// Odpala losowe wydarzenie giełdowe na danym materiale
/datum/controller/subsystem/stock_market/proc/handle_market_event(datum/material/mat)
	var/event_type = pick(subtypesof(/datum/stock_market_event))
	var/datum/stock_market_event/event = new event_type
	if(event.start_event(mat))
		active_events += event
	else
		qdel(event)

/// Publikuje zebrane wiadomości giełdowe w newscasterze
/datum/controller/subsystem/stock_market/proc/publish_news()
	var/channel_name = "Wiadomości giełdowe"
	var/has_channel = FALSE
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		if(channel.channel_name == channel_name)
			has_channel = TRUE
			break
	if(!has_channel)
		GLOB.news_network.create_feed_channel(channel_name, "Galaktyczny Rynek Materiałów", "Notowania i wydarzenia z galaktycznego rynku materiałów.", locked = TRUE)
	GLOB.news_network.submit_article(news_string, "Galaktyczny Rynek Materiałów", channel_name, null, allow_comments = FALSE)
	news_string = ""
	COOLDOWN_START(src, news_cooldown, 10 MINUTES)
