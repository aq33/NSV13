/datum/surgery/advanced/viral_bonding
	name = "Viral Bonding"
	desc = "A surgical procedure that forces a symbiotic relationship between a virus and its host. The patient must be dosed with spaceacillin, virus food, and formaldehyde."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/viral_bond,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	self_operable = TRUE

/datum/surgery/advanced/viral_bonding/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(!LAZYLEN(target.diseases))
		return FALSE
	return TRUE

/datum/surgery_step/viral_bond
	name = "viral bond"
	implements = list(TOOL_CAUTERY = 100, TOOL_WELDER = 50, /obj/item = 30) // 30% success with any hot item.
	time = 100
	chems_needed = list(/datum/reagent/medicine/spaceacillin,/datum/reagent/consumable/virus_food,/datum/reagent/toxin/formaldehyde)

/datum/surgery_step/viral_bond/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.is_hot()

	return TRUE

/datum/surgery_step/viral_bond/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz podgrzewać szpik kostny [target] za pomocą [tool]...</span>",
		"[user] zaczyna podgrzewać szpik kostny [target] za pomocą [tool]...",
		"[user] zaczyna podgrzewać coś w klatce piersiowej [target] za pomocą [tool]...")

/datum/surgery_step/viral_bond/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Szpik kostny [target] zaczyna powoli pulsować. Wiązanie wirusowe zakończone.</span>",
		"Szpik kostny [target] zaczyna powoli pulsować.",
		"[user] kończy operację.")
	for(var/X in target.diseases)
		var/datum/disease/D = X
		D.carrier = TRUE
	return TRUE
