// Port BeeStation/BeeStation-Hornet#12449: przycisk „Obserwuj” na HUD-zie ducha

/atom/movable/screen/ghost/observe
	name = "Obserwuj"
	icon = 'aquila/icons/hud/screen_ghost.dmi'
	icon_state = "observe"

/atom/movable/screen/ghost/observe/Click()
	var/mob/dead/observer/G = usr
	G.observe()

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using = new /atom/movable/screen/ghost/observe()
	using.screen_loc = ui_ghost_observe
	using.hud = src
	static_inventory += using
