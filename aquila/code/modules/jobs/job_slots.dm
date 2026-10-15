// Liczba slotów prac Aquili - nadpisuje domyślne wartości z code/ i nsv13/ na wszystkich mapach.

/datum/job/bridge
	total_positions = 1
	spawn_positions = 1

/datum/job/munitions_tech
	total_positions = 2
	spawn_positions = 2

/datum/job/pilot
	total_positions = 1
	spawn_positions = 1

// Inżynier przejął atmosferykę: dodatkowy slot i dostęp do atmosferyki także przy minimal access
/datum/job/station_engineer
	total_positions = 2
	spawn_positions = 2

/datum/job/station_engineer/New()
	. = ..()
	minimal_access |= ACCESS_ATMOSPHERICS

/datum/job/medical_doctor
	total_positions = 2
	spawn_positions = 2

/datum/job/scientist
	total_positions = 2
	spawn_positions = 2

/datum/job/janitor
	total_positions = 1
	spawn_positions = 1

/datum/job/security_officer
	total_positions = 2
	spawn_positions = 2

// Stała liczba żandarmów zamiast skalowania z liczbą graczy (SECURITY_SCALING_COEFF)
/datum/controller/subsystem/job/setup_officer_positions()
	return

// Prace wyłączone na Aquili
/datum/job/brig_physician/map_check()
	return FALSE

/datum/job/air_traffic_controller/map_check()
	return FALSE

/datum/job/exploration_crew/map_check()
	return FALSE

/datum/job/deputy/map_check()
	return FALSE

/datum/job/atmospheric_technician/map_check()
	return FALSE
