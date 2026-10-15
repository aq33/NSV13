// Port BeeStation #13247: głosowanie jako singleton /datum/vote, używany przez SSvote i okno VotePanel.

/**
 * # Vote Singleton
 *
 * A singleton datum that represents a type of vote for the voting subsystem.
 */
/datum/vote
	/// The name of the vote.
	var/name
	/// If supplied, an override question will be displayed instead of the name of the vote.
	var/override_question
	/// The sound effect played to everyone when this vote is initiated.
	var/vote_sound = 'aquila/sound/misc/Vote_started.ogg'
	/// A list of default choices we have for this vote.
	var/list/default_choices
	/// Does the name of this vote contain the word "vote"?
	var/contains_vote_in_name = FALSE
	/// What message do we show as the tooltip of this vote if the vote can be initiated?
	var/default_message = "Click to initiate a vote."
	/// The counting method we use for votes.
	var/count_method = VOTE_COUNT_METHOD_SINGLE
	/// The method for selecting a winner.
	var/winner_method = VOTE_WINNER_METHOD_SIMPLE
	/// Should we show details about the number of votes submitted for each option?
	var/display_statistics = TRUE

	// Internal values used when tracking ongoing votes.
	/// An assoc list of [all choices] to [number of votes in the current running vote].
	var/list/choices = list()
	/// An assoc list of [all choices] to [choice description], must be manually set.
	var/list/choice_descriptions = list()
	/// A assoc list of [ckey] to [what they voted for in the current running vote].
	var/list/choices_by_ckey = list()
	/// The world time this vote was started.
	var/started_time = -1
	/// The time remaining in this vote's run.
	var/time_remaining = -1

/**
 * Used to determine if this vote is a possible vote type for the vote subsystem.
 * If FALSE is returned, nobody will be able to hold this vote.
 */
/datum/vote/proc/is_accessible_vote()
	return !!length(default_choices)

/// Resets our vote to its default state.
/datum/vote/proc/reset()
	SHOULD_CALL_PARENT(TRUE)
	choices.Cut()
	choices_by_ckey.Cut()
	started_time = null
	time_remaining = -1

/// If this vote has a config associated, toggles it between enabled and disabled.
/datum/vote/proc/toggle_votable()
	return

/// If this vote has a config associated, returns its value. If it has no config, returns -1.
/datum/vote/proc/is_config_enabled()
	return -1

/**
 * Checks if the vote can be started.
 *
 * * forced - if being invoked by someone who is an admin
 *
 * Return VOTE_AVAILABLE if the vote can start, or a string with the reason why it can't.
 */
/datum/vote/proc/can_be_initiated(forced = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!forced && !is_config_enabled())
		return "This vote is currently disabled by the server configuration."
	return VOTE_AVAILABLE

/// Whether this mob may vote in this vote right now
/datum/vote/proc/can_mob_vote(mob/voter)
	if(CONFIG_GET(flag/no_dead_vote) && voter.stat == DEAD && !isnewplayer(voter) && !voter.client?.holder)
		return FALSE
	return TRUE

/**
 * Called prior to the vote being initiated.
 * Return FALSE to prevent the vote from being initiated.
 */
/datum/vote/proc/create_vote(mob/vote_creator)
	SHOULD_CALL_PARENT(TRUE)
	for(var/key in default_choices)
		choices[key] = 0
	return TRUE

/**
 * Called when this vote is actually initiated.
 * Return the text displayed to the world when the vote is initiated.
 */
/datum/vote/proc/initiate_vote(initiator, duration, anonymous)
	SHOULD_CALL_PARENT(TRUE)
	started_time = world.time
	time_remaining = round(duration / 10)

	var/to_display = "[contains_vote_in_name ? "[capitalize(name)]" : "[capitalize(name)] vote"] started by"
	if(anonymous)
		message_admins("[to_display] [initiator].")
	return "[to_display] [anonymous ? "Anonymous" : initiator || "Central Command"]."

/**
 * Gets the result of the vote.
 *
 * non_voters - a list of all ckeys who didn't vote in the vote.
 *
 * Returns a list of all options that won (empty without votes, more than one on a tie).
 */
/datum/vote/proc/get_vote_result(list/non_voters)
	RETURN_TYPE(/list)
	SHOULD_CALL_PARENT(TRUE)
	switch(winner_method)
		if(VOTE_WINNER_METHOD_NONE)
			return list()
		if(VOTE_WINNER_METHOD_SIMPLE)
			return get_simple_winner()
		if(VOTE_WINNER_METHOD_WEIGHTED_RANDOM)
			return get_random_winner()
	stack_trace("invalid select winner method: [winner_method]. Defaulting to simple.")
	return get_simple_winner()

/// Gets the winner of the vote, selecting the choice with the most votes.
/datum/vote/proc/get_simple_winner()
	var/highest_vote = 0
	var/list/current_winners = list()
	for(var/option in choices)
		var/vote_count = choices[option]
		if(vote_count < highest_vote)
			continue
		if(vote_count > highest_vote)
			highest_vote = vote_count
			current_winners = list(option)
			continue
		current_winners += option
	return highest_vote ? current_winners : list()

/// Gets the winner of the vote, selecting a random choice from all choices based on their vote count.
/datum/vote/proc/get_random_winner()
	var/winner = pickweight(choices.Copy())
	return winner ? list(winner) : list()

/**
 * Gets the resulting text displayed when the vote is completed.
 *
 * all_winners - list of all options that won. Can be multiple, in the event of ties.
 * real_winner - the option that actually won.
 * non_voters - a list of all ckeys who didn't vote in the vote.
 */
/datum/vote/proc/get_result_text(list/all_winners, real_winner, list/non_voters)
	var/returned_text = ""
	if(override_question)
		returned_text += "<b>[override_question]</b>"
	else
		returned_text += "<b>[capitalize(name)] Vote</b>"

	returned_text += "\nWinner Selection: "
	switch(winner_method)
		if(VOTE_WINNER_METHOD_NONE)
			returned_text += "None"
		if(VOTE_WINNER_METHOD_WEIGHTED_RANDOM)
			returned_text += "Weighted Random"
		else
			returned_text += "Simple"

	var/total_votes = 0 // for determining percentage of votes
	for(var/option in choices)
		total_votes += choices[option]

	if(total_votes <= 0)
		return "<b>[capitalize(name)] Vote Result: Inconclusive - No Votes!</b>"

	if(display_statistics)
		returned_text += "\nResults:"
		for(var/option in choices)
			var/votes = choices[option]
			var/percentage_text = votes > 0 ? "[round((votes / total_votes) * 100, 0.1)]%" : "0%"
			returned_text += "\n[percentage_text] | <b>[option]</b>: [votes]"

	if(!real_winner) // vote has no winner or cannot be won, but still had votes
		return EXAMINE_BLOCK(returned_text)

	returned_text += "\n"
	returned_text += get_winner_text(all_winners, real_winner, non_voters)
	return EXAMINE_BLOCK(returned_text)

/// Gets the text that displays the winning options within the result text.
/datum/vote/proc/get_winner_text(list/all_winners, real_winner, list/non_voters)
	var/returned_text = ""
	if(length(all_winners) > 1)
		returned_text += "\n<b>Vote Tied Between:</b>"
		for(var/a_winner in all_winners)
			returned_text += "\n\t[a_winner]"
	returned_text += "<b>\nVote Result: [real_winner]</b>"
	return returned_text

/// How this vote handles a tiebreaker between multiple winners.
/datum/vote/proc/tiebreaker(list/winners)
	return pick(winners)

/// Called when a vote is actually all said and done. Apply actual vote effects here.
/datum/vote/proc/finalize_vote(winning_option)
	return
