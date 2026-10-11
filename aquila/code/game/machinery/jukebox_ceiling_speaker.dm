// AQUILA EDIT - głośnik pokładowego nagłośnienia: wisi na ścianie korytarza i gra jukebox, który kapitan
// puścił na cały statek (program "Nagłośnienie statku"). Rozwieszane automatycznie na starcie rundy (SSjukeboxes).

/obj/machinery/ceiling_speaker
	name = "głośnik nagłośnienia"
	desc = "Głośnik pokładowego nagłośnienia. Gra, gdy kapitan puści jukebox na cały statek."
	icon = 'goon/icons/obj/loudspeakers.dmi'
	icon_state = "loudspeaker"
	anchored = TRUE
	density = FALSE
	layer = WALL_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	max_integrity = 100
	integrity_failure = 50
	var/datum/music_emitter/emitter
	/// Statek, na którym wisi (zapamiętany przy pierwszym sprawdzeniu)
	var/obj/structure/overmap/ship
	/// Gra teraz muzykę z nadającego jukeboxa (tylko do ikony)
	var/playing = FALSE

/obj/machinery/ceiling_speaker/Initialize(mapload)
	. = ..()
	emitter = new(src, JUKEBOX_CEILING_RANGE, 1, 3)
	SSjukeboxes.ceiling_speakers += src

/obj/machinery/ceiling_speaker/Destroy()
	SSjukeboxes.ceiling_speakers -= src
	QDEL_NULL(emitter)
	ship = null
	return ..()

/obj/machinery/ceiling_speaker/proc/get_ship()
	if(!ship)
		ship = get_overmap()
	return ship

/// Czy może grać (zasilony i sprawny)
/obj/machinery/ceiling_speaker/proc/can_play()
	return !(machine_stat & (BROKEN|NOPOWER))

/// Wiesza głośnik na ścianie w kierunku wall_dir od kratki, na której stoi
/obj/machinery/ceiling_speaker/proc/mount_on(wall_dir)
	dir = turn(wall_dir, 180) // tuba w stronę korytarza
	pixel_x = (wall_dir & EAST) ? 26 : ((wall_dir & WEST) ? -26 : 0)
	pixel_y = (wall_dir & NORTH) ? 26 : ((wall_dir & SOUTH) ? -26 : 0)

/obj/machinery/ceiling_speaker/power_change()
	. = ..()
	update_icon()

/obj/machinery/ceiling_speaker/obj_break(damage_flag)
	. = ..()
	update_icon()

/obj/machinery/ceiling_speaker/update_icon_state()
	icon_state = (playing && can_play()) ? "loudspeaker-transmitting" : "loudspeaker"
	return ..()
