/client/verb/toggle_tips()
	set name = "Toggle Examine Tooltips"
	set desc = "Toggles examine hover-over tooltips"
	set category = "Preferences"

	prefs.toggles2 ^= PREFTOGGLE_2_ENABLE_TIPS
	prefs.save_preferences()
	to_chat(usr, "<span class='danger'>Podpowiedzi przy oglądaniu [(prefs.toggles2 & PREFTOGGLE_2_ENABLE_TIPS) ? "włączone" : "wyłączone"].</span>")

/client/verb/change_tip_delay()
	set name = "Set Examine Tooltip Delay"
	set desc = "Sets the delay in milliseconds before examine tooltips appear"
	set category = "Preferences"

	var/indelay = stripped_input(usr, "Podaj opóźnienie podpowiedzi w milisekundach (domyślnie: 500)", "Opóźnienie podpowiedzi", "", 10)
	indelay = text2num(indelay)
	if(usr)//is this what you mean?
		prefs.tip_delay = indelay
		prefs.save_preferences()
		to_chat(usr, "<span class='danger'>Ustawiono opóźnienie podpowiedzi na [indelay] ms.</span>")
