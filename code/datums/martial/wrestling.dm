/mob/living/carbon/human/proc/wrestling_help()
	set name = "Recall Teachings"
	set desc = "Remember how to wrestle."
	set category = "Wrestling"

	to_chat(usr, "<b><i>Napinasz mięśnie i doznajesz objawienia...</i></b>")
	to_chat(usr, "<span class='notice'>Klincz</span>: chwyt. Biernie daje szansę na natychmiastowe agresywne chwycenie kogoś. Nie zawsze się udaje.")
	to_chat(usr, "<span class='notice'>Suplex</span>: rozbrój kogoś, kogo trzymasz. Rzuca cel suplexem na podłogę. Mocno go rani i zostawia was oboje na ziemi.")
	to_chat(usr, "<span class='notice'>Zaawansowany chwyt</span>: chwyt. Biernie zadaje obrażenia wytrzymałości podczas chwytania.")

/datum/martial_art/wrestling
	name = "Wrestling"
	id = MARTIALART_WRESTLING
	var/datum/action/slam/slam = new/datum/action/slam()
	var/datum/action/throw_wrassle/throw_wrassle = new/datum/action/throw_wrassle()
	var/datum/action/kick/kick = new/datum/action/kick()
	var/datum/action/strike/strike = new/datum/action/strike()
	var/datum/action/drop/drop = new/datum/action/drop()

/datum/martial_art/wrestling/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("drop")
			streak = ""
			drop(A,D)
			return 1
		if("strike")
			streak = ""
			strike(A,D)
			return 1
		if("kick")
			streak = ""
			kick(A,D)
			return 1
		if("throw")
			streak = ""
			throw_wrassle(A,D)
			return 1
		if("slam")
			streak = ""
			slam(A,D)
			return 1
	return 0

/datum/action/slam
	name = "Slam (Cinch) - Slam a grappled opponent into the floor."
	button_icon_state = "wrassle_slam"

/datum/action/slam/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Nie możesz ZAPASOWAĆ, gdy jesteś LICZONY DO DZIESIĘCIU.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] szykuje się do BODY SLAMU!</span>", "<b><i>Twoim następnym atakiem będzie BODY SLAM.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "slam"

/datum/action/throw_wrassle
	name = "Throw (Cinch) - Spin a cinched opponent around and throw them."
	button_icon_state = "wrassle_throw"

/datum/action/throw_wrassle/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Nie możesz ZAPASOWAĆ, gdy jesteś LICZONY DO DZIESIĘCIU.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] szykuje się do RZUTU!</span>", "<b><i>Twoim następnym atakiem będzie RZUT.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "throw"

/datum/action/kick
	name = "Kick - A powerful kick, sends people flying away from you. Also useful for escaping from bad situations."
	button_icon_state = "wrassle_kick"

/datum/action/kick/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Nie możesz ZAPASOWAĆ, gdy jesteś LICZONY DO DZIESIĘCIU.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] szykuje się do KOPNIĘCIA!</span>", "<b><i>Twoim następnym atakiem będzie KOPNIĘCIE.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "kick"

/datum/action/strike
	name = "Strike - Hit a neaby opponent with a quick attack."
	button_icon_state = "wrassle_strike"

/datum/action/strike/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Nie możesz ZAPASOWAĆ, gdy jesteś LICZONY DO DZIESIĘCIU.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] szykuje się do UDERZENIA!</span>", "<b><i>Twoim następnym atakiem będzie UDERZENIE.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "strike"

/datum/action/drop
	name = "Drop - Smash down onto an opponent."
	button_icon_state = "wrassle_drop"

/datum/action/drop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>Nie możesz ZAPASOWAĆ, gdy jesteś LICZONY DO DZIESIĘCIU.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] szykuje się do LEG DROPU!</span>", "<b><i>Twoim następnym atakiem będzie LEG DROP.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "drop"

/datum/martial_art/wrestling/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>CHRUP, I MASZ SLIM JIMA!</span>")
		to_chat(H, "<span class = 'danger'>Najedź kursorem na ruch u góry ekranu, by zobaczyć, co robi.</span>")
		drop.Grant(H)
		kick.Grant(H)
		slam.Grant(H)
		throw_wrassle.Grant(H)
		strike.Grant(H)

/datum/martial_art/wrestling/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>Nie czujesz już, że wieża mocy jest zbyt słodka, by być kwaśną...</span>")
	drop.Remove(H)
	kick.Remove(H)
	slam.Remove(H)
	throw_wrassle.Remove(H)
	strike.Remove(H)

/datum/martial_art/wrestling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "punched with wrestling")
	..()

/datum/martial_art/wrestling/proc/throw_wrassle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, "Musisz trzymać [D] w klinczu!")
		return
	D.forceMove(A.loc)
	D.setDir(get_dir(D, A))

	D.Stun(80)
	D.visible_message("<span class='danger'><B>[A] zaczyna kręcić się z [D]!</B></span>", \
					"<span class='userdanger'>[A] zaczyna kręcić się z tobą!</span>")
	A.emote("scream")

	for (var/i = 0, i < 20, i++)
		var/delay = 5
		switch (i)
			if (17 to INFINITY)
				delay = 0.25
			if (14 to 16)
				delay = 0.5
			if (9 to 13)
				delay = 1
			if (5 to 8)
				delay = 2
			if (0 to 4)
				delay = 3

		if (A && D)

			if (get_dist(A, D) > 1)
				to_chat(A, "[D] jest za daleko!")
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, "Nie możesz stąd rzucić [D]!")
				return 0

			A.setDir(turn(A.dir, 90))
			var/turf/T = get_step(A, A.dir)
			var/turf/S = D.loc
			var/direction = get_dir(D, A)
			if ((S && isturf(S) && S.Exit(D, direction)) && (T && isturf(T) && T.Enter(A)))
				D.forceMove(T)
				D.setDir(direction)
		else
			return 0

		sleep(delay)

	if (A && D)
		// These are necessary because of the sleep call.

		if (get_dist(A, D) > 1)
			to_chat(A, "[D] jest za daleko!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, "Nie możesz stąd rzucić [D]!")
			return 0

		D.forceMove(A.loc) // Maybe this will help with the wallthrowing bug.

		D.visible_message("<span class='danger'><B>[A] throws [D]!</B></span>", \
						"<span class='userdanger'>[A] tobą rzuca!</span>")
		playsound(A.loc, "swing_hit", 50, 1)
		var/turf/T = get_edge_target_turf(A, A.dir)
		if (T && isturf(T))
			if (!D.stat)
				D.emote("scream")
			D.throw_at(T, 10, 4, A, TRUE, TRUE, callback = CALLBACK(D, TYPE_PROC_REF(/mob/living/carbon/human, Paralyze), 20))
	log_combat(A, D, "has thrown with wrestling")
	return 0

/datum/martial_art/wrestling/proc/FlipAnimation(mob/living/carbon/human/D)
	set waitfor = FALSE
	if (D)
		animate(D, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	sleep(15)
	if (D)
		animate(D, transform = null, time = 1, loop = 0)

/datum/martial_art/wrestling/proc/slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, "Musisz trzymać [D] w klinczu!")
		return
	D.forceMove(A.loc)
	A.setDir(get_dir(A, D))
	D.setDir(get_dir(D, A))

	D.visible_message("<span class='danger'><B>[A] podnosi [D]!</B></span>", \
					"<span class='userdanger'>[A] cię podnosi!</span>")

	FlipAnimation()

	for (var/i = 0, i < 3, i++)
		if (A && D)
			A.pixel_y += 3
			D.pixel_y += 3
			A.setDir(turn(A.dir, 90))
			D.setDir(turn(D.dir, 90))

			switch (A.dir)
				if (NORTH)
					D.pixel_x = A.pixel_x
				if (SOUTH)
					D.pixel_x = A.pixel_x
				if (EAST)
					D.pixel_x = A.pixel_x - 8
				if (WEST)
					D.pixel_x = A.pixel_x + 8

			if (get_dist(A, D) > 1)
				to_chat(A, "[D] jest za daleko!")
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, "Nie możesz tu rzucić [D] o ziemię!")
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return 0
		else
			if (A)
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
			if (D)
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
			return 0

		sleep(1)

	if (A && D)
		A.pixel_x = A.base_pixel_x
		A.pixel_y = A.base_pixel_y
		D.pixel_x = D.base_pixel_x
		D.pixel_y = D.base_pixel_y

		if (get_dist(A, D) > 1)
			to_chat(A, "[D] jest za daleko!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, "Nie możesz tu rzucić [D] o ziemię!")
			return 0

		D.forceMove(A.loc)

		var/fluff = "body-slam"
		switch(pick(2,3))
			if (2)
				fluff = "turbo [fluff]"
			if (3)
				fluff = "atomic [fluff]"

		D.visible_message("<span class='danger'><B>[A] [fluff] [D]!</B></span>", \
						"<span class='userdanger'>[A] [fluff] cię!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(A.loc, "swing_hit", 50, 1)
		if (!D.stat)
			D.emote("scream")
			D.Paralyze(40)

			switch(rand(1,3))
				if (2)
					D.adjustBruteLoss(rand(20,30))
				if (3)
					D.ex_act(EXPLODE_LIGHT)
				else
					D.adjustBruteLoss(rand(10,20))
		else
			D.ex_act(EXPLODE_LIGHT)

	else
		if (A)
			A.pixel_x = 0
			A.pixel_y = 0
		if (D)
			D.pixel_x = 0
			D.pixel_y = 0


	log_combat(A, D, "body-slammed")
	return 0

/datum/martial_art/wrestling/proc/CheckStrikeTurf(mob/living/carbon/human/A, turf/T)
	if (A && (T && isturf(T) && get_dist(A, T) <= 1))
		A.forceMove(T)

/datum/martial_art/wrestling/proc/strike(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/turf/T = get_turf(A)
	if (T && isturf(T) && D && isturf(D.loc))
		for (var/i = 0, i < 4, i++)
			A.setDir(turn(A.dir, 90))

		A.forceMove(D.loc)
		addtimer(CALLBACK(src, PROC_REF(CheckStrikeTurf), A, T), 4)

		D.visible_message("<span class='danger'><B>[A] headbutts [D]!</B></span>", \
						"<span class='userdanger'>[A] uderza cię głową!</span>", null, COMBAT_MESSAGE_RANGE)
		D.adjustBruteLoss(rand(10,20))
		playsound(A.loc, "swing_hit", 50, 1)
		D.Unconscious(20)
	log_combat(A, D, "headbutted")

/datum/martial_art/wrestling/proc/kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	A.emote("scream")
	A.emote("flip")
	A.setDir(turn(A.dir, 90))

	D.visible_message("<span class='danger'><B>[A] kopie [D] z półobrotu!</B></span>", \
					"<span class='userdanger'>[A] kopie cię z półobrotu!</span>", null, COMBAT_MESSAGE_RANGE)
	playsound(A.loc, "swing_hit", 50, 1)
	D.adjustBruteLoss(rand(10,20))

	var/turf/T = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	if (T && isturf(T))
		D.Paralyze(20)
		D.throw_at(T, 3, 2)
	log_combat(A, D, "roundhouse-kicked")

/datum/martial_art/wrestling/proc/drop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/obj/surface = null
	var/turf/ST = null
	var/falling = 0

	for (var/obj/O in oview(1, A))
		if(O.density)
			if (O == D)
				continue
			if (O.opacity)
				continue
			else
				surface = O
				ST = get_turf(O)
				break

	if (surface && (ST && isturf(ST)))
		A.forceMove(ST)
		A.visible_message("<span class='danger'><B>[A] wspina się na [surface]!</B></span>", \
						"<span class='danger'><B>Wspinasz się na [surface]!</B></span>")
		A.pixel_y = A.base_pixel_y + 10
		falling = 1
		sleep(10)

	if (A && D)
		// These are necessary because of the sleep call.

		if ((falling == 0 && get_dist(A, D) > 1) || (falling == 1 && get_dist(A, D) > 2)) // We climbed onto stuff.
			A.pixel_y = A.base_pixel_y
			if (falling == 1)
				A.visible_message("<span class='danger'><B>...i nurkuje głową prosto w ziemię, auć!</B></span>", \
								"<span class='userdanger'>...i nurkujesz głową prosto w ziemię, auć!</span>")
				A.adjustBruteLoss(rand(10,20))
				A.Paralyze(60)
			to_chat(A, "[D] jest za daleko!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			A.pixel_y = A.base_pixel_y
			to_chat(A, "Nie możesz stąd spaść na [D]!")
			return 0

		if(A)
			animate(A, transform = matrix(90, MATRIX_ROTATE), time = 1, loop = 0)
		sleep(10)
		if(A)
			animate(A, transform = null, time = 1, loop = 0)

		A.forceMove(D.loc)

		D.visible_message("<span class='danger'><B>[A] spada nogą na [D]!</B></span>", \
									"<span class='userdanger'>[A] spada na ciebie nogą!</span>")
		playsound(A.loc, "swing_hit", 50, 1)
		A.emote("scream")

		if (falling == 1)
			if (prob(33) || D.stat)
				D.ex_act(EXPLODE_LIGHT)
			else
				D.adjustBruteLoss(rand(20,30))
		else
			D.adjustBruteLoss(rand(20,30))

		D.Paralyze(40)

		A.pixel_y = A.base_pixel_y

	else
		if (A)
			A.pixel_y = A.base_pixel_y
	log_combat(A, D, "leg-dropped")
	return

/datum/martial_art/wrestling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "wrestling-disarmed")
	..()

/datum/martial_art/wrestling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	if(A.pulling == D)
		return 1
	A.start_pulling(D)
	D.visible_message("<span class='danger'>[A] łapie [D] w klincz!</span>", \
								"<span class='userdanger'>[A] łapie cię w klincz!</span>", null, COMBAT_MESSAGE_RANGE)
	D.Stun(rand(60,100))
	log_combat(A, D, "cinched")
	return 1

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_BELT)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(H)
