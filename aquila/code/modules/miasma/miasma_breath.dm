// AQUILA - Breathing miasma. Called once per breath from /obj/item/organ/lungs/check_breath().
// BeeStation handled this twice (carbon/life.dm and lungs.dm) and cleared the mood event on every
// breath of clean air; here only the lungs handle it, and the mood event is cleared once.

/obj/item/organ/lungs
	/// TRUE while the owner has the "smell" mood event from miasma
	var/smelling_miasma = FALSE

/obj/item/organ/lungs/proc/handle_miasma_breath(mob/living/carbon/human/H, miasma_pp)
	if(miasma_pp < 1)
		clear_miasma_smell(H)
		return

	// Miasma sickness
	if(prob(0.05 * miasma_pp))
		var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2, 3)
		miasma_disease.name = "Unknown"
		H.ForceContractDisease(miasma_disease, FALSE, TRUE)

	switch(miasma_pp)
		if(1 to 5)
			// At lower pp, give out a little warning
			clear_miasma_smell(H)
			if(prob(5))
				to_chat(H, "<span class='notice'>Czujesz w powietrzu nieprzyjemny zapach.</span>")
		if(5 to 15)
			// At somewhat higher pp, the warning becomes more obvious
			if(prob(15))
				to_chat(H, "<span class='warning'>Czujesz, że coś w tym pomieszczeniu okropnie gnije.</span>")
				SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
				smelling_miasma = TRUE
		if(15 to 30)
			// Small chance to vomit. By now, people have internals on anyway
			if(prob(5))
				miasma_vomit(H)
		if(30 to INFINITY)
			// Higher chance to vomit. Let the horror start
			if(prob(15))
				miasma_vomit(H)

	// In a full miasma atmosphere at 101.34 kPa, about 10 disgust per breath, which is low compared to the thresholds
	H.adjust_disgust(0.1 * miasma_pp)

/obj/item/organ/lungs/proc/miasma_vomit(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning'>Smród gnijących zwłok jest nie do zniesienia!</span>")
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
	smelling_miasma = TRUE
	H.vomit()

/obj/item/organ/lungs/proc/clear_miasma_smell(mob/living/carbon/human/H)
	if(!smelling_miasma)
		return
	smelling_miasma = FALSE
	SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "smell")
