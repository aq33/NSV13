//The hunters!!
/datum/antagonist/fugitive_hunter
	name = "Łowca zbiegów"
	roundend_category = "zbiegowie"
	banning_key = ROLE_FUGITIVE_HUNTER
	silent = TRUE //greet called by the spawn
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/fugitive_hunters/hunter_team
	var/backstory = "error"

/datum/antagonist/fugitive_hunter/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive_hunter/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive_hunter/on_gain()
	forge_objectives()
	. = ..()
	for(var/datum/objective/O in objectives)
		log_objective(owner, O.explanation_text)

/datum/antagonist/fugitive_hunter/proc/forge_objectives() //this isn't an actual objective because it's about round end rosters
	var/datum/objective/capture = new /datum/objective
	capture.owner = owner
	capture.explanation_text = "Schwytaj zbiegów na stacji i umieść ich w maszynie przechwytującej bluespace na swoim statku."
	objectives += capture

/datum/antagonist/fugitive_hunter/greet()
	switch(backstory)
		if("space cop")
			to_chat(owner, "<span class='boldannounce'>Sprawiedliwość przybyła. Jestem członkiem Kosmopolu!</span>")
			to_chat(owner, "<B>Przestępcy powinni być na stacji, mamy wszczepione specjalne HUD-y, by ich rozpoznać.</B>")
			to_chat(owner, "<B>Straciliśmy praktycznie całą władzę nad tymi przeklętymi, bezprawnymi megakorporacjami, więc nie wiadomo, czy ich ochrona będzie z nami współpracować.</B>")
		if("russian")
			to_chat(src, "<span class='danger'>Ay blyat. Jestem kosmorosyjskim przemytnikiem! Byliśmy w trakcie lotu, gdy ktoś przeteleportował ładunek z naszego statku!</span>")
			to_chat(src, "<span class='danger'>Wywołał nas człowiek w zielonym mundurze, obiecując zwrot towaru w zamian za przysługę:</span>")
			to_chat(src, "<span class='danger'>Na pobliskiej stacji ukrywają się zbiegowie, których szuka. Chce ich z powrotem, żywych lub martwych.</span>")
			to_chat(src, "<span class='danger'>Bez ładunku nie zwiążemy końca z końcem, więc musimy zrobić, co każe, i ich schwytać.</span>")

	to_chat(owner, "<span class='boldannounce'>Nie jesteś antagonistą w tym sensie, że możesz zabijać, kogo chcesz, ale możesz zrobić wszystko, by schwytać zbiegów, nawet jeśli trzeba przebić się przez stację.</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive_hunter/create_team(datum/team/fugitive_hunters/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive_hunter/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.hunter_team)
				hunter_team = H.hunter_team
				return
		hunter_team = new /datum/team/fugitive_hunters
		hunter_team.backstory = backstory
		hunter_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	hunter_team = new_team

/datum/antagonist/fugitive_hunter/get_team()
	return hunter_team

/datum/team/fugitive_hunters
	var/backstory = "error"

/datum/team/fugitive_hunters/proc/update_objectives(initial = FALSE)
	objectives = list()
	var/datum/objective/O = new()
	O.team = src
	objectives += O
	for(var/datum/mind/M in members)
		log_objective(M, O.explanation_text)

/datum/team/fugitive_hunters/proc/assemble_fugitive_results()
	var/list/fugitives_counted = list()
	var/list/fugitives_dead = list()
	var/list/fugitives_captured = list()
	for(var/datum/antagonist/fugitive/A in GLOB.antagonists)
		if(!A.owner)
			continue
		fugitives_counted += A
		if(A.owner.current.stat == DEAD)
			fugitives_dead += A
		if(A.is_captured)
			fugitives_captured += A
	. = list(fugitives_counted, fugitives_dead, fugitives_captured) //okay, check out how cool this is.

/datum/team/fugitive_hunters/proc/all_hunters_dead()
	var/dead_boys = 0
	for(var/I in members)
		var/datum/mind/hunter_mind = I
		if(!(ishuman(hunter_mind.current) || (hunter_mind.current.stat == DEAD)))
			dead_boys++
	return dead_boys >= members.len

/datum/team/fugitive_hunters/proc/get_result()
	var/list/fugitive_results = assemble_fugitive_results()
	var/list/fugitives_counted = fugitive_results[1]
	var/list/fugitives_dead = fugitive_results[2]
	var/list/fugitives_captured = fugitive_results[3]
	var/hunters_dead = all_hunters_dead()
	//this gets a little confusing so follow the comments if it helps
	if(!fugitives_counted.len)
		return
	if(fugitives_captured.len)//any captured
		if(fugitives_captured.len == fugitives_counted.len)//if the hunters captured all the fugitives, there's a couple special wins
			if(!fugitives_dead)//specifically all of the fugitives alive
				return FUGITIVE_RESULT_BADASS_HUNTER
			else if(hunters_dead)//specifically all of the hunters died (while capturing all the fugitives)
				return FUGITIVE_RESULT_POSTMORTEM_HUNTER
			else//no special conditional wins, so just the normal major victory
				return FUGITIVE_RESULT_MAJOR_HUNTER
		else if(!hunters_dead)//so some amount captured, and the hunters survived.
			return FUGITIVE_RESULT_HUNTER_VICTORY
		else//so some amount captured, but NO survivors.
			return FUGITIVE_RESULT_MINOR_HUNTER
	else//from here on out, hunters lost because they did not capture any fugitive dead or alive. there are different levels of getting beat though:
		if(!fugitives_dead)//all fugitives survived
			return FUGITIVE_RESULT_MAJOR_FUGITIVE
		else if(fugitives_dead < fugitives_counted)//at least ANY fugitive lived
			return FUGITIVE_RESULT_FUGITIVE_VICTORY
		else if(!hunters_dead)//all fugitives died, but none were taken in by the hunters. minor win
			return FUGITIVE_RESULT_MINOR_FUGITIVE
		else//all fugitives died, all hunters died, nobody brought back. seems weird to not give fugitives a victory if they managed to kill the hunters but literally no progress to either goal should lead to a nobody wins situation
			return FUGITIVE_RESULT_STALEMATE

/datum/team/fugitive_hunters/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	if(!members.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>...a <B>[members.len]</B> łowców próbowało ich dopaść!"

	for(var/datum/mind/M in members)
		result += "<b>[printplayer(M)]</b>"

	switch(get_result())
		if(FUGITIVE_RESULT_BADASS_HUNTER)//use defines
			result += "<span class='greentext big'>Zabójcze zwycięstwo łowców!</span>"
			result += "<B>Łowcom udało się schwytać wszystkich zbiegów żywych!</B>"
		if(FUGITIVE_RESULT_POSTMORTEM_HUNTER)
			result += "<span class='greentext big'>Pośmiertne zwycięstwo łowców!</span>"
			result += "<B>Łowcom udało się schwytać wszystkich zbiegów, ale sami wszyscy zginęli! Upiorne!</B>"
		if(FUGITIVE_RESULT_MAJOR_HUNTER)
			result += "<span class='greentext big'>Wielkie zwycięstwo łowców</span>"
			result += "<B>Łowcom udało się schwytać wszystkich zbiegów, żywych lub martwych.</B>"
		if(FUGITIVE_RESULT_HUNTER_VICTORY)
			result += "<span class='greentext big'>[capitalize(backstory)] Victory</span>"
			result += "<B>Łowcom udało się schwytać zbiega, żywego lub martwego.</B>"
		if(FUGITIVE_RESULT_MINOR_HUNTER)
			result += "<span class='greentext big'>Małe zwycięstwo łowców</span>"
			result += "<B>Wszyscy łowcy zginęli, ale schwytali zbiega, żywego lub martwego.</B>"
		if(FUGITIVE_RESULT_STALEMATE)
			result += "<span class='neutraltext big'>Krwawy pat</span>"
			result += "<B>Wszyscy zginęli, a żadnego zbiega nie odzyskano!</B>"
		if(FUGITIVE_RESULT_MINOR_FUGITIVE)
			result += "<span class='redtext big'>Małe zwycięstwo zbiegów</span>"
			result += "<B>Wszyscy zbiegowie zginęli, ale żadnego nie odzyskano!</B>"
		if(FUGITIVE_RESULT_FUGITIVE_VICTORY)
			result += "<span class='redtext big'>Zwycięstwo zbiegów</span>"
			result += "<B>Jeden ze zbiegów przeżył, a łowcy nie odzyskali żadnych ciał.</B>"
		if(FUGITIVE_RESULT_MAJOR_FUGITIVE)
			result += "<span class='redtext big'>Wielkie zwycięstwo zbiegów</span>"
			result += "<B>Wszyscy zbiegowie przeżyli i uniknęli schwytania!</B>"
		else //get_result returned null- either bugged or no fugitives showed
			result += "<span class='neutraltext big'>Głupi żart!</span>"
			result += "<B>Wezwano łowców, a zbiegów nie było...?</B>"

	result += "</div>"

	return result.Join("<br>")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive_hunter")

/datum/antagonist/fugitive_hunter/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
