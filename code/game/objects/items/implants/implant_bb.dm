/obj/item/implant/bloodbrother
	name = "communication implant"
	desc = "Use this to communicate with your fellow blood brother(s)."
	icon = 'icons/obj/radio.dmi'
	icon_state = "headset"
	var/span_implant_colour = "cfc_redpurple" // AQ EDIT - port BeeStation #9908: chat class, not a hex color
	var/list/linked_implants // All other implants that this communicates to

/obj/item/implant/bloodbrother/Initialize(mapload)
	. = ..()
	linked_implants = list()

/obj/item/implant/bloodbrother/activate()
	. = ..()
	if(linked_implants.len)
		var/input = stripped_input(imp_in, "Wpisz wiadomość do swojego brata (braci) krwi.", "Implant radiowy", "")
		if(!input || imp_in.stat == DEAD)
			return
		if(CHAT_FILTER_CHECK(input))
			to_chat(imp_in, "<span class='warning'>Wiadomość zawiera zakazane słowa!</span>")
			return
		input = imp_in.treat_message_min(input)

		var/my_message = "<span class='[span_implant_colour]'><b><i>[imp_in.mind.name]:</i></b></span> [input]" //add sender, color source with syndie color
		var/ghost_message = "<span class='[span_implant_colour]'><b><i>[imp_in.mind.name] -> Bracia krwi:</i></b></span> [input]"

		to_chat(imp_in, my_message) // Sends message to the user
		for(var/obj/item/implant/bloodbrother/i in linked_implants) // Sends message to all linked implnats
			var/M = i.imp_in
			to_chat(M, my_message)
		for(var/M in GLOB.dead_mob_list) // Sends message to ghosts
			var/link = FOLLOW_LINK(M, imp_in)
			to_chat(M, "[link] [ghost_message]")

		imp_in.log_talk(input, LOG_SAY, tag="Blood Brother Implant")
	else
		to_chat(imp_in, "<span class='bold'>Brak połączonych implantów!</span>")

/obj/item/implant/bloodbrother/Destroy()
	. = ..()
	for(var/obj/item/implant/bloodbrother/i in linked_implants) // Removes this implant from the list of implants
		i.linked_implants -= src

/obj/item/implant/bloodbrother/proc/link_implant(var/obj/item/implant/bloodbrother/BB)
	if(BB)
		if(BB == src) // Don't want to put this implant into itself
			return
		linked_implants |= BB
		BB.linked_implants |= src

/obj/item/implant/bloodbrother/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant komunikacyjny Donk Corp(tm)<BR><b>Żywotność:</b> nieograniczona.<BR><b>Ważne uwagi: <font color='red'>Nielegalny</font></B><BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera małe, bezpośrednio połączone radio z głośniczkiem i mikrofonem. Umożliwia komunikację między dwoma podobnymi implantami.<BR>"}
	return dat

/obj/item/implanter/bloodbrother
	name = "implanter (communication)"
	imp_type = /obj/item/implant/bloodbrother



