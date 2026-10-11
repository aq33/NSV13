// Port BeeStation #8776: opisy, historia i unikalne cechy gatunków do okna wyboru gatunku (teksty z BeeStation)

/// Krótki opis gatunku w oknie wyboru
/datum/species/proc/get_species_description()
	return ""

/// Akapity historii gatunku, null gdy brak
/datum/species/proc/get_species_lore()
	return null

/// Lista cech (SPECIES_PERK_*) pokazywanych w oknie wyboru
/datum/species/proc/create_pref_unique_perks()
	return list()

/// Cechy pogrupowane tak, jak oczekuje okno
/datum/species/proc/get_species_perks()
	var/list/perks = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEGATIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
	)
	for(var/list/perk as anything in create_pref_unique_perks())
		var/list/perk_list = perks[perk[SPECIES_PERK_TYPE]]
		perk_list += list(list(
			"ui_icon" = perk[SPECIES_PERK_ICON],
			"name" = perk[SPECIES_PERK_NAME],
			"description" = perk[SPECIES_PERK_DESC],
		))
	return perks

/datum/species/ipc/get_species_description()
	return "The newest in artificial life, IPCs are entirely robotic, synthetic life, made of motors, circuits, and wires \
	- based on newly developed Postronic brain technology."

/datum/species/ipc/get_species_lore()
	return null

/datum/species/ipc/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shockingly Tasty",
			SPECIES_PERK_DESC = "IPCs can feed on electricity from APCs and powercells to restore their charge; and do not otherwise need to eat.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Robotic",
			SPECIES_PERK_DESC = "IPCs have an entirely robotic body, meaning medical care is typically done through Robotics or Engineering. \
			Whether this is helpful or not is heavily dependent on your coworkers. It does, however, mean you are usually able to perform self-repairs easily.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "magnet",
			SPECIES_PERK_NAME = "EMP Vulnerable",
			SPECIES_PERK_DESC = "IPC organs are cybernetic, and thus susceptible to electromagnetic interference. Getting hit by an EMP may stop your heart.",
		),
	)

	return to_add

/datum/species/apid/get_species_description()
	return "Beepeople, god damn it. It's hip, and alive! Buzz buzz!"

/datum/species/apid/get_species_lore()
	return null

/datum/species/ethereal/get_species_description()
	return "Ethereals are a unique species with liquid electricity for blood and a glowing body. They thrive on electricity, and are naturally agender."

/datum/species/ethereal/get_species_lore()
	return null

/datum/species/human/felinid/get_species_description()
	return "Felinids are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Felinids are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Felinids are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

/datum/species/fly/get_species_description()
	return "With no official documentation or knowledge of the origin of \
		this species, they remain a mystery to most. Any and all rumours among \
		Nanotrasen staff regarding flypeople are often quickly silenced by high \
		ranking staff or officials."

/datum/species/fly/get_species_lore()
	return list(
		"Flypeople are a curious species with a striking resemblance to the insect order of Diptera, \
		commonly known as flies. With no publically known origin, flypeople are rumored to be a side effect of bluespace travel, \
		despite statements from Nanotrasen officials.",

		"Little is known about the origins of this race, \
		however they posess the ability to communicate with giant spiders, originally discovered in the Australicus sector \
		and now a common occurence in black markets as a result of a breakthrough in syndicate bioweapon research.",

		"Flypeople are often feared or avoided among other species, their appearance often described as unclean or frightening in some cases, \
		and their eating habits even more so with an insufferable accent to top it off.",
	)

/datum/species/human/get_species_description()
	return "Humans are the dominant species in the known galaxy. \
		Their kind extend from old Earth to the edges of known space."

/datum/species/human/get_species_lore()
	return list(
		"These primate-descended creatures, originating from the mostly harmless Earth, \
		have long-since outgrown their home and semi-benign designation. \
		The space age has taken humans out of their solar system and into the galaxy-at-large."
	)

/datum/species/lizard/get_species_description()
	return "Lizardpeople, unlike many 'Animalid' species, are not derived from humans, and are simply bipedal reptile-like people. \
	Lizards often find great pride in their species."

/datum/species/lizard/get_species_lore()
	return null

/datum/species/moth/get_species_description()
	return "Mothpeople are an intelligent species, known for their affinity to all things moth - lights, cloth, wings, and friendship."

/datum/species/moth/get_species_lore()
	return null

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off. However, moths can spin a cooccon to restore their wings if necessary.",
		),
	)

	return to_add

/datum/species/oozeling/get_species_description()
	return "Literally made of jelly, Oozelings are squishy friends aboard Space Station 13."

/datum/species/oozeling/get_species_lore()
	return null

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Splat!",
			SPECIES_PERK_DESC = "Oozelings have special resistance to falling, because their body and organs can flatten on impact. \
			It might hurt a bit, but generally Oozelings can fall a lot further before their vitals organs start being pulverized.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "street-view",
			SPECIES_PERK_NAME = "Regenerative Limbs",
			SPECIES_PERK_DESC = "Oozelings can regrow their limbs at will, provided they have enough Jelly.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Hydrophobic",
			SPECIES_PERK_DESC = "Oozelings are decomposed by water - contact with water, water vapor, or ingesting water can lead to rapid loss of body mass.",
		)
	)

	return to_add

/datum/species/plasmaman/get_species_description()
	return "Found on the Icemoon of Freyja, plasmamen consist of colonial \
		fungal organisms which together form a sentient being. In human space, \
		they're usually attached to skeletons to afford a human touch."

/datum/species/plasmaman/get_species_lore()
	return list(
		"A confusing species, plasmamen are truly \"a fungus among us\". \
		What appears to be a singular being is actually a colony of millions of organisms \
		surrounding a found (or provided) skeletal structure.",

		"Originally discovered by NT when a researcher \
		fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating \
		the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen \
		have been deployed en masse throughout NT to bolster the workforce.",

		"New to the galactic stage, plasmamen are a blank slate. \
		Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. \
		It might be the whole \"flammable purple skeleton\" thing.",

		"The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. \
		Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
	)

