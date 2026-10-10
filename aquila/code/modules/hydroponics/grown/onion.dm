// Krojenie cebuli bez osłony oczu wyciska łzy (port Yogstation#15690)
/obj/item/food/grown/onion/UsedforProcessing(mob/living/user, obj/item/I, list/chosen_option)
	if(isliving(user))
		var/mob/living/L = user
		if(!L.is_eyes_covered())
			user.emote("cry")
	. = ..()
