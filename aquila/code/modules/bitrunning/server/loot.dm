/// Handles calculating rewards based on number of players, parts, threats, etc
/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	rewards_base += servo_bonus

	rewards_base += (length(spawned_threat_refs) * 2)

	rewards_base += get_multiplayer_bonus()

	rewards_base += get_nohit_bonus()

	return rewards_base

/// Calculates total bonus from completing the domain in multiplayer
/obj/machinery/quantum_server/proc/get_multiplayer_bonus()
	var/total = 0
	var/multiplayer = FALSE
	for(var/datum/weakref/connection_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = connection_ref.resolve()
		if(isnull(connection))
			continue
		if(multiplayer)
			total += multiplayer_bonus
		multiplayer = TRUE
	return total

/// Calculates total bonus from completing the domain without taking damage
/obj/machinery/quantum_server/proc/get_nohit_bonus()
	if(generated_domain.domain_flags & DOMAIN_NO_NOHIT_BONUS)
		return 0

	var/total = 0
	for(var/datum/weakref/connection_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = connection_ref.resolve()
		if(connection?.nohit)
			total += nohit_bonus
	return total

/// Handles spawning the (new) crate and deleting the former
/obj/machinery/quantum_server/proc/generate_loot(obj/cache, obj/machinery/byteforge/chosen_forge)
	SSblackbox.record_feedback("tally", "bitrunning_domain_primary_completed", 1, generated_domain.key)
	for(var/mob/person in cache.contents)
		SEND_SIGNAL(person, COMSIG_BITRUNNER_CACHE_SEVER)

	spark_at_location(cache) // abracadabra!
	qdel(cache) // and it's gone!
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_COMPLETE, cache, generated_domain.reward_points)

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, TRUE)

	var/bonus = calculate_rewards()

	var/time_difference = world.time - generated_domain.start_time
	var/grade = grade_completion(time_difference)

	var/obj/item/paper/certificate = new()
	certificate.add_raw_text(get_completion_certificate(time_difference, grade))
	certificate.name = "certyfikat ukończenia domeny"
	certificate.update_appearance()

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward_cache = new(src, generated_domain, bonus)
	certificate.forceMove(reward_cache)
	label_reward(reward_cache)

	generated_domain.submit_grade(grade)

	if(can_generate_tech_disk(grade))
		SSblackbox.record_feedback("tally", "bitrunning_bepis_rewarded", 1, generated_domain.key)
		new /obj/item/disk/tech_disk/research/random(reward_cache)
		generated_domain.disk_reward_spawned = TRUE
		generated_domain.prototype?.disk_reward_spawned = TRUE

	chosen_forge.start_to_spawn(reward_cache)

	domain_complete = TRUE
	return TRUE

/// AQUILA: miejsce na podpisanie skrzynki (używa tego Pętla wygnańców)
/obj/machinery/quantum_server/proc/label_reward(obj/reward)
	return

/// Builds secondary loot if the achievements were met
/obj/machinery/quantum_server/proc/generate_secondary_loot(obj/curiosity, obj/machinery/byteforge/chosen_forge)
	SSblackbox.record_feedback("tally", "bitrunning_domain_secondary_completed", 1, generated_domain.key)
	spark_at_location(curiosity) // abracadabra!
	qdel(curiosity) // and it's gone!

	var/obj/item/storage/lockbox/bitrunning/decrypted/reward_curiosity = new(src, generated_domain)
	label_reward(reward_curiosity)

	chosen_forge.start_to_spawn(reward_curiosity)
	return TRUE


/// Returns the html text containing domain completion information
/obj/machinery/quantum_server/proc/get_completion_certificate(time_difference, grade)
	var/base_points = generated_domain.reward_points
	if(domain_randomized)
		base_points -= 1

	var/bonuses = calculate_rewards()

	var/domain_threats = length(spawned_threat_refs)

	var/completion_time = "<h3>Czas ukończenia: [DisplayTimeText(time_difference)]</h3>"

	var/completion_grade = "<hr><h1>Ocena: [grade]</h1>"

	var/text = "<h1>Certyfikat ukończenia domeny</h1><hr>"

	text += "<h3>[generated_domain.name][domain_randomized ? " (losowa)" : ""]</h3><ul>"
	text += "<li><b>Trudność:</b> [generated_domain.difficulty]</li>"
	text += "<li><b>Zagrożenia:</b> [domain_threats]</li>"
	text += "<li><b>Nagroda bazowa:</b> [base_points][domain_randomized ? " +1" : ""]</li>"
	text += "<li><b>Łączny bonus:</b> [bonuses]x</li></ul>"

	if(bonuses <= 1)
		text += completion_time
		text += completion_grade
		return text

	text += "<h3>Bonusy</h3><ul>"
	if(domain_randomized)
		text += "<li><b>Losowa:</b> + 0.2</li>"

	var/mp_bonus = get_multiplayer_bonus()
	if(mp_bonus)
		text += "<li><b>Gra zespołowa:</b> + [mp_bonus]</li>"

	var/nohit = get_nohit_bonus()
	if(nohit)
		text += "<li><b>Bez obrażeń:</b> + [nohit]</li>"

	if(domain_threats > 0)
		text += "<li><b>Zagrożenia:</b> + [domain_threats * 2]</li>"

	if(servo_bonus > 0.2)
		text += "<li><b>Części:</b> + [servo_bonus]</li>"

	text += "</ul>"
	text += completion_time
	text += completion_grade

	return text

/// Checks if the players should get a bepis reward
/obj/machinery/quantum_server/proc/can_generate_tech_disk(grade)
	if(generated_domain.disk_reward_spawned)
		return FALSE

	var/static/list/passing_grades = list(BITRUNNING_GRADE_A, BITRUNNING_GRADE_S)
	return generated_domain.difficulty >= BITRUNNER_DIFFICULTY_MEDIUM && (grade in passing_grades)


/// Grades the player's run based on several factors
/obj/machinery/quantum_server/proc/grade_completion(completion_time)
	var/score = length(spawned_threat_refs) * 5
	score += generated_domain.reward_points

	var/base = generated_domain.difficulty + 1
	var/time_score = 1

	if(completion_time <= 1 MINUTES)
		time_score = 10
	else if(completion_time <= 2 MINUTES)
		time_score = 5
	else if(completion_time <= 5 MINUTES)
		time_score = 3
	else if(completion_time <= 10 MINUTES)
		time_score = 2
	else
		time_score = 1

	score += time_score * base

	// Increases the chance for glitches to spawn based on how well they're doing
	threat += score

	switch(score)
		if(1 to 4)
			return BITRUNNING_GRADE_D
		if(5 to 7)
			return BITRUNNING_GRADE_C
		if(8 to 10)
			return BITRUNNING_GRADE_B
		if(11 to 13)
			return BITRUNNING_GRADE_A
		else
			return BITRUNNING_GRADE_S
