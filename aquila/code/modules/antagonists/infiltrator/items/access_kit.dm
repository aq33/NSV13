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
		to_chat(user, span_warning("You have no idea how to use [src]..."))
		return
	if(job)
		to_chat(user, span_warning("[src] has already been set up! Apply it to an ID card to use it."))
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
	to_chat(user, span_notice("You set up [src] to spoof and grant access to [job.title]."))

/obj/item/access_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(syndicate && !is_syndicate(user))
		return
	if(!istype(target, /obj/item/card/id))
		return
	if(!job)
		to_chat(user, span_warning("[src] has not been set to a specific job yet! Use it in-hand to set up the access kit."))
		return
	var/obj/item/card/id/id = target
	id.assignment = job.title
	id.access |= job.minimal_access
	id.update_label()
	to_chat(user, span_notice("You apply [src] to [id], granting it the access of a [job.title]!"))
	if(is_infiltrator(user))
		to_chat(user, span_boldnotice("Make sure to properly update your chameleon clothes to reflect that of a [job.title]!"))
	do_sparks(5, FALSE, user)
	qdel(src)

/obj/item/access_kit/syndicate
	syndicate = TRUE
