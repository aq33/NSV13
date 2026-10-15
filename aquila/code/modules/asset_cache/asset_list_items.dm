// AQUILA - the vending spritesheet only had products of vendors that existed when assets loaded, so a vendor built
// from a board (e.g. the Donksoft vendor, mapped only on Aetherwhisp) showed broken icons. Build every vendor type once
// so its products land in GLOB.vending_products (initial() can't read list vars). Same approach as tgstation.
/datum/asset/spritesheet/vending/register()
	for(var/vendor_type in typesof(/obj/machinery/vending))
		if(ispath(vendor_type, /obj/machinery/vending/cola/random) || ispath(vendor_type, /obj/machinery/vending/snack/random))
			continue // they spawn a random sibling and delete themselves
		qdel(new vendor_type())
	return ..()
