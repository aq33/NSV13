//Taste defines
#define NO_TASTE_SENSITIVITY -1
#define DEFAULT_TASTE_SENSITIVITY 15 

/mob/living
	var/last_taste_time
	var/last_taste_text

/mob/living/proc/get_taste_sensitivity()
	return DEFAULT_TASTE_SENSITIVITY

/mob/living/carbon/get_taste_sensitivity()
	var/obj/item/organ/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(istype(tongue) && !HAS_TRAIT(src, TRAIT_AGEUSIA))
		. = tongue.taste_sensitivity
	else
		. = NO_TASTE_SENSITIVITY // can't taste anything without a tongue

// non destructively tastes a reagent container
/mob/living/proc/taste(datum/reagents/from)
	if(last_taste_time + 50 < world.time)
		var/taste_sensitivity = get_taste_sensitivity()
		var/text_output = from.generate_taste_message(taste_sensitivity)
		// We dont want to spam the same message over and over again at the
		// person. Give it a bit of a buffer.
		if(hallucination > 50 && prob(25))
			text_output = pick("pająki","sny","koszmary","przyszłość","przeszłość","zwycięstwo",\
			"porażka","ból","błogość","zemsta","trucizna","czas","kosmos","śmierć","życie","prawda","kłamstwa","sprawiedliwość","pamięć",\
			"żal","twoja dusza","cierpienie","muzyka","hałas","krew","głód","amerykański styl życia")
		if((text_output != last_taste_text || last_taste_time + 100 < world.time) && (taste_sensitivity != NO_TASTE_SENSITIVITY))
			to_chat(src, "<span class='notice'>Czujesz smak: [text_output].</span>")
			// "something indescribable" -> too many tastes, not enough flavor.

			last_taste_time = world.time
			last_taste_text = text_output

#undef DEFAULT_TASTE_SENSITIVITY
