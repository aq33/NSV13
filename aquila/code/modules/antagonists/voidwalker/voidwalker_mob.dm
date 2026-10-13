// AQUILA - wędrowiec pustki (port z tgstation, code/modules/antagonists/voidwalker)
// U tg to basic mob z komponentami; tu simple_animal z tą samą logiką w środku.

/// Najsłabsza ściana (hardness), którą da się zamienić w okno pustki. Niższa liczba = twardsza ściana
#define VOIDWALKER_WALL_CONVERT_STRENGTH 40
/// Ile trwa ukrycie po walce, zanim znów zniknie w kosmosie
#define VOIDWALKER_REVEAL_TIME (5 SECONDS)
/// Jak długo przepuszczone okno zostaje miękkie dla innych
#define VOIDWALKER_DEFORM_GLASS_TIME (5 SECONDS)

/mob/living/simple_animal/hostile/voidwalker
	name = "voidwalker"
	real_name = "wędrowiec pustki"
	desc = "Szklista istota z pustki między gwiazdami. Lepiej się w nią nie wpatrywać."
	icon = 'aquila/icons/mob/voidwalker.dmi'
	icon_state = "voidwalker"
	icon_living = "voidwalker"
	mob_biotypes = list(MOB_INORGANIC, MOB_SPIRIT)
	maxHealth = 150
	health = 150
	damage_coeff = list(BRUTE = 1, BURN = 0.66, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 0)
	pressure_resistance = 200
	combat_mode = TRUE
	obj_damage = 15
	melee_damage = 14
	melee_damage_type = OXY
	attack_sound = 'aquila/sound/voidwalker/shrink_hit.ogg'
	attacktext = "wysysa oddech z"
	friendly = "obejmuje"
	response_help = "dotyka"
	response_disarm = "odpycha"
	response_harm = "uderza"
	speak_emote = list("dźwięczy")
	faction = list("carp")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	healable = FALSE
	del_on_death = TRUE
	deathmessage = "rozpryskuje się na tysiąc odłamków!"
	speed = 0
	movement_type = FLYING
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	dextrous = TRUE
	held_items = list(null, null)
	AIStatus = AI_OFF
	can_have_ai = FALSE
	wander = FALSE
	stop_automated_movement = TRUE
	sight = SEE_TURFS | SEE_MOBS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	move_resist = MOVE_FORCE_STRONG
	discovery_points = 3000

	/// Ile trwa porwanie
	var/kidnap_time = 6 SECONDS
	/// Czy właśnie kogoś porywamy
	var/kidnapping = FALSE
	/// Ile ścian możemy jeszcze zamienić w okna. Każde porwanie dokłada jedną
	var/conversions_remaining = 2
	/// Odstęp między zamianami ścian
	COOLDOWN_DECLARE(wall_conversion)
	/// Pole, na którym działa leczenie, kamuflaż, nurkowanie i porwania
	var/home_turf = /turf/open/space
	/// Plama, na której też można porywać i z której można się wynurzyć
	var/kidnapping_decal = /obj/effect/decal/cleanable/vomit/nebula

	/// Czy jesteśmy teraz niewidzialni w kosmosie
	var/camouflaged = FALSE
	/// Gracz wyłączył kamuflaż przyciskiem
	var/camo_disabled = FALSE
	/// Do kiedy kamuflaż jest zablokowany po walce
	var/reveal_until = 0
	/// Półprzezroczysty obraz siebie, który widzimy tylko my, gdy jesteśmy niewidzialni
	var/image/self_image

	var/obj/effect/proc_holder/spell/pointed/unsettle/unsettle
	var/obj/effect/proc_holder/spell/pointed/voidwalker_dash/dash
	var/obj/effect/proc_holder/spell/targeted/telepathy/voidwalker/telepathy
	var/datum/action/innate/voidwalker_camo/camo_action
	var/datum/action/innate/voidwalker_vomit_jump/vomit_jump
	var/datum/action/innate/voidwalker_floor/floor_up
	var/datum/action/innate/voidwalker_floor/down/floor_down
	/// Radio, które ich tu przywabiło. Słyszą przez nie wszystkie kanały
	var/obj/item/radio/internal_radio

/mob/living/simple_animal/hostile/voidwalker/Initialize(mapload)
	. = ..()
	status_flags &= ~CANSTUN
	ADD_TRAIT(src, TRAIT_MUTE, INNATE_TRAIT)
	fully_replace_character_name(null, pick(GLOB.voidwalker_names))

	unsettle = new
	AddSpell(unsettle)
	dash = new
	AddSpell(dash)
	telepathy = new
	AddSpell(telepathy)
	camo_action = new(src)
	camo_action.Grant(src)
	vomit_jump = new(src)
	vomit_jump.Grant(src)
	floor_up = new(src)
	floor_up.Grant(src)
	floor_down = new(src)
	floor_down.Grant(src)

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/heads/captain
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0 // większy zasięg i słyszeliby to ludzie obok
	internal_radio.recalculateChannels()

	self_image = image(icon, src, "[icon_state]_stealthed", ABOVE_LIGHTING_LAYER)
	self_image.plane = ABOVE_LIGHTING_PLANE
	self_image.appearance_flags |= RESET_ALPHA
	self_image.alpha = 0

	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_shocked_grille))
	update_camo()

/mob/living/simple_animal/hostile/voidwalker/Destroy()
	unsettle = null
	dash = null
	telepathy = null
	QDEL_NULL(camo_action)
	QDEL_NULL(vomit_jump)
	QDEL_NULL(floor_up)
	QDEL_NULL(floor_down)
	QDEL_NULL(internal_radio)
	client?.images -= self_image
	self_image = null
	return ..()

/mob/living/simple_animal/hostile/voidwalker/Login()
	. = ..()
	client.images |= self_image

/mob/living/simple_animal/hostile/voidwalker/Logout()
	client?.images -= self_image
	return ..()

/mob/living/simple_animal/hostile/voidwalker/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/voidwalker/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	// Leczy się tylko w swoim żywiole
	if(is_home_turf(get_turf(src)) && (getBruteLoss() || getFireLoss()))
		adjustBruteLoss(-4)
		adjustFireLoss(-4)
	update_camo()

/mob/living/simple_animal/hostile/voidwalker/death(gibbed)
	var/turf/spawn_loc = get_turf(src)
	new /obj/effect/spawner/lootdrop/voidwalker_shards(spawn_loc)
	new /obj/item/clothing/head/helmet/skull/cosmic(spawn_loc)
	playsound(spawn_loc, "shatter", 100)
	return ..()

/mob/living/simple_animal/hostile/voidwalker/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		reveal()

/mob/living/simple_animal/hostile/voidwalker/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	// Mocne ciosy wybijają z niego szkło
	if(amount > 20 && !QDELETED(src))
		new /obj/effect/spawner/lootdrop/voidwalker_shards/mini(get_turf(src))
		playsound(src, "shatter", 60)

/mob/living/simple_animal/hostile/voidwalker/Moved(atom/OldLoc, Dir)
	. = ..()
	update_camo()
	if(isturf(OldLoc))
		deform_glass(OldLoc)

/// Zostawione za sobą okna przez chwilę przepuszczają też innych, ale nie powietrze
/mob/living/simple_animal/hostile/voidwalker/proc/deform_glass(turf/old_turf)
	for(var/obj/structure/structure in old_turf)
		if(!structure.density || !(istype(structure, /obj/structure/window) || istype(structure, /obj/structure/grille)))
			continue
		if(istype(structure, /obj/structure/window))
			var/obj/structure/window/window = structure
			window.void_deformed = TRUE
		structure.density = FALSE
		apply_wibbly_filters(structure)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(voidwalker_undeform_glass), structure), VOIDWALKER_DEFORM_GLASS_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

/proc/voidwalker_undeform_glass(obj/structure/structure)
	if(QDELETED(structure))
		return
	if(istype(structure, /obj/structure/grille))
		var/obj/structure/grille/grille = structure
		structure.density = !grille.broken
	else
		var/obj/structure/window/window = structure
		window.void_deformed = FALSE
		structure.density = initial(structure.density)
	remove_wibbly_filters(structure)

/obj/structure/window
	/// Wędrowiec pustki przeszedł przez okno: przepuszcza ludzi, ale wciąż trzyma powietrze
	var/void_deformed = FALSE

/obj/structure/window/CanAtmosPass(turf/T)
	if(void_deformed && anchored)
		return !(FULLTILE_WINDOW_DIR == dir || dir == get_dir(loc, T))
	return ..()

/// Krata pod prądem nie przepuszcza
/mob/living/simple_animal/hostile/voidwalker/proc/check_shocked_grille(datum/source, atom/newloc)
	SIGNAL_HANDLER
	if(!isturf(newloc))
		return
	for(var/obj/structure/grille/grille in newloc)
		if(voidwalker_grille_shocked(grille))
			grille.balloon_alert(src, "pod prądem!")
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/proc/voidwalker_grille_shocked(obj/structure/grille/grille)
	if(!grille.anchored || grille.broken)
		return FALSE
	var/turf/T = get_turf(grille)
	var/obj/structure/cable/cable = T?.get_cable_node()
	return cable?.powernet?.avail > 0

///
/// Kamuflaż
///

/mob/living/simple_animal/hostile/voidwalker/proc/update_camo()
	var/should_hide = !camo_disabled && reveal_until <= world.time && is_home_turf(get_turf(src))
	if(should_hide == camouflaged)
		return
	camouflaged = should_hide
	if(camouflaged)
		animate(src, alpha = 0, time = 0.5 SECONDS)
		animate(self_image, alpha = 120, time = 0.5 SECONDS)
		remove_from_all_data_huds()
	else
		animate(src, alpha = 255, time = 0.5 SECONDS)
		animate(self_image, alpha = 0, time = 0.5 SECONDS)
		add_to_all_human_data_huds()

/// Walka wyciąga nas z kamuflażu na chwilę
/mob/living/simple_animal/hostile/voidwalker/proc/reveal()
	reveal_until = world.time + VOIDWALKER_REVEAL_TIME
	update_camo()
	addtimer(CALLBACK(src, PROC_REF(update_camo)), VOIDWALKER_REVEAL_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

///
/// Atak, porwania, ściany
///

/mob/living/simple_animal/hostile/voidwalker/UnarmedAttack(atom/target, proximity, list/modifiers)
	// Okna kochamy
	if(istype(target, /obj/structure/window))
		visible_message("<span class='notice'>[src] łasi się do [target]!</span>")
		new /obj/effect/temp_visual/heart(target.loc)
		return FALSE
	// Do mgławicowych wymiocin można zanurkować
	if(istype(target, kidnapping_decal))
		INVOKE_ASYNC(src, PROC_REF(try_dive_into_decal), target)
		return FALSE

	if(ishuman(target) && !get_active_held_item())
		var/mob/living/carbon/human/victim = target
		var/should_attack = try_kidnap(victim)
		// Ofiara nie umrze, dopóki ją męczymy
		victim.apply_status_effect(/datum/status_effect/void_chomped)
		if(!should_attack)
			return FALSE
		if(victim.InFullCritical() && !victim.has_trauma_type(/datum/brain_trauma/voided))
			victim.balloon_alert(src, "w stanie krytycznym!")
			victim.Stun(5 SECONDS)
			return FALSE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		// Prawy klik: zwykłe obrażenia albo otwieranie ściany
		melee_damage_type = BRUTE
		if(istype(target, /turf/closed/wall))
			INVOKE_ASYNC(src, PROC_REF(try_convert_wall), target)
			return FALSE
	else
		melee_damage_type = ishuman(target) ? initial(melee_damage_type) : BRUTE

	. = ..()
	if(isliving(target))
		reveal()

/// Zwraca TRUE, jeśli zamiast porywać trzeba dalej bić
/mob/living/simple_animal/hostile/voidwalker/proc/try_kidnap(mob/living/carbon/human/victim)
	if(victim.has_trauma_type(/datum/brain_trauma/voided))
		victim.balloon_alert(src, "już oświecony!")
		new /obj/effect/temp_visual/voidwalker_wave(get_turf(victim))
		victim.SetSleeping(30 SECONDS)
		return FALSE
	if(victim.stat == DEAD)
		victim.balloon_alert(src, "martwy!")
		return FALSE
	if(victim.stat == CONSCIOUS) // jeszcze się broni
		return TRUE
	if(!is_home_turf(get_turf(victim)) && !(locate(kidnapping_decal) in get_turf(victim)))
		victim.balloon_alert(src, "nie w kosmosie!")
		return FALSE
	if(!kidnapping)
		INVOKE_ASYNC(src, PROC_REF(kidnap), victim)
	return FALSE

/mob/living/simple_animal/hostile/voidwalker/proc/kidnap(mob/living/carbon/human/victim)
	victim.Paralyze(kidnap_time) // żeby nie wstał, jeśli już go mamy
	victim.add_filter("voidwalker_kidnap", 3, list(type = "wave", x = 2, size = 4))
	animate(victim.get_filter("voidwalker_kidnap"), offset = 32, time = kidnap_time)
	kidnapping = TRUE
	if(do_after(src, kidnap_time, FALSE, victim, TRUE, CALLBACK(src, PROC_REF(check_incapacitated), victim)))
		take_them(victim)
	victim.remove_filter("voidwalker_kidnap")
	kidnapping = FALSE

/mob/living/simple_animal/hostile/voidwalker/proc/check_incapacitated(mob/living/carbon/human/victim)
	return victim.stat != CONSCIOUS || victim.incapacitated()

/// Wziął cię
/mob/living/simple_animal/hostile/voidwalker/proc/take_them(mob/living/carbon/human/victim)
	victim.gain_trauma(/datum/brain_trauma/voided)
	victim.flash_act(INFINITY, TRUE, FALSE, TRUE)
	new /obj/effect/temp_visual/voidwalker_wave(get_turf(victim))
	conversions_remaining++
	log_combat(src, victim, "kidnapped into the void")

	var/turf/void_turf = get_voidwalker_void_turf()
	if(!void_turf)
		victim.forceMove(get_random_station_turf())
		victim.heal_overall_damage(80, 20)
		stack_trace("[victim] was instantly dumped after being voidwalker kidnapped, the void could not be created!")
		return
	victim.heal_and_revive(90)
	victim.adjustOxyLoss(-100, FALSE)
	victim.updatehealth()
	var/obj/effect/wisp_mobile/wisp = new(void_turf)
	victim.forceMove(wisp)

/// Zamienia ścianę i ściany obok w okna pustki
/mob/living/simple_animal/hostile/voidwalker/proc/try_convert_wall(turf/closed/wall/our_wall)
	if(!conversions_remaining)
		balloon_alert(src, "potrzeba więcej porwań!")
		return
	if(!COOLDOWN_FINISHED(src, wall_conversion))
		balloon_alert(src, "poczekaj jeszcze [DisplayTimeText(COOLDOWN_TIMELEFT(src, wall_conversion))]!")
		return
	if(!check_wall_validity(our_wall, silent = FALSE))
		return
	playsound(our_wall, 'sound/magic/blind.ogg', 100, TRUE)
	new /obj/effect/temp_visual/transmute_tile_flash(our_wall)
	var/obj/effect/abstract/voidwalker_particles/particles = new(our_wall, /particles/void_wall)
	balloon_alert(src, "otwieranie okna...")
	var/success = do_after(src, 8 SECONDS, FALSE, our_wall)
	qdel(particles)
	if(!success || !conversions_remaining || !istype(our_wall, /turf/closed/wall))
		return

	var/list/target_walls = list(our_wall)
	for(var/turf/closed/wall/adjacent_wall in orange(1, our_wall))
		if(check_wall_validity(adjacent_wall))
			target_walls += adjacent_wall
	playsound(our_wall, 'sound/magic/blind.ogg', 100, TRUE)
	for(var/turf/closed/wall/targeted_wall as anything in target_walls)
		new /obj/effect/temp_visual/transmute_tile_flash(targeted_wall)
		var/turf/new_turf = targeted_wall.ScrapeAway()
		new /obj/structure/grille(new_turf)
		new /obj/structure/window/fulltile/voidwalker(new_turf)
	conversions_remaining--
	COOLDOWN_START(src, wall_conversion, 60 SECONDS)
	log_game("[key_name(src)] converted [length(target_walls)] walls into void windows at [AREACOORD(our_wall)]")

/mob/living/simple_animal/hostile/voidwalker/proc/check_wall_validity(turf/closed/wall/wall_to_check, silent = TRUE)
	if(wall_to_check.hardness < VOIDWALKER_WALL_CONVERT_STRENGTH)
		if(!silent)
			balloon_alert(src, "za mocna!")
		return FALSE
	return TRUE

///
/// Ręce: tylko podnosić i upuszczać
///

/mob/living/simple_animal/hostile/voidwalker/ClickOn(atom/A, params)
	var/obj/item/held = get_active_held_item()
	// Celowanie zdolnością (zryw, niepokój) musi przejść mimo przedmiotu w ręce
	if(held && !throw_mode && !istype(A, /atom/movable/screen) && !ranged_ability && !click_intercept && !client?.click_intercept)
		var/list/modifiers = params2list(params)
		if(!LAZYACCESS(modifiers, SHIFT_CLICK) && !LAZYACCESS(modifiers, ALT_CLICK) && !LAZYACCESS(modifiers, CTRL_CLICK) && !LAZYACCESS(modifiers, MIDDLE_CLICK))
			if(world.time > next_click)
				next_click = world.time + 1
				balloon_alert(src, "umiesz tylko nosić!")
			return
	return ..()

/mob/living/simple_animal/hostile/voidwalker/mode()
	if(get_active_held_item())
		balloon_alert(src, "umiesz tylko nosić!")
		return
	return ..()

/// Czy pole to nasz żywioł. U nas wyższe pokłady statków otacza otwarta przestrzeń bez powietrza zamiast zwykłego kosmosu
/mob/living/simple_animal/hostile/voidwalker/proc/is_home_turf(turf/T)
	if(!T)
		return FALSE
	if(istype(T, home_turf))
		return TRUE
	return ispath(home_turf, /turf/open/space) && istype(T, /turf/open/openspace/airless)

/// Admin zmieniający home_turf zmienia też wszystko, co od niego zależy
/mob/living/simple_animal/hostile/voidwalker/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, home_turf))
		update_camo()

#undef VOIDWALKER_WALL_CONVERT_STRENGTH
#undef VOIDWALKER_REVEAL_TIME
#undef VOIDWALKER_DEFORM_GLASS_TIME
