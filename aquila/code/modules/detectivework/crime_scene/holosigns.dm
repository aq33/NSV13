// AQUILA - holobariery miejsca zbrodni.
// 1. Rażąca holobariera detektywa (wzór: Paradise holosign_projector.dm i holosigns.dm, AGPL; ikony z Paradise).
// 2. Strefa miejsca zbrodni w projektorze ochrony (wzór: BeeStation crimesign.dm i holosign_creator.dm, AGPL;
//    ikony i dźwięk z Bee). Akcja projektora rysuje czerwoną ramkę wokół gracza i ogłasza strefę na kanale ochrony.

// ---- Holobariera detektywa ----

/obj/item/holosign_creator/detective
	name = "projektor barier śledczych"
	desc = "Holograficzny projektor detektywa. Stawia bariery miejsca zbrodni, które razią prądem każdego, kto je dotknie."
	icon = 'aquila/icons/obj/crime_scene/det_holosign.dmi'
	icon_state = "signmaker_det"
	holosign_type = /obj/structure/holosign/barrier/cyborg/hacked/detective
	creation_time = 1 SECONDS
	max_signs = 8

/obj/structure/holosign/barrier/cyborg/hacked/detective
	name = "bariera śledcza"
	desc = "Holograficzna bariera z napisem MIEJSCE ZBRODNI. Iskrzy od energii."
	icon = 'aquila/icons/obj/crime_scene/det_holosign.dmi'
	icon_state = "holosign_det"

// ---- Strefa miejsca zbrodni (crimesign) ----

/datum/action/item_action/toggle_crimesigns
	name = "Ogłoś strefę miejsca zbrodni"
	desc = "Wyświetla wokół ciebie holograficzną ramkę strefy zamkniętej i ogłasza ją na kanale ochrony."

/obj/item/holosign_creator/security
	actions_types = list(/datum/action/item_action/toggle_crimesigns)
	/// Czy ramka jest teraz wyświetlana
	var/active_crimesign = FALSE
	/// Hologramy ramki
	var/list/active_crimesign_barriers = list()
	/// Promień ramki w kratkach
	var/crimesign_range = 4
	/// Odnowienie funkcji
	var/crimesign_cooldown_length = 5 MINUTES
	/// Radio do ogłaszania strefy na kanale ochrony
	var/obj/item/radio/crimesign_radio
	COOLDOWN_DECLARE(crimesign_cooldown)

/obj/item/holosign_creator/security/Initialize(mapload)
	. = ..()
	crimesign_radio = new(src)
	crimesign_radio.listening = FALSE
	crimesign_radio.set_frequency(FREQ_SECURITY)

/obj/item/holosign_creator/security/Destroy()
	delete_crimesign(FALSE)
	QDEL_NULL(crimesign_radio)
	return ..()

/obj/item/holosign_creator/security/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Przycisk akcji ogłasza strefę miejsca zbrodni o promieniu [crimesign_range] kratek.</span>"

/obj/item/holosign_creator/security/ui_action_click(mob/user, datum/actiontype)
	if(!istype(actiontype, /datum/action/item_action/toggle_crimesigns))
		return ..()
	if(active_crimesign)
		delete_crimesign(FALSE)
		to_chat(user, "<span class='notice'>Wyłączasz strefę miejsca zbrodni.</span>")
		return
	if(!COOLDOWN_FINISHED(src, crimesign_cooldown))
		say("Błąd. Projektor ładuje się jeszcze [DisplayTimeText(COOLDOWN_TIMELEFT(src, crimesign_cooldown))].")
		return
	spawn_crimesign(user)

/obj/item/holosign_creator/security/proc/spawn_crimesign(mob/user)
	var/turf/center = get_turf(user)
	if(!center)
		return
	// Ramka = kwadrat o promieniu R bez kwadratu o promieniu R-1.
	var/list/border = RANGE_TURFS(crimesign_range, center) - RANGE_TURFS(crimesign_range - 1, center)
	for(var/turf/open/floor/candidate in border)
		if(is_blocked_turf(candidate, TRUE))
			continue
		active_crimesign_barriers += new /obj/effect/crimesign(candidate, center, crimesign_range)
	playsound(user, 'aquila/sound/effects/crimesignalarm.ogg', 10, FALSE, 4)
	crimesign_radio.talk_into(src, "Uwaga: [user] ogłasza strefę zamkniętą w: [get_area_name(center, TRUE)].")
	say("OSOBY POSTRONNE MAJĄ OPUŚCIĆ TEN TEREN.")
	active_crimesign = TRUE
	COOLDOWN_START(src, crimesign_cooldown, crimesign_cooldown_length)
	addtimer(CALLBACK(src, PROC_REF(delete_crimesign), TRUE), crimesign_cooldown_length / 1.2)

/obj/item/holosign_creator/security/proc/delete_crimesign(fizzled)
	if(!active_crimesign)
		return
	QDEL_LIST(active_crimesign_barriers)
	active_crimesign = FALSE
	if(fizzled)
		say("Błąd. Ładunek wyczerpany.")

/obj/effect/crimesign
	name = "holoznak ochrony"
	desc = "Holograficzne oznaczenie na podłodze: trwa akcja ochrony. Lepiej się nie wtrącać."
	icon = 'aquila/icons/obj/crime_scene/crimesign.dmi'
	icon_state = "crimesign"
	anchored = TRUE
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = "#ff2466"
	light_range = 1
	light_power = 0.25

/obj/effect/crimesign/Initialize(mapload, turf/source, size)
	. = ..()
	if(source)
		align(source, size)
	alpha = 100
	add_filter("bloom", 1, list(type = "bloom", size = 0.5, offset = 0.1, alpha = 200))
	update_icon()

/obj/effect/crimesign/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]-emissive", layer, alpha)

/// Dobiera róg albo prosty odcinek ramki zależnie od położenia względem środka.
/obj/effect/crimesign/proc/align(turf/source, size)
	var/top = y >= source.y + size
	var/bottom = y <= source.y - size
	var/right = x >= source.x + size
	var/left = x <= source.x - size
	if(top || bottom)
		if(right || left)
			icon_state = "crimesign_corner"
			if(top)
				dir = right ? NORTH : EAST
			else
				dir = right ? SOUTH : WEST
			return
		icon_state = "crimesign_straight"
		dir = top ? NORTH : SOUTH
		return
	icon_state = "crimesign_straight"
	dir = right ? EAST : WEST
