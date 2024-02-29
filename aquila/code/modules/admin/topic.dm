/datum/admins/Topic(href, href_list)
	if(href_list["makeAntag"])
		if(!check_rights(R_ADMIN))
			return
		if (!SSticker.mode)
			to_chat(usr, span_danger("Not until the round starts!"))
			return
		switch(href_list["makeAntag"])
			if("infiltrator")
				message_admins("[key_name(usr)] is creating an infiltration team...")
				if(makeInfiltratorTeam())
					message_admins("[key_name(usr)] created an infiltration team.")
					log_admin("[key_name(usr)] created an infiltration team.")
				else
					message_admins("[key_name_admin(usr)] tried to create an infiltration team. Unfortunately, there were not enough candidates available.")
					log_admin("[key_name(usr)] failed to create an infiltration team.")
	.=..()
