// AQUILA - moce wędrowca pustki (port z tgstation)

/datum/action/spell_action/spell/voidwalker
	button_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'

///
/// Niepokój: wpatruj się w kogoś, kto cię widzi, a padnie
///

/obj/effect/proc_holder/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Wpatruj się w ofiarę, która cię widzi. Jeśli przez kilka sekund nie straci cię z oczu, padnie oszołomiona i wyczerpana, ale dowie się, że tu jesteś."
	action_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	action_icon_state = "unsettle"
	action_background_icon_state = "bg_void"
	base_action = /datum/action/spell_action/spell/voidwalker
	base_icon_state = "unsettle"
	clothes_req = FALSE
	charge_max = 12 SECONDS
	range = 9
	active_msg = "Szykujesz się, by wpatrzyć się w ofiarę..."
	deactive_msg = "Odwracasz wzrok..."
	/// Jak długo trzeba się wpatrywać
	var/stare_time = 6 SECONDS
	/// Na ile powala
	var/stun_time = 2 SECONDS
	/// Ile wyczerpania zadaje
	var/stamina_damage = 80

/obj/effect/proc_holder/spell/pointed/unsettle/update_icon()
	if(!action)
		return
	action.button_icon_state = base_icon_state
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pointed/unsettle/can_target(atom/target, mob/user, silent)
	if(!isliving(target) || target == user)
		if(!silent)
			target.balloon_alert(user, "nie da się!")
		return FALSE
	if(get_dist(user, target) > range)
		if(!silent)
			target.balloon_alert(user, "za daleko!")
		return FALSE
	if(!check_if_staring(target, user))
		if(!silent)
			user.balloon_alert(user, "nie widzi cię!")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/unsettle/cast(list/targets, mob/living/user)
	var/mob/living/target = targets[1]
	if(!istype(target))
		revert_cast(user)
		return
	var/datum/progressbar/bar = new(user, stare_time, target)
	var/start = world.time
	var/success = TRUE
	while(world.time < start + stare_time)
		stoplag(1)
		bar.update(world.time - start)
		if(QDELETED(user) || QDELETED(target) || user.stat || !check_if_staring(target, user))
			success = FALSE
			break
	qdel(bar)
	if(!success)
		if(!QDELETED(user))
			user.balloon_alert(user, "stracono kontakt wzrokowy!")
			revert_cast(user)
		return
	spookify(target, user)

/// Czy ofiara nas widzi. Niewidzialność w kosmosie nie przeszkadza, liczy się linia wzroku
/obj/effect/proc_holder/spell/pointed/unsettle/proc/check_if_staring(mob/living/target, mob/living/user)
	if(is_blind(target) || target.stat != CONSCIOUS)
		return FALSE
	return (user in view(world.view, target)) || (istype(user.loc, /obj/effect/dummy) && (user.loc in view(world.view, target)))

/obj/effect/proc_holder/spell/pointed/unsettle/proc/spookify(mob/living/target, mob/living/user)
	target.Paralyze(stun_time)
	target.adjustStaminaLoss(stamina_damage)
	target.slurring = max(target.slurring, 10)
	target.emote("scream")
	to_chat(target, "<span class='userdanger'>Coś wpatruje się w ciebie z pustki!</span>")
	new /obj/effect/temp_visual/voidwalker_wave(get_turf(user))
	new /obj/effect/temp_visual/voidwalker_wave(get_turf(target))
	log_combat(user, target, "unsettled")
	if(istype(user, /mob/living/simple_animal/hostile/voidwalker))
		var/mob/living/simple_animal/hostile/voidwalker/walker = user
		walker.reveal()

///
/// Kosmiczny przekaz
///

/obj/effect/proc_holder/spell/targeted/telepathy/voidwalker
	name = "Cosmic Transmit"
	desc = "Przekaż myśl wprost do czyjegoś umysłu."
	action_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	action_icon_state = "telepathy"
	action_background_icon_state = "bg_void"
	base_action = /datum/action/spell_action/spell/voidwalker
	notice = "purple"
	boldnotice = "purple bold"
	phase_allowed = TRUE

///
/// Kosmiczny zryw
///

/obj/effect/proc_holder/spell/pointed/voidwalker_dash
	name = "Cosmic Dash"
	desc = "Pomknij przez kosmos do wskazanego miejsca, taranując wszystko po drodze. Słaby atak, świetna ucieczka."
	action_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	action_icon_state = "dash"
	action_background_icon_state = "bg_void"
	base_action = /datum/action/spell_action/spell/voidwalker
	base_icon_state = "dash"
	clothes_req = FALSE
	charge_max = 8 SECONDS
	range = 40
	active_msg = "Szykujesz się do zrywu..."
	deactive_msg = "Uspokajasz się..."
	/// Pole, w które musi trafić zryw
	var/valid_target_turf = /turf/open/space
	/// Obrażenia dla każdego staranowanego
	var/charge_damage = 20

/obj/effect/proc_holder/spell/pointed/voidwalker_dash/update_icon()
	if(!action)
		return
	action.button_icon_state = base_icon_state
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/pointed/voidwalker_dash/can_target(atom/target, mob/user, silent)
	var/turf/target_turf = get_turf(target)
	if(!istype(target_turf, valid_target_turf))
		if(!silent)
			user.balloon_alert(user, "musisz celować w kosmos!")
		return FALSE
	if(get_dist(user, target_turf) > range)
		if(!silent)
			user.balloon_alert(user, "za daleko!")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/voidwalker_dash/cast(list/targets, mob/living/user)
	var/turf/target_turf = get_turf(targets[1])
	if(!target_turf || !isturf(user.loc))
		revert_cast(user)
		return
	playsound(user, 'sound/effects/curse1.ogg', 100)
	var/mob/living/simple_animal/hostile/voidwalker/walker = user
	if(istype(walker))
		walker.dashing = TRUE
	user.throw_at(target_turf, range, 2, user, FALSE, callback = CALLBACK(src, PROC_REF(dash_end), user))

/obj/effect/proc_holder/spell/pointed/voidwalker_dash/proc/dash_end(mob/living/user)
	var/mob/living/simple_animal/hostile/voidwalker/walker = user
	if(istype(walker))
		walker.dashing = FALSE

/mob/living/simple_animal/hostile/voidwalker
	/// Czy właśnie mkniemy zrywem
	var/dashing = FALSE

/mob/living/simple_animal/hostile/voidwalker/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!dashing)
		return ..()
	dashing = FALSE
	if(isliving(hit_atom))
		var/mob/living/victim = hit_atom
		victim.visible_message("<span class='danger'>[src] taranuje [victim]!</span>", "<span class='userdanger'>[src] taranuje cię!</span>")
		victim.apply_damage(dash.charge_damage, BRUTE)
		victim.Knockdown(1 SECONDS)
		playsound(victim, 'aquila/sound/voidwalker/shrink_hit.ogg', 50, TRUE)
		log_combat(src, victim, "dashed into")
		reveal()
	return ..()

///
/// Przyciski
///

/datum/action/innate/voidwalker_camo
	name = "Toggle Space Camouflage"
	desc = "Włącz albo wyłącz niewidzialność w kosmosie."
	icon_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	button_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	background_icon_state = "bg_void"
	button_icon_state = "camo_toggle"

/datum/action/innate/voidwalker_camo/Activate()
	var/mob/living/simple_animal/hostile/voidwalker/walker = owner
	if(!istype(walker))
		return
	walker.camo_disabled = !walker.camo_disabled
	button_icon_state = walker.camo_disabled ? "camo_toggle_off" : "camo_toggle"
	UpdateButtonIcon()
	walker.balloon_alert(walker, walker.camo_disabled ? "kamuflaż wyłączony" : "kamuflaż włączony")
	walker.update_camo()

/datum/action/innate/voidwalker_vomit_jump
	name = "Jump To Nebula Vomit"
	desc = "Podczas nurkowania przeskocz do kolejnych mgławicowych wymiocin zostawionych przez oświeconych."
	icon_icon = 'aquila/icons/effects/voidwalker_vomit.dmi'
	button_icon = 'aquila/icons/mob/actions/actions_voidwalker.dmi'
	background_icon_state = "bg_void"
	button_icon_state = "vomitnebula_1"
	/// Żeby kolejne kliknięcia przechodziły po wszystkich plamach
	var/index = 1

/datum/action/innate/voidwalker_vomit_jump/Activate()
	if(!istype(owner.loc, /obj/effect/dummy/phased_mob/voidwalker))
		owner.balloon_alert(owner, "musisz nurkować!")
		return
	var/list/vomits = list()
	for(var/obj/effect/decal/cleanable/vomit/nebula/vomit as anything in GLOB.nebula_vomits)
		if(is_station_level(vomit.z))
			vomits += vomit
	if(!length(vomits))
		owner.balloon_alert(owner, "brak wymiocin!")
		return
	index = (index % length(vomits)) + 1
	var/atom/movable/holder = owner.loc
	holder.forceMove(get_step(vomits[index], pick(GLOB.alldirs)) || get_turf(vomits[index]))
	owner.playsound_local(owner, 'sound/effects/phasein.ogg', 50, FALSE)
	to_chat(owner, "<span class='notice'>Mgławicowe wymiociny: [index] z [length(vomits)].</span>")

///
/// Efekty
///

/obj/effect/temp_visual/voidwalker_wave
	icon = 'aquila/icons/effects/voidwalker_wave.dmi'
	icon_state = "circle_wave"
	color = COLOR_PURPLE
	pixel_x = -16
	pixel_y = -16
	duration = 0.5 SECONDS

/obj/effect/temp_visual/voidwalker_wave/Initialize(mapload)
	transform = matrix().Scale(0.1)
	animate(src, transform = matrix().Scale(2), time = duration, flags = ANIMATION_PARALLEL)
	animate(src, alpha = 255, time = duration * 0.6, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = duration * 0.4)
	apply_wibbly_filters(src)
	return ..()

/obj/effect/temp_visual/transmute_tile_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 3

/// Nośnik cząsteczek (tg: /obj/effect/abstract/particle_holder)
/obj/effect/abstract/voidwalker_particles
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/abstract/voidwalker_particles/Initialize(mapload, particle_type)
	. = ..()
	if(particle_type)
		particles = new particle_type

/obj/effect/abstract/voidwalker_particles/Destroy()
	particles = null
	return ..()

/particles/void_wall
	icon = 'aquila/icons/effects/voidwalker_particles.dmi'
	icon_state = list("kidnap_1" = 1, "kidnap_2" = 1, "kidnap_3" = 2)
	width = 100
	height = 300
	count = 1000
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = generator("sphere", 12, 12, NORMAL_RAND)
	drift = generator("sphere", 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.1)
	grow = 0.05

/particles/void_vomit
	icon = 'aquila/icons/effects/voidwalker_particles.dmi'
	icon_state = list("void_1" = 1, "void_2" = 5)
	width = 100
	height = 300
	count = 100
	spawning = 1
	lifespan = 3 SECONDS
	fade = 2 SECONDS
	velocity = list(0, 0.1, 0)
	position = generator("sphere", 6, 6, NORMAL_RAND)
	drift = generator("sphere", 0, 0.05, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.5)
