/datum/map_template/tutorial/aquila_gq
	name = "Samouczek: Alarm bojowy"
	mappath = 'aquila/_maps/tutorial/aquila_gq.dmm'
	width = 16
	height = 12

/// Lekcja 3: alarm bojowy (General Quarters), skład, wyposażenie, strzelanie i działo Gaussa
/datum/tutorial/aquila/general_quarters
	name = "Alarm bojowy"
	desc = "Co robić, gdy na statku ogłoszą alarm bojowy (General Quarters): pager i składy, wyposażenie z vendora, strzelanie i obsługa działa Gaussa."
	tutorial_id = "aquila_gq_1"
	icon = "crosshairs"
	order = 3
	tutorial_template = /datum/map_template/tutorial/aquila_gq
	/// Cele na strzelnicy, które jeszcze nie zostały trafione
	var/list/targets_left = list()
	/// Gracz dostał już podpowiedź o niezaładowanym luźnym pocisku
	var/loose_round_hint_given = FALSE

// Układ (przesunięcia od lewego dolnego rogu podłogi): kwatera z koją i vendorem u góry z lewej,
// stanowisko Gaussa u góry z prawej, strzelnica na dole.
#define GQ_BED 1, 8
#define GQ_PAGER 2, 8
#define GQ_VENDOR 3, 9
#define GQ_MAG_TABLE 1, 2
#define GQ_GUN 9, 10
#define GQ_CHAIR 9, 6
#define GQ_RACK 9, 5
#define GQ_CRATE 7, 6
#define GQ_LOOSE_ROUND 6, 5
/// Ile pocisków jest w skrzyni (plus jeden luzem)
#define GQ_CRATE_ROUNDS 4

// Skrypt

/datum/tutorial/aquila/general_quarters/start_tutorial(mob/dead/new_player/starting_mob)
	. = ..()
	if(!.)
		return

	init_mob()
	message_to_player("Lekcja „Alarm bojowy”. Śpisz w swojej koi na Aquili. Za chwilę zabrzmi alarm.")
	update_objective("Poczekaj na alarm.")
	addtimer(CALLBACK(src, PROC_REF(start_general_quarters)), 6 SECONDS)

// 1. Ogłoszenie alarmu

/datum/tutorial/aquila/general_quarters/proc/start_general_quarters()
	if(!tutorial_mob)
		return
	current_step = "gq"
	// Tylko dla gracza: poziom alarmu statku się nie zmienia
	SEND_SOUND(tutorial_mob, sound('nsv13/sound/effects/ship/action_stations.ogg', volume = 60))
	to_chat(tutorial_mob, "<h1 class='alert'>Attention! General Quarters!</h1><br><span class='alert'>Wszyscy na stanowiska bojowe. To są ćwiczenia.</span>")
	message_to_player("Ogłoszono <b>alarm bojowy</b> (General Quarters). Statek szykuje się do walki, a każdy ma swoje zadanie. Wstań z koi: kliknij ją albo naciśnij <b>[retrieve_bind("resist")]</b>.")
	update_objective("Wstań z koi.")
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/bed, bed)
	add_highlight(bed)
	RegisterSignal(bed, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_bed_left))

/datum/tutorial/aquila/general_quarters/proc/on_bed_left(datum/source, mob/living/unbuckled)
	SIGNAL_HANDLER

	if(unbuckled != tutorial_mob)
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/bed, bed)
	UnregisterSignal(bed, COMSIG_MOVABLE_UNBUCKLE)
	remove_highlight(bed)
	require_pager()

// 2. Pager i składy

/datum/tutorial/aquila/general_quarters/proc/require_pager()
	current_step = "pager"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/squad_pager/tutorial, pager)
	pager.add_tutorial_message("Alarm bojowy! Skład Able: do vendora składu po wyposażenie, potem na strzelnicę i do działa Gaussa.")
	message_to_player("Przy koi leży twój <b>pager składu</b>. Podnieś go i przeczytaj rozkaz: aktywuj go w ręce klawiszem <b>[retrieve_bind("activate_inhand")]</b>.")
	update_objective("Podnieś pager i przeczytaj rozkaz ([retrieve_bind("activate_inhand")]).")
	add_highlight(pager)
	RegisterSignal(pager, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_pager_read))

/datum/tutorial/aquila/general_quarters/proc/on_pager_read(datum/source, mob/user)
	SIGNAL_HANDLER

	if(user != tutorial_mob)
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/squad_pager/tutorial, pager)
	UnregisterSignal(pager, COMSIG_TUTORIAL_ITEM_USED)
	remove_highlight(pager)
	current_step = "squads"
	describe_step("Na Aquili załoga bez stanowiska bojowego trafia do <b>składów</b>. <b>Able</b> i <b>Charlie</b> naprawiają statek i łatają wyłomy, <b>Baker</b> to skład medyczny, a <b>Duff</b> pomaga przy amunicji. Kolor składu widać na hełmie i w HUD-zie. Składy przydziela XO na swojej konsoli, a rozkazy dowódcy przychodzą na pager. Pager trzymaj przy sobie, najlepiej przy pasie.", 16 SECONDS, PROC_REF(require_vendor))

// 3. Wyposażenie

/datum/tutorial/aquila/general_quarters/proc/require_vendor()
	if(!tutorial_mob)
		return
	current_step = "vendor"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/squad_vendor/tutorial, vendor)
	message_to_player("Podejdź do <b>vendora składu</b> i weź zestaw <b>Żołnierz składu (standardowy)</b>. Zestaw wypadnie w pudełku obok vendora.")
	update_objective("Weź zestaw z vendora składu.")
	add_highlight(vendor)
	RegisterSignal(vendor, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_kit_vended))

/datum/tutorial/aquila/general_quarters/proc/on_kit_vended(datum/source, mob/user, obj/item/storage/box/kit)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/squad_vendor/tutorial, vendor)
	UnregisterSignal(vendor, COMSIG_TUTORIAL_ITEM_USED)
	remove_highlight(vendor)
	current_step = "equip"
	message_to_player("Otwórz pudełko (<b>Alt+klik</b>) i załóż <b>kamizelkę</b> oraz <b>hełm</b> składu ([retrieve_bind("quick_equip")]). Na statku zestaw jest wypożyczony: po alarmie oddajesz go do vendora. Broń z zestawu dostajesz tylko wtedy, gdy XO wyda składom <b>zgodę na broń</b>.")
	update_objective("Załóż kamizelkę i hełm składu.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped))

/datum/tutorial/aquila/general_quarters/proc/on_equipped(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/student = tutorial_mob
	if(!istype(student.wear_suit, /obj/item/clothing/suit/ship/squad) || !istype(student.head, /obj/item/clothing/head/helmet/ship/squad))
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM)
	require_shooting()

// 4. Strzelanie

/datum/tutorial/aquila/general_quarters/proc/require_shooting()
	current_step = "shooting"
	open_gate("range")
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/table, mag_table)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/squad_pager/tutorial, pager)
	pager.add_tutorial_message("XO wydał zgodę na broń. Sprawdź się na strzelnicy.")
	message_to_player("XO wydał <b>zgodę na broń</b>. Zejdź na strzelnicę (oświetlone cele na dole). Weź <b>pistolet</b> z zestawu, a jeśli jest pusty, kliknij go <b>magazynkiem</b>, żeby go załadować (zapasowe leżą na stole). Trafiaj w każdy z trzech celów: weź pistolet do ręki i kliknij cel.")
	update_objective("Traf każdy z trzech celów na strzelnicy ([length(targets_left)] zostało).")
	add_highlight(mag_table)
	for(var/obj/item/target/tutorial/target as anything in targets_left)
		add_highlight(target)
		RegisterSignal(target, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_target_hit))

/datum/tutorial/aquila/general_quarters/proc/on_target_hit(datum/source, atom/firer)
	SIGNAL_HANDLER

	if(firer != tutorial_mob || !(source in targets_left))
		return
	var/obj/item/target/tutorial/target = source
	targets_left -= target
	UnregisterSignal(target, COMSIG_TUTORIAL_ITEM_USED)
	remove_highlight(target)
	if(length(targets_left))
		update_objective("Traf każdy z trzech celów na strzelnicy ([length(targets_left)] zostało).")
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/table, mag_table)
	remove_highlight(mag_table)
	message_to_player("Wszystkie cele trafione! Pamiętaj: na statku strzelasz tylko do wrogów, a pociski lecą dalej, jeśli chybisz. Broń przeładujesz, wyjmując pusty magazynek (<b>[retrieve_bind("activate_inhand")]</b> z pistoletem w ręce) i wkładając nowy.")
	addtimer(CALLBACK(src, PROC_REF(require_rack_hand)), 8 SECONDS)

// 5. Działo Gaussa: amunicja na stojak

/datum/tutorial/aquila/general_quarters/proc/require_rack_hand()
	if(!tutorial_mob)
		return
	current_step = "rack_hand"
	open_gate("gauss")
	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/ship_weapon/gauss_gun/tutorial, gun)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/ship_weapon/ammunition/gauss, round)
	message_to_player("Teraz <b>działo Gaussa</b>. Na statku wisi pod sufitem, a pod nim stoi <b>krzesło strzelca</b> i <b>stojak z amunicją</b>. Podnieś leżący <b>pocisk</b> i kliknij nim stojak, żeby go załadować.")
	update_objective("Załaduj jeden pocisk Gaussa na stojak.")
	add_highlight(round)
	add_highlight(gun.ammo_rack)
	RegisterSignal(gun.ammo_rack, COMSIG_ATOM_ENTERED, PROC_REF(on_rack_loaded))

/datum/tutorial/aquila/general_quarters/proc/on_rack_loaded(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER

	if(!istype(arrived, /obj/item/ship_weapon/ammunition/gauss))
		return
	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/ship_weapon/gauss_gun/tutorial, gun)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/ship_weapon/ammunition/gauss, round)
	if(current_step == "rack_hand")
		require_rack_crate()
	if(round?.loc == gun.ammo_rack)
		remove_highlight(round)
	// Krok kończy się po stanie, nie po liczbie: skrzynia pusta i luźny pocisk na stojaku (kolejność dowolna)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate, crate)
	if(locate(/obj/item/ship_weapon/ammunition/gauss) in crate)
		return
	if(round && round.loc != gun.ammo_rack)
		if(!loose_round_hint_given)
			loose_round_hint_given = TRUE
			message_to_player("Skrzynia jest pusta. Załaduj jeszcze ręcznie <b>luźny pocisk</b> (podświetlony): podnieś go i kliknij nim stojak.")
			update_objective("Załaduj luźny pocisk na stojak.")
		return
	UnregisterSignal(gun.ammo_rack, COMSIG_ATOM_ENTERED)
	remove_highlight(crate)
	remove_highlight(gun.ammo_rack)
	require_chair()

/datum/tutorial/aquila/general_quarters/proc/require_rack_crate()
	current_step = "rack_crate"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/closet/crate, crate)
	message_to_player("Dobrze. Pociski nosi się w skrzyniach: zamiast ładować je po jednym, <b>przeciągnij skrzynię myszą na stojak</b>, a załaduje się cała jej zawartość. Skrzynię możesz najpierw przyciągnąć (<b>Ctrl+klik</b>).")
	update_objective("Przeciągnij skrzynię z pociskami na stojak.")
	add_highlight(crate)

// 6. Krzesło strzelca i obsługa działa

/datum/tutorial/aquila/general_quarters/proc/require_chair()
	current_step = "chair"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/chair/fancy/gauss, chair)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/ship_weapon/gauss_gun/tutorial, gun)
	message_to_player("Stojak jest pełny. Usiądź na <b>krześle strzelca</b>: stań na nim i przeciągnij myszą swoją postać na krzesło. Pasy się zapną, a krzesło wjedzie do kabiny działa.")
	update_objective("Usiądź na krześle strzelca (przeciągnij siebie na krzesło).")
	add_highlight(chair)
	RegisterSignal(gun, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_gun_event))

/datum/tutorial/aquila/general_quarters/proc/on_gun_event(datum/source, mob/user, action)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/machinery/ship_weapon/gauss_gun/tutorial, gun)
	switch(current_step)
		if("chair")
			if(action != "gunner")
				return
			TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/chair/fancy/gauss, chair)
			remove_highlight(chair)
			current_step = "gun_load"
			message_to_player("Jesteś w kabinie. Otworzyło się okno działa. Najpierw podnieś amunicję ze stojaka: <b>I4 - Przeładuj ze stojaka</b>. Stojak wjedzie do działa i poda pociski.")
			update_objective("W oknie działa: I4 - Przeładuj ze stojaka.")
		if("gun_load")
			if(gun.state != STATE_LOADED)
				return
			current_step = "gun_feed"
			message_to_player("Pociski są w dziale. Podaj pocisk do zamka: <b>I1 - Pocisk podany</b>.")
			update_objective("W oknie działa: I1 - Pocisk podany.")
		if("gun_feed")
			if(gun.state != STATE_FED)
				return
			current_step = "gun_chamber"
			message_to_player("Teraz wprowadź pocisk do komory: <b>I2 - Pocisk w komorze</b>.")
			update_objective("W oknie działa: I2 - Pocisk w komorze.")
		if("gun_chamber")
			if(gun.state != STATE_CHAMBERED)
				return
			current_step = "gun_arm"
			message_to_player("Działo jest naładowane. Uzbrój je, wyłączając bezpieczniki: <b>I3 - Bezpieczniki</b>.")
			update_objective("W oknie działa: I3 - Bezpieczniki (wyłącz).")
		if("gun_arm")
			if(gun.safety)
				return
			current_step = "gun_camera"
			message_to_player("Działo jest uzbrojone. Włącz kamerę działa przyciskiem <b>Kamera działa</b> na pasku akcji po lewej stronie ekranu.")
			update_objective("Kliknij przycisk Kamera działa po lewej stronie ekranu.")
		if("gun_camera")
			if(action != "camera")
				return
			current_step = "gun_fire"
			describe_step("Na statku kamera pokazuje widok z działa na mapie kosmosu, a kliknięcie celu oddaje strzał. Po 12 strzałach przeładowujesz ze stojaka (I4), a koledzy na dole dokładają na niego amunicję. W samouczku nie ma statku ani wrogów, więc strzału nie oddasz.", 14 SECONDS, PROC_REF(require_exit))
		if("gun_exit")
			if(action != "gunner_left")
				return
			UnregisterSignal(gun, COMSIG_TUTORIAL_ITEM_USED)
			finish()

/datum/tutorial/aquila/general_quarters/proc/require_exit()
	if(!tutorial_mob)
		return
	current_step = "gun_exit"
	message_to_player("Na koniec wyjdź z działa przyciskiem <b>Wyjdź z działa</b> na pasku akcji po lewej (albo kliknij działo). Krzesło zjedzie na dół. Zanim wyjdziesz na dłużej, włącz z powrotem bezpieczniki.")
	update_objective("Wyjdź z działa (przycisk Wyjdź z działa po lewej).")

/datum/tutorial/aquila/general_quarters/proc/finish()
	if(!tutorial_mob)
		return
	current_step = "finished"
	message_to_player("Świetnie! Wiesz, co robić podczas alarmu bojowego. To koniec samouczka Aquili, powodzenia na służbie! Za chwilę wrócisz do lobby.")
	update_objective("")
	tutorial_end_in(8 SECONDS, TRUE)

// Przygotowanie

/datum/tutorial/aquila/general_quarters/init_map()
	// Drzwi z kwatery na strzelnicę i do stanowiska Gaussa, otwierają się po kolejnych krokach
	add_gate("range", 2, 4)
	add_gate("gauss", 5, 6)
	var/obj/structure/bed/bed = locate() in loc_from_corner(GQ_BED)
	if(bed)
		add_to_tracking_atoms(bed)
	add_to_tracking_atoms(new /obj/item/squad_pager/tutorial(loc_from_corner(GQ_PAGER)))
	add_to_tracking_atoms(new /obj/machinery/squad_vendor/tutorial(loc_from_corner(GQ_VENDOR)))

	// Strzelnica: stół z zapasowymi magazynkami i trzy cele
	var/obj/structure/table/mag_table = new(loc_from_corner(GQ_MAG_TABLE))
	add_to_tracking_atoms(mag_table)
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/glock/lethal(mag_table.loc)
	for(var/y_offset in 1 to 3)
		targets_left += new /obj/item/target/tutorial(loc_from_corner(7, y_offset))

	// Działo Gaussa w przekroju: działo na ścianie u góry, pod nim krzesło i stojak
	var/obj/structure/chair/fancy/gauss/chair = new(loc_from_corner(GQ_CHAIR))
	add_to_tracking_atoms(chair)
	var/obj/machinery/ship_weapon/gauss_gun/tutorial/gun = new(loc_from_corner(GQ_GUN))
	add_to_tracking_atoms(gun)
	gun.link_tutorial(chair, loc_from_corner(GQ_RACK))
	add_to_tracking_atoms(new /obj/item/ship_weapon/ammunition/gauss(loc_from_corner(GQ_LOOSE_ROUND)))
	var/obj/structure/closet/crate/crate = new(loc_from_corner(GQ_CRATE))
	for(var/i in 1 to GQ_CRATE_ROUNDS)
		new /obj/item/ship_weapon/ammunition/gauss(crate)
	add_to_tracking_atoms(crate)

/datum/tutorial/aquila/general_quarters/init_mob()
	. = ..()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/bed, bed)
	if(!bed)
		return
	tutorial_mob.forceMove(get_turf(bed))
	bed.buckle_mob(tutorial_mob, TRUE)

/datum/tutorial/aquila/general_quarters/Destroy(force, ...)
	QDEL_LIST(targets_left)
	return ..()

#undef GQ_BED
#undef GQ_PAGER
#undef GQ_VENDOR
#undef GQ_MAG_TABLE
#undef GQ_GUN
#undef GQ_CHAIR
#undef GQ_RACK
#undef GQ_CRATE
#undef GQ_LOOSE_ROUND
#undef GQ_CRATE_ROUNDS
