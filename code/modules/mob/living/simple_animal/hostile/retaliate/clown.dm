/mob/living/simple_animal/hostile/retaliate/clown
	name = JOB_NAME_CLOWN
	desc = "A denizen of clown planet."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "szturcha"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "robustuje"
	speak = list("HONK", "Honk!", "Witaj na planecie klaunów!")
	emote_see = list("trąbi", "piszczy")
	speak_chance = 1
	combat_mode = TRUE
	maxHealth = 75
	health = 75
	speed = 1
	melee_damage = 10
	attacktext = "atakuje"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = TRUE
	loot = list(/obj/effect/mob_spawn/human/clown/corpse)

	mobchatspan = "clown"

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = 370
	unsuitable_atmos_damage = 10
	do_footstep = TRUE
	hardattacks = TRUE
	var/banana_time = 0 // If there's no time set it won't spawn.
	var/banana_type = /obj/item/grown/bananapeel
	var/attack_reagent

/mob/living/simple_animal/hostile/retaliate/clown/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(10)
		throw_alert("temp", /atom/movable/screen/alert/cold, 2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(15)
		throw_alert("temp", /atom/movable/screen/alert/hot, 3)
	else
		clear_alert("temp")

/mob/living/simple_animal/hostile/retaliate/clown/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)

/mob/living/simple_animal/hostile/retaliate/clown/Life()
	. = ..()
	if(banana_time && banana_time < world.time)
		var/turf/T = get_turf(src)
		var/list/adjacent =  T.GetAtmosAdjacentTurfs(1)
		new banana_type(pick(adjacent))
		banana_time = world.time + rand(30,60)

/mob/living/simple_animal/hostile/retaliate/clown/AttackingTarget()
	. = ..()
	if(attack_reagent && . && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(attack_reagent, 5)

/mob/living/simple_animal/hostile/retaliate/clown/lube
	name = "Living Lube"
	desc = "A puddle of lube brought to life by the honkmother."
	icon_state = "lube"
	icon_living = "lube"
	turns_per_move = 1
	response_help = "zanurza palec w"
	response_disarm = "delikatnie zgarnia i odlewa na bok"
	emote_see = list("bąbelkuje", "sączy się")
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/particle_effect/foam)

/mob/living/simple_animal/hostile/retaliate/clown/lube/Life()
	. = ..()
	var/turf/open/OT = get_turf(src)
	if(isopenturf(OT))
		OT.MakeSlippery(TURF_WET_LUBE, 100)

/mob/living/simple_animal/hostile/retaliate/clown/banana
	name = "Clownana"
	desc = "A fusion of clown and banana DNA birthed from a botany experiment gone wrong."
	icon_state = "banana tree"
	icon_living = "banana tree"
	response_help = "szturcha"
	response_disarm = "obiera"
	response_harm = "obiera"
	turns_per_move = 1
	speak = list("HONK", "Honk!", "JA-HONK!!!")
	emote_see = list("trąbi", "wgryza się w banana", "zrywa banana ze swojej głowy", "fotosyntetyzuje")
	maxHealth = 120
	health = 120
	speed = -10
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/seeds/banana)
	banana_time = 20

/mob/living/simple_animal/hostile/retaliate/clown/honkling
	name = "Honkling"
	desc = "A divine being sent by the Honkmother to spread joy. It's not dangerous, but it's a bit of a nuisance."
	icon_state = "honkling"
	icon_living = "honkling"
	turns_per_move = 1
	speed = -10
	melee_damage = 1
	attacktext = "pociesza"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/seeds/banana/bluespace)
	banana_type = /obj/item/grown/bananapeel
	attack_reagent = /datum/reagent/consumable/laughter

/mob/living/simple_animal/hostile/retaliate/clown/fleshclown
	name = "Fleshclown"
	desc = "A being forged out of the pure essence of pranking, cursed into existence by a cruel maker."
	icon_state = "fleshclown"
	icon_living = "fleshclown"
	response_help = "niechętnie szturcha"
	response_disarm = "zanurza dłonie w gąbczastym ciele"
	response_harm = "oczyszcza świat z"
	speak = list("HONK", "Honk!", "Nie prosiłem się o to", "Czuję ciągły, straszny ból", "JA-HONK!!!", "to ciało to bezlitosne i nieprzebaczające więzienie", "zrodziłem się z radosnych psot, ale żyję w cierpieniu")
	emote_see = list("trąbi", "poci się", "trzęsie się", "rozmyśla nad swoim istnieniem")
	speak_chance = 5
	dextrous = TRUE
	ventcrawler = VENTCRAWLER_ALWAYS
	maxHealth = 140
	health = 140
	speed = -5
	melee_damage = 15
	attacktext = "bezwładnie klepie"
	obj_damage = 5
	loot = list(/obj/item/clothing/suit/hooded/bloated_human, /obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/longface
	name = "Longface"
	desc = "Often found walking into the bar."
	icon_state = "long face"
	icon_living = "long face"
	move_resist = INFINITY
	turns_per_move = 10
	response_help = "niezgrabnie próbuje przytulić"
	response_disarm = "popycha nieporęczną konstrukcję"
	response_harm = "próbuje uciszyć"
	speak = list("JA-HONK!!!")
	emote_see = list("trąbi", "piszczy")
	speak_chance = 60
	maxHealth = 150
	health = 150
	pixel_x = -16
	base_pixel_x = -16
	speed = 10
	melee_damage = 5
	attacktext = "JA-HONKUJE na"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	name = "Honk Hulk"
	desc = "A cruel and fearsome clown. Don't make him angry."
	icon_state = "honkhulk"
	icon_living = "honkhulk"
	move_resist = INFINITY
	response_help = "desperacko próbuje udobruchać"
	response_disarm = "głupio popycha"
	response_harm = "rozwściecza"
	speak = list("HONK", "Honk!", "HAUAUANK!!!", "GUUURRRRAAAHHH!!!")
	emote_see = list("trąbi", "poci się", "chrząka")
	speak_chance = 5
	maxHealth = 400
	health = 400
	pixel_x = -16
	base_pixel_x = -16
	speed = 2
	melee_damage = 17
	attacktext = "okłada pięściami"
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown
	name = "Chlown"
	desc = "A real lunkhead who somehow gets all the girls."
	icon_state = "chlown"
	icon_living = "chlown"
	response_help = "poddaje się"
	response_disarm = "próbuje zdominować"
	response_harm = "wykonuje słaby, betowy atak na"
	speak = list("HONK", "Honk!", "Bruh", "cheeaaaahhh?")
	emote_see = list("pokazuje, kto tu rządzi", "po cichu odbiera wszystkim męskość")
	maxHealth = 500
	health = 500
	speed = -2
	armour_penetration = 20
	attacktext = "kradnie dziewczynę"
	attack_sound = 'sound/items/airhorn2.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus
	name = "Honkmunculus"
	desc = "A slender wiry figure of alchemical origin."
	icon_state = "honkmunculus"
	icon_living = "honkmunculus"
	response_help = "sceptycznie szturcha"
	response_disarm = "popycha nieporęczną konstrukcję"
	speak = list("honk")
	emote_see = list("wije się", "skręca się")
	speak_chance = 1
	maxHealth = 200
	health = 200
	speed = -5
	melee_damage = 10
	attacktext = "zajadle szarpie"
	environment_smash = ENVIRONMENT_SMASH_NONE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap)
	attack_reagent = /datum/reagent/peaceborg/confuse

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/destroyer
	name = "The Destroyer"
	desc = "An ancient being born of arcane honking."
	icon_state = "destroyer"
	icon_living = "destroyer"
	response_disarm = "odbija się od"
	response_harm = "odbija się od"
	speak = list("HONK!!!", "Honkmatka jest miłosierna, więc to ja muszę wymierzyć jej gniew.", "parce mihi ad beatus honkmother placet mihi ut peccata committere,", "DIE!!!")
	maxHealth = 400
	health = 400
	speed = 5
	melee_damage = 30
	armour_penetration = 30
	stat_attack = UNCONSCIOUS
	attacktext = "wymierza boską zemstę"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/mutant
	name = "Unknown"
	desc = "Kill it for its own sake."
	icon_state = "mutant"
	icon_living = "mutant"
	move_resist = INFINITY
	turns_per_move = 10
	response_help = "niechętnie wbija palec w"
	response_disarm = "wciska się w"
	response_harm = "wciska się w"
	speak = list("aaaaaahhhhuuhhhuhhhaaaaa", "AAAaaauuuaaAAAaauuhhh", "huuuuuh... hhhhuuuooooonnnnkk", "HuaUAAAnKKKK")
	emote_see = list("wije się", "skręca się", "pulsuje", "pieni się", "sączy się")
	speak_chance = 10
	maxHealth = 130
	health = 130
	pixel_x = -16
	base_pixel_x = -16
	speed = -5
	melee_damage = 15
	attacktext = "niezgrabnie macha na"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/retaliate/clown/mutant/blob
	name = "Something that was once a clown"
	desc = "A grotesque bulging figure far mutated from it's original state."
	icon_state = "blob"
	icon_living = "blob"
	speak = list("hej, kolego", "HONK!!!", "H-h-h-H-HOOOOONK!!!!", "HONKHONKHONK!!!", "HEJ, KOLEŻKO, WRACAJ TU!!!", "HOOOOOOOONK!!!")
	emote_see = list("trzęsie się", "chybocze się")
	health = 130
	mob_size = MOB_SIZE_LARGE
	speed = 20
	attacktext = "odbija się od"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)
	attack_reagent = /datum/reagent/toxin/mindbreaker
