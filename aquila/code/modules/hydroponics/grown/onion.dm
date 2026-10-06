// Krojenie cebuli bez osłony oczu wyciska łzy (port Yogstation#15690)
/obj/item/reagent_containers/food/snacks/grown/onion/slice(accuracy, obj/item/W, mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!L.is_eyes_covered())
			user.emote("cry")
	. = ..()
