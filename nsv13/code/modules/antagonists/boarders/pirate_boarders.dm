/datum/antagonist/pirate/boarder
	name = "Kosmiczny pirat"
	var/datum/team/pirate/boarder/boarding_crew

/datum/team/pirate/boarder
	name = "Space Pirate Boarding Crew"

/datum/antagonist/pirate/boarder/greet()
	to_chat(owner, "<span class='boldannounce'>Jesteś kosmicznym piratem!</span>")
	to_chat(owner, "<B>Udało się wam zadokować w pobliżu okrętu wojennego Nanotrasen. Jesteście w mniejszości, gorzej uzbrojeni i pod każdym względem gorzej przygotowani, ale jeśli uda wam się obrabować ten statek, wasza piracka załoga zyska sławę.</B>")
	owner.announce_objectives()

/datum/antagonist/pirate/boarder/get_team()
	return boarding_crew

/datum/antagonist/pirate/boarder/on_gain()
	if(boarding_crew)
		objectives |= boarding_crew.objectives
	return ..()

/datum/antagonist/pirate/boarder/create_team(datum/team/pirate/boarder/new_team)
	if(!new_team)
		for(var/datum/antagonist/pirate/boarder/P in GLOB.antagonists)
			if(!P.owner)
				continue
			if(P.boarding_crew)
				boarding_crew = P.boarding_crew
				return
		if(!new_team)
			boarding_crew = new /datum/team/pirate/boarder
			boarding_crew.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	boarding_crew = new_team

/datum/team/pirate/boarder/forge_objectives()
	var/datum/objective/loot/plunder/P = new()
	P.team = src
	for(var/obj/machinery/computer/piratepad_control/PPC in GLOB.machines)
		var/area/A = get_area(PPC)
		if(istype(A,/area/shuttle/pirate))
			P.cargo_hold = PPC
			break
	objectives += P
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/boarder/B = M.has_antag_datum(/datum/antagonist/pirate/boarder)
		if(B)
			B.objectives |= objectives

/datum/objective/loot/plunder
	explanation_text = "Złup i spustosz statek, przewożąc łupy warte 50000 kredytów." //replace me
