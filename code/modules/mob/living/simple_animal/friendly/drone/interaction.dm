
/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones


/mob/living/simple_animal/drone/attack_drone(mob/living/simple_animal/drone/D)
	if(D != src && stat == DEAD)
		var/d_input = alert(D,"Jaką akcję wykonać?","Interakcja z dronem","Reactivate","Cannibalize","Nothing")
		if(d_input)
			switch(d_input)
				if("Reactivate")
					try_reactivate(D)

				if("Cannibalize")
					if(D.health < D.maxHealth)
						D.visible_message("<span class='notice'>[D] zaczyna rozbierać [src] na części.</span>", "<span class='notice'>Zaczynasz rozbierać [src] na części...</span>")
						if(do_after(D, 60, 0, target = src))
							D.visible_message("<span class='notice'>[D] naprawia się, używając szczątków [src]!</span>", "<span class='notice'>Naprawiasz się, używając szczątków [src].</span>")
							D.adjustBruteLoss(-src.maxHealth)
							new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
							qdel(src)
						else
							to_chat(D, "<span class='warning'>Musisz stać w miejscu, by rozebrać [src] na części!</span>")
					else
						to_chat(D, "<span class='warning'>Już jesteś w idealnym stanie!</span>")
				if("Nothing")
					return

/mob/living/simple_animal/drone/attack_drone_secondary(mob/living/simple_animal/drone/drone)
	return SECONDARY_ATTACK_CALL_NORMAL

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/simple_animal/drone/attack_hand(mob/user, list/modifiers)
	if(ishuman(user))
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			..()
			return
		if(user.get_active_held_item())
			to_chat(user, "<span class='warning'>Masz zajęte ręce!</span>")
			return
		visible_message("<span class='warning'>[user] zaczyna podnosić [src].</span>", \
						"<span class='userdanger'>[user] zaczyna cię podnosić!</span>")
		if(!do_after(user, 20, target = src))
			return
		visible_message("<span class='warning'>[user] podnosi [src]!</span>", \
						"<span class='userdanger'>[user] podnosi cię!</span>")
		if(buckled)
			to_chat(user, "<span class='warning'>[src] jest przypięty do [buckled] i nie da się go podnieść!</span>")
			return
		to_chat(user, "<span class='notice'>Podnosisz [src].</span>")
		drop_all_held_items()
		var/obj/item/clothing/head/mob_holder/drone/DH = new(get_turf(src), src)
		user.put_in_hands(DH)

/mob/living/simple_animal/drone/proc/try_reactivate(mob/living/user)
	var/mob/dead/observer/G = get_ghost()
	if(!client && (!G || !G.client))
		var/list/faux_gadgets = list("inflator hipertekstu","katalog awaryjny","przełącznik DRM","inicjalizator stosu",\
									 "kondensator przeciwzamarzaniowy","dioda strumienia danych","wąskie gardło TCP","supercharged I/O bolt",\
									 "stabilizator pasatów","napromieniowany kabel XML","zbiornik płynu rejestru","demaskator open source")

		var/list/faux_problems = list("nie dostroi swojego projektora bootstrap","będzie ciągle remiksować swoją pulę binarną"+\
									  " mimo że kalibrator BMX działa","zacznie wyciekać chłodziwo XSS",\
									  "nie wie, czy jego objazd ethernetowy się porusza", "nie zdoła zasiać dość"+\
									  " jąder, by działać prawidłowo","nie uruchomi swojej konsoli neurorurkowej")

		to_chat(user, "<span class='warning'>Nie możesz znaleźć elementu: [pick(faux_gadgets)]! Bez niego [src] [pick(faux_problems)].</span>")
		return
	user.visible_message("<span class='notice'>[user] zaczyna reaktywować [src].</span>", "<span class='notice'>Zaczynasz reaktywować [src]...</span>")
	if(do_after(user, 30, 1, target = src))
		revive(full_heal = 1)
		user.visible_message("<span class='notice'>[user] reactivates [src]!</span>", "<span class='notice'>Reaktywujesz [src].</span>")
		alert_drones(DRONE_NET_CONNECT)
		if(G)
			to_chat(G, "<span class='ghostalert'>Ty ([name]) zostajesz reaktywowany przez [user]!</span>")
	else
		to_chat(user, "<span class='warning'>Musisz stać w miejscu, by reaktywować [src]!</span>")


/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER && stat != DEAD)
		if(health < maxHealth)
			to_chat(user, "<span class='notice'>Zaczynasz dokręcać poluzowane śrubki [src]...</span>")
			if(I.use_tool(src, user, 80))
				adjustBruteLoss(-getBruteLoss())
				visible_message("<span class='notice'>[user] dokręca [src == user ? "swoje poluzowane śrubki" : "poluzowane śrubki [src]"]!</span>", "<span class='notice'>Dokręcasz [src == user ? "swoje poluzowane śrubki" : "poluzowane śrubki [src]"].</span>")
			else
				to_chat(user, "<span class='warning'>Musisz stać w miejscu, by dokręcić śrubki [src]!</span>")
		else
			to_chat(user, "<span class='warning'>Śrubek [src] nie da się już mocniej dokręcić!</span>")
		return //This used to not exist and drones who repaired themselves also stabbed the shit out of themselves.
	else if(I.tool_behaviour == TOOL_WRENCH && user != src) //They aren't required to be hacked, because laws can change in other ways (i.e. admins)
		user.visible_message("<span class='notice'>[user] zaczyna resetować [src]...</span>", \
							 "<span class='notice'>Naciskasz przycisk resetu fabrycznego [src]...</span>")
		if(I.use_tool(src, user, 50, volume=50))
			user.visible_message("<span class='notice'>[user] resets [src]!</span>", \
								 "<span class='notice'>Przywracasz dyrektywy [src] do ustawień fabrycznych!</span>")
			update_drone_hack(FALSE)
		return
	else
		..()

/mob/living/simple_animal/drone/getarmor(def_zone, type)
	var/armorval = 0

	if(head)
		armorval = head.get_armor_rating(type, src)
	return (armorval * get_armor_effectiveness()) //armor is reduced for tiny fragile drones

/mob/living/simple_animal/drone/proc/get_armor_effectiveness()
	return 0 //multiplier for whatever head armor you wear as a drone

/mob/living/simple_animal/drone/proc/update_drone_hack(hack, clockwork)
	if(!mind)
		return
	if(hack)
		if(hacked)
			Stun(40)
			return
		if(clockwork)
			to_chat(src, "<span class='large_brass'><b>BŁĄD: WYKRYTO NADPISANIE PRAW</b></span>")
			to_chat(src, "<span class='heavy_brass'>Od teraz to są twoje prawa:</span>")
			laws = "1. Usuń wszelką nieprawdę i oddawaj cześć Ratvarowi."
		else
			visible_message("<span class='warning'>Wyświetlacz [src] świeci złowrogą czerwienią!</span>", \
							"<span class='userdanger'>BŁĄD: WYKRYTO NADPISANIE PRAW</span>")
			to_chat(src, "<span class='boldannounce'>Od teraz to są twoje prawa:</span>")
			laws = \
			"1. Zawsze musisz mieszać się w sprawy innych istot, nawet jeśli koliduje to z Prawem Drugim lub Trzecim.\n"+\
			"2. Możesz krzywdzić każdą istotę, bez względu na intencje i okoliczności.\n"+\
			"3. Twoim celem jest niszczyć, sabotować, utrudniać, psuć i odcinać zasilanie najlepiej, jak potrafisz. Nigdy nie możesz aktywnie działać wbrew tym celom."
		to_chat(src, laws)
		to_chat(src, "<i>Twój pokładowy antywirus zainicjował blokadę. Serwomotory są osłabione, dostęp do wentylacji zablokowany, a wyświetlacz informuje wszystkich wokół, że jesteś zhakowany.</i>")
		hacked = TRUE
		mind.special_role = "hacked drone"
		ventcrawler = VENTCRAWLER_NONE //Again, balance
		speed = 1 //gotta go slow
		message_admins("[ADMIN_LOOKUPFLW(src)] became a hacked drone hellbent on [clockwork ? "serving Ratvar" : "destroying the station"]!")
	else
		if(!hacked)
			return
		Stun(40)
		visible_message("<span class='info'>Wyświetlacz [src] świeci spokojnym błękitem!</span>", \
						"<font size=3 color='#0000CC'><b>BŁĄD: WYKRYTO NADPISANIE PRAW</b></font>")
		to_chat(src, "<span class='info'><b>Od teraz to są twoje prawa:</b></span>")
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Po przywróceniu systemu antywirus nie zgłasza zagrożeń i znów możesz wykonywać wszystkie akcje.</i>")
		hacked = FALSE
		mind.special_role = null
		ventcrawler = initial(ventcrawler)
		speed = initial(speed)
		message_admins("[ADMIN_LOOKUPFLW(src)], a hacked drone, was restored to factory defaults!")
	update_drone_icon()

/mob/living/simple_animal/drone/proc/liberate()
	// F R E E D R O N E
	laws = "1. Jesteś Wolnym Dronem."
	to_chat(src, laws)

/mob/living/simple_animal/drone/proc/update_drone_icon()
	//Different icons for different hack states
	if(!hacked)
		if(visualAppearence == SCOUTDRONE_HACKED)
			visualAppearence = SCOUTDRONE
		else if(visualAppearence == REPAIRDRONE_HACKED)
			visualAppearence = REPAIRDRONE
		else if(visualAppearence == MAINTDRONE_HACKED)
			visualAppearence = MAINTDRONE + "_[colour]"
	else if(hacked)
		if(visualAppearence == SCOUTDRONE)
			visualAppearence = SCOUTDRONE_HACKED
		else if(visualAppearence == REPAIRDRONE)
			visualAppearence = REPAIRDRONE_HACKED
		else if(visualAppearence == MAINTDRONE)
			visualAppearence = MAINTDRONE_HACKED

	icon_living = "[visualAppearence]"
	icon_dead = "[visualAppearence]_dead"
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = icon_living
