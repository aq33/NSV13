/*				ENGINEERING OBJECTIVES				*/

/datum/objective/crew/integrity //ported from old Hippie
	explanation_text = "Dopilnuj, by na koniec zmiany wskaźnik integralności stacji wynosił co najmniej (coś się zepsuło, zgłoś na GitHubie)%."
	jobs = "chiefengineer,stationengineer"

/datum/objective/crew/integrity/New()
	. = ..()
	target_amount = rand(60,95)
	update_explanation_text()

/datum/objective/crew/integrity/update_explanation_text()
	. = ..()
	explanation_text = "Dopilnuj, by na koniec zmiany wskaźnik integralności stacji wynosił co najmniej [target_amount]%."

/datum/objective/crew/integrity/check_completion()
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	if(!SSticker.mode.station_was_nuked && station_integrity >= target_amount)
		return TRUE
	else
		return FALSE

/datum/objective/crew/poly
	explanation_text = "Dopilnuj, by Poly zachował słuchawki i dożył końca zmiany."
	jobs = "chiefengineer"

/datum/objective/crew/poly/check_completion()
	for(var/mob/living/simple_animal/parrot/Poly/dumbbird in GLOB.mob_list)
		if(!(dumbbird.stat == DEAD) && dumbbird.ears)
			if(istype(dumbbird.ears, /obj/item/radio/headset))
				return TRUE
	return FALSE

/datum/objective/crew/meltdown
	explanation_text = "Dopilnuj, by podczas twojej służby silnik się nie stopił."
	jobs = "chiefengineer,stationengineer,atmospherictechnician"
	var/meltdown = FALSE

/datum/objective/crew/meltdown/check_completion()
	if(meltdown)
		return FALSE
	return TRUE

/datum/objective/crew/power_generation
	explanation_text = "Utrzymaj wytwarzanie x MW w silniku do końca zmiany."
	jobs = "chiefengineer,stationengineer,atmospherictechnician"
	var/obj/machinery/atmospherics/components/binary/stormdrive_reactor/SD
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/RBMK

/datum/objective/crew/power_generation/New()
	. = ..()
	SD = locate() in GLOB.machines
	RBMK = locate() in GLOB.machines
	var/base_target_power
	if(SD)
		base_target_power = 13000000
	else if(RBMK)
		base_target_power = 10000000
	else
		base_target_power = 5000000
	var/target_percent = rand(60,90)
	target_amount = base_target_power * target_percent
	update_explanation_text()

/datum/objective/crew/power_generation/update_explanation_text()
	. = ..()
	explanation_text = "Utrzymaj wytwarzanie [target_amount] W w silniku do końca zmiany."

/datum/objective/crew/power_generation/check_completion()
	if(SD?.last_power_produced >= target_amount)
		return TRUE
	if(RBMK?.last_power_produced >= target_amount)
		return TRUE
	return FALSE
