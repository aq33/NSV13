#define MAX_TIMER 10 HOURS //Permabrig.
#define PRESET_SHORT 5 MINUTES
#define PRESET_MEDIUM 10 MINUTES
#define PRESET_LONG 15 MINUTES

#define CRIME_MINOR "Minor"
#define CRIME_MISDEMEANOUR "Misdemeanour"
#define CRIME_MAJOR "Major"
#define CRIME_CAPITAL "Capital"

/* This is overwritten by the config (space_law.json as of writting this), this only exists as a backup in case the game fails to load said file.
Do not modify this unless you know what you're doing. */

/datum/crime
	var/name
	var/tooltip
	var/colour
	var/icon
	var/sentence
	var/category

/datum/crime/minor
	category = CRIME_MINOR
	sentence = PRESET_SHORT
	colour="yellow"

/datum/crime/minor/assault
	name = "Assault"
	icon = "hand-rock"
	tooltip = "Użycie siły fizycznej wobec kogoś bez widocznego zamiaru zabicia go."

/datum/crime/minor/pickpocketting
	name = "Pickpocketting"
	icon = "mask"
	tooltip = "Kradzież przedmiotów z osoby innego człowieka."

/datum/crime/minor/minor_vandalism
	name = "Minor Vandalism"
	icon = "house-damage"
	tooltip = "Uszkodzenie, zniszczenie lub trwałe oszpecenie niekrytycznych mebli, automatów lub mienia osobistego."

/datum/crime/minor/vigilantism
	name = "Vigilantism"
	icon = "user-secret"
	tooltip = "Wykonywanie obowiązków i zadań działu ochrony bez zgody lub uzasadnionej przyczyny."

/datum/crime/minor/illegal_distribution
	name = "Illegal Distribution"
	icon = "joint"
	tooltip = "Posiadanie niebezpiecznych lub nielegalnych narkotyków/sprzętu w ilości większej niż rozsądna do użytku osobistego."

/datum/crime/minor/disturbing
	name = "Disturbing the Peace"
	icon = "fist-raised"
	tooltip = "Świadome organizowanie ruchu, który zakłóca normalną pracę działu."

/datum/crime/minor/negligence
	name = "Negligence"
	icon = "low-vision"
	tooltip = "Zaniedbanie obowiązków w stopniu, który może spowodować krzywdę, chorobę lub inne negatywne skutki dla innej osoby."

/datum/crime/minor/trespass
	name = "Trespass"
	icon = "walking"
	tooltip = "Przebywanie w obszarze, do którego dana osoba nie została celowo wpuszczona, nie ma dostępu lub z którego kazała jej wyjść osoba mająca do niego dostęp."

/datum/crime/minor/breaking_and_entering
	name = "Breaking and Entering"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru z użyciem siłowego wejścia."

/datum/crime/minor/discriminatory_language
	name = "Discriminatory Language"
	icon = "comment-slash"
	tooltip = "Używanie języka, który poniża, uogólnia lub w inny sposób odczłowiecza osobę, do której jest skierowany."

/datum/crime/minor/fine_evasion
	name = "Fine Evasion"
	icon = "dollar-sign"
	tooltip = "Celowe unikanie lub odmowa zapłaty legalnej grzywny."

/datum/crime/minor/religious_activity
	name = "Religious Activity outside of the chapel"
	icon = "cross"
	tooltip = "Nawracanie, prozelityzm, odprawianie rytuałów lub inne próby działania w imieniu religii lub bóstwa poza kaplicą."

/datum/crime/misdemeanour
	category = CRIME_MISDEMEANOUR
	sentence = PRESET_MEDIUM
	colour="orange"

/datum/crime/misdemeanour/aggravated_assault
	name = "Aggravated Assault"
	icon = "user-injured"
	tooltip = "Podjęcie działań fizycznych wobec osoby z zamiarem ciężkiego zranienia, ale nie zabicia."

/datum/crime/misdemeanour/theft
	name = "Theft"
	icon = "mask"
	tooltip = "Kradzież sprzętu lub przedmiotów z miejsca pracy albo przedmiotów o nadzwyczajnej wartości z osoby."

/datum/crime/misdemeanour/vandilism
	name = "Major Vandalism"
	icon = "house-damage"
	tooltip = "Zniszczenie lub uszkodzenie niekrytycznych mebli, automatów lub mienia osobistego w sposób, którego nie da się naprawić."

/datum/crime/misdemeanour/conspiracy
	name = "Conspiracy"
	icon = "user-friends"
	tooltip = "Świadoma współpraca z inną osobą w celu popełnienia czynu niezgodnego z prawem."

/datum/crime/misdemeanour/hostile_agent
	name = "Hostile Agent"
	icon = "user-ninja"
	tooltip = "Świadome działanie jako rekruter, przedstawiciel, posłaniec, sojusznik, dobroczyńca lub inny współpracownik wrogiej organizacji w rozumieniu Kodeksu 405 (EOTC)."

/datum/crime/misdemeanour/contraband
	name = "Contraband Equipment Possession"
	icon = "briefcase"
	tooltip = "Posiadanie sprzętu niezatwierdzonego do użytku lub produkcji na stacjach Nanotrasen. Obejmuje to sprzęt wytwarzany przez Syndykat, Federację Czarodziejów lub inną wrogą organizację w rozumieniu Kodeksu 405 (EOTC)."

/datum/crime/misdemeanour/rioting
	name = "Rioting"
	icon = "fist-raised"
	tooltip = "Działanie jako członek grupy, która wspólnie dopuszcza się poważnego wandalizmu, sabotażu, wielkiego sabotażu lub innych zbrodni."

/datum/crime/misdemeanour/negligence
	name = "High Negligence"
	icon = "blind"
	tooltip = "Zaniedbanie obowiązków w stopniu, który może spowodować krzywdę wielu osób lub działu albo w sposób, który bezpośrednio prowadzi do poważnego obrażenia innej osoby wymagającego pilnej pomocy medycznej."

/datum/crime/misdemeanour/tresspass
	name = "Trespass, Inherently Dangerous Areas"
	icon = "door-closed"
	tooltip = "Wtargnięcie do obszaru, które może prowadzić do zranienia siebie lub innych."

/datum/crime/misdemeanour/entering
	name = "Breaking and Entering, Inherently Dangerous Areas"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru, które może prowadzić do zranienia siebie lub innych, z użyciem siłowego wejścia."

/datum/crime/misdemeanour/insubordination
	name = "Insubordination"
	icon = "hand-middle-finger"
	tooltip = "Świadome nieposłuszeństwo wobec zgodnego z prawem rozkazu przełożonego."

/datum/crime/misdemeanour/fraud
	name = "Fraud"
	icon = "comment-dollar"
	tooltip = "Wprowadzanie w błąd co do swoich zamiarów w celu uzyskania mienia lub pieniędzy od innej osoby."

/datum/crime/misdemeanour/genetic_mutilation
	name = "Genetic Mutilation"
	icon = "dna"
	tooltip = "Celowa modyfikacja kodu genetycznego osoby bez jej zgody lub z zamiarem wyrządzenia krzywdy."

/datum/crime/major
	category = CRIME_MAJOR
	sentence = PRESET_LONG
	colour="bad"

/datum/crime/major/murder
	name = "Murder"
	icon = "skull"
	tooltip = "Celowe zabicie kogoś."

/datum/crime/major/larceny
	name = "Larceny"
	icon = "mask"
	tooltip = "Kradzież rzadkiego, drogiego (przedmioty o wartości ponad 1000 kredytów) lub zastrzeżonego sprzętu z obszarów chronionych lub z osoby."

/datum/crime/major/sabotage
	name = "Sabotage"
	icon = "bomb"
	tooltip = "Zniszczenie mienia lub zasobów stacji krytycznych dla normalnych lub awaryjnych procedur stacji albo doprowadzenie do tego, że części stacji nie nadają się do zamieszkania."

/datum/crime/major/conspiracy
	name = "High Conspiracy"
	icon = "users"
	tooltip = "Świadoma współpraca z inną osobą w celu popełnienia poważnego lub cięższego przestępstwa."

/datum/crime/major/hostile
	name = "Hostile Activity"
	icon = "thumbs-down"
	tooltip = "Świadome popełnienie czynu sprzecznego z interesami Nanotrasen albo bezpośrednia pomoc znanemu wrogowi korporacji."

/datum/crime/major/contraband
	name = "Possession, Illegal Inherently Dangerous Equipment"
	icon = "exclamation-triangle"
	tooltip = "Posiadanie zastrzeżonego lub nielegalnego sprzętu, którego głównym przeznaczeniem jest krzywdzenie innych lub powodowanie dużych zniszczeń."

/datum/crime/major/riot
	name = "Inciting a Riot"
	icon = "fist-raised"
	tooltip = "Podejmowanie działań mających wywołać duże niepokoje, aż po zamieszki włącznie."

/datum/crime/major/manslaughter
	name = "Manslaughter"
	icon = "book-dead"
	tooltip = "Nieumyślne zabicie kogoś w wyniku niedbałych, lecz nie złośliwych działań."

/datum/crime/major/tresspass
	name = "Trespass, High Security Areas"
	icon = "running"
	tooltip = "Wtargnięcie bez odpowiedniego pozwolenia lub dostępu do któregokolwiek z poniższych: obszarów dowództwa, gabinetów, zbrojowni, produkcji broni, magazynów materiałów wybuchowych, produkcji materiałów wybuchowych lub innych obszarów o wysokim stopniu zabezpieczenia."

/datum/crime/major/break_enter
	name = "Breaking and Entering, High Security Areas"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru chronionego w rozumieniu Kodeksu 309 (Wtargnięcie, obszary wysokiego bezpieczeństwa) z użyciem siłowego wejścia."

/datum/crime/major/dereliction
	name = "Dereliction"
	icon = "walking"
	tooltip = "Umyślne porzucenie obowiązku krytycznego dla dalszego funkcjonowania stacji."

/datum/crime/major/fraud
	name = "Corporate Fraud"
	icon = "hand-holding-usd"
	tooltip = "Wprowadzanie w błąd co do swoich zamiarów w celu uzyskania mienia lub pieniędzy od Nanotrasen albo uzyskiwanie lub przekazywanie mienia lub pieniędzy Nanotrasen bez odpowiedniego upoważnienia."

/datum/crime/major/impersonation
	name = "Identity Theft"
	icon = "theater-masks"
	tooltip = "Podszywanie się pod inną osobę."

/datum/crime/capital
	category = CRIME_CAPITAL
	sentence = MAX_TIMER
	colour = "grey"

/datum/crime/capital/murder
	name = "Prime Murder"
	icon = "skull-crossbones"
	tooltip = "Popełnienie morderstwa z wyraźnym zamiarem zabicia oraz wyraźnym zamiarem lub faktycznymi działaniami mającymi uniemożliwić wskrzeszenie ofiary"

/datum/crime/capital/larcany
	name = "Grand Larceny"
	icon = "mask"
	tooltip = "Kradzież z natury niebezpiecznych przedmiotów z ich magazynu, z osoby lub zdobycie ich w inny nielegalny sposób."

/datum/crime/capital/sabotage
	name = "Grand Sabotage"
	icon = "bomb"
	tooltip = "Zniszczenie lub modyfikacja mienia lub sprzętu stacji, bez których stacja może się zawalić lub w inny sposób przestać nadawać się do zamieszkania."

/datum/crime/capital/espionage
	name = "Espionage"
	icon = "user-secret"
	tooltip = "Świadome zdradzenie krytycznych informacji wrogom stacji."

/datum/crime/capital/enemy
	name = "Enemy of the Corporation"
	icon = "user-alt-slash"
	tooltip = "Członkostwo w którejkolwiek z poniższych organizacji: wrogie grupy abordażowe, czarodzieje, roje zmiennokształtnych, kulty."

/datum/crime/capital/contraband
	name = "Possession, Corporate Secrets"
	icon = "file-invoice"
	tooltip = "Posiadanie tajnej dokumentacji lub odpornych na manipulację urządzeń do przechowywania danych o dużej gęstości (czarnych skrzynek) dowolnej organizacji bez zgody Nanotrasen."

/datum/crime/capital/subversion
	name = "Subversion of the Chain of Command"
	icon = "link"
	tooltip = "Zakłócanie łańcucha dowodzenia przez zabójstwo oficera dowodzącego lub nielegalne ogłoszenie się oficerem dowodzącym."

/datum/crime/capital/biological
	name = "Biological Terror"
	icon = "biohazard"
	tooltip = "Świadome uwolnienie, spowodowanie lub doprowadzenie w inny sposób do skażenia stacji chorobą, rośliną lub inną formą biologiczną, która może rozprzestrzeniać się bez kontroli i/lub powodować poważne obrażenia fizyczne."

#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG
