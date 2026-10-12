/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/prerequisites
	var/admin_notes

	var/credit_cost = INFINITY
	var/can_be_bought = TRUE
	var/illegal_shuttle = FALSE	//makes you able to buy the shuttle at a hacked/emagged comms console even if can_be_bought is FALSE

	var/list/movement_force // If set, overrides default movement_force on shuttle
	var/untowable = FALSE // If set, the shuttle becomes untowable

	var/port_x_offset
	var/port_y_offset
	var/extra_desc = ""

/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New(path = null, rename = null, cache = FALSE, admin_load = null)
	if(admin_load)//This data must be populated for the system to not shit itself apparently
		suffix = admin_load
		port_id = "custom"
		can_be_bought = FALSE
	shuttle_id = "[port_id]_[suffix]"
	if(!admin_load)
		mappath = "[prefix][port_id]/[shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	discover_port_offset()

	if(!cache)
		cached_map = null

/datum/map_template/shuttle/proc/discover_port_offset()
	var/key
	var/list/models = cached_map.grid_models
	for(key in models)
		if(findtext(models[key], "[/obj/docking_port/mobile]")) // Yay compile time checks
			break // This works by assuming there will ever only be one mobile dock in a template at most

	for(var/i in cached_map.gridSets)
		var/datum/grid_set/gset = i
		var/ycrd = gset.ycrd
		for(var/line in gset.gridLines)
			var/xcrd = gset.xcrd
			for(var/j in 1 to length(line) step cached_map.key_len)
				if(key == copytext(line, j, j + cached_map.key_len))
					port_x_offset = xcrd
					port_y_offset = ycrd
					return
				++xcrd
			--ycrd

/datum/map_template/shuttle/load(turf/T, centered, init_atmos = TRUE, finalize = TRUE, register=TRUE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
		centered = FALSE
	//This assumes a non-multi-z shuttle. If you are making a multi-z shuttle, you'll need to change the z bounds for this block. Good luck.
	var/list/turfs = block(locate(max(T.x, 1), max(T.y, 1),  T.z),
							locate(min(T.x+width, world.maxx), min(T.y+height, world.maxy), T.z))
	for(var/turf/turf in turfs)
		turfs[turf] = turf.loc
	keep_cached_map = TRUE //We need to access some stuff here below for shuttle skipovers
	. = ..(T, centered, init_atmos = TRUE, finalize = FALSE)
	keep_cached_map = initial(keep_cached_map)
	if(!.)
		cached_map = keep_cached_map ? cached_map : null
		return
	var/obj/docking_port/mobile/my_port
	for(var/turf/place in turfs)
		if(place.loc == turfs[place] || !istype(place.loc, /area/shuttle)) //If not part of the shuttle, ignore it
			turfs -= place
			continue
		for(var/obj/docking_port/mobile/port in place)
			my_port = port
			port.untowable = untowable
			if(register)
				port.register()
			if(isnull(port_x_offset))
				continue
			switch(port.dir) // Yeah this looks a little ugly but mappers had to do this in their head before
				if(NORTH)
					port.width = width
					port.height = height
					port.dwidth = port_x_offset - 1
					port.dheight = port_y_offset - 1
				if(EAST)
					port.width = height
					port.height = width
					port.dwidth = height - port_y_offset
					port.dheight = port_x_offset - 1
				if(SOUTH)
					port.width = width
					port.height = height
					port.dwidth = width - port_x_offset
					port.dheight = height - port_y_offset
				if(WEST)
					port.width = height
					port.height = width
					port.dwidth = port_y_offset - 1
					port.dheight = width - port_x_offset

	for(var/turf/shuttle_turf in turfs)
		var/area/shuttle/turf_loc = turfs[shuttle_turf]
		my_port.underlying_turf_area[shuttle_turf] = turf_loc
		if(istype(turf_loc) && turf_loc.mobile_port)
			turf_loc.mobile_port.towed_shuttles |= my_port

		//Getting the amount of baseturfs added
		var/z_offset = shuttle_turf.z - T.z
		var/y_offset = shuttle_turf.y - T.y
		var/x_offset = shuttle_turf.x - T.x
		//retrieving our cache
		var/line
		var/list/cache
		for(var/datum/grid_set/gset as() in cached_map.gridSets)
			if(gset.zcrd - 1 != z_offset) //Not our Z-level
				continue
			if((gset.ycrd - 1 < y_offset) || (gset.ycrd - length(gset.gridLines) > y_offset)) //Our y coord isn't in the bounds
				continue
			line = gset.gridLines[length(gset.gridLines) - y_offset] //Y goes from top to bottom
			if((gset.xcrd - 1 < x_offset) || (gset.xcrd + (length(line)/cached_map.key_len) - 2 > x_offset)) ///Our x coord isn't in the bounds
				continue
			cache = cached_map.modelCache[copytext(line, 1+((x_offset-gset.xcrd+1)*cached_map.key_len), 1+((x_offset-gset.xcrd+2)*cached_map.key_len))]
			break
		if(!cache) //Our turf isn't in the cached map, something went very wrong
			continue

		//How many baseturfs were added to this turf by the mapload
		var/baseturf_length
		var/turf/P //Typecasted for the initial call
		for(P as() in cache[1])
			if(ispath(P, /turf))
				var/list/added_baseturfs = GLOB.created_baseturf_lists[initial(P.baseturfs)] //We can assume that our turf type will be included here because it was just generated in the mapload.
				if(!islist(added_baseturfs))
					added_baseturfs = list(added_baseturfs)
				baseturf_length = length(added_baseturfs - GLOB.blacklisted_automated_baseturfs)
				break
		if(ispath(P, /turf/template_noop)) //No turf was added, don't add a skipover
			continue

		if(!islist(shuttle_turf.baseturfs))
			shuttle_turf.baseturfs = list(shuttle_turf.baseturfs)
		shuttle_turf.baseturfs.Insert(shuttle_turf.baseturfs.len + 1 - baseturf_length, /turf/baseturf_skipover/shuttle)

	//If this is a superfunction call, we don't want to initialize atoms here, let the subfunction handle that
	if(finalize)
		//initialize things that are normally initialized after map load
		initTemplateBounds(cached_map.bounds, init_atmos)

		log_game("[name] loaded at [T.x],[T.y],[T.z]")

	cached_map = keep_cached_map ? cached_map : null

//Whatever special stuff you want
/datum/map_template/shuttle/proc/post_load(obj/docking_port/mobile/M)
	if(movement_force)
		M.movement_force = movement_force.Copy()

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"
	untowable = TRUE

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"
	can_be_bought = FALSE

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"

/datum/map_template/shuttle/whiteship
	port_id = "whiteship"

/datum/map_template/shuttle/labour
	port_id = "labour"
	can_be_bought = FALSE

/datum/map_template/shuttle/mining
	port_id = "mining"
	can_be_bought = FALSE

/datum/map_template/shuttle/arrival
	port_id = "arrival"
	can_be_bought = FALSE
	untowable = TRUE

/datum/map_template/shuttle/infiltrator
	port_id = "infiltrator"
	can_be_bought = FALSE

/datum/map_template/shuttle/aux_base
	port_id = "aux_base"
	can_be_bought = FALSE

/datum/map_template/shuttle/escape_pod
	port_id = "escape_pod"
	can_be_bought = FALSE

/datum/map_template/shuttle/assault_pod
	port_id = "assault_pod"
	can_be_bought = FALSE

/datum/map_template/shuttle/pirate
	port_id = "pirate"
	can_be_bought = FALSE

/datum/map_template/shuttle/hunter
	port_id = "hunter"
	can_be_bought = FALSE

/datum/map_template/shuttle/ruin //For random shuttles in ruins
	port_id = "ruin"
	can_be_bought = FALSE

/datum/map_template/shuttle/snowdin
	port_id = "snowdin"
	can_be_bought = FALSE

// Shuttles start here:

/datum/map_template/shuttle/emergency/backup
	suffix = "backup"
	name = "Backup Shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/emergency/construction
	suffix = "construction"
	name = "Build your own shuttle kit"
	description = "Dla przedsiębiorczego inżyniera promów! Kadłub zadokuje zaraz po zakupie, ale start trzeba będzie jak zwykle zatwierdzić przez wezwanie promu. Zaopatrzony w materiały budowlane."
	admin_notes = "Bez aresztu, bez zaplecza medycznego, bez konsoli promu."
	credit_cost = -2500

/datum/map_template/shuttle/emergency/airless/prerequisites_met()
	// first 10 minutes only
	return world.time - SSticker.round_start_time < 6000

/datum/map_template/shuttle/emergency/airless/post_load()
	. = ..()
	//enable buying engines from cargo
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/shuttle_engine]
	P.special_enabled = TRUE


/datum/map_template/shuttle/emergency/asteroid
	suffix = "asteroid"
	name = "Asteroid Station Emergency Shuttle"
	description = "Szanowany prom średniej wielkości, który po raz pierwszy służył do przewożenia załogi Nanotrasen do i z placówek w pasie asteroid."
	credit_cost = 3000

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "The Emergency Escape Bar"
	description = "Na wyposażeniu: świadoma obsługa baru (Bardron i Barmanka), łazienka, wysokiej klasy salonik dla szefów oraz duży stół do spotkań."
	admin_notes = "Bardron i Barmanka mają GODMODE i zostaną automatycznie ożywieni przez balon zabawy 60 sekund przed przylotem. Ma zaplecze medyczne."
	credit_cost = 5000

/datum/map_template/shuttle/emergency/pod
	suffix = "pod"
	name = "Emergency Pods"
	description = "Nie spodziewaliśmy się tak szybkiej ewakuacji. Mamy do dyspozycji tylko dwie kapsuły ratunkowe."
	admin_notes = "Do karania graczy."
	can_be_bought = FALSE

/datum/map_template/shuttle/emergency/russiafightpit
	suffix = "russiafightpit"
	name = "Mother Russia Bleeds"
	description = "To jest wysokiej jakości prom, da. Dużo miejsc, dużo przestrzeni, cały sprzęt! Jest nawet rozrywka! Na przykład dużo picia i arena walk, żeby pijana załoga mogła się zabawić! Jak arena za mało zabawna, wystarczy nacisnąć przycisk wypuszczania niedźwiedzi. Nie martw się, niedźwiedzie wytresowane, żeby nie uciekać z areny, więc zupełnie bezpiecznie, dopóki nikt nie jest tak głupi albo pijany, żeby zostawić otwarte drzwi. Postaraj się, żeby asimovowe borgi nie zepsuły zabawy!"
	admin_notes = "Zawiera niewielki wybór broni. I niedźwiedzie. Tylko dostęp kapitański pozwala wypuścić niedźwiedzie. Niedźwiedzie same nie rozbiją okien, ale mogą uciec, jeśli ktoś je wypuści."
	credit_cost = 5000 // While the shuttle is rusted and poorly maintained, trained bears are costly.

/datum/map_template/shuttle/emergency/meteor
	suffix = "meteor"
	name = "Asteroid With Engines Strapped To It"
	description = "Wydrążona asteroida z przypiętymi silnikami; procedura drążenia bardzo utrudnia porwanie, ale jest bardzo droga. Ze względu na rozmiar i trudne sterowanie ten prom może uszkodzić strefę dokowania."
	admin_notes = "Ten prom najpewniej zmiażdży strefę ewakuacji, zabijając wszystkich, którzy tam są."
	credit_cost = 15000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/luxury
	suffix = "luxury"
	name = "Luxury Shuttle"
	description = "Luksusowy złoty prom z krytym basenem. Każdy członek załogi, który chce wejść na pokład, musi przynieść 500 kredytów, płatnych gotówką i monetami z minerałów."
	extra_desc = "Wejście na pokład tego promu kosztuje 500 kredytów."
	admin_notes = "Z powodu ograniczonego miejsca dla niepłacącej załogi ten prom może wywołać zamieszki."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/discoinferno
	suffix = "discoinferno"
	name = "Disco Inferno"
	description = "Wspaniały rezultat wieków badań nad plazmą prowadzonych przez pracowników Nanotrasen. To dlatego tu jesteś. Wsiadaj i tańcz, jakbyś płonął, burn baby burn!"
	admin_notes = "Rozgrzany do czerwoności. W głównej części jest maszyna do tańca oraz plazmowe płytki podłogowe, które gracze za każdym razem podpalą."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/arena
	suffix = "arena"
	name = "The Arena"
	description = "Aby wejść na pokład tego promu, załoga musi przejść przez nieziemską arenę. Należy spodziewać się ogromnych strat. Aby odblokować ten prom, trzeba wytropić i zlikwidować źródło Krwawego Sygnału."
	admin_notes = "ROZERWIJ I ROZSZARP."
	credit_cost = 10000
	/// Whether the arena z-level has been created
	var/arena_loaded = FALSE

/datum/map_template/shuttle/emergency/arena/prerequisites_met()
	if(SHUTTLE_UNLOCK_BUBBLEGUM in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/emergency/arena/post_load(obj/docking_port/mobile/M)
	. = ..()
	if(!arena_loaded)
		arena_loaded = TRUE
		var/datum/map_template/arena/arena_template = new()
		arena_template.load_new_z()

/datum/map_template/arena
	name = "The Arena"
	mappath = "_maps/templates/the_arena.dmm"

/datum/map_template/shuttle/emergency/birdboat
	suffix = "birdboat"
	name = "Birdboat Station Emergency Shuttle"
	description = "Choć trochę mały, ten prom ma wszystko, czego trzeba, czego nie da się powiedzieć o typie stacji, dla którego go zamówiono."
	credit_cost = 1000

/datum/map_template/shuttle/emergency/shelter
	suffix = "shelter"
	name = "BSP Collapsable Emergency Shuttle"
	description = "Nowy produkt spółki zależnej Nanotrasen, zaprojektowany z myślą o szybkiej budowie i użyciu, z udogodnieniami małego promu ewakuacyjnego, w tym kapsułami medycznymi. Na szczęście prom rzeczywiście szybciej się rozkłada. Na nieszczęście dochodzi do tego czas budowy, więc przelot wcale nie będzie szybszy."
	credit_cost = 2500

/datum/map_template/shuttle/emergency/box
	suffix = "box"
	name = "Box Station Emergency Shuttle"
	credit_cost = 2000
	description = "Złoty standard ewakuacji awaryjnej; ta sprawdzona konstrukcja ma wszystko, czego załoga potrzebuje do bezpiecznego lotu do domu."

/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Snappop(tm)!"
	description = "Hej, dzieciaki i dorośli! Nudzą was NUDNE i MĘCZĄCE podróże promem po ewakuacji z pewnie NUDNYCH powodów? To zamówcie Snappop(tm) już dziś! Mamy zabawy dla każdego, kokpit z pełnym dostępem i żadnego nudnego aresztu! Buu! Przebierajcie się z przyjaciółmi! Zbierzcie wszystkie prześcieradła, zanim zrobi to sąsiad! Sprawdźcie, czy SI was obserwuje, z naszym opatentowanym (w toku) „Wykrywaczem Podglądającej SI Multitool”, w skrócie PEEEEEETUR. Miłej jazdy!"
	admin_notes = "Areszt zastąpiono przytwierdzoną księgą greentextu otoczoną przepaściami z Lavalandu; drzwi od strony stacji usunięto, by nikt przypadkiem nie spadł. Brak aresztu."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Secure Transport Vessel 5 (STV5)"
	description = "Wygląda na to, że Centrala miała w okolicy tylko ten statek; pewnie nie spodziewali się, że tak szybko będziecie potrzebować ewakuacji. Lepiej nie grzebcie w sprzęcie, który przewozili. Mam nadzieję, że lubicie współpracowników, bo miejsca jest tu bardzo mało.\n\nZawiera kontrabandową broń ze zbrojowni, łupy z tuneli technicznych i porzucone skrzynie!"
	admin_notes = "Jako że był to zabezpieczony statek dla jednego pilota, ma na pokładzie aktywny GPS oznaczony STV5. Ma mniej więcej tyle miejsca co Hi Daniel, tylko ze skrzyniami wybuchowymi."

/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "Meta Station Emergency Shuttle"
	credit_cost = 4000
	description = "Dość standardowy prom, choć większy i nieco lepiej wyposażony niż wariant z Box Station."

/datum/map_template/shuttle/emergency/kilo
	suffix = "kilo"
	name = "Kilo Station Emergency Shuttle"
	credit_cost = 5000
	description = "W pełni funkcjonalny prom z kompletnym ambulatorium, magazynami i zwykłymi udogodnieniami."

/datum/map_template/shuttle/emergency/corg
	suffix = "corg"
	name = "Corg Station Emergency Shuttle"
	credit_cost = 4000
	description = "Mniejszy prom z miejscem dla personelu zaopatrzenia, medycznego i ochrony."

/datum/map_template/shuttle/emergency/fland
	suffix = "fland"
	name = "Flandstation Wide shuttle"
	description = "To gruby prom dla dość nietypowej stacji... hmm..."
	admin_notes = "Jest duży, więc może zahaczyć o otoczenie na innych mapach, które nie mają ogromnej strefy dokowania awaryjnego."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/donut //NSV13 - we were using that shuttle
	suffix = "donut"
	name = "Donut Station Emergency Shuttle"
	credit_cost = 4000

/datum/map_template/shuttle/emergency/mini
	suffix = "mini"
	name = "Ministation emergency shuttle"
	credit_cost = 1000
	description = "Mimo nazwy ten prom jest tylko nieco mniejszy od standardowego i wciąż ma areszt oraz ambulatorium."

/datum/map_template/shuttle/emergency/scrapheap
	suffix = "scrapheap"
	name = "Standby Evacuation Vessel \"Scrapheap Challenge\""
	credit_cost = -1000
	description = "Z powodu braku sprawnych promów ewakuacyjnych kupiliśmy ten z drugiej ręki na złomowisku i wcieliliśmy go do służby. Prosimy nie opierać się zbyt mocno o zewnętrzne okna, są kruche."
	admin_notes = "Pokraka bez działającego ambulatorium, z brakującymi sekcjami i bardzo kruchymi oknami. Zaskakująco szczelna."
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Wygląda na to, że ten prom w drodze na stację zabłądził w ciemność między gwiazdami. Lepiej nie zastanawiać się zbyt długo, skąd się wzięły te wszystkie ciała."
	admin_notes = "Zawiera prawdziwe ruiny kultu, gałki oczne i nieaktywne konstrukty. Moby kultu zostaną automatycznie ożywione przez balon zabawy. Kapsuły klonujące w „ambulatorium” są atrapami i nie działają."

/datum/map_template/shuttle/emergency/narnar/prerequisites_met()
	if(SHUTTLE_UNLOCK_NARNAR in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/emergency/pubby
	suffix = "pubby"
	name = "Pubby Station Emergency Shuttle"
	description = "Pociąg, tylko w kosmosie! Z pierwszą i drugą klasą, aresztem i magazynem."
	admin_notes = "Ciuch ciuch, skurczybyku!"
	credit_cost = 1000

/datum/map_template/shuttle/emergency/cere
	suffix = "cere"
	name = "Cere Station Emergency Shuttle"
	description = "Duża, wzmocniona wersja standardowego promu z Box. Zawiera powiększony areszt, w pełni zaopatrzone ambulatorium, rozbudowany magazyn zaopatrzenia z ładowarkami mechów, maszynownię z różnymi zapasami, a na dokładkę mieści ponad 80 osób załogi. Żyj z rozmachem, żyj jak na Cere."
	admin_notes = "Naprawdę wielki, nawet większy od promu Delta."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/supermatter
	suffix = "supermatter"
	name = "Hyperfractal Gigashuttle"
	description = "„Nie wiem, to wydaje się niepotrzebnie skomplikowane.”\n„Według kadeta Centrali Yinsa ten prom ma bardzo wysoki wskaźnik bezpieczeństwa.”\n„Na pewno?”\n„Tak, ma wskaźnik bezpieczeństwa N-A-N, a to podobno więcej niż 100%.”"
	admin_notes = "Supermateria pojawiająca się na promie to specjalna, przytwierdzona supermateria „hugbox”, która nie otrzymuje obrażeń i nie pochłania ani nie emituje gazu. Bez ingerencji admina nie może wybuchnąć. Nadal jednak obraca w pył wszystko, czego dotknie, emituje wysokie promieniowanie i wywołuje halucynacje u każdego, kto patrzy na nią bez gogli ochronnych. Emitery pojawiają się włączone; spodziewaj się powiadomień dla adminów, są nieszkodliwe."
	credit_cost = 100000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/imfedupwiththisworld
	suffix = "imfedupwiththisworld"
	name = "Oh, Hi Daniel"
	description = "Jak tam dziś kosmiczna praca? A, całkiem nieźle. Dostaliśmy nową stację kosmiczną i firma zarobi masę pieniędzy. Jaką stację kosmiczną? Nie mogę ci powiedzieć, to kosmicznie poufne. Ej, no kosmicznie weź. Czemu nie? Nie, nie mogę. Tak w ogóle, jak twoje kosmiczne życie roleplayowe?"
	admin_notes = "Malutki, z jedną śluzą i drewnianymi ścianami. Co mogłoby pójść nie tak?"
	credit_cost = -5000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

/datum/map_template/shuttle/emergency/goon
	suffix = "goon"
	name = "NES Port"
	description = "Port Promu Ewakuacyjnego Nanotrasen (w skrócie NES Port) to prom używany w innych, mniej znanych placówkach Nanotrasen; ma bardziej otwarte wnętrze dla większych tłumów, ale mniej udogodnień na pokładzie."
	credit_cost = 500

/datum/map_template/shuttle/emergency/wabbajack
	suffix = "wabbajack"
	name = "NT Lepton Violet"
	description = "Pewnego dnia zespół badawczy stacjonujący na tym statku zaginął i żadne śledztwo nie zdołało ustalić, co się z nim stało. Jedynymi pasażerami były martwe gryzonie, które najwyraźniej zadrapały się nawzajem na śmierć. Nie trzeba dodawać, że żaden zespół inżynierów nie chciał się do tego zbliżać, a używa się go jako promu ewakuacyjnego tylko dlatego, że dosłownie nic innego nie ma."
	admin_notes = "Jeśli załoga rozwiąże zagadkę, obudzi posąg wabbajacka. Pewnie nie skończy się to dobrze. Nie bez powodu jest zabity deskami. Może lepiej było go zostawić w spokoju."
	credit_cost = 15000

/datum/map_template/shuttle/emergency/omega
	suffix = "omega"
	name = "Omegastation Emergency Shuttle"
	description = "Raczej niewielki, o nowoczesnym wyglądzie; ten prom jest dla załogi, która lubi przytulne wnętrza, ale wciąż chce mieć gdzie rozprostować nogi."
	credit_cost = 1000

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standardowy prom Centrali dla stacji Box/Meta."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoj! Mamy tu na rufie wszelkie mięsiwo. Mięso z ludzi-roślin, z ludzi, co są ciemni, nie w rasistowskim sensie, po prostu są czarni jak smoła. A, i mięso jaszczurów też, cholernie popularne. Na pewno w 100% świeże, spytaj tego gościa. *osoba na haku na mięso jęczy* Widzisz? Na pewno wysokiej jakości mięso, nic mu nie brakuje, nic nie dodane, na pewno żadnych zombifikujących odczynników!"
	admin_notes = "Mięso obecnie nie zawiera zombifikujących odczynników, jaszczura na haku trzeba zespawnować."

/datum/map_template/shuttle/ferry/lighthouse
	suffix = "lighthouse"
	name = "The Lighthouse(?)"
	description = "*szum*... część znacznie większego statku, możliwe, że wojskowego. Oznaczenia broni nie przypominają niczego, co widzieliśmy ...szum... prawie nigdy przez tę samą osobę dwa razy, możliwe użycie nieznanego magazynu ...szum... widząc na pokładzie oficerów ERT, ale w aktach nie ma misji dla ...szum...szum...irytujący dżingiel... tylko w LIGHTHOUSE! Zaspokajamy potrzeby, o których nawet nie wiedziałeś. Mamy WSZYSTKO, i jeszcze coś!"
	admin_notes = "Obecnie większy niż port dokowania promu na Box; w nic nie uderzy, ale trzeba go dokować siłą. Handlarz i ochroniarze ERT nie są wliczeni."

/datum/map_template/shuttle/ferry/fancy
	suffix = "fancy"
	name = "fancy transport ferry"
	description = "W pewnym momencie ktoś ulepszył prom, dając mu bardziej wymyślną podłogę... i mniej siedzeń."

/datum/map_template/shuttle/ferry/kilo
	suffix = "kilo"
	name = "kilo transport ferry"
	description = "Standardowy prom Centrali dla stacji typu Kilo. Zawiera dodatkowy sprzęt i ładowarki."

/datum/map_template/shuttle/whiteship/box
	suffix = "box"
	name = "Hospital Ship"

/datum/map_template/shuttle/whiteship/meta
	suffix = "meta"
	name = "Salvage Ship"

/datum/map_template/shuttle/whiteship/pubby
	suffix = "pubby"
	name = "NT White UFO"

/datum/map_template/shuttle/whiteship/cere
	suffix = "cere"
	name = "NT Construction Vessel"

/datum/map_template/shuttle/whiteship/delta
	suffix = "delta"
	name = "NT Frigate"

/datum/map_template/shuttle/whiteship/pod
	suffix = "whiteship_pod"
	name = "Salvage Pod"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "supply shuttle (Box)"

/datum/map_template/shuttle/cargo/kilo
	suffix = "kilo"
	name = "supply shuttle (Kilo)"

/datum/map_template/shuttle/cargo/corg
	suffix = "corg"
	name = "supply shuttle (Corg)"

/datum/map_template/shuttle/cargo/birdboat
	suffix = "birdboat"
	name = "supply shuttle (Birdboat)"

/datum/map_template/shuttle/emergency/delta
	suffix = "delta"
	name = "Delta Station Emergency Shuttle"
	description = "Duży prom dla dużej stacji; zmieści wygodnie całe twoje przeludnienie i tłok. Ze wszystkimi udogodnieniami i dodatkowym sprzętem."
	admin_notes = "Na bogato albo wcale."
	credit_cost = 7500

/datum/map_template/shuttle/emergency/raven
	suffix = "raven"
	name = "CentCom Raven Cruiser"
	description = "Krążownik Raven Centrali to dawny statek ratowniczy wysokiego ryzyka, przerobiony na prom ewakuacyjny. Kiedyś pierwszy na miejscu, by przeczesywać strefy działań wojennych w poszukiwaniu cennych szczątków, teraz świetnie sprawdza się przy ewakuacji stacji pod ciężkim ostrzałem sił zewnętrznych. Ten prom ma osłony i liczne wieżyczki przeciwpiechotne strzegące jego obwodu, by odpierać meteory i próby abordażu."
	admin_notes = "Ma wieżyczki, które celują we wszystko spoza neutralnej frakcji (nukeopsi, ksenomorfy itd., ale nie zwierzaki)."
	credit_cost = 30000

/datum/map_template/shuttle/emergency/zeta
	suffix = "zeta"
	name = "Tr%nPo2r& Z3TA"
	description = "Na twoim monitorze pojawia się zakłócenie, migocząc między wyświetlonymi opcjami. Wydaje się dziwne i obce; możesz potrzebować specjalnej technologii, by odebrać ten sygnał..."
	admin_notes = "Ma na pokładzie eksperymentalny klonownik tworzący kopie użytkownika, obce narzędzia chirurgiczne i rdzeń pustki, który zapewnia nieograniczoną moc."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/zeta/prerequisites_met()
	if(SHUTTLE_UNLOCK_ALIENTECH in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/arrival/box
	suffix = "box"
	name = "arrival shuttle (Box)"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "cargo ferry (Box)"

/datum/map_template/shuttle/mining/box
	suffix = "box"
	name = "mining shuttle (Box)"

/datum/map_template/shuttle/labour/box
	suffix = "box"
	name = "labour shuttle (Box)"

/datum/map_template/shuttle/arrival/corg
	suffix = "corg"
	name = "arrival shuttle (Corg)"

/datum/map_template/shuttle/infiltrator/basic
	suffix = "basic"
	name = "basic syndicate infiltrator"

/datum/map_template/shuttle/infiltrator/advanced
	suffix = "advanced"
	name = "advanced syndicate infiltrator"

/datum/map_template/shuttle/cargo/delta
	suffix = "delta"
	name = "cargo ferry (Delta)"

/datum/map_template/shuttle/mining/delta
	suffix = "delta"
	name = "mining shuttle (Delta)"

/datum/map_template/shuttle/mining/kilo
	suffix = "kilo"
	name = "mining shuttle (Kilo)"

/datum/map_template/shuttle/mining/large
	suffix = "large"
	name = "mining shuttle (Large)"

/datum/map_template/shuttle/science
	port_id = "science"
	suffix = "outpost"
	name = "science outpost shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/exploration
	port_id = "exploration"
	suffix = "shuttle"
	name = "exploration shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/exploration/corg
	suffix = "corg"
	name = "corg exploration shuttle"

/datum/map_template/shuttle/exploration/delta
	suffix = "delta"
	name = "delta exploration shuttle"

/datum/map_template/shuttle/exploration/kilo
	suffix = "kilo"
	name = "kilo exploration shuttle"

/datum/map_template/shuttle/labour/delta
	suffix = "delta"
	name = "labour shuttle (Delta)"

/datum/map_template/shuttle/labour/kilo
	suffix = "kilo"
	name = "labour shuttle (Kilo)"

/datum/map_template/shuttle/labour/corg
	suffix = "corg"
	name = "labour shuttle (Corg)"

/datum/map_template/shuttle/arrival/delta
	suffix = "delta"
	name = "arrival shuttle (Delta)"

/datum/map_template/shuttle/arrival/kilo
	suffix = "kilo"
	name = "arrival shuttle (Kilo)"

/datum/map_template/shuttle/arrival/pubby
	suffix = "pubby"
	name = "arrival shuttle (Pubby)"

/datum/map_template/shuttle/arrival/omega
	suffix = "omega"
	name = "arrival shuttle (Omega)"

/datum/map_template/shuttle/aux_base/default
	suffix = "default"
	name = "auxilliary base (Default)"

/datum/map_template/shuttle/aux_base/small
	suffix = "small"
	name = "auxilliary base (Small)"

/datum/map_template/shuttle/escape_pod/default
	suffix = "default"
	name = "escape pod (Default)"

/datum/map_template/shuttle/escape_pod/large
	suffix = "large"
	name = "escape pod (Large)"

/datum/map_template/shuttle/assault_pod/default
	suffix = "default"
	name = "assault pod (Default)"

/datum/map_template/shuttle/pirate/default
	suffix = "default"
	name = "pirate ship (Default)"

/datum/map_template/shuttle/hunter/space_cop
	suffix = "space_cop"
	name = "Police Spacevan"

/datum/map_template/shuttle/hunter/russian
	suffix = "russian"
	name = "Russian Cargo Ship"

/datum/map_template/shuttle/hunter/bounty
	suffix = "bounty"
	name = "Bounty Hunter Ship"

/datum/map_template/shuttle/ruin/caravan_victim
	suffix = "caravan_victim"
	name = "Small Freighter"

/datum/map_template/shuttle/ruin/pirate_cutter
	suffix = "pirate_cutter"
	name = "Pirate Cutter"

/datum/map_template/shuttle/ruin/syndicate_dropship
	suffix = "syndicate_dropship"
	name = "Syndicate Dropship"

/datum/map_template/shuttle/ruin/syndicate_fighter_shiv
	suffix = "syndicate_fighter_shiv"
	name = "Syndicate Fighter"

/datum/map_template/shuttle/snowdin/mining
	suffix = "mining"
	name = "Snowdin Mining Elevator"

/datum/map_template/shuttle/snowdin/excavation
	suffix = "excavation"
	name = "Snowdin Excavation Elevator"

 // Turbolifts
/datum/map_template/shuttle/turbolift
	prefix = "_maps/shuttles/turbolifts/"
	can_be_bought = FALSE

/datum/map_template/shuttle/turbolift/debug/primary
	port_id = "debug"
	suffix = "primary"
	name = "primary turbolift (multi-z debug)"
	can_be_bought = FALSE

/datum/map_template/shuttle/tram
	port_id = "tram"
	can_be_bought = FALSE

/datum/map_template/shuttle/tram/corg
	suffix = "corg"
	name = "corgstation transport shuttle"

//---------cargo_fland.dmm
/datum/map_template/shuttle/cargo/fland
	suffix = "fland"
	name = "supply shuttle (fland)"

//---------labour_fland.dmm
/datum/map_template/shuttle/cargo/fland
	suffix = "fland"
	name = "cargo ferry (Fland)"

//---------mining_fland.dmm
/datum/map_template/shuttle/mining/fland
	suffix = "fland"
	name = "mining shuttle (fland)"

//---------labour_fland.dmm
/datum/map_template/shuttle/labour/fland
	suffix = "fland"
	name = "labour shuttle (Fland)"

//---------arrival_fland.dmm
/datum/map_template/shuttle/arrival/fland
	suffix = "fland"
	name = "arrival shuttle (Fland)"

//---------whiteship_fland.dmm
/datum/map_template/shuttle/whiteship/fland
	suffix = "fland"
	name = "Eden Whiteship"

//---------exploration_fland.dmm
/datum/map_template/shuttle/exploration/fland
	suffix = "fland"
	name = "Fland exploration shuttle"

//---------ferry_fland.dmm
/datum/map_template/shuttle/ferry/fland
	suffix = "fland"
	name = "fland transport ferry"
	description = "Standardowy prom Centrali dla stacji fland. Zawiera dodatkowy sprzęt i ładowarkę."

/datum/map_template/shuttle/turbolift/semmes/aircraft //NSV13
	port_id = "aircraft"
	suffix = "semmes"
	name = "Aircraft elevator (NSV Semmes)"
	can_be_bought = FALSE
