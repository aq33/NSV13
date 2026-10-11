// Port BeeStation/BeeStation-Hornet#12738 i #13722: jedna ankieta na rolę ducha, pokazywana jako alert.
// Różnice: teksty po polsku, nasz stary dźwięk powiadomienia (notice2.ogg; nowy dźwięk z Bee bez pewnej licencji
// i bez wolnego bitu na jego opcję), COMSIG_PARENT_QDELETING zamiast COMSIG_PREQDELETED/COMSIG_QDELETING,
// bez wpisywania ankiet do menu spawnerów.

/// The datum that describes one instance of candidate polling
/datum/candidate_poll
	/// Settings for the poll
	var/datum/poll_config/config
	/// The players who signed up to this poll
	var/list/mob/signed_up
	/// the linked alert buttons
	var/list/atom/movable/screen/alert/poll_alert/alert_buttons = list()
	/// The world.time at which the poll was created
	var/time_started
	/// Whether the polling is finished
	var/finished = FALSE
	/// Used to categorize in the alerts system and identify polls of same question+role so we can stack the alert buttons
	var/poll_key
	///Response messages sent in specific key areas for full customization of polling.
	var/list/response_messages = list(
		POLL_RESPONSE_SIGNUP = "Zgłosiłeś się na: %ROLE%! Wkrótce zostanie wylosowany kandydat.",
		POLL_RESPONSE_ALREADY_SIGNED = "Już się na to zgłosiłeś!",
		POLL_RESPONSE_NOT_SIGNED = "Nie jesteś na to zgłoszony!",
		POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "Za późno na wycofanie się, losowanie już trwa!",
		POLL_RESPONSE_UNREGISTERED = "Wycofałeś zgłoszenie na: %ROLE%. Możesz zgłosić się ponownie, dopóki ankieta trwa.",
	)
	/// List of candidates chosen by the poll
	var/list/chosen_candidates = list()

/datum/candidate_poll/New(datum/poll_config/config)
	if (config == null)
		CRASH("Assertion Violation: Creating a poll without passing a valid config for that poll.")
	signed_up = list()
	time_started = world.time
	poll_key = "[config.question]_[config.role ? config.role : "0"]"
	src.config = config
	if(length(config.custom_response_messages))
		response_messages = config.custom_response_messages
	for(var/individual_message in response_messages)
		response_messages[individual_message] = replacetext(response_messages[individual_message], "%ROLE%", config.role_name_text)
	return ..()

/datum/candidate_poll/Destroy()
	if(src in SSpolling.currently_polling)
		SSpolling.polling_finished(src)
		return QDEL_HINT_IWILLGC // the above proc will call QDEL_IN(src, 0.5 SECONDS)
	config.jump_target = null
	signed_up = null
	return ..()

/datum/candidate_poll/proc/clear_alert_ref(atom/movable/screen/alert/poll_alert/source)
	SIGNAL_HANDLER
	alert_buttons -= source

/datum/candidate_poll/proc/sign_up(mob/candidate, silent = FALSE, skip_confirmation = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(candidate in signed_up)
		if(!silent)
			to_chat(candidate, "<span class='warning'>[response_messages[POLL_RESPONSE_ALREADY_SIGNED]]</span>")
		return FALSE
	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, "<span class='danger'>Niestety, zgłosiłeś się za późno!</span>")
			SEND_SOUND(candidate, 'sound/machines/buzz-sigh.ogg')
		return FALSE

	if (!skip_confirmation && config.requires_confirmation)
		if (tgui_alert(candidate, "Na pewno chcesz zgłosić się na: [config.role_name_text]?", "Potwierdzenie", list("Tak", "Nie"), 10 SECONDS) != "Tak")
			return FALSE
		// Re-check all initial conditions
		if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
			return FALSE
		if(candidate in signed_up)
			if(!silent)
				to_chat(candidate, "<span class='warning'>[response_messages[POLL_RESPONSE_ALREADY_SIGNED]]</span>")
			return FALSE
		if(time_left() <= 0)
			if(!silent)
				to_chat(candidate, "<span class='danger'>Niestety, zgłosiłeś się za późno!</span>")
				SEND_SOUND(candidate, 'sound/machines/buzz-sigh.ogg')
			return FALSE

	signed_up += candidate
	RegisterSignal(candidate, COMSIG_PARENT_QDELETING, PROC_REF(on_candidate_deleted))
	if(!silent)
		to_chat(candidate, "<span class='notice'>[response_messages[POLL_RESPONSE_SIGNUP]]</span>")
		// Sign them up for any other polls with the same mob type
		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && !(candidate in existing_poll.signed_up))
				existing_poll.sign_up(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/remove_candidate(mob/candidate, silent = FALSE)
	if(!istype(candidate) || isnull(candidate.key) || isnull(candidate.client))
		return FALSE
	if(!(candidate in signed_up))
		if(!silent)
			to_chat(candidate, "<span class='warning'>[response_messages[POLL_RESPONSE_NOT_SIGNED]]</span>")
		return FALSE

	if(time_left() <= 0)
		if(!silent)
			to_chat(candidate, "<span class='danger'>[response_messages[POLL_RESPONSE_TOO_LATE_TO_UNREGISTER]]</span>")
		return FALSE

	signed_up -= candidate
	UnregisterSignal(candidate, COMSIG_PARENT_QDELETING)
	if(!silent)
		to_chat(candidate, "<span class='danger'>[response_messages[POLL_RESPONSE_UNREGISTERED]]</span>")

		for(var/datum/candidate_poll/existing_poll as anything in SSpolling.currently_polling)
			if(src != existing_poll && poll_key == existing_poll.poll_key && (candidate in existing_poll.signed_up))
				existing_poll.remove_candidate(candidate, TRUE)
	for(var/atom/movable/screen/alert/poll_alert/linked_button as anything in alert_buttons)
		linked_button.update_candidates_number_overlay()
	return TRUE

/datum/candidate_poll/proc/on_candidate_deleted(datum/candidate)
	SIGNAL_HANDLER
	remove_candidate(candidate, TRUE)

/datum/candidate_poll/proc/do_never_for_this_round(mob/candidate)
	var/list/ignore_list = GLOB.poll_ignore[config.ignore_category]
	if(!ignore_list)
		GLOB.poll_ignore[config.ignore_category] = list()
	GLOB.poll_ignore[config.ignore_category] += candidate.ckey
	to_chat(candidate, "<span class='danger'>Zapamiętano: nigdy w tej rundzie.</span>")
	remove_candidate(candidate, silent = TRUE)

/datum/candidate_poll/proc/undo_never_for_this_round(mob/candidate)
	GLOB.poll_ignore[config.ignore_category] -= candidate.ckey
	to_chat(candidate, "<span class='notice'>Zapamiętano: możesz być wybrany w tej rundzie.</span>")

/datum/candidate_poll/proc/trim_candidates()
	listclearnulls(signed_up)
	for(var/mob/candidate as anything in signed_up)
		if(isnull(candidate.key) || isnull(candidate.client))
			signed_up -= candidate
			UnregisterSignal(candidate, COMSIG_PARENT_QDELETING)

/datum/candidate_poll/proc/time_left()
	return config.poll_time - (world.time - time_started)

/// Print to chat which candidate was selected
/datum/candidate_poll/proc/announce_chosen(list/poll_recipients)
	if(!length(chosen_candidates))
		return
	for(var/mob/chosen in chosen_candidates)
		var/client/chosen_client = chosen.client
		if(!chosen_client)
			continue
		for(var/mob/poll_recipient as anything in poll_recipients)
			if(QDELETED(poll_recipient))
				continue
			to_chat(poll_recipient, "<span class='ooc'>[isobserver(poll_recipient) ? FOLLOW_LINK(poll_recipient, chosen_client.mob) : null]<span class='warning'> Ankieta ([capitalize(config.role_name_text || "rola")]): </span>wybrano gracza.</span>")

/datum/candidate_poll/proc/show_to(mob/candidate_mob, start_signed_up = FALSE, flash_window = FALSE)
	if(!candidate_mob.client)
		return
	// Universal opt-out for all players.
	if(!SSpolling.is_eligible(candidate_mob, config.role, config.check_jobban, config.ignore_category, config.req_hours))
		return

	if(start_signed_up)
		sign_up(candidate_mob, TRUE)
	if(flash_window && !config.silent)
		window_flash(candidate_mob.client)

	var/category = "[poll_key]_poll_alert"

	// If we somehow send two polls for the same mob type, but with a duration on the second one shorter than the time left on the first one,
	// we need to keep the first one's timeout rather than use the shorter one
	var/atom/movable/screen/alert/poll_alert/current_alert = LAZYACCESS(candidate_mob.alerts, category)
	var/alert_time = config.poll_time
	var/datum/candidate_poll/alert_poll = src
	if(current_alert && current_alert.timeout > (world.time + config.poll_time - world.tick_lag))
		alert_time = current_alert.timeout - world.time + world.tick_lag
		alert_poll = current_alert.poll

	// Send them an on-screen alert
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = create_alert(candidate_mob, alert_poll, category, alert_time, start_signed_up, flash_window)
	if(!poll_alert_button)
		return

	alert_buttons += poll_alert_button
	RegisterSignal(poll_alert_button, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/candidate_poll, clear_alert_ref))

	// Sign up inheritance and stacking
	for(var/datum/candidate_poll/other_poll as anything in SSpolling.currently_polling)
		if(src == other_poll || poll_key != other_poll.poll_key)
			continue
		// If there's already a poll for an identical mob type ongoing and the client is signed up for it, sign them up for this one
		if((candidate_mob in other_poll.signed_up) && src.sign_up(candidate_mob, TRUE))
			break

	// Image to display
	var/image/poll_image
	if(ispath(config.alert_pic, /atom) || isatom(config.alert_pic))
		poll_image = new /mutable_appearance(config.alert_pic)
		poll_image.layer = FLOAT_LAYER
		poll_image.plane = poll_alert_button.plane
		poll_image.pixel_z = 0
	else if(!isnull(config.alert_pic))
		poll_image = config.alert_pic
	else
		// Bez obrazka z ankiety: ikona roli z okna antagonistów, a gdy jej nie ma, szum
		var/datum/role_preference/role_pref = ispath(config.role, /datum/role_preference) ? GLOB.role_preference_entries[config.role] : null
		var/icon/role_icon = role_pref?.get_poll_icon()
		if(role_icon)
			poll_image = image(role_icon)
		else
			poll_image = image('icons/effects/effects.dmi', icon_state = "static")
		poll_image.layer = FLOAT_LAYER
		poll_image.plane = poll_alert_button.plane

	if(poll_image)
		poll_alert_button.add_overlay(poll_image)

	// Chat message
	var/act_jump = ""
	var/custom_link_style_start = "<style>a:visited{color:Crimson !important}</style>"
	var/custom_link_style_end = "style='color:DodgerBlue;font-weight:bold;-dm-text-outline: 1px black'"
	if(isatom(config.alert_pic) && isobserver(candidate_mob))
		act_jump = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];jump=1'[custom_link_style_end]>\[Teleportuj\]</a>"
	var/act_signup = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];signup=1'[custom_link_style_end]>\[[start_signed_up ? "Wypisz się" : "Zgłoś się"]\]</a>"
	var/act_never = ""
	if(config.ignore_category)
		act_never = "[custom_link_style_start]<a href='byond://?src=[REF(poll_alert_button)];never=1'[custom_link_style_end]>\[Nigdy w tej rundzie\]</a>"

	if(!SSpolling.duplicate_message_check(alert_poll) && !config.silent) //Only notify people once. They'll notice if there are multiple and we don't want to spam people.
		SEND_SOUND(candidate_mob, 'sound/misc/notice2.ogg')

		var/surrounding_icon
		if(config.chat_text_border_icon)
			var/image/surrounding_image
			if(!ispath(config.chat_text_border_icon))
				var/mutable_appearance/border_image = config.chat_text_border_icon
				surrounding_image = border_image
			else
				surrounding_image = image(config.chat_text_border_icon)
			surrounding_icon = icon2html(surrounding_image, candidate_mob, extra_classes = "bigicon")
		var/final_message = EXAMINE_BLOCK("<span style='text-align:center;display:block'>[surrounding_icon] <span style='font-size:1.2em'><span class='ooc'>[config.question]</span></span> [surrounding_icon]\n[act_jump]      [act_signup]      [act_never]</span>")
		to_chat(candidate_mob, final_message)

	// Start processing it so it updates visually the timer
	START_PROCESSING(SSprocessing, poll_alert_button)

/datum/candidate_poll/proc/create_alert(mob/candidate_mob, datum/candidate_poll/alert_poll, category, alert_time, start_signed_up = FALSE, flash_window = FALSE)
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, timeout_override = alert_time, no_anim = TRUE)
	if(!poll_alert_button)
		return null
	poll_alert_button.icon = ui_style2icon(candidate_mob.client?.prefs?.UI_style)
	poll_alert_button.desc = "[config.question]"
	poll_alert_button.show_time_left = TRUE
	poll_alert_button.poll = alert_poll
	poll_alert_button.set_role_overlay()
	poll_alert_button.update_stacks_overlay()
	poll_alert_button.update_candidates_number_overlay()
	poll_alert_button.update_signed_up_overlay()
	return poll_alert_button

// ================================
// Persistent Candidate Poll
// ================================

/datum/candidate_poll/persistent
	/// Called when a mob signs up, passing thruogh the
	/// persistent poll as the first argument, and the list
	/// of candidates as the second
	var/datum/callback/on_signup

/datum/candidate_poll/persistent/sign_up(mob/candidate, silent = FALSE, skip_confirmation = FALSE)
	if (!..())
		return FALSE
	on_signup?.Invoke(src, signed_up)
	return TRUE

/datum/candidate_poll/persistent/time_left()
	return INFINITY

/datum/candidate_poll/persistent/create_alert(mob/candidate_mob, datum/candidate_poll/alert_poll, category, alert_time, start_signed_up = FALSE, flash_window = FALSE)
	var/atom/movable/screen/alert/poll_alert/poll_alert_button = candidate_mob.throw_alert(category, /atom/movable/screen/alert/poll_alert, no_anim = TRUE)
	if(!poll_alert_button)
		return null
	poll_alert_button.icon = ui_style2icon(candidate_mob.client?.prefs?.UI_style)
	poll_alert_button.desc = "[config.question]"
	poll_alert_button.show_time_left = FALSE
	poll_alert_button.poll = alert_poll
	poll_alert_button.set_role_overlay()
	poll_alert_button.update_stacks_overlay()
	poll_alert_button.update_candidates_number_overlay()
	poll_alert_button.update_signed_up_overlay()
	poll_alert_button.timeout = INFINITY
	return poll_alert_button

/datum/candidate_poll/persistent/proc/end_poll()
	SSpolling.polling_finished(src)
