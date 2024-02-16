/obj/structure/toilet/verb/verb_defecate()
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	set src in view(1)
	set category = "Object"
	set name = "Wysraj się"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr))
		return toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/toilet/proc/shit(/mob/living)
