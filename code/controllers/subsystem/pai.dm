SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	var/list/candidates = list()
	var/ghost_spam = FALSE
	var/spam_delay = 100
	var/list/pai_card_list = list()

/datum/controller/subsystem/pai/Topic(href, href_list[])
	if(href_list["download"])
		var/datum/paiCandidate/candidate = locate(href_list["candidate"]) in candidates
		var/obj/item/paicard/card = locate(href_list["device"]) in pai_card_list
		if(card.pai)
			return
		if(istype(card, /obj/item/paicard) && istype(candidate, /datum/paiCandidate))
			if(check_ready(candidate) != candidate)
				return FALSE
			var/mob/living/silicon/pai/pai = new(card)
			if(!candidate.name)
				pai.name = pick(GLOB.ninja_names)
			else
				pai.name = candidate.name
			pai.real_name = pai.name
			pai.key = candidate.key

			card.setPersonality(pai)

			SSticker.mode.update_cult_icons_removed(card.pai.mind)

			candidates -= candidate
			usr << browse(null, "window=findPai")

	if(href_list["new"])
		var/datum/paiCandidate/candidate = locate(href_list["candidate"]) in candidates
		var/option = href_list["option"]
		var/t = ""

		switch(option)
			if("name")
				t = sanitize_name(stripped_input(usr, "Podaj imię swojego pAI", "pAI Name", candidate.name, MAX_NAME_LEN))
				if(t)
					candidate.name = t
			if("desc")
				t = stripped_multiline_input(usr, "Podaj opis swojego pAI", "pAI Description", candidate.description)
				if(t)
					candidate.description = t
			if("role")
				t = stripped_input(usr, "Podaj rolę swojego pAI", "pAI Role", candidate.role)
				if(t)
					candidate.role = t
			if("ooc")
				t = stripped_multiline_input(usr, "Podaj komentarze OOC", "pAI OOC Comments", candidate.comments)
				if(t)
					candidate.comments = t
			if("save")
				candidate.savefile_save(usr)
			if("load")
				candidate.savefile_load(usr)
				//In case people have saved unsanitized stuff.
				if(candidate.name)
					candidate.name = copytext_char(sanitize(candidate.name),1,MAX_NAME_LEN)
				if(candidate.description)
					candidate.description = copytext_char(sanitize(candidate.description),1,MAX_MESSAGE_LEN)
				if(candidate.role)
					candidate.role = copytext_char(sanitize(candidate.role),1,MAX_MESSAGE_LEN)
				if(candidate.comments)
					candidate.comments = copytext_char(sanitize(candidate.comments),1,MAX_MESSAGE_LEN)

			if("submit")
				if(candidate)
					candidate.ready = 1
					for(var/obj/item/paicard/p in pai_card_list)
						if(!p.pai)
							p.alertUpdate()
				usr << browse(null, "window=paiRecruit")
				return
		recruitWindow(usr)

/datum/controller/subsystem/pai/proc/recruitWindow(mob/M)
	var/datum/paiCandidate/candidate
	for(var/datum/paiCandidate/c in candidates)
		if(c.key == M.key)
			candidate = c
	if(!candidate)
		candidate = new /datum/paiCandidate()
		candidate.key = M.key
		candidates.Add(candidate)


	var/dat = ""
	dat += {"
			<style type="text/css">

			p.top {
				background-color: #AAAAAA; color: black;
			}

			tr.d0 td {
				background-color: #CC9999; color: black;
			}
			tr.d1 td {
				background-color: #9999CC; color: black;
			}
			</style>
			"}

	dat += "<p class=\"top\">Skonfiguruj opcje osobowości swojego pAI. Pamiętaj, że to, co tu wpiszesz, może przesądzić o tym, czy osoba prosząca o osobowość wybierze właśnie ciebie!</p>"
	dat += "<table>"
	dat += "<tr class=\"d0\"><td>Name:</td><td>[candidate.name]</td></tr>"
	dat += "<tr class=\"d1\"><td><a href='byond://?src=[REF(src)];option=name;new=1;candidate=[REF(candidate)]'>\[Edytuj\]</a></td><td>Jak zamierzasz się nazywać. Sugestie: dowolne imię, które wybrałbyś dla postaci na stacji ALBO dla SI.</td></tr>"

	dat += "<tr class=\"d0\"><td>Description:</td><td>[candidate.description]</td></tr>"
	dat += "<tr class=\"d1\"><td><a href='byond://?src=[REF(src)];option=desc;new=1;candidate=[REF(candidate)]'>\[Edytuj\]</a></td><td>Jakiego pAI zwykle odgrywasz; twoje maniery, dziwactwa itp. Może to być tak skąpe albo szczegółowe, jak chcesz.</td></tr>"

	dat += "<tr class=\"d0\"><td>Preferred Role:</td><td>[candidate.role]</td></tr>"
	dat += "<tr class=\"d1\"><td><a href='byond://?src=[REF(src)];option=role;new=1;candidate=[REF(candidate)]'>\[Edytuj\]</a></td><td>Lubisz współpracować z podstępnymi ninja towarzyskimi? Lubisz pomagać ochronie w łapaniu bandziorów? Lubisz pilnować pleców inżyniera, gdy po raz kolejny ratuje stację? Nie musi się to ograniczać do stanowisk na stacji. Sprawdzi się tu niemal każdy ogólny opis tego, czym chciałbyś się zajmować.</td></tr>"

	dat += "<tr class=\"d0\"><td>OOC Comments:</td><td>[candidate.comments]</td></tr>"
	dat += "<tr class=\"d1\"><td><a href='byond://?src=[REF(src)];option=ooc;new=1;candidate=[REF(candidate)]'>\[Edytuj\]</a></td><td>Wszystko, co chcesz przekazać graczowi czytającemu to w sposób OOC. \"Wolę poważniejszy RP.\", \"Wciąż uczę się interfejsu!\" itp. Możesz zostawić to pole puste.</td></tr>"

	dat += "</table>"

	dat += "<br>"
	dat += "<h3><a href='byond://?src=[REF(src)];option=submit;new=1;candidate=[REF(candidate)]'>Submit Personality</a></h3><br>"
	dat += "<a href='byond://?src=[REF(src)];option=save;new=1;candidate=[REF(candidate)]'>Save Personality</a><br>"
	dat += "<a href='byond://?src=[REF(src)];option=load;new=1;candidate=[REF(candidate)]'>Load Personality</a><br>"

	M << browse(dat, "window=paiRecruit")

/datum/controller/subsystem/pai/proc/spam_again()
	ghost_spam = FALSE

/datum/controller/subsystem/pai/proc/check_ready(var/datum/paiCandidate/C)
	if(!C.ready)
		return FALSE
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(O.key == C.key)
			return C
	return FALSE

/datum/controller/subsystem/pai/proc/findPAI(obj/item/paicard/p, mob/user)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, "<span class='warning'>Z powodu rosnącej liczby incydentów z SAMOUSZKODZONYMI niezależnymi sztucznymi inteligencjami urządzenia z dowolną osobowością zostały tymczasowo zakazane w tym sektorze.</span>")
		return
	if(!ghost_spam)
		ghost_spam = TRUE
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(!G.key || !G.client)
				continue
			//NSV13 - Disabled until Beemerge, I don't know what to put here without porting from another PR so WEH
			//if(!(ROLE_PAI in G.client.prefs.be_special))
			//	continue
			//NSV13 - Stop
			to_chat(G, "<span class='ghostalert'>[user] prosi o osobowość pAI! Użyj przycisku pAI, by się zgłosić.</span>")
		addtimer(CALLBACK(src, PROC_REF(spam_again)), spam_delay)
	var/list/available = list()
	for(var/datum/paiCandidate/c in SSpai.candidates)
		available.Add(check_ready(c))
	var/dat = ""

	dat += {"
			<style type="text/css">

			p.top {
				background-color: #AAAAAA; color: black;
			}

			tr.d0 td {
				background-color: #CC9999; color: black;
			}
			tr.d1 td {
				background-color: #9999CC; color: black;
			}
			tr.d2 td {
				background-color: #99CC99; color: black;
			}
			</style>
			"}
	dat += "<p class=\"top\">Requesting AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>"

	dat += "<table>"

	for(var/datum/paiCandidate/c in available)
		dat += "<tr class=\"d0\"><td>Name:</td><td>[c.name]</td></tr>"
		dat += "<tr class=\"d1\"><td>Description:</td><td>[c.description]</td></tr>"
		dat += "<tr class=\"d0\"><td>Preferred Role:</td><td>[c.role]</td></tr>"
		dat += "<tr class=\"d1\"><td>OOC Comments:</td><td>[c.comments]</td></tr>"
		dat += "<tr class=\"d2\"><td><a href='byond://?src=[REF(src)];download=1;candidate=[REF(c)];device=[REF(p)]'>\[Download [c.name]\]</a></td><td></td></tr>"

	dat += "</table>"

	user << browse(dat, "window=findPai")

/datum/paiCandidate
	var/name
	var/key
	var/description
	var/role
	var/comments
	var/ready = 0
