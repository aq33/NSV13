// AQUILA - darkspawn: efekty statusów

/// Całun: chroni przed paleniem przez światło, zżera Psi
/datum/status_effect/darkspawn_creep
	id = "darkspawn_creep"
	duration = -1
	tick_interval = 2
	alert_type = /atom/movable/screen/alert/status_effect/darkspawn_creep
	examine_text = "<span class='warning'>SUBJECTPRONOUN otaczają aksamitne, łagodnie falujące czarne cienie!</span>"
	var/datum/antagonist/darkspawn/darkspawn

/datum/status_effect/darkspawn_creep/on_creation(mob/living/new_owner, datum/antagonist/darkspawn/new_darkspawn)
	darkspawn = new_darkspawn
	return ..()

/datum/status_effect/darkspawn_creep/tick()
	if(!darkspawn)
		qdel(src)
		return
	// 5 ticków na sekundę, 5 Psi na sekundę
	if(!darkspawn.has_psi(1))
		to_chat(owner, "<span class='warning'>Bez Psi ochronna aura znika!</span>")
		qdel(src)
		return
	darkspawn.use_psi(1)

/datum/status_effect/darkspawn_creep/Destroy()
	darkspawn = null
	return ..()

/atom/movable/screen/alert/status_effect/darkspawn_creep
	name = "Całun"
	desc = "Jesteś odporny na palenie przez światło. Zużywa 5 Psi na sekundę."
	icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	icon_state = "creep"

/// Dylatacja czasu: dwa razy szybsze działania i odporność na spowolnienie
/datum/status_effect/darkspawn_time_dilation
	id = "darkspawn_time_dilation"
	duration = 1 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/darkspawn_time_dilation
	examine_text = "<span class='warning'>SUBJECTPRONOUN porusza się gwałtownie i nieprzewidywalnie!</span>"

/datum/status_effect/darkspawn_time_dilation/on_apply()
	owner.next_move_modifier *= 0.5
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/darkspawn_time_dilation)
	owner.ignore_slowdown(id)
	return TRUE

/datum/status_effect/darkspawn_time_dilation/on_remove()
	owner.next_move_modifier *= 2
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/darkspawn_time_dilation)
	owner.unignore_slowdown(id)

/datum/actionspeed_modifier/darkspawn_time_dilation
	multiplicative_slowdown = -0.5

/atom/movable/screen/alert/status_effect/darkspawn_time_dilation
	name = "Dylatacja czasu"
	desc = "Twoje działania są dwa razy szybsze, a przerwy między nimi o połowę krótsze. Do tego nic cię nie spowalnia."
	icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	icon_state = "time_dilation"

/// Złamana wola: głęboki sen po Pożarciu woli, skracany przez obrażenia
/datum/status_effect/broken_will
	id = "broken_will"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 30 SECONDS
	examine_text = "<span class='deadsay'>SUBJECTPRONOUN śpi głębokim, trupim snem, nie reagując na nic wokół.</span>"
	alert_type = /atom/movable/screen/alert/status_effect/broken_will
	var/old_health

/datum/status_effect/broken_will/tick()
	owner.Unconscious(15)
	if(!old_health)
		old_health = owner.health
	var/health_difference = old_health - owner.health
	if(!health_difference)
		return
	owner.visible_message("<span class='warning'>[owner] wzdryga się przez sen, gdy coś go rani!</span>")
	to_chat(owner, "<span class='boldannounce'>Coś cię uderza i wyrywa ze snu!</span>")
	duration -= health_difference * 10 // 1 punkt obrażeń = 1 sekunda
	old_health = owner.health

/atom/movable/screen/alert/status_effect/broken_will
	name = "Złamana wola"
	desc = "..."
	icon = 'aquila/icons/mob/darkspawn/broken_will.dmi'
	icon_state = "broken_will"
	alerttooltipstyle = "alien"

/// Klątwa Potomka: z każdej strony wyciągają się po ciebie ręce
/datum/status_effect/progenitor_curse
	id = "progenitor_curse"
	duration = 20 SECONDS
	tick_interval = 5
	alert_type = null

/datum/status_effect/progenitor_curse/tick()
	if(owner.stat == DEAD)
		return
	var/grab_dir = turn(owner.dir, rand(-180, 180))
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
	if(spawn_turf)
		grasp(spawn_turf)

/datum/status_effect/progenitor_curse/proc/grasp(turf/spawn_turf)
	set waitfor = FALSE
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/item/projectile/curse_hand/hand = new(spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	hand.fire()

/// Wtopienie w cień: darkspawn siedzi w cieniu celu, dopóki ten jest w świetle
/datum/status_effect/darkspawn_tagalong
	id = "darkspawn_tagalong"
	duration = 5 MINUTES
	tick_interval = 1
	alert_type = /atom/movable/screen/alert/status_effect/darkspawn_tagalong
	var/mob/living/shadowing
	/// Ostatnia pozycja celu, żeby po zgibowaniu nie wylądować w nullspace
	var/turf/cached_location

/datum/status_effect/darkspawn_tagalong/on_creation(mob/living/new_owner, mob/living/tag)
	shadowing = tag
	cached_location = get_turf(tag)
	return ..()

/datum/status_effect/darkspawn_tagalong/on_remove()
	if(owner.loc == shadowing)
		owner.forceMove(cached_location || get_turf(owner))
		shadowing.visible_message("<span class='warning'>[owner] odrywa się od cienia [shadowing]!</span>", \
			"<span class='userdanger'>Czujesz, jak przenika cię lodowaty chłód!</span>")
		to_chat(owner, "<span class='velvet'>Odrywasz się od [shadowing].</span>")
	else if(!isturf(owner.loc))
		owner.forceMove(cached_location || get_turf(owner))
	playsound(owner, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	owner.setDir(SOUTH)
	shadowing = null

/datum/status_effect/darkspawn_tagalong/tick()
	if(QDELETED(shadowing))
		qdel(src)
		return
	cached_location = get_turf(shadowing)
	if(cached_location.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		owner.forceMove(cached_location)
		shadowing.visible_message("<span class='warning'>[owner] nagle wyłania się z ciemności!</span>")
		to_chat(owner, "<span class='warning'>Zostajesz wyrzucony z cienia [shadowing]!</span>")
		owner.Knockdown(3 SECONDS)
		qdel(src)
		return
	var/obj/item/I = owner.get_active_held_item()
	if(I)
		to_chat(owner, "<span class='userdanger'>Wzięcie czegoś do ręki cię wyrzuca!</span>")
		if(istype(I, /obj/item/dark_bead))
			to_chat(owner, "<span class='userdanger'>[I] trzeszczy od sprzężenia, na chwilę cię oszałamiając!</span>")
			owner.Stun(5)
		qdel(src)

/atom/movable/screen/alert/status_effect/darkspawn_tagalong
	name = "Wtopienie w cień"
	desc = "Towarzyszysz komuś w jego cieniu. Użyj Wtopienia w cień, żeby w każdej chwili się oderwać."
	icon_state = "shadow_mend"
