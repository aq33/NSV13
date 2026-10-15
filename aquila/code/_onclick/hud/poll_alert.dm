// Port BeeStation/BeeStation-Hornet#12738 i #13722: alert ankiety na rolę ducha.
// Ikona roli, nazwa roli, licznik sekund, liczba zgłoszonych i znacznik „jesteś zgłoszony”.
// LPM: zgłoś się / wycofaj, Alt: nigdy w tej rundzie, Ctrl: skocz do celu (tylko duchy).
// Bez ukrywania prawym przyciskiem (can_hide), bo nie mamy set_right_click_menu_mode.

/atom/movable/screen/alert/poll_alert
	name = "Szukamy chętnych"
	icon_state = "template"
	timeout = 30 SECONDS
	clickable_glow = TRUE
	/// If true you need to call START_PROCESSING manually
	var/show_time_left = FALSE
	/// MA for maptext showing time left for poll
	var/mutable_appearance/time_left_overlay
	/// MA for overlay showing that you're signed up to poll
	var/mutable_appearance/signed_up_overlay
	/// MA for maptext overlay showing how many polls are stacked together
	var/mutable_appearance/stacks_overlay
	/// MA for maptext overlay showing how many candidates are signed up to a poll
	var/mutable_appearance/candidates_num_overlay
	/// MA for maptext overlay of poll's role name or question
	var/mutable_appearance/role_overlay
	/// If set, on Click() it'll register the player as a candidate
	var/datum/candidate_poll/poll

/atom/movable/screen/alert/poll_alert/Initialize(mapload)
	. = ..()
	signed_up_overlay = mutable_appearance('icons/mob/screen_gen.dmi', icon_state = "selector")

/atom/movable/screen/alert/poll_alert/proc/set_role_overlay()
	var/role_or_only_question = poll.config.role_name_text || "?"
	role_overlay = new
	role_overlay.screen_loc = screen_loc
	role_overlay.maptext = MAPTEXT("<span style='text-align: right; color: #B3E3FC'>[capitalize(role_or_only_question)]</span>")
	role_overlay.maptext_width = 128
	role_overlay.transform = role_overlay.transform.Translate(-128, 0)
	add_overlay(role_overlay)

/atom/movable/screen/alert/poll_alert/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(role_overlay)
	QDEL_NULL(time_left_overlay)
	QDEL_NULL(stacks_overlay)
	QDEL_NULL(candidates_num_overlay)
	QDEL_NULL(signed_up_overlay)
	poll?.alert_buttons -= src
	poll = null
	return ..()

/atom/movable/screen/alert/poll_alert/add_context_self(datum/screentip_context/context, mob/user)
	if(!poll)
		return
	context.add_left_click_action((owner in poll.signed_up) ? "Wycofaj zgłoszenie" : "Zgłoś się")
	if(poll.config.ignore_category)
		context.add_alt_click_action((owner.ckey in GLOB.poll_ignore[poll.config.ignore_category]) ? "Cofnij „nigdy w tej rundzie”" : "Nigdy w tej rundzie")
	if(poll.config.jump_target && isobserver(owner))
		context.add_ctrl_click_action("Skocz do celu")

/atom/movable/screen/alert/poll_alert/process(delta_time)
	if (poll)
		timeout = world.time + poll.time_left()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL
		if (time_left_overlay)
			cut_overlay(time_left_overlay)
		time_left_overlay = new
		time_left_overlay.maptext = MAPTEXT("<span style='color: [(timeleft <= 10 SECONDS) ? "red" : "white"]'><b>[CEILING(timeleft / (1 SECONDS), 1)]</b></span>")
		time_left_overlay.transform = time_left_overlay.transform.Translate(4, 19)
		add_overlay(time_left_overlay)
	else
		if (time_left_overlay)
			cut_overlay(time_left_overlay)
			time_left_overlay = null

/atom/movable/screen/alert/poll_alert/Click(location, control, params)
	if(isnull(poll) || usr != owner)
		return

	var/clicky = FALSE
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, "alt") && poll.config.ignore_category)
		clicky = TRUE
		set_never_round()
	if(LAZYACCESS(modifiers, "ctrl") && poll.config.jump_target)
		clicky = TRUE
		jump_to_jump_target()

	if(!clicky)
		handle_sign_up()
	refresh_screentips()

/atom/movable/screen/alert/poll_alert/proc/handle_sign_up()
	if(owner in poll.signed_up)
		poll.remove_candidate(owner)
	else if(!(owner.ckey in GLOB.poll_ignore[poll.config.ignore_category]))
		poll.sign_up(owner)
	// Sign-up may delete the poll in the case of overriden signup logic
	if (QDELETED(poll))
		return
	update_signed_up_overlay()

/atom/movable/screen/alert/poll_alert/proc/set_never_round()
	if(!(owner.ckey in GLOB.poll_ignore[poll.config.ignore_category]))
		poll.do_never_for_this_round(owner)
		color = "red"
		update_signed_up_overlay()
		return
	poll.undo_never_for_this_round(owner)
	color = initial(color)

/atom/movable/screen/alert/poll_alert/proc/jump_to_jump_target()
	if(!poll?.config.jump_target || !isobserver(owner))
		return
	var/turf/target_turf = get_turf(poll.config.jump_target)
	if(target_turf && isturf(target_turf))
		owner.abstract_move(target_turf)

/atom/movable/screen/alert/poll_alert/Topic(href, href_list)
	if(usr != owner || isnull(poll))
		return
	if(href_list["never"])
		set_never_round()
		return
	if(href_list["signup"])
		handle_sign_up()
	if(href_list["jump"])
		jump_to_jump_target()
		return

/atom/movable/screen/alert/poll_alert/proc/update_signed_up_overlay()
	if(owner in poll.signed_up)
		add_overlay(signed_up_overlay)
	else
		cut_overlay(signed_up_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_candidates_number_overlay()
	cut_overlay(candidates_num_overlay)
	if(!length(poll.signed_up))
		return
	candidates_num_overlay = new
	candidates_num_overlay.maptext = MAPTEXT("<span style='text-align: right; color: aqua'>[length(poll.signed_up)]</span>")
	candidates_num_overlay.transform = candidates_num_overlay.transform.Translate(-4, 2)
	add_overlay(candidates_num_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_stacks_overlay()
	cut_overlay(stacks_overlay)
	var/stack_number = 1
	for(var/datum/candidate_poll/other_poll as anything in SSpolling.currently_polling)
		if(other_poll != poll && other_poll.poll_key == poll.poll_key && !other_poll.finished)
			stack_number++
	if(stack_number <= 1)
		return
	stacks_overlay = new
	stacks_overlay.maptext = MAPTEXT("<span style='color: yellow'>[stack_number]x</span>")
	stacks_overlay.transform = stacks_overlay.transform.Translate(3, 2)
	stacks_overlay.layer = layer
	add_overlay(stacks_overlay)
