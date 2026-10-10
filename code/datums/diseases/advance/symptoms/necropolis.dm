/datum/symptom/necroseed
	name = "Necropolis Seed"
	desc = "Niedojrzała forma korzenia macek Lavalandu. Tworzy z nosicielem więź symbiotyczną, czyniąc go silniejszym i wytrzymalszym kosztem szybkości. Jeśli choroba zostanie wyleczona, nosiciel bardzo osłabnie"
	stealth = 0
	resistance = 3
	stage_speed = -10
	transmission = -3
	level = 9
	base_message_chance = 5
	severity = -1
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/tendrils = FALSE
	var/chest = FALSE
	var/fireproof = FALSE
	prefixes = list("Lava ", "Lavaland ", "Eldritch ")
	bodies = list("Goliath", "Tentacle", "Carapace")
	threshold_desc = "<b>Ukrycie 8:</b> po śmierci dusza nosiciela zestala się w bezbożny artefakt, przez co nie da się go już wskrzesić.<br><b>Odporność 15:</b> okolicę nosiciela wypełniają paraliżujące macki.<br><b>Odporność 20:</b> nosiciel staje się odporny na gorąco, popiół i lawę"
	var/list/cached_tentacle_turfs
	var/turf/last_location
	var/tentacle_recheck_cooldown = 100

/datum/symptom/necroseed/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 8)
		severity += 2
	if(A.resistance >= 20)
		severity -= 1

/datum/symptom/necroseed/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 15)
		tendrils = TRUE
		if(A.resistance >= 20)
			fireproof = TRUE
	if(A.stealth >= 8)
		chest = TRUE


/datum/symptom/necroseed/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>Twoja skóra wydaje się łuskowata.</span>")
		if(3, 4)
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your skin is hard.", "You feel stronger.", "You feel powerful.")]</span>")
		if(5)
			if(tendrils)
				tendril(A)
			M.dna.species.punchdamage = max(12, M.dna.species.punchdamage)
			M.dna.species.brutemod = min(0.6, M.dna.species.brutemod)
			M.dna.species.burnmod = min(0.6, M.dna.species.burnmod)
			M.dna.species.heatmod = min(0.6, M.dna.species.heatmod)
			M.add_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN, update=TRUE, priority=100, multiplicative_slowdown=1)
			ADD_TRAIT(M, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
			if(fireproof)
				ADD_TRAIT(M, TRAIT_RESISTHEAT, DISEASE_TRAIT)
				ADD_TRAIT(M, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
				M.weather_immunities |= "ash"
				M.weather_immunities |= "lava"
			if(HAS_TRAIT(M, TRAIT_NECROPOLIS_INFECTED))
				REMOVE_TRAIT(M, TRAIT_NECROPOLIS_INFECTED, "legion_core_trait")
				to_chat(M, "<span class='notice'>Macki rozluźniają uścisk, chroniąc nekropolię w tobie.</span>")
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your skin has become a hardened carapace", "Your strength is superhuman.", "You feel invincible.")]</span>")
	return

/datum/symptom/necroseed/proc/tendril(datum/disease/advance/A)
	. = A.affected_mob
	var/mob/living/loc = A.affected_mob.loc
	if(isturf(loc))
		if(!LAZYLEN(cached_tentacle_turfs) || loc != last_location || tentacle_recheck_cooldown <= world.time)
			LAZYCLEARLIST(cached_tentacle_turfs)
			last_location = loc
			tentacle_recheck_cooldown = world.time + initial(tentacle_recheck_cooldown)
			for(var/turf/open/T in (RANGE_TURFS(1, loc)-loc))
				LAZYADD(cached_tentacle_turfs, T)
		for(var/t in cached_tentacle_turfs)
			if(isopenturf(t))
				if(prob(5))
					new /obj/effect/temp_visual/goliath_tentacle/necro(t, A.affected_mob)
			else
				cached_tentacle_turfs -= t

/datum/symptom/necroseed/End(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, "<span class='danger'>Czujesz się słaby i bezsilny, gdy błogosławieństwo nekropolii opuszcza twoje ciało, zostawiając cię powolnym i bezbronnym.</span>")
	M.dna.species.punchdamage = initial(M.dna.species.punchdamage)
	M.dna.species.brutemod = initial(M.dna.species.heatmod)
	M.dna.species.burnmod = initial(M.dna.species.heatmod)
	M.dna.species.heatmod = initial(M.dna.species.heatmod)
	M.remove_movespeed_modifier(MOVESPEED_ID_NECRO_VIRUS_SLOWDOWN, TRUE)
	REMOVE_TRAIT(M, TRAIT_PIERCEIMMUNE, DISEASE_TRAIT)
	if(fireproof)
		REMOVE_TRAIT(M, TRAIT_RESISTHIGHPRESSURE, DISEASE_TRAIT)
		REMOVE_TRAIT(M, TRAIT_RESISTHEAT, DISEASE_TRAIT)
		M.weather_immunities -= "ash"
		M.weather_immunities -= "lava"

/datum/symptom/necroseed/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(chest && A.stage >= 5 && M.sethellbound())
		to_chat(M, "<span class='danger'>Twoja dusza zostaje wyrwana z ciała!</span>")
		M.visible_message("<span class='danger'>Nieziemski ryk wstrząsa ziemią, gdy [M] eksploduje deszczem krwawych szczątków, zostawiając po sobie złowieszczą, mięsistą skrzynię.</span>")
		playsound(M.loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, gib)), 0.5 SECONDS)	//we can't gib mob while it's already dying
		if(!ishuman(M) || HAS_TRAIT(M, TRAIT_NONECRODISEASE)) //We don't NEED them to be human. However, I want to avoid people making teratoma-farms for necrochests
			return
		new /obj/structure/closet/crate/necropolis/tendril(M.loc)

/obj/effect/temp_visual/goliath_tentacle/necro
	name = "fledgling necropolis tendril"

/obj/effect/temp_visual/goliath_tentacle/necro/trip()
	var/latched = FALSE
	for(var/mob/living/L in loc)
		if(L == spawner)
			retract()
			return
		visible_message("<span class='danger'>[src] chwyta [L]!</span>")
		L.Stun(40)
		L.adjustBruteLoss(rand(1,10))
		latched = TRUE
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), 10, TIMER_STOPPABLE)
