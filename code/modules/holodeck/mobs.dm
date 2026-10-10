/*
	Mobs
*/

/mob/living/simple_animal/holodeck_monkey
	name = "monkey"
	desc = "A holographic creature fond of bananas."
	icon = 'nsv13/icons/mob/legacy_monkey.dmi'
	icon_state = "monkey1"
	icon_living = "monkey1"
	icon_dead = "monkey1_dead"
	speak_emote = list("pokrzykuje")
	emote_hear = list("pokrzykuje.")
	emote_see = list("drapie się.", "rozgląda się.")
	speak_chance = 1
	turns_per_move = 2
	butcher_results = list()
	response_help = "pets"
	response_disarm = "pushes aside"
	response_harm = "kicks"
