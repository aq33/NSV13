/datum/symptom/undead_adaptation
	name = "Necrotic Metabolism"
	desc = "Wirus potrafi rozwijać się i działać nawet w martwych nosicielach."
	stealth = 2
	resistance = 2
	stage_speed = 2
	transmission = 0
	level = 4
	severity = 0
	prefixes = list("Zombie ")

/datum/symptom/undead_adaptation/OnAdd(datum/disease/advance/A)
	A.process_dead = TRUE
	A.infectable_biotypes |= MOB_UNDEAD

/datum/symptom/undead_adaptation/OnRemove(datum/disease/advance/A)
	A.process_dead = FALSE
	A.infectable_biotypes -= MOB_UNDEAD

/datum/symptom/inorganic_adaptation
	name = "Inorganic Biology"
	desc = "Wirus potrafi przetrwać i namnażać się nawet w środowisku nieorganicznym, zwiększając swoją odporność i zaraźliwość."
	stealth = -1
	resistance = 4
	stage_speed = -2
	transmission = 3
	level = 4
	severity = 0
	prefixes = list("Crystalline ")


/datum/symptom/inorganic_adaptation/OnAdd(datum/disease/advance/A)
	A.infectable_biotypes |= MOB_INORGANIC

/datum/symptom/inorganic_adaptation/OnRemove(datum/disease/advance/A)
	A.infectable_biotypes -= MOB_INORGANIC
