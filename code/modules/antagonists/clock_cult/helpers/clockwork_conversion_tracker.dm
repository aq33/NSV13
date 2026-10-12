//Helps track the living % of the crew that are servants for when opening the ark automatically

GLOBAL_VAR(ark_transport_triggered)

GLOBAL_VAR(critical_servant_count)

GLOBAL_VAR_INIT(conversion_warning_stage, CONVERSION_WARNING_NONE)

//If there is a clockcult team (clockcult gamemode), add them to the team
/proc/add_servant_of_ratvar(mob/M, add_team = TRUE, silent=FALSE, servant_type = /datum/antagonist/servant_of_ratvar, datum/team/clock_cult/team = null)
	if(!istype(M))
		return
	if(!silent)
		hierophant_message("<b>[M]</b> zostaje nawrócony!", span = "<span class='sevtug'>", use_sanitisation=FALSE)
	var/datum/antagonist/servant_of_ratvar/antagdatum = servant_type
	if(ishuman(M) && (servant_type == /datum/antagonist/servant_of_ratvar) && GLOB.critical_servant_count)
		if((GLOB.critical_servant_count)/2 < GLOB.human_servants_of_ratvar.len)
			if(GLOB.conversion_warning_stage < CONVERSION_WARNING_HALFWAY)
				send_sound_to_servants(sound('sound/magic/clockwork/scripture_tier_up.ogg'))
				hierophant_message("Wpływ Rat'vara rośnie. Arka zostanie rozdarta, jeśli na wiarę Rat'vara nawróci się jeszcze [GLOB.critical_servant_count - GLOB.human_servants_of_ratvar.len] umysłów.", span="<span class='large_brass'>")
				GLOB.conversion_warning_stage = CONVERSION_WARNING_HALFWAY
		else if((3/4) * GLOB.critical_servant_count < GLOB.human_servants_of_ratvar.len)
			if(GLOB.conversion_warning_stage < CONVERSION_WARNING_THREEQUARTERS)
				send_sound_to_servants(sound('sound/magic/clockwork/scripture_tier_up.ogg'))
				hierophant_message("Czujesz, jak granica między rzeczywistością a fikcją słabnie, a Arka iskrzy tajemną energią.<br> Arka zostanie rozdarta, jeśli na wiarę Rat'vara nawróci się jeszcze [GLOB.critical_servant_count - GLOB.human_servants_of_ratvar.len] umysłów.", span="<span class='large_brass'>", use_sanitisation=FALSE)
				GLOB.conversion_warning_stage = CONVERSION_WARNING_THREEQUARTERS
		else if(GLOB.critical_servant_count-1 == GLOB.human_servants_of_ratvar.len)
			if(GLOB.conversion_warning_stage < CONVERSION_WARNING_CRITIAL)
				send_sound_to_servants(sound('sound/magic/clockwork/scripture_tier_up.ogg'))
				hierophant_message("Wewnętrzne zębatki Arki zaczynają się kręcić, gotowe do aktywacji.<br> Po kolejnym nawróceniu bariera wymiarowa będzie zbyt słaba, by Niebiańska Brama pozostała zamknięta, i zostanie otwarta siłą.", span="<span class='large_brass'>", use_sanitisation=FALSE)
				GLOB.conversion_warning_stage = CONVERSION_WARNING_CRITIAL
	return M.mind.add_antag_datum(antagdatum, team)

/proc/remove_servant_of_ratvar(datum/mind/cult_mind, silent, stun)
	if(cult_mind.current)
		var/datum/antagonist/servant_of_ratvar/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/servant_of_ratvar)
		if(!cult_datum)
			return FALSE
		to_chat(cult_mind, "<span class='large_brass'>Nigdy nie zapomnij o...[text2ratvar("e will of Eng'ine!")]...</span>")
		to_chat(cult_mind, "<span class='warning'>Ciche tykanie z tyłu głowy powoli cichnie...</span>")
		cult_datum.silent = silent
		cult_datum.on_removal()
		cult_mind.special_role = null
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/proc/calculate_clockcult_values()
	var/playercount = get_active_player_count()
	GLOB.critical_servant_count = round(max((playercount/6)+6,10))

/proc/check_ark_status()
	if(!GLOB.critical_servant_count)
		return
	if(GLOB.ark_transport_triggered)
		return
	//Cogscarabs will not trigger the gateway to open
	if(GLOB.human_servants_of_ratvar.len < GLOB.critical_servant_count)
		return FALSE
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, 'sound/magic/clockwork/scripture_tier_up.ogg')
	hierophant_message("Liczne zębatki Arki nagle ożywają z warkotem, a z jej szczelin bucha para; otworzy się za 5 minut!", null, "<span class='large_brass'>")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(force_open_ark)), 3000)
	GLOB.ark_transport_triggered = TRUE
	return TRUE

/proc/force_open_ark()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		log_runtime("Celestial gateway not located.")
		return
	gateway.open_gateway()

/proc/send_sound_to_servants(sound/S)
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		if(M.current.mind)
			SEND_SOUND(M.current, S)
	for(var/mob/dead/observer/O in GLOB.player_list)
		SEND_SOUND(O, S)
