/client/verb/toggle_radio_sound()
	set name = "Hear/Silence Radio Sound"
	set category = "Preferences"
	set desc = "Hear/Silence Radio Sound"
	prefs.toggles2 ^= PREFTOGGLE_2_RADIO_SOUND
	to_chat(usr, "You will now [(prefs.toggles2 & PREFTOGGLE_2_RADIO_SOUND) ? "hear radio sounds" : "no longer hear radio noise"].")
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Radio Sound", "[prefs.toggles2 & PREFTOGGLE_2_RADIO_SOUND ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_walk_animation()
	set name = "Animacja chodu"
	set category = "Preferences"
	set desc = "Włącz lub wyłącz animację rąk i nóg twojej postaci przy chodzeniu"
	prefs.toggles2 ^= PREFTOGGLE_2_DISABLE_WALK_ANIMATION
	to_chat(usr, "Animacja chodu twojej postaci jest teraz [(prefs.toggles2 & PREFTOGGLE_2_DISABLE_WALK_ANIMATION) ? "wyłączona" : "włączona"].")
	prefs.save_preferences()
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.update_walk_animation()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Walk Animation", "[prefs.toggles2 & PREFTOGGLE_2_DISABLE_WALK_ANIMATION ? "Disabled" : "Enabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
