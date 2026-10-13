// Kierunkowe światło leżących przedmiotów zgodne ze sprite'em i obrotem z rozrzutu (item_scatter.dm).
// Latarka na podłodze świeci tam, gdzie wskazuje jej sprite, a nie w swój dir (po rzucie to kierunek lotu).

/obj/item
	/// W którą stronę świeci sprite leżącego przedmiotu z kierunkowym światłem. null = jego dir.
	var/light_sprite_dir

/obj/item/flashlight
	light_sprite_dir = WEST

/obj/item/flashlight/seclite
	light_sprite_dir = EAST

/obj/item/flashlight/pen
	light_sprite_dir = SOUTHEAST

/obj/item/gun
	light_sprite_dir = EAST

/datum/component/overlay_lighting
	/// Jednokierunkowe wersje stożka, żeby nie dziedziczył dir trzymającego
	var/static/list/cone_icons

/// Kierunek rzutu światła: dla leżącego przedmiotu kierunek sprite'a obrócony o scatter_angle
/datum/component/overlay_lighting/proc/get_cast_dir(base_dir)
	var/obj/item/item = current_holder
	if(!istype(item) || !isturf(item.loc))
		return base_dir
	var/sprite_dir = item.light_sprite_dir || base_dir
	if(!item.scatter_angle)
		return sprite_dir
	return angle2dir(dir2angle(sprite_dir) + item.scatter_angle)

/datum/component/overlay_lighting/proc/get_cone_icon(cone_dir)
	if(!cone_icons)
		cone_icons = list()
		for(var/each_dir in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			cone_icons["[each_dir]"] = icon('icons/effects/light_overlays/light_cone.dmi', "light", each_dir)
	return cone_icons["[cone_dir]"]

/datum/component/overlay_lighting/proc/on_holder_scatter_rotated(obj/item/source)
	SIGNAL_HANDLER
	if(source != current_holder)
		return
	set_direction(get_cast_dir(source.dir))
