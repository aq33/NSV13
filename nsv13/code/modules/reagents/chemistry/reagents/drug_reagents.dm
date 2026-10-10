/datum/reagent/drug/highjack
	name = "Highjack"
	description = "Przetworzony przez syntetyki wywołuje efekty podobne do substancji zmieniających świadomość."
	color = "#271509"
	taste_description = "metallic"
	process_flags = SYNTHETIC
	overdose_threshold = 30


/datum/reagent/drug/highjack/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(prob(7))
		M.emote(pick("buzz","beep","ping","buzz2"))
	..()

/datum/reagent/drug/highjack/overdose_process(mob/living/carbon/M)
	var/obj/item/bodypart/head/head = M.get_bodypart("head")
	if(prob(30))
		if(head)
			to_chat(M, "<span class='userdanger'>Kręci ci się w głowie...</span>")
			head.dismember()
		else
			to_chat(M,"<span class='userdanger'>Czujesz, jak z twojej bezgłowej szyi wycieka olej.</span>")
			M.bleed(20) //effectively bleed 2 due to robot physiology bleed mod being 0.1.
