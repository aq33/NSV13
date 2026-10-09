/// Odświeża głośność i echo słuchaczy grających jukeboxów co 0,5 s (płynniej niż SSobj co 2 s).
SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	flags = SS_NO_INIT
	/// Jukeboxy grające teraz z YouTube
	var/list/obj/machinery/jukebox/yt_jukeboxes = list()

/datum/controller/subsystem/jukeboxes/fire()
	for(var/obj/machinery/jukebox/yt_jukebox as anything in yt_jukeboxes)
		yt_jukebox.yt_update_listeners()
