// AQUILA - komponenty darkspawna (port z Yogstation)

/// Zwiadowca przechodzi przez ściany i drzwi, gdy po drugiej stronie jest ciemno
/datum/component/darkspawn_shadow_walk

/datum/component/darkspawn_shadow_walk/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/darkspawn_shadow_walk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(handle_move))
	ADD_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, type)

/datum/component/darkspawn_shadow_walk/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLIENT_PRE_MOVE)
	REMOVE_TRAIT(parent, TRAIT_SILENT_FOOTSTEPS, type)

/datum/component/darkspawn_shadow_walk/proc/handle_move(mob/living/source, turf/destination)
	SIGNAL_HANDLER
	if(!istype(destination) || !istype(source.loc, /turf))
		return
	var/mob/living/carbon/human/H = source
	if(!ishuman(H) || !istype(H.dna?.species, /datum/species/darkspawn))
		return
	// Zwykły ruch, kiedy nic nie stoi na drodze
	if(!destination.density && !is_blocked_turf(destination, TRUE) && source.loc.Exit(source, destination))
		return
	if(istype(destination, /turf/closed/mineral) || isspaceturf(destination))
		return
	if(destination.get_lumcount() > DARKSPAWN_DIM_LIGHT)
		return
	var/atom/movable/pulled = source.pulling
	if(pulled && (pulled.anchored || isliving(pulled)))
		source.stop_pulling()
		pulled = null
	source.forceMove(destination)
	if(pulled)
		pulled.forceMove(get_turf(source))
		source.start_pulling(pulled, supress_message = TRUE)
	if(source.client)
		source.client.move_delay = world.time + source.movement_delay()
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Zwiadowca z Sigilami wędrówki biega szybciej w ciemności
/datum/component/darkspawn_shadow_step
	var/speedboost = -0.7

/datum/component/darkspawn_shadow_step/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/darkspawn_shadow_step/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(apply_darkness_speed))

/datum/component/darkspawn_shadow_step/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	var/mob/living/owner = parent
	owner.remove_movespeed_modifier(type)

/datum/component/darkspawn_shadow_step/proc/apply_darkness_speed(mob/living/owner)
	SIGNAL_HANDLER
	var/turf/T = get_turf(owner)
	if(T && T.get_lumcount() < DARKSPAWN_BRIGHT_LIGHT)
		owner.add_movespeed_modifier(type, update = TRUE, priority = 100, multiplicative_slowdown = speedboost, override = TRUE)
	else
		owner.remove_movespeed_modifier(type)

/// Zjada światło wszystkiego, w co się nim uderzy (broń, mob, pocisk)
/datum/component/darkspawn_light_eater

/datum/component/darkspawn_light_eater/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/darkspawn_light_eater/RegisterWithParent()
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_item_afterattack))
	if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, PROC_REF(on_mob_attack))
	if(istype(parent, /obj/item/projectile))
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_projectile_hit))

/datum/component/darkspawn_light_eater/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_ATTACKINGTARGET, COMSIG_PROJECTILE_SELF_ON_HIT))

/datum/component/darkspawn_light_eater/proc/on_item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag)
	SIGNAL_HANDLER
	if(proximity_flag)
		devour(target)

/datum/component/darkspawn_light_eater/proc/on_mob_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER
	devour(target)

/datum/component/darkspawn_light_eater/proc/on_projectile_hit(datum/source, atom/firer, atom/target, angle)
	SIGNAL_HANDLER
	devour(target)

/datum/component/darkspawn_light_eater/proc/devour(atom/target)
	if(QDELETED(target) || isturf(target))
		return
	if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/lamp = target
		if(lamp.status == LIGHT_OK)
			lamp.visible_message("<span class='danger'>[lamp] gaśnie, pochłonięta przez cień!</span>")
			lamp.break_light_tube()
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, lighteater_act), null)

/// Po Sakramencie: fioletowa zasłona na ekranie wszystkich na stacji
/datum/component/shadowlands
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/shadowlands/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shadowlands/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_fullscreen))
	update_fullscreen()

/datum/component/shadowlands/UnregisterFromParent()
	var/mob/living/owner = parent
	owner.clear_fullscreen("shadowlands")
	UnregisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED)

/datum/component/shadowlands/proc/update_fullscreen()
	SIGNAL_HANDLER
	var/mob/living/owner = parent
	var/turf/location = get_turf(owner)
	if(location && !is_centcom_level(location.z) && !is_reserved_level(location.z))
		owner.overlay_fullscreen("shadowlands", /atom/movable/screen/fullscreen/shadowlands)
	else
		owner.clear_fullscreen("shadowlands")

/atom/movable/screen/fullscreen/shadowlands
	icon = 'aquila/icons/mob/darkspawn/shadowlands.dmi'
	icon_state = "shadowlands"
	layer = CURSE_LAYER
	plane = FULLSCREEN_PLANE
