/mob/living/simple_animal/hostile/kurwinoxy
	name = "Kurwinox"
	desc = "Co za skurwiel, nie dość że brzydki to jeszcze gównem zajeżdża."
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "kurwinox_b_chod"
	icon_dead = "kurwinox_b"
	maxHealth = 80
	health = 80
	faction = list("Kurwinox")
	melee_damage = 25 //Te skurwysyny to nie żart
	deathmessage = "Sra pod siebie i przestaje się ruszać."

/mob/living/simple_animal/hostile/kurwinoxy/czerwony
	desc = "Co za skurwiel, nie dość że gównem zajeżdża to jeszcze brzydki."
	icon_state = "kurwinox_cz_chod"
	icon_dead = "kurwinox_cz"
	maxHealth = 150
	health = 150
	melee_damage = 35 //Te skurwysyny to nie żart

/mob/living/simple_animal/hostile/clowiekmaupa
	name = "maupa"
	desc = "Co to kurwa jest"
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "bestia"
	icon_dead = "bestia"
	maxHealth = 666
	health = 666
	melee_damage = 40 // Jak się balansuje simple moba takiego????


/obj/structure/spawner/kurwinoxy
	name = "Kosmo Portal"
	desc = "Portal z galaktyki Kurwix"
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "kurwinox_b_chod"
	max_mobs = 5
	spawn_time = 480
	mob_types = list(/mob/living/simple_animal/hostile/kurwinoxy, /mob/living/simple_animal/hostile/kurwinoxy/czerwony)
	faction = list("Kurwinox")

/obj/structure/spawner/clowiekmaupa
	name = ""
	desc = ""
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "bestia"
	max_mobs = 1
	spawn_time = 1200
	mob_types = list(/mob/living/simple_animal/hostile/clowiekmaupa)
	faction = list("Kurwinox")
