// Ogień, iskry i dym z płonącego ogniska (port z Yogstation).

/obj/structure/bonfire/StartBurning()
	. = ..()
	if(burning)
		add_emitter(/obj/emitter/fire, "fire")
		add_emitter(/obj/emitter/sparks/fire, "fire_spark")
		add_emitter(/obj/emitter/fire_smoke, "smoke", 9)

/obj/structure/bonfire/extinguish()
	. = ..()
	if(!burning)
		remove_emitter("fire")
		remove_emitter("fire_spark")
		remove_emitter("smoke")
