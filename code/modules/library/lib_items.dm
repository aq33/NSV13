/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */

/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookempty"
	desc = "A great place for storing knowledge."
	anchored = FALSE
	density = TRUE
	opacity = 0
	resistance_flags = FLAMMABLE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0, "stamina" = 0, "bleed" = 0)
	var/state = 0
	var/list/allowed_books = list(/obj/item/book, /obj/item/spellbook, /obj/item/storage/book, /obj/item/codex_cicatrix) //Things allowed in the bookcase
	/// When enabled, books_to_load number of random books will be generated for this bookcase when first interacted with.
	var/load_random_books = FALSE
	/// The category of books to pick from when populating random books.
	var/random_category = null
	/// How many random books to generate.
	var/books_to_load = 0

/obj/structure/bookcase/examine(mob/user)
	. = ..()
	if(!anchored)
		. += "<span class='notice'><i>Śruby</i> na spodzie są odkręcone.</span>"
	else
		. += "<span class='notice'>Jest przymocowany <b>śrubami</b>.</span>"
	switch(state)
		if(0)
			. += "<span class='notice'>Na tylnym panelu widać <b>małe pęknięcie</b>.</span>"
		if(1)
			. += "<span class='notice'>W środku jest miejsce na <i>drewnianą</i> półkę.</span>"
		if(2)
			. += "<span class='notice'>Na półce widać <b>małe pęknięcie</b>.</span>"

/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	state = 2
	icon_state = "book-0"
	anchored = TRUE
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/book))
			I.forceMove(src)
	update_icon()

/obj/structure/bookcase/attackby(obj/item/I, mob/user, params)
	switch(state)
		if(0)
			if(I.tool_behaviour == TOOL_WRENCH)
				if(I.use_tool(src, user, 20, volume=50))
					to_chat(user, "<span class='notice'>Przykręcasz ramę na miejscu.</span>")
					anchored = TRUE
					state = 1
			if(I.tool_behaviour == TOOL_CROWBAR)
				if(I.use_tool(src, user, 20, volume=50))
					to_chat(user, "<span class='notice'>Rozbierasz ramę łomem.</span>")
					deconstruct(TRUE)

		if(1)
			if(istype(I, /obj/item/stack/sheet/mineral/wood))
				var/obj/item/stack/sheet/mineral/wood/W = I
				if(W.get_amount() >= 2)
					W.use(2)
					to_chat(user, "<span class='notice'>Dodajesz półkę.</span>")
					state = 2
					icon_state = "book-0"
			if(I.tool_behaviour == TOOL_WRENCH)
				I.play_tool_sound(src, 100)
				to_chat(user, "<span class='notice'>Odkręcasz ramę.</span>")
				anchored = FALSE
				state = 0

		if(2)
			var/datum/component/storage/STR = I.GetComponent(/datum/component/storage)
			if(is_type_in_list(I, allowed_books))
				if(!user.transferItemToLoc(I, src))
					return
				update_icon()
			else if(STR)
				for(var/obj/item/T in I.contents)
					if(istype(T, /obj/item/book) || istype(T, /obj/item/spellbook))
						STR.remove_from_storage(T, src)
				to_chat(user, "<span class='notice'>Opróżniasz [I] do [src].</span>")
				update_icon()
			else if(istype(I, /obj/item/pen))
				if(!user.is_literate())
					to_chat(user, "<span class='notice'>Gryzmolisz nieczytelnie na boku [src]!</span>")
					return
				var/newname = stripped_input(user, "Jak chcesz nazwać tę półkę z książkami?")
				if(!user.canUseTopic(src, BE_CLOSE))
					return
				if(!newname)
					return
				else
					name = "bookcase ([sanitize(newname)])"
			else if(I.tool_behaviour == TOOL_CROWBAR)
				if(contents.len)
					to_chat(user, "<span class='warning'>Najpierw musisz wyjąć książki!</span>")
				else
					I.play_tool_sound(src, 100)
					to_chat(user, "<span class='notice'>Wyważasz półkę.</span>")
					new /obj/item/stack/sheet/mineral/wood(drop_location(), 2)
					state = 1
					icon_state = "bookempty"
			else
				return ..()


/obj/structure/bookcase/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!istype(user))
		return
	if(load_random_books)
		create_random_books(books_to_load, src, FALSE, random_category)
		load_random_books = FALSE
	if(contents.len)
		var/obj/item/book/choice = input(user, "Którą książkę chcesz zdjąć z półki?") as null|obj in sortNames(contents)
		if(choice)
			if(!(user.mobility_flags & MOBILITY_USE) || user.stat || user.restrained() || !in_range(loc, user))
				return
			if(ishuman(user))
				if(!user.get_active_held_item())
					user.put_in_hands(choice)
			else
				choice.forceMove(drop_location())
			update_icon()


/obj/structure/bookcase/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(loc, 4)
	for(var/obj/item/book/B in contents)
		B.forceMove(get_turf(src))
	qdel(src)


/obj/structure/bookcase/update_icon()
	var/amount = contents.len
	if(load_random_books)
		amount += books_to_load
	icon_state = "book-[amount < 5 ? amount : 5]"


/obj/structure/bookcase/manuals/medical
	name = "medical manuals bookcase"

/obj/structure/bookcase/manuals/medical/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/medical_cloning(src)
	update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "engineering manuals bookcase"

/obj/structure/bookcase/manuals/engineering/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/engineering_construction(src)
	new /obj/item/book/manual/wiki/engineering_hacking(src)
	new /obj/item/book/manual/wiki/engineering_guide(src)
	new /obj/item/book/manual/wiki/engineering_singulo_tesla(src)
	new /obj/item/book/manual/wiki/robotics_cyborgs(src)
	update_icon()


/obj/structure/bookcase/manuals/research_and_development
	name = "\improper R&D manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/Initialize(mapload)
	. = ..()
	new /obj/item/book/manual/wiki/research_and_development(src)
	update_icon()


/*
 * Book
 */
/obj/item/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	desc = "Crack it open, inhale the musk of its pages, and learn something new."
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'
	attack_verb = list("grzmoci", "wali", "edukuje")
	resistance_flags = FLAMMABLE
	var/dat				//Actual page content
	var/due_date = 0	//Game time in 1/10th seconds
	var/author			//Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0		//0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title			//The real name of the book.
	var/window_size = null // Specific window size for the book, i.e: "1920x1080", Size x Width


/obj/item/book/attack_self(mob/user)
	if(!user.can_read(src))
		return
	user.visible_message("<span class='notice'>[user] otwiera książkę zatytułowaną \"[title]\" i zaczyna uważnie czytać.</span>")
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "book_nerd", /datum/mood_event/book_nerd)
	on_read(user)

/obj/item/book/proc/on_read(mob/user)
	if(dat)
		user << browse(HTML_SKELETON_TITLE(title, "<TT><I>Penned by [author].</I></TT> <BR>" + "[dat]"), "window=book[window_size != null ? ";size=[window_size]" : ""]")
		onclose(user, "book")
	else
		to_chat(user, "<span class='notice'>Ta książka jest zupełnie pusta!</span>")


/obj/item/book/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen))
		if(is_blind(user))
			to_chat(user, "<span class='warning'> Gdy próbujesz pisać w książce, nagle czujesz się bardzo głupio!</span>")
			return
		if(unique)
			to_chat(user, "<span class='warning'>Te strony chyba nie przyjmują dobrze atramentu! Wygląda na to, że nie możesz jej zmienić.</span>")
			return
		var/literate = user.is_literate()
		if(!literate)
			to_chat(user, "<span class='notice'>Gryzmolisz nieczytelnie na okładce [src]!</span>")
			return
		var/choice = input("Co chcesz zmienić?") in list("Title", "Contents", "Author", "Cancel")
		if(!user.canUseTopic(src, BE_CLOSE, literate))
			return
		switch(choice)
			if("Title")
				var/newtitle = reject_bad_text(stripped_input(user, "Wpisz nowy tytuł:"))
				if(!user.canUseTopic(src, BE_CLOSE, literate))
					return
				if (length(newtitle) > 50)
					to_chat(user, "Ten tytuł nie zmieści się na okładce!")
					return
				if(!newtitle)
					to_chat(user, "Ten tytuł jest nieprawidłowy.")
					return
				else
					name = newtitle
					title = newtitle
			if("Contents")
				var/content = stripped_input(user, "Wpisz treść książki (HTML NIEDOZWOLONY):","","",8192)
				if(!user.canUseTopic(src, BE_CLOSE, literate))
					return
				if(!content)
					to_chat(user, "Treść jest nieprawidłowa.")
					return
				else
					dat += content
			if("Author")
				var/newauthor = stripped_input(user, "Wpisz imię autora:")
				if(!user.canUseTopic(src, BE_CLOSE, literate))
					return
				if(!newauthor)
					to_chat(user, "Imię jest nieprawidłowe.")
					return
				else if(length(newauthor) > 45)
					to_chat(user, "To imię jest za długie!")
				else
					author = newauthor
			else
				return

	else if(istype(I, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = I
		if(!scanner.computer)
			to_chat(user, "Ekran [I] wyświetla: „Nie znaleziono powiązanego komputera!”")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze.”")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = name
					to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze. Tytuł książki zapisany w buforze powiązanego komputera.”")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze. Książka została zwrócona.”")
							return
					to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze. Nie znaleziono aktywnego wypożyczenia dla tego tytułu.”")
				if(3)
					scanner.book = src
					for(var/obj/item/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze. Tytuł już jest w katalogu, przerywanie, by uniknąć duplikatu.”")
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, "Ekran [I] wyświetla: „Książka zapisana w buforze. Tytuł dodany do katalogu ogólnego.”")

	else if((istype(I, /obj/item/kitchen/knife) || I.tool_behaviour == TOOL_WIRECUTTER) && !(flags_1 & HOLOGRAM_1))
		to_chat(user, "<span class='notice'>Zaczynasz wycinać środek [title]...</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>Wycinasz kartki z [title]! I tak nie chciałeś tego czytać.</span>")
			var/obj/item/storage/book/B = new
			B.name = src.name
			B.title = src.title
			B.icon_state = src.icon_state
			if(user.is_holding(src))
				qdel(src)
				user.put_in_hands(B)
				return
			else
				B.forceMove(drop_location())
				qdel(src)
				return
		return
	else
		..()


/*
 * Barcode Scanner
 */
/obj/item/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	desc = "A fabulous tool if you need to scan a barcode."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/computer/libraryconsole/bookmanagement/computer	//Associated computer - Modes 1 to 3 use this
	var/obj/item/book/book			//Currently scanned book
	var/mode = 0							//0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > 3)
		mode = 0
	to_chat(user, "Wyświetlacz stanu [src]:")
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Skanuj książkę do lokalnego bufora."
		if(1)
			modedesc = "Skanuj książkę do lokalnego bufora i ustaw bufor powiązanego komputera tak samo."
		if(2)
			modedesc = "Skanuj książkę do lokalnego bufora, spróbuj zwrócić zeskanowaną książkę."
		if(3)
			modedesc = "Skanuj książkę do lokalnego bufora, spróbuj dodać książkę do katalogu ogólnego."
		else
			modedesc = "ERROR"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(computer)
		to_chat(user, "<font color=green>Powiązano komputer z tym urządzeniem.</font>")
	else
		to_chat(user, "<font color=red>Nie znaleziono powiązanego komputera. Poprawnie będą działać tylko lokalne skany.</font>")
	to_chat(user, "\n")
