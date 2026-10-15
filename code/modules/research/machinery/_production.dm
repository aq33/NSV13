#define MAX_SENT 10

/obj/machinery/rnd/production
	name = "technology fabricator"
	desc = "Makes researched and prototype items with materials and energy."
	layer = BELOW_OBJ_LAYER
	var/consoleless_interface = FALSE			//Whether it can be used without a console.
	var/efficiency_coeff = 1				//Materials needed / coeff = actual.
	var/list/categories = list()
	var/datum/component/remote_materials/materials
	var/allowed_department_flags = ALL
	var/production_animation				//What's flick()'d on print.
	var/allowed_buildtypes = NONE
	var/list/datum/design/cached_designs
	var/list/datum/design/matching_designs
	var/department_tag = "Unidentified"			//used for material distribution among other things.
	var/datum/techweb/stored_research
	var/datum/techweb/host_research

	var/search = null
	var/selected_category = null

	var/list/mob/viewing_mobs = list()

	/// Only used for storing pending research for examine()
	var/list/pending_research = list()
	var/base_storage = 75000

/obj/machinery/rnd/production/Initialize(mapload)
	. = ..()
	create_reagents(0, OPENCONTAINER)
	matching_designs = list()
	cached_designs = list()
	stored_research = new
	host_research = SSresearch.science_tech
	update_research()
	materials = AddComponent(/datum/component/remote_materials, "lathe", mapload)
	RefreshParts()
	RegisterSignal(src, COMSIG_MATERIAL_CONTAINER_CHANGED, PROC_REF(on_materials_changed))
	RegisterSignal(src, COMSIG_REMOTE_MATERIALS_CHANGED, PROC_REF(on_materials_changed))
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_RESEARCH, PROC_REF(alert_research))

/obj/machinery/rnd/production/Destroy()
	materials = null
	cached_designs = null
	matching_designs = null
	QDEL_NULL(stored_research)
	host_research = null
	return ..()

/obj/machinery/rnd/production/examine(mob/user)
	. = ..()
	var/num_research = length(pending_research)
	if(num_research)
		. += "\nOCZEKUJĄCE BADANIA:"
		var/list/displayed = reverseList(pending_research)  // newest first
		if(num_research >= MAX_SENT)
			displayed.Cut(MAX_SENT)
			displayed += "..."
		. += displayed.Join("\n")

/obj/machinery/rnd/production/update_icon()
	. = ..()
	cut_overlays()
	if(length(pending_research))
		add_overlay("lathe-research")

/obj/machinery/rnd/production/proc/on_materials_changed()
	SIGNAL_HANDLER
	ui_update()

/obj/machinery/rnd/production/on_reagent_change(changetype)
	. = ..()
	ui_update()

/obj/machinery/rnd/production/proc/update_research()
	host_research.copy_research_to(stored_research, TRUE)
	update_designs()

/obj/machinery/rnd/production/proc/alert_research(datum/source, var/node_id)
	SIGNAL_HANDLER

	var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)

	for(var/i in node.design_ids)
		var/datum/design/d = SSresearch.techweb_design_by_id(i)
		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			pending_research += d.name
	update_icon()

/obj/machinery/rnd/production/proc/update_designs()
	pending_research.Cut()
	cached_designs.Cut()
	for(var/i in stored_research.researched_designs)
		var/datum/design/d = SSresearch.techweb_design_by_id(i)
		if((isnull(allowed_department_flags) || (d.departmental_flags & allowed_department_flags)) && (d.build_type & allowed_buildtypes))
			cached_designs |= d
	update_viewer_statics()
	update_icon()

/obj/machinery/rnd/production/RefreshParts()
	calculate_efficiency()
	ui_update()

/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fabricator") // AQ EDIT - port BeeStation #14723
		ui.open()
		viewing_mobs += user

/obj/machinery/rnd/production/ui_close(mob/user)
	. = ..()
	viewing_mobs -= user

/obj/machinery/rnd/production/proc/update_viewer_statics()
	for(var/mob/M as() in viewing_mobs)
		if(QDELETED(M) || !(M.client || M.mind))
			continue
		update_static_data(M)

// AQ EDIT START - port BeeStation #14723: data for the Fabricator window from Bee
/obj/machinery/rnd/production/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = fabricator_ui_materials(materials?.mat_container)
	data["onHold"] = materials?.on_hold()
	data["busy"] = busy
	var/list/loaded_reagents = list()
	for(var/datum/reagent/reagent as anything in reagents?.reagent_list)
		loaded_reagents += list(list(
			"name" = reagent.name,
			"volume" = reagent.volume,
			"id" = "[reagent.type]",
		))
	data["reagents"] = loaded_reagents
	data["reagentCapacity"] = reagents?.maximum_volume
	return data

/// The real material cost multiplier for a design, see user_try_print_id()
/obj/machinery/rnd/production/proc/design_cost_coefficient(datum/design/design)
	return efficient_with(design.build_path) ? 1 / efficiency_coeff : 1
// AQ EDIT END

/obj/machinery/rnd/production/proc/build_materials()
	if(!materials || !materials.mat_container)
		return null

	var/list/L = list()
	for(var/datum/material/material as() in materials.mat_container.materials)
		L[material.id] = list(
				name = material.name,
				amount = materials.mat_container.materials[material]/MINERAL_MATERIAL_AMOUNT,
				id = material.id,
			)

	return list(
		materials = L,
		materials_label = materials.format_amount()
	)

/obj/machinery/rnd/production/proc/build_reagents()
	if(!reagents)
		return null

	var/list/L = list()
	for(var/datum/reagent/reagent as() in reagents.reagent_list)
		L["[reagent.type]"] = list(
				name = reagent.name,
				volume = reagent.volume,
				id = "[reagent.type]",
			)

	return list(
		reagents = L,
		reagents_label = "[reagents.total_volume] / [reagents.maximum_volume]"
	)

/obj/machinery/rnd/production/ui_static_data(mob/user)
	// AQ EDIT - port BeeStation #14723
	var/list/data = list()
	data["designs"] = fabricator_ui_designs(cached_designs, coefficient_override = CALLBACK(src, PROC_REF(design_cost_coefficient)))
	data["fabName"] = name
	return data

/obj/machinery/rnd/production/proc/build_recipes()
	var/list/L = list()
	for(var/datum/design/design as() in cached_designs)
		L += list(build_design(design))
	return L

/obj/machinery/rnd/production/proc/build_design(var/datum/design/design)
	return list(
			name = design.name,
			description = design.desc,
			id = design.id,
			category = design.category,
			max_amount = design.maxstack,
			efficiency_affects = efficient_with(design.build_path),
			materials = design.materials,
			reagents = build_recipe_reagents(design.reagents_list),
		)

/obj/machinery/rnd/production/proc/build_recipe_reagents(var/list/reagents)
	var/list/L = list()

	for(var/id in reagents)
		L[id] = list(
			name = CallMaterialName(id),
			volume = reagents[id],
		)

	return L

/obj/machinery/rnd/production/ui_act(action, params)
	if(..())
		return
	if(action == "build")
		if(busy)
			say("Ostrzeżenie: fabrykatory zajęte!")
		else
			user_try_print_id(params["ref"] || params["design_id"], params["amount"]) // AQ EDIT - the Bee window sends "ref"
			. = TRUE
	// AQ EDIT START - port BeeStation #14723
	if(action == "remove_mat" && materials?.mat_container)
		for(var/datum/material/potential_material as anything in materials.mat_container.materials)
			if(REF(potential_material) == params["ref"])
				eject_sheets(potential_material, params["amount"])
				. = TRUE
				break
	// AQ EDIT END
	if(action == "sync_research" || action == "sync_rnd") // AQ EDIT
		update_research()
		say("Baza danych programu naukowego została zaktualizowana.")
		. = TRUE
	if(action == "dispose")
		var/R = text2path(params["reagent_id"])
		if(R)
			reagents.del_reagent(R)
			. = TRUE
	if(action == "disposeall")
		reagents.clear_reagents()
		. = TRUE
	if(action == "ejectsheet" && materials && materials.mat_container)
		var/datum/material/M
		for(var/datum/material/potential_material as() in materials.mat_container.materials)
			if(potential_material.id == params["material_id"])
				M = potential_material
				break
		if(M)
			eject_sheets(M, params["amount"])
			. = TRUE
	if(action == "search")
		var/new_search = params["value"]
		if(new_search != search)
			search = new_search
			. = TRUE
	if(action == "category")
		var/new_category = params["category"]
		if(new_category != selected_category)
			search = null
			selected_category = new_category
			. = TRUE
	if(action == "mainmenu" && (search != null || selected_category != null))
		search = null
		selected_category = null
		. = TRUE

/obj/machinery/rnd/production/proc/calculate_efficiency()
	efficiency_coeff = 1
	if(reagents)		//If reagents/materials aren't initialized, don't bother, we'll be doing this again after reagents init anyways.
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/glass/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/M in component_parts)
			total_storage += M.rating * base_storage
		materials.set_local_size(total_storage)
	var/total_rating = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating = CLAMP(total_rating - (M.rating * 0.1), 0, 1)
	if(total_rating == 0)
		efficiency_coeff = INFINITY
	else
		efficiency_coeff = 1/total_rating

//we eject the materials upon deconstruction.
/obj/machinery/rnd/production/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	return ..()

/obj/machinery/rnd/production/proc/do_print(path, amount, list/matlist, notify_admins)
	if(notify_admins)
		investigate_log("[key_name(usr)] built [amount] of [path] at [src]([type]).", INVESTIGATE_RESEARCH)
		message_admins("[ADMIN_LOOKUPFLW(usr)] has built [amount] of [path] at \a [src]([type]).")
	for(var/i in 1 to amount)
		var/obj/item/I = new path(get_turf(src))
		if(efficient_with(I.type))
			I.materials = matlist.Copy()
	SSblackbox.record_feedback("nested tally", "item_printed", amount, list("[type]", "[path]"))

/obj/machinery/rnd/production/proc/check_mat(datum/design/being_built, var/mat)	// now returns how many times the item can be built with the material
	if (!materials.mat_container)  // no connected silo
		return 0
	var/list/all_materials = being_built.reagents_list + being_built.materials

	var/A = materials.mat_container.get_material_amount(mat)
	if(!A)
		A = reagents.get_reagent_amount(mat)

	// these types don't have their .materials set in do_print, so don't allow
	// them to be constructed efficiently
	var/ef = efficient_with(being_built.build_path) ? efficiency_coeff : 1
	return round(A / max(1, all_materials[mat] / ef))

/obj/machinery/rnd/production/proc/efficient_with(path)
	return !ispath(path, /obj/item/stack/sheet) && !ispath(path, /obj/item/stack/ore/bluespace_crystal)

/obj/machinery/rnd/production/proc/user_try_print_id(id, amount)
	if((!istype(linked_console) && requires_console) || !id)
		return FALSE
	if(istext(amount))
		amount = text2num(amount)
	if(isnull(amount))
		amount = 1
	var/datum/design/D = (linked_console || requires_console)? (linked_console.stored_research.researched_designs[id]? SSresearch.techweb_design_by_id(id) : null) : SSresearch.techweb_design_by_id(id)
	if(!istype(D))
		return FALSE
	if(!(isnull(allowed_department_flags) || (D.departmental_flags & allowed_department_flags)))
		say("Ostrzeżenie: drukowanie nieudane: ten fabrykator nie ma kluczy potrzebnych do odszyfrowania schematów projektu. Zaktualizuj dane badań przyciskiem na ekranie i skontaktuj się z pomocą techniczną Nanotrasen!")
		return FALSE
	if(D.build_type && !(D.build_type & allowed_buildtypes))
		say("Ta maszyna nie ma systemów manipulacji potrzebnych do tego projektu. Skontaktuj się z pomocą techniczną Nanotrasen!")
		return FALSE
	if(!materials.mat_container)
		say("Brak połączenia z magazynem materiałów, skontaktuj się z kwatermistrzem.")
		return FALSE
	if(materials.on_hold())
		say("Dostęp do minerałów jest wstrzymany, skontaktuj się z kwatermistrzem.")
		return FALSE
	var/power = 1000
	amount = CLAMP(amount, 1, 50) // AQ EDIT - port BeeStation #14723: the Fabricator window offers x50 (MAX_LATHE_PRINT_AMOUNT)
	for(var/M in D.materials)
		power += round(D.materials[M] * amount / 35)
	power = min(3000, power)
	use_power(power)
	var/coeff = efficient_with(D.build_path) ? efficiency_coeff : 1
	var/list/efficient_mats = list()
	for(var/MAT in D.materials)
		efficient_mats[MAT] = D.materials[MAT]/coeff
	if(!materials.mat_container.has_materials(efficient_mats, amount))
		say("Za mało materiałów, by ukończyć [amount > 1? "prototypy" : "prototyp"].")
		return FALSE
	for(var/R in D.reagents_list)
		if(!reagents.has_reagent(R, D.reagents_list[R]*amount))
			say("Za mało odczynników, by ukończyć [amount > 1? "prototypy" : "prototyp"].")
			return FALSE
	materials.mat_container.use_materials(efficient_mats, amount)
	materials.silo_log(src, "built", -amount, "[D.name]", efficient_mats)
	for(var/R in D.reagents_list)
		reagents.remove_reagent(R, D.reagents_list[R]*amount)
	busy = TRUE
	soundloop.start() // AQ EDIT
	if(production_animation)
		flick(production_animation, src)
	var/timecoeff = D.lathe_time_factor / efficiency_coeff
	addtimer(CALLBACK(src, PROC_REF(reset_busy)), (30 * timecoeff * amount) ** 0.5)
	addtimer(CALLBACK(src, PROC_REF(do_print), D.build_path, amount, efficient_mats, D.dangerous_construction), (32 * timecoeff * amount) ** 0.8)
	addtimer(CALLBACK(soundloop, TYPE_PROC_REF(/datum/looping_sound,stop)), (32 * timecoeff * amount) ** 0.8) // AQ EDIT
	return TRUE

/obj/machinery/rnd/production/proc/eject_sheets(eject_sheet, eject_amt)
	var/datum/component/material_container/mat_container = materials.mat_container
	if (!mat_container)
		say("Brak dostępu do magazynu materiałów, skontaktuj się z kwatermistrzem.")
		return 0
	if (materials.on_hold())
		say("Dostęp do minerałów jest wstrzymany, skontaktuj się z kwatermistrzem.")
		return 0
	var/count = mat_container.retrieve_sheets(text2num(eject_amt), eject_sheet, drop_location())
	var/list/matlist = list()
	matlist[eject_sheet] = MINERAL_MATERIAL_AMOUNT
	materials.silo_log(src, "ejected", -count, "sheets", matlist)
	return count

/obj/machinery/rnd/production/reset_busy()
	. = ..()
	SStgui.update_uis(src)

#undef MAX_SENT
