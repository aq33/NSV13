// AQUILA - Corpse flower, a starthistle mutation that releases miasma once it matures

/obj/item/seeds/starthistle
	mutatelist = list(/obj/item/seeds/starthistle/corpse_flower, /obj/item/seeds/galaxythistle)

/obj/item/seeds/starthistle/corpse_flower
	name = "paczka nasion kwiatu trupiego"
	desc = "Gatunek rośliny wydzielający okropny odór. Przestaje go wydzielać w trudnych warunkach atmosferycznych."
	icon_state = "seed-corpse-flower"
	species = "corpse-flower"
	plantname = "Kwiat trupi"
	production = 2
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list()
	mutatelist = list()

// Registers when planted by hand (Moved) or mutated in place (Initialize); emission unregisters it once it leaves the tray
/obj/item/seeds/starthistle/corpse_flower/Initialize(mapload, nogenes)
	. = ..()
	if(istype(loc, /obj/machinery/hydroponics))
		SSmiasma.add_source(src)

/obj/item/seeds/starthistle/corpse_flower/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(istype(loc, /obj/machinery/hydroponics))
		SSmiasma.add_source(src)

/obj/item/seeds/starthistle/corpse_flower/miasma_emission(seconds)
	var/obj/machinery/hydroponics/tray = loc
	if(!istype(tray) || tray.myseed != src)
		return null
	if(tray.dead || tray.age < maturation) // starts a little before it blooms
		return 0
	var/turf/open/T = get_turf(tray)
	// Clouds can begin showing at around 50-60 potency in standard atmos
	if(!istype(T) || abs(ONE_ATMOSPHERE - T.return_air().return_pressure()) > (potency / 10 + 10))
		return 0
	return (yield + 6) * 3.5 * MIASMA_CORPSE_MOLES * seconds
