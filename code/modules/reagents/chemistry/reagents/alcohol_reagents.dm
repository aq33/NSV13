#define ALCOHOL_THRESHOLD_MODIFIER 1 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_RATE 0.005 //The rate at which alcohol affects you
#define ALCOHOL_EXPONENT 1.6 //The exponent applied to boozepwr to make higher volume alcohol at least a little bit damaging to the liver

////////////// I don't know who made this header before I refactored alcohols but I'm going to fucking strangle them because it was so ugly, holy Christ
// ALCOHOLS //
//////////////

/datum/reagent/consumable/ethanol
	name = "Ethanol"
	description = "Powszechnie znany alkohol o wielu zastosowaniach."
	color = "#404030" // rgb: 64, 64, 48
	nutriment_factor = 0
	taste_description = "alcohol"
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	hydration_factor = 8 * REAGENTS_METABOLISM // AQ EDIT
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning

/*
Boozepwr Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occassional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - heavy toxin damage, passing out
91-100: Dangerously toxic - swift death
*/

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/carbon/C)
	if(C.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
		var/booze_power = boozepwr
		if(HAS_TRAIT(C, TRAIT_ALCOHOL_TOLERANCE)) //we're an accomplished drinker
			booze_power *= 0.7
		if(HAS_TRAIT(C, TRAIT_LIGHT_DRINKER))
			if(booze_power < 0)
				booze_power *= -1
			else
				booze_power *= 2
		C.drunkenness = max((C.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk
		if(C.drunkenness >= 250)
			C.client?.give_award(/datum/award/achievement/misc/drunk, C)
		var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
		if (istype(L))
			L.applyOrganDamage(((max(sqrt(volume) * (boozepwr ** ALCOHOL_EXPONENT) * L.alcohol_tolerance, 0))/150))
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clear_paper()
		to_chat(usr, "<span class='notice'>Atrament na [paperaffected] się zmywa.</span>")
	if(istype(O, /obj/item/book))
		if(reac_volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			O.visible_message("<span class='notice'>[name] zmywa pismo z [O]!</span>")
		else
			O.visible_message("<span class='warning'>[name] rozmazuje atrament na [O], ale go nie zmywa!</span>")
	return

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!isliving(M))
		return

	if(method in list(TOUCH, VAPOR, PATCH))
		M.adjust_fire_stacks(reac_volume / 15)

		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/power_multiplier = boozepwr / 65 // Weak alcohol has less sterilizing power

			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.speed_modifier = max(0.1*power_multiplier, S.speed_modifier)
				// +10% surgery speed on each step, useful while operating in less-than-perfect conditions
	return ..()

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	description = "Napój alkoholowy warzony od starożytności na Starej Ziemi. Wciąż popularny."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "siki"
	glass_name = "glass of beer"
	glass_desc = "Lodowato zimny kufel piwa."

/datum/reagent/consumable/ethanol/ftliver
	name = "Faster-Than-Liver"
	description = "Napój zrodzony wśród gwiazd; mówią, że picie go w nadmiarze przypomina tranzyt FTL."
	color = "#0D0D0D" // rgb: 13, 13, 13
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 52
	taste_description = "pusta przestrzeń"
	glass_icon_state = "ftliver"
	glass_name = "glass of Faster-Than-Liver"
	glass_desc = "Mój Boże, jest pełny gwiazd!"
	var/HasTraveled = 0

/datum/reagent/consumable/ethanol/ftliver/on_mob_life(mob/living/carbon/M)
	if(!HasTraveled && prob(volume))
		HasTraveled = 1
		M.AdjustKnockdown(15)
		M.become_nearsighted("ftliver")
		shake_camera(M,15)
		M.playsound_local(M.loc,"sound/effects/hyperspace_end.ogg",50)
		addtimer(CALLBACK(src, PROC_REF(Recover), M), 55)
	return ..()

/datum/reagent/consumable/ethanol/ftliver/proc/Recover(mob/living/M)
	M.cure_nearsighted("ftliver")

/datum/reagent/consumable/ethanol/beer/light
	name = "Light Beer"
	description = "Napój alkoholowy warzony od starożytności na Starej Ziemi. Ta odmiana ma mniej kalorii i alkoholu."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 5 //Space Europeans hate it
	taste_description = "pomyje"
	glass_name = "glass of light beer"
	glass_desc = "Lodowato zimny kufel wodnistego jasnego piwa."

/datum/reagent/consumable/ethanol/beer/green
	name = "Green Beer"
	description = "Napój alkoholowy warzony od starożytności na Starej Ziemi. Ta odmiana jest świątecznie zabarwiona na zielono."
	color = "#A8E61D"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "zielone siki"
	glass_icon_state = "greenbeerglass"
	glass_name = "glass of green beer"
	glass_desc = "Lodowato zimny kufel zielonego piwa. Świątecznie."

/datum/reagent/consumable/ethanol/beer/green/on_mob_life(mob/living/carbon/M)
	if(M.color != color)
		M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)
	return ..()

/datum/reagent/consumable/ethanol/beer/green/on_mob_end_metabolize(mob/living/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	description = "Powszechnie znany meksykański likier kawowy. Produkowany od 1936 roku!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	glass_icon_state = "kahluaglass"
	glass_name = "glass of RR coffee liquor"
	glass_desc = "KURCZĘ, TO WYGLĄDA ROBUSTOWO!"
	shot_glass_icon_state = "shotglasscream"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Jitter(5)
	..()
	. = 1

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	description = "Wyborna, dobrze leżakowana whisky single malt. Kurczę."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 75
	taste_description = "molasses"
	glass_icon_state = "whiskeyglass"
	glass_name = "glass of whiskey"
	glass_desc = "Jedwabista, dymna whisky w szklance sprawia, że drink wygląda bardzo elegancko."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	description = "Silna mieszanka kofeiny i alkoholu."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 80
	quality = DRINK_GOOD
	overdose_threshold = 60
	addiction_threshold = 30
	taste_description = "drgawki i śmierć"
	glass_icon_state = "thirteen_loko_glass"
	glass_name = "glass of Thirteen Loko"
	glass_desc = "To szklanka Thirteen Loko, wygląda na najwyższej jakości. Drink, nie szklanka."

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(0,M.drowsyness-7)
	M.AdjustSleeping(-40)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/thirteenloko/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>Całym twoim ciałem gwałtownie wstrząsają drgawki i zaczyna ci się robić niedobrze. Naprawdę nie powinieneś był wypijać całego [name]!</span>")
	M.Jitter(20)
	M.Stun(15)

/datum/reagent/consumable/ethanol/thirteenloko/overdose_process(mob/living/M)
	if(prob(7) && iscarbon(M))
		var/obj/item/I = M.get_active_held_item()
		if(I)
			M.dropItemToGround(I)
			to_chat(M, "<span class ='notice'>Twoje dłonie drżą i upuszczasz to, co trzymałeś!</span>")
			M.Jitter(10)

	if(prob(7))
		to_chat(M, "<span class='notice'>[pick("You have a really bad headache.", "Your eyes hurt.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]</span>")

	if(prob(5) && iscarbon(M))
		var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
		if(HAS_TRAIT(M, TRAIT_BLIND))
			if(istype(eyes))
				eyes.Remove(M)
				eyes.forceMove(get_turf(M))
				to_chat(M, "<span class='userdanger'>Zginasz się wpół z bólu, czując, jak twoje gałki oczne upłynniają się w głowie!</span>")
				M.emote("scream")
				M.adjustBruteLoss(15)
		else
			to_chat(M, "<span class='userdanger'>Krzyczysz z przerażenia, ślepnąc!</span>")
			eyes.applyOrganDamage(eyes.maxHealth)
			M.emote("scream")

	if(prob(3) && iscarbon(M))
		M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
		M.Unconscious(100)
		M.Jitter(350)

	if(prob(1) && iscarbon(M))
		var/datum/disease/D = new /datum/disease/heart_failure
		M.ForceContractDisease(D)
		to_chat(M, "<span class='userdanger'>Jesteś prawie pewien, że twoje serce na sekundę stanęło..</span>")
		M.playsound_local(M, 'sound/effects/singlebeat.ogg', 100, 0)

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	description = "Napój i paliwo numer jeden dla Rosjan na całym świecie."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 65
	taste_description = "spirytus zbożowy"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of vodka"
	glass_desc = "Szklanka zawiera wódkę. Na zdrowie."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/carbon/M)
	M.radiation = max(M.radiation-2,0)
	return ..()

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	description = "To chyba piwo zmieszane z mlekiem. Obrzydliwe."
	color = "#895C4C" // rgb: 137, 92, 76
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 15
	taste_description = "desperacja i laktoza"
	glass_icon_state = "glass_brown"
	glass_name = "glass of bilk"
	glass_desc = "Mieszanka mleka i piwa. Dla alkoholików, którzy boją się osteoporozy."

/datum/reagent/consumable/ethanol/bilk/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(10))
		M.heal_bodypart_damage(1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	description = "Zrobiony dla kobiety, ale dość mocny dla mężczyzny."
	color = "#666340" // rgb: 102, 99, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "dryness"
	glass_icon_state = "threemileislandglass"
	glass_name = "Three Mile Island Ice Tea"
	glass_desc = "Szklanka tego na pewno zapobiegnie stopieniu rdzenia."

/datum/reagent/consumable/ethanol/threemileisland/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(50)
	return ..()

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	description = "To gin. W kosmosie. Powiadam, szanowny panie."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	taste_description = "alkoholowa choinka"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of gin"
	glass_desc = "Krystalicznie czysta szklanka ginu Griffeater."

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	description = "Jo-ho-ho i tak dalej."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 60
	taste_description = "zaprawiony karmel"
	glass_icon_state = "rumglass"
	glass_name = "glass of rum"
	glass_desc = "Teraz chcesz się pomodlić o strój pirata, prawda?"
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	description = "Mocny, łagodny w smaku meksykański trunek. Chce się pić, hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 70
	taste_description = "rozpuszczalnik do farb"
	glass_icon_state = "tequilaglass"
	glass_name = "glass of tequila"
	glass_desc = "Teraz brakuje tylko dziwnie kolorowych okularów!"
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	description = "Nagle masz ochotę na martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	taste_description = "wytrawny alkohol"
	glass_icon_state = "vermouthglass"
	glass_name = "glass of vermouth"
	glass_desc = "Zastanawiasz się, czemu w ogóle pijesz to bez niczego."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	description = "Ekskluzywny napój alkoholowy z destylowanego soku winogronowego."
	color = "#7E4043" // rgb: 126, 64, 67
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 35
	taste_description = "gorzka słodycz"
	glass_icon_state = "wineglass"
	glass_name = "glass of wine"
	glass_desc = "Bardzo elegancko wyglądający drink."
	shot_glass_icon_state = "shotglassred"

/datum/reagent/consumable/ethanol/lizardwine
	name = "Lizard wine"
	description = "Napój alkoholowy z Kosmicznych Chin, robiony przez nasączanie etanolu jaszczurczymi ogonami."
	color = "#7E4043" // rgb: 126, 64, 67
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_FANTASTIC
	taste_description = "łuskowata słodycz"

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	description = "Wyborna włoska brandy na czas, gdy zwykłe wino jest za mało alkoholowe."
	color = "#F8EBF1"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	taste_description = "elegancka gorzka słodycz"
	glass_icon_state = "grappa"
	glass_name = "glass of grappa"
	glass_desc = "Wyborny trunek, pierwotnie robiony z resztek po produkcji wina, by nic się nie zmarnowało."

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	description = "Słodki i mocny trunek, powstający po wielu destylacjach i latach dojrzewania. Elegancki jak diabli."
	color = "#AB3C05" // rgb: 171, 60, 5
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 75
	taste_description = "elegancka francuska brandy"
	glass_icon_state = "cognacglass"
	glass_name = "glass of cognac"
	glass_desc = "Kurczę, czujesz się jak francuski arystokrata, ledwo to trzymając."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	description = "Mocny napój alkoholowy. Podobno wywołuje halucynacje, ale nie wywołuje."
	color = rgb(10, 206, 0)
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 80 //Very strong even by default
	taste_description = "śmierć i lukrecja"
	glass_icon_state = "absinthe"
	glass_name = "glass of absinthe"
	glass_desc = "Jest tak mocny, jak pachnie."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/carbon/M)
	if(prob(10) && !HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.hallucination += 4 //Reference to the urban myth
	..()

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	description = "Albo czyjaś porażka w robieniu koktajli, albo próba produkcji alkoholu. Tak czy inaczej, naprawdę chcesz to pić?"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 100
	taste_description = "czysta rezygnacja"
	glass_icon_state = "glass_brown2"
	glass_name = "Hooch"
	glass_desc = "Teraz naprawdę sięgnąłeś dna... twoja wątroba spakowała się i wyszła zeszłej nocy."

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M)
	if(M.mind?.assigned_role == JOB_NAME_ASSISTANT)
		M.heal_bodypart_damage(1,1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	description = "Ciemny napój alkoholowy z jęczmienia słodowanego i drożdży."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 65
	taste_description = "treściwe jęczmienne ale"
	glass_icon_state = "aleglass"
	glass_name = "glass of ale"
	glass_desc = "Lodowato zimny kufel pysznego ale."

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	description = "Cynamonowy sznaps 100 proof, dla nastoletnich alkoholiczek na wiosennej przerwie."
	color = "#FFFF91" // rgb: 255, 255, 145
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "palący cynamon"
	glass_icon_state = "goldschlagerglass"
	glass_name = "glass of goldschlager"
	glass_desc = "100% dowód na to, że nastolatki wypiją wszystko, co ma w sobie złoto."
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	description = "Tequila ze srebrem, ulubiony trunek alkoholiczek z klubów."
	color = "#585840" // rgb: 88, 88, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_VERYGOOD
	taste_description = "metaliczny i drogi"
	glass_icon_state = "patronglass"
	glass_name = "glass of patron"
	glass_desc = "Pijemy patrona w barze, z kiepskimi paniami."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	description = "Klasyka wszech czasów, łagodny koktajl."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "łagodny i cierpki"
	glass_icon_state = "gintonicglass"
	glass_name = "Gin and Tonic"
	glass_desc = "Łagodny, ale wciąż świetny koktajl. Pij jak prawdziwy Anglik."

/datum/reagent/consumable/ethanol/rum_coke
	name = "Rum and Coke"
	description = "Rum zmieszany z colą."
	taste_description = "cola"
	color = "#3E1B00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_NICE
	glass_icon_state = "whiskeycolaglass"
	glass_name = "Rum and Coke"
	glass_desc = "Klasyczny wybór kosmicznych bractw studenckich."

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	description = "Viva la Revolucion! Viva Cuba Libre!"
	color = "#3E1B00" // rgb: 62, 27, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "orzeźwiające połączenie cytrusów i rumu"
	glass_icon_state = "cubalibreglass"
	glass_name = "Cuba Libre"
	glass_desc = "Klasyczna mieszanka rumu, coli i limonki. Ulubieniec rewolucjonistów na całym świecie!"

/datum/reagent/consumable/ethanol/cuba_libre/on_mob_life(mob/living/carbon/M)
	if(M?.mind?.has_antag_datum(/datum/antagonist/rev)) //Cuba Libre, the traditional drink of revolutions! Heals revolutionaries.
		M.adjustBruteLoss(-1, 0)
		M.adjustFireLoss(-1, 0)
		M.adjustToxLoss(-1, 0)
		M.adjustOxyLoss(-5, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	description = "Whisky z colą. Zaskakująco orzeźwiające."
	color = "#3E1B00" // rgb: 62, 27, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "cola"
	glass_icon_state = "whiskeycolaglass"
	glass_name = "whiskey cola"
	glass_desc = "Niewinnie wyglądająca mieszanka coli i whisky. Pyszna."


/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	description = "Wermut z ginem. Nie tak, jak lubił go 007, ale wciąż pyszny."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "wytrawna klasa"
	glass_icon_state = "martiniglass"
	glass_name = "Classic Martini"
	glass_desc = "Kurczę, barman nawet go zamieszał, a nie wstrząsnął."

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	description = "Wódka z ginem. Nie tak, jak lubił go 007, ale wciąż pyszny."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 65
	quality = DRINK_NICE
	taste_description = "wstrząśnięte, nie zmieszane"
	glass_icon_state = "martiniglass"
	glass_name = "Vodka martini"
	glass_desc ="Wypaczenie klasycznego martini. Wciąż świetne."

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	description = "To tylko, no wiesz, twoja opinia, stary..."
	color = "#A68340" // rgb: 166, 131, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "gorzka śmietanka"
	glass_icon_state = "whiterussianglass"
	glass_name = "White Russian"
	glass_desc = "Bardzo ładnie wyglądający drink. Ale to tylko, no wiesz, twoja opinia, stary."

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	description = "Wódka zmieszana ze zwykłym sokiem pomarańczowym. Wynik jest zaskakująco pyszny."
	color = "#A68310" // rgb: 166, 131, 16
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 55
	quality = DRINK_NICE
	taste_description = "oranges"
	glass_icon_state = "screwdriverglass"
	glass_name = "Screwdriver"
	glass_desc = "Prosta, a jednocześnie wyborna mieszanka wódki i soku pomarańczowego. W sam raz dla zmęczonego inżyniera."

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_life(mob/living/carbon/M)
	if(M.mind && (M.mind.assigned_role in list(JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN, JOB_NAME_CHIEFENGINEER))) //Engineers lose radiation poisoning at a massive rate.
		M.radiation = max(M.radiation - 25, 0)
	return ..()

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	description = "Fuuuj..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	taste_description = "sweet 'n creamy"
	glass_icon_state = "booger"
	glass_name = "Booger"
	glass_desc = "Fuuuj..."

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	description = "Dziwna, ale przyjemna mieszanka wódki, pomidora i soku z limonki. A przynajmniej MYŚLISZ, że to czerwone to sok pomidorowy."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 55
	quality = DRINK_GOOD
	taste_description = "pomidory z nutą limonki"
	glass_icon_state = "bloodymaryglass"
	glass_name = "Bloody Mary"
	glass_desc = "Sok pomidorowy zmieszany z wódką i odrobiną limonki. Smakuje jak płynne morderstwo."

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/carbon/C)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume = min(BLOOD_VOLUME_NORMAL, C.blood_volume + 3) //Bloody Mary quickly restores blood loss.
	..()

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	description = "Równie skuteczne jak holenderska odwaga!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_NICE
	taste_description = "alkoholowa odwaga"
	glass_icon_state = "bravebullglass"
	glass_name = "Brave Bull"
	glass_desc = "Tequila i likier kawowy połączone w ślinotoczną mieszankę. Pij."
	var/tough_text

/datum/reagent/consumable/ethanol/brave_bull/on_mob_metabolize(mob/living/M)
	tough_text = pick("krzepki", "nieustępliwy", "twardy", "wytrzymały", "silny") //Tuff stuff
	to_chat(M, "<span class='notice'>Czujesz się [tough_text]!</span>")
	M.maxHealth += 10 //Brave Bull makes you sturdier, and thus capable of withstanding a tiny bit more punishment.
	M.health += 10

/datum/reagent/consumable/ethanol/brave_bull/on_mob_end_metabolize(mob/living/M)
	to_chat(M, "<span class='notice'>Nie czujesz się już [tough_text].</span>")
	M.maxHealth -= 10
	M.health = min(M.health - 10, M.maxHealth) //This can indeed crit you if you're alive solely based on alchol ingestion

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	description = "Tequila, grenadyna i sok pomarańczowy."
	color = "#FFE48C" // rgb: 255, 228, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "pomarańcze z nutą granatu"
	glass_icon_state = "tequilasunriseglass"
	glass_name = "tequila Sunrise"
	glass_desc = "No świetnie, teraz tęsknisz za wschodami słońca na Terze..."
	var/obj/effect/light_holder

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_metabolize(mob/living/M)
	to_chat(M, "<span class='notice'>Czujesz, jak przez twoje ciało rozchodzi się łagodne ciepło!</span>")
	light_holder = new(M)
	light_holder.set_light(3, 0.7, "#FFCC00") //Tequila Sunrise makes you radiate dim light, like a sunrise!

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_life(mob/living/carbon/M)
	if(QDELETED(light_holder))
		M.reagents.del_reagent(/datum/reagent/consumable/ethanol/tequila_sunrise) //If we lost our light object somehow, remove the reagent
	else if(light_holder.loc != M)
		light_holder.forceMove(M)
	return ..()

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_end_metabolize(mob/living/M)
	to_chat(M, "<span class='notice'>Ciepło w twoim ciele słabnie.</span>")
	QDEL_NULL(light_holder)

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	description = "TO SIĘ PALI! WEZWIJCIE TEN CHOLERNY PROM!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "ostre toksyny"
	glass_icon_state = "toxinsspecialglass"
	glass_name = "Toxins Special"
	glass_desc = "Łooo, to się pali!"
	shot_glass_icon_state = "toxinsspecialglass"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(var/mob/living/M)
	M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	description = "Wypij to i szykuj się na PRAWO."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90 //THE FIST OF THE LAW IS STRONG AND HARD
	quality = DRINK_GOOD
	metabolization_rate = 0.5
	taste_description = "JUSTICE"
	glass_icon_state = "beepskysmashglass"
	glass_name = "Beepsky Smash"
	glass_desc = "Ciężki, gorący i mocny. Jak żelazna pięść PRAWA."
	overdose_threshold = 40

	var/datum/brain_trauma/special/beepsky/B

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_metabolize(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		metabolization_rate = 0.8
	if(M.mind && !HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		B = new()
		M.gain_trauma(B, TRAUMA_RESILIENCE_ABSOLUTE)
	ADD_TRAIT(M, TRAIT_NOBLOCK, type) //sorry sec, but you dont get a special stam heal to help with blocking
	..()

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/carbon/M)
	M.Jitter(2)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.adjustStaminaLoss(-10, 0)
		if(prob(20))
			new /datum/hallucination/items_other(M)
		if(prob(10))
			new /datum/hallucination/stray_bullet(M)
	..()
	. = 1

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_end_metabolize(mob/living/carbon/M)
	if(B)
		QDEL_NULL(B)
	REMOVE_TRAIT(M, TRAIT_NOBLOCK, type)
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash/overdose_start(mob/living/carbon/M)
	if(M.mind && !HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.gain_trauma(/datum/brain_trauma/mild/phobia/security, TRAUMA_RESILIENCE_BASIC)


/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	description = "Śmietanka z whisky. Czego innego spodziewać się po Irlandczykach?"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "kremowy alkohol"
	glass_icon_state = "irishcreamglass"
	glass_name = "Irish Cream"
	glass_desc = "Śmietanka z whisky. Czego innego spodziewać się po Irlandczykach?"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	description = "Piwo i ale połączone w pyszną mieszankę. Tylko dla prawdziwych mężczyzn."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 100 //For the manly only
	quality = DRINK_NICE
	taste_description = "włosy na klacie i brodzie"
	glass_icon_state = "manlydorfglass"
	glass_name = "The Manly Dorf"
	glass_desc = "Piwo i ale połączone w pyszną mieszankę. Tylko dla prawdziwych mężczyzn."
	var/dorf_mode

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(HAS_TRAIT(C, TRAIT_ALCOHOL_TOLERANCE) || (C.has_dna() && C.dna.check_mutation(DWARFISM)))
			to_chat(C, "<span class='notice'>To jest MĘSKIE!</span>")
			boozepwr = 5 //We've had worse in the mines
			dorf_mode = TRUE

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_life(mob/living/carbon/M)
	if(dorf_mode)
		M.adjustBruteLoss(-2)
		M.adjustFireLoss(-2)
	return ..()

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	description = "Cały barek połączony w pyszną mieszankę. Tylko dla alkoholiczek w średnim wieku."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "mieszanka coli i alkoholu"
	glass_icon_state = "longislandicedteaglass"
	glass_name = "Long Island Iced Tea"
	glass_desc = "Cały barek połączony w pyszną mieszankę. Tylko dla alkoholiczek w średnim wieku."


/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	description = "Teraz naprawdę sięgnąłeś dna. Twoja wątroba spakowała się i wyszła zeszłej nocy."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha) (like water)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING | CHEMICAL_GOAL_BOTANIST_HARVEST
	boozepwr = 95
	taste_description = "bitterness"
	glass_icon_state = "glass_clear"
	glass_name = "Moonshine"
	glass_desc = "Teraz naprawdę sięgnąłeś dna. Twoja wątroba spakowała się i wyszła zeszłej nocy."

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	description = "Kawa, Irish Cream i koniak. Upijesz się."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 85
	quality = DRINK_GOOD
	taste_description = "wściekły i irlandzki"
	glass_icon_state = "b52glass"
	glass_name = "B-52"
	glass_desc = "Kahlua, Irish Cream i koniak. Upijesz się."
	shot_glass_icon_state = "b52glass"

/datum/reagent/consumable/ethanol/b52/on_mob_metabolize(mob/living/M)
	playsound(M, 'sound/effects/explosion_distant.ogg', 100, FALSE)

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	description = "Kawa i alkohol. Przyjemniejsze na rano niż mimosa."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "poddanie się na cały dzień"
	glass_icon_state = "irishcoffeeglass"
	glass_name = "Irish Coffee"
	glass_desc = "Kawa i alkohol. Przyjemniejsze na rano niż mimosa."

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	description = "Z lodem i solą na brzegu. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "wytrawny i słony"
	glass_icon_state = "margaritaglass"
	glass_name = "Margarita"
	glass_desc = "Z lodem i solą na brzegu. Arriba~!"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	description = "Dla osób z nietolerancją laktozy. Wciąż elegancki jak White Russian."
	color = "#360000" // rgb: 54, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "bitterness"
	glass_icon_state = "blackrussianglass"
	glass_name = "Black Russian"
	glass_desc = "Dla osób z nietolerancją laktozy. Wciąż elegancki jak White Russian."


/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	description = "Ulubiony drink detektywa pod przykrywką. Nigdy nie znosił ginu."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "łagodna wytrawność"
	glass_icon_state = "manhattanglass"
	glass_name = "Manhattan"
	glass_desc = "Ulubiony drink detektywa pod przykrywką. Nigdy nie znosił ginu."


/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	description = "Ulubiony drink naukowców. Świetny do rozmyślania, jak wysadzić stację."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "śmierć, niszczyciel światów"
	glass_icon_state = "proj_manhattanglass"
	glass_name = "Manhattan Project"
	glass_desc = "Ulubiony drink naukowców. Świetny do myślenia, jak wysadzić stację."


/datum/reagent/consumable/ethanol/manhattan_proj/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(30)
	return ..()

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	description = "Dla bardziej wyrafinowanego gryfa."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "soda"
	glass_icon_state = "whiskeysodaglass2"
	glass_name = "whiskey soda"
	glass_desc = "Ostateczne orzeźwienie."

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	description = "Ostateczne orzeźwienie. To nie to, na co brzmi."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "siki Dziadka Mroza"
	glass_icon_state = "antifreeze"
	glass_name = "Anti-freeze"
	glass_desc = "Ostateczne orzeźwienie."

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	description = "Bosa i w ciąży."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "kremowe jagody"
	glass_icon_state = "b&p"
	glass_name = "Barefoot"
	glass_desc = "Bosa i w ciąży."

/datum/reagent/consumable/ethanol/barefoot/on_mob_life(mob/living/carbon/M)
	if(ishuman(M)) //Barefoot causes the imbiber to quickly regenerate brute trauma if they're not wearing shoes.
		var/mob/living/carbon/human/H = M
		if(!H.shoes)
			H.adjustBruteLoss(-3, 0)
			. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	description = "Zimne orzeźwienie."
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "orzeźwiający chłód"
	glass_icon_state = "snowwhite"
	glass_name = "Snow White"
	glass_desc = "Zimne orzeźwienie."

/datum/reagent/consumable/ethanol/demonsblood //Prevents the imbiber from being dragged into a pool of blood by a slaughter demon.
	name = "Demon's Blood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 75
	quality = DRINK_VERYGOOD
	taste_description = "słodkie żelazo"
	glass_icon_state = "demonsblood"
	glass_name = "Demons Blood"
	glass_desc = "Samo patrzenie na to sprawia, że włosy na karku stają dęba."


/datum/reagent/consumable/ethanol/devilskiss //If eaten by a slaughter demon, the demon will regret it.
	name = "Devil's Kiss"
	description = "Upiorna pora!"
	color = "#A68310" // rgb: 166, 131, 16
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_VERYGOOD
	taste_description = "gorzkie żelazo"
	glass_icon_state = "devilskiss"
	glass_name = "Devils Kiss"
	glass_desc = "Upiorna pora!"


/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	description = "Gdy gin z tonikiem nie jest dość rosyjski."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "cierpka gorycz"
	glass_icon_state = "vodkatonicglass"
	glass_name = "vodka and tonic"
	glass_desc = "Gdy gin z tonikiem nie jest dość rosyjski."


/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	description = "Orzeźwiająco cytrynowy, wybornie wytrawny."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "wytrawne, cierpkie cytryny"
	glass_icon_state = "ginfizzglass"
	glass_name = "gin fizz"
	glass_desc = "Orzeźwiająco cytrynowy, wybornie wytrawny."


/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama Mama"
	description = "Tropikalny koktajl o złożonej mieszance smaków."
	color = "#FF7F3B" // rgb: 255, 127, 59
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "ananas, kokos i nuta kawy"
	glass_icon_state = "bahama_mama"
	glass_name = "Bahama Mama"
	glass_desc = "Tropikalny koktajl o złożonej mieszance smaków."

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	description = "Napój z bluespace!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "skoncentrowana materia"
	glass_icon_state = "singulo"
	glass_name = "Singulo"
	glass_desc = "Napój z bluespace."

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	description = "Ostra wódka! Może być trochę za ostra dla maluchów!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_GOOD
	taste_description = "ostrość i przyprawy"
	glass_icon_state = "sbitenglass"
	glass_name = "Sbiten"
	glass_desc = "Ostra wódka! Może być trochę za ostra dla maluchów!"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT, 0 ,BODYTEMP_HEAT_DAMAGE_LIMIT) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	description = "Prawdziwy napój wikingów! Choć ma dziwny czerwony kolor."
	color = "#C73C00" // rgb: 199, 60, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 31 //Red drinks are stronger
	quality = DRINK_GOOD
	taste_description = "słodko-słony alkohol"
	glass_icon_state = "red_meadglass"
	glass_name = "Red Mead"
	glass_desc = "Prawdziwy napój wikingów! Choć ma dziwny czerwony kolor."

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	description = "Napój wikingów, choć tani."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "słodki, słodki alkohol"
	glass_icon_state = "meadglass"
	glass_name = "Mead"
	glass_desc = "Napój wikinga, choć tani."

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	description = "Piwo tak zimne, że zamarza wokół niego powietrze."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 15
	taste_description = "orzeźwiająco zimne"
	glass_icon_state = "iced_beerglass"
	glass_name = "iced beer"
	glass_desc = "Piwo tak mroźne, że zamarza wokół niego powietrze."

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	description = "Rozwodniony rum. Zatwierdzony przez Nanotrasen!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 1 //Basically nothing
	taste_description = "marna wymówka zamiast alkoholu"
	glass_icon_state = "grogglass"
	glass_name = "Grog"
	glass_desc = "Rozwodniony rum. Zatwierdzony przez Nanotrasen!"


/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	description = "Taki bardzo, bardzo, bardzo dobry."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "sweet 'n creamy"
	glass_icon_state = "aloe"
	glass_name = "Aloe"
	glass_desc = "Bardzo, bardzo, bardzo dobry."

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	description = "Ładny drink o dziwnej nazwie."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "lemons"
	glass_icon_state = "andalusia"
	glass_name = "Andalusia"
	glass_desc = "Ładny drink o dziwnej nazwie."

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	description = "Drink zrobiony z twoich sojuszników. Nie tak słodki jak te z twoich wrogów."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_NICE
	taste_description = "gorzki, ale wolny"
	glass_icon_state = "alliescocktail"
	glass_name = "Allies cocktail"
	glass_desc = "Drink zrobiony z twoich sojuszników. Nie tak słodki jak te z twoich wrogów."

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	description = "Drink dla odważnych! Zawiera o 20% więcej żywych obcych."
	color = "#365000" // rgb: 54, 80, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_VERYGOOD
	taste_description = "kwas żołądkowy"
	glass_icon_state = "acidspitglass"
	glass_name = "Acid Spit"
	glass_desc = "Drink dla odważnych! Zawiera o 20% więcej żywych obcych."

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	description = "Oficjalny drink Klubu Strzeleckiego Nanotrasen!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "ciemny i metaliczny"
	glass_icon_state = "amasecglass"
	glass_name = "Amasec"
	glass_desc = "Oficjalny drink Klubu Strzeleckiego Nanotrasen!"

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	description = "Bierzesz malutki łyk i czujesz pieczenie..."
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 95
	quality = DRINK_GOOD
	taste_description = "mózg wyciekający ci nosem"
	glass_icon_state = "changelingsting"
	glass_name = "Changeling Sting"
	glass_desc = "Kłujący drink."

/datum/reagent/consumable/ethanol/changelingsting/on_mob_life(mob/living/carbon/M)
	if(M.mind) //Changeling Sting assists in the recharging of changeling chemicals.
		var/datum/antagonist/changeling/changeling = M.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges += metabolization_rate
			changeling.chem_charges = CLAMP(changeling.chem_charges, 0, changeling.chem_storage)
	return ..()

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	description = "Mmm, smakuje jak tort czekoladowy..."
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "pyszna złość"
	glass_icon_state = "irishcarbomb"
	glass_name = "Irish Car Bomb"
	glass_desc = "Irlandzka bomba samochodowa."

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	description = "Smakuje jak terroryzm!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90
	quality = DRINK_GOOD
	taste_description = "oczyszczony antagonizm"
	glass_icon_state = "syndicatebomb"
	glass_name = "Syndicate Bomb"
	glass_desc = "Bomba Syndykatu."

/datum/reagent/consumable/ethanol/syndicatebomb/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		playsound(get_turf(M), 'sound/effects/explosionfar.ogg', 100, 1)
	return ..()

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	description = "Niespodzianka: jest zielony!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "cierpkość i banany"
	glass_icon_state = "erikasurprise"
	glass_name = "Erika Surprise"
	glass_desc = "Niespodzianka: jest zielony!"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	description = "Tylko dla doświadczonych. Wydaje ci się, że w szklance pływa piasek."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 65
	quality = DRINK_GOOD
	taste_description = "a beach"
	glass_icon_state = "driestmartiniglass"
	glass_name = "Driest Martini"
	glass_desc = "Tylko dla doświadczonych. Wydaje ci się, że w szklance pływa piasek."

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Honk"
	description = "Drink z Nieba Klaunów."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "kiepski żart"
	glass_icon_state = "bananahonkglass"
	glass_name = "Banana Honk"
	glass_desc = "Drink z Nieba Klaunów."

/datum/reagent/consumable/ethanol/bananahonk/on_mob_life(mob/living/carbon/M)
	if((ishuman(M) && M.job == JOB_NAME_CLOWN) || ismonkey(M))
		M.heal_bodypart_damage(1,1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	description = "Drink z Nieba Mimów."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = NONE
	boozepwr = 59 //Proof that clowns are better than mimes right here
	quality = DRINK_GOOD
	taste_description = "gumka do ścierania"
	glass_icon_state = "silencerglass"
	glass_name = "Silencer"
	glass_desc = "Drink z Nieba Mimów."

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/carbon/M)
	M.silent = max(M.silent, 1.25)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.heal_bodypart_damage(1 , 1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	description = "Dziwna mieszanka whisky i soku z blumpkina."
	color = "#1EA0FF" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "melasa i haust wody z basenu"
	glass_icon_state = "drunkenblumpkin"
	glass_name = "Drunken Blumpkin"
	glass_desc = "Dziwna mieszanka whisky i soku z blumpkina."

/datum/reagent/consumable/ethanol/whiskey_sour //Requested since we had whiskey cola and soda but not sour.
	name = "Whiskey Sour"
	description = "Sok z cytryny zmieszany z whisky i odrobiną cukru. Zaskakująco satysfakcjonujący."
	color = rgb(255, 201, 49)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "kwaśne cytryny"
	glass_icon_state = "whiskey_sour"
	glass_name = "whiskey sour"
	glass_desc = "Sok z cytryny zmieszany z whisky i odrobiną cukru. Zaskakująco satysfakcjonujący."

/datum/reagent/consumable/ethanol/hcider
	name = "Hard Cider"
	description = "Smakuje jak jesień. Nie, czekaj, jak liście spadające z drzew!"
	color = "#CD6839"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "pora roku, która <i>spada</i> między latem a zimą"
	glass_icon_state = "whiskeyglass"
	glass_name = "hard cider"
	glass_desc = "Smakuje jak jesień. Nie, czekaj, jak liście spadające z drzew!"
	shot_glass_icon_state = "shotglassbrown"


/datum/reagent/consumable/ethanol/fetching_fizz //A reference to one of my favorite games of all time. Pulls nearby ores to the imbiber!
	name = "Fetching Fizz"
	description = "Mieszanka whisky sour, żelaza i uranu, z której powstaje silnie magnetyczna breja. Niska zawartość alkoholu." //Requires no alcohol to make but has alcohol anyway because ~magic~
	color = rgb(255, 91, 15)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "naładowany metal" // the same as teslium, honk honk.
	glass_icon_state = "fetching_fizz"
	glass_name = "Fetching Fizz"
	glass_desc = "Wywołuje magnetyzm u pijącego. Zaczęło się jako barowy żart, ale stało się popularne wśród górników i złomiarzy. Metaliczny posmak."


/datum/reagent/consumable/ethanol/fetching_fizz/on_mob_life(mob/living/carbon/M)
	for(var/obj/item/stack/ore/O in orange(3, M))
		step_towards(O, get_turf(M))
	return ..()

//Another reference. Heals those in critical condition extremely quickly.
/datum/reagent/consumable/ethanol/hearty_punch
	name = "Hearty Punch"
	description = "Mieszanka brave bull, bomby Syndykatu i absyntu, z której powstaje energetyzujący napój. Niska zawartość alkoholu."
	color = rgb(140, 0, 0)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	taste_description = "brawura w obliczu katastrofy"
	glass_icon_state = "hearty_punch"
	glass_name = "Hearty Punch"
	glass_desc = "Aromatyczny napój podawany gorący. Według ludowych opowieści potrafi niemal obudzić zmarłych."


/datum/reagent/consumable/ethanol/hearty_punch/on_mob_life(mob/living/carbon/M)
	if(M.health <= 0)
		M.adjustBruteLoss(-3, 0)
		M.adjustFireLoss(-3, 0)
		M.adjustCloneLoss(-5, 0)
		M.adjustOxyLoss(-4, 0)
		M.adjustToxLoss(-3, 0)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	description = "Niezidentyfikowana mieszanka. Niemierzalnie wysoka zawartość alkoholu."
	color = rgb(51, 19, 3) //Sickly brown
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 300 //I warned you
	taste_description = "ściana z cegieł"
	glass_icon_state = "glass_brown2"
	glass_name = "Bacchus' Blessing"
	glass_desc = "Nie sądziłeś, że płyn może być aż tak odrażający. Na pewno tego chcesz...?"



/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	description = "Proliferacja broni jądrowej nigdy nie smakowała tak dobrze."
	color = "#666300" // rgb: 102, 99, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	taste_description = "bomba"
	glass_icon_state = "atomicbombglass"
	glass_name = "Atomic Bomb"
	glass_desc = "Nanotrasen nie ponosi prawnej odpowiedzialności za twoje czyny po spożyciu."

/datum/reagent/consumable/ethanol/atomicbomb/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(50)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.confused = max(M.confused+2,0)
		M.Dizzy(10)
	if (!M.slurring)
		M.slurring = 1
	M.slurring += 3
	switch(current_cycle)
		if(51 to 200)
			M.Sleeping(100, FALSE)
			. = 1
		if(201 to INFINITY)
			M.AdjustSleeping(40, FALSE)
			M.adjustToxLoss(2, 0)
			. = 1
	..()

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Łooo, to wygląda na niestabilne!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //custom drunk effect
	quality = DRINK_GOOD
	taste_description = "mózg wybity plasterkiem cytryny owiniętym wokół sztabki złota"
	glass_icon_state = "gargleblasterglass"
	glass_name = "Pan-Galactic Gargle Blaster"
	glass_desc = "Jakby ktoś wybił ci mózg plasterkiem cytryny owiniętym wokół dużej sztabki złota."

/datum/reagent/consumable/ethanol/gargle_blaster/on_mob_life(mob/living/carbon/M)
	M.dizziness +=1.5
	switch(current_cycle)
		if(15 to 45)
			if(!M.slurring)
				M.slurring = 1
			M.slurring += 3
		if(45 to 55)
			if(prob(50))
				M.confused = max(M.confused+3,0)
		if(55 to 200)
			M.set_drugginess(55)
		if(200 to INFINITY)
			M.adjustToxLoss(2, 0)
			. = 1
	..()

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neurotoxin"
	description = "Silna neurotoksyna, która wprowadza ofiarę w stan przypominający śmierć."
	color = "#2E2E61" // rgb: 46, 46, 97
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "uczucie odrętwienia"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	glass_icon_state = "neurotoxinglass"
	glass_name = "Neurotoxin"
	glass_desc = "Drink, który gwarantuje, że cię znokautuje."


/datum/reagent/consumable/ethanol/neurotoxin/proc/pickt()
	return (pick(TRAIT_PARALYSIS_L_ARM,TRAIT_PARALYSIS_R_ARM,TRAIT_PARALYSIS_R_LEG,TRAIT_PARALYSIS_L_LEG))

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(50)
	M.dizziness +=2
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1*REM, 150)
	if(prob(20))
		M.adjustStaminaLoss(10)
		M.drop_all_held_items()
		to_chat(M, "<span class='notice'>Nie czujesz rąk!</span>")
	if(current_cycle > 5)
		if(prob(20))
			var/t = pickt()
			ADD_TRAIT(M, t, type)
			M.adjustStaminaLoss(10)
		if(current_cycle > 30)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
			if(current_cycle > 50 && prob(15))
				if(!M.undergoing_cardiac_arrest() && M.can_heartattack())
					M.set_heartattack(TRUE)
					if(M.stat == CONSCIOUS)
						M.visible_message("<span class='userdanger'>[M] chwyta się za klatkę piersiową, jakby jego serce stanęło!</span>")
	. = 1
	..()

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_LEG, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_LEG, type)
	M.adjustStaminaLoss(10)
	..()

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	description = "Po prostu tego nie łapiesz, staaary."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 0
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "daj szansę pokojowi"
	glass_icon_state = "hippiesdelightglass"
	glass_name = "Hippie's Delight"
	glass_desc = "Drink, którym delektowano się w latach 60."


/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/carbon/M)
	if (!M.slurring)
		M.slurring = 1
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(10)
			M.set_drugginess(30)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(45)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if (10 to 200)
			M.Jitter(40)
			M.Dizzy(40)
			M.set_drugginess(60)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			M.Jitter(60)
			M.Dizzy(60)
			M.set_drugginess(75)
			if(prob(40))
				M.emote(pick("twitch","giggle"))
			if(prob(30))
				M.adjustToxLoss(2, 0)
				. = 1
	..()

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	description = "Na najcudowniejszą porę roku."
	color = "#fcfdc6" // rgb: 252, 253, 198
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 1
	quality = DRINK_VERYGOOD
	taste_description = "budyń i alkohol"
	glass_icon_state = "glass_yellow"
	glass_name = "eggnog"
	glass_desc = "Na najcudowniejszą porę roku."


/datum/reagent/consumable/ethanol/narsour
	name = "Nar'Sour"
	description = "Skutki uboczne obejmują samookaleczenie i chomikowanie plastali."
	color = RUNE_COLOR_DARKRED
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "blood"
	glass_icon_state = "narsour"
	glass_name = "Nar'Sour"
	glass_desc = "Nowy przebojowy koktajl inspirowany browarami THE ARM sprawi, że w mgnieniu oka będziesz krzyczeć Fuu ma'jin!"


/datum/reagent/consumable/ethanol/narsour/on_mob_life(mob/living/carbon/M)
	M.cultslurring = min(M.cultslurring + 3, 3)
	M.stuttering = min(M.stuttering + 3, 3)
	..()

/datum/reagent/consumable/ethanol/triple_sec
	name = "Triple Sec"
	description = "Słodki i żywy likier pomarańczowy."
	color = "#ffcc66"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 30
	taste_description = "ciepły, kwiatowy smak pomarańczy przywołujący morskie powietrze i letni wiatr Karaibów"
	glass_icon_state = "glass_orange"
	glass_name = "Triple Sec"
	glass_desc = "Szklanka czystego Triple Sec."

/datum/reagent/consumable/ethanol/creme_de_menthe
	name = "Creme de Menthe"
	description = "Miętowy likier, doskonały do orzeźwiających, chłodnych drinków."
	color = "#00cc00"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "miętowy, chłodny i orzeźwiający plusk zimnej wody ze strumienia"
	glass_icon_state = "glass_green"
	glass_name = "Creme de Menthe"
	glass_desc = "Patrząc na to, niemal czujesz pierwszy oddech wiosny."

/datum/reagent/consumable/ethanol/creme_de_cacao
	name = "Creme de Cacao"
	description = "Czekoladowy likier doskonały do nadawania napojom deserowych nut i przekupywania studenckich stowarzyszeń."
	color = "#996633"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "gładka i aromatyczna nuta czekolady wirująca w kęsie alkoholu"
	glass_icon_state = "glass_brown"
	glass_name = "Creme de Cacao"
	glass_desc = "Ten skromny składnik zapoczątkował milion pozwów o otrzęsiny i zatruć alkoholowych."

/datum/reagent/consumable/ethanol/creme_de_coconut
	name = "Creme de Coconut"
	description = "Kokosowy likier do gładkich, kremowych, tropikalnych drinków."
	color = "#F7F0D0"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "słodki, mleczny smak z nutą przypalonego cukru"
	glass_icon_state = "glass_white"
	glass_name = "Creme de Coconut"
	glass_desc = "Niegroźnie wyglądająca szklanka likieru kokosowego."

/datum/reagent/consumable/ethanol/quadruple_sec
	name = "Quadruple Sec"
	description = "Kopie równie mocno jak lizanie ogniwa pałki, ale smaczniej."
	color = "#cc0000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "orzeźwiająca, gorzka świeżość przenikająca twoje jestestwo; dziś żaden wróg stacji nie ujdzie bez zrobustowania"
	glass_icon_state = "quadruple_sec"
	glass_name = "Quadruple Sec"
	glass_desc = "Groźny i praworządny napój rzuca ci wyzwanie, byś złamał prawo i sprawił mu przyjemność. Na służbie i tak nie można go pić."

/datum/reagent/consumable/ethanol/quadruple_sec/on_mob_life(mob/living/carbon/M)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(0.5 , 0.5)
		M.adjust_nutrition(-1)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/quintuple_sec
	name = "Quintuple Sec"
	description = "Prawo, porządek, alkohol i brutalność policji przedestylowane w jeden eliksir SPRAWIEDLIWOŚCI."
	color = "#ff3300"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_FANTASTIC
	taste_description = "THE LAW"
	glass_icon_state = "quintuple_sec"
	glass_name = "Quintuple Sec"
	glass_desc = "Teraz stałeś się prawem, niszczycielem klaunów."


/datum/reagent/consumable/ethanol/quintuple_sec/on_mob_life(mob/living/carbon/M)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes but STRONG..
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(1 , 1 , 1)
		M.adjust_nutrition(-2)//BECOME HONGRY
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/grasshopper
	name = "Grasshopper"
	description = "Świeży i słodki deserowy shot. Trudno wyglądać męsko, pijąc to."
	color = "#00ff00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "czekolada i mięta tańczące w ustach"
	glass_icon_state = "grasshopper"
	glass_name = "Grasshopper"
	glass_desc = "Nie wiedziałeś, że jadalne napoje mogą być tak zielone."

/datum/reagent/consumable/ethanol/stinger
	name = "Stinger"
	description = "Energiczny sposób na zakończenie dnia."
	color = "#ccff99"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "policzek w najlepszym możliwym wydaniu"
	glass_icon_state = "stinger"
	glass_name = "Stinger"
	glass_desc = "Zastanawiasz się, co by się stało, gdybyś skierował to na źródło ciepła..."

/datum/reagent/consumable/ethanol/bastion_bourbon
	name = "Bastion Bourbon"
	description = "Kojący, gorący napar ziołowy o właściwościach regenerujących. Nuty cytrusów i jagód."
	color = "#00FFFF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_FANTASTIC
	taste_description = "gorący napar ziołowy z nutą owoców"
	metabolization_rate = 2 * REAGENTS_METABOLISM //0.8u per tick
	glass_icon_state = "bastion_bourbon"
	glass_name = "Bastion Bourbon"
	glass_desc = "Jeśli masz doła, licz na maślany smak naszego bastion bourbonu."
	shot_glass_icon_state = "shotglassgreen"


/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_metabolize(mob/living/L)
	var/heal_points = 10
	if(L.health <= 0)
		heal_points = 20 //heal more if we're in softcrit
	for(var/i in 1 to min(volume, heal_points)) //only heals 1 point of damage per unit on add, for balance reasons
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)
		L.adjustToxLoss(-1)
		L.adjustOxyLoss(-1)
		L.adjustStaminaLoss(-1)
	L.visible_message("<span class='warning'>[L] drży z nowym wigorem!</span>", "<span class='notice'>Jeden łyk [lowertext(name)] napełnia cię energią!</span>")
	if(!L.stat && heal_points == 20) //brought us out of softcrit
		L.visible_message("<span class='danger'>[L] chwiejnie staje na nogi!</span>", "<span class='boldnotice'>Wstawaj i do roboty, mały.</span>")

/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_life(mob/living/L)
	if(L.health > 0)
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)
		L.adjustToxLoss(-0.5)
		L.adjustOxyLoss(-3)
		L.adjustStaminaLoss(-5)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/squirt_cider
	name = "Squirt Cider"
	description = "Sfermentowany ekstrakt z kałamarniczki o bukiecie czerstwego chleba i wody morskiej. Czymkolwiek jest kałamarniczka."
	color = "#FF0000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	taste_description = "czerstwy chleb z jeszcze czerstwszym posmakiem"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	glass_icon_state = "squirt_cider"
	glass_name = "Squirt Cider"
	glass_desc = "Cydr z kałamarniczki od razu cię zahartuje. Szkoda tego stęchłego posmaku."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/squirt_cider/on_mob_life(mob/living/carbon/M)
	M.satiety += 5 //for context, vitamins give 30 satiety per tick
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/fringe_weaver
	name = "Fringe Weaver"
	description = "Musujący, elegancki i bez wątpienia mocny - klasyk z Glitch City."
	color = "#FFEAC4"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90 //classy hooch, essentially, but lower pwr to make up for slightly easier access
	quality = DRINK_GOOD
	taste_description = "alkohol etylowy z nutą cukru"
	glass_icon_state = "fringe_weaver"
	glass_name = "Fringe Weaver"
	glass_desc = "Cud, że nie wylewa się ze szklanki."

/datum/reagent/consumable/ethanol/sugar_rush
	name = "Sugar Rush"
	description = "Słodki, lekki i owocowy - bardziej dziewczęcy być nie może."
	color = "#FF226C"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_GOOD
	taste_description = "cukier zatykający ci tętnice"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	glass_icon_state = "sugar_rush"
	glass_name = "Sugar Rush"
	glass_desc = "Jak nie umiesz zmiksować Sugar Rush, to nie nadajesz się na barmana."

/datum/reagent/consumable/ethanol/sugar_rush/on_mob_life(mob/living/carbon/M)
	M.satiety -= 10 //junky as hell! a whole glass will keep you from being able to eat junk food
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/crevice_spike
	name = "Crevice Spike"
	description = "Kwaśny, gorzki i zabójczo trzeźwiący. Nie trzeźwi osób o słabej głowie."
	color = "#5BD231"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = -10 //sobers you up - ideally, one would drink to get hit with brute damage now to avoid alcohol problems later
	quality = DRINK_VERYGOOD
	taste_description = "gorzki KOLEC z kwaśnym posmakiem"
	glass_icon_state = "crevice_spike"
	glass_name = "Crevice Spike"
	glass_desc = "Albo wybije z ciebie pijaństwo, albo cię znokautuje. Pewnie jedno i drugie."


/datum/reagent/consumable/ethanol/crevice_spike/on_mob_metabolize(mob/living/L) //damage only applies when drink first enters system and won't again until drink metabolizes out
	L.adjustBruteLoss(3 * min(5,volume)) //minimum 3 brute damage on ingestion to limit non-drink means of injury - a full 5 unit gulp of the drink trucks you for the full 15

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	description = "Słodkie wino ryżowe o wątpliwej legalności i ogromnej mocy."
	color = "#DDDDDD"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 70
	taste_description = "słodkie wino ryżowe"
	glass_icon_state = "sakecup"
	glass_name = "cup of sake"
	glass_desc = "Tradycyjna czarka sake."

/datum/reagent/consumable/ethanol/peppermint_patty
	name = "Peppermint Patty"
	description = "Ten lekko alkoholowy napój łączy zalety mentolu i kakao."
	color = "#45ca7a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "mięta i czekolada"
	boozepwr = 25
	quality = DRINK_GOOD
	glass_icon_state = "peppermint_patty"
	glass_name = "Peppermint Patty"
	glass_desc = "Mocno zaprawione miętowe kakao, które rozgrzewa brzuch w zimną noc."

/datum/reagent/consumable/ethanol/peppermint_patty/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/throat_soothed)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/ethanol/alexander
	name = "Alexander"
	description = "Nazwany na cześć greckiego bohatera; podobno wzmacnia tarczę pijącego, jakby stał w falandze."
	color = "#F5E9D3"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "gorzkie, kremowe kakao"
	glass_icon_state = "alexander"
	glass_name = "Alexander"
	glass_desc = "Kremowa, rozpustna rozkosz, mocniejsza, niż się wydaje."
	var/obj/item/shield/mighty_shield

/datum/reagent/consumable/ethanol/alexander/on_mob_metabolize(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/thehuman = L
		for(var/obj/item/shield/theshield in thehuman.contents)
			mighty_shield = theshield
			mighty_shield.block_power += 15
			to_chat(thehuman, "<span class='notice'>[theshield] wygląda na wypolerowaną, choć nie pamiętasz, byś ją polerował.</span>")
			return TRUE

/datum/reagent/consumable/ethanol/alexander/on_mob_life(mob/living/L)
	..()
	if(mighty_shield && !(mighty_shield in L.contents)) //If you had a shield and lose it, you lose the reagent as well. Otherwise this is just a normal drink.
		L.reagents.del_reagent(/datum/reagent/consumable/ethanol/alexander)

/datum/reagent/consumable/ethanol/alexander/on_mob_end_metabolize(mob/living/L)
	if(mighty_shield)
		mighty_shield.block_power -= 15
		to_chat(L,"<span class='notice'>Zauważasz, że [mighty_shield] znów wygląda na zużytą. Dziwne.</span>")
	..()

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	description = "Jedyna przejażdżka, przy której chętnie oddasz kierownicę."
	color = "#FFC55B"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "pyszna wolność"
	glass_icon_state = "sidecar"
	glass_name = "Sidecar"
	glass_desc = "Jedyna przejażdżka, przy której chętnie oddasz kierownicę."

/datum/reagent/consumable/ethanol/between_the_sheets
	name = "Between the Sheets"
	description = "Klasyk o prowokacyjnej nazwie. Co zabawne, lekarze zalecają go wypić przed drzemką."
	color = "#F4C35A"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "seduction"
	glass_icon_state = "between_the_sheets"
	glass_name = "Between the Sheets"
	glass_desc = "Jedyny drink z etykietą przypominającą o polityce zerowej tolerancji Nanotrasen wobec rozwiązłości."

/datum/reagent/consumable/ethanol/between_the_sheets/on_mob_life(mob/living/L)
	..()
	if(L.IsSleeping())
		if(L.getBruteLoss() && L.getFireLoss()) //If you are damaged by both types, slightly increased healing but it only heals one. The more the merrier wink wink.
			if(prob(50))
				L.adjustBruteLoss(-0.25)
			else
				L.adjustFireLoss(-0.25)
		else if(L.getBruteLoss()) //If you have only one, it still heals but not as well.
			L.adjustBruteLoss(-0.2)
		else if(L.getFireLoss())
			L.adjustFireLoss(-0.2)

/datum/reagent/consumable/ethanol/kamikaze
	name = "Kamikaze"
	description = "Boski wiatr."
	color = "#EEF191"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "boska wietrzność"
	glass_icon_state = "kamikaze"
	glass_name = "Kamikaze"
	glass_desc = "Boski wiatr."

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	description = "Drink, który wygląda równie orzeźwiająco, jak smakuje."
	color = "#DFFAD9"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "orzeźwiająca mięta"
	glass_icon_state = "mojito"
	glass_name = "Mojito"
	glass_desc = "Drink, który wygląda równie orzeźwiająco, jak smakuje."

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	description = "Niezwykle gorzki likier ziołowy używany jako digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 80
	taste_description = "totalna gorycz"
	glass_name = "glass of fernet"
	glass_desc = "Szklanka czystego Fernetu. Tylko kompletny szaleniec piłby to bez niczego." //Hi Kevum

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/carbon/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(1*REM, 0)
	M.adjust_nutrition(-5)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fernet_cola
	name = "Fernet Cola"
	description = "Bardzo popularny, gorzko-słodki digestif, idealny po ciężkim posiłku. Według tradycji najlepiej podawany w obciętej butelce po coli."
	color = "#390600" // rgb: 57, 6,
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "słodka ulga"
	glass_icon_state = "godlyblend"
	glass_name = "glass of fernet cola"
	glass_desc = "Obcięta butelka po coli wypełniona Fernetem z colą. Nie ma nic lepszego po obżarciu się jak świnia."

/datum/reagent/consumable/ethanol/fernet_cola/on_mob_life(mob/living/carbon/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.5*REM, 0)
	M.adjust_nutrition(- 3)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli

	name = "Fanciulli"
	description = "A gdyby koktajl Manhattan NAPRAWDĘ zawierał gorzki likier ziołowy? Pomaga wytrzeźwieć. Nie trzeźwi osób o słabej głowie." //also causes a bit of stamina damage to symbolize the afterdrink lazyness
	color = "#CA933F" // rgb: 202, 147, 63
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = -10
	quality = DRINK_NICE
	taste_description = "słodka, trzeźwiąca mieszanka"
	glass_icon_state = "fanciulli"
	glass_name = "glass of fanciulli"
	glass_desc = "Szklanka Fanciulli. To po prostu Manhattan z Fernetem."

/datum/reagent/consumable/ethanol/fanciulli/on_mob_life(mob/living/carbon/M)
	M.adjust_nutrition(-5)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli/on_mob_metabolize(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(20)
		. = TRUE
	..()


/datum/reagent/consumable/ethanol/branca_menta
	name = "Branca Menta"
	description = "Orzeźwiająca mieszanka gorzkiego Fernetu z likierem miętowym."
	color = "#4B5746" // rgb: 75, 87, 70
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "gorzka świeżość"
	glass_icon_state= "minted_fernet"
	glass_name = "glass of branca menta"
	glass_desc = "Szklanka Branca Menta, idealna na leniwe, upalne letnie niedzielne popołudnia." //Get lazy literally by drinking this


/datum/reagent/consumable/ethanol/branca_menta/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C)
	return ..()

/datum/reagent/consumable/ethanol/branca_menta/on_mob_metabolize(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(35)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/blank_paper
	name = "Blank Paper"
	description = "Bąbelkująca szklanka czystej kartki. Samo patrzenie na nią odświeża."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#DCDCDC" // rgb: 220, 220, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 20
	quality = DRINK_GOOD
	taste_description = "bąbelkujące możliwości"
	glass_icon_state = "blank_paper"
	glass_name = "glass of blank paper"
	glass_desc = "Musujący koktajl dla tych, którzy chcą zacząć od nowa."


/datum/reagent/consumable/ethanol/blank_paper/on_mob_life(mob/living/carbon/M)
	M.silent = max(M.silent, MIMEDRINK_SILENCE_DURATION)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.heal_bodypart_damage(1,1)
		. = 1
	return ..()

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	description = "Wino z uprawianych roślin."
	color = "#FFFFFF"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "bad coding"
	var/list/names = list("null fruit" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("bad coding" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	names = data["names"]
	tastes = data["tastes"]
	boozepwr = data["boozepwr"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	boozepwr *= oldvolume
	var/newzepwr = data["boozepwr"] * amount
	boozepwr += newzepwr
	boozepwr /= volume //Blending boozepwr to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	//BYOND compiler bug means this must be an explicit constant
	var/const/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	glass_name = "glass of [name]"
	glass_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "wine"
	else
		name = "mixed [names_in_order[1]] wine"

	var/alcohol_description
	switch(boozepwr)
		if(120 to INFINITY)
			alcohol_description = "samobójczo mocne"
		if(90 to 120)
			alcohol_description = "dość mocne"
		if(70 to 90)
			alcohol_description = "strong"
		if(40 to 70)
			alcohol_description = "rich"
		if(20 to 40)
			alcohol_description = "mild"
		if(0 to 20)
			alcohol_description = "sweet"
		else
			alcohol_description = "watery" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "inne rośliny"
	var/fruit_list = english_list(fruits)
	description = "Wino ([alcohol_description]) uwarzone z: [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", z nutą: "
		flavor += english_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()


/datum/reagent/consumable/ethanol/champagne //How the hell did we not have champagne already!?
	name = "Champagne"
	description = "Musujące wino znane z tego, że uderza szybko i mocno."
	color = "#ffffc1"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 40
	taste_description = "pomyślne okazje i złe decyzje"
	glass_icon_state = "champagne_glass"
	glass_name = "Champagne"
	glass_desc = "W kieliszku wyraźnie widać powoli unoszące się bąbelki."


/datum/reagent/consumable/ethanol/wizz_fizz
	name = "Wizz Fizz"
	description = "Magiczny eliksir, musujący i dziki! Lecz smak jego, przekonasz się, jest całkiem łagodny."
	color = "#4235d0" //Just pretend that the triple-sec was blue curacao.
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "przyjaźń! To w końcu magia"
	glass_icon_state = "wizz_fizz"
	glass_name = "Wizz Fizz"
	glass_desc = "Szklanka bulgocze i pieni się z niemal magiczną intensywnością."

/datum/reagent/consumable/ethanol/wizz_fizz/on_mob_life(mob/living/carbon/M)
	//A healing drink similar to Quadruple Sec, Ling Stings, and Screwdrivers for the Wizznerds; the check is consistent with the changeling sting
	if(M?.mind?.has_antag_datum(/datum/antagonist/wizard))
		M.heal_bodypart_damage(1,1,1)
		M.adjustOxyLoss(-1,0)
		M.adjustToxLoss(-1,0)
	return ..()

/datum/reagent/consumable/ethanol/bug_spray
	name = "Bug Spray"
	description = "Ostry, cierpki, gorzki drink dla tych, którzy muszą się na coś przygotować."
	color = "#33ff33"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "ból dziesięciu tysięcy zabitych komarów"
	glass_icon_state = "bug_spray"
	glass_name = "Bug Spray"
	glass_desc = "Oczy zaczynają ci łzawić, gdy dociera do nich szczypiący alkohol."

/datum/reagent/consumable/ethanol/bug_spray/on_mob_life(mob/living/carbon/M)
//Bugs should not drink Bug spray.
	if(ismoth(M) || isflyperson(M))
		M.adjustToxLoss(1,0)
	return ..()
/datum/reagent/consumable/ethanol/bug_spray/on_mob_metabolize(mob/living/carbon/M)

	if(ismoth(M) || isflyperson(M))
		M.emote("scream")
	return ..()


/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	description = "Idealny napój, gdy masz ochotę się wygłupiać jak koń."
	color = "#ff6633"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "uczciwy dzień pracy w sadzie"
	glass_icon_state = "applejack_glass"
	glass_name = "Applejack"
	glass_desc = "Masz wrażenie, że mógłbyś to pić przez całą noc."

/datum/reagent/consumable/ethanol/jack_rose
	name = "Jack Rose"
	description = "Lekki koktajl idealny do sączenia z kawałkiem ciasta."
	color = "#ff6633"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 15
	quality = DRINK_NICE
	taste_description = "słodko-kwaśny plasterek jabłka"
	glass_icon_state = "jack_rose"
	glass_name = "Jack Rose"
	glass_desc = "Po wystarczającej liczbie tych zaczniesz naprawdę myśleć, że twoje palce u stóp to róże."

/datum/reagent/consumable/ethanol/turbo
	name = "Turbo"
	description = "Burzliwy koktajl kojarzony z nielegalnymi wyścigami poduszkowców. Nie dla ludzi o słabych nerwach."
	color = "#e94c3a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 85
	quality = DRINK_VERYGOOD
	taste_description = "duch wyjętego spod prawa"
	glass_icon_state = "turbo"
	glass_name = "Turbo"
	glass_desc = "Burzliwy koktajl dla wyjętych spod prawa motocyklistów poduszkowych."

/datum/reagent/consumable/ethanol/turbo/on_mob_life(mob/living/carbon/M)
	if(prob(4))
		to_chat(M, "<span class='notice'>[pick("You feel disregard for the rule of law.", "You feel pumped!", "Your head is pounding.", "Your thoughts are racing..")]</span>")
	M.adjustStaminaLoss(-M.drunkenness * 0.25)
	return ..()

/datum/reagent/consumable/ethanol/old_timer
	name = "Old Timer"
	description = "Archaiczny trunek, którym delektują się starzy dziwacy w każdym wieku."
	color = "#996835"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "prostsze czasy"
	glass_icon_state = "old_timer"
	glass_name = "Old Timer"
	glass_desc = "OSTRZEŻENIE! Może powodować przedwczesne starzenie!"

/datum/reagent/consumable/ethanol/old_timer/on_mob_life(mob/living/carbon/M)
	if(prob(20))
		if(ishuman(M))
			var/mob/living/carbon/human/N = M
			N.age += 1
			if(N.age > 70)
				N.facial_hair_color = "ccc"
				N.hair_color = "ccc"
				N.update_hair()
				if(N.age > 100)
					N.become_nearsighted(type)
					if(N.gender == MALE)
						N.facial_hair_style = "Beard (Very Long)"
						N.update_hair()

				if(N.age > 969) //Best not let people get older than this or i might incur G-ds wrath
					M.visible_message("<span class='notice'>[M] staje się starszy, niż jakikolwiek człowiek powinien być... i rozsypuje się w proch!</span>")
					M.dust(0,1,0)

	return ..()

/datum/reagent/consumable/ethanol/rubberneck
	name = "Rubberneck"
	description = "Porządny rubberneck nie powinien zawierać żadnych obrzydliwych naturalnych składników."
	color = "#ffe65b"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "sztuczna owocowość"
	glass_icon_state = "rubberneck"
	glass_name = "Rubberneck"
	glass_desc = "Popularny drink wśród zwolenników całkowicie syntetycznej diety."

/datum/reagent/consumable/ethanol/duplex
	name = "Duplex"
	description = "Nierozłączne połączenie dwóch owocowych napojów."
	color = "#50e5cf"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "zielone jabłka i niebieskie maliny"
	glass_icon_state = "duplex"
	glass_name = "Duplex"
	glass_desc = "Picie jednego składnika osobno od drugiego uważa się za wielką gafę."

/datum/reagent/consumable/ethanol/trappist
	name = "Trappist Beer"
	description = "Mocne ciemne ale warzone przez kosmicznych mnichów."
	color = "#390c00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "suszone śliwki i słód"
	glass_icon_state = "trappistglass"
	glass_name = "Trappist Beer"
	glass_desc = "zaprawiony katolicyzm w szklance."

/datum/reagent/consumable/ethanol/trappist/on_mob_life(mob/living/carbon/M)
	if(M.mind?.holy_role)
		M.adjustFireLoss(-2.5, 0)
		M.jitteriness = max(0, M.jitteriness-1)
		M.stuttering = max(0, M.stuttering-1)
	return ..()

/datum/reagent/consumable/ethanol/blazaam
	name = "Blazaam"
	description = "Dziwny drink, o którego istnieniu mało kto pamięta. Służy też jako zmywacz Berenstainów."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY // don't put CHEMICAL_GOAL_BARTENDER_SERVING. peach juice is totally RNG to get
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "alternatywne rzeczywistości"
	glass_icon_state = "blazaamglass"
	glass_name = "Blazaam"
	glass_desc = "Szklanka zdaje się przesuwać między rzeczywistościami. Służy też jako zmywacz Berenstainów."

	var/stored_teleports = 0

/datum/reagent/consumable/ethanol/blazaam/on_mob_life(mob/living/carbon/M)
	if(M.drunkenness > 40)
		if(stored_teleports)
			do_teleport(M, get_turf(M), rand(1,3), channel = TELEPORT_CHANNEL_WORMHOLE)
			stored_teleports--
		if(prob(10))
			stored_teleports += rand(2,6)
			if(prob(70))
				M.vomit()
	return ..()


/datum/reagent/consumable/ethanol/planet_cracker
	name = "Planet Cracker"
	description = "Ten radosny drink świętuje triumf ludzkości nad obcym zagrożeniem. Może urazić nieludzkich członków załogi."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "triumf z nutą goryczy"
	glass_icon_state = "planet_cracker"
	glass_name = "Planet Cracker"
	glass_desc = "Choć historycy uważają, że drink powstał, by upamiętnić koniec ważnego konfliktu w przeszłości ludzkości, jego pochodzenie w dużej mierze zapomniano i dziś uchodzi raczej za ogólny symbol ludzkiej supremacji."

/datum/reagent/consumable/ethanol/mauna_loa
	name = "Mauna Loa"
	description = "Niezwykle ostry; nie dla ludzi o słabych nerwach!"
	boozepwr = 40
	color = "#fe8308" // 254, 131, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_FANTASTIC
	taste_description = "ognisty, z posmakiem spalonego ciała"
	glass_icon_state = "mauna_loa"
	glass_name = "Mauna Loa"
	glass_desc = "Lavaland w drinku... kuflu... wulkanie... czymś."


/datum/reagent/consumable/ethanol/mauna_loa/on_mob_life(mob/living/carbon/M)
	// Heats the user up while the reagent is in the body. Occasionally makes you burst into flames.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT)
	if (prob(5))
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	..()

/datum/reagent/consumable/ethanol/painkiller
	name = "Painkiller"
	description = "Tępi ból. Emocjonalny ból, ma się rozumieć."
	boozepwr = 20
	color = "#EAD677"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_NICE
	taste_description = "słodka cierpkość"
	glass_icon_state = "painkiller"
	glass_name = "Painkiller"
	glass_desc = "Połączenie tropikalnych soków i rumu. Na pewno poczujesz się po tym lepiej."

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	description = "Świeży napój ananasowy z rumem kokosowym. Mniam."
	boozepwr = 40
	color = "#FFF1B2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_FANTASTIC
	taste_description = "ananas, kokos i nuta oceanu"
	glass_icon_state = "pina_colada"
	glass_name = "Pina Colada"
	glass_desc = "Jeśli lubisz piña coladę i łapanie deszczu... cóż, polubisz ten drink."

/datum/reagent/consumable/ethanol/plasmaflood
	name = "Plasma Flood"
	description = "Z oczywistych powodów niezbyt popularny wśród plazmoludzi."
	color = "#630480" // rgb: 99, 4, 128
	chem_flags = NONE
	boozepwr = 60
	quality = DRINK_NICE
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "plazmowy pożar w ustach"
	glass_icon_state = "plasmaflood"
	glass_name = "Plasma Flood"
	glass_desc = "Ulubieniec szarej fali. Na ironię, podczas picia nie zaleca się stania w plazmie."

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_metabolize(mob/living/L)
	to_chat(L, "<span class='notice'>Czujesz się odporny na ogień!</span>")
	. = ..()

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_life(mob/living/M)
	if(prob(80))
		M.IgniteMob()
		M.adjust_fire_stacks(10)

	if(M.fire_stacks > 9)
		if(M.on_fire)
			M.adjustFireLoss(-16, 0)

	..()

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_end_metabolize(mob/living/L)
	to_chat(L, "<span class='warning'>Nie czujesz się już odporny na płomienie!</span>")
	. = ..()

/datum/reagent/consumable/ethanol/fourthwall
	name = "Fourth Wall"
	description = "Ta substancja wygląda na coś, co nie powinno istnieć."
	color = "#0b43a3"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //I feel like brain traumas is enough
	quality = DRINK_GOOD
	metabolization_rate = 0.3
	taste_description = "binary"
	glass_icon_state = "fourthwallglass"
	glass_name = "Fourth Wall"
	glass_desc = "Samo patrzenie na to przyprawia o ból głowy."
	var/list/trauma_list

/datum/reagent/consumable/ethanol/fourthwall/proc/traumaweightpick(var/mild,var/severe,var/special)
	return pick(pickweight(list(subtypesof(/datum/brain_trauma/mild) = mild, subtypesof(/datum/brain_trauma/severe) - /datum/brain_trauma/severe/split_personality - /datum/brain_trauma/severe/hypnotic_stupor = severe, subtypesof(/datum/brain_trauma/special) - /datum/brain_trauma/special/imaginary_friend = special)))

/datum/reagent/consumable/ethanol/fourthwall/on_mob_metabolize(mob/living/carbon/M)
	trauma_list = list()
	to_chat(M, "<span class='warning'>Twój umysł pęka, gdy uświadamiasz sobie, że twoja rzeczywistość to tylko jakaś gra komputerowa.</span>")
	var/datum/brain_trauma/trauma = traumaweightpick(60,40,0)
	trauma = new trauma()
	trauma_list += trauma
	M.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/consumable/ethanol/fourthwall/on_mob_life(mob/living/carbon/M)
	var/datum/brain_trauma/OD_trauma
	M.Jitter(2)
	if(prob(5) && current_cycle > 10)
		switch(current_cycle) //The longer they're on this stuff, the higher the chance for worse brain trauma
			if(10 to 50)
				to_chat(M, "<span class='warning'>Twój umysł pęka.</span>")
				OD_trauma = traumaweightpick(50,40,10)
			if(50 to 100)
				to_chat(M, "<span class='warning'>Twój umysł się rozszczepia.</span>")
				OD_trauma = traumaweightpick(30,50,20)
			if(100 to INFINITY)
				to_chat(M, "<span class='warning'>Twój umysł się roztrzaskuje.</span>")
				OD_trauma = traumaweightpick(20,50,30)
		OD_trauma = new OD_trauma()
		trauma_list += OD_trauma
		M.gain_trauma(OD_trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/consumable/ethanol/fourthwall/on_mob_end_metabolize(mob/living/carbon/M)
	to_chat(M, "<span class='notice'>Wiesz, że odkryłeś coś ważnego, ale nie możesz sobie przypomnieć co. Głowa boli cię znacznie mniej.</span>")
	for(var/T in trauma_list)
		QDEL_NULL(T)
	return ..()

/datum/reagent/consumable/ethanol/ratvander
	name = "Rat'vander Cocktail"
	description = "Skutki uboczne obejmują chomikowanie mosiądzu i nienawiść do krwi."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "słodki mosiądz"
	glass_icon_state = "ratvander"
	glass_name = "Rat'vander Cocktail"
	glass_desc = "Nowy koktajl, pierwotnie zmiksowany przez TRNE Corp. Podobno nasycony pradawną magią."


/datum/reagent/consumable/ethanol/ratvander/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		to_chat(M, "<span class = 'warning'>[pick("You can faintly hear the sound of gears.","You can feel an unnatural hatred towards exposed blood.","You swear you can feel steam eminating from the drink.","You hear faint, pleasant whispers.","You can see a white void within your mind.")]</span>")
	M.clockslurring = min(M.clockslurring + 3, 3)
	M.stuttering = min(M.stuttering + 3, 3)
	..()
	. = 1

/datum/reagent/consumable/ethanol/icewing
	name = "Icewing"
	description = "Promień mrozu na lodzie."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "frostburn"
	glass_icon_state = "icewing"
	glass_name = "Icewing"
	glass_desc = "Ulubiony drink łowców obserwatorów. Uleczy odmrożenia albo cię schłodzi."


/datum/reagent/consumable/ethanol/icewing/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(M.bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT) //heals burn if freezing
		M.adjustFireLoss(-5, 0)
	..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset
	name = "Sarsaparillian Sunset"
	description = "Smak pustkowi."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "przyjemne pieczenie"
	glass_icon_state = "sarsaparilliansunset"
	glass_name = "Sarsaparillian Sunset"
	glass_desc = "Widok zachodu słońca nad napromieniowanym pustkowiem. Koi oparzenia, ale nie pij za dużo."
	var/power = /obj/effect/proc_holder/spell/aimed/firebreath/weak
	overdose_threshold = 50
	metabolization_rate = 0.5

/datum/reagent/consumable/ethanol/sarsaparilliansunset/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-3, 0)
	..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/overdose_start(mob/living/M)
	to_chat(M, "<span class='warning'>Czujesz żar w brzuchu, który pali cię od środka!</span>")
	power = new power()
	M.AddSpell(power)
	. = ..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/overdose_process(mob/living/M)
	M.adjustFireLoss(7, 0)
	. = ..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/on_mob_end_metabolize(mob/living/M)
	to_chat(M, "<span class='notice'>Ogień w tobie się uspokaja.</span>")
	M.RemoveSpell(power)
	return ..()

/obj/effect/proc_holder/spell/aimed/firebreath/weak
	name = "Fire Upchuck"
	desc = "You can feel heat rising from your stomach"
	range = 20
	charge_max = 300
	projectile_type = /obj/item/projectile/magic/fireball/firebreath/weak

/obj/item/projectile/magic/fireball/firebreath/weak
	exp_fire = 1

/datum/reagent/consumable/ethanol/beesknees
	name = "Bee's Knees"
	description = "Tu jest zdecydowanie za dużo miodu."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	chem_flags = NONE
	boozepwr = 35
	quality = 0
	taste_description = "słodszy miód pitny"
	glass_icon_state = "beesknees"
	glass_name = "Bee's Knees"
	glass_desc = "Z tej szklanki aż ścieka miód. Trochę za dużo miodu, by kusiło kogokolwiek poza pewnym owadem."

/datum/reagent/consumable/ethanol/beesknees/on_mob_metabolize(mob/living/M)
	if(is_species(M, /datum/species/apid))
		to_chat(M, "<span class='notice'>Co za dobry drink! Przypomina miód z domu.</span>")
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)
	else
		to_chat(M, "<span class='warning'>Ten drink był zdecydowanie za słodki! Robi ci się niedobrze.</span>")
		M.adjust_disgust(10)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
	. = ..()

/datum/reagent/consumable/ethanol/beesknees/on_mob_life(mob/living/carbon/M)
	if(is_species(M, /datum/species/apid))
		M.adjustBruteLoss(-1.5, 0)
		M.adjustFireLoss(-1.5, 0)
		M.adjustToxLoss(-1, 0)
	. = ..()

/datum/reagent/consumable/ethanol/beeffizz
	name = "Beef Fizz"
	description = "To wołowy napój gazowany, WOŁOWY NAPÓJ GAZOWANY, NIE MA BOGA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 15
	quality = DRINK_BAD
	taste_description = "Ładny i słony niegazowany sok wołowy z odrobiną cytryny"
	glass_icon_state = "beef_fizz"
	glass_name = "Beef Fizz"
	glass_desc = "KTO UZNAŁ, ŻE TO DOBRY POMYSŁ??"


/datum/reagent/consumable/beeffizz/on_mob_metabolize(mob/living/M)
	to_chat(M, "<span class='warning'>Ten drink był zdecydowanie za wołowy! Robi ci się niedobrze.</span>")
	M.adjust_disgust(30)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
	. = ..()

//NSV13
/datum/reagent/consumable/ethanol/torp_juice
        name = "Torpedo Juice"
        color = "#F9E43D"
        description = "Uwaga, dział uzbrojenia: ROBIĆ TORPEDĘ."
        taste_description = "eksplozja w ustach"
        glass_icon_state = "torp_juice"
        glass_name = "glass of torpedo juice"
        glass_desc = "Uwaga, dział uzbrojenia: ROBIĆ TORPEDĘ."
        quality = DRINK_VERYGOOD
        boozepwr = 70

/datum/reagent/consumable/ethanol/torp_juice/on_mob_life(mob/living/carbon/M)
    if(HAS_TRAIT(M.mind, TRAIT_MUNITIONS_METABOLISM))
        M.heal_bodypart_damage(1, 1)
        M.adjustBruteLoss(-2,0)
        . = 1
    return ..()
