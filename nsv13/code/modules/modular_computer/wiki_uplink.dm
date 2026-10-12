/datum/computer_file/program/databank_uplink
	filename = "databank"
	filedesc = "Łącze z bankiem danych okrętu"
	extended_desc = "Aplikacja do łączenia się z bankami danych okrętu, by mieć dostęp do wszystkich poradników, jakich kiedykolwiek będziesz potrzebować!"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	size = 2
	tgui_id = "NtosDatabank"
	program_icon = "book"

/datum/computer_file/program/databank_uplink/ui_data(mob/user)
	var/list/data = list()
	var/wikiurl = CONFIG_GET(string/wikiurl)

	data["src"] = wikiurl
	return data
