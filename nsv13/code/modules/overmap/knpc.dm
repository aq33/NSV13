#define AI_TRAIT_BRAWLER 1 //The "marines". These guys will attempt to stand and fight
#define AI_TRAIT_SUPPORT 2 //The "medics", civvies, etc. These lads will call for backup

GLOBAL_LIST_EMPTY(knpcs)

/datum/component/knpc
	var/ai_trait = AI_AGGRESSIVE
	var/static/list/ai_goals = null
	var/datum/ai_goal/human/current_goal = null
	var/view_range = 8 //How good is this mob's "eyes"?
	var/guess_range = 12 //How far away will we assume they're still there after seeing them?
	var/list/last_aggressors = list()
	var/next_backup_call = 0 //Delay for calling for backup to avoid spam.
	var/list/path = list()
	var/turf/dest = null
	var/tries = 0 //How quickly do we give up on following a path? To avoid lag...
	var/max_tries = 10
	var/next_action = 0
	var/next_move = 0
	var/obj/effect/landmark/patrol_node/last_node = null //What was the last patrol node we visited?
	var/stealing_id = FALSE
	var/next_internals_attempt = 0
	var/static/list/climbable = typecacheof(list(
		/obj/structure/table,
		/obj/structure/railing,
		/obj/structure/peacekeeper_barricade,
		/obj/item/ship_weapon/ammunition
		)) // climbable things
	var/pathfind_timeout = 0 //If pathfinding fails, it is püt in timeout for a while to avoid spamming the server with pathfinding calls.
	var/timeout_stacks = 0 //Consecutive pathfind fails add additional delay stacks to further counteract the effects of knpcs in unreachable locations.
	///Time since when we have been disabled.
	var/failsafe_timer = 0
	///Each knpc has their own level of restraint before deciding to take desperate measures, but this is the base value.
	var/failsafe_trust = 3 SECONDS
	///This determines the maximum variance freom the base value of a particular knpc. Modifies upwards only.
	var/failsafe_trust_variance = 3 SECONDS
	///Weakrefs to items we failed to path to, so we stop chasing a gun behind a window forever.
	var/list/unreachable_items
	///Are we in the middle of a resist do_after?
	var/resisting = FALSE

/mob/living/carbon/human/ai_boarder
	faction = list("Neutral")
	var/move_delay = 4  //How quickly do the boys travel?
	var/action_delay = 9 //How long we delay between actions
	var/knpc_traits = KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC
	var/difficulty_override = FALSE //Whether to ignore overmap difficulty or not
	var/list/outfit = list (
		/datum/outfit/job/assistant
	)
	var/list/taunts = list("Atakuję wroga!")
	var/list/call_lines = list("Wróg w zasięgu wzroku!")
	var/list/response_lines = list("Już idę!")

/mob/living/carbon/human/ai_boarder/Initialize(mapload)
	. = ..()
	randomize_human(src)
	var/outfit_path = pick(outfit)
	var/datum/outfit/O = new outfit_path
	O.equip(src)
	AddComponent(/datum/component/knpc)
	if(!difficulty_override) //Check if we actually care about current difficulty
		switch(SSovermap_mode.mode.difficulty) //Check our current difficulty value
			if(1) //Lowest pop, so slow them down
				move_delay += 2
				action_delay += 2
			if(2 to 3)
				move_delay += 1
				action_delay += 1

/datum/component/knpc/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	failsafe_trust = rand(failsafe_trust, (failsafe_trust + failsafe_trust_variance))
	if(!ai_goals)
		for(var/gtype in subtypesof(/datum/ai_goal/human))
			LAZYADD(ai_goals, new gtype)
	START_PROCESSING(SSfastprocess, src)
	//They're alive!
	GLOB.knpcs.Add(src)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(restart))
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(register_bullet))

//Swiper! no swiping
/datum/component/knpc/proc/steal_id(obj/item/card/id/their_id, mob/living/carbon/victim)
	//Time to teach them about IDs :)))
	stealing_id = FALSE
	var/mob/living/carbon/human/H = parent
	if(QDELETED(their_id) || QDELETED(victim) || H.incapacitated())
		return FALSE
	//The ID may sit in a PDA or wallet, so take whatever the victim actually has equipped.
	var/obj/item/stolen = their_id
	while(isitem(stolen.loc) && stolen.loc != victim)
		stolen = stolen.loc
	if(stolen.loc != victim || get_dist(H, victim) > 1)
		return FALSE
	var/obj/item/card/id/ID = H.get_idcard()
	if(ID)
		if(istype(ID, /obj/item/card/id/syndicate) || istype(ID, /obj/item/card/id/syndicate_command) || istype(ID, /obj/item/card/id/syndi_crew))
			if(!victim.dropItemToGround(stolen))
				return FALSE
			H.visible_message("<span class='warning'>[H] wyrywa [stolen]. </span>")
			ID.access |= their_id.access
	else
		if(!victim.temporarilyRemoveItemFromInventory(stolen))
			return FALSE
		if(!H.put_in_inactive_hand(stolen))
			stolen.forceMove(get_turf(H))
			return FALSE
		if(H.equip_to_appropriate_slot(stolen))
			H.update_inv_hands()
			return TRUE

/datum/component/knpc/Destroy(force, silent)
	GLOB.knpcs -= src
	return ..()

/datum/component/knpc/proc/pathfind_to(atom/target, turf/avoid)
	if(pathfind_timeout > 0)
		return KNPC_PATHFIND_TIMEOUT
	var/mob/living/carbon/human/ai_boarder/H = parent
	if(target == null)
		path = list()
		dest = null
		return KNPC_PATHFIND_SKIP
	if((dest && dest == get_turf(target) && length(path)) || H.incapacitated())
		return KNPC_PATHFIND_SKIP //No need to recalculate this path.
	path = list()
	dest = null
	var/obj/item/card/id/access_card = H.wear_id
	if(target)
		dest = get_turf(target)
		path = get_path_to(H, dest, 120, 0, access_card, !(H.wear_suit?.clothing_flags & STOPSPRESSUREDAMAGE && H.head?.clothing_flags & STOPSPRESSUREDAMAGE), avoid)
	//There's no valid path, try run against the wall.
	if(!length(path) && !H.incapacitated())
		pathfind_timeout += KNPC_TIMEOUT_BASE * (1 + timeout_stacks)
		timeout_stacks = min(timeout_stacks+1, KNPC_TIMEOUT_STACK_CAP)
		return KNPC_PATHFIND_FAIL
	timeout_stacks = 0
	return KNPC_PATHFIND_SUCCESS

/datum/component/knpc/proc/next_path_step()
	if(world.time < next_move)
		return FALSE
	var/mob/living/carbon/human/ai_boarder/H = parent
	next_move = world.time + H.move_delay
	if(H.incapacitated() || H.stat == DEAD)
		return FALSE
	if(pathfind_timeout > 0) //Pathfinding in timeout, move around aimlessly
		H.set_resting(FALSE, FALSE)
		H.Move(get_step(H,pick(GLOB.cardinals)))
		return FALSE
	if(!path)
		return FALSE
	if(tries > 5)
		//Add a bit of randomness to their movement to reduce "traffic jams"
		H.Move(get_step(H,pick(GLOB.cardinals)))
		if(prob(10))
			H.lay_down()
			return FALSE

	if(tries >= max_tries)
		tries = 0
		if(length(last_node?.next_nodes)) //Skip this one.
			last_node = pick(last_node.next_nodes)
			pathfind_to(last_node)
		else
			pathfind_to(null)
			last_node = null //Reset pathfinding fully.
		return FALSE
	if(length(path) > 1)
		var/turf/next_turf = get_step_towards(H, path[1])
		var/turf/this_turf = get_turf(H)
		var/move_dir = get_dir(this_turf, next_turf)
		var/reverse_dir = get_dir(next_turf, this_turf)
		//Walk when you see a wet floor
		if(next_turf.GetComponent(/datum/component/wet_floor))
			H.m_intent = MOVE_INTENT_WALK
		else
			H.m_intent = MOVE_INTENT_RUN

		for(var/obj/machinery/door/firedoor/blocking_firelock in next_turf)
			if((blocking_firelock.flags_1 & ON_BORDER_1) && !(blocking_firelock.dir in dir_to_cardinal_dirs(reverse_dir))) //Here, only firelocks on the border matter since fulltile firelocks let you exit.
				continue
			if(!blocking_firelock.density || blocking_firelock.powered())
				continue
			if((blocking_firelock.welded))
				break	//If at least one firedoor in our way is welded shut, welp!
			blocking_firelock.open()	//Open one firelock per tile per try.
			break
		for(var/obj/machinery/door/firedoor/blocking_firelock in this_turf)
			if(!((blocking_firelock.flags_1 & ON_BORDER_1) && (blocking_firelock.dir in dir_to_cardinal_dirs(move_dir))))
				continue
			if(!blocking_firelock.density || blocking_firelock.powered())
				continue
			if(blocking_firelock.welded)
				break	//If at least one firedoor in our way is welded shut, welp!
			blocking_firelock.open()	//Open one firelock per tile per try.
			break
		for(var/obj/structure/possible_barrier in next_turf) //If we're stuck
			if(!climbable[possible_barrier.type])
				continue
			if(possible_barrier.dir == reverse_dir || istype(possible_barrier, /obj/structure/table))
				var/obj/item/dropped_it
				if(H.get_active_held_item())
					dropped_it = H.get_active_held_item()
				possible_barrier.climb_structure(H)
				if(dropped_it) //Don't forget to pick up your stuff
					H.put_in_hands(dropped_it, forced=TRUE)
			else
				continue
			if(get_turf(H) == path[1])
				increment_path()
				return TRUE
		for(var/obj/structure/possible_barrier in this_turf)
			if(!climbable[possible_barrier.type])
				continue
			if(possible_barrier.dir == move_dir || istype(possible_barrier, /obj/structure/table))
				var/obj/item/dropped_it
				if(H.get_active_held_item())
					dropped_it = H.get_active_held_item()
				possible_barrier.climb_structure(H)
				if(dropped_it) //Don't forget to pick up your stuff
					H.put_in_hands(dropped_it, forced=TRUE)
			else
				continue
			if(get_turf(H) == path[1])
				increment_path()
				return TRUE
		step_towards(H, path[1])
		if(get_turf(H) == path[1]) //Successful move
			increment_path()
			tries = 0
			if(H.resting)
				//Gotta bypass the do-after here...
				H.set_resting(FALSE, FALSE)
		else
			tries++
			return FALSE
	else if(length(path) == 1)
		step_to(H, dest)
		pathfind_to(null)
	return TRUE

/datum/component/knpc/proc/increment_path()
	path.Cut(1, 2)

///Allows the AI humans to kite around
/datum/component/knpc/proc/kite(atom/movable/target)
	if(world.time < next_move)
		return
	var/mob/living/carbon/human/ai_boarder/H = parent
	next_move = world.time + (H.move_delay * 2)
	if(!target || !isturf(target.loc) || !isturf(H.loc) || H.stat == DEAD)
		return
	var/target_dir = get_dir(H,target)
	var/static/list/cardinal_sidestep_directions = list(-90,-45,0,45,90)
	var/static/list/diagonal_sidestep_directions = list(-45,0,45)
	var/chosen_dir = 0
	if (target_dir & (target_dir - 1))
		chosen_dir = pick(diagonal_sidestep_directions)
	else
		chosen_dir = pick(cardinal_sidestep_directions)
	if(chosen_dir)
		chosen_dir = turn(target_dir,chosen_dir)
		H.Move(get_step(H,chosen_dir))
		H.face_atom(target) //Looks better if they keep looking at you when dodging

///Allows the AI actor to be revived by a medic, and get straight back into the fight!
/datum/component/knpc/proc/restart()
	SIGNAL_HANDLER
	START_PROCESSING(SSfastprocess, src)

///Resisting out of cuffs or a locked closet sleeps on a do_after, so do it outside of process() and only once at a time.
/datum/component/knpc/proc/try_resist()
	set waitfor = FALSE
	if(resisting)
		return
	resisting = TRUE
	var/mob/living/H = parent
	H.resist()
	resisting = FALSE

///Pick a goal from the available goals!
/datum/component/knpc/proc/pick_goal()
	var/best_score = -1000
	var/datum/ai_goal/chosen = null
	for(var/datum/ai_goal/human/H in ai_goals)
		var/this_score = H.check_score(src)
		if(this_score > best_score)
			chosen = H
			best_score = this_score
	if(chosen)
		chosen.assume(src)

///Add someone to our threat list when they shoot us. Shamelessly lifted from monkey AI code.
/datum/component/knpc/proc/register_bullet(datum/source, obj/item/projectile/Proj)
	SIGNAL_HANDLER
	if(istype(Proj , /obj/item/projectile/beam)||istype(Proj, /obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && isliving(Proj.firer))
				last_aggressors += Proj.firer

///Handles actioning on the goal every tick.
/datum/component/knpc/process()
	var/mob/living/carbon/human/ai_boarder/H = parent
	if(H.stat == DEAD)
		return PROCESS_KILL
	if(world.time >= next_action)
		next_action = world.time + H.action_delay
		pick_goal()
		current_goal?.action(src)
	pathfind_timeout = max(0, pathfind_timeout - SSfastprocess.wait)
	if(!H.can_resist())
		if(H.incapacitated()) //In crit or something....
			return
	if(length(path))
		next_path_step()
	else //They should always be pathing somewhere...
		next_path_step()
		dest = null
		tries = 0
		path = list()
		//Don't wander off to a patrol node in the middle of a fistfight.
		if(current_goal && !istype(current_goal, /datum/ai_goal/human/engage_targets) && !pathfind_timeout)
			current_goal.get_next_patrol_node(src)

/datum/ai_goal/human
	name = "Placeholder goal" //Please keep these human readable for debugging!
	score = 0
	required_ai_flags = null //Set this if you want this task to only be achievable by certain types of ship.

/**
Method to get the score of a certain action. This can change the "base" score if the score
of a specific action goes up, to encourage skynet to go for that one instead.

@param OM - If you want this score to be affected by the stats of an overmap.
*/
/datum/ai_goal/check_score(datum/component/knpc/HA)
	if(!istype(HA)) // why is this here >:(
		return ..()
	if(required_ai_flags && !(HA.ai_trait & required_ai_flags))
		return 0
	var/mob/M = HA.parent
	if(M.client) //AI disabled...
		return 0
	return score //Children sometimes NEED this true value to run their own checks. We also cancel here if the mob has been overtaken by someone.

///Delete the AI's last orders, tell the AI ship what to do.
/datum/ai_goal/human/assume(datum/component/knpc/HA)
	if(istype(HA, /obj/structure/overmap))
		return ..()
	//message_admins("Goal [src] chosen!")
	HA.current_goal = src

///Method that gets all the potential aggressors for this target.
/datum/ai_goal/proc/get_aggressors(datum/component/knpc/HA)
	. = list()
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	var/list/detected_objects = view(HA.view_range, HA.parent)
	var/list/guessed_objects = view(HA.guess_range, HA.parent)
	for(var/mob/living/M in guessed_objects)
		//Invis is a no go. Non-human, -cyborg or -hostile mobs are ignored.
		if(M.invisibility >= INVISIBILITY_ABSTRACT || M.alpha <= 0 || (!ishuman(M) && !iscyborg(M))) //Removed && !ishostile(M) temporarily because of Sgt. Araneus
			continue
		// Dead mobs are ignored.
		if(CHECK_BITFIELD(H.knpc_traits, KNPC_IS_MERCIFUL) && M.stat >= UNCONSCIOUS)
			continue
		else if(M.stat == DEAD)
			continue
		if(H.faction_check_mob(M))
			continue
		if(!(M in detected_objects) && !(M in HA.last_aggressors))
			continue
		. += M
	//Check for nearby mechas....
	for(var/obj/mecha/OM in guessed_objects)
		if(!ismecha(OM))
			continue
		if(OM.z != H.z)
			continue
		if(get_dist(H, OM) > HA.view_range || !can_see(H, OM, HA.view_range))
			continue
		if(OM.occupant && !H.faction_check_mob(OM.occupant))
			. += OM
	for(var/obj/structure/overmap/OM as() in GLOB.overmap_objects) //Has to go through global objects due to happening on a ship's z level.
		if(OM.z != H.z)
			continue
		if(get_dist(H, OM) > HA.view_range || !can_see(H, OM, HA.view_range))
			continue
		if(OM.pilot && !H.faction_check_mob(OM.pilot))
			. += OM

///What happens when this action is selected? You'll override this and check_score mostly.
/datum/ai_goal/human/action(datum/component/knpc/HA)
	if(istype(HA, /obj/structure/overmap))
		return ..()
	var/mob/living/carbon/human/H = HA.parent
	if(H.incapacitated() || H.client) //An admin overtook this mob or something, ignore.
		return FALSE

/datum/ai_goal/human/proc/can_action(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	return (!H.incapacitated() && !H.client) //An admin overtook this mob or something, ignore.

/**
Goal #1, get a weapon!
If we don't have a weapon, we really ought to grab one...
This is to account for sec Ju-Jitsuing boarding commandos.
*/
/datum/ai_goal/human/acquire_weapon
	name = "Acquire Weapon" //Please keep these human readable for debugging!
	score = AI_SCORE_PRIORITY //Fighting takes priority
	required_ai_flags = null //Set this if you want this task to only be achievable by certain types of ship.

/datum/ai_goal/human/acquire_weapon/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	var/obj/A = H.get_active_held_item()
	var/obj/B = H.get_inactive_held_item() //check your other hand, just in case.
	//We already have a gun
	if((A && istype(A, /obj/item/gun)) || (B && istype(B, /obj/item/gun)))
		return 0
	for(var/obj/item/gun/G in view(HA.view_range, H))
		if(gun_suitable(H, G) && !is_unreachable(HA, G))
			return AI_SCORE_CRITICAL //There is a gun really obviously in the open....
	if(find_carried_gun(H) || find_nearby_gun(HA))
		return score
	return 0 //Nothing to grab, so go patrol (or punch people) instead.

///Returns a usable gun we carry on our person or in our backpack, if any.
/datum/ai_goal/human/acquire_weapon/proc/find_carried_gun(mob/living/carbon/human/H)
	var/list/expanded_contents = H.contents.Copy()
	var/obj/item/storage/S = H.back
	if(S)
		expanded_contents += S.contents
	for(var/obj/item/gun/G in expanded_contents)
		if(H.is_holding(G))
			continue
		if(gun_suitable(H, G))
			return G

///Returns the closest usable gun in view, lying around or stashed in a closet we can open.
/datum/ai_goal/human/acquire_weapon/proc/find_nearby_gun(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	var/obj/item/gun/target_item = null
	var/best_distance = world.maxx
	for(var/obj/O in oview(HA.view_range, H))
		var/dist = get_dist(O, H)
		if(dist > best_distance)
			continue
		var/obj/item/gun/G = null
		if(istype(O, /obj/structure/closet))
			var/obj/structure/closet/C = O
			if(!C.allowed(H))
				continue
			G = locate(/obj/item/gun) in C.contents
		else if(istype(O, /obj/item/gun))
			G = O
		if(G && gun_suitable(H, G) && !is_unreachable(HA, G))
			target_item = G
			best_distance = dist
	return target_item

/datum/ai_goal/human/acquire_weapon/proc/is_unreachable(datum/component/knpc/HA, obj/item/I)
	return (WEAKREF(I) in HA.unreachable_items)

/datum/ai_goal/human/proc/CheckFriendlyFire(mob/living/us, mob/living/them)
	for(var/turf/T as() in getline(us,them)) // Not 100% reliable but this is faster than simulating actual trajectory
		for(var/mob/living/L in T)
			if(L == us || L == them)
				continue
			if(us.faction_check_mob(L))
				return TRUE

/datum/ai_goal/human/acquire_weapon/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/obj/item/storage/S = H.back
	var/obj/item/gun/target_item = null
	//We must have lost our gun somehow, get it from the floor if we simply dropped it.
	if(istype(H.loc, /turf))
		var/turf/T = H.loc
		for(var/obj/item/gun/G in T.contents)
			if(gun_suitable(H, G))
				target_item = G
				break
		if(target_item && H.put_in_hands(target_item))
			return TRUE
	//Otherwise, is there a gun already on our person?
	target_item = find_carried_gun(H)
	if(target_item)
		H.visible_message("<span class='notice'>[H] grzebie w plecaku...</span>")
		if(target_item.loc == H) //Equipped in a slot, unequip it properly first
			H.temporarilyRemoveItemFromInventory(target_item)
		if(H.put_in_hands(target_item))
			return TRUE //We're done!
	//Now we run the more expensive check to find a gun farther away.
	target_item = find_nearby_gun(HA)
	if(target_item)
		var/dist = get_dist(H, target_item)
		if(dist > 1)
			if(HA.pathfind_to(target_item) == KNPC_PATHFIND_FAIL)
				LAZYADD(HA.unreachable_items, WEAKREF(target_item))
		else
			if(istype(target_item.loc, /obj/structure/closet))
				var/obj/structure/closet/C = target_item.loc
				if(C.open(H))
					H.visible_message("<span class='notice'>[H] otwiera [C]...</span>")
			if(istype(target_item, /obj/item/gun/ballistic))
				var/obj/item/gun/ballistic/B = target_item
				var/obj/item/ammo_box/magazine/M = locate(B.mag_type) in oview(3, target_item)
				if(M && S) //If they have a backpack, put the ammo in the backpack.
					SEND_SIGNAL(S, COMSIG_TRY_STORAGE_INSERT, M, H, TRUE)

			if(H.put_in_hands(target_item))
				H.visible_message("<span class='warning'>[H] grabs [target_item]!</span>")

///Checks that G exists, has ammo and that H can fire it. Returns G if yes, FALSE otherwise.
/datum/ai_goal/human/acquire_weapon/proc/gun_suitable(mob/living/carbon/human/H, obj/item/gun/G)
	return G.can_shoot() && G.can_trigger_gun(H)


/datum/ai_goal/human/engage_targets
	name = "Engage targets"
	score = AI_SCORE_SUPERPRIORITY //If we find a target, we want to engage!
	required_ai_flags = null

/datum/ai_goal/human/engage_targets/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/list/enemies = get_aggressors(HA)
	HA.last_aggressors = enemies
	//We have people to fight
	if(length(enemies) >= 1)
		return score
	return 0 //You can still fight with your bare hands...

/datum/ai_goal/human/proc/reload(datum/component/knpc/HA, obj/item/gun)
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	if(istype(gun, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = gun
		if(E.selfcharge) //Okay good, it self charges we can just wait.
			return TRUE
		else //Discard it, we're not gonna teach them to use rechargers yet.
			H.dropItemToGround(E)
		return FALSE
	if(istype(gun, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/B = gun
		//Still got rounds, we just need to chamber one (pump shotguns, freshly inserted mags).
		if(B.magazine?.ammo_count() && !istype(B, /obj/item/gun/ballistic/revolver))
			B.attack_self(H)
			return TRUE
		if(ispath(B.mag_type, /obj/item/ammo_box/magazine/internal))
			//Not dealing with this. They'll just ditch the revolver when they're done with it.
			H.dropItemToGround(B)
			return FALSE
		var/obj/item/storage/backpack = H.back
		//Okay first off, is the gun already on our person?
		var/list/expanded_contents = H.contents
		if(backpack)
			expanded_contents = backpack.contents + H.contents
		var/obj/item/ammo_box/magazine/target_mag = null
		for(var/obj/item/ammo_box/magazine/M in expanded_contents)
			if(istype(M, B.mag_type) && M != B.magazine && M.ammo_count())
				target_mag = M
				break
		if(target_mag)
			if(B.magazine)
				B.eject_magazine(H, FALSE, target_mag) //Tacticool reloads
			else
				B.insert_magazine(H, target_mag, FALSE)
			for(var/obj/item/ammo_box/magazine/old_mag in H.held_items)
				H.dropItemToGround(old_mag) //We don't need that magazine anymore
			B.attack_self(H) //Rack the bolt.
			return TRUE
		else
			//Out of ammo, this is useless to us so drop it and go find another one.
			H.dropItemToGround(B)
			return FALSE

/datum/ai_goal/human/engage_targets/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	HA.last_node = null //Reset their pathfinding
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	var/list/enemies = get_aggressors(HA)
	var/obj/item/A = H.get_active_held_item()
	var/closest_dist = 1000
	var/mob/living/target = null
	for(var/mob/living/L as() in enemies)
		var/dist = get_dist(L, H)
		if(dist < closest_dist)
			closest_dist = dist
			target = L
	if(!target)
		return
	var/dist = get_dist(H, target)
	//We're holding a gun. See if we can shoot it....
	HA.pathfind_to(target) //Walk up close and YEET SLAM
	var/obj/item/gun/G = null
	if(istype(A, /obj/item/gun))
		G = A
	var/obj/item/gun/ballistic/B = null
	if(istype(A, /obj/item/gun/ballistic))
		B = A
	H.a_intent = (prob(65)) ? INTENT_HARM : INTENT_DISARM
	if(G && dist > 0)
		//We need to reload first.... If that fails we've ditched the gun.
		if(!G.can_shoot() && !reload(HA, G))
			G = null
		//Fire! If they're in a ship, we don't want to scrap them directly.
		if(G && !CheckFriendlyFire(H, target))
			//Okay, we have a line of sight, shoot!
			if(B && !(B.semi_auto) && !G.chambered)
				//Pump the shotty
				G.attack_self(H)
			//Let's help them use E-Guns....
			if(istype(G, /obj/item/gun/energy/e_gun))
				var/obj/item/gun/energy/e_gun/E = G
				if(prob(20))
					E.select_fire(H)

			if(isobj(target.loc))
				G.afterattack(target.loc, H)
			else
				G.afterattack(target, H)
	//Call your friends to help :))
	if(world.time >= HA.next_backup_call)
		call_backup(HA)

	if(dist <= 1)
		if(A && !istype(A, /obj/item/gun) && A.force > 0)
			target.attackby(A, H)
			A.afterattack(target, H, TRUE)

		else
			//Stop them from trying to knee a mech in the stomach
			if(iscarbon(target))
				H.dna.species.spec_attack_hand(H, target)
				if(target.incapacitated())
					//I know kung-fu.

					var/obj/item/card/id/their_id = target.get_idcard()
					if(their_id && !HA.stealing_id)
						H.visible_message("<span class='warning'>[H] zaczyna zabierać [their_id] z [target]!</span>")
						HA.stealing_id = TRUE
						addtimer(CALLBACK(HA, TYPE_PROC_REF(/datum/component/knpc, steal_id), their_id, target), 5 SECONDS)

					if(istype(H) && CHECK_BITFIELD(H.knpc_traits, KNPC_IS_MARTIAL_ARTIST))
						switch(rand(0, 2))
							//Throw!
							if(0)
								H.start_pulling(target, supress_message = FALSE)
								H.setGrabState(GRAB_AGGRESSIVE)
								H.visible_message("<span class='warning'>[H] rzuca [target] judo!</span>")
								playsound(get_turf(target), 'nsv13/sound/effects/judo_throw.ogg', 100, TRUE)
								target.shake_animation(10)
								target.throw_at(get_turf(get_step(H, pick(GLOB.cardinals))), 5, 5)
							if(1)
								H.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
								target.visible_message("<span class='warning'>[H] chwyta [target] za nadgarstek i wykręca go w bok!</span>", \
												"<span class='userdanger'>[H] chwyta cię za nadgarstek i gwałtownie wykręca go w bok!</span>")
								playsound(get_turf(H), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
								target.emote("scream")
								target.dropItemToGround(target.get_active_held_item())
								target.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
							if(2)
								H.do_attack_animation(target, ATTACK_EFFECT_KICK)
								target.visible_message("<span class='warning'>[H] wbija [target] kolano w brzuch!</span>", \
												"<span class='userdanger'>[H] pozbawia cię tchu kolanem w brzuch!</span>")
								target.audible_message("<b>[target]</b> gags!")
								target.losebreath += 3

					else
						//So they actually execute the curbstomp.
						if(dist <= 1)
							H.forceMove(get_turf(target))
						H.zone_selected = BODY_ZONE_HEAD
						//Curbstomp!
						H.MouseDrop(target)
						return
			else
				//Used when punching non-carbon targets
				H.UnarmedAttack(target)

		if(CHECK_BITFIELD(H.knpc_traits, KNPC_IS_DODGER))
			HA.kite(target)

/datum/ai_goal/human/proc/call_backup(datum/component/knpc/HA)
	HA.next_backup_call = world.time + 30 SECONDS //So it's not horribly spammy.
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	var/obj/item/radio/headset/radio = H.ears
	H.do_alert_animation(H)
	playsound(H, 'sound/machines/chime.ogg', 50, 1, -1)
	//Lets the AIs call for help over comms... This is quite deadly.
	var/support_text = (radio) ? "; " : ""
	if(CHECK_BITFIELD(H.knpc_traits, KNPC_IS_AREA_SPECIFIC))
		var/text = pick(H.call_lines)
		text += " [get_area(H)]!"
		support_text += text
	else
		support_text += pick(H.call_lines)
	H.say(support_text, forced = "knpc AI")

	// Call for other intelligent AIs
	for(var/datum/component/knpc/HH as() in GLOB.knpcs - HA)
		var/mob/living/carbon/human/ai_boarder/other = HH.parent
		var/obj/item/radio/headset/other_radio = other.ears
		if(other.z != H.z || !other.can_hear() || other.incapacitated())
			continue //Yeah no. Radio is good, but not THAT good....yet
		if(!H.faction_check_mob(other, TRUE))
			continue //Don't call the enemy over.
		//They both have radios and can hear each other!
		if((radio?.on && other_radio?.on) || get_dist(other, H) <= HA.view_range)
			var/thetext = (other_radio) ? "; " : ""
			thetext += pick(H.response_lines)
			HH.pathfind_to(H)
			other.say(thetext, forced = "knpc AI")
	//Firstly! Call for the simplemobs..
	for(var/mob/living/simple_animal/hostile/M in oview(HA.view_range, HA.parent))
		if(H.faction_check_mob(M, TRUE))
			if(M.AIStatus == AI_OFF)
				continue
			else
				M.Goto(HA.parent,M.move_to_delay,M.minimum_distance)

/datum/ai_goal/human/patrol
	name = "Patrol Nodes"
	score = AI_SCORE_LOW_PRIORITY //The default task for most AIs is to just patrol
	required_ai_flags = null //Set this if you want this task to only be achievable by certain types of ship.


/datum/ai_goal/human/patrol/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	if(HA.last_node && get_dist(HA.last_node, H) > 2)
		HA.pathfind_to(HA.last_node) //Restart pathfinding
		return FALSE
	get_next_patrol_node(HA)

/obj/effect/landmark/patrol_node
	name = "AI patrol node"
	icon = 'nsv13/icons/effects/mapping_helpers.dmi'
	icon_state = "patrol_node"
	var/id = null
	var/next_id = null //id of the node that this one goes to. Alternatively, a list of ids which will all be possible next destinations.
	var/previous_id = null //id of the node that precedes this one
	var/obj/effect/landmark/patrol_node/previous //-- This isn't actually used anywhere.. - Delta
	var/list/next_nodes	= list() //List of possible followup nodes set by next_id. If multiple entities exist in the list, one will be chosen at random on every occasion.

/obj/effect/landmark/patrol_node/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/patrol_node/LateInitialize()
	. = ..()
	for(var/obj/effect/landmark/patrol_node/node in GLOB.landmarks_list)
		if(!node.id)
			continue
		if(next_id)
			if(islist(next_id))
				var/list/next_id_list = next_id
				if(node.id in next_id_list)
					next_nodes += node
			else
				if(node.id == next_id)
					next_nodes += node
		if(previous_id && node.id == previous_id)
			previous = node
	if(next_id && !length(next_nodes))
		CRASH("WARNING: Patrol node in [get_area(src)] has no next node(s) despite set id(s).")
	if(previous_id && !previous)
		CRASH("WARNING: Patrol node in [get_area(src)] has no previous node despite a set id.")

/datum/ai_goal/human/proc/get_next_patrol_node(datum/component/knpc/HA)
	//Okay, we need to pick a starting point.
	var/mob/living/carbon/human/ai_boarder/H = HA.parent
	if(!HA.last_node)
		var/best_dist = 10000
		var/obj/effect/landmark/patrol_node/best
		for(var/obj/effect/landmark/patrol_node/node in GLOB.landmarks_list)
			var/dist = get_dist(H, node.loc)
			if(dist < best_dist && node.z == H.z)
				best_dist = dist
				best = node
		if(!best)
			return
		HA.last_node = best
		//Start the patrol. If we're already standing on the node, move straight on to the next one.
		if(best_dist > 1)
			HA.pathfind_to(best)
			return

	if(!length(HA.last_node.next_nodes)) //Dead end, nowhere to go from here.
		return
	var/obj/effect/landmark/patrol_node/next_node = pick(HA.last_node.next_nodes)
	if(HA.last_node.z != next_node.z)
		var/obj/structure/ladder/L = locate(/obj/structure/ladder) in get_turf(HA.last_node)
		if(!L)
			L = locate(/obj/structure/ladder) in orange(1, get_turf(HA.last_node))
		if(L)
			//Use the ladder....
			if(next_node.z > HA.last_node.z)
				L.travel(TRUE, H, FALSE, L.up, FALSE)
			else
				L.travel(FALSE, H, FALSE, L.down, FALSE)
		//No Ladder, lets check for stairs
		else if(!L && next_node.z > HA.last_node.z) //If going up a Z
			var/obj/structure/stairs/S = locate(/obj/structure/stairs) in orange(1, get_turf(HA.last_node))
			if(S)
				step_towards(H, S)
				step(H, S.dir)
		else //If down
			var/obj/structure/stairs/S = locate(/obj/structure/stairs) in orange(1, get_step_multiz(get_turf(HA.last_node), DOWN))
			if(S)
				step_towards(H, S)

	HA.last_node = next_node
	HA.pathfind_to(next_node)

/datum/ai_goal/human/set_internals
	name = "Set Internals"
	score = AI_SCORE_CRITICAL //The lads need to be able to breathe.
	required_ai_flags = null

/datum/ai_goal/human/set_internals/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	//We need to breathe....
	if(H.failed_last_breath && world.time >= HA.next_internals_attempt)
		HA.next_internals_attempt = world.time + 5 SECONDS
		var/obj/item/storage/S = H.back
		if(S && locate(/obj/item/tank/internals) in S.contents + H.contents)
			return score
	return 0

/datum/ai_goal/human/set_internals/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/ai_boarder/C = HA.parent

	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
	else
		if(!C.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(!istype(C.wear_mask))
				return 1
			else
				var/obj/item/clothing/mask/M = C.wear_mask
				if(M.mask_adjusted) // if mask on face but pushed down
					M.adjustmask(C) // adjust it back
				if(!(M.clothing_flags & MASKINTERNALS))
					return

		var/obj/item/I = C.is_holding_item_of_type(/obj/item/tank)
		if(I)
			C.internal = I
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.internal = locate(/obj/item/tank/internals) in H

		//Separate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/tank))
			C.internal = C.back

/datum/ai_goal/human/stop_drop_n_roll
	name = "Stop drop & roll"
	score = AI_SCORE_HIGH_PRIORITY //Putting out fires is important, but not more important than killing the target setting us on fire
	required_ai_flags = null

/datum/ai_goal/human/stop_drop_n_roll/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	//We need to breathe....
	if(H.fire_stacks > 0)
		return score
	return 0

/datum/ai_goal/human/stop_drop_n_roll/action(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	if(!can_action(HA))
		return
	H.resist() //Stop drop and roll!

/datum/ai_goal/human/escape_custody
	name = "Escape Custody"
	score = AI_SCORE_CRITICAL //Not being contained is fairly important
	required_ai_flags = null

/datum/ai_goal/human/escape_custody/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(istype(H.loc, /obj/structure/closet)) //Check if we are in a closet
		return score
	if(H.handcuffed || H.buckled || H.legcuffed) //Or locked up somehow
		return score
	return 0

/datum/ai_goal/human/escape_custody/action(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	if(!H.can_resist()) //We use a different check here
		return

	if(istype(H.loc, /obj/structure/closet))
		var/obj/structure/closet/C = H.loc
		if(!C.open(H)) //Open that closet
			HA.try_resist() //Locked or welded, break out instead
			return
	if(H.handcuffed || H.buckled || H.legcuffed)
		HA.try_resist() //Trigger the universal escape button

/datum/ai_goal/human/heal_self
	name = "Heal Self"
	score = AI_SCORE_PRIORITY //Heal ourselves if outside of combat
	required_ai_flags = null

/datum/ai_goal/human/heal_self/check_score(datum/component/knpc/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	if(H.health <= (H.maxHealth / 2)) //If half health
		if(find_pen(H)) //And has survival pen
			return score
	return 0

///Returns a loaded survival medipen on our person or in our backpack, if any.
/datum/ai_goal/human/heal_self/proc/find_pen(mob/living/carbon/human/H)
	var/list/expanded_contents = H.contents.Copy() //Copy! Adding to the real contents list would move the items.
	var/obj/item/storage/S = H.back
	if(S)
		expanded_contents += S.contents
	for(var/obj/item/reagent_containers/hypospray/medipen/survival/P in expanded_contents)
		if(P.reagents?.total_volume)
			return P

/datum/ai_goal/human/heal_self/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/obj/item/reagent_containers/hypospray/medipen/survival/P = find_pen(H)
	if(!P)
		return
	P.attack(H, H) //Roll Up Your Sleeve, Self Vax
	//Litter because doing one good thing is enugh for today
	if(P.loc == H)
		H.dropItemToGround(P)
	else
		SEND_SIGNAL(P.loc, COMSIG_TRY_STORAGE_TAKE, P, H.drop_location(), TRUE)

//Alternate capture reaction for those with microbombs.
/datum/ai_goal/human/deny_capture
	name = "Deny Capture"
	score = AI_SCORE_SUPERCRITICAL
	required_ai_flags = NONE

/datum/ai_goal/human/deny_capture/check_score(datum/component/knpc/HA)
	. = ..()
	if(!.)
		return 0
	var/mob/living/carbon/human/knpc_mob = HA.parent
	if(!(locate(/datum/action/item_action/explosive_implant) in knpc_mob.actions))
		return 0
	if(knpc_mob.handcuffed || knpc_mob.get_num_arms() == 0 || knpc_mob.IsUnconscious() || knpc_mob.IsSleeping() || (knpc_mob.stat && knpc_mob.health <= -20))
		if(!HA.failsafe_timer)
			HA.failsafe_timer = world.time
		else if(world.time - HA.failsafe_timer >= HA.failsafe_trust)
			return score
	else
		HA.failsafe_timer = 0
	return 0

//Override.
/datum/ai_goal/human/deny_capture/action(datum/component/knpc/HA)
	var/mob/living/carbon/human/knpc_mob = HA.parent
	if(QDELETED(knpc_mob) || knpc_mob.client)
		return
	var/datum/action/item_action/explosive_implant/boom_action = (locate() in knpc_mob.actions)
	if(!boom_action) //Guh?
		return
	if(knpc_mob.stat == CONSCIOUS)
		knpc_mob.say(pick("Żadnego odwrotu, żadnej kapitulacji!", "NIGDY NIE WEŹMIECIE MNIE ŻYWCEM!!", "MASZ!!"), forced = "knpc AI")
	boom_action.Trigger()


#undef AI_TRAIT_BRAWLER
#undef AI_TRAIT_SUPPORT
