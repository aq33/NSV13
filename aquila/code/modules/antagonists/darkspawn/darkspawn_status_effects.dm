// AQUILA - darkspawn: efekty statusów i chemikalia (port z Yogstation)

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

/// Złamana wola: głęboki sen po Pożarciu woli, przerywany mocniejszym ciosem
/datum/status_effect/broken_will
	id = "broken_will"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 30 SECONDS
	examine_text = "<span class='deadsay'>SUBJECTPRONOUN śpi głębokim, trupim snem, nie reagując na nic wokół.</span>"
	alert_type = /atom/movable/screen/alert/status_effect/broken_will
	/// Ile obrażeń jednym ciosem budzi śpiącego
	var/wake_threshold = 5
	var/old_health

/datum/status_effect/broken_will/on_apply()
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, id)
	old_health = owner.health
	return ..()

/datum/status_effect/broken_will/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, id)
	owner.SetUnconscious(0)

/datum/status_effect/broken_will/tick()
	if(is_team_darkspawn(owner) || owner.stat == DEAD)
		qdel(src)
		return
	if(old_health - owner.health >= wake_threshold) // dostał mocniej, budzi się
		owner.visible_message("<span class='warning'>[owner] budzi się gwałtownie od uderzenia!</span>", "<span class='boldannounce'>Coś cię uderza i wyrywa ze snu!</span>")
		ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, id)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_remove_wake_traits), owner, id), 20 SECONDS)
		qdel(src)
		return
	old_health = owner.health
	owner.Unconscious(15)
	if(owner.health <= HEALTH_THRESHOLD_CRIT) // porzucony nie wykrwawi się na śmierć
		owner.adjustBruteLoss(-3)
		owner.adjustFireLoss(-3)
		old_health = owner.health
		if(prob(10))
			to_chat(owner, "<span class='velvet'>sen... błogość...</span>")

/proc/darkspawn_remove_wake_traits(mob/living/target, source)
	if(QDELETED(target))
		return
	REMOVE_TRAIT(target, TRAIT_NOSOFTCRIT, source)
	REMOVE_TRAIT(target, TRAIT_IGNOREDAMAGESLOWDOWN, source)

/atom/movable/screen/alert/status_effect/broken_will
	name = "Złamana wola"
	desc = "..."
	icon = 'aquila/icons/mob/darkspawn/broken_will.dmi'
	icon_state = "broken_will"
	alerttooltipstyle = "alien"

/// Klątwa Potomka: z każdej strony wyciągają się po ciebie ręce
/datum/status_effect/progenitor_curse
	id = "progenitor_curse"
	duration = 30 SECONDS
	tick_interval = 1.5 SECONDS
	alert_type = null

/datum/status_effect/progenitor_curse/tick()
	if(owner.stat == DEAD)
		return
	var/grab_dir = turn(owner.dir, rand(-180, 180))
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
	if(spawn_turf)
		INVOKE_ASYNC(src, PROC_REF(grasp), spawn_turf)

/datum/status_effect/progenitor_curse/proc/grasp(turf/spawn_turf)
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, pick('sound/effects/curse1.ogg', 'sound/effects/curse2.ogg', 'sound/effects/curse3.ogg'), 80, TRUE, -1)
	var/obj/item/projectile/curse_hand/hand = new(spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	hand.fire()

/// Wtargnięcie w cień: darkspawn siedzi w cieniu celu, dopóki ten jest w świetle
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
		qdel(src)
		return
	if(owner.get_active_held_item())
		to_chat(owner, "<span class='userdanger'>Wzięcie czegoś do ręki cię wyrzuca!</span>")
		qdel(src)

/atom/movable/screen/alert/status_effect/darkspawn_tagalong
	name = "Wtargnięcie w cień"
	desc = "Towarzyszysz komuś w jego cieniu. Użyj Wtargnięcia w cień, żeby w każdej chwili się oderwać."
	icon_state = "shadow_mend"

/// Podburzenie: cel musi iść w stronę darkspawna
/datum/status_effect/darkspawn_taunt
	id = "darkspawn_taunt"
	duration = 5 SECONDS
	tick_interval = CLICK_CD_MELEE
	alert_type = null
	var/mob/living/taunter

/datum/status_effect/darkspawn_taunt/on_creation(mob/living/new_owner, mob/living/new_taunter)
	taunter = new_taunter
	return ..()

/datum/status_effect/darkspawn_taunt/on_apply()
	if(HAS_TRAIT(owner, TRAIT_STUNIMMUNE) || !taunter)
		return FALSE
	owner.SetImmobilized(5 SECONDS)
	return TRUE

/datum/status_effect/darkspawn_taunt/tick()
	if(QDELETED(taunter))
		qdel(src)
		return
	step_towards(owner, taunter)
	owner.SetImmobilized(5 SECONDS)

/datum/status_effect/darkspawn_taunt/on_remove()
	owner.SetImmobilized(0)
	taunter = null

/// Przyspieszenie (albo spowolnienie przy dodatniej wartości) na określony czas
/datum/status_effect/darkspawn_speedboost
	id = "darkspawn_speedboost"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/strength = -0.5

/datum/status_effect/darkspawn_speedboost/on_creation(mob/living/new_owner, new_strength = -0.5, new_duration = 10 SECONDS)
	strength = new_strength
	duration = new_duration
	return ..()

/datum/status_effect/darkspawn_speedboost/on_apply()
	owner.add_movespeed_modifier(id, update = TRUE, priority = 100, multiplicative_slowdown = strength, override = TRUE)
	return TRUE

/datum/status_effect/darkspawn_speedboost/on_remove()
	owner.remove_movespeed_modifier(id)

/// Spowolnienie w polu pustki
/datum/status_effect/darkspawn_slow
	id = "darkspawn_slow"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/darkspawn_slow/on_creation(mob/living/new_owner, new_duration = 1 SECONDS)
	duration = new_duration
	return ..()

/datum/status_effect/darkspawn_slow/on_apply()
	owner.add_movespeed_modifier(id, update = TRUE, priority = 100, multiplicative_slowdown = 3, override = TRUE)
	return TRUE

/datum/status_effect/darkspawn_slow/on_remove()
	owner.remove_movespeed_modifier(id)

/// Cienisty płomień: zimny ogień, który szybko wychładza ciało
/datum/status_effect/shadowflame
	id = "shadowflame"
	status_type = STATUS_EFFECT_REFRESH
	duration = 10 SECONDS
	tick_interval = 1 SECONDS
	alert_type = null
	examine_text = "<span class='warning'>SUBJECTPRONOUN płonie zimnym, fioletowym ogniem!</span>"
	var/mutable_appearance/flame_overlay

/datum/status_effect/shadowflame/on_apply()
	owner.ExtinguishMob()
	flame_overlay = mutable_appearance('icons/mob/OnFire.dmi', "Generic_mob_burning", -FIRE_LAYER)
	flame_overlay.color = COLOR_VELVET
	owner.add_overlay(flame_overlay)
	return TRUE

/datum/status_effect/shadowflame/on_remove()
	owner.cut_overlay(flame_overlay)
	flame_overlay = null

/datum/status_effect/shadowflame/tick()
	if(is_team_darkspawn(owner) || !ishuman(owner))
		return
	var/mob/living/carbon/human/victim = owner
	var/thermal_multiplier = 1 - victim.get_cold_protection(0)
	victim.adjust_bodytemperature(BODYTEMP_COOLING_MAX * thermal_multiplier, 0)

// Chemikalia

/// Lodowe żyły: spowalnia każdego, kto ma to we krwi
/datum/reagent/shadowfrost
	name = "Shadowfrost"
	description = "Ciemna ciecz, która zdaje się spowalniać wszystko, czego dotknie."
	color = "#000000"

/datum/reagent/shadowfrost/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(type, update = TRUE, priority = 100, multiplicative_slowdown = 2)

/datum/reagent/shadowfrost/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	return ..()

/// Oślepiające miazmaty: oślepia wrogów, chroni darkspawnów przed światłem
/datum/reagent/darkspawn_darkness_smoke
	name = "odd black liquid"
	description = "<::BŁĄD::> NIE MOŻNA PRZEANALIZOWAĆ ODCZYNNIKA <::BŁĄD::>"
	color = "#000000"

/datum/reagent/darkspawn_darkness_smoke/on_mob_add(mob/living/L)
	. = ..()
	var/datum/antagonist/darkspawn/dude = isdarkspawn(L)
	if(dude)
		ADD_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

/datum/reagent/darkspawn_darkness_smoke/on_mob_delete(mob/living/L)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(L)
	if(dude)
		REMOVE_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)
	return ..()

/datum/reagent/darkspawn_darkness_smoke/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	if(is_team_darkspawn(M) && M.reagents) // darkspawni nie oddychają, więc dym trafia do nich tak
		M.reagents.add_reagent(type, 5)

/datum/reagent/darkspawn_darkness_smoke/on_mob_life(mob/living/carbon/M)
	if(!is_team_darkspawn(M))
		to_chat(M, "<span class='warning'><b>Smoliście czarny dym okropnie drażni ci oczy!</b></span>")
		M.blind_eyes(2)
		if(prob(25))
			M.visible_message("<b>[M]</b> drapie się po oczach!")
			M.Stun(3)
	holder.remove_reagent(type, 1) // ubywa po 1 jednostce
	volume = clamp(volume, 0, 2) // najwyżej 2 jednostki naraz
	return ..()
