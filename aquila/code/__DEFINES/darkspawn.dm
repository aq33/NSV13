// AQUILA - darkspawn (port z Yogstation, wersja sprzed przeróbki z 2024)

#define DARKSPAWN_MUNDANE 0
#define DARKSPAWN_DIVULGED 1
#define DARKSPAWN_PROGENITOR 2

/// Światło tej mocy blokuje leczenie i powoli parzy
#define DARKSPAWN_DIM_LIGHT 0.2
/// Światło tej mocy szybko pali
#define DARKSPAWN_BRIGHT_LIGHT 0.3
/// Ile obrażeń każdego typu leczy się na tick w ciemności
#define DARKSPAWN_DARK_HEAL 5
/// Ile oparzeń dostaje na tick w świetle
#define DARKSPAWN_LIGHT_BURN 7

#define COLOR_DARKSPAWN_PSI "#7264FF"

/// Mindlink darkspawnów i welonów (:j, bo :w to u nas kanał radia)
#define MODE_DARKSPAWN "mindlink"
#define MODE_KEY_DARKSPAWN "j"

#define SPECIES_DARKSPAWN "darkspawn"

#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isveil(A) (A?.mind?.has_antag_datum(/datum/antagonist/veil))
#define is_darkspawn_or_veil(A) (isdarkspawn(A) || isveil(A))
