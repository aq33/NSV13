// AQUILA - pick the surgery from a radial menu around the patient (the UX part of tgstation#93697) instead of the TGUI list.
// The step-based surgeries stay as they are: drapes on the patient, pick the surgery, then the usual steps.

/datum/component/surgery_initiator
	/// TRUE while the radial menu is open, so changing the zone doesn't open a second one
	var/radial_open = FALSE

/datum/component/surgery_initiator/ui_interact(mob/user, datum/tgui/ui)
	INVOKE_ASYNC(src, PROC_REF(show_surgery_radial), user)

/datum/component/surgery_initiator/proc/show_surgery_radial(mob/user)
	if(radial_open)
		return
	var/mob/living/target = surgery_target_ref?.resolve()
	if(isnull(target))
		return

	var/list/choices = list()
	var/list/surgery_by_name = list()
	for(var/datum/surgery/surgery as anything in get_available_surgeries(user, target))
		var/choice_name = surgery.name
		if(surgery_needs_exposure(surgery, target))
			choice_name = "[surgery.name] (zasłonięte ubraniem)"
		choices[choice_name] = get_surgery_radial_image(surgery)
		surgery_by_name[choice_name] = surgery

	if(!length(choices))
		ui_close(user)
		return

	radial_open = TRUE
	var/picked = show_radial_menu(user, target, choices, custom_check = CALLBACK(src, PROC_REF(can_start_surgery), user, target), require_near = TRUE, tooltips = TRUE)
	radial_open = FALSE

	var/datum/surgery/picked_surgery = surgery_by_name[picked]
	if(isnull(picked_surgery) || QDELETED(target))
		ui_close(user)
		return
	try_choose_surgery(user, target, picked_surgery)
	// try_choose_surgery() only closes on success; a refusal should not leave us waiting for zone changes
	if(surgery_target_ref)
		ui_close(user)

/// Picks a picture for a surgery: the tool of its first step that isn't just opening or closing the patient
/datum/component/surgery_initiator/proc/get_surgery_radial_image(datum/surgery/surgery)
	var/static/list/image/images_by_type = list()
	if(images_by_type[surgery.type])
		return images_by_type[surgery.type]

	var/static/list/generic_steps = typecacheof(list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/saw,
		/datum/surgery_step/close,
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_close,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/mechanic_wrench,
	))
	var/static/list/tool_states = list(
		TOOL_SCALPEL = "scalpel",
		TOOL_HEMOSTAT = "hemostat",
		TOOL_RETRACTOR = "retractor",
		TOOL_CAUTERY = "cautery",
		TOOL_SAW = "saw",
		TOOL_DRILL = "drill",
		TOOL_BLOODFILTER = "bloodfilter",
	)

	var/image/picture = image('icons/obj/surgery.dmi', "surgical_drapes")
	for(var/step_type in surgery.steps)
		if(is_type_in_typecache(step_type, generic_steps))
			continue
		var/datum/surgery_step/step = new step_type
		if(step.accept_hand)
			picture = image('icons/obj/surgery.dmi', "heart-on")
		else
			for(var/implement in step.implements)
				if(ispath(implement, /obj/item))
					var/obj/item/implement_item = implement
					picture = image(initial(implement_item.icon), initial(implement_item.icon_state))
					break
				if(tool_states[implement])
					picture = image('icons/obj/surgery.dmi', tool_states[implement])
					break
		qdel(step)
		break

	images_by_type[surgery.type] = picture
	return picture
