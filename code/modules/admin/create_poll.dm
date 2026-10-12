/client/proc/create_poll()
	set name = "Create Poll"
	set category = "Adminbus"
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	var/polltype = input("Choose poll type.","Poll Type") as null|anything in list("Single Option","Text Reply","Rating","Multiple Choice", "Instant Runoff Voting")
	var/choice_amount = 0
	switch(polltype)
		if("Single Option")
			polltype = POLLTYPE_OPTION
		if("Text Reply")
			polltype = POLLTYPE_TEXT
		if("Rating")
			polltype = POLLTYPE_RATING
		if("Multiple Choice")
			polltype = POLLTYPE_MULTI
			choice_amount = input("Ile wyborów ma być dozwolonych?","Select choice amount") as num|null
			switch(choice_amount)
				if(0)
					to_chat(src, "Ankieta wielokrotnego wyboru musi pozwalać na co najmniej jeden wybór.")
					return
				if(1)
					polltype = POLLTYPE_OPTION
				if(null)
					return
		if ("Instant Runoff Voting")
			polltype = POLLTYPE_IRV
		else
			return 0
	var/starttime = SQLtime()
	var/endtime = capped_input(usr, "Ustaw czas zakończenia ankiety w formacie RRRR-MM-DD GG:MM:SS. Wszystkie czasy według czasu serwera. GG:MM:SS jest opcjonalne, zapis 24-godzinny. Musi być późniejszy niż czas rozpoczęcia, z oczywistych powodów.", "Set end time", SQLtime())
	if(!endtime)
		return
	var/datum/DBQuery/query_validate_time = SSdbcore.NewQuery("SELECT IF(STR_TO_DATE('[endtime]','%Y-%c-%d %T') > NOW(), STR_TO_DATE('[endtime]','%Y-%c-%d %T'), 0)")
	if(!query_validate_time.warn_execute() || QDELETED(usr) || !src)
		qdel(query_validate_time)
		return
	if(query_validate_time.NextRow())
		var/checktime = text2num(query_validate_time.item[1])
		if(!checktime)
			to_chat(src, "Wprowadzona data jest źle sformatowana lub nie jest późniejsza niż obecny czas serwera.")
			qdel(query_validate_time)
			return
		endtime = query_validate_time.item[1]
	qdel(query_validate_time)
	var/adminonly
	switch(alert("Admin only poll?",,"Yes","No","Cancel"))
		if("Yes")
			adminonly = 1
		if("No")
			adminonly = 0
		else
			return
	var/dontshow
	switch(alert("Ukryć wyniki ankiety przed śledzeniem do jej zakończenia?",,"Yes","No","Cancel"))
		if("Yes")
			dontshow = 1
		if("No")
			dontshow = 0
		else
			return
	var/sql_ckey = sanitizeSQL(ckey)
	var/question = capped_multiline_input(usr, "Wpisz swoje pytanie","Question")
	if(!question)
		return
	var/list/sql_option_list = list()
	if(polltype != POLLTYPE_TEXT)
		var/add_option = 1
		while(add_option)
			var/option = capped_multiline_input(usr, "Wpisz swoją opcję","Option")
			if(!option)
				return
			var/default_percentage_calc = 0
			if(polltype != POLLTYPE_IRV)
				switch(alert("Czy ta opcja ma być domyślnie uwzględniana przy wyliczaniu procentów wyników ankiety?",,"Yes","No","Cancel"))
					if("Yes")
						default_percentage_calc = 1
					if("No")
						default_percentage_calc = 0
					else
						return
			var/minval = 0
			var/maxval = 0
			var/descmin = ""
			var/descmid = ""
			var/descmax = ""
			if(polltype == POLLTYPE_RATING)
				minval = input("Set minimum rating value.","Minimum rating") as num|null
				if(minval == null)
					return
				maxval = input("Set maximum rating value.","Maximum rating") as num|null
				if(minval >= maxval)
					to_chat(src, "Maksymalna wartość oceny nie może być mniejsza ani równa minimalnej")
					continue
				else if(maxval == null)
					return
				descmin = capped_multiline_input(src, "Opcjonalnie: ustaw opis minimalnej oceny","Minimum rating description")
				if(descmin == null)
					return
				descmid = capped_multiline_input(src, "Opcjonalnie: ustaw opis środkowej oceny","Median rating description")
				if(descmid == null)
					return
				descmax = capped_multiline_input(src, "Opcjonalnie: ustaw opis maksymalnej oceny","Maximum rating description")
				if(descmax == null)
					return
			sql_option_list += list(list("text" = "'[option]'", "minval" = "'[minval]'", "maxval" = "'[maxval]'", "descmin" = "'[descmin]'", "descmid" = "'[descmid]'", "descmax" = "'[descmax]'", "default_percentage_calc" = "'[default_percentage_calc]'"))
			switch(alert(" ",,"Add option","Finish", "Cancel"))
				if("Add option")
					add_option = 1
				if("Finish")
					add_option = 0
				else
					return 0

	var/minimum_player_playtime = input("Minimalny czas gry, by głosować (w godzinach)","Minimum playtime") as num|null
	if (minimum_player_playtime == null)
		minimum_player_playtime = 0
	minimum_player_playtime = min(minimum_player_playtime, 100) //max 100 hours

	var/m1 = "[key_name(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"] - Question: [question]"
	var/m2 = "[key_name_admin(usr)] has created a new server poll. Poll type: [polltype] - Admin Only: [adminonly ? "Yes" : "No"]<br>Question: [question]"
	var/datum/DBQuery/query_polladd_question = SSdbcore.NewQuery("INSERT INTO [format_table_name("poll_question")] (polltype, starttime, endtime, question, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip, dontshow, minimumplaytime) VALUES ('[polltype]', '[starttime]', '[endtime]', '[question]', '[adminonly]', '[choice_amount]', '[sql_ckey]', INET_ATON('[address]'), '[dontshow]', '[minimum_player_playtime]')")
	if(!query_polladd_question.warn_execute())
		qdel(query_polladd_question)
		return
	qdel(query_polladd_question)
	if(polltype != POLLTYPE_TEXT)
		var/pollid = 0
		var/datum/DBQuery/query_get_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
		if(!query_get_id.warn_execute())
			qdel(query_get_id)
			return
		if(query_get_id.NextRow())
			pollid = query_get_id.item[1]
		qdel(query_get_id)
		for(var/list/i in sql_option_list)
			i |= list("pollid" = "'[pollid]'")
		SSdbcore.MassInsert(format_table_name("poll_option"), sql_option_list, warn = 1)
	log_admin(m1)
	message_admins(m2)
