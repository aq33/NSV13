GLOBAL_LIST_INIT(infiltrator_objective_areas, typecacheof(list(/area/syndicate_mothership/infiltrator_base, /area/syndicate_mothership, /area/shuttle/stealthcruiser)))

/datum/objective/give_special_equipment(special_equipment)
	if(istype(team, /datum/team/infiltrator))
		for(var/eq_path in special_equipment)
			if(eq_path)
				for(var/turf/T in GLOB.infiltrator_objective_items)
					if(!(eq_path in T.contents))
						new eq_path(T)
		return
	.=..()

/datum/objective/steal/check_completion()
	.=..()
	if (istype(team, /datum/team/infiltrator))
		for (var/area/A in world)
			if (is_type_in_typecache(A, GLOB.infiltrator_objective_areas))
				for (var/obj/item/I in A.GetAllContents()) //Check for items
					if (istype(I, steal_target))
						if (!targetinfo)
							return TRUE
						else if (targetinfo.check_special_completion(I))
							return TRUE
					if (targetinfo && (I.type in targetinfo.altitems))
						if (targetinfo.check_special_completion(I))
							return TRUE
					CHECK_TICK
			CHECK_TICK
		CHECK_TICK

/datum/objective/download/check_completion()
	var/datum/techweb/checking = new
	if (istype(team, /datum/team/infiltrator))
		for (var/area/A in world)
			if (is_type_in_typecache(A, GLOB.infiltrator_objective_areas))
				for (var/obj/item/disk/tech_disk/TD in A.GetAllContents()) //Check for items
					TD.stored_research.copy_research_to(checking)
				CHECK_TICK
			CHECK_TICK
		CHECK_TICK
	.=..()
