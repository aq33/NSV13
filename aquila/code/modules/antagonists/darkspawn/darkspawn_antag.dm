// AQUILA - darkspawn (port z Yogstation, wersja po przeróbce Yogstation#20581)
// Obcy ukryci w ludzkiej skórze. Wybierają klasę, zrzucają skórę (Divulge), pożerają wolę załogi i odprawiają Sakrament.

GLOBAL_DATUM(darkspawn_team, /datum/team/darkspawn)
GLOBAL_VAR_INIT(sacrament_done, FALSE)

/proc/get_darkspawn_team()
	RETURN_TYPE(/datum/team/darkspawn)
	if(!GLOB.darkspawn_team)
		GLOB.darkspawn_team = new
	return GLOB.darkspawn_team

/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawni"
	antagpanel_category = "Darkspawn"
	banning_key = ROLE_DARKSPAWN
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	ui_name = "AntagInfoDarkspawn"

	var/datum/team/darkspawn/team
	/// Imię sprzed zrzucenia skóry
	var/disguise_name
	/// Imię po zrzuceniu skóry
	var/darkspawn_name
	/// MUNDANE = w ludzkiej skórze, DIVULGED = prawdziwa postać, PROGENITOR = po Sakramencie
	var/darkspawn_state = DARKSPAWN_MUNDANE
	/// Wybrana klasa, trzyma zdolności z Psi Web
	var/datum/component/darkspawn_class/picked_class

	// Psi, czyli mana zdolności
	var/psi = 100
	var/psi_cap = 100
	/// Ile czasu po wydaniu Psi zaczyna wracać
	var/psi_regen_delay = 9 SECONDS
	/// Ile Psi wraca na sekundę, gdy już wraca
	var/psi_per_second = 20
	COOLDOWN_DECLARE(psi_cooldown)
	var/psi_regenerating = FALSE

	/// Wola, za którą kupuje się zdolności w Psi Web. Zdobywa się ją Pożarciem woli i od thralli.
	var/willpower = 6

	/// Ile leczy się na tick w ciemności
	var/dark_healing = 8
	/// Ile obrażeń dostaje na tick w świetle
	var/light_burning = 7
	// Mnożniki obrażeń ustawiane gatunkowi
	var/brute_mod = 1
	var/burn_mod = 1
	var/stam_mod = 1

	/// Czy gracz już wie, że Nieśmiertelne sigile go podnoszą
	var/revive_notice = FALSE
	/// Timer wymuszonego zrzucenia skóry
	var/force_divulge_timer

/datum/antagonist/darkspawn/create_team(datum/team/darkspawn/new_team)
	team = new_team || get_darkspawn_team()

/datum/antagonist/darkspawn/get_team()
	return team

/datum/antagonist/darkspawn/on_gain()
	if(!team)
		create_team()
	team.add_member(owner)
	owner.special_role = ROLE_DARKSPAWN
	for(var/datum/objective/team_objective as anything in team.objectives)
		objectives |= team_objective
	RegisterSignal(owner, COMSIG_MIND_CHECK_ANTAG_RESOURCE, PROC_REF(has_psi))
	RegisterSignal(owner, COMSIG_MIND_SPEND_ANTAG_RESOURCE, PROC_REF(use_psi))
	START_PROCESSING(SSprocessing, src)
	force_divulge_timer = addtimer(CALLBACK(src, PROC_REF(begin_force_divulge)), 20 MINUTES, TIMER_STOPPABLE)
	. = ..()
	owner.announce_objectives()

/datum/antagonist/darkspawn/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	deltimer(force_divulge_timer)
	team?.remove_member(owner)
	if(owner.special_role == ROLE_DARKSPAWN)
		owner.special_role = null
	hide_psi_hud(owner.current)
	QDEL_NULL(picked_class)
	UnregisterSignal(owner, list(COMSIG_MIND_CHECK_ANTAG_RESOURCE, COMSIG_MIND_SPEND_ANTAG_RESOURCE))
	return ..()

/datum/antagonist/darkspawn/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	handle_clown_mutation(current_mob, mob_override ? null : "Nasze moce pozwalają przezwyciężyć klaunowską naturę, możemy więc swobodnie używać broni.")
	current_mob.grant_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction |= ROLE_DARKSPAWN
	add_antag_hud(ANTAG_HUD_SHADOW, "shadowling", current_mob)
	update_psi_hud()
	if(darkspawn_state == DARKSPAWN_MUNDANE && ishuman(current_mob))
		grant_divulge(current_mob)

/datum/antagonist/darkspawn/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	current_mob.remove_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction -= ROLE_DARKSPAWN
	remove_antag_hud(ANTAG_HUD_SHADOW, current_mob)
	for(var/datum/action/cooldown/spell/divulge/divulge in current_mob.actions)
		qdel(divulge)

/datum/antagonist/darkspawn/proc/grant_divulge(mob/living/target)
	if(locate(/datum/action/cooldown/spell/divulge) in target.actions)
		return
	var/datum/action/cooldown/spell/divulge/action = new(owner)
	action.Grant(target)

/datum/antagonist/darkspawn/greet()
	var/mob/user = owner.current
	if(!user)
		return
	user.playsound_local(get_turf(user), 'aquila/sound/darkspawn/darkspawn.ogg', 50, FALSE)
	var/list/report = list()
	report += "<span class='velvet bold big'>Jesteś darkspawnem!</span>"
	report += "<i>Dopisz :[MODE_KEY_DARKSPAWN] lub .[MODE_KEY_DARKSPAWN] przed wiadomością, żeby bezgłośnie mówić do innych darkspawnów przez Mindlink.</i>"
	report += "Najpierw wybierz klasę w oknie antagonisty. Gdy będziesz gotowy, schowaj się w ciemnym, ustronnym miejscu i użyj Divulge, żeby zrzucić ludzką skórę."
	report += "Pamiętaj, że potem światło będzie cię zabijać, a ciemność leczyć. Trzymaj się cieni."
	report += "<span class='boldwarning'>Jeśli nie zrobisz tego w ciągu dwudziestu pięciu minut, stanie się to samo. Przygotuj się szybko.</span>"
	to_chat(user, report.Join("<br>"))

/datum/antagonist/darkspawn/roundend_report()
	return "[owner ? printplayer(owner) : "Bezimienny darkspawn"]"

// Okno antagonisty: wybór klasy i sklep Psi Web

/datum/antagonist/darkspawn/ui_data(mob/user)
	var/list/data = list()
	data["willpower"] = willpower
	data["objectives"] = get_objectives()
	data["divulged"] = (darkspawn_state > DARKSPAWN_MUNDANE)
	data["ascended"] = (darkspawn_state == DARKSPAWN_PROGENITOR)
	data["has_class"] = !!picked_class
	if(team)
		data["lucidity_drained"] = team.lucidity
		data["required_succs"] = team.required_succs
		data["max_thralls"] = team.max_thralls
		data["current_thralls"] = LAZYLEN(team.thralls)
		var/list/thrall_names = list()
		for(var/datum/mind/dude as anything in team.thralls)
			thrall_names += dude.name
		data["thrall_names"] = thrall_names

	data["categories"] = list()
	for(var/category in list(STORE_OFFENSE, STORE_UTILITY, STORE_PASSIVE))
		var/list/category_data = list()
		category_data["name"] = category
		var/list/paths = list()
		if(picked_class)
			for(var/datum/psi_web/knowledge as anything in picked_class.get_purchasable_abilities())
				if(category != initial(knowledge.menu_tab))
					continue
				var/list/knowledge_data = list()
				knowledge_data["path"] = knowledge
				knowledge_data["name"] = initial(knowledge.name)
				knowledge_data["desc"] = initial(knowledge.desc)
				knowledge_data["lore_description"] = initial(knowledge.lore_description)
				knowledge_data["cost"] = initial(knowledge.willpower_cost)
				knowledge_data["disabled"] = (initial(knowledge.willpower_cost) > willpower)
				knowledge_data["infinite"] = initial(knowledge.infinite)
				if(initial(knowledge.icon_state))
					knowledge_data["icon"] = icon2base64(icon(initial(knowledge.icon), initial(knowledge.icon_state)))
				paths += list(knowledge_data)
		category_data["knowledgeData"] = paths
		data["categories"] += list(category_data)
	return data

/datum/antagonist/darkspawn/ui_static_data(mob/user)
	var/list/data = ..()
	data["classData"] = list()
	for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
		if(!initial(class.choosable))
			continue
		var/list/class_data = list()
		class_data["path"] = class
		class_data["name"] = initial(class.name)
		class_data["color"] = initial(class.class_color)
		class_data["description"] = initial(class.description)
		class_data["long_description"] = initial(class.long_description)
		data["classData"] += list(class_data)
	return data

/datum/antagonist/darkspawn/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("purchase")
			return purchase(text2path(params["upgrade_path"]))
		if("select")
			return select_class(text2path(params["class_path"]))

/// Kupno w Psi Web, dopiero po zrzuceniu skóry
/datum/antagonist/darkspawn/proc/purchase(upgrade_path)
	if(!ispath(upgrade_path, /datum/psi_web) || darkspawn_state == DARKSPAWN_MUNDANE || !picked_class)
		return FALSE
	SEND_SIGNAL(owner, COMSIG_DARKSPAWN_PURCHASE_POWER, upgrade_path)
	return TRUE

/// Wybór klasy, tylko raz i tylko spośród dostępnych dla graczy
/datum/antagonist/darkspawn/proc/select_class(class_path)
	if(picked_class || !ispath(class_path, /datum/component/darkspawn_class))
		return FALSE
	var/datum/component/darkspawn_class/class = class_path
	if(!initial(class.choosable))
		return FALSE
	picked_class = owner.AddComponent(class_path)
	mindlink_message("<span class='velvet'><b>\[Mindlink\] [owner.current] wybiera klasę: [picked_class.name].</b></span>")
	update_static_data(owner.current)
	return TRUE

/datum/antagonist/darkspawn/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()

/// Darkspawn, thrall, psyche albo mob z frakcji darkspawnów (np. iluzje), żeby zaklęcia ich omijały
/proc/is_team_darkspawn(atom/A)
	if(!ismob(A))
		return FALSE
	var/mob/M = A
	if(is_darkspawn_or_thrall(M) || ispsyche(M))
		return TRUE
	return (ROLE_DARKSPAWN in M.faction)

/// Wiadomość do wszystkich żywych z drużyny darkspawnów i do duchów
/proc/darkspawn_mindlink_broadcast(message, mob/source)
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(is_team_darkspawn(M))
			to_chat(M, message)
	if(source)
		deadchat_broadcast(message, follow_target = source)

/datum/antagonist/darkspawn/proc/mindlink_message(message)
	darkspawn_mindlink_broadcast(message, owner.current)

// Psi

/datum/antagonist/darkspawn/process(delta_time)
	psi = min(psi, psi_cap)
	if(psi < psi_cap && COOLDOWN_FINISHED(src, psi_cooldown) && !psi_regenerating && !HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK))
		regenerate_psi()
	update_psi_hud()

	// Bardzo rzadko mózg darkspawna w MMI albo borgu odzyskuje ciało
	if(owner.current && (isbrain(owner.current) || issilicon(owner.current)) && rand(0, 10000) == 0)
		addtimer(CALLBACK(src, PROC_REF(grant_reform)), rand(1, 20 MINUTES), TIMER_UNIQUE)

	if(owner?.current?.stat == DEAD && HAS_TRAIT(src, TRAIT_DARKSPAWN_UNDYING) && ishuman(owner.current) && !QDELETED(owner.current))
		undying_tick(owner.current)

	if(darkspawn_state == DARKSPAWN_MUNDANE && ishuman(owner.current))
		grant_divulge(owner.current)

/// Nieśmiertelne sigile: martwy darkspawn w ciemności powoli wstaje
/datum/antagonist/darkspawn/proc/undying_tick(mob/living/carbon/human/deadguy)
	var/turf/location = get_turf(deadguy)
	if(location?.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		if(!revive_notice)
			deadguy.visible_message("<span class='notice'>Ciało [deadguy] drga.</span>", "<span class='velvet'>Twoje ciało szarpie się, nie godząc się na śmierć.</span>")
			revive_notice = TRUE
		deadguy.adjustBruteLoss(-10)
		deadguy.adjustFireLoss(-10)
		deadguy.adjustToxLoss(-10)
		deadguy.adjustOxyLoss(-10)
		deadguy.adjustCloneLoss(-10)
		deadguy.adjustOrganLoss(ORGAN_SLOT_BRAIN, -10)
		if(deadguy.health >= deadguy.maxHealth)
			deadguy.grab_ghost()
			deadguy.revive(TRUE)
			revive_notice = FALSE
			deadguy.visible_message("<span class='velvet'>Sigile [deadguy] rozbłyskują, gdy znów wkracza do świata żywych!</span>", "<span class='velvet'>Powstajesz raz jeszcze!</span>")
			playsound(deadguy, 'aquila/sound/darkspawn/demented_outburst_scream.ogg', 40, FALSE)
	else if(revive_notice)
		revive_notice = FALSE
		deadguy.visible_message("<span class='notice'>Ciało [deadguy] nieruchomieje.</span>", "<span class='velvet'>Twoje ciało znów nieruchomieje.</span>")

/datum/antagonist/darkspawn/proc/has_psi(datum/mind/source, resource = ANTAG_RESOURCE_DARKSPAWN, amount)
	SIGNAL_HANDLER
	if(resource != ANTAG_RESOURCE_DARKSPAWN)
		return FALSE
	return psi >= amount

/datum/antagonist/darkspawn/proc/use_psi(datum/mind/source, list/resource_costs)
	SIGNAL_HANDLER
	if(!LAZYLEN(resource_costs))
		return
	var/amount = resource_costs[ANTAG_RESOURCE_DARKSPAWN]
	if(!amount || psi < amount)
		return
	if(amount > 0 && psi_regen_delay)
		COOLDOWN_START(src, psi_cooldown, psi_regen_delay)
	psi = round(psi - amount, 0.1)
	update_psi_hud()
	return TRUE

/// Wydaje Psi bezpośrednio (nie przez sygnał)
/datum/antagonist/darkspawn/proc/spend_psi(amount)
	return use_psi(owner, list(ANTAG_RESOURCE_DARKSPAWN = amount))

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	if(QDELETED(src))
		return
	psi_regenerating = TRUE
	// Najszybciej 20 ticków na sekundę; szybsza regeneracja dokłada więcej na tick
	var/regen_amount = max(1, psi_per_second / 20)
	psi = round(min(psi + regen_amount, psi_cap), 0.1)
	update_psi_hud()
	if(psi >= psi_cap || !COOLDOWN_FINISHED(src, psi_cooldown) || HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK))
		psi_regenerating = FALSE
		return
	addtimer(CALLBACK(src, PROC_REF(regenerate_psi)), max(world.tick_lag, (1 / psi_per_second) SECONDS), TIMER_UNIQUE)

/// Na chwilę wstrzymuje odnawianie Psi
/datum/antagonist/darkspawn/proc/block_psi(duration = 5 SECONDS, identifier)
	if(!identifier)
		return
	ADD_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK, identifier)
	owner.current?.throw_alert("psiblock", /atom/movable/screen/alert/psiblock)
	addtimer(CALLBACK(src, PROC_REF(unblock_psi), identifier), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/antagonist/darkspawn/proc/unblock_psi(identifier)
	REMOVE_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK, identifier)
	if(!HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK))
		owner.current?.clear_alert("psiblock")

/datum/antagonist/darkspawn/proc/update_psi_hud()
	var/mob/living/current = owner?.current
	if(!current?.hud_used?.psi_counter)
		return
	var/atom/movable/screen/counter = current.hud_used.psi_counter
	counter.invisibility = 0
	counter.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[COLOR_DARKSPAWN_PSI]'>[round(psi)]</font></div>")

/datum/antagonist/darkspawn/proc/hide_psi_hud(mob/living/current)
	if(!current?.hud_used?.psi_counter)
		return
	current.hud_used.psi_counter.invisibility = INVISIBILITY_ABSTRACT
	current.hud_used.psi_counter.maptext = ""

/atom/movable/screen/alert/psiblock
	name = "Psi zablokowane"
	desc = "Ostatnio użyłeś bardzo potężnej zdolności. Twoje Psi chwilowo się nie odnawia."
	icon_state = "shadow_mend"

// Divulge

/datum/antagonist/darkspawn/proc/begin_force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE || !owner.current || owner.current.stat == DEAD)
		return
	to_chat(owner.current, "<span class='userdanger'>Skóra, którą nosisz, trzeszczy jak papier. Wkrótce zrzucisz ją siłą! Znajdź ciemną kryjówkę!</span>")
	owner.current.playsound_local(owner.current, 'aquila/sound/darkspawn/divulge_01.ogg', 50, FALSE, pressure_affected = FALSE)
	force_divulge_timer = addtimer(CALLBACK(src, PROC_REF(force_divulge)), 5 MINUTES, TIMER_STOPPABLE)

/datum/antagonist/darkspawn/proc/force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE)
		return
	var/mob/living/current = owner.current
	if(!current || current.stat == DEAD)
		return
	if(iscarbon(current) && !ishuman(current))
		var/mob/living/carbon/carbon_current = current
		carbon_current.humanize()
	var/mob/living/carbon/human/H = owner.current
	if(!ishuman(H))
		owner.current.gib(TRUE)
		return
	H.visible_message("<span class='boldwarning'>Skóra [H] zaczyna schodzić płatami!</span>", \
		"<span class='userdanger'>Nie jesteś już w stanie utrzymać przebrania! Zaczyna z ciebie schodzić!</span>")
	playsound(H, 'aquila/sound/darkspawn/darkspawn_force_divulge.ogg', 50, FALSE)
	H.do_jitter_animation(1000)
	mindlink_message("<span class='velvet'><b>\[Mindlink\] [H.real_name] nie zrzucił skóry na czas i robi to teraz siłą.</b></span>")
	addtimer(CALLBACK(src, PROC_REF(divulge), TRUE), 2.5 SECONDS)

/// Zrzucenie ludzkiej skóry. Bez wybranej klasy dostaje losową.
/datum/antagonist/darkspawn/proc/divulge(forced = FALSE)
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		return FALSE
	var/mob/living/carbon/human/user = owner.current
	if(!ishuman(user))
		return FALSE
	deltimer(force_divulge_timer)

	if(!picked_class)
		var/list/classes = list()
		for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
			if(initial(class.choosable))
				classes += class
		picked_class = owner.AddComponent(pick(classes))
		to_chat(user, "<span class='velvet'>Twoja klasa: <b>[picked_class.name]</b>.</span>")

	owner.assigned_role = picked_class.name // po zrzuceniu skóry przestaje być członkiem załogi

	if(forced)
		user.visible_message("<span class='boldwarning'>Skóra [user] odpada, odsłaniając czarne ciało pokryte symbolami!</span>", \
			"<span class='userdanger'>Zrzuciłeś skórę siłą!</span>")

	for(var/datum/action/cooldown/spell/divulge/divulge in user.actions)
		qdel(divulge)

	user.fully_heal()
	disguise_name = user.real_name
	user.set_species(/datum/species/darkspawn)
	darkspawn_name = user.real_name
	user.update_body()
	picked_class.update_owner_overlay()

	show_to_ghosts = TRUE
	darkspawn_mindlink_broadcast("<span class='velvet'><b>\[Mindlink\] [disguise_name] zrzuca ludzkie przebranie i od teraz jest [darkspawn_name].</b></span>", user)

	darkspawn_state = DARKSPAWN_DIVULGED
	to_chat(user, "<span class='velvet'>Twój umysł się rozszerzył. Unikaj światła. Trzymaj się cieni. Twój czas nadejdzie.</span>")
	to_chat(user, "<span class='velvet bold'>W oknie antagonisty otworzył się sklep Psi Web. Wydaj [willpower] woli na zdolności i ulepszenia.</span>")
	update_static_data(user)
	return TRUE

// Sakrament

/datum/antagonist/darkspawn/proc/sacrament()
	var/mob/living/carbon/human/user = owner.current
	if(!ishuman(user))
		return
	user.status_flags |= GODMODE

	if(!GLOB.sacrament_done)
		GLOB.sacrament_done = TRUE
		team.upon_sacrament()
		set_security_level(SEC_LEVEL_DELTA)
		shatter_lights()
		addtimer(CALLBACK(src, PROC_REF(sacrament_shuttle_call)), 5 SECONDS)
		to_chat(world, "<span class='velvet'>Rzeczywistość zaczyna drżeć i pękać w szwach.</span>")
		addtimer(CALLBACK(src, PROC_REF(start_overlay)), 15 SECONDS)
		SSblackbox.record_feedback("tally", "darkspawn", 1, "sacrament")

	for(var/datum/action/cooldown/spell/spell in user.actions) // potomek ma własne zdolności
		qdel(spell)

	var/class_color = picked_class?.class_color || COLOR_DARKSPAWN_PSI
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user), user.real_name, class_color)
	owner.transfer_to(progenitor)

	psi = 9999
	psi_cap = 9999
	psi_per_second = 9999
	psi_regen_delay = 0
	update_psi_hud()

	darkspawn_state = DARKSPAWN_PROGENITOR
	QDEL_IN(user, 1)

/// Gasi wszystkie lampy na stacji (z rozłożeniem w czasie)
/datum/antagonist/darkspawn/proc/shatter_lights()
	for(var/obj/machinery/light/L in GLOB.machines)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, break_light_tube)), rand(1, 50))

/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, set_coefficient = 0.1)

/datum/antagonist/darkspawn/proc/start_overlay()
	to_chat(world, "<span class='velvet big'>COŚ JEST NIE TAK.</span>")
	for(var/mob/living/person in GLOB.player_list)
		person.AddComponent(/datum/component/shadowlands)

// Odtworzenie ciała z mózgu

/datum/antagonist/darkspawn/proc/grant_reform()
	if(!owner.current || !(isbrain(owner.current) || issilicon(owner.current)))
		return
	if(locate(/datum/action/cooldown/spell/reform_body) in owner.current.actions)
		return
	var/datum/action/cooldown/spell/reform_body/recreance = new(owner)
	recreance.Grant(owner.current)

/// Tworzy nowe ludzkie ciało dla darkspawna uwięzionego w MMI albo borgu
/datum/antagonist/darkspawn/proc/reform_body()
	if(!owner.current)
		return
	for(var/datum/action/cooldown/spell/reform_body/spell in owner.current.actions)
		qdel(spell)
	if(!(isbrain(owner.current) || issilicon(owner.current)))
		return

	var/mob/living/old_body = owner.current
	var/mob/living/carbon/human/returner = new(get_turf(old_body))
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		returner.set_species(/datum/species/darkspawn)
	returner.fully_replace_character_name(null, darkspawn_name || pick(GLOB.nightmare_names))
	owner.transfer_to(returner)
	returner.update_body()

	picked_class?.refresh_powers()

	playsound(returner, 'aquila/sound/darkspawn/divulge_end.ogg', 50, FALSE)
	playsound(returner, 'aquila/sound/darkspawn/darkspawn_death.ogg', 50, FALSE)
	mindlink_message("<span class='velvet'><b>\[Mindlink\] [returner] odtwarza swoje ciało.</b></span>")

	if(isbrain(old_body))
		var/mob/living/brain/thinker = old_body
		if(thinker.container)
			qdel(thinker.container)
			return
	old_body.gib(TRUE, TRUE, TRUE)

// Panel admina

/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	if(darkspawn_state == DARKSPAWN_MUNDANE)
		.["Force Divulge"] = CALLBACK(src, PROC_REF(divulge), TRUE)
	.["Set Lucidity"] = CALLBACK(src, PROC_REF(admin_set_lucidity))
	.["Set Willpower"] = CALLBACK(src, PROC_REF(admin_set_willpower))
	.["Set Psi Values"] = CALLBACK(src, PROC_REF(admin_set_psi))
	.["Set Max Thralls"] = CALLBACK(src, PROC_REF(admin_set_max_thralls))
	if(picked_class)
		.["Refund Ability"] = CALLBACK(src, PROC_REF(admin_refund_ability))
	.["Set Class"] = CALLBACK(src, PROC_REF(admin_set_class))
	if(darkspawn_state == DARKSPAWN_DIVULGED)
		.["Sacrament (ENDS THE ROUND)"] = CALLBACK(src, PROC_REF(sacrament))

/datum/antagonist/darkspawn/proc/admin_set_lucidity(mob/admin)
	var/lucid = input(admin, "How much lucidity should the darkspawn team have?", "Lucidity", team?.lucidity) as null|num
	if(!isnull(lucid) && team)
		team.lucidity = max(0, lucid)

/datum/antagonist/darkspawn/proc/admin_set_willpower(mob/admin)
	var/will = input(admin, "How much willpower should [owner] have?", "Willpower", willpower) as null|num
	if(!isnull(will))
		willpower = max(0, will)

/datum/antagonist/darkspawn/proc/admin_set_psi(mob/admin)
	var/max = input(admin, "What should the psi cap be?", "Psi", psi_cap) as null|num
	if(!isnull(max))
		psi_cap = max(0, max)
	var/regen = input(admin, "How much psi should be regenerated per second?", "Psi", psi_per_second) as null|num
	if(!isnull(regen))
		psi_per_second = max(1, regen)
	var/delay = input(admin, "What should the delay to psi regeneration be (deciseconds)?", "Psi", psi_regen_delay) as null|num
	if(!isnull(delay))
		psi_regen_delay = max(0, delay)

/datum/antagonist/darkspawn/proc/admin_set_max_thralls(mob/admin)
	var/thrall = input(admin, "How many thralls should the darkspawn team be able to get?", "Thralls", team?.max_thralls) as null|num
	if(!isnull(thrall) && team)
		team.max_thralls = max(0, thrall)

/datum/antagonist/darkspawn/proc/admin_refund_ability(mob/admin)
	if(!picked_class)
		return
	var/list/abilities = list()
	for(var/datum/psi_web/ability as anything in picked_class.learned_abilities)
		if(ability.willpower_cost)
			abilities[ability.name] = ability
	if(!length(abilities))
		to_chat(admin, "<span class='warning'>There are no abilities to refund.</span>")
		return
	var/choice = tgui_input_list(admin, "Select which ability to refund.", "Select Ability", abilities)
	var/datum/psi_web/picked_ability = abilities[choice]
	if(!picked_ability || QDELETED(src) || QDELETED(picked_class))
		return
	picked_class.lose_power(picked_ability, TRUE)

/datum/antagonist/darkspawn/proc/admin_set_class(mob/admin)
	var/list/classes = list()
	for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
		classes["[initial(class.name)][initial(class.choosable) ? "" : " (not selectable)"]"] = class
	var/choice = tgui_input_list(admin, "Select which class to force on the target.", "Select Class", classes)
	var/chosen = classes[choice]
	if(!chosen || QDELETED(src) || QDELETED(owner.current))
		return
	QDEL_NULL(picked_class)
	picked_class = owner.AddComponent(chosen)
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		owner.assigned_role = picked_class.name
	update_static_data(owner.current)

/datum/antagonist/darkspawn/antag_panel_data()
	. = ""
	if(team)
		. += "<b>Lucidity:</b> [team.lucidity] / [team.required_succs]<br>"
		. += "<b>Max Thralls:</b> [team.max_thralls]<br>"
	. += "<b>Willpower:</b> [willpower]<br>"
	. += "<b>Psi:</b> [psi]/[psi_cap], [psi_per_second]/s, [psi_regen_delay ? "[psi_regen_delay / 10] s delay" : "no delay"]<br>"
	if(picked_class)
		. += "<b>Class:</b> [picked_class.name]<br><b>Upgrades:</b><br>"
		for(var/datum/psi_web/ability as anything in picked_class.learned_abilities)
			. += "[ability.name]<br>"

// Drużyna

/datum/team/darkspawn
	name = "Darkspawni"
	member_name = "darkspawn"
	/// Umysły thralli
	var/list/datum/mind/thralls = list()
	/// Ile różnych umysłów trzeba pożreć do Sakramentu (tryb ustawia według liczby graczy)
	var/required_succs = 10
	/// Postęp do następnej woli od guzów cienia
	var/current_willpower_progress = 0
	var/max_willpower_progress = 100
	/// Ile umysłów już pożarto
	var/lucidity = 0
	/// Ilu thralli może być naraz
	var/max_thralls = 0
	/// Czy darkspawni już wiedzą, że mogą odprawić Sakrament
	var/announced = FALSE

/datum/team/darkspawn/New(starting_members)
	. = ..()
	objectives += new /datum/objective/darkspawn
	update_objectives()
	addtimer(CALLBACK(src, PROC_REF(enable_validhunt)), 75 MINUTES)

/datum/team/darkspawn/remove_member(datum/mind/member)
	. = ..()
	thralls -= member

/datum/team/darkspawn/proc/set_required_succs(players)
	required_succs = clamp(round(players / 2), 5, 25)
	update_objectives()

/datum/team/darkspawn/proc/update_objectives()
	for(var/datum/objective/darkspawn/O in objectives)
		O.required_succs = required_succs
		O.update_explanation_text()

/datum/team/darkspawn/proc/add_thrall(datum/mind/new_member)
	thralls |= new_member

/datum/team/darkspawn/proc/remove_thrall(datum/mind/member)
	thralls -= member

/datum/team/darkspawn/roundend_report()
	var/list/report = list()
	if(GLOB.sacrament_done)
		report += "<span class='greentext big'>Darkspawni znów się wznieśli! Stacja na zawsze przepadła za zasłoną.</span>"
	else
		report += "<span class='header'>[name]:</span>"
		if(check_darkspawn_death())
			report += "<span class='redtext big'>Załoga zabiła darkspawnów!</span>"
		else if(EMERGENCY_ESCAPED_OR_ENDGAMED)
			report += "<span class='redtext big'>Załoga uciekła, zanim darkspawni zdążyli odprawić Sakrament!</span>"
		else
			report += "<span class='redtext big'>Darkspawnom się nie udało!</span>"
	report += "Darkspawnami byli:"
	report += printplayerlist(members)
	if(LAZYLEN(thralls))
		report += "Thrallami byli:"
		report += printplayerlist(thralls)
	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/// TRUE, jeśli nie został żaden żywy darkspawn z graczem
/datum/team/darkspawn/proc/check_darkspawn_death()
	for(var/datum/mind/dark_mind as anything in members)
		if(!istype(dark_mind) || !dark_mind.current || QDELETED(dark_mind.current))
			continue
		if(dark_mind.current.stat == DEAD)
			continue
		if(isbrain(dark_mind.current) || issilicon(dark_mind.current))
			continue
		if(!dark_mind.current.ckey)
			continue
		return FALSE
	return TRUE

/datum/team/darkspawn/proc/willpower_progress(amount = 1)
	current_willpower_progress += amount
	if(current_willpower_progress >= max_willpower_progress)
		current_willpower_progress -= max_willpower_progress
		max_willpower_progress *= 1.1 // każda kolejna wola przychodzi trudniej
		grant_willpower(1)

/// Daje wolę każdemu darkspawnowi w drużynie
/datum/team/darkspawn/proc/grant_willpower(amount = 1)
	for(var/datum/mind/master as anything in members)
		var/datum/antagonist/darkspawn/antag = master.has_antag_datum(/datum/antagonist/darkspawn)
		if(antag)
			antag.willpower += amount

/datum/team/darkspawn/proc/grant_lucidity(amount = 1)
	lucidity += amount
	if(lucidity >= required_succs - 1) // tuż przed celem załoga dostaje przyzwolenie na wszystko
		enable_validhunt()
	if(lucidity >= required_succs && !announced)
		announced = TRUE
		for(var/datum/mind/master as anything in members)
			if(master.current)
				to_chat(master.current, "<span class='velvet bold'>Zebraliście dość jasności! Odprawcie Sakrament, żeby znów się wznieść!</span>")
	if(lucidity >= required_succs + 5) // nie farmić rundy, która już jest wygrana
		for(var/datum/mind/master as anything in members)
			if(master.current)
				to_chat(master.current, "<span class='userdanger'>Twoja postać nie utrzyma tyle energii!</span>")
				master.current.gib(TRUE, TRUE, TRUE)

/datum/team/darkspawn/proc/upon_sacrament()
	for(var/datum/mind/master as anything in members)
		if(!master.current)
			continue
		var/dead = master.current.stat == DEAD
		master.current.grab_ghost()
		master.current.revive(TRUE)
		if(dead)
			to_chat(master.current, "<span class='velvet'>Powrót do Pustki ożywił twoje ciało.</span>")

/// Po 75 minutach albo tuż przed Sakramentem: kod gamma i ogłoszenie dla załogi
/datum/team/darkspawn/proc/enable_validhunt()
	if(check_darkspawn_death() || GLOB.security_level >= SEC_LEVEL_RED)
		return
	set_security_level(SEC_LEVEL_RED)
	priority_announce("Na pokładzie wykryto niebezpieczne fluktuacje zasłony. Zachowajcie najwyższą czujność wobec nietypowych istot władających nienaturalnymi mocami.", "Departament Spraw Wyższych Wymiarów CentComu")

/datum/objective/darkspawn
	name = "Sakrament"
	explanation_text = "Osiągnij jasność umysłu i odpraw Sakrament."
	var/required_succs = 10

/datum/objective/darkspawn/update_explanation_text()
	explanation_text = "Pożrej wolę tylu osób, żeby zebrać [required_succs] jasności, i odpraw Sakrament."

/datum/objective/darkspawn/check_completion()
	if(..())
		return TRUE
	return GLOB.sacrament_done

// Licznik Psi na HUD

/atom/movable/screen/darkspawn_psi
	name = "psi"
	icon = 'aquila/icons/mob/darkspawn/psi_counter.dmi'
	icon_state = "psi_counter"
	screen_loc = ui_lingchemdisplay
	invisibility = INVISIBILITY_ABSTRACT

/datum/hud
	var/atom/movable/screen/darkspawn_psi/psi_counter

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	psi_counter = new /atom/movable/screen/darkspawn_psi()
	psi_counter.hud = src
	infodisplay += psi_counter

/datum/hud/Destroy()
	. = ..()
	psi_counter = null

// Ułatwienia do nadawania ról

/mob/living/proc/add_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/darkspawn)

/mob/living/proc/remove_darkspawn()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/darkspawn)
