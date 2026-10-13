/// Wspólny typ lekcji Aquili
/datum/tutorial/aquila
	parent_path = /datum/tutorial/aquila
	/// Zaryglowane drzwi między pomieszczeniami: nazwa = drzwi. Otwierają się po wykonaniu kroku
	var/list/gates = list()

/datum/tutorial/aquila/Destroy(force, ...)
	gates = null // drzwi kasuje rezerwacja razem z pokojem
	return ..()

/// Stawia zaryglowane drzwi w pomieszczeniu samouczka
/datum/tutorial/aquila/proc/add_gate(gate_id, offset_x, offset_y)
	gates[gate_id] = new /obj/machinery/door/airlock/public/glass/tutorial(loc_from_corner(offset_x, offset_y))

/// Odryglowuje i otwiera drzwi, gdy gracz może iść dalej
/datum/tutorial/aquila/proc/open_gate(gate_id)
	var/obj/machinery/door/airlock/door = gates[gate_id]
	if(QDELETED(door) || !door.locked)
		return
	door.unbolt()
	INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))

/datum/map_template/tutorial/aquila_basic
	name = "Samouczek: Podstawy"
	mappath = 'aquila/_maps/tutorial/aquila_basic.dmm'
	width = 13
	height = 11

/datum/outfit/aquila_tutorial/basic
	ears = /obj/item/radio/headset/munitions/tutorial
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/// Lekcja 1: sterowanie postacią
/datum/tutorial/aquila/basic
	name = "Podstawy"
	desc = "Sterowanie postacią: ruch, ręce, przedmioty, rzucanie, ciągnięcie, bieg, plecak, internale, walka i radio. Zacznij od tej lekcji, jeśli grasz pierwszy raz."
	tutorial_id = "aquila_basic_1"
	icon = "walking"
	order = 1
	tutorial_template = /datum/map_template/tutorial/aquila_basic
	outfit = /datum/outfit/aquila_tutorial/basic

// Układ pokoju (przesunięcia od lewego dolnego rogu podłogi): kajuta u góry z lewej,
// ciemny korytarz przez środek, magazyn u góry z prawej, sala na dole.
#define BASIC_CHAIR 1, 7
#define BASIC_CLOSET 0, 8
#define BASIC_CORRIDOR_SPOT 3, 4
#define BASIC_CAN 7, 7
#define BASIC_BIN 10, 8
#define BASIC_CRATE 5, 7
#define BASIC_CRATE_TARGET 9, 6
#define BASIC_HALL_SPOT 5, 1
#define BASIC_DUMMY 8, 1
#define BASIC_GATE_CABIN 1, 5
#define BASIC_GATE_STORAGE 6, 5
#define BASIC_GATE_HALL 5, 2
#define BASIC_WET_FROM_X 4
#define BASIC_WET_TO_X 7
#define BASIC_WET_FROM_Y 3
#define BASIC_WET_TO_Y 4

// Skrypt

/datum/tutorial/aquila/basic/start_tutorial(mob/dead/new_player/starting_mob)
	. = ..()
	if(!.)
		return

	init_mob()
	message_to_player("Witaj w samouczku Aquili! Polecenia zobaczysz tutaj, a bieżący cel także w panelu Status.")
	update_objective("Poczekaj na pierwsze polecenie.")
	addtimer(CALLBACK(src, PROC_REF(require_unbuckle)), 4 SECONDS)

// 1. Odpięcie z krzesła

/datum/tutorial/aquila/basic/proc/require_unbuckle()
	if(!tutorial_mob)
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/chair, chair)
	// Gracz mógł się odpiąć, zanim pojawiło się polecenie
	if(tutorial_mob.buckled != chair)
		require_swap_hands()
		return
	current_step = "unbuckle"
	message_to_player("Siedzisz przypięty pasami do krzesła. Odepnij się: kliknij krzesło albo naciśnij <b>[retrieve_bind("resist")]</b> (opór).")
	update_objective("Odepnij się od krzesła (klik na krzesło albo [retrieve_bind("resist")]).")
	add_highlight(chair)
	highlight_hud(/atom/movable/screen/resist)
	RegisterSignal(chair, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))

/datum/tutorial/aquila/basic/proc/on_unbuckle(datum/source, mob/living/unbuckled)
	SIGNAL_HANDLER

	if(unbuckled != tutorial_mob)
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/chair, chair)
	UnregisterSignal(chair, COMSIG_MOVABLE_UNBUCKLE)
	remove_highlight(chair)
	unhighlight_hud(/atom/movable/screen/resist)
	require_swap_hands()

// 2. Zmiana rąk

/datum/tutorial/aquila/basic/proc/require_swap_hands()
	current_step = "swap_hands"
	message_to_player("Masz dwie ręce, a używasz zawsze tej aktywnej (podświetlonej na dole ekranu). Zmień rękę klawiszem <b>[retrieve_bind("swap_hands")]</b>.")
	update_objective("Zmień aktywną rękę ([retrieve_bind("swap_hands")]).")
	highlight_hud(/atom/movable/screen/inventory/hand)
	RegisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_swap_hands))

/datum/tutorial/aquila/basic/proc/on_swap_hands(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS)
	unhighlight_hud(/atom/movable/screen/inventory/hand)
	require_flashlight()

// 3. Szafka i latarka: aktywacja w ręce

/datum/tutorial/aquila/basic/proc/require_flashlight()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet, closet)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/flashlight/tutorial, flashlight)
	current_step = "flashlight"
	message_to_player("Na korytarzu jest ciemno. Otwórz szafkę (kliknij ją), weź latarkę i włącz ją w ręce klawiszem <b>[retrieve_bind("activate_inhand")]</b>.")
	update_objective("Weź latarkę z szafki i włącz ją ([retrieve_bind("activate_inhand")]).")
	add_highlight(closet)
	add_highlight(flashlight)
	RegisterSignal(flashlight, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_flashlight_used))

/datum/tutorial/aquila/basic/proc/on_flashlight_used(datum/source, mob/user)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/flashlight/tutorial, flashlight)
	if(user != tutorial_mob || !flashlight.on)
		return
	UnregisterSignal(flashlight, COMSIG_TUTORIAL_ITEM_USED)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet, closet)
	remove_highlight(closet)
	remove_highlight(flashlight)
	require_corridor()

// 4. Ruch

/datum/tutorial/aquila/basic/proc/require_corridor()
	open_gate("cabin")
	var/turf/target = loc_from_corner(BASIC_CORRIDOR_SPOT)
	add_highlight(target)
	current_step = "corridor"
	message_to_player("Latarka świeci. Wyjdź na korytarz, na podświetlone pole. Chodzisz klawiszami <b>[retrieve_bind("move_north")]</b>, <b>[retrieve_bind("move_west")]</b>, <b>[retrieve_bind("move_south")]</b> i <b>[retrieve_bind("move_east")]</b>.")
	update_objective("Dojdź do podświetlonego pola na korytarzu.")
	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_corridor_move))

/datum/tutorial/aquila/basic/proc/on_corridor_move(datum/source)
	SIGNAL_HANDLER

	var/turf/target = loc_from_corner(BASIC_CORRIDOR_SPOT)
	if(get_turf(tutorial_mob) != target)
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED)
	remove_highlight(target)
	require_throw()

// 5. Rzut

/datum/tutorial/aquila/basic/proc/require_throw()
	open_gate("storage")
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/trash/can, can)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate/bin, bin)
	current_step = "throw"
	message_to_player("Drzwi do magazynu się otworzyły. Wejdź do niego, podnieś pustą puszkę, włącz rzucanie klawiszem <b>[retrieve_bind("toggle_throw_mode")]</b> i kliknij kosz, żeby do niego trafić. Gdy zechcesz coś po prostu odłożyć, upuścisz to klawiszem <b>[retrieve_bind("drop_item")]</b>.")
	update_objective("Rzuć pustą puszką w kosz ([retrieve_bind("toggle_throw_mode")], potem klik na kosz).")
	add_highlight(can)
	add_highlight(bin)
	add_highlight(get_turf(bin))
	highlight_hud(/atom/movable/screen/throw_catch)
	RegisterSignal(can, COMSIG_MOVABLE_IMPACT, PROC_REF(on_can_impact))
	RegisterSignal(can, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_can_landed))

/datum/tutorial/aquila/basic/proc/on_can_impact(datum/source, atom/hit_atom)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate/bin, bin)
	if(hit_atom != bin)
		return
	can_in_bin()

/datum/tutorial/aquila/basic/proc/on_can_landed(datum/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/trash/can, can)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate/bin, bin)
	// Puszka czasem odbija się od kosza i leci krótko, więc liczymy też lądowanie tuż przy koszu,
	// ale tylko po rzucie wymierzonym w kosz (a nie w podłogę obok niego)
	var/aimed_at_bin = throwing_datum && (throwing_datum.initial_target?.resolve() == bin || throwing_datum.target_turf == get_turf(bin))
	if(aimed_at_bin && get_dist(can, bin) <= 1)
		can_in_bin()
		return
	message_to_player("Pudło! Podnieś puszkę, podejdź bliżej i spróbuj jeszcze raz: <b>[retrieve_bind("toggle_throw_mode")]</b>, potem klik na kosz.")

/datum/tutorial/aquila/basic/proc/can_in_bin()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/trash/can, can)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate/bin, bin)
	UnregisterSignal(can, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_THROW_LANDED))
	remove_highlight(can)
	remove_highlight(bin)
	remove_highlight(get_turf(bin))
	unhighlight_hud(/atom/movable/screen/throw_catch)
	require_pull()

// 6. Ciągnięcie

/datum/tutorial/aquila/basic/proc/require_pull()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate, crate)
	var/turf/target = loc_from_corner(BASIC_CRATE_TARGET)
	current_step = "pull"
	message_to_player("Trafiony! Teraz zaciągnij skrzynię na podświetlone pole: <b>Ctrl+klik</b> na skrzynię zaczyna ciągnięcie, a <b>[retrieve_bind("stop_pulling")]</b> je kończy.")
	update_objective("Zaciągnij skrzynię na podświetlone pole (Ctrl+klik na skrzynię).")
	add_highlight(crate)
	add_highlight(target)
	highlight_hud(/atom/movable/screen/pull)
	RegisterSignal(crate, COMSIG_MOVABLE_MOVED, PROC_REF(on_crate_moved))

/datum/tutorial/aquila/basic/proc/on_crate_moved(datum/source)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate, crate)
	var/turf/target = loc_from_corner(BASIC_CRATE_TARGET)
	if(get_turf(crate) != target)
		return
	UnregisterSignal(crate, COMSIG_MOVABLE_MOVED)
	remove_highlight(crate)
	remove_highlight(target)
	unhighlight_hud(/atom/movable/screen/pull)
	tutorial_mob.stop_pulling()
	require_walk()

// 7. Chód i bieg

/datum/tutorial/aquila/basic/proc/require_walk()
	wet_corridor()
	open_gate("hall")
	current_step = "walk"
	message_to_player("Ktoś rozlał wodę na korytarzu. W biegu poślizgniesz się na mokrej podłodze, więc przełącz się na <b>chód</b> klawiszem <b>[retrieve_bind("toggle_move_intent")]</b>.")
	update_objective("Przełącz się na chód ([retrieve_bind("toggle_move_intent")]).")
	highlight_hud(/atom/movable/screen/mov_intent)
	if(tutorial_mob.m_intent == MOVE_INTENT_WALK)
		require_hall()
		return
	RegisterSignal(tutorial_mob, COMSIG_MOB_MOVE_INTENT_CHANGED, PROC_REF(on_walk))

/datum/tutorial/aquila/basic/proc/on_walk(datum/source, new_intent)
	SIGNAL_HANDLER

	if(new_intent != MOVE_INTENT_WALK)
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOB_MOVE_INTENT_CHANGED)
	require_hall()

/datum/tutorial/aquila/basic/proc/require_hall()
	unhighlight_hud(/atom/movable/screen/mov_intent)
	var/turf/target = loc_from_corner(BASIC_HALL_SPOT)
	add_highlight(target)
	current_step = "hall"
	message_to_player("Idąc spokojnie, przejdź przez mokry korytarz do sali na dole, na podświetlone pole.")
	update_objective("Przejdź chodem przez mokrą podłogę do sali.")
	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_hall_move))
	RegisterSignal(tutorial_mob, COMSIG_ADD_MOOD_EVENT, PROC_REF(on_mood_event))

/datum/tutorial/aquila/basic/proc/on_mood_event(datum/source, category)
	SIGNAL_HANDLER

	if(category != "slipped")
		return
	message_to_player("Poślizgnąłeś się! Na mokrej podłodze chodź, nie biegaj: <b>[retrieve_bind("toggle_move_intent")]</b> przełącza chód i bieg. Podnieś to, co upuściłeś, i idź dalej.")

/datum/tutorial/aquila/basic/proc/on_hall_move(datum/source)
	SIGNAL_HANDLER

	var/turf/target = loc_from_corner(BASIC_HALL_SPOT)
	if(get_turf(tutorial_mob) != target)
		return
	UnregisterSignal(tutorial_mob, list(COMSIG_MOVABLE_MOVED, COMSIG_ADD_MOOD_EVENT))
	remove_highlight(target)
	current_step = "run"
	message_to_player("Udało się. Na suchej podłodze możesz znów biegać: przełącz się z powrotem na <b>bieg</b> ([retrieve_bind("toggle_move_intent")]). Bieg męczy szybciej, co widać na wskaźniku staminy.")
	update_objective("Przełącz się z powrotem na bieg ([retrieve_bind("toggle_move_intent")]).")
	highlight_hud(/atom/movable/screen/mov_intent)
	if(tutorial_mob.m_intent == MOVE_INTENT_RUN)
		on_run_ready()
		return
	RegisterSignal(tutorial_mob, COMSIG_MOB_MOVE_INTENT_CHANGED, PROC_REF(on_run))

/datum/tutorial/aquila/basic/proc/on_run(datum/source, new_intent)
	SIGNAL_HANDLER

	if(new_intent != MOVE_INTENT_RUN)
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOB_MOVE_INTENT_CHANGED)
	on_run_ready()

/datum/tutorial/aquila/basic/proc/on_run_ready()
	unhighlight_hud(/atom/movable/screen/mov_intent)
	require_rest()

/// Mokra podłoga na korytarzu między magazynem a salą
/datum/tutorial/aquila/basic/proc/wet_corridor()
	for(var/x_offset in BASIC_WET_FROM_X to BASIC_WET_TO_X)
		for(var/y_offset in BASIC_WET_FROM_Y to BASIC_WET_TO_Y)
			var/turf/open/floor = loc_from_corner(x_offset, y_offset)
			if(istype(floor))
				// Czas musi być dodatni, inaczej komponent mokrej podłogi od razu się usuwa
				floor.MakeSlippery(TURF_WET_WATER, min_wet_time = MAXIMUM_WET_TIME, permanent = TRUE)

// 8. Kładzenie się

/datum/tutorial/aquila/basic/proc/require_rest()
	current_step = "rest"
	message_to_player("Połóż się klawiszem <b>[retrieve_bind("rest")]</b> albo przyciskiem odpoczynku. Leżąc trudniej cię trafić i możesz czołgać się pod stołami, ale ruszasz się wolno.")
	update_objective("Połóż się ([retrieve_bind("rest")]).")
	highlight_hud(/atom/movable/screen/rest)
	RegisterSignal(tutorial_mob, COMSIG_LIVING_RESTING_CHANGED, PROC_REF(on_rest))

/datum/tutorial/aquila/basic/proc/on_rest(datum/source, resting)
	SIGNAL_HANDLER

	if(!resting)
		return
	UnregisterSignal(tutorial_mob, COMSIG_LIVING_RESTING_CHANGED)
	current_step = "stand_up"
	message_to_player("Dobrze. Teraz wstań tym samym klawiszem: <b>[retrieve_bind("rest")]</b>.")
	update_objective("Wstań ([retrieve_bind("rest")]).")
	RegisterSignal(tutorial_mob, COMSIG_LIVING_RESTING_CHANGED, PROC_REF(on_stand_up))

/datum/tutorial/aquila/basic/proc/on_stand_up(datum/source, resting)
	SIGNAL_HANDLER

	if(resting)
		return
	UnregisterSignal(tutorial_mob, COMSIG_LIVING_RESTING_CHANGED)
	unhighlight_hud(/atom/movable/screen/rest)
	require_backpack()

// 9. Plecak

/datum/tutorial/aquila/basic/proc/require_backpack()
	current_step = "backpack"
	var/mob/living/carbon/student = tutorial_mob
	var/obj/item/storage/box/survival/box = locate() in student.back
	if(!box)
		describe_step("Na plecach masz plecak. Kliknij go, żeby go otworzyć, i wyjmij z niego, co potrzebujesz. Ciemne sloty na pasku ekwipunku to miejsca, w które teraz nic nie włożysz.", 10 SECONDS, PROC_REF(require_internals))
		return
	add_to_tracking_atoms(box)
	add_highlight(box)
	message_to_player("Na plecach masz plecak. Kliknij go, żeby go otworzyć, i wyjmij z niego <b>pudełko przetrwania</b>. Pojemniki otwierasz też <b>Alt+klik</b>. Ciemne sloty na pasku ekwipunku to miejsca, w które teraz nic nie włożysz.")
	update_objective("Otwórz plecak i wyjmij pudełko przetrwania.")
	RegisterSignal(box, COMSIG_ITEM_EQUIPPED, PROC_REF(on_box_taken))

/datum/tutorial/aquila/basic/proc/on_box_taken(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(equipper != tutorial_mob || slot != ITEM_SLOT_HANDS)
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/storage/box/survival, box)
	UnregisterSignal(box, COMSIG_ITEM_EQUIPPED)
	remove_highlight(box)
	require_internals()

// 10. Internale

/datum/tutorial/aquila/basic/proc/require_internals()
	current_step = "internals"
	var/mob/living/carbon/human/student = tutorial_mob
	if(student.dna?.species?.outfit_important_for_life || student.internal)
		describe_step("Twoja postać już oddycha z butli. Pamiętaj: internale to maska na twarzy i butla z powietrzem. Włączasz je przyciskiem butli na pasku akcji albo przyciskiem internali na HUD-zie.", 10 SECONDS, PROC_REF(require_combat))
		return
	message_to_player("Otwórz pudełko: <b>Alt+klik</b> na nim albo kliknij je, gdy trzymasz je w drugiej ręce (aktywna ręka musi być pusta). W środku jest maska i mała butla z tlenem. Załóż maskę (weź ją do ręki i naciśnij <b>[retrieve_bind("quick_equip")]</b>), schowaj butlę do kieszeni albo za pas i włącz internale przyciskiem butli na pasku akcji albo przyciskiem internali na HUD-zie.")
	update_objective("Otwórz pudełko (Alt+klik), załóż maskę, weź butlę i włącz internale.")
	highlight_hud(/atom/movable/screen/internals)
	RegisterSignal(tutorial_mob, COMSIG_CARBON_INTERNALS_CHANGED, PROC_REF(on_internals))

/datum/tutorial/aquila/basic/proc/on_internals(datum/source, internal_state)
	SIGNAL_HANDLER

	if(!internal_state)
		return
	UnregisterSignal(tutorial_mob, COMSIG_CARBON_INTERNALS_CHANGED)
	unhighlight_hud(/atom/movable/screen/internals)
	current_step = "internals_done"
	message_to_player("Oddychasz z butli. Przy rozszczelnieniu kadłuba to ratuje życie, a butla starcza na kilka minut. Wyłączysz ją tym samym przyciskiem.")
	addtimer(CALLBACK(src, PROC_REF(require_combat)), 7 SECONDS)

// 11. Intencje: pomoc i cios na manekinie

/datum/tutorial/aquila/basic/proc/require_combat()
	if(!tutorial_mob)
		return
	current_step = "help"
	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, dummy)
	message_to_player("Interakcje z ludźmi zależą od <b>intencji</b> (przycisk w prawym dolnym rogu HUD-u). Ustaw intencję <b>pomocy</b> (help, <b>[retrieve_bind("select_help_intent")]</b>) i kliknij manekina. Na help klik na kogoś to przyjazny gest: poklepanie, przytulenie, ratowanie z ognia.")
	update_objective("Na intencji help ([retrieve_bind("select_help_intent")]) kliknij manekina.")
	add_highlight(dummy)
	highlight_hud(/atom/movable/screen/act_intent)
	RegisterSignal(tutorial_mob, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_dummy_touched))

/datum/tutorial/aquila/basic/proc/on_dummy_touched(datum/source, atom/target)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, dummy)
	if(target != dummy)
		return
	switch(current_step)
		if("help")
			if(tutorial_mob.a_intent != INTENT_HELP)
				message_to_player("To nie była intencja pomocy. Przełącz na <b>help</b> ([retrieve_bind("select_help_intent")]) i kliknij manekina jeszcze raz.")
				return
			current_step = "harm"
			message_to_player("Tak wygląda przyjazny gest. Teraz przełącz na intencję <b>krzywdy</b> (harm, <b>[retrieve_bind("select_harm_intent")]</b>) i uderz manekina. Na harm każdy klik na kogoś to atak: pięścią albo przedmiotem z ręki.")
			update_objective("Na intencji harm ([retrieve_bind("select_harm_intent")]) uderz manekina.")
		if("harm")
			if(tutorial_mob.a_intent != INTENT_HARM)
				message_to_player("To nie był cios. Przełącz na <b>harm</b> ([retrieve_bind("select_harm_intent")]) i kliknij manekina.")
				return
			UnregisterSignal(tutorial_mob, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
			remove_highlight(dummy)
			unhighlight_hud(/atom/movable/screen/act_intent)
			current_step = "harm_done"
			message_to_player("Cios! Zapamiętaj różnicę: <b>help</b> to pomoc, <b>harm</b> to atak. Są jeszcze <b>disarm</b> (popchnięcie, wytrącenie broni) i <b>grab</b> (chwyt). Gdy nie walczysz, zawsze wracaj na <b>help</b>, żeby nikogo przypadkiem nie uderzyć.")
			update_objective("Wróć na intencję help ([retrieve_bind("select_help_intent")]).")
			addtimer(CALLBACK(src, PROC_REF(require_say)), 10 SECONDS)

// 12. Radio i kanały

/datum/tutorial/aquila/basic/proc/require_say()
	if(!tutorial_mob)
		return
	current_step = "say"
	message_to_player("Na koniec rozmowa. Powiedz coś normalnie: otwórz czat klawiszem <b>T</b> i napisz wiadomość. Usłyszą cię tylko osoby obok.")
	update_objective("Powiedz coś (T).")
	RegisterSignal(tutorial_mob, COMSIG_MOB_SAY, PROC_REF(on_say))

/datum/tutorial/aquila/basic/proc/on_say(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOB_SAY)
	current_step = "radio_common"
	var/obj/item/radio/headset/munitions/tutorial/headset = tutorial_mob.get_item_by_slot(ITEM_SLOT_EARS)
	if(!istype(headset))
		describe_step("Radio: z założonymi słuchawkami mówisz do całego statku, zaczynając wiadomość od <b>;</b>, a do swojego działu przez <b>:h</b>. W oknie czatu kanały radia przełączasz też klawiszem <b>TAB</b>.", 12 SECONDS, PROC_REF(finish))
		return
	add_to_tracking_atoms(headset)
	message_to_player("Masz słuchawki treningowe. Żeby powiedzieć coś przez radio do całej załogi, zacznij wiadomość od <b>;</b>, otwórz czat od razu na radiu klawiszem <b>Y</b> albo w oknie czatu wybierz kanał <b>Radio</b> klawiszem <b>TAB</b>.")
	update_objective("Powiedz coś przez radio (;, Y albo TAB w czacie).")
	RegisterSignal(headset, COMSIG_RADIO_MESSAGE, PROC_REF(on_radio_common))

/datum/tutorial/aquila/basic/proc/on_radio_common(datum/source, atom/movable/speaker, message, channel)
	SIGNAL_HANDLER

	if(speaker != tutorial_mob || (channel && channel != RADIO_CHANNEL_COMMON))
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/radio/headset/munitions/tutorial, headset)
	UnregisterSignal(headset, COMSIG_RADIO_MESSAGE)
	current_step = "radio_department"
	message_to_player("Teraz kanał działu. Te słuchawki mają kanał <b>[RADIO_CHANNEL_MUNITIONS]</b>. Otwórz czat klawiszem <b>T</b> i przełączaj kanały klawiszem <b>TAB</b>, aż przycisk kanału pokaże <b>[RADIO_CHANNEL_MUNITIONS]</b>, albo zacznij wiadomość od <b>:[RADIO_KEY_MUNITIONS]</b> (lub <b>:h</b>, czyli kanał twojego działu). Uwaga: w oknie otwartym na <b>Radio</b> prefiks działu nie działa, wiadomość pójdzie na kanał ogólny.")
	update_objective("Powiedz coś na kanale działu: T, potem TAB do kanału [RADIO_CHANNEL_MUNITIONS] albo :[RADIO_KEY_MUNITIONS] i wiadomość.")
	RegisterSignal(headset, COMSIG_RADIO_MESSAGE, PROC_REF(on_radio_department))

/datum/tutorial/aquila/basic/proc/on_radio_department(datum/source, atom/movable/speaker, message, channel)
	SIGNAL_HANDLER

	if(speaker != tutorial_mob)
		return
	if(!channel || channel == RADIO_CHANNEL_COMMON)
		message_to_player("To poszło na kanał <b>ogólny</b>. Otwórz zwykły czat klawiszem <b>T</b> (nie Y) i zacznij wiadomość od <b>:[RADIO_KEY_MUNITIONS]</b>.")
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/radio/headset/munitions/tutorial, headset)
	if(!headset.has_tutorial_channel(channel))
		message_to_player("Twoje słuchawki nie mają kanału <b>[channel]</b>. Użyj <b>:[RADIO_KEY_MUNITIONS]</b> ([RADIO_CHANNEL_MUNITIONS]) albo <b>:h</b>.")
		return
	UnregisterSignal(headset, COMSIG_RADIO_MESSAGE)
	finish()

/datum/tutorial/aquila/basic/proc/finish()
	if(!tutorial_mob)
		return
	current_step = "finished"
	message_to_player("Gratulacje, umiesz podstawy! Następna lekcja: <b>Przetrwanie</b>. Za chwilę wrócisz do lobby.")
	update_objective("")
	tutorial_end_in(8 SECONDS, TRUE)

// Pomocnicze

/// Krok, którego nie da się wykonać w pokoju samouczka: sam opis, a po chwili następny krok
/datum/tutorial/aquila/proc/describe_step(message, time = 10 SECONDS, next_step)
	message_to_player(message)
	update_objective("Przeczytaj opis. Samouczek sam przejdzie dalej.")
	addtimer(CALLBACK(src, next_step), time)

/// Podświetla element HUD-u gracza danego typu
/datum/tutorial/aquila/proc/highlight_hud(hud_type)
	for(var/atom/movable/screen/element in tutorial_mob?.client?.screen)
		if(istype(element, hud_type))
			add_highlight(element)

/datum/tutorial/aquila/proc/unhighlight_hud(hud_type)
	for(var/atom/movable/screen/element in tutorial_mob?.client?.screen)
		if(istype(element, hud_type))
			remove_highlight(element)

/datum/tutorial/aquila/basic/init_map()
	var/obj/structure/chair/chair = locate() in loc_from_corner(BASIC_CHAIR)
	if(chair)
		add_to_tracking_atoms(chair)
	var/obj/structure/closet/closet = locate() in loc_from_corner(BASIC_CLOSET)
	if(closet)
		add_to_tracking_atoms(closet)
		add_to_tracking_atoms(new /obj/item/flashlight/tutorial(closet))
	add_to_tracking_atoms(new /obj/item/trash/can(loc_from_corner(BASIC_CAN)))
	// Drzwi: kajuta, magazyn i sala otwierają się po kolejnych krokach
	add_gate("cabin", BASIC_GATE_CABIN)
	add_gate("storage", BASIC_GATE_STORAGE)
	add_gate("hall", BASIC_GATE_HALL)
	add_to_tracking_atoms(new /obj/structure/closet/crate/bin(loc_from_corner(BASIC_BIN)))
	add_to_tracking_atoms(new /obj/structure/closet/crate(loc_from_corner(BASIC_CRATE)))

	// Manekin do ćwiczenia intencji: nie da się go zranić ani zabić
	var/mob/living/carbon/human/dummy = new(loc_from_corner(BASIC_DUMMY))
	dummy.real_name = "Manekin treningowy"
	dummy.name = dummy.real_name
	dummy.status_flags |= GODMODE
	dummy.equipOutfit(/datum/outfit/aquila_tutorial)
	add_to_tracking_atoms(dummy)

/datum/tutorial/aquila/basic/init_mob()
	. = ..()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/chair, chair)
	if(!chair)
		return
	tutorial_mob.forceMove(get_turf(chair))
	chair.buckle_mob(tutorial_mob, TRUE)

#undef BASIC_CHAIR
#undef BASIC_CLOSET
#undef BASIC_CORRIDOR_SPOT
#undef BASIC_CAN
#undef BASIC_BIN
#undef BASIC_CRATE
#undef BASIC_CRATE_TARGET
#undef BASIC_HALL_SPOT
#undef BASIC_DUMMY
#undef BASIC_GATE_CABIN
#undef BASIC_GATE_STORAGE
#undef BASIC_GATE_HALL
#undef BASIC_WET_FROM_X
#undef BASIC_WET_TO_X
#undef BASIC_WET_FROM_Y
#undef BASIC_WET_TO_Y
