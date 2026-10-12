/// The carp rift is currently charging.
#define CHARGE_ONGOING			0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING		1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED		2

/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Summon a rift to bring forth a horde of space carp."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'
	button_icon_state = "carp_rift"

/datum/action/innate/summon_rift/Activate()
	var/datum/antagonist/space_dragon/dragon = owner.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(!dragon)
		return
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return
	if(S.can_summon_rifts)
		to_chat(S, "<span class='warning'>Przez twoją porażkę nie możesz przywoływać szczelin!</span>")
		return
	var/area/A = get_area(S)
	if(!(A in dragon.chosen_rift_areas))
		to_chat(S, "<span class='warning'>Nie możesz tu przywołać szczeliny!</span>")
		return
	for(var/obj/structure/carp_rift/rift in dragon.rift_list)
		var/area/RA = get_area(rift)
		if(RA == A)
			to_chat(S, "<span class='warning'>Już przywołałeś szczelinę w tym obszarze! Następną musisz przywołać gdzie indziej!</span>")
			return
	var/turf/rift_spawn_turf = get_turf(S)
	if(istype(rift_spawn_turf, /turf/open/openspace))
		owner.balloon_alert(S, "potrzebny stabilny grunt!")
		return
	to_chat(S, "<span class='warning'>Zaczynasz otwierać szczelinę...</span>")
	if(do_after(S, 100, target = S))
		for(var/obj/structure/carp_rift/c in rift_spawn_turf.contents)
			return
		var/obj/structure/carp_rift/CR = new /obj/structure/carp_rift(rift_spawn_turf)
		playsound(S, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
		dragon.stop_rift_timer() // the rift needs to finish charging before we should worry about the dragon summoning another in time
		CR.dragon = dragon
		dragon.rift_list += CR
		to_chat(S, "<span class='boldwarning'>Szczelina została przywołana. Za wszelką cenę nie pozwól załodze jej zniszczyć!</span>")
		notify_ghosts("Kosmiczny smok otworzył szczelinę!", source = CR, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Otwarto szczelinę karpi")
		qdel(src)

/**
  * # Carp Rift
  *
  * The portals Space Dragon summons to bring carp onto the station.
  *
  * The portals Space Dragon summons to bring carp onto the station.  His main objective is to summon 3 of them and protect them from being destroyed.
  * The portals can summon sentient space carp in limited amounts.  The portal also changes color based on whether or not a carp spawn is available.
  * Once it is fully charged, it becomes indestructible, and intermitently spawns non-sentient carp.  It is still destroyed if Space Dragon dies.
  */
/obj/structure/carp_rift
	name = "carp rift"
	desc = "A rift akin to the ones space carp use to travel long distances."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 0)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	light_color = LIGHT_COLOR_PURPLE
	light_range = 10
	anchored = TRUE
	density = TRUE
	plane = MASSIVE_OBJ_LAYER
	/// The amount of time the rift has charged for.
	var/time_charged = 0
	/// The maximum charge the rift can have.
	var/max_charge = 300
	/// How many carp spawns it has available.
	var/carp_stored = 1
	/// A reference to the Space Dragon that created it.
	var/datum/antagonist/space_dragon/dragon
	/// Current charge state of the rift.
	var/charge_state = CHARGE_ONGOING
	/// The interval for adding additional space carp spawns to the rift.
	var/carp_interval = 45
	/// The time since an extra carp was added to the ghost role spawning pool.
	var/last_carp_inc = 0
	/// A list of all the ckeys which have used this carp rift to spawn in as carps.
	var/list/ckey_list = list()

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent( \
		/datum/component/gravity_aura, \
		range = 15, \
		requires_visibility = FALSE, \
		gravity_strength = 1, \
	)

/obj/structure/carp_rift/examine(mob/user)
	. = ..()
	if(time_charged < max_charge)
		. += "<span class='notice'>Wygląda na naładowaną w [(time_charged / max_charge) * 100]%.</span>"
	else
		. += "<span class='warning'>Ta jest w pełni naładowana. W tym stanie przeniesie znacznie więcej karpi niż zwykle.</span>"

	if(isobserver(user))
		. += "<span class='notice'>Dostępne karpie do odrodzenia: [carp_stored].</span>"

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(time_charged != max_charge + 1)
		dragon?.destroy_rifts()
		if(dragon)
			to_chat(dragon, "<span class='boldwarning'>Szczelina została zniszczona! Ponosisz porażkę i czujesz się osłabiony.</span>")
			dragon = null
	return ..()

/obj/structure/carp_rift/process(delta_time)
	// Heal carp around us
	for(var/mob/living/simple_animal/hostile/hostilehere in range(1))
		if("carp" in hostilehere.faction)
			hostilehere.adjustHealth(-10)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(hostilehere))
			H.color = "#0000FF"

	// If we're fully charged, just start mass spawning carp and move around.
	if(charge_state == CHARGE_COMPLETED)
		if(DT_PROB(1.25, delta_time))
			new /mob/living/simple_animal/hostile/carp/advanced(loc)
		if(DT_PROB(1.5, delta_time))
			var/rand_dir = pick(GLOB.cardinals)
			Move(get_step(src, rand_dir), rand_dir)
		return

	// Increase time trackers and check for any updated states.
	time_charged = min(time_charged + delta_time, max_charge)
	last_carp_inc += delta_time
	update_check()

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	summon_carp(user)

/**
 * Does a series of checks based on the portal's status.
 *
 * Performs a number of checks based on the current charge of the portal, and triggers various effects accordingly.
 * If the current charge is a multiple of carp_interval, add an extra carp spawn.
 * If we're halfway charged, announce to the crew our location in a CENTCOM announcement.
 * If we're fully charged, tell the crew we are, change our color to yellow, become invulnerable, and give Space Dragon the ability to make another rift, if he hasn't summoned 3 total.
 */
/obj/structure/carp_rift/proc/update_check()
	// If the rift is fully charged, there's nothing to do here anymore.
	if(charge_state == CHARGE_COMPLETED)
		return

	// Can we increase the carp spawn pool size?
	if(last_carp_inc >= carp_interval)
		carp_stored++
		icon_state = "carp_rift_carpspawn"
		if(light_color != LIGHT_COLOR_PURPLE)
			set_light_color(LIGHT_COLOR_PURPLE)
			update_light()
		notify_ghosts("Szczelina karpi może przywołać dodatkowego karpia!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Dostępny karp")
		last_carp_inc -= carp_interval

	// Is the rift now fully charged?
	if(time_charged >= max_charge)
		charge_state = CHARGE_COMPLETED
		var/area/A = get_area(src)
		priority_announce("Obiekt przestrzenny w [initial(A.name)] osiągnął szczytowy poziom energii, prosimy czekać na dalsze informacje.", "Obserwacja Fauny Centrali")
		obj_integrity = INFINITY
		icon_state = "carp_rift_charged"
		set_light_color(LIGHT_COLOR_YELLOW)
		update_light()
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3 && !dragon.objective_complete)
			dragon.rift_ability = new
			dragon.rift_ability.Grant(dragon.owner.current)
			dragon.start_rift_timer() // dragon now needs to make a rift in the time limit
			dragon.rift_empower()
		// Early return, nothing to do after this point.
		return

	// Do we need to give a final warning to the station at the halfway mark?
	if(charge_state < CHARGE_FINALWARNING && time_charged >= (max_charge * 0.5))
		charge_state = CHARGE_FINALWARNING
		var/area/A = get_area(src)
		priority_announce("Szczelina wywołuje nienaturalnie duży strumień energii w [initial(A.name)]. Powstrzymajcie ją za wszelką cenę!", "Obserwacja Fauny Centrali", ANNOUNCER_SPANOMALIES)

/**
  * Used to create carp controlled by ghosts when the option is available.
  *
  * Creates a carp for the ghost to control if we have a carp spawn available.
  * Gives them prompt to control a carp, and if our circumstances still allow if when they hit yes, spawn them in as a carp.
  * Also add them to the list of carps in Space Dragon's antgonist datum, so they'll be displayed as having assisted him on round end.
  * Arguments:
  * * mob/user - The ghost which will take control of the carp.
  */
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored <= 0)//Not enough carp points
		return FALSE
	var/is_listed = FALSE
	if (user.ckey in ckey_list)
		if(carp_stored == 1)
			to_chat(user, "<span class='warning'>Już stałeś się karpiem dzięki tej szczelinie! Zaczekaj na kolejne odrodzenia karpi albo na następną szczelinę!</span>")
			return FALSE
		is_listed = TRUE
	var/carp_ask = alert("Zostać karpiem?", "Pomóc sprowadzić hordę?", "Yes", "No")
	if(carp_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored <= 0)
		to_chat(user, "<span class='warning'>Szczelina przywołała już dość karpi!</span>")
		return FALSE
	var/mob/living/simple_animal/hostile/carp/advanced/newcarp = new(loc)
	var/datum/action/innate/wavespeak/wave_action = new
	wave_action.Grant(newcarp)
	if(!is_listed)
		ckey_list += user.ckey
	newcarp.key = user.key
	newcarp.unique_name = TRUE
	dragon.carp += newcarp.mind
	to_chat(newcarp, "<span class='boldwarning'>Przybywasz, by pomóc kosmicznemu smokowi w zabezpieczeniu szczelin. Nie narażaj misji i za wszelką cenę chroń szczeliny!</span>")
	carp_stored--
	if(carp_stored <= 0 && charge_state < CHARGE_COMPLETED)
		icon_state = "carp_rift"
		set_light_color(LIGHT_COLOR_BLUE)
		update_light()
	return TRUE

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
