// To add a rev to the list of revolutionaries, make sure it's rev (with if(SSticker.mode.name == "revolution)),
// then call SSticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call SSticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the game somtimes isn't registering a win properly, then SSticker.mode.check_win() isn't being called somewhere.


/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	report_type = "revolution"
	role_preference = /datum/role_preference/antagonist/revolutionary
	antag_datum = /datum/antagonist/rev/head
	false_report_weight = 10
	restricted_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_AI, JOB_NAME_CYBORG,JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_HEADOFSECURITY, JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MASTERATARMS) //NSV13 - added MAA
	required_jobs = list(list(JOB_NAME_CAPTAIN=1),list(JOB_NAME_HEADOFPERSONNEL=1),list(JOB_NAME_HEADOFSECURITY=1),list(JOB_NAME_CHIEFENGINEER=1),list(JOB_NAME_RESEARCHDIRECTOR=1),list(JOB_NAME_CHIEFMEDICALOFFICER=1),list(JOB_NAME_MASTERATARMS=1)) //Any head present //NSV13 - added MAA
	required_players = 30
	required_enemies = 2
	recommended_enemies = 3
	title_icon = "revolution"

	announce_span = "danger"
	announce_text = "Niektórzy członkowie załogi próbują przeprowadzić zamach stanu!\n<span class='danger'>Rewolucjoniści</span>: szerzcie swoją sprawę i obalcie szefów, egzekucją lub w inny sposób.\n<span class='notice'>Załoga</span>: nie pozwólcie rewolucjonistom przejąć stacji."

	var/finished = 0
	var/check_counter = 0
	var/max_headrevs = 3
	var/datum/team/revolution/revolution
	var/list/datum/mind/headrev_candidates = list()
	var/end_when_heads_dead = TRUE

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<B>Obecny tryb gry to rewolucja!</B>")
	to_chat(world, "<B>Część załogi próbuje wzniecić rewolucję!<BR>\nRewolucjoniści - zabijcie Kapitana, HoP-a, HoS-a, CE, RD, CMO i MAA. Przeciągajcie innych członków załogi (poza szefami działów i ochroną) na swoją stronę, oślepiając ich fleszem. Chrońcie swoich przywódców.<BR>\nZałoga - chrońcie szefów działów. Zabijcie przywódców rewolucji, a pozostałym rewolucjonistom wybijcie to z głowy (dosłownie, uderzając ich w głowę).</B>")


///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = antag_pick(antag_candidates, /datum/role_preference/antagonist/revolutionary)
		antag_candidates -= lenin
		headrev_candidates += lenin
		lenin.restricted_roles = restricted_jobs

	if(headrev_candidates.len < required_enemies)
		setup_error = "Not enough headrev candidates"
		return FALSE

	return TRUE

/datum/game_mode/revolution/post_setup()
	var/list/heads = SSjob.get_living_heads()
	var/list/sec = SSjob.get_living_sec()
	var/weighted_score = min(max(round(heads.len - ((8 - sec.len) / 3)),1),max_headrevs)

	for(var/datum/mind/rev_mind in headrev_candidates)	//People with return to lobby may still be in the lobby. Let's pick someone else in that case.
		if(isnewplayer(rev_mind.current))
			headrev_candidates -= rev_mind
			var/list/newcandidates = shuffle(antag_candidates)
			if(newcandidates.len == 0)
				continue
			for(var/M in newcandidates)
				var/datum/mind/lenin = M
				antag_candidates -= lenin
				newcandidates -= lenin
				if(isnewplayer(lenin.current)) //We don't want to make the same mistake again
					continue
				else
					var/mob/Nm = lenin.current
					if(Nm.job in restricted_jobs)	//Don't make the HOS a replacement revhead
						antag_candidates += lenin	//Let's let them keep antag chance for other antags
						continue

					headrev_candidates += lenin
					break

	while(weighted_score < headrev_candidates.len) //das vi danya
		var/datum/mind/trotsky = pick(headrev_candidates)
		antag_candidates += trotsky
		headrev_candidates -= trotsky

	revolution = new()

	for(var/datum/mind/rev_mind in headrev_candidates)
		log_game("[key_name(rev_mind)] has been selected as a head rev")
		var/datum/antagonist/rev/head/new_head = new()
		new_head.give_hud = TRUE
		new_head.remove_clumsy = TRUE
		rev_mind.add_antag_datum(new_head,revolution)

	revolution.update_objectives()
	revolution.update_heads()

	..()


/datum/game_mode/revolution/process()
	check_counter++
	if(check_counter >= 5)
		if(!finished)
			SSticker.mode.check_win()
		check_counter = 0

//////////////////////////////////////
//Checks if the revs have won or not//
//////////////////////////////////////
/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/revolution/check_finished()
	if(CONFIG_GET(keyed_list/continuous)["revolution"])
		return ..()
	if(finished && end_when_heads_dead)
		return TRUE
	else
		return ..()

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/proc/is_revolutionary(mob/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/rev)

/proc/is_head_revolutionary(mob/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/rev/head)

//////////////////////////
//Checks for rev victory//
//////////////////////////
/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in revolution.objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in revolution.head_revolutionaries())
		var/turf/T = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && is_station_level(T.z))
			if(ishuman(rev_mind.current) || ismonkey(rev_mind.current))
				return FALSE
	return TRUE


/datum/game_mode/revolution/set_round_result()
	..()
	if(finished == 1)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if(finished == 2)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE

//TODO What should be displayed for revs in non-rev rounds
/datum/game_mode/revolution/special_report()
	if(finished == 1)
		return "<div class='panel redborder'><span class='redtext big'>Szefowie działów zostali zabici albo wygnani! Rewolucjoniści wygrywają!</span></div>"
	else if(finished == 2)
		return "<div class='panel redborder'><span class='redtext big'>Szefom działów udało się powstrzymać rewolucję!</span></div>"

/datum/game_mode/revolution/generate_report()
	return "W ostatnich czasach dostaliśmy raporty o zamieszkach ze strony naszych ukochanych pracowników, z kilkoma próbami buntu oraz zamachów na głowy departamentów. Z obserwacji wynika że kilkoro załogantów używa urządzeń typu 'flash' na swoich kolegach, którzy później wykonują ich rozkazy bez pytań. Ogranizują bunt i zamieszki by wyeliminować głowy departamentów. Zwracajcie szczególną uwagę na dziwne zachowania oraz losowe oślepianie załogantów. Jeżeli załoga spróbuje zorganizować rewoltę, macie pełne prawo do ekzegucji oraz użycia ostrej amunicji - zostaną później sklonowani w Centrali w celu przesłuchania."

/datum/game_mode/revolution/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>Wkurwieni Rewolucjoniści:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/headrev in revolution.head_revolutionaries())
		round_credits += "<center><h2>[headrev.name] jako lider rewolucji</h2>"
	for(var/datum/mind/grunt in (revolution.members - revolution.head_revolutionaries()))
		round_credits += "<center><h2>[grunt.name] jako dzielny rewolucjonista</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Wszyscy rewolucjoniści zgineli!</h2>", "<center><h2>Nie mogliśmy zidentyfikować ich zwłok!!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
