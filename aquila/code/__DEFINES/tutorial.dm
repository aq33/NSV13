// Samouczek Aquili (rdzeń z cmss13-devs/cmss13#5030 i późniejszych poprawek)

/// Mob jest w samouczku albo samouczek się dla niego ładuje
#define TRAIT_IN_TUTORIAL "in_tutorial"
/// Źródło traitów nadawanych przez samouczek
#define TRAIT_SOURCE_TUTORIAL "tutorial"

/// Pobiera śledzony obiekt samouczka do zmiennej o podanej nazwie
#define TUTORIAL_ATOM_FROM_TRACKING(path, varname) var##path/##varname = tracking_atoms[##path]

/// Czy klient ukończył samouczek o danym ID
#define IS_TUTORIAL_COMPLETED(client, tutorial_id) (client?.prefs && (tutorial_id in client.prefs.completed_tutorials))

/// Wysyłany do moba samouczka, gdy zmienia się cel w panelu Status: (objective_text)
#define COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE "mob_tutorial_update_objective"
/// Wysyłany do moba, gdy coś (np. obiekt na mapie) ma zakończyć jego samouczek: ()
#define COMSIG_MOB_END_TUTORIAL "mob_end_tutorial"

/// Z /mob/toggle_move_intent(): (new_intent)
#define COMSIG_MOB_MOVE_INTENT_CHANGED "mob_move_intent_changed"
/// Z /mob/living/set_resting(): (resting)
#define COMSIG_LIVING_RESTING_CHANGED "living_resting_changed"
/// Z /mob/living/carbon/update_internals_hud_icon(): (internal_state)
#define COMSIG_CARBON_INTERNALS_CHANGED "carbon_internals_changed"
/// Wysyłany przez przedmioty samouczka, gdy gracz ich użyje: (mob/user)
#define COMSIG_TUTORIAL_ITEM_USED "tutorial_item_used"
