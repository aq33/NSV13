// Pomocnicze procki do tłumaczeń na polski.

/// Zwraca formę zależną od rodzaju gramatycznego: plec(user, "zrobił", "zrobiła").
/// Brak formy nijakiej lub mnogiej = forma męska.
/proc/plec(atom/target, male, female, neuter, plural)
	switch(target?.gender)
		if(FEMALE)
			return female
		if(NEUTER)
			return isnull(neuter) ? male : neuter
		if(PLURAL)
			return isnull(plural) ? male : plural
	return male

/// Czasownik ataku gatunku (attack_verb, klucz po angielsku) w 3. osobie: "[user] [attack_verb_pl(verb)] [cel]".
/proc/attack_verb_pl(verb)
	switch(verb)
		if("punch")
			return "uderza"
		if("kick")
			return "kopie"
		if("smash")
			return "miażdży"
		if("claw")
			return "drapie"
		if("slash")
			return "tnie"
		if("bite")
			return "gryzie"
		if("burn")
			return "parzy"
		if("honk")
			return "trąbi na"
		if("whips")
			return "smaga"
		if("bluespace punch")
			return "uderza bluespace'owym ciosem"
		if("monopoliz")
			return "monopolizuje"
		if("nationaliz")
			return "nacjonalizuje"
	return "uderza"

/// Polska nazwa poziomu alarmu (get_security_level() zwraca klucze po angielsku).
/proc/get_security_level_pl()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "stan 3"
		if(SEC_LEVEL_BLUE)
			return "stan 2"
		if(SEC_LEVEL_RED)
			return "alarm bojowy"
		if(SEC_LEVEL_ZEBRA)
			return "stan Zebra"
		if(SEC_LEVEL_DELTA)
			return "delta"
