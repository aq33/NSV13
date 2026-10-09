/datum/preferences
	clientfps = 60

/// Body sizes the active character can pick. "Polak" also needs its loadout unlock.
/datum/preferences/proc/get_body_size_choices()
	var/datum/gear/ooc/polak/polak_unlock = /datum/gear/ooc/polak
	if(md5(initial(polak_unlock.display_name)) in purchased_gear)
		return active_character.pref_species.get_body_sizes()
	return active_character.pref_species.get_body_sizes() - "Polak"
