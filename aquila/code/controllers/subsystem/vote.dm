GLOBAL_VAR(vote_submit_cooldown)
#define VOTE_SUBMIT_COOLDOWN_TIME 1 SECONDS

/// Sound for everyone when someone votes, at most once a second
/datum/controller/subsystem/vote/proc/aquila_vote_submitted_sound()
	if(GLOB.vote_submit_cooldown < world.time)
		sound_to_playing_players('aquila/sound/misc/Vote.ogg')
		GLOB.vote_submit_cooldown = world.time + VOTE_SUBMIT_COOLDOWN_TIME

/datum/controller/subsystem/vote/submit_single_vote(mob/voter, their_vote)
	. = ..()
	if(.)
		aquila_vote_submitted_sound()

/datum/controller/subsystem/vote/submit_multi_vote(mob/voter, their_vote)
	. = ..()
	if(.)
		aquila_vote_submitted_sound()

// The start sound is the vote_sound of /datum/vote (aquila/code/datums/votes/_vote_datum.dm)
/datum/controller/subsystem/vote/process_vote_result()
	sound_to_playing_players('aquila/sound/misc/Vote_success.ogg')
	return ..()

#undef VOTE_SUBMIT_COOLDOWN_TIME
