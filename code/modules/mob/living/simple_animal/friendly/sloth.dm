/mob/living/simple_animal/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"
	speak_emote = list("ziewa")
	emote_hear = list("chrapie.","ziewa.")
	emote_see = list("przysypia.", "rozgląda się sennie.")
	speak_chance = 1
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "kopie"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage = 18 //why the fuck does it do this much damage
	health = 50
	maxHealth = 50
	speed = 10
	chat_color = "#728AE6"
	can_be_held = TRUE
	held_state = "sloth"
	do_footstep = TRUE


//Cargo Sloth
/mob/living/simple_animal/sloth/paperwork
	name = "Paperwork"
	desc = "Cargo's pet sloth. About as useful as the rest of the techs."
	gold_core_spawnable = NO_SPAWN

//Cargo Sloth 2

/mob/living/simple_animal/sloth/citrus
	name = "Citrus"
	desc = "Cargo's pet sloth. She's dressed in a horrible sweater."
	icon_state = "cool_sloth"
	icon_living = "cool_sloth"
	icon_dead = "cool_sloth_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/toy/spinningtoy = 1)
	gold_core_spawnable = NO_SPAWN
