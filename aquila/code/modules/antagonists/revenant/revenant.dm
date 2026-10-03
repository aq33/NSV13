// AQUILA - aq33/NSV13#245, port of BeeStation/BeeStation-Hornet#8823
// Revenants see ghosts and other revenants, can orbit things next to them (never ghosts or revenants),
// and get a recall spell while they are away from the station.
// The orbit code came from an earlier Bee PR that NSV never had, so its movement check is ported here too.

/mob/living/simple_animal/revenant
	see_invisible = SEE_INVISIBLE_OBSERVER

/mob/living/simple_animal/revenant/Initialize(mapload)
	. = ..()
	check_rev_teleport() // they can spawn off the station

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
	if(revealed)
		to_chat(src, "<span class='revenwarning'>You can't orbit while you're revealed!</span>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='revenwarning'>You can only orbit things that are next to you!</span>")
		return
	if(isobserver(A) || isrevenant(A)) // ghosts travel anywhere for free, and orbiting revenants would let them team up
		to_chat(src, "<span class='revenwarning'>You can't orbit a ghost!</span>")
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
		to_chat(src, "<span class='warning'>[salt] bars your passage!</span>")
		reveal(20)
		stun(20)
		return FALSE
	if(step_turf.flags_1 & NOJAUNT_1)
		to_chat(src, "<span class='warning'>Some strange aura is blocking the way.</span>")
		return FALSE
	if(locate(/obj/effect/blessing) in step_turf)
		to_chat(src, "<span class='warning'>Holy energies block your path!</span>")
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
	if(!isrevenant(user))
		return
	if(is_station_level(user.z))
		to_chat(user, "<span class='revenwarning'>Recalling yourself to the station is only available when you're not in the station.</span>")
		return
	if(user.revealed)
		to_chat(user, "<span class='revenwarning'>Recalling yourself to the station is only available when you're invisible.</span>")
		return
	to_chat(user, "<span class='revennotice'>You start to concentrate recalling yourself to the station.</span>")
	if(!do_after(user, 3 SECONDS) || user.revealed || QDELETED(src)) // QDELETED: the spell is removed if they reach the station meanwhile
		return
	var/turf/target_turf = get_random_station_turf()
	if(!target_turf || !do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_CULT, forced = TRUE))
		to_chat(user, "<span class='revenwarning'>You have failed to recall yourself to the station... You should try again.</span>")
		return
	user.reveal(8 SECONDS)
	user.stun(4 SECONDS)
