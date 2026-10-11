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
	/// Kto ostatnio zadał Wojtkowi obrażenia. Załoga ma tę samą frakcję, więc bazowe Retaliate() by jej nie dopisało do wrogów.
	var/mob/living/last_attacker

/mob/living/simple_animal/hostile/retaliate/wojtek/Destroy()
	last_attacker = null
	return ..()

/// Odda tylko temu, kto go skrzywdził, a nie wszystkim dookoła
/mob/living/simple_animal/hostile/retaliate/wojtek/Retaliate()
	if(isliving(last_attacker) && !QDELETED(last_attacker) && last_attacker != src && (last_attacker in oview(vision_range, src)))
		add_enemy(last_attacker)
	last_attacker = null
	return FALSE

/// Bazowe CanAttack odrzuca cele z tej samej frakcji, więc bez tego Wojtek nie oddałby nikomu z załogi
/mob/living/simple_animal/hostile/retaliate/wojtek/CanAttack(atom/the_target)
	if(isliving(the_target) && (the_target in enemies))
		var/mob/living/L = the_target
		return L.stat <= stat_attack && !(L.status_flags & GODMODE) && see_invisible >= L.invisibility
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attacked_by(obj/item/I, mob/living/user)
	last_attacker = user
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HARM || M.a_intent == INTENT_DISARM)
		last_attacker = M
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	last_attacker = user
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_paw(mob/living/carbon/monkey/M)
	last_attacker = M
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_alien(mob/living/carbon/alien/humanoid/M)
	last_attacker = M
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_larva(mob/living/carbon/alien/larva/L)
	last_attacker = L
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_animal(mob/living/simple_animal/M)
	last_attacker = M
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/attack_slime(mob/living/simple_animal/slime/M)
	last_attacker = M
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(isliving(P.firer))
		last_attacker = P.firer
	return ..()

/mob/living/simple_animal/hostile/retaliate/wojtek/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isliving(throwingdatum?.thrower))
		last_attacker = throwingdatum.thrower
	return ..()

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
