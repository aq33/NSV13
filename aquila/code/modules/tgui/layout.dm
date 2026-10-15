// Port z BeeStation #13072: układ siatka/lista w oknach automatów i lodówek.
// Bee trzyma wybór w preferencjach (tgui_layout); do czasu przeniesienia Preferences Redux
// pamiętamy go tylko na czas sesji klienta.

#define TGUI_LAYOUT_GRID "grid"
#define TGUI_LAYOUT_LIST "list"

/datum
	/// Which layout choice the UI of this datum uses (tgui_layout or tgui_layout_smartfridge in Bee)
	var/layout_prefs_used = "tgui_layout"

/client
	/// layout_prefs_used key -> TGUI_LAYOUT_GRID or TGUI_LAYOUT_LIST, for this session only
	var/list/tgui_layouts

/// The layout the user picked for the UI of src_object
/proc/get_tgui_layout(mob/user, datum/src_object)
	return LAZYACCESS(user?.client?.tgui_layouts, src_object.layout_prefs_used) || TGUI_LAYOUT_GRID

/// Stores the layout picked with the toggle in the window
/proc/set_tgui_layout(mob/user, datum/src_object, new_state)
	if(!user?.client || !(new_state in list(TGUI_LAYOUT_GRID, TGUI_LAYOUT_LIST)))
		return
	LAZYSET(user.client.tgui_layouts, src_object.layout_prefs_used, new_state)

#undef TGUI_LAYOUT_GRID
#undef TGUI_LAYOUT_LIST
