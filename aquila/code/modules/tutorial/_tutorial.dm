// Samouczek Aquili: rdzeń przeniesiony z cmss13-devs/cmss13#5030 wraz z poprawkami
// cmss13#5695 (abort przy braku rezerwacji), #5718 (ispath w menu), #5921 (mark_completed) i #11680 (podwójne kończenie).
// Różnice względem CM:
// - mapa ładuje się w naszej rezerwacji (RequestBlockReservation), landmark rogu szukamy tylko w tej rezerwacji;
// - koniec przy ghoście, wylogowaniu i śmierci idzie przez jeden timer (gracz wraca do lobby z ducha albo z ciała);
// - komunikaty przez napis na ekranie z tutorial_text.dm zamiast screen_text z CM.

GLOBAL_LIST_EMPTY_TYPED(ongoing_tutorials, /datum/tutorial)

/// Lekcja samouczka: co wczytać, jak przygotować gracza i skrypt kolejnych kroków
/datum/tutorial
	/// Nazwa widoczna dla gracza
	var/name = "Base"
	/// ID zapisywane w preferencjach. Nie zmieniać po wejściu na serwer
	var/tutorial_id = "base"
	/// Krótki opis w menu
	var/desc = ""
	/// Ikona FontAwesome w menu
	var/icon = ""
	/// Kolejność w menu
	var/order = 0
	/// tutorial_id lekcji, którą trzeba ukończyć wcześniej
	var/required_tutorial
	/// Najwyższy abstrakcyjny typ, pomijany w menu
	var/parent_path = /datum/tutorial
	/// Szablon mapy pokoju
	var/datum/map_template/tutorial/tutorial_template = /datum/map_template/tutorial
	/// Strój postaci gracza
	var/datum/outfit/outfit = /datum/outfit/aquila_tutorial

	/// Pierwsze pole podłogi w lewym dolnym rogu pokoju (landmark na mapie)
	var/turf/bottom_left_corner
	/// Rezerwacja kafli z pokojem
	var/datum/turf_reservation/reservation
	/// Gracz: najpierw mob z lobby, po init_mob() postać w pokoju
	var/mob/tutorial_mob
	/// ckey gracza, żeby po wylogowaniu albo ghoście znaleźć jego klienta
	var/tutorial_ckey
	/// Lekcja skończy się za chwilę (tutorial_end_in)
	var/tutorial_ending = FALSE
	/// end_tutorial() już się wykonał albo jest zaplanowany
	var/ending_scheduled = FALSE
	/// Śledzone obiekty, typ = obiekt. Jeden obiekt danego typu
	var/list/tracking_atoms = list()
	/// Nazwa akcji z keybindów = lista klawiszy
	var/list/player_bind_dict = list()
	/// Lekcja liczy się jako ukończona przy każdym wyjściu
	var/completion_marked = FALSE
	/// Napis z poleceniem na ekranie gracza
	var/atom/movable/screen/tutorial_text/screen_text
	/// Przycisk „Zakończ samouczek”
	var/datum/action/tutorial_end/end_action
	/// Bieżący krok skryptu (do podglądu w VV i do testów)
	var/current_step
	/// Znaczniki podświetlonych pól: pole = znacznik
	var/list/floor_markers = list()

/datum/tutorial/Destroy(force, ...)
	GLOB.ongoing_tutorials -= src
	if(tutorial_mob)
		UnregisterSignal(tutorial_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING, COMSIG_MOB_END_TUTORIAL))
	tutorial_mob = null // Postać kasuje rezerwacja razem z pokojem
	hide_screen_text()
	QDEL_NULL(screen_text)
	QDEL_NULL(end_action)
	QDEL_LIST_ASSOC_VAL(tracking_atoms)
	QDEL_LIST_ASSOC_VAL(floor_markers)
	QDEL_NULL(reservation)
	return ..()

/// Zaczyna lekcję dla gracza z lobby. Podtypy wołają ..(), sprawdzają wynik, a potem init_mob() i skrypt
/datum/tutorial/proc/start_tutorial(mob/dead/new_player/starting_mob)
	SHOULD_CALL_PARENT(TRUE)

	if(!starting_mob?.client)
		return FALSE

	ADD_TRAIT(starting_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)
	tutorial_mob = starting_mob
	tutorial_ckey = starting_mob.ckey

	// Rezerwacja i wczytywanie mogą chwilę potrwać, gracz mógł w tym czasie wyjść
	if(!setup_room() || !tutorial_mob?.client)
		abort_tutorial()
		return FALSE

	generate_binds()
	GLOB.ongoing_tutorials |= src
	init_map()
	if(!tutorial_mob)
		end_tutorial()
		return FALSE

	return TRUE

/// Rezerwuje kafle i wczytuje pokój. Bez gracza, więc da się to sprawdzić w teście
/datum/tutorial/proc/setup_room()
	var/width = initial(tutorial_template.width)
	var/height = initial(tutorial_template.height)
	reservation = SSmapping.RequestBlockReservation(width, height)
	if(!reservation)
		return FALSE

	var/turf/reservation_corner = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/datum/map_template/tutorial/template = new tutorial_template
	if(!template.load(reservation_corner))
		return FALSE

	// Landmark szukamy tylko w naszej rezerwacji, bo kilka lekcji może się ładować naraz
	for(var/turf/tile as anything in reserved_block())
		var/obj/effect/landmark/tutorial_bottom_left/landmark = locate() in tile
		if(landmark)
			bottom_left_corner = tile
			qdel(landmark)
			break

	return bottom_left_corner && verify_template_loaded()

/// Wszystkie kafle rezerwacji
/datum/tutorial/proc/reserved_block()
	RETURN_TYPE(/list)
	return block(
		locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3]),
		locate(reservation.top_right_coords[1], reservation.top_right_coords[2], reservation.top_right_coords[3]),
	)

/// Szablon czasem nie wczytuje się w całości (zostają kafle kosmosu), wtedy przerywamy
/datum/tutorial/proc/verify_template_loaded()
	for(var/turf/tile as anything in reserved_block())
		if(isspaceturf(tile))
			return FALSE
	return TRUE

/// Coś poszło nie tak przy ładowaniu
/datum/tutorial/proc/abort_tutorial()
	to_chat(tutorial_mob, "<span class='boldwarning'>Nie udało się wczytać samouczka. Spróbuj ponownie.</span>")
	end_tutorial(FALSE)

/// Kończy lekcję: zapisuje ukończenie, odsyła gracza do lobby i kasuje pokój
/datum/tutorial/proc/end_tutorial(completed = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(QDELETED(src))
		return
	ending_scheduled = TRUE
	var/mob/old_tutorial_mob = tutorial_mob
	// Czyścimy od razu, żeby wylogowanie przy przenoszeniu do lobby nie zakończyło lekcji drugi raz (cmss13#11680)
	tutorial_mob = null
	if(old_tutorial_mob)
		UnregisterSignal(old_tutorial_mob, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING, COMSIG_MOB_END_TUTORIAL))
		end_action?.Remove(old_tutorial_mob)
		hide_screen_text(old_tutorial_mob)
		REMOVE_TRAIT(old_tutorial_mob, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)

	var/client/player = GLOB.directory[tutorial_ckey]
	if(player?.prefs && (completed || completion_marked))
		var/list/completed_tutorials = player.prefs.get_completed_tutorials()
		if(!(tutorial_id in completed_tutorials))
			completed_tutorials += tutorial_id
			player.prefs.save_preferences()

	if(old_tutorial_mob && !isnewplayer(old_tutorial_mob))
		send_to_lobby(old_tutorial_mob)
	// Klient mógł być w duchu, więc napis zdejmujemy z niego bezpośrednio
	if(player && screen_text)
		player.screen -= screen_text

	if(!QDELETED(src))
		qdel(src)

/// Przenosi gracza z postaci w samouczku (albo z ducha, w którego się zamienił) z powrotem do lobby
/datum/tutorial/proc/send_to_lobby(mob/old_tutorial_mob)
	var/client/player = GLOB.directory[tutorial_ckey]
	var/mob/dead/observer/ghost = isobserver(player?.mob) ? player.mob : null

	var/mob/dead/new_player/lobby_mob = new()
	var/datum/mind/mind = old_tutorial_mob.mind
	if(mind)
		mind.transfer_to(lobby_mob, TRUE)
	else if(player)
		lobby_mob.key = player.key

	if(ghost && !ghost.client)
		qdel(ghost)

/// Kończy lekcję w następnym ticku. Z sygnałów, żeby ghostize() i death() zdążyły się wykonać do końca
/datum/tutorial/proc/schedule_end(completed = FALSE)
	if(ending_scheduled)
		return
	ending_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_tutorial), completed), 1)

/// Kończy lekcję po czasie. Przy completed = TRUE od razu liczy ją jako ukończoną
/datum/tutorial/proc/tutorial_end_in(time = 5 SECONDS, completed = TRUE)
	if(completed)
		mark_completed() // Gracz nie traci ukończenia, jeśli wyjdzie w tych ostatnich sekundach
	tutorial_ending = TRUE
	addtimer(CALLBACK(src, PROC_REF(end_tutorial), completed), time)

/// Każde wyjście z lekcji będzie ją liczyć jako ukończoną
/datum/tutorial/proc/mark_completed()
	completion_marked = TRUE

/// Spawn obiektów potrzebnych od początku lekcji
/datum/tutorial/proc/init_map()
	return

/// Tworzy postać gracza w pokoju i przenosi go do niej. Podtypy wołają to w start_tutorial()
/datum/tutorial/proc/init_mob()
	var/mob/dead/new_player/lobby_mob = tutorial_mob
	var/mob/living/carbon/human/character = new(bottom_left_corner)
	// Trait przed przeniesieniem gracza, żeby dynamic nie liczył go jako żywego gracza
	ADD_TRAIT(character, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)
	lobby_mob.client.prefs.active_character.copy_to(character)
	// Zawsze człowiek: samouczek uczy podstaw, a np. plazmamen w zwykłym powietrzu by spłonął
	if(!ishumanbasic(character))
		character.set_species(/datum/species/human)
	character.dna.update_dna_identity()
	if(outfit)
		character.equipOutfit(outfit)

	lobby_mob.close_spawn_windows()
	lobby_mob.spawning = TRUE
	if(!lobby_mob.mind)
		lobby_mob.mind_initialize()
	lobby_mob.mind.transfer_to(character, TRUE)
	character.stop_sound_channel(CHANNEL_LOBBYMUSIC)
	qdel(lobby_mob)

	tutorial_mob = character
	RegisterSignal(character, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	RegisterSignal(character, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING, COMSIG_MOB_END_TUTORIAL), PROC_REF(signal_end_tutorial))
	character.AddComponent(/datum/component/tutorial_status, src)
	end_action = new(src)
	end_action.Grant(character)
	show_screen_text()

/// Wylogowanie i ghost (klient przechodzi do ducha) kończą lekcję
/datum/tutorial/proc/on_logout(datum/source)
	SIGNAL_HANDLER

	if(!tutorial_mob)
		return
	var/mob/living/living_mob = tutorial_mob
	if(copytext(living_mob.key, 1, 2) == "@") // aghost admina
		return
	schedule_end(FALSE)

/// Do sygnałów, które kończą lekcję (śmierć, skasowanie postaci)
/datum/tutorial/proc/signal_end_tutorial(datum/source)
	SIGNAL_HANDLER

	schedule_end(FALSE)

/// Pole przesunięte od lewego dolnego rogu podłogi
/datum/tutorial/proc/loc_from_corner(offset_x = 0, offset_y = 0)
	RETURN_TYPE(/turf)
	return locate(bottom_left_corner.x + offset_x, bottom_left_corner.y + offset_y, bottom_left_corner.z)

/datum/tutorial/proc/add_to_tracking_atoms(atom/reference)
	tracking_atoms[reference.type] = reference

/datum/tutorial/proc/remove_from_tracking_atoms(atom/reference)
	tracking_atoms -= reference.type

/// Żółty obrys wokół obiektu albo przycisku HUD-u. Pole podłogi dostaje znacznik widoczny także w ciemności
/datum/tutorial/proc/add_highlight(atom/target, color = "#d19a02")
	if(isturf(target))
		if(!floor_markers[target])
			floor_markers[target] = new /obj/effect/tutorial_marker(target)
		return
	target.add_filter("tutorial_highlight", 2, list("type" = "outline", "color" = color, "size" = 1))

/datum/tutorial/proc/remove_highlight(atom/target)
	if(isturf(target))
		var/obj/effect/tutorial_marker/marker = floor_markers[target]
		floor_markers -= target
		qdel(marker)
		return
	target.remove_filter("tutorial_highlight")

/// Polecenie dla gracza: dźwięk, napis na ekranie i czat
/datum/tutorial/proc/message_to_player(message)
	if(!tutorial_mob)
		return
	SEND_SOUND(tutorial_mob, sound('sound/misc/notice2.ogg', volume = 30))
	show_screen_text(message)
	to_chat(tutorial_mob, "<span class='notice'><b>Samouczek:</b> [message]</span>")

/// Krótki cel w panelu Status
/datum/tutorial/proc/update_objective(message)
	if(tutorial_mob)
		SEND_SIGNAL(tutorial_mob, COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE, message)

/datum/tutorial/proc/show_screen_text(message)
	var/client/player = tutorial_mob?.client
	if(!player)
		return
	if(!screen_text)
		screen_text = new
	if(!isnull(message))
		screen_text.set_text(message)
	player.screen |= screen_text

/datum/tutorial/proc/hide_screen_text(mob/target = tutorial_mob)
	if(screen_text && target?.client)
		target.client.screen -= screen_text

/// Słownik nazwa akcji = klawisze, odwrotność prefs.key_bindings (klawisz = akcje)
/datum/tutorial/proc/generate_binds()
	var/list/key_bindings = tutorial_mob?.client?.prefs?.key_bindings
	if(!length(key_bindings))
		return
	for(var/key in key_bindings)
		for(var/action_name in key_bindings[key])
			LAZYADD(player_bind_dict[action_name], key)

/// Klawisz przypisany do akcji, np. retrieve_bind("swap_hands") = "X"
/datum/tutorial/proc/retrieve_bind(action_name)
	var/list/keys = player_bind_dict[action_name]
	if(!length(keys))
		return "(brak klawisza)"
	return keys[1]

/// Przycisk akcji „Zakończ samouczek”
/datum/action/tutorial_end
	name = "Zakończ samouczek"
	desc = "Wróć do lobby. Postęp tej lekcji przepadnie."
	icon_icon = 'icons/mob/actions/actions_vr.dmi'
	button_icon_state = "logout"
	/// Lekcja, którą przycisk kończy
	var/datum/weakref/tutorial

/datum/action/tutorial_end/New(datum/tutorial/selected_tutorial)
	. = ..(null)
	tutorial = WEAKREF(selected_tutorial)

/datum/action/tutorial_end/Trigger()
	. = ..()
	if(!.)
		return
	var/datum/tutorial/selected_tutorial = tutorial?.resolve()
	if(!selected_tutorial || selected_tutorial.tutorial_ending || selected_tutorial.ending_scheduled)
		return
	if(tgui_alert(owner, "Wrócić do lobby? Postęp tej lekcji przepadnie.", "Samouczek", list("Wróć do lobby", "Zostań")) != "Wróć do lobby")
		return
	if(QDELETED(selected_tutorial) || selected_tutorial.ending_scheduled)
		return
	selected_tutorial.end_tutorial(FALSE)

/// Strój postaci w samouczku: mundur załogi Aquili, bez karty i dostępu
/datum/outfit/aquila_tutorial
	name = "Samouczek Aquili"
	uniform = /obj/item/clothing/under/ship/marine
	shoes = /obj/item/clothing/shoes/jackboots

/// Obszar pokoi samouczka
/area/aquila_tutorial
	name = "Samouczek"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	area_flags = HIDDEN_AREA | UNIQUE_AREA | BLOCK_SUICIDE
	teleport_restriction = TELEPORT_ALLOW_NONE

/// Znacznik pola, na które ma dojść gracz albo trafić przedmiot. Nad oświetleniem, więc widać go w ciemności
/obj/effect/tutorial_marker
	name = "cel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "launchpad_target"
	color = "#ffd23f"
	plane = ABOVE_LIGHTING_PLANE
	layer = ABOVE_LIGHTING_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/// Lewy dolny róg podłogi pokoju samouczka
/obj/effect/landmark/tutorial_bottom_left
	name = "tutorial bottom left"

/// Szablony pokoi samouczka
/datum/map_template/tutorial
	name = "Samouczek"
	width = 0
	height = 0
