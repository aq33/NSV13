/datum/surgery/advanced/bioware/cortex_folding
	name = "Cortex Folding"
	desc = "A surgical procedure which modifies the cerebral cortex into a complex fold, giving space to non-standard neural patterns."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/fold_cortex,
		/datum/surgery_step/close,
	)

	bioware_target = BIOWARE_CORTEX

/datum/surgery/advanced/bioware/cortex_folding/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return ..()

/datum/surgery_step/fold_cortex
	name = "fold cortex (hand)"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/fold_cortex/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		"<span class='notice'>Zaczynasz składać zewnętrzną korę mózgową [target] we wzór fraktalny.</span>",
		"<span class='notice'>[user] zaczyna składać zewnętrzną korę mózgową [target] we wzór fraktalny.</span>",
		"<span class='notice'>[user] zaczyna operację mózgu [target].</span>",
	)

/datum/surgery_step/fold_cortex/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		"<span class='notice'>Składasz zewnętrzną korę mózgową [target] we wzór fraktalny!</span>",
		"<span class='notice'>[user] składa zewnętrzną korę mózgową [target] we wzór fraktalny!</span>",
		"<span class='notice'>[user] kończy operację mózgu [target].</span>",
	)
	new /datum/bioware/cortex_fold(target)
	return ..()

/datum/surgery_step/fold_cortex/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
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

/datum/bioware/cortex_fold
	name = "Cortex Fold"
	desc = "The cerebral cortex has been folded into a complex fractal pattern, and can support non-standard neural patterns."
	mod_type = BIOWARE_CORTEX

/datum/bioware/cortex_fold/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/cortex_fold/on_lose()
	REMOVE_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, EXPERIMENTAL_SURGERY_TRAIT)
	return ..()
