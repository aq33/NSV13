// Port BeeStation #8776: zasoby okna preferencji (ikony wyborów i preferences.json)

/// Ikona z nałożonym kolorem przedmiotu (hex albo macierz kolorów, np. szaliki i opaski)
/proc/aq_colored_icon(icon/source, color)
	if(istext(color))
		source.Blend(color, ICON_MULTIPLY)
	else if(islist(color))
		source.MapColors(arglist(color))
	return source

/// Przerysowuje ikonę na czysty podkład z jednym kierunkiem i klatką. Ikony z getFlatIcon (zwłaszcza gatunków
/// z własnymi kończynami) potrafią nie dać się wstawić do arkusza przy pierwszej próbie (bad icon operation).
/proc/aq_normalized_icon(icon/source)
	var/icon/canvas = icon('icons/effects/effects.dmi', "nothing", SOUTH, 1)
	canvas.Scale(source.Width(), source.Height())
	canvas.Blend(source, ICON_OVERLAY)
	return canvas

/// Kopia piksel po pikselu (pierwsza klatka, kierunek SOUTH). Dla małych ikon, gdy aq_normalized_icon nie wystarcza,
/// np. gatunki z animowanymi nakładkami (jaszczur, ćma, oozeling, plazmaman) nie wchodziły do arkusza.
/proc/aq_pixel_copy_icon(icon/source)
	var/icon/first_frame = icon(source, "", SOUTH, 1)
	var/width = first_frame.Width()
	var/height = first_frame.Height()
	var/icon/canvas = icon('icons/effects/effects.dmi', "nothing", SOUTH, 1)
	canvas.Scale(width, height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			var/pixel = first_frame.GetPixel(x, y)
			if(pixel)
				canvas.DrawBox(pixel, x, y)
	return canvas

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
				value_icon = aq_colored_icon(icon(initial(atom_icon_source.icon), initial(atom_icon_source.icon_state), SOUTH, 1), initial(atom_icon_source.color))
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
