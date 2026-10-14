// AQUILA - nawiedzone przedmioty z tg (code/modules/antagonists/revenant/haunted_item.dm + code/datums/ai/hauntium)
// Rewenant rzuca na nie Haunt Object: unoszą się, świecą i rzucają się na ludzi w pobliżu.
// Zachowania item_escape_grasp i item_move_close_and_attack/haunted mamy już w code/datums/ai/_item_behaviors.dm,
// brakowało samego kontrolera, więc tu jest jego wersja na nasz stary framework z planning_subtrees.

/// Czy przedmiot lubi tego, kto go trzyma (nieumarli), wtedy się nie wyrywa
#define BB_LIKES_EQUIPPER "BB_likes_equipper"

/datum/ai_controller/haunted
	movement_delay = 0.4 SECONDS
	blackboard = list(
		BB_TO_HAUNT_LIST = list(),
		BB_LIKES_EQUIPPER = FALSE,
		BB_HAUNT_TARGET = null,
		BB_HAUNTED_THROW_ATTEMPT_COUNT = 0,
	)
	planning_subtrees = list(/datum/ai_planning_subtree/haunted)

/datum/ai_controller/haunted/TryPossessPawn(atom/new_pawn)
	if(!isitem(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	return ..()

/datum/ai_controller/haunted/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	return ..()

/// Ktoś podniósł przedmiot: żywy trafia na listę nawiedzanych, nieumarłego przedmiot polubi
/datum/ai_controller/haunted/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_ITEM_EQUIPPED)
	var/haunt_equipper = TRUE
	if(isliving(equipper))
		var/mob/living/possibly_cool = equipper
		if(MOB_UNDEAD in possibly_cool.mob_biotypes)
			haunt_equipper = FALSE
	if(haunt_equipper)
		var/list/hauntee_list = blackboard[BB_TO_HAUNT_LIST]
		hauntee_list[equipper] += HAUNTED_ITEM_AGGRO_ADDITION
	else
		blackboard[BB_LIKES_EQUIPPER] = TRUE
	RegisterSignal(pawn, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/datum/ai_controller/haunted/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	blackboard[BB_LIKES_EQUIPPER] = FALSE
	RegisterSignal(pawn, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	UnregisterSignal(pawn, COMSIG_ITEM_DROPPED)

/// Bez celu co jakiś czas przeskakuje w inne miejsce
/datum/ai_controller/haunted/PerformIdleBehavior(delta_time)
	var/obj/item/item_pawn = pawn
	if(ismob(item_pawn.loc) || !isturf(item_pawn.loc))
		return
	if(DT_PROB(HAUNTED_ITEM_TELEPORT_CHANCE, delta_time))
		playsound(item_pawn.loc, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
		#ifndef UNIT_TESTS // teleport mógłby wynieść przedmiot poza pokój testowy
		do_teleport(item_pawn, get_turf(item_pawn), 4, channel = TELEPORT_CHANNEL_MAGIC)
		#endif

/datum/ai_planning_subtree/haunted

/datum/ai_planning_subtree/haunted/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/obj/item/item_pawn = controller.pawn
	if(ismob(item_pawn.loc)) // ktoś nas trzyma, może się wyrwiemy
		if(controller.blackboard[BB_LIKES_EQUIPPER])
			return SUBTREE_RETURN_FINISH_PLANNING
		if(DT_PROB(HAUNTED_ITEM_ESCAPE_GRASP_CHANCE, delta_time))
			controller.queue_behavior(/datum/ai_behavior/item_escape_grasp)
		return SUBTREE_RETURN_FINISH_PLANNING
	if(!isturf(item_pawn.loc))
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!DT_PROB(HAUNTED_ITEM_ATTACK_HAUNT_CHANCE, delta_time))
		return
	var/list/to_haunt_list = controller.blackboard[BB_TO_HAUNT_LIST]
	for(var/mob/living/potential_target as anything in to_haunt_list)
		if(QDELETED(potential_target) || to_haunt_list[potential_target] <= 0)
			to_haunt_list -= potential_target
			continue
		if(get_dist(potential_target, item_pawn) <= CURSED_VIEW_RANGE)
			controller.blackboard[BB_HAUNT_TARGET] = potential_target
			controller.queue_behavior(/datum/ai_behavior/item_move_close_and_attack/haunted, BB_HAUNT_TARGET, BB_HAUNTED_THROW_ATTEMPT_COUNT)
			return SUBTREE_RETURN_FINISH_PLANNING

/// Nawiedzony przedmiot: świeci, unosi się i atakuje rzucając się na ludzi, dopóki nie minie czas albo ktoś go nie oczyści
/datum/component/haunted_item
	/// Siła rzutu przed nawiedzeniem
	var/pre_haunt_throwforce
	/// Komunikat po zniknięciu nawiedzenia
	var/despawn_message
	/// Czym da się rozproszyć nawiedzenie
	var/list/types_which_dispell_us

/datum/component/haunted_item/Initialize(
	haunt_color = "#f8f8ff",
	haunt_duration,
	aggro_radius,
	spawn_message,
	despawn_message,
	throw_force_bonus = 3,
	throw_force_max = 15,
	list/types_which_dispell_us,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/haunted_item = parent
	if(istype(haunted_item.ai_controller, /datum/ai_controller/haunted)) // już straszy
		return COMPONENT_INCOMPATIBLE

	haunted_item.add_filter("haunt_glow", 2, list("type" = "outline", "color" = haunt_color, "size" = 1))
	haunted_item.ai_controller = new /datum/ai_controller/haunted(haunted_item)
	if(isturf(haunted_item.loc))
		haunted_item.float(TRUE)

	if(!isnull(haunt_duration))
		addtimer(CALLBACK(src, PROC_REF(clear_haunting)), haunt_duration)

	if(!isnull(spawn_message))
		haunted_item.visible_message(spawn_message)

	if(!isnull(aggro_radius))
		// Każdy w zasięgu dostaje 5 punktów nawiedzenia, podniesienie przedmiotu daje 2
		var/list/hauntee_list = haunted_item.ai_controller.blackboard[BB_TO_HAUNT_LIST]
		for(var/mob/living/victim in view(aggro_radius, haunted_item))
			if(victim.stat >= SOFT_CRIT)
				continue
			if(MOB_SPIRIT in victim.mob_biotypes)
				continue
			if(victim.invisibility >= INVISIBILITY_REVENANT)
				continue
			hauntee_list[victim] += 5

	if(haunted_item.throwforce < throw_force_max)
		pre_haunt_throwforce = haunted_item.throwforce
		haunted_item.throwforce = min(haunted_item.throwforce + throw_force_bonus, throw_force_max)

	var/static/list/default_dispell_types = list(/obj/item/nullrod, /obj/item/storage/book/bible)
	src.types_which_dispell_us = types_which_dispell_us || default_dispell_types
	src.despawn_message = despawn_message

/datum/component/haunted_item/Destroy(force, silent)
	var/obj/item/haunted_item = parent
	// Tu, a nie w clear_haunting(), żeby sprzątnąć niezależnie od tego, jak komponent zniknął
	if(!isnull(pre_haunt_throwforce))
		haunted_item.throwforce = pre_haunt_throwforce
	haunted_item.remove_filter("haunt_glow")
	if(istype(haunted_item.ai_controller, /datum/ai_controller/haunted))
		QDEL_NULL(haunted_item.ai_controller)
	haunted_item.float(FALSE)
	return ..()

/datum/component/haunted_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_hit_by_holy_tool))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_THROW_LANDED), PROC_REF(start_floating))

/datum/component/haunted_item/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_THROW_LANDED))

/datum/component/haunted_item/proc/on_equipped(datum/source)
	SIGNAL_HANDLER
	var/obj/item/haunted_item = parent
	haunted_item.float(FALSE)

/// Po upuszczeniu albo wylądowaniu rzutu znowu się unosi
/datum/component/haunted_item/proc/start_floating(datum/source)
	SIGNAL_HANDLER
	var/obj/item/haunted_item = parent
	if(!isturf(haunted_item.loc))
		return
	haunted_item.float(FALSE)
	haunted_item.float(TRUE)

/// Zdejmuje nawiedzenie, pokazuje komunikat i usuwa komponent
/datum/component/haunted_item/proc/clear_haunting()
	var/obj/item/haunted_item = parent
	if(!isnull(despawn_message))
		haunted_item.visible_message(despawn_message)
	qdel(src)

/// Uderzenie świętym przedmiotem rozprasza nawiedzenie
/datum/component/haunted_item/proc/on_hit_by_holy_tool(obj/item/source, obj/item/attacking_item, mob/living/attacker, params)
	SIGNAL_HANDLER
	if(!is_type_in_list(attacking_item, types_which_dispell_us))
		return
	attacker.visible_message("<span class='warning'>[attacker] rozprasza upiorną energię z [source]!</span>", "<span class='warning'>Rozpraszasz upiorną energię z [source]!</span>")
	clear_haunting()
	return COMPONENT_NO_AFTERATTACK

#undef BB_LIKES_EQUIPPER
