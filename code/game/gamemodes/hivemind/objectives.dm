/datum/objective/hivemind

/datum/objective/hivemind/hivesize
	explanation_text = "This is a bug. Error:HIVE2"
	target_amount = 10

/datum/objective/hivemind/hivesize/New()
	target_amount = ( max(8, round(GLOB.joined_player_list.len/3)) + rand(0,3) )
	update_explanation_text()

/datum/objective/hivemind/hivesize/update_explanation_text()
	explanation_text = "Zakończ rundę z co najmniej [target_amount] istotami przyłączonymi do roju."

/datum/objective/hivemind/hivesize/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	return (host.hive_size >= target_amount) || ..()

/datum/objective/hivemind/hiveescape
	explanation_text = "This is a bug. Error:HIVE2"
	target_amount = 10

/datum/objective/hivemind/hiveescape/New()
	target_amount = ( max(5, round(GLOB.joined_player_list.len/6)) + rand(0,2) )
	update_explanation_text()

/datum/objective/hivemind/hiveescape/update_explanation_text()
	explanation_text = "Spraw, by co najmniej [target_amount] członków roju uciekło promem żywych i wolnych."

/datum/objective/hivemind/hiveescape/check_completion()
	var/count = 0
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	for(var/datum/mind/M in host.hivemembers)
		if(considered_escaped(M))
			count++
	return (count >= target_amount) || ..()

/datum/objective/hivemind/biggest
	explanation_text = "Zakończ rundę z większą liczbą naczyń niż jakikolwiek inny nosiciel roju."

/datum/objective/hivemind/biggest/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	for(var/datum/antagonist/hivemind/H as() in GLOB.hivehosts)
		if(H == host)
			continue
		if(H.hive_size >= host.hive_size)
			return ..()
	return TRUE

/datum/objective/hivemind/dominance
	name = "dominance"
	explanation_text = "Zdominuj pozostałych, mając o dwadzieścia naczyń i więcej integracji niż jakikolwiek inny rój."

/datum/objective/hivemind/dominance/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	return host?.dominant || ..()

/datum/objective/hivemind/awaken
	name = "awaken"
	var/target_role_type=FALSE

/datum/objective/hivemind/awaken/update_explanation_text()
	if(target && target.current)
		explanation_text = "Zmień [target.name] ([!target_role_type ? target.assigned_role : target.special_role]) w przebudzone naczynie."
	else
		explanation_text = "Cel dowolny"

/datum/objective/hivemind/awaken/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	for(var/datum/mind/mind as() in host.avessels)
		if(target == mind)
			return TRUE
	return FALSE

/datum/objective/hivemind/integrate
	name = "integrate"
	explanation_text = "Zintegruj co najmniej jednego innego nosiciela roju."

/datum/objective/hivemind/integrate/check_completion()
	var/datum/antagonist/hivemind/host = owner.has_antag_datum(/datum/antagonist/hivemind)
	if(!host)
		return ..()
	return host?.size_mod || ..()
