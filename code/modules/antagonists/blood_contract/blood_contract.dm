/datum/antagonist/blood_contract
	name = "Cel krwawego kontraktu"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/duration = 2 MINUTES
	banning_key = UNBANNABLE_ANTAGONIST

/datum/antagonist/blood_contract/on_gain()
	. = ..()
	give_objective()
	start_the_hunt()

/datum/antagonist/blood_contract/proc/give_objective()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive
	log_objective(owner, survive.explanation_text)

/datum/antagonist/blood_contract/greet()
	. = ..()
	to_chat(owner, "<span class='userdanger'>Naznaczono cię na śmierć! Nie daj się demonom! ZABIJ ICH WSZYSTKICH!</span>")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Krwawy kontrakt",
		"Naznaczono cię na śmierć, demony łakną twojej krwi. ZABIJ ICH WSZYSTKICH.")

/datum/antagonist/blood_contract/proc/start_the_hunt()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	H.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)

	var/obj/effect/mine/pickup/bloodbath/B = new(H)
	B.duration = duration

	INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/effect/mine/pickup/bloodbath, mineEffect), H) //could use moving out from the mine

	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P == H)
			continue
		log_game("[key_name(P)] was selected to kill [key_name(H)] by blood contract") // holy shit why is there no antag datum. I'm doing a huge refactor so I don't have time for one but I had to add this log here
		to_chat(P, "<span class='userdanger'>Czujesz przemożną chęć zabicia [H]. Ta osoba została naznaczona na czerwono! Przyjaciel czy wróg - idź i zabij!</span>")

		var/obj/item/I = new /obj/item/kitchen/knife/butcher(get_turf(P))
		P.put_in_hands(I, del_on_fail=TRUE)
		QDEL_IN(I, duration)
