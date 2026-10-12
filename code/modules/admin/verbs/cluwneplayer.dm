/mob/living/proc/cluwne()
	for(var/obj/item/W in src)  // they drop everything they have
		if(!dropItemToGround(W))
			qdel(W)
			regenerate_icons()

	var/datum/mind/M = mind

	var/mob/living/simple_animal/cluwne/newmob =  new(get_turf(src))

	if(client)
		client.give_award(/datum/award/achievement/misc/cluwne, client.mob)

	if(mind) // If the mob has a mind, we transfer
		M.transfer_to(newmob)

	if(key)  // afk (no mind)
		newmob.key = key

	var/msg = "\n\n\n\n\nTwój umysł zostaje rozdarty jak nitki w tkaninie, wszystko, co kiedykolwiek znałeś, znika.\n"
	msg += "Teraz jest już tylko <b><i>Honkmatka</i></b>.\n"
	msg += "Honk!\n"
	to_chat(M, msg)

	qdel(src)
