// AQUILA - darkspawn: zdolności wspólne dla wszystkich klas (port z Yogstation)

// Divulge: zrzucenie ludzkiej skóry

/datum/action/cooldown/spell/divulge
	name = "Divulge"
	desc = "Zrzucasz ludzkie przebranie. To bardzo widowiskowe, więc rób to w ustronnym miejscu. Nie da się tego cofnąć."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "divulge"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = NONE
	/// Czy właśnie trwa zrzucanie skóry
	var/in_use = FALSE

/datum/action/cooldown/spell/divulge/can_cast_spell(feedback = TRUE)
	if(in_use)
		if(feedback)
			owner.balloon_alert(owner, "już trwa!")
		return FALSE
	return ..()

/datum/action/cooldown/spell/divulge/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(do_divulge), owner)

/datum/action/cooldown/spell/divulge/proc/do_divulge(mob/living/carbon/human/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>Musisz być bardziej człowiekiem, żeby to zrobić!</span>")
		return
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(darkspawn)
		if(!darkspawn.picked_class)
			to_chat(user, "<span class='warning'>Najpierw wybierz klasę w oknie antagonisty!</span>")
			return
		if(darkspawn.darkspawn_state != DARKSPAWN_MUNDANE) // już wcześniej zrzucił skórę, pomija całą ceremonię
			darkspawn.divulge()
			return

	var/turf/spot = get_turf(user)
	if(spot.get_lumcount() > DARKSPAWN_DIM_LIGHT)
		to_chat(user, "<span class='warning'>Skórę możesz zrzucić tylko w ciemności!</span>")
		return
	if(tgui_alert(user, "Możesz zrzucić skórę. To potrwa długo, a przez ten czas będziesz bezbronny. Na pewno?", name, list("Tak", "Nie")) != "Tak")
		return
	in_use = TRUE

	to_chat(user, "<span class='velvet'>Zaczynasz wznosić wokół siebie psioniczną barierę...</span>")
	if(!do_after(user, 3 SECONDS, target = user))
		in_use = FALSE
		return
	for(var/turf/T in RANGE_TURFS(1, user))
		if(isclosedturf(T))
			continue
		new /obj/structure/psionic_barrier(T, 35 SECONDS)
	user.visible_message("<span class='warning'>Wokół [user] wiruje fioletowa energia!</span>", "<span class='velvet'>Bariera do pewnego stopnia cię osłoni...</span>")

	notify_ghosts("Darkspawn [user.real_name] zaczyna zrzucać skórę w: [get_area(user)]!", ghost_sound = 'aquila/sound/darkspawn/devour_will_victim.ogg', source = user, action = NOTIFY_ORBIT)

	user.visible_message("<span class='danger'>[user] powoli unosi się w powietrze, gubiąc swoje rzeczy, i zaczyna migotać...</span>", "<span class='velvet'>Zaczynasz zrzucać ludzkie przebranie. Przez ten czas będziesz zupełnie bezbronny.</span>")
	user.setDir(SOUTH)
	user.unequip_everything()

	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Powietrze drży. Oczy [user] zaczynają świecić głębokim fioletem.</span>", \
					"<span class='velvet'>Psi zalewa twoją świadomość. Czujesz, jak umysł nabiera mocy... <i>rozszerza się.</i></span>")
				playsound(user, 'aquila/sound/darkspawn/divulge_01.ogg', 30, FALSE)
			if(2)
				user.visible_message("<span class='userdanger'>Grawitacja faluje. Psioniczne macki wyciągają się i macają na oślep wokół.</span>", \
					"<span class='velvet'>Grawitacja wokół ciebie faluje. Niepewnie sięgasz umysłem na zewnątrz.</span>")
				user.do_jitter_animation(500)
				playsound(user, 'aquila/sound/darkspawn/divulge_02.ogg', 40, FALSE)
			if(3)
				user.visible_message("<span class='userdanger'>Na ciele [user] pojawiają się sigile. Skóra czernieje, a [user.p_they()] świeci oślepiającym fioletem.</span>", \
					"<span class='velvet'>Twoje ciało zaczyna się wypaczać. Sigile wyżłabiają się w twoim ciele.</span>")
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 10 SECONDS)
				playsound(user, 'aquila/sound/darkspawn/divulge_03.ogg', 50, FALSE)
		if(!do_after(user, 10 SECONDS, target = user))
			user.visible_message("<span class='warning'>[user] spada na ziemię!</span>", "<span class='userdanger'>Przemiana została przerwana!</span>")
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 1 SECONDS)
			in_use = FALSE
			return

	playsound(user, 'aquila/sound/darkspawn/divulge_ending.ogg', 50, FALSE)
	user.visible_message("<span class='userdanger'>[user] unosi się w powietrze, trzeszcząc od mocy!</span>", "<span class='velvet bold'>Twój umysł...! nie może--- MYŚLEĆ--</span>")
	animate(user, pixel_y = user.pixel_y + 8, time = 6 SECONDS)
	sleep(4.5 SECONDS)
	if(QDELETED(user))
		return

	user.do_jitter_animation(1000)
	var/list/spooky = list("J- J- J-", "Umysł-", "Sigile-", "Nie mogę myśleć-", "<i>MOC-</i>", "<i>BIERZ-</i>", "W-W-WIĘCEJ-", "<i>MYŚL-</i>", "PRZYJMIJ-", "STAŃ SIĘ-")
	for(var/i in 1 to 40)
		to_chat(user, "<span class='velvet bold'>[pick(spooky)]</span>")
		sleep(0.05 SECONDS)

	user.visible_message("<span class='userdanger'>Od [user] rozchodzi się potężna fala uderzeniowa!</span>", "<span class='velvet big'>JESTEŚ WOLNY!!</span>")
	playsound(user, 'aquila/sound/darkspawn/divulge_end.ogg', 50, FALSE)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 3 SECONDS)

	for(var/mob/living/L in view(7, user))
		if(L == user || is_team_darkspawn(L))
			continue
		L.flash_act(1, 1)
		L.Knockdown(5 SECONDS)

	in_use = FALSE
	darkspawn?.divulge()

// Sakrament: przemiana w potomka

/datum/action/cooldown/spell/sacrament
	name = "Sakrament"
	desc = "Wznosisz się jako potomek. Wymaga wyssania jasności z określonej liczby różnych osób."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "sacrament"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	var/datum/looping_sound/sacrament/soundloop
	var/datum/antagonist/darkspawn/darkspawn
	/// Czy właśnie trwa Sakrament
	var/in_use = FALSE

/datum/action/cooldown/spell/sacrament/Destroy()
	QDEL_NULL(soundloop)
	darkspawn = null
	return ..()

/datum/action/cooldown/spell/sacrament/can_cast_spell(feedback = TRUE)
	if(in_use)
		if(feedback)
			owner.balloon_alert(owner, "już trwa!")
		return FALSE
	return ..()

/datum/action/cooldown/spell/sacrament/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(do_sacrament), owner)

/datum/action/cooldown/spell/sacrament/proc/do_sacrament(mob/living/carbon/human/user)
	darkspawn = isdarkspawn(user)
	if(!darkspawn)
		return
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(!team)
		stack_trace("Darkspawn without a team tried to perform the sacrament")
		return
	if(team.lucidity < team.required_succs)
		to_chat(user, "<span class='warning'>Brakuje ci jasności z różnych umysłów! ([team.lucidity] / [team.required_succs])</span>")
		return
	if(tgui_alert(user, "Sakrament jest gotowy! Jesteś przygotowany?", name, list("Tak", "Nie")) != "Tak")
		return
	if(GLOB.sacrament_done)
		darkspawn.sacrament() // ktoś już odprawił Sakrament, od razu do sedna
		return
	if(!ishuman(user))
		return

	darkspawn.mindlink_message("<span class='velvet bold'>\[Mindlink\] [user] zaczyna odprawiać Sakrament.</span>")
	in_use = TRUE

	user.visible_message("<span class='warning'>Sigile [user] rozbłyskują, a wokół wiruje energia...</span>", "<span class='velvet'>Zaczynasz wznosić wokół siebie psioniczną barierę...</span>")
	sound_to_playing_players('aquila/sound/darkspawn/sacrament_begin.ogg', 50, FALSE, pressure_affected = FALSE)
	if(!do_after(user, 3 SECONDS, target = user))
		in_use = FALSE
		return
	user.visible_message("<span class='warning'>Wokół [user] wiruje fioletowa energia!</span>", "<span class='velvet'>Bariera cię ochroni.</span>")
	for(var/turf/T in RANGE_TURFS(2, user))
		if(isclosedturf(T))
			continue
		new /obj/structure/psionic_barrier(T, 34 SECONDS)

	notify_ghosts("Darkspawn [user.real_name] zaczyna Sakrament w: [get_area(user)]!", ghost_sound = 'aquila/sound/darkspawn/devour_will_victim.ogg', source = user, action = NOTIFY_ORBIT)
	soundloop = new(GLOB.player_list, TRUE, TRUE)

	user.visible_message("<span class='danger'>[user] nagle szarpie się w powietrze, pulsując wrzeszczącym fioletowym światłem.</span>", "<span class='velvet bold'>Zaczynasz Sakrament.</span>")

	for(var/stage in 1 to 2)
		soundloop.stage = stage
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Sigile [user] wyją światłem. Kończyny skręcają się, a po chitynie biegną świecące pęknięcia.</span>", \
					"<span class='velvet'>Moc... <i>moc...</i> płynie przez ciebie, a sny i myśli pożartych wól szepczą ci do ucha...</span>")
				sound_to_playing_players('aquila/sound/darkspawn/sacrament_01.ogg', 20, FALSE, pressure_affected = FALSE)
			if(2)
				for(var/turf/T in range(10, user))
					if(prob(10))
						addtimer(CALLBACK(src, PROC_REF(unleashed_psi), T), rand(1, 15 SECONDS))
				animate(user, transform = matrix() * 2, time = 15 SECONDS)
				user.visible_message("<span class='userdanger'>[user] zaczyna... <i>rosnąć.</i></span>", "<span class='velvet bold'>Twoja śmiertelna skorupa zaczyna pękać od narastającej mocy!</span>")
				sound_to_playing_players('aquila/sound/darkspawn/sacrament_02.ogg', 20, FALSE, pressure_affected = FALSE)
		if(!do_after(user, 15 SECONDS, target = user))
			user.visible_message("<span class='warning'>[user] spada na ziemię!</span>", "<span class='userdanger'>Przemiana została przerwana!</span>")
			animate(user, transform = matrix(), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
			in_use = FALSE
			QDEL_NULL(soundloop)
			return

	soundloop.stage = 3
	animate(user, pixel_y = user.pixel_y + 20, time = 4 SECONDS)
	user.visible_message("<span class='userdanger'>[user] unosi się w powietrze, trzeszcząc od mocy!</span>")
	for(var/turf/T in range(10, user))
		if(prob(35))
			addtimer(CALLBACK(src, PROC_REF(unleashed_psi), T), rand(1, 40))
	addtimer(CALLBACK(src, PROC_REF(finalize), user), 3 SECONDS) // złowieszczo cicha chwila

/datum/action/cooldown/spell/sacrament/proc/finalize(mob/living/carbon/human/user)
	to_chat(user, "<span class='velvet big'>A SŁABI POZNAJĄ <i>STRACH--</i></span>")
	sound_to_playing_players('aquila/sound/darkspawn/sacrament_ending.ogg', 75, FALSE, pressure_affected = FALSE)
	QDEL_IN(soundloop, 1 SECONDS)
	addtimer(CALLBACK(darkspawn, TYPE_PROC_REF(/datum/antagonist/darkspawn, sacrament)), 1 SECONDS)

/datum/action/cooldown/spell/sacrament/proc/unleashed_psi(turf/T)
	if(!in_use)
		return
	playsound(T, 'aquila/sound/darkspawn/divulge_end.ogg', 25, FALSE)
	new /obj/effect/temp_visual/revenant/cracks(T)

// Pożarcie woli: główna zdolność do zdobywania jasności i woli

/obj/item/melee/spell_hand/darkspawn
	name = "Psionic hand"
	desc = "Skupiona psioniczna moc, gotowa bawić się śmiertelnymi umysłami."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "hivemind"

/obj/item/melee/spell_hand/devour_will
	name = "dark bead"
	desc = "Skupiona psioniczna moc, gotowa bawić się śmiertelnymi umysłami."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "hivemind"

/datum/action/cooldown/spell/touch/devour_will
	name = "Pożarcie woli"
	desc = "Tworzy ciemny paciorek. Przyłożony do człowieka zaczyna wysysać z niego jasność i wolę, na jakiś czas pozbawiając przytomności.<br>Przerwanie powala cię na ziemię."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "devour_will"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 5)
	hand_path = /obj/item/melee/spell_hand/devour_will
	/// Czy właśnie wysysa czyjąś wolę
	var/eating = FALSE

/datum/action/cooldown/spell/touch/devour_will/can_cast_spell(feedback = TRUE)
	if(eating)
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/devour_will/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/touch/devour_will/create_hand(mob/living/carbon/cast_on)
	. = ..()
	if(.)
		playsound(owner, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)

/datum/action/cooldown/spell/touch/devour_will/cast_on_hand_hit(obj/item/melee/spell_hand/hand, mob/living/carbon/target, mob/living/carbon/caster)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
	if(!darkspawn || eating || target == caster)
		return FALSE
	if(!target.mind)
		to_chat(caster, "<span class='warning'>Nie da się wyssać kogoś bez umysłu.</span>")
		return FALSE
	if(is_team_darkspawn(target))
		to_chat(caster, "<span class='warning'>Nie możesz wysysać sojuszników.</span>")
		return FALSE
	if(target.stat == DEAD)
		to_chat(caster, "<span class='warning'>[target] jest zbyt słaby, żeby go wyssać.</span>")
		return FALSE
	if(get_shadow_tumor(target))
		to_chat(caster, "<span class='danger'>W umyśle [target] tkwi już ciemny paciorek.</span>")
		return FALSE

	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(!team)
		CRASH("darkspawn without a team is trying to devour someone")

	caster.Immobilize(1 SECONDS) // żeby się przypadkiem nie ruszyć
	target.Immobilize(10 SECONDS)
	target.silent += 5

	caster.balloon_alert(caster, "Cera ko...")
	to_chat(caster, "<span class='velvet'>Zaczynasz wysysać wolę [target]...</span>")
	target.emote("scream")
	target.visible_message("<span class='danger'><i>[target] nagle wyje i łapie się za twarz, a z oczu bije wrzeszczące fioletowe światło!</i></span>", "<span class='userdanger'><i>AAAAAAAAAAAAAAA-</i></span>")
	playsound(target, 'aquila/sound/darkspawn/devour_will_long.ogg', 65, FALSE)

	eating = TRUE
	if(!do_after(caster, 5 SECONDS, target = target))
		to_chat(caster, "<span class='danger'>Przerwanie wywołuje wstrząs psionicznej mocy.</span>")
		caster.Immobilize(5 SECONDS)
		caster.Knockdown(10 SECONDS)
		to_chat(target, "<span class='boldwarning'>Już dobrze... Wszystko w porządku.</span>")
		target.SetImmobilized(0)
		eating = FALSE
		return FALSE
	eating = FALSE

	if(get_shadow_tumor(target))
		to_chat(caster, "<span class='danger'>W umyśle [target] tkwi już ciemny paciorek.</span>")
		return FALSE

	// usypia ofiarę przed komunikatem, żeby go nie widziała
	to_chat(target, "<span class='velvet bold'>Nagle czujesz się... pusty. Myśli próbują się uformować, ale się rozpierzchają. Zapadasz w głęboki, głęboki sen...</span>")
	playsound(target, 'aquila/sound/darkspawn/devour_will_end.ogg', 75, FALSE)
	target.playsound_local(target, 'aquila/sound/darkspawn/devour_will_victim.ogg', 50, FALSE)
	caster.balloon_alert(caster, "...akkraup'dej")

	var/obj/item/organ/shadowtumor/bead = target.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(!istype(bead))
		bead = new
		bead.Insert(target, FALSE, FALSE)
		bead.antag_team = team

	var/list/self_text = list()
	if(!HAS_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED))
		ADD_TRAIT(target, TRAIT_DARKSPAWN_DEVOURED, type)
		self_text += "<span class='velvet'>Umieszczasz ciemny paciorek głęboko w umyśle [target].</span>"
		self_text += "<span class='velvet'>Jasność tej osoby przybliża cię o krok do Sakramentu...</span>"
		self_text += "<span class='velvet'>Karmisz się też jej wolą, zyskując 2 punkty woli.</span>"
		self_text += "<span class='velvet'>Kolejne wysysanie tej osoby nie da już ani woli, ani jasności.</span>"
		team.grant_willpower(2)
		team.grant_lucidity(1)
	else
		self_text += "<span class='velvet'>Odnawiasz ciemny paciorek w umyśle [target].</span>"

	caster.visible_message("<span class='warning'>[caster] delikatnie kładzie [target] na ziemi...</span>", self_text.Join("<br>"))
	target.apply_status_effect(/datum/status_effect/broken_will)
	return TRUE

// Srebrny język: odwołanie promu z konsoli komunikacyjnej

/datum/action/cooldown/spell/touch/silver_tongue
	name = "Srebrny język"
	desc = "Przy konsoli komunikacyjnej pozwala siłą nadać wiadomość do CentComu i odwołać prom. Działa tylko, gdy prom jest w drodze. Kosztuje 60 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "silver_tongue"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 60)
	hand_path = /obj/item/melee/spell_hand/darkspawn
	var/in_use = FALSE
	/// Jak długo trwa nadawanie
	var/duration = 8 SECONDS

/datum/action/cooldown/spell/touch/silver_tongue/can_cast_spell(feedback = TRUE)
	if(SSshuttle.emergency.mode != SHUTTLE_CALL || in_use)
		if(feedback)
			to_chat(owner, "<span class='warning'>Prom nie jest w drodze.</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/silver_tongue/is_valid_target(atom/cast_on)
	return istype(cast_on, /obj/machinery/computer/communications)

/datum/action/cooldown/spell/touch/silver_tongue/cast_on_hand_hit(obj/item/melee/spell_hand/hand, obj/machinery/computer/communications/target, mob/living/carbon/caster)
	if(in_use)
		return FALSE
	if(target.machine_stat & (NOPOWER|BROKEN))
		to_chat(caster, "<span class='warning'>[target] nie ma zasilania.</span>")
		return FALSE
	caster.balloon_alert(caster, pick("Pda ykw'lpwe skwo h'kccaz ej.", "Pda aiank'cajyu eo kran.", "Oknnu, bkn swop'ejc ukqn pkza.", "Wke swo kxn'znaz xu hws psk."))
	caster.visible_message("<span class='warning'>[caster] na chwilę dotyka ekranu [target], a klawisze zaczynają same się poruszać!</span>", "<span class='velvet'>Zaczynasz nadawać do CentComu wiadomość o odwołaniu promu...</span>")
	in_use = TRUE
	play_recall_sounds(target, (duration / 10) - 1)
	if(!do_after(caster, duration, target = target))
		in_use = FALSE
		return FALSE
	in_use = FALSE
	if(QDELETED(target) || (target.machine_stat & (NOPOWER|BROKEN)))
		to_chat(caster, "<span class='warning'>[target] stracił zasilanie.</span>")
		return FALSE
	SSshuttle.emergency.cancel()
	to_chat(caster, "<span class='velvet'>Podstęp się udał. Prom zawraca.</span>")
	return TRUE

/datum/action/cooldown/spell/touch/silver_tongue/proc/play_recall_sounds(obj/machinery/C, iterations)
	if(QDELETED(C) || !in_use)
		return
	playsound(C, "terminal_type", 50, TRUE)
	if(prob(25))
		playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
		do_sparks(5, TRUE, get_turf(C))
	if(iterations <= 0)
		addtimer(CALLBACK(src, PROC_REF(end_recall_sounds), C), 0.4 SECONDS)
	else
		addtimer(CALLBACK(src, PROC_REF(play_recall_sounds), C, iterations - 1), 1 SECONDS)

/datum/action/cooldown/spell/touch/silver_tongue/proc/end_recall_sounds(obj/machinery/C)
	if(QDELETED(C) || !in_use)
		return
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE), 0.4 SECONDS)

// Budowanie z cieni: wspólna baza zdolności, które coś stawiają

/datum/action/cooldown/spell/pointed/darkspawn_build
	name = "Darkspawn building thing"
	desc = "Tego nie powinno być widać."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "sacrament(old)"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 35)
	cooldown_time = 15 SECONDS
	cast_range = 2
	aim_assist = FALSE
	/// Czy właśnie coś buduje
	var/casting = FALSE
	/// Jak długo trwa budowanie
	var/cast_time = 2 SECONDS
	/// Co stawia
	var/object_type
	/// Czy można stawiać na polu z czymś gęstym
	var/can_density = FALSE
	/// Ostatnie słowa przy stawianiu (dla klimatu)
	var/language_final = "xom"

/datum/action/cooldown/spell/pointed/darkspawn_build/can_cast_spell(feedback = TRUE)
	if(casting)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/darkspawn_build/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/darkspawn_build/before_cast(atom/cast_on)
	. = ..()
	if(!object_type)
		stack_trace("[type] has no object_type")
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	var/turf/target_turf = get_turf(cast_on)
	if(!target_turf || (!can_density && (target_turf.density || is_blocked_turf(target_turf, TRUE))))
		owner.balloon_alert(owner, "tu się nie da!")
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(cast_time)
		casting = TRUE
		owner.balloon_alert(owner, "Xkla'thra...")
		playsound(get_turf(owner), 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
		if(!do_after(owner, cast_time, target = cast_on))
			casting = FALSE
			return . | SPELL_CANCEL_CAST
		casting = FALSE

/datum/action/cooldown/spell/pointed/darkspawn_build/cast(atom/cast_on)
	. = ..()
	if(!object_type)
		return
	playsound(get_turf(cast_on), 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	var/obj/thing = new object_type(get_turf(cast_on), owner)
	owner.balloon_alert(owner, "...[language_final]")
	owner.visible_message("<span class='warning'>[owner] splata cienie w [thing]!</span>", "<span class='velvet'>Tworzysz: [thing].</span>")

// Odtworzenie ciała z mózgu w MMI albo borgu

/datum/action/cooldown/spell/reform_body
	name = "Odtworzenie ciała"
	desc = "Straciłeś ciało, ale to bez znaczenia."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "sacrament(old)"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = NONE
	spell_requirements = SPELL_CASTABLE_AS_BRAIN

/datum/action/cooldown/spell/reform_body/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/darkspawn/darkmind = isdarkspawn(owner)
	darkmind?.reform_body()
