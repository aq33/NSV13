/obj/machinery/fat_sucker
	name = "lipid extractor"
	desc = "Safely and efficiently extracts excess fat from a subject."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"

	state_open = FALSE
	density = TRUE
	req_access = list(ACCESS_KITCHEN)
	circuit = /obj/item/circuitboard/machine/fat_sucker
	var/processing = FALSE
	var/start_at = NUTRITION_LEVEL_WELL_FED
	var/stop_at = NUTRITION_LEVEL_STARVING
	var/free_exit = TRUE //set to false to prevent people from exiting before being completely stripped of fat
	var/bite_size = 7.5 //amount of nutrients we take per second
	var/nutrients //amount of nutrients we got build up
	var/nutrient_to_meat = 90 //one slab of meat gives about 52 nutrition
	var/datum/looping_sound/microwave/soundloop //100% stolen from microwaves
	var/breakout_time = 600

	var/next_fact = 10 //in ticks, so about 20 seconds
	var/static/list/fat_facts = list(\
	"Tłuszcze to triglicerydy zbudowane z różnych składników: glicerolu i kwasów tłuszczowych.", \
	"Dorośli powinni czerpać z tłuszczu zalecane 20-35% energii.", \
	"Nadwaga lub otyłość zwiększa ryzyko chorób przewlekłych, takich jak choroby sercowo-naczyniowe, zespół metaboliczny, cukrzyca typu 2 i niektóre nowotwory.", \
	"Nie wszystkie tłuszcze są złe. Pewna ilość tłuszczu jest niezbędnym elementem zdrowej, zbilansowanej diety. " , \
	"Tłuszcze nasycone nie powinny stanowić więcej niż 11% dziennych kalorii.", \
	"Tłuszcze nienasycone, czyli jednonienasycone, wielonienasycone i kwasy tłuszczowe omega-3, występują w produktach roślinnych i rybach." \
	)

/obj/machinery/fat_sucker/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)
	update_icon()

/obj/machinery/fat_sucker/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/fat_sucker/RefreshParts()
	..()
	var/rating = 0
	var/nutriment_rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		rating += L.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		nutriment_rating += M.rating
	bite_size = initial(bite_size) + rating * 2.5
	nutrient_to_meat = initial(nutrient_to_meat) - nutriment_rating * 5

/obj/machinery/fat_sucker/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-kliknij, by przełączyć właz bezpieczeństwa.</span>\n"+\
			"<span class='notice'>Usuwa [bite_size] jednostek odżywczych na operację.</span>\n"+\
			"<span class='notice'>Wymaga [nutrient_to_meat] jednostek odżywczych na płat mięsa.</span>"

/obj/machinery/fat_sucker/close_machine(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>Najpierw musisz zamknąć właz serwisowy!</span>")
		return
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		var/mob/living/L = occupant
		if(!iscarbon(L) || HAS_TRAIT(L, TRAIT_POWERHUNGRY) || !(MOB_ORGANIC in L?.mob_biotypes))
			occupant.forceMove(drop_location())
			occupant = null
			return

		to_chat(occupant, "<span class='notice'>Wchodzisz do [src]</span>")
		addtimer(CALLBACK(src, PROC_REF(start_extracting)), 20, TIMER_OVERRIDE|TIMER_UNIQUE)
		update_icon()

/obj/machinery/fat_sucker/open_machine(mob/user)
	make_meat()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(processing)
		stop()
	..()

/obj/machinery/fat_sucker/container_resist(mob/living/user)
	if(!free_exit || state_open)
		to_chat(user, "<span class='notice'>Awaryjne zwolnienie nie reaguje! Zaczynasz napierać na kadłub!</span>")
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		user.visible_message("<span class='notice'>Widzisz, jak [user] kopie w drzwi [src]!</span>", \
			"<span class='notice'>Opierasz się o tył [src] i zaczynasz pchać drzwi... (zajmie to około [DisplayTimeText(breakout_time)].)</span>", \
			"<span class='italics'>Słyszysz metaliczne skrzypienie z [src].</span>")
		if(do_after(user, breakout_time, target = src))
			if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
				return
			free_exit = TRUE
			user.visible_message("<span class='warning'>[user] wydostaje się z [src]!</span>", \
				"<span class='notice'>Wydostajesz się z [src]!</span>")
			open_machine()
		return
	open_machine()

/obj/machinery/fat_sucker/interact(mob/user)
	if(state_open)
		close_machine()
	else if(!processing || free_exit)
		open_machine()
	else
		to_chat(user, "<span class='warning'>Właz bezpieczeństwa został wyłączony!</span>")

/obj/machinery/fat_sucker/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(user == occupant)
		to_chat(user, "<span class='warning'>Ze środka nie sięgasz do sterowania!</span>")
		return
	if(!(obj_flags & EMAGGED) && !allowed(user))
		to_chat(user, "<span class='warning'>Nie masz wymaganego dostępu.</span>")
		return
	free_exit = !free_exit
	to_chat(user, "<span class='notice'>Właz bezpieczeństwa [free_exit ? "odblokowany" : "zablokowany"].</span>")

/obj/machinery/fat_sucker/update_icon()
	overlays.Cut()
	if(!state_open)
		if(processing)
			overlays += "[icon_state]_door_on"
			overlays += "[icon_state]_stack"
			overlays += "[icon_state]_smoke"
			overlays += "[icon_state]_green"
		else
			overlays += "[icon_state]_door_off"
			if(occupant)
				if(powered(AREA_USAGE_EQUIP))
					overlays += "[icon_state]_stack"
					overlays += "[icon_state]_yellow"
			else
				overlays += "[icon_state]_red"
	else if(powered(AREA_USAGE_EQUIP))
		overlays += "[icon_state]_red"
	if(panel_open)
		overlays += "[icon_state]_panel"

/obj/machinery/fat_sucker/process(delta_time)
	if(!processing)
		return
	if(!is_operational || !occupant || !iscarbon(occupant))
		open_machine()
		return

	var/mob/living/carbon/C = occupant
	if(C.nutrition <= stop_at)
		open_machine()
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
		return
	C.adjust_nutrition(-bite_size * delta_time)
	nutrients += bite_size * delta_time

	if(next_fact <= 0)
		next_fact = initial(next_fact)
		say(pick(fat_facts))
		playsound(loc, 'sound/machines/chime.ogg', 30, FALSE)
	else
		next_fact--
	use_power(500)

/obj/machinery/fat_sucker/proc/start_extracting()
	if(state_open || !occupant || processing || !is_operational)
		return
	if(iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		if(C.nutrition > start_at)
			processing = TRUE
			soundloop.start()
			update_icon()
			set_light(2, 1, "#ff0000")
		else
			say("Obiekt nie jest wystarczająco gruby.")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			overlays += "[icon_state]_red" //throw a red light icon over it, to show that it wont work

/obj/machinery/fat_sucker/proc/stop()
	processing = FALSE
	soundloop.stop()
	set_light(0, 0)

/obj/machinery/fat_sucker/proc/make_meat()
	if(occupant && iscarbon(occupant))
		var/mob/living/carbon/C = occupant
		if(C.type_of_meat)
			// Someone changed component rating high enough so it requires negative amount of nutrients to create a meat slab
			if(nutrient_to_meat < 0)
				occupant.forceMove(drop_location())
				occupant = null
				explosion(loc, 0, 1, 2, 3, TRUE)
				qdel(src)
				return
			if(nutrients >= nutrient_to_meat * 2)
				C.put_in_hands(new /obj/item/food/cookie, del_on_fail = TRUE)
			while(nutrients >= nutrient_to_meat)
				nutrients -= nutrient_to_meat
				new C.type_of_meat (drop_location())
			while(nutrients >= nutrient_to_meat / 3)
				nutrients -= nutrient_to_meat / 3
				new /obj/item/food/meat/rawcutlet/plain (drop_location())
			nutrients = 0

/obj/machinery/fat_sucker/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] jest obecnie zajęty!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] musi być zamknięty, by [panel_open ? "zamknąć" : "otworzyć"] właz serwisowy!</span>")
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	return FALSE

/obj/machinery/fat_sucker/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/fat_sucker/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	start_at = 100
	stop_at = 0
	to_chat(user, "<span class='notice'>Usuwasz ograniczenia dostępu i obniżasz próg automatycznego wyrzucenia!</span>")
	obj_flags |= EMAGGED
