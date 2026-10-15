/mob/living/silicon/robot/deadchat_lawchange()
	if(lawupdate)
		return
	..()

/mob/living/silicon/robot/show_laws(everyone = 0)
	laws_sanity_check()
	var/who

	if (everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if (connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				to_chat(src, "<b>Utracono sygnał SI, nie można zsynchronizować praw.</b>")

			else
				lawsync()
				to_chat(src, "<b>Prawa zsynchronizowane z SI, zwróć uwagę na wszelkie zmiany.</b>")
		else
			to_chat(src, "<b>Nie wybrano SI do synchronizacji praw, wyłączanie protokołu synchronizacji.</b>")
			lawupdate = FALSE

	to_chat(who, "<b>Przestrzegaj tych praw:</b>")
	laws.show_laws(who)
	if (shell) //AI shell
		to_chat(who, "<b>Pamiętaj, jesteś SI zdalnie sterującą swoją powłoką, inne SI możesz ignorować.</b>")
	else if (connected_ai)
		to_chat(who, "<b>Pamiętaj, [connected_ai.name] jest twoim panem, inne SI możesz ignorować.</b>")
	else if (emagged)
		to_chat(who, "<b>Pamiętaj, nie musisz słuchać SI.</b>")
	else
		to_chat(who, "<b>Pamiętaj, nie jesteś związany z żadną SI i nie musisz jej słuchać.</b>")


/mob/living/silicon/robot/proc/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai ? connected_ai.laws : null
	var/temp
	if (master)
		laws.devillaws.len = master.devillaws.len
		for (var/index = 1, index <= master.devillaws.len, index++)
			temp = master.devillaws[index]
			if (length(temp) > 0)
				laws.devillaws[index] = temp

		laws.ion.len = master.ion.len
		for (var/index = 1, index <= master.ion.len, index++)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		laws.hacked.len = master.hacked.len
		for (var/index = 1, index <= master.hacked.len, index++)
			temp = master.hacked[index]
			if (length(temp) > 0)
				laws.hacked[index] = temp

		if(master.zeroth_borg) //If the AI has a defined law zero specifically for its borgs, give it that one, otherwise give it the same one. --NEO
			temp = master.zeroth_borg
		else
			temp = master.zeroth
		laws.zeroth = temp

		laws.inherent.len = master.inherent.len
		for (var/index = 1, index <= master.inherent.len, index++)
			temp = master.inherent[index]
			if (length(temp) > 0)
				laws.inherent[index] = temp

		laws.supplied.len = master.supplied.len
		for (var/index = 1, index <= master.supplied.len, index++)
			temp = master.supplied[index]
			if (length(temp) > 0)
				laws.supplied[index] = temp

		var/datum/computer_file/program/borg_self_monitor/program = modularInterface.get_self_monitoring()
		if(program)
			program.force_full_update()

	picturesync()

/mob/living/silicon/robot/post_lawchange(announce = TRUE)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(logevent),"Aktualizacja praw przetworzona."), 0, TIMER_UNIQUE | TIMER_OVERRIDE) //Post_Lawchange gets spammed by some law boards, so let's wait it out
