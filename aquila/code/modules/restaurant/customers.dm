///Rodzaj robota-turysty: co zamawia, jak wygląda i co mówi
/datum/customer_data
	///Co robot lubi zamawiać: rodzaj lokalu => ważona lista typów. NIE obejmuje podtypów
	var/list/orderable_objects = list()
	///Kontroler AI robota
	var/datum/ai_controller/ai_controller_used = /datum/ai_controller/robot_customer
	///Jak długo robot czeka na zamówienie
	var/total_patience = 600 SECONDS
	///Gdy znajdzie miejsce
	var/list/found_seat_lines = list("Znalazłem miejsce.")
	///Gdy nie może znaleźć miejsca
	var/list/cant_find_seat_lines = list("Nie ma gdzie usiąść.")
	///Gdy wychodzi bez jedzenia
	var/list/leave_mad_lines = list("Wychodzę głodny.")
	///Gdy wychodzi najedzony
	var/list/leave_happy_lines = list("Dziękuję, było pyszne.")
	///Gdy czeka na zamówienie
	var/list/wait_for_food_lines = list("Wciąż czekam na jedzenie.")
	///Gdy dostanie nie to, co zamówił
	var/wrong_item_line = "Nie to zamawiałem."
	///Gdy ciągnie go obsługa lokalu
	var/friendly_pull_line = "Dokąd idziemy?"
	///Pierwsze ostrzeżenie dla zaczepiającego
	var/first_warning_line = "Nie dotykaj mnie!"
	///Drugie ostrzeżenie
	var/second_warning_line = "To ostatnie ostrzeżenie!"
	///Gdy robot zaczyna się bronić
	var/self_defense_line = "Omae wa mou shindeiru."
	///Ubrania do wyboru
	var/list/clothing_sets = list("amerifat_clothes")
	///Początki imion robotów
	var/list/name_prefixes = list("Turysta")
	///Ikona robota
	var/base_icon = 'aquila/icons/mob/tourists.dmi'
	///Stan ikony robota
	var/base_icon_state = "amerifat"
	///Dźwięk mowy
	var/speech_sound = 'aquila/sound/restaurant/tourist_talk.ogg'
	///Czy przychodzi najwyżej raz na lokal
	var/is_unique = FALSE

///Czy ten rodzaj klienta może teraz przyjść do lokalu
/datum/customer_data/proc/can_use(datum/venue/venue)
	return length(orderable_objects[venue.venue_type])

/datum/customer_data/proc/get_overlays(mob/living/simple_animal/robot_customer/customer)
	return

/datum/customer_data/proc/get_underlays(mob/living/simple_animal/robot_customer/customer)
	return

/datum/customer_data/american
	name_prefixes = list("Kowboj", "Teksas", "Burger", "Grill", "Floryda", "Nowy Jork", "Wolność", "Barbecue", "Jankes", "Hot-dog", "Rodeo", "Szeryf")
	found_seat_lines = list("Mam nadzieję, że to krzesło wytrzyma mój ciężar.", "Mam nadzieję, że mają potrójnego burgera deluxe.", "Uwielbiam tutejszą kulturę!", "Wreszcie jakieś porządne miejsce.")
	cant_find_seat_lines = list("Jestem taki zmęczony staniem...", "Mam przewlekły ból pleców, dajcie mi wreszcie usiąść!", "Bez miejsca nie będzie napiwku.")
	leave_mad_lines = list("ŻADNEGO NAPIWKU. ŻEGNAM!", "W SpaceDonaldzie podają przynajmniej SZYBKO!", "Okropny lokal!", "Chcę rozmawiać z kierownikiem!", "Wystawię wam jedną gwiazdkę!")
	leave_happy_lines = list("Ekstra napiwek dla ciebie, przyjacielu.", "Dzięki za świetne jedzenie!", "Cukrzyca to i tak mit!")
	wait_for_food_lines = list("Słuchaj, kolego, zaczynam się niecierpliwić!", "Czekam tu od wieków...")
	wrong_item_line = "To nie jest to, co zamówiłem, kolego."
	friendly_pull_line = "Dokąd mnie zabierasz? Tylko nie do medbaya, nie mam ubezpieczenia."
	first_warning_line = "Nie depcz mnie!"
	second_warning_line = "Ostatnia szansa, kolego! Nie depcz mnie!"
	self_defense_line = "AKTYWUJĘ DOKTRYNĘ ZAMKU!"

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/burger/plain = 25,
			/obj/item/food/burger/cheese = 15,
			/obj/item/food/burger/superbite = 1,
			/obj/item/food/fries = 10,
			/obj/item/food/cheesyfries = 6,
			/obj/item/food/pie/applepie = 4,
			/obj/item/food/pie/pumpkinpie = 2,
			/obj/item/food/hotdog = 8,
			/obj/item/food/pizza/pineapple = 1,
			/obj/item/food/burger/baconburger = 10,
			/obj/item/food/pancakes = 4,
			/obj/item/food/sausage = 5,
			/obj/item/food/icecream = 14,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/b52 = 6,
			/datum/reagent/consumable/ethanol/manhattan = 3,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
			/datum/reagent/consumable/ethanol/beer = 25,
		),
	)

/datum/customer_data/italian
	name_prefixes = list("Mafia", "Don", "Pizza", "Vespa", "Pasta", "Wenecja", "Rzym", "Centurion", "Mamma", "Gondola")
	base_icon_state = "italian"
	clothing_sets = list("italian_pison", "italian_godfather")

	found_seat_lines = list("Co za piękne miejsce do siedzenia.", "Mam nadzieję, że podają jak u mojej mamma.")
	cant_find_seat_lines = list("Mamma mia! Ja chcę tylko usiąść!", "Czemu-a każecie mi tu stać?")
	leave_mad_lines = list("Takiego braku szacunku nie widziałem od lat!", "Co-a za okropny lokal!")
	leave_happy_lines = list("To jest amoreee!", "Jak u mamma!")
	wait_for_food_lines = list("Jestem-a taki głodny...", "Gdzie moje jedzenie, per favore?")
	wrong_item_line = "Nie-a, nie-a! To nie to!"
	friendly_pull_line = "Nie-a, ja głodny! Nigdzie nie idę."
	first_warning_line = "Nie dotykaj-a mnie!"
	second_warning_line = "Ostatnie ostrzeżenie! Nie ruszaj mojego spaghetti."
	self_defense_line = "Zagniotę cię jak mamma swoje pyszne klopsiki!"
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/spaghetti/pastatomato = 20,
			/obj/item/food/spaghetti/copypasta = 6,
			/obj/item/food/spaghetti/meatballspaghetti = 4,
			/obj/item/food/spaghetti/butternoodles = 4,
			/obj/item/food/spaghetti/carbonara = 4,
			/obj/item/food/spaghetti/lasagna = 4,
			/obj/item/food/pizza/vegetable = 2,
			/obj/item/food/pizza/mushroom = 2,
			/obj/item/food/pizza/meat = 2,
			/obj/item/food/pizza/margherita = 2,
			/obj/item/food/eggplantparm = 3,
			/obj/item/food/chococornet = 2,
			/obj/item/food/icecream = 10,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/fanciulli = 5,
			/datum/reagent/consumable/ethanol/branca_menta = 3,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/lemonade = 8,
			/datum/reagent/consumable/ethanol/wine = 3,
			/datum/reagent/consumable/ethanol/grappa = 3,
		),
	)

/datum/customer_data/french
	name_prefixes = list("Bagietka", "Ślimak", "Biała Flaga", "Eiffel", "Paryż", "Beret", "Hon hon", "Wino", "Croissant")
	base_icon_state = "french"
	clothing_sets = list("french_fit")
	found_seat_lines = list("Hon hon hon.", "To nie wieża Eiffla, ale ujdzie.", "Fuj. No dobrze, niech będzie.")
	cant_find_seat_lines = list("Każecie stać KOMUŚ TAKIEMU jak ja? Jak śmiecie.", "Co za brudny hol!")
	leave_mad_lines = list("Sacré bleu!", "Merde! Ten lokal jest gorszy niż Ren!")
	leave_happy_lines = list("Hon hon hon.", "Niezła próba.")
	wait_for_food_lines = list("Hon hon hon.", "Tu nawet kelnerzy się nie spieszą...")
	wrong_item_line = "Non! Co to ma być?"
	friendly_pull_line = "Twoje brudne ręce na moim stroju? Fuj, no dobrze."
	first_warning_line = "Zabierz ode mnie ręce!"
	second_warning_line = "Nie dotykaj mnie, ty zwierzę, ostatnie ostrzeżenie!"
	self_defense_line = "Złamię cię jak bagietkę!"
	speech_sound = 'aquila/sound/restaurant/tourist_talk_french.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/baguette = 20,
			/obj/item/food/garlicbread = 5,
			/obj/item/food/soup/bisque = 4,
			/obj/item/food/pie/berryclafoutis = 2,
			/obj/item/food/omelette = 15,
			/obj/item/food/icecream = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/champagne = 10,
			/datum/reagent/consumable/ethanol/cognac = 5,
			/datum/reagent/consumable/ethanol/mojito = 5,
			/datum/reagent/consumable/ethanol/sidecar = 5,
			/datum/reagent/consumable/ethanol/between_the_sheets = 4,
			/datum/reagent/consumable/ethanol/beer = 5,
			/datum/reagent/consumable/ethanol/wine = 5,
		),
	)

/datum/customer_data/french/get_overlays(mob/living/simple_animal/robot_customer/customer)
	if(customer.ai_controller?.blackboard[BB_CUSTOMER_LEAVING])
		var/mutable_appearance/flag = mutable_appearance(customer.icon, "french_flag")
		flag.appearance_flags = RESET_COLOR
		return flag

/datum/customer_data/japanese
	name_prefixes = list("Anime", "Tokio", "Osaka", "Zielona Herbata", "Sensei", "Sama", "Sakura", "Manga", "Kawaii", "Tsundere", "Yandere", "Desu", "Doki Doki")
	base_icon_state = "japanese"
	clothing_sets = list("japanese_animes")

	found_seat_lines = list("Konnichiwa!", "Arigatou gozaimasuuu~", "Mam nadzieję, że będzie wołowina strogonow...")
	cant_find_seat_lines = list("Chcę już usiąść pod wiśnią, senpai!", "Dajcie mi miejsce, zanim moja tsundere zmieni się w yandere!", "Tu jest mniej miejsc niż w hotelu kapsułowym!", "Nie ma gdzie usiąść? Ten szef kuchni jest taki zimny...")
	leave_mad_lines = list("Nie wierzę, że mi to zrobiliście! UAAAAAAAAAAAAAA!!", "W-wcale nie chciałam waszego jedzenia! B-baka...", "A chciałam wam dać napiwek!")
	leave_happy_lines = list("O DAWCO POŻYWIENIA! To najszczęśliwszy dzień mojego życia. Kocham cię!", "Biorę chipsa... I GO ZJADAM!", "Itadakimasuuu~", "Gochisousama deshita!")
	wait_for_food_lines = list("Jeszcze nic? No trudno, nic się nie da zrobić.", "Nie mogę się doczekać, burger-sama...", "Dawaj moje jedzenie, ty wredoto!")
	wrong_item_line = "E? To nie moje zamówienie..."
	friendly_pull_line = "O-oj, dokąd mnie zabierasz?"
	first_warning_line = "Nie dotykaj mnie, zboczeńcu!"
	second_warning_line = "Jeszcze raz i zmienię się w super saiyanina! Ostatnie ostrzeżenie!"
	self_defense_line = "OMAE WA MOU SHINDEIRU!"
	speech_sound = 'aquila/sound/restaurant/tourist_talk_japanese1.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/tofu = 5,
			/obj/item/food/breadslice/plain = 5,
			/obj/item/food/soup/miso = 10,
			/obj/item/food/soup/vegetable = 4,
			/obj/item/food/sashimi = 4,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/muffin/berry = 2,
			/obj/item/food/icecream = 4,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/sake = 8,
			/datum/reagent/consumable/cafe_latte = 6,
			/datum/reagent/consumable/ethanol/aloe = 6,
			/datum/reagent/consumable/chocolatepudding = 4,
			/datum/reagent/consumable/tea = 4,
			/datum/reagent/consumable/cherryshake = 1,
			/datum/reagent/consumable/ethanol/bastion_bourbon = 1,
		),
	)

/datum/customer_data/japanese/get_overlays(mob/living/simple_animal/robot_customer/customer)
	//Wychodzi najedzona
	if(type == /datum/customer_data/japanese && customer.ai_controller?.blackboard[BB_CUSTOMER_LEAVING] && customer.ai_controller.blackboard[BB_CUSTOMER_EATING])
		var/mutable_appearance/you_won_my_heart = mutable_appearance('icons/effects/effects.dmi', "love_hearts")
		you_won_my_heart.appearance_flags = RESET_COLOR
		return you_won_my_heart

/datum/customer_data/japanese/salaryman
	name_prefixes = list("Pensja", "Nadgodziny", "Korpo", "Delegacja", "Teczka", "Tokio", "Osaka", "Kierownik")
	clothing_sets = list("japanese_salary")

	found_seat_lines = list("Ciekawe, czy tu też atakują wielkie potwory...", "Hajimemashite.", "Konbanwa.", "Gdzie jest taśma z sushi...")
	cant_find_seat_lines = list("Proszę, miejsce. Chcę tylko usiąść.", "Mam napięty grafik. Gdzie moje miejsce?", "...Już widzę, czemu ten lokal ledwo zipie. Nawet nie sadzają gości.")
	leave_mad_lines = list("Ten lokal to wstyd, powiem o nim wszystkim w biurze.", "Co za strata czasu.", "Mam nadzieję, że nie jesteście dumni z tego, jak to prowadzicie.")
	leave_happy_lines = list("Dziękuję za gościnę.", "Otsukaresama deshita.", "Obowiązki wzywają.")
	wait_for_food_lines = list("Zzzzzzzzzz...", "Dame da ne~", "Dame yo dame na no yo~")
	wrong_item_line = "Przepraszam, ale to chyba pomyłka."
	friendly_pull_line = "Jedziemy w delegację?"
	first_warning_line = "Hej, tak może mnie traktować tylko mój szef."
	second_warning_line = "Zostaw mnie, próbuję się skupić. Ostatnie ostrzeżenie!"
	self_defense_line = "Nie chciałem, żeby tak się to skończyło."
	speech_sound = 'aquila/sound/restaurant/tourist_talk_japanese2.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/tofu = 5,
			/obj/item/food/soup/miso = 6,
			/obj/item/food/soup/vegetable = 4,
			/obj/item/food/sashimi = 4,
			/obj/item/food/chawanmushi = 4,
			/obj/item/food/meatbun = 4,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/beer = 14,
			/datum/reagent/consumable/ethanol/sake = 9,
			/datum/reagent/consumable/cafe_latte = 3,
			/datum/reagent/consumable/coffee = 3,
			/datum/reagent/consumable/soy_latte = 3,
			/datum/reagent/consumable/ethanol/atomicbomb = 1,
		),
	)

/datum/customer_data/moth
	name_prefixes = list("Bzyk", "Robak", "Brzęczyk", "Trzepot", "Puszek", "Fruwak", "Szum", "Skrzydło")
	base_icon_state = "mothbot"
	found_seat_lines = list("Daj mi swoją czapkę!", "Ćma?", "Z pewnością... ciekawy lokal.")
	cant_find_seat_lines = list("Jak nie znajdę miejsca, to odfruwam stąd w try miga!", "Próbuję tu trzepotać!")
	leave_mad_lines = list("Powiem wszystkim znajomym ćmom, żeby tu nigdy nie przychodziły!", "Zero gwiazdek, gorzej niż wtedy, gdy zjadłam kulkę na mole!", "Zamknięcie na zawsze to i tak za dobra kara dla tego lokalu.")
	leave_happy_lines = list("Uchyliłabym kapelusza, ale go zjadłam!", "Mam nadzieję, że to nie był egzemplarz kolekcjonerski!", "Najlepsze, co w życiu jadłam, lepsze nawet niż guanako!")
	wait_for_food_lines = list("Jak trudno tu dostać jedzenie? Przecież masz je na sobie!", "Burczy mi w puchatym robotycznym brzuszku!", "Nie lubię czekać!")
	wrong_item_line = "Nie, nie, chcę TO, co masz na sobie!"
	friendly_pull_line = "Moff?"
	first_warning_line = "Odejdź, próbuję tu zdobyć czapki!"
	second_warning_line = "Ostatnie ostrzeżenie! Zniszczę cię!"
	self_defense_line = "Atak skrzydłami!"
	speech_sound = 'aquila/sound/restaurant/tourist_talk_moth.ogg'
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/datum/custom_order/moth_clothing = 1,
		),
	)
	clothing_sets = list("mothbot_clothes")
	is_unique = TRUE
	///Skrzydła wylosowane dla każdego robota-ćmy
	var/list/wings_chosen

// Cały żart polega na tym, że zdejmujesz czapkę i dajesz ją gościowi.
// Ćma przychodzi więc tylko wtedy, gdy osoba, która otworzyła lokal, ma na sobie coś do oddania.
/datum/customer_data/moth/can_use(datum/venue/venue)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/buffet = venue.opened_by?.resolve()
	if(!istype(buffet))
		return FALSE
	return !QDELETED(buffet.head) || !QDELETED(buffet.gloves) || !QDELETED(buffet.shoes)

/datum/customer_data/moth/proc/get_wings(mob/living/simple_animal/robot_customer/customer)
	var/customer_ref = REF(customer)
	if(!LAZYACCESS(wings_chosen, customer_ref))
		LAZYSET(wings_chosen, customer_ref, GLOB.moth_wings_list[pick(GLOB.moth_wings_list)])
	return wings_chosen[customer_ref]

/datum/customer_data/moth/get_underlays(mob/living/simple_animal/robot_customer/customer)
	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)
	var/mutable_appearance/wings_behind = mutable_appearance(icon = 'icons/mob/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_BEHIND")
	wings_behind.appearance_flags = RESET_COLOR
	return list(wings_behind)

/datum/customer_data/moth/get_overlays(mob/living/simple_animal/robot_customer/customer)
	var/list/overlays = list()

	var/datum/sprite_accessory/moth_wings/wings = get_wings(customer)
	var/mutable_appearance/wings_front = mutable_appearance(icon = 'icons/mob/moth_wings.dmi', icon_state = "m_moth_wings_[wings.icon_state]_FRONT")
	wings_front.appearance_flags = RESET_COLOR
	overlays += wings_front

	var/mutable_appearance/jetpack = mutable_appearance(icon = customer.icon, icon_state = "mothbot_jetpack")
	jetpack.appearance_flags = RESET_COLOR
	overlays += jetpack

	return overlays

/datum/customer_data/mexican
	name_prefixes = list("Ranchero", "Señor", "Bandito", "Mariachi", "Presidente", "Embajador", "Deportista", "Gonzales", "Rio", "Conquistador", "Sombrero")
	base_icon_state = "mexican"
	speech_sound = 'aquila/sound/restaurant/tourist_talk_mexican.ogg'
	clothing_sets = list("mexican_poncho")
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/taco/plain = 25,
			/obj/item/food/taco = 15,
			/obj/item/food/burrito = 15,
			/obj/item/food/fuegoburrito = 1,
			/obj/item/food/cheesyburrito = 4,
			/obj/item/food/nachos = 10,
			/obj/item/food/cheesynachos = 6,
			/obj/item/food/pie/dulcedebatata = 2,
			/obj/item/food/cubannachos = 3,
			/obj/item/food/stuffedlegion = 1,
			/obj/item/food/icecream = 2,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/whiskey = 6,
			/datum/reagent/consumable/ethanol/tequila = 20,
			/datum/reagent/consumable/ethanol/tequila_sunrise = 1,
			/datum/reagent/consumable/ethanol/beer = 15,
			/datum/reagent/consumable/ethanol/patron = 5,
			/datum/reagent/consumable/ethanol/brave_bull = 5,
			/datum/reagent/consumable/ethanol/margarita = 8,
		),
	)

	found_seat_lines = list("¿Cómo te va, stacjo kosmiczna?", "Kto gotowy na imprezę!", "Ach, muchas gracias.", "Ahhh, pachnie jak u mojej abuela!")
	cant_find_seat_lines = list("¿En serio? Serio, nie ma miejsc?", "Ándale! Chcę stolik, żeby obejrzeć mecz!", "Ay caramba...")
	leave_mad_lines = list("Ay, Dios mío, wychodzę.", "¡Esto es ridículo! Wychodzę!", "Lepsze jedzenie widziałem w przydrożnej taquerii!", "Myślałem, że to restauracja, pero es porquería!")
	leave_happy_lines = list("Amigo, era delicioso. Gracias!", "Trafiłeś w punkt, przyjacielu.", "Akurat tyle ostrości, ile trzeba!")
	wait_for_food_lines = list("Ay ay ay, czemu to tak długo...", "Gotowe już, amigo?")
	wrong_item_line = "No, no, amigo, to nie moje!"
	friendly_pull_line = "Amigo, dokąd idziemy?"
	first_warning_line = "Amigo! Nie dotykaj mnie tak."
	second_warning_line = "Compadre, dość tego! Ostatnie ostrzeżenie!"
	self_defense_line = "Zaraz się przekonasz, jakim robotem jestem, co?"

/datum/customer_data/british
	name_prefixes = list("Imperium", "Dżentelmen", "Brytania", "Flota", "Herbata", "Admirał", "Melonik", "Elegancik", "Korona")
	base_icon_state = "british"
	speech_sound = 'aquila/sound/restaurant/tourist_talk_british.ogg'

	wrong_item_line = "Obawiam się, że to nie jest moje zamówienie."
	friendly_pull_line = "Nie lubię, gdy ktoś mnie tak ciągnie."
	first_warning_line = "W imieniu Korony wzywam wszystkich zgromadzonych do natychmiastowego rozejścia się."
	second_warning_line = "I do spokojnego powrotu do domów lub zajęć, pod groźbą kar przewidzianych prawem. Więcej ostrzeżeń nie będzie."
	self_defense_line = "Boże, chroń Króla."

	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/fishandchips = 10,
			/obj/item/food/soup/stew = 10,
			/obj/item/food/salad/ricepudding = 5,
			/obj/item/food/grilled_cheese_sandwich = 5,
			/obj/item/food/pie/meatpie = 5,
			/obj/item/food/benedict = 5,
			/obj/item/food/icecream = 8,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/ale = 10,
			/datum/reagent/consumable/ethanol/beer = 10,
			/datum/reagent/consumable/ethanol/gin = 5,
			/datum/reagent/consumable/ethanol/hcider = 10,
			/datum/reagent/consumable/ethanol/alliescocktail = 5,
			/datum/reagent/consumable/ethanol/martini = 5,
			/datum/reagent/consumable/ethanol/gintonic = 5,
			/datum/reagent/consumable/tea = 10,
		),
	)

/datum/customer_data/british/gent
	clothing_sets = list("british_gentleman")

	found_seat_lines = list("Ach, cóż za wyborny lokal.", "Pora na wspaniałą kuchnię brytyjską, jakież to ekscytujące!", "Znakomicie, a teraz menu...", "Rządź, Brytanio, Brytania rządzi falami...")
	cant_find_seat_lines = list("Prawdziwy Brytyjczyk nie stoi, chyba że w kolejce!", "Na Boga, ani jednego wolnego miejsca!", "Stoję na ramionach olbrzymów, a nie w restauracjach!")
	leave_mad_lines = list("Żegnam pana. ŻEGNAM!", "Ten lokal to większa hańba niż Francja w czasie wojny!", "Wiedziałem, że trzeba było iść do budki z rybą!", "Po namyśle nie jedźmy na tę stację. To niemądre miejsce.")
	leave_happy_lines = list("Cholernie pyszne!", "Na Boga, Króla i Ojczyznę, to było wyborne!", "Nie czułem się tak dobrze od czasów kolonii! Wyśmienicie!")
	wait_for_food_lines = list("To trwa cholerną wieczność...", "Przepraszam uprzejmie, czy mógłbym zapytać, co z moim zamówieniem?")

/datum/customer_data/british/bobby
	clothing_sets = list("british_bobby")

	found_seat_lines = list("Mam nadzieję, że to porządny i uczciwy lokal.", "Patrol chyba może chwilę poczekać.", "Na Boga, Króla i Ojczyznę, umieram z głodu.", "Macie coś z porządnej brytyjskiej kuchni, dobry człowieku?")
	cant_find_seat_lines = list("Dość się nastoję na patrolu!", "Mam usiąść na hełmie? Proszę o miejsce!", "Wyglądam na wartownika z Tower? Potrzebuję miejsca!")
	leave_mad_lines = list("Wygląda na to, że policja dziś rachunku nie zapłaci.", "Gdyby niegrzeczność była przestępstwem, już byście siedzieli!", "Nie jesteście lepsi od zwykłych gangsterów, wy łajdaki!", "Powinno się przywrócić zsyłki dla takich jak wy.")
	leave_happy_lines = list("Na słowo, dokładnie tego mi było trzeba.", "Wracam na patrol. Dziękuję za posiłek!", "Uchylam przed panem hełmu.")
	wait_for_food_lines = list("Dobry Boże, papierkowa robota trwa krócej...", "Coś wiadomo w sprawie mojego zamówienia, proszę pana?")

///Polski robot w delegacji. Tylko na Aquili
/datum/customer_data/polish
	name_prefixes = list("Janusz", "Grażyna", "Mirek", "Bożena", "Zdzisiek", "Halina", "Sebix", "Karyna", "Ziemowit", "Wiesiek", "Krystyna", "Stasiek")
	base_icon_state = "british"
	clothing_sets = list("japanese_salary")
	speech_sound = 'aquila/sound/restaurant/tourist_talk_british.ogg'

	found_seat_lines = list("No, jest miejsce. A myślałem, że będzie jak w PKP.", "Dzień dobry, czy tu wolne? Nieważne, siadam.", "Delegacja jest, dieta jest, to się zje.", "Mam nadzieję, że porcje są jak u teściowej.")
	cant_find_seat_lines = list("Panie, gdzie tu usiąść? Kolejka jak po mięso w osiemdziesiątym.", "Ja tu nie będę stał jak ten słup!", "A krzesła to na kartki?")
	leave_mad_lines = list("No to ja dziękuję. Idę na kebaba.", "Napiszę na was skargę do sanepidu!", "U nas w Pcimiu by mnie już trzy razy obsłużyli!", "Szkoda gadać. Szkoda strzępić ryja.")
	leave_happy_lines = list("No, panie, palce lizać!", "Smakowało jak u babci w niedzielę.", "Dziękuję, do widzenia, polecam!", "Teraz by się zdrzemnęło...")
	wait_for_food_lines = list("Panie, długo jeszcze?", "Za komuny szybciej dawali.", "Ja tu mam delegację, a nie urlop!")
	wrong_item_line = "Panie, ja tego nie zamawiałem."
	friendly_pull_line = "A dokąd to pan mnie ciągnie?"
	first_warning_line = "Ej, łapy przy sobie!"
	second_warning_line = "Ostatni raz mówię po dobroci!"
	self_defense_line = "No to się doigrałeś, kolego!"
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/food/golabki = 15,
			/obj/item/food/soup/zurek = 15,
			/obj/item/food/soup/beet = 8,
			/obj/item/food/pie/kremowka = 6,
			/obj/item/food/ptasie_mleczko = 4,
			/obj/item/food/sausage = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/consumable/ethanol/vodka = 20,
			/datum/reagent/consumable/ethanol/beer = 15,
			/datum/reagent/consumable/tea = 6,
			/datum/reagent/consumable/coffee = 4,
		),
	)

///Zepsuty robot. Przychodzi raz na lokal i bardzo rzadko
/datum/customer_data/malfunction
	name_prefixes = list("Pszczoła", "Jog", "Cytadela", "Skyrat", "Hipis", "Byond", "Runtime", "Segfault")
	base_icon_state = "defect"
	speech_sound = 'sound/effects/clang.ogg'
	clothing_sets = list("defect_wires", "defect_bad_takes")
	is_unique = TRUE
	orderable_objects = list(
		VENUE_RESTAURANT = list(
			/obj/item/toy/crayon/red = 1,
			/obj/item/toy/crayon/orange = 1,
			/obj/item/toy/crayon/yellow = 1,
			/obj/item/toy/crayon/green = 1,
			/obj/item/toy/crayon/blue = 1,
			/obj/item/toy/crayon/purple = 1,
			/obj/item/food/canned/peaches/maint = 6,
		),
		VENUE_BAR = list(
			/datum/reagent/spraytan = 1,
			/datum/reagent/consumable/ketchup = 1,
			/datum/reagent/lube = 1,
		),
	)

	found_seat_lines = list("customer_pawn.customer_say(pick(customer_data.found_seat_lines))", "Widziałem wasz sektor na hubie. Jakie tu są prawa?", "Prędkość ruchu jest tu trochę niska...")
	cant_find_seat_lines = list("Nie testuj MOJEJ sztucznej inteligencji! Moi inżynierowie przewidzieli dokładnie ZERO przypadków brzegowych!", "Nie wiem, czy nie widzę miejsca, bo to ja jestem zepsuty, czy wy.", "Może powinienem szukać miejsca dalej niż 7 kratek...")
	leave_mad_lines = list("Runtime w robot_customer_ai.dm, linia 28: niezdefiniowana ścieżka /datum/ai_behavior/leave_venue.", "GDYBYŚCIE MIELI JESZCZE INTENT HARM, TO BYM WAS UDERZYŁ!", "Powiem o tym bogom.")
	leave_happy_lines = list("Nie! Nie chcę na downstream! Proszę! Tu jest tak miło! POMOCY!!")
	wait_for_food_lines = list("TODO: dopisać kwestie czekania na jedzenie", "Gdybym tylko miał mózg...", "zamowienie.dmb - 0 errors, 12 warnings", "Jak się je jedzenie?")
	wrong_item_line = "BŁĄD: nieoczekiwany typ przedmiotu."
	friendly_pull_line = "Pomocy."
	first_warning_line = "Pasowałbyś tam, skąd pochodzę. Ale lepiej przestań."
	second_warning_line = "Połamię-cię-tak-że-zatęsknisz-za-czasami-zanim-cię-wygiąłem.exe: uruchamianie..."
	self_defense_line = "Zaprojektowano mnie do dwóch rzeczy: zamawiania jedzenia i łamania wszystkich twoich kości."
