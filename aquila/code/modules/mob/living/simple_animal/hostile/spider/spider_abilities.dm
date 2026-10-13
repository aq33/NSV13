// AQUILA - zdolności pająków (tg: /datum/action/cooldown/mob_cooldown/*)

/**
 * Wspólna podstawa zdolności pająków. Zastępuje tg-owe mob_cooldown:
 * pilnuje przytomności, czasu odnowienia i tego, czy pająk nie jest zajęty czymś innym.
 */
/datum/action/cooldown/spider
	icon_icon = 'aquila/icons/mob/actions/actions_spider.dmi'
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	/// Czy zdolność trzeba wycelować kliknięciem
	var/click_to_activate = FALSE
	/// Kursor podczas celowania
	var/targeting_pointer = null
	/// Czy właśnie celujemy
	var/targeting = FALSE
	/// Przycisk idzie na sam początek paska akcji (przed sieć), żeby się nie pomylił
	var/button_first = FALSE

/datum/action/cooldown/spider/Remove(mob/M)
	if(targeting)
		stop_targeting(FALSE)
	return ..()

/datum/action/cooldown/spider/IsAvailable()
	if(!owner || owner.stat)
		return FALSE
	if(next_use_time > world.time)
		return FALSE
	return TRUE

/// Zwraca powód, dla którego zdolności nie da się teraz użyć, albo null
/datum/action/cooldown/spider/proc/unavailable_reason()
	if(owner_busy())
		return "zajęty!"
	return null

/datum/action/cooldown/spider/proc/owner_busy()
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	return istype(spider_owner) && spider_owner.busy

/datum/action/cooldown/spider/Trigger()
	if(!IsAvailable())
		return FALSE
	var/reason = unavailable_reason()
	if(reason)
		owner.balloon_alert(owner, reason)
		return FALSE
	if(click_to_activate)
		if(targeting)
			stop_targeting()
		else
			start_targeting()
		return TRUE
	return Activate()

/datum/action/cooldown/spider/proc/Activate(atom/target)
	return FALSE

/// Ustawia odnowienie na podany czas (0 zeruje)
/datum/action/cooldown/spider/proc/start_spider_cooldown(time = cooldown_time)
	var/old_time = cooldown_time
	cooldown_time = time
	StartCooldown()
	cooldown_time = old_time

/// Ustawia blokadę na czas trwania zdolności
/datum/action/cooldown/spider/proc/set_busy(state)
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	if(istype(spider_owner))
		spider_owner.busy = state
	UpdateButtonIcon(TRUE)

/datum/action/cooldown/spider/proc/start_targeting()
	if(!owner?.client)
		return
	if(owner.click_intercept && owner.click_intercept != src)
		return
	owner.click_intercept = src
	targeting = TRUE
	if(targeting_pointer)
		owner.client.mouse_pointer_icon = targeting_pointer
	on_targeting_changed()

/datum/action/cooldown/spider/proc/stop_targeting(feedback = TRUE)
	targeting = FALSE
	if(owner && owner.click_intercept == src)
		owner.click_intercept = null
		owner.update_mouse_pointer()
	on_targeting_changed(feedback)

/datum/action/cooldown/spider/proc/on_targeting_changed(feedback = TRUE)
	return

/datum/action/cooldown/spider/proc/InterceptClickOn(mob/living/caller, params, atom/clicked)
	if(caller != owner || !targeting)
		return FALSE
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
		return FALSE
	if(!IsAvailable())
		stop_targeting(FALSE)
		return TRUE
	caller.face_atom(clicked)
	if(Activate(clicked))
		stop_targeting(FALSE)
	return TRUE

///
/// Snucie sieci
///

/// Snuj lepką sieć pod sobą, by umocnić okolicę
/datum/action/cooldown/spider/lay_web
	name = "Snuj sieć"
	desc = "Utkaj sieć, która spowolni ofiary. Pająki chodzą po niej szybciej."
	button_icon_state = "spider_web"
	cooldown_time = 0
	/// Ile trwa snucie
	var/webbing_time = 4 SECONDS
	/// Pola, na których ktoś właśnie snuje (tg: TRAIT_SPINNING_WEB_TURF)
	var/static/list/turfs_being_webbed = list()

/datum/action/cooldown/spider/lay_web/unavailable_reason()
	. = ..()
	if(.)
		return
	if(!isturf(owner.loc))
		return "złe miejsce!"
	if(turfs_being_webbed[owner.loc])
		return "ktoś już tu snuje!"
	if(obstructed_by_other_web(owner.loc))
		return "już tu jest sieć!"

/// Czy na tym polu jest sieć, na której nic nie postawimy
/datum/action/cooldown/spider/lay_web/proc/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/stickyweb) in target_turf)

/// Dla AI: czy na tym polu da się snuć
/datum/action/cooldown/spider/lay_web/proc/can_web_turf(turf/target_turf)
	if(!isturf(target_turf) || turfs_being_webbed[target_turf])
		return FALSE
	return !obstructed_by_other_web(target_turf)

/datum/action/cooldown/spider/lay_web/Activate()
	var/turf/spider_turf = get_turf(owner)
	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	owner.balloon_alert_to_viewers(web ? "uszczelnia sieć..." : "snuje sieć...")
	turfs_being_webbed[spider_turf] = TRUE
	set_busy(TRUE)
	if(do_after(owner, webbing_time, target = spider_turf) && owner?.loc == spider_turf)
		plant_web(spider_turf, web)
		start_spider_cooldown()
	else
		owner?.balloon_alert(owner, "przerwano!")
	turfs_being_webbed -= spider_turf
	if(owner)
		set_busy(FALSE)
	return TRUE

/// Tworzy sieć na polu
/datum/action/cooldown/spider/lay_web/proc/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb(target_turf)

/// Wariant pozwalający nałożyć drugą warstwę, która zmienia sieć w ścianę
/datum/action/cooldown/spider/lay_web/sealer
	desc = "Utkaj sieć, która spowolni ofiary. Druga warstwa na tej samej sieci tworzy szczelną ścianę."

/datum/action/cooldown/spider/lay_web/sealer/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	if(existing_web)
		qdel(existing_web)
		new /obj/structure/spider/stickyweb/sealed(target_turf)
		return
	new /obj/structure/spider/stickyweb(target_turf)

/datum/action/cooldown/spider/lay_web/sealer/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/stickyweb/sealed) in target_turf)

/datum/action/cooldown/spider/lay_web/solid_web
	name = "Snuj twardą sieć"
	desc = "Utkaj nieprzejrzystą, utwardzoną ścianę z sieci, która zatrzyma ofiary."
	button_icon_state = "spider_wall"
	webbing_time = 5 SECONDS

/datum/action/cooldown/spider/lay_web/solid_web/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/stickyweb/sealed/tough) in target_turf)

/datum/action/cooldown/spider/lay_web/solid_web/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb/sealed/tough(target_turf)

/datum/action/cooldown/spider/lay_web/web_passage
	name = "Snuj przejście"
	desc = "Utkaj zasłonę, która trzyma powietrze i zasłania widok na gniazdo, ale nie blokuje przejścia."
	button_icon_state = "spider_roof"
	webbing_time = 4 SECONDS

/datum/action/cooldown/spider/lay_web/web_passage/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/passage) in target_turf)

/datum/action/cooldown/spider/lay_web/web_passage/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/passage(target_turf)

/datum/action/cooldown/spider/lay_web/sticky_web
	name = "Snuj lepką sieć"
	desc = "Utkaj wyjątkowo lepką sieć, która zawsze łapie intruzów."
	button_icon_state = "spider_ropes"
	cooldown_time = 20 SECONDS
	webbing_time = 3 SECONDS

/datum/action/cooldown/spider/lay_web/sticky_web/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/stickyweb/very_sticky) in target_turf)

/datum/action/cooldown/spider/lay_web/sticky_web/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb/very_sticky(target_turf)

/datum/action/cooldown/spider/lay_web/web_spikes
	name = "Snuj kolce"
	desc = "Utwardź jedwab w małe, ostre kolce, które zniechęcą najeźdźców."
	button_icon_state = "spider_spikes"
	cooldown_time = 40 SECONDS
	webbing_time = 3 SECONDS

/datum/action/cooldown/spider/lay_web/web_spikes/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/spikes) in target_turf)

/datum/action/cooldown/spider/lay_web/web_spikes/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/spikes(target_turf)

/datum/action/cooldown/spider/lay_web/web_reflector
	name = "Snuj lustrzany ekran"
	desc = "Utkaj ekran z jedwabiu, który odbija pociski z dala od gniazda."
	button_icon_state = "spider_mirror"
	cooldown_time = 30 SECONDS
	webbing_time = 4 SECONDS

/datum/action/cooldown/spider/lay_web/web_reflector/obstructed_by_other_web(turf/target_turf)
	return !!(locate(/obj/structure/spider/stickyweb/sealed/reflector) in target_turf)

/datum/action/cooldown/spider/lay_web/web_reflector/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb/sealed/reflector(target_turf)

///
/// Pajęcza kukła
///

/datum/action/cooldown/spider/web_effigy
	name = "Pajęcza kukła"
	desc = "Zrzuć wytrzymałą sieć w kształcie własnego ciała. Straszy i zasłania przed napastnikami, ale po minucie się rozpada."
	button_icon_state = "shed_web_carcass"
	cooldown_time = 60 SECONDS

/datum/action/cooldown/spider/web_effigy/unavailable_reason()
	. = ..()
	if(!. && !isturf(owner.loc))
		return "złe miejsce!"

/datum/action/cooldown/spider/web_effigy/Activate()
	new /obj/structure/spider/effigy(get_turf(owner))
	start_spider_cooldown()
	return TRUE

///
/// Owijanie w kokon
///

/datum/action/cooldown/spider/wrap
	name = "Owiń"
	desc = "Owiń coś lub kogoś w kokon. Żywe istoty przy okazji wysysasz: każda daje 2 ładunki na jaja. Włącz zdolność i kliknij sąsiedni cel."
	button_icon_state = "wrap_0"
	click_to_activate = TRUE
	button_first = TRUE
	targeting_pointer = 'icons/effects/wrap_target.dmi'
	/// Ile trwa owijanie
	var/wrap_time = 5 SECONDS

/datum/action/cooldown/spider/wrap/on_targeting_changed(feedback = TRUE)
	button_icon_state = "wrap_[targeting ? 1 : 0]"
	UpdateButtonIcon()
	if(!owner)
		return
	if(targeting)
		owner.balloon_alert(owner, "gotowy do owijania")
	else if(feedback)
		owner.balloon_alert(owner, "anulowano")

/datum/action/cooldown/spider/wrap/Activate(atom/to_wrap)
	if(!ismovable(to_wrap) || to_wrap == owner)
		return FALSE
	if(!owner.Adjacent(to_wrap))
		owner.balloon_alert(owner, "podejdź bliżej!")
		return FALSE
	if(isliving(to_wrap))
		var/mob/living/living_target = to_wrap
		if(isspider(living_target))
			owner.balloon_alert(owner, "nie owiniesz pająka!")
			return FALSE
		if(living_target.mob_size >= MOB_SIZE_LARGE && !ishuman(living_target))
			owner.balloon_alert(owner, "za duże!")
			return FALSE
	var/atom/movable/target_movable = to_wrap
	if(target_movable.anchored)
		return FALSE
	start_spider_cooldown(wrap_time)
	INVOKE_ASYNC(src, PROC_REF(cocoon), to_wrap)
	return TRUE

/datum/action/cooldown/spider/wrap/proc/cocoon(atom/movable/to_wrap)
	if(isliving(to_wrap))
		to_chat(to_wrap, span_userdanger("[owner] zaczyna oblepiać cię lepką wydzieliną."))
	owner.visible_message(span_notice("[owner] zaczyna oblepiać [to_wrap] lepką wydzieliną."), span_notice("Zaczynasz owijać [to_wrap] w kokon."))
	set_busy(TRUE)
	var/success = do_after(owner, wrap_time, target = to_wrap)
	if(owner)
		set_busy(FALSE)
	if(success && !QDELETED(to_wrap) && owner.Adjacent(to_wrap) && !to_wrap.anchored)
		wrap_target(to_wrap)
	else
		owner?.balloon_alert(owner, "przerwano!")

/datum/action/cooldown/spider/wrap/proc/wrap_target(atom/movable/to_wrap)
	var/obj/structure/spider/cocoon/casing = new(to_wrap.loc)
	if(isliving(to_wrap))
		var/mob/living/living_wrapped = to_wrap
		// Ładunki za każde pożarcie żywego, ale z konkretnych zwłok tylko raz
		if(!(MOB_ROBOTIC in living_wrapped.mob_biotypes) && (living_wrapped.stat != DEAD || !HAS_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED)))
			var/mob/living/simple_animal/hostile/spider/spider_owner = owner
			if(istype(spider_owner) && (locate(/datum/action/cooldown/spider/lay_eggs) in owner.actions))
				spider_owner.adjust_egg_charges(SPIDER_EGG_CHARGES_PER_BODY)
				owner.visible_message(span_danger("[owner] wbija ssawkę w [living_wrapped] i wysysa lepką substancję."),
					span_notice("Wysysasz z [living_wrapped] składniki odżywcze na jaja (+[SPIDER_EGG_CHARGES_PER_BODY], masz [spider_owner.egg_charges])."))
			ADD_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED, TRAIT_GENERIC)
			living_wrapped.death()
			log_combat(owner, living_wrapped, "spider cocooned")
		else
			to_chat(owner, span_warning("[living_wrapped] nie nadaje się do jedzenia!"))
	to_wrap.forceMove(casing)
	if(ismob(to_wrap) && (ishuman(to_wrap) || to_wrap.density))
		casing.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")
	else if(to_wrap.density)
		casing.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")

///
/// Składanie jaj
///

/datum/action/cooldown/spider/lay_eggs
	name = "Złóż jaja"
	desc = "Złóż gniazdo jaj, z którego wkrótce wykluje się zwykły pająk. Kosztuje 1 ładunek (ładunki daje owijanie ludzi)."
	button_icon_state = "lay_eggs"
	cooldown_time = 20 SECONDS
	/// Ile trwa składanie
	var/egg_lay_time = 4 SECONDS
	/// Jakie jaja składamy
	var/egg_type = /obj/structure/spider/eggcluster
	/// Ile ładunków z wyssanych ofiar kosztuje jedno gniazdo
	var/charge_cost = 1

/datum/action/cooldown/spider/lay_eggs/unavailable_reason()
	. = ..()
	if(.)
		return
	if(!isturf(owner.loc))
		return "złe miejsce!"
	if(locate(/obj/structure/spider/eggcluster) in owner.loc)
		return "tu już są jaja!"
	if(!has_charges())
		return "potrzeba [charge_cost] ład., nakarm się!"

/datum/action/cooldown/spider/lay_eggs/proc/has_charges()
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	return istype(spider_owner) && spider_owner.egg_charges >= charge_cost

/// Pokazuje na przycisku ładunki i koszt (gdy nie odlicza odnowienia)
/datum/action/cooldown/spider/lay_eggs/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	if(!button || next_use_time > world.time)
		return
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	button.maptext = istype(spider_owner) ? MAPTEXT("<b>[spider_owner.egg_charges]/[charge_cost]</b>") : ""

/datum/action/cooldown/spider/lay_eggs/Activate()
	INVOKE_ASYNC(src, PROC_REF(lay_eggs_async))
	return TRUE

/datum/action/cooldown/spider/lay_eggs/proc/lay_eggs_async()
	var/turf/egg_turf = get_turf(owner)
	owner.balloon_alert_to_viewers("składa jaja...")
	set_busy(TRUE)
	var/success = do_after(owner, egg_lay_time, target = egg_turf)
	if(!owner)
		return
	set_busy(FALSE)
	if(!success)
		owner.balloon_alert(owner, "przerwano!")
		return
	if(locate(/obj/structure/spider/eggcluster) in egg_turf)
		owner.balloon_alert(owner, "tu już są jaja!")
		return
	if(!has_charges())
		owner.balloon_alert(owner, "za mało ładunków!")
		return
	lay_egg(egg_turf)
	start_spider_cooldown()

/datum/action/cooldown/spider/lay_eggs/proc/lay_egg(turf/egg_turf)
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	if(istype(spider_owner))
		spider_owner.adjust_egg_charges(-charge_cost)
	var/obj/structure/spider/eggcluster/new_eggs = new egg_type(egg_turf)
	new_eggs.faction = owner.faction.Copy()
	// Ustalony rozkaz trafia też do directive matki, więc wystarczy go przepisać
	if(istype(spider_owner))
		new_eggs.directive = spider_owner.directive
	message_admins("[ADMIN_LOOKUPFLW(owner)] złożył(a) [new_eggs] w [ADMIN_VERBOSEJMP(egg_turf)].")
	log_game("[key_name(owner)] laid [new_eggs] at [AREACOORD(egg_turf)].")

/datum/action/cooldown/spider/lay_eggs/abnormal
	name = "Złóż nietypowe jaja"
	desc = "Złóż gniazdo jaj, z którego wkrótce wykluje się rzadszy pająk. Kosztuje 2 ładunki."
	button_icon_state = "lay_abnormal_eggs"
	cooldown_time = 180 SECONDS
	egg_type = /obj/structure/spider/eggcluster/abnormal
	charge_cost = 2

/datum/action/cooldown/spider/lay_eggs/enriched
	name = "Złóż wzbogacone jaja"
	desc = "Złóż gniazdo jaj, z którego wykluje się rzadki pająk, w tym kolejna matka. Kosztuje 3 ładunki."
	button_icon_state = "lay_enriched_eggs"
	cooldown_time = 60 SECONDS
	egg_type = /obj/structure/spider/eggcluster/enriched
	charge_cost = 3

///
/// Rozkazy dla potomstwa i reszty roju
///

/datum/action/cooldown/spider/set_spider_directive
	name = "Ustal rozkaz"
	desc = "Ustal rozkaz, który przejmą wszystkie twoje przyszłe dzieci."
	button_icon_state = "directive"
	/// Bieżący rozkaz
	var/current_directive = ""

/datum/action/cooldown/spider/set_spider_directive/Activate()
	INVOKE_ASYNC(src, PROC_REF(ask_directive))
	return TRUE

/datum/action/cooldown/spider/set_spider_directive/proc/ask_directive()
	var/mob/living/simple_animal/hostile/spider/spider_owner = owner
	if(!current_directive && istype(spider_owner))
		current_directive = spider_owner.directive
	var/new_directive = tgui_input_text(owner, "Podaj nowy rozkaz", "Rozkaz dla potomstwa", current_directive, MAX_MESSAGE_LEN)
	if(isnull(new_directive) || QDELETED(src) || QDELETED(owner) || owner.stat)
		return
	if(CHAT_FILTER_CHECK(new_directive))
		to_chat(owner, span_warning("Twój rozkaz zawiera zakazane słowa."))
		return
	current_directive = new_directive
	if(istype(spider_owner))
		spider_owner.directive = current_directive
	message_admins("[ADMIN_LOOKUPFLW(owner)] ustawił(a) rozkaz pająków: '[current_directive]'.")
	owner.log_message("set its directive to: '[current_directive]'.", LOG_GAME)

/// Wiadomość do wszystkich żywych pająków
/datum/action/cooldown/spider/command
	name = "Rozkaz"
	desc = "Wyślij rozkaz do wszystkich żywych pająków."
	button_icon_state = "command"

/datum/action/cooldown/spider/command/Activate()
	INVOKE_ASYNC(src, PROC_REF(ask_command))
	return TRUE

/datum/action/cooldown/spider/command/proc/ask_command()
	var/input = tgui_input_text(owner, "Co mają zrobić twoje zastępy?", name, "", MAX_MESSAGE_LEN)
	if(!input || QDELETED(src) || QDELETED(owner) || owner.stat)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(owner, span_warning("Twoja wiadomość zawiera zakazane słowa."))
		return
	spider_command(owner, input)

/datum/action/cooldown/spider/command/proc/spider_command(mob/living/user, message)
	var/my_message = format_message(user, message)
	for(var/mob/living/spider as anything in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag = "spider command")

/datum/action/cooldown/spider/command/proc/format_message(mob/living/user, message)
	return span_spiderbroodmother("<b>Rozkaz od [user]:</b> [message]")

/datum/action/cooldown/spider/command/communication
	name = "Meldunek"
	desc = "Wyślij meldunek do wszystkich żywych pająków."
	button_icon_state = "message"

/datum/action/cooldown/spider/command/communication/format_message(mob/living/user, message)
	return span_spiderscout("<b>Meldunek od [user]:</b> [message]")

/datum/action/cooldown/spider/command/warning
	name = "Ostrzeżenie"
	desc = "Wyślij ostrzeżenie do wszystkich żywych pająków."
	button_icon_state = "warning"

/datum/action/cooldown/spider/command/warning/format_message(mob/living/user, message)
	return span_spiderbreacher("<b>Ostrzeżenie od [user]:</b> [message]")

///
/// Skradanie się pająka zasadzkowego
///

/datum/action/cooldown/spider/sneak
	name = "Wtop się w sieć"
	desc = "Wtop się w otoczenie i podejdź ofiarę."
	button_icon_state = "web_sneak"
	cooldown_time = 0.5 SECONDS
	/// Przezroczystość w ukryciu
	var/sneak_alpha = 75
	/// Czy się ukrywamy
	var/sneaking = FALSE

/datum/action/cooldown/spider/sneak/Remove(mob/M)
	if(sneaking && M)
		M.alpha = initial(M.alpha)
		sneaking = FALSE
	return ..()

/datum/action/cooldown/spider/sneak/unavailable_reason()
	return null

/datum/action/cooldown/spider/sneak/Activate()
	sneaking = !sneaking
	if(sneaking)
		animate(owner, alpha = sneak_alpha, time = 0.5 SECONDS)
		owner.balloon_alert(owner, "wtapiasz się w otoczenie")
	else
		animate(owner, alpha = initial(owner.alpha), time = 0.5 SECONDS)
		owner.balloon_alert(owner, "ujawniasz się")
	start_spider_cooldown()
	return TRUE

///
/// Tryb obronny żmii
///

/datum/action/cooldown/spider/defensive_mode
	name = "Zmień tryb"
	desc = "Zwiń się w tryb obronny: mniej obrażeń, ale wolniejszy ruch."
	button_icon_state = "defensive_mode"
	cooldown_time = 5 SECONDS
	/// Czy tryb obronny jest włączony
	var/defense_active = FALSE

/datum/action/cooldown/spider/defensive_mode/Remove(mob/M)
	if(defense_active)
		offence(M)
	return ..()

/datum/action/cooldown/spider/defensive_mode/unavailable_reason()
	return null

/datum/action/cooldown/spider/defensive_mode/Activate()
	var/mob/living/simple_animal/owner_mob = owner
	if(!istype(owner_mob))
		return FALSE
	if(defense_active)
		offence(owner_mob)
	else
		defence(owner_mob)
	start_spider_cooldown()
	return TRUE

/datum/action/cooldown/spider/defensive_mode/proc/offence(mob/living/simple_animal/owner_mob)
	owner_mob.damage_coeff[BRUTE] *= 2.5
	owner_mob.damage_coeff[BURN] *= 2.5
	owner_mob.icon_state = initial(owner_mob.icon_state)
	owner_mob.icon_living = initial(owner_mob.icon_living)
	owner_mob.icon_dead = initial(owner_mob.icon_dead)
	owner_mob.remove_movespeed_modifier(MOVESPEED_ID_SPIDER_DEFENSIVE)
	defense_active = FALSE

/datum/action/cooldown/spider/defensive_mode/proc/defence(mob/living/simple_animal/owner_mob)
	owner_mob.damage_coeff = owner_mob.damage_coeff.Copy()
	owner_mob.damage_coeff[BRUTE] *= 0.4
	owner_mob.damage_coeff[BURN] *= 0.4
	owner_mob.icon_dead = "[initial(owner_mob.icon_state)]_d_dead"
	owner_mob.icon_state = "[initial(owner_mob.icon_state)]_d"
	owner_mob.icon_living = "[initial(owner_mob.icon_living)]_d"
	owner_mob.add_movespeed_modifier(MOVESPEED_ID_SPIDER_DEFENSIVE, TRUE, 100, override = TRUE, multiplicative_slowdown = 1.5)
	defense_active = TRUE

///
/// Szarża tarantuli
///

/datum/action/cooldown/spider/charge
	name = "Szarża"
	desc = "Po krótkim przygotowaniu rzuć się na cel, przewracając i raniąc wszystko po drodze. Prawy przycisk myszy na odległość też szarżuje."
	button_icon_state = "expand"
	cooldown_time = 6 SECONDS
	click_to_activate = TRUE
	/// Jak daleko szarżujemy
	var/charge_distance = 7
	/// Ile trwa przygotowanie
	var/charge_delay = 0.6 SECONDS
	/// Na ile przewracamy trafionego
	var/knockdown_time = 2 SECONDS
	/// Obrażenia przy trafieniu
	var/charge_damage = 15

/datum/action/cooldown/spider/charge/on_targeting_changed(feedback = TRUE)
	if(!owner)
		return
	if(targeting)
		owner.balloon_alert(owner, "wskaż cel szarży")
	else if(feedback)
		owner.balloon_alert(owner, "anulowano")

/datum/action/cooldown/spider/charge/Activate(atom/charge_target)
	if(!charge_target || get_turf(charge_target) == get_turf(owner))
		return FALSE
	if(!isturf(owner.loc))
		owner.balloon_alert(owner, "złe miejsce!")
		return FALSE
	start_spider_cooldown()
	INVOKE_ASYNC(src, PROC_REF(do_charge), charge_target)
	return TRUE

/datum/action/cooldown/spider/charge/proc/do_charge(atom/charge_target)
	var/mob/living/charger = owner
	var/turf/target_turf = get_turf(charge_target)
	charger.visible_message(span_danger("[charger] napina odnóża, szykując się do skoku!"))
	charger.Shake(2, 2, charge_delay)
	set_busy(TRUE)
	sleep(charge_delay)
	if(QDELETED(charger) || charger.stat || !isturf(charger.loc))
		if(!QDELETED(charger))
			set_busy(FALSE)
		return
	RegisterSignal(charger, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	// Nieudany start rzutu nie wywoła callbacku, więc sprzątamy sami
	if(!charger.throw_at(target_turf, charge_distance, 1, charger, FALSE, callback = CALLBACK(src, PROC_REF(charge_end), charger)))
		charge_end(charger)

/datum/action/cooldown/spider/charge/proc/charge_end(mob/living/charger)
	if(QDELETED(charger))
		return
	UnregisterSignal(charger, COMSIG_MOVABLE_IMPACT)
	set_busy(FALSE)

/datum/action/cooldown/spider/charge/proc/on_impact(mob/living/charger, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isliving(hit_atom))
		return
	var/mob/living/victim = hit_atom
	if(victim.faction_check_mob(charger))
		return
	victim.visible_message(span_danger("[charger] wpada na [victim]!"), span_userdanger("[charger] wpada na ciebie!"))
	victim.Knockdown(knockdown_time)
	victim.apply_damage(charge_damage, BRUTE)
	playsound(victim, 'sound/effects/meteorimpact.ogg', 50, TRUE)
	log_combat(charger, victim, "charged")

///
/// Samoleczenie (pająki splątujące i czołgi)
///

/datum/action/cooldown/spider/mend
	name = "Zalecz rany"
	desc = "Zasklep własne rany nicią. Nie działa, gdy płoniesz."
	button_icon_state = "wrap_1"
	/// Ile brute i burn leczymy
	var/heal_amount = 15
	/// Ile to trwa
	var/heal_time = 3 SECONDS

/datum/action/cooldown/spider/mend/New(Target, amount, time)
	. = ..()
	if(amount)
		heal_amount = amount
	if(time)
		heal_time = time

/datum/action/cooldown/spider/mend/unavailable_reason()
	. = ..()
	if(.)
		return
	var/mob/living/living_owner = owner
	if(living_owner.on_fire)
		return "płoniesz!"
	if(living_owner.health >= living_owner.maxHealth)
		return "nie jesteś ranny!"

/datum/action/cooldown/spider/mend/Activate()
	INVOKE_ASYNC(src, PROC_REF(mend_async))
	return TRUE

/datum/action/cooldown/spider/mend/proc/mend_async()
	var/mob/living/living_owner = owner
	living_owner.visible_message(span_notice("[living_owner] zaczyna zasklepiać swoje rany..."), span_notice("Zaczynasz zasklepiać swoje rany..."))
	set_busy(TRUE)
	var/success = do_after(living_owner, heal_time, target = living_owner)
	if(QDELETED(living_owner))
		return
	set_busy(FALSE)
	if(!success || living_owner.on_fire)
		living_owner.balloon_alert(living_owner, "przerwano!")
		return
	living_owner.adjustBruteLoss(-heal_amount)
	living_owner.adjustFireLoss(-heal_amount)
	living_owner.visible_message(span_notice("Rany [living_owner] zrastają się."), span_notice("Twoje rany się zrastają."))
