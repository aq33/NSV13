// Turf fires (port of Yogstation #19738): how much fuel each floor gives a turf fire

/turf/open/floor/wood
	flammability = 3 // yikes, better put that out quick

/turf/open/floor/grass
	flammability = 2 // california simulator

/turf/open/floor/carpet
	flammability = 3 // this will be abused and i am all for it

/turf/open/floor/mineral/plasma
	flammability = 25 // oh fuck-

/turf/open/floor/engine
	flammability = 0 // nope

/turf/open/floor/engine/temperature_expose()
	return //still unburnable
