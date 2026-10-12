// Port BeeStation/BeeStation-Hornet#13512: kursor w kształcie dłoni nad klikalnymi elementami HUD-u i przyciskami,
// a klikalne alerty dostają złotą obwódkę.
// Pominięte z oryginału: refaktor `skin` -> `base_icon_state` w przyciskach, zwinięcie stanów `busy` w access_controller
// (w oryginale psuje cykl śluzy) i zamiana spanów na makra w alertach mrówek.
// Bez obwódki dla alertu freonu, bo u nas nie ma on Click(). Typy, których u nas nie ma (navigate, combattoggle,
// succumb, leaning, bleeding, tazed, shapeshifted), też pominięte.

#define CLICKABLE_ALERT_GLOW_COLOR "#FFD700"

// HUD
/atom/movable/screen/movable/action_button
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ai
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/blob
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ghost
	mouse_over_pointer = MOUSE_HAND_POINTER

/// Odpowiednik `/atom/movable/screen/holoparasite` z Bee
/atom/movable/screen/guardian
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/human/toggle
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/human/equip
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ling/sting
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/pai
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/robot
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/swap_hand
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/craft
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/area_creator
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/language_menu
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/close
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/drop
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/mov_intent
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/pull
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/resist
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/rest
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/throw_catch
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/zone_sel
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/healthdoll
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/mood
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/component_button
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/buildmode
	mouse_over_pointer = MOUSE_HAND_POINTER

// Przyciski na ścianach
/obj/machinery/button
	mouse_over_pointer = MOUSE_HAND_POINTER

/obj/machinery/doorButtons
	mouse_over_pointer = MOUSE_HAND_POINTER

/obj/machinery/firealarm
	mouse_over_pointer = MOUSE_HAND_POINTER

/obj/machinery/light_switch
	mouse_over_pointer = MOUSE_HAND_POINTER

// Alerty, które coś robią po kliknięciu
/atom/movable/screen/alert
	/// Czy alert świeci, żeby pokazać, że kliknięcie coś robi
	var/clickable_glow = FALSE

/atom/movable/screen/alert/Initialize(mapload)
	. = ..()
	if(clickable_glow)
		add_filter("clickglow", 2, outline_filter(color = CLICKABLE_ALERT_GLOW_COLOR, size = 1))
		mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/alert/mind_control
	clickable_glow = TRUE

/atom/movable/screen/alert/embeddedobject
	clickable_glow = TRUE

/atom/movable/screen/alert/fire
	clickable_glow = TRUE

/atom/movable/screen/alert/give
	clickable_glow = TRUE

/atom/movable/screen/alert/hackingapc
	clickable_glow = TRUE

/atom/movable/screen/alert/notify_cloning
	clickable_glow = TRUE

/atom/movable/screen/alert/notify_action
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained/buckled
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained/handcuffed
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained/legcuffed
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/strandling
	clickable_glow = TRUE

/atom/movable/screen/alert/status_effect/ants
	clickable_glow = TRUE

#undef CLICKABLE_ALERT_GLOW_COLOR
