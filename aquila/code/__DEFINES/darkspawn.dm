// AQUILA - darkspawn (port z Yogstation, wersja po przeróbce Yogstation#20581)

#define DARKSPAWN_MUNDANE 0
#define DARKSPAWN_DIVULGED 1
#define DARKSPAWN_PROGENITOR 2

// Klasy
#define DARKSPAWN_SCOUT (1<<0)
#define DARKSPAWN_FIGHTER (1<<1)
#define DARKSPAWN_WARLOCK (1<<2)
#define ALL_DARKSPAWN_CLASSES (DARKSPAWN_SCOUT | DARKSPAWN_FIGHTER | DARKSPAWN_WARLOCK)

// Zakładki sklepu Psi Web
/// Zdolności, które komuś robią krzywdę
#define STORE_OFFENSE "offense"
/// Zdolności pomocnicze
#define STORE_UTILITY "utility"
/// Ulepszenia działające cały czas
#define STORE_PASSIVE "passives"

/// Z umysłu: kupno zdolności z Psi Web (datum/psi_web typepath)
#define COMSIG_DARKSPAWN_PURCHASE_POWER "purchase_power"
/// Z umysłu: ulepszenie istniejącej zdolności (flaga)
#define COMSIG_DARKSPAWN_UPGRADE_ABILITY "upgrade_ability"
/// Z umysłu: cofnięcie ulepszenia zdolności (flaga)
#define COMSIG_DARKSPAWN_DOWNGRADE_ABILITY "downgrade_ability"

// Ulepszenia laski czarnoksiężnika i macek wojownika
#define STAFF_UPGRADE_CONFUSION (1<<0)
#define STAFF_UPGRADE_HEAL (1<<1)
#define STAFF_UPGRADE_LIGHTEATER (1<<2)
#define STAFF_UPGRADE_EXTINGUISH (1<<3)
#define TENDRIL_UPGRADE_TWIN (1<<4)
#define TENDRIL_UPGRADE_CLEAVE (1<<5)
#define STAFF_UPGRADE_EFFICIENCY (1<<6)

/// Światło tej mocy blokuje leczenie i powoli parzy
#define DARKSPAWN_DIM_LIGHT 0.2
/// Światło tej mocy szybko pali
#define DARKSPAWN_BRIGHT_LIGHT 0.3

#define COLOR_DARKSPAWN_PSI "#7264FF"
#define COLOR_VELVET "#21007F"

/// Mindlink darkspawnów i thralli (:j, bo :w to u nas kanał radia)
#define MODE_DARKSPAWN "mindlink"
#define MODE_KEY_DARKSPAWN "j"

#define SPECIES_DARKSPAWN "darkspawn"

// Cechy na datum antagonisty darkspawna (nie na mobie)
/// Odporność na przyćmione światło
#define TRAIT_DARKSPAWN_LIGHTRES "darkspawn_lightres"
/// Pełna ochrona przed światłem (Całun, mgła)
#define TRAIT_DARKSPAWN_CREEP "darkspawn_creep"
/// Wstaje po śmierci w ciemności
#define TRAIT_DARKSPAWN_UNDYING "darkspawn_undying"
/// Wsparcie thralli działa też na innych darkspawnów
#define TRAIT_DARKSPAWN_BUFFALLIES "darkspawn_buffallies"
/// Psi się nie odnawia
#define TRAIT_DARKSPAWN_PSIBLOCK "darkspawn_psiblock"
/// Na mobie: wola już wyssana, kolejne wyssanie nie daje woli ani jasności
#define TRAIT_DARKSPAWN_DEVOURED "darkspawn_devoured"

#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isthrall(A) (A?.mind?.has_antag_datum(/datum/antagonist/thrall))
#define ispsyche(A) (A?.mind?.has_antag_datum(/datum/antagonist/psyche))
#define is_darkspawn_or_thrall(A) (isdarkspawn(A) || isthrall(A))
/// Gniazdo organu dla guza cienia w głowie
#define ORGAN_SLOT_BRAIN_TUMOR "brain_tumor"
