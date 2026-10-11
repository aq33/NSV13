// Port BeeStation #12236: changelog w TGUI. Okno pobiera miesiące z html/changelogs/archive/RRRR-MM.yml,
// które CI zapisuje obok .all_changelog.yml (tools/changelog/ss13_genchangelog.py).
// Stary changelog.html zostaje i nadal służy do wykrywania zmian (GLOB.changelog_hash).

GLOBAL_DATUM(changelog_tgui, /datum/changelog)

/datum/changelog
	var/static/list/changelog_items = list()

/datum/changelog/ui_state()
	return GLOB.always_state

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Changelog")
		ui.open()

/datum/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "get_month")
		var/date = params["date"]
		if(!findtext(date, regex(@"^\d{4}-\d{2}$")))
			return
		var/datum/asset/changelog_item/changelog_item = changelog_items[date]
		if(!changelog_item)
			changelog_item = new /datum/asset/changelog_item(date)
			changelog_items[date] = changelog_item
		return ui.send_asset(changelog_item)

/datum/changelog/ui_static_data()
	var/list/data = list("dates" = list())
	var/regex/yml_regex = regex(@"\.yml", "g")
	for(var/archive_file in sort_list(flist("html/changelogs/archive/")))
		var/archive_date = yml_regex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]
	for(var/datum/tgs_revision_information/test_merge/testmerge in world.TgsTestMerges())
		if(!testmerge.body || findtext(testmerge.title, @"[s]"))
			continue
		var/list/changes = parse_github_changelog(testmerge.body)
		if(!length(changes))
			changes = list("unknown" = list("Zmiany nie są opisane. Poproś autora ([testmerge.author]) o dodanie changeloga do PR-a!"))
		LAZYADD(data["testmerges"], list(list(
			"title" = "[testmerge.title]",
			"number" = testmerge.number,
			"author" = testmerge.author,
			"link" = testmerge.url,
			"changes" = changes,
		)))
	return data

/// Reads the :cl: block of a PR body into change type -> list of descriptions
/proc/parse_github_changelog(body)
	var/static/regex/cl_pattern = new(@"(:cl:|🆑)([\S \t]*)$")
	var/static/regex/entry_pattern = new(@"(\w+): (.+)")
	var/static/regex/end_pattern = new(@"^/(:cl:|🆑)")
	var/static/regex/newline_pattern = new(@"(\r\n|\r|\n)")

	var/started = FALSE
	var/list/lines = splittext_char(trim(body), newline_pattern)
	for(var/line in lines)
		line = trim(line)
		if(findtext_char(line, end_pattern))
			break
		if(started)
			if(findtext_char(line, entry_pattern))
				var/change_type = trim(entry_pattern.group[1])
				var/change_desc = trim(entry_pattern.group[2])
				if(!change_type || !change_desc)
					continue
				LAZYADDASSOCLIST(., change_type, change_desc)
		else if(findtext_char(line, cl_pattern))
			started = TRUE

/// One month of the changelog, sent to the client when the window asks for it
/datum/asset/changelog_item
	_abstract = /datum/asset/changelog_item
	var/item_filename

/datum/asset/changelog_item/New(date)
	item_filename = SANITIZE_FILENAME("[date].yml")
	SSassets.transport.register_asset(item_filename, file("html/changelogs/archive/" + item_filename))

/datum/asset/changelog_item/send(client)
	if(!item_filename)
		return
	. = SSassets.transport.send_assets(client, item_filename)

/datum/asset/changelog_item/get_url_mappings()
	if(!item_filename)
		return
	. = list("[item_filename]" = SSassets.transport.get_asset_url(item_filename))
