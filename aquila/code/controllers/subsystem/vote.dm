GLOBAL_VAR(vote_submit_cooldown)
#define VOTE_SUBMIT_COOLDOWN_TIME 1 SECONDS
/datum/controller/subsystem/vote/submit_vote(vote)
	. = ..()
	if(GLOB.vote_submit_cooldown < world.time)
		sound_to_playing_players('aquila/sound/misc/Vote.ogg')
		GLOB.vote_submit_cooldown = world.time + VOTE_SUBMIT_COOLDOWN_TIME

// tu nie musimy napisywać całego procu
/datum/controller/subsystem/vote/get_result()
	sound_to_playing_players('aquila/sound/misc/Vote_success.ogg')
	. = ..()

/datum/controller/subsystem/vote/initiate_vote(vote_type, initiator_key, forced=FALSE, popup=FALSE)
	. = ..()
	sound_to_playing_players('aquila/sound/misc/Vote_started.ogg')
