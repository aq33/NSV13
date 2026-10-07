// AQUILA - port tgstation/tgstation#90775: HUD konsoli ksenobiologii (małpy, szlamy, załadowana mikstura)

#define POTION_DROP_SPEED 5

/// Used to show how many monkeys & slimes are in the console
/atom/movable/screen/xenobio_console
	name = "Magazyn małp i szlamów"
	icon = 'aquila/icons/mob/screen/xenobio.dmi'
	icon_state = "xenobio_console"
	screen_loc = ui_xenobiodisplay
	var/atom/movable/screen/xenobio_potion/potion_hud
	var/atom/movable/screen/xenobio_potion/potion_launcher
	var/atom/movable/screen/xenobio_counter/monkey_counter
	var/atom/movable/screen/xenobio_counter/slime_counter

/atom/movable/screen/xenobio_console/Initialize(mapload)
	. = ..()
	potion_hud = new()
	potion_hud.layer = layer - 1
	vis_contents += potion_hud
	potion_launcher = new()
	potion_launcher.layer = layer - 2
	vis_contents += potion_launcher
	monkey_counter = new()
	monkey_counter.maptext_y = 18
	monkey_counter.layer = layer + 0.1
	vis_contents += monkey_counter
	slime_counter = new()
	slime_counter.maptext_y = 8
	slime_counter.layer = layer + 0.1
	vis_contents += slime_counter

/atom/movable/screen/xenobio_console/Destroy()
	vis_contents -= potion_hud
	QDEL_NULL(potion_hud)
	vis_contents -= potion_launcher
	QDEL_NULL(potion_launcher)
	vis_contents -= monkey_counter
	QDEL_NULL(monkey_counter)
	vis_contents -= slime_counter
	QDEL_NULL(slime_counter)
	return ..()

/// Called by the console any time we update the monkeys, slimes, or max slimes
/atom/movable/screen/xenobio_console/proc/on_update_hud(slimes, monkeys, max_slimes)
	monkey_counter.maptext = MAPTEXT("[monkeys]")
	slime_counter.maptext = MAPTEXT("[slimes]/[max_slimes]")

/// One line of the console HUD counters, placed next to its icon
/atom/movable/screen/xenobio_counter
	screen_loc = ui_xenobiodisplay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext_width = 20
	maptext_height = 9
	maptext_x = 12

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

#undef POTION_DROP_SPEED
