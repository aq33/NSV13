// Port BeeStation #8776 (Preferences Redux): okno PreferencesMenu na naszych danych (preferences2, bity toggles, active_character)

/// Preferencja zapisana w aktywnej postaci (active_character)
#define PREFERENCE_CHARACTER "character"
/// Preferencja gracza, wspólna dla wszystkich postaci
#define PREFERENCE_PLAYER "player"

#define PREFERENCE_TAB_CHARACTER_PREFERENCES 0
#define PREFERENCE_TAB_GAME_PREFERENCES 1
#define PREFERENCE_TAB_KEYBINDINGS 2

/// Duże przyciski z ikoną obok podglądu, widoczne tylko gdy gatunek ma daną cechę
#define PREFERENCE_CATEGORY_FEATURES "features"
/// Duże przyciski z ikoną obok podglądu, zawsze widoczne
#define PREFERENCE_CATEGORY_CLOTHING "clothing"
/// Lista ustawień postaci, niezależna od gatunku
#define PREFERENCE_CATEGORY_NON_CONTEXTUAL "non_contextual"
/// Ustawienia gry (druga strona okna)
#define PREFERENCE_CATEGORY_GAME_PREFERENCES "game_preferences"
/// Lista ustawień postaci zależnych od gatunku
#define PREFERENCE_CATEGORY_SECONDARY_FEATURES "secondary_features"
/// Ustawienie doczepione do przycisku z kategorii features/clothing (np. kolor włosów)
#define PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES "supplemental_features"
#define PREFERENCE_CATEGORY_NAMES "names"
#define PREFERENCE_CATEGORY_MISC "misc"

#define SUPPLEMENTAL_FEATURE_KEY "supplemental_feature"

#define PREFERENCE_SHEET_NORMAL "preferences"
#define PREFERENCE_SHEET_LARGE "preferences_l"
#define PREFERENCE_SHEET_HUGE "preferences_h"

/// Ustawienia losowania w oknie (RandomSetting we froncie)
#define RANDOM_ANTAG_ONLY 1
#define RANDOM_DISABLED 2
#define RANDOM_ENABLED 3
