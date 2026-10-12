/datum/orbital_objective/nuclear_bomb
	name = "Nuclear Decomission"
	var/generated = FALSE
	//The blackbox required to recover.
	var/obj/machinery/nuclearbomb/decomission/nuclear_bomb
	var/obj/item/disk/nuclear/decommission/nuclear_disk
	min_payout = 6000
	max_payout = 25000

/datum/orbital_objective/nuclear_bomb/generate_objective_stuff(turf/chosen_turf)
	generated = TRUE
	nuclear_disk = new(chosen_turf)
	nuclear_bomb.target_z = chosen_turf.z
	nuclear_bomb.linked_objective = src

/datum/orbital_objective/nuclear_bomb/get_text()
	. = "Posterunek [station_name] wymaga natychmiastowej likwidacji, by zapobiec wyciekowi informacji do kosmicznej prasy. Odzyskajcie z posterunku dysk uwierzytelniania jądrowego i zdetonujcie go za pomocą dostarczonej bomby atomowej, która zostanie dostarczona na mostek."
	if(linked_beacon)
		. += " Stacja znajduje się przy nadajniku oznaczonym [linked_beacon.name]. Powodzenia."

/datum/orbital_objective/nuclear_bomb/on_assign(obj/machinery/computer/objective/objective_computer)
	var/area/A = GLOB.areas_by_type[/area/bridge]
	var/turf/open/T = locate() in shuffle(A.contents)
	nuclear_bomb = new /obj/machinery/nuclearbomb/decomission(T)

/datum/orbital_objective/nuclear_bomb/check_failed()
	if((!QDELETED(nuclear_bomb) && !QDELETED(nuclear_disk) && !QDELETED(linked_beacon)) || !generated)
		return FALSE
	return TRUE

//==============
//The disk
//==============

/obj/item/disk/nuclear/decommission
	name = "outdated nuclear authentication disk"
	desc = "An old, worn nuclear authentication disk used in the outdated X-7 nuclear fission explosive. Nanotrasen no longer uses this model of authentication due to its poor security."
	fake = TRUE

/obj/item/disk/nuclear/decommission/ComponentInitialize()
	AddComponent(/datum/component/gps, "AUTH0", TRUE)

//==============
//The bomb
//==============

GLOBAL_LIST_EMPTY(decomission_bombs)

/obj/machinery/nuclearbomb/decomission
	desc = "A nuclear bomb for destroying stations. Uses an old version of the nuclear authentication disk."
	proper_bomb = FALSE
	var/datum/orbital_objective/nuclear_bomb/linked_objective
	var/target_z

/obj/machinery/nuclearbomb/decomission/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "BOMB0", TRUE)

/obj/machinery/nuclearbomb/decomission/Initialize(mapload)
	. = ..()
	GLOB.decomission_bombs += src
	r_code = "[rand(10000, 99999)]"
	print_command_report("Kod ładunku jądrowego do likwidacji: [r_code]")
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,4)
	new /obj/effect/pod_landingzone(get_turf(src), pod)
	forceMove(pod)

/obj/machinery/nuclearbomb/decomission/Destroy()
	. = ..()
	GLOB.decomission_bombs -= src

/obj/machinery/nuclearbomb/decomission/process()
	if(z != target_z)
		timing = FALSE
		detonation_timer = null
		countdown?.stop()
		update_icon()
		return
	. = ..()

/obj/machinery/nuclearbomb/decomission/disk_check(obj/item/disk/nuclear/D)
	if(istype(D, /obj/item/disk/nuclear/decommission))
		return TRUE
	return FALSE

/obj/machinery/nuclearbomb/decomission/set_safety()
	safety = !safety
	if(safety)
		timing = FALSE
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/decomission/set_active()
	if(safety)
		to_chat(usr, "<span class='danger'>Zabezpieczenie jest wciąż włączone.</span>")
		return
	timing = !timing
	if(timing)
		detonation_timer = world.time + (timer_set * 10)
		countdown.start()
		priority_announce("Uzbrojono ładunek rozszczepienia jądrowego na opuszczonym posterunku, natychmiast opuśćcie posterunek.",
			null, 'sound/misc/notice1.ogg', "Priority")
	else
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/decomission/explode()
	if(z != target_z)
		timing = FALSE
		detonation_timer = null
		countdown?.stop()
		update_icon()
		return
	. = ..()

/obj/machinery/nuclearbomb/decomission/actually_explode()
	SSticker.roundend_check_paused = FALSE
	linked_objective.complete_objective()
	INVOKE_ASYNC(GLOBAL_PROC,PROC_REF(KillEveryoneOnZLevel), target_z)
	QDEL_NULL(linked_objective.linked_beacon)
	qdel(src)
