/obj/item/paper/pamphlet
	name = "pamphlet"
	icon_state = "pamphlet"
	show_written_words = FALSE


/obj/item/paper/pamphlet/violent_video_games
	name = "pamphlet - \'Violent Video Games and You\'"
	desc = "A pamphlet encouraging the reader to maintain a balanced lifestyle and take care of their mental health, while still enjoying video games in a healthy way. You probably don't need this..."
	default_raw_text = "Nie każą wam zabijać ludzi. No, powiedzieliśmy to. A teraz wracajcie do pracy!"

/obj/item/paper/pamphlet/gateway
	default_raw_text = "<b>Witamy w Projekcie Brama Nanotrasen...</b><br>Gratulacje! Jeśli to czytasz, ty i twoi przełożeni uznaliście, że jesteś gotów poświęcić życie kolonizowaniu falistych wzgórz odległych światów. Musisz być gotów na życie pełne przygód, odrobinę ciężkiej pracy i nagradzany plan stomatologiczny – ale to nie wszystko, co Projekt Brama Nanotrasen ma do zaoferowania.<br><br>Ponieważ nam na tobie zależy, uważamy, że uczciwie jest upewnić się, że znasz ryzyko, zanim zdecydujesz się dołączyć do Projektu Brama Nanotrasen. Wszystkie odległe miejsca docelowe zostały w pełni zeskanowane przez zespół ekspedycyjny Nanotrasen i mają certyfikat 100% bezpieczeństwa. Zostawiliśmy nawet skrzynkę kosmicznego piwa wraz z podstawowymi materiałami, których będziesz potrzebować, by poszerzyć obszar działalności Nanotrasen i zacząć nowe życie.<br><br><b>Podstawy obsługi Bramy</b><br>Wszystkie zatwierdzone przez Nanotrasen Bramy działają na tych samych podstawowych zasadach. Zasilane są, jak można się spodziewać, z sieci zasilania sprzętu w danym obszarze, a bez tego zasilania nie mogą bezpiecznie działać i odrzucają wszelkie próby uruchomienia.<br><br>Gdy Brama zostanie prawidłowo skonfigurowana i będzie miała dość mocy, zacznie szukać miejsca wyjścia. Czas trwania jest zmienny, ale interfejs Bramy poda szacunek z dokładnością do minuty. Utrata zasilania nie przerwie procesu wyszukiwania. Grypa nie przerwie procesu wyszukiwania. Anomalie czasowe mogą sprawić, że szacunek będzie niedokładny, ale nie przerwą procesu wyszukiwania.<br><br><b>Życie po drugiej stronie</b><br>Po przejściu przez Bramę możesz odczuwać pewną dezorientację. Nie panikuj. To normalny skutek uboczny przebywania ogromnych odległości w krótkim czasie. Rozejrzyj się po najbliższej okolicy i spróbuj odnaleźć swoją darmową skrzynkę kosmicznego piwa. Nasze zespoły ekspedycyjne zapewniły pełne bezpieczeństwo wszystkich odległych miejsc, ale w nielicznych przypadkach ustanowiona przez nie Brama może nie być od razu widoczna. Nie panikuj, jeśli nie możesz znaleźć Bramy powrotnej. Rozpocznij kolonizację miejsca docelowego.<br><br><b>Nowy świat</b><br>Jako uczestnik Projektu Brama Nanotrasen będziesz na granicach kosmosu. Choć pełne bezpieczeństwo jest zapewnione, uczestnikom zaleca się przygotowanie na nieprzyjazne środowisko."

//we don't want the silly text overlay!
/obj/item/paper/pamphlet/update_icon()
	return
