/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 10

/datum/round_event/bureaucratic_error
	announceWhen = 1

/datum/round_event/bureaucratic_error/announce(fake)
	priority_announce("Dokonana niedawno biurorkatyczna pomyłka w dziale Zarządzania Środkami Ludzkimi i Nieludzkimi może spowodować deficyty personelu w niektórych działach i nadwyżkę w innych.", "Ostrzeżenie administracyjne", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/bureaucratic_error/start()
	// AQ EDIT - only jobs that exist on this map and allow it, GetJob() returns null for the rest
	var/list/jobs = list()
	for(var/job_name in get_all_jobs())
		var/datum/job/job = SSjob.GetJob(job_name)
		if(job?.allow_bureaucratic_error)
			jobs += job_name
	if(length(jobs))
		SSjob.set_overflow_role(pick(jobs))
