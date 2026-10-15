/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viraladaptation
	name = "Viral Self-Adaptation"
	desc = "Wirus naśladuje działanie normalnych komórek ciała, przez co trudniej go wykryć i zwalczyć, ale wolniej się rozwija. Ten objaw zniechęca do mutacji choroby"
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmission = 0
	level = 4
	prefixes = list("Chronic ")

/datum/symptom/viraladaptation/OnAdd(datum/disease/advance/A)
	A.mutability -= 0.5

/datum/symptom/viraladaptation/OnRemove(datum/disease/advance/A)
	A.mutability += 0.5

/*
//////////////////////////////////////
Viral evolution

	Moderate stealth reductopn.
	Major decreases to resistance.
	increases stage speed.
	increase to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viralevolution
	name = "Viral Evolutionary Acceleration"
	desc = "Wirus szybko przystosowuje się do jak najszybszego rozprzestrzeniania się zarówno na zewnątrz, jak i wewnątrz nosiciela. Przez to jednak łatwiej go wykryć i gorzej broni się przed lekarstwem. Ten objaw sprzyja mutacji choroby"
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmission = 3
	level = 4
	prefixes = list("Unstable ")

/datum/symptom/viralevolution/OnAdd(datum/disease/advance/A)
	A.mutability += 2

/datum/symptom/viralevolution/OnRemove(datum/disease/advance/A)
	A.mutability -= 1

/*
//////////////////////////////////////

Viral aggressive metabolism

	Somewhat increased stealth.
	Abysmal resistance.
	Increased stage speed.
	Poor transmitability.
	Medium Level.

Bonus
	The virus starts at stage 5, but after a certain time will start curing itself.
	Stages still increase naturally with stage speed.

//////////////////////////////////////
*/

/datum/symptom/viralreverse

	name = "Viral Aggressive Metabolism"
	desc = "Wirus poświęca długoterminową przeżywalność, by niemal natychmiast w pełni rozprzestrzenić się w nosicielu. Zaczyna od ostatniego stadium, ale w końcu sam zanika i obumiera."
	stealth = 1
	resistance = 1
	stage_speed = 3
	transmission = -4
	level = 4
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Spontaneous ")
	var/time_to_cure
	threshold_desc = "<b>Odporność/Szybkość stadiów:</b> wyższa z tych wartości określa czas do samowyleczenia.<br><b>Ukrycie 4</b> podwaja czas do samowyleczenia wirusa"


/datum/symptom/viralreverse/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(time_to_cure > 0)
		time_to_cure--
	else
		var/mob/living/M = A.affected_mob
		Heal(M, A)

/datum/symptom/viralreverse/proc/Heal(mob/living/M, datum/disease/advance/A)
	A.stage -= 1
	if(A.stage < 2)
		to_chat(M, "<span class='notice'>Nagle czujesz się zdrowy.</span>")
		A.cure(FALSE) //Doesn't Add Resistance. Virology can now make potions for stuff, be it healing the senses or making people explode

/datum/symptom/viralreverse/Start(datum/disease/advance/A)
	if(!..())
		return
	A.stage = 5
	if(A.stealth >= 4) //more time before it's cured
		power = 2
	time_to_cure = max(A.resistance, A.stage_rate) * 10 * power

/*
//////////////////////////////////////

Viral Suspended Animation

	Very high stealth.
	Abysmal resistance.
	Poor stage speed.
	Decent transmitability.
	Medium Level.

Bonus
	The virus does not start until stage 5

//////////////////////////////////////
*/

/datum/symptom/viralincubate
	name = "Viral Suspended Animation"
	desc = "Wirus ma bardzo słabe działanie, dopóki nie osiągnie ostatniego stadium"
	stealth = 4
	resistance = -2
	stage_speed = -2
	transmission = 1
	level = 4
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Asymptomatic ")
	var/list/captives = list()
	var/used = FALSE

/datum/symptom/viralincubate/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage >= 5)
		for(var/datum/symptom/S as() in captives)
			S.stopped = FALSE
			captives -= S
		if(!LAZYLEN(captives))
			stopped = TRUE
	else if(!used)
		for(var/datum/symptom/S as() in A.symptoms)
			if(S.neutered)
				continue
			if(S == src)
				continue
			S.stopped = TRUE
			captives += S
		used = TRUE
	

/*
//////////////////////////////////////

Viral power multiplier

	Average stats
	UNOBTAINABLE- THIS SYMPTOM IS FOR ADMINBUS OR WEIRD CRAZY SHIT. You can enable it if you like, but be warned that this symptom is potentially very abusable

Bonus
	All unneutered symptoms in the virus have their power boosted

//////////////////////////////////////
*/
/datum/symptom/viralpower
	name = "Viral power multiplier"
	desc = "Wirus ma silniejsze objawy. Może mieć nieprzewidywalne skutki"
	stealth = 2
	resistance = 2
	stage_speed = 2
	transmission = 2
	level = -1 //currently unobtainable except by adminbus
	prefixes = list("Super", "Mega", "Admin ")
	var/maxpower
	var/powerbudget
	var/scramble = FALSE 
	var/used = FALSE
	threshold_desc = "<b>Transmisja 8:</b> nieustannie miesza moc wszystkich niezneutralizowanych objawów.<br><b>Szybkość stadiów 8</b> podwaja wzmocnienie mocy"


/datum/symptom/viralpower/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.speed >= 8)
		power = 2
	if(A.transmission >= 8)
		scramble = TRUE

/datum/symptom/viralpower/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(!used)
		for(var/datum/symptom/S as() in A.symptoms)
			if(S.neutered)
				continue
			if(S == src)
				return
			S.power += power
			maxpower += S.power 
		if(scramble)
			powerbudget += power 
			maxpower += power 
			power = 0
		used = TRUE
	if(scramble)
		var/datum/symptom/S = pick(A.symptoms)
		if(S == src)
			return
		if(S.neutered)
			return
		if(powerbudget && (prob(50) || powerbudget == maxpower))
			S.power += 1
			powerbudget -= 1
		else if(S.power >= 2)
			S.power -= 1
			powerbudget += 1

