// AQUILA - port of the BeeStation identity recalibration surgery (BeeStation #12856): swipe an ID inside a robotic chest to rename the patient

/datum/surgery/rename
	name = "rekalibracja tożsamości"
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/rename,
		/datum/surgery_step/mechanic_close,
	)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYTYPE_ROBOTIC
	requires_real_bodypart = TRUE
	self_operable = TRUE

/datum/surgery_step/rename
	name = "przeciągnij kartę ID"
	implements = list(/obj/item/card/id = 100)
	time = 10
	repeatable = TRUE

/datum/surgery_step/rename/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/card/id/id = tool
	if(!istype(id))
		return
	var/old_name = target.real_name
	if(id.registered_name)
		target.fully_replace_character_name(old_name, id.registered_name)
		display_results(user, target, span_notice("Rekalibrujesz tożsamość [old_name]!"),
			span_notice("[user] rekalibruje tożsamość [old_name] za pomocą [tool]!"),
			span_notice("[user] rekalibruje tożsamość [old_name]!"))
		log_combat(user, target, "renamed", addition="changed [old_name]'s name to [id.registered_name]")
	else
		target.fully_replace_character_name(old_name, "????")
		to_chat(user, span_warning("Na karcie nie ma zapisanego nazwiska, co powoduje błąd!"))
		log_combat(user, target, "renamed", addition="changed [old_name] to ????")
	return TRUE
