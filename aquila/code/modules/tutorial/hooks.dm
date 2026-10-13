// Sygnały, na które czeka skrypt samouczka. Nadpisania z ..(), bez zmian w rdzeniu

/mob/toggle_move_intent(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOB_MOVE_INTENT_CHANGED, m_intent)

/mob/living/set_resting(rest, silent = TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_RESTING_CHANGED, rest)

/mob/living/carbon/update_internals_hud_icon(internal_state = 0)
	. = ..()
	SEND_SIGNAL(src, COMSIG_CARBON_INTERNALS_CHANGED, internal_state)
