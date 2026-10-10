/**
  * Returns the HTML for the status UI for this song datum.
  */
/datum/song/proc/instrument_status_ui()
	. = list()
	. += "<div class='statusDisplay'>"
	. += "<b><a href='byond://?src=[REF(src)];switchinstrument=1'>Obecny instrument</a>:</b> "
	if(!using_instrument)
		. += "<span class='danger'>Nie załadowano instrumentu!</span><br>"
	else
		. += "[using_instrument.name]<br>"
	. += "Ustawienia odtwarzania:<br>"
	if(can_noteshift)
		. += "<a href='byond://?src=[REF(src)];setnoteshift=1'>Przesunięcie/transpozycja nut</a>: [note_shift] klawiszy / [round(note_shift / 12, 0.01)] oktaw<br>"
	var/smt
	var/modetext = ""
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			smt = "Linear"
			modetext = "<a href='byond://?src=[REF(src)];setlinearfalloff=1'>Czas liniowego podtrzymania</a>: [sustain_linear_duration / 10] s<br>"
		if(SUSTAIN_EXPONENTIAL)
			smt = "Exponential"
			modetext = "<a href='byond://?src=[REF(src)];setexpfalloff=1'>Współczynnik wykładniczego zaniku</a>: [sustain_exponential_dropoff]% na decysekundę<br>"
	. += "<a href='byond://?src=[REF(src)];setsustainmode=1'>Tryb podtrzymania</a>: [smt]<br>"
	. += modetext
	. += using_instrument?.ready()? "Stan: <span class='good'>Gotowy</span><br>" : "Stan: <span class='bad'>!Błąd definicji instrumentu!</span><br>"
	. += "Typ instrumentu: [legacy? "dawny" : "syntetyzowany"]<br>"
	. += "<a href='byond://?src=[REF(src)];setvolume=1'>Volume</a>: [volume]<br>"
	. += "<a href='byond://?src=[REF(src)];setdropoffvolume=1'>Próg zaniku głośności</a>: [sustain_dropoff_volume]<br>"
	. += "<a href='byond://?src=[REF(src)];togglesustainhold=1'>Podtrzymuj bez końca ostatnią przytrzymaną nutę</a>: [full_sustain_held_note? "włączone" : "wyłączone"].<br>"
	. += "</div>"

/datum/song/ui_interact(mob/user)
	var/list/dat = list()

	dat += instrument_status_ui()

	if(lines.len > 0)
		dat += "<H3>Playback</H3>"
		if(!playing)
			dat += "<A href='byond://?src=[REF(src)];play=1'>Graj</A> <SPAN CLASS='linkOn'>Stop</SPAN><BR><BR>"
			dat += "Powtarzaj utwór: "
			dat += repeat > 0 ? "<A href='byond://?src=[REF(src)];repeat=-10'>-</A><A href='byond://?src=[REF(src)];repeat=-1'>-</A>" : "<SPAN CLASS='linkOff'>-</SPAN><SPAN CLASS='linkOff'>-</SPAN>"
			dat += " [repeat] times "
			dat += repeat < max_repeats ? "<A href='byond://?src=[REF(src)];repeat=1'>+</A><A href='byond://?src=[REF(src)];repeat=10'>+</A>" : "<SPAN CLASS='linkOff'>+</SPAN><SPAN CLASS='linkOff'>+</SPAN>"
			dat += "<BR>"
		else
			dat += "<SPAN CLASS='linkOn'>Graj</SPAN> <A href='byond://?src=[REF(src)];stop=1'>Stop</A><BR>"
			dat += "Pozostałe powtórzenia: <B>[repeat]</B><BR>"
	if(!editing)
		dat += "<BR><B><A href='byond://?src=[REF(src)];edit=2'>Pokaż edytor</A></B><BR>"
	else
		dat += "<H3>Editing</H3>"
		dat += "<B><A href='byond://?src=[REF(src)];edit=1'>Ukryj edytor</A></B>"
		dat += " <A href='byond://?src=[REF(src)];newsong=1'>Zacznij nowy utwór</A>"
		dat += " <A href='byond://?src=[REF(src)];import=1'>Import a Song</A><BR><BR>"
		var/bpm = round(600 / tempo)
		dat += "Tempo: <A href='byond://?src=[REF(src)];tempo=[world.tick_lag]'>-</A> [bpm] BPM <A href='byond://?src=[REF(src)];tempo=-[world.tick_lag]'>+</A><BR><BR>"
		var/linecount = 0
		for(var/line in lines)
			linecount += 1
			dat += "Linia [linecount]: <A href='byond://?src=[REF(src)];modifyline=[linecount]'>Edytuj</A> <A href='byond://?src=[REF(src)];deleteline=[linecount]'>X</A> [line]<BR>"
		dat += "<A href='byond://?src=[REF(src)];newline=1'>Dodaj linię</A><BR><BR>"
		if(help)
			dat += "<B><A href='byond://?src=[REF(src)];help=1'>Ukryj pomoc</A></B><BR>"
			dat += {"
					Linie to ciągi akordów oddzielonych przecinkami (,), a nuty w akordzie oddziela się łącznikami (-).<br>Wszystkie nuty w akordzie zagrają razem, a czas akordu wyznacza tempo.<br><br>Nuty zapisuje się nazwą nuty i opcjonalnie znakiem chromatycznym i/lub numerem oktawy.<br>Domyślnie każda nuta jest naturalna i w oktawie 3. Zmienione ustawienie jest zapamiętywane dla każdej nuty.<br>Przykład: <i>C,D,E,F,G,A,B</i> zagra gamę C-dur.<br>Gdy nuta dostanie znak chromatyczny, zostanie on zapamiętany: <i>C,C4,C,C3</i> to <i>C3,C4,C4,C3</i><br>Akordy można grać, po prostu oddzielając nuty łącznikiem: <i>A-C#,Cn-E,E-G#,Gn-B</i><br>Pauzę oznacza pusty akord: <i>C,E,,C,G</i><br>Aby akord trwał inaczej, zakończ go /x, a długość akordu wyniesie<br>tempo / x: <i>C,G/2,E/4</i><br>Łącznie przykład wygląda tak: <i>E-E4/4,F#/2,G#/8,B/8,E3-E4/4</i><br>Linie mogą mieć do [MUSIC_MAXLINECHARS] znaków.<br>Utwór może mieć najwyżej [MUSIC_MAXLINES] linii.<br>
					"}
		else
			dat += "<B><A href='byond://?src=[REF(src)];help=2'>Pokaż pomoc</A></B><BR>"

	var/datum/browser/popup = new(user, "instrument", parent?.name || "instrument", 700, 500)
	popup.set_content(dat.Join(""))
	popup.open()

/**
  * Parses a song the user has input into lines and stores them.
  */
/datum/song/proc/ParseSong(text)
	set waitfor = FALSE
	//split into lines
	lines = splittext(text, "\n")
	if(lines.len)
		var/bpm_string = "BPM: "
		if(findtext(lines[1], bpm_string, 1, length(bpm_string) + 1))
			var/divisor = text2num(copytext(lines[1], length(bpm_string) + 1)) || 120 // default
			tempo = sanitize_tempo(600 / round(divisor, 1))
			lines.Cut(1, 2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(lines.len > MUSIC_MAXLINES)
			to_chat(usr, "Za dużo linii!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				to_chat(usr, "Linia [linenum] jest za długa!")
				lines.Remove(l)
			else
				linenum++
		updateDialog(usr)		// make sure updates when complete

/datum/song/Topic(href, href_list)
	if(!usr.canUseTopic(parent, TRUE, FALSE, FALSE, FALSE))
		usr << browse(null, "window=instrument")
		usr.unset_machine()
		return

	parent.add_fingerprint(usr)

	if(href_list["newsong"])
		lines = new()
		tempo = sanitize_tempo(5) // default 120 BPM
		name = ""

	else if(href_list["import"])
		var/t = ""
		do
			t = html_encode(input(usr, "Wklej cały utwór w formacie:", text("[]", name), t)  as message)
			if(!in_range(parent, usr))
				return

			if(length_char(t) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
				var/cont = input(usr, "Twoja wiadomość jest za długa! Czy chcesz kontynuować edycję?", "", "yes") in list("yes", "no")
				if(cont == "no")
					break
		while(length_char(t) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
		ParseSong(t)

	else if(href_list["help"])
		help = text2num(href_list["help"]) - 1

	else if(href_list["edit"])
		editing = text2num(href_list["edit"]) - 1

	if(href_list["repeat"]) //Changing this from a toggle to a number of repeats to avoid infinite loops.
		if(playing)
			return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
		repeat += round(text2num(href_list["repeat"]))
		if(repeat < 0)
			repeat = 0
		if(repeat > max_repeats)
			repeat = max_repeats

	else if(href_list["tempo"])
		tempo = sanitize_tempo(tempo + text2num(href_list["tempo"]))

	else if(href_list["play"])
		INVOKE_ASYNC(src, PROC_REF(start_playing), usr)

	else if(href_list["newline"])
		var/newline = html_encode(input("Wpisz swoją linię: ", parent.name) as text|null)
		if(!newline || !in_range(parent, usr))
			return
		if(lines.len > MUSIC_MAXLINES)
			return
		if(length(newline) > MUSIC_MAXLINECHARS)
			newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
		lines.Add(newline)

	else if(href_list["deleteline"])
		var/num = round(text2num(href_list["deleteline"]))
		if(num > lines.len || num < 1)
			return
		lines.Cut(num, num+1)

	else if(href_list["modifyline"])
		var/num = round(text2num(href_list["modifyline"]),1)
		var/content = stripped_input(usr, "Wpisz swoją linię: ", parent.name, lines[num], MUSIC_MAXLINECHARS)
		if(!content || !in_range(parent, usr))
			return
		if(num > lines.len || num < 1)
			return
		lines[num] = content

	else if(href_list["stop"])
		stop_playing()

	else if(href_list["setlinearfalloff"])
		var/amount = input(usr, "Ustaw czas liniowego podtrzymania w sekundach", "Czas liniowego podtrzymania") as null|num
		if(!isnull(amount))
			set_linear_falloff_duration(round(amount * 10, world.tick_lag))

	else if(href_list["setexpfalloff"])
		var/amount = input(usr, "Ustaw współczynnik wykładniczego podtrzymania", "Współczynnik wykładniczego podtrzymania") as null|num
		if(!isnull(amount))
			set_exponential_drop_rate(round(amount, 0.00001))

	else if(href_list["setvolume"])
		var/amount = input(usr, "Ustaw głośność", "Volume") as null|num
		if(!isnull(amount))
			set_volume(round(amount, 1))

	else if(href_list["setdropoffvolume"])
		var/amount = input(usr, "Ustaw próg zaniku", "Głośność progu zaniku") as null|num
		if(!isnull(amount))
			set_dropoff_volume(round(amount, 0.01))

	else if(href_list["switchinstrument"])
		if(!length(allowed_instrument_ids))
			return
		else if(length(allowed_instrument_ids) == 1)
			set_instrument(allowed_instrument_ids[1])
			return
		var/list/categories = list()
		for(var/i in allowed_instrument_ids)
			var/datum/instrument/I = SSinstruments.get_instrument(i)
			if(I)
				LAZYSET(categories[I.category || "ERROR CATEGORY"], I.name, I.id)
		var/cat = input(usr, "Wybierz kategorię", "Kategoria instrumentu") as null|anything in categories
		if(!cat)
			return
		var/list/instruments = categories[cat]
		var/choice = input(usr, "Wybierz instrument", "Wybór instrumentu") as null|anything in instruments
		if(!choice)
			return
		choice = instruments[choice]		//get id
		if(choice)
			set_instrument(choice)

	else if(href_list["setnoteshift"])
		var/amount = input(usr, "Ustaw przesunięcie nut", "Przesunięcie nut") as null|num
		if(!isnull(amount))
			note_shift = clamp(amount, note_shift_min, note_shift_max)

	else if(href_list["setsustainmode"])
		var/choice = input(usr, "Wybierz tryb podtrzymania", "Tryb podtrzymania") as null|anything in list("Linear", "Exponential")
		switch(choice)
			if("Linear")
				sustain_mode = SUSTAIN_LINEAR
			if("Exponential")
				sustain_mode = SUSTAIN_EXPONENTIAL

	else if(href_list["togglesustainhold"])
		full_sustain_held_note = !full_sustain_held_note

	updateDialog()
