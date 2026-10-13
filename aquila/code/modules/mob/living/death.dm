/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	. = ..()
	if(!was_dead_before && client && mind?.current)
		INVOKE_ASYNC(src, PROC_REF(show_death_info))

///Okienko z informacją, że gracz umarł i jak może wrócić do gry (tgui DeathInfo.js)
/mob/living/proc/show_death_info()
	GLOB.death_info.ui_interact(src)

GLOBAL_DATUM_INIT(death_info, /datum/death_info, new)

/// One shared datum behind every "Nie żyjesz" window, the window only shows static text
/datum/death_info

/datum/death_info/ui_state(mob/user)
	return GLOB.always_state

/datum/death_info/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DeathInfo")
		ui.open()

/datum/death_info/ui_static_data(mob/user)
	return list(
		"defib_minutes" = DEFIB_TIME_LIMIT / 60,
		"norespawn" = CONFIG_GET(flag/norespawn),
	)
