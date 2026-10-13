// AQUILA - darkspawn: Pełzające cienie i Potomek

/mob/living/simple_animal/hostile/crawling_shadows
	name = "crawling shadows"
	real_name = "pełzające cienie"
	desc = "Bezkształtna masa czerni z dwiema wielkimi, szponiastymi dłońmi i przeszywającymi białymi oczami."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_effects.dmi'
	icon_state = "blank_dspawn"
	icon_living = "blank_dspawn"
	response_help = "odsuwa się od"
	response_disarm = "odpycha"
	response_harm = "macha na"
	speed = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	maxHealth = 125
	health = 125
	obj_damage = 50
	melee_damage = 5 // ma wbudowane ogłuszenie; jak chcesz kogoś zabić, zrób to jak należy
	attacktext = "drapie"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("szepcze")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	movement_type = FLYING
	pressure_resistance = INFINITY
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
	deathmessage = "drży, traci kształt i się rozpływa!"
	deathsound = 'aquila/sound/darkspawn/devour_will_victim.ogg'
	stop_automated_movement = TRUE
	/// Do upiornych dźwięków kroków
	var/move_count = 0
	var/knocking_out = FALSE
	var/mob/living/darkspawn_mob
	var/returned = FALSE

/// Wkłada ciało darkspawna do środka i przenosi umysł
/mob/living/simple_animal/hostile/crawling_shadows/proc/check_darkspawn()
	if(!darkspawn_mob?.mind)
		qdel(src)
		return
	darkspawn_mob.forceMove(src)
	darkspawn_mob.status_flags |= GODMODE
	darkspawn_mob.mind.transfer_to(src)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(src)
	darkspawn?.regain_abilities()
	to_chat(src, "<span class='warning'>Potrwa to około minuty.</span>")
	var/datum/action/innate/end_crawling_shadows/end_action = new
	end_action.Grant(src)
	addtimer(CALLBACK(src, PROC_REF(return_to_body)), 1 MINUTES)

/mob/living/simple_animal/hostile/crawling_shadows/proc/return_to_body()
	if(QDELETED(src))
		return
	if(!returned && darkspawn_mob && !QDELETED(darkspawn_mob))
		visible_message("<span class='warning'>[src] przybiera postać humanoidalną!</span>", "<span class='warning'>Wracasz do swojej zwykłej postaci.</span>")
		playsound(src, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	release_body()
	qdel(src)

/// Wypuszcza ciało darkspawna i oddaje mu umysł oraz przyciski zdolności
/mob/living/simple_animal/hostile/crawling_shadows/proc/release_body()
	if(returned)
		return
	returned = TRUE
	if(!darkspawn_mob || QDELETED(darkspawn_mob))
		return
	darkspawn_mob.forceMove(get_turf(src))
	darkspawn_mob.status_flags &= ~GODMODE
	if(!mind)
		return
	var/datum/mind/our_mind = mind
	our_mind.transfer_to(darkspawn_mob)
	var/datum/antagonist/darkspawn/darkspawn = our_mind.has_antag_datum(/datum/antagonist/darkspawn)
	darkspawn?.regain_abilities()

/mob/living/simple_animal/hostile/crawling_shadows/Destroy()
	release_body()
	darkspawn_mob = null
	return ..()

/mob/living/simple_animal/hostile/crawling_shadows/death(gibbed)
	release_body()
	return ..()

/mob/living/simple_animal/hostile/crawling_shadows/Moved(atom/OldLoc, Dir)
	. = ..()
	move_count++
	if(move_count >= 5)
		playsound(src, pick('aquila/sound/darkspawn/crawling_shadows_walk_01.ogg', 'aquila/sound/darkspawn/crawling_shadows_walk_02.ogg', 'aquila/sound/darkspawn/crawling_shadows_walk_03.ogg'), 25, FALSE)
		move_count = 0

/mob/living/simple_animal/hostile/crawling_shadows/Life()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/lums = T.get_lumcount()
	if(lums < DARKSPAWN_BRIGHT_LIGHT)
		invisibility = INVISIBILITY_OBSERVER // w pełnej ciemności niewidoczny
		set_varspeed(-1)
		alpha = 255
	else
		invisibility = initial(invisibility)
		set_varspeed(0)
		alpha = min(lums * 60, 255) // w jaśniejszym świetle coraz lepiej widoczny

/mob/living/simple_animal/hostile/crawling_shadows/AttackingTarget()
	if(ishuman(target) && !knocking_out)
		var/mob/living/carbon/human/H = target
		if(H.stat)
			return ..()
		knocking_out = TRUE
		visible_message("<span class='warning'>[src] podnosi [H] i trzyma w powietrzu!</span>", "<span class='notice'>Wyrywasz [H] z ziemi...</span>")
		to_chat(H, "<span class='userdanger'>[src] chwyta cię i trzyma w powietrzu!</span>")
		H.Stun(3 SECONDS)
		H.pixel_y += 4
		if(!do_after(src, 1 SECONDS, target = H))
			H.pixel_y -= 4
			knocking_out = FALSE
			return
		visible_message("<span class='warning'>[src] delikatnie przyciska dłoń do twarzy [H], a ten wiotczeje...</span>", "<span class='notice'>Po cichu obezwładniasz [H].</span>")
		H.pixel_y -= 4
		to_chat(H, "<span class='userdanger'>[src] przyciska dłoń do twojej twarzy i ogarnia cię uległość...</span>")
		H.Paralyze(6 SECONDS)
		knocking_out = FALSE
		return TRUE
	if(istype(target, /obj/machinery/door))
		forceMove(get_turf(target))
		visible_message("<span class='warning'>Cienie przesączają się przez [target]...</span>", "<span class='notice'>Prześlizgujesz się przez [target].</span>")
		return
	return ..()

/datum/action/innate/end_crawling_shadows
	name = "Koniec Pełzających cieni"
	desc = "Wracasz do postaci humanoidalnej."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "crawling_shadows"
	background_icon_state = "bg_alien"

/datum/action/innate/end_crawling_shadows/Activate()
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = owner
	if(istype(shadows))
		shadows.return_to_body()

/// Potomek po Sakramencie
/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "cosmic progenitor"
	real_name = "kosmiczny potomek"
	desc = "..."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health = INFINITY
	maxHealth = INFINITY
	attacktext = "rozrywa"
	attack_sound = 'aquila/sound/darkspawn/progenitor_attack.ogg'
	friendly = "patrzy z góry na"
	speak_emote = list("ryczy")
	armour_penetration = 100
	melee_damage = 40
	move_to_delay = 10
	speed = 1
	pixel_x = -48
	pixel_y = -32
	base_pixel_x = -48
	base_pixel_y = -32
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 100
	light_range = 15
	light_color = "#21007F"
	weather_immunities = list("lava", "ash")
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	movement_type = FLYING
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	stop_automated_movement = TRUE
	faction = list(ROLE_DARKSPAWN)
	var/time_to_next_roar = 0

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_HOLY, "darkspawn_progenitor") // magia na niego nie działa
	alpha = 0
	animate(src, alpha = 255, time = 1 SECONDS)
	var/obj/item/radio/headset/silicon/ai/radio = new(src) // słyszy krzyki przez radio
	radio.wires.cut(WIRE_TX) // ale nie mówi przez nie
	var/datum/action/innate/progenitor_curse/curse = new
	curse.Grant(src)

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'aquila/sound/darkspawn/pass_smash_door.ogg', 100, FALSE)
	return ..()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	. = ..()
	var/image/I = image(icon = 'aquila/icons/mob/darkspawn/smol_progenitor.dmi', icon_state = "smol_progenitor", loc = src)
	I.override = TRUE
	I.pixel_x -= pixel_x
	I.pixel_y -= pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)
	time_to_next_roar = world.time + 30 SECONDS

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life()
	. = ..()
	if(time_to_next_roar + 10 SECONDS <= world.time) // daje czas na ręczny ryk
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	. = ..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'aquila/sound/darkspawn/progenitor_roar.ogg', 50, TRUE)
	for(var/mob/M as anything in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'aquila/sound/darkspawn/progenitor_distant.ogg', 25, FALSE, falloff_exponent = 5)
		else if(isliving(M) && M != src)
			var/mob/living/L = M
			to_chat(L, "<span class='boldannounce'>Stoisz sparaliżowany w cieniu chłodu, który zstępuje z wysoka.</span>")
			L.Stun(2 SECONDS)
	time_to_next_roar = world.time + 30 SECONDS

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act(severity, target)
	return

/datum/action/innate/progenitor_curse
	name = "Rozszarpanie umysłu"
	desc = "Uderzasz potężną psioniczną nawałnicą w umysł wybranej istoty."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "veil_mind"
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(curse_cooldown)

/datum/action/innate/progenitor_curse/IsAvailable()
	return ..() && COOLDOWN_FINISHED(src, curse_cooldown)

/datum/action/innate/progenitor_curse/Activate()
	var/list/targets = list()
	for(var/mob/living/L in view(7, owner))
		if(L != owner && L.stat != DEAD && !is_darkspawn_or_veil(L))
			targets += L
	if(!length(targets))
		to_chat(owner, "<span class='warning'>Nie ma nikogo w zasięgu wzroku.</span>")
		return
	var/mob/living/target = input(owner, "Czyj umysł rozszarpać?", name) as null|anything in targets
	if(!target || !(target in view(7, owner)) || !COOLDOWN_FINISHED(src, curse_cooldown))
		return
	COOLDOWN_START(src, curse_cooldown, 5 SECONDS)
	owner.visible_message("<span class='warning'>Sigile [owner] rozbłyskują, gdy spogląda na [target]!</span>", \
		"<span class='velvet'>Kierujesz [pick(0.1, 0.5, 1)]% swojej psionicznej mocy w umysł [target]!</span>")
	target.apply_status_effect(/datum/status_effect/progenitor_curse)
