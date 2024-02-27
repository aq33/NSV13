
/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--
		if(!target.stat_panel.is_ready())
			continue
		if(target.stat_tab == "Status" && num_fires % status_wait == 0)
			set_status_tab(target)
		if(!target.holder)
			target.stat_panel.send_message("remove_admin_tabs")
		else
			target.stat_panel.send_message("update_split_admin_tabs", !!(target.prefs.toggles & SPLIT_ADMIN_TABS))
			if(!("MC" in target.panel_tabs) || !("Tickets" in target.panel_tabs))
				target.stat_panel.send_message("add_admin_tabs", target.holder.href_token)
			if(target.stat_tab == "MC" && ((num_fires % mc_wait == 0) || target?.prefs.read_preference(/datum/preference/toggle/fast_mc_refresh)))
				set_MC_tab(target)
			if(target.stat_tab == "Tickets" && num_fires % default_wait == 0)
				set_tickets_tab(target)
			if(!length(GLOB.sdql2_queries) && ("SDQL2" in target.panel_tabs))
				target.stat_panel.send_message("remove_sdql2")
			else if(length(GLOB.sdql2_queries) && (target.stat_tab == "SDQL2" || !("SDQL2" in target.panel_tabs)) && num_fires % default_wait == 0)
				set_SDQL2_tab(target)

		if(target.mob)
			var/mob/target_mob = target.mob
			if((target.stat_tab in target.spell_tabs) || !length(target.spell_tabs) && (length(target_mob.mob_spell_list) || length(target_mob.mind?.spell_list)))
				if(num_fires % default_wait == 0)
					set_spells_tab(target, target_mob)

			// Handle the action panels of the stat panel

			var/update_actions = FALSE
			// We're on a spell tab, update the tab so we can see cooldowns progressing and such
			if(target.stat_tab in target.spell_tabs)
				update_actions = TRUE
			// We're not on a spell tab per se, but we have cooldown actions, and we've yet to
			// set up our spell tabs at all
			if(!length(target.spell_tabs) && locate(/datum/action/cooldown) in target_mob.actions)
				update_actions = TRUE

			if(update_actions && num_fires % default_wait == 0)
				set_action_tabs(target, target_mob)

			// Handle the examined turf of the stat panel

			if(target_mob?.listed_turf && num_fires % default_wait == 0)
				if(!target_mob.TurfAdjacent(target_mob.listed_turf) || isnull(target_mob.listed_turf))
					target.stat_panel.send_message("remove_listedturf")
					target_mob.listed_turf = null
				else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
					set_turf_examine_tab(target, target_mob)
		if(MC_TICK_CHECK)
			return
	.=..()
