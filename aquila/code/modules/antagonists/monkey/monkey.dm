#define MONKEYS_ESCAPED		1
#define MONKEYS_LIVED		2
#define MONKEYS_DIED		3
#define DISEASE_LIVED		4

/datum/antagonist/monkey
	name = "Małpa"
	banning_key = ROLE_MONKEY
	roundend_category = "małpy"
	antagpanel_category = "Monkey"
	show_to_ghosts = TRUE
	var/datum/team/monkey/monkey_team
	var/monkey_only = TRUE

/datum/antagonist/monkey/can_be_owned(datum/mind/new_owner)
	return ..() && (!monkey_only || ismonkey(new_owner.current))

/datum/antagonist/monkey/get_team()
	return monkey_team

/datum/antagonist/monkey/on_gain()
	. = ..()
	SSticker.mode.ape_infectees += owner
	owner.special_role = "Infected Monkey"

	var/datum/disease/D = new /datum/disease/transformation/jungle_fever/monkeymode
	if(!owner.current.HasDisease(D))
		owner.current.ForceContractDisease(D)
	else
		QDEL_NULL(D)

/datum/antagonist/monkey/greet()
	to_chat(owner, "<b>Jesteś teraz małpą!</b>")
	to_chat(owner, "<b>Gryź ludzi, żeby ich zarazić, i zdrowe małpy, żeby powiększyć armię, a potem obal ludzi!</b>")
	to_chat(owner, "<b>Dopilnuj, by co najmniej jedna zarażona małpa uciekła promem ewakuacyjnym!</b>")
	to_chat(owner, "<b><i>Jako inteligentna małpa umiesz korzystać z technologii i chodzić wywietrznikami w ubraniu.</i></b>")
	to_chat(owner, "<b>Użyj :k, żeby rozmawiać z innymi małpami!</b>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/monkey.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Monkey",
		"Gryź ludzi, żeby ich zarazić, i ucieknij promem ewakuacyjnym, żeby wygrać.")

/datum/antagonist/monkey/on_removal()
	owner.special_role = null
	SSticker.mode.ape_infectees -= owner

	var/datum/disease/transformation/jungle_fever/D =  locate() in owner.current.diseases
	if(D)
		qdel(D)

	. = ..()

/datum/antagonist/monkey/create_team(datum/team/monkey/new_team)
	if(!new_team)
		for(var/datum/antagonist/monkey/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.monkey_team)
				monkey_team = H.monkey_team
				return
		monkey_team = new /datum/team/monkey
		monkey_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	monkey_team = new_team

/datum/antagonist/monkey/proc/forge_objectives()
	if(!give_objectives)
		return
	objectives |= monkey_team.objectives

/datum/antagonist/monkey/admin_remove(mob/admin)
	var/mob/living/carbon/monkey/M = owner.current
	if(alert(admin, "Humanize?", "Humanize", "Yes", "No") == "Yes")
		M.humanize(TR_KEEPITEMS  |  TR_KEEPIMPLANTS  |  TR_KEEPORGANS  |  TR_KEEPDAMAGE  |  TR_KEEPVIRUS  |  TR_DEFAULTMSG)
	. = ..()

/datum/antagonist/monkey/leader
	name = "Przywódca małp"
	monkey_only = FALSE

/datum/antagonist/monkey/leader/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/human/H = new_owner.current
	if(alert(admin, "Monkeyize?", "Monkeyize", "Yes", "No") == "Yes")
		H.monkeyize()
	new_owner.add_antag_datum(src)
	log_admin("[key_name(admin)] made [key_name(new_owner)] a monkey leader!")
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] a monkey leader!")

/datum/antagonist/monkey/leader/on_gain()
	. = ..()
	var/obj/item/organ/heart/freedom/F = new
	F.Insert(owner.current, drop_if_replaced = FALSE)
	SSticker.mode.ape_leaders += owner
	owner.special_role = "Monkey Leader"

/datum/antagonist/monkey/leader/on_removal()
	SSticker.mode.ape_leaders -= owner
	var/obj/item/organ/heart/H = new
	H.Insert(owner.current, drop_if_replaced = FALSE) //replace freedom heart with normal heart

	. = ..()

/datum/antagonist/monkey/leader/greet()
	to_chat(owner, "<B><span class='notice'>Jesteś pacjentem zero Gorączki Dżungli!!</B></span>")
	to_chat(owner, "<b>Konsorcjum Praw Zwierząt podrzuciło cię na tę stację.</b>")
	to_chat(owner, "<b>Wkrótce choroba zmieni cię w małpę. Potem będziesz mógł zarażać innych ugryzieniem.</b>")
	to_chat(owner, "<b>Twojego szczepu nie wykryją skanery, ale pozostali zarażeni będą widoczni na sprzęcie medycznym.</b>")
	to_chat(owner, "<b>Misja zakończy się sukcesem, jeśli którakolwiek żywa zarażona małpa dotrze do Centrali.</b>")
	to_chat(owner, "<b>Jako pierwszy zarażony będziesz dla innych małp 'przywódcą'.</b>")
	to_chat(owner, "<b>Użyj :k, żeby rozmawiać z innymi małpami!</b>")
	SEND_SOUND(owner.current, sound('sound/ambience/antag/monkey.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Przywódca małp",
		"Gryź ludzi, żeby ich zarazić, i ucieknij promem ewakuacyjnym, żeby wygrać.")

/datum/objective/monkey
	explanation_text = "Dopilnuj, by zarażone małpy uciekły promem ewakuacyjnym!"
	martyr_compatible = TRUE
	var/monkeys_to_win = 1
	var/escaped_monkeys = 0

/datum/objective/monkey/check_completion()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if (M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			escaped_monkeys++
	if(escaped_monkeys >= monkeys_to_win)
		return TRUE
	return ..()

/datum/team/monkey
	name = "Monkeys"

/datum/team/monkey/proc/update_objectives()
	objectives = list()
	var/datum/objective/monkey/O = new()
	O.team = src
	objectives += O
	for(var/datum/mind/M in members)
		log_objective(M, O.explanation_text)

/datum/team/monkey/proc/infected_monkeys_alive()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if(M.HasDisease(D))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_monkeys_escaped()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		if(M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_gorillas_alive()
	for(var/mob/living/simple_animal/hostile/gorilla/rabid/M in GLOB.alive_mob_list)
		return TRUE
	return FALSE

/datum/team/monkey/proc/infected_gorillas_escaped()
	for(var/mob/living/simple_animal/hostile/gorilla/rabid/M in GLOB.alive_mob_list)
		if(M.onCentCom() || M.onSyndieBase())
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_humans_escaped()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/human/M in GLOB.alive_mob_list)
		if(M.HasDisease(D) && (M.onCentCom() || M.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/monkey/proc/infected_humans_alive()
	var/datum/disease/D = new /datum/disease/transformation/jungle_fever()
	for(var/mob/living/carbon/human/M in GLOB.alive_mob_list)
		if(M.HasDisease(D))
			return TRUE
	return FALSE

/datum/team/monkey/proc/get_result()
	if(infected_monkeys_escaped() || infected_gorillas_escaped())
		return MONKEYS_ESCAPED
	if(infected_monkeys_alive() || infected_gorillas_alive())
		return MONKEYS_LIVED
	if(infected_humans_alive() || infected_humans_escaped())
		return DISEASE_LIVED
	return MONKEYS_DIED

/datum/team/monkey/roundend_report()
	var/list/parts = list()
	switch(get_result())
		if(MONKEYS_ESCAPED)
			parts += "<span class='greentext big'><B>Wielkie zwycięstwo małp!</B></span>"
			parts += "<span class='greentext'><B>Małpy przejęły Centralę i [station_name()]! U-u-a-a!</B></span>"
		if(MONKEYS_LIVED)
			parts += "<FONT size = 3><B>Małe zwycięstwo małp!</B></FONT>"
			parts += "<span class='greentext'><B>Małpy przejęły [station_name()]! U-u-a-a!</B></span>"
		if(DISEASE_LIVED)
			parts += "<span class='redtext big'><B>Mała porażka małp!</B></span>"
			parts += "<span class='redtext'><B>Wszystkie małpy zginęły, ale choroba żyje dalej! Przyszłość jest niepewna.</B></span>"
		if(MONKEYS_DIED)
			parts += "<span class='redtext big'><B>Wielka porażka małp!</B></span>"
			parts += "<span class='redtext'><B>Wszystkie małpy zginęły, a Gorączka Dżungli została wytępiona!</B></span>"
	var/list/leaders = get_antag_minds(/datum/antagonist/monkey/leader, TRUE)
	var/list/monkeys = get_antag_minds(/datum/antagonist/monkey, TRUE)

	if(LAZYLEN(leaders))
		parts += "<span class='header'>Przywódcy małp:</span>"
		parts += printplayerlist(SSticker.mode.ape_leaders)
	if(LAZYLEN(monkeys))
		parts += "<span class='header'>Małpy:</span>"
		parts += printplayerlist(SSticker.mode.ape_infectees)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
