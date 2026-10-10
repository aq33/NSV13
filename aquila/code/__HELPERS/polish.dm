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
