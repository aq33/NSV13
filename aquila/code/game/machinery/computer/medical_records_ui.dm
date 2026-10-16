// Okno akt medycznych w TGUI (zamiast HTML z code/game/machinery/computer/medical.dm).
// Przyciski wysyłają te same parametry co dawne linki i idą przez Topic(), więc logi, sprawdzanie dostępu,
// komentarze i wydruki działają bez zmian. Podmenu z temp (stany, grupy krwi, potwierdzenia) są rozbierane
// na tekst i przyciski, jak w konsoli ochrony (security_records_ui.dm).

/obj/machinery/computer/med_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(isliving(user))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		ui = new(user, src, "MedicalRecordsConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/med_data/ui_static_data(mob/user)
	var/list/data = list()
	var/static/list/viruses
	if(!viruses)
		viruses = list()
		for(var/datum/disease/disease_type as anything in subtypesof(/datum/disease))
			if(ispath(disease_type, /datum/disease/advance) || !initial(disease_type.desc))
				continue
			viruses += list(list(
				"name" = initial(disease_type.name),
				"stages" = initial(disease_type.max_stages),
				"spread" = initial(disease_type.spread_text),
				"cure" = initial(disease_type.cure_text),
				"desc" = initial(disease_type.desc),
				"danger" = initial(disease_type.danger),
				"agent" = initial(disease_type.agent),
			))
	data["viruses"] = viruses
	return data

/obj/machinery/computer/med_data/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated
	data["rank"] = rank
	data["screen"] = screen
	data["printing"] = !!printing
	data["temp"] = temp ? aquila_split_topic_links(temp) : null
	if(!authenticated || !can_view_medical_records(user))
		return data
	switch(screen)
		if(1, 2)
			var/list/medical_by_id = list()
			for(var/datum/data/record/medical_record in GLOB.data_core.medical)
				medical_by_id["[medical_record.fields["name"]]|[medical_record.fields["id"]]"] = medical_record
			var/list/records = list()
			for(var/datum/data/record/record in GLOB.data_core.general)
				var/datum/data/record/medical_record = medical_by_id["[record.fields["name"]]|[record.fields["id"]]"]
				records += list(list(
					"name" = record.fields["name"],
					"id" = record.fields["id"],
					"rank" = record.fields["rank"],
					"fingerprint" = record.fields["fingerprint"],
					"dna" = medical_record?.fields["b_dna"] || "",
					"blood_type" = medical_record?.fields["blood_type"] || "",
					"physical" = record.fields["p_stat"],
					"mental" = record.fields["m_stat"],
				))
			data["records"] = records
		if(4)
			data["general"] = medical_general_data()
			data["medical"] = medical_record_data()
		if(6)
			var/list/medbots = list()
			for(var/mob/living/simple_animal/bot/medbot/medbot in GLOB.alive_mob_list)
				if(medbot.get_virtual_z_level() != get_virtual_z_level())
					continue
				var/turf/medbot_turf = get_turf(medbot)
				if(!medbot_turf)
					continue
				var/area/medbot_area = get_area(medbot)
				medbots += list(list(
					"name" = medbot.name,
					"x" = medbot_turf.x,
					"y" = medbot_turf.y,
					"area" = medbot_area?.name,
					"on" = !!medbot.on,
				))
			data["medbots"] = medbots
	return data

/// Same reach as Topic(): in hand, next to the console, a silicon or an admin ghost
/obj/machinery/computer/med_data/proc/can_view_medical_records(mob/user)
	return user.contents.Find(src) || (in_range(src, user) && isturf(loc)) || issilicon(user) || IsAdminGhost(user)

/obj/machinery/computer/med_data/proc/medical_general_data()
	if(!istype(active1, /datum/data/record) || !GLOB.data_core.general.Find(active1))
		return null
	return list(
		"name" = active1.fields["name"],
		"id" = active1.fields["id"],
		"rank" = active1.fields["rank"],
		"gender" = active1.fields["gender"],
		"sex" = active1.fields["sex"],
		"age" = active1.fields["age"],
		"species" = active1.fields["species"],
		"fingerprint" = active1.fields["fingerprint"],
		"physical" = active1.fields["p_stat"],
		"mental" = active1.fields["m_stat"],
		"cause_of_death" = active1.fields["cause_of_death"],
		"photo_front" = medical_photo_data(active1.fields["photo_front"]),
		"photo_side" = medical_photo_data(active1.fields["photo_side"]),
	)

/// Zdjęcie z rekordu jako base64 (raz na zdjęcie, bo okno odświeża się co chwilę)
/obj/machinery/computer/med_data/proc/medical_photo_data(obj/item/photo/photo)
	if(!istype(photo) || !photo.picture?.picture_image)
		return null
	var/static/list/photo_cache = list()
	var/key = REF(photo)
	if(!photo_cache[key])
		photo_cache[key] = icon2base64(photo.picture.picture_image)
	return photo_cache[key]

/obj/machinery/computer/med_data/proc/medical_record_data()
	if(!istype(active2, /datum/data/record) || !GLOB.data_core.medical.Find(active2))
		return null
	var/list/comments = list()
	var/counter = 1
	while(active2.fields["com_[counter]"])
		comments += list(list("index" = counter, "text" = active2.fields["com_[counter]"], "deleted" = active2.fields["com_[counter]"] == "<B>Deleted</B>"))
		counter++
	return list(
		"blood_type" = active2.fields["blood_type"],
		"dna" = active2.fields["b_dna"],
		"mi_dis" = active2.fields["mi_dis"],
		"mi_dis_d" = active2.fields["mi_dis_d"],
		"ma_dis" = active2.fields["ma_dis"],
		"ma_dis_d" = active2.fields["ma_dis_d"],
		"alg" = active2.fields["alg"],
		"alg_d" = active2.fields["alg_d"],
		"cdi" = active2.fields["cdi"],
		"cdi_d" = active2.fields["cdi_d"],
		"notes" = active2.fields["notes"],
		"comments" = comments,
	)

/obj/machinery/computer/med_data/ui_act(action, list/params)
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
	if(!length(href_list))
		return
	Topic(null, href_list)
	return TRUE
