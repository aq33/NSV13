/mob/living/silicon/ai/verb/clear_custom_holoform()
	set name = "Clear Custom Holoform"
	set desc = "Clear your current custom holoform"
	set category = "AI Commands"

	if(!client.prefs)
		to_chat(src, "<span class='boldwarning'>Twój klient nie ma datum preferencji, skontaktuj się z adminem/koderem!</span>")
		return
	client.prefs.custom_holoform_icon = null
	client.prefs.cached_holoform_icons = null
	to_chat(src, "<span class='boldnotice'>Usunięto holoformę.</span>")

/mob/living/silicon/ai/verb/set_custom_holoform()
	set name = "Set Custom Holoform"
	set desc = "Set your custom holoform using your current preferences slot and a specified set of gear."
	set category = "AI Commands"

	if(!client.prefs)
		to_chat(src, "<span class='boldwarning'>Twój klient nie ma datum preferencji, skontaktuj się z adminem/koderem!</span>")
		return
	if(client.prefs.last_custom_holoform > world.time - CUSTOM_HOLOFORM_DELAY)
		to_chat(src, "<span class='warning'>Zbyt szybko próbujesz zmieniać własne holoformy!</span>")
	var/icon/new_holoform = user_interface_custom_holoform(client)
	if(new_holoform)
		client.prefs.custom_holoform_icon = new_holoform
		client.prefs.cached_holoform_icons = null
		client.prefs.last_custom_holoform = world.time
		to_chat(src, "<span class='boldnotice'>Ustawiono holoformę.</span>")
