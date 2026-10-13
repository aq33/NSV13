// AQUILA - zdolności demona impulsu (port z ParadiseSS13, tam były to spelle)
// Zdolności kupuje się i ulepsza za przejęte APC w menu zdolności (jak emporium changelinga).
// Przycisk zdolności pojawia się dopiero po jej kupieniu.

#define PULSEDEMON_REMOTE_DRAIN_MULTIPLIER 5

#define PD_UPGRADE_HIJACK_SPEED "Szybkość"
#define PD_UPGRADE_DRAIN_SPEED "Pochłanianie"
#define PD_UPGRADE_HEALTH_LOSS "Wytrzymałość"
#define PD_UPGRADE_HEALTH_REGEN "Regeneracja"
#define PD_UPGRADE_MAX_HEALTH "Siła"
#define PD_UPGRADE_HEALTH_COST "Wydajność"
#define PD_UPGRADE_MAX_CHARGE "Pojemność"

/datum/action/cooldown/pulse_demon
	button_icon = 'aquila/icons/mob/actions/actions_pulse_demon.dmi'
	icon_icon = 'aquila/icons/mob/actions/actions_pulse_demon.dmi'
	background_icon_state = "bg_pulsedemon"
	check_flags = AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	cooldown_time = 20 SECONDS
	/// Trzeba ją najpierw kupić za APC
	var/locked = TRUE
	/// Koszt odblokowania w APC
	var/unlock_cost = 1
	/// Koszt użycia w J
	var/cast_cost = 1000
	/// Koszt ulepszenia w APC
	var/upgrade_cost = 1
	/// Obecny poziom ulepszenia
	var/level = 0
	/// Najwyższy poziom ulepszenia, 0 = bez ulepszeń
	var/level_max = 4
	/// Bazowy czas odnowienia, ulepszenia go skracają
	var/base_cooldown = 20 SECONDS
	/// Działa tylko z przejętego APC na cele w jego obszarze
	var/requires_area = FALSE
	/// Użycie na chwilę ujawnia demona
	var/revealing = FALSE
	var/reveal_time = 10 SECONDS
	/// Czeka na kliknięcie celu, inaczej działa od razu na demona
	var/targeted = TRUE
	/// Nazwa i opis bez dopisków o kosztach
	var/base_name
	var/base_desc

/datum/action/cooldown/pulse_demon/New(Target)
	base_name = name
	base_desc = desc
	cooldown_time = base_cooldown
	. = ..()
	update_info()

/datum/action/cooldown/pulse_demon/Remove(mob/M)
	var/mob/living/simple_animal/pulse_demon/demon = M
	if(istype(demon) && demon.selected_action == src)
		unset_click_ability(demon)
	return ..()

/datum/action/cooldown/pulse_demon/proc/update_info()
	name = "[base_name][cast_cost ? " ([display_joules(cast_cost)])" : ""][level ? " - poziom [level + 1]" : ""]"
	desc = base_desc
	UpdateButtonIcon()

/datum/action/cooldown/pulse_demon/IsAvailable()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/pulse_demon/demon = owner
	if(!istype(demon) || locked || demon.charge < cast_cost)
		return FALSE
	if(requires_area && !demon.controlling_area)
		return FALSE

/// Sprawdza, czy można użyć, i mówi demonowi dlaczego nie
/datum/action/cooldown/pulse_demon/proc/can_use(mob/living/simple_animal/pulse_demon/user, show_message = TRUE)
	if(!istype(user) || user.stat)
		return FALSE
	if(locked)
		if(show_message)
			to_chat(user, "<span class='warning'>Najpierw kup tę zdolność w menu zdolności!</span>")
		return FALSE
	if(next_use_time > world.time)
		if(show_message)
			to_chat(user, "<span class='warning'>Ta zdolność jeszcze się odnawia!</span>")
		return FALSE
	if(user.charge < cast_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>Masz za mało energii! Użycie kosztuje [display_joules(cast_cost)].</span>")
		return FALSE
	if(requires_area && !user.controlling_area)
		if(show_message)
			to_chat(user, "<span class='warning'>Musisz kontrolować obszar z przejętego APC, żeby tego użyć!</span>")
		return FALSE
	return TRUE

/datum/action/cooldown/pulse_demon/Trigger()
	var/mob/living/simple_animal/pulse_demon/user = owner
	if(!can_use(user))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	if(!targeted)
		attempt_cast(user, user)
		return TRUE
	if(user.selected_action == src)
		unset_click_ability(user)
		to_chat(user, "<span class='notice'>Anulujesz [base_name].</span>")
		return TRUE
	if(user.selected_action)
		user.selected_action.unset_click_ability(user)
	user.selected_action = src
	user.click_intercept = src
	if(user.client)
		user.client.mouse_pointer_icon = 'icons/effects/overload_machine_target.dmi'
	to_chat(user, "<span class='notice'>Kliknij cel dla [base_name]. Kliknij przycisk jeszcze raz, żeby anulować.</span>")
	return TRUE

/datum/action/cooldown/pulse_demon/proc/unset_click_ability(mob/living/simple_animal/pulse_demon/user)
	if(user.selected_action == src)
		user.selected_action = null
	if(user.click_intercept == src)
		user.click_intercept = null
	if(user.client)
		user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)

/datum/action/cooldown/pulse_demon/proc/InterceptClickOn(mob/living/user, params, atom/target)
	var/list/modifiers = params2list(params)
	// Shift+klik dalej ogląda rzeczy
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK))
		return FALSE
	unset_click_ability(user)
	attempt_cast(user, target)
	return TRUE

/datum/action/cooldown/pulse_demon/proc/attempt_cast(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(!can_use(user))
		return FALSE
	if(requires_area && user.controlling_area != get_area(target))
		to_chat(user, "<span class='warning'>Tego możesz użyć tylko w kontrolowanym obszarze!</span>")
		return FALSE
	if(!try_cast_action(user, target))
		return FALSE
	user.adjust_charge(-cast_cost)
	if(cooldown_time)
		StartCooldown()
	if(revealing)
		user.reveal(reveal_time)
	return TRUE

/// Właściwe działanie zdolności, TRUE gdy się udało
/datum/action/cooldown/pulse_demon/proc/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	return FALSE

// Kupowanie i ulepszanie (wołane z menu zdolności)

/// Kupuje zdolność za APC i daje demonowi jej przycisk
/datum/action/cooldown/pulse_demon/proc/buy(mob/living/simple_animal/pulse_demon/user)
	if(!locked)
		return FALSE
	if(user.apcs_remaining < unlock_cost)
		to_chat(user, "<span class='warning'>Nie stać cię na [base_name]! Kosztuje [unlock_cost] APC.</span>")
		return FALSE
	user.apcs_remaining -= unlock_cost
	locked = FALSE
	Grant(user)
	update_info()
	to_chat(user, "<span class='notice'>Kupujesz [base_name]! Przycisk pojawił się na pasku zdolności.</span>")
	return TRUE

/datum/action/cooldown/pulse_demon/proc/upgrade(mob/living/simple_animal/pulse_demon/user)
	if(locked || level >= level_max)
		return FALSE
	if(user.apcs_remaining < upgrade_cost)
		to_chat(user, "<span class='warning'>Nie stać cię na ulepszenie! Kosztuje [upgrade_cost] APC.</span>")
		return FALSE
	user.apcs_remaining -= upgrade_cost
	level = min(level + 1, level_max)
	do_upgrade(user)
	update_info()
	return TRUE

/datum/action/cooldown/pulse_demon/proc/do_upgrade(mob/living/simple_animal/pulse_demon/user)
	cooldown_time = round(base_cooldown / (1.5 ** level))
	to_chat(user, "<span class='notice'>Ulepszasz [base_name] do poziomu [level + 1], odnawia się teraz [cooldown_time / 10] s.</span>")

// Skok po kablach

/datum/action/cooldown/pulse_demon/cablehop
	name = "Skok po kablach"
	desc = "Przeskakujesz do innego kabla w zasięgu wzroku."
	button_icon_state = "pd_cablehop"
	unlock_cost = 4
	cast_cost = 200000
	upgrade_cost = 2
	revealing = TRUE
	reveal_time = 5 SECONDS

/datum/action/cooldown/pulse_demon/cablehop/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/turf/O = get_turf(user)
	var/turf/T = get_turf(target)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!istype(C))
		to_chat(user, "<span class='warning'>Tam nie ma kabla!</span>")
		return FALSE
	// trochę zapasu na sterowanie maszynami z dala od APC, ale bez przeskakiwania przez cały statek z konsoli kamer
	if(O.z != T.z || get_dist(O, T) > 15)
		to_chat(user, "<span class='warning'>Ten kabel jest za daleko!</span>")
		return FALSE
	playsound(T, 'sound/magic/lightningshock.ogg', 50, TRUE)
	O.Beam(T, icon_state = "lightning[rand(1, 12)]", time = 1 SECONDS)
	for(var/turf/working in getline(O, T))
		for(var/mob/living/L in working)
			if(L == user)
				continue
			// trochę nieśmiertelnej kontry na izolowane rękawice
			if(!electrocute_mob(L, C.powernet, user))
				L.Jitter(5)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, Knockdown), 5 SECONDS), 1 SECONDS)
	if(user.current_power)
		user.UnregisterSignal(user.current_power, COMSIG_ATOM_EMP_ACT)
	user.current_power = null
	user.forceMove(T)
	user.Move(T)
	user.current_cable = C
	user.update_controlling_area()
	return TRUE

// Elektromagnetyczna ingerencja

/datum/action/cooldown/pulse_demon/emagtamper
	name = "Elektromagnetyczna ingerencja"
	desc = "Odblokowuje ukryte funkcje maszyn. Działa tylko z przejętego APC."
	button_icon_state = "pd_emag"
	unlock_cost = 4
	cast_cost = 200000
	upgrade_cost = 2
	requires_area = TRUE
	revealing = TRUE

/datum/action/cooldown/pulse_demon/emagtamper/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	to_chat(user, "<span class='warning'>Próbujesz namieszać w [target]!</span>")
	target.emag_act(user)
	return TRUE

// EMP

/datum/action/cooldown/pulse_demon/emp
	name = "Impuls elektromagnetyczny"
	desc = "Tworzy EMP w klikniętym miejscu. Uważaj, żeby nie trafić siebie!"
	button_icon_state = "pd_emp"
	unlock_cost = 4
	cast_cost = 500000
	upgrade_cost = 2
	requires_area = TRUE
	revealing = TRUE

/datum/action/cooldown/pulse_demon/emp/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	to_chat(user, "<span class='warning'>Próbujesz przepalić [target] impulsem!</span>")
	empulse(get_turf(target), 1, 1)
	return TRUE

// Przeciążenie maszyny

/datum/action/cooldown/pulse_demon/overload
	name = "Przeciążenie maszyny"
	desc = "Przeciąża maszynę, aż wybuchnie. Po pełnym ulepszeniu wybuch przebija ściany."
	button_icon_state = "pd_overload"
	unlock_cost = 8
	cast_cost = 1000000
	upgrade_cost = 4
	requires_area = TRUE
	revealing = TRUE
	base_cooldown = 60 SECONDS
	reveal_time = 20 SECONDS

/datum/action/cooldown/pulse_demon/overload/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/obj/machinery/M = target
	if(!istype(M))
		to_chat(user, "<span class='warning'>To nie jest maszyna.</span>")
		return FALSE
	if(is_type_in_typecache(M, GLOB.blacklisted_malf_machines) || (M.resistance_flags & INDESTRUCTIBLE))
		to_chat(user, "<span class='warning'>Tej maszyny nie da się przeciążyć.</span>")
		return FALSE
	M.audible_message("<span class='italics'>Słyszysz głośne elektryczne brzęczenie dochodzące z [M]!</span>")
	message_admins("[ADMIN_LOOKUPFLW(user)] overloaded [M] at [ADMIN_VERBOSEJMP(M)] as a pulse demon.")
	log_game("[key_name(user)] overloaded [M] at [AREACOORD(M)] as a pulse demon.")
	addtimer(CALLBACK(src, PROC_REF(detonate), M), 5 SECONDS)
	return TRUE

/datum/action/cooldown/pulse_demon/overload/proc/detonate(obj/machinery/target)
	if(QDELETED(target))
		return
	if(level == level_max)
		explosion(get_turf(target), 0, 1, 2, 2)
	else
		explosion(get_turf(target), 0, 0, 2, 2)
	if(!QDELETED(target))
		qdel(target)

// Zdalne przejęcie

/datum/action/cooldown/pulse_demon/remotehijack
	name = "Zdalne przejęcie"
	desc = "Przejmuje APC na odległość."
	button_icon_state = "pd_remotehack"
	unlock_cost = 2
	cast_cost = 200000
	level_max = 0
	base_cooldown = 3 SECONDS // i tak trzeba odczekać zwykły czas przejęcia

/datum/action/cooldown/pulse_demon/remotehijack/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/obj/machinery/power/apc/A = target
	if(!istype(A))
		to_chat(user, "<span class='warning'>To nie jest APC.</span>")
		return FALSE
	if(!(A in view(user.client?.view || world.view, get_turf(user))))
		to_chat(user, "<span class='warning'>Nie widzisz tego APC.</span>")
		return FALSE
	if(!user.is_valid_apc(A) || (A in user.hijacked_apcs) || user.apc_being_hijacked || A.being_hijacked)
		to_chat(user, "<span class='warning'>Nie możesz teraz przejąć tego APC!</span>")
		return FALSE
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/simple_animal/pulse_demon, try_hijack_apc), A, TRUE)
	return TRUE

// Zdalne wysysanie

/datum/action/cooldown/pulse_demon/remotedrain
	name = "Zdalne wysysanie"
	desc = "Wysysa prąd ze źródła na odległość."
	button_icon_state = "pd_remotedrain"
	unlock_cost = 2
	cast_cost = 50000
	upgrade_cost = 2

/datum/action/cooldown/pulse_demon/remotedrain/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(!(target in view(user.client?.view || world.view, get_turf(user))))
		to_chat(user, "<span class='warning'>Nie widzisz tego źródła.</span>")
		return FALSE
	if(istype(target, /obj/machinery/power/apc))
		var/drained = user.drain_APC(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		if(drained == PULSEDEMON_SOURCE_DRAIN_INVALID)
			to_chat(user, "<span class='warning'>To APC jest właśnie przejmowane, nie możesz teraz z niego pić.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>Wysysasz [display_joules(drained)] z [target].</span>")
		return TRUE
	if(istype(target, /obj/machinery/power/smes))
		var/drained = user.drain_SMES(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		to_chat(user, "<span class='notice'>Wysysasz [display_joules(drained)] z [target].</span>")
		return TRUE
	to_chat(user, "<span class='warning'>To nie jest źródło prądu.</span>")
	return FALSE

// Przełączniki

/datum/action/cooldown/pulse_demon/toggle
	cooldown_time = 0
	base_cooldown = 0
	cast_cost = 0
	targeted = FALSE
	/// Koniec zdania „Od teraz będziesz / nie będziesz ...”
	var/base_message = "widzieć wiadomości, których nie powinieneś!"

/// Ustawia wygląd przycisku według zmiennej demona
/datum/action/cooldown/pulse_demon/toggle/proc/sync_state(mob/living/simple_animal/pulse_demon/user)
	set_visual_state(get_state(user))

/datum/action/cooldown/pulse_demon/toggle/proc/get_state(mob/living/simple_animal/pulse_demon/user)
	return FALSE

/datum/action/cooldown/pulse_demon/toggle/proc/set_visual_state(state)
	background_icon_state = state ? "bg_pulsedemon" : "bg_pulsedemon_disabled"
	UpdateButtonIcon()

/datum/action/cooldown/pulse_demon/toggle/buy(mob/living/simple_animal/pulse_demon/user)
	. = ..()
	if(.)
		sync_state(user)

/datum/action/cooldown/pulse_demon/toggle/proc/announce(mob/user, state)
	set_visual_state(state)
	to_chat(user, "<span class='notice'>Od teraz [state ? "będziesz" : "nie będziesz"] [base_message]</span>")
	return state

/datum/action/cooldown/pulse_demon/toggle/do_drain
	name = "Przełącz wysysanie"
	desc = "Włącza i wyłącza wysysanie prądu ze źródeł. Tempo ustawisz w menu zdolności."
	base_message = "wysysać prądu ze źródeł."
	button_icon_state = "pd_toggle_steal"
	locked = FALSE
	level_max = 0

/datum/action/cooldown/pulse_demon/toggle/do_drain/get_state(mob/living/simple_animal/pulse_demon/user)
	return user.do_drain

/datum/action/cooldown/pulse_demon/toggle/do_drain/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	user.do_drain = announce(user, !user.do_drain)
	return TRUE

/datum/action/cooldown/pulse_demon/toggle/can_exit_cable
	name = "Przełącz samopodtrzymanie"
	desc = "Pozwala ruszać się poza kablami i źródłami prądu, kosztem zdrowia."
	base_message = "wychodzić poza kable."
	button_icon_state = "pd_toggle_exit"
	upgrade_cost = 2
	level_max = 3
	locked = FALSE

/datum/action/cooldown/pulse_demon/toggle/can_exit_cable/get_state(mob/living/simple_animal/pulse_demon/user)
	return user.can_exit_cable

/datum/action/cooldown/pulse_demon/toggle/can_exit_cable/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(user.can_exit_cable && !(user.current_cable || user.current_power))
		to_chat(user, "<span class='warning'>Najpierw wejdź do kabla albo źródła prądu!</span>")
		return FALSE
	user.can_exit_cable = announce(user, !user.can_exit_cable)
	return TRUE

/datum/action/cooldown/pulse_demon/toggle/can_exit_cable/do_upgrade(mob/living/simple_animal/pulse_demon/user)
	user.outside_cable_speed = max(initial(user.outside_cable_speed) - level, 1)
	to_chat(user, "<span class='notice'>Ulepszasz [base_name] do poziomu [level + 1], poza kablami ruszasz się teraz szybciej.</span>")

/datum/action/cooldown/pulse_demon/toggle/penetrating_shock
	name = "Przełącz silne wstrząsy"
	desc = "Przy ataku wydajesz 200 kJ, żeby przebić izolację ofiary."
	base_message = "używać silnych wstrząsów przy atakach."
	button_icon_state = "pd_strong_shocks"
	unlock_cost = 4
	level_max = 0

/datum/action/cooldown/pulse_demon/toggle/penetrating_shock/get_state(mob/living/simple_animal/pulse_demon/user)
	return user.strong_shocks

/datum/action/cooldown/pulse_demon/toggle/penetrating_shock/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	user.strong_shocks = announce(user, !user.strong_shocks)
	return TRUE

// Kamery w przejętym obszarze

/datum/action/cooldown/pulse_demon/cycle_camera
	name = "Przełącz kamerę"
	desc = "Skacze między kamerami w obszarze przejętego APC. Po ostatniej kamerze wraca do APC."
	button_icon_state = "pd_camera_view"
	locked = FALSE
	cast_cost = 0
	level_max = 0
	base_cooldown = 0
	requires_area = TRUE
	targeted = FALSE
	/// Indeks obecnej kamery w obszarze, 0 = APC
	var/current_camera = 0

/datum/action/cooldown/pulse_demon/cycle_camera/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/list/cameras = user.controlling_area.cameras
	if(!length(cameras))
		to_chat(user, "<span class='warning'>W tym obszarze nie ma kamer.</span>")
		return FALSE

	if(istype(user.loc, /obj/machinery/power/apc))
		current_camera = 0
	else if(istype(user.loc, /obj/machinery/camera))
		current_camera = (current_camera + 1) % length(cameras)
		if(current_camera == 0)
			user.forceMove(user.current_power)
			return TRUE

	if(current_camera >= length(cameras))
		current_camera = 0
	user.forceMove(cameras[current_camera + 1])
	return TRUE

// Szept

/datum/action/cooldown/pulse_demon/whisper
	name = "Demoniczny szept"
	desc = "Przemawiasz wprost do umysłu kogoś w zasięgu wzroku."
	button_icon_state = "pulse_whisper"
	locked = FALSE
	cast_cost = 0
	level_max = 0
	base_cooldown = 0
	targeted = FALSE

/datum/action/cooldown/pulse_demon/whisper/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	var/list/valid_targets = list()
	for(var/mob/living/M in view(user.client?.view || world.view, get_turf(user)))
		if(M != user && M.mind && M.stat != DEAD)
			valid_targets += M
	if(!length(valid_targets))
		to_chat(user, "<span class='warning'>Nie ma nikogo, do kogo można by przemówić!</span>")
		return FALSE
	var/mob/living/choice = tgui_input_list(user, "Do kogo chcesz przemówić?", "Demoniczny szept", valid_targets)
	if(!choice || QDELETED(user) || QDELETED(choice))
		return FALSE
	var/msg = tgui_input_text(user, "Co chcesz powiedzieć [choice]?", "Demoniczny szept")
	if(!msg || QDELETED(user) || QDELETED(choice))
		return FALSE
	user.log_talk(msg, LOG_SAY, tag = "pulse demon whisper to [key_name(choice)]")
	to_chat(user, "<span class='notice'><b>Szepczesz do [choice]:</b> [msg]</span>")
	to_chat(choice, "<span class='deadsay'><b>Nagle w twojej głowie rozbrzmiewa dziwny, trzeszczący głos...</b></span> <i><span class='danger'>[msg]</span></i>")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Demoniczny szept od <b>[user]</b> [FOLLOW_LINK(G, user)] do <b>[choice]</b> [FOLLOW_LINK(G, choice)]: [msg]</i>")
	return TRUE

// Menu zdolności

/datum/action/cooldown/pulse_demon/open_menu
	name = "Menu zdolności"
	desc = "Kupuj i ulepszaj zdolności za przejęte APC, ulepszaj swoje ciało i ustaw tempo wysysania."
	button_icon_state = "pd_upgrade"
	locked = FALSE
	cast_cost = 0
	level_max = 0
	base_cooldown = 0
	targeted = FALSE

/datum/action/cooldown/pulse_demon/open_menu/try_cast_action(mob/living/simple_animal/pulse_demon/user, atom/target)
	if(!user.ability_menu)
		user.ability_menu = new(user)
	user.ability_menu.ui_interact(user)
	return TRUE

/// Okno zakupów demona, odpowiednik emporium changelinga
/datum/pulse_demon_menu
	var/mob/living/simple_animal/pulse_demon/demon
	var/static/list/body_upgrade_descs = list(
		PD_UPGRADE_HIJACK_SPEED = "Skraca czas przejmowania APC o 3 s (najmniej 6 s).",
		PD_UPGRADE_DRAIN_SPEED = "Pozwala wysysać o 20 kW więcej na cykl.",
		PD_UPGRADE_MAX_HEALTH = "Zwiększa maksymalne zdrowie o połowę (najwyżej 200).",
		PD_UPGRADE_HEALTH_REGEN = "Leczysz o 2 zdrowia więcej na cykl z zasilaniem.",
		PD_UPGRADE_HEALTH_LOSS = "Tracisz o 1 zdrowia mniej na cykl bez zasilania.",
		PD_UPGRADE_HEALTH_COST = "Leczenie wymaga o 1/3 mniej prądu, a nadwyżka z kabla trafia do zapasu.",
		PD_UPGRADE_MAX_CHARGE = "Mieścisz o 50 kJ energii więcej.",
	)

/datum/pulse_demon_menu/New(mob/living/simple_animal/pulse_demon/new_demon)
	. = ..()
	demon = new_demon

/datum/pulse_demon_menu/Destroy()
	demon = null
	return ..()

/datum/pulse_demon_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/pulse_demon_menu/ui_status(mob/user, datum/ui_state/state)
	if(user != demon || demon.stat == DEAD)
		return UI_CLOSE
	return ..()

/datum/pulse_demon_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PulseDemonMenu", "Zdolności demona impulsu")
		ui.open()

/datum/pulse_demon_menu/ui_data(mob/user)
	var/list/data = list()
	data["apcs_remaining"] = demon.apcs_remaining
	data["hijacked_apcs"] = length(demon.hijacked_apcs)
	data["charge"] = display_joules(demon.charge)
	data["maxcharge"] = display_joules(demon.maxcharge)
	data["power_status"] = demon.power_status
	data["controlling_area"] = demon.controlling_area ? "[demon.controlling_area.name]" : null
	data["drain_rate"] = demon.power_drain_rate
	data["max_drain_rate"] = demon.max_drain_rate
	data["do_drain"] = demon.do_drain
	data["show_cables"] = demon.show_cables

	var/list/abilities = list()
	for(var/i in 1 to length(demon.pulse_actions))
		var/datum/action/cooldown/pulse_demon/action = demon.pulse_actions[i]
		if(istype(action, /datum/action/cooldown/pulse_demon/open_menu))
			continue
		abilities += list(list(
			"id" = i,
			"name" = action.base_name,
			"desc" = action.base_desc,
			"owned" = !action.locked,
			"unlock_cost" = action.unlock_cost,
			"upgrade_cost" = action.upgrade_cost,
			"level" = action.level,
			"level_max" = action.level_max,
			"cast_cost" = action.cast_cost ? display_joules(action.cast_cost) : null,
			"cooldown" = action.cooldown_time ? "[action.cooldown_time / 10] s" : null,
			"requires_area" = action.requires_area,
		))
	data["abilities"] = abilities

	var/list/body = list()
	for(var/upgrade in body_upgrade_descs)
		body += list(list(
			"name" = upgrade,
			"desc" = body_upgrade_descs[upgrade],
			"cost" = calc_body_cost(upgrade),
		))
	data["body_upgrades"] = body
	return data

/datum/pulse_demon_menu/ui_act(action, params)
	if(..())
		return
	if(QDELETED(demon) || demon.stat == DEAD)
		return
	switch(action)
		if("buy", "upgrade")
			var/index = text2num(params["id"])
			if(!index || index < 1 || index > length(demon.pulse_actions))
				return
			var/datum/action/cooldown/pulse_demon/ability = demon.pulse_actions[index]
			return action == "buy" ? ability.buy(demon) : ability.upgrade(demon)
		if("body")
			return buy_body_upgrade(params["name"])
		if("drain_rate")
			var/rate = text2num(params["rate"])
			if(isnull(rate))
				return
			demon.power_drain_rate = clamp(round(rate), 1000, demon.max_drain_rate)
			return TRUE
		if("toggle_cables")
			demon.show_cables = !demon.show_cables
			demon.update_cableview(TRUE)
			return TRUE

/// Koszt ulepszenia ciała w APC albo -1, gdy jest już maksymalne
/datum/pulse_demon_menu/proc/calc_body_cost(upgrade)
	switch(upgrade)
		if(PD_UPGRADE_HIJACK_SPEED)
			if(demon.hijack_time <= 6 SECONDS)
				return -1
			return demon.hijack_time > 12 SECONDS ? 1 : 2
		if(PD_UPGRADE_DRAIN_SPEED)
			return demon.max_drain_rate >= 500000 ? -1 : 1
		if(PD_UPGRADE_MAX_HEALTH)
			if(demon.maxHealth >= 200)
				return -1
			return demon.maxHealth <= 100 ? 1 : 2
		if(PD_UPGRADE_HEALTH_REGEN)
			return demon.health_regen_rate >= 10 ? -1 : 1
		if(PD_UPGRADE_HEALTH_LOSS)
			if(demon.health_loss_rate <= 0)
				return -1
			return demon.health_loss_rate >= 3 ? 1 : 2
		if(PD_UPGRADE_HEALTH_COST)
			return demon.power_per_regen <= 1000 ? -1 : 1
		if(PD_UPGRADE_MAX_CHARGE)
			return 1
	return -1

/datum/pulse_demon_menu/proc/buy_body_upgrade(choice)
	var/cost = calc_body_cost(choice)
	if(cost == -1)
		return FALSE
	if(demon.apcs_remaining < cost)
		to_chat(demon, "<span class='warning'>Masz za mało niewydanych APC na to ulepszenie!</span>")
		return FALSE

	demon.apcs_remaining -= cost
	switch(choice)
		if(PD_UPGRADE_HIJACK_SPEED)
			demon.hijack_time = max(round(demon.hijack_time - 3 SECONDS), 6 SECONDS)
		if(PD_UPGRADE_DRAIN_SPEED)
			var/old = demon.max_drain_rate
			demon.max_drain_rate += 20000
			if(demon.power_drain_rate == old)
				demon.power_drain_rate = demon.max_drain_rate
		if(PD_UPGRADE_MAX_HEALTH)
			demon.maxHealth = min(round(demon.maxHealth * 1.5), 200)
			demon.updatehealth()
		if(PD_UPGRADE_HEALTH_REGEN)
			demon.health_regen_rate = min(round(demon.health_regen_rate + 2), 10)
		if(PD_UPGRADE_HEALTH_LOSS)
			demon.health_loss_rate = max(round(demon.health_loss_rate - 1), 0)
		if(PD_UPGRADE_HEALTH_COST)
			demon.power_per_regen = max(round(demon.power_per_regen / 1.5), 1)
		if(PD_UPGRADE_MAX_CHARGE)
			demon.maxcharge += 50000
	to_chat(demon, "<span class='notice'>Ulepszasz: [choice].</span>")
	return TRUE

#undef PULSEDEMON_REMOTE_DRAIN_MULTIPLIER
#undef PD_UPGRADE_HIJACK_SPEED
#undef PD_UPGRADE_DRAIN_SPEED
#undef PD_UPGRADE_HEALTH_LOSS
#undef PD_UPGRADE_HEALTH_REGEN
#undef PD_UPGRADE_MAX_HEALTH
#undef PD_UPGRADE_HEALTH_COST
#undef PD_UPGRADE_MAX_CHARGE
