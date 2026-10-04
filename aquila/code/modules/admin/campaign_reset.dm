/// AQUILA - "Hard Restart + New Campaign": put the clean default starmap in place of the persistent one, then hard restart.
/// Only files under config/starmap/ are touched. The database is left alone; it disconnects through the normal reboot path.

#define CAMPAIGN_DEFAULT_STARMAP "config/starmap/starmap_default.json"

/datum/controller/subsystem/star_system
	/// AQUILA - TRUE once the starmap file was reset for a new campaign; stops Shutdown() saving the old campaign over it
	var/campaign_reset_pending = FALSE

/datum/controller/subsystem/star_system/save(_destination_path = SSmapping.config.starmap_path)
	if(campaign_reset_pending)
		log_game("Starmap save to [_destination_path] skipped: the campaign was reset for the next round.")
		return 1
	return ..()

/// Returns the active starmap path if it is a JSON file under config/starmap/, or null
/proc/campaign_starmap_path(path = SSmapping.config.starmap_path)
	if(!path)
		return
	path = sanitize_filepath(path)
	var/list/nodes = splittext(path, "/")
	if(length(nodes) < 3 || nodes[1] != "config" || nodes[2] != "starmap" || !findtext(nodes[nodes.len], ".json"))
		return
	return path

/**
 * Replaces the starmap at `path` with `default_path`.
 * Returns list("success" = TRUE/FALSE, "error" = reason).
 * On any failure the original file is put back as it was.
 */
/proc/reset_campaign_starmap(path, default_path = CAMPAIGN_DEFAULT_STARMAP)
	. = list("success" = FALSE, "error" = null)
	path = campaign_starmap_path(path)
	if(!path)
		.["error"] = "the starmap path isn't a JSON file under config/starmap/"
		return
	if(path == default_path)
		.["error"] = "the active starmap is the default starmap itself, there is no clean copy to restore"
		return
	if(!fexists(default_path))
		.["error"] = "the default starmap [default_path] is missing"
		return
	var/clean = rustg_file_read(default_path)
	if(!length(clean))
		.["error"] = "the default starmap [default_path] is empty"
		return

	var/original = fexists(path) ? rustg_file_read(path) : null
	if(!fcopy(default_path, path) || rustg_file_read(path) != clean)
		fdel(path)
		if(!isnull(original))
			rustg_file_write(original, path) // put the old campaign back
		.["error"] = "couldn't write the default starmap to [path]"
		return
	.["success"] = TRUE

/// Admin side: double confirmation, reset, logging, then the same hard restart as "Hard Restart"
/datum/admins/proc/hard_restart_new_campaign(init_by)
	if(!check_rights(R_SERVER))
		return
	var/path = SSmapping.config.starmap_path
	if(alert(usr, "This hard restarts the server and RESETS the persistent starmap campaign ([path]) to the default map. No backup is kept, this cannot be undone. Continue?", "New Campaign", "Reset campaign", "Cancel") != "Reset campaign")
		return
	if(alert(usr, "Are you absolutely sure? Every system, owner and campaign change on the starmap goes back to the start.", "New Campaign - final warning", "Yes, reset and restart", "Cancel") != "Yes, reset and restart")
		return

	var/list/result = reset_campaign_starmap(path)
	if(!result["success"])
		log_admin("[key_name(usr)] tried Hard Restart + New Campaign; the starmap reset FAILED ([result["error"]]). Starmap: [path]. Restart aborted, campaign kept.")
		message_admins("[key_name_admin(usr)] tried Hard Restart + New Campaign; the starmap reset FAILED ([result["error"]]). Restart aborted, campaign kept.")
		to_chat(usr, "<span class='warning'>Campaign reset failed: [result["error"]]. The server was not restarted and the campaign is unchanged.</span>")
		return
	SSstar_system.campaign_reset_pending = TRUE
	log_admin("[key_name(usr)] used Hard Restart + New Campaign. Starmap [path] reset to [CAMPAIGN_DEFAULT_STARMAP]. Restarting.")
	message_admins("[key_name_admin(usr)] used Hard Restart + New Campaign. Starmap [path] reset. Restarting.")
	to_chat(world, "World reboot - new campaign - [init_by]")
	world.Reboot()

#undef CAMPAIGN_DEFAULT_STARMAP
