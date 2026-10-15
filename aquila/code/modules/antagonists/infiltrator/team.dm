#define MIN_MAJOR_OBJECTIVES 1
#define MAX_MAJOR_OBJECTIVES 2
#define MIN_MINOR_OBJECTIVES 3
#define MAX_MINOR_OBJECTIVES 4

/datum/team/infiltrator
	name = "Syndicate Infiltration Unit"
	member_name = "infiltrator Syndykatu"

/datum/team/infiltrator/roundend_report()
	var/list/parts = list()
	parts += span_header("Infiltratorzy Syndykatu:<br>")

	var/result = get_result()
	var/dead_as_a_doornail = TRUE
	for(var/I in members)
		var/datum/mind/syndicate = I
		if (syndicate?.current?.stat != DEAD)
			dead_as_a_doornail = FALSE

	var/flavor_message
	if (dead_as_a_doornail)
		var/static/list/messages = list(
			"No cóż, wysłanie tych matołów było stratą czasu.",
			"Wyciągnę was, niekompetentnych idiotów, z piekła tylko po to, żeby osobiście was pozabijać!",
			"Daliśmy wam, debilom, tyle zasobów, a wy po prostu giniecie? Żałosne namiastki agentów."
		)
		parts += "<span class='redtext big'>Wielkie zwycięstwo załogi!</span>"
		parts += "<B>Załoga zabiła infiltratorów Syndykatu!</B>"
		flavor_message = pick(messages)
	else
		switch (result)
			if (INFILTRATION_ALLCOMPLETE)
				var/static/list/messages = list(
					"No pewnie! Dzięki wam Nanotrasen pożałuje, że z nami zadarł!",
					"Chłopaki w ciemnej czerwieni są z was dumni, agenci. Sowicie was wynagrodzimy.",
					"Naprawdę robicie wrażenie, agenci. Zasłużyliście na miejsce w Syndykacie.",
					"Ha! Wiedziałem, że wygracie! Nanotrasen nie ma szans z ludzką determinacją!"
				)
				parts += span_greentext(span_big("Wielkie zwycięstwo infiltratorów!"))
				parts += span_bold("Infiltratorzy Syndykatu wykonali wszystkie cele!")
				flavor_message = pick(messages)
			if (INFILTRATION_MOSTCOMPLETE)
				var/static/list/messages = list(
					"No, idealnie nie było, ale byliście cholernie dobrzy.",
					"Dobra robota, agenci. Nie zdobyliśmy wszystkiego, ale nawet my nie jesteśmy idealni.",
					"Dzięki za dobrą robotę. Wracajcie do bazy i odpocznijcie przed kolejnym zadaniem."
				)
				parts += span_greentext(span_big("Umiarkowane zwycięstwo infiltratorów"))
				parts += span_bold("Infiltratorzy Syndykatu wykonali większość celów!")
				flavor_message = pick(messages)
			if (INFILTRATION_SOMECOMPLETE)
				var/static/list/messages = list(
					"Lepsze to niż kompletna klapa, chyba.",
					"Będę musiał pociągnąć za parę sznurków, żeby nie obcięli nam pensji za słabe wyniki.",
					"Przynajmniej nie była to kompletna strata czasu..."
				)
				parts += span_marooned(span_big("Remis"))
				parts += span_bold("Infiltratorzy Syndykatu wykonali część celów, ale za mało, by wygrać.")
				flavor_message = pick(messages)
			else
				var/static/list/messages = list(
					"Jak wrócicie do bazy, matoły, to lepiej miejcie na to cholernie dobre wytłumaczenie!",
					"Mam nadzieję, że lubicie kupy kosmicznych karpi, bo ich sprzątanie będzie przez jakiś czas waszą najważniejszą operacją, idioci!",
					"Jak można było zawalić tak prostą operację? Mieliście tylko się skradać i nie robić scen!"
				)
				parts += span_redtext(span_big("Zwycięstwo załogi"))
				parts += span_bold("Załoga nie pozwoliła infiltratorom Syndykatu wykonać żadnego celu!")
				flavor_message = pick(messages)
	parts += "<div><font color='#FF0000'><i>\"[flavor_message]\"</i></font>"
	parts += "[GLOB.TAB]- Dowódca Syndykatu [pick(pick(GLOB.first_names_male,GLOB.first_names_female))]</div>"

	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/text = span_header("Infiltratorzy Syndykatu:")
	var/purchases = ""
	var/tc_spent = 0
	for (var/I in members)
		var/datum/mind/syndicate = I
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[syndicate.key]
		if (H)
			tc_spent += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	text += printplayerlist(members)
	text += "(Syndykat wydał [tc_spent] TC) [purchases]"
	if (tc_spent == 0 && !dead_as_a_doornail && result < INFILTRATION_NONECOMPLETE)
		text += span_big("[icon2html('icons/badass.dmi', world, "badass")]")
	parts += text
	parts += printobjectives(objectives)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/infiltrator/is_gamemode_hero()
	return SSticker.mode.name == "infiltration"

/datum/team/infiltrator/proc/forge_single_objective() // Complete traitor copypasta!
	if(prob(50))
		if(prob(30))
			add_objective(/datum/objective/maroon)
		else
			add_objective(/datum/objective/assassinate)
	else
		add_objective(/datum/objective/steal)

/datum/team/infiltrator/proc/add_objective(type)
	var/datum/objective/O = type
	if (ispath(type))
		O = new type
	O.find_target()
	O.team = src
	objectives |= O
	if(istype(O, /datum/objective/steal))
		var/datum/objective/steal/S = O
		if(S.targetinfo)
			for(var/item in S.targetinfo.special_equipment)
				for(var/turf/T in GLOB.infiltrator_objective_items)
					if(!(item in T.contents))
						new item(T)
	return O

/datum/team/infiltrator/proc/update_objectives()
	if(LAZYLEN(objectives))
		return
	var/list/major_objectives = subtypesof(/datum/objective/infiltrator)
	var/major = rand(MIN_MAJOR_OBJECTIVES, MAX_MAJOR_OBJECTIVES)
	var/minor = rand(MIN_MINOR_OBJECTIVES, MAX_MINOR_OBJECTIVES)
	for(var/i in 1 to major)
		var/objective_type = pick_n_take(major_objectives)
		var/datum/objective/infiltrator/objective = new objective_type
		if (objective.is_possible())
			add_objective(objective)
		else
			qdel(objective)
	for(var/i in 1 to minor)
		forge_single_objective()
	for(var/datum/mind/M in members)
		var/datum/antagonist/infiltrator/I = M.has_antag_datum(/datum/antagonist/infiltrator)
		if(I)
			I.objectives |= objectives
		M.announce_objectives()

/datum/team/infiltrator/proc/get_result()
	var/objectives_complete = 0
	var/objectives_failed = 0

	for(var/datum/objective/O in objectives)
		if(O.check_completion())
			objectives_complete++
		else
			objectives_failed++

	if(objectives_failed == 0 && objectives_complete > 0) //Complete all, and fail none, big win!
		return INFILTRATION_ALLCOMPLETE
	else if (objectives_failed == 1 && objectives_complete > 0) // Fail one, but complete the rest, still pretty good!
		return INFILTRATION_MOSTCOMPLETE
	else if((objectives_complete == objectives_failed) || (objectives_complete > 0 && objectives_failed > objectives_complete)) //Fail almost all of them, not very good...
		return INFILTRATION_SOMECOMPLETE
	else
		return INFILTRATION_NONECOMPLETE //You completely failed, you suck.
