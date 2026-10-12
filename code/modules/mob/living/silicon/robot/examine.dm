/mob/living/silicon/robot/examine(mob/user)
	. = list("<span class='info'>To [icon2html(src, user)] <EM>[src]</EM>!")
	if(desc)
		. += "[desc]"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "Trzyma [icon2html(act_module, user)] [act_module]."
	. += status_effect_examines()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += "<span class='warning'>Jest lekko wgniecione.</span>"
		else
			. += "<span class='warning'><B>Jest mocno powgniatane!</B></span>"
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += "<span class='warning'>Jest lekko osmalone.</span>"
		else
			. += "<span class='warning'><B>Jest mocno spalony i powyginany od gorąca!</B></span>"
	if (health < -maxHealth*0.5)
		. += "<span class='warning'>Ledwo działa.</span>"
	if (fire_stacks < 0)
		. += "<span class='warning'>Jest pokryty wodą.</span>"
	else if (fire_stacks > 0)
		. += "<span class='warning'>Jest pokryty czymś łatwopalnym.</span>"

	if(opened)
		. += "<span class='warning'>Pokrywa jest otwarta, a ogniwo zasilające [cell ? "jest zainstalowane" : "jest nieobecne"].</span>"
	else
		. += "Pokrywa jest zamknięta[locked ? "" : " i wygląda na odblokowaną"]."

	if(cell && cell.charge <= 0)
		. += "<span class='warning'>Wskaźnik baterii miga na czerwono!</span>"

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "Wygląda na [deployed ? "aktywną" : "pustą"] powłokę SI."
			else if(!client)
				. += "Wygląda na to, że jest w trybie czuwania." //afk
		if(UNCONSCIOUS)
			. += "<span class='warning'>Wygląda na to, że nie reaguje.</span>"
		if(DEAD)
			. += "<span class='deadsay'>Wygląda na to, że jego system jest uszkodzony i wymaga resetu.</span>"
	. += "</span>"

	. += ..()

/mob/living/silicon/robot/get_examine_string(mob/user, thats = FALSE)
	return null
