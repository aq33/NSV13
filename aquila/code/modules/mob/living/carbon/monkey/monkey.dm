
/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	if(mind && is_monkey(mind))
		return TRUE
	return FALSE
