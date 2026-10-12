
//Syndicate Fleets

/datum/fleet/neutral //The values here are the same as the default, copied for easier reference. This fleet is specifically one that flies in the neutral zone
	name = "\improper Syndicate scout fleet"
	fighter_types = list(/obj/structure/overmap/syndicate/ai/fighter, /obj/structure/overmap/syndicate/ai/bomber)
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser, /obj/structure/overmap/syndicate/ai/assault_cruiser)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier)
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/border
	name = "\improper Syndicate border defense force"
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier, /obj/structure/overmap/syndicate/ai/carrier/elite)
	fleet_trait = FLEET_TRAIT_BORDER_PATROL
	hide_movements = TRUE
	size = FLEET_DIFFICULTY_HARD //Border patrol is stronger

/datum/fleet/light_defense
	name = "\improper Syndicate defense fleet"
	fleet_trait = FLEET_TRAIT_DEFENSE //Fleet meant for general system defense, nothing major

/datum/fleet/boarding
	name = "\improper Syndicate commando taskforce"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	taunts = list("Uwaga: to automatyczna wiadomość. Wszystkie okręty spoza Syndykatu mają przygotować się do abordażu w celu kontroli bezpieczeństwa.")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/wolfpack
	name = "\improper unidentified Syndicate fleet"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/destroyer, /obj/structure/overmap/syndicate/ai/submarine/elite)
	audio_cues = list()
	hide_movements = TRUE
	taunts = list("....", "*static*")
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/wolfpack/elite
	name = "\improper unidentified Syndicate taskforce"
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/submarine/elite)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/submarine/elite, /obj/structure/overmap/syndicate/ai/cruiser/elite)
	taunts = list(".....", "*głośne sprzężenie mikrofonu*", "Nie macie dokąd uciec ani gdzie się ukryć...")

/datum/fleet/conflagration
	name = "\improper Syndicate conflagration deterrent"
	taunts = list("Wrogi okręcie, poddajcie się natychmiast. Ta jednostka jest uzbrojona w pociski hellfire i chętnie je przetestuje.")
	audio_cues = list()
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_NEUTRAL_ZONE

/datum/fleet/elite
	name = "\improper elite Syndicate taskforce"
	taunts = list("Wrogi okręcie, poddajcie się natychmiast albo zostaniecie zniszczeni.", "Doskonale, wartościowy cel. Uzbroić wszystkie baterie.")
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/submarine/elite)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite)

//Space Pirate Fleets
/datum/fleet/pirate
	name = "\proper Tortuga Raiders Fleet"
	fighter_types = null
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai)
	battleship_types = list(/obj/structure/overmap/spacepirate/ai/nt_missile, /obj/structure/overmap/spacepirate/ai/syndie_gunboat)
	default_ghost_ship = /obj/structure/overmap/spacepirate/ai
	supply_types = null
	alignment = "pirate"
	faction_id = FACTION_ID_PIRATES
	reward = 35

/datum/fleet/pirate/scout
	name = "\improper Tortuga Raiders scout fleet"
	audio_cues = list()
	taunts = list("Jo-ho-ho! Świeże mięso", "Rozwinąć żagle! Mamy towarzystwo", "Giń, szczurze lądowy!")
	size = FLEET_DIFFICULTY_MEDIUM
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/pirate/raiding
	name = "\improper Tortuga Raiders raiding fleet"
	destroyer_types = list(/obj/structure/overmap/spacepirate/ai, /obj/structure/overmap/spacepirate/ai/boarding)
	audio_cues = list()
	taunts = list("Ahoj! Płynie ku nam ładowna pełna łupów", "Szykować ekipy abordażowe, mają łupów dla nas wszystkich!")
	size = FLEET_DIFFICULTY_MEDIUM

/datum/fleet/pirate/tortuga
	name = "\improper Tortuga Raiders holding fleet"
	supply_types = list(/obj/structure/overmap/spacepirate/ai/dreadnought)
	audio_cues = list(/datum/soundtrack_song/bee/hierophant)
	taunts = list("To nasze wody, po których płyniecie, szykujcie się do kapitulacji!", "Śmiało, latać w tym systemie pod barwami Nanotrasen. Wasz ostatni błąd.")
	size = FLEET_DIFFICULTY_VERY_HARD
	fleet_trait = FLEET_TRAIT_DEFENSE
	reward = 200

/datum/fleet/pirate/tortuga/defeat()
	if(!current_system)
		return ..()
	for(var/obj/structure/overmap/survivor in current_system.system_contents)
		if(survivor.ai_controlled)
			continue
		for(var/mob/living/victorious_mob in survivor.mobs_in_ship)
			if(!victorious_mob.client)
				continue
			victorious_mob.client.give_award(/datum/award/achievement/misc/pirate_exterminator, victorious_mob)
	return ..()


//Boss battles.

/datum/fleet/rubicon //Crossing the rubicon, are we?
	name = "\proper Rubicon Crossing"
	size = FLEET_DIFFICULTY_VERY_HARD
	allow_difficulty_scaling = FALSE
	battleship_types = list(/obj/structure/overmap/syndicate/ai/kadesh)	//:)
	audio_cues = list()
	taunts = list("Lepsze załogi próbowały przekroczyć Rubikon, zginiecie tak jak one.", "Siły obronne, w gotowości!", "Nanotraseńskie ścierwo. Amunicja, przygotować działa. Oczyścimy galaktykę z was, robactwa.", "Ta zmiana robi się coraz lepsza. Powieszę głowę waszego kapitana na ścianie.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/earthbuster
	name = "\proper Syndicate Armada" //Fleet spawned if the players are too inactive. Set course...FOR EARTH.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/gunboat, /obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship) //The fist of sol is leading the charge
	size = FLEET_DIFFICULTY_INSANE
	allow_difficulty_scaling = FALSE
	taunts = list("Idziemy po Sol i nie powstrzymacie nas. Wszystkie baterie, ogień według uznania.", "Złóżcie broń, macie przewagę liczebną przeciwko sobie.", "Wszyscy na stanowiska, formacja szturmowa. Rozpocząć bombardowanie.")
	audio_cues = list(/datum/soundtrack_song/bee/countdown)

/datum/fleet/interdiction	//Pretty strong fleet with unerring hunting senses, Adminspawn for now.
	name = "\improper Syndicate interdiction fleet"	//These fun guys can and will hunt the player ship down, no matter how far away they are.
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser, /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/kadesh)
	size = FLEET_DIFFICULTY_HARD
	taunts = list("Przybyliśmy, by zakończyć wasze marne istnienie. Szykujcie się na śmierć.", "Wróg wchodzi w zasięg broni. Ogień według uznania.", "Od dawna jesteście dla nas cierniem w boku. Czas z tym skończyć.", "Ładny okręt macie. Nic, czego kilka pocisków hellfire by nie naprawiło.")
	audio_cues = list()
	var/obj/structure/overmap/hunted_ship
	initial_move_delay = 5 MINUTES
	minimum_random_move_delay = 2 MINUTES	//These are quite a bunch faster than your usual fleets. Good luck running. It won't save you.
	maximum_random_move_delay = 4 MINUTES
	combat_move_delay = 6 MINUTES

/datum/fleet/interdiction/stealth	//More fun for badmins
	name = "\improper unidentified Syndicate heavy fleet"
	hide_movements = TRUE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/conflagration, /obj/structure/overmap/syndicate/ai/assault_cruiser)

/datum/fleet/interdiction/light	//The syndicate can spawn these randomly (though rare). Be caareful! But, at least they aren't that scary.
	name = "\improper Syndicate light interdiction fleet"
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser)
	size = FLEET_DIFFICULTY_MEDIUM	//Don't let this fool you though, they are still somewhat dangerous and will hunt you down.
	initial_move_delay = 12 MINUTES

/datum/fleet/dolos
	name = "\proper Dolos Welcoming Party" //Don't do it czanek, don't fucking do it!
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/future_perception)
	taunts = list("Nie myślcie, że nie wyciągnęliśmy wniosków z waszej ostatniej próby.", "Nie zawiedziemy ponownie", "Wasza przestarzała broń MAC nie ma z nami szans. Szykujcie się na zniszczenie.")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/remnant
	name = "\proper The Remnant"
	size = FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/finale)
	taunts = list("<pre>\[DECRYPTION FAILURE]</pre>")
	fleet_trait = FLEET_TRAIT_DEFENSE
	destroyer_types = list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/destroyer/elite, /obj/structure/overmap/syndicate/ai/destroyer/flak, /obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/mako_flak, /obj/structure/overmap/syndicate/ai/mako_carrier)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/cruiser/elite, /obj/structure/overmap/syndicate/ai/conflagration/elite)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)

/datum/fleet/unknown_ship
	name = "\improper unknown Syndicate ship class"
	size = 1
	allow_difficulty_scaling = FALSE
	battleship_types = list(/obj/structure/overmap/syndicate/ai/battleship)
	audio_cues = list(/datum/soundtrack_song/bee/finale)
	taunts = list("Wasz atak na Rubikon tylko odwrócił waszą uwagę od prawdziwego zagrożenia. Czas zakończyć tę wojnę jednym szybkim ciosem.")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/syndicate/fistofsol_boss
	name = "SSV Fist of Sol"
	faction = FACTION_ID_SYNDICATE
	size = 1
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/countdownext)
	battleship_types = list(/obj/structure/overmap/syndicate/ai/fistofsol)
	supply_types = list(/obj/structure/overmap/syndicate/ai/carrier/elite)
	taunts = list("Co za przyjemność spotkać się znowu. Mam nadzieję, że nie zawiedziecie!")
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/hostile/alicorn_boss
	name = "\proper SGV Alicorn"
	size = 1
	hide_movements = TRUE
	allow_difficulty_scaling = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/bubblegum)
	fighter_types = list(/obj/structure/overmap/hostile/ai/fighter)
	supply_types = list(/obj/structure/overmap/hostile/ai/alicorn)
	taunts = list("Potężny okręt, potężne działo, potężna amunicja. Wdzięczna rzeź miliarda istnień, by ocalić miliardy kolejnych, a wy będziecie pierwsi z wielu.")
	fleet_trait = FLEET_TRAIT_DEFENSE


//Nanotrasen fleets

/datum/fleet/nanotrasen
	name = "\improper Nanotrasen heavy combat fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/ai, /obj/structure/overmap/nanotrasen/frigate/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai, /obj/structure/overmap/nanotrasen/heavy_cruiser/ai, /obj/structure/overmap/nanotrasen/battlecruiser/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/carrier/ai)
	default_ghost_ship = /obj/structure/overmap/nanotrasen/ai
	alignment = "nanotrasen"
	hide_movements = TRUE //Friendly fleets just move around as you'd expect.
	faction_id = FACTION_ID_NT
	taunts = list("Okręcie Syndykatu, wycofaj się albo zostaniesz zniszczony", "Naruszacie naszą przestrzeń, szykujcie się na zniszczenie", "Niezidentyfikowany okręcie, zgodnie z ustawą o siłach pokojowych wasze istnienie zostanie zakończone.")
	can_reinforce = FALSE
	threat_elevation_allowed = FALSE	//Sorry EDF, nothing personal.

/datum/fleet/nanotrasen/light
	name = "\improper Nanotrasen light fleet"
	battleship_types = list(/obj/structure/overmap/nanotrasen/patrol_cruiser/ai)

/datum/fleet/nanotrasen/border
	name = "\proper Concord Border Enforcement Unit"
	taunts = list("Złamaliście prawo. Wyłączcie broń i przygotujcie się do abordażu.", "Wrogi okręcie. Natychmiast się wycofaj albo zostaniesz zniszczony.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_BORDER_PATROL

/datum/fleet/nanotrasen/border/defense
	name = "\proper 501st 'Crais' Fist' Expeditionary Force"
	taunts = list("Złamaliście prawo. Wyłączcie broń i przygotujcie się do abordażu.", "Wrogi okręcie. Natychmiast się wycofaj albo zostaniesz zniszczony.")
	size = FLEET_DIFFICULTY_EASY
	fleet_trait = FLEET_TRAIT_DEFENSE

//Solgov

/datum/fleet/solgov
	name = "\improper Solgov light exploratory fleet"
	fighter_types = list(/obj/structure/overmap/nanotrasen/solgov/ai/fighter)
	destroyer_types = list(/obj/structure/overmap/nanotrasen/solgov/ai, /obj/structure/overmap/nanotrasen/solgov/vnc/ai)
	battleship_types = list(/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/ai)
	supply_types = list(/obj/structure/overmap/nanotrasen/solgov/carrier/ai)
	alignment = "solgov"
	hide_movements = TRUE //They're "friendly" alright....
	faction_id = FACTION_ID_NT
	taunts = list("Naruszacie naszą przestrzeń, szykujcie się na zniszczenie", "Wkroczyliście w strzeżoną przestrzeń SolGov. Szykujcie się na zniszczenie", "Naruszacie porozumienie o nieagresji SolGov. Natychmiast opuśćcie tę przestrzeń.")
	size = FLEET_DIFFICULTY_EASY
	greetings = list("Sojuszniczy okręcie. Za 30 sekund zostaniecie zeskanowani pod kątem zgodności z ustawą o siłach pokojowych. Dziękujemy za współpracę.")
	var/scan_delay = 30 SECONDS
	var/scanning = FALSE

/datum/fleet/solgov/earth
	name = "\proper Earth Defense Force"
	taunts = list("Głupotą było zapuszczać się tak głęboko w przestrzeń Solgov! Główne baterie w gotowości.", "Wszyscy na stanowiska, stan 1 w całej flocie, zbliża się wrogi okręt.", "Siły obronne, w gotowości!", "Obronimy naszą ojczyznę!")
	size = FLEET_DIFFICULTY_HARD
	allow_difficulty_scaling = FALSE
	audio_cues = list()
	fleet_trait = FLEET_TRAIT_DEFENSE

/datum/fleet/solgov/assemble(datum/star_system/SS, difficulty)
	. = ..()
	if(!scanning)
		addtimer(CALLBACK(src, PROC_REF(scan)), scan_delay)
		scanning = TRUE

/datum/fleet/solgov/proc/scan()
	scanning = FALSE
	if(!current_system)
		return FALSE
	for(var/obj/structure/overmap/OM in current_system.system_contents)
		OM.relay('nsv13/sound/effects/ship/solgov_scan.ogg')
	sleep(5 SECONDS)
	for(var/obj/structure/overmap/shield_scan_target in current_system.system_contents)
		if(istype(shield_scan_target, /obj/structure/overmap/nanotrasen/solgov))
			continue //We don't scan our own boys.
		//Ruh roh.... (Persona non gratas do not need to be scanned again.)
		if((shield_scan_target.faction != shield_scan_target.name) && shield_scan_target.shields && shield_scan_target.shields.active && length(shield_scan_target.occupying_levels))
			shield_scan_target.hail("Skany wykazały, że posiadacie zakazaną technologię. \n Wasza sygnatura IFF została oznaczona jako 'persona non grata'. \n Zgodnie z przepisem SGC-reg #10124 wasz okręt i wasze życie przepadają. Natychmiast ewakuujcie cały personel cywilny i się poddajcie.", name)
			shield_scan_target.relay_to_nearby('nsv13/sound/effects/ship/solgov_scan_alert.ogg', ignore_self=FALSE)
			grant_oopsie_achievement(shield_scan_target)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(play_soundtrack_music), /datum/soundtrack_song/bee/mind_crawler, null, 120), 2 SECONDS)
			shield_scan_target.faction = shield_scan_target.name

/datum/fleet/solgov/proc/grant_oopsie_achievement(obj/structure/overmap/fugitive)
	for(var/mob/living/traitor in fugitive.mobs_in_ship)
		if(!traitor.client)
			continue
		traitor.client.give_award(/datum/award/achievement/misc/illegal_technology, traitor)

/datum/fleet/solgov/interdiction
	name = "\improper Solgov hunter fleet"
	destroyer_types = list(/obj/structure/overmap/nanotrasen/solgov/ai/interdictor)
	var/list/traitor_taunts = list("Zbuntowany okręcie, natychmiast zresetuj kody identyfikacyjne albo zostaniesz zniszczony.", "Karą za dezercję jest śmierć.", "Wasza załoga zostaje oskarżona o zdradę i naruszenie umowy. Zezwala się na użycie śmiercionośnej siły.")
	size = FLEET_DIFFICULTY_INSANE
	var/players_fired_upon = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/mind_crawler)
	var/obj/structure/overmap/hunted_ship

/datum/fleet/solgov/interdiction/New()
	. = ..()
	hunted_ship = SSstar_system.find_main_overmap()

/datum/fleet/solgov/interdiction/move(datum/star_system/target, force=FALSE)
	// If we're going home just delete us actually
	// Don't let the players game the ability to make solgov show up
	if(!hunted_ship && goal_system)
		qdel(src)
		return
	if(!target && hunted_ship)
		goal_system = hunted_ship.current_system
	. = ..()
	if(.)
		navigate_to(goal_system)	//Anytime we successfully move we recalculate the route, since players like moving around alot.

/datum/fleet/solgov/interdiction/assemble(datum/star_system/SS, difficulty)
	. = ..()
	for(var/obj/structure/overmap/OM as() in all_ships)
		RegisterSignal(OM, COMSIG_ATOM_BULLET_ACT, PROC_REF(check_bullet))

/datum/fleet/solgov/interdiction/encounter(obj/structure/overmap/OM)
	// Same as parent but detects if the player ship is hostile and uses different taunts
	if(OM.faction == alignment || federation_check(OM))
		OM.hail(pick(greetings), name)
	assemble(current_system)
	if(OM.faction != alignment && !federation_check(OM))
		if(OM.alpha >= 150)
			if(OM == SSstar_system.find_main_overmap())
				OM.hail(pick(traitor_taunts), name)
				RegisterSignal(OM, COMSIG_SHIP_BOARDED, PROC_REF(handle_iff_change))
			else
				OM.hail(pick(taunts), name)
			last_encounter_time = world.time
			if(audio_cues?.len)
				play_soundtrack_music(pick(audio_cues) , volume = 100)

/datum/fleet/solgov/interdiction/proc/check_bullet(obj/structure/overmap/source, obj/item/projectile/P)
	if(P.overmap_firer?.role == MAIN_OVERMAP)
		players_fired_upon = TRUE
		for(var/obj/structure/overmap/OM as() in all_ships)
			UnregisterSignal(OM, COMSIG_ATOM_BULLET_ACT)

/datum/fleet/solgov/interdiction/proc/handle_iff_change(obj/structure/overmap/source)
	switch(source.faction)
		if("nanotrasen")
			if(!players_fired_upon)
				hunted_ship = null
				goal_system = SSstar_system.system_by_id("Sol")
				if(current_system == source.current_system)
					source.hail("Niech to się więcej nie powtórzy.", name)
			else if(current_system == source.current_system)
				source.hail("... To już nie wystarczy.", name)
		if("syndicate")
			// Anger
			hunted_ship = source
			goal_system = null
