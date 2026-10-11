// AQUILA - niedźwiedź Wojtek, port z NovaSector/NovaSector (modular_nova/modules/mapping/voidraptor)
// Niedźwiedź z 22. Kompanii Zaopatrywania Artylerii II Korpusu Polskiego, który nosił skrzynie z pociskami.
// Spokojny, dopóki nikt go nie skrzywdzi; lubi piwo i papierosy, tak jak oryginał.

/mob/living/simple_animal/hostile/retaliate/wojtek
	name = "Wojtek"
	real_name = "Wojtek"
	desc = "Kapral Wojtek, weteran kompanii zaopatrzenia artylerii. Nosi pociski do dział bluespace i nigdy nie odmówi piwa ani papierosa."
	gender = MALE
	icon = 'icons/mob/animal.dmi'
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("Mrrr...", "Rawr!", "Grrrm.")
	speak_emote = list("mruczy", "pomrukuje")
	emote_hear = list("mruczy.", "sapie.", "drapie się po brzuchu.")
	emote_see = list("salutuje łapą.", "przeciąga się.", "rozgląda się za piwem.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/bearpelt = 1)
	response_help = "głaszcze"
	response_disarm = "delikatnie odpycha"
	response_harm = "uderza"
	maxHealth = 120
	health = 120
	obj_damage = 60
	melee_damage = 25
	attacktext = "drapie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	friendly = "przytula po niedźwiedziemu"
	chat_color = "#CAA25B"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("neutral")
	gold_core_spawnable = NO_SPAWN
	do_footstep = TRUE

/mob/living/simple_animal/hostile/retaliate/wojtek/attackby(obj/item/I, mob/living/user, params)
	if(stat != CONSCIOUS || user.a_intent == INTENT_HARM)
		return ..()
	if(istype(I, /obj/item/clothing/mask/cigarette))
		visible_message("<span class='notice'>[src] bierze [I] od [user] i ze smakiem go zjada, jak na weterana przystało.</span>")
		qdel(I)
		adjustBruteLoss(-10)
		return
	if(istype(I, /obj/item/reagent_containers) && I.reagents?.has_reagent(/datum/reagent/consumable/ethanol/beer))
		visible_message("<span class='notice'>[src] wyrywa [I] z rąk [user] i wypija wszystko duszkiem.</span>")
		I.reagents.clear_reagents()
		adjustBruteLoss(-20)
		playsound(src, 'sound/items/drink.ogg', 50, TRUE)
		return
	return ..()
