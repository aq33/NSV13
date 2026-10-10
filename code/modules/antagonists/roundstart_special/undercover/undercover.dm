////////////////////////////////
////// Special Role Datum///////
////////////////////////////////

/datum/special_role/undercover
	probability = 65			//The probability of any spawning at all
	proportion = 0.05			//The prbability per person of rolling it (5% is (5 in 100) (1 in 20))
	max_amount = 4				//The maximum amount
	role_name = "Undercover Agent"
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_CHIEFENGINEER, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN, JOB_NAME_CLOWN, JOB_NAME_MASTERATARMS) //NSV13 - added MAA
	attached_antag_datum = /datum/antagonist/special/undercover

////////////////////////////////
//////  Antagonist Datum ///////
////////////////////////////////

/datum/antagonist/special/undercover
	name = "Były agent ochrony"
	roundend_category = "role specjalne"
	antag_moodlet = /datum/mood_event/determined

/datum/antagonist/special/undercover/greet()
	to_chat(owner, "<span class='userdanger'>Jesteś byłym agentem ochrony.</span>")
	to_chat(owner, "<b>Ze względu na dawną lojalność wobec Nanotrasen otrzymujesz pozwolenie na broń.</b>")
	to_chat(owner, "<b>Dodatkowo Nanotrasen pozwala ci mieć disabler do samoobrony.</b>")
	to_chat(owner, "<b>Nie należysz do ochrony i nie powinieneś ścigać przestępców, ale możesz użyć broni w samoobronie.</b>")
	to_chat(owner, "<span class='boldannounce'>NIE dopuszczaj się zdrady, realizując swoje cele.</span>")

/datum/antagonist/special/undercover/admin_add(datum/mind/new_owner, mob/admin)
	. = ..()
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "You can only turn carbons into an ex-security agent.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into an ex-security agent.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/special/undercover/forge_objectives()
	var/datum/objective/saveshuttle/chosen_objective = new
	chosen_objective.generate_people_goal()
	objectives += chosen_objective
	log_objective(owner, chosen_objective.explanation_text)

	if(owner.assigned_role in GLOB.engineering_positions)
		var/datum/objective/protect_sm/objective = new
		if(objective.get_target())
			objective.update_explanation_text()
			objectives += objective
			log_objective(owner, objective.explanation_text)

	owner.announce_objectives()

/datum/antagonist/special/undercover/equip()
	if(!owner)
		return

	var/mob/living/carbon/H = owner.current
	if(!ishuman(H) && !ismonkey(H))
		return

	var/obj/item/gun/energy/disabler/T = new(H)
	var/obj/item/restraints/handcuffs/cable/zipties/T2 = new(H)
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)
	var/where = H.equip_in_one_of_slots(T, slots)
	H.equip_in_one_of_slots(T2, slots)
	if (!where)
		if(!H.put_in_hands(T))
			to_chat(owner, "<span class='warning'>Twoja broń leży na podłodze.</span>")

	//Update ID
	var/obj/item/card/id/ID = H.get_idcard()
	if(ID)
		ID.access += ACCESS_WEAPONS

////////////////////////////////
//////     Objectives    ///////
////////////////////////////////

/datum/objective/saveshuttle
	name = "protect shuttle"

/datum/objective/saveshuttle/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return ..()
	var/count = 0
	for(var/mob/living/carbon/human/person in get_living_crew())
		if(get_area(person) in SSshuttle.emergency.shuttle_areas)
			count ++
	return (count >= target_amount) || ..()

/datum/objective/saveshuttle/update_explanation_text()
	. = ..()
	explanation_text = "Chroń prom ewakuacyjny, tak by co najmniej [target_amount] osób dotarło nim żywych."

/datum/objective/saveshuttle/proc/generate_people_goal()
	var/potential_escapees = 0
	for(var/mob/M in GLOB.mob_living_list)
		if(M.mind)
			potential_escapees++
	if(potential_escapees == 0)
		explanation_text = "Cel dowolny"
		return 0
	target_amount = rand(1, round(potential_escapees * 0.2))			//This should really be made to scale with the population
	update_explanation_text()
	return target_amount

/datum/objective/protect_sm
	name = "protect supermatter"
	var/target_integrity = 20
	var/datum/weakref/target_sm

/datum/objective/protect_sm/get_target()
	for(var/obj/machinery/power/supermatter_crystal/S in GLOB.machines)
		target_sm = WEAKREF(S)
		return TRUE
	log_runtime("Failed to find a supermatter crystal for the supermatter objective.")
	return FALSE

/datum/objective/protect_sm/update_explanation_text()
	var/obj/machinery/power/supermatter_crystal/S = target_sm.resolve()
	explanation_text = "Dopilnuj, by kryształ supermaterii w [get_area(S)] pozostał stabilny i na koniec zmiany miał ponad [target_integrity]% integralności."

/datum/objective/protect_sm/check_completion()
	var/obj/machinery/power/supermatter_crystal/S = target_sm.resolve()
	if(!S)
		return ..()
	return (S.get_integrity_percent() > target_amount) || ..()
