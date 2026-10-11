/obj/machinery/modular_fabricator/exosuit_fab
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "An advanced machine containing many internal robotic arms which fabricate components for robots and exosuits."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab

	output_direction = SOUTH

	remote_materials = TRUE
	can_sync = TRUE
	can_print_category = TRUE

	categories = list(
		"Cyborg",
		"Ripley",
		"Firefighter",
		"Odysseus",
		"Gygax",
		"Durand",
		"H.O.N.K",
		"Phazon",
		"Exosuit Equipment",
		"Cyborg Upgrade Modules",
		"IPC Components",
		"Cybernetics",
		"Implants",
		"Control Interfaces",
		"Misc"
	)

	stored_research_type = /datum/techweb/specialized/autounlocking/exofab

/obj/machinery/modular_fabricator/exosuit_fab/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", I)

/obj/machinery/modular_fabricator/exosuit_fab/crowbar_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/modular_fabricator/exosuit_fab/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	. = ..()
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), "fab-load-[M.name]"), 10)

/obj/machinery/modular_fabricator/exosuit_fab/set_default_sprite()
	cut_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/set_working_sprite()
	add_overlay("fab-active")

/obj/machinery/modular_fabricator/exosuit_fab/maint
	auto_link = FALSE

// AQ EDIT START - port BeeStation #14723: the ExosuitFabricator window from Bee
/obj/machinery/modular_fabricator/exosuit_fab/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExosuitFabricator")
		ui.set_autoupdate(TRUE)
		ui.open()
		viewing_mobs += user

/obj/machinery/modular_fabricator/exosuit_fab/ui_static_data(mob/user)
	var/list/data = list()
	data["designs"] = fabricator_ui_designs(printable_designs(), coefficient_override = CALLBACK(src, PROC_REF(design_cost_coefficient)))
	data["can_sync"] = can_sync
	return data

/obj/machinery/modular_fabricator/exosuit_fab/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = fabricator_ui_materials(get_material_container())
	data["processing"] = operating && !queue_stopped
	data["queue"] = list()
	if(being_built)
		data["queue"] += list(list(
			"jobId" = "building-[being_built.id]",
			"designId" = being_built.id,
			"processing" = TRUE,
			"timeLeft" = max(process_completion_world_tick - world.time, 0),
		))
	var/queue_index = 0
	for(var/design_id in item_queue)
		for(var/copy in 1 to max(item_queue[design_id]["amount"], 1))
			queue_index++
			data["queue"] += list(list(
				"jobId" = "queued-[queue_index]-[design_id]",
				"designId" = design_id,
				"processing" = FALSE,
				"timeLeft" = 0,
			))
	return data
// AQ EDIT END
