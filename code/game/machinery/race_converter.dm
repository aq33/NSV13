/obj/machinery/species_converter
	name = "species conversion chamber"
	desc = "Safely and efficiently converts the species of the occupant, warranty void if exposed to plasma."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"
	state_open = FALSE
	density = TRUE
	var/dangerous = FALSE // Can the species coverter turn people into plasma men?
	var/brainwash = FALSE
	var/processing = FALSE
	var/iterations = 0 // how long the user (victim) has been in the chamber for
	var/changed =  FALSE
	var/datum/species/desired_race = /datum/species/human/felinid
	var/datum/looping_sound/microwave/soundloop

/obj/machinery/species_converter/racewar
	name = "species hypnosis chamber"
	brainwash = TRUE

/obj/machinery/species_converter/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)
	update_icon()

/obj/machinery/species_converter/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/species_converter/can_be_occupant(atom/movable/am)
	return ishuman(am)

/obj/machinery/species_converter/close_machine(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>Najpierw musisz zamknąć właz serwisowy!</span>")
		return
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		to_chat(occupant, "<span class='notice'>Wchodzisz do [src]</span>")
		addtimer(CALLBACK(src, PROC_REF(begin_conversion)), 20, TIMER_OVERRIDE|TIMER_UNIQUE)
		update_icon()

/obj/machinery/species_converter/open_machine(mob/user)
	playsound(src, 'sound/machines/click.ogg', 50)
	if(processing)
		stop()
	..()

/obj/machinery/species_converter/proc/stop()
	processing = FALSE
	iterations = 0
	soundloop.stop()
	set_light(0, 0)

/obj/machinery/species_converter/interact(mob/user)
	if(state_open)
		close_machine()
	else if(!processing)
		open_machine()
	else
		to_chat(user, "<span class='warning'>Nie możesz otworzyć [src], gdy jest aktywny!</span>")

/obj/machinery/species_converter/update_overlays()
	. = ..()
	if(!state_open)
		if(processing)
			. += "[icon_state]_door_on"
			. += "[icon_state]_stack"
			. += "[icon_state]_smoke"
			. += "[icon_state]_green"
		else
			. += "[icon_state]_door_off"
			if(occupant)
				if(powered(AREA_USAGE_EQUIP))
					. += "[icon_state]_stack"
					. += "[icon_state]_yellow"
			else
				. += "[icon_state]_red"
	else if(powered(AREA_USAGE_EQUIP))
		. += "[icon_state]_red"
	if(panel_open)
		. += "[icon_state]_panel"

/obj/machinery/species_converter/process(delta_time)
	if(!processing)
		return
	if(!is_operational || !occupant || !iscarbon(occupant))
		open_machine()
		return

	var/mob/living/carbon/C = occupant
	if(is_species(C, desired_race))
		open_machine()
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
		return

	if(DT_PROB(iterations * 10 + 10, delta_time)) // conversion has some random variation in it
		C.set_species(desired_race)
		if(brainwash)
			to_chat(C, "<span class='userdanger'>Twój umysł wypełnia nowy przymus... czujesz, że musisz go słuchać!</span>")
			var/objective = "Zamień jak najwięcej osób w: [initial(desired_race.name)]. Wojna ras!"
			brainwash(C, objective)
			log_game("[key_name(C)] has been brainwashed with the objective '[objective]' via the species converter.")

	iterations++
	use_power(500)

/obj/machinery/species_converter/proc/begin_conversion()
	if(state_open || !occupant || processing || !is_operational)
		return
	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		if(!is_species(C, desired_race))
			processing = TRUE
			soundloop.start()
			update_icon()
			set_light(2, 1, "#ff0000")
		else
			say("Pacjent już należy do wybranej rasy.")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			open_machine()

/obj/machinery/species_converter/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || processing)
		return
	if(user == occupant)
		to_chat(user, "<span class='warning'>Ze środka nie sięgasz do sterowania!</span>")
		return
	if(brainwash && changed)
		to_chat(user, "<span class='warning'>Kontroler gatunków jest zablokowany!</span>")
		return
	var/list/allowed = GLOB.roundstart_races
	if(!dangerous)
		allowed -= "plasmaman"
	var/choice = input("Wybierz docelową rasę") as null|anything in allowed
	if(choice)
		desired_race = GLOB.species_list[choice]
		changed = TRUE
		to_chat(user, "<span class='notice'>Zmieniasz docelową rasę [src] na: [initial(desired_race.name)].</span>")

/obj/machinery/species_converter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	dangerous = TRUE
	brainwash = prob(30)
	changed = FALSE
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>Po cichu wyłączasz zabezpieczenia [src].</span>")
