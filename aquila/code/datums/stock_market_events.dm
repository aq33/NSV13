// AQUILA - wydarzenia giełdowe z tgstation (code/datums/stock_market_events.dm)

/datum/stock_market_event
	/// Nazwa wydarzenia w wiadomościach
	var/name = "Wydarzenie giełdowe!"
	/// Materiał, którego dotyczy
	var/datum/material/mat
	/// Ile ticków trwa (handle() co tick)
	var/duration = 0
	/// Losowe firmy do wiadomości
	var/list/company_name = list(
		"Nakamura Engineering",
		"Robust Industries, LLC",
		"MODular Solutions",
		"SolGov",
		"Australicus Industrial Mining",
		"Vey-Medical",
		"Aussec Armory",
		"Dreamland Robotics",
	)
	/// Opisy okoliczności do wiadomości
	var/list/circumstance = list()
	/// Trend ustawiany na start (null = bez zmian)
	var/trend_value
	/// Ile ticków trwa ten trend
	var/trend_duration

/// Zaczyna wydarzenie na materiale; FALSE = wydarzenie nie wystartowało
/datum/stock_market_event/proc/start_event(datum/material/new_mat)
	if(!ispath(new_mat, /datum/material) || isnull(SSstock_market.materials_prices[new_mat]))
		return FALSE
	mat = new_mat
	if(!isnull(trend_value))
		SSstock_market.materials_trends[mat] = trend_value
		if(trend_duration)
			SSstock_market.materials_trend_life[mat] = trend_duration
	return TRUE

/// Wołane co tick giełdy, dopóki wydarzenie trwa
/datum/stock_market_event/proc/handle()
	duration--
	if(duration <= 0)
		end_event()

/// Kończy wydarzenie
/datum/stock_market_event/proc/end_event()
	SSstock_market.active_events -= src
	qdel(src)

/// Dopisuje wiadomość o wydarzeniu do newscastera
/datum/stock_market_event/proc/create_news()
	var/temp_company = pick(company_name)
	var/temp_circumstance = pick(circumstance)
	SSstock_market.news_string += "<b>[name] [temp_company]</b> [temp_circumstance]<b>[initial(mat.name)].</b><br>"

/datum/stock_market_event/market_reset
	name = "Reset rynku!"
	trend_value = MARKET_TREND_STABLE
	trend_duration = 1
	circumstance = list(
		"została wykupiona przez prywatny fundusz inwestycyjny, co zresetowało cenę: ",
		"przechodzi restrukturyzację, co zresetowało cenę: ",
		"połączyła się z konkurentem, co zresetowało cenę: ",
	)

/datum/stock_market_event/market_reset/start_event(datum/material/new_mat)
	. = ..()
	if(!.)
		return
	SSstock_market.materials_prices[mat] = SSstock_market.price_baseline(mat)
	create_news()

/datum/stock_market_event/large_boost
	name = "Duży wzrost!"
	trend_value = MARKET_TREND_UPWARD
	trend_duration = 3
	duration = 4
	circumstance = list(
		"właśnie wypuściła nowy produkt, który podbił cenę: ",
		"wygrała duży kontrakt, co podbiło cenę: ",
		"właśnie otrzymała rządową dotację, co podbiło cenę: ",
	)

/datum/stock_market_event/large_boost/start_event(datum/material/new_mat)
	. = ..()
	if(!.)
		return
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.adjust_material_price(mat, round(gaussian(price_units, price_units * 0.15)))
	create_news()

/datum/stock_market_event/large_drop
	name = "Duży spadek!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 5
	duration = 4
	circumstance = list(
		"najnowszy produkt firmy wywołał ogromne kontrowersje i spadek ceny: ",
		"wygrała proces sądowy, co obniżyło cenę: ",
		"właśnie straciła duży kontrakt, co obniżyło cenę: ",
	)

/datum/stock_market_event/large_drop/start_event(datum/material/new_mat)
	. = ..()
	if(!.)
		return
	var/price_units = SSstock_market.materials_prices[mat]
	SSstock_market.adjust_material_price(mat, -round(gaussian(price_units * 1.5, price_units * 0.15)))
	create_news()

/datum/stock_market_event/hotcakes
	name = "Schodzi jak ciepłe bułeczki!"
	trend_value = MARKET_TREND_UPWARD
	trend_duration = 1
	circumstance = list(
		"odnosi wielki sukces! Mocno skupuje i podbija cenę: ",
		"ogłosiła nowy rekord sprzedaży i skupuje: ",
		"właśnie zawarła kontrakt z rządem na: ",
	)

/datum/stock_market_event/hotcakes/start_event(datum/material/new_mat)
	. = ..()
	if(!.)
		return
	SSstock_market.materials_prices[mat] = SSstock_market.price_maximum(mat)
	create_news()

/datum/stock_market_event/lockdown
	name = "Blokada!"
	trend_value = MARKET_TREND_DOWNWARD
	trend_duration = 2
	duration = 2
	circumstance = list(
		"jest pod lupą Galaktycznej Komisji Handlu, co wstrzymało obrót: ",
		"padła ofiarą wycieku danych, co wstrzymało obrót: ",
	)

/datum/stock_market_event/lockdown/handle()
	SSstock_market.materials_quantity[mat] = 0 // materiału nie da się kupić, dopóki blokada trwa
	return ..()

/datum/stock_market_event/lockdown/end_event()
	SSstock_market.materials_quantity[mat] = initial(mat.tradable_base_quantity)
	SSstock_market.materials_prices[mat] = SSstock_market.price_baseline(mat)
	create_news()
	return ..()
