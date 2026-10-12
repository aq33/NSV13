/mob/living/silicon/ai/examine(mob/user)
	. = list("<span class='info'>To [icon2html(src, user)] <EM>[src]</EM>!")
	if (stat == DEAD)
		. += "<span class='deadsay'>Wygląda na wyłączone.</span>"
	else
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				. += "<span class='warning'>Jest lekko wgniecione.</span>"
			else
				. += "<span class='warning'><B>Jest mocno powgniatane!</B></span>"
		if (getFireLoss())
			if (getFireLoss() < 30)
				. += "<span class='warning'>Jest lekko osmalone.</span>"
			else
				. += "<span class='warning'><B>Obudowa jest stopiona i powyginana od gorąca!</B></span>"
		if(deployed_shell)
			. += "Lampka sieci bezprzewodowej miga.\n"
		else if (!shunted && !client)
			. += "[src]Core.exe przestał odpowiadać! NTOS szuka rozwiązania problemu...\n"
	. += "</span>"

	. += ..()

/mob/living/silicon/ai/get_examine_string(mob/user, thats = FALSE)
	return null
