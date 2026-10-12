///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// 	condiments, additives, and such go.


/datum/reagent/consumable
	name = "Consumable"
	chem_flags = CHEMICAL_NOT_DEFINED
	taste_description = "zwykłe jedzenie"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/quality = 0	//affects mood, typically higher for mixed drinks with more complex recipes
	/// AQ EDIT - How much does this hydrate you?
	var/hydration_factor = 1 * REAGENTS_METABOLISM

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER) && !HAS_TRAIT(H, TRAIT_POWERHUNGRY))
			H.adjust_nutrition(nutriment_factor)
		if(!HAS_TRAIT(H, TRAIT_NOTHIRST))
			H.adjust_hydration(get_hydration_factor())
	holder.remove_reagent(type, metabolization_rate)

/datum/reagent/consumable/proc/get_hydration_factor()
	return hydration_factor

/datum/reagent/consumable/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == INGEST)
		if (quality && !HAS_TRAIT(M, TRAIT_AGEUSIA))
			switch(quality)
				if (DRINK_BAD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
				if (DRINK_NICE)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_nice)
				if (DRINK_GOOD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_good)
				if (DRINK_VERYGOOD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_verygood)
				if (DRINK_FANTASTIC)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)
	return ..()

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "Wszystkie witaminy, minerały i węglowodany, których potrzebuje ciało, w czystej postaci."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/M)
	if(prob(50))
		M.heal_bodypart_damage(brute_heal,burn_heal, 0)
		. = 1
	..()

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = newdata.Copy()
	counterlist_scale(other_taste_amounts, newvolume)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	description = "Wszystkie najlepsze witaminy, minerały i węglowodany, których potrzebuje ciało, w czystej postaci."

	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/M)
	if(M.satiety < 600)
		M.satiety += 30
	. = ..()

/datum/reagent/consumable/nutriment/protein //this is from a tg pr that actually makes use of this reagent. At the moment that I am porting newfood, we are just using it as filler to have something other than vitamins and nutriments.
	name = "Protein"
	description = "Naturalny poliamid zbudowany z aminokwasów. Niezbędny składnik większości znanych form życia."
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	nutriment_factor = 9 * REAGENTS_METABOLISM //45% as calorie dense as corn oil.

/datum/reagent/consumable/nutriment/fat
	name = "Fat"
	description = "Triglicerydy występujące w olejach roślinnych i tłuszczu zwierzęcym."
	color = "#f0eed7"
	taste_description = "smalec"
	brute_heal = 0
	burn_heal = 1
	nutriment_factor = 18 // Twice as nutritious compared to protein and carbohydrates
	var/fry_temperature = 450 //Around ~350 F (117 C) which deep fryers operate around in the real world

/datum/reagent/consumable/nutriment/fat/reaction_obj(obj/exposed_obj, reac_volume)
	. = ..()
	if(!holder || (holder.chem_temp <= fry_temperature))
		return
	if(!isitem(exposed_obj) || HAS_TRAIT(exposed_obj, TRAIT_FOOD_FRIED))
		return
	// if the fried obj is indestructible or under the fry blacklist (His Grace), we dont want it to be fried, for obvious reasons
	if(is_type_in_typecache(exposed_obj, GLOB.oilfry_blacklisted_items) || (exposed_obj.resistance_flags & INDESTRUCTIBLE))
		exposed_obj.visible_message("<span class='notice'>Gorący olej nie działa na [exposed_obj]!</span>")
		return
	// if we are holding an item/atom inside, we dont want to arbitrarily fry this item
	if(SEND_SIGNAL(exposed_obj, COMSIG_CONTAINS_STORAGE))
		exposed_obj.visible_message("<span class='notice'>Gorący olej pryska, gdy [exposed_obj] go dotyka. Wygląda na zbyt pełny, by się porządnie usmażyć!</span>")
		return

	log_game("[exposed_obj.name] ([exposed_obj.type]) has been deep fried by a reaction with cooking oil reagent at [AREACOORD(exposed_obj)].")
	exposed_obj.visible_message("<span class='warning'>[exposed_obj] błyskawicznie się smaży, oblany gorącym olejem! Jakimś cudem.</span>")
	exposed_obj.AddElement(/datum/element/fried_item, volume)
	exposed_obj.reagents.add_reagent(src.type, reac_volume)

/datum/reagent/consumable/nutriment/fat/reaction_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods == VAPOR || methods == TOUCH) || isnull(holder) || (holder.chem_temp < fry_temperature)) //Directly coats the mob, and doesn't go into their bloodstream
		return

	var/burn_damage = min(1, (holder.chem_temp / fry_temperature) * 0.33) //Damage taken per unit //NSV13 - per unit damage also caps at 1 to counteract microdosing.
	if(methods & TOUCH)
		burn_damage *= max(1 - touch_protection, 0)
	var/FryLoss = round(min(30, burn_damage * reac_volume)) //NSV13 - total damage caps at 30.
	if(!HAS_TRAIT(exposed_mob, TRAIT_OIL_FRIED))
		exposed_mob.visible_message("<span class='warning'>Wrzący olej skwierczy, pokrywając [exposed_mob]!</span>", \
		"<span class='userdanger'>Zostajesz oblany wrzącym olejem!</span>")
		if(FryLoss)
			exposed_mob.emote("scream")
		playsound(exposed_mob, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
		ADD_TRAIT(exposed_mob, TRAIT_OIL_FRIED, "cooking_oil_react")
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, unfry_mob)), 3)
	if(FryLoss)
		exposed_mob.adjustFireLoss(FryLoss)

/datum/reagent/consumable/nutriment/fat/reaction_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf) || isgroundlessturf(exposed_turf) || (reac_volume < 5))
		return
	exposed_turf.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume * 1.5 SECONDS)
	exposed_turf.name = "deep-fried [initial(exposed_turf.name)]"
	exposed_turf.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)

/datum/reagent/consumable/nutriment/fat/oil
	name = "Vegetable Oil"
	description = "Rodzaj oleju spożywczego z tłuszczów roślinnych. Używany do przygotowywania i smażenia potraw."
	color = "#EADD6B" //RGB: 234, 221, 107 (based off of canola oil)
	taste_mult = 0.8
	taste_description = "olej"
	nutriment_factor = 7 //Not very healthy on its own
	metabolization_rate = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/nutriment/fat/oil/olive
	name = "Olive Oil"
	description = "Wysokiej jakości olej, odpowiedni do dań, w których olej jest kluczowym smakiem."
	taste_description = "oliwa z oliwek"
	color = "#DBCF5C"
	nutriment_factor = 10

/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "Związek organiczny powszechnie znany jako cukier stołowy, czasem nazywany sacharozą. Ten biały, bezwonny, krystaliczny proszek ma przyjemny, słodki smak."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 100 // Hyperglycaemic shock
	taste_description = "słodycz"

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>Wpadasz we wstrząs hiperglikemiczny! Odpuść sobie te ciastka!</span>")
	M.AdjustSleeping(600, FALSE)
	. = 1

/datum/reagent/consumable/sugar/overdose_process(mob/living/M)
	M.AdjustSleeping(40, FALSE)
	..()
	. = 1

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "Mieszanka wody i mleka. Komórki wirusów mogą jej używać do rozmnażania."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "wodniste mleko"

/datum/reagent/consumable/virus_food/on_mob_life(mob/living/carbon/M)
	. = ..()
	for(var/datum/disease/D in M.diseases)
		if(D.spread_flags & DISEASE_SPREAD_SPECIAL || D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS)
			continue
		if(prob(D.stage_prob * 10))
			D.update_stage(min(D.stage += 1, D.max_stages))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "Słony sos z soi."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "umami"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Keczup, ketchup, jak zwał. To przecier pomidorowy."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "keczup"


/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "To właśnie sprawia, że papryczki chili są ostre."
	color = "#B31008" // rgb: 179, 16, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "ostre papryczki"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/M)
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent(/datum/reagent/cryostylane))
				holder.remove_reagent(/datum/reagent/cryostylane, 5)
			if(isslime(M))
				heating = rand(5,20)
		if(15 to 25)
			heating = 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(10,20)
		if(25 to 35)
			heating = 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(15,20)
		if(35 to INFINITY)
			heating = 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(20,25)
	M.adjust_bodytemperature(heating)
	..()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "Specjalny olej, który wyraźnie schładza ciało. Pozyskiwany z lodowych papryczek i szlamów."
	color = "#8BA6E9" // rgb: 139, 166, 233
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "mięta"

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/M)
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5)
			if(isslime(M))
				cooling = -rand(5,20)
		if(15 to 25)
			cooling = -20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				cooling = -rand(10,20)
		if(25 to 35)
			cooling = -30 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(15,20)
		if(35 to INFINITY)
			cooling = -40 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(5))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(20,25)
	M.adjust_bodytemperature(cooling, 50)
	..()

/datum/reagent/consumable/frostoil/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15,30))
	if(reac_volume >= 1) // Make Freezy Foam and anti-fire grenades!
		if(isopenturf(T))
			var/turf/open/OT = T
			OT.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=100, wet_time_to_add=reac_volume SECONDS) // Is less effective in high pressure/high heat capacity environments. More effective in low pressure.
			OT.air.set_temperature(OT.air.return_temperature() - MOLES_CELLSTANDARD*100*reac_volume/OT.air.heat_capacity()) // reduces environment temperature by 5K per unit.

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "Środek chemiczny używany do samoobrony i w pracy policji."
	color = "#B31008" // rgb: 179, 16, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "paląca agonia"

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!ishuman(M) && !ismonkey(M))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		//check for protection
		//actually handle the pepperspray effects
		if(!victim.is_eyes_covered() || !victim.is_mouth_covered())
			victim.blur_eyes(5) // 10 seconds
			victim.blind_eyes(3) // 6 seconds
			victim.Knockdown(3 SECONDS)
			if(prob(5))
				victim.emote("scream")
			victim.confused = max(M.confused, 5) // 10 seconds
			victim.add_movespeed_modifier(MOVESPEED_ID_PEPPER_SPRAY, update=TRUE, priority=100, multiplicative_slowdown=0.25, blacklisted_movetypes=(FLYING|FLOATING))
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), MOVESPEED_ID_PEPPER_SPRAY), 10 SECONDS)
		victim.update_damage_hud()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	description = "Sól z chlorku sodu. Powszechnie używana do przyprawiania jedzenia."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "sól"

/datum/reagent/consumable/sodiumchloride/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	if(M.has_bane(BANE_SALT))
		M.mind.disrupt_spells(-200)

/datum/reagent/consumable/sodiumchloride/reaction_turf(turf/T, reac_volume) //Creates an umbra-blocking salt pile
	if(!istype(T))
		return
	if(reac_volume < 1)
		return
	new/obj/effect/decal/cleanable/food/salt(T)

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "Proszek z mielonych ziaren pieprzu. *APSIK*"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	reagent_state = SOLID
	// no color (ie, black)
	taste_description = "pieprz"

/datum/reagent/consumable/cocoa
	name = "Cocoa Powder"
	description = "Tłusta, gorzka pasta z ziaren kakaowca."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "gorycz"

/datum/reagent/consumable/cocoa/on_mob_add(mob/living/carbon/M)
	.=..()
	if(iscatperson(M))
		to_chat(M, "<span class='warning'>Twoje wnętrzności buntują się przeciw śmiercionośnej czekoladzie!</span>")
		M.vomit(20)



/datum/reagent/consumable/cocoa/hot_cocoa
	name = "Hot Chocolate"
	description = "Zrobione z miłością! I ziaren kakaowca."
	reagent_state = LIQUID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "kremowa czekolada"
	glass_icon_state  = "chocolateglass"
	glass_name = "glass of chocolate"
	glass_desc = "Smaczne."

/datum/reagent/consumable/cocoa/hot_cocoa/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "Silny halucynogen pozyskiwany z niektórych gatunków grzybów."
	color = "#E700E7" // rgb: 231, 0, 231
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "grzyb"

/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/M)
	if(!M.slurring)
		M.slurring = 1
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(5)
			M.set_drugginess(30)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(10)
			M.Dizzy(10)
			M.set_drugginess(35)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(40)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/consumable/garlic //NOTE: having garlic in your blood stops vampires from biting you.
	name = "Garlic Juice"
	description = "Zgnieciony czosnek. Kucharze go uwielbiają, ale przez niego można brzydko pachnieć."
	color = "#FEFEFE"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "czosnek"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/M)
	if(isvampire(M)) //incapacitating but not lethal. Unfortunately, vampires cannot vomit.
		if(prob(min(25,current_cycle)))
			to_chat(M, "<span class='danger'>Nie możesz pozbyć się zapachu czosnku z nosa! Ledwo możesz myśleć...</span>")
			M.Paralyze(10)
			M.Jitter(10)
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job == JOB_NAME_COOK)
			if(prob(20)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
				H.heal_bodypart_damage(1,1, 0)
				. = 1
		else //NSV13 - chefs' robust space-Italian metabolism lets them eat garlic without producing allyl methyl sulfide
			H.adjust_hygiene(-0.15 * volume)
	..()

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Wielobarwne kawałeczki cukru, często spotykane na pączkach. Kochane przez gliniarzy."
	color = "#FF00FF" // rgb: 255, 0, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	taste_description = "dziecięca beztroska"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/carbon/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "Uniwersalny enzym używany do przygotowywania niektórych substancji i potraw."
	color = "#365E30" // rgb: 54, 94, 48
	chem_flags = NONE
	taste_description = "słodycz"

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Jedzenie ery kosmicznej, od 25 sierpnia 1958. Zawiera suszony makaron, warzywa i substancje, które gotują się w kontakcie z wodą."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "suchy i tani makaron"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "Makaron jest ugotowany, smaki są sztuczne, zupełnie jak za szkolnych czasów."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "mokry i tani makaron"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "Makaron jest ugotowany, smaki są sztuczne, zupełnie jak za szkolnych czasów."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "mokry i tani makaron w ogniu"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT)
	..()

/datum/reagent/consumable/flour
	name = "Flour"
	description = "Tym się smarujesz, żeby udawać ducha."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	chem_flags = NONE
	taste_description = "kredowa pszenica"

/datum/reagent/consumable/flour/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/food/flour/reagentdecal = new(T)
		reagentdecal = locate() in T //Might have merged with flour already there.
		if(reagentdecal)
			reagentdecal.reagents.add_reagent(/datum/reagent/consumable/flour, reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Absolutnie najlepsze. Do smarowania wyłącznie potraw o doskonałej symetrii bocznej."
	color = "#801E28" // rgb: 128, 30, 40
	chem_flags = NONE
	taste_description = "wiśnia"

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Niebieski i smaczniejszy rodzaj galaretki wiśniowej."
	color = "#00F0FF"
	chem_flags = NONE
	taste_description = "niebieska wiśnia"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "Małe, pożywne ziarenka. Szybki i sycący posiłek!"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	chem_flags = NONE
	taste_description = "ryż"

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "Tłusta, gorzka pasta z lasek wanilii."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	chem_flags = CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "wanilia"

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "Jest pełne białka."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFB500"
	chem_flags = NONE
	taste_description = "jajko"

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "Śliski roztwór."
	color = "#DBCE95"
	chem_flags = NONE
	taste_description = "szlam"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Rozkłada się na cukier."
	color = "#DBCE95"
	chem_flags = NONE
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "słodki szlam"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/M)
	holder.add_reagent(/datum/reagent/consumable/sugar, 3)
	..()
/datum/reagent/consumable/honey
	name = "Honey"
	description = "Słodki, słodki miód, który rozkłada się na cukier. Ma właściwości antybakteryjne i naturalnie leczące."
	color = "#d3a308"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	nutriment_factor = 15 * REAGENTS_METABOLISM
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "słodycz"
	var/power = 0

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/M)
	if(power == 0)
		M.reagents.add_reagent(/datum/reagent/consumable/sugar,3)
	if(prob(55))
		M.adjustBruteLoss(-1*REM+power, 0)
		M.adjustFireLoss(-1*REM+power, 0)
		M.adjustOxyLoss(-1*REM+power, 0)
		M.adjustToxLoss(-1*REM+power, 0)
	..()

/datum/reagent/consumable/honey/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		var/mob/living/carbon/C = M
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.speed_modifier = max(0.6, S.speed_modifier) // +60% surgery speed on each step, compared to bacchus' blessing's ~46%
	..()

/datum/reagent/consumable/honey/special
	name = "Royal Honey"
	description = "Specjalny miód, który leczy pijącego o wiele szybciej niż zwykły"
	power = 1

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "Biała, oleista mieszanka żółtek jaj."
	color = "#DFDFDF"
	chem_flags = NONE
	taste_description = "majonez"

/datum/reagent/consumable/mold // yeah, ok, togopal, I guess you could call that a condiment
	name = "Mold"
	description = "Ta przyprawa sprawi, że każde jedzenie wyjdzie poza schemat. Albo twój żołądek."
	color ="#708a88"
	taste_description = "zjełczały grzyb"
	chem_flags = NONE

/datum/reagent/consumable/eggrot
	name = "Rotten Eggyolk"
	description = "Pachnie absolutnie okropnie."
	color ="#708a88"
	taste_description = "zgniłe jaja"
	chem_flags = NONE

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "Oślepiająca substancja pozyskiwana z niektórych cebul."
	color = "#c0c9a0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "gorycz"

/datum/reagent/consumable/tearjuice/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	var/unprotected = FALSE
	switch(method)
		if(INGEST)
			unprotected = TRUE
		if(INJECT)
			unprotected = FALSE
		else	//Touch or vapor
			if(!M.is_mouth_covered() && !M.is_eyes_covered())
				unprotected = TRUE
	if(unprotected)
		if(!M.getorganslot(ORGAN_SLOT_EYES))	//can't blind somebody with no eyes
			to_chat(M, "<span class = 'notice'>Twoje oczodoły robią się mokre.</span>")
		else
			if(!M.eye_blurry)
				to_chat(M, "<span class = 'warning'>Łzy napływają ci do oczu!</span>")
			M.blind_eyes(2)
			M.blur_eyes(5)
	..()

/datum/reagent/consumable/tearjuice/on_mob_life(mob/living/carbon/M)
	..()
	if(M.eye_blurry)	//Don't worsen vision if it was otherwise fine
		M.blur_eyes(4)
		if(prob(10))
			to_chat(M, "<span class = 'warning'>Pieką cię oczy!</span>")
			M.blind_eyes(2)


/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "Biotechnologiczna struktura białkowo-odżywcza zaprojektowana tak, by rozkładać się przy wysokim nasyceniu. Mówiąc po ludzku, nie utyjesz od tego."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/M)
	if(M.nutrition > NUTRITION_LEVEL_FULL - 25)
		M.adjust_nutrition(-3*nutriment_factor)
	..()

/datum/reagent/consumable/maltodextrin
	name = "Maltodextrin"
	description = "Powszechny wypełniacz w żywności przetworzonej. Jedzenie z nim zapewnia uczucie sytości na znacznie krócej."
	color = "#ffffff"
	chem_flags = CHEMICAL_RNG_GENERAL
	taste_mult = 0.1 // Taste the salt and sugar not the cheap carbs
	taste_description = "przetworzona dobroć"
	nutriment_factor = 0
	metabolization_rate = 0.05 * REAGENTS_METABOLISM //Each unit will last 50 ticks

/datum/reagent/consumable/maltodextrin/on_mob_life(mob/living/carbon/M)
	M.adjust_nutrition(-0.3) //Each unit will match nutriment 1:1 when completely processed
	..()

////Lavaland Flora Reagents////


/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	description = "Wydzielina z pewnego grzyba. Sprawia, że jest kiepsko."
	color = "#1d043d"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "gorzki grzyb"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= 10)
		M.Unconscious(40, 0)
		. = 1
	if(prob(20))
		M.losebreath += 4
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM, 150)
		M.adjustToxLoss(3*REM,0)
		M.adjustStaminaLoss(10*REM,0)
		M.blur_eyes(5)
		. = TRUE
	..()


/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	description = "Pobudzająca wydzielina, przez którą na skórze wyrastają świecące grzyby. "
	color = "#b5a213"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "mrowiący grzyb"
	//Lazy list of mobs affected by the luminosity of this reagent.
	var/list/mobs_affected

/datum/reagent/consumable/tinlux/reaction_mob(mob/living/M)
	add_reagent_light(M)

/datum/reagent/consumable/tinlux/on_mob_end_metabolize(mob/living/M)
	remove_reagent_light(M)

/datum/reagent/consumable/tinlux/proc/on_living_holder_deletion(mob/living/source)

	remove_reagent_light(source)

/datum/reagent/consumable/tinlux/proc/add_reagent_light(mob/living/living_holder)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = living_holder.mob_light(2)
	LAZYSET(mobs_affected, living_holder, mob_light_obj)
	RegisterSignal(living_holder, COMSIG_PARENT_QDELETING, PROC_REF(on_living_holder_deletion))

/datum/reagent/consumable/tinlux/proc/remove_reagent_light(mob/living/living_holder)
	UnregisterSignal(living_holder, COMSIG_PARENT_QDELETING)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = LAZYACCESS(mobs_affected, living_holder)
	LAZYREMOVE(mobs_affected, living_holder)
	if(mob_light_obj)
		qdel(mob_light_obj)


/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	description = "Bąbelkująca pasta lecząca rany skóry."
	color = "#d3a308"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "owocowy grzyb"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/carbon/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		. = TRUE
	..()

/datum/reagent/consumable/clownstears
	name = "Clown's Tears"
	description = "Smutek i melancholia tysiąca pogrążonych w żałobie klaunów, którym na zawsze odmówiono Honkmechów."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#eef442" // rgb: 238, 244, 66
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "żałobne trąbienie"


/datum/reagent/consumable/liquidelectricity
	name = "Liquid Electricity"
	description = "Krew eteryków i to, co utrzymuje ich przy życiu. Świetna dla nich, okropna dla wszystkich innych."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#97ee63"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "czysta elektryczność"

/datum/reagent/consumable/liquidelectricity/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/stomach = M.getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(stomach))
			stomach.adjust_charge(40*REM)
	else if(prob(3)) //scp13 optimization
		M.electrocute_act(rand(3,5), "Liquid Electricity in their body", 1) //lmao at the newbs who eat energy bars
		playsound(M, "sparks", 50, 1)
	return ..()

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "Sztuczny słodzik ery kosmicznej."
	nutriment_factor = 0
	metabolization_rate = 2 * REAGENTS_METABOLISM
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_mult = 8
	taste_description = "słodycz"
	overdose_threshold = 17

/datum/reagent/consumable/astrotame/overdose_process(mob/living/carbon/M)
	if(M.disgust < 80)
		M.adjust_disgust(10)
	..()
	. = 1

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Kto by pomyślał, że podgrzany cukier jest taki pyszny?"
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#C65A00"
	chem_flags = NONE
	taste_mult = 2
	taste_description = "gorzka słodycz"
	reagent_state = SOLID

/datum/reagent/consumable/mesophilicculture
	name = "mesophilic culture"
	description = "Mieszanka bakterii mezofilnych używana do produkcji większości serów."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "gorycz"

/datum/reagent/consumable/thermophilicculture
	name = "thermophilic culture"
	description = "Mieszanka bakterii termofilnych używana do produkcji niektórych serów."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "gorycz"

/datum/reagent/consumable/penicilliumcandidum
	name = "penicillium candidum"
	description = "Specjalna bakteria używana do produkcji brie."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "gorycz"

/datum/reagent/consumable/penicilliumroqueforti
	name = "penicillium roqueforti"
	description = "Specjalna bakteria używana do produkcji sera pleśniowego."
	color = "#365E30" // rgb: 54, 94, 48
	taste_description = "gorycz"

/datum/reagent/consumable/parmesan_delight
	name = "Parmesan Delight"
	description = "Czas poświęcony na dojrzewanie parmezanu dał ten magiczny płyn."
	color = "#FFD700" // rgb: 255, 140, 255
	quality = DRINK_VERYGOOD
	taste_description = "słona dobroć"

/datum/reagent/consumable/parmesan_delight/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5, 0)
	M.adjustFireLoss(-0.5, 0)
	M.adjustToxLoss(-0.5, 0)
	M.adjustOxyLoss(-0.5, 0)
	M.heal_bodypart_damage(1,1, 0)
	..()

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Słodki, dymny, wytrawny i dostaje się wszędzie. Idealny do grillowania."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#78280A" // rgb: 120 40, 10
	chem_flags = NONE
	taste_mult = 2.5 //sugar's 1.5, capsacin's 1.5, so a good middle ground.
	taste_description = "dymna słodycz"

/datum/reagent/consumable/char
	name = "Char"
	description = "Esencja grilla. Przy przedawkowaniu ma dziwne właściwości."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#C8C8C8"
	chem_flags = NONE
	taste_mult = 6
	taste_description = "dym"
	overdose_threshold = 25

/datum/reagent/consumable/char/overdose_process(mob/living/carbon/M)
	if(prob(10))
		M.say(pick("Nienawidzę swojej żony.", "Chcę tylko grillować, na litość boską.", "Chciałbym po prostu wsiąść na kosiarkę i skosić trawę.", "No, Quake. To była dobra gra...", "Tak, moje PDA ma wi-fi. Wi-fe, której nienawidzę."), forced = /datum/reagent/consumable/char)
	..()
