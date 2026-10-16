/// AQUILA: odpowiednik area_flags_mapping z tg (VIRTUAL_AREA / VIRTUAL_SAFE_AREA)
/area/var/virtual_area_flags = NONE

/// Station side

/area/quartermaster/bitrunning
	name = "Bitrunning"
	icon = 'aquila/icons/area/bitrunning.dmi'
	icon_state = "bit_den"

/area/quartermaster/bitrunning/den
	name = "Pracownia Bitrunnerów"
	desc = "Biuro bitrunnerów, tu stoi ich sprzęt."
	icon_state = "bit_den"
	sound_environment = SOUND_AREA_STANDARD_STATION

/// VDOM

/area/virtual_domain
	name = "Ruiny Domeny Wirtualnej"
	icon = 'aquila/icons/area/bitrunning.dmi'
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | HIDDEN_AREA
	virtual_area_flags = VIRTUAL_AREA
	has_gravity = STANDARD_GRAVITY
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/virtual_domain/fullbright
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/// Safehouse

/area/virtual_domain/safehouse
	name = "Kryjówka Domeny Wirtualnej"
	area_flags = UNIQUE_AREA
	virtual_area_flags = VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Wirtualne Ruiny Lawy"
	icon = 'aquila/icons/area/bitrunning.dmi'
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | HIDDEN_AREA
	virtual_area_flags = VIRTUAL_AREA
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/virtual_domain/ice
	name = "Wirtualne Lodowe Ruiny"
	icon_state = "bit_ice"

/area/ruin/space/virtual_domain
	name = "Niezbadane Miejsce Domeny Wirtualnej"
	icon = 'aquila/icons/area/bitrunning.dmi'
	icon_state = "bit_ruin"
	area_flags = UNIQUE_AREA | HIDDEN_AREA
	virtual_area_flags = VIRTUAL_AREA
	has_gravity = STANDARD_GRAVITY
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/space/virtual_domain
	name = "Kosmos Domeny Wirtualnej"
	icon = 'aquila/icons/area/bitrunning.dmi'
	icon_state = "bit_space"
	area_flags = UNIQUE_AREA | HIDDEN_AREA
	virtual_area_flags = VIRTUAL_AREA
	teleport_restriction = TELEPORT_ALLOW_NONE

///Areas that virtual entities should not be in

/area/virtual_domain/protected_space
	name = "Strefa Bezpieczna Domeny Wirtualnej"
	area_flags = UNIQUE_AREA
	virtual_area_flags = VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"

/area/virtual_domain/protected_space/fullbright
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/// AQUILA: Pętla, cyfrowe więzienie wygnańców
/area/virtual_domain/exile_loop
	name = "Pętla"
	desc = "Cyfrowe więzienie, z którego nie ma wyjścia."
	area_flags = UNIQUE_AREA
	virtual_area_flags = VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Czy obszar jest wirtualny (domena, kryjówka, Pętla)
/proc/is_virtual_area(area/checked)
	return checked && (checked.virtual_area_flags & VIRTUAL_AREA)
