// AQUILA - zlecenia cywilne i giełda materiałów, port z tgstation

// Kategorie zleceń cywilnych przypisywane pracom (/datum/job/var/bounty_types)
#define CIV_JOB_BASIC 1
#define CIV_JOB_ROBO 2
#define CIV_JOB_CHEF 3
#define CIV_JOB_SEC 4
#define CIV_JOB_DRINK 5
#define CIV_JOB_CHEM 6
#define CIV_JOB_MED_VIRO 7
#define CIV_JOB_SCI 8
#define CIV_JOB_ENG 9
#define CIV_JOB_MED 10
#define CIV_JOB_GROW 11
// kategorie Aquili dla prac NSV
#define CIV_JOB_MUNITIONS 12
#define CIV_JOB_PILOT 13
#define CIV_JOB_MINE 14
#define CIV_JOB_BRIDGE 15
#define CIV_JOB_JANITOR 16
#define CIV_JOB_RANDOM 17
/// Najwyższa kategoria losowana dla CIV_JOB_RANDOM
#define MAXIMUM_BOUNTY_JOBS 16

/// Ile globalnych zleceń jest zawsze na liście (bez premii za graczy)
#define CIV_BOUNTY_BASELINE 5
/// Procent nagrody, który dostaje wykonawca zlecenia
#define CIV_BOUNTY_SPLIT 30
/// Szansa, że nowe globalne zlecenie będzie priorytetowe (x1.5)
#define HIGH_PRIORITY_BOUNTY_ODDS 20
/// Część nagrody z kostki dla wykonawców (dzielona przy globalnych zleceniach)
#define BOUNTY_CUT_STANDARD 0.3
/// Podatek od kostki zleceń dla budżetów działów statku - stawka polskiego VAT
#define BOUNTY_VAT 0.23
/// Bazowy SSeconomy.bounty_modifier; nagrody cywilne skalują się względem niego, żeby premia stacji nadal działała
#define CIV_BOUNTY_MODIFIER_BASE 3

// Trendy na giełdzie materiałów
#define MARKET_TREND_UPWARD 1
#define MARKET_TREND_DOWNWARD -1
#define MARKET_TREND_STABLE 0
/// Szansa (%) na wydarzenie giełdowe dla każdego materiału przy każdym ticku
#define MARKET_EVENT_PROBABILITY 8

// Bazowa podaż materiałów na giełdzie
#define MATERIAL_QUANTITY_COMMON 5000
#define MATERIAL_QUANTITY_UNCOMMON 1000
#define MATERIAL_QUANTITY_RARE 200
#define MATERIAL_QUANTITY_EXOTIC 50
