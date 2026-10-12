/datum/language_menu
	var/datum/language_holder/language_holder

/datum/language_menu/New(_language_holder)
	language_holder = _language_holder

/datum/language_menu/Destroy()
	language_holder = null
	. = ..()


/datum/language_menu/ui_state(mob/user)
	return GLOB.language_menu_state

/datum/language_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LanguageMenu")
		ui.open()

// AQ EDIT START - port BeeStation #13895: data for the LanguageMenu window from Bee.
// Every language is sent, the window hides the unknown ones unless in admin mode.
/datum/language_menu/ui_data(mob/user)
	var/list/data = list()
	var/atom/movable/speaker = language_holder.get_atom()

	data["languages"] = list()
	for(var/datum/language/language as anything in GLOB.all_languages)
		var/list/lang_data = list()
		lang_data["name"] = initial(language.name)
		lang_data["desc"] = initial(language.desc)
		lang_data["key"] = initial(language.key)
		lang_data["is_default"] = (language == language_holder.selected_language)
		lang_data["icon"] = initial(language.icon)
		lang_data["icon_state"] = initial(language.icon_state)
		if(speaker)
			lang_data["can_speak"] = !!speaker.has_language(language, TRUE)
			lang_data["could_speak"] = !!(language_holder.omnitongue || speaker.could_speak_language(language))
			lang_data["can_understand"] = !!speaker.has_language(language)
		data["languages"] += list(lang_data)

	data["is_living"] = isliving(speaker)
	data["admin_mode"] = check_rights_for(user.client, R_ADMIN) || isobserver(speaker)
	data["omnitongue"] = language_holder.omnitongue
	return data
// AQ EDIT END

/datum/language_menu/ui_act(action, params)
	if(..())
		return
	var/mob/user = usr
	var/atom/movable/AM = language_holder.get_atom()

	var/language_name = params["language_name"]
	var/datum/language/language_datum
	for(var/lang in GLOB.all_languages)
		var/datum/language/language = lang
		if(language_name == initial(language.name))
			language_datum = language
	var/is_admin = check_rights_for(user.client, R_ADMIN)

	switch(action)
		if("select_default")
			if(language_datum && AM.can_speak_language(language_datum))
				language_holder.selected_language = language_datum
				. = TRUE
		if("grant_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"Jak chcesz dodać ten język?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				language_holder.grant_language(language_datum, understood, spoken)
				if(is_admin)
					message_admins("[key_name_admin(user)] granted the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] granted the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("remove_language")
			if((is_admin || isobserver(AM)) && language_datum)
				var/list/choices = list("Only Spoken", "Only Understood", "Both")
				var/choice = input(user,"Którą część chcesz usunąć?","[language_datum]",null) as null|anything in choices
				var/spoken = FALSE
				var/understood = FALSE
				switch(choice)
					if("Only Spoken")
						spoken = TRUE
					if("Only Understood")
						understood = TRUE
					if("Both")
						spoken = TRUE
						understood = TRUE
				language_holder.remove_language(language_datum, understood, spoken)
				if(is_admin)
					message_admins("[key_name_admin(user)] removed the [language_name] language to [key_name_admin(AM)].")
					log_admin("[key_name(user)] removed the language [language_name] to [key_name(AM)].")
				. = TRUE
		if("toggle_omnitongue")
			if(is_admin || isobserver(AM))
				language_holder.omnitongue = !language_holder.omnitongue
				if(is_admin)
					message_admins("[key_name_admin(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that they know) of [key_name_admin(AM)].")
					log_admin("[key_name(user)] [language_holder.omnitongue ? "enabled" : "disabled"] the ability to speak all languages (that_they know) of [key_name(AM)].")
				. = TRUE
