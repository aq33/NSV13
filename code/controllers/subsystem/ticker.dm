#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/hide_mode = FALSE
	var/datum/game_mode/mode = null

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE			//If all clients have loaded it

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/delay_end = 0						//if set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE			//all roundend preparation done with, all that's left is reboot

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft						//pregame timer
	var/start_at

	var/gametime_offset = 432000		//Deciseconds to add to world.time for station time.
	var/station_time_rate_multiplier = 12		//factor of station time progressal vs real time.

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/maprotatechecked = 0

	var/list/datum/game_mode/runnable_modes //list of runnable gamemodes

	var/news_report

	var/late_join_disabled

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/round_start_timeofday = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"

	//Gamemode setup
	var/gamemode_hotswap_disabled = FALSE
	var/pre_setup_completed = FALSE
	var/fail_counter
	var/emergency_start = FALSE

/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	var/list/byond_sound_formats = list(
		"mid"  = TRUE,
		"midi" = TRUE,
		"mod"  = TRUE,
		"it"   = TRUE,
		"s3m"  = TRUE,
		"xm"   = TRUE,
		"oxm"  = TRUE,
		"wav"  = TRUE,
		"ogg"  = TRUE,
		"raw"  = TRUE,
		"wma"  = TRUE,
		"aiff" = TRUE
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = lowertext(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.config.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.config.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.config.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				if(L[1] == "exclude")
					continue
				music += S

	var/old_login_music = trim(rustg_file_read("data/last_round_lobby_music.txt"))
	if(music.len > 1)
		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = lowertext(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(!length(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"


	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase	= generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday

	return ..()

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
			to_chat(world, "<span class='boldnotice'>Witaj na [station_name()]!</span>")
			send2chat("New round starting on [SSmapping.config.map_name]!", CONFIG_GET(string/chat_announce_new_game))
			current_state = GAME_STATE_PREGAME
			//Everyone who wants to be an observer is now spawned
			create_observers()
			fire()
		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/dead/new_player/player in GLOB.player_list)
				++totalPlayers
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(timeLeft <= 300 && !pre_setup_completed)
				//Setup gamemode maps 30 seconds before roundstart.
				if(!pre_setup())
					fail_setup()
					return
				pre_setup_completed = TRUE

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!pre_setup_completed)
				if(!pre_setup())
					fail_setup()
					return
				else
					message_admins("Pre-setup completed successfully, however was run late. Likely due to start-now or a bug.")
					log_game("Pre-setup completed successfully, however was run late. Likely due to start-now or a bug.")
					pre_setup_completed = TRUE
			//Attempt normal setup
			if(!setup())
				fail_setup()
			else
				fail_counter = null

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()
			check_maprotate()

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

//Reverts the game to the lobby
/datum/controller/subsystem/ticker/proc/fail_setup()
	if(fail_counter >= 2)
		log_game("Failed setting up [GLOB.master_mode] [fail_counter + 1] times, defaulting to extended.")
		message_admins("Failed setting up [GLOB.master_mode] [fail_counter + 1] times, defaulting to extended.")
		//This has failed enough, lets just get on with extended.
		failsafe_pre_setup()
		return
	//Let's try this again.
	fail_counter++
	current_state = GAME_STATE_STARTUP
	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 5)
	timeLeft = null
	Master.SetRunLevel(RUNLEVEL_LOBBY)
	pre_setup_completed = FALSE
	//Return to default mode
	load_mode()
	message_admins("Failed to setup. Failures: ([fail_counter] / 3).")
	log_game("Setup failed.")

//Fallback presetup that sets up extended.
/datum/controller/subsystem/ticker/proc/failsafe_pre_setup()
	//Emergerncy start extended.
	emergency_start = TRUE
	pre_setup_completed = TRUE
	mode = config.pick_mode("extended")

//Select gamemode and load any maps associated with it
/datum/controller/subsystem/ticker/proc/pre_setup()
	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(GLOB.master_mode == "secret" || GLOB.master_mode == "secret_extended")
			hide_mode = TRUE
			if(GLOB.secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(GLOB.secret_force_mode)
				if(!smode.can_start())
					message_admins("<span class='notice'>Unable to force secret [GLOB.secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.</span>")
				else
					mode = smode

		if(!mode)
			if(!runnable_modes.len)
				to_chat(world, "<B>Nie udało się wybrać grywalnego trybu gry.</B> Powrót do lobby.")
				return FALSE
			mode = pickweight(runnable_modes)
			if(!mode)	//too few roundtypes all run too recently
				mode = pick(runnable_modes)

	else
		mode = config.pick_mode(GLOB.master_mode)
		if(!mode.can_start())
			to_chat(world, "<B>Nie można rozpocząć trybu [mode.name].</B> Za mało graczy: potrzeba [mode.required_players] graczy i [mode.required_enemies] chętnych antagonistów. Powrót do lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return FALSE

	return mode.setup_maps()

/datum/controller/subsystem/ticker/proc/setup()
	message_admins("Setting up game.")
	var/init_start = world.timeofday

	CHECK_TICK
	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	mode.setup_antag_candidates()			//Re-calculate antag candidates in case anybody left
	can_continue = src.mode.pre_setup()		//Choose antagonists
	CHECK_TICK //NSV 13
	SSovermap_mode.setup_overmap_mode() //NSV 13 - Injecting our overmap stuff here
	CHECK_TICK
	can_continue = can_continue && SSjob.DivideOccupations(mode.required_jobs) 				//Distribute jobs
	CHECK_TICK

	to_chat(world, "<span class='boldannounce'>Rozpoczynanie gry...</span>")
	if(!GLOB.Debug2 && !emergency_start)
		if(!can_continue)
			log_game("[mode.name] failed pre_setup, cause: [mode.setup_error]")
			QDEL_NULL(mode)
			to_chat(world, "<B>Błąd podczas przygotowywania trybu [GLOB.master_mode].</B> Powrót do lobby.")
			SSjob.ResetOccupations()
			return FALSE
	else
		message_admins("<span class='notice'>DEBUG: Bypassing prestart checks...</span>")

	CHECK_TICK
	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<b>Tryb gry: tajny!\nMożliwości:</B> [english_list(modes, and_text = " i ")]")
	else
		mode.announce()

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	equip_characters()

	GLOB.data_core.manifest()

	transfer_characters()	//transfer keys to the new mobs

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	log_world("Game start took [(world.timeofday - init_start)/10]s")
	round_start_time = world.time
	round_start_timeofday = world.timeofday
	SSdbcore.SetRoundStart()

	to_chat(world, "<span class='notice'><B>Witaj na [station_name()], miłego pobytu!</B></span>")
	SEND_SOUND(world, sound(SSstation.announcer.get_rand_welcome_sound()))

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)
	SSovermap_mode.start_reminder() //NSV13

	if(SSevents.holidays)
		to_chat(world, "<span class='notice'>and...</span>")
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	//Setup orbits.
	SSorbits.post_load_init()

	PostSetup()
	SSstat.clear_global_alert()

	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2tgs("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]:" : "of"] [hide_mode ? "secret":"[mode.name]"] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE

	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S))							//we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")


//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/station_explosion_detonation(atom/bomb)
	if(bomb)	//BOOM
		qdel(bomb)
		for(var/mob/M in GLOB.mob_list)
			var/turf/T = get_turf(M)
			if(T && is_station_level(T.z) && !istype(M.loc, /obj/structure/closet/secure_closet/freezer)) //protip: freezers protect you from nukes
				M.gib(TRUE)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.new_character?.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	var/highest_rank = length(SSjob.chain_of_command) + 1
	var/list/spare_id_candidates = list()
	var/enforce_coc = CONFIG_GET(flag/spare_enforce_coc)

	for(var/mob/dead/new_player/N in GLOB.player_list)
		var/mob/living/carbon/human/player = N.new_character
		if(istype(player) && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == JOB_NAME_CAPTAIN)
				captainless = FALSE
				spare_id_candidates += N
			else if(captainless && (player.mind.assigned_role in GLOB.command_positions) && !(is_banned_from(N.ckey, JOB_NAME_CAPTAIN)))
				if(!enforce_coc)
					spare_id_candidates += N
				else
					var/spare_id_priority = SSjob.chain_of_command[player.mind.assigned_role]
					if(spare_id_priority)
						if(spare_id_priority < highest_rank)
							spare_id_candidates.Cut()
							spare_id_candidates += N
							highest_rank = spare_id_priority
						else if(spare_id_priority == highest_rank)
							spare_id_candidates += N
			if(player.mind.assigned_role != player.mind.special_role)
				SSjob.EquipRank(N, player.mind.assigned_role, FALSE)
			if(CONFIG_GET(flag/roundstart_traits) && ishuman(N.new_character))
				SSquirks.AssignQuirks(N.new_character, N.client, TRUE)
		CHECK_TICK
	if(length(spare_id_candidates))			//No captain, time to choose acting captain
		if(!enforce_coc)
			for(var/mob/dead/new_player/player in spare_id_candidates)
				SSjob.promote_to_captain(player, captainless)

		else
			SSjob.promote_to_captain(pick(spare_id_candidates), captainless)		//This is just in case 2 heads of the same priority spawn
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/player in GLOB.mob_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.notransform = TRUE
			if(living.client)
				var/atom/movable/screen/splash/S = new(null, living.client, TRUE)
				S.Fade(TRUE)
			livings += living
	if(livings.len)
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 30, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		var/list/memetips = world.file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, EXAMINE_BLOCK("<span class='purple'><b>Porada rundy: </b>[html_encode(m)]</span>"))

/datum/controller/subsystem/ticker/proc/check_queue()
	if(!queued_players.len)
		return
	var/hpc = CONFIG_GET(number/hard_popcap)
	if(!hpc)
		listclearnulls(queued_players)
		for (var/mob/dead/new_player/NP in queued_players)
			to_chat(NP, "<span class='userdanger'>Limit żywych graczy został zniesiony!<br><a href='byond://?src=[REF(NP)];late_join=override'>[html_encode(">>Dołącz do gry<<")]</a></span>")
			SEND_SOUND(NP, sound('sound/misc/notice1.ogg'))
			NP.LateChoices()
		queued_players.len = 0
		queue_delay = 0
		return

	queue_delay++
	var/mob/dead/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			listclearnulls(queued_players)
			if(living_player_count() < hpc)
				if(next_in_line && next_in_line.client)
					to_chat(next_in_line, "<span class='userdanger'>Zwolniło się miejsce! Masz około 20 sekund, żeby dołączyć. <a href='byond://?src=[REF(next_in_line)];late_join=override'>\>\>Dołącz do gry\<\<</a></span>")
					SEND_SOUND(next_in_line, sound('sound/misc/notice1.ogg'))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, "<span class='danger'>Brak odpowiedzi. Usunięto cię z kolejki.</span>")
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/check_maprotate()
	if (!CONFIG_GET(flag/maprotation))
		return
	if (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*CONFIG_GET(number/maprotatechancedelta)))
		return
	INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, maprotate))

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	hide_mode = SSticker.hide_mode
	mode = SSticker.mode

	login_music = SSticker.login_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	triai = SSticker.triai
	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked
	round_start_time = SSticker.round_start_time
	round_start_timeofday = SSticker.round_start_timeofday

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked

	if (Master) //Set Masters run level if it exists
		switch (current_state)
			if(GAME_STATE_SETTING_UP)
				Master.SetRunLevel(RUNLEVEL_SETUP)
			if(GAME_STATE_PLAYING)
				Master.SetRunLevel(RUNLEVEL_GAME)
			if(GAME_STATE_FINISHED)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen Admiralty"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "W śmiałym nalocie bohaterska załoga [station_name()] zdetonowała ładunek jądrowy w sercu bazy terrorystów."
		if(STATION_DESTROYED_NUKE)
			news_message = "Pragniemy zapewnić wszystkich pracowników, że doniesienia o wspieranym przez Syndykat ataku jądrowym na [station_name()] są w rzeczywistości mistyfikacją. Bezpiecznego dnia!"
		if(STATION_EVACUATED)
			news_message = "Załoga [station_name()] została ewakuowana w związku z niepotwierdzonymi doniesieniami o aktywności wroga."
		if(BLOB_WIN)
			news_message = "[station_name()] padła ofiarą nieznanej epidemii biologicznej, która zabiła całą załogę na pokładzie. Nie pozwól, by to spotkało ciebie! Pamiętaj: czyste stanowisko pracy to bezpieczne stanowisko pracy."
		if(BLOB_NUKE)
			news_message = "[station_name()] przechodzi obecnie dekontaminację po tym, jak kontrolowany impuls promieniowania posłużył do usunięcia biologicznego szlamu. Wszyscy pracownicy zostali wcześniej bezpiecznie ewakuowani i cieszą się relaksującymi wakacjami."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] przechodzi obecnie procedury dekontaminacji po zniszczeniu zagrożenia biologicznego. Przypominamy, że członkowie załogi odczuwający skurcze lub wzdęcia powinni natychmiast zgłosić się do ochrony w celu spalenia."
		if(CULT_ESCAPE)
			news_message = "Alarm ochrony: grupa religijnych fanatyków uciekła z [station_name()]."
		if(CULT_FAILURE)
			news_message = "Po rozbiciu zakazanego kultu na pokładzie [station_name()] przypominamy wszystkim pracownikom, że oddawanie czci poza kaplicą jest surowo zabronione i stanowi podstawę do zwolnienia."
		if(CULT_SUMMON)
			news_message = "Przedstawiciele firmy pragną wyjaśnić, że [station_name()] miała zostać wycofana z eksploatacji po zeszłorocznych uszkodzeniach od meteorów. Wcześniejsze doniesienia o niepojętym, przedwiecznym horrorze były błędne."
		if(NUKE_MISS)
			news_message = "Syndykat spartaczył atak terrorystyczny na [station_name()], detonując broń jądrową w pustej przestrzeni w pobliżu."
		if(OPERATIVES_KILLED)
			news_message = "Trwają naprawy [station_name()] po tym, jak załoga zniszczyła elitarny szwadron śmierci Syndykatu."
		if(OPERATIVE_SKIRMISH)
			news_message = "Potyczka między siłami ochrony a agentami Syndykatu na pokładzie [station_name()] zakończyła się krwawo dla obu stron, ale bez strat."
		if(REVS_WIN)
			news_message = "Przedstawiciele firmy zapewnili inwestorów, że mimo prowadzonej przez związki zawodowe rewolty na pokładzie [station_name()] nie będzie podwyżek dla pracowników."
		if(REVS_LOSE)
			news_message = "[station_name()] szybko stłumiła nieprzemyślaną próbę buntu. Pamiętaj, zakładanie związków zawodowych jest nielegalne!"
		if(WIZARD_KILLED)
			news_message = "Napięcia z Kosmiczną Federacją Czarodziejów wzrosły po śmierci jednego z jej członków na pokładzie [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self-destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are underway."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."
		if(SHIP_VICTORY) //NSV13 start - news reports for nsv round ends
			news_message = "[station_name()] has successfully completed their mission and has returned to Outpost 45 for resupply and crew transfer."
		if(SHIP_DESTROYED)
			news_message = "[station_name()] has been defeated in combat while attempting to complete their mission."
		if(PVP_SYNDIE_WIN)
			news_message = "The crew of [station_name()] have been cloned and subsequently court-martialled after losing a border skirmish to the SSV Nebuchadnezzar and her crew. VICKER media would like to remind all employees to do better than that crew!"
		if(PVP_SYNDIE_LOSS)
			news_message = "The crew of [station_name()] successfully repelled an attempted invasion by the SSV Nebuchadnezzar and have strengthened Nanotrasen's position in the Sol sector!"
		if(PVP_SYNDIE_PIRATE_WIN)
			news_message = "The Sol sector has fallen into anarchistic piracy, as the Tortuga raiders used the chaos of a surprise attack by Syndicate forces to seize a large amount of territory unanswered." //NSV13 end

	if(news_message)
		if(!AWAIT(SStopic.crosscomms_send_async("news_report", news_message, news_source), 10 SECONDS))
			message_admins("Failed to send news report through crosscomms. The sending task expired.")
			log_game("Failed to send news report through crosscomms. The sending task expired.")

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft))	//remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

//Everyone who wanted to be an observer gets made one now
/datum/controller/subsystem/ticker/proc/create_observers()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_OBSERVE && player.mind)
			//Break chain since this has a sleep input in it
			addtimer(CALLBACK(player, TYPE_PROC_REF(/mob/dead/new_player, make_me_an_observer)), 1)

/datum/controller/subsystem/ticker/proc/load_mode()
	var/mode = CONFIG_GET(string/master_mode)
	if(mode)
		GLOB.master_mode = mode
	else
		GLOB.master_mode = "extended"
	log_game("Master mode is '[GLOB.master_mode]'")
	log_config("Master mode is '[GLOB.master_mode]'")

/// Returns if either the master mode or the forced secret ruleset matches the mode name.
/datum/controller/subsystem/ticker/proc/is_mode(mode_name)
	return GLOB.master_mode == mode_name || GLOB.secret_force_mode == mode_name

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_ADMIN || R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldannounce'>Admin opóźnił koniec rundy.</span>")
		return

	to_chat(world, "<span class='boldannounce'>Restart świata za [DisplayTimeText(delay)]. [reason]</span>")

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2))	//don't wait forever
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldannounce'>Admin anulował restart.</span>")
		return
	if(end_string)
		end_state = end_string

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, "<span class='info'>Statystyki i logi rundy znajdziesz <a href=\"[statspage][GLOB.round_id]\">na tej stronie!</a></span>")
	else if(gamelogloc)
		to_chat(world, "<span class='info'>Logi rundy znajdziesz <a href=\"[gamelogloc]\">na tej stronie!</a></span>")

	log_game("<span class='boldannounce'>Rebooting World. [reason]</span>")

	world.Reboot()

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()
	if(!round_end_sound)
		var/list/tracks = flist("sound/roundend/")
		if(tracks.len)
			round_end_sound = "sound/roundend/[pick(tracks)]"

	SEND_SOUND(world, sound(round_end_sound))
	rustg_file_append(login_music, "data/last_round_lobby_music.txt")
