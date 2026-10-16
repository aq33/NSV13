/obj/structure/closet/secure_closet/engineering_personal/PopulateContents()
	..()
	new /obj/item/energy_harvester(src)

// Atlas nie ma szafek inżynierów, więc jeden harvester trafia też do szafki CE (jest na każdej mapie)
/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()
	new /obj/item/energy_harvester(src)
