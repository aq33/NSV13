// AQUILA - Eldritch Horror chemical counter (Yogstation#13033)
/atom/movable/screen/horror_chemicals
	name = "chemikalia"
	icon = 'aquila/icons/mob/screen_horror.dmi'
	icon_state = "horror_counter"
	screen_loc = ui_lingchemdisplay

/datum/hud/chemical_counter
	ui_style = 'icons/mob/screen_midnight.dmi'
	var/atom/movable/screen/horror_chemicals/chemical_counter

/datum/hud/chemical_counter/New(mob/owner)
	. = ..()
	chemical_counter = new /atom/movable/screen/horror_chemicals
	infodisplay += chemical_counter

/datum/hud/chemical_counter/Destroy()
	. = ..()
	QDEL_NULL(chemical_counter)
