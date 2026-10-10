// Port BeeStation/BeeStation-Hornet#11938: miejsca, w których screentip trzeba przeliczyć, i sterowanie nim przez gracza.
// W Bee te wywołania siedzą w plikach core; tu są jako nadpisania z ..().

/client/verb/toggle_screentips()
	set name = "Podpowiedzi na ekranie"
	set category = "Preferences"
	set desc = "Pokazuj u góry ekranu nazwę rzeczy pod kursorem i co można z nią zrobić"
	prefs.toggles2 ^= PREFTOGGLE_2_DISABLE_SCREENTIPS
	var/enabled = !(prefs.toggles2 & PREFTOGGLE_2_DISABLE_SCREENTIPS)
	to_chat(usr, "Podpowiedzi na ekranie są teraz [enabled ? "włączone" : "wyłączone"].")
	if(!enabled && mob?.hud_used?.screentip)
		mob.hud_used.screentip.maptext = null
	prefs.save_preferences()
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Screentips", "[enabled ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// W Bee rozszerzone podpowiedzi (narzędzia) włącza keybind na Shift. U nas zapisane skróty graczy nie dostałyby
// nowego bindu, więc Shift jest obsługiwany bezpośrednio.
/client/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE
	. = ..()
	if(_key == "Shift" && !show_extended_screentips)
		show_extended_screentips = TRUE
		mob?.refresh_self_screentips()

/client/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE
	. = ..()
	if(_key == "Shift" && show_extended_screentips)
		show_extended_screentips = FALSE
		mob?.refresh_self_screentips()

/atom/Click(location, control, params)
	. = ..()
	refresh_screentips()

/obj/item/dropped(mob/user, silent = FALSE)
	. = ..()
	user?.refresh_self_screentips()

/obj/item/pickup(mob/user)
	. = ..()
	user?.refresh_self_screentips()

/mob/living/carbon/swap_hand(held_index)
	. = ..()
	refresh_self_screentips()

/mob/living/silicon/robot/swap_hand()
	. = ..()
	refresh_self_screentips()

/mob/living/simple_animal/swap_hand(hand_index)
	. = ..()
	refresh_self_screentips()
