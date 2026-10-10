/datum/disease/heart_failure
	form = "Condition"
	name = "Myocardial Infarction"
	max_stages = 5
	stage_prob = 2
	cure_text = "Leczy się przeszczepem serca. Po zatrzymaniu akcji serca skuteczna może też być defibrylacja (lub, w ostateczności, niekontrolowane rażenie prądem). Korazon może też łagodzić zatrzymanie akcji serca."
	agent = "Shitty Heart"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will die!"
	danger = DISEASE_DANGEROUS
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/heart)
	bypasses_immunity = TRUE // Immunity is based on not having an appendix; this isn't a virus
	var/sound = FALSE

/datum/disease/heart_failure/Copy()
	var/datum/disease/heart_failure/D = ..()
	D.sound = sound
	return D

/datum/disease/heart_failure/stage_act()
	..()
	var/obj/item/organ/heart/O = affected_mob.getorgan(/obj/item/organ/heart)
	var/mob/living/carbon/H = affected_mob
	if(O && H.can_heartattack())
		switch(stage)
			if(1 to 2)
				if(prob(2))
					to_chat(H, "<span class='warning'>Czujesz w klatce piersiowej [pick("dyskomfort", "ucisk", "pieczenie", "ból")].</span>")
				if(prob(2))
					to_chat(H, "<span class='warning'>Kręci ci się w głowie.</span>")
					H.confused += 6
				if(prob(3))
					to_chat(H, "<span class='warning'>Czujesz [pick("pełność", "mdłości", "pot", "osłabienie", "zmęczenie", "duszność", "niepokój")].</span>")
			if(3 to 4)
				if(!sound)
					H.playsound_local(H, 'sound/health/slowbeat.ogg',40,0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
					sound = TRUE
				if(prob(3))
					to_chat(H, "<span class='danger'>Czujesz ostry ból w klatce piersiowej!</span>")
					if(prob(25))
						affected_mob.vomit(95)
					H.emote("cough")
					H.Paralyze(40)
					H.losebreath += 4
				if(prob(3))
					to_chat(H, "<span class='danger'>Czujesz się bardzo słaby i kręci ci się w głowie...</span>")
					H.confused += 8
					H.adjustStaminaLoss(40)
					H.emote("cough")
			if(5)
				H.stop_sound_channel(CHANNEL_HEARTBEAT)
				H.playsound_local(H, 'sound/effects/singlebeat.ogg', 100, 0)
				if(H.stat == CONSCIOUS)
					H.visible_message("<span class='danger'>[H] chwyta się za klatkę piersiową, jakby jego serce się zatrzymywało!</span>", \
						"<span class='userdanger'>Czujesz straszliwy ból w klatce piersiowej, jakby twoje serce stanęło!</span>")
				H.adjustStaminaLoss(60)
				H.set_heartattack(TRUE)
				H.reagents.add_reagent(/datum/reagent/medicine/corazone, 3) // To give the victim a final chance to shock their heart before losing consciousness
				cure()
	else
		cure()
