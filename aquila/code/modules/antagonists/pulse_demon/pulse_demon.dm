// AQUILA - demon impulsu (port z ParadiseSS13, pierwowzór: https://ss13.moe/wiki/index.php/Pulse_Demon)
// Żyje w kablach, przejmuje APC, kradnie prąd i bawi się maszynami w przejętych pomieszczeniach.
// Energia demona jest w dżulach, a pobór z sieci w watach na tick Life, tak jak w Paradise.

#define PULSEDEMON_PLATING_SPARK_CHANCE 20
#define PULSEDEMON_APC_CHARGE_MULTIPLIER 2
#define PULSEDEMON_SMES_DRAIN_MULTIPLIER 10
/// Przelicznik W na ładunek SMES-a, ten sam co SMESRATE w smes.dm (tam #undef)
#define PULSEDEMON_SMESRATE 0.05
/// Co tyle ticków Life odświeża się podgląd kabli, żeby było widać nowo położone
#define PULSEDEMON_CABLEVIEW_REFRESH 15
/// Pod nienaruszoną podłogą demona widzą tylko duchy i on sam
#define PULSEDEMON_INVISIBILITY 35
#define ALERT_CATEGORY_NOPOWER "pulse_nopower"
#define ALERT_CATEGORY_NOREGEN "pulse_noregen"

/mob/living/simple_animal/pulse_demon
	name = "pulse demon"
	real_name = "demon impulsu"
	desc = "A strange electrical apparition that lives in wires."
	icon = 'aquila/icons/mob/pulse_demon.dmi'
	icon_state = "pulsedem"
	icon_living = "pulsedem"
	icon_dead = "pulsedem"
	// Bardzo odporny na zwykłe obrażenia. Na demona impulsu bierze się jony i EMP.
	damage_coeff = list(BRUTE = 0.25, BURN = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	speak_emote = list("moduluje", "wibruje", "skwierczy")
	response_help = "wkłada rękę w"
	response_disarm = "przepycha rękę przez"
	response_harm = "przebija pięścią"
	deathmessage = "rozpada się w słabe iskry, zostawiając tylko smużkę dymu..."
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("demon")
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	maxHealth = 50
	health = 50
	healable = FALSE
	speed = -0.3
	mob_size = MOB_SIZE_TINY
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSDOORS | PASSTABLE | PASSMOB
	attacktext = "razi prądem"
	attack_sound = "sparks"
	melee_damage = 0
	combat_mode = TRUE
	stop_automated_movement = TRUE
	wander = FALSE
	see_in_dark = 8
	see_invisible = PULSEDEMON_INVISIBILITY
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	// Demon wchodzi do APC, kamer i cyborgów przez forceMove
	allow_movement_on_non_turfs = TRUE
	// Maszyny w przejętym obszarze traktują go jak SI
	has_unlimited_silicon_privilege = TRUE
	mobchatspan = "cultmobsay"
	loot = list(/obj/item/organ/heart/pulse_demon)
	del_on_death = TRUE

	/// Dźwięki przy mówieniu
	var/list/speech_sounds = list('aquila/sound/pulsedemon/pdvoice1.ogg', 'aquila/sound/pulsedemon/pdvoice2.ogg', 'aquila/sound/pulsedemon/pdvoice3.ogg')
	/// Dźwięki przy śmierci i trafieniu EMP
	var/list/hurt_sounds = list('aquila/sound/pulsedemon/pdwail1.ogg', 'aquila/sound/pulsedemon/pdwail2.ogg', 'aquila/sound/pulsedemon/pdwail3.ogg')

	/// Zgromadzona energia w J, wydawana na zdolności. Zmieniaj przez adjust_charge().
	var/charge = 100000
	/// Ile energii (J) demon może zmagazynować
	var/maxcharge = 100000
	/// Ile energii wyssał łącznie, do celu „wyssij prąd”
	var/charge_drained = 0
	/// Czy demon wysysa prąd ze źródeł, przełączane zdolnością
	var/do_drain = TRUE
	/// Ile W wysysa ze źródła co tick Life
	var/power_drain_rate = 20000
	/// Górna granica power_drain_rate, rośnie z ulepszeniami
	var/max_drain_rate = 100000

	/// Ile W musi dostać co tick, żeby się leczyć
	var/power_per_regen = 200000
	/// Ile zdrowia traci co tick bez zasilania
	var/health_loss_rate = 5
	/// Ile zdrowia odzyskuje co tick z zasilaniem
	var/health_regen_rate = 2
	/// Dopóki nie spadnie do 0, leczenie jest zablokowane (po EMP). Maleje co tick Life.
	var/regen_lock = 0
	/// Żeby kilka EMP w jednym ticku nie zabiło demona od razu
	var/emp_debounce = FALSE

	/// Czy może wychodzić z kabli, przełączane zdolnością
	var/can_exit_cable = FALSE
	/// Prędkość w kablach
	var/inside_cable_speed = -0.3
	/// Prędkość poza kablami, rośnie z ulepszeniem samopodtrzymania
	var/outside_cable_speed = 5

	/// Czas przejmowania APC i cyborgów
	var/hijack_time = 20 SECONDS

	/// Kolor poświaty. Zasięg światła rośnie z zapasem energii.
	var/glow_color = "#bbbb00"

	/// Kontrolowany obszar, trzymany dopóki demon nie wyjdzie z APC albo czegoś w tym obszarze
	var/area/controlling_area
	/// Kabel, w którym demon siedzi
	var/obj/structure/cable/current_cable
	/// Maszyna zasilająca, w której demon siedzi (albo APC w obszarze, gdy skacze po kamerach)
	var/obj/machinery/power/current_power
	/// Przejęta broń energetyczna
	var/obj/item/current_weapon
	/// Przejęty cyborg
	var/mob/living/silicon/robot/current_robot
	/// Przejęty bot
	var/mob/living/simple_animal/bot/current_bot

	/// Opóźnienie ruchu bota
	var/bot_movedelay = 0
	/// Raz przejętego cyborga można zająć ponownie od razu
	var/list/hijacked_robots = list()

	/// Obrazy kabli widoczne tylko dla demona, REF kabla -> obraz (bez twardych referencji do kabli)
	var/list/cable_images = list()
	/// Poziom, dla którego zbudowano podgląd kabli
	var/cableview_z
	/// Obrazy przejętych APC widoczne tylko dla demona
	var/list/apc_images = list()
	/// Wszystkie przejęte APC
	var/list/hijacked_apcs = list()
	/// Niewydane APC, waluta ulepszeń
	var/apcs_remaining = 0
	/// Czy przy ataku wydaje energię, żeby przebić izolację
	var/strong_shocks = FALSE
	/// APC, które właśnie przejmuje
	var/obj/machinery/power/apc/apc_being_hijacked
	/// Licznik ticków do odświeżenia podglądu kabli
	var/cableview_ticks = 0
	/// Skąd demon brał prąd w ostatnim ticku, do panelu Status
	var/power_status = "brak"
	/// Ujawniony po użyciu zdolności, widać go wtedy nawet pod podłogą
	var/revealed = FALSE
	/// Zdolności demona (akcje)
	var/list/datum/action/cooldown/pulse_demon/pulse_actions = list()
	/// Zdolność celowana, która czeka na kliknięcie
	var/datum/action/cooldown/pulse_demon/selected_action

/mob/living/simple_animal/pulse_demon/wizard
	name = "Empowered Pulse Demon"
	real_name = "wzmocniony demon impulsu"
	desc = "A strange electrical apparition that lives in wires. This one appears more charged than usual."

/mob/living/simple_animal/pulse_demon/wizard/Initialize(mapload)
	. = ..()
	apcs_remaining = 20
	maxcharge = 500000
	charge = 100000

/mob/living/simple_animal/pulse_demon/Initialize(mapload)
	. = ..()
	if(!mapload)
		name += " ([rand(100, 999)])"
		real_name = name

	access_card = new /obj/item/card/id(src)
	access_card.access = get_all_accesses()
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NOFIRE, INNATE_TRAIT)

	// Ktoś na nas wszedł
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
	RegisterSignal(src, COMSIG_ATOM_EMP_ACT, PROC_REF(handle_emp))

	current_power = locate(/obj/machinery/power) in loc
	// Bez maszyny i bez kabla demon zginie w następnym ticku
	if(!current_power)
		current_cable = locate(/obj/structure/cable) in loc
	// np. spawn przez admina poza kablem: bez tego demon zginąłby w pierwszym ticku
	if(!current_power && !current_cable)
		can_exit_cable = TRUE
	else
		forceMove(current_power)
		RegisterSignal(current_power, COMSIG_ATOM_EMP_ACT, PROC_REF(handle_emp), TRUE)
	update_glow()
	update_tile_visibility()
	playsound(get_turf(src), 'aquila/sound/pulsedemon/eleczap.ogg', 30, TRUE)
	give_actions()

/mob/living/simple_animal/pulse_demon/Destroy()
	if(client)
		client.images -= get_cable_images() + flatten_images(apc_images)
	cable_images.Cut()
	apc_images.Cut()
	controlling_area = null
	release_bot()
	current_cable = null
	current_power = null
	current_robot = null
	current_weapon = null
	if(apc_being_hijacked)
		apc_being_hijacked.being_hijacked = FALSE
		apc_being_hijacked = null
	selected_action = null
	QDEL_LIST(pulse_actions)
	hijacked_apcs = null
	hijacked_robots = null
	QDEL_NULL(access_card)
	return ..()

/mob/living/simple_animal/pulse_demon/Login()
	. = ..()
	update_cableview(TRUE)

/mob/living/simple_animal/pulse_demon/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, glow_color))
			. = ..()
			update_glow()
			return
		if(NAMEOF(src, charge))
			// sam podnosi maxcharge, żeby nowa wartość się zmieściła
			adjust_charge(var_value - charge, TRUE)
			return TRUE
	return ..()

/mob/living/simple_animal/pulse_demon/forceMove(atom/destination)
	var/old_location = loc
	. = ..()
	current_weapon = null
	current_robot = null
	release_bot()
	if(istype(old_location, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = old_location
		// ogniwo zostaje „uzbrojone”, gdy nie ma w nim już żadnego demona
		C.rigged = !(locate(/mob/living/simple_animal/pulse_demon) in old_location)
	if(istype(loc, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = loc
		C.rigged = FALSE
	// Poza polem ruchy trafiają do relaymove() demona, patrz pulse_demon_interactions.dm
	remote_control = isturf(loc) ? null : src
	update_tile_visibility()

/mob/living/simple_animal/pulse_demon/proc/give_actions()
	for(var/action_type in list(
		/datum/action/cooldown/pulse_demon/open_upgrades,
		/datum/action/cooldown/pulse_demon/whisper,
		/datum/action/cooldown/pulse_demon/cycle_camera,
		/datum/action/cooldown/pulse_demon/toggle/penetrating_shock,
		/datum/action/cooldown/pulse_demon/toggle/do_drain,
		/datum/action/cooldown/pulse_demon/toggle/can_exit_cable,
		/datum/action/cooldown/pulse_demon/cablehop,
		/datum/action/cooldown/pulse_demon/emagtamper,
		/datum/action/cooldown/pulse_demon/emp,
		/datum/action/cooldown/pulse_demon/overload,
		/datum/action/cooldown/pulse_demon/remotehijack,
		/datum/action/cooldown/pulse_demon/remotedrain,
	))
		var/datum/action/cooldown/pulse_demon/action = new action_type(src)
		action.Grant(src)
		pulse_actions += action
	for(var/datum/action/cooldown/pulse_demon/toggle/toggle in pulse_actions)
		toggle.sync_state(src)

/mob/living/simple_animal/pulse_demon/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Zasilanie"] = GENERATE_STAT_TEXT(power_status)
	tab_data["Energia"] = GENERATE_STAT_TEXT(display_joules(charge))
	tab_data["Maks. energia"] = GENERATE_STAT_TEXT(display_joules(maxcharge))
	tab_data["Wyssana energia"] = GENERATE_STAT_TEXT(display_joules(charge_drained))
	tab_data["Przejęte APC"] = GENERATE_STAT_TEXT("[length(hijacked_apcs)]")
	tab_data["Niewydane APC"] = GENERATE_STAT_TEXT("[apcs_remaining]")
	tab_data["Tempo wysysania"] = GENERATE_STAT_TEXT(display_power(power_drain_rate))
	tab_data["Czas przejęcia"] = GENERATE_STAT_TEXT("[hijack_time / 10] s")
	return tab_data

/mob/living/simple_animal/pulse_demon/gib()
	return death()

/mob/living/simple_animal/pulse_demon/dust(just_ash, drop_items, force)
	return death()

/mob/living/simple_animal/pulse_demon/death(gibbed)
	if(stat == DEAD)
		return
	// Serce ma wypaść na podłogę, a nie do APC
	var/turf/T = get_turf(src)
	if(T && loc != T)
		forceMove(T)
	do_sparks(rand(2, 4), FALSE, src)
	var/heavy_radius = min(charge / 50000, 20)
	var/light_radius = min(charge / 25000, 25)
	playsound(T, pick(hurt_sounds), 30, TRUE)
	. = ..()
	if(T)
		empulse(T, heavy_radius, light_radius)

/// Wychodzi z maszyny na pole pod nią
/mob/living/simple_animal/pulse_demon/proc/exit_to_turf()
	var/turf/T = get_turf(src)
	if(current_power)
		UnregisterSignal(current_power, COMSIG_ATOM_EMP_ACT)
	current_power = null
	update_controlling_area()
	current_cable = null
	forceMove(T)
	Move(T)
	if(!current_cable && !current_power && !can_exit_cable)
		var/datum/action/cooldown/pulse_demon/toggle/can_exit_cable/exit_action = locate() in pulse_actions
		if(exit_action && !exit_action.locked)
			can_exit_cable = TRUE
			exit_action.sync_state(src)
			to_chat(src, "<span class='danger'>Samopodtrzymanie włączyło się samo, żebyś nie zginął bez połączenia!</span>")

/mob/living/simple_animal/pulse_demon/proc/update_controlling_area(reset = FALSE)
	var/area/prev = controlling_area
	if(reset || !current_power)
		controlling_area = null
	else if(istype(current_power, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = current_power
		controlling_area = (A in hijacked_apcs) ? A.area : null

	if(!prev == !controlling_area)
		return // przyciski zmieniają się tylko, gdy zyskujemy albo tracimy jakikolwiek obszar
	for(var/datum/action/cooldown/pulse_demon/action as anything in pulse_actions)
		if(action.requires_area && !action.locked)
			action.UpdateButtonIcon()

/// Czy do tego APC da się wejść
/mob/living/simple_animal/pulse_demon/proc/is_valid_apc(obj/machinery/power/apc/A)
	return istype(A) && !(A.machine_stat & BROKEN) && !A.shorted

/mob/living/simple_animal/pulse_demon/Move(atom/newloc, direct, glide_size_override)
	var/obj/machinery/power/new_power = locate(/obj/machinery/power) in newloc
	var/obj/structure/cable/new_cable = locate(/obj/structure/cable) in newloc

	if(QDELETED(new_power))
		new_power = null
	if(QDELETED(new_cable))
		new_cable = null

	if(istype(new_power, /obj/machinery/power/terminal))
		// terminal nic nie daje, a pod działającym zawsze leży kabel
		new_power = null

	if(istype(new_power, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = new_power
		if(!is_valid_apc(A) || !A.terminal)
			new_power = null // nie wchodzimy do zepsutego APC albo bez terminala

	// w kosmosie nie ma prądu
	if(!new_cable && !new_power && (!can_exit_cable || isspaceturf(newloc)))
		return FALSE

	var/moved = ..()

	if(!new_cable && !new_power)
		if(can_exit_cable && moved)
			set_varspeed(outside_cable_speed)
	else if(speed != inside_cable_speed)
		set_varspeed(inside_cable_speed)

	if(moved && !is_under_tile() && prob(PULSEDEMON_PLATING_SPARK_CHANCE))
		do_sparks(rand(2, 4), FALSE, src)

	current_weapon = null
	current_robot = null
	release_bot()

	// Nie wolno tu wołać do_after, Move nie może spać
	if(new_power)
		if(current_power)
			UnregisterSignal(current_power, COMSIG_ATOM_EMP_ACT)
		current_power = new_power
		current_cable = null
		forceMove(current_power) // wchodzimy do środka maszyny
		RegisterSignal(current_power, COMSIG_ATOM_EMP_ACT, PROC_REF(handle_emp), TRUE)
		playsound(src, 'aquila/sound/pulsedemon/eleczap.ogg', 15, TRUE)
		do_sparks(rand(2, 4), FALSE, src)
		if(istype(current_power, /obj/machinery/power/apc))
			if(current_power in hijacked_apcs)
				update_controlling_area()
			else
				INVOKE_ASYNC(src, PROC_REF(try_hijack_apc), current_power)
	else if(new_cable)
		current_cable = new_cable
		if(current_power)
			UnregisterSignal(current_power, COMSIG_ATOM_EMP_ACT)
		current_power = null
		update_controlling_area()
		if(!moved)
			forceMove(newloc)
	else if(moved)
		current_cable = null
		if(current_power)
			UnregisterSignal(current_power, COMSIG_ATOM_EMP_ACT)
		current_power = null
		update_controlling_area()
	return moved

/mob/living/simple_animal/pulse_demon/onTransitZ(old_z, new_z)
	. = ..()
	update_cableview()

/mob/living/simple_animal/pulse_demon/proc/adjust_charge(amount, adjust_max = FALSE)
	if(!amount)
		return FALSE
	if(adjust_max)
		maxcharge = max(maxcharge, charge + amount)
	var/orig = charge
	charge = clamp(charge + amount, 0, maxcharge)
	var/realdelta = charge - orig
	if(!realdelta)
		return FALSE
	if(realdelta > 0)
		charge_drained += realdelta

	update_glow()
	for(var/datum/action/cooldown/pulse_demon/action as anything in pulse_actions)
		if(action.locked || !action.cast_cost)
			continue
		var/dist = action.cast_cost - orig
		// odświeżamy przycisk tylko, gdy zmiana przekroczyła koszt zdolności
		if(dist == 0 || (dist > 0 && realdelta >= dist) || (dist < 0 && realdelta <= dist))
			action.UpdateButtonIcon()
	return realdelta

/// Zasięg poświaty rośnie liniowo z energią: 1.5 przy 300 kJ, 3 przy 600 kJ, maks. 5
/mob/living/simple_animal/pulse_demon/proc/update_glow()
	set_light(clamp(charge / 200000, 1.5, 5), 2, glow_color)

/// Na chwilę ujawnia demona, także pod podłogą
/mob/living/simple_animal/pulse_demon/proc/reveal(reveal_time)
	revealed = TRUE
	update_tile_visibility()
	do_sparks(rand(2, 4), FALSE, src)
	addtimer(CALLBACK(src, PROC_REF(unreveal)), reveal_time, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/pulse_demon/proc/unreveal()
	revealed = FALSE
	update_tile_visibility()

/// Pod podłogą widzą go tylko duchy, chyba że się ujawni zdolnością
/mob/living/simple_animal/pulse_demon/proc/update_tile_visibility()
	if(isturf(loc) && is_under_tile() && !revealed)
		invisibility = PULSEDEMON_INVISIBILITY
	else
		invisibility = 0

/// Zwraca wyssane W albo PULSEDEMON_SOURCE_DRAIN_INVALID, gdy APC jest właśnie przejmowane
/mob/living/simple_animal/pulse_demon/proc/drain_APC(obj/machinery/power/apc/A, multiplier = 1)
	if(A.being_hijacked)
		return PULSEDEMON_SOURCE_DRAIN_INVALID
	if(!A.cell)
		return 0
	// CELLRATE przelicza W na jednostki ładunku ogniwa
	var/amount_to_drain = clamp(A.cell.charge / GLOB.CELLRATE, 0, power_drain_rate * multiplier)
	// mnożnik APC nie zwiększa tego, co faktycznie ubywa z ogniwa
	A.cell.use(min(amount_to_drain, maxcharge - charge) * GLOB.CELLRATE)
	return adjust_charge(amount_to_drain * PULSEDEMON_APC_CHARGE_MULTIPLIER)

/mob/living/simple_animal/pulse_demon/proc/drain_SMES(obj/machinery/power/smes/S, multiplier = 1)
	var/amount_to_drain = clamp(S.charge / PULSEDEMON_SMESRATE, 0, power_drain_rate * multiplier * PULSEDEMON_SMES_DRAIN_MULTIPLIER)
	var/drained = adjust_charge(amount_to_drain)
	S.charge = max(S.charge - drained * PULSEDEMON_SMESRATE, 0)
	return drained

/mob/living/simple_animal/pulse_demon/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return

	if(client && ++cableview_ticks >= PULSEDEMON_CABLEVIEW_REFRESH)
		update_cableview()

	var/got_power = FALSE
	if(current_cable)
		// wystarczy, że w kablu jest prąd; bierzemy tyle, ile zostało, najwyżej power_per_regen
		if(current_cable.avail() > 0)
			current_cable.add_load(min(current_cable.surplus(), power_per_regen))
			got_power = TRUE
			power_status = "kabel"
			// po ulepszeniu „Wydajność” nadwyżka ponad koszt leczenia trafia do zapasu
			var/excess = initial(power_per_regen) - power_per_regen
			if(excess > 0 && do_drain && current_cable.surplus() >= excess)
				adjust_charge(excess)
				current_cable.add_load(excess)
	else if(current_power)
		if(istype(current_power, /obj/machinery/power/apc) && loc == current_power && do_drain)
			// zasila nas samo ogniwo, nawet gdy przy pełnym zapasie nic już nie wysysamy
			var/obj/machinery/power/apc/A = current_power
			// ładunek sprawdzamy przed wysysaniem, które może opróżnić ogniwo do zera
			got_power = A.cell?.charge > 0
			if(got_power)
				power_status = "ogniwo APC"
			drain_APC(A)
		else if(istype(current_power, /obj/machinery/power/smes) && do_drain)
			var/obj/machinery/power/smes/S = current_power
			got_power = S.charge > 0
			if(got_power)
				power_status = "SMES"
			drain_SMES(S)
		// pusty APC albo SMES (albo demon skacze po kamerach): bierzemy z sieci, w przypadku APC przez terminal
		var/obj/machinery/power/net_source = current_power
		if(istype(current_power, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/apc_source = current_power
			net_source = apc_source.terminal
		if(!got_power && net_source?.surplus() >= power_per_regen)
			net_source.add_load(power_per_regen)
			got_power = TRUE
			power_status = "sieć"
	else if(!can_exit_cable)
		death()
		return

	if(got_power)
		if(regen_lock <= 0)
			adjustHealth(-health_regen_rate)
		clear_alert(ALERT_CATEGORY_NOPOWER)
	else
		var/rate = health_loss_rate
		if(!current_cable && !current_power && can_exit_cable)
			// poza kablem tracimy podwójnie (minus ulepszenia)
			rate += initial(health_loss_rate)
		adjustHealth(rate)
		power_status = "BRAK - tracisz zdrowie!"
		throw_alert(ALERT_CATEGORY_NOPOWER, /atom/movable/screen/alert/pulse_nopower)

	if(regen_lock > 0 && --regen_lock == 0)
		clear_alert(ALERT_CATEGORY_NOREGEN)

/// Losowe znaczki zamiast imienia przy mówieniu przez radio
/mob/living/simple_animal/pulse_demon/proc/gen_speech_name()
	. = ""
	for(var/i in 1 to 10)
		. += pick("!", "@", "#", "$", "%", "^", "&", "*")

// Zwykła mowa nie dochodzi do nikogo: demon mówi tylko przez radio, holopad i przejętego cyborga.
// Wyciszenia, sanityzacja i logi zostają w standardowym say().
/mob/living/simple_animal/pulse_demon/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language = null, list/message_mods = list())
	if(stat == DEAD)
		return ..()
	if(current_robot)
		log_admin("[key_name(src)] made [key_name(current_robot)] say: [message]")
		message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(src)] made [ADMIN_LOOKUPFLW(current_robot)] say: [message]</span>")
		current_robot.say(message, language = message_language, forced = "pulse demon")
		return
	playsound(get_turf(src), pick(speech_sounds), 30, TRUE)
	if(istype(loc, /obj/item/radio))
		var/obj/item/radio/R = loc
		name = gen_speech_name()
		R.talk_into(src, message, null, spans, message_language, message_mods)
		name = real_name
		return
	if(istype(loc, /obj/machinery/holopad))
		var/obj/machinery/holopad/H = loc
		H.say(message, language = message_language, forced = "pulse demon")
		return
	to_chat(src, "<span class='warning'>Bez radia, holopadu albo przejętego cyborga słychać tylko trzaski.</span>")

/mob/living/simple_animal/pulse_demon/proc/try_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	// jedno APC naraz, jeden demon na APC, bez duplikatów
	if(!is_valid_apc(A) || (A in hijacked_apcs) || apc_being_hijacked || A.being_hijacked)
		return FALSE

	to_chat(src, "<span class='notice'>Próbujesz przejąć [A], to potrwa około [hijack_time / 10] sekund.</span>")
	apc_being_hijacked = A
	A.being_hijacked = TRUE
	A.update_icon()
	if(do_after(src, hijack_time, target = A, progress = TRUE))
		if(is_valid_apc(A))
			finish_hijack_apc(A, remote)
		else
			to_chat(src, "<span class='warning'>Nie udało się przejąć [A].</span>")
	apc_being_hijacked = null
	if(!QDELETED(A))
		A.being_hijacked = FALSE
		A.update_icon()
	return TRUE

/// Maks. energia rośnie o 25 kJ za każde przejęte APC
/mob/living/simple_animal/pulse_demon/proc/calc_maxcharge(hijacked_count)
	return 100000 + hijacked_count * 25000

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_apc(obj/machinery/power/apc/A, remote = FALSE)
	apcs_remaining++
	hijacked_apcs += A
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(apc_deleted_handler))
	add_apc_image(A)
	if(!remote)
		update_controlling_area()
	maxcharge = calc_maxcharge(length(hijacked_apcs)) + (maxcharge - calc_maxcharge(length(hijacked_apcs) - 1))
	to_chat(src, "<span class='notice'>Przejęcie zakończone! Kontrolujesz [length(hijacked_apcs)] APC i masz [apcs_remaining] do wydania.</span>")

/mob/living/simple_animal/pulse_demon/proc/apc_deleted_handler(obj/machinery/power/apc/A, force)
	SIGNAL_HANDLER
	hijacked_apcs -= A
	var/turf/T = get_turf(A)
	if(T && apc_images[T])
		client?.images -= apc_images[T]
		apc_images -= T

/mob/living/simple_animal/pulse_demon/proc/on_atom_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(entered != src)
		try_cross_shock(entered)

/mob/living/simple_animal/pulse_demon/proc/on_movable_moved(datum/source, old_location, direction, forced)
	SIGNAL_HANDLER
	update_tile_visibility()
	if(!isturf(loc) || is_under_tile())
		return
	for(var/mob/living/victim in loc)
		if(victim != src)
			try_shock_mob(victim)

/mob/living/simple_animal/pulse_demon/proc/try_cross_shock(atom/movable/A)
	if(!isliving(A) || !isturf(loc) || is_under_tile())
		return
	try_shock_mob(A)

/mob/living/simple_animal/pulse_demon/proc/try_shock_mob(mob/living/L, siemens_coeff = 1)
	var/dealt = 0
	if(current_cable?.powernet?.avail)
		// zwraca zużytą energię, nie obrażenia; /20 daje przybliżone obrażenia
		dealt = electrocute_mob(L, current_cable.powernet, src, siemens_coeff) / 20
	else
		dealt = L.electrocute_act(30, src, siemens_coeff)
	if(dealt > 0)
		do_sparks(rand(2, 4), FALSE, src)
	else if(strong_shocks)
		if(charge >= 200000)
			adjust_charge(-200000)
			do_sparks(rand(2, 4), FALSE, src)
			// safety = TRUE pomija rękawice izolacyjne
			dealt = L.electrocute_act(30, src, 1, TRUE)
		else
			to_chat(src, "<span class='danger'>Masz za mało energii, by przebić izolację! Potrzebujesz co najmniej 200 kJ.</span>")
	log_combat(src, L, "shocked", addition = "([dealt] damage)")

/// Czy demon siedzi pod nienaruszoną podłogą
/mob/living/simple_animal/pulse_demon/proc/is_under_tile()
	var/turf/T = get_turf(src)
	return T?.intact

/// Spłaszcza listę pole -> obrazy w jedną listę obrazów
/mob/living/simple_animal/pulse_demon/proc/flatten_images(list/images_by_turf)
	. = list()
	for(var/turf in images_by_turf)
		. += images_by_turf[turf]

/// Obraz kabla albo przejętego APC rysowany nad oświetleniem, widoczny tylko dla demona
/mob/living/simple_animal/pulse_demon/proc/make_overlay_image(atom/source, icon_file, state, atom/image_loc = source)
	var/image/I = image(icon_file, image_loc, state, ABOVE_LIGHTING_LAYER, source.dir)
	I.plane = ABOVE_LIGHTING_PLANE
	I.color = source.color
	I.pixel_x = source.pixel_x
	I.pixel_y = source.pixel_y
	return I

/mob/living/simple_animal/pulse_demon/proc/add_apc_image(obj/machinery/power/apc/A)
	var/turf/T = get_turf(A)
	var/turf/our_turf = get_turf(src)
	if(!T || !our_turf || !client || T.z != our_turf.z)
		return
	var/image/apc_image = make_overlay_image(A, 'icons/obj/power.dmi', "apcemag")
	apc_image.color = null
	LAZYADD(apc_images[T], apc_image)
	client.images += apc_image

/mob/living/simple_animal/pulse_demon/proc/get_cable_images()
	. = list()
	for(var/cable in cable_images)
		. += cable_images[cable]

/// Podgląd kabli i przejętych APC na tym poziomie. Pełna przebudowa tylko przy zmianie poziomu albo full = TRUE,
/// okresowe odświeżenie dokłada nowe kable i usuwa zniszczone.
/mob/living/simple_animal/pulse_demon/proc/update_cableview(full = FALSE)
	cableview_ticks = 0
	if(!client)
		return
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	if(full || cableview_z != our_turf.z)
		client.images -= get_cable_images() + flatten_images(apc_images)
		cable_images.Cut()
		apc_images.Cut()
		cableview_z = our_turf.z
		for(var/obj/machinery/power/apc/A as anything in hijacked_apcs)
			add_apc_image(A)

	var/list/removed_images = list()
	for(var/cable_ref in cable_images.Copy())
		var/obj/structure/cable/C = locate(cable_ref)
		if(!istype(C) || QDELETED(C) || C.z != cableview_z)
			removed_images += cable_images[cable_ref]
			cable_images -= cable_ref
	if(length(removed_images))
		client.images -= removed_images

	var/list/new_images = list()
	for(var/datum/powernet/P as anything in SSmachines.powernets)
		for(var/obj/structure/cable/C as anything in P.cables)
			if(C.z != cableview_z || cable_images[REF(C)])
				continue // kable wielopoziomowe łączą sieci między poziomami
			// obraz wisi na polu, a nie na kablu, żeby nie trzymać zniszczonych kabli
			var/image/cable_image = make_overlay_image(C, C.icon, C.icon_state, C.loc)
			cable_images[REF(C)] = cable_image
			new_images += cable_image
	if(length(new_images))
		client.images += new_images

/mob/living/simple_animal/pulse_demon/proc/handle_emp(datum/source, severity)
	SIGNAL_HANDLER
	if(emp_debounce)
		return
	visible_message("<span class='danger'>[src] [pick("skwierczy", "zawodzi", "miota się")] w agonii!</span>")
	playsound(get_turf(src), pick(hurt_sounds), 30, TRUE)
	throw_alert(ALERT_CATEGORY_NOREGEN, /atom/movable/screen/alert/pulse_noregen)
	switch(severity)
		if(EMP_LIGHT)
			adjustHealth(round(max(initial(health) / 4, maxHealth / 8)))
			regen_lock = 5
		if(EMP_HEAVY)
			adjustHealth(round(max(initial(health) / 3, maxHealth / 6)))
			regen_lock = 8
	emp_debounce = TRUE
	addtimer(VARSET_CALLBACK(src, emp_debounce, FALSE), 0.1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/pulse_demon/proc/try_attack_mob(mob/living/L)
	if(!is_under_tile() && L != src)
		do_attack_animation(L)
		try_shock_mob(L)

/mob/living/simple_animal/pulse_demon/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(isliving(A))
		try_attack_mob(A)
		return
	if(isitem(A) && !is_under_tile())
		var/obj/item/O = A
		var/obj/item/stock_parts/cell/C = O.get_cell()
		if(C?.charge)
			var/drained = min(C.charge / GLOB.CELLRATE, power_drain_rate)
			C.use(drained * GLOB.CELLRATE)
			adjust_charge(drained)
			O.update_icon()
			visible_message("<span class='notice'>[src] dotyka [O] i wysysa z tego prąd!</span>", "<span class='notice'>Dotykasz [O] i wysysasz z tego prąd!</span>")

/mob/living/simple_animal/pulse_demon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(is_under_tile())
		to_chat(user, "<span class='danger'>Nie dosięgniesz czegoś, co jest pod podłogą!</span>")
		return
	if(user.combat_mode)
		visible_message("<span class='warning'>[user] [response_harm] [src].</span>")
	else
		visible_message("<span class='notice'>[user] [response_help] [src].</span>")
	try_attack_mob(user)

/mob/living/simple_animal/pulse_demon/attackby(obj/item/O, mob/living/user, params)
	if(is_under_tile())
		to_chat(user, "<span class='danger'>Nie dosięgniesz czegoś, co jest pod podłogą!</span>")
		return TRUE
	var/obj/item/stock_parts/cell/C = O.get_cell()
	if(C?.charge)
		var/drained = min(C.charge / GLOB.CELLRATE, power_drain_rate)
		C.use(drained * GLOB.CELLRATE)
		adjust_charge(drained)
		O.update_icon()
		to_chat(user, "<span class='warning'>Dotykasz [src] przedmiotem [O], a [src] wysysa z niego prąd!</span>")
		to_chat(src, "<span class='notice'>[user] dotyka cię przedmiotem [O], a ty wysysasz z niego prąd!</span>")
	visible_message("<span class='notice'>[O] przechodzi prosto przez [src].</span>")
	try_shock_mob(user, O.siemens_coefficient)
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE

/mob/living/simple_animal/pulse_demon/ex_act(severity, target, origin)
	return

/mob/living/simple_animal/pulse_demon/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /obj/item/projectile/ion))
		return FALSE

/mob/living/simple_animal/pulse_demon/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(P.damage_type == BURN)
		regen_lock = max(regen_lock, 1)
		return ..()
	visible_message("<span class='warning'>[P] przelatuje prosto przez [src]!</span>")
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/pulse_demon/electrocute_act(shock_damage, source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	return FALSE

/mob/living/simple_animal/pulse_demon/blob_act(obj/structure/blob/B)
	return // i tak zginie, jeśli blob przetnie mu kable

/mob/living/simple_animal/pulse_demon/narsie_act()
	return // prądu nie da się zamienić w żniwiarza

/mob/living/simple_animal/pulse_demon/IsAdvancedToolUser()
	return TRUE // obsługuje maszyny

/mob/living/simple_animal/pulse_demon/can_be_pulled(user, grab_state, force)
	return FALSE

/mob/living/simple_animal/pulse_demon/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	return

/mob/living/simple_animal/pulse_demon/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	return // przepływ gazu go nie rusza

/mob/living/simple_animal/pulse_demon/singularity_pull(S, current_size)
	return

/mob/living/simple_animal/pulse_demon/mob_negates_gravity()
	return TRUE

/mob/living/simple_animal/pulse_demon/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0) // obrażenia
		return ..()
	// poza maszyną leczy się najwyżej do połowy zdrowia
	if(!ismachinery(loc))
		if(health >= maxHealth / 2)
			amount = 0
		else
			amount = clamp(amount, -((maxHealth / 2) - health), 0)
	amount = round(amount, 1)
	if(!amount)
		return 0
	return ..()

/atom/movable/screen/alert/pulse_nopower
	name = "Brak zasilania"
	desc = "Nie jesteś podłączony do kabla ani maszyny i tracisz zdrowie!"
	icon = 'aquila/icons/mob/pulse_demon.dmi'
	icon_state = "pd_nopower"

/atom/movable/screen/alert/pulse_noregen
	name = "Regeneracja wstrzymana"
	desc = "Trafił cię EMP i nie możesz się leczyć!"
	icon = 'aquila/icons/mob/pulse_demon.dmi'
	icon_state = "pd_noregen"

#undef PULSEDEMON_PLATING_SPARK_CHANCE
#undef PULSEDEMON_APC_CHARGE_MULTIPLIER
#undef PULSEDEMON_SMES_DRAIN_MULTIPLIER
#undef PULSEDEMON_SMESRATE
#undef PULSEDEMON_CABLEVIEW_REFRESH
#undef PULSEDEMON_INVISIBILITY
#undef ALERT_CATEGORY_NOPOWER
#undef ALERT_CATEGORY_NOREGEN
