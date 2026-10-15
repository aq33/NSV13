// AQUILA - port of tgstation#88217 (IV drips pull you closer)

/// "Tugs" an atom towards another atom. That is to say, it will visually
/// pixel offset to look like it is close to the point it's tugging to,
/// but not actually move position.
/datum/component/tug_towards
	// If multiple are specified, will tug in between them.
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// atom -> strength
	var/list/tugging_to_targets = list()
	var/current_tug_offset_x = 0
	var/current_tug_offset_y = 0

/datum/component/tug_towards/Initialize(atom/tugging_to, strength)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	ASSERT(istype(tugging_to))

	add_tugging_to_target(tugging_to, strength)

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_tug))

/datum/component/tug_towards/Destroy(force)
	tugging_to_targets.Cut()

	animate(
		parent,
		pixel_x = -current_tug_offset_x,
		pixel_y = -current_tug_offset_y,
		time = 0.2 SECONDS,
		flags = ANIMATION_RELATIVE
	)

	return ..()

/datum/component/tug_towards/InheritComponent(datum/component/tug_towards/new_tug_towards, i_am_original, atom/tugging_to, strength)
	add_tugging_to_target(tugging_to, strength)

/datum/component/tug_towards/proc/remove_tug_target(atom/target)
	tugging_to_targets -= target

	if (tugging_to_targets.len == 0)
		qdel(src)
	else
		update_tug()

/datum/component/tug_towards/proc/add_tugging_to_target(atom/tugging_to, strength = 0.8)
	tugging_to_targets[tugging_to] = strength
	RegisterSignal(tugging_to, COMSIG_PARENT_PREQDELETED, PROC_REF(on_tugging_to_qdeleting))
	RegisterSignal(tugging_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_tug))

	update_tug()

/datum/component/tug_towards/proc/on_tugging_to_qdeleting(datum/target)
	SIGNAL_HANDLER

	tugging_to_targets -= target
	if (tugging_to_targets.len == 0)
		qdel(src)
	else
		update_tug()

/datum/component/tug_towards/proc/update_tug()
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	var/mob/mob_parent = parent

	var/total_tug_x = 0
	var/total_tug_y = 0

	if (!istype(mob_parent) || !mob_parent.buckled)
		var/tuggers = 0

		for (var/atom/target as anything in tugging_to_targets)
			if (target.z != atom_parent.z)
				continue

			tuggers += 1
			var/strength = tugging_to_targets[target]
			total_tug_x += SIGN(target.x - atom_parent.x) * strength
			total_tug_y += SIGN(target.y - atom_parent.y) * strength

		if (tuggers)
			// Intentionally not trig--something at a corner with a strength of 1 should have
			// you at the corner, rather than root(2).
			total_tug_x /= tuggers
			total_tug_y /= tuggers

			var/half_size = world.icon_size * 0.5
			total_tug_x *= half_size
			total_tug_y *= half_size

	if (total_tug_x == current_tug_offset_x && total_tug_y == current_tug_offset_y)
		return

	animate(
		atom_parent,
		pixel_x = -current_tug_offset_x + total_tug_x,
		pixel_y = -current_tug_offset_y + total_tug_y,
		time = 0.2 SECONDS,
		flags = ANIMATION_RELATIVE
	)

	current_tug_offset_x = total_tug_x
	current_tug_offset_y = total_tug_y
