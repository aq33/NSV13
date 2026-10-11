// AQUILA - port BeeStation/BeeStation-Hornet#11938 (screentips), w wersji z obecnego Bee (bez tymczasowych ikon dla 516 z #13029)

#define HINT_ICON_FILE 'aquila/icons/ui_icons/screentips/cursor_hints.dmi'
#define HINT_TOOL_ICON_FILE 'aquila/icons/ui_icons/screentips/tool_hints.dmi'

/// Stores the cursor hint icons for screentip context.
GLOBAL_LIST_INIT_TYPED(screentip_context_icons, /image, prepare_screentip_context_icons())

// AQUILA: tekst zamiast ikonek myszy i narzędzi. Ikonki w maptexcie rosły z powiększeniem mapy szybciej niż tekst
// i wychodziły za duże; napisy skalują się jak reszta podpowiedzi.
GLOBAL_VAR_INIT(lmb_icon, "<b>LPM:</b>")
GLOBAL_VAR_INIT(rmb_icon, "<b>PPM:</b>")
GLOBAL_VAR_INIT(hint_screwdriver, "(śrubokręt)")
GLOBAL_VAR_INIT(hint_wrench, "(klucz)")
GLOBAL_VAR_INIT(hint_crowbar, "(łom)")
GLOBAL_VAR_INIT(hint_wirecutters, "(przecinak)")
GLOBAL_VAR_INIT(hint_welder, "(spawarka)")
GLOBAL_VAR_INIT(hint_multitool, "(multitool)")
GLOBAL_VAR_INIT(hint_knife, "(nóż)")
GLOBAL_VAR_INIT(hint_rolling_pin, "(wałek)")

/proc/prepare_screentip_context_icons()
	var/list/output = list()
	for(var/state in icon_states(HINT_ICON_FILE))
		output[state] = image(HINT_ICON_FILE, icon_state = state)
	for(var/state in icon_states(HINT_TOOL_ICON_FILE))
		output[state] = image(HINT_TOOL_ICON_FILE, icon_state = state)
	return output

#define SCREEN_TIP_ALLOWED "#a9f59d"
#define SCREEN_TIP_REJECTED "#e39191"
#define SCREEN_TIP_NORMAL "#daf3f2"
#define SCREEN_TIP_INACCESSIBLE "#a1b6b5"

/// Layer for screentips, above the rest of the HUD (action buttons included)
#define SCREENTIP_LAYER (HUD_LAYER + 1)

#define FIRE_PRIORITY_SCREENTIPS 5 // Don't spend a lot of time on this

// COMSIG_ATOM_ADD_CONTEXT jest w code/__DEFINES/dcs/signals/signals_atom.dm (używa go processable.dm w core)
/// from base of atom/on_mouse_enter(): (atom/hovered)
#define COMSIG_ATOM_MOUSE_ENTERED "mouse_entered"

// ============================
// Auto-tips: Developer QOL
// ============================

GLOBAL_LIST_EMPTY(screentip_contextless_items)

GLOBAL_LIST_INIT(screentips_cache, init_autotips())

#define SCREENTIP_ATTACK_HAND(type, message) /datum/screentip_cache##type/attack_hand = "\n" + "<span class='maptext'><span style='line-height: 0.35; color:" + SCREEN_TIP_NORMAL + "'><center>%LMB% " + message + "</center></span></span>"

/proc/init_autotips()
	. = list()
	for (var/datum/screentip_cache/type as anything in subtypesof(/datum/screentip_cache))
		// Parent type, not a real type
		if (!initial(type.attack_hand))
			continue
		var/path = text2path(copytext("[type]", 23))
		var/datum/screentip_cache/cache = new type
		cache.attack_hand = replacetext(cache.attack_hand, "%LMB%", GLOB.lmb_icon)
		.["[path]"] = cache
		for (var/subtype in subtypesof(path))
			if (!.["[subtype]"])
				.["[subtype]"] = cache
