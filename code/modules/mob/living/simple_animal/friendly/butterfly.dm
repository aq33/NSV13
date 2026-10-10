/mob/living/simple_animal/butterfly
	name = "butterfly"
	desc = "A colorful butterfly, how'd it get up here?"
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help = "przegania"
	response_disarm = "odsuwa na bok"
	response_harm = "zgniata"
	speak_emote = list("trzepocze")
	maxHealth = 2
	health = 2
	friendly = "trąca"
	density = FALSE
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "trzepocze"
	verb_ask = "trzepocze pytająco"
	verb_exclaim = "trzepocze zawzięcie"
	verb_yell = "trzepocze zawzięcie"

/mob/living/simple_animal/butterfly/Initialize(mapload)
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	chat_color = newcolor
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/butterfly/bee_friendly()
	return TRUE //treaty signed at the Beeneeva convention
