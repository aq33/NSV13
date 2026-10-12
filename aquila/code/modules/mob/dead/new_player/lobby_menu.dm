// Okno startowe w lobby w TGUI (zamiast HTML z new_player_panel() w code/modules/mob/dead/new_player/new_player.dm).
// Przyciski idą przez dawny Topic(), więc gotowość, obserwowanie, późne dołączanie i ankiety działają jak wcześniej.

/mob/dead/new_player
	/// Czy gracz ma nowe ankiety w bazie (sprawdzane przy otwieraniu okna, bo to zapytanie do bazy)
	var/lobby_new_polls = FALSE
	/// Czy w ogóle pokazywać ankiety (gracz z kontem i działająca baza)
	var/lobby_polls_available = FALSE

/mob/dead/new_player/new_player_panel()
	if(client?.interviewee)
		return
	// Zasoby lobby jak w dawnym oknie (korzystają z nich też inne okna lobby)
	var/datum/asset/asset_datum = get_asset_datum(/datum/asset/simple/lobby)
	asset_datum.send(client)
	lobby_check_polls()
	if(QDELETED(src))
		return
	ui_interact(src)

/// Zapytanie o ankiety jak w dawnym oknie: są w bazie i gracz jeszcze na nie nie odpowiedział
/mob/dead/new_player/proc/lobby_check_polls()
	lobby_polls_available = FALSE
	lobby_new_polls = FALSE
	if(IS_GUEST_KEY(key) || !SSdbcore.Connect())
		return
	lobby_polls_available = TRUE
	var/datum/DBQuery/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = !!client?.holder, "ckey" = ckey))
	if(query_get_new_polls.Execute() && query_get_new_polls.NextRow())
		lobby_new_polls = TRUE
	qdel(query_get_new_polls)

/mob/dead/new_player/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LobbyMenu", "Witaj na Aquila Station!")
		ui.open()

/mob/dead/new_player/ui_state(mob/user)
	return GLOB.always_state

/mob/dead/new_player/ui_status(mob/user, datum/ui_state/state)
	return user == src ? UI_INTERACTIVE : UI_CLOSE

/mob/dead/new_player/ui_data(mob/user)
	var/list/data = list()
	data["pregame"] = SSticker.current_state <= GAME_STATE_PREGAME
	data["ready"] = ready
	data["polls"] = lobby_polls_available
	data["new_polls"] = lobby_new_polls
	return data

/mob/dead/new_player/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("preferences")
			Topic(null, list("show_preferences" = 1))
		if("ready")
			var/new_ready = text2num(params["ready"])
			if(!(new_ready in list(PLAYER_NOT_READY, PLAYER_READY_TO_PLAY, PLAYER_READY_TO_OBSERVE)))
				return
			Topic(null, list("ready" = new_ready))
		if("manifest")
			Topic(null, list("manifest" = 1))
		if("late_join")
			Topic(null, list("late_join" = 1))
		if("polls")
			Topic(null, list("showpoll" = 1))
		else
			return
	return TRUE

/mob/dead/new_player/close_spawn_windows()
	. = ..()
	SStgui.close_uis(src)
