// Turf fires (port of Yogstation #19738): igniting turfs. The fire effect itself is in aquila/code/game/objects/effects/turf_fire.dm

#define IGNITE_TURF_CHANCE 30
#define IGNITE_TURF_LOW_POWER 8
#define IGNITE_TURF_HIGH_POWER 22

/turf/open
	flammability = 0.2

/turf/open/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(IGNITE_TURF_CHANCE))
		IgniteTurf(rand(IGNITE_TURF_LOW_POWER, IGNITE_TURF_HIGH_POWER))
	return ..()

/// Called when attempting to set fire to a turf
/turf/proc/IgniteTurf(power, fire_color = "red")
	return

/turf/open/IgniteTurf(power, fire_color = "red")
	if(!air || air.get_moles(GAS_O2) < 1)
		return
	if(turf_fire)
		turf_fire.AddPower(power)
		return
	if(!isgroundlessturf(src))
		new /obj/effect/abstract/turf_fire(src, power, fire_color)

#undef IGNITE_TURF_CHANCE
#undef IGNITE_TURF_LOW_POWER
#undef IGNITE_TURF_HIGH_POWER
