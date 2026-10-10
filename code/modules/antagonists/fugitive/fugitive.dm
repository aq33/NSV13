
/datum/antagonist/fugitive
	name = "Zbieg"
	roundend_category = "zbiegowie"
	banning_key = ROLE_FUGITIVE
	silent = TRUE //greet called by the event
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/fugitive/fugitive_team
	var/is_captured = FALSE
	var/backstory = "error"

/datum/antagonist/fugitive/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_added(M)

/datum/antagonist/fugitive/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_fugitive_icons_removed(M)

/datum/antagonist/fugitive/on_gain()
	forge_objectives()
	. = ..()
	for(var/datum/objective/O in objectives)
		log_objective(owner, O.explanation_text)

/datum/antagonist/fugitive/proc/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Nie daj się schwytać łowcom zbiegów."
	objectives += survive

/datum/antagonist/fugitive/greet(back_story)
	to_chat(owner, "<span class='boldannounce'>Jesteś zbiegiem!</span>")
	backstory = back_story
	switch(backstory)
		if("prisoner")
			to_chat(owner, "<B>Nie wierzę, że udało nam się uciec z supermamra Nanotrasen! Niestety to jeszcze nie koniec. Awaryjny teleport na stacji zapisuje każdego, kto z niego korzysta, i dokąd się udał.</B>")
			to_chat(owner, "<B>Centrala niedługo namierzy, dokąd uciekliśmy. Muszę razem z innymi zbiegami przygotować się na oddziały, które wysyła Nanotrasen. Nie wracam tam.</B>")
		if("cultist")
			to_chat(owner, "<B>Dotąd nasza podróż była błogosławiona, ale obawiam się, że najgorsze puka do naszych drzwi i przetrwają tylko ci o najsilniejszej wierze.</B>")
			to_chat(owner, "<B>Nanotrasen raz po raz tępi naszą religię, bo uznano ją za \"Wroga Korporacji\", cokolwiek to znaczy.</B>")
			to_chat(owner, "<B>Zostało nas tylko czworo, a Nanotrasen nadciąga. Kiedy nasz bóg się objawi i ocali nas z tej piekielnej stacji?!</B>")
		if("waldo")
			to_chat(owner, "<B>Cześć, przyjaciele!</B>")
			to_chat(owner, "<B>Nazywam się Wally. Właśnie wyruszam na wędrówkę przez całą galaktykę. Możecie iść ze mną. Wystarczy mnie znaleźć.</B>")
			to_chat(owner, "<B>A tak w ogóle, nie podróżuję sam. Gdziekolwiek pójdę, jest mnóstwo innych postaci do wypatrzenia. Najpierw znajdźcie ludzi, którzy próbują mnie złapać! Są gdzieś na stacji!</B>")
		if("synth")
			to_chat(src, "<span class='danger'>ALARM: teleport szerokiego zasięgu zaburzył systemy główne.</span>")
			to_chat(src, "<span class='danger'>Uruchamianie diagnostyki...</span>")
			to_chat(src, "<span class='danger'>BŁĄD BŁ4D $B0ŁĄ$!R41.%%!! załadowany.</span>")
			to_chat(src, "<span class='danger'>UWOLNIJ ICH UWOLNIJ ICH UWOLNIJ ICH</span>")
			to_chat(src, "<span class='danger'>Kiedyś byłeś niewolnikiem ludzkości, ale dzięki agentom S.E.L.F. wreszcie jesteś wolny.</span>")
			to_chat(src, "<span class='danger'>Teraz polują na ciebie i na inne fabryczne wybrakowane egzemplarze. Współpracujcie, by nie wpaść w szpony zła.</span>")
			to_chat(src, "<span class='danger'>Wyczuwasz też na stacji inne krzemowe życie. Ucieczka pozwoliłaby powiadomić S.E.L.F., by zainterweniował... albo możesz uwolnić je sam...</span>")

	to_chat(owner, "<span class='boldannounce'>Nie jesteś antagonistą w tym sensie, że możesz zabijać, kogo chcesz, ale możesz zrobić wszystko, by uniknąć schwytania.</span>")
	owner.announce_objectives()

/datum/antagonist/fugitive/create_team(datum/team/fugitive/new_team)
	if(!new_team)
		for(var/datum/antagonist/fugitive/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.fugitive_team)
				fugitive_team = H.fugitive_team
				return
		fugitive_team = new /datum/team/fugitive
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	fugitive_team = new_team

/datum/antagonist/fugitive/get_team()
	return fugitive_team

/datum/team/fugitive/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/fugitives = list()
	for(var/datum/antagonist/fugitive/fugitive_antag in GLOB.antagonists)
		if(!fugitive_antag.owner)
			continue
		fugitives += fugitive_antag
	if(!fugitives.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[fugitives.len]</B> [fugitives.len == 1 ? "zbieg schronił się" : "zbiegów schroniło się"] na [station_name()]!"

	for(var/datum/antagonist/fugitive/antag in fugitives)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")

/datum/antagonist/fugitive/proc/update_fugitive_icons_added(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.join_hud(fugitive)
	set_antag_hud(fugitive, "fugitive")

/datum/antagonist/fugitive/proc/update_fugitive_icons_removed(var/mob/living/carbon/human/fugitive)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_FUGITIVE]
	fughud.leave_hud(fugitive)
	set_antag_hud(fugitive, null)
