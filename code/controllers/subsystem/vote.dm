// AQ EDIT - port BeeStation #13247: votes are /datum/vote singletons (aquila/code/datums/votes) and the window is VotePanel.
// The map vote keeps our NSV13 MapVote window, preferred maps and map vote bans.
SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	/// A list of all generated action buttons
	var/list/datum/action/generated_actions = list()
	/// All votes that we can possible vote for, by name
	var/list/datum/vote/possible_votes = list()
	/// The vote we're currently voting on
	var/datum/vote/current_vote
	/// A list of all ckeys who have voted for the current vote
	var/list/voted = list()
	/// A list of all ckeys currently voting for the current vote
	var/list/voting = list()
	/// World.time we started our last vote
	var/last_vote_time = -INFINITY

/datum/controller/subsystem/vote/Initialize(timeofday)
	for(var/vote_type in subtypesof(/datum/vote))
		var/datum/vote/vote = new vote_type()
		if(!vote.is_accessible_vote())
			qdel(vote)
			continue
		possible_votes[vote.name] = vote
	return ..()

/datum/controller/subsystem/vote/fire()
	if(!current_vote)
		return
	current_vote.time_remaining = round((current_vote.started_time + CONFIG_GET(number/vote_period) - world.time) / 10)
	if(current_vote.time_remaining < 0)
		end_vote()

/// Ends the current vote
/datum/controller/subsystem/vote/proc/end_vote()
	ASSERT(current_vote)
	process_vote_result()
	SStgui.close_uis(src)
	reset()

/// Resets all of our vars after votes conclude / are cancelled
/datum/controller/subsystem/vote/proc/reset()
	voted.Cut()
	voting.Cut()
	current_vote?.reset()
	current_vote = null
	remove_action_buttons()
	SStgui.update_uis(src)

/// Collects the winners, breaks ties, prints the results and applies the effects of the vote
/datum/controller/subsystem/vote/proc/process_vote_result()
	// Non-voters who are here and not AFK
	var/list/non_voters = GLOB.directory.Copy() - voted
	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]
		if(!istype(non_voter_client) || non_voter_client.is_afk())
			non_voters -= non_voter_ckey

	var/list/winners = current_vote.get_vote_result(non_voters)
	var/final_winner
	if(length(winners) == 1)
		final_winner = winners[1]
	else if(length(winners) > 1)
		final_winner = current_vote.tiebreaker(winners)

	var/to_display = current_vote.get_result_text(winners, final_winner, non_voters)
	log_vote("[current_vote.name] vote finished, winner: [final_winner || "none"]. [json_encode(current_vote.choices)]")
	if(to_display)
		to_chat(world, "<span class='purple'>[to_display]</span>")

	current_vote.finalize_vote(final_winner)

/**
 * One selection per person, and the selection with the most votes wins.
 */
/datum/controller/subsystem/vote/proc/submit_single_vote(mob/voter, their_vote)
	if(!current_vote || !voter?.ckey)
		return
	if(!(their_vote in current_vote.choices))
		return
	if(!current_vote.can_mob_vote(voter))
		return

	// If user has already voted, remove their specific vote
	if(voter.ckey in current_vote.choices_by_ckey)
		var/their_old_vote = current_vote.choices_by_ckey[voter.ckey]
		current_vote.choices[their_old_vote]--
	else
		voted += voter.ckey

	current_vote.choices_by_ckey[voter.ckey] = their_vote
	current_vote.choices[their_vote]++
	return TRUE

/**
 * Any number of selections per person, and the selection with the most votes wins.
 */
/datum/controller/subsystem/vote/proc/submit_multi_vote(mob/voter, their_vote)
	if(!current_vote || !voter?.ckey)
		return
	if(!(their_vote in current_vote.choices))
		return
	if(!current_vote.can_mob_vote(voter))
		return

	voted |= voter.ckey
	if(current_vote.choices_by_ckey[voter.ckey + their_vote] == 1)
		current_vote.choices_by_ckey[voter.ckey + their_vote] = 0
		current_vote.choices[their_vote]--
	else
		current_vote.choices_by_ckey[voter.ckey + their_vote] = 1
		current_vote.choices[their_vote]++
	return TRUE

/**
 * Initiates a vote, allowing all players to vote on something.
 *
 * * vote_type - A [/datum/vote] typepath, a [/datum/vote] instance, or the name of a vote datum.
 * * vote_initiator_name - The ckey (if player initiated) or name that initiated a vote. Ex: "UristMcAdmin", "the server"
 * * vote_initiator - If a person / mob initiated the vote, this is the mob that did it
 * * forced - Whether we're forcing the vote to go through regardless of existing votes or other circumstances.
 * * popup - Open the vote window for everyone
 */
/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, vote_initiator_name, mob/vote_initiator, forced = FALSE, anonymous = FALSE, popup = FALSE)
	if(!can_vote_start(vote_initiator, forced))
		return FALSE

	var/datum/vote/to_vote
	if(ispath(vote_type, /datum/vote))
		var/datum/vote/vote_path = vote_type
		to_vote = possible_votes[initial(vote_path.name)]
	else if(istype(vote_type, /datum/vote))
		to_vote = vote_type
	else
		to_vote = possible_votes[vote_type]
		if(!to_vote)
			stack_trace("Voting initiate_vote was passed an invalid vote type. (Got: [vote_type || "null"])")

	if(!istype(to_vote))
		if(vote_initiator)
			to_chat(vote_initiator, "<span class='warning'>Invalid voting choice.</span>")
		return FALSE

	if(to_vote.can_be_initiated(forced) != VOTE_AVAILABLE)
		return FALSE

	reset()
	if(!to_vote.create_vote(vote_initiator))
		return FALSE

	if(!vote_initiator_name && vote_initiator)
		vote_initiator_name = vote_initiator.key

	current_vote = to_vote
	last_vote_time = world.time

	var/duration = CONFIG_GET(number/vote_period)
	var/to_display = current_vote.initiate_vote(vote_initiator_name, duration, anonymous)

	log_vote(to_display)
	to_chat(world, EXAMINE_BLOCK("<span class='purple'><b>[to_display]</b>\n\n\
		Type <b>vote</b> or click <a href='byond://winset?command=vote'>here</a> to place your votes.\n\
		You have [DisplayTimeText(duration)] to vote.</span>"))

	// Give everyone a voter action
	for(var/client/new_voter as anything in GLOB.clients)
		var/datum/action/vote/voting_action = new()
		voting_action.name = "Vote: [current_vote.override_question || current_vote.name]"
		voting_action.Grant(new_voter.mob)
		new_voter.player_details.player_actions += voting_action
		generated_actions += voting_action
		if(current_vote.vote_sound)
			SEND_SOUND(new_voter, sound(current_vote.vote_sound))
		if(popup)
			new_voter.mob?.vote()

	return TRUE

/**
 * Checks if we can start a vote.
 *
 * Returns TRUE if we can start a vote, FALSE if we can't.
 */
/datum/controller/subsystem/vote/proc/can_vote_start(mob/vote_initiator, forced)
	if(!initialized)
		if(vote_initiator)
			to_chat(vote_initiator, "<span class='warning'>You cannot start a vote now, the server is not done initializing.</span>")
		return FALSE

	if(forced)
		return TRUE

	var/next_allowed_time = last_vote_time + CONFIG_GET(number/vote_delay)
	if(next_allowed_time > world.time)
		if(vote_initiator)
			to_chat(vote_initiator, "<span class='warning'>A vote was initiated recently. You must wait [DisplayTimeText(next_allowed_time - world.time)] before a new vote can be started!</span>")
		return FALSE

	if(current_vote)
		if(vote_initiator)
			to_chat(vote_initiator, "<span class='warning'>There is already a vote in progress! Please wait for it to finish.</span>")
		return FALSE

	return TRUE

/datum/controller/subsystem/vote/proc/toggle_dead_voting(mob/toggle_initiator)
	var/switch_deadvote_config = !CONFIG_GET(flag/no_dead_vote)
	CONFIG_SET(flag/no_dead_vote, switch_deadvote_config)
	var/text_verb = !switch_deadvote_config ? "enabled" : "disabled"
	log_admin("[key_name(toggle_initiator)] [text_verb] Dead Vote.")
	message_admins("[key_name_admin(toggle_initiator)] [text_verb] Dead Vote.")

/datum/controller/subsystem/vote/proc/remove_action_buttons()
	for(var/datum/action/vote/voting_action as anything in generated_actions)
		if(!QDELETED(voting_action))
			voting_action.remove_from_client()
			voting_action.Remove(voting_action.owner)
	generated_actions = list()

/datum/controller/subsystem/vote/ui_state()
	return GLOB.always_state

/datum/controller/subsystem/vote/ui_interact(mob/user, datum/tgui/ui)
	// Tracks who is currently voting
	voting |= user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// NSV13 - the map vote has its own window with the ship info
		ui = new(user, src, istype(current_vote, /datum/vote/map) ? "MapVote" : "VotePanel")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/controller/subsystem/vote/ui_data(mob/user)
	var/list/data = list()

	var/is_lower_admin = !!user.client?.holder
	var/is_upper_admin = check_rights_for(user.client, R_ADMIN)

	// NSV13 - data for the MapVote window
	if(istype(current_vote, /datum/vote/map))
		var/list/map_choices = list()
		var/selected_index
		var/i = 0
		for(var/key in current_vote.choices)
			i++
			map_choices += list(list("name" = key, "votes" = current_vote.choices[key] || 0))
			if(current_vote.choices_by_ckey[user.client?.ckey] == key)
				selected_index = i
		data["mode"] = "map"
		data["question"] = current_vote.override_question
		data["choices"] = map_choices
		data["selectedChoice"] = selected_index
		data["time_remaining"] = current_vote.time_remaining
		data["lower_admin"] = is_lower_admin
		data["upper_admin"] = is_upper_admin
		data["mapvote_banned"] = is_banned_from(user.ckey, "Mapvote")
		return data

	data["user"] = list(
		"ckey" = user.client?.ckey,
		"isGhost" = CONFIG_GET(flag/no_dead_vote) && user.stat == DEAD && !user.client?.holder,
		"isLowerAdmin" = is_lower_admin,
		"isUpperAdmin" = is_upper_admin,
		// What the current user has selected in any ongoing votes.
		"singleSelection" = current_vote?.choices_by_ckey[user.client?.ckey],
		"multiSelection" = current_vote?.choices_by_ckey,
	)

	data["voting"] = is_lower_admin ? voting : list()

	var/list/all_vote_data = list()
	for(var/vote_name in possible_votes)
		var/datum/vote/vote = possible_votes[vote_name]
		if(!istype(vote))
			continue
		var/can_vote = vote.can_be_initiated(is_lower_admin)
		var/list/vote_data = list(
			"name" = vote_name,
			"canBeInitiated" = can_vote == VOTE_AVAILABLE,
			"config" = vote.is_config_enabled(),
			"message" = can_vote == VOTE_AVAILABLE ? vote.default_message : can_vote,
		)

		if(vote == current_vote)
			var/list/choices = list()
			for(var/key in current_vote.choices)
				choices += list(list(
					"name" = key,
					"description" = current_vote.choice_descriptions[key],
					"votes" = current_vote.choices[key],
				))

			data["currentVote"] = list(
				"name" = current_vote.name,
				"question" = current_vote.override_question,
				"timeRemaining" = current_vote.time_remaining,
				"countMethod" = current_vote.count_method,
				"displayStatistics" = current_vote.display_statistics,
				"choices" = choices,
				"vote" = vote_data,
			)

		all_vote_data += list(vote_data)

	data["possibleVotes"] = all_vote_data
	data["LastVoteTime"] = last_vote_time - world.time
	return data

/datum/controller/subsystem/vote/ui_static_data(mob/user)
	var/list/data = list()
	data["VoteCD"] = CONFIG_GET(number/vote_delay)
	return data

/datum/controller/subsystem/vote/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/voter = usr

	switch(action)
		if("cancel")
			if(!voter.client?.holder)
				message_admins("[key_name(voter)] tried to cancel the current vote while having no admin holder, \
					this is potentially a malicious exploit and worth noting.")
				return
			log_admin("[key_name(voter)] cancelled a vote.")
			message_admins("[key_name_admin(voter)] has cancelled the current vote.")
			SStgui.close_uis(src)
			reset()
			return TRUE

		if("endNow")
			if(!voter.client?.holder)
				message_admins("[key_name(voter)] tried to end the current vote while having no admin holder, \
					this is potentially a malicious exploit and worth noting.")
				return
			if(!current_vote)
				return
			log_admin("[key_name(voter)] ended the current vote early.")
			message_admins("[key_name_admin(voter)] has ended the current vote.")
			end_vote()
			return TRUE

		if("toggleDeadVote")
			if(!check_rights_for(voter.client, R_ADMIN))
				message_admins("[key_name(voter)] tried to toggle vote abillity for ghosts while having improper rights, \
					this is potentially a malicious exploit and worth noting.")
				return
			toggle_dead_voting(voter)
			return TRUE

		if("toggleVote")
			var/datum/vote/selected = possible_votes[params["voteName"]]
			if(!istype(selected))
				return
			if(!check_rights_for(voter.client, R_ADMIN))
				message_admins("[key_name(voter)] tried to toggle vote availability while having improper rights, \
					this is potentially a malicious exploit and worth noting.")
				return
			selected.toggle_votable()
			return TRUE

		if("callVote")
			var/datum/vote/selected = possible_votes[params["voteName"]]
			if(!istype(selected))
				return
			// Whether the user actually can initiate this vote is checked in initiate_vote
			return initiate_vote(
				vote_type = selected,
				vote_initiator_name = voter.key,
				vote_initiator = voter,
				forced = !!GLOB.admin_datums[voter.ckey],
				anonymous = params["anonymous"],
				popup = istype(selected, /datum/vote/map),
			)

		if("voteSingle")
			return submit_single_vote(voter, params["voteOption"])

		if("voteMulti")
			return submit_multi_vote(voter, params["voteOption"])

		// NSV13 - the MapVote window votes by index
		if("vote")
			if(!istype(current_vote, /datum/vote/map))
				return
			var/index = round(text2num(params["index"]))
			if(index < 1 || index > length(current_vote.choices))
				return
			return submit_single_vote(voter, current_vote.choices[index])

		if("resetCooldown")
			if(!voter.client?.holder)
				message_admins("[key_name(voter)] tried to reset the vote cooldown while having no admin holder, \
					this is potentially a malicious exploit and worth noting.")
				return
			last_vote_time = -INFINITY
			return TRUE

/datum/controller/subsystem/vote/ui_close(mob/user, datum/tgui/tgui)
	voting -= user.client?.ckey

/// Mob level verb that allows players to vote on the current vote
/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	// AQUILA EDIT - src, not usr: initiate_vote() calls this for every client to pop the window up, and then usr is not that player
	if(!SSvote.initialized)
		to_chat(src, "<span class='notice'><i>Voting is not set up yet!</i></span>")
		return
	SSvote.ui_interact(src)

/// Action given to mobs that allows players to vote on the current vote
/datum/action/vote
	name = "Vote!"
	button_icon_state = "vote"

/datum/action/vote/Trigger()
	if(owner)
		owner.vote()
		remove_from_client()
		Remove(owner)

/datum/action/vote/IsAvailable()
	return TRUE

/datum/action/vote/proc/remove_from_client()
	if(!owner)
		return
	if(owner.client)
		owner.client.player_details.player_actions -= src
	else if(owner.ckey)
		var/datum/player_details/P = GLOB.player_details[owner.ckey]
		if(P)
			P.player_actions -= src
