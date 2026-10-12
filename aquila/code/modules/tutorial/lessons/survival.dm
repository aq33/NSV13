/datum/map_template/tutorial/aquila_survival
	name = "Samouczek: Przetrwanie"
	mappath = 'aquila/_maps/tutorial/aquila_survival.dmm'
	width = 14
	height = 9

/datum/outfit/aquila_tutorial/survival
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/// Lekcja 2: rozszczelnienie, ranny w stanie krytycznym, noszenie na plecach
/datum/tutorial/aquila/survival
	name = "Przetrwanie"
	desc = "Co robić, gdy z pomieszczenia ucieka powietrze, jak ratować rannego w stanie krytycznym i jak zanieść go na łóżko."
	tutorial_id = "aquila_survival_1"
	icon = "heartbeat"
	order = 2
	tutorial_template = /datum/map_template/tutorial/aquila_survival
	outfit = /datum/outfit/aquila_tutorial/survival
	/// Trwa spuszczanie powietrza z pokoju
	var/draining = FALSE
	/// Gracz już dostał podpowiedź, że internale działają, ale brakuje skafandra
	var/suit_hint_given = FALSE

// Układ pokoju (przesunięcia od lewego dolnego rogu podłogi): po lewej korytarz,
// po prawej pokój z rannym, stołem i łóżkiem.
#define SURVIVAL_START 1, 2
#define SURVIVAL_PATIENT 7, 1
#define SURVIVAL_BED 11, 6
/// Do takiego ciśnienia (kPa) spada powietrze: trudno oddychać, ale bez obrażeń od niskiego ciśnienia
#define SURVIVAL_TARGET_PRESSURE 50

// Skrypt

/datum/tutorial/aquila/survival/start_tutorial(mob/dead/new_player/starting_mob)
	. = ..()
	if(!.)
		return

	init_mob()
	message_to_player("Lekcja „Przetrwanie”. Na statku najczęściej zabija brak powietrza i brak szybkiej pomocy. Za chwilę coś pójdzie nie tak.")
	update_objective("Poczekaj na pierwsze polecenie.")
	addtimer(CALLBACK(src, PROC_REF(start_decompression)), 6 SECONDS)

// 1. Rozszczelnienie: skafander z pudełka przetrwania i internale

/datum/tutorial/aquila/survival/proc/start_decompression()
	if(!tutorial_mob)
		return
	current_step = "decompression"
	SEND_SOUND(tutorial_mob, sound('sound/machines/warning-buzzer.ogg', volume = 50))
	SEND_SOUND(tutorial_mob, sound('sound/effects/space_wind.ogg', volume = 40))
	message_to_player("<b>Rozszczelnienie!</b> Powietrze ucieka. W plecaku masz <b>pudełko przetrwania</b> (otwierasz je <b>Alt+klik</b>). Załóż <b>maskę</b>, potem <b>hełm</b>. <b>Skafander</b> jest zwinięty: weź go do ręki i rozwiń klawiszem <b>[retrieve_bind("activate_inhand")]</b>, potem załóż ([retrieve_bind("quick_equip")]). Butlę schowaj do kieszeni i włącz internale.")
	update_objective("Z pudełka przetrwania: maska, hełm, skafander (rozwiń go [retrieve_bind("activate_inhand")]), butla i internale.")
	highlight_hud(/atom/movable/screen/internals)
	RegisterSignal(tutorial_mob, list(COMSIG_CARBON_INTERNALS_CHANGED, COMSIG_MOB_EQUIPPED_ITEM), PROC_REF(check_protection))
	RegisterSignal(tutorial_mob, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	draining = TRUE
	drain_air()

/// Co sekundę zabiera część powietrza z pokoju, aż ciśnienie spadnie do SURVIVAL_TARGET_PRESSURE
/datum/tutorial/aquila/survival/proc/drain_air()
	if(!draining || QDELETED(src))
		return
	var/turf/open/sample = loc_from_corner(SURVIVAL_START)
	if(sample.return_air().return_pressure() > SURVIVAL_TARGET_PRESSURE)
		for(var/turf/open/floor in reserved_block())
			floor.remove_air_ratio(0.1)
	addtimer(CALLBACK(src, PROC_REF(drain_air)), 1 SECONDS)

/// Przywraca zwykłe powietrze w całym pokoju
/datum/tutorial/aquila/survival/proc/restore_air()
	draining = FALSE
	for(var/turf/open/floor in reserved_block())
		floor.air.parse_gas_string(floor.initial_gas_mix)
		floor.update_visuals()

/// Czy gracz ma skafander i hełm z pudełka i oddycha z butli
/datum/tutorial/aquila/survival/proc/is_protected()
	var/mob/living/carbon/human/student = tutorial_mob
	return istype(student.wear_suit, /obj/item/clothing/suit/space/skinsuit) && istype(student.head, /obj/item/clothing/head/helmet/space/skinsuit) && student.internal

/datum/tutorial/aquila/survival/proc/check_protection(datum/source)
	SIGNAL_HANDLER

	if(!is_protected())
		var/mob/living/carbon/human/student = tutorial_mob
		if(student.internal && !suit_hint_given)
			suit_hint_given = TRUE
			message_to_player("Internale działają. Załóż jeszcze <b>skafander</b> (najpierw rozwiń go w ręce: <b>[retrieve_bind("activate_inhand")]</b>) i <b>hełm</b>. Przy prawdziwym wyłomie ciśnienie spada do zera i bez nich szybko zginiesz.")
		return
	UnregisterSignal(tutorial_mob, list(COMSIG_CARBON_INTERNALS_CHANGED, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_STATCHANGE))
	unhighlight_hud(/atom/movable/screen/internals)
	current_step = "protected"
	message_to_player("Masz skafander, hełm i oddychasz z butli, więc jesteś bezpieczny. Wyłom zaraz zostanie załatany. Przy prawdziwym rozszczelnieniu uciekaj za najbliższe zamknięte drzwi i wezwij pomoc przez radio.")
	update_objective("Poczekaj, aż wróci powietrze.")
	addtimer(CALLBACK(src, PROC_REF(after_decompression)), 6 SECONDS)

/datum/tutorial/aquila/survival/proc/after_decompression()
	if(!tutorial_mob)
		return
	restore_air()
	message_to_player("Powietrze wróciło. Skafander spowalnia, więc możesz go zdjąć, a internale wyłączyć tym samym przyciskiem. W pokoju obok ktoś potrzebuje pomocy.")
	addtimer(CALLBACK(src, PROC_REF(require_strip)), 6 SECONDS)

/// Gracz zemdlał z braku powietrza: oddajemy powietrze i zaczynamy krok od nowa (to, co założył, zostaje)
/datum/tutorial/aquila/survival/proc/on_stat_change(datum/source, new_stat)
	SIGNAL_HANDLER

	if(new_stat == CONSCIOUS)
		return
	restore_air()
	var/mob/living/student = tutorial_mob
	student.setOxyLoss(0)
	student.SetUnconscious(0)
	message_to_player("Straciłeś przytomność z braku tlenu. Przy rozszczelnieniu masz tylko chwilę: od razu sięgaj po pudełko przetrwania. Spróbuj jeszcze raz, to, co już założyłeś, zostaje na tobie.")
	draining = TRUE
	addtimer(CALLBACK(src, PROC_REF(drain_air)), 4 SECONDS)

// 2. Rozbieranie: autoinjektor z kieszeni rannego

/datum/tutorial/aquila/survival/proc/require_strip()
	if(!tutorial_mob)
		return
	current_step = "strip"
	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	message_to_player("Ten członek załogi jest w <b>stanie krytycznym</b>: nieprzytomny, a bez pomocy będzie się dusił. W kieszeni ma <b>autoinjektor z epinefryną</b>. Przeciągnij go myszą na swoją postać: otworzy się okno z jego ekwipunkiem. Opróżnij jego <b>kieszeń</b>.")
	update_objective("Przeciągnij rannego na siebie i opróżnij jego kieszeń.")
	add_highlight(patient)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/reagent_containers/hypospray/medipen/tutorial, medipen)
	RegisterSignal(medipen, COMSIG_MOVABLE_MOVED, PROC_REF(on_medipen_taken))

/datum/tutorial/aquila/survival/proc/on_medipen_taken(datum/source)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/reagent_containers/hypospray/medipen/tutorial, medipen)
	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	if(medipen.loc == patient)
		return
	UnregisterSignal(medipen, COMSIG_MOVABLE_MOVED)
	require_epinephrine()

// 3. Epinefryna

/datum/tutorial/aquila/survival/proc/require_epinephrine()
	current_step = "epinephrine"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/reagent_containers/hypospray/medipen/tutorial, medipen)
	message_to_player("Tak samo zdejmiesz komuś ubranie, broń czy kartę. Teraz podnieś <b>autoinjektor</b> i kliknij nim rannego.")
	update_objective("Wstrzyknij rannemu epinefrynę z autoinjektora.")
	add_highlight(medipen)
	RegisterSignal(medipen, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_medipen_used))

/datum/tutorial/aquila/survival/proc/on_medipen_used(datum/source, mob/user, mob/living/target)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/reagent_containers/hypospray/medipen/tutorial, medipen)
	if(target != patient)
		if(target == tutorial_mob)
			message_to_player("To było w ciebie! Autoinjektor jest jednorazowy, więc obok rannego leży nowy. Tym razem kliknij nim <b>rannego</b>.")
			replace_medipen()
		return
	UnregisterSignal(medipen, COMSIG_TUTORIAL_ITEM_USED)
	remove_highlight(medipen)
	require_carry()

/// Nowy autoinjektor obok rannego, gdy gracz zmarnował poprzedni
/datum/tutorial/aquila/survival/proc/replace_medipen()
	TUTORIAL_ATOM_FROM_TRACKING(/obj/item/reagent_containers/hypospray/medipen/tutorial, old_medipen)
	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	UnregisterSignal(old_medipen, COMSIG_TUTORIAL_ITEM_USED)
	remove_highlight(old_medipen)
	remove_from_tracking_atoms(old_medipen)
	var/obj/item/reagent_containers/hypospray/medipen/tutorial/medipen = new(get_turf(patient))
	add_to_tracking_atoms(medipen)
	add_highlight(medipen)
	RegisterSignal(medipen, COMSIG_TUTORIAL_ITEM_USED, PROC_REF(on_medipen_used))

// 4. Noszenie na plecach

/datum/tutorial/aquila/survival/proc/require_carry()
	current_step = "carry"
	message_to_player("Epinefryna go ustabilizowała, ale trzeba go zanieść na łóżko. Przełącz intencję na <b>chwyt</b> ([retrieve_bind("select_grab_intent")]) i kliknij rannego <b>dwa razy</b> (mocny chwyt). Potem, wciąż na chwycie, przeciągnij go myszą na swoją postać, żeby wziąć go na plecy.")
	update_objective("Chwyć rannego mocno (intencja chwytu, dwa kliknięcia) i przeciągnij go na siebie.")
	highlight_hud(/atom/movable/screen/act_intent)
	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_carry))

/datum/tutorial/aquila/survival/proc/on_carry(datum/source, mob/living/carried)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	if(carried != patient)
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_BUCKLE)
	unhighlight_hud(/atom/movable/screen/act_intent)
	remove_highlight(patient)
	require_bed()

/datum/tutorial/aquila/survival/proc/require_bed()
	current_step = "bed"
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/bed, bed)
	add_highlight(bed)
	add_highlight(get_turf(bed))
	message_to_player("Niesiesz rannego. Stań na podświetlonym łóżku i połóż go, upuszczając go klawiszem <b>[retrieve_bind("drop_item")]</b>.")
	update_objective("Zanieś rannego na łóżko i połóż go ([retrieve_bind("drop_item")]).")
	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_put_down))

/datum/tutorial/aquila/survival/proc/on_put_down(datum/source, mob/living/carried)
	SIGNAL_HANDLER

	TUTORIAL_ATOM_FROM_TRACKING(/mob/living/carbon/human, patient)
	TUTORIAL_ATOM_FROM_TRACKING(/obj/structure/bed, bed)
	if(carried != patient)
		return
	if(get_turf(patient) != get_turf(bed))
		UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_UNBUCKLE)
		current_step = "carry"
		message_to_player("Położyłeś go obok łóżka. Weź go znów na plecy (chwyt dwa razy i przeciągnięcie na siebie) i połóż na łóżku.")
		RegisterSignal(tutorial_mob, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_carry))
		return
	UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_UNBUCKLE)
	remove_highlight(bed)
	remove_highlight(get_turf(bed))
	finish()

/datum/tutorial/aquila/survival/proc/finish()
	if(!tutorial_mob)
		return
	current_step = "finished"
	message_to_player("Dobra robota! Ranny jest bezpieczny, a ty wiesz, jak przetrwać rozszczelnienie. Następna lekcja: <b>Alarm bojowy</b>. Za chwilę wrócisz do lobby.")
	update_objective("")
	tutorial_end_in(8 SECONDS, TRUE)

// Przygotowanie

/datum/tutorial/aquila/survival/Destroy(force, ...)
	draining = FALSE
	return ..()

/datum/tutorial/aquila/survival/init_map()
	var/obj/structure/bed/bed = locate() in loc_from_corner(SURVIVAL_BED)
	if(bed)
		add_to_tracking_atoms(bed)

	var/mob/living/carbon/human/patient = new(loc_from_corner(SURVIVAL_PATIENT))
	patient.real_name = "Ranny technik"
	patient.name = patient.real_name
	patient.equipOutfit(/datum/outfit/aquila_tutorial)
	var/obj/item/reagent_containers/hypospray/medipen/tutorial/medipen = new(patient)
	if(!patient.equip_to_slot_if_possible(medipen, ITEM_SLOT_LPOCKET, disable_warning = TRUE))
		medipen.forceMove(get_turf(patient))
	add_to_tracking_atoms(medipen)
	// Nie umrze w trakcie lekcji, nawet gdy gracz długo zwleka
	ADD_TRAIT(patient, TRAIT_NODEATH, TRAIT_SOURCE_TUTORIAL)
	patient.apply_damage(130, BRUTE, BODY_ZONE_CHEST)
	add_to_tracking_atoms(patient)

/datum/tutorial/aquila/survival/init_mob()
	. = ..()
	tutorial_mob.forceMove(loc_from_corner(SURVIVAL_START))
	// Autoinjektor ma być tylko u rannego, żeby gracz nauczył się go od niego wziąć
	var/mob/living/carbon/student = tutorial_mob
	var/obj/item/storage/box/survival/box = locate() in student.back
	for(var/obj/item/reagent_containers/hypospray/medipen/own_medipen in box)
		qdel(own_medipen)

#undef SURVIVAL_START
#undef SURVIVAL_PATIENT
#undef SURVIVAL_BED
#undef SURVIVAL_TARGET_PRESSURE
