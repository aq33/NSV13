// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#13247: votes are datums, our NSV13 votes are there and keep their non-voter rules
/datum/unit_test/aquila_votes

/datum/unit_test/aquila_votes/Run()
	for(var/vote_name in list("Restart", "Transfer", "Gamemode", "Map", "Custom", "Hardmode", "Press On Or Return Home?"))
		TEST_ASSERT(istype(SSvote.possible_votes[vote_name], /datum/vote), "The [vote_name] vote is missing")

	// Players cannot start the transfer or hardmode votes, admins and the server can
	var/datum/vote/transfer/transfer = SSvote.possible_votes["Transfer"]
	TEST_ASSERT(transfer.can_be_initiated(FALSE) != VOTE_AVAILABLE, "Players can start a transfer vote")
	TEST_ASSERT(transfer.can_be_initiated(TRUE) == VOTE_AVAILABLE, "The server cannot start a transfer vote")

	// A forced vote starts, takes votes by name and gives the result
	TEST_ASSERT(SSvote.initiate_vote(/datum/vote/hardmode, "unit test", forced = TRUE), "A forced hardmode vote did not start")
	TEST_ASSERT(istype(SSvote.current_vote, /datum/vote/hardmode), "The current vote is not the hardmode vote")
	var/datum/vote/hardmode/hardmode = SSvote.current_vote
	TEST_ASSERT(length(hardmode.choices) == 2, "The hardmode vote has [length(hardmode.choices)] choices")
	hardmode.choices["Let's GO FOR IT"] = 3
	// Non-voters count for a normal round: 3 votes against 5 non-voters
	var/old_default_no_vote = CONFIG_GET(flag/default_no_vote)
	CONFIG_SET(flag/default_no_vote, FALSE)
	var/list/winners = hardmode.get_vote_result(list("a" = null, "b" = null, "c" = null, "d" = null, "e" = null))
	CONFIG_SET(flag/default_no_vote, old_default_no_vote)
	TEST_ASSERT(length(winners) == 1 && winners[1] == "Play a normal round", "Non-voters did not count for a normal round: [json_encode(winners)]")
	SSvote.reset()
	TEST_ASSERT(!SSvote.current_vote, "The vote did not reset")

	// The window data
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/list/panel = SSvote.ui_data(viewer)
	TEST_ASSERT(length(panel["possibleVotes"]) == length(SSvote.possible_votes), "VotePanel does not list every vote")
	TEST_ASSERT(!panel["currentVote"], "VotePanel shows a vote that is not running")

#undef TEST_ASSERT
