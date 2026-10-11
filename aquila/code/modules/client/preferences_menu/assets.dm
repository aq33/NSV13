// Port BeeStation #8776: zasoby okna preferencji (ikony wyborów i preferences.json)

/// Ikony dla wpisów choiced z should_generate_icons. Duże listy (włosy) idą na osobne arkusze.
/datum/asset/spritesheet/preferences
	name = PREFERENCE_SHEET_NORMAL

/datum/asset/spritesheet/preferences/register()
	for(var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[preference_key]
		if(!istype(preference) || !preference.should_generate_icons || preference.preference_spritesheet != name)
			continue
		for(var/value in preference.get_choices())
			var/spritesheet_key = preference.get_spritesheet_key(preference.serialize(value))
			if(sprites[spritesheet_key])
				continue
			var/create_icon_of = preference.icon_for(value)
			var/icon/value_icon
			if(ispath(create_icon_of, /atom))
				var/atom/atom_icon_source = create_icon_of
				value_icon = icon(initial(atom_icon_source.icon), initial(atom_icon_source.icon_state), SOUTH, 1)
			else if(isicon(create_icon_of))
				value_icon = create_icon_of
			if(!value_icon)
				continue
			Insert(spritesheet_key, value_icon)
	return ..()

/datum/asset/spritesheet/preferences/large
	name = PREFERENCE_SHEET_LARGE

/datum/asset/spritesheet/preferences/huge
	name = PREFERENCE_SHEET_HUGE

/// Stałe dane okna: wybory, zakresy, dane middleware
/datum/asset/json/preferences
	name = "preferences"

/datum/asset/json/preferences/generate()
	var/list/preference_data = list()
	for(var/middleware_type in subtypesof(/datum/preference_middleware))
		var/datum/preference_middleware/preference_middleware = new middleware_type
		var/data = preference_middleware.get_constant_data()
		if(!isnull(data))
			preference_data[preference_middleware.key] = data
		qdel(preference_middleware)
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		var/data = preference.compile_constant_data()
		if(!isnull(data))
			preference_data[preference.db_key] = data
	return preference_data
