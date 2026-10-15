/datum/antagonist/disease
	name = "Świadoma choroba"
	roundend_category = "choroby"
	antagpanel_category = "Disease"
	show_to_ghosts = TRUE
	banning_key = BAN_ROLE_ALL_ANTAGONISTS
	var/disease_name = ""

/datum/antagonist/disease/on_gain()
	owner.special_role = "Sentient Disease"
	owner.assigned_role = "Sentient Disease"
	var/datum/objective/O = new /datum/objective/disease_infect()
	O.owner = owner
	objectives += O
	log_objective(owner, O.explanation_text)

	O = new /datum/objective/disease_infect_centcom()
	O.owner = owner
	objectives += O
	log_objective(owner, O.explanation_text)

	. = ..()

/datum/antagonist/disease/greet()
	to_chat(owner.current, "<span class='notice'>Jesteś świadomą chorobą!</span>")
	to_chat(owner.current, "<span class='notice'>Zarażaj członków załogi, by zdobywać punkty adaptacji i dalej szerzyć infekcję.</span>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Świadoma choroba",
		"Zarażaj członków załogi, by zdobywać punkty adaptacji i dalej szerzyć infekcję.")

/datum/antagonist/disease/apply_innate_effects(mob/living/mob_override)
	if(!istype(owner.current, /mob/camera/disease))
		var/turf/T = get_turf(owner.current)
		T = T ? T : SSmapping.get_station_center()
		var/mob/camera/disease/D = new /mob/camera/disease(T)
		owner.transfer_to(D)

/datum/antagonist/disease/admin_add(datum/mind/new_owner,mob/admin)
	..()
	var/mob/camera/disease/D = new_owner.current
	D.pick_name()

/datum/antagonist/disease/roundend_report()
	var/list/result = list()

	result += "<b>Nazwa choroby:</b> [disease_name]"
	result += printplayer(owner)

	var/win = TRUE
	var/objectives_text = ""
	var/count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objectives_text += "<br><B>Cel nr [count]</B>: [objective.explanation_text] <span class='greentext'>Sukces!</span>"
		else
			objectives_text += "<br><B>Cel nr [count]</B>: [objective.explanation_text] <span class='redtext'>Porażka.</span>"
			win = FALSE
		count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(win)
		result += "<span class='greentext'>[capitalize(special_role_text)]: sukces!</span>"
	else
		result += "<span class='redtext'>[capitalize(special_role_text)]: porażka!</span>"

	if(istype(owner.current, /mob/camera/disease))
		var/mob/camera/disease/D = owner.current
		result += "<B>[disease_name] kończy rundę z [D.hosts.len] zarażonymi nosicielami, osiągając maksymalnie [D.total_points] jednoczesnych infekcji.</B>"
		result += "<B>[disease_name] kończy rundę z następującymi adaptacjami:</B>"
		var/list/adaptations = list()
		for(var/V in D.purchased_abilities)
			var/datum/disease_ability/A = V
			adaptations += A.name
		result += adaptations.Join(", ")

	return result.Join("<br>")


/datum/objective/disease_infect
	explanation_text = "Przetrwaj i zaraź jak najwięcej osób."

/datum/objective/disease_infect/check_completion()
	var/mob/camera/disease/D = owner.current
	if(istype(D) && D.hosts.len) //theoretically it should not exist if it has no hosts, but better safe than sorry.
		return TRUE
	return ..()


/datum/objective/disease_infect_centcom
	explanation_text = "Dopilnuj, by co najmniej jeden zarażony nosiciel uciekł promem albo kapsułą ratunkową."

/datum/objective/disease_infect_centcom/check_completion()
	var/mob/camera/disease/D = owner.current
	if(!istype(D))
		return ..()
	for(var/V in D.hosts)
		var/mob/living/L = V
		if(L.onCentCom() || L.onSyndieBase())
			return TRUE
	return ..()
