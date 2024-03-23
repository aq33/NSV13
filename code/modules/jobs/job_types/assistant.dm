/*
Assistant
*/
/datum/job/assistant
	title = JOB_NAME_ASSISTANT
	flag = ASSISTANT
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 100
	spawn_positions = 100
	supervisors = "absolutely everyone"
	selection_color = "#dddddd"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/assistant_ship //Nsv13 - Assistant resprite
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.
	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments = DEPARTMENT_BITFLAG_SERVICE
	rpg_title = "Lout"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)
/datum/job/assistant/get_access()
	if(CONFIG_GET(flag/assistants_have_maint_access) || !CONFIG_GET(flag/jobs_have_minimal_access)) //Config has assistant maint access set
		. = ..()
		. |= list(ACCESS_MAINT_TUNNELS)
	else
		return ..()

/datum/outfit/job/assistant
	name = JOB_NAME_ASSISTANT
	jobtype = /datum/job/assistant
	belt = /obj/item/modular_computer/tablet/pda/assistant
	id = /obj/item/card/id/job/assistant

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		/* NSV13 - no skirts
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/grey
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/grey
		*/
		uniform = /obj/item/clothing/under/color/grey
	else
		/* NSV13 - no skirts
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random
		*/
		uniform = /obj/item/clothing/under/color/random
