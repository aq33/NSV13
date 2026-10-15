// Okno rekordów ochrony w TGUI (zamiast HTML z code/game/machinery/computer/security.dm).
// Przyciski wysyłają te same parametry co dawne linki i idą przez Topic(), więc logi, sprawdzanie dostępu,
// mandaty, wydruki i listy gończe działają bez zmian. Podmenu z temp (statusy, rangi, potwierdzenia)
// są rozbierane na tekst i przyciski.

/obj/machinery/computer/secure_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(z > 6)
			to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
			return
		if(isliving(user))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		ui = new(user, src, "SecurityRecordsConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/secure_data/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated
	data["rank"] = rank
	data["screen"] = screen
	data["printing"] = !!printing
	data["sort_by"] = sortBy
	data["order"] = order
	data["temp"] = temp ? aquila_split_topic_links(temp) : null
	if(!authenticated)
		return data
	switch(screen)
		if(1)
			var/list/statuses = list()
			for(var/datum/data/record/security_record in GLOB.data_core.security)
				statuses["[security_record.fields["name"]]|[security_record.fields["id"]]"] = security_record.fields["criminal"]
			var/list/records = list()
			for(var/datum/data/record/record in sortRecord(GLOB.data_core.general, sortBy, order))
				records += list(list(
					"ref" = REF(record),
					"name" = record.fields["name"],
					"id" = record.fields["id"],
					"rank" = record.fields["rank"],
					"fingerprint" = record.fields["fingerprint"],
					"criminal" = statuses["[record.fields["name"]]|[record.fields["id"]]"] || "",
				))
			data["records"] = records
		if(3)
			data["general"] = security_general_data()
			data["security"] = security_record_data()
	return data

/obj/machinery/computer/secure_data/proc/security_general_data()
	if(!istype(active1, /datum/data/record) || !GLOB.data_core.general.Find(active1))
		return null
	return list(
		"name" = active1.fields["name"],
		"id" = active1.fields["id"],
		"gender" = active1.fields["gender"],
		"age" = active1.fields["age"],
		"species" = active1.fields["species"],
		"rank" = active1.fields["rank"],
		"fingerprint" = active1.fields["fingerprint"],
		"physical" = active1.fields["p_stat"],
		"mental" = active1.fields["m_stat"],
		"photo_front" = security_photo_data(active1.fields["photo_front"]),
		"photo_side" = security_photo_data(active1.fields["photo_side"]),
	)

/// Zdjęcie z rekordu jako base64 (raz na zdjęcie, bo okno odświeża się co chwilę)
/obj/machinery/computer/secure_data/proc/security_photo_data(obj/item/photo/photo)
	if(!istype(photo) || !photo.picture?.picture_image)
		return null
	var/static/list/photo_cache = list()
	var/key = REF(photo)
	if(!photo_cache[key])
		photo_cache[key] = icon2base64(photo.picture.picture_image)
	return photo_cache[key]

/obj/machinery/computer/secure_data/proc/security_record_data()
	if(!istype(active2, /datum/data/record) || !GLOB.data_core.security.Find(active2))
		return null
	var/list/citations = list()
	for(var/datum/data/crime/crime in active2.fields["citation"])
		citations += list(list(
			"id" = crime.dataId,
			"name" = crime.crimeName,
			"fine" = crime.fine,
			"owed" = crime.fine - crime.paid,
			"author" = crime.author,
			"time" = crime.time,
		))
	var/list/crimes = list()
	for(var/datum/data/crime/crime in active2.fields["crim"])
		crimes += list(list(
			"id" = crime.dataId,
			"name" = crime.crimeName,
			"details" = crime.crimeDetails,
			"author" = crime.author,
			"time" = crime.time,
		))
	var/list/comments = list()
	var/counter = 1
	while(active2.fields["com_[counter]"])
		comments += list(list("index" = counter, "text" = active2.fields["com_[counter]"], "deleted" = active2.fields["com_[counter]"] == "<B>Deleted</B>"))
		counter++
	return list(
		"criminal" = active2.fields["criminal"],
		"notes" = active2.fields["notes"],
		"citations" = citations,
		"crimes" = crimes,
		"comments" = comments,
	)

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "topic")
		return
	var/list/href_list = list()
	for(var/key in params)
		if(key == "src")
			continue
		href_list["[key]"] = "[params[key]]"
	if(!href_list["choice"])
		return
	Topic(null, href_list)
	return TRUE

/// Rozbiera HTML z linkami byond://?src=...;klucz=wartość na tekst i przyciski z pełnymi parametrami linku
/proc/aquila_split_topic_links(html)
	var/static/regex/link_regex = regex(@"<a href\s*=\s*'byond://\?src=[^;']+;([^']*)'>(.*?)</a>", "gi")
	var/list/buttons = list()
	while(link_regex.Find(html))
		buttons += list(list("params" = params2list(replacetext(link_regex.group[1], ";", "&")), "label" = strip_html_simple(link_regex.group[2])))
	var/static/regex/empty_items = regex(@"<li>\s*</li>|<ul>\s*</ul>", "gi")
	var/text = link_regex.Replace(html, "")
	text = empty_items.Replace(text, "")
	text = empty_items.Replace(text, "")
	return list("text" = text, "buttons" = buttons)
