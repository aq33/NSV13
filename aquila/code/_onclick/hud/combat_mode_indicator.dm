/*
 * Wskaźnik combat mode dla mobów, których HUD nie ma przełącznika walki (simple animale, antagi-zwierzęta itp.),
 * a combat mode zmienia ich zachowanie. Ustaw combat_mode_indicator = TRUE na typie moba, a po wejściu gracza
 * w HUD pojawi się przełącznik walki albo, przy preferencji starych intencji, wybór help/harm
 * (podmianą zajmuje się refresh_intent_selector() z legacy_intents.dm).
 */

/mob/living
	/// Czy dołożyć do HUD przełącznik combat mode, jeśli HUD tego moba go nie ma
	var/combat_mode_indicator = FALSE

/mob/living/create_mob_hud()
	. = ..()
	if(combat_mode_indicator && hud_used && !hud_used.action_intent)
		hud_used.add_combat_mode_indicator()

/datum/hud/proc/add_combat_mode_indicator()
	action_intent = create_combat_mode_selector()
	static_inventory += action_intent
	if(hud_shown)
		mymob.client?.screen += action_intent
	refresh_intent_selector()
