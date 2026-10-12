/datum/disease/rhumba_beat
	name = "The Rhumba Beat"
	max_stages = 5
	spread_text = "Przez kontakt"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Chick Chicky Boom!"
	cures = list("plasma")
	agent = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	danger = DISEASE_BIOHAZARD

/datum/disease/rhumba_beat/stage_act()
	..()
	if(affected_mob.ckey == "rosham")
		cure()
		return
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustFireLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Czujesz się dziwnie...</span>")
		if(3)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Czujesz chęć, by tańczyć...</span>")
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Czujesz potrzebę, by zrobić chick chicky boom...</span>")
		if(4)
			if(prob(20))
				if (prob(50))
					affected_mob.adjust_fire_stacks(2)
					affected_mob.IgniteMob()
				else
					affected_mob.emote("gasp")
					to_chat(affected_mob, "<span class='danger'>Czujesz w sobie palący rytm...</span>")
		if(5)
			to_chat(affected_mob, "<span class='danger'>Twoje ciało nie jest w stanie powstrzymać Rytmu Rumby...</span>")
			if(prob(50))
				explosion(get_turf(affected_mob), -1, 0, 2, 3, 0, 2, magic=TRUE) // This is equivalent to a lvl 1 fireball
		else
			return
