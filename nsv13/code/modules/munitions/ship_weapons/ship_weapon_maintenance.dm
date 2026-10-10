// #define MSTATE_PRIEDOUT 3 // BEGONE

/**
 * Give people a hint about what to do.
 */
/obj/machinery/ship_weapon/examine()
	. = ..()
	if(malfunction)
		. += "Lampki serwisowe migają na czerwono."
	switch(maint_state)
		if(MSTATE_CLOSED)
			. += "Panel serwisowy jest <i>przykręcony</i>."
		if(MSTATE_UNSCREWED)
			. += "Panel serwisowy jest <b>odkręcony</b>, a wewnętrzna obudowa jest <i>przykręcona</i> śrubami."
		if(MSTATE_UNBOLTED)
			. += "Wewnętrzna obudowa została <b>odkręcona</b>, a części można <i>wyważyć</i>."

/**
 * The weapon has malfunctioned and needs maintenance. Set the flag and do some effects to let people know.
 */
/obj/machinery/ship_weapon/proc/weapon_malfunction()
	malfunction = TRUE
	playsound(src, malfunction_sound, 100, TRUE)
	visible_message("<span class=userdanger>Wykryto usterkę w [src]! Sekwencja strzału przerwana!</span>") //perhaps additional flavour text of a non angry red kind?
	for(var/mob/living/M in range(10, get_turf(src)))
		shake_with_inertia(M, 2, 1)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(6, 0, src)
	s.start()
	light_color = LIGHT_COLOR_RED
	set_light(3)

/**
 * Unscrews or re-secures the maintenance panel.
 * Transitions from MSTATE_CLOSED to MSTATE_UNSCREWED.
 * Transitions from MSTATE_UNSCREWED to MSTATE_CLOSED.
 * Returns TRUE if handled, FALSE otherwise.
 */
/obj/machinery/ship_weapon/screwdriver_act(mob/user, obj/item/tool)
	if(state == STATE_FIRING && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='warning'>Nie możesz otworzyć panelu serwisowego, gdy [src] strzela!</span>")
		return TRUE
	else if(state < STATE_FIRING && maint_state == MSTATE_CLOSED)
		to_chat(user, "<span class='notice'>Zaczynasz odkręcać panel serwisowy [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> Odkręcasz panel serwisowy [src].</span>")
			maint_state = MSTATE_UNSCREWED
			panel_open = TRUE
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>Zaczynasz przykręcać panel serwisowy [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> Przykręcasz panel serwisowy [src].</span>")
			maint_state = MSTATE_CLOSED
			panel_open = FALSE
			update_overlay()
			return TRUE
	. = ..()

/**
 * Unbolts or re-secures the inner casing bolts.
 * Transitions from MSTATE_UNSCREWED to MSTATE_UNBOLTED.
 * Transitions from MSTATE_UNBOLTED to MSTATE_UNSCREWED.
 * Returns TRUE if handled, FALSE otherwise.
 */
/obj/machinery/ship_weapon/wrench_act(mob/user, obj/item/tool)
	if(state >= STATE_CHAMBERED && maint_state == MSTATE_UNSCREWED)//we can put buttons and stuff inside the maintenance panel
		to_chat(user, "<span class='warning'>Nie możesz odkręcić wewnętrznej obudowy, gdy [src] ma pocisk w komorze!</span>")
		return TRUE
	else if(maint_state == MSTATE_UNSCREWED)
		to_chat(user, "<span class='notice'>Zaczynasz odkręcać śruby wewnętrznej obudowy [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Odkręcasz śruby wewnętrznej obudowy [src] i ją zdejmujesz.</span>")
			maint_state = MSTATE_UNBOLTED
			update_overlay()
			return TRUE
	else if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>Zaczynasz zakładać wewnętrzną obudowę i przykręcać jej śruby w [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>Przykręcasz śruby wewnętrznej obudowy [src].</span>")
			maint_state = MSTATE_UNSCREWED
			update_overlay()
			return TRUE

/**
 * Deconstructs the machine. We no longer track the panel casing
 */
/obj/machinery/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	// if(maint_state == MSTATE_UNBOLTED)
	// 	to_chat(user, "<span class='notice'>You begin prying the inner casing off [src]...</span>")
	// 	if(tool.use_tool(src, user, 40, volume=100))
	// 		to_chat(user, "<span class='notice'>You pry the inner casing off [src].</span>")
	// 		maint_state = MSTATE_PRIEDOUT
	// 		update_overlay()
	// 		if(prob(50))
	// 			to_chat(user, "<span class='warning'>Oil spurts out of the exposed machinery!</span>")
	// 			new /obj/effect/decal/cleanable/oil(user.loc)
	// 			reagents.clear_reagents()
	// 		return TRUE
	// if(maint_state == MSTATE_PRIEDOUT)
	// 	to_chat(user, "<span class='notice'>You begin slotting the inner casing back in [src]...</span>")
	// 	if(tool.use_tool(src, user, 40, volume=100))
	// 		to_chat(user, "<span class='notice'>You slot the inner casing back in [src].</span>")
	// 		maint_state = MSTATE_UNBOLTED
	// 		update_overlay()
	// 		return TRUE
	// . = ..()
	if ( maint_state != MSTATE_UNBOLTED )
		to_chat(user, "<span class='warning'>Śruby wewnętrznej obudowy [src] są przykręcone!</span>")
		return FALSE
	else
		if(default_deconstruction_crowbar(tool))
			return TRUE

/**
 * Tries to use item I to lubricate the machinery.
 */
/obj/machinery/ship_weapon/proc/oil(obj/item/I, mob/user)
	// if(maint_state != MSTATE_PRIEDOUT)
	// 	to_chat(user, "<span class='notice'>You require access to the inner workings of [src].</span>")
	// 	return
	if((maint_state == MSTATE_UNBOLTED) && istype(I, /obj/item/reagent_containers))
		if(I.reagents.has_reagent(/datum/reagent/oil, 10))
			to_chat(user, "<span class='notice'>Zaczynasz smarować wnętrze [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(!I.reagents.has_reagent(/datum/reagent/oil, 10)) //Since things can change during the doafter, we need to check again.
				to_chat(user, "<span class='notice'>Masz za mało oleju, by nasmarować [src]!</span>")
				return
			to_chat(user, "<span class='notice'>Smarujesz wnętrze [src].</span>")
			if(malfunction)
				malfunction = FALSE
				visible_message("<span class='notice'>Czerwone lampki ostrzegawcze na [src] gasną.</span>")
				set_light(0)
			maint_req = max(maint_req, rand(15,25))
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return
		else if(I.reagents.has_reagent(/datum/reagent/oil))
			to_chat(user, "<span class='notice'>Do nasmarowania [src] potrzebujesz przynajmniej 10 jednostek oleju!</span>")
			return
		else
			visible_message("<span class=warning>Ostrzeżenie: wykryto zanieczyszczenia, płukanie systemów.</span>")
			new /obj/effect/decal/cleanable/oil(user.loc)
			I.reagents.trans_to(src, 10)
			reagents.clear_reagents()
			return
	else
		to_chat(user, "<span class='notice'>Nie możesz nasmarować [src] za pomocą [I]!</span>")

/obj/machinery/ship_weapon/proc/update_overlay()
	cut_overlays()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			add_overlay("[initial(icon_state)]_screwdriver")
		if(MSTATE_UNBOLTED)
			add_overlay("[initial(icon_state)]_wrench")
		// if(MSTATE_PRIEDOUT)
		// 	add_overlay("[initial(icon_state)]_crowbar")
