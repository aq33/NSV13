// AQUILA - Magnetic Field: a magnetic anomaly polarizes the crew. Half of the players on the ship get a positive pole, the other half a negative one.
// Like poles push each other away, opposite poles pull each other in. Only the nearest polarized person within range matters.
// Only player-controlled humans are polarized, and it wears off on its own.

#define MAGNETIC_FIELD_DURATION (3 MINUTES)
/// How far, in tiles, another pole can push or pull you from
#define MAGNETIC_FIELD_RANGE 3
/// Tiles moved per status effect tick (every half a second), fractions carry over to the next tick
#define MAGNETIC_FIELD_STRENGTH 1.5

/datum/round_event_control/aquila_magnetic_field
	name = "Magnetic Field"
	typepath = /datum/round_event/aquila_magnetic_field
	weight = 10
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event/aquila_magnetic_field
	announceWhen = 1
	startWhen = 1

/datum/round_event/aquila_magnetic_field/announce(fake)
	priority_announce("Statek wleciał w anomalię magnetyczną, która spolaryzowała część załogi. \
		Osoby o tym samym biegunie będą się wzajemnie odpychać, a o przeciwnych przyciągać. Efekt powinien ustąpić w ciągu kilku minut.", "Anomalia magnetyczna", ANNOUNCER_IONSTORM)

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
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Anomalia magnetyczna minęła, polaryzacja załogi wygasła.", "Anomalia magnetyczna"), MAGNETIC_FIELD_DURATION)
	log_game("Magnetic Field event polarized [length(players)] players.")

/datum/status_effect/aquila_magnetic_charge
	id = "aquila_magnetic_charge"
	duration = MAGNETIC_FIELD_DURATION
	tick_interval = 5
	alert_type = null
	/// 1 for the positive pole, -1 for the negative one
	var/polarity = 1
	/// Movement owed from earlier ticks, so the strength can be a fraction of a tile
	var/pending_steps = 0
	/// Next world.time the owner gets told why they are sliding around
	var/next_message = 0

/datum/status_effect/aquila_magnetic_charge/on_creation(mob/living/new_owner, new_polarity = 1)
	polarity = new_polarity
	examine_text = polarity > 0 ? "<span class='warning'>SUBJECTPRONOUN otacza czerwonawa poświata anomalii.</span>" : "<span class='warning'>SUBJECTPRONOUN otacza niebieskawa poświata anomalii.</span>"
	return ..()

/datum/status_effect/aquila_magnetic_charge/on_apply()
	owner.add_filter("aquila_magnetic_charge", 2, list("type" = "outline", "color" = polarity > 0 ? "#ff3030" : "#3060ff", "size" = 1))
	if(polarity > 0)
		to_chat(owner, "<span class='warning'>Anomalia szarpie tobą jak opiłkiem przy magnesie. Masz <b>dodatni</b> biegun (+): odpychasz się od innych dodatnich, a ujemni cię przyciągają!</span>")
	else
		to_chat(owner, "<span class='warning'>Anomalia szarpie tobą jak opiłkiem przy magnesie. Masz <b>ujemny</b> biegun (-): odpychasz się od innych ujemnych, a dodatni cię przyciągają!</span>")
	return TRUE

/datum/status_effect/aquila_magnetic_charge/on_remove()
	owner.remove_filter("aquila_magnetic_charge")
	to_chat(owner, "<span class='notice'>Szarpanie ustaje, anomalia przestała na ciebie działać.</span>")

/datum/status_effect/aquila_magnetic_charge/tick()
	if(owner.stat == DEAD || owner.buckled || owner.anchored || !isturf(owner.loc))
		pending_steps = 0
		return
	var/mob/living/closest
	var/closest_distance = INFINITY
	var/attracted = FALSE
	for(var/mob/living/carbon/human/other in range(MAGNETIC_FIELD_RANGE, owner))
		if(other == owner)
			continue
		var/datum/status_effect/aquila_magnetic_charge/charge = other.has_status_effect(/datum/status_effect/aquila_magnetic_charge)
		if(!charge)
			continue
		var/distance = get_dist(owner, other)
		if(distance < closest_distance)
			closest = other
			closest_distance = distance
			attracted = charge.polarity != polarity
	// Opposite poles that already touch stay stuck together, stepping into them would just shove them around
	if(!closest || (attracted && closest_distance <= 1))
		pending_steps = 0
		return

	pending_steps += MAGNETIC_FIELD_STRENGTH
	// Both sides run this, so the pair drifts apart from (or towards) each other
	while(pending_steps >= 1)
		pending_steps--
		var/direction = attracted ? get_dir(owner, closest) : (get_dir(closest, owner) || pick(GLOB.cardinals))
		if(attracted && get_dist(owner, closest) <= 1)
			break
		step(owner, direction)

	if(world.time >= next_message)
		next_message = world.time + 10 SECONDS
		if(attracted)
			to_chat(owner, "<span class='warning'>Niewidzialna siła przyciąga cię do [closest]!</span>")
		else
			to_chat(owner, "<span class='warning'>Niewidzialna siła odpycha cię od [closest]!</span>")

#undef MAGNETIC_FIELD_DURATION
#undef MAGNETIC_FIELD_RANGE
#undef MAGNETIC_FIELD_STRENGTH
