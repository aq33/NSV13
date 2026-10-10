///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Pradawny horror"
	roundend_category = "heretycy"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	show_in_antagpanel = FALSE
	banning_key = ROLE_HERETIC_MONSTER
	var/antag_hud_type = ANTAG_HUD_HERETIC
	var/antag_hud_name = "heretic_beast"
	/// Our master (a heretic)'s mind.
	var/datum/mind/master
	show_to_ghosts = TRUE

/datum/antagonist/heretic_monster/on_gain()
	. = ..()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, "<span class='warning'>Esencja twojego sługi, [owner], znika z twojego umysłu.</span>")
		if(owner.current)
			to_chat(owner.current, "<span class='deconversion_message'>Twój umysł spowija mgła - [master ? "[master] nie jest już twoim panem":"nie masz już pana"], jesteś wolny!</span>")
			owner.current.visible_message("[owner.current] wygląda, jakby uwolnił się z łańcuchów Mansusa!", ignored_mobs = owner.current)

	master = null
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
	if(master_heretic)
		LAZYOR(master_heretic.monsters_summoned, WEAKREF(owner))

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Wspieraj swojego pana."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, "<span class='boldnotice'>Jesteś okropnym tworem sprowadzonym na ten plan przez Bramy Mansusa.</span>")
	to_chat(owner, "<span class='notice'>Twoim panem jest [master.name]. Wspieraj go we wszystkim.</span>")

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	remove_antag_hud(antag_hud_type, owner.current)

/datum/antagonist/heretic_monster/get_antag_name() // good to recognise who's responsible with these monsters
	if(!master)
		return "Pradawny horror bez pana"
	return "Pradawny horror: [master.name]"
