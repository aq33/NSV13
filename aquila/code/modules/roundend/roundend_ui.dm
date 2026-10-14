// AQUILA - raport końca rundy i ranking zarobków w oknach TGUI zamiast surowego HTML
// Stary raport HTML dalej zapisuje się do pliku, z którego czyta "Pokaż poprzedni raport".

/// Sekcje raportu z build_roundend_report(): lista list(tytuł, html)
GLOBAL_LIST_EMPTY(roundend_report_sections)
/// Statystyki przetrwania z końca rundy (popcount z declare_completion)
GLOBAL_LIST_EMPTY(roundend_popcount)
/// ckey => dane osobiste gracza z chwili końca rundy
GLOBAL_LIST_EMPTY(roundend_personal_data)
GLOBAL_DATUM_INIT(roundend_report_ui, /datum/roundend_report_ui, new)
GLOBAL_DATUM_INIT(economy_leaderboard_ui, /datum/economy_leaderboard_ui, new)

/datum/controller/subsystem/ticker/display_report(popcount)
	GLOB.roundend_popcount = popcount
	return ..()

/datum/controller/subsystem/ticker/show_roundend_report(client/C, previous = FALSE)
	if(previous || !C)
		return ..()
	// HTML do pliku, żeby w następnej rundzie dało się otworzyć poprzedni raport
	var/filename = C.roundend_report_file()
	var/list/report_parts = list(personal_report(C), GLOB.common_report)
	C.remove_verb(/client/proc/show_previous_roundend_report)
	fdel(filename)
	rustg_file_append(report_parts.Join(), filename)

	// wynik zapamiętany raz - przycisk raportu można kliknąć później, już jako duch
	if(!GLOB.roundend_personal_data[C.ckey])
		GLOB.roundend_personal_data[C.ckey] = roundend_personal_data(C)
	GLOB.roundend_report_ui.ui_interact(C.mob)

/// Wynik gracza: przeżył, ewakuował się, utknął, zginął
/datum/controller/subsystem/ticker/proc/roundend_personal_data(client/C)
	var/list/data = list("status" = "observer", "name" = null, "objectives" = list())
	var/mob/M = C.mob
	if(!M?.mind || isnewplayer(M))
		return data
	data["name"] = M.real_name
	if(M.stat == DEAD || isbrain(M))
		data["status"] = "dead"
	else if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		data["status"] = (M.onCentCom() || M.onSyndieBase()) ? "escaped" : "marooned"
	else
		data["status"] = GLOB.crew_transfer_risa ? "transfer" : "survived"

	if(CONFIG_GET(flag/allow_crew_objectives) && M.mind.current)
		var/list/objectives = list()
		for(var/datum/objective/crew/crew_objective as anything in M.mind.crew_objectives)
			objectives += list(list("text" = crew_objective.explanation_text, "success" = crew_objective.check_completion()))
		data["objectives"] = objectives
	return data

/datum/roundend_report_ui

/datum/roundend_report_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/roundend_report_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoundEndReport")
		ui.open()

/datum/roundend_report_ui/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = station_name()
	data["round_id"] = GLOB.round_id
	data["personal"] = GLOB.roundend_personal_data[user.ckey] || list("status" = "observer", "objectives" = list())
	data["stats"] = roundend_stats()
	data["mission"] = roundend_mission()

	var/list/sections = list()
	for(var/list/section as anything in GLOB.roundend_report_sections)
		sections += list(list("title" = section[1], "html" = section[2]))
	data["sections"] = sections

	var/list/earnings = list()
	for(var/list/result as anything in sortTim(GLOB.economy_round_results.Copy(), GLOBAL_PROC_REF(cmp_economy_result_balance)))
		earnings += list(result)
	data["earnings"] = earnings
	data["leaderboard"] = GLOB.economy_leaderboard
	data["my_ckey"] = user.ckey
	return data

/datum/roundend_report_ui/proc/roundend_stats()
	var/list/popcount = GLOB.roundend_popcount
	var/total_players = length(GLOB.joined_player_list)
	var/list/stats = list(
		"duration" = DisplayTimeText(world.time - SSticker.round_start_time),
		"integrity" = SSticker.mode?.station_was_nuked ? -1 : (popcount?["station_integrity"] || 0),
		"crew" = total_players,
		"evacuated" = EMERGENCY_ESCAPED_OR_ENDGAMED,
		"escapees" = popcount?[POPCOUNT_ESCAPEES] || 0,
		"shuttle_escapees" = popcount?[POPCOUNT_SHUTTLE_ESCAPEES] || 0,
		"survivors" = popcount?[POPCOUNT_SURVIVORS] || 0,
	)
	var/list/first_death = SSblackbox.first_death
	if(length(first_death))
		stats["first_death"] = list(
			"name" = first_death["name"],
			"role" = first_death["role"],
			"area" = first_death["area"],
			"damage" = first_death["damage"],
			"last_words" = first_death["last_words"],
		)
	return stats

/// Misja NSV: cele z trybu overmapy i czy załoga wygrała
/datum/roundend_report_ui/proc/roundend_mission()
	var/datum/overmap_gamemode/mode = SSovermap_mode?.mode
	if(!mode)
		return null
	var/list/objectives = list()
	var/completed = 0
	var/victory_override = FALSE
	for(var/datum/overmap_objective/objective as anything in mode.objectives)
		var/done = (objective.status == 1 || objective.status == 3)
		objectives += list(list("text" = objective.brief, "success" = done))
		if(objective.status == 3)
			victory_override = TRUE
		else if(objective.status == 1)
			completed++
	return list(
		"name" = mode.name,
		"faction" = capitalize(mode.starting_faction),
		"objectives" = objectives,
		"won" = victory_override || completed >= length(mode.objectives),
	)

/// Okno rankingu zarobków wszech czasów
/datum/economy_leaderboard_ui

/datum/economy_leaderboard_ui/ui_state(mob/user)
	return GLOB.always_state

/datum/economy_leaderboard_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EconomyLeaderboard")
		ui.open()

/datum/economy_leaderboard_ui/ui_static_data(mob/user)
	return list(
		"leaderboard" = GLOB.economy_leaderboard,
		"my_ckey" = user.ckey,
	)
