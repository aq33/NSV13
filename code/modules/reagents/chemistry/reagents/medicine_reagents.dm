
//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	name = "Medicine"
	chem_flags = CHEMICAL_NOT_DEFINED
	taste_description = "gorycz"

/datum/reagent/medicine/on_mob_life(mob/living/carbon/M)
	current_cycle++
	holder.remove_reagent(type, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	description = "Leporazyna skutecznie reguluje temperaturę ciała pacjenta, dbając, by nigdy nie wyszła poza bezpieczne poziomy."
	color = "#DB90C6"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	else if(M.bodytemperature < (BODYTEMP_NORMAL + 1))
		M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/medicine/leporazine/overdose_process(mob/living/M)
	if(prob(50))
		M.adjust_bodytemperature(200, 0)
	else
		M.adjust_bodytemperature(-200, 0)
	..()
	. = 1

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	description = "To magia. Nie musimy tego tłumaczyć."
	color = "#E0BB00" //golden for the gods
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "badmini"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0, 0)
	M.setOxyLoss(0, 0)
	M.radiation = 0
	M.heal_bodypart_damage(5,5)
	M.adjustToxLoss(-5, 0, TRUE)
	M.hallucination = 0
	REMOVE_TRAITS_NOT_IN(M, list(SPECIES_TRAIT, ROUNDSTART_TRAIT, ORGAN_TRAIT, TRAIT_GENERIC))
	M.set_blurriness(0)
	M.set_blindness(0)
	M.SetKnockdown(0, FALSE)
	M.SetStun(0, FALSE)
	M.SetUnconscious(0, FALSE)
	M.SetParalyzed(0, FALSE)
	M.SetImmobilized(0, FALSE)
	M.silent = FALSE
	M.dizziness = 0
	M.disgust = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.SetSleeping(0, 0)
	M.jitteriness = 0
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = BLOOD_VOLUME_NORMAL

	M.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	for(var/organ in M.internal_organs)
		var/obj/item/organ/O = organ
		O.setOrganDamage(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.danger == DISEASE_BENEFICIAL || D.danger == DISEASE_POSITIVE)
			continue
		D.cure()
	..()
	. = 1

/datum/reagent/medicine/adminordrazine/quantum_heal
	name = "Quantum Medicine"
	description = "Rzadkie i eksperymentalne cząstki, które podobno zamieniają ciało użytkownika na ciało z alternatywnego wymiaru, w którym jest całkowicie zdrowe."
	taste_description = "nauka"

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	description = "Zwiększa odporność na ogłuszenia oraz zmniejsza senność i halucynacje."
	color = "#FF00FF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustStun(-20, FALSE)
	M.AdjustKnockdown(-20, FALSE)
	M.AdjustUnconscious(-20, FALSE)
	M.AdjustImmobilized(-20, FALSE)
	M.AdjustParalyzed(-20, FALSE)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	description = "Zmniejsza senność, halucynacje i usuwa histaminę z organizmu."
	color = "#EC536D" // rgb: 236, 83, 109
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent(/datum/reagent/toxin/mindbreaker))
		holder.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
	if(holder.has_reagent(/datum/reagent/toxin/histamine))
		holder.remove_reagent(/datum/reagent/toxin/histamine, 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	description = "Natychmiast przywraca pacjentowi pełny słuch, ale nie leczy głuchoty."
	color = "#606060" //inacusiate is light grey, oculine is dark grey
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/carbon/M)
	M.restoreEars()
	..()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	description = "Mieszanka chemiczna o niemal magicznych właściwościach leczniczych. Jej głównym ograniczeniem jest to, że temperatura ciała pacjenta musi być poniżej 270 K, by prawidłowo się metabolizowała."
	color = "#0000C8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "kolor niebieski"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/M)
	var/power = -0.00003 * (M.bodytemperature ** 2) + 3
	if(M.bodytemperature < T0C)
		M.adjustOxyLoss(-3 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-power, 0)
		M.adjustToxLoss(-power, 0, TRUE) //heals TOXINLOVERs
		M.adjustCloneLoss(-power, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (M.bodytemperature ** 2) + 0.5)//Metabolism rate is reduced in colder body temps making it more effective
	..()

/datum/reagent/medicine/clonexadone
	name = "Clonexadone"
	description = "Substancja pochodna kriooksadonu. Specjalizuje się w leczeniu uszkodzeń genetycznych, ale niczego więcej. Wymaga bardzo niskich temperatur, by się prawidłowo metabolizować, i metabolizuje się szybciej niż kriooksadon."
	color = "#3D3DC6"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	taste_description = "mięśnie"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/clonexadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < T0C)
		M.adjustCloneLoss(0.00006 * (M.bodytemperature ** 2) - 6, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.000015 * (M.bodytemperature ** 2) + 0.75)//Metabolism rate is reduced in colder body temps making it more effective
	..()

/datum/reagent/medicine/pyroxadone
	name = "Pyroxadone"
	description = "Mieszanka kriooksadonu i galaretki ze szlamu, która podobno odwraca wymóg aktywacji."
	color = "#f7832a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "ostra galaretka"

/datum/reagent/medicine/pyroxadone/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		metabolization_rate = 0.2 // It metabolises effectively when the body is taking heat damage
		var/power = 0
		switch(M.bodytemperature)
			if(BODYTEMP_HEAT_DAMAGE_LIMIT to 400)
				power = 2
			if(400 to 460)
				power = 3
			else
				power = 5
		if(M.on_fire)
			power *= 2

		M.adjustOxyLoss(-2 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-1.5 * power, 0)
		M.adjustToxLoss(-power, 0, TRUE)
		M.adjustCloneLoss(-power, 0)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
		. = 1
	else //If not the right temperature for pyroxadone to work
		metabolization_rate = REAGENTS_METABOLISM
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	description = "Proszek z rybiej toksyny; rezadon skutecznie leczy uszkodzenia genetyczne i drobne rany. Przedawkowanie wywołuje silne mdłości i lekkie obrażenia od toksyn."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	overdose_threshold = 30
	taste_description = "ryba"

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.heal_bodypart_damage(1,1)
	REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
	..()
	. = 1

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.Dizzy(5)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/medicine/rezadone/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	. = ..()
	if(iscarbon(M))
		var/mob/living/carbon/patient = M
		if(reac_volume >= 5 && HAS_TRAIT_FROM(patient, TRAIT_HUSK, "burn") && patient.getFireLoss() < THRESHOLD_UNHUSK) //One carp yields 12u rezadone.
			patient.cure_husk("burn")
			patient.visible_message("<span class='nicegreen'>Ciało [patient] błyskawicznie wchłania wilgoć z otoczenia, nabierając zdrowszego wyglądu.")

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	description = "Spacyklina sprawia, że pacjent nie roznosi w zwykły sposób chorób, którymi jest zarażony."
	color = "#E1F2E6"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

//Goon Chems. Ported mainly from Goonstation. Easily mixable (or not so easily) and provide a variety of effects.
/datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	description = "Stosowany w plastrach natychmiast leczy oparzenia i dalej leczy je z czasem. Przyjęty inną drogą zadaje lekkie obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 100

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1) //NSV 13 - reverted to old application
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(M, "<span class='warning'>Nie czujesz się najlepiej...</span>")
		else if(M.getFireLoss() && method == PATCH)
			M.adjustFireLoss(-reac_volume) //NSV 13 - reverted to old application
			M.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(M, "<span class='danger'>Czujesz, jak twoje oparzenia się goją! Piecze jak diabli!</span>")
			M.emote("scream")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/silver_sulfadiazine/overdose_process(mob/living/M)
	M.adjustOxyLoss(1*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/oxandrolone
	name = "Oxandrolone"
	description = "Pobudza gojenie ciężkich oparzeń. Przedawkowanie podwaja skuteczność leczenia oparzeń, zadając przy tym obrażenia od toksyn i wątroby"
	reagent_state = LIQUID
	color = "#1E8BFF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/oxandrolone/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-3*REM, 0)
	if(M.getFireLoss() != 0)
		M.adjustStaminaLoss(3*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/oxandrolone/overdose_process(mob/living/M)
	M.adjustFireLoss(-3*REM, 0)
	M.adjustToxLoss(3*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	..()

/datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	description = "Stosowany w plastrach natychmiast leczy stłuczenia. Przyjęty inną drogą zadaje lekkie obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#FF9696"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 100

/datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1) //NSV 13 - reverted to old application
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjustToxLoss(0.5*reac_volume)
			if(show_message)
				to_chat(M, "<span class='warning'>Nie czujesz się najlepiej...</span>")
		else if(M.getBruteLoss() && method == PATCH)
			M.adjustBruteLoss(-reac_volume) //NSV 13 - reverted to old application
			M.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(M, "<span class='danger'>Czujesz, jak twoje stłuczenia się goją! Piecze jak diabli!</span>")
			M.emote("scream")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	return ..()


/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/styptic_powder/overdose_process(mob/living/M)
	M.adjustOxyLoss(1*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	description = "Ma 33% szansy na cykl metabolizmu, by wyleczyć urazy i oparzenia. Może służyć jako tymczasowy zamiennik krwi."
	reagent_state = LIQUID
	color = "#DCDCDC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	taste_description = "słodycz i sól"
	var/last_added = 0
	var/maximum_reachable = BLOOD_VOLUME_NORMAL - 10	//So that normal blood regeneration can continue with salglu active

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/carbon/M)
	if(last_added)
		M.blood_volume -= last_added
		last_added = 0
	if(M.blood_volume < maximum_reachable)	//Can only up to double your effective blood level.
		var/amount_to_add = min(M.blood_volume, volume*5)
		var/new_blood_level = min(M.blood_volume + amount_to_add, maximum_reachable)
		last_added = new_blood_level - M.blood_volume
		M.blood_volume = new_blood_level
	if(prob(33))
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
		. = TRUE
	..()

/datum/reagent/medicine/salglu_solution/overdose_process(mob/living/M)
	if(prob(3))
		to_chat(M, "<span class = 'warning'>Czujesz się słony.</span>")
		holder.add_reagent(/datum/reagent/consumable/sodiumchloride, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	else if(prob(3))
		to_chat(M, "<span class = 'warning'>Czujesz się słodki.</span>")
		holder.add_reagent(/datum/reagent/consumable/sugar, 1)
		holder.remove_reagent(/datum/reagent/medicine/salglu_solution, 0.5)
	if(prob(33))
		M.adjustBruteLoss(0.5*REM, FALSE, FALSE, BODYTYPE_ORGANIC)
		M.adjustFireLoss(0.5*REM, FALSE, FALSE, BODYTYPE_ORGANIC)
		. = TRUE
	..()

/datum/reagent/medicine/mine_salve
	name = "Miner's Salve"
	description = "Silny środek przeciwbólowy. Leczy stłuczenia i oparzenia, a do tego sprawia, że pacjent wierzy, że jest w pełni zdrowy."
	reagent_state = LIQUID
	color = "#6D6374"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/mine_salve/on_mob_life(mob/living/carbon/C)
	C.hal_screwyhud = SCREWYHUD_HEALTHY
	C.adjustBruteLoss(-0.25*REM, 0)
	C.adjustFireLoss(-0.25*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/mine_salve/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(INGEST, VAPOR, INJECT))
			M.adjust_nutrition(-5)
			if(show_message)
				to_chat(M, "<span class='warning'>Twój żołądek jest pusty i dostaje skurczów!</span>")
		else
			var/mob/living/carbon/C = M
			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.speed_modifier = max(0.1, S.speed_modifier)
				// +10% surgery speed on each step, useful while operating in less-than-perfect conditions

			if(show_message)
				to_chat(M, "<span class='danger'>Czujesz, jak twoje rany bledną i znikają!</span>" )
	..()

/datum/reagent/medicine/mine_salve/on_mob_end_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = SCREWYHUD_NONE
	..()

/datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	description = "Ma 100% szansy na natychmiastowe wyleczenie urazów i oparzeń. Jedna jednostka leczy jeden punkt obrażeń. Tylko do stosowania zewnętrznego."
	reagent_state = LIQUID
	color = "#FFEBEB"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 125

/datum/reagent/medicine/synthflesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1) //NSV 13 -  reverted to old application
	if(iscarbon(M))
		if (M.stat == DEAD)
			show_message = 0
		if(method in list(PATCH))
			M.adjustBruteLoss(-1 * reac_volume) //NSV 13 - reverted to old application
			M.adjustFireLoss(-1 * reac_volume) //NSV 13 - reverted to old application
			M.adjustStaminaLoss(reac_volume*2)
			if(show_message)
				to_chat(M, "<span class='danger'>Czujesz, jak twoje oparzenia i stłuczenia się goją! Piecze jak diabli!</span>")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
			M.emote("scream")
			//Has to be at less than THRESHOLD_UNHUSK burn damage and have at least 100 synthflesh (currently inside the body + amount now being applied). Corpses dont metabolize.
			if(HAS_TRAIT_FROM(M, TRAIT_HUSK, "burn") && M.getFireLoss() < THRESHOLD_UNHUSK && (M.reagents.get_reagent_amount(/datum/reagent/medicine/synthflesh) + reac_volume) >= 100)
				M.cure_husk("burn")
				M.visible_message("<span class='nicegreen'>Udaje ci się zastąpić większość spalonej tkanki [M].")
	..()

/datum/reagent/medicine/synthflesh/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.5*REM, 0)
	M.adjustBruteLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/synthflesh/overdose_process(mob/living/M)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/charcoal
	name = "Charcoal"
	description = "Leczy lekkie obrażenia od toksyn i powoli usuwa z krwiobiegu pacjenta inne substancje."
	reagent_state = LIQUID
	color = "#000000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = REAGENTS_METABOLISM
	taste_description = "popiół"
	process_flags = ORGANIC

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-1*REM, 0)
	. = 1
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,0.75)
	..()

/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizuje szkodliwe związki chemiczne w systemach syntetycznych."
	reagent_state = LIQUID
	color = "#F1C40F"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	process_flags = SYNTHETIC

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/M)
	M.adjustToxLoss(-2*REM, 0)
	. = 1
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,1)
	..()

/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Naprawia uszkodzenia mózgu u syntetyków."
	color = "#727272"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "metal"
	process_flags = SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (-3*REM))
	M.hallucination = max(0, M.hallucination - 10)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(prob(30) && C.has_trauma_type(BRAIN_TRAUMA_SPECIAL))
			C.cure_trauma_type(BRAIN_TRAUMA_SPECIAL)
		if(prob(10) && C.has_trauma_type(BRAIN_TRAUMA_MILD))
			C.cure_trauma_type(BRAIN_TRAUMA_MILD)
	..()

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	description = "Powoli leczy wszystkie rodzaje obrażeń. Przedawkowanie zamiast tego zadaje wszystkie rodzaje obrażeń."
	reagent_state = LIQUID
	color = "#DCDCDC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-0.5*REM, 0)
	M.adjustOxyLoss(-0.5*REM, 0)
	M.adjustBruteLoss(-0.5*REM, 0)
	M.adjustFireLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M)
	M.adjustToxLoss(1.5*REM, 0)
	M.adjustOxyLoss(1.5*REM, 0)
	M.adjustBruteLoss(1.5*REM, FALSE, FALSE, BODYTYPE_ORGANIC)
	M.adjustFireLoss(1.5*REM, FALSE, FALSE, BODYTYPE_ORGANIC)
	..()
	. = 1

/datum/reagent/medicine/calomel
	name = "Calomel"
	description = "Szybko usuwa z organizmu wszystkie substancje. Zadaje obrażenia od toksyn, jeśli pacjent jest w dobrym stanie."
	reagent_state = LIQUID
	color = "#19C832"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "kwas"

/datum/reagent/medicine/calomel/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,2.5)
	if(M.health > 20)
		M.adjustToxLoss(2.5*REM, 0)
		. = 1
	..()

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	description = "Skutecznie leczy lekkie napromieniowanie."
	reagent_state = LIQUID
	color = "#BAA15D"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/carbon/M)
	if(M.radiation > 0)
		M.radiation -= min(M.radiation, 8)
	..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	description = "Usuwa ogromne ilości napromieniowania i obrażeń od toksyn, usuwając przy tym inne substancje z organizmu."
	reagent_state = LIQUID
	color = "#E6FFF0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/carbon/M)
	M.radiation -= max(M.radiation-RAD_MOB_SAFE, 0)/50
	M.adjustToxLoss(-2*REM, 0)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,2)
	..()
	. = 1

/datum/reagent/medicine/sal_acid
	name = "Salicyclic Acid"
	description = "Pobudza gojenie ciężkich stłuczeń. Przedawkowanie podwaja skuteczność leczenia stłuczeń, zadając przy tym obrażenia od toksyn i wątroby."
	reagent_state = LIQUID
	color = "#D2D2D2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 25


/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-3*REM, 0)
	if(M.getBruteLoss() != 0)
		M.adjustStaminaLoss(3*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/sal_acid/overdose_process(mob/living/M)
	M.adjustBruteLoss(-3*REM, 0)
	M.adjustToxLoss(3*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	..()

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	description = "Szybko leczy niedotlenienie i do pewnego stopnia zapobiega kolejnemu."
	reagent_state = LIQUID
	color = "#00FFFF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG
	overdose_threshold = 25
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-3*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	..()
	. = 1

/datum/reagent/medicine/salbutamol/overdose_process(mob/living/M)
	M.reagents.add_reagent(/datum/reagent/toxin/histamine, 1)
	M.reagents.remove_reagent(/datum/reagent/medicine/salbutamol, 1)
	..()

/datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	description = "Niezwykle szybko leczy niedotlenienie, ale zadaje lekkie obrażenia od toksyn. Przedawkowanie poważnie uszkadza płuca."
	reagent_state = LIQUID
	color = "#FF6464"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	overdose_threshold = 30
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -2)
	M.adjustOxyLoss(-10*REM, 0)
	M.adjustToxLoss(1*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/perfluorodecalin/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 2)
	..()

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	description = "Zwiększa odporność na ogłuszenia i szybkość ruchu. Przedawkowanie zadaje obrażenia od toksyn i utrudnia oddychanie."
	reagent_state = LIQUID
	color = "#D2FFFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25

/datum/reagent/medicine/ephedrine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.35, blacklisted_movetypes=(FLYING|FLOATING))//mildly slower than meth

/datum/reagent/medicine/ephedrine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/carbon/M)
	if(prob(20) && iscarbon(M))
		var/obj/item/I = M.get_active_held_item()
		if(I && M.dropItemToGround(I))
			to_chat(M, "<span class ='notice'>Twoje dłonie wariują i upuszczasz to, co trzymałeś!</span>")
			M.Jitter(10)

	M.AdjustAllImmobility(-20, FALSE)
	M.adjustStaminaLoss(-10*REM, FALSE)
	..()
	return TRUE

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M)
	if(prob(2) && iscarbon(M))
		var/datum/disease/D = new /datum/disease/heart_failure
		M.ForceContractDisease(D)
		to_chat(M, "<span class='userdanger'>Jesteś prawie pewien, że twoje serce na sekundę stanęło..</span>")
		M.playsound_local(M, 'sound/effects/singlebeat.ogg', 100, 0)

	if(prob(7))
		to_chat(M, "<span class='notice'>[pick("Your head pounds.", "You feel a tight pain in your chest.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]</span>")

	if(prob(33))
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	return TRUE

/datum/reagent/medicine/ephedrine/addiction_act_stage1(mob/living/M)
	if(prob(3) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(2*REM, 0)
		M.losebreath += 2
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage2(mob/living/M)
	if(prob(6) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(3*REM, 0)
		M.losebreath += 3
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage3(mob/living/M)
	if(prob(12) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(4*REM, 0)
		M.losebreath += 4
		. = 1
	..()

/datum/reagent/medicine/ephedrine/addiction_act_stage4(mob/living/M)
	if(prob(24) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(33))
		M.adjustToxLoss(5*REM, 0)
		M.losebreath += 5
		. = 1
	..()

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	description = "Szybko usuwa z organizmu histaminę i zmniejsza drżenie. Niewielka szansa na senność."
	reagent_state = LIQUID
	color = "#64FFE6"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent(/datum/reagent/toxin/histamine,3)
	..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	description = "Środek przeciwbólowy, który pozwala pacjentowi poruszać się z pełną szybkością nawet z masywnymi przedmiotami. W dużych dawkach powoduje senność, a w końcu utratę przytomności. Przedawkowanie wywołuje różne efekty, od łagodnych po śmiertelne."
	reagent_state = LIQUID
	color = "#A9FBFB"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25

/datum/reagent/medicine/morphine/on_mob_metabolize(mob/living/L)
	..()
	L.ignore_slowdown(type)

/datum/reagent/medicine/morphine/on_mob_end_metabolize(mob/living/L)
	L.unignore_slowdown(type)
	..()

/datum/reagent/medicine/morphine/on_mob_life(mob/living/carbon/M)
	switch(current_cycle)
		if(11)
			to_chat(M, "<span class='warning'>Zaczynasz czuć zmęczenie...</span>" )
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(40, 0)
			. = 1
	..()

/datum/reagent/medicine/morphine/overdose_process(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Dizzy(2)
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.Jitter(2)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(1*REM, 0)
		. = 1
		M.Dizzy(3)
		M.Jitter(3)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Dizzy(4)
		M.Jitter(4)
	..()

/datum/reagent/medicine/morphine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		M.drop_all_held_items()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/medicine/oculine
	name = "Oculine"
	description = "Szybko leczy uszkodzenia oczu, leczy krótkowzroczność i może przywrócić wzrok niewidomym."
	reagent_state = LIQUID
	color = "#404040" //ucline is dark grey, inacusiate is light grey
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "tępa toksyna"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	eyes.applyOrganDamage(-2)
	if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
		if(prob(20))
			to_chat(M, "<span class='warning'>Twój wzrok powoli wraca...</span>")
			M.cure_blind(EYE_DAMAGE)
			M.cure_nearsighted(EYE_DAMAGE)
			M.blur_eyes(35)

	else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
		to_chat(M, "<span class='warning'>Ciemność na obrzeżach pola widzenia zanika.</span>")
		M.cure_nearsighted(EYE_DAMAGE)
		M.blur_eyes(10)
	else if(M.eye_blind || M.eye_blurry)
		M.set_blindness(0)
		M.set_blurriness(0)
	..()

/datum/reagent/medicine/atropine
	name = "Atropine"
	description = "Jeśli pacjent jest w stanie krytycznym, szybko leczy wszystkie rodzaje obrażeń i reguluje tlen w organizmie. Doskonały do stabilizowania rannych. Skutkiem ubocznym jest lekka dezorientacja."
	reagent_state = LIQUID
	color = "#1D3535" //slightly more blue, like epinephrine
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 15

/datum/reagent/medicine/atropine/on_mob_life(mob/living/carbon/M)
	if(M.health <= 20)
		M.adjustToxLoss(-4*REM, 0)
		M.adjustBruteLoss(-4*REM, 0)
		M.adjustFireLoss(-4*REM, 0)
		M.adjustOxyLoss(-5*REM, 0)
		. = 1
	M.losebreath = 0
	if(prob(20))
		M.Dizzy(5)
		M.Jitter(5)
		M.drop_all_held_items()
	..()

/datum/reagent/medicine/atropine/overdose_process(mob/living/M)
	M.reagents.add_reagent(/datum/reagent/toxin/histamine, 3)
	M.reagents.remove_reagent(/datum/reagent/medicine/atropine, 2)
	. = 1
	M.Dizzy(1)
	M.Jitter(1)
	..()

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	description = "Lekko zwiększa odporność na ogłuszenia. Powoli leczy obrażenia, jeśli pacjent jest w stanie krytycznym, i reguluje utratę tlenu. Przedawkowanie powoduje osłabienie i obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#D2FFFA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/epinephrine/on_mob_metabolize(mob/living/carbon/M)
	..()
	ADD_TRAIT(M, TRAIT_NOCRITDAMAGE, type)

/datum/reagent/medicine/epinephrine/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_NOCRITDAMAGE, type)
	..()

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/carbon/M)
	if(M.health <= M.crit_threshold)
		M.adjustToxLoss(-0.5*REM, 0)
		M.adjustBruteLoss(-0.5*REM, 0)
		M.adjustFireLoss(-0.5*REM, 0)
		M.adjustOxyLoss(-0.5*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	if(M.losebreath < 0)
		M.losebreath = 0
	M.adjustStaminaLoss(-0.5*REM, 0)
	. = 1
	if(prob(20))
		M.AdjustAllImmobility(-20, FALSE)
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	description = "Cudowny lek zdolny przywracać zmarłych do życia. Działa tylko w plastrze lub sprayu, jeśli cel ma mniej niż 100 obrażeń od urazów i od oparzeń (osobno) i nie jest wysuszony. Lekko szkodzi żywym."
	reagent_state = LIQUID
	color = "#A0E85E"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "magnesy"

/datum/reagent/medicine/strange_reagent/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.stat == DEAD)
		if(M.suiciding || M.ishellbound()) //they are never coming back
			M.visible_message("<span class='warning'>Ciało [M] nie reaguje...</span>")
			return
		if(M.getBruteLoss() >= 100 || M.getFireLoss() >= 100 || HAS_TRAIT(M, TRAIT_HUSK)) //body is too damaged to be revived
			M.visible_message("<span class='warning'>Ciałem [M] wstrząsają lekkie drgawki, po czym znów nieruchomieje.</span>")
			M.do_jitter_animation(10)
			return
		else
			M.visible_message("<span class='warning'>Ciało [M] zaczyna drgać w konwulsjach!</span>")
			M.notify_ghost_cloning(source = M)
			M.do_jitter_animation(10)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 10), 40) //jitter immediately, then again after 4 and 8 seconds
			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 10), 80)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, revive), FALSE, FALSE), 100)
	..()

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(0.5*REM, 0)
	M.adjustFireLoss(0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	description = "Skutecznie leczy uszkodzenia mózgu."
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM | CHEMICAL_GOAL_BOTANIST_HARVEST

/datum/reagent/medicine/mannitol/on_mob_add(mob/living/carbon/C)
	if(HAS_TRAIT(C, TRAIT_BRAIN_TUMOR))
		overdose_threshold = 35 // special overdose to brain tumor quirker
	..()


/datum/reagent/medicine/mannitol/on_mob_life(mob/living/carbon/C)
	if(HAS_TRAIT(C, TRAIT_BRAIN_TUMOR)) // to brain tumor quirker
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "brain_tumor", /datum/mood_event/brain_tumor_mannitol)
		if(!overdosed)
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.5*REM)
	else // to ordinary people
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2*REM)
	..()

/datum/reagent/medicine/mannitol/overdose_process(mob/living/carbon/C)
	if(HAS_TRAIT(C, TRAIT_BRAIN_TUMOR))
		if(prob(10))
			C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.1*REM)
	..()


/datum/reagent/medicine/neurine
	name = "Neurine"
	description = "Reaguje z tkanką nerwową, pomagając odbudować uszkodzone połączenia. Może leczyć drobne urazy."
	color = "#C0C0C0" //ditto
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM

/datum/reagent/medicine/neurine/on_mob_life(mob/living/carbon/C)
	if(holder.has_reagent(/datum/reagent/consumable/ethanol/neurotoxin))
		holder.remove_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 5)
	if(prob(15))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	description = "Usuwa drżenie i naprawia wady genetyczne."
	color = "#5096C8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "kwas"

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	if(M.has_dna())
		M.dna.remove_all_mutations(mutadone = TRUE)
	if(!QDELETED(M)) //We were a monkey, now a human
		..()

/datum/reagent/medicine/antihol
	name = "Antihol"
	description = "Usuwa alkohol z organizmu pacjenta i eliminuje jego skutki uboczne. Mniej skuteczny u osób o słabej głowie."
	color = "#00B4C8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	taste_description = "surowe jajko"

/datum/reagent/medicine/antihol/on_mob_life(mob/living/carbon/M)
	if(!HAS_TRAIT(M, TRAIT_LIGHT_DRINKER))
		M.dizziness = 0
		M.drowsyness = 0
		M.slurring = 0
		M.confused = 0
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.drunkenness = max(H.drunkenness - 10, 0)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM, 0)
	..()
	. = 1

//Stimulants. Used in Adrenal Implant
/datum/reagent/medicine/amphetamine
	name = "Amphetamine"
	description = "Zwiększa odporność na ogłuszenia i szybkość ruchu, a do tego leczy drobne obrażenia i osłabienie. Przedawkowanie powoduje osłabienie i obrażenia od toksyn."
	color = "#78008C"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

/datum/reagent/medicine/amphetamine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.5, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/medicine/amphetamine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/medicine/amphetamine/on_mob_life(mob/living/carbon/M)
	if(M.health < 50 && M.health > 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
	M.AdjustAllImmobility(-60, FALSE)
	M.adjustStaminaLoss(-35*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/amphetamine/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()


//Pump-Up for Pump-Up Stimpack
/datum/reagent/medicine/pumpup
	name = "Pump-Up"
	description = "Daje odporność na spowolnienie od obrażeń, odporność na inne spowolnienia i lekko przyspiesza. Przedawkowanie powoduje osłabienie i obrażenia od toksyn."
	color = "#78008C"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

/datum/reagent/medicine/pumpup/on_mob_life(mob/living/carbon/M as mob)
	M.AdjustAllImmobility(-80, FALSE)
	M.adjustStaminaLoss(-80, 0)
	M.Jitter(300)
	..()
	return TRUE

/datum/reagent/medicine/pumpup/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)

/datum/reagent/medicine/pumpup/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)

/datum/reagent/medicine/pumpup/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM, 0)
		M.adjustToxLoss(1*REM, 0)
		M.losebreath++
		. = 1
	..()


/datum/reagent/medicine/insulin
	name = "Insulin"
	description = "Zwiększa tempo zużywania cukru."
	reagent_state = LIQUID
	color = "#FFFFF0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/insulin/on_mob_life(mob/living/carbon/M)
	if(M.AdjustSleeping(-20, FALSE))
		. = 1
	M.reagents.remove_reagent(/datum/reagent/consumable/sugar, 3)
	..()

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.
/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	description = "Leczy stłuczenia. Przedawkowanie uszkadza wątrobę."
	reagent_state = LIQUID
	color = "#bf0000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() < 50)
		M.adjustBruteLoss(-1.5*REM, 0)
	else
		M.adjustBruteLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	..()
	. = 1

/datum/reagent/medicine/dexalin
	name = "Dexalin"
	description = "Leczy niedotlenienie. Przedawkowanie zamiast tego je wywołuje."
	reagent_state = LIQUID
	color = "#0080FF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG
	overdose_threshold = 30

/datum/reagent/medicine/dexalin/on_mob_life(mob/living/carbon/M)
	if(M.getOxyLoss() < 50)
		M.adjustOxyLoss(-1.5*REM, 0)
	else
		M.adjustOxyLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/dexalin/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 2)
	..()
	. = 1

/datum/reagent/medicine/dexalinp
	name = "Dexalin Plus"
	description = "Leczy niedotlenienie. Przedawkowanie poważnie uszkadza serce. Bardzo skuteczny."
	reagent_state = LIQUID
	color = "#0040FF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	overdose_threshold = 25

/datum/reagent/medicine/dexalinp/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-3*REM, 0)
	if(M.getOxyLoss() != 0)
		M.adjustStaminaLoss(3*REM, FALSE)
	..()
	. = 1

/datum/reagent/medicine/dexalinp/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 4)
	..()
	. = 1

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	description = "Leczy oparzenia. Przedawkowanie uszkadza wątrobę."
	reagent_state = LIQUID
	color = "#FFa800"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() < 50)
		M.adjustFireLoss(-1.5*REM, 0)
	else
		M.adjustFireLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	..()
	. = 1

/datum/reagent/medicine/antitoxin
	name = "Anti-Toxin"
	description = "Leczy obrażenia od toksyn i usuwa toksyny z krwiobiegu. Przedawkowanie zadaje obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#00a000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	taste_description = "rolka gazy"

/datum/reagent/medicine/antitoxin/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() < 50)
		M.adjustToxLoss(-1.5*REM, 0)
	else
		M.adjustToxLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/antitoxin/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 2)
	..()
	. = 1

/datum/reagent/medicine/carthatoline
	name = "Carthatoline"
	description = "Kartatolina to silny środek przeczyszczający stosowany przy ciężkich zatruciach."
	reagent_state = LIQUID
	color = "#225722"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	overdose_threshold = 25

/datum/reagent/medicine/carthatoline/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-3*REM, 0)
	if(M.getToxLoss() && prob(10))
		M.vomit(1)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)
	..()
	. = 1

/datum/reagent/medicine/carthatoline/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	..()
	. = 1

/datum/reagent/medicine/meclizine
	name = "Meclizine"
	description = "Lek zapobiegający wymiotom."
	reagent_state = LIQUID
	color = "#cecece"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/meclizine/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.adjustToxLoss(-1)
	..()
	. = TRUE //Some other poor sod can do the rest, I just make chems

/datum/reagent/medicine/meclizine/overdose_process(mob/living/M)
	M.adjustToxLoss(2)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 2)
	..()
	. = TRUE

/datum/reagent/medicine/meclizine/on_mob_metabolize(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_NOVOMIT, type)

/datum/reagent/medicine/meclizine/on_mob_end_metabolize(mob/living/M)
	..()
	REMOVE_TRAIT(M, TRAIT_NOVOMIT, type)

/datum/reagent/medicine/hepanephrodaxon
	name = "Hepanephrodaxon"
	description = "Służy do naprawy zwykłych tkanek biorących udział w filtracji."
	taste_description = "klej"
	reagent_state = LIQUID
	color = "#D2691E"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = REM * 3.75
	overdose_threshold = 10

/datum/reagent/medicine/hepanephrodaxon/on_mob_life(var/mob/living/carbon/M)
	var/repair_strength = 1
	var/obj/item/organ/liver/L = M.getorganslot(ORGAN_SLOT_LIVER)
	if(L.damage > 0)
		L.damage = max(L.damage - 4 * repair_strength, 0)
		M.confused = (2)
	M.adjustToxLoss(-6)
	..()
	. = 1

/datum/reagent/medicine/hepanephrodaxon/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	M.confused = (2)
	..()
	. = 1

/datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	description = "Stabilizuje oddech pacjentów. Dobry dla osób w stanie krytycznym."
	reagent_state = LIQUID
	color = "#A4D8D8"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/carbon/M)
	if(M.losebreath >= 5)
		M.losebreath -= 5
	..()

/datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	description = "Ma dużą szansę na wyleczenie wszystkich rodzajów obrażeń. Przedawkowanie zadaje obrażenia od toksyn i wątroby."
	reagent_state = LIQUID
	color = "#707A00" //tricord's component chems mixed together, olive.
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG
	overdose_threshold = 30
	taste_description = "obrzydliwość"

/datum/reagent/medicine/tricordrazine/on_mob_life(mob/living/carbon/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
		. = 1
	..()

/datum/reagent/medicine/tricordrazine/overdose_process(mob/living/M)
	M.adjustToxLoss(2*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 3)
	..()
	. = 1

/datum/reagent/medicine/regen_jelly
	name = "Regenerative Jelly"
	description = "Stopniowo regeneruje wszystkie rodzaje obrażeń, nie szkodząc anatomii szlamów."
	reagent_state = LIQUID
	color = "#CC23FF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "galaretka"

/datum/reagent/medicine/regen_jelly/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-1.5*REM, 0)
	M.adjustFireLoss(-1.5*REM, 0)
	M.adjustOxyLoss(-1.5*REM, 0)
	M.adjustToxLoss(-1.5*REM, 0, TRUE) //heals TOXINLOVERs
	. = 1
	..()

/datum/reagent/medicine/regen_ooze
	name = "Regenerative Ooze"
	description = "Stopniowo regeneruje wszystkie rodzaje obrażeń, nie szkodząc anatomii szlamów."
	reagent_state = LIQUID
	color = "#65d891"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "galaretka"

/datum/reagent/medicine/regen_ooze/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5*REM, 0)
	M.adjustFireLoss(-0.5*REM, 0)
	M.adjustOxyLoss(-0.5*REM, 0)
	M.adjustToxLoss(-0.5*REM, 0, TRUE) //heals TOXINLOVERs
	. = 1
	..()

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	description = "Miniaturowe roboty medyczne, które szybko leczą obrażenia ciała."
	reagent_state = SOLID
	color = "#555555"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-5*REM, 0) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REM, 0)
	M.adjustOxyLoss(-15, 0)
	M.adjustToxLoss(-5*REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -15*REM)
	M.adjustCloneLoss(-3*REM, 0)
	if (M.blood_volume < BLOOD_VOLUME_NORMAL)
		M.blood_volume = max(M.blood_volume, min(M.blood_volume + 4, BLOOD_VOLUME_NORMAL))
	..()
	. = 1

/datum/reagent/medicine/syndicate_nanites/overdose_process(mob/living/carbon/M) //wtb flavortext messages that hint that you're vomitting up robots
	if(prob(25))
		M.reagents.remove_reagent(type, metabolization_rate*15) // ~5 units at a rate of 0.4 but i wanted a nice number in code
		M.vomit(20) // nanite safety protocols make your body expel them to prevent harmies
	..()
	. = 1

/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	description = "Wydzielina z niezwykle potężnej rośliny. Świetna do leczenia ran, ale trochę obciąża mózg."
	color = "#FFAF00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	overdose_threshold = 25

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-3 * REM, 0)
	M.adjustFireLoss(-3 * REM, 0)
	M.adjustOxyLoss(-15 * REM, 0)
	M.adjustToxLoss(-3 * REM, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM, 150) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	M.adjustCloneLoss(-1 * REM, 0)
	M.adjustStaminaLoss(-30 * REM, 0)
	M.jitteriness = min(max(0, M.jitteriness + 3), 30)
	M.druggy = min(max(0, M.druggy + 10), 15) //See above
	..()
	. = 1

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	M.adjustToxLoss(5 * REM, 0)
	..()
	. = 1

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	description = "Zwiększa tempo zużywania większości środków pobudzających i halucynogennych. Zmniejsza efekty narkotyków i drżenie. Poważnie spowalnia regenerację wytrzymałości, powoduje senność. Niewielka szansa na uszkodzenie mózgu."
	reagent_state = LIQUID
	color = "#27870a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/drug/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,5)
	M.drowsyness += 2
	if(M.jitteriness >= 3)
		M.jitteriness -= 3
	if (M.hallucination >= 5)
		M.hallucination -= 5
	if(prob(20))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1*REM, 50)
	M.adjustStaminaLoss(2.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/lavaland_extract
	name = "Lavaland Extract"
	description = "Wyciąg z atmosferycznych i mineralnych składników Lavalandu. W małych dawkach leczy, poza tym jest skrajnie toksyczny."
	color = "#6B372E" //dark and red like lavaland
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 3 //To prevent people stacking massive amounts of a very strong healing reagent

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/M)
	M.heal_bodypart_damage(5,5)
	..()
	return TRUE

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/M)
	M.adjustBruteLoss(3*REM, 0, FALSE, BODYTYPE_ORGANIC)
	M.adjustFireLoss(3*REM, 0, FALSE, BODYTYPE_ORGANIC)
	M.adjustToxLoss(3*REM, 0)
	..()
	return TRUE

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingadrenaline
	name = "Changeling Adrenaline"
	description = "Skraca czas utraty przytomności, powalenia i ogłuszenia. Przywraca wytrzymałość, ale przedawkowany zadaje obrażenia od toksyn."
	color = "#C1151D"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30

/datum/reagent/medicine/changelingadrenaline/on_mob_life(mob/living/carbon/M as mob)
	M.AdjustAllImmobility(-20, FALSE)
	M.adjustStaminaLoss(-20, 0)
	..()
	return TRUE

/datum/reagent/medicine/changelingadrenaline/overdose_process(mob/living/M as mob)
	M.adjustToxLoss(2, 0)
	..()
	return TRUE

/datum/reagent/medicine/changelinghaste
	name = "Changeling Haste"
	description = "Drastycznie zwiększa szybkość ruchu, ale zadaje obrażenia od toksyn."
	color = "#AE151D"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1

/datum/reagent/medicine/changelinghaste/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/medicine/changelinghaste/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/medicine/changelinghaste/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(2, 0)
	..()
	return TRUE

/datum/reagent/medicine/corazone
	// Heart attack code will not do damage if corazone is present
	// because it's SPACE MAGIC ASPIRIN
	name = "Corazone"
	description = "Lek wspomagający leczenie serca oraz stabilizujący serce i wątrobę."
	color = "#F49797"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 20
	self_consuming = TRUE

/datum/reagent/medicine/corazone/on_mob_metabolize(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, -1.5)
	..()
	ADD_TRAIT(M, TRAIT_STABLEHEART, type)
	ADD_TRAIT(M, TRAIT_STABLELIVER, type)

/datum/reagent/medicine/corazone/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_STABLEHEART, type)
	REMOVE_TRAIT(M, TRAIT_STABLELIVER, type)
	..()

/datum/reagent/medicine/corazone/overdose_process(mob/living/M)
	M.reagents.add_reagent(/datum/reagent/toxin/histamine, 1)
	M.reagents.remove_reagent(/datum/reagent/medicine/corazone, 1)
	..()

/datum/reagent/medicine/muscle_stimulant
	name = "Muscle Stimulant"
	description = "Silna substancja, która pozwala osobie pod jej wpływem zachować pełną sprawność fizyczną nawet przy ogromnym bólu."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/medicine/muscle_stimulant/on_mob_metabolize(mob/living/M)
	. = ..()
	M.ignore_slowdown(type)

/datum/reagent/medicine/muscle_stimulant/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M.unignore_slowdown(type)

/datum/reagent/medicine/modafinil
	name = "Modafinil"
	description = "Długo działający środek zapobiegający senności, który bardzo lekko skraca ogłuszenia i powalenia. Przedawkowanie ma okropne skutki uboczne i zadaje śmiertelne niedotlenienie; jeśli się tym nie zająć, pozbawi cię przytomności."
	reagent_state = LIQUID
	color = "#BEF7D8" // palish blue white
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 20 // with the random effects this might be awesome or might kill you at less than 10u (extensively tested)
	taste_description = "sól" // it actually does taste salty
	var/overdose_progress = 0 // to track overdose progress

/datum/reagent/medicine/modafinil/on_mob_metabolize(mob/living/M)
	ADD_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()
	M.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/medicine/modafinil/on_mob_end_metabolize(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_SLEEPIMMUNE, type)
	..()
	M.remove_movespeed_modifier(type)

/datum/reagent/medicine/modafinil/on_mob_life(mob/living/carbon/M)
	if(!overdosed) // We do not want any effects on OD
		overdose_threshold = overdose_threshold + rand(-10,10)/10 // for extra fun
		M.AdjustAllImmobility(-20, FALSE)
		M.adjustStaminaLoss(-15*REM, 0)
		M.Jitter(1)
		metabolization_rate = 0.01 * REAGENTS_METABOLISM * rand(5,20) // randomizes metabolism between 0.02 and 0.08 per tick
		. = TRUE
	..()

/datum/reagent/medicine/modafinil/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>Okropnie brakuje ci tchu i drżysz!</span>")
	metabolization_rate = 0.025 * REAGENTS_METABOLISM // sets metabolism to 0.01 per tick on overdose

/datum/reagent/medicine/modafinil/overdose_process(mob/living/M)
	overdose_progress++
	switch(overdose_progress)
		if(1 to 40)
			M.jitteriness = min(M.jitteriness+1, 10)
			M.stuttering = min(M.stuttering+1, 10)
			M.Dizzy(5)
			if(prob(50))
				M.losebreath++
		if(41 to 80)
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
			M.jitteriness = min(M.jitteriness+1, 20)
			M.stuttering = min(M.stuttering+1, 20)
			M.Dizzy(10)
			if(prob(50))
				M.losebreath++
			if(prob(20))
				to_chat(M, "Dostajesz nagłego ataku!")
				M.emote("moan")
				M.Paralyze(20, 1, 0) // you should be in a bad spot at this point unless epipen has been used
		if(81)
			to_chat(M, "Jesteś zbyt wyczerpany, by kontynuować!") // at this point you will eventually die unless you get charcoal
			M.adjustOxyLoss(0.1*REM, 0)
			M.adjustStaminaLoss(0.1*REM, 0)
		if(82 to INFINITY)
			M.Sleeping(100, 0, TRUE)
			M.adjustOxyLoss(1.5*REM, 0)
			M.adjustStaminaLoss(1.5*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/psicodine
	name = "Psicodine"
	description = "Tłumi niepokój i inne formy cierpienia psychicznego. Przedawkowanie wywołuje halucynacje i lekkie obrażenia od toksyn."
	reagent_state = LIQUID
	color = "#07E79E"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_CHEMIST_DRUG | CHEMICAL_GOAL_CHEMIST_BLOODSTREAM
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	var/dosage

/datum/reagent/medicine/psicodine/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)

/datum/reagent/medicine/psicodine/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	..()

/datum/reagent/medicine/psicodine/on_mob_life(mob/living/carbon/M) //0.1 Metabolism at tick rate 1.8 secs
	dosage++
	M.jitteriness = max(0, M.jitteriness-6)
	M.dizziness = max(0, M.dizziness-6)
	M.confused = max(0, M.confused-6)
	M.disgust = max(0, M.disgust-6)
	if(dosage >= 25) //45 seconds
		if(is_hivemember(M))
			for(var/datum/antagonist/hivemind/hive in GLOB.antagonists)
				if(hive.hivemembers.Find(M.mind))
					var/mob/living/carbon/C = hive.owner.current
					if(C?.mind)
						to_chat(C, "<span class='assimilator'>Wykrywamy skok energii psionicznej z odległego naczynia, zanim zniknęło z roju. Cokolwiek się stało, jest duża szansa, że teraz na nas polują.</span>")
			if(IS_WOKEVESSEL(M))
				M.mind.remove_antag_datum(/datum/antagonist/hivevessel)
				ADD_TRAIT(M, TRAIT_HIVE_BURNT, HIVEMIND_TRAIT)
			to_chat(M, "<span class='assimilator'>W twoim umyśle rozbrzmiewa nadprzyrodzone zawodzenie, gdy w końcu zostajesz uwolniony. W głębi duszy czujesz pozostałą obecność tych, którzy cię zniewolili... a oni czują twoją!</span>")
			remove_hivemember(M)

	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	if(mood.sanity <= SANITY_NEUTRAL) // only take effect if in negative sanity and then...
		mood.setSanity(min(mood.sanity+5, SANITY_NEUTRAL)) // set minimum to prevent unwanted spiking over neutral
	..()
	. = 1

/datum/reagent/medicine/psicodine/overdose_process(mob/living/M)
	M.hallucination = min(max(0, M.hallucination + 5), 60)
	M.adjustToxLoss(1, 0)
	..()
	. = 1

/datum/reagent/medicine/silibinin
	name = "Silibinin"
	description = "Hepatoprotekcyjna mieszanka flawonolignanów z ostu, która pomaga cofnąć uszkodzenia wątroby."
	reagent_state = SOLID
	color = "#FFFFD0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/silibinin/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -2)//Add a chance to cure liver trauma once implemented.
	..()
	. = 1

/datum/reagent/medicine/polypyr  //This is intended to be an ingredient in advanced chems.
	name = "Polypyrylium Oligomers"
	description = "Fioletowa mieszanka krótkich łańcuchów polielektrolitów, trudna do syntezy w laboratorium. Ceniona jako półprodukt w syntezie najnowocześniejszych leków."
	reagent_state = SOLID
	color = "#9423FF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 50
	taste_description = "odrętwiająca gorycz"

/datum/reagent/medicine/polypyr/on_mob_life(mob/living/carbon/M) //I wanted a collection of small positive effects, this is as hard to obtain as coniine after all.
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25)
	M.adjustBruteLoss(-0.35, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.cauterise_wounds(0.1)
	..()
	. = 1

/datum/reagent/medicine/polypyr/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M) && reac_volume >= 0.5)
			var/mob/living/carbon/human/H = M
			H.hair_color = "92f"
			H.facial_hair_color = "92f"
			H.update_hair()

/datum/reagent/medicine/polypyr/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5)
	..()
	. = 1

/datum/reagent/medicine/stabilizing_nanites
	name = "Stabilizing nanites"
	description = "Szybko wyprowadza pacjenta ze stanu krytycznego, regenerując uszkodzone komórki. Rozproszenie nanitów we krwi sprawia, że są nieskuteczne u osób w umiarkowanie dobrym stanie."
	reagent_state = LIQUID
	color = "#000000"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 15

/datum/reagent/medicine/stabilizing_nanites/on_mob_life(mob/living/carbon/M)
	if(M.health <= 80)
		M.adjustToxLoss(-4*REM, 0)
		M.adjustBruteLoss(-4*REM, 0)
		M.adjustFireLoss(-4*REM, 0)
		M.adjustOxyLoss(-5*REM, 0)
		. = 1
	if(prob(20))
		M.Jitter(5)
	M.losebreath = 0
	if (M.blood_volume < BLOOD_VOLUME_SAFE)
		M.blood_volume = max(M.blood_volume, min(M.blood_volume + 4, BLOOD_VOLUME_SAFE))
	..()

/datum/reagent/medicine/stabilizing_nanites/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NO_BLEEDING, type)

/datum/reagent/medicine/stabilizing_nanites/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NO_BLEEDING, type)
