/datum/species/ipc
	speech_sound = "synthetic"

/datum/species/ipc/post_death(mob/living/carbon/C)
	return

// Dym z przegrzanego IPC (port z Yogstation).
/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		H.add_emitter(/obj/emitter/ipc_smoke, "ipc_overheat", 8)
	else
		H.remove_emitter("ipc_overheat")

/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.remove_emitter("ipc_overheat", TRUE)
