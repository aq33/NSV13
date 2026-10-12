/// AQUILA - przy każdym otwarciu czatu wysyłamy kanały radia, po których TAB ma przełączać (zamiast OOC/LOOC)
/datum/tgui_say/open(payload)
	. = ..()
	window.send_message("radio", list(
		prefixes = get_radio_prefixes(),
	))

/// Prefiksy (np. ":e ") kanałów, na których mob może mówić przez swoje radio
/datum/tgui_say/proc/get_radio_prefixes()
	. = list()
	var/obj/item/radio/radio
	if(ishuman(client?.mob))
		var/mob/living/carbon/human/human_mob = client.mob
		radio = human_mob.ears
	else if(issilicon(client?.mob))
		var/mob/living/silicon/silicon_mob = client.mob
		radio = silicon_mob.radio
	if(!istype(radio) || !radio.on || !length(radio.channels))
		return

	var/list/seen_channels = list()
	for(var/key in GLOB.department_radio_keys)
		var/channel = GLOB.department_radio_keys[key]
		if(seen_channels[channel] || !(channel in radio.channels))
			continue
		seen_channels[channel] = TRUE
		. += ":[key] "
