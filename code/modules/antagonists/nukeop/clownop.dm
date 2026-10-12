
/datum/antagonist/nukeop/clownop
	name = "Klaun-operator"
	roundend_category = "klauni-operatorzy"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop

/datum/antagonist/nukeop/leader/clownop
	name = "Przywódca klaunów-operatorów"
	roundend_category = "klauni-operatorzy"
	antagpanel_category = "ClownOp"
	nukeop_outfit = /datum/outfit/syndicate/clownop/leader

/datum/antagonist/nukeop/leader/clownop/give_alias()
	title = pick("Naczelny Trąbiciel", "Mistrz Poślizgu", "Król Klaunów", "Honkonośca")
	if(nuke_team?.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/clownop/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = "Clown Operative"
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has clown op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has clown op'ed [key_name(new_owner)].")
