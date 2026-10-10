#define STYLE_STANDARD 1
#define STYLE_BLUESPACE 2
#define STYLE_CENTCOM 3
#define STYLE_SYNDICATE 4
#define STYLE_BLUE 5
#define STYLE_CULT 6
#define STYLE_MISSILE 7
#define STYLE_RED_MISSILE 8
#define STYLE_BOX 9
#define STYLE_HONK 10
#define STYLE_FRUIT 11
#define STYLE_INVISIBLE 12
#define STYLE_GONDOLA 13
#define STYLE_SEETHROUGH 14
#define STYLE_PIRATE 15 //NSV13 - added pirate drop pod

#define MAX_EMAG_ROCKETS 8
#define BEACON_COST 500
#define SP_LINKED 1
#define SP_READY 2
#define SP_LAUNCH 3
#define SP_UNLINK 4
#define SP_UNREADY 5
#define ORDER_COOLDOWN (10 SECONDS)

#define POD_SHAPE 1
#define POD_BASE 2
#define POD_DOOR 3
#define POD_DECAL 4
#define POD_GLOW 5
#define POD_RUBBLE_TYPE 6
#define POD_NAME 7
#define POD_DESC 8

#define RUBBLE_NONE 1
#define RUBBLE_NORMAL 2
#define RUBBLE_WIDE 3
#define RUBBLE_THIN 4

#define POD_SHAPE_NORML 1
#define POD_SHAPE_OTHER 2

#define POD_TRANSIT "1"
#define POD_FALLING "2"
#define POD_OPENING "3"
#define POD_LEAVING "4"

#define SUPPLYPOD_X_OFFSET -16

GLOBAL_LIST_EMPTY(supplypod_loading_bays)

//NSV13 - added pirate drop pod
GLOBAL_LIST_INIT(podstyles, list(\
	list(POD_SHAPE_NORML, "pod",         TRUE, "default", "yellow",   RUBBLE_NORMAL, "supply pod",     "Kapsuła zaopatrzeniowa Nanotrasen."),\
	list(POD_SHAPE_NORML, "advpod",      TRUE, "bluespace", "blue",     RUBBLE_NORMAL, "bluespace supply pod" ,     "Kapsuła zaopatrzeniowa bluespace Nanotrasen. Po dostawie teleportuje się z powrotem do Centrali."),\
	list(POD_SHAPE_NORML, "advpod",      TRUE, "centcom", "blue",     RUBBLE_NORMAL, "\improper CentCom supply pod", "Kapsuła zaopatrzeniowa Nanotrasen z oznaczeniami Centrali. Po dostawie teleportuje się z powrotem do Centrali."),\
	list(POD_SHAPE_NORML, "darkpod",     TRUE, "syndicate", "red",      RUBBLE_NORMAL, "blood-red supply pod", "Groźnie wyglądająca kapsuła zaopatrzeniowa pokryta krwistoczerwonymi oznaczeniami Syndykatu. Lepiej się od niej odsunąć."),\
	list(POD_SHAPE_NORML, "darkpod",     TRUE, "deathsquad", "blue",     RUBBLE_NORMAL, "\improper Deathsquad drop pod",     "Kapsuła zrzutowa Nanotrasen z oznaczeniami elitarnego oddziału uderzeniowego Nanotrasen."),\
	list(POD_SHAPE_NORML, "pod",         TRUE, "cultist", "red",      RUBBLE_NORMAL, "bloody supply pod",     "Kapsuła zaopatrzeniowa Nanotrasen pokryta zadrapaniami, krwią i dziwnymi runami."),\
	list(POD_SHAPE_OTHER, "missile",     FALSE, FALSE, FALSE,   RUBBLE_THIN,     "cruise missile", "Wielki pocisk, który chyba nie wybuchł do końca. Pewnie wystrzelono go z jakiegoś odległego silosu rakietowego w głębokim kosmosie. Z boku jest dodatkowy luk ładunkowy, ale ręczne otwarcie go jest raczej niemożliwe."),\
	list(POD_SHAPE_OTHER, "smissile",    FALSE, FALSE,         FALSE,   RUBBLE_THIN,     "\improper Syndicate cruise missile", "Wielki, krwistoczerwony pocisk, który chyba nie wybuchł do końca. Pewnie wystrzelono go z jakiegoś silosu rakietowego Syndykatu w głębokim kosmosie. Z boku jest dodatkowy luk ładunkowy, ale ręczne otwarcie go jest raczej niemożliwe."),\
	list(POD_SHAPE_OTHER, "box",         TRUE, FALSE,            FALSE,   RUBBLE_WIDE, "\improper Aussec supply crate", "Niezwykle wytrzymała skrzynia zaopatrzeniowa, zaprojektowana, by przetrwać wejście w atmosferę. Na boku wygrawerowano „Aussec Armory - 2532”."),\
	list(POD_SHAPE_NORML, "clownpod",    TRUE, "clown", "green",    RUBBLE_NORMAL, "\improper HONK pod",     "Jaskrawo kolorowa kapsuła zaopatrzeniowa. Pewnie pochodzi od Federacji Klaunów."),\
	list(POD_SHAPE_OTHER, "orange",      TRUE, FALSE, FALSE,   RUBBLE_NONE,     "\improper Orange", "Rozgniewana pomarańcza."),\
	list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,     "\improper S.T.E.A.L.T.H. pod MKVII", "Kapsuła zaopatrzeniowa, która w normalnych warunkach jest całkowicie niewykrywalna konwencjonalnymi metodami. Jak ty to w ogóle widzisz?"),\
	list(POD_SHAPE_OTHER, "gondola",     FALSE, FALSE, FALSE,   RUBBLE_NONE,     "gondola",     "Cichy wędrowiec. Ten wydaje się należeć do firmy kurierskiej."),\
	list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,         FALSE,      FALSE,      "rl_click", "give_po"),\
	list(POD_SHAPE_NORML, "ratpod",		 TRUE, "pirate", "yellow",		RUBBLE_NORMAL, "tortugan boarding pod",			"Zdalne wiertło górnicze z ładunkiem. To przerobiono do abordażu przez piratów z Tortugi.")\
))

