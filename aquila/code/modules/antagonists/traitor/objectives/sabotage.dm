// AQUILA - sabotage objectives.
// power sink / supermatter / integrity / AI law: Skyrat-SS13/Skyrat13#157 (objective_sabotage.dm), its cloner sabotage is covered by break_machinery.
// air sabotage and IFF subversion: Aquila. Forged manifest: BeeStation/BeeStation-Hornet#10656.

/datum/objective/sabotage
	name = "sabotaż"
	martyr_compatible = TRUE

/// Drain power with a power sink. Our sinks explode at 6e8, so the goal is a part of that.
/datum/objective/sabotage/power_sink
	name = "pochłaniacz mocy"
	/// Drained by the sinks of this objective so far
	var/drained = 0

/datum/objective/sabotage/power_sink/traitor_roll_setup(datum/antagonist/traitor/rolling)
	target_amount = rand(15, 35) * 1e7
	update_explanation_text()
	give_beacon()
	return TRUE

/datum/objective/sabotage/power_sink/proc/give_beacon()
	var/datum/mind/receiver = owner || pick(get_owners())
	if(!ishuman(receiver?.current))
		return
	var/mob/living/carbon/human/H = receiver.current
	var/obj/item/sbeacondrop/powersink/traitor/beacon = new(get_turf(H))
	beacon.objective = src
	H.equip_in_one_of_slots(beacon, list("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET, "hands" = ITEM_SLOT_HANDS))

/datum/objective/sabotage/power_sink/update_explanation_text()
	explanation_text = "Wyssij co najmniej [DisplayPower(target_amount)] z sieci energetycznej statku dostarczonym pochłaniaczem mocy. Uważaj - przepełniony pochłaniacz wybucha."

/datum/objective/sabotage/power_sink/check_completion()
	return completed || drained >= target_amount

/datum/objective/sabotage/power_sink/admin_edit(mob/admin)
	if(!target_amount)
		target_amount = 25e7
	update_explanation_text()
	give_beacon()

/obj/item/sbeacondrop/powersink/traitor
	droptype = /obj/item/powersink/traitor
	var/datum/objective/sabotage/power_sink/objective

/obj/item/sbeacondrop/powersink/traitor/attack_self(mob/user)
	if(!user)
		return
	to_chat(user, "<span class='notice'>Namierzono.</span>")
	var/obj/item/powersink/traitor/sink = new droptype(user.loc)
	sink.objective = objective
	playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
	qdel(src)

/obj/item/powersink/traitor
	var/datum/objective/sabotage/power_sink/objective

/obj/item/powersink/traitor/on_drain(drained)
	if(objective && !QDELETED(objective))
		objective.drained += drained
	return ..()

/// Get the supermatter under 50% integrity without delaminating it. Only rolled when the ship has one.
/datum/objective/sabotage/supermatter
	name = "sabotaż supermaterii"
	/// Lowest integrity seen so far
	var/lowest_integrity = 100
	var/obj/machinery/power/supermatter_crystal/crystal

/datum/objective/sabotage/supermatter/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(owner.assigned_role in list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN))
		return FALSE
	for(var/obj/machinery/power/supermatter_crystal/S in GLOB.machines)
		if(isturf(S.loc) && is_station_level(S.z))
			crystal = S
			break
	if(!crystal)
		return FALSE
	START_PROCESSING(SSprocessing, src)
	update_explanation_text()
	give_special_equipment(list(/obj/item/paper/guides/antag/supermatter_sabotage))
	return TRUE

/datum/objective/sabotage/supermatter/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	crystal = null
	return ..()

/datum/objective/sabotage/supermatter/process()
	if(QDELETED(crystal))
		crystal = null
		return PROCESS_KILL
	lowest_integrity = min(lowest_integrity, crystal.get_integrity_percent())

/datum/objective/sabotage/supermatter/update_explanation_text()
	explanation_text = "Zsabotuj supermaterię tak, by jej integralność spadła poniżej 50%. Jeśli dojdzie do delaminacji, cel przepadnie."

/datum/objective/sabotage/supermatter/check_completion()
	return completed || (!QDELETED(crystal) && lowest_integrity < 50)

/obj/item/paper/guides/antag/supermatter_sabotage
	name = "Jak zepsuć supermaterię"
	default_raw_text = "Sposoby na sabotaż supermaterii:<br>\
	<ul>\
	<li>Przestaw tryb alarmu powietrza na cokolwiek innego niż 'przeciąg' (najlepiej 'wyłączony'). Albo po prostu go rozbij.</li>\
	<li>Odkręć rurę (najlepiej złączkę pętli chłodzącej; niektóre układy to wytrzymają, więc spróbuj w kilku miejscach).</li>\
	<li>Wpompuj tyle dwutlenku węgla, tlenu, plazmy albo trytu, ile znajdziesz.</li>\
	<li>Wyłącz filtry pętli chłodzącej albo, podstępniej, przestaw je na tlen lub plazmę.</li>\
	<li>Jest wiele innych sposobów, bądź kreatywny! Tylko nie doprowadź do delaminacji.</li>\
	</ul>"

/// Leave the ship under a set integrity rating at the end of the round
/datum/objective/sabotage/integrity
	name = "zniszczenie statku"

/datum/objective/sabotage/integrity/traitor_roll_setup(datum/antagonist/traitor/rolling)
	target_amount = 80
	update_explanation_text()
	return TRUE

/datum/objective/sabotage/integrity/update_explanation_text()
	explanation_text = "Dopilnuj, by na koniec zmiany integralność statku wynosiła mniej niż [target_amount]%. Rozbijaj ściany, okna, maszyny - wszystko się liczy."

/datum/objective/sabotage/integrity/check_completion()
	if(completed || SSticker.mode.station_was_nuked)
		return TRUE
	return get_ship_integrity() < target_amount

/// Integrity rating of the ship right now, the same number the round end report shows. Cached for a tick.
/proc/get_ship_integrity()
	var/static/cached_integrity
	var/static/cached_at = -1
	if(cached_at == world.time)
		return cached_integrity
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	cached_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	cached_at = world.time
	return cached_integrity

/// Upload a hacked law to the AI
/datum/objective/sabotage/ai_law
	name = "zhakowane prawo SI"

/datum/objective/sabotage/ai_law/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(owner.assigned_role in GLOB.command_positions)
		return FALSE
	if(!length(active_ais(TRUE)))
		return FALSE
	update_explanation_text()
	give_special_equipment(list(/obj/item/aiModule/syndicate))
	return TRUE

/datum/objective/sabotage/ai_law/update_explanation_text()
	explanation_text = "Wgraj SI statku zhakowane prawo dostarczonym modułem i dopilnuj, by obowiązywało do końca zmiany."

/datum/objective/sabotage/ai_law/check_completion()
	if(completed)
		return TRUE
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.mind && length(ai.laws?.hacked))
			return TRUE
	return FALSE

/// A part of the ship has to be unbreathable at the end of the round.
/// Only checked once, at round end, so it doesn't cost anything during the round.
/datum/objective/air_sabotage
	name = "sabotaż powietrza"
	martyr_compatible = TRUE

/datum/objective/air_sabotage/traitor_roll_setup(datum/antagonist/traitor/rolling)
	target_amount = rand(2, 4) * 5
	update_explanation_text()
	return TRUE

/datum/objective/air_sabotage/update_explanation_text()
	explanation_text = "Na koniec zmiany co najmniej [target_amount]% statku ma się nie nadawać do oddychania - próżnia, plazma, brak tlenu, skrajna temperatura, cokolwiek."

/datum/objective/air_sabotage/check_completion()
	return completed || get_unbreathable_percent() >= target_amount

/// Percent of open turfs on the ship that a human couldn't breathe on. Cached for a tick, every objective shares it.
/proc/get_unbreathable_percent()
	var/static/cached_percent
	var/static/cached_at = -1
	if(cached_at == world.time)
		return cached_percent
	var/total = 0
	var/unbreathable = 0
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.type in GLOB.the_station_areas))
			continue
		for(var/turf/open/T in A)
			if(isspaceturf(T))
				continue
			total++
			if(!is_breathable_air(T.return_air()))
				unbreathable++
	cached_percent = total ? round(100 * unbreathable / total, 0.1) : 0
	cached_at = world.time
	return cached_percent

/proc/is_breathable_air(datum/gas_mixture/air)
	if(!air)
		return FALSE
	var/pressure = air.return_pressure()
	if(pressure < WARNING_LOW_PRESSURE || pressure > WARNING_HIGH_PRESSURE)
		return FALSE
	var/temperature = air.return_temperature()
	if(temperature < BODYTEMP_COLD_DAMAGE_LIMIT || temperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		return FALSE
	var/total_moles = air.total_moles()
	if(total_moles <= 0)
		return FALSE
	if(pressure * air.get_moles(GAS_O2) / total_moles < 16)
		return FALSE
	if(pressure * air.get_moles(GAS_PLASMA) / total_moles > 0.5)
		return FALSE
	if(pressure * air.get_moles(GAS_CO2) / total_moles > 8)
		return FALSE
	return TRUE

/// Turn the ship's IFF to the Syndicate and keep it that way until the end of the round
/datum/objective/iff_subvert
	name = "subwersja IFF"
	martyr_compatible = TRUE

/datum/objective/iff_subvert/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(taken_by_other_traitor())
		return FALSE
	if(length(GLOB.joined_player_list) < CONFIG_GET(number/min_pop_kill_objectives))
		return FALSE
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(!main_ship || main_ship.faction != "nanotrasen")
		return FALSE
	var/console_found = FALSE
	for(var/obj/machinery/computer/iff_console/console in GLOB.machines)
		if(console.get_overmap() == main_ship)
			console_found = TRUE
			break
	if(!console_found)
		return FALSE
	update_explanation_text()
	return TRUE

/datum/objective/iff_subvert/update_explanation_text()
	explanation_text = "Przestaw sygnaturę IFF statku na Syndykat i utrzymaj ją do końca zmiany. Zemaguj konsolę IFF, a potem przełam ją multitoolem (2 minuty). Uwaga: SolGov wyśle po statek flotę przechwytującą."

/datum/objective/iff_subvert/check_completion()
	if(completed)
		return TRUE
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	return main_ship?.faction == "syndicate"

/// Add a made up person with the given data to the crew manifest (BeeStation/BeeStation-Hornet#10656)
/datum/objective/forged_manifest
	name = "fałszywy manifest"
	martyr_compatible = TRUE
	var/person_name
	var/age
	var/gender
	var/job
	/// Species id, the records console stores ids
	var/species_id
	var/species_name
	var/fail_reasons

/datum/objective/forged_manifest/traitor_roll_setup(datum/antagonist/traitor/rolling)
	generate_person()
	return TRUE

/datum/objective/forged_manifest/admin_edit(mob/admin)
	generate_person()

/datum/objective/forged_manifest/proc/generate_person()
	gender = pick(MALE, FEMALE)
	species_id = pick(GLOB.roundstart_races)
	var/species_type = GLOB.species_list[species_id]
	var/datum/species/species = new species_type
	species_name = species.name
	for(var/attempt in 1 to 10)
		person_name = species.random_name(gender, TRUE)
		if(!find_record("name", person_name, GLOB.data_core.general))
			break
	qdel(species)
	age = rand(20, 60)
	job = pick(JOB_NAME_ASSISTANT, JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_SCIENTIST, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_MUNITIONSTECHNICIAN, JOB_NAME_PILOT, JOB_NAME_DECKTECHNICIAN)
	update_explanation_text()

/datum/objective/forged_manifest/update_explanation_text()
	explanation_text = "Wpisz do manifestu załogi nieistniejącą osobę (np. konsolą akt ochrony): [person_name], [gender == MALE ? "mężczyzna" : "kobieta"], [age] lat, [species_name], [job]."

/datum/objective/forged_manifest/check_completion()
	if(completed)
		return TRUE
	fail_reasons = list()
	var/datum/data/record/R = find_record("name", person_name, GLOB.data_core.general)
	if(!R)
		return FALSE
	if("[R.fields["age"]]" != "[age]")
		fail_reasons += "wiek"
	if(lowertext(R.fields["gender"]) != lowertext(gender))
		fail_reasons += "płeć"
	if(lowertext(R.fields["rank"]) != lowertext(job))
		fail_reasons += "stanowisko"
	if(R.fields["species"] != species_id && R.fields["species"] != species_name)
		fail_reasons += "gatunek"
	return !length(fail_reasons)
