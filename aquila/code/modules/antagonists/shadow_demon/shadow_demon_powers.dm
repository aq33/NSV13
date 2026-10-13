// AQUILA - moce demona cieni (port z ParadiseSS13)

/// Przyciski mocy demona z jego własnym tłem
/datum/action/spell_action/spell/shadow_demon
	button_icon = 'aquila/icons/mob/actions/actions_shadow_demon.dmi'

// Cień-hak

/obj/effect/proc_holder/spell/aimed/shadow_grapple
	name = "Shadow Grapple"
	desc = "Wystrzel jedną z dłoni. Trafiona osoba zostaje przyciągnięta do ciebie, a trafienie w ścianę przyciąga ciebie do niej. Gasi światła w promieniu dwóch pól od miejsca trafienia."
	school = "evocation"
	charge_max = 10 SECONDS
	cooldown_min = 10 SECONDS
	level_max = 0
	clothes_req = FALSE
	antimagic_allowed = TRUE
	invocation_type = "none"
	sound = null
	projectile_type = /obj/item/projectile/magic/shadow_hand
	active_msg = "Unosisz dłoń pełną demonicznej energii!"
	deactive_msg = "Wchłaniasz energię z powrotem... na razie."
	action_icon = 'aquila/icons/mob/actions/actions_shadow_demon.dmi'
	action_icon_state = "shadow_grapple"
	action_background_icon_state = "shadow_demon_bg"
	base_action = /datum/action/spell_action/spell/shadow_demon

/obj/effect/proc_holder/spell/aimed/shadow_grapple/update_icon()
	return // jedna ikona, bez wariantu aktywnego

/obj/item/projectile/magic/shadow_hand
	name = "shadow hand"
	icon = 'aquila/icons/mob/shadow_demon.dmi'
	icon_state = "shadow_hand"
	hitsound = 'aquila/sound/shadowdemon/shadowattack1.ogg'
	martial_arts_no_deflect = FALSE
	/// Chroni przed podwójnym trafieniem podczas przyciągania
	var/hit = FALSE
	var/datum/beam/chain

/obj/item/projectile/magic/shadow_hand/fire(angle, atom/direct_target)
	if(firer)
		var/mob/living/simple_animal/shadow_demon/demon = firer
		if(istype(demon))
			demon.set_block_shadow_crawl()
		chain = firer.Beam(src, icon_state = "grabber_beam", icon = 'aquila/icons/mob/shadow_demon.dmi', time = INFINITY, maxdistance = INFINITY)
	return ..()

/obj/item/projectile/magic/shadow_hand/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(hit)
		return
	hit = TRUE
	. = ..()
	for(var/atom/extinguish_target in range(2, get_turf(src)))
		extinguish_target.extinguish_light(TRUE)
	if(!firer)
		return
	if(!isliving(target))
		var/turf/destination = get_step(target, get_dir(target, firer))
		if(istype(firer, /mob/living/simple_animal/shadow_demon))
			firer.throw_at(destination, 50, 10, spin = FALSE, callback = CALLBACK(firer, TYPE_PROC_REF(/mob/living/simple_animal/shadow_demon, unblock_shadow_crawl)))
		else
			firer.throw_at(destination, 50, 10, spin = FALSE)
		return
	unblock_demon_crawl()
	var/mob/living/L = target
	if(L.anti_magic_check())
		L.visible_message("<span class='warning'>[src] rozwiewa się w zetknięciu z [L]!</span>")
		return BULLET_ACT_BLOCK
	playsound(L, hitsound, 50, TRUE)
	L.Immobilize(2 SECONDS)
	L.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
	L.throw_at(get_step(firer, get_dir(firer, L)), 50, 10)

/obj/item/projectile/magic/shadow_hand/Destroy()
	if(!hit)
		unblock_demon_crawl()
	if(chain)
		chain.End()
		chain = null
	return ..()

/obj/item/projectile/magic/shadow_hand/proc/unblock_demon_crawl()
	var/mob/living/simple_animal/shadow_demon/demon = firer
	if(istype(demon))
		demon.unblock_shadow_crawl()

// Cienisty pełz

/obj/effect/proc_holder/spell/shadow_crawl
	name = "Shadow Crawl"
	desc = "Wtop się w cienie: poruszasz się szybciej, przenikasz przez ściany i nikt cię nie widzi. Działa tylko w ciemności."
	charge_max = 1 SECONDS
	clothes_req = FALSE
	antimagic_allowed = TRUE
	phase_allowed = TRUE // inaczej nie dałoby się wyjść z cienia
	level_max = 0
	cooldown_min = 1 SECONDS
	overlay = null
	action_icon = 'aquila/icons/mob/actions/actions_shadow_demon.dmi'
	action_icon_state = "shadow_crawl"
	action_background_icon_state = "shadow_demon_bg"
	base_action = /datum/action/spell_action/spell/shadow_demon
	var/phased = FALSE

/obj/effect/proc_holder/spell/shadow_crawl/choose_targets(mob/user = usr)
	var/mob/living/simple_animal/shadow_demon/demon = user
	if(istype(demon) && demon.block_shadow_crawl)
		to_chat(user, "<span class='warning'>Jesteś zbyt skupiony, by użyć [name].</span>")
		return
	var/turf/target = find_dark_turf(user)
	if(!target)
		to_chat(user, "<span class='warning'>Tu nie jest wystarczająco ciemno!</span>")
		return
	perform(list(target), user = user)

/// Ciemne pole pod użytkownikiem albo obok niego. Przy wychodzeniu z cienia pole nie może być zablokowane.
/obj/effect/proc_holder/spell/shadow_crawl/proc/find_dark_turf(mob/user)
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return
	if(is_valid_crawl_turf(user_turf))
		return user_turf
	var/list/candidates = list()
	for(var/turf/T in orange(1, user_turf))
		if(is_valid_crawl_turf(T))
			candidates += T
	if(length(candidates))
		return pick(candidates)

/obj/effect/proc_holder/spell/shadow_crawl/proc/is_valid_crawl_turf(turf/T)
	if(isspaceturf(T) || T.get_lumcount() >= SHADOW_DEMON_LIGHT_THRESHOLD)
		return FALSE
	if(phased && is_blocked_turf(T, TRUE))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/shadow_crawl/cast(list/targets, mob/living/user = usr)
	var/turf/target = targets[1]
	if(!istype(user) || !target)
		revert_cast(user)
		return
	if(phased)
		if(!phase_in(target, user))
			revert_cast(user)
	else
		phase_out(target, user)
		revert_cast(user) // wejście w cień nie ma odnowienia, tylko wyjście

/obj/effect/proc_holder/spell/shadow_crawl/proc/phase_out(turf/target, mob/living/user)
	var/turf/mob_loc = get_turf(user)
	mob_loc.visible_message("<span class='danger'>[user] zanurza się w cieniach...</span>")
	new /obj/effect/temp_visual/dir_setting/shadow_crawl(mob_loc, user.dir, "shadowwalk_disappear")
	var/obj/effect/dummy/phased_mob/shadow_crawl/holder = new(mob_loc)
	user.ExtinguishMob()
	user.forceMove(holder)
	phased = TRUE
	var/mob/living/simple_animal/shadow_demon/demon = user
	if(istype(demon))
		demon.check_darkness()

/obj/effect/proc_holder/spell/shadow_crawl/proc/phase_in(turf/target, mob/living/user)
	if(!istype(user.loc, /obj/effect/dummy/phased_mob/shadow_crawl))
		phased = FALSE
		return FALSE
	if(!do_after(user, 2 SECONDS, target = target))
		return FALSE
	if(!istype(user.loc, /obj/effect/dummy/phased_mob/shadow_crawl) || get_dist(get_turf(user), target) > 1 || !is_valid_crawl_turf(target))
		return FALSE
	var/obj/effect/dummy/phased_mob/shadow_crawl/holder = user.loc
	user.forceMove(target)
	user.client?.eye = user
	new /obj/effect/temp_visual/dir_setting/shadow_crawl(target, user.dir, "shadowwalk_appear")
	if(prob(25))
		playsound(target, pick('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/i_see_you1.ogg'), 50, TRUE, -1)
	qdel(holder)
	phased = FALSE
	return TRUE

/obj/effect/temp_visual/dir_setting/shadow_crawl
	icon = 'aquila/icons/mob/shadow_demon.dmi'
	icon_state = "blank" // animacja przez flick
	duration = 0.6 SECONDS

/obj/effect/temp_visual/dir_setting/shadow_crawl/Initialize(mapload, set_dir, animation_state)
	. = ..()
	flick(animation_state, src) // ustawienie icon_state na animację gubi klatki

/obj/effect/dummy/phased_mob/shadow_crawl
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/phased_mob/shadow_crawl/relaymove(mob/user, direction)
	var/turf/new_loc = get_step(src, direction)
	if(!new_loc)
		return
	forceMove(new_loc)
	var/mob/living/simple_animal/shadow_demon/demon = user
	if(istype(demon))
		demon.check_darkness()

/obj/effect/dummy/phased_mob/shadow_crawl/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/A as anything in contents)
		A.forceMove(T)
	return ..()

/obj/effect/dummy/phased_mob/shadow_crawl/ex_act()
	return

/obj/effect/dummy/phased_mob/shadow_crawl/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/shadow_crawl/singularity_act()
	return

// Demoniczny szept

/obj/effect/proc_holder/spell/targeted/telepathy/shadow_demon
	name = "Demonic Whisper"
	desc = "Przemów wprost do umysłu wybranej osoby."
	action_icon = 'aquila/icons/mob/actions/actions_shadow_demon.dmi'
	action_icon_state = "shadow_whisper"
	action_background_icon_state = "shadow_demon_bg"
	base_action = /datum/action/spell_action/spell/shadow_demon
	notice = "cultitalic"
	boldnotice = "cultbold"
	phase_allowed = TRUE
