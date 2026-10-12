/datum/surgery/advanced/bioware/cortex_imprint
	name = "Cortex Imprint"
	desc = "A surgical procedure which modifies the cerebral cortex into a redundant neural pattern, making the brain able to bypass impediments caused by minor brain traumas."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/imprint_cortex,
		/datum/surgery_step/close,
	)

	bioware_target = BIOWARE_CORTEX

/datum/surgery/advanced/bioware/cortex_imprint/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return ..()

/datum/surgery_step/imprint_cortex
	name = "imprint cortex (hand)"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/imprint_cortex/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		"<span class='notice'>Zaczynasz rzeźbić zewnętrzną korę mózgową [target] w samoodciskający się wzór.</span>",
		"<span class='notice'>[user] zaczyna rzeźbić zewnętrzną korę mózgową [target] w samoodciskający się wzór.</span>",
		"<span class='notice'>[user] zaczyna operację mózgu [target].</span>",
	)

/datum/surgery_step/imprint_cortex/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		"<span class='notice'>Przekształcasz zewnętrzną korę mózgową [target] w samoodciskający się wzór!</span>",
		"<span class='notice'>[user] przekształca zewnętrzną korę mózgową [target] w samoodciskający się wzór!</span>",
		"<span class='notice'>[user] kończy operację mózgu [target].</span>",
	)
	new /datum/bioware/cortex_imprint(target)
	return ..()

/datum/surgery_step/imprint_cortex/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(
			user,
			target,
			"<span class='warning'>Partaczysz, uszkadzając mózg!</span>",
			"<span class='warning'>[user] partaczy, uszkadzając mózg!</span>",
			"<span class='notice'>[user] kończy operację mózgu [target].</span>",
		)
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message("<span class='warning'>[user] nagle zauważa, że mózgu, nad którym pracował, już tam nie ma.</span>", "<span class='warning'>Nagle zauważasz, że mózgu, nad którym pracowałeś, już tam nie ma.</span>")
	return FALSE

/datum/bioware/cortex_imprint
	name = "Cortex Imprint"
	desc = "The cerebral cortex has been reshaped into a redundant neural pattern, making the brain able to bypass impediments caused by minor brain traumas."
	mod_type = BIOWARE_CORTEX
	can_process = TRUE

/datum/bioware/cortex_imprint/process()
	owner.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
