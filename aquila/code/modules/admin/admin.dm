/datum/admins/proc/reloadwhitelist()
	set category = "Server"
	set desc="Reloads the whitelist from file"
	set name="Reload Whitelist"
	load_whitelist()
	log_admin("[key_name(usr)] reloaded whitelist from file.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] reloaded whitelist from file.</span>")
