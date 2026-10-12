
/mob/living/silicon/pai/proc/fold_out(force = FALSE)
	if(emitterhealth < 0)
		to_chat(src, "<span class='warning'>Emitery holoobudowy są wciąż zbyt niestabilne! Zaczekaj na automatyczną naprawę.</span>")
		return FALSE

	if(!canholo && !force)
		to_chat(src, "<span class='warning'>Twój właściciel lub inna siła wyłączyła emitery holoobudowy!</span>")
		return FALSE

	if(holoform)
		. = fold_in(force)
		return

	if(emittersemicd)
		to_chat(src, "<span class='warning'>Błąd: emitery holoobudowy się regenerują. Spróbuj ponownie później.</span>")
		return FALSE

	emittersemicd = TRUE
	addtimer(CALLBACK(src, PROC_REF(emittercool)), emittercd)
	mobility_flags = MOBILITY_FLAGS_DEFAULT
	density = TRUE
	if(isliving(card.loc))
		var/mob/living/L = card.loc
		if(!L.temporarilyRemoveItemFromInventory(card))
			to_chat(src, "<span class='warning'>Błąd: nie można przejść w formę mobilną. Obudowę unieruchamia jakieś urządzenie lub osoba.</span>")
			return FALSE
	forceMove(get_turf(card))
	card.forceMove(src)
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = src
	set_light_on(FALSE)
	icon_state = "[chassis]"
	held_state = "[chassis]"
	visible_message("<span class='boldnotice'>[src] rozkłada emiter holoobudowy i tworzy wokół siebie holopowłokę!</span>")
	holoform = TRUE

/mob/living/silicon/pai/proc/emittercool()
	emittersemicd = FALSE

/mob/living/silicon/pai/proc/fold_in(force = FALSE)
	emittersemicd = TRUE
	if(!force)
		addtimer(CALLBACK(src, PROC_REF(emittercool)), emittercd)
	else
		addtimer(CALLBACK(src, PROC_REF(emittercool)), emitteroverloadcd)
	icon_state = "[chassis]"
	if(!holoform)
		. = fold_out(force)
		return
	visible_message("<span class='notice'>[src] wyłącza emiter holoobudowy i składa się z powrotem w kompaktową kartę!</span>")
	stop_pulling()
	if(client)
		client.perspective = EYE_PERSPECTIVE
		client.eye = card
	var/turf/T = drop_location()
	card.forceMove(T)
	forceMove(card)
	mobility_flags = NONE
	density = FALSE
	set_light_on(FALSE)
	holoform = FALSE
	set_resting(resting)

/mob/living/silicon/pai/proc/choose_chassis()
	if(!isturf(loc) && loc != card)
		to_chat(src, "<span class='boldwarning'>Nie możesz zmienić kompozycji holoobudowy, gdy nie jesteś na ziemi ani w karcie!</span>")
		return FALSE
	var/choice = input(src, "Czego chcesz użyć jako kompozycji holoobudowy?") as null|anything in sortList(possible_chassis)
	if(!choice)
		return FALSE
	chassis = choice
	icon_state = "[chassis]"
	held_state = "[chassis]"
	update_resting()
	to_chat(src, "<span class='boldnotice'>Przełączasz kompozycję projekcji holoobudowy na: [chassis].</span>")

/mob/living/silicon/pai/update_resting()
	. = ..()
	if(resting)
		icon_state = "[chassis]_rest"
	else
		icon_state = "[chassis]"
	if(loc != card)
		visible_message("<span class='notice'>[src] [resting? "lays down for a moment." : "perks up from the ground."]</span>")

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/silicon/pai/proc/toggle_integrated_light()
	if(!light_on)
		set_light_on(TRUE)
		to_chat(src, "<span class='notice'>Włączasz wbudowane światło.</span>")
	else
		set_light_on(FALSE)
		to_chat(src, "<span class='notice'>Wyłączasz wbudowane światło.</span>")

/mob/living/silicon/pai/mob_try_pickup(mob/living/user)
	if(!possible_chassis[chassis])
		to_chat(user, "<span class='warning'>Obecnej formy [src] nie da się nosić!</span>")
		return FALSE
	return ..()
