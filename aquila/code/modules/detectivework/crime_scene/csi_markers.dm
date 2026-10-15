// AQUILA - numerowane znaczniki dowodów (wzór: Baystation12 scene_cards.dm, AGPL; ikony z Baya).
// Plastikowe karty 1-7 kładzione przy dowodach. Leżą nad mobami, więc można oznaczyć też ciało.

#define CSI_MARKER_COUNT 7

/obj/item/csi_marker
	name = "znacznik dowodu"
	desc = "Plastikowa karta do oznaczania dowodów na miejscu zdarzenia. Zupełnie jak w holoserialach!"
	icon = 'aquila/icons/obj/crime_scene/csi_markers.dmi'
	icon_state = "card1"
	w_class = WEIGHT_CLASS_TINY
	layer = ABOVE_MOB_LAYER // żeby dało się oznaczyć ciało
	resistance_flags = FLAMMABLE
	/// Numer na karcie
	var/number = 1

/obj/item/csi_marker/Initialize(mapload, new_number)
	. = ..()
	if(new_number)
		number = new_number
	number = clamp(number, 1, CSI_MARKER_COUNT)
	name = "znacznik dowodu nr [number]"
	icon_state = "card[number]"
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/csi_marker/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ma na sobie dużą cyfrę [number].</span>"

/obj/item/storage/box/csi_markers
	name = "pudełko znaczników dowodów"
	desc = "Kartonowe pudełko na numerowane znaczniki dowodów 1-7."
	icon = 'aquila/icons/obj/crime_scene/csi_markers.dmi'
	icon_state = "cards"
	illustration = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/csi_markers/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = CSI_MARKER_COUNT
	STR.can_hold = typecacheof(list(/obj/item/csi_marker))

/obj/item/storage/box/csi_markers/PopulateContents()
	for(var/i in 1 to CSI_MARKER_COUNT)
		new /obj/item/csi_marker(src, i)

#undef CSI_MARKER_COUNT
