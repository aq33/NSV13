/datum/map_template/shelter
	var/shelter_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas
	var/banned_objects

/datum/map_template/shelter/New()
	. = ..()
	blacklisted_turfs = typecacheof(/turf/closed)
	whitelisted_turfs = list()
	banned_areas = typecacheof(/area/shuttle)
	banned_objects = list()

/datum/map_template/shelter/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if((O.density && O.anchored) || is_type_in_typecache(O, banned_objects))
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/shelter/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "Przytulne, samowystarczalne, hermetyczne schronienie z wbudowaną nawigacją, rozrywką, zapleczem medycznym i częścią sypialną! Zamów teraz, a dorzucimy MAŁY WENTYLATOR całkowicie za darmo!"
	mappath = "_maps/templates/shelter_1.dmm"

/datum/map_template/shelter/alpha/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/shelter/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "Niezwykle luksusowe schronienie ze wszystkimi wygodami domu, w tym wykładziną, ciepłą i zimną bieżącą wodą, trzydaniowym posiłkiem dla smakoszy, zapleczem kuchennym i luksusowym towarzyszem, byś nie czuł się samotny podczas burzy popiołu."
	mappath = "_maps/templates/shelter_2.dmm"

/datum/map_template/shelter/beta/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/shelter/charlie
	name = "Shelter Charlie"
	shelter_id = "shelter_charlie"
	description = "Luksusowe, elitarne schronienie mieszczące cały bar, dwa automaty sprzedające, stoły i toaletę z umywalką. To nie jest kapsuła przetrwania, więc nie uratuje cię, jeśli będziesz się wykrwawiać na śmierć."
	mappath = "_maps/templates/shelter_3.dmm"

/datum/map_template/shelter/charlie/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile) 

/datum/map_template/shelter/delta
	name = "Shelter Delta"
	shelter_id = "shelter_delta"
	description = "Średniej wielkości obóz górniczy z automatem z jedzeniem, barakami z zapasowymi ubraniami i sejfem w podłodze, nadajnikiem GPS oraz małym budynkiem z automatem ze sprzętem."
	mappath = "_maps/templates/shelter_4.dmm"

/datum/map_template/shelter/delta/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/closed/mineral)
	banned_objects = typecacheof(/obj/structure/stone_tile)

/datum/map_template/shelter/echo
	name = "Shelter Echo"
	shelter_id = "shelter_echo"
	description = "Mała kapsuła wyposażona w kapsułę medyczną i jednostkę stazy, nanomed oraz chemmaster, zaprojektowana na stacyjne sytuacje awaryjne."
	mappath = "_maps/templates/shelter_5.dmm"

/datum/map_template/shelter/eta
	name = "Shelter Eta"
	shelter_id = "shelter_eta"
	description = "Małe schronienie zdolne do lotu w kosmosie, z większością udogodnień standardowego schronienia bluespace."
	mappath = "_maps/templates/shelter_6.dmm"
	
/datum/map_template/shelter/golf
	name = "Capsule Barricade"
	shelter_id = "capsule_barricade"
	description = "Szklana barykada 3x3, idealna dla ochrony i laserów."
	mappath = "_maps/templates/capsule_barricade.dmm"

/datum/map_template/shelter/theta
	name = "Shelter Theta"
	shelter_id = "shelter_theta"
	description = "Duża przestrzeń imprezowa, odpowiednia na stacyjne imprezy."
	mappath = "_maps/templates/shelter_7.dmm"
