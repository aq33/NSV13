// Port BeeStation #8776: middleware okna preferencji (prace, antagoniści, cechy, loadout, imiona, losowanie, klawisze)
// Każde middleware dokłada swoje dane do okna i obsługuje swoje akcje (action_delegations).

/datum/preference_middleware
	var/datum/preferences/preferences
	/// Klucz w preferences.json, domyślnie końcówka ścieżki typu
	var/key
	/// akcja -> proc(params, user)
	var/list/action_delegations = list()

/datum/preference_middleware/New(datum/preferences/preferences)
	src.preferences = preferences
	if(isnull(key))
		key = copytext("[type]", length("[parent_type]") + 2)

/datum/preference_middleware/Destroy(force, ...)
	preferences = null
	return ..()

/datum/preference_middleware/proc/get_ui_data(mob/user)
	return list()

/datum/preference_middleware/proc/get_ui_static_data(mob/user)
	return list()

/datum/preference_middleware/proc/get_ui_assets()
	return list()

/// Dane do preferences.json
/datum/preference_middleware/proc/get_constant_data()
	return null

/// Dokładane do character_preferences
/datum/preference_middleware/proc/get_character_preferences(mob/user)
	return null

/// Po zmianie postaci (slotu)
/datum/preference_middleware/proc/on_new_character(mob/user)
	return

// Prace

/datum/preference_middleware/jobs
	action_delegations = list(
		"set_job_preference" = PROC_REF(set_job_preference),
		"clear_job_preferences" = PROC_REF(clear_job_preferences),
	)

/// Dział w oknie (nazwy działów są na sztywno w JobsPage.tsx)
/proc/aq_job_department_for_prefs(datum/job/job)
	if(job.title == JOB_NAME_CAPTAIN || job.title == JOB_NAME_BRIDGESTAFF)
		return "Captain"
	if(job.title == SSjob.overflow_role)
		return "Assistant"
	if(job.title == JOB_NAME_HEADOFPERSONNEL || job.title == JOB_NAME_GIMMICK)
		return "Service"
	if(job.title in GLOB.nonhuman_positions)
		return "Silicon"
	if(job.title in GLOB.security_positions)
		return "Security"
	if(job.title in GLOB.engineering_positions)
		return "Engineering"
	if(job.title in GLOB.medical_positions)
		return "Medical"
	if(job.title in GLOB.science_positions)
		return "Science"
	if(job.title in GLOB.munitions_positions)
		return "Munitions"
	if(job.title in GLOB.supply_positions)
		return "Cargo"
	if(job.title in GLOB.civilian_positions)
		return "Service"
	return "Captain"

/datum/preference_middleware/jobs/get_constant_data()
	var/static/list/department_heads = list(
		"Captain" = JOB_NAME_CAPTAIN,
		"Service" = JOB_NAME_HEADOFPERSONNEL,
		"Security" = JOB_NAME_HEADOFSECURITY,
		"Engineering" = JOB_NAME_CHIEFENGINEER,
		"Medical" = JOB_NAME_CHIEFMEDICALOFFICER,
		"Science" = JOB_NAME_RESEARCHDIRECTOR,
		"Munitions" = JOB_NAME_MASTERATARMS,
		"Cargo" = JOB_NAME_QUARTERMASTER,
		"Silicon" = JOB_NAME_AI,
	)
	var/list/departments = list()
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		if(job.gimmick)
			continue
		var/department = aq_job_department_for_prefs(job)
		if(isnull(departments[department]))
			departments[department] = department_heads[department] ? list("head" = department_heads[department]) : list()
		jobs[job.title] = list(
			"description" = job.supervisors ? "Supervisors: [job.supervisors]" : "",
			"department" = department,
			"lock_reason" = null,
		)
	return list(
		"departments" = departments,
		"jobs" = jobs,
	)

/datum/preference_middleware/jobs/get_ui_data(mob/user)
	return list("job_preferences" = preferences.active_character.job_preferences)

/datum/preference_middleware/jobs/get_ui_static_data(mob/user)
	var/list/data = list()
	var/list/job_days_left = list()
	var/list/job_required_experience = list()
	var/list/job_bans = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		if(is_banned_from(user.client?.ckey, job.title))
			job_bans += job.title
			continue
		var/required_playtime_remaining = job.required_playtime_remaining(user.client)
		if(required_playtime_remaining)
			job_required_experience[job.title] = list(
				"experience_type" = job.get_exp_req_type(),
				"required_playtime" = required_playtime_remaining,
			)
			continue
		if(!job.player_old_enough(user.client))
			job_days_left[job.title] = job.available_in_days(user.client)
	if(length(job_days_left))
		data["job_days_left"] = job_days_left
	if(length(job_required_experience))
		data["job_required_experience"] = job_required_experience
	if(length(job_bans))
		data["job_bans"] = job_bans
	return data

/datum/preference_middleware/jobs/proc/set_job_preference(list/params, mob/user)
	var/level = params["level"]
	if(!isnull(level) && level != JP_LOW && level != JP_MEDIUM && level != JP_HIGH)
		return FALSE
	var/datum/job/job = SSjob.GetJob(params["job"])
	if(!job || job.gimmick)
		return FALSE
	if(is_banned_from(user.client?.ckey, job.title) || job.required_playtime_remaining(user.client) || !job.player_old_enough(user.client))
		return FALSE
	if(isnull(level))
		preferences.active_character.job_preferences -= job.title
	else
		preferences.SetJobPreferenceLevel(job, level)
	preferences.update_character_preview()
	return TRUE

/datum/preference_middleware/jobs/proc/clear_job_preferences(list/params, mob/user)
	preferences.ResetJobs()
	preferences.update_character_preview()
	return TRUE

// Antagoniści. Ustawienia "na postać" trzymamy w każdej postaci osobno, więc warstwa globalna
// z okna Bee to dla nich "włączone w którejś postaci", a przełącznik globalny zmienia wszystkie postacie.

/datum/preference_middleware/antags
	action_delegations = list(
		"set_antags" = PROC_REF(set_antags),
	)

/datum/preference_middleware/antags/get_ui_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/enabled_global = list()
	var/list/enabled_character = list()
	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		if(!pref.per_character)
			if(role_enabled(preferences.role_preferences, pref_type))
				enabled_global += "[pref_type]"
			continue
		if(role_enabled(preferences.active_character.role_preferences_character, pref_type))
			enabled_character += "[pref_type]"
		for(var/datum/character_save/save as anything in preferences.character_saves)
			if(role_enabled(save.role_preferences_character, pref_type))
				enabled_global += "[pref_type]"
				break
	return list(
		"enabled_global" = enabled_global,
		"enabled_character" = enabled_character,
	)

/datum/preference_middleware/antags/proc/role_enabled(list/source, pref_type)
	var/value = source["[pref_type]"]
	return !(isnum(value) && !value)

/datum/preference_middleware/antags/get_ui_static_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/data = list()
	var/list/antag_bans = list()
	var/list/hours_left = list()
	var/exempt = !preferences.parent || preferences.parent.holder || !CONFIG_GET(flag/antag_living_playtime_requirements)
	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		if(!ispath(antag_datum, /datum/antagonist))
			continue
		var/ban_key = initial(antag_datum.banning_key)
		if(ban_key && is_banned_from(preferences.parent?.ckey, ban_key))
			antag_bans |= ban_key
		var/living_hours_needed = initial(antag_datum.required_living_playtime)
		if(exempt || living_hours_needed <= 0)
			continue
		var/left = max(0, living_hours_needed - (preferences.parent.get_exp_living(TRUE) / 60))
		if(left > 0)
			hours_left["[pref_type]"] = left
	if(length(antag_bans))
		data["antag_bans"] = antag_bans
	if(length(hours_left))
		data["antag_living_playtime_hours_left"] = hours_left
	return data

/datum/preference_middleware/antags/get_constant_data()
	var/list/antags = list()
	var/list/categories = list()
	for(var/pref_type in GLOB.role_preference_entries)
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		var/datum/antagonist/antag_datum = pref.antag_datum
		categories |= pref.category
		antags += list(list(
			"name" = pref.name,
			"description" = pref.description,
			"category" = pref.category,
			"per_character" = pref.per_character,
			"ban_key" = ispath(antag_datum, /datum/antagonist) ? initial(antag_datum.banning_key) : null,
			"path" = "[pref_type]",
			"icon_path" = serialize_antag_name("[pref_type]"),
			"icon_sheet" = antag_icon_sheet(pref_type),
		))
	return list(
		"antagonists" = antags,
		"categories" = categories,
	)

/datum/preference_middleware/antags/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/antagonists),
		get_asset_datum(/datum/asset/spritesheet/antagonists/second),
		get_asset_datum(/datum/asset/spritesheet/antagonists/third),
	)

/datum/preference_middleware/antags/proc/set_antags(list/params, mob/user)
	var/list/sent_antags = params["antags"]
	if(!islist(sent_antags))
		return FALSE
	var/toggled = !!params["toggled"]
	var/per_character = !!params["character"]
	var/any_changed = FALSE
	var/changed_all_characters = FALSE
	for(var/sent_antag in sent_antags)
		var/datum/role_preference/pref = GLOB.role_preference_entries[text2path(sent_antag)]
		if(!istype(pref))
			continue
		if(!pref.per_character)
			if(per_character)
				continue
			preferences.role_preferences["[pref.type]"] = toggled
		else if(per_character)
			preferences.active_character.role_preferences_character["[pref.type]"] = toggled
		else
			for(var/datum/character_save/save as anything in preferences.character_saves)
				save.role_preferences_character["[pref.type]"] = toggled
			changed_all_characters = TRUE
		any_changed = TRUE
	// Aktywna postać zapisze się przy zamknięciu okna, pozostałe zapisujemy od razu
	if(changed_all_characters)
		for(var/datum/character_save/save as anything in preferences.character_saves)
			if(save != preferences.active_character && save.from_db)
				save.save(preferences.parent)
	return any_changed

/datum/role_preference
	/// Opis w oknie antagonistów
	var/description = ""

/// Bezpieczna nazwa klasy CSS dla ikony antagonisty
/proc/serialize_antag_name(antag_name)
	return lowertext(sanitize_css_class_name(replacetext(antag_name, "/", "_")))

/// Ikona antagonisty dla okna: list(plik, stan). Potwory mają swój sprite, reszta znaczek z HUD-u.
/datum/role_preference/proc/get_preview_source()
	// Podtypy przed rodzicami: wygrywa pierwsze dopasowanie
	var/static/list/sources = list(
		/datum/antagonist/traitor/internal_affairs = list('icons/obj/storage.dmi', "briefcase"),
		/datum/antagonist/traitor/excommunicate = list('icons/obj/card.dmi', "emag"),
		/datum/antagonist/traitor/boarder = list('icons/obj/clothing/hats.dmi', "hardsuit0-syndi"),
		/datum/antagonist/nukeop/syndi_crew = list('icons/obj/clothing/hats.dmi', "syndicate-helm-black-red"),
		/datum/antagonist/nukeop = list('icons/obj/machines/nuke.dmi', "nuclearbomb_base"),
		/datum/antagonist/infiltrator = list('icons/obj/clothing/masks.dmi', "balaclava"),
		/datum/antagonist/vampire = list('icons/mob/animal.dmi', "bat"),
		/datum/antagonist/pirate = list('icons/obj/clothing/hats.dmi', "pirate"),
		/datum/antagonist/chrono_legionnaire = list('icons/obj/clothing/hats.dmi', "chronohelmet"),
		/datum/antagonist/sinfuldemon = list('aquila/icons/mob/mob.dmi', "lesserdaemon"),
		/datum/antagonist/ghost_ship = list('icons/mob/mob.dmi', "ghost"),
		/datum/antagonist/blob = list('icons/mob/blob.dmi', "blob_core"),
		/datum/antagonist/xeno = list('icons/mob/alien.dmi', "alienh"),
		/datum/antagonist/revenant = list('icons/mob/mob.dmi', "revenant_idle"),
		/datum/antagonist/morph = list('icons/mob/animal.dmi', "morph"),
		/datum/antagonist/slaughter = list('icons/mob/mob.dmi', "daemon"),
		/datum/antagonist/space_dragon = list('icons/mob/spacedragon.dmi', "spacedragon"),
		/datum/antagonist/monkey = list('icons/mob/monkey.dmi', "monkey1"),
		/datum/antagonist/horror = list('aquila/icons/mob/horror.dmi', "horror"),
		/datum/antagonist/pulse_demon = list('aquila/icons/mob/pulse_demon.dmi', "pulsedem"),
		/datum/antagonist/voidwalker = list('aquila/icons/mob/voidwalker.dmi', "voidwalker"),
		/datum/antagonist/shadow_demon = list('aquila/icons/mob/shadow_demon.dmi', "shadow_demon"),
		/datum/antagonist/nightmare = list('icons/mob/hud.dmi', "shadowling"),
		/datum/antagonist/bloodling = list('icons/mob/hud.dmi', "bloodling_thrall"),
		/datum/antagonist/thief = list('icons/mob/hud.dmi', "thief"),
		/datum/antagonist/paradox_clone = list('icons/mob/hud.dmi', "paradox_clone"),
		/datum/antagonist/brother = list('icons/mob/hud.dmi', "brother"),
		/datum/antagonist/cult = list('icons/mob/hud.dmi', "cult"),
		/datum/antagonist/servant_of_ratvar = list('icons/mob/hud.dmi', "clockwork"),
		/datum/antagonist/devil = list('icons/mob/hud.dmi', "devil"),
		/datum/antagonist/rev = list('icons/mob/hud.dmi', "rev_head"),
		/datum/antagonist/heretic = list('icons/mob/hud.dmi', "heretic"),
		/datum/antagonist/hivemind = list('icons/mob/hud.dmi', "hivemind"),
		/datum/antagonist/incursion = list('icons/mob/hud.dmi', "incursion"),
		/datum/antagonist/gang = list('icons/mob/hud.dmi', "gang_boss"),
		/datum/antagonist/changeling = list('icons/mob/hud.dmi', "changeling"),
		/datum/antagonist/abductor = list('icons/mob/hud.dmi', "abductor"),
		/datum/antagonist/fugitive = list('icons/mob/hud.dmi', "fugitive"),
		/datum/antagonist/fugitive_hunter = list('icons/mob/hud.dmi', "fugitive_hunter"),
		/datum/antagonist/ninja = list('icons/mob/hud.dmi', "ninja"),
		/datum/antagonist/obsessed = list('icons/mob/hud.dmi', "obsessed"),
		/datum/antagonist/wizard = list('icons/mob/hud.dmi', "wizard"),
		/datum/antagonist/traitor = list('icons/mob/hud.dmi', "traitor"),
	)
	for(var/antag_type in sources)
		if(ispath(antag_datum, antag_type))
			return sources[antag_type]
	return list('icons/mob/hud.dmi', "synd")

/// Ikona 96x96 przycięta do niepustych pikseli
/datum/role_preference/proc/get_preview_icon(icon_size = 96)
	// Role ludzkie: postać w stroju roli (preview_icons.dm)
	var/icon/outfit_icon = get_outfit_preview_icon()
	if(outfit_icon)
		if(icon_size != 96)
			outfit_icon.Scale(icon_size, icon_size)
		return aq_normalized_icon(outfit_icon)
	var/list/preview_source = get_preview_source()
	var/icon/source = icon(preview_source[1], preview_source[2], SOUTH, 1)
	var/width = source.Width()
	var/height = source.Height()
	var/min_x = width + 1
	var/min_y = height + 1
	var/max_x = 0
	var/max_y = 0
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			if(!source.GetPixel(x, y))
				continue
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)
	if(max_x)
		// Kwadrat wokół narysowanych pikseli, wyśrodkowany, z małym marginesem
		var/box_w = max_x - min_x + 1
		var/box_h = max_y - min_y + 1
		var/size = max(box_w, box_h)
		var/margin = max(1, round(size * 0.12))
		var/offset_x = margin + round((size - box_w) / 2)
		var/offset_y = margin + round((size - box_h) / 2)
		size += margin * 2
		// Crop poza krawędzią psuje ikonę (bad icon operation przy wstawianiu), więc wklejamy wycinek na pusty kwadrat
		source.Crop(min_x, min_y, max_x, max_y)
		var/icon/canvas = icon('icons/effects/effects.dmi', "nothing", SOUTH, 1)
		canvas.Scale(size, size)
		canvas.Blend(source, ICON_OVERLAY, offset_x + 1, offset_y + 1)
		source = canvas
	source.Scale(icon_size, icon_size)
	return aq_normalized_icon(source)

/// Ikona roli w powiadomieniu o ankiecie dla duchów (32x32), liczona raz
/datum/role_preference/proc/get_poll_icon()
	var/static/list/cache = list()
	if(!cache[type])
		cache[type] = get_preview_icon(32)
	return cache[type]

/// Jedna ikona BYOND ma ograniczony rozmiar: po około 40 ikonach 96x96 kolejne nie wchodzą (bad icon operation),
/// więc ikony ról dzielimy na kilka arkuszy po ANTAG_ICONS_PER_SHEET
#define ANTAG_ICONS_PER_SHEET 30

/// Nazwa arkusza z ikoną danej roli
/proc/antag_icon_sheet(pref_type)
	var/index = GLOB.role_preference_entries.Find(pref_type)
	var/sheet_number = round((index - 1) / ANTAG_ICONS_PER_SHEET)
	return sheet_number ? "antagonists[sheet_number + 1]" : "antagonists"

/datum/asset/spritesheet/antagonists
	name = "antagonists"

/datum/asset/spritesheet/antagonists/register()
	for(var/pref_type in GLOB.role_preference_entries)
		if(antag_icon_sheet(pref_type) != name)
			continue
		var/datum/role_preference/pref = GLOB.role_preference_entries[pref_type]
		var/icon/preview_icon = pref.get_preview_icon()
		if(preview_icon)
			Insert(serialize_antag_name("[pref_type]"), preview_icon)
	return ..()

/datum/asset/spritesheet/antagonists/second
	name = "antagonists2"

/datum/asset/spritesheet/antagonists/third
	name = "antagonists3"

#undef ANTAG_ICONS_PER_SHEET

// Cechy (quirks)

/datum/preference_middleware/quirks
	action_delegations = list(
		"give_quirk" = PROC_REF(give_quirk),
		"remove_quirk" = PROC_REF(remove_quirk),
	)

/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	return list("selected_quirks" = get_selected_quirks())

/datum/preference_middleware/quirks/on_new_character(mob/user)
	preferences.update_static_data(user)

/datum/preference_middleware/quirks/get_constant_data()
	var/list/quirk_info = list()
	for(var/quirk_name in SSquirks.quirks)
		var/datum/quirk/quirk = SSquirks.quirks[quirk_name]
		if(initial(quirk.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			continue
		quirk_info[sanitize_css_class_name(quirk_name)] = list(
			"description" = html_decode(strip_html_simple(initial(quirk.desc))),
			"icon" = initial(quirk.icon) || (initial(quirk.value) > 0 ? "plus" : (initial(quirk.value) < 0 ? "minus" : "circle")),
			"name" = quirk_name,
			"value" = initial(quirk.value),
		)
	return list(
		"max_positive_quirks" = MAX_QUIRKS,
		"quirk_info" = quirk_info,
		"quirk_blacklist" = SSquirks.quirk_blacklist,
	)

/datum/preference_middleware/quirks/proc/get_selected_quirks()
	var/list/selected_quirks = list()
	for(var/quirk in preferences.active_character.all_quirks)
		selected_quirks += sanitize_css_class_name(quirk)
	return selected_quirks

/// Te same zasady co w starym menu: bilans >= 0, limit dobrych cech, wykluczenia
/datum/preference_middleware/quirks/proc/give_quirk(list/params, mob/user)
	var/quirk = params["quirk"]
	var/list/all_quirks = preferences.active_character.all_quirks
	if(!SSquirks.quirks[quirk] || (quirk in all_quirks))
		return resync(user)
	for(var/list/blacklist as anything in SSquirks.quirk_blacklist)
		if(!(quirk in blacklist))
			continue
		for(var/other in all_quirks)
			if(other != quirk && (other in blacklist))
				to_chat(user, "<span class='danger'>[quirk] is incompatible with [other].</span>")
				return resync(user)
	var/value = SSquirks.quirk_points[quirk]
	if(value > 0 && preferences.GetPositiveQuirkCount() >= MAX_QUIRKS)
		to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] positive quirks!</span>")
		return resync(user)
	if(preferences.GetQuirkBalance() - value < 0)
		to_chat(user, "<span class='warning'>You don't have enough balance to gain this quirk! Take a negative quirk first.</span>")
		return resync(user)
	all_quirks += quirk
	return TRUE

/datum/preference_middleware/quirks/proc/remove_quirk(list/params, mob/user)
	var/quirk = params["quirk"]
	var/list/all_quirks = preferences.active_character.all_quirks
	if(!(quirk in all_quirks))
		return resync(user)
	if(preferences.GetQuirkBalance() + SSquirks.quirk_points[quirk] < 0)
		to_chat(user, "<span class='warning'>Refunding this would cause you to go below your balance!</span>")
		return resync(user)
	all_quirks -= quirk
	return TRUE

/// Okno przewidziało zmianę, której serwer nie przyjął, więc odsyłamy prawdziwy stan
/datum/preference_middleware/quirks/proc/resync(mob/user)
	preferences.update_static_data(user)
	return TRUE

// Loadout (sklep za metamonety)

/datum/preference_middleware/loadout
	action_delegations = list(
		"purchase_gear" = PROC_REF(purchase_gear),
		"equip_gear" = PROC_REF(equip_gear),
		"preview_gear" = PROC_REF(preview_gear),
	)
	/// Stan konta z bazy, odświeżany przy otwarciu okna i zakupie (ui_data nie może czekać na bazę)
	var/cached_balance = 0

/datum/preference_middleware/loadout/proc/refresh_balance()
	cached_balance = preferences.parent?.get_metabalance() || 0

/datum/preference_middleware/loadout/get_ui_data(mob/user)
	return list(
		"equipped_gear" = preferences.active_character.equipped_gear,
		"purchased_gear" = preferences.purchased_gear,
		"metacurrency_balance" = cached_balance,
		"is_donator" = IS_PATRON(preferences.parent?.ckey) || !!preferences.parent?.holder,
		"user_ckey" = preferences.parent?.ckey,
		"preview_gear" = preferences.preview_gear,
	)

/datum/preference_middleware/loadout/get_constant_data()
	var/list/categories = list()
	for(var/category_id in GLOB.loadout_categories)
		var/datum/loadout_category/category = GLOB.loadout_categories[category_id]
		if(category.category == "Donator" && !CONFIG_GET(flag/donator_items))
			continue
		var/list/gear_list = list()
		for(var/gear_id in category.gear)
			var/datum/gear/gear = category.gear[gear_id]
			gear_list += list(list(
				"id" = gear.id,
				"display_name" = gear.display_name,
				"skirt_display_name" = null,
				"description" = gear.description,
				"skirt_description" = null,
				"donator" = gear.sort_category == "Donator",
				"donator_ckey" = gear.unlocktype == GEAR_DONATOR ? gear.ckey : null,
				"cost" = gear.unlocktype == GEAR_DONATOR ? 0 : gear.cost,
				"allowed_roles" = gear.allowed_roles,
				"is_equippable" = !!gear.path,
				"can_preview" = gear.can_preview(),
				"multi_purchase" = FALSE,
			))
		categories += list(list(
			"name" = category.category,
			"gear" = gear_list,
		))
	return list(
		"categories" = categories,
		"metacurrency_name" = CONFIG_GET(string/metacurrency_name),
	)

/// Zakup jak w starym menu, z rozróżnieniem przedmiotów za monety i darczyńców NSV
/datum/preference_middleware/loadout/proc/purchase_gear(list/params, mob/user)
	var/datum/gear/gear = GLOB.gear_datums[params["id"]]
	if(!istype(gear) || (gear.id in preferences.purchased_gear))
		return FALSE
	var/client/C = user.client
	switch(gear.unlocktype)
		if(GEAR_METACOIN)
			if(gear.sort_category == "Donator")
				if(CONFIG_GET(flag/donator_items) && alert(C, "This item is only accessible to our patrons. Would you like to subscribe?", "Patron Locked", "Yes", "No") == "Yes")
					C.donate()
				return FALSE
			refresh_balance()
			if(gear.cost >= cached_balance)
				to_chat(user, "<span class='warning'>You don't have enough [CONFIG_GET(string/metacurrency_name)]s to purchase \the [gear.display_name]!</span>")
				return TRUE
			preferences.purchased_gear += gear.id
			gear.purchase(C)
			C.inc_metabalance((gear.cost * -1), TRUE, "Purchased [gear.display_name].")
			preferences.save_preferences()
			refresh_balance()
		if(GEAR_DONATOR)
			if(C.ckey != gear.ckey)
				log_href_exploit(user)
				return FALSE
			if(!(C.ckey in config.active_donators))
				to_chat(user, "<span class='warning'>Your donation has expired or is not yet valid! Donation status is refreshed at round end.</span>")
				return TRUE
			preferences.purchased_gear += gear.display_name
			gear.purchase(C)
			preferences.save_preferences()
	return TRUE

/datum/preference_middleware/loadout/proc/equip_gear(list/params, mob/user)
	var/datum/gear/gear = GLOB.gear_datums[params["id"]]
	if(!istype(gear))
		return FALSE
	var/list/equipped = preferences.active_character.equipped_gear
	if(gear.id in equipped)
		equipped -= gear.id
		preferences.update_character_preview()
		return TRUE
	if(!(gear.id in preferences.purchased_gear) && !(gear.display_name in preferences.purchased_gear))
		log_href_exploit(user)
		return FALSE
	if(!gear.path)
		return FALSE
	for(var/gear_id in equipped)
		var/datum/gear/other = GLOB.gear_datums[gear_id]
		if(istype(other) && other.subtype_path == gear.subtype_path && other.slot == gear.slot)
			to_chat(user, "<span class='warning'>Can't equip [gear.display_name]. It conflicts with an already-equipped item.</span>")
			return TRUE
	equipped += gear.id
	preferences.update_character_preview()
	return TRUE

/// AQUILA: podgląd przedmiotu na postaci przed zakupem, drugie kliknięcie wyłącza
/datum/preference_middleware/loadout/proc/preview_gear(list/params, mob/user)
	var/gear_id = params["id"]
	preferences.preview_gear = (preferences.preview_gear == gear_id || !GLOB.gear_datums[gear_id]) ? null : gear_id
	preferences.update_character_preview()
	return TRUE

/datum/preference_middleware/loadout/get_ui_assets()
	return list(get_asset_datum(/datum/asset/spritesheet/preferences_loadout))

/datum/asset/spritesheet/preferences_loadout
	name = "preferences_loadout"

/datum/asset/spritesheet/preferences_loadout/register()
	for(var/gear_id in GLOB.gear_datums)
		var/datum/gear/gear = GLOB.gear_datums[gear_id]
		var/obj/item_path = gear.path
		if(!ispath(item_path, /atom))
			continue
		var/item_icon = initial(item_path.icon)
		var/item_state = initial(item_path.icon_state)
		if(!item_icon || !(item_state in aq_pref_icon_states(item_icon)))
			continue
		var/icon/gear_icon = aq_colored_icon(icon(item_icon, item_state, SOUTH, 1), initial(item_path.color))
		if(gear_icon.Width() != 32 || gear_icon.Height() != 32)
			gear_icon.Scale(32, 32)
		Insert("loadout_gear___[gear_id]", gear_icon)
	return ..()

// Imiona

/datum/preference_middleware/names
	action_delegations = list(
		"randomize_name" = PROC_REF(randomize_name),
	)

/datum/preference_middleware/names/get_constant_data()
	var/list/types = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/name/name_preference = GLOB.preference_entries[preference_type]
		if(!istype(name_preference))
			continue
		types[name_preference.db_key] = list(
			"can_randomize" = TRUE,
			"explanation" = name_preference.explanation,
			"group" = name_preference.group,
		)
	return list("types" = types)

/datum/preference_middleware/names/get_ui_data(mob/user)
	return list("name_to_use" = get_name_to_use())

/datum/preference_middleware/names/proc/get_name_to_use()
	var/datum/job/highest_job = preferences.active_character.get_highest_job()
	if(highest_job)
		for(var/preference_type in GLOB.preference_entries)
			var/datum/preference/name/name_preference = GLOB.preference_entries[preference_type]
			if(istype(name_preference) && name_preference.relevant_job && istype(highest_job, name_preference.relevant_job))
				return name_preference.db_key
	return "real_name"

/datum/preference_middleware/names/proc/randomize_name(list/params, mob/user)
	var/datum/preference/name/name_preference = GLOB.preference_entries_by_key[params["preference"]]
	if(!istype(name_preference))
		return FALSE
	var/new_name = name_preference.create_random_value(preferences)
	if(isnull(new_name))
		return FALSE
	name_preference.write_value(preferences, new_name)
	return TRUE

// Losowanie. Mamy tylko "losowe ciało" i "losowe imię", bez losowania pojedynczych cech.

/datum/preference_middleware/random
	action_delegations = list(
		"randomize_character" = PROC_REF(randomize_character),
		"set_random_preference" = PROC_REF(set_random_preference),
	)

/datum/preference_middleware/random/get_character_preferences(mob/user)
	return list("randomization" = list())

/datum/preference_middleware/random/get_constant_data()
	return list("randomizable" = list())

/datum/preference_middleware/random/proc/randomize_character(list/params, mob/user)
	var/datum/character_save/character = preferences.active_character
	character.randomise()
	character.remove_locked_accessories(preferences.parent)
	character.real_name = character.pref_species.random_name(character.gender, TRUE)
	preferences.update_character_preview()
	return TRUE

/datum/preference_middleware/random/proc/set_random_preference(list/params, mob/user)
	return FALSE

// Gatunki: tylko arkusz ikon, dane są w preferencji species

/datum/preference_middleware/species/get_ui_assets()
	return list(get_asset_datum(/datum/asset/spritesheet/species))

/datum/asset/spritesheet/species
	name = "species"

/datum/asset/spritesheet/species/register()
	for(var/species_id in GLOB.roundstart_races)
		var/species_type = GLOB.species_list[species_id]
		var/mob/living/carbon/human/dummy/dummy = new
		dummy.set_species(species_type)
		// Strój asystenta jak w Bee, ale bez nakrycia głowy. Tworzenie nowego kombinezonu w trakcie
		// inicjalizacji zasobów psuło wstawianie ikon kilku gatunków (bad icon operation)
		dummy.equipOutfit(/datum/outfit/job/assistant, TRUE)
		var/obj/item/hat = dummy.head
		if(hat)
			qdel(hat)
		COMPILE_OVERLAYS(dummy)
		var/icon/dummy_icon = getFlatIcon(dummy)
		// Głowa i tułów: kwadrat 16x16 przy górnej krawędzi postaci, wyśrodkowany na obrysie widocznych pikseli.
		// Skrzydła i ogony poszerzają płaską ikonę (apid ma 96x34), więc stały wycinek trafiał w pustkę.
		var/min_x = dummy_icon.Width() + 1
		var/max_x = 0
		var/max_y = 0
		for(var/x in 1 to dummy_icon.Width())
			for(var/y in 1 to dummy_icon.Height())
				if(!dummy_icon.GetPixel(x, y))
					continue
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				max_y = max(max_y, y)
		if(max_x)
			var/center_x = round((min_x + max_x) / 2)
			dummy_icon.Crop(center_x - 7, max_y - 15, center_x + 8, max_y)
		dummy_icon.Scale(64, 64)
		Insert(sanitize_css_class_name(species_id), dummy_icon)
		qdel(dummy)
	return ..()

// Klawisze. U nas key_bindings to klawisz -> lista nazw, w oknie nazwa -> lista klawiszy.

#define MAX_HOTKEY_SLOTS 3

/datum/preference_middleware/keybindings
	action_delegations = list(
		"reset_all_keybinds" = PROC_REF(reset_all_keybinds),
		"reset_keybinds_to_defaults" = PROC_REF(reset_keybinds_to_defaults),
		"set_keybindings" = PROC_REF(set_keybindings),
	)

/datum/preference_middleware/keybindings/get_ui_static_data(mob/user)
	if(preferences.current_window == PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/by_name = list()
	for(var/key in preferences.key_bindings)
		for(var/kb_name in preferences.key_bindings[key])
			if(!by_name[kb_name])
				by_name[kb_name] = list()
			if(key != "Unbound")
				by_name[kb_name] |= key
	return list("keybindings" = by_name)

/datum/preference_middleware/keybindings/get_ui_assets()
	return list(get_asset_datum(/datum/asset/json/keybindings))

/// Usuwa wszystkie klawisze akcji
/datum/preferences/proc/unbind_keybinding(kb_name)
	for(var/key in key_bindings.Copy())
		var/list/names = key_bindings[key]
		if(!(kb_name in names))
			continue
		while(kb_name in names) // domyślne listy mają duplikaty (rdzeń i Aquila rejestrują klawisze)
			names -= kb_name
		if(!length(names) && key != "Unbound")
			key_bindings -= key

/datum/preferences/proc/bind_keybinding(kb_name, key)
	if(!islist(key_bindings[key]))
		key_bindings[key] = list()
	key_bindings[key] |= kb_name
	key_bindings[key] = sortList(key_bindings[key])

/datum/preference_middleware/keybindings/proc/reset_all_keybinds(list/params, mob/user)
	preferences.key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
	preferences.save_preferences()
	preferences.update_static_data(user)
	return TRUE

/datum/preference_middleware/keybindings/proc/reset_keybinds_to_defaults(list/params, mob/user)
	var/kb_name = params["keybind_name"]
	var/datum/keybinding/keybinding = GLOB.keybindings_by_name[kb_name]
	if(isnull(keybinding))
		return FALSE
	preferences.unbind_keybinding(kb_name)
	preferences.bind_keybinding(kb_name, keybinding.key)
	preferences.save_preferences()
	preferences.update_static_data(user)
	return TRUE

/datum/preference_middleware/keybindings/proc/set_keybindings(list/params, mob/user)
	var/kb_name = params["keybind_name"]
	if(isnull(GLOB.keybindings_by_name[kb_name]))
		return FALSE
	var/list/raw_hotkeys = params["hotkeys"]
	if(!istype(raw_hotkeys) || length(raw_hotkeys) > MAX_HOTKEY_SLOTS)
		return FALSE
	var/list/hotkeys = list()
	for(var/hotkey in raw_hotkeys)
		if(!istext(hotkey) || length(hotkey) > 100)
			return FALSE
		hotkeys += hotkey
	preferences.unbind_keybinding(kb_name)
	if(!length(hotkeys))
		preferences.bind_keybinding(kb_name, "Unbound")
	for(var/hotkey in hotkeys)
		preferences.bind_keybinding(kb_name, hotkey)
	preferences.save_preferences()
	return TRUE

#undef MAX_HOTKEY_SLOTS

/datum/asset/json/keybindings
	name = "keybindings"

/datum/asset/json/keybindings/generate()
	var/list/keybindings = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/keybinding = GLOB.keybindings_by_name[name]
		if(!(keybinding.category in keybindings))
			keybindings[keybinding.category] = list()
		keybindings[keybinding.category][keybinding.name] = list(
			"name" = keybinding.full_name || keybinding.name,
			"description" = keybinding.description,
		)
	return keybindings

// Opcje, których gracz jeszcze nie odblokował (polska bielizna, rozmiar "Polak"), okno ukrywa

/datum/preference_middleware/locked_choices

/datum/preference_middleware/locked_choices/get_ui_data(mob/user)
	if(preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()
	var/list/locked = list()
	for(var/key in list("underwear", "undershirt", "socks"))
		var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[key]
		var/list/locked_values = list()
		for(var/value in preference.get_choices())
			if(!is_accessory_unlocked(value, preferences.parent))
				locked_values += value
		if(length(locked_values))
			locked[key] = locked_values
	var/datum/preference/choiced/body_size = GLOB.preference_entries_by_key["body_size"]
	// GLOB.body_sizes to nazwa -> skala, oknu wysyłamy same nazwy
	var/list/allowed_sizes = preferences.get_body_size_choices()
	var/list/locked_sizes = list()
	for(var/size in body_size.get_choices())
		if(!(size in allowed_sizes))
			locked_sizes += size
	if(length(locked_sizes))
		locked["body_size"] = locked_sizes
	return list("locked_choices" = locked)
