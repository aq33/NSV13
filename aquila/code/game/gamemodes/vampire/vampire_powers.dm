/obj/effect/proc_holder/spell
	var/gain_desc
	var/blood_used = 0
	var/vamp_req = FALSE

/obj/effect/proc_holder/spell/cast_check(skipcharge = 0, mob/user = usr)
	if(vamp_req)
		if(!is_vampire(user))
			return FALSE
		var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V)
			return FALSE
		if(V.usable_blood < blood_used)
			to_chat(user, "<span class='warning'>Masz za mało krwi, żeby tego użyć!</span>")
			return FALSE
	. = ..(skipcharge, user)

/obj/effect/proc_holder/spell/Initialize()
	. = ..()
	if(vamp_req)
		clothes_req = FALSE
		range = 1
		human_req = FALSE //so we can cast stuff while a bat, too


/obj/effect/proc_holder/spell/before_cast(list/targets)
	. = ..()
	if(vamp_req)
		// sanity check before we cast
		if(!is_vampire(usr))
			targets.Cut()
			return

		if(!blood_used)
			return

		// enforce blood
		var/datum/antagonist/vampire/vampire = usr.mind.has_antag_datum(/datum/antagonist/vampire)

		if(blood_used <= vampire.usable_blood)
			vampire.usable_blood -= blood_used
		else
			// stop!!
			targets.Cut()

		if(LAZYLEN(targets))
			to_chat(usr, "<span class='notice'><b>Krew do wykorzystania: [vampire.usable_blood].</b></span>")


/obj/effect/proc_holder/spell/can_target(mob/living/target)
	. = ..()
	if(vamp_req && is_vampire(target))
		return FALSE

/// Gives back blood spent on a vampire spell, e.g. when the cast fails partway through
/obj/effect/proc_holder/spell/proc/refund_vampire_blood(mob/user, amount = blood_used)
	var/datum/antagonist/vampire/V = is_vampire(user)
	if(!V || !amount)
		return
	V.usable_blood += amount
	to_chat(user, "<span class='notice'><b>Krew do wykorzystania: [V.usable_blood].</b></span>")

/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "<span class='notice'>Zyskujesz zdolność: [src].</span>"


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/vampire_passive/nostealth
	gain_desc = "<span class='warning'>Nie możesz już się ukrywać podczas wysysania krwi.</span>" //gets a warning span because it's a downgrade

/datum/vampire_passive/regen
	gain_desc = "<span class='notice'>Twoje wrodzone zdolności regeneracyjne się poprawiły, dając bierne leczenie. Odmłodzenie pomaga teraz też zmniejszyć efekty obezwładniające.</span>"

/datum/vampire_passive/vision
	gain_desc = "<span class='notice'>Twój wampirzy wzrok się poprawił.</span>"

/datum/vampire_passive/full
	gain_desc = "<span class='notice'>Osiągasz pełnię możliwości - nie jesteś już podatny na nic świętego, a twój wzrok znacznie się poprawił.</span>"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/self/rejuvenate
	name = "Rejuvenate (20)"
	desc= "Flush your system with some spare blood to restore stamina over time."
	action_icon_state = "rejuv"
	charge_max = 200
	stat_allowed = 1
	blood_used = 20
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/rejuvenate/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		return
	heal(user)

/obj/effect/proc_holder/spell/self/rejuvenate/proc/heal(mob/living/carbon/user, iterations = 1)
	if(iterations > 5 || QDELETED(user)) //5 total instances of stam heal each split by 1 second
		return
	user.stuttering = 0

	var/datum/antagonist/vampire/V = is_vampire(user)
	if(!V) //sanity check
		return
	user.adjustStaminaLoss(-50)
	if(V.get_ability(/datum/vampire_passive/regen))
		user.AdjustAllImmobility(-1 SECONDS)
	addtimer(CALLBACK(src, .proc/heal, user, iterations + 1), 1 SECONDS)


/obj/effect/proc_holder/spell/pointed/gaze
	name = "Vampiric Gaze"
	desc = "Paralyze your target with fear."
	charge_max = 300
	action_icon_state = "gaze"
	active_msg = "Przygotowujesz wampirze spojrzenie."
	deactive_msg = "Przestajesz przygotowywać wampirze spojrzenie."
	vamp_req = TRUE
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/gaze_target.dmi'
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/pointed/gaze/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>Spojrzenie nie zadziała na tę istotę.</span>")
		return FALSE
	var/mob/living/carbon/human/T = target

	if(T.stat == DEAD)
		to_chat(user,"<span class='warning'>Nie możesz wpatrywać się w zwłoki... \
			a może jednak możesz, jeśli naprawdę chcesz.</span>")
		return FALSE

/obj/effect/proc_holder/spell/pointed/gaze/cast(list/targets, mob/user)
	var/mob/living/carbon/human/T = targets[1]
	if(!ishuman(T))
		return
	user.visible_message("<span class='warning'>Oczy [user] błyskają czerwienią.</span>",\
					"<span class='warning'>Twoje oczy błyskają czerwienią.</span>")
	var/protection = T.get_eye_protection()
	if(protection == INFINITY)
		to_chat(user, "<span class='warning'>[T] jest ślepy, więc twoje spojrzenie nie działa!</span>")
		return
	if(protection > 0) //eye protection only dampens the gaze
		to_chat(user, "<span class='warning'>Ochrona oczu [T] tłumi twoje spojrzenie, tylko dezorientując cel.</span>")
		to_chat(T, "<span class='warning'>Czujesz dezorientację, gdy twoja ochrona oczu tłumi spojrzenie [user]!</span>")
		T.confused = max(T.confused, 3)
		return
	to_chat(T, "<span class='userdanger'>Paraliżuje cię strach!</span>")
	to_chat(user, "<span class='notice'>Paraliżujesz [T].</span>")
	T.Stun(5 SECONDS)


/obj/effect/proc_holder/spell/pointed/hypno
	name = "Hypnotize (20)"
	desc = "Knock out your target."
	charge_max = 300
	blood_used = 20
	action_icon_state = "hypnotize"
	active_msg = "<span class='warning'>Przygotowujesz technikę hipnozy.</span>"
	deactive_msg = "<span class='warning'>Przestajesz przygotowywać hipnozę.</span>"
	vamp_req = TRUE
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/hypnotize_target.dmi'
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/pointed/hypno/can_target(atom/target, mob/user, silent)
	if(!..())
		return FALSE
	if(!ishuman(target))
		to_chat(user, "<span class='warning'>Hipnoza nie zadziała na tę istotę.</span>")
		return FALSE

	var/mob/living/carbon/human/T = target
	if(T.IsSleeping())
		to_chat(user, "<span class='warning'>[T] już śpi!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/hypno/cast(list/targets, mob/user)
	var/mob/living/carbon/human/T = targets[1]
	if(!ishuman(T))
		return
	user.visible_message("<span class='warning'>[user] kręci palcem w kółko.</span>",\
			"<span class='warning'>Kręcisz palcem w kółko.</span>")

	var/protection = T.get_eye_protection()
	var/sleep_duration = 30 SECONDS
	if(protection == INFINITY)
		to_chat(user, "<span class='warning'>[T] jest ślepy, więc hipnoza nie działa!</span>")
		return
	if(protection > 0)
		to_chat(user, "<span class='warning'>Ochrona oczu [T] tłumi twoje moce hipnotyczne.</span>")
		sleep_duration = 10 SECONDS

	to_chat(T, "<span class='boldwarning'>Kolana nagle ci ciężeją. Twoje ciało zaczyna osuwać się na podłogę.</span>")
	to_chat(user, "<span class='notice'>[T] jest teraz pod twoim urokiem. Za cztery sekundy straci przytomność, o ile będzie blisko.</span>")
	if(do_mob(user, T, 4 SECONDS, TRUE)) // 4 seconds...
		if(get_dist(user, T) <= 3)
			flash_color(T, flash_color="#472040", flash_time=3 SECONDS) // it's the vampires color!
			T.SetSleeping(sleep_duration)
			to_chat(user, "<span class='warning'>[T] zasypia!</span>")
		else
			to_chat(T, "<span class='notice'>Czujesz się teraz o wiele lepiej.</span>")


/obj/effect/proc_holder/spell/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
	gain_desc = "Zyskujesz zdolność Płaszcz Ciemności, która po włączeniu czyni cię niemal niewidzialnym w mroku."
	action_icon_state = "cloak"
	charge_max = 10
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/cloak/Initialize()
	. = ..()
	update_name()

/obj/effect/proc_holder/spell/self/cloak/update_name()
	. = ..()
	var/mob/living/user = loc
	if(!ishuman(user) || !is_vampire(user))
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"

/obj/effect/proc_holder/spell/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(user, "<span class='notice'>W ciemności będziesz teraz [V.iscloaking ? "ukryty" : "widoczny"].</span>")


/obj/effect/proc_holder/spell/self/screech
	name = "Chiropteran Screech (20)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "Zyskujesz zdolność Nietoperzy Wrzask, która ogłusza wszystko, co ma uszy, w dużym promieniu i przy okazji tłucze szkło."
	action_icon_state = "reeee"
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 20
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='warning'>[user] wydaje przeszywający uszy wrzask!</span>", "<span class='warning'>Wydajesz głośny wrzask.</span>", "<span class='warning'>Słyszysz głośny, bolesny wrzask!</span>")
	for(var/mob/living/carbon/human/C in hearers(4, user))
		if(C == user || is_vampire(C))
			continue
		if(!C.soundbang_act(1, 0)) //earmuffs and the like protect from it
			continue
		to_chat(C, "<span class='warning'><font size='3'><b>Słyszysz przeszywający uszy wrzask i tępieją ci zmysły!</b></font></span>")
		C.Knockdown(40)
		C.adjustEarDamage(0, 30)
		C.stuttering = max(C.stuttering, 30)
		C.Paralyze(40)
		C.Jitter(150)
	for(var/obj/structure/window/W in view(4, user))
		W.take_damage(75)
	playsound(user.loc, 'sound/effects/screech.ogg', 100, 1)


/obj/effect/proc_holder/spell/self/bats
	name = "Summon Bats (30)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "Zyskujesz zdolność Przywołanie Nietoperzy."
	action_icon_state = "bats"
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	charge_max = 1200
	vamp_req = TRUE
	blood_used = 30
	var/num_bats = 2

/obj/effect/proc_holder/spell/self/bats/cast(list/targets, mob/user = usr)
	. = ..()
	var/list/turf/spawns = get_adjacent_open_turfs(user)
	for(var/i = 1 to num_bats)
		var/turf/T = get_turf(user) //pad with the caster's location if we are boxed in
		if(length(spawns))
			T = pick_n_take(spawns)
		new /mob/living/simple_animal/hostile/vampire_bat(T)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform
	name = "Mist Form (30)"
	gain_desc = "Zyskujesz zdolność Postać Mgły, która pozwala na krótko zmienić się w mgłę i pokonać każdą przeszkodę."
	blood_used = 30
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform/Initialize()
	. = ..()
	range = -1
	addtimer(VARSET_CALLBACK(src, range, -1), 10) //Avoid fuckery


/obj/effect/proc_holder/spell/targeted/vampirize
	name = "Lilith's Pact (300)"
	desc = "You drain a victim's blood, and fill them with new blood, blessed by Lilith, turning them into a new vampire."
	gain_desc = "Zyskujesz zdolność, by z czasem zmusić kogoś do stania się wampirem."
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	action_icon_state = "oath"
	blood_used = 300
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/vampirize/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/vamp = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/carbon/target in targets)
		if(is_vampire(target))
			to_chat(user, "<span class='warning'>To już jest wampir!</span>")
			refund_vampire_blood(user)
			continue
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(user, "<span class='warning'>Umysł [target] jest zbyt silny!</span>")
			refund_vampire_blood(user)
			continue
		user.visible_message("<span class='warning'>[user] wpija się w szyję [target], emanując czystą grozą.</span>", "<span class='warning'>Wpijasz się w szyję [target], przygotowując się, by przekazać swoją nieświętą krew.</span>", "<span class='warning'>Ogarnia cię straszliwe uczucie</span>")
		target.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10) //incase you're choking the victim
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					to_chat(target, "<span class='danger'>Złowrogie cienie wdzierają się w twoje pole widzenia, przyzywając cię.</span>")
					to_chat(user, "<span class='notice'>Zaczynamy wysysać krew [target], by Lilith mogła ją pobłogosławić.</span>")
				if(2)
					to_chat(target, "<span class='danger'>Demoniczne szepty wypełniają twój umysł i stają się nie do odparcia...</span>")
				if(3)
					to_chat(target, "<span class='danger'>Świat znika, a ty widzisz demo- nie, anio- demon- lil- chwała- błogosławieństwo... Lilith.</span>")
					to_chat(user, "<span class='notice'>Narasta w tobie ekscytacja, gdy [target] dostrzega błogosławieństwo Lilith.</span>")
			if(!do_mob(user, target, 70))
				to_chat(user, "<span class='danger'>Pakt się nie powiódł! [target] nie zostaje wampirem.</span>")
				to_chat(target, "<span class='notice'>Wizje ustają, a ty się rozluźniasz.</span>")
				refund_vampire_blood(user)
				return
		if(!QDELETED(user) && !QDELETED(target))
			to_chat(user, "<span class='notice'>. . .</span>")
			to_chat(target, "<span class='italics'>Przyjdź do mnie, dziecko.</span>")
			sleep(10)
			to_chat(target, "<span class='italics'>Świat nie traktował cię dobrze, prawda?</span>")
			sleep(15)
			to_chat(target, "<span class='italics'>Zasiej strach w ich sercach...</span>")
			to_chat(user, "<span class='notice italics bold'>Pakt został podpisany!</span>")
			to_chat(target, "<span class='userdanger'>Podpisujesz Pakt Lilith.</span>")
			target.mind.store_memory("<B>[user] pokazał ci chwałę Lilith. <I>Nie musisz słuchać [user], ale zyskujesz dla niego szacunek.</I></B>")
			target.Sleeping(600)
			target.blood_volume = 560
			add_vampire(target, FALSE)
			vamp.converted++


/obj/effect/proc_holder/spell/self/revive
	name = "Revive"
	gain_desc = "Zyskujesz zdolność odradzania się po śmierci... Wciąż możesz jednak zostać spopielony lub rozerwany, a w kaplicy, dopóki nie jesteś dość silny, rozpadniesz się w proch!"
	desc = "Revives you, provided you are not in the chapel! Use again to cancel the reanimation."
	blood_used = 0
	stat_allowed = TRUE
	charge_max = 600 //cooldown is only applied once we actually revive
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_icon_state = "coffin"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE
	var/reviving = FALSE
	var/revive_timer

/obj/effect/proc_holder/spell/self/revive/cast(list/targets, mob/user = usr)
	revert_cast(user) //no cooldown on the button itself
	if(!is_vampire(user) || !isliving(user))
		return
	if(user.stat != DEAD)
		to_chat(user, "<span class='notice'>Nie jesteśmy jeszcze dość martwi, by to zrobić!</span>")
		return
	if(user.reagents.has_reagent(/datum/reagent/water/holywater))
		to_chat(user, "<span class='danger'>Nie możemy się ożywić, mamy w organizmie wodę święconą!</span>")
		return
	reviving = !reviving
	deltimer(revive_timer)
	if(reviving)
		to_chat(user, "<span class='notice'>Zaczynamy się reanimować... zajmie to minutę.</span>")
		revive_timer = addtimer(CALLBACK(src, .proc/revive, user), 1 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		to_chat(user, "<span class='notice'>Przerywamy reanimację.</span>")

/obj/effect/proc_holder/spell/self/revive/proc/revive(mob/living/user)
	reviving = FALSE
	if(QDELETED(user))
		return
	if(istype(get_area(user), /area/chapel))
		var/datum/antagonist/vampire/V = is_vampire(user)
		if(V && V.get_ability(/datum/vampire_passive/full)) //full blooded vampire doesn't get dusted if they try to res, it still doesn't work though
			to_chat(user, "<span class='danger'>Święte energie tego miejsca uniemożliwiają nam ożywienie!</span>")
			return
		user.visible_message("<span class='warning'>[user] rozpada się w pył!</span>", "<span class='userdanger'>Święta energia przenika naszą istotę, natychmiast nas dezintegrując!</span>", "Słyszysz skwierczenie.")
		new /obj/effect/decal/remains/human(user.loc)
		user.dust()
		return
	if(user.stat != DEAD) //if they somehow revive before it goes off
		return
	charge_counter = 0 //start the cooldown when the revive actually happens
	start_recharge()
	var/list/missing = user.get_missing_limbs()
	if(missing.len)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
		user.visible_message("<span class='warning'>Cienista materia zastępuje brakujące kończyny [user], które się odtwarzają!</span>")
		user.regenerate_limbs()
		user.regenerate_organs()
	user.revive(full_heal = TRUE)
	user.visible_message("<span class='warning'>[user] powstaje z martwych!</span>", "<span class='notice'>Wstajemy z powrotem.</span>")


/obj/effect/proc_holder/spell/self/summon_coat
	name = "Summon Dracula Coat (100)"
	desc = "Allows you to summon a Vampire Coat providing passive usable blood restoration."
	gain_desc = "Teraz, gdy osiągasz pełnię mocy, możesz wyciągnąć wampirzy płaszcz z powietrza!"
	blood_used = 100
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_icon_state = "coat"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/summon_coat/cast(list/targets, mob/user = usr)
	if(!is_vampire(user) || !isliving(user))
		revert_cast()
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	if(QDELETED(V.coat) || !V.coat)
		V.coat = new /obj/item/clothing/suit/draculacoat(user.loc)
	else if(get_dist(V.coat, user) > 1 || !(V.coat in user.GetAllContents()))
		V.coat.forceMove(user.loc)
	user.put_in_hands(V.coat)
	to_chat(user, "<span class='notice'>Przywołujesz swój płaszcz Drakuli.</span>")


/obj/effect/proc_holder/spell/self/batform
	name = "Bat Form (15)"
	gain_desc = "Masz teraz zdolność Postać Nietoperza, która pozwala zmienić się w nietoperza (i z powrotem!)"
	desc = "Transform into a bat!"
	action_icon_state = "bat"
	charge_max = 200
	blood_used = 0 //this is only 0 so we can do our own custom checks
	action_icon = 'aquila/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE
	var/mob/living/simple_animal/hostile/vampire_bat/bat

/obj/effect/proc_holder/spell/self/batform/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return FALSE
	if(!bat || bat.stat == DEAD)
		if(isliving(user))
			var/mob/living/L = user
			if(L.incapacitated())
				to_chat(user, "<span class='warning'>Nie możesz się przemienić, gdy jesteś obezwładniony!</span>")
				revert_cast()
				return FALSE
		if(V.usable_blood < 15)
			to_chat(user, "<span class='warning'>Masz za mało krwi, żeby tego użyć!</span>")
			revert_cast()
			return FALSE
		V.usable_blood -= 15
		bat = new /mob/living/simple_animal/hostile/vampire_bat(user.loc)
		user.forceMove(bat)
		bat.controller = user
		user.status_flags |= GODMODE
		user.mind.transfer_to(bat)
		charge_counter = charge_max //so you don't need to wait 20 seconds to turn BACK.
		recharging = FALSE
		action.UpdateButtonIcon()
	else
		bat.controller.forceMove(bat.loc)
		bat.controller.status_flags &= ~GODMODE
		bat.mind.transfer_to(bat.controller)
		bat.controller = null //just so we don't accidently trigger the death() thing
		QDEL_NULL(bat)
