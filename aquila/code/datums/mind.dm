/datum/mind/proc/vampire_href(href, mob/M)
	switch(href)
		if("clear")
			remove_vampire(current)
			message_admins("[key_name_admin(usr)] has de-vampired [current].")
			log_admin("[key_name(usr)] has de-vampired [current].")
		if("vampire")
			if(!is_vampire(current))
				message_admins("[key_name_admin(usr)] has vampired [current].")
				log_admin("[key_name(usr)] has vampired [current].")
				add_vampire(current)
			else
				to_chat(usr, "<span class='warning'>[current] is already a vampire!</span>")
		if("full")
			message_admins("[key_name_admin(usr)] has full-vampired [current].")
			log_admin("[key_name(usr)] has full-vampired [current].")
			if(!is_vampire(current))
				add_vampire(current)
				var/datum/antagonist/vampire/V = has_antag_datum(/datum/antagonist/vampire)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()
			else
				var/datum/antagonist/vampire/V = has_antag_datum(/datum/antagonist/vampire)
				if(V)
					V.total_blood = 1500
					V.usable_blood = 1500
					V.check_vampire_upgrade()
/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	S.on_gain(current)
	.=..()

/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			spell_list -= S
			S.on_lose(current)
			qdel(S)
	.=..()

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		S.action.Grant(new_character)
		S.on_gain(new_character)
