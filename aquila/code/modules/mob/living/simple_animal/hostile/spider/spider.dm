// AQUILA - pająki z tgstation (basic mob /mob/living/basic/spider) przepisane na simple_animal

/**
 * Podstawa wszystkich stadiów pająka: pajączek, młody pająk i pająk olbrzymi.
 */
/mob/living/simple_animal/hostile/spider
	name = "abstrakcyjny pająk"
	desc = "Włochaty i abstrakcyjny, aż ciarki przechodzą. Ten nie powinien istnieć."
	icon = 'aquila/icons/mob/arachnoid.dmi'
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	speak_emote = list("szczebiocze")
	emote_hear = list("szczebiocze.")
	speak_chance = 5
	turns_per_move = 5
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	response_help = "głaszcze"
	response_disarm = "delikatnie odsuwa"
	response_harm = "uderza"
	damage_coeff = list(BRUTE = 1, BURN = 1.25, TOX = 3, CLONE = 1, STAMINA = 0, OXY = 1)
	faction = list("spiders")
	pass_flags = PASSTABLE
	attacktext = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	unique_name = TRUE
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	do_footstep = TRUE
	discovery_points = 1000
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	mobchatspan = "researchdirector"
	minbodytemp = 250
	maxbodytemp = 350

	/// Przyspieszenie (ujemne) dla pająka sterowanego przez gracza
	var/player_speed_modifier = -4
	/// Jaki odczynnik wstrzykujemy przy ugryzieniu
	var/poison_type = /datum/reagent/toxin/hunterspider
	/// Ile odczynnika na ugryzienie
	var/poison_per_bite = 0
	/// Czy ugryzienie przebija grube ubrania (skafandry)
	var/bite_pierces_thick = FALSE
	/// Mnożnik czasu snucia sieci. Ułamek przyspiesza.
	var/web_speed = 1
	/// Podstawowa zdolność snucia sieci
	var/web_type = /datum/action/cooldown/spider/lay_web
	/// Spowolnienie poza siecią (0 = brak)
	var/off_web_slowdown = 0
	/// Rozkaz pozostawiony przez matkę przy składaniu jaj
	var/directive = ""
	/// Krótki opis do menu wyboru pająka
	var/menu_description = "Wytrzymały i silny, do obrony gniazda i innych pająków."
	/// Zdolności nadawane przy Initialize
	var/list/innate_actions = null
	/// Zajęty snuciem, owijaniem, składaniem jaj albo leczeniem
	var/busy = FALSE
	/// Bazowe opóźnienie ruchu AI, bez kar za brak sieci
	var/base_move_to_delay
	/// Zdolność snucia sieci, z której korzysta AI
	var/datum/action/cooldown/spider/lay_web/web_action
	/// Pole, na którym AI chce snuć sieć
	var/turf/web_target
	/// Kiedy AI odpuszcza dojście do pola pod sieć
	var/web_target_timeout = 0
	/// Zdolność samoleczenia (tangle, tank)
	var/datum/action/cooldown/spider/mend/mend_action
	/// Lecząc innych: ile brute i burn naraz
	var/heal_others_amount = 0
	/// Lecząc innych: ile to trwa
	var/heal_others_time = 2.5 SECONDS
	/// Czy AI tylko oddaje (młode pająki, pająki kanałowe)
	var/retaliate_only = FALSE
	/// Kto nas zaatakował, gdy retaliate_only
	var/list/enemies
	/// Uciekamy, gdy zdrowie spadnie poniżej tego ułamka (0 = nigdy)
	var/flee_health_ratio = 0
	/// Ładunki na jaja z wyssanych ofiar (używa ich matka)
	var/egg_charges = 0

/mob/living/simple_animal/hostile/spider/Initialize(mapload)
	. = ..()
	base_move_to_delay = max(1.5, speed + 1.5)
	move_to_delay = base_move_to_delay
	// Kolejność przycisków: najpierw te oznaczone button_first (np. owijanie), potem sieć, potem reszta
	var/list/later_actions = list()
	for(var/action_type in innate_actions)
		var/datum/action/cooldown/spider/new_action = new action_type(src)
		if(istype(new_action) && new_action.button_first)
			new_action.Grant(src)
		else
			later_actions += new_action
	web_action = new web_type(src)
	web_action.webbing_time *= web_speed
	web_action.Grant(src)
	for(var/datum/action/new_action as anything in later_actions)
		new_action.Grant(src)
	if(off_web_slowdown)
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(update_web_walking))
		update_web_walking()

/mob/living/simple_animal/hostile/spider/Destroy()
	GLOB.spidermobs -= src
	web_target = null
	web_action = null
	mend_action = null
	enemies = null
	return ..()

/mob/living/simple_animal/hostile/spider/Login()
	. = ..()
	if(!client)
		return
	GLOB.spidermobs[src] = TRUE
	if(player_speed_modifier)
		add_movespeed_modifier(MOVESPEED_ID_SPIDER_PLAYER, TRUE, 100, override = TRUE, multiplicative_slowdown = player_speed_modifier)
	if(directive)
		to_chat(src, span_spiderlarge("Matka zostawiła ci rozkaz! Wypełnij go za wszelką cenę."))
		to_chat(src, span_spiderlarge("<b>Rozkaz: [directive]</b>"))

/mob/living/simple_animal/hostile/spider/Logout()
	. = ..()
	remove_movespeed_modifier(MOVESPEED_ID_SPIDER_PLAYER)

/mob/living/simple_animal/hostile/spider/mob_negates_gravity()
	if(locate(/obj/structure/spider/stickyweb) in loc)
		return TRUE
	return ..()

/// Pająki chodzą szybciej po sieci (tg: /datum/element/web_walker)
/mob/living/simple_animal/hostile/spider/proc/update_web_walking()
	SIGNAL_HANDLER
	if(!off_web_slowdown)
		return
	if(locate(/obj/structure/spider/stickyweb) in loc)
		remove_movespeed_modifier(MOVESPEED_ID_SPIDER_WEB_WALKER)
		move_to_delay = base_move_to_delay
	else
		add_movespeed_modifier(MOVESPEED_ID_SPIDER_WEB_WALKER, TRUE, 100, override = TRUE, multiplicative_slowdown = off_web_slowdown)
		move_to_delay = base_move_to_delay + off_web_slowdown

/// Ugryzienie wstrzykuje jad (tg: /datum/element/venomous)
/mob/living/simple_animal/hostile/spider/AttackingTarget()
	if(!combat_mode && client && try_heal_target(target))
		return FALSE
	. = ..()
	if(!. || !poison_per_bite || !isliving(target))
		return
	var/mob/living/victim = target
	if(!victim.reagents || victim.stat == DEAD)
		return
	if(iscarbon(victim) && !bite_pierces_thick)
		var/mob/living/carbon/carbon_victim = victim
		if(!carbon_victim.can_inject(src, FALSE, BODY_ZONE_CHEST, bite_pierces_thick))
			return
	victim.reagents.add_reagent(poison_type, poison_per_bite)

/// Owijanie ran innych pająków (tg: /datum/component/healing_touch u pielęgniarek)
/mob/living/simple_animal/hostile/spider/proc/try_heal_target(atom/heal_target)
	if(!heal_others_amount || heal_target == src || !istype(heal_target, /mob/living/simple_animal/hostile/spider/giant))
		return FALSE
	var/mob/living/simple_animal/hostile/spider/giant/patient = heal_target
	if(patient.stat == DEAD)
		return FALSE
	if(patient.health >= patient.maxHealth)
		patient.balloon_alert(src, "nie jest ranny!")
		return TRUE
	if(busy)
		balloon_alert(src, "zajęty!")
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(heal_target_async), patient)
	return TRUE

/mob/living/simple_animal/hostile/spider/proc/heal_target_async(mob/living/simple_animal/hostile/spider/giant/patient)
	busy = TRUE
	visible_message(span_notice("[src] zaczyna owijać rany [patient]."), span_notice("Zaczynasz owijać rany [patient]."))
	if(do_after(src, heal_others_time, target = patient) && patient.stat != DEAD)
		patient.adjustBruteLoss(-heal_others_amount)
		patient.adjustFireLoss(-heal_others_amount)
		visible_message(span_notice("[src] owija rany [patient]."), span_notice("Owijasz rany [patient]."))
	busy = FALSE

/// Zmienia liczbę ładunków na jaja i odświeża przyciski składania
/mob/living/simple_animal/hostile/spider/proc/adjust_egg_charges(amount)
	egg_charges = max(egg_charges + amount, 0)
	for(var/datum/action/cooldown/spider/lay_eggs/egg_action in actions)
		egg_action.UpdateButtonIcon()

// AI

/mob/living/simple_animal/hostile/spider/ListTargets()
	if(!retaliate_only)
		return ..()
	if(!length(enemies))
		return list()
	var/list/seen = ..()
	return seen & enemies

/mob/living/simple_animal/hostile/spider/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0 && stat == CONSCIOUS && retaliate_only && !client)
		for(var/mob/living/attacker in oview(vision_range, src))
			if(!faction_check_mob(attacker) && attacker.stat != DEAD)
				LAZYOR(enemies, attacker)
	if(flee_health_ratio && !client)
		retreat_distance = (health < maxHealth * flee_health_ratio) ? 6 : initial(retreat_distance)

/// Gdy nie ma kogo gryźć, AI rozsnuwa sieć w okolicy (tg: find_unwebbed_turf + spin_web)
/mob/living/simple_animal/hostile/spider/handle_automated_movement()
	if(client || stat != CONSCIOUS || busy)
		return
	if(target || !web_action)
		return ..()
	if(web_target)
		if(world.time > web_target_timeout || !isturf(loc))
			web_target = null
			stop_automated_movement = FALSE
			return ..()
		if(loc == web_target)
			web_target = null
			stop_automated_movement = FALSE
			if(web_action.IsAvailable())
				INVOKE_ASYNC(web_action, TYPE_PROC_REF(/datum/action, Trigger))
			return
		return
	if(prob(10))
		var/turf/spot = find_unwebbed_turf()
		if(spot)
			web_target = spot
			web_target_timeout = world.time + 10 SECONDS
			stop_automated_movement = TRUE
			SSmove_manager.move_to(src, spot, 0, move_to_delay, 10 SECONDS)
			return
	return ..()

/// Szuka pobliskiego, otwartego pola, które przyda się zasnuć
/mob/living/simple_animal/hostile/spider/proc/find_unwebbed_turf()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return null
	if(web_action.can_web_turf(our_turf))
		return our_turf
	var/list/candidates = list()
	for(var/turf/open/nearby in view(3, src))
		if(isspaceturf(nearby) || nearby.density)
			continue
		if(!web_action.can_web_turf(nearby))
			continue
		candidates += nearby
	if(!length(candidates))
		return null
	return pick(candidates)

/// Pająk, który z czasem przechodzi w kolejne stadium
/mob/living/simple_animal/hostile/spider/growing
	/// W co wyrośniemy. Pusty = losowy pająk olbrzymi.
	var/mob/living/simple_animal/hostile/spider/grow_as = null
	/// Ile trwa dorastanie
	var/spider_growth_time = 1 MINUTES
	/// Postęp dorastania w procentach
	var/growth_progress = 0

/mob/living/simple_animal/hostile/spider/growing/Life()
	. = ..()
	if(!. || stat == DEAD)
		return
	if(!ready_to_grow())
		return
	// Życie tyka co 2 sekundy; jak w tg dorastamy nierówno, ale średnio w spider_growth_time
	if(prob(50))
		growth_progress += (4 SECONDS / spider_growth_time) * 100
	if(growth_progress >= 100)
		grow_up()

/// Rośniemy tylko na twardym gruncie, nie w rurach
/mob/living/simple_animal/hostile/spider/growing/proc/ready_to_grow()
	return isturf(loc)

/// Zmienia nas w następne stadium
/mob/living/simple_animal/hostile/spider/growing/proc/grow_up()
	if(isnull(grow_as))
		if(prob(3))
			grow_as = pick(/mob/living/simple_animal/hostile/spider/giant/tarantula, /mob/living/simple_animal/hostile/spider/giant/viper, /mob/living/simple_animal/hostile/spider/giant/midwife)
		else
			grow_as = pick(/mob/living/simple_animal/hostile/spider/giant/guard, /mob/living/simple_animal/hostile/spider/giant/ambush, /mob/living/simple_animal/hostile/spider/giant/hunter, /mob/living/simple_animal/hostile/spider/giant/scout, /mob/living/simple_animal/hostile/spider/giant/nurse, /mob/living/simple_animal/hostile/spider/giant/tangle)

	var/mob/living/simple_animal/hostile/spider/grown = new grow_as(get_turf(src))
	grown.faction = faction.Copy()
	grown.directive = directive
	grown.adjustBruteLoss(getBruteLoss())
	grown.adjustFireLoss(getFireLoss())
	if(mind)
		mind.transfer_to(grown, TRUE)
	else if(key)
		grown.key = key
	grown.visible_message(span_warning("[src] wyrasta na [grown]!"))
	qdel(src)

/**
 * ### Pająk kanałowy
 * Mały pająk z technicznych, który snuje sieci i poluje na myszy.
 */
/mob/living/simple_animal/hostile/spider/maintenance
	name = "pająk kanałowy"
	desc = "Importowane przez Nanotrasen rozwiązanie problemu myszy. Ma własne problemy."
	icon_state = "maint_spider"
	icon_living = "maint_spider"
	icon_dead = "maint_spider_dead"
	mob_size = MOB_SIZE_TINY
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	gold_core_spawnable = FRIENDLY_SPAWN
	maxHealth = 10
	health = 10
	melee_damage = 1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speed = 0
	player_speed_modifier = 0
	web_speed = 0.25
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	ventcrawler = VENTCRAWLER_ALWAYS
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	retaliate_only = TRUE
	menu_description = "Kruchy pająk, który nadaje się głównie do snucia sieci."
	response_harm = "rozgniata"
