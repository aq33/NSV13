/datum/symptom/cockroach

	name = "SBG Syndrome"
	desc = "Wywołuje synchroniczność bluespace z pobliskimi kanałami powietrza, przez co karaluchy zasiedlające filtry stacji wypełzają z twarzy nosiciela"
	stealth = 1
	resistance = 2
	stage_speed = 3
	transmission = 1
	level = 0
	severity = 0 //rip funy
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Blatto")
	bodies = list("Roach")
	var/death_roaches = FALSE
	threshold_desc = "<b>Szybkość stadiów 8:</b> zwiększa szybkość karaluchów<br><b>Transmisja 8:</b> gdy nosiciel umiera, pojawia się więcej karaluchów<br>"

/datum/symptom/cockroach/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		symptom_delay_min = 5
		symptom_delay_max = 15
	if(A.transmission >= 8)
		death_roaches = TRUE

/datum/symptom/cockroach/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(50))
				to_chat(M, "<span class='notice'>Czujesz mrowienie pod skórą.</span>")
		if(3)
			if(prob(50))
				to_chat(M, "<span class='notice'>Czujesz przeciąg w porach.</span>")
			if(prob(5))
				to_chat(M, "<span class='notice'>Czujesz się zestrojony z atmosferą.</span>")
		if(4)
			if(prob(50))
				to_chat(M, "<span class='notice'>Czujesz się zestrojony ze stacją.</span>")
		if(5)
			if(prob(30))
				M.visible_message("<span class='danger'>[M] wije się, gdy z jego porów wypełza karaluch!</span>", \
								  "<span class='userdanger'>Z twojej twarzy wypełza karaluch!!</span>")
				new /mob/living/simple_animal/cockroach(M.loc)
			if(prob(50))
				to_chat(M, "<span class='notice'>Czujesz, jak coś pełza ci w rurach!</span>")

/datum/symptom/cockroach/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	if(death_roaches)
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='warning'>Twoje pory eksplodują kolonią karaluchów!</span>")
		for(var/i in 1 to rand(1,5))
			new /mob/living/simple_animal/cockroach(M.loc)

