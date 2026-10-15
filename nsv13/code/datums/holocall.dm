/obj/item/disk/holodisk/hammerhead_cryo
	name = "Engineering Audit Log HH-593"
	desc = "A holodisk containing a recording of a work order being carried out during servicing."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Almayer Gervais
	DELAY 10
	SAY Powiedz mi, czemu zwalamy kupę łóżek stazy do kwater?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY A czemu NT robi cokolwiek dziwnego? Pewnie mają jakieś opóźnienie w projekcie.
	DELAY 10
	SAY I zamiast przyznać się do błędu, wysyłają cokolwiek. Nawet jeśli kompletnie nie trzyma specyfikacji.
	DELAY 20
	NAME Almayer Gervais
	PRESET /datum/preset_holoimage/engineer/rig
	SAY Brzmi dość podle.
	DELAY 5
	SAY No trudno, zlecenie to zlecenie. Wszystkie podłączone?
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY No, wszystkie gotowe. Następne jest, eee... coś o rurze transportowej?
	DELAY 15
	SAY A kogo to obchodzi, ruszajmy
	DELAY 20
	PRESET /datum/preset_holoimage/corgi
	NAME Burst Data
	LANGUAGE /datum/language/machine
	SAY POCZĄTEK METADANYCH NTINTEL
	SAY NAGRANO 12-17-0000
	SAY KLAUZULA BEZPIECZEŃSTWA: JAWNE
	SAY KONIEC METADANYCH NTINTEL
"}

/obj/item/disk/holodisk/enterprise_log
	name = "SGC Enterprise Audit Log CV-9654"
	desc = "It has a large label on it reading 'CLASSIFIED' underneath a symbol of a large sun surrounded by wings."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Joshua Griggs
	DELAY 10
	SAY Masz chwilę? Pomóż mi wyjąć ten obwód. Cholerstwo się zaklinowało
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY Spróbuj śrubokrętem.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY Dzięki. Właściwie czemu wyrywamy te przekaźniki osłon?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY Ciszej, szeregowy. To tajne. Ale coś ci powiem... Nie powierzyłbym załodze Nanotrasen niczego bardziej skomplikowanego niż spinacz.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY To prawda... ale nie uważasz, że to trochę nieuczciwe, że to przed nimi ukrywamy?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY Wiedza tylko dla upoważnionych. Centrala pożycza im ten statek ze względów humanitarnych i tyle. Szczerze mówiąc, Syndykat otwarcie wypowiedział wrogość tylko Nanotrasen, nie nam. To w ogóle nie jest problem SolGovu.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY Może i tak. Po prostu mi się to nie podoba. Mam tylko nadzieję, że załoga, która odziedziczy ten statek, dobrze o niego zadba.
	DELAY 20
	PRESET /datum/preset_holoimage/captain
	NAME Dayton Lux
	SAY Szeregowi, macie robotę do zrobienia. Koniec gadania, idźcie do wręgi 5 J-7, kierownik chce was widzieć.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY Tak jest!
	DELAY 20
	SAY POCZĄTEK METADANYCH
	SAY NAGRANO 12-17-0000
	SAY KLAUZULA BEZPIECZEŃSTWA: TAJNE
	SAY KONIEC METADANYCH
"}

/obj/item/disk/holodisk/enterprise_log/two
	name = "SGC Enterprise Audit Log CV-9658"
	desc = "A diskette with a symbol of a large sun surrounded by wings. A date has been hastily scrawled onto it with a permanent marker."
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Stewart Lance
	DELAY 20
	SAY To... słyszałeś o nowej klasie statków NT, Hammerhead?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Słyszałem, że są duże. I co z tego?
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY No wiesz, te, które zastąpiły tę ich okropną klasę Aegis...
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Nie bardzo. To nie mój dział. Jestem tu, żeby utrzymywać statki SolGovu, a nie martwić się tym, co, do diabła, kombinuje Nanotrasen.
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY W sumie racja... ale plotka głosi, że prototyp Hammerheada zbudowano w tydzień. Przynajmniej tak słyszałem od kuzyna Francisa.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY W tydzień!? Jak, do diabła, można zaprojektować i zbudować statek w tydzień?!
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY I słuchaj tego... prototyp Aegisa zrobiono w weekend.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Jezu. Wiedziałem, że NT lubi iść na skróty, ale to już przesada. Zaczynam myśleć, że dobrze wybrałem, zaciągając się do SolGovu.
	DELAY 20
	PRESET /datum/preset_holoimage/captain
	NAME Dayton Lux
	SAY Inżynierze, badaczu. Skończyliście już sprzątać Akule? Kierownik potrzebuje kogoś do rozładunku promu towarowego.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Tak jest. Zajmę się tym.
	DELAY 20
	SAY POCZĄTEK METADANYCH
	SAY NAGRANO 12-19-0000
	SAY KLAUZULA BEZPIECZEŃSTWA: TAJNE
	SAY KONIEC METADANYCH
"}

/datum/preset_holoimage/curator
	outfit_type = /datum/outfit/job/curator

/obj/item/disk/holodisk/galactica_history
	name = "SGC Solaria History #1 - A battleship to surpass them all!"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 1
	SAY WITAMY NA SOLARII.
	NAME Joe 'Schlomo' Speedwagon
	SAY Witamy na SGV Solaria! Jestem Joe i będę waszym przewodnikiem.
	DELAY 30
	SAY To pierwsza z kilku informacyjnych holotaśm nagranych przez VICKER media na zlecenie Rządu Solarnego.
	DELAY 30
	SAY Naszą podróż zaczynamy 30 lat temu, gdy zbudowano ten statek. Zaprojektowano go jako pancernik, który miał stanąć na czele floty SolGovu w odpowiedzi na agresywną ekspansję militarną Nanotrasen w latach 2210., i dysponował imponującą siłą ognia.
	DELAY 30
	SAY Szacunki stawiają siłę ognia tego statku na równi z trzema lekkimi krążownikami Nanotrasen klasy Aegis, jednak od tamtej pory wycofano go ze służby i ze względu na znaczenie historyczne zamieniono w muzeum!
	DELAY 30
	SAY W następnej części dowiecie się o znaczeniu Solarii w kilku kluczowych konfliktach. A na razie do widzenia! I miłego zwiedzania muzeum...
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/galactica_history/history
	name = "SGC Solaria History #2 - Historical significance"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria, part 2 in the series."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 2
	SAY WITAMY NA SOLARII.
	NAME Joe 'Schlomo' Speedwagon
	SAY Witamy na SGV Solaria! Jestem Joe i będę waszym przewodnikiem.
	DELAY 30
	SAY To druga część z kilku informacyjnych holotaśm nagranych przez VICKER media na zlecenie Rządu Solarnego.
	DELAY 30
	SAY Solaria brała udział w wielu potyczkach granicznych, jednak jako że stworzono ją głównie jako statek pokojowy, rzadko widziała ciężkie walki.
	DELAY 30
	SAY Najsłynniejszym jej wyczynem było zadanie miażdżącego ciosu jowiszowym siatkom porywaczy felinidów, gdy w pojedynkę stawiła czoła całej flocie transportowców!
	DELAY 30
	SAY Niestety, na dziś to wszystko. Obejrzyjcie następną część, by poznać specyfikację techniczną Solarii. A na razie do widzenia! I miłego zwiedzania muzeum...
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/galactica_history/tech_specs
	name = "SGC Solaria History #3 - Technical Specifications"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria, the final part in the series."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 3
	SAY WITAMY NA SOLARII.
	NAME Joe 'Schlomo' Speedwagon
	SAY Witamy na SGV Solaria! Jestem Joe i będę waszym przewodnikiem.
	DELAY 30
	SAY To ostatnia z kilku informacyjnych holotaśm nagranych przez VICKER media na zlecenie Rządu Solarnego.
	DELAY 30
	SAY W ostatniej części opowiedziałem wam o bogatej historii Solarii, a teraz czas na technikę!
	DELAY 30
	SAY Solaria może się pochwalić 8 działami Gaussa, 4 elektromagnetycznymi działami szynowymi i jeszcze większą liczbą wyrzutni torped!
	DELAY 30
	SAY Ma wytrzymać wybuch termojądrowy o mocy do 200 Mt, choć nigdy tego nie sprawdzono!
	DELAY 30
	SAY Solaria jest zdolna do dalekich podróży z prędkością nadświetlną, a w szczytowym okresie miała eksperymentalny stormdrive klasy 2, zdolny dostarczać megawaty mocy! Niestety po wycofaniu ze służby stormdrive Solarii zastąpiono stabilniejszym reaktorem rozszczepieniowym.
	DELAY 30
	SAY Dziękuję, że wyruszyliście ze mną w tę podróż, i mam nadzieję, że wasza pogoń za wiedzą się tu nie kończy! W muzeum jest mnóstwo materiałów do czytania, możecie też obejrzeć niektóre działy statku, zachowane dokładnie tak, jak używano ich 30 lat temu!
	DELAY 30
	SAY Tu Joe Speedwagon, bez odbioru.
	SAY KONIEC SERII.
"}

//Nsv galactica 3 log files!
/obj/item/disk/holodisk/nsv_history
	name = "VICKER educational chronicles issue #1 - The fall of Dolos"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 1
	SAY WITAMY NA NSV GALACTICA.
	NAME David 'Record Keeper' Bregg
	SAY Witamy w kronikach edukacyjnych VICKER media! W tej serii dowiecie się wszystkiego o kluczowych wydarzeniach historycznych, tak jak się wydarzyły.
	DELAY 20
	SAY Edytuj mnie!
	DELAY 30
	SAY Naszą podróż zaczynamy 30 lat temu, gdy zbudowano ten statek. Zaprojektowano go jako pancernik, który miał stanąć na czele floty SolGovu w odpowiedzi na agresywną ekspansję militarną Nanotrasen w latach 2210., i dysponował imponującą siłą ognia.
	DELAY 30
	SAY Szacunki stawiają siłę ognia tego statku na równi z trzema lekkimi krążownikami Nanotrasen klasy Aegis, jednak od tamtej pory wycofano go ze służby i ze względu na znaczenie historyczne zamieniono w muzeum!
	DELAY 30
	SAY W następnej części dowiecie się o znaczeniu Solarii w kilku kluczowych konfliktach. A na razie do widzenia! I miłego zwiedzania muzeum...
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/nsv_history/galactica
	name = "NSV Galactica History #1 - Introduction!"
	desc = "An informational holodisk carrying information about the history of the NSV Galactica."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 1
	SAY WITAMY NA NSV GALACTICA.
	NAME Senior Fleetyard Engineer Beck
	SAY NSV Galactica, pierwotnie rozwijana pod nazwą „Iowa”, to obecny okręt flagowy Nanotrasen. Ważąca 500 000 ton jest największym statkiem w czynnej służbie!
	DELAY 20
	SAY Trzecia z linii wielkich okrętów noszących imię Galactica, ta wersja jest zdecydowanie najbardziej niszczycielska w swoim rodzie.
	DELAY 30
	SAY Wywodząca się z SGV Solaria, dawnego okrętu flagowego SolGovu, pierwotna Galactica pływała krótko kilka lat temu, a jej rejs zakończył się bitwą o Tartar, w której bohaterski inżynier Patel wysadził planetę w imię korporacji.
	DELAY 30
	SAY Patel poświęcił się, by zniszczyć ośrodek programowania uśpionych agentów Syndykatu, jednak wkrótce potem rejs pierwotnej Galactiki dobiegł końca, gdy dosięgła ją fala wybuchu.
	DELAY 30
	SAY Po zniszczeniu Galactiki szabrownicy CaracalCorp natychmiast przystąpili do prac ratunkowych. Całe działy zostały rozerwane, ale pozostały względnie nienaruszone...
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/nsv_history/galactica/two
	name = "NSV Galactica History #2 - Breakthroughs"
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 2
	SAY WITAMY NA NSV GALACTICA.
	NAME Senior Fleetyard Engineer Beck
	SAY Gdy prace ratunkowe zakończyły się przez ingerencję Syndykatu, pozostałe części dawnej Solarii odesłano do stoczni.
	DELAY 20
	SAY Inżynierowie TitanWerks od kilku lat badają wraki i dokonali ważnego odkrycia... Zanim SolGov przekazał nam Solarię, by stała się Galacticą, ogołocił ją ze wszystkich swoich charakterystycznych technologii.
	DELAY 30
	SAY Okazało się, że statek wciąż miał nienaruszone wszystkie punkty ogniskowe potrzebne do generowania osłon, mimo że usunięto cały aparat projekcji osłon.
	DELAY 30
	SAY Choć nie mogę fizycznie nagrać zbyt szczegółowo danych technicznych statku, mogę powiedzieć tyle: Galactica jest jedyna w swoim rodzaju.
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/nsv_history/galactica/three
	name = "NSV Galactica History #3 - Firepower"
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	SAY WCZYTYWANIE HOLOTAŚMY INFORMACYJNEJ NR 2
	SAY WITAMY NA NSV GALACTICA.
	NAME Senior Fleetyard Engineer Beck
	SAY NSV Galactica to okręt wojenny. Raczej nie znajdziecie tu luksusów; zbudowano ją w jednym celu i w nim się wyróżnia.
	DELAY 20
	SAY NSV Galactica ma 4 baterie główne z 8 działami Gaussa NT-BSG, 6 działami artylerii morskiej NT-HOOD i eksperymentalną artylerią bluespace.
	DELAY 30
	SAY Obok imponującej artylerii fizycznej wiązka artylerii bluespace to nowy przełom w technologii bluespace, który wcale nie narusza żadnych sankcji SolGovu!
	DELAY 30
	SAY Galacticę zbudowano w bezpośredniej odpowiedzi na agresję Syndykatu i jest wyposażona, by zrównywać z ziemią zarówno kolonie, jak i całe floty.
	DELAY 30
	SAY Na tym kończymy naszą miniserię o danych technicznych, miłego zwiedzania reszty muzeum!
	DELAY 30
	SAY KONIEC NAGRANIA. WŁÓŻ NASTĘPNĄ DYSKIETKĘ.
"}

/obj/item/disk/holodisk/pdsr
	name = "Project 'Zelbinion' Operational Notes (CLASSIFIED)"
	desc = "A holodisk plastered with 'classified' labels, the name has been somewhat redacted."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Almayer Gervais
	DELAY 10
	SAY Ta holotaśma i jej zawartość są objęte klauzulą ARD poziomu C8.
	DELAY 20
	SAY Przed kontynuowaniem upewnij się, że pomieszczenie jest zamknięte. Poza oficerem flagowym inżynierii nie powinien być obecny żaden oficer.
	DELAY 20
	SAY Masz 15 sekund na wykonanie polecenia.
	DELAY 150
	SAY Projekt Zelbinion to reaktor ekranu obronnego. Działa poprzez projekcję utwardzonych cząstek wokół statku.
	DELAY 50
	SAY Reaktor zasilany jest Nukleum, produktem ubocznym rozszczepienia jądrowego wzbogaconego plazmą.
	DELAY 50
	SAY Po uruchomieniu reaktor musi pracować bez przerwy aż do wyłączenia. Strumienia cząstek nie można przerwać, inaczej grozi to emisją.
	DELAY 50
	SAY Projekt Zelbinion ma automatyczne procedury wyłączania, które powinny zapobiec awarii przyczynowości, jednak twój statek NIE wyjdzie z tego bez szwanku.
	DELAY 50
	SAY Reaktor obsługuje się z dwóch konsol. Używaj ich razem, by sterować reakcją.
	DELAY 50
	SAY Pierwszym parametrem, który kontrolujesz, jest moc wejściowa. Nie przekraczaj podanej mocy maksymalnej i nie schodź poniżej minimalnej. Grozi to emisją.
	DELAY 50
	SAY Zwiększając moc wejściową, zwiększasz też zdolność PDSR do projekcji cząstek wokół statku, co daje silniejszy ekran cząstek.
	DELAY 50
	SAY Kolejną zmienną reakcji, którą kontrolujesz, jest tempo wtrysku Nukleum. Wyższe tempo, podobnie jak moc, daje silniejszą osłonę.
	DELAY 50
	SAY Wtrysk Nukleum można gwałtownie zwiększyć dla szybkiego wzmocnienia w walce, ale uwaga: zdestabilizuje to reaktor.
	DELAY 50
	SAY Samymi zmiennymi osłony można sterować osobno. Wykorzystaj to na swoją korzyść.
	DELAY 50
	SAY Na stabilność reaktora wpływa polaryzacja reakcji. W razie potrzeby przełączaj polaryzację wtrysku z ujemnej na dodatnią, by utrzymać polaryzację jak najbliżej 0.
	DELAY 50
	SAY Jeśli musisz wyłączyć reaktor, powoli zmniejszaj tempo wtrysku Nukleum. W sytuacji awaryjnej możesz przepłukać chłodziwo, by szybko schłodzić reaktor.
	DELAY 50
	SAY Reakcję można zakończyć, gdy rdzeń reaktora ma poniżej 200 stopni Celsjusza. Zadbaj o odpowiednie chłodzenie, by to osiągnąć.
	DELAY 50
	SAY Na koniec: jeśli minimalna moc wejściowa zacznie zbliżać się do maksymalnej, zmierzasz ku emisji. Natychmiast to napraw albo bezpiecznie wyłącz reaktor.
	DELAY 50
	SAY W razie utraty Iowy Główny Inżynier jest upoważniony do zniszczenia PDSR za pomocą dołączonego terminalu usuwania dowodów.
	DELAY 50
	SAY Wykonaj swój obowiązek. Ta taśma powinna zostać zniszczona po użyciu. Technologia osłon nie istnieje. Chwała Nanotrasen.
	NAME Burst Data
	LANGUAGE /datum/language/machine
	DELAY 20
	SAY POCZĄTEK METADANYCH
	SAY NAGRANO 5-25-0000
	SAY KLAUZULA BEZPIECZEŃSTWA: ARD-C8 TAJNE
	SAY KONIEC METADANYCH
"}
