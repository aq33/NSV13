// Wejście do samouczka z lobby i propozycja dla gracza, który łączy się pierwszy raz

/mob/dead/new_player
	/// Okno wyboru lekcji
	var/datum/tutorial_menu/tutorial_menu

/mob/dead/new_player/Destroy()
	QDEL_NULL(tutorial_menu)
	return ..()

/// Przycisk „Samouczek” w oknie lobby (LobbyMenu)
/mob/dead/new_player/ui_act(action, list/params)
	if(action == "tutorial")
		if(client && !client.interviewee)
			open_tutorial_menu()
		return TRUE
	return ..()

/// Czy można teraz zacząć lekcję. Z komunikatem dla gracza, jeśli nie
/mob/dead/new_player/proc/can_start_tutorial()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>Samouczek będzie dostępny po rozpoczęciu rundy.</span>")
		return FALSE
	if(SSticker.current_state > GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>Runda się skończyła. Samouczek będzie dostępny w następnej.</span>")
		return FALSE
	if(spawning || HAS_TRAIT(src, TRAIT_IN_TUTORIAL))
		to_chat(src, "<span class='warning'>Samouczek już się wczytuje.</span>")
		return FALSE
	return TRUE

/mob/dead/new_player/proc/open_tutorial_menu()
	if(!can_start_tutorial())
		return
	if(!tutorial_menu)
		tutorial_menu = new
	tutorial_menu.ui_interact(src)

/// Wołane z client/New(), gdy gracz łączy się z serwerem pierwszy raz
/client/proc/aquila_tutorial_first_connection()
	if(SSticker.current_state == GAME_STATE_PLAYING)
		addtimer(CALLBACK(src, PROC_REF(offer_tutorial)), 5 SECONDS) // klient musi najpierw wczytać okna TGUI
		return
	if(SSticker.current_state > GAME_STATE_PLAYING)
		return
	to_chat(src, "<span class='notice'><b>Witaj na Aquili!</b> Po rozpoczęciu rundy zaproponujemy Ci samouczek. Znajdziesz go też w lobby pod przyciskiem „Samouczek”.</span>")
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_tutorial_roundstart_offer), ckey))

/// Po starcie rundy proponuje samouczek nowemu graczowi, jeśli nadal jest w lobby
/proc/aquila_tutorial_roundstart_offer(player_ckey)
	UNTIL(SSticker.current_state >= GAME_STATE_PLAYING)
	sleep(5 SECONDS) // po starcie rundy lobby odświeża się graczom, okno nie powinno zniknąć pod nim
	var/client/player = GLOB.directory[player_ckey]
	player?.offer_tutorial()

/// Okno z propozycją samouczka
/client/proc/offer_tutorial()
	if(!isnewplayer(mob) || length(prefs?.get_completed_tutorials()))
		return
	var/choice = tgui_alert(mob, "Pierwszy raz na Aquili? Samouczek w kilka minut nauczy Cię sterowania, przetrwania na statku i tego, co robić podczas alarmu bojowego.", "Samouczek", list("Otwórz samouczek", "Nie teraz"))
	if(choice != "Otwórz samouczek" || !isnewplayer(mob))
		return
	var/mob/dead/new_player/lobby_mob = mob
	lobby_mob.open_tutorial_menu()
