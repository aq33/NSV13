/obj/structure/toilet/verb/verb_defecate()
	set src in view(1)
	set category = "Object"
	set name = "Wysraj się"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(!CONFIG_GET(flag/shitting_enabled))
		to_chat(usr, "<span class='warning'>Sranie zostało wyłączone w konfiguracji serwera.</span>")
		return

	if(isliving(usr))
		if(do_after(usr, 3 SECONDS, target = src))
			shit(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/toilet/proc/shit(mob/living/user)
	if(user.defecation > DEFECATION_VERY)
		//user.adjust_defecation(-rand(DEFECATION_SLIGHTLY, DEFECATION_VERY))
		user.set_defecation(DEFECATION_NONE)
		playsound(src, 'aquila/sound/misc/toilet_flush.ogg', vary = FALSE)
		to_chat(user, "<span class='notice'><i>Ale ulga...</i></span>")
	else
		to_chat(user, "<span class='notice'>Nie chce Ci się srać.</span>")
