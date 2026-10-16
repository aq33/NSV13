// AQUILA - the advanced health analyzer shows which step comes next in an ongoing surgery and what to do it with.

/// Polish names of the common steps, others show their own name
GLOBAL_LIST_INIT(aq_surgery_step_names, list(
	/datum/surgery_step/incise = "nacięcie",
	/datum/surgery_step/retract_skin = "rozwarcie skóry",
	/datum/surgery_step/clamp_bleeders = "zaciśnięcie naczyń",
	/datum/surgery_step/saw = "piłowanie kości",
	/datum/surgery_step/close = "zamknięcie rany",
	/datum/surgery_step/drill = "wiercenie",
	/datum/surgery_step/mechanic_open = "odkręcenie obudowy",
	/datum/surgery_step/mechanic_close = "zakręcenie obudowy",
	/datum/surgery_step/open_hatch = "otwarcie klapy",
	/datum/surgery_step/prepare_electronics = "przygotowanie elektroniki",
	/datum/surgery_step/mechanic_unwrench = "odkręcenie śrub",
	/datum/surgery_step/mechanic_wrench = "dokręcenie śrub",
	/datum/surgery_step/manipulate_organs = "przenoszenie narządów",
	/datum/surgery_step/heal = "leczenie ran",
	/datum/surgery_step/sever_limb = "odcięcie kończyny",
	/datum/surgery_step/replace_limb = "wymiana kończyny",
	/datum/surgery_step/add_prosthetic = "przyłączenie protezy",
	/datum/surgery_step/fix_brain = "naprawa mózgu",
	/datum/surgery_step/fix_eyes = "naprawa oczu",
	/datum/surgery_step/fix_ears = "naprawa uszu",
	/datum/surgery_step/handle_cavity = "umieszczenie w jamie ciała",
	/datum/surgery_step/extract_implant = "wyjęcie implantu",
	/datum/surgery_step/remove_object = "wyjęcie ciał obcych",
	/datum/surgery_step/incise_heart = "nacięcie serca",
	/datum/surgery_step/coronary_bypass = "bypass wieńcowy",
	/datum/surgery_step/filter_blood = "filtracja krwi",
))

/// Polish names of tool behaviours
GLOBAL_LIST_INIT(aq_surgery_tool_names, list(
	TOOL_SCALPEL = "skalpel",
	TOOL_RETRACTOR = "retraktor",
	TOOL_HEMOSTAT = "hemostat",
	TOOL_CAUTERY = "kauter",
	TOOL_SAW = "piła",
	TOOL_DRILL = "wiertarka",
	TOOL_SCREWDRIVER = "śrubokręt",
	TOOL_WRENCH = "klucz",
	TOOL_CROWBAR = "łom",
	TOOL_MULTITOOL = "multitool",
	TOOL_WIRECUTTER = "przecinak",
	TOOL_WELDER = "spawarka",
	TOOL_BLOODFILTER = "filtr krwi",
	TOOL_KNIFE = "nóż",
))

/// What the next step of every ongoing surgery is, for the advanced analyzer
/mob/living/proc/get_surgery_progress()
	var/list/progress = list()
	for(var/datum/surgery/surgery as anything in surgeries)
		if(surgery.status > length(surgery.steps))
			continue
		var/step_type = surgery.steps[surgery.status]
		var/datum/surgery_step/step = new step_type
		progress += list(list(
			"name" = surgery.name,
			"zone" = strefa_pl(surgery.location),
			"step" = GLOB.aq_surgery_step_names[step_type] || step.name,
			"step_number" = surgery.status,
			"step_count" = length(surgery.steps),
			"tools" = aq_surgery_step_tools(step),
		))
		qdel(step)
	return progress

/// The best tools for a step, best first
/proc/aq_surgery_step_tools(datum/surgery_step/step)
	if(step.accept_hand)
		return "ręka"
	var/list/sorted = list()
	for(var/implement in step.implements)
		sorted[implement] = step.implements[implement]
	sortTim(sorted, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/list/names = list()
	for(var/implement in sorted)
		if(length(names) >= 3)
			break
		if(ispath(implement, /obj/item))
			var/obj/item/item_type = implement
			if(implement == /obj/item)
				names += "dowolny przedmiot ([sorted[implement]]%)"
			else
				names += "[initial(item_type.name)] ([sorted[implement]]%)"
		else
			names += "[GLOB.aq_surgery_tool_names[implement] || implement] ([sorted[implement]]%)"
	if(step.accept_any_item)
		names += "dowolny przedmiot"
	return jointext(names, ", ")

/// Lines for the chat scan of the advanced analyzer
/mob/living/proc/get_surgery_scan_lines()
	var/list/lines = list()
	for(var/list/surgery as anything in get_surgery_progress())
		lines += "<span class='notice'>Operacja: <b>[surgery["name"]]</b> ([surgery["zone"]]), krok [surgery["step_number"]]/[surgery["step_count"]]: <b>[surgery["step"]]</b>. Narzędzie: [surgery["tools"]].</span>"
	return lines
