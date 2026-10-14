// AQUILA - wędrowiec pustki, antagonista z kosmosu (port z tgstation)

/// Imiona wędrowców (tg: strings/names/voidwalker.txt)
GLOBAL_LIST_INIT(voidwalker_names, list("Ere", "Vee", "Gea", "Vai", "Nei", "Dae", "Tia", "Ae", "Vex", "Voi", "Nox", "Zae", "Lia", "Ora", "Sae", "Eon", "Iva", "Ula", "Kai"))

/datum/antagonist/voidwalker
	name = "Wędrowiec pustki"
	roundend_category = "wędrowcy pustki"
	antagpanel_category = "Voidwalker"
	banning_key = ROLE_VOIDWALKER
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoVoidwalker"

/datum/antagonist/voidwalker/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/voidwalker/greet()
	to_chat(owner, "<span class='big purple bold'>Jesteś wędrowcem pustki!</span>")
	to_chat(owner, "<span class='purple'>Przybyłeś z pustki między gwiazdami, zwabiony sygnałami radiowymi tego statku. \
		W kosmosie jesteś niewidzialny i leczysz się, przenikasz przez szkło i nurkujesz pod pokładem. \
		Powal ofiarę, wyciągnij ją w kosmos (albo na mgławicowe wymiociny) i pokaż jej prawdę pustki.</span>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/effects/curse5.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Wędrowiec pustki",
		"Pokaż im piękno pustki. Porywaj, oświecaj, nie zabijaj.")

/datum/antagonist/voidwalker/proc/forge_objectives()
	var/datum/objective/voidwalker/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/voidwalker/roundend_report()
	var/voided = 0
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H.has_trauma_type(/datum/brain_trauma/voided))
			voided++
	return ..() + "<br>Oświeconych na koniec rundy: <b>[voided]</b>"

/datum/objective/voidwalker
	name = "voidwalker"

/datum/objective/voidwalker/New()
	var/static/list/explanation_texts = list(
		"Pokaż im piękno pustki. Wciągnij ich w kosmiczną otchłań, a potem przekaż im prawdę pustki. Oświecaj, nie niszcz.",
		"Muszą zobaczyć to, co ty widziałeś. Muszą przejść tam, gdzie ty chodziłeś. Zabierz ich do pustki i pokaż im prawdę. Martwi nie poznają tego, co wiesz.",
		"Odzyskaj to, co utraciłeś. Zabierz swoje dzieci w atramentową czerń i przywróć je swojemu stadu.",
	)
	explanation_text = pick(explanation_texts)
	if(prob(5))
		explanation_text = "Człowieku, jak ja kocham szkło."
	..()

/datum/objective/voidwalker/check_completion()
	return owner.current && owner.current.stat != DEAD

/// Pole w kosmosie tuż przy statku, skąd wędrowiec wyrusza
/proc/find_voidwalker_spawn()
	var/list/spawns = list()
	for(var/obj/effect/landmark/carpspawn/spawnpoint in GLOB.landmarks_list)
		var/turf/T = get_turf(spawnpoint)
		if(T && isspaceturf(T) && is_station_level(T.z))
			spawns += T
	if(length(spawns))
		return pick(spawns)
	// Bez spawnów karpi: idziemy z losowego miejsca na statku w prostej linii, aż trafimy w kosmos
	for(var/attempt in 1 to 30)
		var/turf/T = get_random_station_turf()
		if(!T)
			continue
		var/dir = pick(GLOB.cardinals)
		for(var/step in 1 to 60)
			T = get_step(T, dir)
			if(!T)
				break
			if(isspaceturf(T))
				var/turf/further = get_step(T, dir)
				return (further && isspaceturf(further)) ? further : T
	return null

/// Tworzy wędrowca w kosmosie i daje mu gracza
/proc/create_voidwalker(key, turf/spawn_loc, give_antag = TRUE)
	var/mob/living/simple_animal/hostile/voidwalker/walker = new(spawn_loc)
	var/datum/mind/player_mind = new /datum/mind(key)
	player_mind.active = TRUE
	player_mind.transfer_to(walker)
	player_mind.assigned_role = ROLE_VOIDWALKER
	player_mind.special_role = ROLE_VOIDWALKER
	if(give_antag)
		player_mind.add_antag_datum(/datum/antagonist/voidwalker)
	playsound(walker, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	return walker
