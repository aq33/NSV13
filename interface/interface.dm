//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki(query as text)
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser. Type nothing to go to the main page."
	set hidden = 1
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		if(query)
			var/output = wikiurl + "/Special:Search/" + query
			src << link(output)
		else if (query != null)
			src << link(wikiurl)
	else
		to_chat(src, "<span class='danger'>Adres wiki nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = 1
	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		if(alert("To otworzy forum w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(forumurl)
	else
		to_chat(src, "<span class='danger'>Adres forum nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/rules()
	set name = "rules"
	set desc = "Show Server Rules."
	set hidden = 1
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(alert("To otworzy zasady w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(rulesurl)
	else
		to_chat(src, "<span class='danger'>Adres zasad nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/github()
	set name = "github"
	set desc = "Visit Github"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(alert("To otworzy repozytorium GitHub w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(githuburl)
	else
		to_chat(src, "<span class='danger'>Adres GitHuba nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		var/message = "To otworzy zgłaszanie błędów na GitHubie w twojej przeglądarce. Na pewno?"
		if(GLOB.revdata.testmerge.len)
			message += "<br>Aktywne są następujące eksperymentalne zmiany, które prawdopodobnie odpowiadają za nowe lub nagłe problemy. Jeśli to możliwe, znajdź konkretny wątek dla swojego problemu, zamiast pisać w ogólnym zgłaszaniu błędów:<br>"
			message += GLOB.revdata.GetTestMergeInfo(FALSE)
		// We still use tgalert here because some people were concerned that if someone wanted to report that tgui wasn't working
		// then the report issue button being tgui-based would be problematic.
		if(tgalert(src, message, "Report Issue","Yes","No")!="Yes")
			return
		var/static/issue_template = rustg_file_read(".github/ISSUE_TEMPLATE.md")
		var/servername = CONFIG_GET(string/servername)
		var/url_params = "Reporting client version: [byond_version].[byond_build]\n\n[issue_template]"
		if(GLOB.round_id || servername)
			url_params = "Issue reported from [GLOB.round_id ? " Round ID: [GLOB.round_id][servername ? " ([servername])" : ""]" : servername]\n\n[url_params]"
		var/issue_label = CONFIG_GET(string/issue_label)
		DIRECT_OUTPUT(src, link("[githuburl]/issues/new?body=[rustg_url_encode(url_params)][issue_label ? "&labels=[rustg_url_encode(issue_label)]" : ""]"))
	else
		to_chat(src, "<span class='danger'>Adres GitHuba nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/adminhotkeys = {"<font color='purple'>
Admin:
\tF3 = asay
\tF4 = msay
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel
\tF7 = Buildmode
\tF8 = Invisimin
\tCtrl+F8 = Stealthmin
</font>"}

	mob.hotkey_help()

	if(holder)
		to_chat(src, adminhotkeys)

/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	// AQ EDIT START - port BeeStation #12236: TGUI changelog
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()
	GLOB.changelog_tgui.ui_interact(mob)
	// AQ EDIT END
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")


/mob/proc/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Tryb skrótów: (tryb skrótów musi być włączony)\n\tTAB = przełącz tryb skrótów\n\ta = w lewo\n\ts = w dół\n\td = w prawo\n\tw = w górę\n\tq = upuść\n\te = załóż\n\tr = rzuć\n\tm = emotka\n\tt = powiedz\n\to = OOC\n\tb = stawiaj opór\n\t<B></B>h = przestań ciągnąć\n\tx = zmień rękę\n\tz = użyj trzymanego przedmiotu (lub y)\n\tShift+e = włóż trzymany przedmiot do pasa (lub w miejsce pasa) albo wyjmij ostatnio włożony.\n\tShift+b = włóż trzymany przedmiot do plecaka (lub w miejsce na plecach) albo wyjmij ostatnio włożony.\n\tf = poprzednia intencja\n\tg = następna intencja\n\t1 = intencja pomocy\n\t2 = intencja rozbrojenia\n\t3 = intencja chwytu\n\t4 = intencja krzywdzenia\n\tNumpad = wybór celu na ciele (naciskaj 8, by przełączać głowa->oczy->usta)\n\tAlt (przytrzymaj) = zmień tryb ruchu
</font>"}

	var/other = {"<font color='purple'>
Każdy tryb: (tryb skrótów nie musi być włączony)\n\tCtrl+a = w lewo\n\tCtrl+s = w dół\n\tCtrl+d = w prawo\n\tCtrl+w = w górę\n\tCtrl+q = upuść\n\tCtrl+e = załóż\n\tCtrl+r = rzuć\n\tCtrl+b = stawiaj opór\n\tCtrl+h = przestań ciągnąć\n\tCtrl+o = OOC\n\tCtrl+x = zmień rękę\n\tCtrl+z = użyj trzymanego przedmiotu (lub Ctrl+y)\n\tCtrl+f = poprzednia intencja\n\tCtrl+g = następna intencja\n\tCtrl+1 = intencja pomocy\n\tCtrl+2 = intencja rozbrojenia\n\tCtrl+3 = intencja chwytu\n\tCtrl+4 = intencja krzywdzenia\n\tCtrl+'+/-' LUB\n\tShift+kółko myszy = przybliżanie/oddalanie ducha\n\tDEL = przestań ciągnąć\n\tINS = następna intencja\n\tHOME = upuść\n\tPGUP = zmień rękę\n\tPGDN = użyj trzymanego przedmiotu\n\tEND = rzuć\n\tCtrl+Numpad = wybór celu na ciele (naciskaj 8, by przełączać głowa->oczy->usta)
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

/mob/living/silicon/robot/hotkey_help()
	//h = talk-wheel has a nonsense tag in it because \th is an escape sequence in BYOND.
	var/hotkey_mode = {"<font color='purple'>
Tryb skrótów: (tryb skrótów musi być włączony)\n\tTAB = przełącz tryb skrótów\n\ta = w lewo\n\ts = w dół\n\td = w prawo\n\tw = w górę\n\tq = zdejmij aktywny moduł\n\t<B></B>h = przestań ciągnąć\n\tm = emotka\n\tt = powiedz\n\to = OOC\n\tx = przełączaj aktywne moduły\n\tb = stawiaj opór\n\tz = użyj trzymanego przedmiotu (lub y)\n\tf = poprzednia intencja\n\tg = następna intencja\n\t1 = aktywuj moduł 1\n\t2 = aktywuj moduł 2\n\t3 = aktywuj moduł 3\n\t4 = przełącz intencje
</font>"}

	var/other = {"<font color='purple'>
Każdy tryb: (tryb skrótów nie musi być włączony)\n\tCtrl+a = w lewo\n\tCtrl+s = w dół\n\tCtrl+d = w prawo\n\tCtrl+w = w górę\n\tCtrl+q = zdejmij aktywny moduł\n\tCtrl+x = przełączaj aktywne moduły\n\tCtrl+b = stawiaj opór\n\tCtrl+h = przestań ciągnąć\n\tCtrl+o = OOC\n\tCtrl+z = użyj trzymanego przedmiotu (lub Ctrl+y)\n\tCtrl+f = poprzednia intencja\n\tCtrl+g = następna intencja\n\tCtrl+1 = aktywuj moduł 1\n\tCtrl+2 = aktywuj moduł 2\n\tCtrl+3 = aktywuj moduł 3\n\tCtrl+4 = przełącz intencje\n\tDEL = przestań ciągnąć\n\tINS = przełącz intencje\n\tPGUP = przełączaj aktywne moduły\n\tPGDN = użyj trzymanego przedmiotu
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)




/client/verb/donate()
	set name = "donate"
	set desc = "Donate to the server"
	set hidden = 1
	var/donateurl = CONFIG_GET(string/donateurl)
	if(donateurl)
		if(alert("To otworzy stronę darowizn w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(donateurl)
	else
		to_chat(src, "<span class='danger'>Adres strony darowizn nie jest ustawiony w konfiguracji serwera.</span>")
	return

/client/verb/discord()
	set name = "discord"
	set desc = "Join the Discord"
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(alert("To otworzy zaproszenie na Discorda w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, "<span class='danger'>Zaproszenie na Discorda nie jest ustawione w konfiguracji serwera.</span>")
	return

/client/verb/map()
	set name = "View Webmap"
	set desc = "View the current map in the webviewer"
	set category = "OOC"
	if(SSmapping.config.map_link == "None")
		to_chat(src,"<span class='danger'>Obecna mapa nie ma mapy w przeglądarce. </span>")
	else if(SSmapping.config.map_link)
		if(alert("To otworzy obecną mapę w twojej przeglądarce. Na pewno?",,"Yes","No")!="Yes")
			return
		src << link("https://webmap.affectedarc07.co.uk/maps/aquila/[SSmapping.config.map_link]")
	else
		to_chat(src, "<span class='danger'>Obecna mapa jest nieprawidłowa lub niedostępna. Zgłoś błąd na GitHubie. </span>")

//NSV13 - alias to "map"
/client/verb/nsv13_map()
	set name = "Map"
	set desc = "View the current map in the webviewer"
	set hidden = 1
	map()
