

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/consumable/orangejuice
	name = "Orange Juice"
	description = "Pyszny I bogaty w witaminę C, czego chcieć więcej?"
	color = "#E78108" // rgb: 231, 129, 8
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "oranges"
	glass_icon_state = "glass_orange"
	glass_name = "glass of orange juice"
	glass_desc = "Witaminy! Hura!"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/orangejuice/on_mob_life(mob/living/carbon/M)
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1, 0)
		. = 1
	..()

/datum/reagent/consumable/tomatojuice
	name = "Tomato Juice"
	description = "Pomidory przerobione na sok. Co za marnotrawstwo dużych, soczystych pomidorów, co?"
	color = "#731008" // rgb: 115, 16, 8
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "tomatoes"
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Na pewno to sok pomidorowy?"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/tomatojuice/on_mob_life(mob/living/carbon/M)
	if(M.getFireLoss() && prob(20))
		M.heal_bodypart_damage(0,1, 0)
		. = 1
	..()

/datum/reagent/consumable/limejuice
	name = "Lime Juice"
	description = "Słodko-kwaśny sok z limonek."
	color = "#365E30" // rgb: 54, 94, 48
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "nieznośna kwaśność"
	glass_icon_state = "glass_green"
	glass_name = "glass of lime juice"
	glass_desc = "Szklanka słodko-kwaśnego soku z limonki."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/limejuice/on_mob_life(mob/living/carbon/M)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1*REM, 0)
		. = 1
	..()

/datum/reagent/consumable/carrotjuice
	name = "Carrot Juice"
	description = "Jak marchewka, tylko bez chrupania."
	color = "#973800" // rgb: 151, 56, 0
	chem_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "carrots"
	glass_icon_state = "carrotjuice"
	glass_name = "glass of  carrot juice"
	glass_desc = "To jak marchewka, tylko bez chrupania."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/carrotjuice/on_mob_life(mob/living/carbon/M)
	M.adjust_blurriness(-1)
	M.adjust_blindness(-1)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				M.cure_nearsighted(list(EYE_DAMAGE))
	..()
	return

/datum/reagent/consumable/berryjuice
	name = "Berry Juice"
	description = "Pyszna mieszanka kilku rodzajów jagód."
	color = "#863333" // rgb: 134, 51, 51
	chem_flags = NONE
	taste_description = "berries"
	glass_icon_state = "berryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Sok z jagód. A może to dżem. Kogo to obchodzi?"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/applejuice
	name = "Apple Juice"
	description = "Słodki sok z jabłka, dla każdego, w każdym wieku."
	color = "#ECFF56" // rgb: 236, 255, 86
	chem_flags = NONE
	taste_description = "apples"
	glass_icon_state = "glass_orange"
	glass_name = "glass of apple juice"
	glass_desc = "Sok jabłkowy. A może to cydr. Kogo to obchodzi?"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/poisonberryjuice
	name = "Poison Berry Juice"
	description = "Smaczny sok z różnych bardzo śmiercionośnych i trujących jagód."
	color = "#863353" // rgb: 134, 51, 83
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "berries"
	glass_icon_state = "poisonberryjuice"
	glass_name = "glass of berry juice"
	glass_desc = "Sok z jagód. A może to trucizna. Kogo to obchodzi?"
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/poisonberryjuice/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	. = 1
	..()

/datum/reagent/consumable/watermelonjuice
	name = "Watermelon Juice"
	description = "Pyszny sok z arbuza."
	color = "#863333" // rgb: 134, 51, 51
	chem_flags = NONE
	taste_description = "soczysty arbuz"
	glass_icon_state = "glass_red"
	glass_name = "glass of watermelon juice"
	glass_desc = "Szklanka soku z arbuza."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/lemonjuice
	name = "Lemon Juice"
	description = "Ten sok jest BARDZO kwaśny."
	color = "#863333" // rgb: 175, 175, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "sourness"
	glass_icon_state  = "lemonglass"
	glass_name = "glass of lemon juice"
	glass_desc = "Kwaśne..."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/banana
	name = "Banana Juice"
	description = "Surowa esencja banana. HONK"
	color = "#863333" // rgb: 175, 175, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "banana"
	glass_icon_state = "banana"
	glass_name = "glass of banana juice"
	glass_desc = "Surowa esencja banana. HONK."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/banana/on_mob_life(mob/living/carbon/M)
	if((ishuman(M) && M.job == JOB_NAME_CLOWN) || ismonkey(M))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/nothing
	name = "Nothing"
	description = "Absolutnie nic."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "nothing"
	glass_icon_state = "nothing"
	glass_name = "nothing"
	glass_desc = "Absolutnie nic."
	shot_glass_icon_state = "shotglass"
	hydration_factor = 0 * REAGENTS_METABOLISM


/datum/reagent/consumable/nothing/on_mob_life(mob/living/carbon/M)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.silent = max(M.silent, MIMEDRINK_SILENCE_DURATION)
		M.heal_bodypart_damage(1,1, 0)
		M.adjust_hydration(15 * REAGENTS_METABOLISM) // AQ EDIT
		. = 1
	..()

/datum/reagent/consumable/laughter
	name = "Laughter"
	description = "Niektórzy mówią, że to najlepsze lekarstwo, ale najnowsze badania dowiodły, że to nieprawda."
	metabolization_rate = INFINITY
	color = "#FF4DD2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "laughter"


/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/M)
	M.emote("laugh")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_laughter)
	..()

/datum/reagent/consumable/laughter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	var/mob/living/carbon/human/reactor = M
	if(istype(reactor))
		var/datum/component/mood/mood = reactor.GetComponent(/datum/component/mood)
		if (mood.get_event("slipped"))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "laughter", /datum/mood_event/funny_prank)
			SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "slipped")
			reactor.AdjustKnockdown(-20)

/datum/reagent/consumable/superlaughter
	name = "Super Laughter"
	description = "Zabawne, dopóki to nie ty się śmiejesz."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#FF4DD2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "laughter"

/datum/reagent/consumable/superlaughter/on_mob_life(mob/living/carbon/M)
	if(prob(30))
		M.visible_message("<span class='danger'>[M] wybucha niekontrolowanym śmiechem!</span>", "<span class='userdanger'>Wybuchasz niekontrolowanym śmiechem!</span>")
		M.Stun(5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "chemical_laughter", /datum/mood_event/chemical_superlaughter)
	..()

/datum/reagent/consumable/potato_juice
	name = "Potato Juice"
	description = "Sok z ziemniaka. Bleh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "irlandzki smutek"
	glass_icon_state = "glass_brown"
	glass_name = "glass of potato juice"
	glass_desc = "Bleh..."
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/grapejuice
	name = "Grape Juice"
	description = "Sok z kiści winogron. Gwarantowanie bezalkoholowy."
	color = "#290029" // dark purple
	chem_flags = NONE
	taste_description = "napój winogronowy"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/milk
	name = "Milk"
	description = "Nieprzezroczysty biały płyn wytwarzany przez gruczoły mleczne ssaków."
	color = "#DFDFDF" // rgb: 223, 223, 223
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "milk"
	glass_icon_state = "glass_white"
	glass_name = "glass of milk"
	glass_desc = "Biała i pożywna dobroć!"
	overdose_threshold = 500 //High calcium intake is bad for bone health. OD is exactly like having taken a normal-ish bone hurt juice. If anyone hits the superoverdose, well I'll be damned
	hydration_factor = 15 * REAGENTS_METABOLISM

/datum/reagent/consumable/milk/goat
	name = "Goat Milk"
	description = "Nieprzezroczysty biały płyn wytwarzany przez gruczoły mleczne kóz."
	taste_description = "goat"
	glass_name = "glass of goat milk"

/datum/reagent/consumable/milk/sheep
	name = "Sheep Milk"
	description = "Nieprzezroczysty biały płyn wytwarzany przez gruczoły mleczne owiec."
	taste_description = "sheep"
	glass_name = "glass of sheep milk"

/datum/reagent/consumable/milk/blue
	name = "Blue Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/brie
	name = "Brie Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/cheddar
	name = "Cheddar Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/feta
	name = "Feta Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/goatcheese
	name = "Goat Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/shoat
	name = "Shoat Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "owca i koza"
	glass_name = "glass of shoat milk"

/datum/reagent/consumable/milk/halloumi
	name = "Halloumi Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/mozzarella
	name = "Mozzarella Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/parmesan
	name = "Parmesan Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/swiss
	name = "Swiss Cheese Milk"
	description = "Nieprzezroczysty biały płyn."
	taste_description = "bitter"
	glass_name = "glass of cheese milk"

/datum/reagent/consumable/milk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
		holder.remove_reagent(/datum/reagent/consumable/capsaicin, 2)
	..()

/*See block comment in ../milk/overdose_process(mob/living/M) for calculation and explanation of why this exists and why 5 was chosen
* For best results use in tandem with method outlined in this comment
*/
/datum/reagent/consumable/milk/overdose_start(mob/living/M)
	M.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, 5) //The integer here should match var/starting_amount in ../milk/overdose_process(mob/living/M)
	return ..()

/datum/reagent/consumable/milk/overdose_process(mob/living/M)
	var/datum/reagent/converted_reagent = /datum/reagent/toxin/bonehurtingjuice //Needed to get the metabolism for desired reagent, exists solely for brevity compared to /datum/reagent/category/reagent.metabolization_rate
	var/minimum_cycles = overdose_threshold/metabolization_rate //minimum_cycles is the number of ticks for an amount of units equal to the overdose threshold to process.
	var/amount_to_add = 45 / minimum_cycles + initial(converted_reagent.metabolization_rate) //amount_to_add is the calculated amount to add per tick to meet ensure that target_units after minimum_cycle ticks.
	M.reagents.add_reagent(/datum/reagent/toxin/bonehurtingjuice, amount_to_add)
	return ..()
	/*In depth explanation by DatBoiTim
	* This number will not put more than 50u of BHJ into their system if only 500u(ie bare minimum OD).
	*  milk.overdose_threshold / milk.metabolization_rate = minimum_cycles = 1,250 cycles
	* (target_units / total_cycles) + BHJ.metabolization_rate = amount_to_add = .44
	* However, regular livers process 1u per tick of any toxin if it is under 3u. This does not account for others, since most others are likely upgrades, and having a workaround for those upgrades defeats their purpose.
	* Meaning we need a starting amount to offset this which is more than three. Ideally this should yield the lowest amount of decimal spaces to save space, while being as low as possible.
	* In this case starting_amount = 5.
	* ( (target_units - starting_amount) / minimum_cycles) + BHJ.metabolization_rate = amount_to_add = .436
	* Copy pasting the above and changing /datum/reagent/toxin/bonehurtingjuice as well as the documentation to be accurate for another type path will work so long as the reagent using this has an OD threshold.
	* You can just change the target units and should double check that the starting amount meets outlined criteria.
	*/

/datum/reagent/consumable/soymilk
	name = "Soy Milk"
	description = "Nieprzezroczysty biały płyn z soi."
	color = "#DFDFC7" // rgb: 223, 223, 199
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "mleko sojowe"
	glass_icon_state = "glass_white"
	glass_name = "glass of soy milk"
	glass_desc = "Biała i pożywna sojowa dobroć!"
	hydration_factor = 12 * REAGENTS_METABOLISM


/datum/reagent/consumable/soymilk/on_mob_add(mob/living/L)
	..()

	if (L.client)
		L.client.give_award(/datum/award/achievement/misc/soy, L)


/datum/reagent/consumable/soymilk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/cream
	name = "Cream"
	description = "Tłusta, wciąż płynna część mleka. Może zmieszasz to z odrobiną szkockiej, co?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "kremowe mleko"
	glass_icon_state  = "glass_white"
	glass_name = "glass of cream"
	glass_desc = "Fuuuj..."
	hydration_factor = 9 * REAGENTS_METABOLISM

/datum/reagent/consumable/cream/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
		. = 1
	..()

/datum/reagent/consumable/coffee
	name = "Coffee"
	description = "Kawa to napój parzony z palonych nasion, zwanych ziarnami kawy, krzewu kawowca."
	color = "#482000" // rgb: 72, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	overdose_threshold = 80
	taste_description = "bitterness"
	glass_icon_state = "glass_brown"
	glass_name = "glass of coffee"
	glass_desc = "Nie upuść jej, bo wszędzie rozpryśnie się wrzący płyn i odłamki szkła."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/coffee/overdose_process(mob/living/M)
	M.Jitter(5)
	..()

/datum/reagent/consumable/coffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = 1

/datum/reagent/consumable/tea
	name = "Tea"
	description = "Smaczna czarna herbata, ma przeciwutleniacze, jest zdrowa!"
	color = "#101000" // rgb: 16, 16, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "cierpka czarna herbata"
	glass_icon_state = "teaglass"
	glass_name = "glass of tea"
	glass_desc = "Picie stąd nie wydawałoby się właściwe."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/tea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.AdjustSleeping(-20, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/lemonade
	name = "Lemonade"
	description = "Słodka, orzeźwiająca lemoniada. Dobra dla duszy."
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "słońce i lato"
	glass_icon_state = "lemonpitcher"
	glass_name = "pitcher of lemonade"
	glass_desc = "Z jakiegoś powodu ten napój budzi nostalgię."
	hydration_factor = 12 * REAGENTS_METABOLISM


/datum/reagent/consumable/tea/arnold_palmer
	name = "Arnold Palmer"
	description = "Zachęca pacjenta do gry w golfa."
	color = "#FFB766"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 2
	taste_description = "gorzka herbata"
	glass_icon_state = "arnold_palmer"
	glass_name = "Arnold Palmer"
	glass_desc = "Po kilku łykach masz ochotę na kilka zamachów kijem golfowym."

/datum/reagent/consumable/tea/arnold_palmer/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		to_chat(M, "<span class = 'notice'>[pick("You remember to square your shoulders.","You remember to keep your head down.","You can't decide between squaring your shoulders and keeping your head down.","You remember to relax.","You think about how someday you'll get two strokes off your golf game.")]</span>")
	..()
	. = 1

/datum/reagent/consumable/icecoffee
	name = "Iced Coffee"
	description = "Kawa i lód, orzeźwiające i chłodne."
	color = "#102838" // rgb: 16, 40, 56
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 0
	taste_description = "gorzki chłód"
	glass_icon_state = "icedcoffeeglass"
	glass_name = "iced coffee"
	glass_desc = "Napój, który cię ożywi i odświeży!"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/icecoffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/icetea
	name = "Iced Tea"
	description = "Nie ma związku z pewnym raperem/aktorem."
	color = "#104038" // rgb: 16, 64, 56
	chem_flags = CHEMICAL_BASIC_DRINK
	nutriment_factor = 0
	taste_description = "słodka herbata"
	glass_icon_state = "icedteaglass"
	glass_name = "iced tea"
	glass_desc = "Całkowicie naturalne, bogate w przeciwutleniacze doznanie smakowe."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/icetea/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.AdjustSleeping(-40, FALSE)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1, 0)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/space_cola
	name = "Cola"
	description = "Orzeźwiający napój."
	color = "#100800" // rgb: 16, 8, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cola"
	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola"
	glass_desc = "Szklanka orzeźwiającej Space Coli."
	hydration_factor = 7 * REAGENTS_METABOLISM

/datum/reagent/consumable/space_cola/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-5)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/nuka_cola
	name = "Nuka Cola"
	description = "Cola, cola nigdy się nie zmienia."
	color = "#100800" // rgb: 16, 8, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "przyszłość"
	glass_icon_state = "nuka_colaglass"
	glass_name = "glass of Nuka Cola"
	glass_desc = "Nie płacz, nie unoś oczu, to tylko jądrowe pustkowie."
	hydration_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/consumable/nuka_cola/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/consumable/nuka_cola/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.set_drugginess(30)
	M.dizziness += 1.5
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.radiation += 4
	..()
	. = 1

/datum/reagent/consumable/grey_bull
	name = "Grey Bull"
	description = "Grey Bull doda ci rękawic!"
	color = "#EEFF00" // rgb: 238, 255, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "gazowany olej"
	glass_icon_state = "grey_bull_glass"
	glass_name = "glass of Grey Bull"
	glass_desc = "O dziwo, nie jest szary."
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/grey_bull/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/grey_bull/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_SHOCKIMMUNE, type)
	..()

/datum/reagent/consumable/grey_bull/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/spacemountainwind
	name = "SM Wind"
	description = "Przewiewa cię na wylot jak kosmiczny wiatr."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "słodki napój cytrusowy"
	glass_icon_state = "Space_mountain_wind_glass"
	glass_name = "glass of Space Mountain Wind"
	glass_desc = "Space Mountain Wind. Jak wiadomo, w kosmosie nie ma gór, jest tylko wiatr."
	hydration_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/consumable/spacemountainwind/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-7)
	M.AdjustSleeping(-20, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/dr_gibb
	name = "Dr. Gibb"
	description = "Pyszna mieszanka 42 różnych smaków."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "napój wiśniowy" // FALSE ADVERTISING
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of Dr. Gibb"
	glass_desc = "Dr. Gibb. Nie tak niebezpieczny, jak mogłaby sugerować nazwa szklanki."
	hydration_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/consumable/dr_gibb/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-6)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/space_up
	name = "Space-Up"
	description = "Smakuje jak wyłom w kadłubie w ustach."
	color = "#00FF00" // rgb: 0, 255, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "napój wiśniowy"
	glass_icon_state = "space-up_glass"
	glass_name = "glass of Space-Up"
	glass_desc = "Space-Up. Pomaga zachować spokój."
	hydration_factor = 6 * REAGENTS_METABOLISM


/datum/reagent/consumable/space_up/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/lemon_lime
	name = "Lemon Lime"
	description = "Wyrazista substancja z 0,5% naturalnych cytrusów!"
	color = "#8CFF00" // rgb: 135, 255, 0
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "wyrazisty napój cytrynowo-limonkowy"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of lemon-lime"
	glass_desc = "Jesteś prawie pewien, że prawdziwy owoc nigdy tego nie dotknął."
	hydration_factor = 5 * REAGENTS_METABOLISM


/datum/reagent/consumable/lemon_lime/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/pwr_game
	name = "Pwr Game"
	description = "Jedyny napój z MOCĄ, której pragną prawdziwi gracze."
	color = "#9385bf" // rgb: 58, 52, 75
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "słodko-słony smak"
	glass_icon_state = "glass_red"
	glass_name = "glass of Pwr Game"
	glass_desc = "Pasuje do sałatki Vlada."
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/pwr_game/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/shamblers
	name = "Shambler's Juice"
	description = "~Wstrząśnij mi trochę tego soku Shamblera!~"
	color = "#f00060" // rgb: 94, 0, 38
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "gazowany metaliczny napój"
	glass_icon_state = "glass_red"
	glass_name = "glass of Shambler's juice"
	glass_desc = "Mmm mm, szamblowate."
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/shamblers/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
/datum/reagent/consumable/sodawater
	name = "Soda Water"
	description = "Puszka wody sodowej. Może zrobić szkocką z wodą?"
	color = "#619494" // rgb: 97, 148, 148
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "woda gazowana"
	glass_icon_state = "glass_clear"
	glass_name = "glass of soda water"
	glass_desc = "Woda sodowa. Może zrobić szkocką z wodą?"
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/sodawater/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/tonic
	name = "Tonic Water"
	description = "Smakuje dziwnie, ale przynajmniej chinina trzyma z daleka kosmiczną malarię."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "cierpki i świeży"
	glass_icon_state = "glass_clear"
	glass_name = "glass of tonic water"
	glass_desc = "Chinina dziwnie smakuje, ale przynajmniej trzyma z daleka kosmiczną malarię."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/tonic/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = 1

/datum/reagent/consumable/monkey_energy
	name = "Monkey Energy"
	description = "Jedyny napój, który uwolni w tobie małpę."
	color = "#f39b03" // rgb: 243, 155, 3
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "grill i nostalgia"
	glass_icon_state = "monkey_energy_glass"
	glass_name = "glass of Monkey Energy"
	glass_desc = "Możesz uwolnić małpę, ale bez syknięcia puszki?"
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/monkey_energy/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness +=1
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/monkey_energy/on_mob_metabolize(mob/living/L)
	..()
	if(ismonkey(L))
		L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.25, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/consumable/monkey_energy/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/consumable/ice
	name = "Ice"
	description = "Zamarznięta woda, dentysta nie byłby zadowolony, że to gryziesz."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "ice"
	glass_icon_state = "iceglass"
	glass_name = "glass of ice"
	glass_desc = "Zasadniczo powinieneś tam włożyć jeszcze coś..."
	hydration_factor = 14 * REAGENTS_METABOLISM

/datum/reagent/consumable/ice/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/soy_latte
	name = "Soy Latte"
	description = "Miły i smaczny napój do czytania hipisowskich książek."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "kremowa kawa"
	glass_icon_state = "soy_latte"
	glass_name = "soy latte"
	glass_desc = "Miły i orzeźwiający napój do czytania."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/soy_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/cafe_latte
	name = "Cafe Latte"
	description = "Miły, mocny i smaczny napój do czytania."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "gorzka śmietanka"
	glass_icon_state = "cafe_latte"
	glass_name = "cafe latte"
	glass_desc = "Miły, mocny i orzeźwiający napój do czytania."
	hydration_factor = 12 * REAGENTS_METABOLISM

/datum/reagent/consumable/cafe_latte/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.SetSleeping(0, FALSE)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	..()
	. = 1

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	description = "Łyk dziennie trzyma medibota z daleka! Mieszanka soków, która dość szybko leczy większość rodzajów obrażeń kosztem głodu."
	color = "#FF8CFF" // rgb: 255, 140, 255
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	taste_description = "swojskie owoce"
	glass_icon_state = "doctorsdelightglass"
	glass_name = "Doctor's Delight"
	glass_desc = "Ulubieniec kosmicznych lekarzy. Gwarantowanie leczy urazy ciała; skutki uboczne to zachcianki i głód."
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/doctor_delight/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.5, 0)
	M.adjustFireLoss(-0.5, 0)
	M.adjustToxLoss(-0.5, 0)
	M.adjustOxyLoss(-0.5, 0)
	if(M.nutrition && (M.nutrition - 2 > 0))
		if(M.mind && !HAS_TRAIT(M.mind, TRAIT_MEDICAL_METABOLISM)) //Drains the nutrition of the holder. Not medical staff though, since it's the Doctor's Delight!
			M.adjust_nutrition(-2)
	..()
	. = 1

/datum/reagent/consumable/chocolatepudding
	name = "Chocolate Pudding"
	description = "Świetny deser dla miłośników czekolady."
	color = "#800000"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "słodka czekolada"
	glass_icon_state = "chocolatepudding"
	glass_name = "chocolate pudding"
	glass_desc = "Smaczne."

/datum/reagent/consumable/vanillapudding
	name = "Vanilla Pudding"
	description = "Świetny deser dla miłośników wanilii."
	color = "#FAFAD2"
	quality = DRINK_VERYGOOD
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "słodka wanilia"
	glass_icon_state = "vanillapudding"
	glass_name = "vanilla pudding"
	glass_desc = "Smaczne."

/datum/reagent/consumable/cherryshake
	name = "Cherry Shake"
	description = "Wiśniowy koktajl mleczny."
	color = "#FFB6C1"
	quality = DRINK_VERYGOOD
	chem_flags = CHEMICAL_RNG_BOTANY
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "kremowa wiśnia"
	glass_icon_state = "cherryshake"
	glass_name = "cherry shake"
	glass_desc = "Wiśniowy koktajl mleczny."
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/bluecherryshake
	name = "Blue Cherry Shake"
	description = "Egzotyczny koktajl mleczny."
	color = "#00F1FF"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 4 * REAGENTS_METABOLISM
	taste_description = "kremowa niebieska wiśnia"
	glass_icon_state = "bluecherryshake"
	glass_name = "blue cherry shake"
	glass_desc = "Egzotyczny niebieski koktajl mleczny."
	hydration_factor = 6 * REAGENTS_METABOLISM

/datum/reagent/consumable/pumpkin_latte
	name = "Pumpkin Latte"
	description = "Mieszanka soku z dyni i kawy."
	color = "#F4A460"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_VERYGOOD
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "kremowa dynia"
	glass_icon_state = "pumpkin_latte"
	glass_name = "pumpkin latte"
	glass_desc = "Mieszanka kawy i soku z dyni."
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/gibbfloats
	name = "Gibb Floats"
	description = "Lody na szklance Dr. Gibba."
	color = "#B22222"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "kremowa wiśnia"
	glass_icon_state = "gibbfloats"
	glass_name = "Gibbfloat"
	glass_desc = "Dr. Gibb z lodami na wierzchu."
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/pumpkinjuice
	name = "Pumpkin Juice"
	description = "Wyciskany z prawdziwej dyni."
	color = "#FFA500"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "pumpkin"
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/blumpkinjuice
	name = "Blumpkin Juice"
	description = "Wyciskany z prawdziwego blumpkina."
	color = "#00BFFF"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "haust wody z basenu"
	hydration_factor = 8 * REAGENTS_METABOLISM

/datum/reagent/consumable/triple_citrus
	name = "Triple Citrus"
	description = "A solution."
	color = "#EEFF00"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "skrajna gorycz"
	glass_icon_state = "triplecitrus" //needs own sprite mine are trash
	glass_name = "glass of triple citrus"
	glass_desc = "Mieszanka soków cytrusowych. Wyrazista, a jednak gładka."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/grape_soda
	name = "Grape soda"
	description = "Ukochany przez dzieci i abstynentów."
	color = "#E6CDFF"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "napój winogronowy"
	glass_name = "glass of grape juice"
	glass_desc = "To napój winogronowy!"
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/grape_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/milk/chocolate_milk
	name = "Chocolate Milk"
	description = "Mleko dla fajnych dzieciaków."
	color = "#7D4E29"
	chem_flags = CHEMICAL_RNG_BOTANY
	quality = DRINK_NICE
	taste_description = "mleko czekoladowe"
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/menthol
	name = "Menthol"
	description = "Łagodzi objawy kaszlu."
	color = "#80AF9C"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "mint"
	glass_icon_state = "glass_green"
	glass_name = "glass of menthol"
	glass_desc = "Ma naturalnie miętowy smak i daje bardzo lekkie uczucie odrętwienia."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/menthol/on_mob_life(mob/living/L)
	L.apply_status_effect(/datum/status_effect/throat_soothed)
	..()

/datum/reagent/consumable/grenadine
	name = "Grenadine"
	description = "Nie o smaku wiśni!"
	color = "#EA1D26"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "słodkie granaty"
	glass_name = "glass of grenadine"
	glass_desc = "Pyszny syrop smakowy."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/parsnipjuice
	name = "Parsnip Juice"
	description = "Czemu..."
	color = "#FFA500"
	chem_flags = NONE
	taste_description = "parsnip"
	glass_name = "glass of parsnip juice"
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/peachjuice //Intended to be extremely rare due to being the limiting ingredients in the blazaam drink
	name = "Peach Juice"
	description = "Po prostu brzoskwiniowo."
	color = "#E78108"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "peaches"
	glass_name = "glass of peach juice"
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/pineapplejuice
	name = "Pineapple Juice"
	description = "Cierpki, tropikalny i budzący gorące spory."
	color = "#F7D435"
	chem_flags = CHEMICAL_BASIC_DRINK
	taste_description = "pineapple"
	glass_name = "glass of pineapple juice"
	glass_desc = "Cierpki, tropikalny i budzący gorące spory."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/cream_soda
	name = "Cream Soda"
	description = "Klasyczny kosmiczno-amerykański napój o smaku wanilii."
	color = "#dcb137"
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_VERYGOOD
	taste_description = "musująca wanilia"
	glass_icon_state = "cream_soda"
	glass_name = "Cream Soda"
	glass_desc = "Klasyczny kosmiczno-amerykański napój o smaku wanilii."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/cream_soda/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/red_queen
	name = "Red Queen"
	description = "WYPIJ MNIE."
	color = "#e6ddc3"
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_GOOD
	taste_description = "wonder"
	glass_icon_state = "red_queen"
	glass_name = "Red Queen"
	glass_desc = "WYPIJ MNIE."
	hydration_factor = 10 * REAGENTS_METABOLISM

	var/current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/consumable/red_queen/on_mob_life(mob/living/carbon/H)
	if(prob(75))
		return ..()
	var/newsize = pick(0.5, 0.75, 1, 1.50, 2)
	newsize *= RESIZE_DEFAULT_SIZE
	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	if(prob(40))
		H.emote("sneeze")
	..()

/datum/reagent/consumable/red_queen/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

/datum/reagent/consumable/bungojuice
	name = "Bungo Juice"
	color = "#F9E43D"
	chem_flags = CHEMICAL_GOAL_BARTENDER_SERVING
	description = "Egzotyczne! Czujesz się, jakbyś już był na wakacjach."
	taste_description = "soczyste bungo"
	glass_icon_state = "glass_yellow"
	glass_name = "glass of bungo juice"
	glass_desc = "Egzotyczne! Czujesz się, jakbyś już był na wakacjach."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/beefbroth
	name = "Beef Broth"
	color = "#100800" // rgb: 16, 8, 0 , just like cola
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "Pure Beef Essence"
	glass_icon_state  = "glass_brown"
	glass_name = "glass of Space Cola?"
	glass_desc = "Szklanka czegoś, co wygląda na orzeźwiającą Space Colę."
	hydration_factor = 10 * REAGENTS_METABOLISM

/datum/reagent/consumable/beefbroth/on_mob_metabolize(mob/living/M)
	to_chat(M, "<span class='warning'>Ten drink był zdecydowanie za wołowy! Robi ci się niedobrze.</span>")
	M.adjust_disgust(30)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
	. = ..()
