// Port BeeStation #8776 (Preferences Redux): wpisy preferencji dla okna PreferencesMenu.
// U Bee każdy wpis ma własne miejsce w bazie. U nas wpis jest tylko widokiem na istniejące zmienne:
// active_character (character_var / feature_key), /datum/preferences (player_var) albo bit w toggles (toggle_var + toggle_bit).
// Zapis do bazy robią nadal active_character.save() i save_preferences().

/// Typ wpisu -> instancja
GLOBAL_LIST_INIT(preference_entries, init_preference_entries())
/// db_key -> instancja
GLOBAL_LIST_INIT(preference_entries_by_key, init_preference_entries_by_key())

/proc/init_preference_entries()
	var/list/output = list()
	for(var/datum/preference/preference_type as anything in subtypesof(/datum/preference))
		if(initial(preference_type.abstract_type) == preference_type)
			continue
		output[preference_type] = new preference_type
	return output

/proc/init_preference_entries_by_key()
	var/list/output = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		output[preference.db_key] = preference
	return output

/datum/preference
	var/abstract_type = /datum/preference
	/// Klucz wysyłany do okna. Okno szuka po nim definicji w preferences/features/*.tsx
	var/db_key
	/// PREFERENCE_CATEGORY_*, decyduje gdzie okno pokaże ustawienie
	var/category = PREFERENCE_CATEGORY_MISC
	/// PREFERENCE_CHARACTER albo PREFERENCE_PLAYER
	var/preference_type = PREFERENCE_PLAYER

	/// Zmienna /datum/character_save
	var/character_var
	/// Klucz w active_character.features
	var/feature_key
	/// Zmienna /datum/preferences
	var/player_var
	/// Nazwa zmiennej z bitami (toggles, toggles2, chat_toggles)
	var/toggle_var
	var/toggle_bit = 0
	/// Bit oznacza wyłączenie (np. PREFTOGGLE_DISABLE_DEATHRATTLE)
	var/toggle_inverted = FALSE

	/// Pokazywane tylko gdy gatunek ma tę cechę w default_features albo mutant_bodyparts
	var/relevant_mutant_bodypart
	/// Pokazywane tylko gdy gatunek ma tę cechę w species_traits
	var/relevant_species_trait

	/// Czy przycisk losowania postaci może zmieniać to ustawienie
	var/can_randomize = FALSE

/// Surowa wartość z naszych zmiennych
/datum/preference/proc/read_value(datum/preferences/prefs)
	if(toggle_var)
		var/on = !!(prefs.vars[toggle_var] & toggle_bit)
		return toggle_inverted ? !on : on
	if(feature_key)
		return prefs.active_character?.features[feature_key]
	if(character_var)
		return prefs.active_character?.vars[character_var]
	if(player_var)
		return prefs.vars[player_var]
	CRASH("Preference [type] has no storage defined")

/// Zapis już sprawdzonej wartości do naszych zmiennych
/datum/preference/proc/write_value(datum/preferences/prefs, value)
	if(toggle_var)
		var/on = toggle_inverted ? !value : !!value
		if(on)
			prefs.vars[toggle_var] |= toggle_bit
		else
			prefs.vars[toggle_var] &= ~toggle_bit
		return
	if(feature_key)
		prefs.active_character.features[feature_key] = value
		return
	if(character_var)
		prefs.active_character.vars[character_var] = value
		return
	if(player_var)
		prefs.vars[player_var] = value
		return
	CRASH("Preference [type] has no storage defined")

/// Wartość z okna -> nasza wartość. Wejście jest niezaufane, null = odrzucone.
/datum/preference/proc/deserialize(input, datum/preferences/prefs)
	return input

/// Nasza wartość -> to, co dostaje okno
/datum/preference/proc/serialize(value)
	return value

/datum/preference/proc/is_valid(value, datum/preferences/prefs)
	return TRUE

/// Wartość dla przycisku losowania
/datum/preference/proc/create_random_value(datum/preferences/prefs)
	return null

/// Efekty po zmianie (przeładowanie HUD-u, dźwięki itd.)
/datum/preference/proc/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	return

/datum/preference/proc/compile_ui_data(mob/user, value)
	return serialize(value)

/// Dane do preferences.json
/datum/preference/proc/compile_constant_data()
	return null

/datum/preference/proc/should_show_on_page(preference_tab)
	var/is_on_character_page = preference_tab == PREFERENCE_TAB_CHARACTER_PREFERENCES
	var/is_character_preference = preference_type == PREFERENCE_CHARACTER
	return is_on_character_page == is_character_preference

/// Czy ustawienie jest dostępne dla tej postaci/gracza
/datum/preference/proc/is_accessible(datum/preferences/prefs)
	if(preference_type == PREFERENCE_CHARACTER)
		var/datum/species/species = prefs.active_character?.pref_species
		if(!species)
			return FALSE
		if(relevant_mutant_bodypart && !(relevant_mutant_bodypart in species.default_features) && !(relevant_mutant_bodypart in species.mutant_bodyparts))
			return FALSE
		if(relevant_species_trait && !(relevant_species_trait in species.species_traits))
			return FALSE
	return TRUE

/// Zmiana z okna: walidacja, zapis, efekty. Zwraca TRUE gdy coś zapisano.
/datum/preferences/proc/update_preference(datum/preference/preference, input)
	if(!preference.is_accessible(src))
		return FALSE
	var/value = preference.deserialize(input, src)
	if(isnull(value) || !preference.is_valid(value, src))
		return FALSE
	var/old_value = preference.read_value(src)
	if(old_value == value)
		return TRUE
	preference.write_value(src, value)
	preference.on_changed(src, parent, old_value, value)
	return TRUE

/// Wybór jednej z listy wartości
/datum/preference/choiced
	abstract_type = /datum/preference/choiced
	/// Czy generować ikonę dla każdej wartości (icon_for)
	var/should_generate_icons = FALSE
	/// Nazwa przycisku przy podglądzie (kategorie features/clothing)
	var/main_feature_name
	/// Na który spritesheet trafiają ikony
	var/preference_spritesheet = PREFERENCE_SHEET_NORMAL
	var/list/cached_values

/datum/preference/choiced/proc/get_choices()
	if(isnull(cached_values))
		cached_values = init_possible_values()
	return cached_values

/datum/preference/choiced/proc/init_possible_values()
	CRASH("init_possible_values() not implemented for [type]")

/// Typ atomu albo /icon dla danej wartości
/datum/preference/choiced/proc/icon_for(value)
	CRASH("icon_for() not implemented for [type]")

/datum/preference/choiced/proc/get_spritesheet_key(value)
	return "[db_key]___[sanitize_css_class_name(value)]"

/datum/preference/choiced/deserialize(input, datum/preferences/prefs)
	if(!istext(input) && !isnum(input))
		return null
	return input

/datum/preference/choiced/is_valid(value, datum/preferences/prefs)
	return value in get_choices()

/datum/preference/choiced/create_random_value(datum/preferences/prefs)
	return pick(get_choices())

/datum/preference/choiced/compile_constant_data()
	var/list/data = list()
	var/list/choices = list()
	for(var/choice in get_choices())
		choices += serialize(choice)
	data["choices"] = choices

	var/list/display_names = get_display_names()
	if(length(display_names))
		data["display_names"] = display_names

	if(should_generate_icons)
		var/list/icons = list()
		for(var/choice in get_choices())
			icons[serialize(choice)] = get_spritesheet_key(serialize(choice))
		data["icons"] = icons
		data["icon_sheet"] = preference_spritesheet

	if(!isnull(main_feature_name))
		data["name"] = main_feature_name
	return data

/// Opcjonalne ładne nazwy wartości: list(wartość = "Nazwa")
/datum/preference/choiced/proc/get_display_names()
	return null

/// Kolor jako #rrggbb. Postacie trzymają kolory bez #, gracz z # (color_with_crunch)
/datum/preference/color
	abstract_type = /datum/preference/color
	var/color_with_crunch = FALSE

/datum/preference/color/serialize(value)
	if(!istext(value) || !length(value))
		return "#ffffff"
	return sanitize_hexcolor(value, 6, TRUE, "#ffffff")

/datum/preference/color/deserialize(input, datum/preferences/prefs)
	if(!istext(input) || !findtext(input, GLOB.is_color))
		return null
	return sanitize_hexcolor(input, 6, color_with_crunch)

/datum/preference/color/create_random_value(datum/preferences/prefs)
	return sanitize_hexcolor(random_color(), 6, color_with_crunch)

/// Liczba z zakresu
/datum/preference/numeric
	abstract_type = /datum/preference/numeric
	var/minimum = 0
	var/maximum = 100
	var/step = 1

/datum/preference/numeric/deserialize(input, datum/preferences/prefs)
	if(istext(input))
		input = text2num(input)
	if(!isnum(input))
		return null
	return clamp(round(input, step), minimum, maximum)

/datum/preference/numeric/create_random_value(datum/preferences/prefs)
	return round(rand(minimum, maximum), step)

/datum/preference/numeric/compile_constant_data()
	return list(
		"minimum" = minimum,
		"maximum" = maximum,
		"step" = step,
	)

/// Włącz/wyłącz
/datum/preference/toggle
	abstract_type = /datum/preference/toggle

/datum/preference/toggle/deserialize(input, datum/preferences/prefs)
	if(istext(input))
		input = text2num(input)
	return !!input

/datum/preference/toggle/serialize(value)
	return !!value

/// Dowolny tekst, np. flavor text
/datum/preference/text
	abstract_type = /datum/preference/text
	var/maximum_length = MAX_MESSAGE_LEN
	/// Opis w okienku edycji
	var/edit_prompt = ""

/datum/preference/text/deserialize(input, datum/preferences/prefs)
	if(!istext(input))
		return null
	return copytext(html_decode(strip_html_simple(input)), 1, maximum_length)

/datum/preference/text/compile_constant_data()
	return list("maximum_length" = maximum_length)
