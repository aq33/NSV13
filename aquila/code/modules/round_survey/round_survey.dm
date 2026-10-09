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

/datum/round_survey/proc/rating_row(field, label, low_text, high_text)
	. = "<p><b>[label]</b><br>[low_text] "
	for(var/i in 1 to 5)
		. += "<label><input type='radio' name='[field]' value='[i]'>[i]</label> "
	. += "[high_text]</p>"

/datum/round_survey/proc/show()
	var/client/C = GLOB.directory[owner_ckey]
	if(!C)
		return
	var/list/dat = list()
	dat += "<form action='?src=[REF(src)]' method='get'>"
	dat += "<input type='hidden' name='src' value='[REF(src)]'>"
	dat += "<p>Runda się skończyła. Poświęć chwilę i oceń ją. Ankieta jest anonimowa dla innych graczy.</p>"
	dat += rating_row("fun", "Wrażenia", "1 = źle się bawiłem", "5 = dobrze się bawiłem")
	dat += rating_row("pace", "Dynamika", "1 = za nudno", "5 = za dużo się działo")
	dat += "<p><b>Czy napotkałeś jakieś błędy?</b><br><textarea name='bugs' cols='50' rows='5'></textarea></p>"
	dat += "<p><b>Ogólne uwagi</b><br><textarea name='comments' cols='50' rows='5'></textarea></p>"
	dat += "<p><input type='submit' value='Wyślij'></p>"
	dat += "</form>"
	var/datum/browser/popup = new(C.mob, "round_survey", "Ankieta po rundzie", 480, 560)
	popup.set_content(dat.Join())
	popup.open()

/datum/round_survey/proc/clean_text(t)
	t = trim(copytext_char("[t]", 1, ROUND_SURVEY_MAX_TEXT))
	t = replacetext(t, ascii2text(13), "")
	return replacetext(t, "\n", " / ")

/datum/round_survey/Topic(href, href_list)
	if(!usr?.client || usr.ckey != owner_ckey)
		return
	if(GLOB.round_survey_submitted[owner_ckey])
		return
	var/fun = text2num(href_list["fun"])
	var/pace = text2num(href_list["pace"])
	if(!(fun in 1 to 5) || !(pace in 1 to 5) || fun != round(fun) || pace != round(pace))
		to_chat(usr, "<span class='warning'>Zaznacz ocenę wrażeń i dynamiki (od 1 do 5).</span>")
		return
	GLOB.round_survey_submitted[owner_ckey] = TRUE
	var/list/entry = list()
	entry += "=== Runda [GLOB.round_id ? GLOB.round_id : "?"] | [time_stamp("YYYY-MM-DD hh:mm")] | [owner_ckey] ==="
	entry += "Wrażenia: [fun]/5"
	entry += "Dynamika: [pace]/5"
	entry += "Błędy: [clean_text(href_list["bugs"]) || "-"]"
	entry += "Uwagi: [clean_text(href_list["comments"]) || "-"]"
	text2file("[entry.Join("\n")]\n", ROUND_SURVEY_FILE)
	usr << browse(null, "window=round_survey")
	to_chat(usr, "<span class='notice'>Dziękujemy za wypełnienie ankiety!</span>")
	GLOB.round_surveys -= owner_ckey
	qdel(src)

#undef ROUND_SURVEY_FILE
#undef ROUND_SURVEY_MAX_TEXT
