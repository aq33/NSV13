/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
 *		Cachedbook datum
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */



/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/libraryconsole
	desc = "Checked out books MUST be returned on time."
	var/screenstate = 0
	var/title
	var/category = "Any"
	var/author
	var/search_page = 0
	clockwork = TRUE //it'd look weird
	broken_overlay_emissive = TRUE

/obj/machinery/computer/libraryconsole/ui_interact(mob/user)
	. = ..()
	var/list/dat = list() // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			dat += "<h2>Ustawienia wyszukiwania</h2><br>"
			dat += "<A href='byond://?src=[REF(src)];settitle=1'>Filtruj po tytule: [title]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];setcategory=1'>Filtruj po kategorii: [category]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];setauthor=1'>Filtruj po autorze: [author]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];search=1'>\[Start Search\]</A><BR>"
		if(1)
			if (!SSdbcore.Connect())
				dat += "<font color=red><b>BŁĄD</b>: nie można połączyć się z archiwum zewnętrznym. Poproś o pomoc administratora systemu.</font><BR>"
			else if(QDELETED(user))
				return
			else
				dat += "<table>"
				dat += "<tr><td>AUTOR</td><td>TYTUŁ</td><td>KATEGORIA</td><td>SS<sup>13</sup>BN</td></tr>"
				var/SQLsearch = "isnull(deleted) AND "
				if(category == "Any")
					SQLsearch += "author LIKE '%[author]%' AND title LIKE '%[title]%'"
				else
					SQLsearch += "author LIKE '%[author]%' AND title LIKE '%[title]%' AND category='[category]'"
				var/bookcount = 0
				var/booksperpage = 20
				var/datum/DBQuery/query_library_count_books = SSdbcore.NewQuery({"
					SELECT COUNT(id) FROM [format_table_name("library")]
					WHERE isnull(deleted)
						AND author LIKE '%' + :author + '%'
						AND title LIKE '%' + :title + '%'
						AND (:category = 'Any' OR category = :category)
				"}, list("author" = author, "title" = title, "category" = category))
				if(!query_library_count_books.warn_execute())
					qdel(query_library_count_books)
					return
				if(query_library_count_books.NextRow())
					bookcount = text2num(query_library_count_books.item[1])
				qdel(query_library_count_books)
				if(bookcount > booksperpage)
					dat += "<b>Page: </b>"
					var/pagecount = 1
					var/list/pagelist = list()
					while(bookcount > 0)
						pagelist += "<a href='byond://?src=[REF(src)];bookpagecount=[pagecount - 1]'>[pagecount == search_page + 1 ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
						bookcount -= booksperpage
						pagecount++
					dat += pagelist.Join(" | ")
				search_page = text2num(search_page)
				var/datum/DBQuery/query_library_list_books = SSdbcore.NewQuery({"
					SELECT author, title, category, id
					FROM [format_table_name("library")]
					WHERE isnull(deleted)
						AND author LIKE '%' + :author + '%'
						AND title LIKE '%' + :title + '%'
						AND (:category = 'Any' OR category = :category)
					LIMIT :skip, :take
				"}, list("author" = author, "title" = title, "category" = category, "skip" = booksperpage * search_page, "take" = booksperpage))
				if(!query_library_list_books.Execute())
					dat += "<font color=red><b>BŁĄD</b>: nie można pobrać listy książek. Poproś o pomoc administratora systemu.</font><BR>"
				else
					while(query_library_list_books.NextRow())
						var/author = query_library_list_books.item[1]
						var/title = query_library_list_books.item[2]
						var/category = query_library_list_books.item[3]
						var/id = query_library_list_books.item[4]
						dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				qdel(query_library_list_books)
				if(QDELETED(user))
					return
				dat += "</table><BR>"
			dat += "<A href='byond://?src=[REF(src)];back=1'>\[Go Back\]</A><BR>"
	var/datum/browser/popup = new(user, "publiclibrary", name, 600, 400)
	popup.set_content(jointext(dat, ""))
	popup.open()

/obj/machinery/computer/libraryconsole/Topic(href, href_list)
	. = ..()
	if(..())
		usr << browse(null, "window=publiclibrary")
		onclose(usr, "publiclibrary")
		return

	if(href_list["settitle"])
		var/newtitle = capped_input(usr, "Wpisz tytuł do wyszukania:")
		if(newtitle)
			title = sanitize(newtitle)
		else
			title = null
	if(href_list["setcategory"])
		var/newcategory = input("Wybierz kategorię do wyszukania:") in list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			category = sanitize(newcategory)
		else
			category = "Any"
	if(href_list["setauthor"])
		var/newauthor = capped_input(usr, "Wpisz autora do wyszukania:")
		if(newauthor)
			author = sanitize(newauthor)
		else
			author = null
	if(href_list["search"])
		screenstate = 1

	if(href_list["bookpagecount"])
		search_page = text2num(href_list["bookpagecount"])

	if(href_list["back"])
		screenstate = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

/*
 * Cachedbook datum
 */
/datum/cachedbook // Datum used to cache the SQL DB books locally in order to achieve a performance gain.
	var/id
	var/title
	var/author
	var/category

GLOBAL_LIST(cachedbooks) // List of our cached book datums


/proc/load_library_db_to_cache()
	if(GLOB.cachedbooks)
		return
	if(!SSdbcore.Connect())
		return
	GLOB.cachedbooks = list()
	var/datum/DBQuery/query_library_cache = SSdbcore.NewQuery("SELECT id, author, title, category FROM [format_table_name("library")] WHERE isnull(deleted)")
	if(!query_library_cache.Execute())
		qdel(query_library_cache)
		return
	while(query_library_cache.NextRow())
		var/datum/cachedbook/newbook = new()
		newbook.id = query_library_cache.item[1]
		newbook.author = query_library_cache.item[2]
		newbook.title = query_library_cache.item[3]
		newbook.category = query_library_cache.item[4]
		GLOB.cachedbooks += newbook
	qdel(query_library_cache)



#define PRINTER_COOLDOWN 60

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "book inventory management console"
	desc = "Librarian's command station."
	screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	verb_say = "pika"
	verb_ask = "pika"
	verb_exclaim = "pika"
	pass_flags = PASSTABLE
	var/arcanecheckout = 0
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive
	var/list/libcomp_menu
	var/page = 1	//current page of the external archives
	var/cooldown = 0

/obj/machinery/computer/libraryconsole/bookmanagement/proc/build_library_menu()
	if(libcomp_menu)
		return
	load_library_db_to_cache()
	if(!GLOB.cachedbooks)
		return
	libcomp_menu = list("")

	for(var/i in 1 to GLOB.cachedbooks.len)
		var/datum/cachedbook/C = GLOB.cachedbooks[i]
		var/page = round(i/250)+1
		if (libcomp_menu.len < page)
			libcomp_menu.len = page
			libcomp_menu[page] = ""
		libcomp_menu[page] += "<tr><td>[C.author]</td><td>[C.title]</td><td>[C.category]</td><td><A href='byond://?src=[REF(src)];targetid=[C.id]'>\[Order\]</A></td></tr>\n"

/obj/machinery/computer/libraryconsole/bookmanagement/Initialize(mapload)
	. = ..()
	if(circuit)
		circuit.name = "Book Inventory Management Console (Machine Board)"
		circuit.build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/obj/machinery/computer/libraryconsole/bookmanagement/ui_interact(mob/user)
	. = ..()
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	switch(screenstate)
		if(0)
			// Main Menu
			dat += "<A href='byond://?src=[REF(src)];switchscreen=1'>1. Przeglądaj katalog ogólny</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=2'>2. Przeglądaj wypożyczone książki</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=3'>3. Wypożycz książkę</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=4'>4. Połącz z archiwum zewnętrznym</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=5'>5. Wgraj nowy tytuł do archiwum</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=6'>6. Wgraj zeskanowany tytuł do serwisu informacyjnego</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=7'>7. Drukuj materiały firmowe</A><BR>"
			if(obj_flags & EMAGGED)
				dat += "<A href='byond://?src=[REF(src)];switchscreen=8'>8. Wejdź do Skarbca Zakazanej Wiedzy</A><BR>"
			if(src.arcanecheckout)
				print_forbidden_lore(user)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<H3>Inventory</H3><BR>"
			for(var/obj/item/book/b in inventory)
				dat += "[b.name] <A href='byond://?src=[REF(src)];delbook=[REF(b)]'>(Delete)</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(2)
			// Checked Out
			dat += "<h3>Wypożyczone książki</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)
				dat += "\"[b.bookname]\", wypożyczona przez: [b.mobname]<BR>--- Wypożyczono: [timetaken] min temu, zwrot: za [timedue] min<BR>"
				dat += "<A href='byond://?src=[REF(src)];checkin=[REF(b)]'>(Zwróć)</A><BR><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(3)
			// Check Out a Book
			dat += "<h3>Wypożycz książkę</h3><BR>"
			dat += "Book: [src.buffer_book] "
			dat += "<A href='byond://?src=[REF(src)];editbook=1'>\[Edit\]</A><BR>"
			dat += "Recipient: [src.buffer_mob] "
			dat += "<A href='byond://?src=[REF(src)];editmob=1'>\[Edit\]</A><BR>"
			dat += "Data wypożyczenia: [world.time/600]<BR>"
			dat += "Termin zwrotu: [(world.time + checkoutperiod)/600]<BR>"
			dat += "(Okres wypożyczenia: [checkoutperiod] min) (<A href='byond://?src=[REF(src)];increasetime=1'>+</A>/<A href='byond://?src=[REF(src)];decreasetime=1'>-</A>)"
			dat += "<A href='byond://?src=[REF(src)];checkout=1'>(Zatwierdź wpis)</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(4)
			dat += "<h3>Archiwum zewnętrzne</h3>"
			build_library_menu()

			if(!GLOB.cachedbooks)
				dat += "<font color=red><b>BŁĄD</b>: nie można połączyć się z archiwum zewnętrznym. Poproś o pomoc administratora systemu.</font>"
			else
				dat += "<A href='byond://?src=[REF(src)];orderbyid=1'>(Sortuj książki według SS<sup>13</sup>BN)</A><BR><BR>"
				dat += "<table>"
				dat += "<tr><td>AUTOR</td><td>TYTUŁ</td><td>KATEGORIA</td><td></td></tr>"
				dat += libcomp_menu[CLAMP(page,1,libcomp_menu.len)]
				dat += "<tr><td><A href='byond://?src=[REF(src)];page=[(max(1,page-1))]'>&lt;&lt;&lt;&lt;</A></td> <td></td> <td></td> <td><span style='text-align:right'><A href='byond://?src=[REF(src)];page=[(min(libcomp_menu.len,page+1))]'>&gt;&gt;&gt;&gt;</A></span></td></tr>"
				dat += "</table>"
			dat += "<BR><A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(5)
			dat += "<H3>Wgraj nowy tytuł</H3>"
			if(!scanner)
				scanner = findscanner(9)
			if(!scanner)
				dat += "<FONT color=red>W zasięgu sieci bezprzewodowej nie znaleziono skanera.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>W pamięci skanera nie znaleziono danych.</FONT><BR>"
			else
				dat += "<TT>Dane oznaczone do wgrania...</TT><BR>"
				dat += "<TT>Title: </TT>[scanner.cache.name]<BR>"
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"
				dat += "<TT>Author: </TT><A href='byond://?src=[REF(src)];setauthor=1'>[scanner.cache.author]</A><BR>"
				dat += "<TT>Category: </TT><A href='byond://?src=[REF(src)];setcategory=1'>[upload_category]</A><BR>"
				dat += "<A href='byond://?src=[REF(src)];upload=1'>\[Upload\]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(6)
			dat += "<h3>Opublikuj tytuł w serwisie informacyjnym</h3>"
			if(!scanner)
				scanner = findscanner(9)
			if(!scanner)
				dat += "<FONT color=red>W zasięgu sieci bezprzewodowej nie znaleziono skanera.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>W pamięci skanera nie znaleziono danych.</FONT><BR>"
			else
				dat += "<TT>Opublikować [scanner.cache.name] w stacyjnych serwisach informacyjnych?</TT>"
				dat += "<A href='byond://?src=[REF(src)];newspost=1'>\[Post\]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(7)
			dat += "<h3>Uniwersalny moduł drukujący NTGanda(tm)</h3>"
			dat += "Co chcesz wydrukować?<BR>"
			dat += "<A href='byond://?src=[REF(src)];printbible=1'>\[Bible\]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];printspacelaw=1'>\[Space Law\]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];printposter=1'>\[Poster\]</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>(Powrót do menu głównego)</A><BR>"
		if(8)
			dat += "<h3>Dostęp do Skarbca Zakazanej Wiedzy v 1.3</h3>"
			dat += "Czy na pewno chcesz kontynuować? EldritchRelics Inc. nie ponosi odpowiedzialności za utratę zdrowia psychicznego wynikłą z tego działania.<p>"
			dat += "<A href='byond://?src=[REF(src)];arccheckout=1'>Tak.</A><BR>"
			dat += "<A href='byond://?src=[REF(src)];switchscreen=0'>No.</A><BR>"

	var/datum/browser/popup = new(user, "library", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/libraryconsole/bookmanagement/proc/findscanner(viewrange)
	return locate(/obj/machinery/libraryscanner) in range(viewrange, get_turf(src))

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_forbidden_lore(mob/user)
	switch(rand(1,3))
		if(1)
			new /obj/item/melee/cultblade/dagger(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest złowieszczy sztylet leżący na biurku. Nawet nie pamiętasz, skąd się wziął...</span>")
		if(2)
			new /obj/item/clockwork/clockwork_slab(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest dziwna metalowa tabliczka leżąca na biurku. Nawet nie pamiętasz, skąd się wzięła...</span>")
		if(3)
			new /obj/item/codex_cicatrix(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest złowróżbna księga skuta łańcuchem, leżąca na biurku. Nawet nie pamiętasz, skąd się wzięła...</span>")
	user.visible_message("[user] przez kilka chwil wpatruje się w pusty ekran z twarzą zastygłą w strachu. Gdy w końcu się z tego budzi, wygląda na znacznie starszego.", 2)

/obj/machinery/computer/libraryconsole/bookmanagement/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = W
		scanner.computer = src
		to_chat(user, "Powiązaną maszyną [scanner] jest teraz [src].")
		audible_message("[src] wydaje niski, krótki pisk.")
	else
		return ..()

/obj/machinery/computer/libraryconsole/bookmanagement/emag_act(mob/user)
	if(density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED

/obj/machinery/computer/libraryconsole/bookmanagement/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=library")
		onclose(usr, "library")
		return
	if(href_list["page"] && screenstate == 4)
		page = text2num(href_list["page"])
	if(href_list["switchscreen"])
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				screenstate = 6
			if("7")
				screenstate = 7
			if("8")
				screenstate = 8
	if(href_list["arccheckout"])
		if(obj_flags & EMAGGED)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = stripped_input(usr, "Wpisz tytuł książki:")
	if(href_list["editmob"])
		buffer_mob = stripped_input(usr, "Wpisz imię odbiorcy:", max_length=MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = sanitize(buffer_book)
		b.mobname = sanitize(buffer_mob)
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"]) in checkouts
		if(b && istype(b))
			checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/book/b = locate(href_list["delbook"]) in inventory
		if(b && istype(b))
			inventory.Remove(b)
	if(href_list["setauthor"])
		var/newauthor = stripped_input(usr, "Wpisz imię autora: ")
		if(newauthor)
			if(length(newauthor) <= 45)
				scanner.cache.author = newauthor
			else
				alert("Nie można ustawić autora. Pole musi mieć mniej niż 45 znaków.")
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion","Technical")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Czy na pewno chcesz wgrać ten tytuł do archiwum?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if (!SSdbcore.Connect())
						alert("Połączenie z archiwum zostało zerwane. Przerywanie.")
					else if((length(scanner.cache.name) > 45) || (length(scanner.cache.author) > 45))
						alert("Pola tytułu i autora mogą mieć najwyżej po 45 znaków. Sprawdź wpis i spróbuj ponownie.")
						return
					else
						var/msg = "[key_name(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs"
						var/datum/DBQuery/query_library_upload = SSdbcore.NewQuery({"
							INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
							VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
						"}, list("title" = scanner.cache.name, "author" = scanner.cache.author, "content" = scanner.cache.dat, "category" = upload_category, "ckey" = usr.ckey, "round_id" = GLOB.round_id))
						if(!query_library_upload.Execute())
							qdel(query_library_upload)
							alert("Napotkano błąd bazy danych podczas wgrywania do archiwum")
							return
						else
							log_game(msg)
							qdel(query_library_upload)
							alert("Wgrywanie zakończone. Wgrany tytuł będzie przez krótki czas niedostępny do druku")
	if(href_list["newspost"])
		if(!GLOB.news_network)
			alert("Nie znaleziono na stacji sieci informacyjnej. Przerywanie.")
		var/channelexists = 0
		for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
			if(FC.channel_name == "Nanotrasen Book Club")
				channelexists = 1
				break
		if(!channelexists)
			GLOB.news_network.create_feed_channel("Nanotrasen Book Club", "Library", null)
		GLOB.news_network.submit_article(scanner.cache.dat, "[scanner.cache.name]", "Nanotrasen Book Club", null)
		alert("Wgrywanie zakończone. Twój tytuł jest teraz dostępny w stacyjnych serwisach informacyjnych.")
	if(href_list["orderbyid"])
		if(cooldown > world.time)
			say("Drukarka niedostępna. Odczekaj chwilę przed ponowną próbą druku.")
		else
			var/orderid = input("Wpisz swoje zamówienie:") as num|null
			if(orderid)
				if(isnum_safe(orderid) && ISINTEGER(orderid))
					href_list["targetid"] = num2text(orderid)

	if(href_list["targetid"])
		var/id = href_list["targetid"]
		if (!SSdbcore.Connect())
			alert("Połączenie z archiwum zostało zerwane. Przerywanie.")
		if(cooldown > world.time)
			say("Drukarka niedostępna. Odczekaj chwilę przed ponowną próbą druku.")
		else
			cooldown = world.time + PRINTER_COOLDOWN
			var/datum/DBQuery/query_library_print = SSdbcore.NewQuery(
				"SELECT * FROM [format_table_name("library")] WHERE id=:id AND isnull(deleted)",
				list("id" = id)
			)
			if(!query_library_print.Execute())
				qdel(query_library_print)
				say("BŁĄD DRUKARKI! Nie udało się wydrukować dokumentu (0x0000000F)")
				return
			while(query_library_print.NextRow())
				var/author = query_library_print.item[2]
				var/title = query_library_print.item[3]
				var/content = query_library_print.item[4]
				if(!QDELETED(src))
					var/obj/item/book/B = new(get_turf(src))
					B.name = "Book: [title]"
					B.title = title
					B.author = author
					B.dat = content
					B.icon_state = "book[rand(1,8)]"
					visible_message("Drukarka [src] buczy, wytwarzając całkowicie oprawioną książkę. Jak ona to zrobiła?")
				break
			qdel(query_library_print)
	if(href_list["printbible"])
		if(cooldown < world.time)
			var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible(src.loc)
			if(GLOB.bible_icon_state && GLOB.bible_item_state)
				B.icon_state = GLOB.bible_icon_state
				B.item_state = GLOB.bible_item_state
				B.name = GLOB.bible_name
				B.deity_name = GLOB.deity
			cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Drukarka jest obecnie niedostępna, poczekaj chwilę.")
	if(href_list["printspacelaw"])
		if(cooldown < world.time)
			new /obj/item/book/manual/wiki/security_space_law(src.loc)
			cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Drukarka jest obecnie niedostępna, poczekaj chwilę.")
	if(href_list["printposter"])
		if(cooldown < world.time)
			new /obj/item/poster/random_official(src.loc)
			cooldown = world.time + PRINTER_COOLDOWN
		else
			say("Drukarka jest obecnie niedostępna, poczekaj chwilę.")
	add_fingerprint(usr)
	updateUsrDialog()

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	desc = "It servers the purpose of scanning stuff."
	density = TRUE
	var/obj/item/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
	else
		return ..()

/obj/machinery/libraryscanner/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	var/dat = "" // <META HTTP-EQUIV='Refresh' CONTENT='10'>
	if(cache)
		dat += "<FONT color=#005500>Dane zapisane w pamięci.</FONT><BR>"
	else
		dat += "Brak danych w pamięci.<BR>"
	dat += "<A href='byond://?src=[REF(src)];scan=1'>\[Scan\]</A>"
	if(cache)
		dat += "       <A href='byond://?src=[REF(src)];clear=1'>\[Clear Memory\]</A><BR><BR><A href='byond://?src=[REF(src)];eject=1'>\[Remove Book\]</A>"
	else
		dat += "<BR>"
	var/datum/browser/popup = new(user, "scanner", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=scanner")
		onclose(usr, "scanner")
		return

	if(href_list["scan"])
		for(var/obj/item/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/book/B in contents)
			B.forceMove(drop_location())
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	desc = "Only intended for binding paper products."
	density = TRUE
	var/busy = FALSE

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/paper))
		bind_book(user, O)
	else if(default_unfasten_wrench(user, O))
		return 1
	else
		return ..()

/obj/machinery/bookbinder/proc/bind_book(mob/user, obj/item/paper/P)
	if(machine_stat)
		return
	if(busy)
		to_chat(user, "<span class='warning'>Introligatornia jest zajęta. Poczekaj na zakończenie poprzedniej operacji.</span>")
		return
	if(!user.transferItemToLoc(P, src))
		return
	user.visible_message("[user] ładuje trochę papieru do [src].", "Ładujesz trochę papieru do [src].")
	audible_message("[src] zaczyna buczeć, rozgrzewając bębny drukujące.")
	busy = TRUE
	sleep(rand(200,400))
	busy = FALSE
	if(P)
		if(!machine_stat)
			visible_message("[src] furczy, drukując i oprawiając nową książkę.")
			var/obj/item/book/B = new(src.loc)
			var/raw_content = ""
			for(var/datum/paper_input/text_input as anything in P.raw_text_inputs)
				raw_content += sanitize(text_input.raw_text)

			B.dat = trim(raw_content, MAX_PAPER_LENGTH)
			B.name = "Print Job #" + "[rand(100, 999)]"
			B.icon_state = "book[rand(1,7)]"
			qdel(P)
		else
			P.forceMove(drop_location())
