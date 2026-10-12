/obj/item/access_kit
	name = "access kit (unset)"
	desc = "A one-use device that can be used to spoof and grant the access associated with a low-level job."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	/// If TRUE, only syndicate agents know how to use it
	var/syndicate = FALSE
	var/datum/job/job
	var/list/available_jobs = list(/datum/job/botanist, /datum/job/janitor, /datum/job/cargo_technician, /datum/job/scientist, /datum/job/medical_doctor, /datum/job/station_engineer)

/obj/item/access_kit/attack_self(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(syndicate && !is_syndicate(user))
		to_chat(user, span_warning("Nie masz pojęcia, jak użyć [src]..."))
		return
	if(job)
		to_chat(user, span_warning("[src] jest już skonfigurowany! Przyłóż go do karty identyfikacyjnej, żeby go użyć."))
		return
	var/list/radial_menu = list()
	var/list/jobs_by_title = list()
	for(var/job_type in available_jobs)
		var/datum/job/J = SSjob.GetJobType(job_type)
		if(!J)
			continue
		jobs_by_title[J.title] = J
		radial_menu[J.title] = get_flat_human_icon("accesskit_[J.type]", J, showDirs = list(SOUTH))
	var/result = show_radial_menu(user, src, radial_menu, require_near = TRUE)
	if(!result || job || QDELETED(src) || !user.is_holding(src))
		return
	job = jobs_by_title[result]
	name = "access kit ([job.title])"
	to_chat(user, span_notice("Ustawiasz [src], by podrabiał i nadawał dostęp stanowiska: [job.title]."))

/obj/item/access_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(syndicate && !is_syndicate(user))
		return
	if(!istype(target, /obj/item/card/id))
		return
	if(!job)
		to_chat(user, span_warning("[src] nie jest jeszcze ustawiony na konkretne stanowisko! Użyj go w dłoni, żeby skonfigurować zestaw."))
		return
	var/obj/item/card/id/id = target
	id.assignment = job.title
	id.access |= job.minimal_access
	id.update_label()
	to_chat(user, span_notice("Przykładasz [src] do [id], nadając jej dostęp stanowiska: [job.title]!"))
	if(is_infiltrator(user))
		to_chat(user, span_boldnotice("Pamiętaj, żeby zmienić ubranie kameleona tak, by pasowało do stanowiska: [job.title]!"))
	do_sparks(5, FALSE, user)
	qdel(src)

/obj/item/access_kit/syndicate
	syndicate = TRUE
