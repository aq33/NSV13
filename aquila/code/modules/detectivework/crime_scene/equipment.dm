// AQUILA - sprzęt miejsca zbrodni dla detektywa.

/datum/outfit/job/detective
	l_pocket = /obj/item/toy/crayon/white/chalk

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/storage/box/csi_markers(src)
	new /obj/item/barrier_tape_roll(src)
	new /obj/item/holosign_creator/detective(src)
	new /obj/item/toy/crayon/white/chalk(src)
