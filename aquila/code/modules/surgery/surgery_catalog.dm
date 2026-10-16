// AQUILA - katalog wszystkich operacji do programu PDA „Operacje”.
// Generowany z /datum/surgery i ich kroków, więc nowe operacje pojawiają się w nim same.

GLOBAL_LIST(surgery_catalog)

/// Polskie nazwy typów narzędzi z implements
GLOBAL_LIST_INIT(surgery_tool_names, list(
	TOOL_SCALPEL = "skalpel",
	TOOL_HEMOSTAT = "hemostat",
	TOOL_RETRACTOR = "retraktor",
	TOOL_CAUTERY = "kauter",
	TOOL_DRILL = "wiertarka chirurgiczna",
	TOOL_SAW = "piła chirurgiczna",
	TOOL_BLOODFILTER = "filtr krwi",
	TOOL_SCREWDRIVER = "śrubokręt",
	TOOL_WRENCH = "klucz",
	TOOL_CROWBAR = "łom",
	TOOL_WIRECUTTER = "przecinak",
	TOOL_WELDER = "spawarka",
	TOOL_MULTITOOL = "multitool",
	TOOL_KNIFE = "nóż",
	TOOL_ANALYZER = "analizator",
	TOOL_MINING = "kilof",
	TOOL_SHOVEL = "łopata",
	TOOL_ROLLINGPIN = "wałek",
	TOOL_RUSTSCRAPER = "skrobaczka do rdzy",
))

/// Zwraca listę wszystkich operacji w formacie dla TGUI (NtosSurgeryLookup)
/proc/get_surgery_catalog()
	if(GLOB.surgery_catalog)
		return GLOB.surgery_catalog

	var/list/catalog = list()
	for(var/surgery_type in subtypesof(/datum/surgery))
		var/datum/surgery/surgery = new surgery_type
		if(surgery.replaced_by != /datum/surgery && length(surgery.steps))
			catalog += list(surgery_catalog_entry(surgery))
		qdel(surgery)
	GLOB.surgery_catalog = catalog
	return catalog

/proc/surgery_catalog_entry(datum/surgery/surgery)
	var/list/locations = list()
	for(var/zone in surgery.possible_locs)
		locations += strefa_pl(zone)

	var/list/targets = list()
	for(var/mob_type in surgery.target_mobtypes)
		targets += surgery_catalog_mob_name(mob_type)

	var/list/steps = list()
	for(var/step_type in surgery.steps)
		var/datum/surgery_step/step = new step_type
		steps += list(surgery_catalog_step(step))
		qdel(step)

	var/replaced_by
	if(surgery.replaced_by)
		var/datum/surgery/better = surgery.replaced_by
		replaced_by = initial(better.name)

	var/bodypart_kind = "dowolna"
	if(surgery.requires_bodypart_type == BODYTYPE_ORGANIC)
		bodypart_kind = "organiczna"
	else if(surgery.requires_bodypart_type == BODYTYPE_ROBOTIC)
		bodypart_kind = "robotyczna"

	return list(
		"id" = "[surgery.type]",
		"name" = capitalize(surgery.name),
		"desc" = (surgery.desc && surgery.desc != "surgery description") ? surgery.desc : null,
		"locations" = locations,
		"targets" = targets,
		"bodypart" = bodypart_kind,
		"missingLimb" = !surgery.requires_bodypart,
		"requiresTech" = !!surgery.requires_tech,
		"replacedBy" = replaced_by,
		"lying" = !!surgery.lying_required,
		"selfOperable" = !!surgery.self_operable,
		"ignoreClothes" = !!surgery.ignore_clothes,
		"steps" = steps,
	)

/proc/surgery_catalog_step(datum/surgery_step/step)
	var/list/tools = list()
	if(step.accept_hand)
		tools += list(list("name" = "pusta ręka", "chance" = 100))
	if(step.accept_any_item)
		tools += list(list("name" = "dowolny przedmiot", "chance" = 100))
	if(!step.accept_any_item)
		for(var/implement in step.implements)
			var/tool_name
			if(ispath(implement))
				var/atom/tool_type = implement
				tool_name = initial(tool_type.name)
			else
				tool_name = GLOB.surgery_tool_names[implement] || "[implement]"
			tools += list(list("name" = tool_name, "chance" = step.implements[implement]))

	var/list/chems = list()
	for(var/reagent_type in step.chems_needed)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
		chems += reagent ? reagent.name : "[reagent_type]"

	return list(
		"name" = capitalize(step.name),
		"tools" = tools,
		"time" = step.time / 10,
		"repeatable" = !!step.repeatable,
		"chems" = chems,
		"allChems" = !!step.require_all_chems,
	)

/proc/surgery_catalog_mob_name(mob_type)
	if(ispath(mob_type, /mob/living/carbon/human))
		return "ludzie"
	if(ispath(mob_type, /mob/living/carbon/monkey))
		return "małpy"
	if(ispath(mob_type, /mob/living/carbon/alien))
		return "ksenomorfy"
	if(ispath(mob_type, /mob/living/simple_animal/slime))
		return "szlamy"
	var/mob/named_type = mob_type
	return initial(named_type.name)
