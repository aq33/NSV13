//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("ryczy")
	emote_hear = list("ryczy.")
	emote_see = list("potrząsa głową.", "tupie nogą.", "rozgląda się gniewnie.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "kopie"
	faction = list("neutral")
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	attack_same = 1
	attacktext = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	minbodytemp = 180
	melee_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	stop_automated_movement_when_pulled = 1
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/udder/goat/udder = null
	chat_color = "#B2CEB3"

	do_footstep = TRUE

/mob/living/simple_animal/hostile/retaliate/goat/Initialize(mapload)
	udder = new()
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	qdel(udder)
	udder = null
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			clear_enemies()
			LoseTarget()
			src.visible_message("<span class='notice'>[src] się uspokaja.</span>")
	if(stat == CONSCIOUS)
		udder.generateMilk()
		eat_plants()
		if(!pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
						Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message("<span class='danger'>W oku [src] pojawia się złowrogi błysk.</span>")

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(!stat)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/eaten = FALSE
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		eaten = TRUE

	var/obj/structure/glowshroom/GS = locate(/obj/structure/glowshroom) in loc
	if(GS)
		qdel(GS)
		eaten = TRUE

	if(eaten && prob(10))
		INVOKE_ASYNC(src, /atom/movable/proc/say, "Nom")

/mob/living/simple_animal/hostile/retaliate/goat/attackby(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return 1
	else
		return ..()


/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.dna.species, /datum/species/pod))
			var/obj/item/bodypart/NB = pick(H.bodyparts)
			H.visible_message("<span class='warning'>[src] odgryza spory kęs [H]!</span>", \
								  "<span class='userdanger'>[src] odgryza spory kęs twojej kończyny ([NB])!</span>")
			NB.dismember()
//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("muu?","muu","MUUUUUU")
	speak_emote = list("muczy","muczy upiornie")
	emote_hear = list("ryczy.")
	emote_see = list("potrząsa głową.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "kopie"
	attacktext = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	maxHealth = 50
	var/obj/item/udder/udder = null
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	chat_color = "#FFFFFF"

	do_footstep = TRUE

/mob/living/simple_animal/cow/Initialize(mapload)
	udder = new()
	. = ..()

/mob/living/simple_animal/cow/Destroy()
	qdel(udder)
	udder = null
	return ..()

/mob/living/simple_animal/cow/attackby(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return 1
	else
		return ..()

/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M)
	if(!stat && M.a_intent == INTENT_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] przewraca [src].</span>",
			"<span class='notice'>Przewracasz [src].</span>")
		to_chat(src, "<span class='userdanger'>[M] cię przewraca!</span>")
		Paralyze(60, ignore_canstun = TRUE)
		icon_state = icon_dead
		addtimer(CALLBACK(src, PROC_REF(tip_back), M), rand(20,50))
	else
		..()

/mob/living/simple_animal/cow/proc/tip_back(mob/living/carbon/M)
	if(stat && M)
		return
	icon_state = icon_living
	var/external
	var/internal
	switch(pick(1,2,3,4))
		if(1,2,3)
			var/text = pick("błagalnie.", "proszącym wzrokiem.",
				"z rezygnacją.")
			external = "[src] patrzy na [M] [text]"
			internal = "Patrzysz na [M] [text]"
		if(4)
			external = "[src] wydaje się pogodzony ze swoim losem."
			internal = "Godzisz się ze swoim losem."
	visible_message("<span class='notice'>[external]</span>",
		"<span class='revennotice'>[internal]</span>")

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "chick"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("Pi.","Pi?","Pi-pi.","Piii!")
	speak_emote = list("piszczy")
	emote_hear = list("piszczy.")
	emote_see = list("dziobie ziemię.","trzepocze malutkimi skrzydełkami.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "kopie"
	attacktext = "kopie"
	health = 3
	maxHealth = 3
	ventcrawler = VENTCRAWLER_ALWAYS
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"

	do_footstep = TRUE

/mob/living/simple_animal/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	GLOB.total_chickens++

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

/mob/living/simple_animal/chick/death(gibbed)
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chick/Destroy()
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chick/holo/Life()
	..()
	amount_grown = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Ko!","KOOOOOO KO KO KO!","Ko-ko.")
	speak_emote = list("gdacze","pogdakuje")
	emote_hear = list("gdacze.")
	emote_see = list("dziobie ziemię.","zawzięcie trzepocze skrzydłami.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	var/egg_type = /obj/item/food/egg
	var/food_type = /obj/item/food/grown/wheat
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "kopie"
	attacktext = "kopie"
	health = 15
	maxHealth = 15
	ventcrawler = VENTCRAWLER_ALWAYS
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/feedMessages = list("Radośnie gdacze.","Radośnie gdacze.")
	var/list/layMessage = EGG_LAYING_MESSAGES
	var/list/validColors = list("brown","black","white")
	gold_core_spawnable = FRIENDLY_SPAWN
	var/static/chicken_count = 0
	chat_color = "#FFDC9B"
	mobchatspan = "stationengineer"

	do_footstep = TRUE

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	held_state = "[icon_prefix]_[body_color]"
	head_icon = 'icons/mob/pets_held_large.dmi'
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	GLOB.total_chickens++

/mob/living/simple_animal/chicken/death(gibbed)
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chicken/Destroy()
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user, params)
	if(istype(O, food_type)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			var/feedmsg = "[user] karmi [name], podając [O]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			qdel(O)
			eggsleft += rand(1, 4)
		else
			to_chat(user, "<span class='warning'>[name] nie wygląda na głodnego!</span>")
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if((!stat && prob(3) && eggsleft > 0) && egg_type && GLOB.total_chickens < CONFIG_GET(number/max_chickens))
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = E.base_pixel_x + rand(-6,6)
		E.pixel_y = E.base_pixel_y + rand(-6,6)
		if(eggsFertile)
			if(prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/food/egg/var/amount_grown = 0
/obj/item/food/egg/process(delta_time)
	if(isturf(loc))
		amount_grown += rand(1,2) * delta_time
		if(amount_grown >= 200)
			visible_message("[src] wykluwa się z cichym trzaskiem.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/chicken/turkey
	name = "\improper turkey"
	desc = "it's that time again."
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak = list("Gul!","GUL GUL GUL!","Ko.")
	speak_emote = list("gdacze","gulgocze")
	emote_hear = list("gulgocze.")
	emote_see = list("dziobie ziemię.","zawzięcie trzepocze skrzydłami.")
	density = FALSE
	health = 15
	maxHealth = 15
	egg_type = null
	attacktext = "dziobie"
	attack_sound = 'sound/creatures/turkey.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	icon_prefix = "turkey"
	feedMessages = list("Łapczywie pożera jedzenie.","Radośnie gdacze.")
	validColors = list("plain")
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"

/mob/living/simple_animal/sheep
	name = "sheep"
	desc = "It's so fluffy!"
	icon_state = "sheep"
	icon_living = "sheep"
	icon_dead = "sheep_dead"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("bee?","bee","BEEEEEE")
	speak_emote = list("beczy")
	emote_hear = list("ryczy.")
	emote_see = list("skubie trawę.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "kopie"
	attacktext = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	var/obj/item/udder/sheep/udder = null
	var/shaved = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN

	do_footstep = TRUE

/mob/living/simple_animal/sheep/Initialize()
	udder = new()
	. = ..()

/mob/living/simple_animal/sheep/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/sheep/attackby(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		return TRUE
	else
		return ..()

/mob/living/simple_animal/sheep/Life()
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/sheep/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if(shaved)
			to_chat(user, "<span class='warning'>Owca nie ma dość wełny, spróbuj później...</span>")
			return
		user.visible_message("[user] zaczyna golić [src] za pomocą [O].", "<span class='notice'>Zaczynasz golić [src] za pomocą [O]...</span>")
		if(do_after(user, 50, target = src))
			if(shaved)
				user.visible_message("[src] jest już ostrzyżona!")
				return
			user.visible_message("[user] strzyże trochę wełny z [src] za pomocą [O].", "<span class='notice'>Strzyżesz trochę wełny z [src] za pomocą [O].</span>")
			playsound(loc, 'sound/items/welder2.ogg', 20, 1)
			shaved = TRUE
			icon_living = "sheep_sheared"
			icon_dead = "sheep_sheared_dead"
			new /obj/item/stack/sheet/cotton/wool(get_turf(src), 8)
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
			addtimer(CALLBACK(src, PROC_REF(generateWool)), 3 MINUTES)

		return
	..()

/mob/living/simple_animal/sheep/proc/generateWool()
	if(stat == CONSCIOUS)
		shaved = FALSE
		icon_living = "sheep"
		icon_dead = "sheep_dead"
		icon_state = icon_living

//udder
/obj/item/udder
	name = "udder"
	var/milktype = /datum/reagent/consumable/milk

/obj/item/udder/sheep
	name = "sheep udder"
	milktype = /datum/reagent/consumable/milk/sheep

/obj/item/udder/goat
	name = "goat udder"
	milktype = /datum/reagent/consumable/milk/goat


/obj/item/udder/Initialize(mapload)
	create_reagents(50)
	reagents.add_reagent(milktype, 20)
	. = ..()

/obj/item/udder/proc/generateMilk()
	if(prob(5))
		reagents.add_reagent(milktype, rand(5, 10))

/obj/item/udder/proc/milkAnimal(obj/O, mob/user)
	var/obj/item/reagent_containers/glass/G = O
	if(G.reagents.total_volume >= G.volume)
		to_chat(user, "<span class='danger'>[O] jest pełne.</span>")
		return
	var/transfered = reagents.trans_to(O, rand(5,10))
	if(transfered)
		user.visible_message("[user] doi [src] do [O].", "<span class='notice'>Doisz [src] do [O].</span>")
	else
		to_chat(user, "<span class='danger'>Wymię jest puste. Zaczekaj jeszcze trochę...</span>")
