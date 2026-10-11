// Port BeeStation #8776: wpisy postaci okna PreferencesMenu, czytane i zapisywane w active_character

// Ikony do przycisków wyglądu

/// Lista stanów ikony, liczona raz na plik
/proc/aq_pref_icon_states(icon_file)
	var/static/list/cache = list()
	var/key = "[icon_file]"
	if(!cache[key])
		cache[key] = icon_states(icon_file)
	return cache[key]

/// Nakłada warstwy części mutanta (BEHIND pod spód, ADJ i FRONT na wierzch)
/proc/aq_pref_mutant_icon(icon/base, datum/sprite_accessory/accessory, key, dir = SOUTH, color)
	var/icon/final_icon = icon('icons/effects/effects.dmi', "nothing")
	var/list/states = accessory?.icon ? aq_pref_icon_states(accessory.icon) : list()
	var/behind = "m_[key]_[accessory?.icon_state]_BEHIND"
	if(accessory && (behind in states))
		var/icon/behind_icon = icon(accessory.icon, behind, dir)
		if(color)
			behind_icon.Blend(color, ICON_MULTIPLY)
		final_icon.Blend(behind_icon, ICON_OVERLAY)
	final_icon.Blend(base, ICON_OVERLAY)
	for(var/layer in list("ADJ", "FRONT"))
		var/state = "m_[key]_[accessory?.icon_state]_[layer]"
		if(!accessory || !(state in states))
			continue
		var/icon/layer_icon = icon(accessory.icon, state, dir)
		if(color)
			layer_icon.Blend(color, ICON_MULTIPLY)
		final_icon.Blend(layer_icon, ICON_OVERLAY)
	return final_icon

/// Głowa z wycięciem i powiększeniem jak u Bee
/proc/aq_pref_head_crop(icon/I)
	I.Crop(10, 19, 22, 31)
	I.Scale(32, 32)
	return I

/proc/aq_pref_greyscale_part(state, color)
	var/icon/I = icon('icons/mob/human_parts_greyscale.dmi', state)
	if(color)
		I.Blend(color, ICON_MULTIPLY)
	return I

/// Ikona akcesorium na głowie (włosy, zarost)
/proc/aq_pref_head_accessory_icon(datum/sprite_accessory/accessory)
	var/static/icon/head_icon
	if(isnull(head_icon))
		head_icon = aq_pref_greyscale_part("human_head_m", "#[skintone2hex("caucasian1")]")
	var/icon/final_icon = icon(head_icon)
	if(accessory?.icon && accessory.icon_state && (accessory.icon_state in aq_pref_icon_states(accessory.icon)))
		var/icon/accessory_icon = icon(accessory.icon, accessory.icon_state)
		accessory_icon.Blend("#5a3b1c", ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
	return aq_pref_head_crop(final_icon)

/// Ikona bielizny na dolnej połowie ciała
/proc/aq_pref_underwear_icon(datum/sprite_accessory/accessory, icon/base, color, list/crop)
	var/icon/final_icon = icon(base)
	if(accessory?.icon && accessory.icon_state && (accessory.icon_state in aq_pref_icon_states(accessory.icon)))
		var/icon/accessory_icon = icon(accessory.icon, accessory.icon_state)
		if(color && !accessory.use_static)
			accessory_icon.Blend(color, ICON_MULTIPLY)
		final_icon.Blend(accessory_icon, ICON_OVERLAY)
	final_icon.Crop(crop[1], crop[2], crop[3], crop[4])
	final_icon.Scale(32, 32)
	return final_icon

/proc/aq_pref_body_icon(list/parts, color)
	var/icon/body = icon('icons/effects/effects.dmi', "nothing")
	for(var/part in parts)
		body.Blend(aq_pref_greyscale_part(part, color), ICON_OVERLAY)
	return body

// Ubrania

/datum/preference/choiced/underwear
	db_key = "underwear"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	character_var = "underwear"
	main_feature_name = "Underwear"
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = TRUE

/datum/preference/choiced/underwear/init_possible_values()
	return GLOB.underwear_list.Copy()

/datum/preference/choiced/underwear/icon_for(value)
	var/static/icon/lower_half
	if(isnull(lower_half))
		lower_half = aq_pref_body_icon(list("human_chest_m", "human_r_leg", "human_l_leg"), "#[skintone2hex("caucasian1")]")
	return aq_pref_underwear_icon(GLOB.underwear_list[value], lower_half, "#333333", list(10, 1, 22, 13))

/datum/preference/choiced/underwear/is_valid(value, datum/preferences/prefs)
	return ..() && is_accessory_unlocked(value, prefs.parent)

/datum/preference/choiced/underwear/is_accessible(datum/preferences/prefs)
	return ..() && !(NO_UNDERWEAR in prefs.active_character.pref_species.species_traits)

/datum/preference/choiced/underwear/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "underwear_color"
	return data

/datum/preference/color/underwear_color
	db_key = "underwear_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	character_var = "underwear_color"
	can_randomize = TRUE

/datum/preference/color/underwear_color/is_accessible(datum/preferences/prefs)
	return ..() && !(NO_UNDERWEAR in prefs.active_character.pref_species.species_traits)

/datum/preference/choiced/undershirt
	db_key = "undershirt"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	character_var = "undershirt"
	main_feature_name = "Undershirt"
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = TRUE

/datum/preference/choiced/undershirt/init_possible_values()
	return GLOB.undershirt_list.Copy()

/datum/preference/choiced/undershirt/icon_for(value)
	var/static/icon/body
	if(isnull(body))
		body = aq_pref_body_icon(list("human_r_leg", "human_l_leg", "human_r_arm", "human_l_arm", "human_r_hand", "human_l_hand", "human_chest_m"), "#[skintone2hex("caucasian1")]")
	return aq_pref_underwear_icon(GLOB.undershirt_list[value], body, null, list(9, 9, 23, 23))

/datum/preference/choiced/undershirt/is_valid(value, datum/preferences/prefs)
	return ..() && is_accessory_unlocked(value, prefs.parent)

/datum/preference/choiced/undershirt/is_accessible(datum/preferences/prefs)
	return ..() && !(NO_UNDERWEAR in prefs.active_character.pref_species.species_traits)

/datum/preference/choiced/socks
	db_key = "socks"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	character_var = "socks"
	main_feature_name = "Socks"
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	can_randomize = TRUE

/datum/preference/choiced/socks/init_possible_values()
	return GLOB.socks_list.Copy()

/datum/preference/choiced/socks/icon_for(value)
	var/static/icon/lower_half
	if(isnull(lower_half))
		lower_half = aq_pref_body_icon(list("human_chest_m", "human_r_leg", "human_l_leg"), "#[skintone2hex("caucasian1")]")
	return aq_pref_underwear_icon(GLOB.socks_list[value], lower_half, null, list(10, 1, 22, 13))

/datum/preference/choiced/socks/is_valid(value, datum/preferences/prefs)
	return ..() && is_accessory_unlocked(value, prefs.parent)

/datum/preference/choiced/socks/is_accessible(datum/preferences/prefs)
	return ..() && !(NO_UNDERWEAR in prefs.active_character.pref_species.species_traits)

/datum/preference/choiced/backpack
	db_key = "backbag"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	character_var = "backbag"
	main_feature_name = "Backpack"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/backpack/init_possible_values()
	return GLOB.backbaglist.Copy()

/datum/preference/choiced/backpack/icon_for(value)
	switch(value)
		if(GBACKPACK)
			return /obj/item/storage/backpack
		if(GSATCHEL)
			return /obj/item/storage/backpack/satchel
		if(LSATCHEL)
			return /obj/item/storage/backpack/satchel/leather
		if(GDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag
		if(DBACKPACK)
			return /obj/item/storage/backpack/medic
		if(DSATCHEL)
			return /obj/item/storage/backpack/satchel/med
		if(DDUFFELBAG)
			return /obj/item/storage/backpack/duffelbag/med
	return /obj/item/storage/backpack

/datum/preference/choiced/jumpsuit_style
	db_key = "jumpsuit_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_CLOTHING
	character_var = "jumpsuit_style"
	main_feature_name = "Jumpsuit"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/jumpsuit_style/init_possible_values()
	return list(PREF_SUIT, PREF_SKIRT)

/datum/preference/choiced/jumpsuit_style/icon_for(value)
	if(value == PREF_SKIRT)
		return /obj/item/clothing/under/color/jumpskirt/grey
	return /obj/item/clothing/under/color/grey

// Włosy

/datum/preference/choiced/hairstyle
	db_key = "hair_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	character_var = "hair_style"
	main_feature_name = "Hairstyle"
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_HUGE
	relevant_species_trait = HAIR
	can_randomize = TRUE

/datum/preference/choiced/hairstyle/init_possible_values()
	return GLOB.hair_styles_list.Copy()

/datum/preference/choiced/hairstyle/icon_for(value)
	return aq_pref_head_accessory_icon(GLOB.hair_styles_list[value])

/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"
	return data

/datum/preference/color/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	character_var = "hair_color"
	relevant_species_trait = HAIR
	can_randomize = TRUE

/datum/preference/choiced/facial_hairstyle
	db_key = "facial_style_name"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	character_var = "facial_hair_style"
	main_feature_name = "Facial Hair"
	should_generate_icons = TRUE
	preference_spritesheet = PREFERENCE_SHEET_LARGE
	relevant_species_trait = FACEHAIR
	can_randomize = TRUE

/datum/preference/choiced/facial_hairstyle/init_possible_values()
	return GLOB.facial_hair_styles_list.Copy()

/datum/preference/choiced/facial_hairstyle/icon_for(value)
	return aq_pref_head_accessory_icon(GLOB.facial_hair_styles_list[value])

/datum/preference/choiced/facial_hairstyle/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "facial_hair_color"
	return data

/datum/preference/color/facial_hair_color
	db_key = "facial_hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	character_var = "facial_hair_color"
	relevant_species_trait = FACEHAIR
	can_randomize = TRUE

/datum/preference/choiced/gradient_style
	db_key = "gradient_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	character_var = "gradient_style"
	relevant_species_trait = HAIR

/datum/preference/choiced/gradient_style/init_possible_values()
	return GLOB.hair_gradients_list.Copy()

/datum/preference/color/gradient_color
	db_key = "gradient_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	character_var = "gradient_color"
	relevant_species_trait = HAIR

// Kolory ciała

/datum/preference/color/eye_color
	db_key = "eye_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	character_var = "eye_color"
	relevant_species_trait = EYECOLOR
	can_randomize = TRUE

/datum/preference/color/eye_color/is_accessible(datum/preferences/prefs)
	return ..() && !(NOEYESPRITES in prefs.active_character.pref_species.species_traits)

/datum/preference/choiced/skin_tone
	db_key = "skin_tone"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	character_var = "skin_tone"
	can_randomize = TRUE

/datum/preference/choiced/skin_tone/init_possible_values()
	return GLOB.skin_tones.Copy()

/datum/preference/choiced/skin_tone/is_accessible(datum/preferences/prefs)
	return ..() && prefs.active_character.pref_species.use_skintones

/datum/preference/choiced/skin_tone/get_display_names()
	var/list/names = list()
	for(var/tone in get_choices())
		names[tone] = capitalize(tone)
	return names

/datum/preference/choiced/skin_tone/compile_constant_data()
	var/list/data = ..()
	var/list/to_hex = list()
	for(var/choice in get_choices())
		var/hex_value = "#[skintone2hex(choice)]"
		var/list/hsl = rgb2num(hex_value, COLORSPACE_HSL)
		to_hex[choice] = list(
			"lightness" = hsl[3],
			"value" = hex_value,
		)
	data["to_hex"] = to_hex
	return data

/// Kolor mutanta, musi być jasny jeśli barwi skórę (jak w starym menu)
/datum/preference/color/mutant_color
	db_key = "feature_mcolor"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "mcolor"
	can_randomize = TRUE

/datum/preference/color/mutant_color/is_accessible(datum/preferences/prefs)
	if(!..())
		return FALSE
	var/list/traits = prefs.active_character.pref_species.species_traits
	return (MUTCOLORS in traits) || (MUTCOLORS_PARTSONLY in traits)

/datum/preference/color/mutant_color/is_valid(value, datum/preferences/prefs)
	if(MUTCOLORS_PARTSONLY in prefs.active_character.pref_species.species_traits)
		return TRUE
	return ReadHSV(RGBtoHSV("#[value]"))[3] >= ReadHSV("#7F7F7F")[3]

/datum/preference/choiced/ethereal_color
	db_key = "feature_ethcolor"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "ethcolor"
	can_randomize = TRUE

/datum/preference/choiced/ethereal_color/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.color_list_ethereal)
		values += GLOB.color_list_ethereal[name]
	return values

/datum/preference/choiced/ethereal_color/get_display_names()
	var/list/names = list()
	for(var/name in GLOB.color_list_ethereal)
		names[GLOB.color_list_ethereal[name]] = name
	return names

/datum/preference/choiced/ethereal_color/is_accessible(datum/preferences/prefs)
	return ..() && istype(prefs.active_character.pref_species, /datum/species/ethereal)

/datum/preference/choiced/helmet_style
	db_key = "helmet_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	character_var = "helmet_style"

/datum/preference/choiced/helmet_style/init_possible_values()
	return list(HELMET_DEFAULT, HELMET_MK2, HELMET_PROTECTIVE)

/datum/preference/choiced/helmet_style/is_accessible(datum/preferences/prefs)
	return ..() && istype(prefs.active_character.pref_species, /datum/species/plasmaman)

/datum/preference/choiced/body_size
	db_key = "body_size"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "body_size"
	relevant_mutant_bodypart = "body_size"

/datum/preference/choiced/body_size/init_possible_values()
	return GLOB.body_sizes.Copy()

/datum/preference/choiced/body_size/is_valid(value, datum/preferences/prefs)
	return value in prefs.get_body_size_choices()

/datum/preference/choiced/body_model
	db_key = "body_model"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "body_model"

/datum/preference/choiced/body_model/init_possible_values()
	return list(MALE, FEMALE)

/datum/preference/choiced/body_model/get_display_names()
	return list(MALE = "Masculine", FEMALE = "Feminine")

/datum/preference/choiced/body_model/is_accessible(datum/preferences/prefs)
	return ..() && !(AGENDER in prefs.active_character.pref_species.species_traits)

// Cechy gatunków. Wartość trzymamy w active_character.features, jak stare menu.

/datum/preference/choiced/species_feature
	abstract_type = /datum/preference/choiced/species_feature
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	can_randomize = TRUE
	/// Nazwa globalnej listy akcesoriów
	var/accessory_list
	/// Klucz w nazwach stanów ikon (m_[icon_key]_...)
	var/icon_key
	/// Część ciała pod akcesorium na ikonie
	var/icon_base_state = "human_head_m"
	var/icon_base_file = 'icons/mob/human_parts_greyscale.dmi'
	var/icon_color = "#7fd36b"
	var/icon_dir = SOUTH
	/// Głowa (wycinek) czy całe ciało
	var/icon_crop_head = TRUE

/datum/preference/choiced/species_feature/init_possible_values()
	var/list/source = GLOB.vars[accessory_list]
	return source.Copy()

/datum/preference/choiced/species_feature/icon_for(value)
	var/list/source = GLOB.vars[accessory_list]
	var/datum/sprite_accessory/accessory = source[value]
	var/icon/base = icon(icon_base_file, icon_base_state, icon_dir)
	if(icon_color)
		base.Blend(icon_color, ICON_MULTIPLY)
	var/icon/final_icon = aq_pref_mutant_icon(base, accessory, icon_key, icon_dir, icon_color)
	if(icon_crop_head)
		return aq_pref_head_crop(final_icon)
	return final_icon

/datum/preference/choiced/species_feature/lizard_tail
	db_key = "feature_lizard_tail"
	feature_key = "tail_lizard"
	relevant_mutant_bodypart = "tail_lizard"
	main_feature_name = "Tail"
	should_generate_icons = TRUE
	accessory_list = "tails_list_lizard"
	icon_key = "tail"
	icon_base_state = "human_chest_m"
	icon_dir = EAST
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/lizard_snout
	db_key = "feature_lizard_snout"
	feature_key = "snout"
	relevant_mutant_bodypart = "snout"
	main_feature_name = "Snout"
	should_generate_icons = TRUE
	accessory_list = "snouts_list"
	icon_key = "snout"
	icon_dir = EAST

/datum/preference/choiced/species_feature/lizard_horns
	db_key = "feature_lizard_horns"
	feature_key = "horns"
	relevant_mutant_bodypart = "horns"
	main_feature_name = "Horns"
	should_generate_icons = TRUE
	accessory_list = "horns_list"
	icon_key = "horns"
	icon_dir = EAST

/datum/preference/choiced/species_feature/lizard_frills
	db_key = "feature_lizard_frills"
	feature_key = "frills"
	relevant_mutant_bodypart = "frills"
	main_feature_name = "Frills"
	should_generate_icons = TRUE
	accessory_list = "frills_list"
	icon_key = "frills"
	icon_dir = EAST

/datum/preference/choiced/species_feature/lizard_spines
	db_key = "feature_lizard_spines"
	feature_key = "spines"
	relevant_mutant_bodypart = "spines"
	main_feature_name = "Spines"
	should_generate_icons = TRUE
	accessory_list = "spines_list"
	icon_key = "spines"
	icon_base_state = "human_chest_m"
	icon_dir = EAST
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/lizard_body_markings
	db_key = "feature_lizard_body_markings"
	feature_key = "body_markings"
	relevant_mutant_bodypart = "body_markings"
	main_feature_name = "Body Markings"
	should_generate_icons = TRUE
	accessory_list = "body_markings_list"
	icon_key = "body_markings"
	icon_base_state = "human_chest_m"
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/lizard_legs
	db_key = "feature_lizard_legs"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "legs"
	relevant_mutant_bodypart = "legs"
	accessory_list = "legs_list"

/datum/preference/choiced/species_feature/human_tail
	db_key = "feature_human_tail"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "tail_human"
	relevant_mutant_bodypart = "tail_human"
	accessory_list = "tails_list_human"

/datum/preference/choiced/species_feature/human_ears
	db_key = "feature_human_ears"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "ears"
	relevant_mutant_bodypart = "ears"
	accessory_list = "ears_list"

/datum/preference/choiced/species_feature/moth_wings
	db_key = "feature_moth_wings"
	feature_key = "moth_wings"
	relevant_mutant_bodypart = "moth_wings"
	main_feature_name = "Wings"
	should_generate_icons = TRUE
	accessory_list = "moth_wings_roundstart_list"
	icon_key = "moth_wings"
	icon_base_state = "human_chest_m"
	icon_color = "#e5d9b4"
	icon_dir = NORTH
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/moth_antennae
	db_key = "feature_moth_antennae"
	feature_key = "moth_antennae"
	relevant_mutant_bodypart = "moth_antennae"
	main_feature_name = "Antennae"
	should_generate_icons = TRUE
	accessory_list = "moth_antennae_roundstart_list"
	icon_key = "moth_antennae"
	icon_color = "#e5d9b4"

/datum/preference/choiced/species_feature/moth_markings
	db_key = "feature_moth_markings"
	feature_key = "moth_markings"
	relevant_mutant_bodypart = "moth_markings"
	main_feature_name = "Markings"
	should_generate_icons = TRUE
	accessory_list = "moth_markings_roundstart_list"
	icon_key = "moth_markings"
	icon_base_state = "human_chest_m"
	icon_color = "#e5d9b4"
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/ipc_screen
	db_key = "feature_ipc_screen"
	feature_key = "ipc_screen"
	relevant_mutant_bodypart = "ipc_screen"
	main_feature_name = "Screen"
	should_generate_icons = TRUE
	accessory_list = "ipc_screens_list"
	icon_key = "ipc_screen"
	icon_base_state = "mcgipc_head"
	icon_color = null

/datum/preference/choiced/species_feature/ipc_screen/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_ipc_screen_color"
	return data

/// Kolor ekranu IPC to u nas kolor oczu
/datum/preference/color/ipc_screen_color
	db_key = "feature_ipc_screen_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	character_var = "eye_color"
	relevant_mutant_bodypart = "ipc_screen"

/datum/preference/choiced/species_feature/ipc_antenna
	db_key = "feature_ipc_antenna"
	feature_key = "ipc_antenna"
	relevant_mutant_bodypart = "ipc_antenna"
	main_feature_name = "Antenna"
	should_generate_icons = TRUE
	accessory_list = "ipc_antennas_list"
	icon_key = "ipc_antenna"
	icon_base_state = "mcgipc_head"
	icon_color = null

/datum/preference/choiced/species_feature/ipc_antenna/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "feature_ipc_antenna_color"
	return data

/// Kolor anteny IPC to u nas kolor włosów
/datum/preference/color/ipc_antenna_color
	db_key = "feature_ipc_antenna_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	character_var = "hair_color"
	relevant_mutant_bodypart = "ipc_antenna"

/datum/preference/choiced/species_feature/ipc_chassis
	db_key = "feature_ipc_chassis"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "ipc_chassis"
	relevant_mutant_bodypart = "ipc_chassis"
	accessory_list = "ipc_chassis_list"

/datum/preference/choiced/species_feature/insect_type
	db_key = "feature_insect_type"
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	feature_key = "insect_type"
	relevant_mutant_bodypart = "insect_type"
	accessory_list = "insect_type_list"

/datum/preference/choiced/species_feature/apid_antenna
	db_key = "feature_apid_antenna"
	feature_key = "apid_antenna"
	relevant_mutant_bodypart = "apid_antenna"
	main_feature_name = "Antenna"
	should_generate_icons = TRUE
	accessory_list = "apid_antenna_list"
	icon_key = "apid_antenna"
	icon_base_file = 'icons/mob/human_parts.dmi'
	icon_base_state = "bee_head_m"
	icon_color = null

/datum/preference/choiced/species_feature/apid_stripes
	db_key = "feature_apid_stripes"
	feature_key = "apid_stripes"
	relevant_mutant_bodypart = "apid_stripes"
	main_feature_name = "Stripes"
	should_generate_icons = TRUE
	accessory_list = "apid_stripes_list"
	icon_key = "apid_stripes"
	icon_base_file = 'icons/mob/human_parts.dmi'
	icon_base_state = "bee_chest_m"
	icon_color = null
	icon_crop_head = FALSE

/datum/preference/choiced/species_feature/apid_headstripes
	db_key = "feature_apid_headstripes"
	feature_key = "apid_headstripes"
	relevant_mutant_bodypart = "apid_headstripes"
	main_feature_name = "Head Stripes"
	should_generate_icons = TRUE
	accessory_list = "apid_headstripes_list"
	icon_key = "apid_headstripes"
	icon_base_file = 'icons/mob/human_parts.dmi'
	icon_base_state = "bee_head_m"
	icon_color = null

// Podstawowe dane postaci

/datum/preference/choiced/gender
	db_key = "gender"
	preference_type = PREFERENCE_CHARACTER
	character_var = "gender"

/datum/preference/choiced/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/is_accessible(datum/preferences/prefs)
	return ..() && !(AGENDER in prefs.active_character.pref_species.species_traits)

/// Jak stare menu: model ciała idzie za płcią, a przy "plural" jest losowany
/datum/preference/choiced/gender/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(new_value == PLURAL)
		prefs.active_character.features["body_model"] = pick(MALE, FEMALE)
	else
		prefs.active_character.features["body_model"] = new_value

/datum/preference/choiced/species
	db_key = "species"
	preference_type = PREFERENCE_CHARACTER

/datum/preference/choiced/species/init_possible_values()
	return GLOB.roundstart_races.Copy()

/datum/preference/choiced/species/read_value(datum/preferences/prefs)
	return prefs.active_character?.pref_species?.id

/datum/preference/choiced/species/is_valid(value, datum/preferences/prefs)
	if(!..())
		return FALSE
	if(CONFIG_GET(keyed_list/paywall_races)[value] && !IS_PATRON(prefs.parent.ckey) && !prefs.parent.holder)
		to_chat(prefs.parent, "<span class='warning'>This species is only accessible to our patrons.</span>")
		return FALSE
	return TRUE

/// Zmiana gatunku jak w starym menu: kolor mutanta, wymuszone cechy, rozmiar ciała
/datum/preference/choiced/species/write_value(datum/preferences/prefs, value)
	var/datum/character_save/character = prefs.active_character
	var/new_species_type = GLOB.species_list[value]
	character.pref_species = new new_species_type()
	var/temp_hsv = RGBtoHSV(character.features["mcolor"])
	if(character.features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in character.pref_species.species_traits) && ReadHSV(temp_hsv)[3] < ReadHSV("#7F7F7F")[3]))
		character.features["mcolor"] = character.pref_species.default_color
	for(var/forced_part in character.pref_species.forced_features)
		character.features[forced_part] = character.pref_species.forced_features[forced_part]
	if(!(character.features["body_size"] in character.pref_species.get_body_sizes()))
		character.features["body_size"] = "Normal"

/datum/preference/choiced/species/compile_constant_data()
	var/list/data = list()
	for(var/species_id in get_choices())
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()
		var/list/enabled_features = list()
		for(var/preference_type in GLOB.preference_entries)
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			if(preference.category != PREFERENCE_CATEGORY_FEATURES)
				continue
			if(preference.relevant_mutant_bodypart && !(preference.relevant_mutant_bodypart in species.default_features) && !(preference.relevant_mutant_bodypart in species.mutant_bodyparts))
				continue
			if(preference.relevant_species_trait && !(preference.relevant_species_trait in species.species_traits))
				continue
			enabled_features += preference.db_key
		data[species_id] = list(
			"name" = capitalize(replacetext(species.name, "\improper ", "")),
			"desc" = species.aq_species_desc(),
			"lore" = null,
			"icon" = sanitize_css_class_name(species_id),
			"use_skintones" = species.use_skintones,
			"sexes" = species.sexes && !(AGENDER in species.species_traits),
			"enabled_features" = enabled_features,
			"perks" = list("positive" = list(), "negative" = list(), "neutral" = list()),
			"selectable" = TRUE,
		)
		qdel(species)
	return data

/// Krótki opis gatunku do okna wyboru
/datum/species/proc/aq_species_desc()
	return ""

/datum/preference/numeric/age
	db_key = "age"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "age"
	minimum = AGE_MIN
	maximum = AGE_MAX
	can_randomize = TRUE

/// U nas to tak/nie, w oknie RandomSetting
/datum/preference/choiced/random_toggle
	abstract_type = /datum/preference/choiced/random_toggle
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/random_toggle/init_possible_values()
	return list(RANDOM_DISABLED, RANDOM_ENABLED)

/datum/preference/choiced/random_toggle/deserialize(input, datum/preferences/prefs)
	if(istext(input))
		input = text2num(input)
	if(input == RANDOM_ANTAG_ONLY)
		input = RANDOM_ENABLED
	return input

/datum/preference/choiced/random_toggle/serialize(value)
	return value

/datum/preference/choiced/random_toggle/read_value(datum/preferences/prefs)
	return prefs.active_character.vars[character_var] ? RANDOM_ENABLED : RANDOM_DISABLED

/datum/preference/choiced/random_toggle/write_value(datum/preferences/prefs, value)
	prefs.active_character.vars[character_var] = value == RANDOM_ENABLED

/datum/preference/choiced/random_toggle/body
	db_key = "body_is_always_random"
	character_var = "be_random_body"

/datum/preference/choiced/random_toggle/name
	db_key = "name_is_always_random"
	character_var = "be_random_name"

/datum/preference/choiced/joblessrole
	db_key = "joblessrole"
	preference_type = PREFERENCE_CHARACTER
	character_var = "joblessrole"

/datum/preference/choiced/joblessrole/init_possible_values()
	return list(BEOVERFLOW, BERANDOMJOB, RETURNTOLOBBY)

/datum/preference/choiced/joblessrole/deserialize(input, datum/preferences/prefs)
	return istext(input) ? text2num(input) : input

/datum/preference/choiced/ai_core_display
	db_key = "preferred_ai_core_display"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "preferred_ai_core_display"

/datum/preference/choiced/ai_core_display/init_possible_values()
	return GLOB.ai_core_display_screens - "Portrait"

/datum/preference/choiced/security_department
	db_key = "preferred_security_department"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "preferred_security_department"

/datum/preference/choiced/security_department/init_possible_values()
	return GLOB.security_depts_prefs.Copy()

/datum/preference/choiced/uplink_location
	db_key = "uplink_loc"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "uplink_spawn_loc"

/datum/preference/choiced/uplink_location/init_possible_values()
	return GLOB.uplink_spawn_loc_list_save.Copy()

/datum/preference/choiced/uplink_location/get_display_names()
	var/list/names = list()
	for(var/location in get_choices())
		names[location] = location == UPLINK_IMPLANT ? UPLINK_IMPLANT_WITH_PRICE : location
	return names

// NSV13

/datum/preference/choiced/pilot_role
	db_key = "preferred_pilot_role"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "preferred_pilot_role"

/datum/preference/choiced/pilot_role/init_possible_values()
	return GLOB.pilot_role_prefs.Copy()

/datum/preference/choiced/squad
	db_key = "preferred_squad"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "preferred_squad"

/datum/preference/choiced/squad/init_possible_values()
	var/list/squads = list()
	for(var/datum/squad/squad_type as anything in subtypesof(/datum/squad))
		if(initial(squad_type.name))
			squads += initial(squad_type.name)
	return squads

/datum/preference/choiced/lizard_hiss_style
	db_key = "lizard_hiss_style"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "lizard_hiss_style"

/datum/preference/choiced/lizard_hiss_style/init_possible_values()
	return list(LIZARD_HISS_EXPANDED, LIZARD_HISS_LEGACY)

/datum/preference/choiced/lizard_hiss_style/is_accessible(datum/preferences/prefs)
	return ..() && istype(prefs.active_character.pref_species, /datum/species/lizard)

/// Rola w Syndykacie (PvP) ma własne okno; tu tylko pokazujemy wybór i przycisk do niego
/datum/preference/syndie_role
	db_key = "preferred_syndie_role"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	player_var = "preferred_syndie_role"

/datum/preference/syndie_role/should_show_on_page(preference_tab)
	return preference_tab == PREFERENCE_TAB_CHARACTER_PREFERENCES

/datum/preference/syndie_role/is_valid(value, datum/preferences/prefs)
	return FALSE

/datum/preference/text/flavor_text
	db_key = "flavor_text"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "flavor_text"
	edit_prompt = "Set the flavor text for your 'examine' verb. No memes, nothing that people can't see at a glance, nothing Out Of Character, nothing that breaks the game."

/datum/preference/text/silicon_flavor_text
	db_key = "silicon_flavor_text"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "silicon_flavor_text"
	edit_prompt = "Set the flavor text in your 'examine' verb. This is for describing what people can tell by looking at your character."

/datum/preference/text/general_record
	db_key = "general_record"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "general_record"
	edit_prompt = "Set your general record. This is more or less public information, available from security, medical and command consoles"

/datum/preference/text/security_record
	db_key = "security_record"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "security_record"
	edit_prompt = "Set your security record."

/datum/preference/text/medical_record
	db_key = "medical_record"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	character_var = "medical_record"
	edit_prompt = "Set your medical record."

// Imiona

/datum/preference/name
	abstract_type = /datum/preference/name
	category = PREFERENCE_CATEGORY_NAMES
	preference_type = PREFERENCE_CHARACTER
	/// Opis w oknie innych imion
	var/explanation
	/// Grupa w oknie innych imion
	var/group
	var/allow_numbers = FALSE
	/// Pusty tekst = nazwa domyślna (np. cyborg)
	var/allow_null = FALSE
	/// Typ pracy, przy której okno pokazuje to imię zamiast prawdziwego
	var/relevant_job

/datum/preference/name/deserialize(input, datum/preferences/prefs)
	if(!istext(input))
		return null
	if(allow_null && !length(trim(input)))
		return ""
	return reject_bad_name(input, allow_numbers)

/datum/preference/name/create_random_value(datum/preferences/prefs)
	return null

/datum/preference/name/real_name
	db_key = "real_name"
	character_var = "real_name"
	explanation = "Name"
	group = "_real_name"

/datum/preference/name/real_name/deserialize(input, datum/preferences/prefs)
	if(!istext(input))
		return null
	return reject_bad_name(input, prefs.active_character.pref_species.allow_numbers_in_name)

/datum/preference/name/real_name/create_random_value(datum/preferences/prefs)
	var/datum/character_save/character = prefs.active_character
	return character.pref_species.random_name(character.gender, TRUE)

/// Imiona z GLOB.preferences_custom_names, trzymane w active_character.custom_names
/datum/preference/name/custom
	abstract_type = /datum/preference/name/custom
	var/custom_name_id

/datum/preference/name/custom/New()
	. = ..()
	var/list/namedata = GLOB.preferences_custom_names[custom_name_id]
	explanation = namedata["pref_name"]
	group = namedata["group"]
	allow_numbers = namedata["allow_numbers"]
	allow_null = namedata["allow_null"]

/datum/preference/name/custom/read_value(datum/preferences/prefs)
	return prefs.active_character.custom_names[custom_name_id]

/datum/preference/name/custom/write_value(datum/preferences/prefs, value)
	prefs.active_character.custom_names[custom_name_id] = value

/datum/preference/name/custom/create_random_value(datum/preferences/prefs)
	return get_default_name(custom_name_id)

/datum/preference/name/custom/backup_human
	db_key = "human_name"
	custom_name_id = "human"

/datum/preference/name/custom/clown
	db_key = "clown_name"
	custom_name_id = "clown"
	relevant_job = /datum/job/clown

/datum/preference/name/custom/mime
	db_key = "mime_name"
	custom_name_id = "mime"
	relevant_job = /datum/job/mime

/datum/preference/name/custom/cyborg
	db_key = "cyborg_name"
	custom_name_id = "cyborg"
	relevant_job = /datum/job/cyborg

/datum/preference/name/custom/ai
	db_key = "ai_name"
	custom_name_id = "ai"
	relevant_job = /datum/job/ai

/datum/preference/name/custom/religion
	db_key = "religion_name"
	custom_name_id = "religion"
	relevant_job = /datum/job/chaplain

/datum/preference/name/custom/deity
	db_key = "deity_name"
	custom_name_id = "deity"
