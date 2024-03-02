// z góry przepraszam, nie umiem into gramatyka bardziej niż na czuja -huusk

/mob/proc/p_jego(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "jego"
	switch(temp_gender)
		if(FEMALE)
			. = "jej"
		if(MALE)
			. = "jego"
		if(PLURAL)
			. = "ich"
	if(capitalized)
		. = capitalize(.)

/mob/proc/p_je(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "je"
	switch(temp_gender)
		if(FEMALE)
			. = "ją"
		if(MALE)
			. = "go"
		if(PLURAL)
			. = "ich"
	if(capitalized)
		. = capitalize(.)

