//Side Objectives still need to be generated
/datum/overmap_gamemode/armada
	name = "Armada"
	config_tag = "armada"
	desc = "Complete objectives to gain reinforcements, defend allocated system when the Syndicate Armada arrives."
	brief = "Wywiad Floty White Rapids donosi, że Syndykat szykuje flotę inwazyjną, by zdobyć selected_system. Zbierzcie siły obronne, by odeprzeć Armadę, zwalniając jednostki floty, i przygotujcie się do obrony systemu."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0				//We have strict timelines on this
	objective_reminder_interval = 3 MINUTES	//60 Minutes Until Vanguard Arrives
	reminder_one = ""							//Countdown 1
	reminder_two = ""							//Countdown 2
	reminder_three = ""							//Countdown 3
	reminder_four = ""							//Vanguard Arrives
	reminder_five = ""							//Mainfleet Arrives

	var/selected_system							//The target of the Syndicate Attack
	var/reinforcements = 0						//How many reinforcement fleets NT has at hand

	selection_weight = 0
	required_players = 15
	fixed_objectives = list(/datum/overmap_objective/system_defence_armada)

/datum/overmap_gamemode/armada/New()
	//Select a system to be targeted

	var/list/candidate = list()
	for(var/datum/star_system/S in SSstar_system.systems)
		if(S.alignment == "nanotrasen")
			candidate += S.name

	candidate -= SSmapping.config.return_system
	selected_system = pick(candidate)

	brief = "Wywiad floty donosi, że Syndykat szykuje flotę inwazyjną, by zdobyć [selected_system]. Zbierzcie siły obronne, by odeprzeć Armadę, zwalniając jednostki floty, i przygotujcie się do obrony systemu."

	reminder_one = "White Rapids przewiduje, że Armada Syndykatu zaatakuje [selected_system] za [(objective_reminder_interval * 3) / 600] min"
	reminder_two = "White Rapids przewiduje, że Armada Syndykatu zaatakuje [selected_system] za [(objective_reminder_interval * 2) / 600] min"
	reminder_three = "White Rapids przewiduje, że Armada Syndykatu zaatakuje [selected_system] za [(objective_reminder_interval * 1) / 600] min"
	reminder_four = "Wykryto sygnatury bluespace na obrzeżach [selected_system], przygotujcie się do obrony systemu!"
	reminder_five = "Wykryto kolejne sygnatury bluespace, szykujcie się na posiłki Syndykatu!"

/datum/overmap_gamemode/armada/consequence_one() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_two() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_three() //Purely a reminder
	return

/datum/overmap_gamemode/armada/consequence_four() //Syndicate Vanguard + Nanotrasen Reinforcements Arrive
	objective_reminder_interval = 5 MINUTES //Armada Soon, Fellow Spaceman

	for(var/datum/overmap_objective/O in objectives)
		O.check_completion()
		if(O.status == 1) //STATUS_COMPLETED
			reinforcements ++ //For each side objective completed, add an NT fleet

	addtimer(CALLBACK(src, PROC_REF(vanguard)), 1 MINUTES)
	if(reinforcements >= 1)
		addtimer(CALLBACK(src, PROC_REF(reinforce)), 2 MINUTES)


/datum/overmap_gamemode/armada/consequence_five() //Syndicate Armada Arrives
	for(var/datum/overmap_objective/system_defence_armada/O in objectives)
		O.armada_arrived = TRUE

	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/earthbuster()
	target.fleets += F
	F.current_system = target
	F.assemble(target)

/datum/overmap_gamemode/armada/proc/reinforce()
	reinforcements-- //Deduct one from the pool
	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/nanotrasen/light() //You expected more?
	target.fleets += F
	F.current_system = target
	F.assemble(target)

	if(reinforcements >= 1)
		addtimer(CALLBACK(src, PROC_REF(reinforce)), 2 MINUTES) //Keep Calling Them In

/datum/overmap_gamemode/armada/proc/vanguard()
	var/datum/star_system/target = SSstar_system.system_by_id(selected_system)
	var/datum/fleet/F = new /datum/fleet/interdiction/stealth()
	target.fleets += F
	F.current_system = target
	F.assemble(target)
