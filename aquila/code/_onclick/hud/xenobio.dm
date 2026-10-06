// AQUILA - port tgstation/tgstation#90775: HUD konsoli ksenobiologii (małpy, szlamy, załadowana mikstura)

#define FORMAT_XENOBIO_HUD_MAPTEXT(text_to_use) MAPTEXT("<span style='text-align: center; line-height: 1.9;'>[text_to_use]</span>")
#define POTION_DROP_SPEED 5

/// Used to show how many monkeys & slimes are in the console
/atom/movable/screen/xenobio_console
	name = "Magazyn małp i szlamów"
	icon = 'aquila/icons/mob/screen/xenobio.dmi'
	icon_state = "xenobio_console"
	screen_loc = ui_xenobiodisplay
	var/atom/movable/screen/xenobio_potion/potion_hud
	var/atom/movable/screen/xenobio_potion/potion_launcher

/atom/movable/screen/xenobio_console/Initialize(mapload)
	. = ..()
	potion_hud = new()
	potion_hud.layer = layer - 1
	vis_contents += potion_hud
	potion_launcher = new()
	potion_launcher.layer = layer - 2
	vis_contents += potion_launcher

/atom/movable/screen/xenobio_console/Destroy()
	vis_contents -= potion_hud
	QDEL_NULL(potion_hud)
	vis_contents -= potion_launcher
	QDEL_NULL(potion_launcher)
	return ..()

/// Called by the console any time we update the monkeys, slimes, or max slimes
/atom/movable/screen/xenobio_console/proc/on_update_hud(slimes, monkeys, max_slimes)
	maptext = FORMAT_XENOBIO_HUD_MAPTEXT("[monkeys]\n[slimes]/[max_slimes]")
	maptext_x = 5
	maptext_y = 2

/// Called by the console any time we update the potion
/atom/movable/screen/xenobio_console/proc/update_potion(obj/item/slimepotion/slime/potion)
	if(isnull(potion))
		potion_hud.eject_pot()
		flick("xenobio_potion_launch", potion_launcher)
	else if(potion_hud.stored_potion)
		potion_hud.swap_pot(potion)
	else
		potion_hud.add_pot(potion)

/atom/movable/screen/xenobio_potion
	name = "Magazyn małp i szlamów"
	icon = 'aquila/icons/mob/screen/xenobio.dmi'
	screen_loc = ui_xenobiodisplay
	/// If we have a potion stored or not
	var/stored_potion = FALSE

/// Visually ejects the current potion
/atom/movable/screen/xenobio_potion/proc/eject_pot()
	animate(src, time = 2, pixel_y = 280)
	stored_potion = FALSE

/// Visually add the current potion
/atom/movable/screen/xenobio_potion/proc/add_pot(obj/item/slimepotion/slime/potion)
	stored_potion = TRUE
	name = potion.name
	icon = potion.icon
	icon_state = potion.icon_state
	pixel_y = 280
	pixel_x = -8
	add_filter("potion_outline", 1, outline_filter(1, "#eeeeee", OUTLINE_SQUARE))
	add_filter("potion_glow", 2, drop_shadow_filter(0.1, 0.1, 2, 0, "#eeeeee"))
	animate(src, time = POTION_DROP_SPEED, easing = BOUNCE_EASING, pixel_y = 19)

/// Swap out our current potion for a new one
/atom/movable/screen/xenobio_potion/proc/swap_pot(obj/item/slimepotion/slime/potion)
	addtimer(CALLBACK(src, PROC_REF(swap_pot_icon), potion.name, potion.icon, potion.icon_state), POTION_DROP_SPEED, TIMER_CLIENT_TIME)
	animate(src, time = POTION_DROP_SPEED, easing = BACK_EASING, pixel_x = -50)

/// Swaps the potion icon & name. Made for use w/ addtimer() so as to not disrupt the animation chain
/atom/movable/screen/xenobio_potion/proc/swap_pot_icon(new_name, new_icon, new_icon_state)
	name = new_name
	icon = new_icon
	icon_state = new_icon_state
	animate(src, time = POTION_DROP_SPEED, easing = BACK_EASING, pixel_x = -8)

#undef FORMAT_XENOBIO_HUD_MAPTEXT
#undef POTION_DROP_SPEED
