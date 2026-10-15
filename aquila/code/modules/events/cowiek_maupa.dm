// AQUILA - Cowiek Maupa: a strong, hostile ape-man waits in a random electrical locker on the ship.
// It sits still until someone opens the locker (or it gets broken), then jumps out with a roar and attacks.

/datum/round_event_control/aquila_cowiek_maupa
	name = "Cowiek Maupa"
	typepath = /datum/round_event/aquila_cowiek_maupa
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_cowiek_maupa
	fakeable = FALSE

/datum/round_event/aquila_cowiek_maupa/start()
	var/list/closets = aquila_cowiek_maupa_closet_candidates()
	if(!length(closets))
		message_admins("Cowiek Maupa event found no closed electrical locker on the ship, nothing was spawned.")
		log_game("Cowiek Maupa event found no closed electrical locker on the ship, nothing was spawned.")
		return
	var/obj/structure/closet/closet = pick(closets)
	var/mob/living/simple_animal/hostile/cowiek_maupa/maupa = new(closet)
	announce_to_ghosts(closet)
	message_admins("Cowiek Maupa event hid [maupa] in [closet] at [ADMIN_VERBOSEJMP(closet)].")
	log_game("Cowiek Maupa event hid [maupa] in [closet] at [AREACOORD(closet)].")

/// Closed electrical lockers on the ship that nobody is hiding in yet
/proc/aquila_cowiek_maupa_closet_candidates()
	. = list()
	for(var/obj/structure/closet/secure_closet/engineering_electrical/closet in world)
		if(closet.opened || closet.welded || !isturf(closet.loc) || !is_station_level(closet.z))
			continue
		if(locate(/mob/living) in closet)
			continue
		. += closet
		CHECK_TICK

/// A strong ape-man that keeps its AI off while it waits in a locker and wakes up with a roar once it is let out
/mob/living/simple_animal/hostile/cowiek_maupa
	name = "cowiek maupa"
	desc = "Pół cowiek, pół maupa. W całości wkurzony."
	icon = 'aquila/icons/mob/cowiek_maupa.dmi'
	icon_state = "cowiek_maupa"
	icon_living = "cowiek_maupa"
	icon_dead = "cowiek_maupa_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	gender = MALE
	maxHealth = 300
	health = 300
	move_to_delay = 3
	melee_damage = 25
	obj_damage = 60
	armour_penetration = 10
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attacktext = "tłucze"
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help = "głaszcze"
	response_disarm = "odpycha"
	response_harm = "uderza"
	faction = list("cowiek_maupa")
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	hardattacks = TRUE
	butcher_results = list(/obj/item/food/meat/slab/monkey = 4)
	deathmessage = "przewraca się i nieruchomieje."
	gold_core_spawnable = NO_SPAWN
	do_footstep = TRUE
	/// Keeps the roar from playing on every single punch
	COOLDOWN_DECLARE(roar_cooldown)

/mob/living/simple_animal/hostile/cowiek_maupa/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/structure/closet))
		toggle_ai(AI_OFF) // a wandering AI would push the door open by itself
		COOLDOWN_START(src, roar_cooldown, rand(1 MINUTES, 3 MINUTES)) // first muffled roar from the locker

/mob/living/simple_animal/hostile/cowiek_maupa/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(AIStatus != AI_OFF || client || stat != CONSCIOUS)
		return
	if(!istype(OldLoc, /obj/structure/closet) || istype(loc, /obj/structure/closet))
		return
	visible_message("<span class='userdanger'>[src] wyskakuje z szafki z rykiem!</span>")
	roar()
	toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/cowiek_maupa/Life()
	. = ..()
	if(stat != CONSCIOUS || client || !istype(loc, /obj/structure/closet))
		return
	if(!COOLDOWN_FINISHED(src, roar_cooldown))
		return
	COOLDOWN_START(src, roar_cooldown, rand(1 MINUTES, 3 MINUTES))
	var/obj/structure/closet/closet = loc
	closet.visible_message("<span class='warning'>Z [closet] dobiega stłumiony ryk!</span>", blind_message = "<span class='warning'>Słyszysz gdzieś blisko stłumiony ryk!</span>")
	playsound(closet, 'aquila/sound/creatures/cowiek_maupa_ryk.ogg', 50, FALSE, -1)
	closet.Shake(2, 2, 1 SECONDS)

/mob/living/simple_animal/hostile/cowiek_maupa/AttackingTarget()
	. = ..()
	if(. && COOLDOWN_FINISHED(src, roar_cooldown) && prob(30))
		roar()

/mob/living/simple_animal/hostile/cowiek_maupa/proc/roar()
	COOLDOWN_START(src, roar_cooldown, 8 SECONDS)
	playsound(src, 'aquila/sound/creatures/cowiek_maupa_ryk.ogg', 100, FALSE, 4)
