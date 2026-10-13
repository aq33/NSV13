// AQUILA - pajęczyny, kokony i jaja (tg: spiderwebs.dm, spider_roles.dm)

/// Filtr obrysu odróżniający rodzaje sieci
#define SPIDER_WEB_TINT "web_colour_tint"

/// Kierunki do wygładzania bitmaską (jak SMOOTH_BITMASK w nowym tg)
#define WEB_JUNCTION_N (1<<0)
#define WEB_JUNCTION_S (1<<1)
#define WEB_JUNCTION_E (1<<2)
#define WEB_JUNCTION_W (1<<3)
#define WEB_JUNCTION_NE (1<<4)
#define WEB_JUNCTION_SE (1<<5)
#define WEB_JUNCTION_SW (1<<6)
#define WEB_JUNCTION_NW (1<<7)

/obj/structure/spider
	name = "sieć"
	icon = 'aquila/icons/effects/web.dmi'
	desc = "Włóknista i lepka."
	anchored = TRUE
	density = FALSE
	max_integrity = 15
	/// Przedrostek stanów ikony wygładzanej ("stickyweb" -> "stickyweb-21")
	var/base_icon_state
	/// Grupa wygładzania. Pusta = bez wygładzania.
	var/web_smooth_group = null
	/// Czy łączymy się wizualnie ze ścianami
	var/web_smooth_with_walls = FALSE
	/// Czy przesuwamy się o -9 px, bo ikona 50x50 ma frędzle
	var/has_frill = FALSE

/obj/structure/spider/Initialize(mapload)
	if(has_frill)
		pixel_x = -9
		pixel_y = -9
	. = ..()
	if(web_smooth_group)
		update_web_smoothing(TRUE)

/obj/structure/spider/Destroy()
	var/turf/old_turf = get_turf(src)
	var/smooth_group = web_smooth_group
	. = ..()
	if(smooth_group && old_turf)
		for(var/turf/neighbour in orange(1, old_turf))
			for(var/obj/structure/spider/web in neighbour)
				if(web.web_smooth_group == smooth_group)
					web.update_web_smoothing(FALSE)

/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN) // lepkość tłumi wszystko poza ogniem
		playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee")
		switch(damage_type)
			if(BURN)
				damage_amount *= 1.25
			if(BRUTE)
				damage_amount *= 0.25
	return ..()

/obj/structure/spider/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 350)
		take_damage(5, BURN, 0, 0)

/// Czy na tym polu jest coś, z czym się łączymy
/obj/structure/spider/proc/web_connects_to(turf/neighbour)
	if(!neighbour)
		return FALSE
	if(web_smooth_with_walls && isclosedturf(neighbour))
		return TRUE
	for(var/obj/structure/spider/web in neighbour)
		if(web != src && web.web_smooth_group == web_smooth_group)
			return TRUE
	return FALSE

/// Wylicza stan ikony z sąsiadów. Diagonale liczą się tylko przy obu sąsiednich kierunkach, jak w tg.
/obj/structure/spider/proc/update_web_smoothing(update_neighbours = FALSE)
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/junction = NONE
	if(web_connects_to(get_step(our_turf, NORTH)))
		junction |= WEB_JUNCTION_N
	if(web_connects_to(get_step(our_turf, SOUTH)))
		junction |= WEB_JUNCTION_S
	if(web_connects_to(get_step(our_turf, EAST)))
		junction |= WEB_JUNCTION_E
	if(web_connects_to(get_step(our_turf, WEST)))
		junction |= WEB_JUNCTION_W
	if((junction & (WEB_JUNCTION_N|WEB_JUNCTION_E)) == (WEB_JUNCTION_N|WEB_JUNCTION_E) && web_connects_to(get_step(our_turf, NORTHEAST)))
		junction |= WEB_JUNCTION_NE
	if((junction & (WEB_JUNCTION_S|WEB_JUNCTION_E)) == (WEB_JUNCTION_S|WEB_JUNCTION_E) && web_connects_to(get_step(our_turf, SOUTHEAST)))
		junction |= WEB_JUNCTION_SE
	if((junction & (WEB_JUNCTION_S|WEB_JUNCTION_W)) == (WEB_JUNCTION_S|WEB_JUNCTION_W) && web_connects_to(get_step(our_turf, SOUTHWEST)))
		junction |= WEB_JUNCTION_SW
	if((junction & (WEB_JUNCTION_N|WEB_JUNCTION_W)) == (WEB_JUNCTION_N|WEB_JUNCTION_W) && web_connects_to(get_step(our_turf, NORTHWEST)))
		junction |= WEB_JUNCTION_NW
	icon_state = "[base_icon_state]-[junction]"
	if(!update_neighbours)
		return
	for(var/turf/neighbour in orange(1, our_turf))
		for(var/obj/structure/spider/web in neighbour)
			if(web.web_smooth_group == web_smooth_group)
				web.update_web_smoothing(FALSE)

/**
 * Zwykła lepka sieć. Pająki przechodzą bez problemu, reszta czasem się zaplątuje.
 */
/obj/structure/spider/stickyweb
	icon = 'aquila/icons/obj/smooth_structures/stickyweb.dmi'
	base_icon_state = "stickyweb"
	icon_state = "stickyweb-0"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	web_smooth_group = "spider_web"
	web_smooth_with_walls = TRUE
	has_frill = TRUE
	/// Czy to szczelna ściana z sieci
	var/sealed = FALSE
	/// Szansa, że ktoś się zaplącze, wchodząc na pole
	var/stuck_chance = 50
	/// Szansa, że pocisk przeleci (reszta grzęźnie)
	var/projectile_stuck_chance = 30

/obj/structure/spider/stickyweb/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/// Pająki potrafią zwinąć sieć z powrotem w tkaninę
/obj/structure/spider/stickyweb/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(isspider(user) && !user.combat_mode && !sealed)
		INVOKE_ASYNC(src, PROC_REF(weave_cloth), user)
		return
	return ..()

/obj/structure/spider/stickyweb/proc/weave_cloth(mob/living/user)
	balloon_alert_to_viewers("zwija sieć...")
	if(!do_after(user, 2 SECONDS, target = src))
		balloon_alert(user, "przerwano!")
		return
	new /obj/item/stack/sheet/cotton/cloth(get_turf(src))
	qdel(src)

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(sealed)
		return FALSE
	if(isprojectile(mover))
		return prob(projectile_stuck_chance)

/// Czy ten mob przechodzi bez problemu
/obj/structure/spider/stickyweb/proc/is_whitelisted(mob/living/candidate)
	return isspider(candidate)

/obj/structure/spider/stickyweb/proc/on_entered(datum/source, atom/movable/victim)
	SIGNAL_HANDLER
	if(!isliving(victim))
		return
	var/mob/living/living_victim = victim
	if(is_whitelisted(living_victim) || (living_victim.pulledby && is_whitelisted(living_victim.pulledby)))
		return
	if(living_victim.movement_type & (FLYING|FLOATING))
		return
	if(prob(stuck_chance))
		stuck_react(living_victim)

/// Wyczerpuje i informuje, że ktoś utknął w sieci
/obj/structure/spider/stickyweb/proc/stuck_react(mob/living/victim)
	if(QDELETED(victim))
		return
	if(victim.getStaminaLoss() > 90)
		if(victim.mobility_flags & MOBILITY_STAND)
			to_chat(victim, span_warning("Potykasz się w [src] z wyczerpania!"))
		victim.SetKnockdown(3 SECONDS)
		return
	if(prob(25))
		victim.balloon_alert(victim, "utknąłeś w sieci!")
		victim.Shake(1, 1, 2)
	victim.adjustStaminaLoss(rand(10, 15))

/// Sieć, przez którą zawsze się utknie
/obj/structure/spider/stickyweb/very_sticky
	max_integrity = 20
	desc = "Wyjątkowo lepki jedwab. Łatwo tędy nie przejdziesz."
	stuck_chance = 100
	projectile_stuck_chance = 100

/obj/structure/spider/stickyweb/very_sticky/Initialize(mapload)
	. = ..()
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ffffaaff", "size" = 0.1))
	var/mutable_appearance/web_overlay = mutable_appearance('aquila/icons/effects/web.dmi', "sticky_overlay", layer + 0.01)
	web_overlay.pixel_x = -pixel_x
	web_overlay.pixel_y = -pixel_y
	add_overlay(web_overlay)

/// Ściana z sieci
/obj/structure/spider/stickyweb/sealed
	name = "szczelna sieć"
	desc = "Lita ściana z sieci, tak gęsta, że nie przepuszcza powietrza."
	icon = 'aquila/icons/obj/smooth_structures/webwall.dmi'
	base_icon_state = "webwall"
	icon_state = "webwall-0"
	web_smooth_group = "spider_web_wall"
	web_smooth_with_walls = FALSE
	plane = GAME_PLANE
	layer = OBJ_LAYER
	sealed = TRUE
	has_frill = FALSE
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/spider/stickyweb/sealed/Initialize(mapload)
	. = ..()
	air_update_turf()

/obj/structure/spider/stickyweb/sealed/Destroy()
	var/turf/old_turf = get_turf(src)
	. = ..()
	old_turf?.air_update_turf()

/// Ściana odbijająca pociski
/obj/structure/spider/stickyweb/sealed/reflector
	name = "lustrzany ekran z jedwabiu"
	desc = "Utwardzona sieć nasączona specjalnymi substancjami, przez które odbija pociski."
	icon = 'aquila/icons/obj/smooth_structures/webwall_reflector.dmi'
	base_icon_state = "webwall_reflector"
	icon_state = "webwall_reflector-0"
	web_smooth_group = "spider_web_wall_mirror"
	max_integrity = 30
	opacity = TRUE
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD

/obj/structure/spider/stickyweb/sealed/reflector/bullet_act(obj/item/projectile/P)
	if(!P.reflectable && !istype(P, /obj/item/projectile/bullet))
		return ..()
	// Odbijamy w przybliżeniu tam, skąd przyleciał
	P.ignore_source_check = TRUE
	P.setAngle(SIMPLIFY_DEGREES(P.Angle + 180 + rand(-30, 30)))
	P.range = P.decayedRange
	P.decayedRange = max(P.decayedRange - 1, 0)
	visible_message(span_warning("[P] odbija się od [src]!"))
	return BULLET_ACT_FORCE_PIERCE

/// Nieprzejrzysta, wytrzymała ściana z sieci
/obj/structure/spider/stickyweb/sealed/tough
	name = "utwardzona sieć"
	desc = "Sieć utwardzona chemicznie w wytrzymałą barierę."
	icon = 'aquila/icons/obj/smooth_structures/webwall_dark.dmi'
	base_icon_state = "webwall_dark"
	icon_state = "webwall_dark-0"
	web_smooth_group = "spider_web_wall_tough"
	opacity = TRUE
	max_integrity = 90
	layer = ABOVE_MOB_LAYER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/// Zasłona z sieci: trzyma powietrze, ale nie blokuje przejścia
/obj/structure/spider/passage
	name = "przejście w sieci"
	desc = "Nieprzejrzysta kurtyna z sieci, która trzyma powietrze, ale nie zatrzymuje przechodzących."
	icon = 'aquila/icons/obj/smooth_structures/stickyweb_rotated.dmi'
	base_icon_state = "stickyweb_rotated"
	icon_state = "stickyweb_rotated-0"
	web_smooth_group = "spider_web_roof"
	web_smooth_with_walls = TRUE
	has_frill = TRUE
	CanAtmosPass = ATMOS_PASS_NO
	opacity = TRUE
	max_integrity = 60
	alpha = 200
	layer = ABOVE_MOB_LAYER
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/obj/structure/spider/passage/Initialize(mapload)
	. = ..()
	air_update_turf()
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ffffffff", "alpha" = 0.8, "size" = 0.1))

/obj/structure/spider/passage/Destroy()
	var/turf/old_turf = get_turf(src)
	. = ..()
	old_turf?.air_update_turf()

/// Kolczatka z jedwabiu
/obj/structure/spider/spikes
	name = "kolce z sieci"
	desc = "Jedwab utwardzony w małe, ale groźne kolce."
	icon = 'aquila/icons/obj/smooth_structures/stickyweb_spikes.dmi'
	base_icon_state = "stickyweb_spikes"
	icon_state = "stickyweb_spikes-0"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	web_smooth_group = "spider_web"
	web_smooth_with_walls = TRUE
	has_frill = TRUE
	max_integrity = 40

/obj/structure/spider/spikes/Initialize(mapload)
	. = ..()
	add_filter(SPIDER_WEB_TINT, 10, list("type" = "outline", "color" = "#ac0000ff", "size" = 0.1))
	AddComponent(/datum/component/caltrop, 20, 30, 100, CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

/// Kokon z ofiarą w środku
/obj/structure/spider/cocoon
	name = "kokon"
	desc = "Coś owiniętego jedwabistą pajęczyną."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")
	return ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	var/breakout_time = 1 MINUTES
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, span_notice("Szarpiesz się w ciasnych więzach... (zajmie to około [DisplayTimeText(breakout_time)])"))
	visible_message(span_notice("Coś szarpie się i wije w [src]!"))
	if(do_after(user, breakout_time, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)

/obj/structure/spider/cocoon/Destroy()
	var/turf/our_turf = get_turf(src)
	visible_message(span_warning("[src] pęka."))
	for(var/atom/movable/contained in contents)
		contained.forceMove(our_turf)
	return ..()

/// Kukła z sieci zrzucona przez pająka strażnika
/obj/structure/spider/effigy
	name = "pajęcza kukła"
	desc = "Pająk olbrzymi! Na szczęście to tylko posąg z utwardzonej sieci."
	icon_state = "effigy"
	max_integrity = 125
	density = TRUE
	anchored = FALSE

/obj/structure/spider/effigy/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 1 MINUTES)

/**
 * # Gniazdo jaj
 *
 * Dojrzewa, a potem duch może z niego wykluć się jako pająk (rola dla duchów).
 * Zastępuje tg-owe /obj/effect/mob_spawn/ghost_role/spider razem z jego strukturą.
 */
/obj/structure/spider/eggcluster
	name = "gniazdo jaj"
	desc = "Coś tam w środku żyje i prędzej czy później znajdzie drogę na zewnątrz."
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	max_integrity = 30
	/// Postęp dojrzewania, przy 100 da się wykluć
	var/amount_grown = 0
	/// Czy gotowe do wyklucia
	var/ready = FALSE
	/// Rozkaz matki przekazywany dziecku
	var/directive = ""
	/// Frakcja potomstwa
	var/list/faction = list("spiders")
	/// Co może się wykluć
	var/list/potentialspawns = list(
		/mob/living/simple_animal/hostile/spider/growing/spiderling/nurse,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/hunter,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/ambush,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/tangle,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/guard,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/scout,
	)
	/// Tekst powitalny
	var/you_are_text = "Jesteś pająkiem."
	var/flavour_text = "Dla roju! Wybierz pająka i wypełnij swoją rolę w przejęciu statku... o ile to zgodne z twoimi rozkazami."
	var/important_text = "Wypełniaj rozkazy za wszelką cenę."
	/// Czy jakiś duch właśnie wybiera
	var/hatching = FALSE

/obj/structure/spider/eggcluster/Initialize(mapload)
	pixel_x = base_pixel_x + rand(-3, 3)
	pixel_y = base_pixel_y + rand(-3, 3)
	. = ..()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src

/obj/structure/spider/eggcluster/Destroy()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	return ..()

/obj/structure/spider/eggcluster/process(delta_time)
	amount_grown += rand(5, 15) * delta_time
	if(amount_grown < 100 || ready)
		return
	ready = TRUE
	notify_ghosts("[src] jest gotowe do wyklucia!", source = src, action = NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_SPIDER, header = "Pajęcza plaga")
	return PROCESS_KILL

/obj/structure/spider/eggcluster/examine(mob/user)
	. = ..()
	if(!isobserver(user) && !isspider(user))
		return
	switch(amount_grown)
		if(0 to 24)
			. += span_info("Jaja wyglądają na skurczone i uśpione.")
		if(25 to 49)
			. += span_info("Jaja zaczęły się ruszać, pulsują...")
		if(50 to 74)
			. += span_info("Jaja falują, pod skorupką budzi się niewidoczne życie.")
		if(75 to 99)
			. += span_info("Jaja pęcznieją od życia. Zaraz pękną.")
		else
			. += span_info("Jaja są pękate i tętnią życiem. Lada chwila...")

/obj/structure/spider/eggcluster/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	INVOKE_ASYNC(src, PROC_REF(try_hatch), user)

/obj/structure/spider/eggcluster/proc/try_hatch(mob/dead/observer/user)
	if(!istype(user) || !SSticker.HasRoundStarted())
		return
	if(!ready)
		to_chat(user, span_warning("[src] nie jest jeszcze gotowe do wyklucia!"))
		return
	if(hatching)
		to_chat(user, span_warning("Ktoś już wykluwa się z [src]!"))
		return
	if(!user.client?.can_take_ghost_spawner(ROLE_ALIEN, TRUE, FALSE, flags_1 & ADMIN_SPAWNED_1))
		return
	if(is_banned_from(user.key, ROLE_ALIEN))
		to_chat(user, span_warning("Masz bana na tę rolę!"))
		return
	hatching = TRUE
	var/chosen_spider = length(potentialspawns) > 1 ? get_radial_choice(user) : potentialspawns[1]
	hatching = FALSE
	if(isnull(chosen_spider) || QDELETED(src) || QDELETED(user) || !user.client || !ready)
		return
	hatch(chosen_spider, user)

/// Menu z opisami pająków dorosłych, w które wyrośnie dany pajączek
/obj/structure/spider/eggcluster/proc/get_radial_choice(mob/user)
	var/list/spider_list = list()
	var/list/display_spiders = list()
	for(var/choice in potentialspawns)
		var/mob/living/simple_animal/hostile/spider/growing/spiderling/chosen_spiderling = choice
		var/mob/living/simple_animal/hostile/spider/growing/young/young_spider = initial(chosen_spiderling.grow_as)
		var/mob/living/simple_animal/hostile/spider/giant/spider = initial(young_spider.grow_as)
		spider_list[initial(spider.name)] = chosen_spiderling

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = initial(spider.icon), icon_state = initial(spider.icon_state))
		var/datum/reagent/spider_poison = initial(spider.poison_type)
		var/spider_description = initial(spider.menu_description)
		if(initial(spider.poison_per_bite))
			spider_description += " Wstrzykuje [initial(spider.poison_per_bite)]u [initial(spider_poison.name)] na ugryzienie."
		option.info = span_boldnotice(spider_description)
		display_spiders[initial(spider.name)] = option
	sortList(display_spiders)
	var/chosen = show_radial_menu(user, src, display_spiders, radius = 38, tooltips = TRUE)
	return spider_list[chosen]

/// Wykluwa pająka i daje go duchowi
/obj/structure/spider/eggcluster/proc/hatch(spider_type, mob/dead/observer/user)
	var/mob/living/simple_animal/hostile/spider/new_spider = new spider_type(get_turf(src))
	new_spider.faction = faction.Copy()
	new_spider.directive = directive
	new_spider.key = user.key
	log_game("[key_name(new_spider)] hatched as [new_spider] from [src] at [AREACOORD(src)].")
	var/output_message = "<span class='big bold'>[you_are_text]</span>"
	if(flavour_text)
		output_message += "\n<span class='bold'>[flavour_text]</span>"
	if(important_text)
		output_message += "\n<span class='userdanger'>[important_text]</span>"
	to_chat(new_spider, output_message)
	give_antag_datum(new_spider)
	qdel(src)

/obj/structure/spider/eggcluster/proc/give_antag_datum(mob/living/new_spider)
	if(!new_spider.mind)
		return
	new_spider.mind.assigned_role = ROLE_SPIDER
	new_spider.mind.special_role = ROLE_SPIDER
	var/datum/antagonist/spider/spider_antag = new(directive)
	new_spider.mind.add_antag_datum(spider_antag)

/obj/structure/spider/eggcluster/abnormal
	name = "nietypowe gniazdo jaj"
	color = rgb(0, 148, 211)
	potentialspawns = list(
		/mob/living/simple_animal/hostile/spider/growing/spiderling/tank,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/viper,
	)

/obj/structure/spider/eggcluster/enriched
	name = "wzbogacone gniazdo jaj"
	color = rgb(148, 0, 211)
	you_are_text = "Jesteś wzbogaconym pająkiem."
	potentialspawns = list(
		/mob/living/simple_animal/hostile/spider/growing/spiderling/tarantula,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/breacher,
		/mob/living/simple_animal/hostile/spider/growing/spiderling/midwife,
	)

/// Gniazdo z eventu: zawsze matka, żeby plaga nie skończyła się od razu przez pechowy wybór
/obj/structure/spider/eggcluster/midwife
	name = "gniazdo jaj matki"
	you_are_text = "Jesteś pająkiem matką."
	flavour_text = "Serce pajęczej hordy. Składasz jaja, z których wyklują się kolejne pająki, a z wyssanych ofiar robisz jaja rzadkich pająków."
	directive = "Zapewnij przetrwanie gatunku i przejmij konstrukcję, na której się znajdujesz."
	potentialspawns = list(
		/mob/living/simple_animal/hostile/spider/growing/spiderling/midwife,
	)

#undef SPIDER_WEB_TINT
#undef WEB_JUNCTION_N
#undef WEB_JUNCTION_S
#undef WEB_JUNCTION_E
#undef WEB_JUNCTION_W
#undef WEB_JUNCTION_NE
#undef WEB_JUNCTION_SE
#undef WEB_JUNCTION_SW
#undef WEB_JUNCTION_NW
