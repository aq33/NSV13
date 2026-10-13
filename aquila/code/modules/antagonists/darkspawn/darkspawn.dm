// AQUILA - darkspawn (port z Yogstation, wersja sprzed przeróbki z 2024)
// Obcy ukryci w ludzkiej skórze. Zrzucają ją (Divulge), pożerają wolę załogi i odprawiają Sakrament.

GLOBAL_DATUM(darkspawn_team, /datum/team/darkspawn)

/proc/get_darkspawn_team()
	RETURN_TYPE(/datum/team/darkspawn)
	if(!GLOB.darkspawn_team)
		GLOB.darkspawn_team = new
	return GLOB.darkspawn_team

/datum/team/darkspawn
	name = "Darkspawn"
	member_name = "darkspawn"
	/// Ile różnych umysłów trzeba pożreć, żeby odprawić Sakrament (tryb ustawia to według liczby graczy)
	var/required_succs = 15
	/// Czy ktoś już odprawił Sakrament
	var/sacrament_done = FALSE
	/// Umysły welonów
	var/list/datum/mind/veils = list()

/datum/team/darkspawn/proc/set_required_succs(players)
	required_succs = clamp(round(players / 3), 15, 30)

/datum/team/darkspawn/roundend_report()
	var/list/parts = list()
	if(sacrament_done)
		parts += "<span class='greentext big'>Darkspawni odprawili Sakrament!</span>"
	else if(all_darkspawn_dead())
		parts += "<span class='redtext big'>Załoga zabiła darkspawnów!</span>"
	else if(SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		parts += "<span class='redtext big'>Załoga uciekła, zanim darkspawni zdążyli odprawić Sakrament!</span>"
	else
		parts += "<span class='redtext big'>Darkspawnom się nie udało!</span>"
	parts += "<span class='header'>Darkspawnami byli:</span>"
	parts += printplayerlist(members)
	if(length(veils))
		parts += "<span class='header'>Welonami byli:</span>"
		parts += printplayerlist(veils)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/darkspawn/proc/all_darkspawn_dead()
	for(var/datum/mind/dark_mind as anything in members)
		if(dark_mind.current && dark_mind.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawni"
	antagpanel_category = "Darkspawn"
	banning_key = ROLE_DARKSPAWN
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	var/datum/team/darkspawn/team
	/// MUNDANE = w ludzkiej skórze, DIVULGED = prawdziwa postać, PROGENITOR = po Sakramencie
	var/darkspawn_state = DARKSPAWN_MUNDANE

	// Psi, czyli mana zdolności
	var/psi = 100
	var/psi_cap = 100
	/// Ile Psi wraca po użyciu zdolności
	var/psi_regen = 20
	/// Ile ticków musi minąć, zanim Psi zacznie wracać
	var/psi_regen_delay = 5
	var/psi_regen_ticks = 0
	/// Ile Psi zużyto od ostatniej regeneracji
	var/psi_used_since_regen = 0
	var/psi_regenerating = FALSE

	/// Lucidity, za którą kupuje się zdolności w Sieci Psi
	var/lucidity = 3
	/// Ile różnych umysłów pożarto (liczy się do Sakramentu)
	var/lucidity_drained = 0

	/// "id" = datum zdolności
	var/list/abilities = list()
	/// "id" = TRUE dla kupionych ulepszeń
	var/list/upgrades = list()
	var/datum/psi_web/psi_web
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
	add_ability("divulge", TRUE)
	force_divulge_timer = addtimer(CALLBACK(src, PROC_REF(begin_force_divulge)), 23 MINUTES, TIMER_STOPPABLE)
	START_PROCESSING(SSprocessing, src)
	var/datum/objective/darkspawn/objective = new
	objective.owner = owner
	objective.team = team
	objective.update_explanation_text()
	objectives += objective
	. = ..()
	update_psi_hud()
	owner.announce_objectives()

/datum/antagonist/darkspawn/on_removal()
	team?.remove_member(owner)
	if(owner.special_role == ROLE_DARKSPAWN)
		owner.special_role = null
	deltimer(force_divulge_timer)
	STOP_PROCESSING(SSprocessing, src)
	for(var/id in abilities)
		remove_ability(id, TRUE)
	QDEL_NULL(psi_web)
	hide_psi_hud(owner.current)
	return ..()

/datum/antagonist/darkspawn/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(psi_web)
	return ..()

/datum/antagonist/darkspawn/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	handle_clown_mutation(current_mob, mob_override ? null : "Nasze moce pozwalają przezwyciężyć klaunowską naturę, możemy więc swobodnie używać broni.")
	current_mob.grant_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	add_antag_hud(ANTAG_HUD_SHADOW, "shadowling", current_mob)

/datum/antagonist/darkspawn/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	remove_antag_hud(ANTAG_HUD_SHADOW, current_mob)

/datum/antagonist/darkspawn/greet()
	to_chat(owner.current, "<span class='velvet bold big'>Jesteś darkspawnem!</span>")
	to_chat(owner.current, "<i>Dopisz :[MODE_KEY_DARKSPAWN] lub .[MODE_KEY_DARKSPAWN] przed wiadomością, żeby bezgłośnie mówić do innych darkspawnów przez Mindlink.</i>")
	to_chat(owner.current, "<i>Gdy będziesz gotowy, schowaj się w ciemnym, ustronnym miejscu i użyj Divulge, żeby zrzucić ludzką skórę.</i>")
	to_chat(owner.current, "<span class='boldwarning'>Jeśli nie zrobisz tego w ciągu dwudziestu pięciu minut, stanie się to samo. Przygotuj się szybko.</span>")
	to_chat(owner.current, "<i>Pamiętaj, że potem światło będzie cię zabijać, a ciemność leczyć. Trzymaj się cieni.</i>")
	owner.current.playsound_local(get_turf(owner.current), 'aquila/sound/darkspawn/darkspawn.ogg', 50, FALSE)

/datum/antagonist/darkspawn/roundend_report()
	return "[owner ? printplayer(owner) : "Bezimienny darkspawn"]"

// Panel admina

/datum/antagonist/darkspawn/antag_panel_data()
	. = "<b>Zdolności:</b><br>"
	for(var/id in abilities)
		var/datum/action/innate/darkspawn/ability = abilities[id]
		if(ability)
			. += "[ability.name] ([ability.id])<br>"
	. += "<br><b>Ulepszenia:</b><br>"
	for(var/id in upgrades)
		. += "[id]<br>"

/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	.["Give Ability"] = CALLBACK(src, PROC_REF(admin_give_ability))
	.["Take Ability"] = CALLBACK(src, PROC_REF(admin_take_ability))
	if(darkspawn_state == DARKSPAWN_MUNDANE)
		.["Divulge"] = CALLBACK(src, PROC_REF(divulge))
		.["Force-Divulge (Obvious)"] = CALLBACK(src, PROC_REF(force_divulge))
	else if(darkspawn_state == DARKSPAWN_DIVULGED)
		.["Give Upgrade"] = CALLBACK(src, PROC_REF(admin_give_upgrade))
		.["[psi]/[psi_cap] Psi"] = CALLBACK(src, PROC_REF(admin_edit_psi))
		.["[lucidity] Lucidity"] = CALLBACK(src, PROC_REF(admin_edit_lucidity))
		.["[lucidity_drained] / [team?.required_succs] Unique Lucidity"] = CALLBACK(src, PROC_REF(admin_edit_lucidity_drained))
		.["Sacrament (ENDS THE ROUND)"] = CALLBACK(src, PROC_REF(sacrament))

/datum/antagonist/darkspawn/proc/admin_give_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID, or \"all\" to give all of them.", "Give Ability")
	if(!id)
		return
	if(has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] already has this ability!</span>")
		return
	if(id != "all")
		add_ability(id, FALSE, TRUE)
		to_chat(admin, "<span class='notice'>Gave [owner.current] the ability \"[id]\".</span>")
		return
	for(var/datum/action/innate/darkspawn/ability_type as anything in subtypesof(/datum/action/innate/darkspawn))
		if(!has_ability(initial(ability_type.id)) && !initial(ability_type.blacklisted))
			add_ability(initial(ability_type.id), FALSE, TRUE)
	to_chat(admin, "<span class='notice'>Gave [owner.current] all abilities.</span>")

/datum/antagonist/darkspawn/proc/admin_take_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID.", "Take Ability")
	if(!id)
		return
	if(!has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] does not have this ability!</span>")
		return
	remove_ability(id)
	to_chat(admin, "<span class='danger'>Took from [owner.current] the ability \"[id]\".</span>")

/datum/antagonist/darkspawn/proc/admin_give_upgrade(mob/admin)
	var/id = stripped_input(admin, "Enter an upgrade ID, or \"all\" to give all of them.", "Give Upgrade")
	if(!id)
		return
	if(has_upgrade(id))
		to_chat(admin, "<span class='warning'>[owner.current] already has this upgrade!</span>")
		return
	if(id != "all")
		add_upgrade(id, FALSE, TRUE)
		to_chat(admin, "<span class='notice'>Gave [owner.current] the upgrade \"[id]\".</span>")
		return
	for(var/datum/darkspawn_upgrade/upgrade_type as anything in subtypesof(/datum/darkspawn_upgrade))
		if(!has_upgrade(initial(upgrade_type.id)))
			add_upgrade(initial(upgrade_type.id), FALSE, TRUE)
	to_chat(admin, "<span class='notice'>Gave [owner.current] all upgrades.</span>")

/datum/antagonist/darkspawn/proc/admin_edit_psi(mob/admin)
	var/new_psi = input(admin, "Enter a new psi amount. (Current: [psi]/[psi_cap])", "Change Psi", psi) as null|num
	if(isnull(new_psi))
		return
	psi = clamp(new_psi, 0, psi_cap)
	update_psi_hud()

/datum/antagonist/darkspawn/proc/admin_edit_lucidity(mob/admin)
	var/new_lucidity = input(admin, "Enter a new lucidity amount. (Current: [lucidity])", "Change Lucidity", lucidity) as null|num
	if(isnull(new_lucidity))
		return
	lucidity = max(0, new_lucidity)

/datum/antagonist/darkspawn/proc/admin_edit_lucidity_drained(mob/admin)
	var/new_lucidity = input(admin, "Enter a new lucidity amount. (Current: [lucidity_drained])", "Change Lucidity Drained", lucidity_drained) as null|num
	if(isnull(new_lucidity))
		return
	lucidity_drained = max(0, new_lucidity)

// Psi

/datum/antagonist/darkspawn/process()
	psi = min(psi, psi_cap)
	if(psi != psi_cap)
		psi_regen_ticks--
		if(psi_regen_ticks <= 0)
			regenerate_psi()
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_psi(amount)
	return psi >= amount

/datum/antagonist/darkspawn/proc/use_psi(amount)
	if(!has_psi(amount))
		return FALSE
	psi_regen_ticks = psi_regen_delay
	psi_used_since_regen += amount
	psi = round(psi - amount, 0.2)
	update_psi_hud()
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	if(psi_regenerating)
		return
	psi_regenerating = TRUE
	var/total_regen = min(psi_regen, psi_used_since_regen)
	// Nabija Psi szybko po jednym punkcie zamiast od razu całości; psi_cap chroni przed nieskończoną pętlą
	for(var/i in 1 to psi_cap)
		if(!total_regen || psi >= psi_cap || QDELETED(src))
			break
		psi = min(psi + 1, psi_cap)
		total_regen--
		update_psi_hud()
		sleep(0.05 SECONDS)
	if(QDELETED(src))
		return
	psi_used_since_regen = 0
	psi_regen_ticks = psi_regen_delay
	psi_regenerating = FALSE

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

// Zdolności i ulepszenia

/// Przenosi przyciski zdolności na obecne ciało (po przejściu w inne ciało albo ponownym zalogowaniu)
/datum/antagonist/darkspawn/proc/regain_abilities()
	for(var/id in abilities)
		var/datum/action/innate/darkspawn/ability = abilities[id]
		if(!ability)
			continue
		if(ability.owner)
			ability.Remove(ability.owner)
		ability.Grant(owner.current)
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_ability(id)
	return abilities[id]

/datum/antagonist/darkspawn/proc/add_ability(id, silent, no_cost)
	if(has_ability(id))
		return FALSE
	for(var/datum/action/innate/darkspawn/ability_type as anything in subtypesof(/datum/action/innate/darkspawn))
		if(initial(ability_type.id) != id)
			continue
		var/datum/action/innate/darkspawn/action = new ability_type(src)
		action.darkspawn = src
		action.Grant(owner.current)
		abilities[id] = action
		if(!silent)
			to_chat(owner.current, "<span class='velvet'>Nauczyłeś się zdolności <b>[action.name]</b>.</span>")
		if(!no_cost)
			lucidity = max(0, lucidity - action.lucidity_price)
		return TRUE
	return FALSE

/datum/antagonist/darkspawn/proc/remove_ability(id, silent)
	var/datum/action/innate/darkspawn/ability = has_ability(id)
	if(!ability)
		return FALSE
	if(!silent)
		to_chat(owner.current, "<span class='velvet'>Straciłeś zdolność <b>[ability.name]</b>.</span>")
	abilities -= id
	qdel(ability)
	return TRUE

/datum/antagonist/darkspawn/proc/has_upgrade(id)
	return upgrades[id]

/datum/antagonist/darkspawn/proc/add_upgrade(id, silent, no_cost)
	if(has_upgrade(id))
		return FALSE
	for(var/datum/darkspawn_upgrade/upgrade_type as anything in subtypesof(/datum/darkspawn_upgrade))
		if(initial(upgrade_type.id) != id)
			continue
		var/datum/darkspawn_upgrade/upgrade = new upgrade_type(src)
		upgrades[id] = TRUE
		if(!silent)
			to_chat(owner.current, "<span class='velvet bold'>Przyswoiłeś ulepszenie \"[upgrade.name]\".</span>")
		if(!no_cost)
			lucidity = max(0, lucidity - upgrade.lucidity_price)
		upgrade.unlock()
		return TRUE
	return FALSE

// Divulge

/datum/antagonist/darkspawn/proc/begin_force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE || !owner.current)
		return
	to_chat(owner.current, "<span class='userdanger'>Skóra, którą nosisz, trzeszczy jak papier. Wkrótce zrzucisz ją siłą! Znajdź ciemną kryjówkę!</span>")
	owner.current.playsound_local(owner.current, 'aquila/sound/darkspawn/divulge_01.ogg', 50, FALSE, pressure_affected = FALSE)
	force_divulge_timer = addtimer(CALLBACK(src, PROC_REF(force_divulge)), 2 MINUTES, TIMER_STOPPABLE)

/datum/antagonist/darkspawn/proc/force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE)
		return
	var/mob/living/current = owner.current
	if(!current)
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
	var/processed_message = "<span class='velvet'><b>\[Mindlink\] [H.real_name] nie zrzucił skóry na czas i robi to teraz siłą.</b></span>"
	for(var/mob/M as anything in GLOB.player_list)
		if(M.stat != DEAD && isdarkspawn(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, H)
	addtimer(CALLBACK(src, PROC_REF(divulge), TRUE), 2.5 SECONDS)

/datum/antagonist/darkspawn/proc/divulge(forced = FALSE)
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		return
	var/mob/living/carbon/human/user = owner.current
	if(!ishuman(user))
		return
	deltimer(force_divulge_timer)
	if(forced)
		user.visible_message("<span class='boldwarning'>Skóra [user] odpada, odsłaniając czarne ciało pokryte symbolami!</span>", \
			"<span class='userdanger'>Zrzuciłeś skórę siłą!</span>")
	to_chat(user, "<span class='velvet bold'>Twój umysł się rozszerzył. Sieć Psi stoi przed tobą otworem. Unikaj światła. Trzymaj się cieni. Twój czas nadejdzie.</span>")
	user.fully_heal()
	user.set_species(/datum/species/darkspawn)
	show_to_ghosts = TRUE
	psi_web = new(src)
	add_ability("psi_web", TRUE)
	add_ability("sacrament", TRUE)
	add_ability("devour_will", TRUE)
	add_ability("pass", TRUE)
	remove_ability("divulge", TRUE)
	darkspawn_state = DARKSPAWN_DIVULGED
	update_psi_hud()

// Sakrament

/datum/antagonist/darkspawn/proc/sacrament()
	var/mob/living/carbon/human/user = owner.current
	if(!user)
		return
	if(!team.sacrament_done)
		set_security_level(SEC_LEVEL_DELTA)
		addtimer(CALLBACK(src, PROC_REF(sacrament_shuttle_call)), 5 SECONDS)
	for(var/id in abilities)
		remove_ability(id, TRUE)
	// Wielki potomek przejmuje umysł
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user))
	user.status_flags |= GODMODE
	owner.transfer_to(progenitor)
	sound_to_playing_players('aquila/sound/darkspawn/sacrament_complete.ogg', 50, FALSE, pressure_affected = FALSE)
	psi = 9999
	psi_cap = 9999
	psi_regen = 9999
	psi_regen_delay = 1
	team.sacrament_done = TRUE
	darkspawn_state = DARKSPAWN_PROGENITOR
	SSblackbox.record_feedback("tally", "darkspawn", 1, "sacrament")
	QDEL_IN(user, 0.5 SECONDS)

/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, set_coefficient = 0.1)

// Cel

/datum/objective/darkspawn
	name = "Sakrament"
	explanation_text = "Osiągnij lucidity i odpraw Sakrament."

/datum/objective/darkspawn/update_explanation_text()
	var/datum/team/darkspawn/dark_team = team
	explanation_text = "Osiągnij lucidity i odpraw Sakrament. Musisz w tym celu pożreć wolę [dark_team?.required_succs || 15] różnych osób i kupić wszystkie ulepszenia pasywne."

/datum/objective/darkspawn/check_completion()
	if(..())
		return TRUE
	var/datum/team/darkspawn/dark_team = team
	return dark_team?.sacrament_done

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

// Po zalogowaniu (np. po wyjściu z Pełzających cieni) przyciski muszą wrócić na ciało
/mob/living/Login()
	. = ..()
	var/datum/antagonist/darkspawn/darkspawn = mind?.has_antag_datum(/datum/antagonist/darkspawn)
	darkspawn?.regain_abilities()
