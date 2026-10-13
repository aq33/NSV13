// AQUILA - "Dynamika rundy" question in the end of round map vote window (tgui MapVote.js).
// Players who had a character answer whether the next rounds should bring fewer threats, stay as they are, or bring more.
// The answers tilt the threat pools of the weighted rotation, see weighted_rotation.dm.

/datum/controller/subsystem/vote/ui_data(mob/user)
	. = ..()
	if(mode != "map" || SSticker.current_state != GAME_STATE_FINISHED)
		return
	var/ckey = user.client?.ckey
	var/list/counts = list("-1" = 0, "0" = 0, "1" = 0)
	for(var/voter in GLOB.weighted_rotation.pending_votes)
		counts["[GLOB.weighted_rotation.pending_votes[voter]]"]++
	.["pace_open"] = TRUE
	.["pace_can_vote"] = GLOB.weighted_rotation.can_vote_pace(ckey)
	.["pace_choice"] = (ckey in GLOB.weighted_rotation.pending_votes) ? GLOB.weighted_rotation.pending_votes[ckey] : null
	.["pace_counts"] = list("less" = counts["-1"], "same" = counts["0"], "more" = counts["1"])

/datum/controller/subsystem/vote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "pace_vote")
		return ..()
	if(!ui || ui.status != UI_INTERACTIVE || mode != "map" || !usr?.client)
		return TRUE
	GLOB.weighted_rotation.set_pace_vote(usr.client.ckey, text2num(params["value"]))
	return TRUE
