/datum/gear/ooc
	subtype_path = /datum/gear/ooc
	sort_category = "OOC"
	cost = 10000

/datum/gear/ooc/char_slot
	display_name = "extra character slot"
	description = "Dodatkowe miejsce na postać. Chyba nie trzeba tłumaczyć."
	cost = 10000

/datum/gear/ooc/char_slot/purchase(var/client/C)
	C?.prefs?.set_max_character_slots(C?.prefs?.max_usable_slots + 1)

/datum/gear/ooc/real_antagtoken
	display_name = "antag token"
	description = "Jeśli cię na to stać, zasługujesz na to."
	cost = 100000

/datum/gear/ooc/real_antagtoken/purchase(var/client/C)
	C.inc_antag_token_count(1)
	message_admins("[C.ckey] has purchased a genuine antag token.")
	log_game("[C.ckey] has purchased a genuine antag token.")
