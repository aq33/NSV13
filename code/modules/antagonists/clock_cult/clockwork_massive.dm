GLOBAL_LIST_INIT(clockwork_portals, list())

/obj/structure/destructible/clockwork/massive/celestial_gateway
	name = "\improper Ark of the Clockwork Justiciar"
	desc = "A massive, hulking amalgamation of parts. It seems to be maintaining a very unstable bluespace anomaly."
	clockwork_desc = "Magnum opus Nezbere: potężna mechaniczna maszyna łącząca bluespace i parę, by przywołać Ratvara. Po aktywacji \
	jej niestabilność otworzy na statku jednokierunkowe szczeliny bluespace do Miasta Zębatek, więc bądź gotów bronić jej za wszelką cenę."
	max_integrity = 1000
	icon = 'icons/effects/96x96.dmi'
	icon_state = "clockwork_gateway_components"
	pixel_x = -32
	pixel_y = -32
	density = TRUE
	can_be_repaired = FALSE
	immune_to_servant_attacks = TRUE
	layer = BELOW_MOB_LAYER

	var/activated = FALSE
	var/grace_period = 1800
	var/assault_time = 0

	var/list/phase_messages = list()
	var/recalled = FALSE

	var/destroyed = FALSE

/obj/structure/destructible/clockwork/massive/celestial_gateway/Initialize(mapload)
	. = ..()
	GLOB.celestial_gateway = src

/obj/structure/destructible/clockwork/massive/celestial_gateway/Destroy()
	if(GLOB.ratvar_risen)
		return
	destroyed = TRUE
	hierophant_message("Arka została zniszczona, Reebe staje się niestabilne!", null, "<span class='large_brass'>")
	for(var/mob/living/M in GLOB.player_list)
		if(!is_reebe(M.z))
			continue
		if(is_servant_of_ratvar(M))
			to_chat(M, "<span class='reallybig hypnophrase'>Twój umysł zniekształca odległy odgłos tysiąca krzyków. <i>NIE OBRONILIŚCIE MOJEJ ARKI. UTKNIECIE TU ZE MNĄ, BY CIERPIEĆ NA WIEKI...</i></span>")
			continue
		var/safe_place = find_safe_turf()
		M.SetSleeping(50)
		to_chat(M, "<span class='reallybig hypnophrase'>Twój umysł zniekształca odległy odgłos tysiąca krzyków, po czym nagle wszystko cichnie.</span>")
		to_chat(M, "<span class='hypnophrase'>Pamiętasz tylko, że nagle zrobiło ci się ciepło i bezpiecznie.</span>")
		M.forceMove(safe_place)
	STOP_PROCESSING(SSobj, src)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(explode_reebe))

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/explode_reebe()
	for(var/i in 1 to 30)
		explosion(pick(get_area_turfs(/area/reebe/city_of_cogs)), 0, 2, 4, 4, FALSE)
		sleep(5)
	explosion(pick(GLOB.servant_spawns), 50, 40, 30, 30, FALSE, TRUE)

/obj/structure/destructible/clockwork/massive/celestial_gateway/examine(mob/user)
	. = ..()
	if(GLOB.ratvar_arrival_tick)
		. += "Otworzy się za [max((GLOB.ratvar_arrival_tick - world.time)/10, 0)] s."
	else
		. += "Na razie chyba niewiele robi, może kiedyś spełni swój cel."

/obj/structure/destructible/clockwork/massive/celestial_gateway/process(delta_time)
	if(DT_PROB(10, delta_time))
		to_chat(world, pick(phase_messages))

/obj/structure/destructible/clockwork/massive/celestial_gateway/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			resistance_flags |= INDESTRUCTIBLE
			visible_message("<span class='userdanger'>[src] zaczyna pulsować w niekontrolowany sposób... może lepiej uciekaj!</span>")
			sound_to_playing_players(volume = 50, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_disrupted.ogg'))
			for(var/mob/M in GLOB.player_list)
				var/turf/T = get_turf(M)
				if((T && T.get_virtual_z_level() == get_virtual_z_level()) || is_servant_of_ratvar(M))
					M.playsound_local(M, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, pressure_affected = FALSE)
			sleep(27)
			explosion(src, 1, 3, 8, 8)
			sound_to_playing_players('sound/effects/explosion_distant.ogg', volume = 50)
			for(var/obj/effect/portal/wormhole/clockcult/CC in GLOB.all_wormholes)
				qdel(CC)
			SSshuttle.clearHostileEnvironment(src)
			set_security_level(SEC_LEVEL_RED)
			sleep(300)
			SSticker.force_ending = TRUE
	qdel(src)

/obj/structure/destructible/clockwork/massive/celestial_gateway/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(!.)
		return
	hierophant_message("Arka otrzymuje obrażenia!", null, "<span class='large_brass'>")
	flick("clockwork_gateway_damaged", src)
	playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)

//==========Battle Phase===========
/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/open_gateway()
	SSshuttle.registerHostileEnvironment(src)
	if(GLOB.gateway_opening)
		return
	GLOB.gateway_opening = TRUE
	var/s = sound('sound/magic/clockwork/ark_activation_sequence.ogg')
	icon_state = "clockwork_gateway_charging"
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		SEND_SOUND(M.current, s)
		to_chat(M, "<span class='big_brass'>Arka została aktywowana, wkrótce zostaniesz przeniesiony!</span>")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(hierophant_message), "Przywołaj 'Mechaniczne Uzbrojenie' za pomocą Mechanicznej Płyty, by zdobyć potężny pancerz i broń.", "Nezbere", "nezbere", FALSE, FALSE), 10)
	addtimer(CALLBACK(src, PROC_REF(announce_gateway)), 300)
	addtimer(CALLBACK(src, PROC_REF(recall_sound)), 270)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_mass_recall()
	if(recalled)
		return
	INVOKE_ASYNC(src, PROC_REF(recall_sound))
	addtimer(CALLBACK(src, PROC_REF(mass_recall)), 30)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/recall_sound()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant)
			continue
		SEND_SOUND(servant, 'sound/machines/clockcult/ark_recall.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/announce_gateway()
	activated = TRUE
	set_security_level(SEC_LEVEL_DELTA)
	mass_recall(TRUE)
	var/grace_time = GLOB.narsie_breaching ? 0 : 1800
	addtimer(CALLBACK(src, PROC_REF(begin_assault)), grace_time)
	priority_announce("Na wszystkich częstotliwościach wykryto potężną anomalię [Gibberish("bluespace", 100)]. Cała załoga ma \
	@!$, [text2ratvar("PURGE ALL UNTRUTHS")] <&. anomalie i zniszczyć ich źródło, by zapobiec dalszym szkodom w mieniu korporacji. To \
	nie są ćwiczenia.[grace_period ? " Szacowany czas pojawienia się: [grace_time/10] s. Wykorzystajcie ten czas, by przygotować się na atak na [station_name()]." : ""]"\
	,"Wydział Spraw Wyższych Wymiarów Centrali", 'sound/magic/clockwork/ark_activation.ogg')
	sound_to_playing_players(volume = 10, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_charging.ogg', TRUE))
	GLOB.ratvar_arrival_tick = world.time + 6000 + grace_time

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/mass_recall(add_overlay = FALSE)
	var/list/spawns = GLOB.servant_spawns.Copy()
	for(var/datum/mind/M in GLOB.servants_of_ratvar)
		var/mob/living/servant = M.current
		if(!servant || QDELETED(servant))
			continue
		servant.forceMove(pick_n_take(spawns))
		if(!LAZYLEN(spawns))	//Just in case :^)
			spawns = GLOB.servant_spawns.Copy()
		if(ishuman(servant) && add_overlay)
			var/datum/antagonist/servant_of_ratvar/servant_antag = is_servant_of_ratvar(servant)
			if(servant_antag)
				servant_antag.forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
				servant.add_overlay(servant_antag.forbearance)
	for(var/mob/M in GLOB.player_list)
		SEND_SOUND(M, 'sound/magic/clockwork/invoke_general.ogg')

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_assault()
	priority_announce("W pobliżu statku wykryto anomalie czasoprzestrzenne. Ustalono, że źródłem jest czasowy \
		impuls energii z J1523-215. Cała załoga ma wejść do [text2ratvar("prep#re %o di%")]\
		i zniszczyć [text2ratvar("I'd like to see you try")], które ustalono jako źródło \
		impulsu, by zapobiec masowym szkodom w mieniu Nanotrasen.", "Alarm - anomalia", ANNOUNCER_SPANOMALIES)

	for(var/i in 1 to 100)
		var/turf/T = get_random_station_turf()
		GLOB.clockwork_portals += new /obj/effect/portal/wormhole/clockcult(T, null, 0, null, FALSE)
	addtimer(CALLBACK(src, PROC_REF(begin_activation)), 2400)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_activation()
	icon_state = "clockwork_gateway_active"
	sound_to_playing_players(volume = 25, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_active.ogg', TRUE))
	addtimer(CALLBACK(src, PROC_REF(begin_ratvar_arrival)), 2400)
	START_PROCESSING(SSobj, src)
	phase_messages = list(
		"<span class='warning'>Słyszysz nieziemskie dźwięki z północy.</span>",
		"<span class='warning'>Czujesz, jak tkanka rzeczywistości się wykręca i zgina.</span>",
		"<span class='warning'>Twój umysł brzęczy ze strachu.</span>",
		"<span class='warning'>Słyszysz wokół siebie nieziemskie krzyki.</span>"
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/begin_ratvar_arrival()
	sound_to_playing_players(volume = 30, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/clockcult_gateway_closing.ogg', TRUE))
	icon_state = "clockwork_gateway_closing"
	addtimer(CALLBACK(src, PROC_REF(ratvar_approaches)), 1200)
	phase_messages = list(
		"<span class='warning'>Słyszysz nieziemskie dźwięki z północy.</span>",
		"<span class='brass'>Niebiańska Brama zasila szczelinę bluespace!</span>",
		"<span class='warning'>Czujesz, jak rzeczywistość na chwilę drży...</span>",
		"<span class='brass'>Czujesz, jak czas i przestrzeń zniekształcają się wokół ciebie...</span>"
	)

/obj/structure/destructible/clockwork/massive/celestial_gateway/proc/ratvar_approaches()
	if(destroyed)
		return
	STOP_PROCESSING(SSobj, src)
	hierophant_message("Ratvar nadchodzi, zostaniecie wiecznie nagrodzeni za swoją służbę!", null, "<span class='large_brass'>")
	resistance_flags |= INDESTRUCTIBLE
	for(var/mob/living/M in GLOB.all_servants_of_ratvar)
		M.status_flags |= GODMODE
	sound_to_playing_players(volume = 100, channel = CHANNEL_JUSTICAR_ARK, S = sound('sound/effects/ratvar_rises.ogg')) //End the sounds
	GLOB.ratvar_risen = TRUE
	var/original_matrix = matrix()
	animate(src, transform = original_matrix * 1.5, alpha = 255, time = 125)
	sleep(125)
	transform = original_matrix
	animate(src, transform = original_matrix * 3, alpha = 0, time = 5)
	QDEL_IN(src, 3)
	sleep(3)
	var/turf/center_station = SSmapping.get_station_center()
	new /obj/eldritch/ratvar(center_station)
	if(GLOB.narsie_breaching)
		new /obj/eldritch/narsie(GLOB.narsie_arrival)
	flee_reebe(TRUE)

//=========Ratvar==========
GLOBAL_VAR(cult_ratvar)

#define RATVAR_CONSUME_RANGE 12
#define RATVAR_GRAV_PULL 10
#define RATVAR_SINGULARITY_SIZE 11

/obj/eldritch/ratvar
	name = "ratvar, the Clockwork Justicar"
	desc = "Oh, that's ratvar!"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	density = FALSE
	pixel_x = -236
	pixel_y = -256
	var/range = 1
	var/ratvar_target
	var/next_attack_tick

/obj/eldritch/ratvar/Initialize(mapload, starting_energy = 50)
	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = RATVAR_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = RATVAR_GRAV_PULL, \
		roaming = TRUE,\
		singularity_size = RATVAR_SINGULARITY_SIZE, \
	))
	log_game("!!! RATVAR HAS RISEN. !!!")
	GLOB.cult_ratvar = src
	. = ..()
	desc = "[text2ratvar("That's Ratvar, the Clockwork Justicar. The great one has risen.")]"
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')
	to_chat(world, "<span class='ratvar'>Zasłona bluespace ustępuje przed Ratvarem, jego światło zaświeci nad wszystkimi śmiertelnikami!</span>")
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(trigger_clockcult_victory), src)
	check_gods_battle()

//tasty
/obj/eldritch/ratvar/process(delta_time)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(ratvar_target)
		singularity_component?.target = ratvar_target
		if(get_dist(src, ratvar_target) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, "<span class='danger'>[pick("Reality shudders around you.","You hear the tearing of flesh.","The sound of bones cracking fills the air.")]</span>")
				SEND_SOUND(world, 'sound/magic/clockwork/ratvar_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(5 * delta_time)
				if(prob(max(GLOB.servants_of_ratvar.len/2, 15)))
					SEND_SOUND(world, 'sound/magic/demon_dies.ogg')
					to_chat(world, "<span class='ratvar'>Głupcy, że mnie nie docenialiście...</span>")
					qdel(ratvar_target)
					for(var/datum/mind/M as() in SSticker.mode?.cult)
						to_chat(M, "<span class='userdanger'>Czujesz kłujący ból w piersi... To nie może się dziać!</span>")
						M.current?.dust()
				return

/obj/eldritch/ratvar/consume(atom/A)
	A.ratvar_act()

/obj/eldritch/ratvar/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(T)

/obj/eldritch/ratvar/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/drone/D = new /mob/living/simple_animal/drone/cogscarab(get_turf(src))
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	add_servant_of_ratvar(D, silent=TRUE)

#undef RATVAR_CONSUME_RANGE
#undef RATVAR_GRAV_PULL
#undef RATVAR_SINGULARITY_SIZE
