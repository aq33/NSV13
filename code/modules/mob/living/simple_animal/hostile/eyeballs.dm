

/mob/living/simple_animal/hostile/carp/eyeball
	name = "eyeball"
	desc = "An odd looking creature, it won't stop staring..."
	icon_state = "eyeball"
	icon_living = "eyeball"
	icon_gib = ""
	gender = NEUTER
	mob_biotypes = list(MOB_ORGANIC)
	response_help = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "uderza"
	emote_taunt = list("glares")
	taunt_chance = 25
	maxHealth = 45
	health = 45
	speak_emote = list("woła telepatycznie")

	obj_damage = 60
	melee_damage = 20
	attacktext = "mruga do"
	attack_sound = 'sound/weapons/pierce.ogg'
	movement_type = FLYING

	faction = list("spooky")
	del_on_death = TRUE
	random_color = FALSE
