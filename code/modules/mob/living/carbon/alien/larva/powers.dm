/obj/effect/proc_holder/alien/hide
	name = "Hide"
	desc = "Allows aliens to hide beneath tables or certain items. Toggled on or off."
	plasma_cost = 0

	action_icon_state = "alien_hide"

/obj/effect/proc_holder/alien/hide/fire(mob/living/carbon/alien/user)
	if(user.stat != CONSCIOUS)
		return
	if (user.layer != ABOVE_NORMAL_TURF_LAYER)
		user.layer = ABOVE_NORMAL_TURF_LAYER
		user.visible_message("<span class='name'>[user] przypada do ziemi!</span>", \
						"<span class='noticealien'>Teraz się ukrywasz.</span>")
	else
		user.layer = MOB_LAYER
		user.visible_message("[user] powoli wychyla się znad ziemi...", \
					"<span class='noticealien'>Przestajesz się ukrywać.</span>")
	return 1


/obj/effect/proc_holder/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	plasma_cost = 0

	action_icon_state = "alien_evolve_larva"

/obj/effect/proc_holder/alien/larva_evolve/fire(mob/living/carbon/alien/user)
	if(!islarva(user))
		return
	var/mob/living/carbon/alien/larva/L = user

	if(L.handcuffed || L.legcuffed) // Cuffing larvas ? Eh ?
		to_chat(user, "<span class='danger'>Nie możesz ewoluować w kajdankach.</span>")
		return

	if(L.movement_type & VENTCRAWLING)
		to_chat(user, "<span class='danger'>Nie możesz ewoluować w wywietrzniku.</span>")
		return

	if(L.amount_grown >= L.max_grown)	//TODO ~Carn
		to_chat(L, "<span class='name'>Wyrastasz na pięknego obcego! Czas wybrać kastę.</span>")
		to_chat(L, "<span class='info'>Do wyboru są trzy:</span>")
		to_chat(L, "<span class='name'>Łowcy</span> <span class='info'>to najzwinniejsza kasta, która poluje na nosicieli. Są szybsi od człowieka i potrafią rzucać się na ofiary, ale nie są dużo wytrzymalsi od trutni.</span>")
		to_chat(L, "<span class='name'>Strażnicy</span> <span class='info'>chronią ul. Dzięki pluciu na odległość, niewidzialności i dużej wytrzymałości są groźnymi obrońcami i niezłymi łowcami pomocniczymi.</span>")
		to_chat(L, "<span class='name'>Trutnie</span> <span class='info'>to najsłabsza i najwolniejsza kasta, ale mogą wyrosnąć na pretorianina, a potem królową, jeśli królowej nie ma, i są niezbędne do utrzymania ula dzięki wydzielaniu żywicy.</span>")
		var/alien_caste = alert(L, "Wybierz, do której kasty obcych chcesz należeć.",,"Hunter","Sentinel","Drone")

		if(user.incapacitated()) //something happened to us while we were choosing.
			return

		var/mob/living/carbon/alien/humanoid/new_xeno
		switch(alien_caste)
			if("Hunter")
				new_xeno = new /mob/living/carbon/alien/humanoid/hunter(L.loc)
			if("Sentinel")
				new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(L.loc)
			if("Drone")
				new_xeno = new /mob/living/carbon/alien/humanoid/drone(L.loc)

		L.alien_evolve(new_xeno)
		return 0
	else
		to_chat(user, "<span class='danger'>Nie jesteś w pełni dojrzały.</span>")
		return 0
