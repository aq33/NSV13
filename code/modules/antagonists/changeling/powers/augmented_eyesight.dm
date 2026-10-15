//Augmented Eyesight: Gives you X-ray vision or protection from flashes. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/datum/action/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates more light sensing rods in our eyes, allowing our vision to penetrate most blocking objects. Protects our vision from flashes while inactive."
	helptext = "Daje nam widzenie rentgenowskie albo ochronę przed błyskami. Przy aktywnym widzeniu rentgenowskim jesteśmy znacznie bardziej podatni na urządzenia błyskowe."
	button_icon_state = "augmented_eyesight"
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = FALSE

/datum/action/changeling/augmented_eyesight/on_purchase(mob/user) //The ability starts inactive, so we should be protected from flashes.
	..()
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if (E)
		E.flash_protect = 2 //Adjust the user's eyes' flash protection.
		to_chat(user, "Dostosowujemy oczy, by chronić je przed jasnym światłem.")
	else
		to_chat(user, "Nie możemy dostosować oczu, skoro ich nie mamy!")

/datum/action/changeling/augmented_eyesight/sting_action(mob/living/carbon/user)
	if(!istype(user))
		return
	..()
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if(!active)
			E.sight_flags |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
			E.flash_protect = -1 //Adjust the user's eyes' flash protection
			to_chat(user, "Dostosowujemy oczy, by wyczuwać ofiary przez ściany.")
			active = TRUE //Defined in code/modules/spells/spell.dm
		else
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
			E.flash_protect = 2 //Adjust the user's eyes' flash protection
			to_chat(user, "Dostosowujemy oczy, by chronić je przed jasnym światłem.")
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "Nie możemy dostosować oczu, skoro ich nie mamy!")
	return 1


/datum/action/changeling/augmented_eyesight/Remove(mob/user) //Get rid of x-ray vision and flash protection when the user refunds this ability
	var/obj/item/organ/eyes/E = user.getorganslot(ORGAN_SLOT_EYES)
	if(E)
		if (active)
			E.sight_flags ^= SEE_MOBS | SEE_OBJS | SEE_TURFS
		else
			E.flash_protect = 0
		user.update_sight()
	..()
