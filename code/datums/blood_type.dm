// Ported from BeeStation/BeeStation-Hornet#13410 (Speciesblood 2).
// AQUILA - dna.blood_type stays a name ("A+", "L", ...). These datums give each name its colour, compatibility and glow,
// so records, cloning, DNA consoles and injectors keep working with plain strings. Look them up with get_blood_type(name).

GLOBAL_LIST_INIT(blood_types, generate_blood_types())

/proc/generate_blood_types()
	. = list()
	for(var/path in subtypesof(/datum/blood_type))
		var/datum/blood_type/new_type = new path()
		.[new_type.name] = new_type

/// Returns the blood type datum for a blood type name, or null
/proc/get_blood_type(name)
	if(istype(name, /datum/blood_type))
		return name
	return GLOB.blood_types[name]

/datum/blood_type
	/// Displayed name of the blood type. This is what dna.blood_type and blood DNA lists store.
	var/name = "?"
	/// Shown color of the blood type.
	var/blood_color = COLOR_BLOOD
	/// Blood types that are safe to use with people that have this blood type.
	var/compatible_types = list()
	///Do we glow or not?
	var/glowy = FALSE

/datum/blood_type/a_minus
	name = "A-"
	compatible_types = list(
		/datum/blood_type/a_minus,
		/datum/blood_type/o_minus
	)

/datum/blood_type/a_plus
	name = "A+"
	compatible_types = list(
		/datum/blood_type/a_minus,
		/datum/blood_type/a_plus,
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus
	)

/datum/blood_type/b_minus
	name = "B-"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/o_minus
	)

/datum/blood_type/b_plus
	name = "B+"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/b_plus,
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus
	)

/datum/blood_type/ab_minus
	name = "AB-"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/a_minus,
		/datum/blood_type/ab_minus,
		/datum/blood_type/o_minus
	)

/datum/blood_type/ab_plus
	name = "AB+"
	compatible_types = list(
		/datum/blood_type/b_minus,
		/datum/blood_type/b_plus,
		/datum/blood_type/a_minus,
		/datum/blood_type/a_plus,
		/datum/blood_type/ab_minus,
		/datum/blood_type/ab_plus,
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus
	)

/datum/blood_type/o_minus
	name = "O-"
	compatible_types = list(
		/datum/blood_type/o_minus
	)

/datum/blood_type/o_plus
	name = "O+"
	compatible_types = list(
		/datum/blood_type/o_minus,
		/datum/blood_type/o_plus
	)

/datum/blood_type/xenomorph //for xenomorph gib dna
	name = "X*"
	blood_color = rgb(0, 255, 0)
	compatible_types = list(
		/datum/blood_type/xenomorph
	)

/datum/blood_type/animal //for simplemob gib dna
	name = "Y-"
	compatible_types = list(
		/datum/blood_type/animal
	)

/datum/blood_type/lizard
	name = "L"
	blood_color = "#009696"
	compatible_types = list(
		/datum/blood_type/lizard
	)

/datum/blood_type/ethereal
	name = "E"
	blood_color = "#7fff7f"
	compatible_types = list(
		/datum/blood_type/ethereal
	)
	glowy = TRUE

/datum/blood_type/synthetic //Blood for synthetic/robotic species
	name = "Coolant"
	blood_color = "#dddeff"
	compatible_types = list(
		/datum/blood_type/synthetic
	)

/datum/blood_type/universal
	name = "U"

/datum/blood_type/universal/New()
	. = ..()
	compatible_types = subtypesof(/datum/blood_type)
