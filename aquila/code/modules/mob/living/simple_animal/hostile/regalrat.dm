// Port szczura królewskiego z tgstation (code/modules/mob/living/simple_animal/hostile/regalrat.dm, stan z tgstation/tgstation@5be6a2c054,
// ostatnia wersja przed przepisaniem na basic moby). Z późniejszych PR tg: liczba mięsa z rzeźni (#73715), wyważanie śluz (#65890)
// i lizanie/drapanie zależne od combat mode (#74040).
// Różnice: duchy przejmują szczura przez set_playable() zamiast ankiety, limit szczurów to stała zamiast configu,
// ser (klin, krąg, królewski) leczy bezpośrednio w AttackingTarget zamiast przez COMSIG_RAT_INTERACT.

#define REGALRAT_RAT_CAP 50
#define REGALRAT_MINOR_HEAL 10
#define REGALRAT_MEDIUM_HEAL 35
#define REGALRAT_MAJOR_HEAL 70

/// Wszystkie żywe wrogie szczury, liczone do limitu przy przywoływaniu myszy
GLOBAL_LIST_EMPTY(hostile_rats)

/mob/living/simple_animal/hostile/regalrat
	name = "feral regal rat"
	desc = "Wyewoluowany szczur, dzieło jakiejś dziwnej nauki. Prowadzi okoliczne szczury ze śmiertelną skutecznością, by bronić swojego królestwa. Technicznie rzecz biorąc, nie jest królem."
	icon = 'aquila/icons/mob/regalrat.dmi'
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 70
	health = 70
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	obj_damage = 10
	butcher_results = list(/obj/item/clothing/head/crown = 1, /obj/item/food/meat/slab/mouse = 2)
	response_help = "spogląda wyniośle na"
	response_disarm = "prycha na"
	response_harm = "tnie"
	melee_damage = 14
	attacktext = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	unique_name = TRUE
	faction = list("rat")
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	flavor_text = "Jesteś szczurzym królem, niezależną, inwazyjną siłą na statku! Gromadź monety, śmieci, ser i co tylko się da w bezpiecznej ciemności. \
		Myszy w pobliżu zmienisz w swoją armię, a twoja domena zatruwa powietrze miazmą, która cię leczy. \
		Z wyłączonym trybem walki liżesz jedzenie i ludzi, a twoja ślina z czasem zjednuje ci poddanych."
	/// Akcja zatruwająca otoczenie miazmą
	var/datum/action/cooldown/domain/domain
	/// Akcja zmieniająca myszy w szczury albo przywołująca nową mysz
	var/datum/action/cooldown/riot/riot
	/// Czy właśnie coś liżemy albo wyważamy, żeby nie zaczynać dwóch rzeczy naraz
	var/busy = FALSE

/mob/living/simple_animal/hostile/regalrat/Initialize(mapload)
	. = ..()
	domain = new
	riot = new
	domain.Grant(src)
	riot.Grant(src)
	AddComponent(/datum/component/waddling)

/mob/living/simple_animal/hostile/regalrat/Destroy()
	QDEL_NULL(domain)
	QDEL_NULL(riot)
	return ..()

/mob/living/simple_animal/hostile/regalrat/handle_automated_action()
	if(prob(20))
		riot.Trigger()
	else if(prob(50))
		domain.Trigger()
	return ..()

/mob/living/simple_animal/hostile/regalrat/CanAttack(atom/the_target)
	if(isregalrat(the_target))
		var/mob/living/other_king = the_target
		return other_king.stat == CONSCIOUS
	if(israt(the_target))
		var/mob/living/simple_animal/hostile/rat/peasant = the_target
		return peasant.stat == CONSCIOUS && !peasant.faction_check_mob(src, TRUE)
	return ..()

/mob/living/simple_animal/hostile/regalrat/examine(mob/user)
	. = ..()
	if(israt(user))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>To twój król. Niech żyje jego wysokość!</span>"
		else
			. += "<span class='warning'>To fałszywy król! Powal go!</span>"
	else if(user != src && isregalrat(user))
		. += "<span class='warning'>Kim jest ten głupi uzurpator? Tak być nie może!</span>"

/mob/living/simple_animal/hostile/regalrat/handle_environment(datum/gas_mixture/environment)
	. = ..()
	if(stat == DEAD || !environment)
		return
	var/total = environment.total_moles()
	if(total && environment.get_moles(GAS_MIASMA) / total >= 0.25)
		heal_bodypart_damage(1)

/mob/living/simple_animal/hostile/regalrat/AttackingTarget()
	if(busy || QDELETED(target))
		return
	if(try_eat_cheese(target))
		return
	// Gracz drapie tylko w trybie walki, poza nim liże i wyważa drzwi. AI liże tylko przedmioty, a ludzi drapie.
	var/peaceful = client && !combat_mode
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = target
		if(door.density && (peaceful || !client))
			pry_open(door)
			return
	if(target.reagents && target.is_injectable(src, allowmobs = TRUE) && (peaceful || (!client && !ismob(target))))
		lick(target)
		return
	if(peaceful)
		return
	return ..()

/// Dodaje szczurzą ślinę do celu
/mob/living/simple_animal/hostile/regalrat/proc/lick(atom/lick_target)
	visible_message("<span class='warning'>[src] zaczyna namiętnie lizać [lick_target]!</span>", "<span class='notice'>Zaczynasz lizać [lick_target]...</span>")
	busy = TRUE
	if(do_after(src, 2 SECONDS, target = lick_target) && lick_target.reagents)
		lick_target.reagents.add_reagent(/datum/reagent/rat_spit, rand(1, 3), no_react = TRUE)
		to_chat(src, "<span class='notice'>Kończysz lizać [lick_target].</span>")
	busy = FALSE

/// Szczur jest za duży na szparę pod drzwiami, ale da radę je podważyć
/mob/living/simple_animal/hostile/regalrat/proc/pry_open(obj/machinery/door/airlock/door)
	if(door.locked || door.welded)
		if(client)
			to_chat(src, "<span class='warning'>[door] ani drgnie, jest zaryglowana albo zaspawana!</span>")
		return
	visible_message("<span class='warning'>[src] zaczyna podważać [door]!</span>", "<span class='notice'>Zaczynasz podważać [door]...</span>")
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50, TRUE)
	busy = TRUE
	if(do_after(src, 10 SECONDS, target = door) && door.density && !door.locked && !door.welded)
		door.open(2)
		visible_message("<span class='warning'>[src] podważa [door] i otwiera ją siłą!</span>")
	busy = FALSE

/// Zjada ser, jeśli jest ranny. Zwraca TRUE, jeśli cel był serem.
/mob/living/simple_animal/hostile/regalrat/proc/try_eat_cheese(atom/cheese)
	var/amount
	if(istype(cheese, /obj/item/food/royalcheese))
		amount = REGALRAT_MAJOR_HEAL
	else if(istype(cheese, /obj/item/food/cheese/wheel))
		amount = REGALRAT_MEDIUM_HEAL
	else if(istype(cheese, /obj/item/food/cheese))
		amount = REGALRAT_MINOR_HEAL
	else
		return FALSE
	if(health >= maxHealth)
		to_chat(src, "<span class='warning'>Czujesz się dobrze, nie musisz nic jeść!</span>")
		return TRUE
	if(amount == REGALRAT_MAJOR_HEAL)
		to_chat(src, "<span class='green'>Zjadasz [cheese], a twoja królewska wola wraca w pełni!</span>")
	else
		to_chat(src, "<span class='green'>Zjadasz [cheese] i odzyskujesz trochę zdrowia.</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	heal_bodypart_damage(amount)
	qdel(cheese)
	return TRUE

/// Wersja dla duchów: losowy tytuł i od razu dostępna do przejęcia
/mob/living/simple_animal/hostile/regalrat/controlled
	name = "regal rat"
	unique_name = FALSE

/mob/living/simple_animal/hostile/regalrat/controlled/Initialize(mapload)
	. = ..()
	var/title = pick("Król", "Lord", "Książę", "Cesarz", "Władca", "Suweren", "Pan", "Szogun", "Bojar", "Car")
	var/kingdom = pick("Zarazy", "Miazmy", "Techów", "Śmieci", "Odpadków", "Szczurów", "Robactwa", "Sera")
	name = "[title] [kingdom]"
	real_name = name
	set_playable(ROLE_SENTIENCE)

/mob/living/simple_animal/hostile/regalrat/controlled/give_mind(mob/user)
	. = ..()
	if(key)
		notify_ghosts("Powstańcie przed szczurzym królem, który zasiadł na tronie w [get_area_name(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Szczurzy król")

/**
 * Domena szczurzego króla: miazma i brud pod łapami
 */
/datum/action/cooldown/domain
	name = "Domena szczurzego króla"
	desc = "Zatruwa okolicę, by lepiej służyła twojej szczurzej armii. Miazma cię leczy."
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 6 SECONDS
	icon_icon = 'aquila/icons/mob/actions/actions_regalrat.dmi'
	background_icon_state = "bg_clock"
	button_icon_state = "coffer"

// /datum/action/cooldown/IsAvailable() pomija check_flags, a martwy król nie powinien rozkazywać (tg#60127)
/datum/action/cooldown/domain/IsAvailable()
	return ..() && owner?.stat == CONSCIOUS

/datum/action/cooldown/domain/Trigger()
	if(!..())
		return FALSE
	var/turf/T = get_turf(owner)
	if(!T)
		return FALSE
	T.atmos_spawn_air("[GAS_MIASMA]=4;TEMP=[T20C]")
	switch(rand(1, 10))
		if(8)
			new /obj/effect/decal/cleanable/vomit(T)
		if(9)
			new /obj/effect/decal/cleanable/vomit/old(T)
		if(10)
			new /obj/effect/decal/cleanable/oil/slippery(T)
		else
			new /obj/effect/decal/cleanable/dirt(T)
	StartCooldown()
	return TRUE

/**
 * Zmienia pobliskie myszy we wrogie szczury. Jeśli żadnej nie ma, przywołuje nową mysz.
 */
/datum/action/cooldown/riot
	name = "Zbierz armię"
	desc = "Wznieć armię z hord myszy i szkodników pełzających po korytarzach serwisowych."
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 8 SECONDS
	icon_icon = 'aquila/icons/mob/actions/actions_regalrat.dmi'
	background_icon_state = "bg_clock"
	button_icon_state = "riot"

/datum/action/cooldown/riot/IsAvailable()
	return ..() && owner?.stat == CONSCIOUS

/datum/action/cooldown/riot/Trigger()
	if(!..())
		return FALSE
	var/mob/living/king = owner
	var/converted = FALSE
	for(var/mob/living/simple_animal/mouse/M in oview(king, 5))
		if(M.stat == DEAD)
			continue
		var/mob/living/simple_animal/hostile/rat/new_rat = new(get_turf(M))
		converted = TRUE
		new_rat.faction = king.faction.Copy()
		if(M.mind)
			M.mind.transfer_to(new_rat)
			to_chat(new_rat, "<span class='userdanger'>Szczurzy król cię wezwał! Służysz teraz [king.name] i jego armii.</span>")
		qdel(M)
	if(converted)
		king.visible_message("<span class='warning'>[king] wydaje rozkaz swojej armii, zmieniając myszy w szczury!</span>")
	else
		var/rodents = length(GLOB.hostile_rats)
		for(var/mob/living/simple_animal/mouse/M in GLOB.alive_mob_list)
			rodents++
		if(rodents >= REGALRAT_RAT_CAP)
			to_chat(king, "<span class='warning'>Na statku jest za dużo gryzoni, żeby przywołać kolejnego! Najpierw je znajdź!</span>")
			return FALSE
		new /mob/living/simple_animal/mouse(king.loc)
		king.visible_message("<span class='warning'>[king] przywołuje mysz do swojego boku!</span>")
	StartCooldown()
	return TRUE

/mob/living/simple_animal/hostile/rat
	name = "rat"
	desc = "Paskudny, brzydki, zły, roznoszący choroby gryzoń z problemami z gniewem."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Skrii!", "SKRIII!", "Pi?")
	speak_emote = list("piszczy")
	emote_hear = list("syczy.")
	emote_see = list("biega w kółko.", "staje na tylnych łapach.")
	melee_damage = 4
	attacktext = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 5
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 8
	maxHealth = 15
	health = 15
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	response_help = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm = "rozpłaszcza"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("rat")
	chat_color = "#82AF84"

/mob/living/simple_animal/hostile/rat/Initialize(mapload)
	. = ..()
	GLOB.hostile_rats += src
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100)

/mob/living/simple_animal/hostile/rat/Destroy()
	GLOB.hostile_rats -= src
	return ..()

/mob/living/simple_animal/hostile/rat/death(gibbed)
	GLOB.hostile_rats -= src
	if(ckey)
		return ..()
	..(TRUE)
	if(!gibbed)
		var/obj/item/food/deadmouse/mouse = new(loc)
		mouse.icon_state = icon_dead
		mouse.name = name
	qdel(src)

/mob/living/simple_animal/hostile/rat/revive(full_heal = FALSE, admin_revive = FALSE)
	if(!admin_revive && !ckey && length(GLOB.hostile_rats) >= REGALRAT_RAT_CAP)
		visible_message("<span class='warning'>[src] drga, ale nie wstaje, przytłoczony liczbą gryzoni na statku!</span>")
		return FALSE
	. = ..()
	if(.)
		GLOB.hostile_rats |= src

/mob/living/simple_animal/hostile/rat/examine(mob/user)
	. = ..()
	if(israt(user))
		var/mob/living/simple_animal/hostile/rat/ratself = user
		if(ratself.faction_check_mob(src, TRUE))
			. += "<span class='notice'>Służycie temu samemu królowi.</span>"
		else
			. += "<span class='warning'>Ten głupiec służy innemu królowi!</span>"
	else if(isregalrat(user))
		var/mob/living/simple_animal/hostile/regalrat/ratking = user
		if(ratking.faction_check_mob(src, TRUE))
			. += "<span class='notice'>Ten szczur ci służy.</span>"
		else
			. += "<span class='warning'>Ten chłop służy innemu królowi! Powal go!</span>"

/mob/living/simple_animal/hostile/rat/CanAttack(atom/the_target)
	if(isregalrat(the_target) || israt(the_target))
		var/mob/living/other = the_target
		return other.stat == CONSCIOUS && !other.faction_check_mob(src, TRUE)
	return ..()

/mob/living/simple_animal/hostile/rat/handle_automated_action()
	. = ..()
	if(!prob(40))
		return
	var/turf/open/floor/F = get_turf(src)
	if(!istype(F) || F.intact || (locate(/obj/structure/lattice/catwalk) in F))
		return
	var/obj/structure/cable/C = locate() in F
	if(!C?.avail())
		return
	if(prob(15))
		visible_message("<span class='warning'>[src] przegryza [C]. Po nim!</span>")
		playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
		C.deconstruct()
		death()
	else
		visible_message("<span class='warning'>[src] przegryza [C] i wygląda na całego!</span>")
		playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
		C.deconstruct()

/mob/living/simple_animal/hostile/rat/AttackingTarget()
	if(istype(target, /obj/item/food/cheese) || istype(target, /obj/item/food/royalcheese))
		if(health >= maxHealth)
			to_chat(src, "<span class='warning'>Czujesz się dobrze, nie musisz nic jeść!</span>")
			return
		to_chat(src, "<span class='green'>Zjadasz [target] i odzyskujesz zdrowie.</span>")
		heal_bodypart_damage(maxHealth)
		qdel(target)
		return
	return ..()

/**
 * Szczurza ślina: nieszkodliwa, obrzydza, a po przedawkowaniu jednoczy ze szczurami
 */
/datum/reagent/rat_spit
	name = "Rat Spit"
	description = "Coś od szczura. Boże! Kto wie, gdzie to było!"
	reagent_state = LIQUID
	color = "#C8C8C8"
	metabolization_rate = 0.03 * REAGENTS_METABOLISM
	taste_description = "coś dziwnego"
	overdose_threshold = 20

/datum/reagent/rat_spit/on_mob_metabolize(mob/living/L)
	..()
	if(HAS_TRAIT(L, TRAIT_AGEUSIA))
		return
	to_chat(L, "<span class='notice'>To jedzenie ma dziwny posmak!</span>")

/datum/reagent/rat_spit/overdose_start(mob/living/M)
	..()
	var/mob/living/carbon/victim = M
	if(istype(victim) && !("rat" in victim.faction))
		to_chat(victim, "<span class='userdanger'>Po tym ostatnim łyku twoje ciało ogarniają straszne drgawki. Rozmyślając nad tym, co się stało, czujesz rodzące się pokrewieństwo ze szczurami i ich nowym władcą!</span>")
		victim.faction |= "rat"
		victim.vomit()
	metabolization_rate = 10 * REAGENTS_METABOLISM

/datum/reagent/rat_spit/on_mob_life(mob/living/carbon/C)
	if(prob(15))
		to_chat(C, "<span class='notice'>Robi ci się niedobrze!</span>")
		C.adjust_disgust(3)
	else if(prob(10))
		to_chat(C, "<span class='warning'>To jedzenie ci nie posłużyło!</span>")
		C.adjust_disgust(5)
	else if(prob(5))
		C.vomit()
	..()

#undef REGALRAT_RAT_CAP
#undef REGALRAT_MINOR_HEAL
#undef REGALRAT_MEDIUM_HEAL
#undef REGALRAT_MAJOR_HEAL
