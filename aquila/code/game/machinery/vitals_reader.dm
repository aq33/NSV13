// AQUILA - port of tgstation#94704 (Medical larp: vitals monitors).
// Differences: our machines have no occupant signal, so the display polls its connected machine every process tick;
// it mounts with our wallframe pixel shift instead of tg's pixel_z trick; beeps are audible messages instead of runechat.

/obj/item/wallframe/vitals
	name = "rama monitora funkcji życiowych"
	desc = "Służy do zbudowania monitora funkcji życiowych. Zamontuj na ścianie obok łóżka stazy, stołu operacyjnego \
		albo innej maszyny, w której leży pacjent, np. kriokomory lub sleepera."
	icon = 'aquila/icons/obj/machines/vitals_monitor.dmi'
	icon_state = "frame"
	custom_materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/gold = 500)
	result_path = /obj/machinery/vitals_reader
	pixel_shift = 32

/obj/item/wallframe/vitals/advanced
	name = "rama zaawansowanego monitora funkcji życiowych"
	desc = "Służy do zbudowania zaawansowanego monitora funkcji życiowych, który dokładniej bada pacjenta."
	custom_materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/gold = 1000, /datum/material/silver = 500)
	result_path = /obj/machinery/vitals_reader/advanced

/// A wall mounted screen that showcases the vitals of a patient nearby.
/obj/machinery/vitals_reader
	name = "monitor funkcji życiowych"
	desc = "Ekran pokazujący funkcje życiowe pobliskiego pacjenta."
	icon = 'aquila/icons/obj/machines/vitals_monitor.dmi'
	icon_state = "frame"
	verb_say = "pika"
	verb_ask = "pika"
	verb_exclaim = "pika"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	max_integrity = 150
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 80, "stamina" = 0)
	light_range = 1.5
	light_power = 0.75
	light_color = LIGHT_COLOR_CYAN

	/// Whether we perform an advanced scan on examine or not
	var/advanced = FALSE
	/// Typepath to spawn when deconstructed
	var/frame = /obj/item/wallframe/vitals
	/// Range which we can connect to machines, don't go crazy ok?
	var/connection_range = 3
	/// Static typecache of things the vitals display can connect to.
	var/static/list/connectable_typecache = typecacheof(list(
		/obj/machinery/abductor/experiment,
		/obj/machinery/atmospherics/components/unary/cryo_cell,
		/obj/machinery/dna_scannernew,
		/obj/machinery/gulag_teleporter,
		/obj/machinery/implantchair,
		/obj/machinery/sleeper,
		/obj/machinery/stasis,
		/obj/machinery/autodoc,
		/obj/structure/table/optable,
	))
	/// The last stat we beeped about
	var/last_reported_stat = null
	/// CD between beeps
	COOLDOWN_DECLARE(beep_cd)
	/// Reference to the mob that is being tracked / scanned
	var/mob/living/patient
	/// What machine are we talking to
	var/obj/connected

/obj/machinery/vitals_reader/advanced
	name = "zaawansowany monitor funkcji życiowych"
	desc = "Ekran pokazujący funkcje życiowe pobliskiego pacjenta. Bada go dokładniej niż zwykły monitor."
	frame = /obj/item/wallframe/vitals/advanced
	advanced = TRUE

/obj/machinery/vitals_reader/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/vitals_reader/LateInitialize()
	. = ..()
	find_machine(prioritize_by_id = TRUE) // mappers can set an id tag to connect it to specific machines
	set_light_on(is_operational)
	START_PROCESSING(SSmachines, src)

/obj/machinery/vitals_reader/Destroy()
	unset_connection()
	unset_patient()
	return ..()

/obj/machinery/vitals_reader/proc/unset_connection(datum/source)
	SIGNAL_HANDLER
	if(isnull(connected))
		return
	UnregisterSignal(connected, COMSIG_PARENT_QDELETING)
	connected = null
	unset_patient()

/obj/machinery/vitals_reader/proc/set_connection(obj/new_connected)
	unset_connection()
	connected = new_connected
	RegisterSignal(connected, COMSIG_PARENT_QDELETING, PROC_REF(unset_connection))
	set_patient(get_connected_patient())

/// Whoever lies in or on the connected machine right now
/obj/machinery/vitals_reader/proc/get_connected_patient()
	if(isnull(connected) || get_dist(src, connected) > connection_range)
		return null
	if(istype(connected, /obj/structure/table/optable))
		var/obj/structure/table/optable/connected_table = connected
		return connected_table.patient
	if(ismachinery(connected))
		var/obj/machinery/connected_machine = connected
		return isliving(connected_machine.occupant) ? connected_machine.occupant : null
	return null

/obj/machinery/vitals_reader/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "odkręcanie...")
	if(tool.use_tool(src, user, 6 SECONDS, volume = 50))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
	return TRUE

/obj/machinery/vitals_reader/multitool_act(mob/living/user, obj/item/tool)
	if(!is_operational)
		return FALSE
	if(isnull(connected))
		if(find_machine())
			balloon_alert(user, "połączono z: [connected.name]")
		else
			balloon_alert(user, "brak maszyn w pobliżu!")
		return TRUE
	balloon_alert(user, "rozłączanie...")
	if(!do_after(user, 2 SECONDS, target = src))
		return TRUE
	balloon_alert(user, "rozłączono z: [connected.name]")
	unset_connection()
	return TRUE

/// Find and connects to a nearby machine
/// If prioritize_by_id is TRUE, will first try to find a machine with the same id_tag as this vitals reader
/obj/machinery/vitals_reader/proc/find_machine(prioritize_by_id = FALSE)
	for(var/obj/nearby_thing in view(connection_range, src))
		if(prioritize_by_id && nearby_thing.id_tag != src.id_tag)
			continue
		if(!is_type_in_typecache(nearby_thing, connectable_typecache))
			continue
		set_connection(nearby_thing)
		return nearby_thing
	if(prioritize_by_id)
		return find_machine(prioritize_by_id = FALSE)
	return null

/obj/machinery/vitals_reader/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/atom/drop_loc = drop_location()
		if(disassembled)
			new frame(drop_loc)
		else
			new /obj/item/stack/sheet/iron(drop_loc, 2)
			new /obj/item/shard(drop_loc)
			new /obj/item/shard(drop_loc)
	qdel(src)

/obj/machinery/vitals_reader/examine(mob/user)
	. = ..()
	if(!is_operational)
		return
	if(isnull(connected))
		. += "<span class='notice'>Monitor nie jest z niczym połączony. Użyj <b>multitoola</b>, żeby połączyć go z pobliską maszyną.</span>"
		return
	if(isnull(patient))
		. += "<span class='notice'>Monitor jest połączony z: [connected.name]. Nikt w niej nie leży.</span>"
		return
	if(is_blind(user))
		return
	if(machine_stat & EMPED)
		. += "<span class='warning'>Ekran chaotycznie migocze!</span>"
		return
	if(!issilicon(user) && !isobserver(user) && get_dist(patient, user) > 2)
		. += "<span class='notice'><i>Stoisz za daleko, żeby odczytać ekran.</i></span>"
		return
	. += healthscan(user, patient, advanced = src.advanced, tochat = FALSE)
	. += chemscan(user, patient, tochat = FALSE)

/**
 * Returns all overlays to be shown when a simple / basic animal patient is detected
 */
/obj/machinery/vitals_reader/proc/get_simple_mob_overlays(hp_color)
	return list(
		construct_overlay("mob", hp_color),
		construct_overlay("blood", COLOR_GRAY),
		construct_overlay("bar9", COLOR_GRAY),
		construct_overlay("bar9", COLOR_GRAY, -3),
	)

/**
 * Returns all overlays to be shown when a humanoid patient is detected
 */
/obj/machinery/vitals_reader/proc/get_humanoid_overlays(hp_color)
	var/list/returned_overlays = list()
	var/mob/living/carbon/human/human_patient = patient

	for(var/body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/real_part = human_patient.get_bodypart(body_zone)
		var/bodypart_color = isnull(real_part) ? COLOR_GRAY : percent_to_color((real_part.brute_dam + real_part.burn_dam) / real_part.max_damage)
		returned_overlays += construct_overlay("human_[body_zone]", bodypart_color)

	if(human_patient.blood_volume && !(NOBLOOD in human_patient.dna.species.species_traits))
		var/blood_color = "#a51919"
		switch((human_patient.blood_volume - BLOOD_VOLUME_SURVIVE) / (BLOOD_VOLUME_NORMAL - BLOOD_VOLUME_SURVIVE))
			if(-INFINITY to 0.2)
				blood_color = "#a1a1a1"
			if(0.2 to 0.4)
				blood_color = "#a18282"
			if(0.4 to 0.6)
				blood_color = "#a16363"
			if(0.6 to 0.8)
				blood_color = "#a14444"
		returned_overlays += construct_overlay("blood", blood_color)
	else
		returned_overlays += construct_overlay("blood", COLOR_GRAY)

	if(HAS_TRAIT(human_patient, TRAIT_NOBREATH))
		returned_overlays += construct_overlay("bar9", COLOR_GRAY)
	else
		returned_overlays += construct_overlay(percent_to_bar(human_patient.getOxyLoss() / human_patient.maxHealth), "#2A72AA")

	if(HAS_TRAIT(human_patient, TRAIT_TOXIMMUNE))
		returned_overlays += construct_overlay("bar9", COLOR_GRAY, -3)
	else
		returned_overlays += construct_overlay(percent_to_bar(human_patient.getToxLoss() / human_patient.maxHealth), "#5d9c11", -3)

	return returned_overlays

/// Returns the EKG and Respiration overlays
/obj/machinery/vitals_reader/proc/get_ekg_and_resp(hp_color)
	var/ekg_icon_state = "ekg"
	var/resp_icon_state = "resp"
	if(patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH))
		ekg_icon_state = "ekg_flat"
		resp_icon_state = "resp_flat"
	else if(patient.InFullCritical() || patient.jitteriness)
		ekg_icon_state = "ekg_fast"

	if(iscarbon(patient))
		var/mob/living/carbon/carbon_patient = patient
		if(carbon_patient.losebreath || HAS_TRAIT(carbon_patient, TRAIT_NOBREATH))
			resp_icon_state = "resp_flat"

	return list(
		construct_overlay(ekg_icon_state, hp_color),
		construct_overlay(resp_icon_state, "#00f7ff"),
	)

/obj/machinery/vitals_reader/update_overlays()
	. = ..()
	if(!is_operational)
		return
	. += emissive_appearance(icon, "outline", alpha = src.alpha)
	if(isnull(patient))
		return
	. += "buttons"
	var/hp_color = percent_to_color((patient.maxHealth - patient.health) / patient.maxHealth)
	. += get_ekg_and_resp(hp_color)
	if(ishuman(patient))
		. += get_humanoid_overlays(hp_color)
	else
		. += get_simple_mob_overlays(hp_color)

/// Converts a percentage to a color
/obj/machinery/vitals_reader/proc/percent_to_color(percent)
	if(machine_stat & EMPED || obj_flags & EMAGGED)
		percent = rand(1, 100) * 0.01
	if(percent == 0)
		return "#2A72AA"
	switch(percent)
		if(0 to 0.125)
			return "#A6BD00"
		if(0.125 to 0.25)
			return "#BDA600"
		if(0.25 to 0.375)
			return "#BD7E00"
		if(0.375 to 0.5)
			return "#BD4200"
	return "#BD0600"

/// Converts a percentage to a bar icon state
/obj/machinery/vitals_reader/proc/percent_to_bar(percent)
	if(machine_stat & EMPED || obj_flags & EMAGGED)
		percent = rand(1, 100) * 0.01
	if(percent >= 1)
		return "bar9"
	if(percent <= 0)
		return "bar1"
	return "bar[clamp(CEILING(percent * 8, 1), 1, 9)]"

/// Helper to construct an overlay for the vitals display
/obj/machinery/vitals_reader/proc/construct_overlay(state_to_use, color_to_use, y_offset = 0)
	var/mutable_appearance/overlay = mutable_appearance(icon, state_to_use, alpha = src.alpha)
	overlay.appearance_flags |= RESET_COLOR
	overlay.color = color_to_use
	overlay.pixel_y += y_offset
	return overlay

/obj/machinery/vitals_reader/power_change()
	. = ..()
	update_appearance()
	set_light_on(is_operational)

/obj/machinery/vitals_reader/process(delta_time)
	if(!is_operational)
		return
	var/mob/living/current_patient = get_connected_patient()
	if(current_patient != patient)
		set_patient(current_patient)
	if(isnull(patient))
		return
	update_appearance()
	if(!COOLDOWN_FINISHED(src, beep_cd))
		return

	var/patient_stat = patient.stat
	if(machine_stat & EMPED || obj_flags & EMAGGED)
		patient_stat = pick(CONSCIOUS, SOFT_CRIT, UNCONSCIOUS, DEAD, DEAD, DEAD)

	switch(patient_stat)
		if(DEAD)
			COOLDOWN_START(src, beep_cd, 11 SECONDS)
			if(last_reported_stat != DEAD)
				beep_message("wydaje przeciągły, jednostajny pisk.")
				last_reported_stat = DEAD
		if(UNCONSCIOUS)
			COOLDOWN_START(src, beep_cd, 5 SECONDS)
			if(last_reported_stat != UNCONSCIOUS)
				beep_message("wydaje naprzemienny pisk.")
				last_reported_stat = UNCONSCIOUS
		if(SOFT_CRIT)
			COOLDOWN_START(src, beep_cd, 7 SECONDS)
			if(last_reported_stat != SOFT_CRIT)
				beep_message("wydaje wysoki pisk.")
				last_reported_stat = SOFT_CRIT
		else
			COOLDOWN_START(src, beep_cd, 7 SECONDS)
			if(last_reported_stat != CONSCIOUS)
				beep_message("pika.")
				last_reported_stat = CONSCIOUS

/obj/machinery/vitals_reader/proc/beep_message(message)
	audible_message("<span class='notice'>[src] [message]</span>")

/// Sets the passed mob as the active patient
/obj/machinery/vitals_reader/proc/set_patient(mob/living/new_patient)
	if(patient == new_patient)
		return
	unset_patient()
	if(isnull(new_patient))
		return
	patient = new_patient
	RegisterSignal(patient, COMSIG_PARENT_QDELETING, PROC_REF(unset_patient))
	update_appearance()
	use_power = ACTIVE_POWER_USE
	last_reported_stat = null

/// Unset the current patient.
/obj/machinery/vitals_reader/proc/unset_patient(datum/source)
	SIGNAL_HANDLER
	if(isnull(patient))
		return
	UnregisterSignal(patient, COMSIG_PARENT_QDELETING)
	patient = null
	use_power = IDLE_POWER_USE
	if(QDELING(src))
		return
	update_appearance()

/obj/machinery/vitals_reader/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	COOLDOWN_START(src, beep_cd, 1 SECONDS * rand(10, (severity == EMP_HEAVY ? 120 : 60)))
	set_machine_stat(machine_stat | EMPED)
	addtimer(CALLBACK(src, PROC_REF(fix_emp)), (severity == EMP_HEAVY ? 150 SECONDS : 75 SECONDS))

/obj/machinery/vitals_reader/proc/fix_emp()
	set_machine_stat(machine_stat & ~EMPED)

/datum/design/vitals_monitor
	name = "Vitals Monitor"
	desc = "Montowany na ścianie monitor funkcji życiowych pobliskiego pacjenta. Łączy się z łóżkami stazy, stołami operacyjnymi \
		i innymi maszynami, w których leży pacjent, np. kriokomorami i sleeperami."
	id = "vitals_monitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/gold = 500)
	build_path = /obj/item/wallframe/vitals
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/vitals_monitor/advanced
	name = "Advanced Vitals Monitor"
	desc = "Monitor funkcji życiowych, który dokładniej bada pacjenta."
	id = "vitals_monitor_advanced"
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/gold = 1000, /datum/material/silver = 500)
	build_path = /obj/item/wallframe/vitals/advanced

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids += "vitals_monitor"

/datum/techweb_node/adv_biotech/New()
	. = ..()
	design_ids += "vitals_monitor_advanced"
