// AQUILA - aq33/NSV13#245, port of BeeStation/BeeStation-Hornet#8823
// Revenants see ghosts and other revenants, can orbit things next to them (never ghosts or revenants),
// and get a recall spell while they are away from the station.
// The orbit code came from an earlier Bee PR that NSV never had, so its movement check is ported here too.

/mob/living/simple_animal/revenant
	see_invisible = SEE_INVISIBLE_OBSERVER

/mob/living/simple_animal/revenant/Initialize(mapload)
	. = ..()
	check_rev_teleport() // they can spawn off the station
	// Moce z tg: nawiedzanie przedmiotów, wir i rozrzut
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/haunt_object(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/vortex(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/scatter(null))
	// Jak w tg słyszy martwy czat, więc zmarli mogą go prosić o przysługi
	ADD_TRAIT(src, TRAIT_SIXTHSENSE, INNATE_TRAIT)

// Jak w tg: niewidzialny rewenant może bawić się tablicą spirytystyczną jak duch
/mob/living/simple_animal/revenant/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(!istype(A, /obj/structure/spirit_board) || modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
		return ..()
	if(check_click_intercept(params, A))
		return
	if(revealed || notransform || inhibited)
		return
	var/obj/structure/spirit_board/board = A
	INVOKE_ASYNC(board, TYPE_PROC_REF(/obj/structure/spirit_board, spirit_board_pick_letter), src)

// Uwięziony w lustrze nie używa mocy (revenant_prison.dm)
/mob/living/simple_animal/revenant/castcheck(essence_cost)
	if(istype(loc, /obj/structure/mirror))
		to_chat(src, "<span class='revenwarning'>Twoje moce są uwięzione razem z tobą!</span>")
		return FALSE
	return ..()

/mob/living/simple_animal/revenant/onTransitZ(old_z, new_z)
	. = ..()
	check_rev_teleport()

/// The recall spell only exists while the revenant is off the station
/mob/living/simple_animal/revenant/proc/check_rev_teleport()
	var/obj/effect/proc_holder/spell/self/rev_teleport/revtele = locate() in mob_spell_list
	if(!is_station_level(z) && !revtele)
		AddSpell(new /obj/effect/proc_holder/spell/self/rev_teleport(null))
	else if(is_station_level(z) && revtele)
		RemoveSpell(revtele)

// Ctrl-click or double-click orbits
/mob/living/simple_animal/revenant/CtrlClickOn(atom/A)
	if(incorporeal_move == INCORPOREAL_MOVE_JAUNT)
		check_orbitable(A)
		return
	..() // pull the thing

/mob/living/simple_animal/revenant/DblClickOn(atom/A, params)
	if(get_dist(src, A) < 5) // no message spam while spamming phase shift
		check_orbitable(A)
	..()

/// Orbits A like a ghost would, if the revenant is allowed to
/mob/living/simple_animal/revenant/proc/check_orbitable(atom/A)
	if(!isturf(loc)) // uwięziony w lustrze
		return
	if(revealed)
		to_chat(src, "<span class='revenwarning'>Nie możesz orbitować, gdy jesteś ujawniony!</span>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='revenwarning'>Możesz orbitować tylko wokół rzeczy obok ciebie!</span>")
		return
	if(isobserver(A) || isrevenant(A)) // ghosts travel anywhere for free, and orbiting revenants would let them team up
		to_chat(src, "<span class='revenwarning'>Nie możesz orbitować wokół ducha!</span>")
		return
	if(notransform || inhibited || !incorporeal_move_check(A))
		return
	var/icon/I = icon(A.icon, A.icon_state, A.dir)
	var/orbitsize = (I.Width() + I.Height()) * 0.5
	orbitsize -= (orbitsize / world.icon_size) * (world.icon_size * 0.25)
	orbit(A, orbitsize)

/mob/living/simple_animal/revenant/orbit(atom/target)
	setDir(SOUTH) // reset dir so the right directional sprites show up
	return ..()

/mob/living/simple_animal/revenant/Moved(atom/OldLoc, Dir, Forced = FALSE)
	if(!orbiting || incorporeal_move_check(src))
		return ..()
	// The orbited thing went somewhere a revenant cannot go, let go of it and stay behind
	orbiting.end_orbit(src)
	abstract_move(OldLoc)

/// Same rules as INCORPOREAL_MOVE_JAUNT in mob_movement.dm: salt, no-jaunt turfs and blessed tiles block a revenant
/mob/living/simple_animal/revenant/proc/incorporeal_move_check(atom/destination)
	var/turf/step_turf = get_turf(destination)
	if(!step_turf)
		return TRUE
	var/obj/effect/decal/cleanable/food/salt/salt = locate() in step_turf
	if(salt)
		to_chat(src, "<span class='warning'>[salt] zagradza ci drogę!</span>")
		reveal(20)
		stun(20)
		return FALSE
	if(step_turf.flags_1 & NOJAUNT_1)
		to_chat(src, "<span class='warning'>Jakaś dziwna aura blokuje przejście.</span>")
		return FALSE
	if(locate(/obj/effect/blessing) in step_turf)
		to_chat(src, "<span class='warning'>Święte energie blokują ci drogę!</span>")
		return FALSE
	return TRUE

// The action icons from the PR: an eye for night vision, and the recall icon
/obj/effect/proc_holder/spell/targeted/night_vision/revenant
	action_icon = 'aquila/icons/mob/actions/actions_revenant.dmi'

/// Recall to Station: only given while the revenant is off the station
/obj/effect/proc_holder/spell/self/rev_teleport
	name = "Recall to Station"
	desc = "Teleport to the station."
	charge_max = 0
	panel = "Revenant Abilities"
	action_icon = 'aquila/icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_teleport"
	action_background_icon_state = "bg_revenant"
	clothes_req = FALSE

/obj/effect/proc_holder/spell/self/rev_teleport/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!isrevenant(user) || !isturf(user.loc)) // z lustra się nie teleportuje
		return
	if(is_station_level(user.z))
		to_chat(user, "<span class='revenwarning'>Powrót na statek jest dostępny tylko wtedy, gdy nie jesteś na statku.</span>")
		return
	if(user.revealed)
		to_chat(user, "<span class='revenwarning'>Powrót na statek jest dostępny tylko wtedy, gdy jesteś niewidzialny.</span>")
		return
	to_chat(user, "<span class='revennotice'>Zaczynasz skupiać się na powrocie na statek.</span>")
	if(!do_after(user, 3 SECONDS) || user.revealed || QDELETED(src)) // QDELETED: the spell is removed if they reach the station meanwhile
		return
	var/turf/target_turf = get_random_station_turf()
	if(!target_turf || !do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_CULT, forced = TRUE))
		to_chat(user, "<span class='revenwarning'>Nie udało ci się wrócić na statek... Spróbuj jeszcze raz.</span>")
		return
	user.reveal(8 SECONDS)
	user.stun(4 SECONDS)
