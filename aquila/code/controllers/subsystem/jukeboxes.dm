/datum/track
	var/name = "undefined"
	var/path = null
	var/length = null

/datum/jukebox
	var/song_id = null
	var/channel = null
	var/speed_factor = 1
	var/obj/jukebox = null
	/// Gracze, którym wysłano już utwór (dalej dostają tylko aktualizacje głośności)
	var/list/listeners = list()
	var/started = 0

SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	var/list/song_lib = list()
	var/list/song_lib_ranch = list()
	var/list/datum/track/songs = list()
	var/list/datum/jukebox/active_jukeboxes = list()
	var/list/free_channels = list()
	/// Jukeboxy grające z YouTube - głośność/echo ich słuchaczy odświeżamy co tick subsystemu (płynniej niż SSobj)
	var/list/obj/machinery/jukebox/yt_jukeboxes = list()

/datum/controller/subsystem/jukeboxes/proc/add_jukebox(obj/jukebox_obj, selection, speed_factor = 1)
	if(selection > songs.len)
		CRASH("[src] tried to play a song with a nonexistant track")
	if(free_channels.len == 0)
		return null
	var/channel = pick(free_channels)
	free_channels -= channel
	var/datum/jukebox/jukebox = new /datum/jukebox()
	jukebox.song_id = selection
	jukebox.channel = channel
	jukebox.jukebox = jukebox_obj
	jukebox.speed_factor = speed_factor
	jukebox.started = world.time
	active_jukeboxes += jukebox
	update_jukebox(jukebox) // słuchacze w zasięgu słyszą od razu, resztę dołącza fire()
	return channel

/datum/controller/subsystem/jukeboxes/proc/remove_jukebox(channel)
	var/datum/jukebox/jukebox = null
	for(var/datum/jukebox/i in active_jukeboxes)
		if(i.channel == channel)
			jukebox = i
			break
	ASSERT(jukebox != null)
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		M.stop_sound_channel(channel)
	active_jukeboxes -= jukebox
	jukebox.listeners = null
	free_channels += channel
	return TRUE

/// Ustawia głośność utworu każdemu graczowi wg odległości (okrąg wokół jukeboxa).
/// Dźwięk nie jest pozycyjny (bez x/y/z), żeby nie uciekał na jedno ucho przy chodzeniu obok.
/datum/controller/subsystem/jukeboxes/proc/update_jukebox(datum/jukebox/jukebox)
	var/datum/track/juketrack = songs[jukebox.song_id]
	if(!istype(juketrack))
		CRASH("Invalid jukebox track datum.")
	var/obj/machinery/jukebox/jukebox_obj = jukebox.jukebox
	if(!istype(jukebox_obj))
		CRASH("Nonexistant or invalid object associated with jukebox.")
	var/list/listeners = jukebox.listeners
	for(var/mob/M as anything in GLOB.player_list)
		if(!M.client)
			continue
		var/volume = round(JUKEBOX_LOCAL_MAX_VOLUME * jukebox_obj.volume / 100 * jukebox_obj.hearing_gain(M))
		var/sound/song_played = sound(juketrack.path)
		song_played.channel = jukebox.channel
		song_played.frequency = jukebox.speed_factor
		song_played.wait = 0
		song_played.volume = volume
		// Dźwięk "3D" tuż przed słuchaczem (oba uszy, bez tłumienia BYOND), żeby działał pogłos.
		song_played.x = 0
		song_played.y = 0
		song_played.z = 1
		song_played.falloff = 2
		var/echo = jukebox_obj.echo_amount(M)
		var/area/A = get_area(M)
		song_played.environment = (A?.sound_environment != SOUND_ENVIRONMENT_NONE) ? A.sound_environment : SOUND_ENVIRONMENT_HALLWAY
		var/list/echo_params = new /list(18) // null = domyślna wartość BYOND
		echo_params[2] = round(-1200 * echo) // DirectHF: z daleka przytłumione wysokie tony
		echo_params[3] = echo > 0 ? round(2000 * log(10, max(echo, 0.01))) : -10000 // Room: poziom pogłosu w mB
		song_played.echo = echo_params
		if(listeners[M])
			song_played.status = SOUND_UPDATE | SOUND_STREAM
			if(volume <= 0)
				song_played.status |= SOUND_MUTE //Setting volume = 0 doesn't let the sound properties update at all, which is lame.
		else
			if(volume <= 0)
				continue
			song_played.status = SOUND_STREAM
#if DM_VERSION >= 515
			song_played.offset = (world.time - jukebox.started) * jukebox.speed_factor / 10
#endif
			listeners[M] = TRUE
		SEND_SOUND(M, song_played)
		CHECK_TICK
		if(!jukebox.listeners) // jukebox wyłączony w trakcie CHECK_TICK
			return

/datum/controller/subsystem/jukeboxes/Initialize()
	var/list/tracks = flist("config/jukebox_music/sounds/")
	for(var/S in tracks)
		if(S == "exclude")
			continue
		var/datum/track/T = new()
		T.path = file("config/jukebox_music/sounds/[S]")
		var/list/tokens = splittext(S, "+")
		if(tokens.len != 2)
			warning("failed to load song [S]")
			continue
		T.name = tokens[1]
		T.length = text2num(tokens[2]) * 10 //seconds to deciseconds
		if(T.length == null)
			warning("failed to load song, couldn't load length [S]")
			continue
		songs |= T
		song_lib[T.name] = songs.len
		if(findtext(T.name, "ram") > 0 && findtext(T.name, "ranch") > 0)
			song_lib_ranch[T.name] = songs.len
	song_lib = sortList(song_lib)
	song_lib_ranch = sortList(song_lib_ranch)
	for(var/i in CHANNEL_JUKEBOX_START to CHANNEL_JUKEBOX_END)
		free_channels |= i
	return ..()

/datum/controller/subsystem/jukeboxes/fire()
	for(var/datum/jukebox/jukebox as anything in active_jukeboxes)
		update_jukebox(jukebox)
	for(var/obj/machinery/jukebox/yt_jukebox as anything in yt_jukeboxes)
		yt_jukebox.yt_update_listeners()
