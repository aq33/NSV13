/// Plik, do którego dopisywane są wszystkie ankiety (wspólny dla wszystkich rund)
#define ROUND_SURVEY_FILE "data/ankiety.txt"
#define ROUND_SURVEY_MAX_TEXT 1000

/// ckeys that already sent the survey this round
GLOBAL_LIST_EMPTY(round_survey_submitted)
/// ckey -> open /datum/round_survey (keeps the datum alive while the window is open)
GLOBAL_LIST_EMPTY(round_surveys)

/client/proc/show_round_survey()
	if(GLOB.round_survey_submitted[ckey])
		return
	var/datum/round_survey/survey = GLOB.round_surveys[ckey]
	if(!survey)
		survey = new(src)
		GLOB.round_surveys[ckey] = survey
	survey.show()

/datum/round_survey
	var/owner_ckey

/datum/round_survey/New(client/C)
	owner_ckey = C.ckey

/datum/round_survey/proc/show()
	var/client/C = GLOB.directory[owner_ckey]
	if(!C?.mob)
		return
	ui_interact(C.mob)

/datum/round_survey/ui_state(mob/user)
	return GLOB.always_state

/datum/round_survey/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RoundSurvey")
		ui.open()

/datum/round_survey/ui_static_data(mob/user)
	return list("max_text" = ROUND_SURVEY_MAX_TEXT)

/datum/round_survey/proc/clean_text(t)
	t = trim(copytext_char("[t]", 1, ROUND_SURVEY_MAX_TEXT))
	t = replacetext(t, ascii2text(13), "")
	return replacetext(t, "\n", " / ")

/datum/round_survey/ui_act(action, list/params)
	. = ..()
	if(. || action != "submit")
		return
	if(!usr?.client || usr.ckey != owner_ckey)
		return
	if(GLOB.round_survey_submitted[owner_ckey])
		return
	var/fun = text2num(params["fun"])
	if(!(fun in 1 to 5) || fun != round(fun))
		to_chat(usr, "<span class='warning'>Zaznacz ocenę wrażeń (od 1 do 5).</span>")
		return
	GLOB.round_survey_submitted[owner_ckey] = TRUE
	var/list/entry = list()
	entry += "=== Runda [GLOB.round_id ? GLOB.round_id : "?"] | [time_stamp("YYYY-MM-DD hh:mm")] | [owner_ckey] ==="
	entry += "Wrażenia: [fun]/5"
	entry += "Błędy: [clean_text(params["bugs"]) || "-"]"
	entry += "Uwagi: [clean_text(params["comments"]) || "-"]"
	text2file("[entry.Join("\n")]\n", ROUND_SURVEY_FILE)
	to_chat(usr, "<span class='notice'>Dziękujemy za wypełnienie ankiety!</span>")
	SStgui.close_uis(src)
	GLOB.round_surveys -= owner_ckey
	qdel(src)
	return TRUE

#undef ROUND_SURVEY_FILE
#undef ROUND_SURVEY_MAX_TEXT
