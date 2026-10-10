/datum/antagonist/wizard
	name = "Kosmiczny czarodziej"
	roundend_category = "czarodzieje i czarownice"
	antagpanel_category = "Wizard"
	banning_key = ROLE_WIZARD
	required_living_playtime = 8
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 0.5
	var/strip = TRUE //strip before equipping
	var/allow_rename = TRUE
	var/hud_version = "wizard"
	var/datum/team/wizard/wiz_team //Only created if wizard summons apprentices
	var/move_to_lair = TRUE
	var/outfit_type = /datum/outfit/wizard
	var/wiz_age = WIZARD_AGE_MIN /* Wizards by nature cannot be too young. */
	show_to_ghosts = TRUE

/datum/antagonist/wizard/on_gain()
	register()
	equip_wizard()
	if(give_objectives)
		create_objectives()
	if(move_to_lair)
		send_to_lair()
	. = ..()
	if(allow_rename)
		rename_wizard()
	owner.current.remove_all_quirks()

/datum/antagonist/wizard/proc/register()
	SSticker.mode.wizards |= owner

/datum/antagonist/wizard/proc/unregister()
	SSticker.mode.wizards -= src

/datum/antagonist/wizard/create_team(datum/team/wizard/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	wiz_team = new_team

/datum/antagonist/wizard/get_team()
	return wiz_team

/datum/team/wizard
	name = "wizard team"
	var/datum/antagonist/wizard/master_wizard

/datum/antagonist/wizard/proc/create_wiz_team()
	wiz_team = new(owner)
	wiz_team.name = "[owner.current.real_name] team"
	wiz_team.master_wizard = src
	update_wiz_icons_added(owner.current)

/datum/antagonist/wizard/proc/send_to_lair()
	if(!owner || !owner.current)
		return
	if(!GLOB.wizardstart.len)
		SSjob.SendToLateJoin(owner.current)
		to_chat(owner, "GORĄCE WEJŚCIE, NAPRZÓD, NAPRZÓD")
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/proc/create_objectives()
	if(!give_objectives)
		return

	//nsv13 - On lowpop, only create one steal and escape objective and then return
	if(GLOB.joined_player_list.len < CONFIG_GET(number/min_pop_kill_objectives))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		objectives += steal_objective
		log_objective(owner, steal_objective.explanation_text)

		if (!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			objectives += escape_objective
			log_objective(owner, escape_objective.explanation_text)
		return //nsv13 end

	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective
				log_objective(owner, escape_objective.explanation_text)

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective
				log_objective(owner, escape_objective.explanation_text)

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective
			log_objective(owner, kill_objective.explanation_text)

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective
			log_objective(owner, steal_objective.explanation_text)

			if (!(locate(/datum/objective/survive) in objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = owner
				objectives += survive_objective
				log_objective(owner, survive_objective.explanation_text)

		else
			if (!(locate(/datum/objective/hijack) in objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				objectives += hijack_objective
				log_objective(owner, hijack_objective.explanation_text)

/datum/antagonist/wizard/on_removal()
	unregister()
	owner.RemoveAllSpells() // TODO keep track which spells are wizard spells which innate stuff
	return ..()

/datum/antagonist/wizard/proc/equip_wizard()
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(strip)
		H.delete_equipment()
	//Wizards are human by default. Use the mirror if you want something else.
	H.set_species(/datum/species/human)
	if(H.age < wiz_age)
		H.age = wiz_age
	H.equipOutfit(outfit_type)

/datum/antagonist/wizard/greet()
	to_chat(owner, "<span class='boldannounce'>Jesteś kosmicznym czarodziejem!</span>")
	to_chat(owner, "<B>Federacja Kosmicznych Czarodziejów powierzyła ci następujące zadania:</B>")
	owner.announce_objectives()
	to_chat(owner, "Listę dostępnych zaklęć znajdziesz w swojej księdze zaklęć. Starannie dobierz magiczny arsenał.")
	to_chat(owner, "Księga zaklęć jest z tobą związana i inni nie mogą jej używać.")
	to_chat(owner, "W kieszeniach znajdziesz zwój teleportacji. Używaj go według potrzeb.")
	to_chat(owner,"<B>Pamiętaj:</B> nie zapomnij przygotować zaklęć.")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Kosmiczny czarodziej",
		"Przygotuj zaklęcia i siej zamęt na tym przeklętym statku.")

/datum/antagonist/wizard/farewell()
	to_chat(owner, "<span class='userdanger'>Wyprano ci mózg! Nie jesteś już czarodziejem!</span>")

/datum/antagonist/wizard/proc/rename_wizard()
	set waitfor = FALSE

	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/mob/living/wiz_mob = owner.current
	var/newname = sanitize_name(reject_bad_text(stripped_input(wiz_mob, "Jesteś: [name]. Chcesz zmienić imię?", "Zmiana imienia", randomname, MAX_NAME_LEN)))

	if (!newname)
		newname = randomname

	wiz_mob.fully_replace_character_name(wiz_mob.real_name, newname)

/datum/antagonist/wizard/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_wiz_icons_added(M, wiz_team ? TRUE : FALSE) //Don't bother showing the icon if you're solo wizard
	M.faction |= FACTION_WIZARD

/datum/antagonist/wizard/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_wiz_icons_removed(M)
	M.faction -= FACTION_WIZARD


/datum/antagonist/wizard/get_admin_commands()
	. = ..()
	.["Send to Lair"] = CALLBACK(src,PROC_REF(admin_send_to_lair))

/datum/antagonist/wizard/proc/admin_send_to_lair(mob/admin)
	owner.current.forceMove(pick(GLOB.wizardstart))

/datum/antagonist/wizard/apprentice
	name = "Uczeń czarodzieja"
	hud_version = "apprentice"
	var/datum/mind/master
	var/school = APPRENTICE_DESTRUCTION
	outfit_type = /datum/outfit/wizard/apprentice
	wiz_age = APPRENTICE_AGE_MIN

/datum/antagonist/wizard/apprentice/greet()
	to_chat(owner, "<B>Jesteś uczniem [master.current.real_name]! Magiczna umowa zobowiązuje cię do wykonywania rozkazów mistrza i pomagania mu w osiąganiu celów.")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/register()
	SSticker.mode.apprentices |= owner

/datum/antagonist/wizard/apprentice/unregister()
	SSticker.mode.apprentices -= owner

/datum/antagonist/wizard/apprentice/equip_wizard()
	. = ..()
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	switch(school)
		if(APPRENTICE_DESTRUCTION)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball(null))
			to_chat(owner, "<b>Twoja służba nie pozostała jednak bez nagrody. Pod okiem [master.current.real_name] nauczono cię potężnych, niszczycielskich zaklęć. Potrafisz rzucać Magiczny Pocisk i Kulę Ognia.</b>")
		if(APPRENTICE_BLUESPACE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			to_chat(owner, "<b>Twoja służba nie pozostała jednak bez nagrody. Pod okiem [master.current.real_name] nauczono cię zaklęć ruchu naginających rzeczywistość. Potrafisz rzucać Teleportację i Eteryczny Spacer.</b>")
		if(APPRENTICE_HEALING)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
			H.put_in_hands(new /obj/item/gun/magic/staff/healing(H))
			to_chat(owner, "<b>Twoja służba nie pozostała jednak bez nagrody. Pod okiem [master.current.real_name] nauczono cię ratujących życie zaklęć przetrwania. Potrafisz rzucać Ładowanie i Ścianę Mocy.</b>")
		if(APPRENTICE_ROBELESS)
			owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(null))
			to_chat(owner, "<b>Twoja służba nie pozostała jednak bez nagrody. Pod okiem [master.current.real_name] nauczono cię skrytych zaklęć niewymagających szat. Potrafisz rzucać Pukanie i Zamianę Umysłów.</b>")
		if(APPRENTICE_WILDMAGIC)
			var/static/list/spell_lists = subtypesof(/datum/spellbook_entry)-typesof(/datum/spellbook_entry/item)-typesof(/datum/spellbook_entry/summon)
			var/spells_left = 2
			while(spells_left)
				var/failsafe = FALSE
				var/datum/spellbook_entry/chosen_spell = pick(spell_lists)
				for(var/obj/effect/proc_holder/spell/my_spell in owner.spell_list)
					if(initial(chosen_spell.name) == initial(my_spell.name)) // You don't learn the same spell
						failsafe = TRUE
						break
					if(is_type_in_typecache(my_spell, initial(chosen_spell.no_coexistance_typecache))) // You don't learn a spell that isn't compatible with another
						failsafe = TRUE
						break
				if(failsafe)
					continue
				var/obj/effect/proc_holder/spell/new_spell = initial(chosen_spell.spell_type)
				owner.AddSpell(new new_spell(null))
				spells_left--
			to_chat(owner, "<b>Twoja służba nie pozostała jednak bez nagrody. Pod okiem [master.current.real_name] nauczono cię specjalnych zaklęć niedostępnych dla zwykłych uczniów.</b>")

/datum/antagonist/wizard/apprentice/create_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = owner
	new_objective.set_target(master)
	new_objective.explanation_text = "Chroń czarodzieja [master.current.real_name]."
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

//Random event wizard
/datum/antagonist/wizard/apprentice/imposter
	name = "Fałszywy czarodziej"
	allow_rename = FALSE
	move_to_lair = FALSE

/datum/antagonist/wizard/apprentice/imposter/greet()
	to_chat(owner, "<B>Jesteś oszustem! Zwodź i dezorientuj załogę, żeby odwrócić jej gniew od twojego przystojnego oryginału!</B>")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/imposter/equip_wizard()
	var/mob/living/carbon/human/master_mob = master.current
	var/mob/living/carbon/human/H = owner.current
	if(!istype(master_mob) || !istype(H))
		return
	if(master_mob.ears)
		H.equip_to_slot_or_del(new master_mob.ears.type, ITEM_SLOT_EARS)
	if(master_mob.w_uniform)
		H.equip_to_slot_or_del(new master_mob.w_uniform.type, ITEM_SLOT_ICLOTHING)
	if(master_mob.shoes)
		H.equip_to_slot_or_del(new master_mob.shoes.type, ITEM_SLOT_FEET)
	if(master_mob.wear_suit)
		H.equip_to_slot_or_del(new master_mob.wear_suit.type, ITEM_SLOT_OCLOTHING)
	if(master_mob.head)
		H.equip_to_slot_or_del(new master_mob.head.type, ITEM_SLOT_HEAD)
	if(master_mob.back)
		H.equip_to_slot_or_del(new master_mob.back.type, ITEM_SLOT_BACK)

	//Operation: Fuck off and scare people
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))

/datum/antagonist/wizard/proc/update_wiz_icons_added(mob/living/wiz,join = TRUE)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.join_hud(wiz)
	set_antag_hud(wiz, hud_version)

/datum/antagonist/wizard/proc/update_wiz_icons_removed(mob/living/wiz)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.leave_hud(wiz)
	set_antag_hud(wiz, null)


/datum/antagonist/wizard/academy
	name = "Nauczyciel Akademii"
	outfit_type = /datum/outfit/wizard/academy
	move_to_lair = FALSE

/datum/antagonist/wizard/academy/equip_wizard()
	. = ..()

	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt)
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile)
	owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball)

	var/mob/living/M = owner.current
	if(!istype(M))
		return

	var/obj/item/implant/exile/Implant = new/obj/item/implant/exile(M)
	Implant.implant(M)

/datum/antagonist/wizard/academy/create_objectives()
	var/datum/objective/new_objective = new("Chroń Akademię Czarodziejów przed intruzami")
	new_objective.owner = owner
	objectives += new_objective
	log_objective(owner, new_objective.explanation_text)

//Solo wizard report
/datum/antagonist/wizard/roundend_report()
	var/list/parts = list()

	parts += printplayer(owner)

	var/count = 1
	var/wizardwin = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Cel nr [count]</B>: [objective.explanation_text] <span class='greentext'>Sukces!</span>"
		else
			parts += "<B>Cel nr [count]</B>: [objective.explanation_text] <span class='redtext'>Porażka.</span>"
			wizardwin = 0
		count++

	if(wizardwin)
		parts += "<span class='greentext'>Czarodziej odniósł sukces!</span>"
	else
		parts += "<span class='redtext'>Czarodziej poniósł porażkę!</span>"

	if(owner.spell_list.len>0)
		parts += "<B>[owner.name] używał następujących zaklęć: </B>"
		var/list/spell_names = list()
		for(var/obj/effect/proc_holder/spell/S in owner.spell_list)
			spell_names += S.name
		parts += spell_names.Join(", ")

	return parts.Join("<br>")

//Wizard with apprentices report
/datum/team/wizard/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Czarodzieje i czarownice z drużyny [master_wizard.owner.name]:</span>"
	parts += master_wizard.roundend_report()
	parts += " "
	parts += "<span class='header'>Uczniowie [master_wizard.owner.name]:</span>"
	parts += printplayerlist(members - master_wizard.owner)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
