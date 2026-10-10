/datum/reagent/drug
	name = "Drug"
	chem_flags = CHEMICAL_NOT_DEFINED
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "Nielegalny związek chemiczny używany jako narkotyk."
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.mobility_flags & MOBILITY_MOVE)
			if(prob(10))
				step(M, pick(GLOB.cardinals))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>Zaczynasz mieć mocny odlot!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Lekko skraca ogłuszenia. Przedawkowany zadaje obrażenia od toksyn i niedotlenienia."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	addiction_threshold = 10
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M)
	if(prob(1))
		var/smoke_message = pick("Czujesz się zrelaksowany.", "Czujesz się uspokojony.","Czujesz się czujny.","Czujesz się twardy.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.AdjustStun(-5, FALSE)
	M.AdjustKnockdown(-5, FALSE)
	M.AdjustUnconscious(-5, FALSE)
	M.AdjustParalyzed(-5, FALSE)
	M.AdjustImmobilized(-5, FALSE)
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank
	name = "Crank"
	description = "Skraca ogłuszenia o około 200%. Przedawkowany lub uzależniający zadaje znaczne obrażenia od toksyn, urazy i obrażenia mózgu."
	reagent_state = LIQUID
	color = "#FA00C8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/crank/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		var/high_message = pick("Czujesz się roztrzęsiony.", "Czujesz, że musisz pędzić.", "Czujesz, że musisz przyspieszyć.")
		to_chat(M, "<span class='notice'>[high_message]</span>")
	if(prob(8))
		M.adjustBruteLoss(rand(1,4))
		M.Stun(5, 0)
		to_chat(M, "<span class='notice'>Zatrzymujesz się, by wściekle drapać skórę.</span>")
	M.AdjustStun(-20, FALSE)
	M.AdjustKnockdown(-20, FALSE)
	M.AdjustUnconscious(-20, FALSE)
	M.AdjustImmobilized(-20, FALSE)
	M.AdjustParalyzed(-20, FALSE)
	M.adjustToxLoss(0.75, 0)
	M.adjustStaminaLoss(-18, 0)
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, FALSE, FALSE, BODYTYPE_ORGANIC)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3*REM)
	M.adjustToxLoss(5*REM, 0)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Chłodzi i uspokaja. Przedawkowany zadaje znaczne obrażenia mózgu i od toksyn. Przy uzależnieniu zaczyna zadawać śmiertelne urazy, bo skóra zaczyna schodzić."
	reagent_state = LIQUID
	color = "#0064B4"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("Czujesz spokój.", "Czujesz się opanowany.", "Czujesz, że musisz się zrelaksować.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage2(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Twoja skóra wydaje się luźna...</span>")
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Twoja skóra zaczyna się łuszczyć...</span>")
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(ishumanbasic(M))
		if(!istype(M.dna.species, /datum/species/human/krokodil_addict))
			to_chat(M, "<span class='userdanger'>Twoja skóra łatwo odpada!</span>")
			M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
			M.set_species(/datum/species/human/krokodil_addict)
		else
			M.adjustBruteLoss(5*REM, 0)
	else
		to_chat(M, "<span class='danger'>Twoja skóra łuszczy się i pęka!</span>")
		M.adjustBruteLoss(5*REM, 0) // repeats 5 times and then you get over it

	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Skraca ogłuszenia o około 300%, przyspiesza użytkownika i pozwala szybko odzyskiwać wytrzymałość, zadając przy tym lekkie obrażenia mózgu. Przy przedawkowaniu ofiara porusza się losowo, losowo się śmieje, upuszcza przedmioty i otrzymuje obrażenia od toksyn i mózgu. Przy uzależnieniu ofiara stale się trzęsie i ślini, potem dostaje zawrotów głowy, traci kontrolę ruchową, a w końcu otrzymuje ciężkie obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	if(L.client)
		L.client.give_award(/datum/award/achievement/misc/meth, L)

	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.5, blacklisted_movetypes=(FLYING|FLOATING))
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("Czujesz się nakręcony.", "Czujesz, że musisz pędzić jeszcze szybciej.", "Czujesz, że mógłbyś rządzić światem.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustStun(-40, FALSE)
	M.AdjustKnockdown(-40, FALSE)
	M.AdjustUnconscious(-40, FALSE)
	M.AdjustParalyzed(-40, FALSE)
	M.AdjustImmobilized(-40, FALSE)
	M.adjustStaminaLoss(-40, 0)
	M.drowsyness = max(0,M.drowsyness-30)
	M.Jitter(2)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>Dłonie [M] wariują i machają na wszystkie strony!</span>")
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/M)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/M)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Czyni cię odpornym na ogłuszenia i przyspiesza regenerację wytrzymałości, ale stajesz się niemal niekontrolowanym, brodatym, bredzącym szaleńcem."
	reagent_state = LIQUID
	color = "#FAFAFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 20
	addiction_threshold = 10
	taste_description = "salt" // because they're bathsalts?
	var/datum/martial_art/psychotic_brawling/brawling

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	brawling = new(null)
	if(!brawling.teach(L, TRUE))
		QDEL_NULL(brawling)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	brawling.remove(L)
	QDEL_NULL(brawling)
	..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("Czujesz się nabuzowany.", "Czujesz się gotowy.", "Czujesz, że możesz dojść do granic możliwości.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustStaminaLoss(-5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4)
	M.hallucination += 5
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.hallucination += 5
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i in 1 to 8)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.hallucination += 10
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(5)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.hallucination += 20
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.hallucination += 30
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 12, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.hallucination += 30
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 16, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Nakręca cię, napędza i szybko przywraca wytrzymałość. Skutki uboczne to duszności i toksyczność."
	reagent_state = LIQUID
	color = "#78FFF0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM

/datum/reagent/drug/aranesp/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/aranesp/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("Czujesz się nabuzowany.", "Czujesz się gotowy.", "Czujesz, że możesz dojść do granic możliwości.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustStaminaLoss(-20, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Wypełnia cię ekstatycznym odrętwieniem i powoduje lekkie uszkodzenia mózgu. Silnie uzależnia. Przedawkowany powoduje nagłe wahania nastroju."
	reagent_state = LIQUID
	color = "#FFF378"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	addiction_threshold = 10
	overdose_threshold = 20

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	M.confused = 0
	M.disgust = 0
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)
	..()
	. = 1

/datum/reagent/drug/happiness/overdose_process(mob/living/M)
	if(prob(30))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.Dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
	..()
	. = 1

/datum/reagent/drug/happiness/addiction_act_stage1(mob/living/M)// all work and no play makes jack a dull boy
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_DISTURBED))
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage2(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_UNSTABLE))
	M.Jitter(10)
	if(prob(30))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage3(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_CRAZY))
	M.Jitter(15)
	if(prob(40))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage4(mob/living/carbon/human/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(SANITY_INSANE)
	M.Jitter(20)
	if(prob(50))
		M.emote(pick("twitch","laugh","frown"))
	..()
	. = 1

//I had to do too much research on this to make this a thing. Hopefully the FBI won't kick my door down.
/datum/reagent/drug/ketamine
	name = "Ketamine"
	description = "Silny środek uspokajający, który wywołuje też euforię i pomaga przy bólu. Popularny na imprezach i wśród małych żabolubów jeżdżących Hondami Civic."
	reagent_state = LIQUID
	color = "#c9c9c9"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_threshold = 8
	overdose_threshold = 16

/datum/reagent/drug/ketamine/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	. = ..()

/datum/reagent/drug/ketamine/on_mob_life(mob/living/carbon/M)
	//Friendly Reminder: Ketamine is a tranquilizer and will sleep you.
	switch(current_cycle)
		if(10)
			to_chat(M, "<span class='warning'>Zaczynasz czuć zmęczenie...</span>" )
		if(11 to 25)
			M.drowsyness ++
		if(26 to INFINITY)
			M.Sleeping(60, 0)
			. = 1
	//Providing a Mood Boost
	M.confused -= 3
	M.jitteriness -= 5
	M.disgust -= 3
	//Ketamine is also a dissociative anasthetic which means Hallucinations!
	M.hallucination += 5
	..()

/datum/reagent/drug/ketamine/overdose_process(mob/living/M)
	var/obj/item/organ/brain/B = M.getorgan(/obj/item/organ/brain)
	var/gained_trauma = FALSE
	if(!gained_trauma)
		B.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
		gained_trauma = TRUE
	M.hallucination += 10
	//Uh Oh Someone is tired
	if(prob(40))
		if(HAS_TRAIT(M, TRAIT_IGNOREDAMAGESLOWDOWN))
			REMOVE_TRAIT(M, TRAIT_IGNOREDAMAGESLOWDOWN, type)
		if(prob(33))
			to_chat(M, "<span class='warning'>Twoje kończyny zaczynają ciążyć...</span>")
		else if(prob(33))
			to_chat(M, "<span class='warning'>Trudno ci się ruszać...</span>")
		else
			to_chat(M, "<span class='warning'>Masz wrażenie, że twoje kończyny się nie ruszą...</span>")
		M.drop_all_held_items()
		M.Dizzy(5)
	..()

//Addiction Gradient
/datum/reagent/drug/ketamine/addiction_act_stage1(mob/living/M)
	if(prob(20))
		M.drop_all_held_items()
		M.Jitter(2)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage2(mob/living/M)
	if(prob(30))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Jitter(3)
		M.Dizzy(3)
	..()

/datum/reagent/drug/ketamine/addiction_act_stage3(mob/living/M)
	if(prob(40))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Jitter(4)
		M.Dizzy(4)
	..()
