// AQUILA - Magnetic Field: half of the players on the ship get a positive charge and the other half a negative one.
// Opposite charges push each other away (yes, backwards, it is a space anomaly). Same charges ignore each other.
// Only player-controlled humans are charged, and the charge wears off on its own.

#define MAGNETIC_FIELD_DURATION (3 MINUTES)
/// How far, in tiles, an opposite charge pushes you away from
#define MAGNETIC_FIELD_RANGE 3

/datum/round_event_control/aquila_magnetic_field
	name = "Magnetic Field"
	typepath = /datum/round_event/aquila_magnetic_field
	weight = 10
	max_occurrences = 1
	min_players = 6
	earliest_start = 10 MINUTES

/datum/round_event/aquila_magnetic_field
	announceWhen = 1
	startWhen = 1

/datum/round_event/aquila_magnetic_field/announce(fake)
	priority_announce("Statek wleciał w anomalię magnetyczną. Członkowie załogi mogą zostać naładowani elektrycznie. \
		Osoby o przeciwnych ładunkach będą się wzajemnie odpychać. Efekt powinien ustąpić w ciągu kilku minut.", "Anomalia magnetyczna", ANNOUNCER_IONSTORM)

/datum/round_event/aquila_magnetic_field/start()
	var/list/players = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.stat == DEAD || !player.client || !is_station_level(player.z))
			continue
		players += player
	if(!length(players))
		return
	shuffle_inplace(players)
	var/half = round(length(players) / 2)
	for(var/i in 1 to length(players))
		var/mob/living/carbon/human/player = players[i]
		player.apply_status_effect(/datum/status_effect/aquila_magnetic_charge, i <= half ? -1 : 1)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Anomalia magnetyczna minęła, ładunki załogi zostały zneutralizowane.", "Anomalia magnetyczna"), MAGNETIC_FIELD_DURATION)
	log_game("Magnetic Field event charged [length(players)] players.")

/datum/status_effect/aquila_magnetic_charge
	id = "aquila_magnetic_charge"
	duration = MAGNETIC_FIELD_DURATION
	tick_interval = 5
	alert_type = null
	/// 1 for a positive charge, -1 for a negative one
	var/polarity = 1
	/// Next world.time the owner gets told why they are sliding around
	var/next_message = 0

/datum/status_effect/aquila_magnetic_charge/on_creation(mob/living/new_owner, new_polarity = 1)
	polarity = new_polarity
	examine_text = polarity > 0 ? "<span class='warning'>SUBJECTPRONOUN iskrzy się na czerwono.</span>" : "<span class='warning'>SUBJECTPRONOUN iskrzy się na niebiesko.</span>"
	return ..()

/datum/status_effect/aquila_magnetic_charge/on_apply()
	owner.add_filter("aquila_magnetic_charge", 2, list("type" = "outline", "color" = polarity > 0 ? "#ff3030" : "#3060ff", "size" = 1))
	if(polarity > 0)
		to_chat(owner, "<span class='warning'>Włosy stają ci dęba. Masz <b>dodatni</b> ładunek (+) i będziesz odpychany od osób z ujemnym!</span>")
	else
		to_chat(owner, "<span class='warning'>Włosy stają ci dęba. Masz <b>ujemny</b> ładunek (-) i będziesz odpychany od osób z dodatnim!</span>")
	return TRUE

/datum/status_effect/aquila_magnetic_charge/on_remove()
	owner.remove_filter("aquila_magnetic_charge")
	to_chat(owner, "<span class='notice'>Mrowienie ustępuje, twój ładunek zniknął.</span>")

/datum/status_effect/aquila_magnetic_charge/tick()
	if(owner.stat == DEAD || owner.buckled || owner.anchored || !isturf(owner.loc))
		return
	var/mob/living/closest
	var/closest_distance = INFINITY
	for(var/mob/living/carbon/human/other in range(MAGNETIC_FIELD_RANGE, owner))
		if(other == owner)
			continue
		var/datum/status_effect/aquila_magnetic_charge/charge = other.has_status_effect(/datum/status_effect/aquila_magnetic_charge)
		if(!charge || charge.polarity == polarity)
			continue
		var/distance = get_dist(owner, other)
		if(distance < closest_distance)
			closest = other
			closest_distance = distance
	if(!closest)
		return
	// Both sides run this, so the pair drifts apart from each other
	var/away = get_dir(closest, owner) || pick(GLOB.cardinals)
	step(owner, away)
	if(world.time >= next_message)
		next_message = world.time + 10 SECONDS
		to_chat(owner, "<span class='warning'>Niewidzialna siła odpycha cię od [closest]!</span>")

#undef MAGNETIC_FIELD_DURATION
#undef MAGNETIC_FIELD_RANGE
