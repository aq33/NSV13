// AQUILA - traitor backstories and factions, port of BeeStation/BeeStation-Hornet#9126.
// After the objectives are rolled the traitor picks a faction and a backstory in the TraitorBackstoryMenu window.
// The uplink and the codewords only come with the faction (black market and independent traitors get no codewords).
// Pure roleplay tool, there is no gameplay incentive to follow the backstory.
// Aquila addition: if nothing is picked within TRAITOR_BACKSTORY_AUTOPICK_TIME, the Syndicate is picked so nobody stays without an uplink.

#define TRAITOR_BACKSTORY_AUTOPICK_TIME (5 MINUTES)

/datum/traitor_faction
	/// The name of this faction
	var/name
	/// The name of this faction when shown to the player as their employer
	var/employer_name
	/// The define tied to this faction
	var/key
	/// A short description of this faction, OOC
	var/description
	/// If this faction has access to codewords
	var/give_codewords = FALSE

/datum/traitor_faction/syndicate
	name = "Syndykat"
	employer_name = "Syndykat"
	description = "Klasyka - albo zmuszono cię do tego szantażem, groźbą lub długami, albo urodziłeś się do tej roboty, zostałeś do niej stworzony, \
	a może dołączyłeś z zemsty.\n\
	Tak czy inaczej masz potencjalnych sojuszników w innych agentach Syndykatu, hasła i środki łączności. Wszystkie zasoby są do twojej dyspozycji.\n\
	Wykonaj robotę dobrze, a zostaniesz nagrodzony - albo po prostu uwolniony od długów.\n"
	key = TRAITOR_FACTION_SYNDICATE
	give_codewords = TRUE

/datum/traitor_faction/black_market
	name = "Czarny rynek"
	employer_name = "Twój łącznik z czarnego rynku"
	description = "Robisz to dla pieniędzy albo dlatego, że cię zmuszono.\n\
	Na okręcie Nanotrasenu można zarobić krocie, a są tacy, którzy chętnie wykorzystają twoją pozycję.\n\
	Twój zleceniodawca oczekuje wyłącznie dobrych wyników - i lepiej mu je dostarcz, bo poniesiesz konsekwencje.\n\
	Nie masz tych samych korzyści co ludzie Syndykatu - <strong><font color='yellow'>żadnych haseł</font></strong> ani środków łączności, mało potencjalnych sojuszników. \
	Pozostaje mieć nadzieję, że twoje cele są zbieżne z celami innych zdrajców.\n\
	Wykonaj robotę dobrze, a dostaniesz całą zapłatę - albo po prostu zostaniesz uwolniony od długów.\n"
	key = TRAITOR_FACTION_BLACK_MARKET

/datum/traitor_faction/independent
	name = "Niezależny"
	employer_name = "Ty sam"
	description = "Nie dla ludzi o słabych nerwach - niezależny zdrajca wymaga świetnego odgrywania postaci i świetnych umiejętności zdrajcy.\n\
	Jesteś osobą, która chowa urazy, a Nanotrasen bardzo cię skrzywdził.\n\
	Nie masz sojuszników, <strong><font color='yellow'>nie masz haseł</font></strong> i radzisz sobie wyłącznie skradzionym uplinkiem Syndykatu. Masz jedną szansę, nie zmarnuj jej.\n\
	<strong>To sprawa osobista.</strong>"
	key = TRAITOR_FACTION_INDEPENDENT

/datum/traitor_backstory
	/// The name of this traitor backstory type, displayed as a title
	var/name
	/// A description of the events leading up to this traitor's existence
	var/description
	/// Factions you can have as this backstory
	var/list/allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_SYNDICATE)
	/// Motivation types for this backstory, used for filtering and searching
	var/list/motivations = list()
	/// If this backstory is suggested for murderboning or hijacking
	var/murderbone = FALSE

/datum/traitor_backstory/proc/has_motivation(motivation)
	return motivation in motivations

/datum/traitor_backstory/debtor
	name = "Dłużnik"
	description = "Jestem winien <b>mnóstwo</b> pieniędzy... Przyszły ciężkie czasy... \
	Nie było mnie stać na życie, a teraz muszę wszystko odpracować, jeśli chcę dalej żyć."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_MONEY, TRAITOR_MOTIVATION_DEATH_THREAT)

/datum/traitor_backstory/stolen
	name = "Okradziony"
	description = "Mają... <b>wszystko</b>. Ukradli cały mój majątek i zostałem z niczym. \
	Odzyskam go tylko wtedy, gdy będę robić, co każą."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_MONEY)

/datum/traitor_backstory/gambler
	name = "Hazardzista"
	description = "Ostrzegali mnie, żebym nie siadał do tej partii kart, ale nikt mnie nie zatrzymał. Wiedzieli, że przegram dziesiątki tysięcy, \
	a ja nie umiem się powstrzymać. Teraz jest tylko jedna droga z dołu, który sam sobie wykopałem. Co za pech... \
	ale jeśli spłacę ich, wykonując te zadania, może, tylko może, wyjdę na swoje."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_MONEY)

/datum/traitor_backstory/blackmailed
	name = "Szantażowany"
	description = "Wiedzą wszystko o <b>tym, co zrobiłem</b>... i nie zawahają się mnie wydać, jeśli nie będę robić, co każą."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_REPUTATION)

/datum/traitor_backstory/hostage
	name = "Zakładnik"
	description = "Przetrzymują kogoś, kogo kocham. Boże... Co ja bym bez tej osoby zrobił? \
	<b>Muszę</b> to zrobić, inaczej już nigdy jej nie zobaczę. <b>Muszę</b>. Nie ma innego wyjścia."
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_LOVE, TRAITOR_MOTIVATION_DEATH_THREAT)

/datum/traitor_backstory/legally_enslaved
	name = "Niewolnik z kontraktu"
	description = "Cholera... Podpisałem kontrakt, którego nie powinienem był podpisywać. <b>Teraz jestem ich własnością.</b> Muszę wykonywać ich polecenia, a jeśli nie... \
	<b>Przyjdą po mnie.</b>"
	motivations = list(TRAITOR_MOTIVATION_FORCED, TRAITOR_MOTIVATION_DEATH_THREAT)

/datum/traitor_backstory/savior
	name = "Zbawca"
	description = "Nanotrasen jest zepsuty do szpiku kości. Załoga to owce. Trybiki w maszynie. \
	Muszę ich wyzwolić, pokazując im ich błędy, i zdemaskować Nanotrasen."
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_POLITICAL, TRAITOR_MOTIVATION_AUTHORITY)

/datum/traitor_backstory/hater
	name = "Mściciel"
	description = "Nanotrasen zrujnował mi życie. Zniszczył wszystko. Odebrał mi to, co kochałem. <b>Teraz za to zapłaci.</b>"
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_POLITICAL, TRAITOR_MOTIVATION_LOVE)
	murderbone = TRUE

/datum/traitor_backstory/greedy
	name = "Chciwiec"
	description = "Jeśli to zrobię, będę ustawiony do końca życia. Będę mieć wszystko, czego zapragnę, i jeszcze więcej. \
	Zapłata jest astronomiczna, a ja nadaję się do tej roboty. Do dzieła."
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_MONEY)

/datum/traitor_backstory/climber
	name = "Karierowicz"
	description = "Życie to drabina i można się po niej tylko wspinać. Nie będę mieć przyjaciół ani lojalności, \
	bo jedynym celem w życiu jest wyniesienie własnego ego ponad wszystko. \
	Przez lata obserwacji tego wszechświata zrozumiałem, że to najpewniejsza droga do panowania nad samym sobą. \
	Dziś zaczyna się moja wspinaczka i liczy się tylko mój wzlot. Jestem ponad wszystkim."
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_MONEY, TRAITOR_MOTIVATION_REPUTATION, TRAITOR_MOTIVATION_FUN)

/datum/traitor_backstory/machine
	name = "Maszyna"
	description = "Urodziłem się w Syndykacie. Syndykat mnie stworzył. <b>Jestem</b> Syndykatem. \
	Bez Syndykatu jestem niczym i zrobię <b>wszystko</b>, o co mnie poproszą."
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_AUTHORITY)
	murderbone = TRUE

/datum/traitor_backstory/sadist
	name = "Sadysta"
	description = "Chcę władzy - nie nad ludźmi, ale nad życiem. Zadawanie bólu i cierpienia to moja droga do niej. \
	Chcą zabójcy? Zagram w ich grę, jeśli pomoże mi to zaspokoić moje chore pragnienia. \
	Nie chcę pieniędzy ani wpływów. Moją zapłatą jest władza nad duszami na tym okręcie."
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	motivations = list(TRAITOR_MOTIVATION_NOT_FORCED, TRAITOR_MOTIVATION_FUN)
	murderbone = TRUE

/// Associative list of /datum/traitor_backstory path strings to datums
GLOBAL_LIST_INIT(traitor_backstories, generate_traitor_backstories())
/// Associative list of /datum/traitor_faction keys to datums
GLOBAL_LIST_INIT(traitor_factions_to_datum, generate_traitor_factions())

/proc/generate_traitor_backstories()
	var/list/result = list()
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		if(isnull(initial(path.name)))
			continue
		result["[path]"] = new path()
	return result

/proc/generate_traitor_factions()
	var/list/result = list()
	for(var/datum/traitor_faction/path as anything in subtypesof(/datum/traitor_faction))
		var/key = initial(path.key)
		if(!istext(key))
			continue
		result[key] = new path()
	return result

GLOBAL_LIST_INIT(traitor_motivations, list(
	TRAITOR_MOTIVATION_FORCED,
	TRAITOR_MOTIVATION_NOT_FORCED,
	TRAITOR_MOTIVATION_MONEY,
	TRAITOR_MOTIVATION_POLITICAL,
	TRAITOR_MOTIVATION_LOVE,
	TRAITOR_MOTIVATION_REPUTATION,
	TRAITOR_MOTIVATION_DEATH_THREAT,
	TRAITOR_MOTIVATION_AUTHORITY,
	TRAITOR_MOTIVATION_FUN,
))

/datum/antagonist/traitor
	/// Factions the traitor can pick from
	var/list/allowed_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_BLACK_MARKET, TRAITOR_FACTION_INDEPENDENT)
	/// Factions recommended by the objectives (murderbone/hijack)
	var/list/recommended_factions = list()
	/// Backstories this traitor may pick
	var/list/allowed_backstories
	/// Backstories recommended for this traitor, based on their murderbone status
	var/list/recommended_backstories
	/// The picked backstory. Can be null.
	var/datum/traitor_backstory/backstory
	/// The picked faction. Can be null.
	var/datum/traitor_faction/faction
	/// If this traitor heard the codewords
	var/has_codewords = FALSE

/// Only plain human traitors that get an uplink pick a backstory. IAA, boarders and the rest keep the old flow.
/datum/antagonist/traitor/proc/uses_backstory()
	return type == /datum/antagonist/traitor && traitor_kind == TRAITOR_HUMAN && should_equip

/datum/antagonist/traitor/proc/setup_backstories(murderbone, hijack)
	if(!uses_backstory())
		return
	ui_name = "TraitorBackstoryMenu"
	if(murderbone || hijack)
		recommended_factions = list(TRAITOR_FACTION_SYNDICATE, TRAITOR_FACTION_INDEPENDENT)
	allowed_backstories = list()
	recommended_backstories = list()
	for(var/path in GLOB.traitor_backstories)
		var/datum/traitor_backstory/possible = GLOB.traitor_backstories[path]
		if(!murderbone)
			allowed_backstories += path
			if(hijack && possible.murderbone)
				recommended_backstories += path
			continue
		if(possible.has_motivation(TRAITOR_MOTIVATION_FORCED))
			continue
		allowed_backstories += path
		if(possible.murderbone)
			recommended_backstories += path
	addtimer(CALLBACK(src, PROC_REF(autopick_faction)), TRAITOR_BACKSTORY_AUTOPICK_TIME)

/// Aquila: nobody stays without an uplink because they missed the window
/datum/antagonist/traitor/proc/autopick_faction()
	if(QDELETED(src) || faction || !owner?.current)
		return
	set_faction(GLOB.traitor_factions_to_datum[TRAITOR_FACTION_SYNDICATE])
	to_chat(owner.current, "<span class='alertsyndie'>Nie wybrano frakcji, więc przydzielił cię Syndykat. Uplink i hasła są już twoje - historię postaci wciąż możesz wybrać w oknie zdrajcy.</span>")

/datum/antagonist/traitor/proc/set_faction(datum/traitor_faction/new_faction)
	if(!istype(new_faction) || faction)
		return
	faction = new_faction
	employer = new_faction.employer_name
	if(new_faction.give_codewords)
		give_codewords()
		has_codewords = TRUE
	equip(silent)
	update_static_data(owner.current)
	log_game("[key_name(owner)] selected traitor faction [new_faction.name]")
	SSblackbox.record_feedback("tally", "traitor_faction_selected", 1, new_faction.name)

/datum/antagonist/traitor/proc/set_backstory(datum/traitor_backstory/new_backstory)
	backstory = new_backstory
	log_game("[key_name(owner)] selected traitor backstory [new_backstory.name]")
	SSblackbox.record_feedback("tally", "traitor_backstory_selected", 1, new_backstory.name)

/datum/antagonist/traitor/ui_data(mob/user)
	var/list/data = list()
	data["allowed_factions"] = allowed_factions
	data["allowed_backstories"] = allowed_backstories
	data["recommended_factions"] = recommended_factions
	data["recommended_backstories"] = recommended_backstories
	if(istype(backstory))
		data["backstory"] = "[backstory.type]"
	if(istype(faction))
		data["faction"] = faction.key
		data["employer"] = employer
	return data

/// Faction and backstory lists for TraitorBackstoryMenu, added to the traitor window data in antag_info_windows.dm
/datum/antagonist/traitor/proc/backstory_static_data()
	. = list()
	var/list/all_factions = list()
	for(var/key in GLOB.traitor_factions_to_datum)
		var/datum/traitor_faction/possible = GLOB.traitor_factions_to_datum[key]
		all_factions[key] = list(
			"name" = possible.name,
			"description" = possible.description,
			"key" = key,
		)
	.["all_factions"] = all_factions
	var/list/all_backstories = list()
	for(var/path in GLOB.traitor_backstories)
		var/datum/traitor_backstory/possible = GLOB.traitor_backstories[path]
		all_backstories[path] = list(
			"name" = possible.name,
			"description" = possible.description,
			"path" = path,
			"allowed_factions" = possible.allowed_factions,
			"motivations" = possible.motivations,
		)
	.["all_backstories"] = all_backstories
	.["all_motivations"] = GLOB.traitor_motivations

/datum/antagonist/traitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(usr != owner?.current)
		return
	switch(action)
		if("select_backstory")
			if(istype(backstory))
				return TRUE
			var/datum/traitor_backstory/selected_backstory = GLOB.traitor_backstories[params["backstory"]]
			var/datum/traitor_faction/selected_faction = GLOB.traitor_factions_to_datum[params["faction"]]
			if(!istype(selected_faction) || !istype(selected_backstory))
				return TRUE
			if(istype(faction) && faction.key != selected_faction.key)
				return TRUE
			if(!(selected_faction.key in selected_backstory.allowed_factions))
				return TRUE
			if(!("[selected_backstory.type]" in allowed_backstories))
				return TRUE
			if(!istype(faction))
				set_faction(selected_faction)
			set_backstory(selected_backstory)
			return TRUE

/datum/antagonist/traitor/antag_panel_data()
	if(!uses_backstory())
		return ..()
	. = "<b>Historia zdrajcy:</b><br>"
	. += istype(faction) ? "<b>Frakcja:</b> [faction.name]<br>" : "<font color='red'>Nie wybrano frakcji!</font><br>"
	. += istype(backstory) ? "<b>Historia:</b> [backstory.name]<br>" : "<font color='red'>Nie wybrano historii!</font><br>"

/// Faction and backstory lines of the round end report
/datum/antagonist/traitor/proc/backstory_roundend_text()
	if(!uses_backstory())
		return ""
	. = "<br>"
	if(istype(faction))
		. += "<b>Frakcja:</b> <span class='tooltip_container' style=\"font-size: 12px\">\[ [faction.name]<span class='tooltip_hover' style=\"width: 320px; padding: 5px;\">[faction.description]</span> \]</span><br>"
	if(istype(backstory))
		. += "<b>Historia:</b> <span class='tooltip_container' style=\"font-size: 12px\">\[ [backstory.name]<span class='tooltip_hover' style=\"width: 320px; padding: 5px;\">[backstory.description]</span> \]</span><br>"
	else
		. += "<span class='redtext'>Nie wybrano historii!</span><br>"

#undef TRAITOR_BACKSTORY_AUTOPICK_TIME
