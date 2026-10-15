/datum/surgery/dental_implant
	name = "dental implant"
	steps = list(/datum/surgery_step/drill, /datum/surgery_step/insert_pill)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	self_operable = TRUE

/datum/surgery_step/insert_pill
	name = "insert pill"
	implements = list(/obj/item/reagent_containers/pill = 100)
	time = 16

/datum/surgery_step/insert_pill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wciskać [tool] w [strefa_pl(target_zone, TRUE)] [target]...</span>",
			"[user] zaczyna wciskać [tool] w [strefa_pl(target_zone, TRUE)] [target].",
			"[user] zaczyna coś wciskać w [strefa_pl(target_zone, TRUE)] [target].")

/datum/surgery_step/insert_pill/success(mob/user, mob/living/carbon/target, target_zone, var/obj/item/reagent_containers/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return 0

	target.cauterise_wounds()
	user.transferItemToLoc(tool, target, TRUE)

	var/datum/action/item_action/hands_free/activate_pill/P = new(tool)
	P.button.name = "Activate [tool.name]"
	P.target = tool
	P.Grant(target)	//The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	display_results(user, target, "<span class='notice'>Wciskasz [tool] w [strefa_pl(target_zone, TRUE)] [target].</span>",
			"[user] wciska [tool] w [strefa_pl(target_zone, TRUE)] [target]!",
			"[user] wciska coś w [strefa_pl(target_zone, TRUE)] [target]!")
	return 1

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return FALSE
	to_chat(owner, "<span class='caution'>Zaciskasz zęby i rozgniatasz wszczepione [target.name]!</span>")
	log_combat(owner, null, "swallowed an implanted pill", target)
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume, transfered_by = owner)
	qdel(target)
	return TRUE
