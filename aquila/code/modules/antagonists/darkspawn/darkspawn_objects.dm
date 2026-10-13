// AQUILA - darkspawn: przedmioty i obiekty

/// Ciemny koralik z Pożarcia woli
/obj/item/dark_bead
	name = "dark bead"
	desc = "Świecąca czarna kula. Szybko blednie."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "dark_bead"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE | INDESTRUCTIBLE
	item_flags = DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2
	/// Czy właśnie pożeramy czyjąś wolę
	var/eating = FALSE
	var/datum/action/innate/darkspawn/devour_will/linked_ability
	var/full_restore = TRUE

/obj/item/dark_bead/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	animate(src, alpha = 50, time = 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fade)), 5 SECONDS)

/obj/item/dark_bead/proc/fade()
	if(eating)
		return
	if(isliving(loc))
		to_chat(loc, "<span class='warning'>Byłeś za wolny! [src] rozwiał się...</span>")
	qdel(src)

/obj/item/dark_bead/Destroy()
	linked_ability = null
	return ..()

/obj/item/dark_bead/attack(mob/living/carbon/L, mob/living/user)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(!darkspawn || eating || L == user)
		return
	if(!iscarbon(L))
		to_chat(user, "<span class='warning'>Umysł [L] jest za słaby, żeby się do czegoś przydać.</span>")
		return
	linked_ability = darkspawn.has_ability("devour_will")
	if(!linked_ability)
		qdel(src)
		return
	if(!L.mind || isdarkspawn(L))
		to_chat(user, "<span class='warning'>Nie możesz wysysać sojuszników ani bezmyślnych.</span>")
		return
	if(!L.health || L.stat)
		to_chat(user, "<span class='warning'>[L] jest za słaby, żeby go wyssać.</span>")
		return
	if(linked_ability.victims[L])
		to_chat(user, "<span class='warning'>[L] musi najpierw dojść do siebie po ostatnim wyssaniu.</span>")
		return
	if(linked_ability.last_victim == L.ckey)
		to_chat(user, "<span class='warning'>Umysł [L] wciąż jest zbyt rozbity. Najpierw wyssij kogoś innego.</span>")
		return
	if(isveil(L))
		full_restore = FALSE
		to_chat(user, "<span class='warning'>[L] jest welonem i nie da tyle Psi co nietknięta ofiara.</span>")
	eating = TRUE
	L.Stun(5 SECONDS)
	user.Immobilize(1 SECONDS) // żeby przypadkiem nie odejść w trakcie
	ADD_TRAIT(L, TRAIT_IMMOBILIZED, "dark_bead")
	if(user.loc != L)
		user.visible_message("<span class='warning'>[user] chwyta [L] i nachyla się blisko...</span>", "<span class='velvet bold'>cera qo...</span><br>\
			<span class='danger'>Zaczynasz wysysać energię umysłu [L]...</span>")
		to_chat(L, "<span class='userdanger'><i>AAAAAAAAAAAAAA-</i></span>")
		L.silent += 4
		playsound(L, 'aquila/sound/darkspawn/devour_will.ogg', 65, FALSE)
		if(!do_after(user, 3 SECONDS, target = L))
			interrupted(L, user, 3 SECONDS)
			return
	else
		L.visible_message("<span class='userdanger italics'>[L] nagle wyje i łapie się za twarz, a z oczu bije wrzeszczące fioletowe światło!</span>", \
			"<span class='userdanger italics'>AAAAAAAAAAAAAAA-</span>")
		to_chat(user, "<span class='velvet'><b>cera qo...</b><br>Zaczynasz wysysać wolę [L]...</span>")
		playsound(L, 'aquila/sound/darkspawn/devour_will_long.ogg', 65, FALSE)
		if(!do_after(user, 5 SECONDS, target = L))
			interrupted(L, user, 5 SECONDS)
			return
	REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, "dark_bead")
	user.visible_message("<span class='warning'>[user] delikatnie opuszcza [L] na ziemię...</span>", "<span class='velvet'><b>...aranupdejc</b><br>\
		Pożerasz wolę [L]. Twoje Psi [full_restore ? "w pełni się odnowiło." : "częściowo się odnowiło."]<br>\
		<span class='warning'>[L] jest teraz bardzo osłabiony i trochę potrwa, zanim dojdzie do siebie.</span> \
		<span class='warning'>Nie możesz też wyssać go znowu, zanim nie wyssiesz kogoś innego.</span></span>")
	playsound(L, 'aquila/sound/darkspawn/devour_will_victim.ogg', 50, FALSE)
	if(full_restore)
		darkspawn.psi = darkspawn.psi_cap
	else // welony nie dają darmowej lucidity, ale wciąż liczą się do Sakramentu
		darkspawn.psi = min(darkspawn.psi + 20, darkspawn.psi_cap)
	if(linked_ability.victims[L] == FALSE)
		to_chat(user, "<span class='warning'>Ta osoba była już wcześniej wyssana i jej lucidity nie przybliży cię więcej do Sakramentu!</span>")
	else
		to_chat(user, "<span class='velvet'>Lucidity tej osoby przybliża cię o krok do Sakramentu... Zyskujesz jedną lucidity, wydaj ją w Sieci Psi.</span>")
		darkspawn.lucidity++
		darkspawn.lucidity_drained++
	darkspawn.update_psi_hud()
	linked_ability.victims[L] = TRUE
	linked_ability.last_victim = L.ckey
	to_chat(L, "<span class='userdanger'>Nagle czujesz się... pusty. Myśli próbują się ułożyć, ale się rozpierzchają. Zapadasz w głęboki, bardzo głęboki sen...</span>")
	L.playsound_local(L, 'aquila/sound/darkspawn/devour_will_end.ogg', 75, FALSE)
	L.Unconscious(15)
	L.stuttering += 20
	L.apply_status_effect(/datum/status_effect/broken_will)
	addtimer(CALLBACK(linked_ability, TYPE_PROC_REF(/datum/action/innate/darkspawn/devour_will, make_eligible), L), 1 MINUTES)
	eating = FALSE
	qdel(src)
	return TRUE

/obj/item/dark_bead/proc/interrupted(mob/living/L, mob/living/user, knockdown_time)
	REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, "dark_bead")
	user.Knockdown(knockdown_time)
	to_chat(L, "<span class='boldwarning'>Dobrze. Nic ci nie jest.</span>")
	L.Knockdown(knockdown_time)
	eating = FALSE
	qdel(src)

/// Bariera z Objawienia i Sakramentu. Regeneruje się i chroni darkspawna.
/obj/structure/psionic_barrier
	name = "psionic barrier"
	desc = "Migoczące fioletowe drobiny tańczące w powietrzu. Nie da się przez nie przejść."
	max_integrity = 200
	icon = 'aquila/icons/mob/darkspawn/darkspawn_effects.dmi'
	icon_state = "purplesparkles"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2

/obj/structure/psionic_barrier/Initialize(mapload, time = 500)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, time)

/obj/structure/psionic_barrier/Destroy()
	if(!obj_integrity)
		visible_message("<span class='warning'>[src] znika w rozbłysku fioletowej energii!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
		new /obj/effect/temp_visual/revenant/cracks(get_turf(src))
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/psionic_barrier/process()
	obj_integrity = min(max_integrity, obj_integrity + 1)

/// Iluzja z Symulakrum. Biegnie prosto, dopóki nie zniknie.
/obj/effect/simulacrum
	name = "an illusion!"
	desc = "Co ukrywasz?!"
	icon_state = "static"
	density = TRUE
	var/mob/living/mimicking

/obj/effect/simulacrum/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	QDEL_IN(src, 10 SECONDS)

/obj/effect/simulacrum/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	mimicking = null
	return ..()

/obj/effect/simulacrum/process()
	Move(get_step(src, dir), dir)

/obj/effect/simulacrum/attack_hand(mob/living/user)
	. = ..()
	dispel()

/obj/effect/simulacrum/attackby(obj/item/I, mob/living/user, params)
	dispel()
	return TRUE

/obj/effect/simulacrum/bullet_act(obj/item/projectile/P)
	. = ..()
	dispel()

/obj/effect/simulacrum/proc/dispel()
	visible_message("<span class='warning'>[src] rozwiewa się w cienie!</span>")
	qdel(src)

/obj/effect/simulacrum/proc/mimic(mob/living/L)
	mimicking = L
	appearance = L.appearance
	name = L.name
	desc = "Realistyczna iluzja [L]."
	setDir(L.dir)
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/// Macki cienia z Przejścia
/obj/item/umbral_tendrils
	name = "umbral tendrils"
	desc = "Masa pulsujących, chitynowych macek z odsłoniętym fioletowym ciałem."
	force = 15
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "umbral_tendrils"
	item_state = "umbral_tendrils"
	lefthand_file = 'aquila/icons/mob/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/darkspawn/darkspawn_righthand.dmi'
	hitsound = 'aquila/sound/darkspawn/pass_attack.ogg'
	attack_verb = list("przebija", "chłoszcze", "rozdziera")
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	var/datum/antagonist/darkspawn/darkspawn
	var/obj/item/umbral_tendrils/twin

/obj/item/umbral_tendrils/Initialize(mapload, new_darkspawn)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	darkspawn = new_darkspawn
	for(var/obj/item/umbral_tendrils/other in loc)
		if(other != src)
			twin = other
			other.twin = src
			force = 12
			other.force = 12

/obj/item/umbral_tendrils/Destroy()
	darkspawn = null
	var/obj/item/umbral_tendrils/old_twin = twin
	twin = null
	if(old_twin && !QDELETED(old_twin))
		old_twin.twin = null
		qdel(old_twin)
	return ..()

/obj/item/umbral_tendrils/examine(mob/user)
	. = ..()
	if(isobserver(user) || isdarkspawn(user))
		. += "<span class='velvet bold'>Zastosowania:</span>"
		. += "<span class='velvet'><b>Bez trybu walki:</b> kliknij wolne pole w zasięgu siedmiu, żeby do niego skoczyć (10 Psi).</span>"
		. += "<span class='velvet'><b>Prawy klik na śluzie:</b> siłą ją otwiera (15 Psi), a zaryglowaną albo zaspawaną rozbija (30 Psi).</span>"
		. += "<span class='velvet'><b>Tryb walki:</b> rzut mackami na pięć pól, który przewraca[twin ? " i przyciąga" : ""] pierwszą trafioną istotę.</span>"
		. += "<span class='velvet'>Macki w walce wręcz niszczą światła trafionych przedmiotów i od razu rozbijają lampy.</span>"
		. += "<span class='velvet'>Śluzy bez zasilania podważają się bez trybu walki.</span>"

/obj/item/umbral_tendrils/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(twin && !QDELETED(twin) && user.get_active_held_item() == src)
		addtimer(CALLBACK(src, PROC_REF(twin_attack), target, user), 0.1 SECONDS)

/obj/item/umbral_tendrils/proc/twin_attack(mob/living/target, mob/living/user)
	if(QDELETED(twin) || QDELETED(target) || !user.Adjacent(target))
		return
	twin.melee_attack_chain(user, target)

/obj/item/umbral_tendrils/pre_attack_secondary(atom/target, mob/living/user, params)
	if(istype(target, /obj/machinery/door/airlock) && darkspawn)
		INVOKE_ASYNC(src, PROC_REF(force_airlock), target, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/umbral_tendrils/pre_attack(atom/target, mob/living/user, params)
	// Śluza bez zasilania podważa się jak łomem
	if(!user.combat_mode && istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		if(airlock.density && !airlock.hasPower())
			if(airlock.locked || airlock.welded)
				to_chat(user, "<span class='warning'>[src] nie podważą zaryglowanej śluzy, trzeba ją rozbić.</span>")
			else
				airlock.open(2)
			return FALSE
	return ..()

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!darkspawn)
		return
	if(proximity_flag)
		if(istype(target, /obj/structure/glowshroom))
			visible_message("<span class='warning'>[src] rozszarpują [target] na strzępy!</span>")
			qdel(target)
		else if(istype(target, /obj/machinery/light))
			var/obj/machinery/light/light = target
			light.break_light_tube()
		else if(isliving(target))
			var/mob/living/L = target
			if(isethereal(L))
				L.emp_act(EMP_LIGHT)
			for(var/obj/item/O in L.GetAllContents())
				if(O.light_range && O.light_power)
					disintegrate(O)
			if(isitem(L.pulling))
				var/obj/item/pulled = L.pulling
				if(pulled.light_range && pulled.light_power)
					disintegrate(pulled)
		else if(isitem(target))
			var/obj/item/I = target
			if(I.light_range && I.light_power)
				disintegrate(I)
	if(user.combat_mode)
		if(!(isliving(target) && proximity_flag)) // w zwarciu macki po prostu biją
			tendril_swing(user, target)
	else if(isopenturf(target) && !proximity_flag)
		tendril_jump(user, target)

/obj/item/umbral_tendrils/proc/disintegrate(obj/item/O)
	if(istype(O, /obj/item/modular_computer))
		O.set_light(0)
		visible_message("<span class='danger'>Światło w [O] gaśnie!</span>")
	else
		visible_message("<span class='danger'>[src] rozkładają [O] na kawałki!</span>")
		O.burn()
	playsound(src, 'sound/items/welder.ogg', 50, TRUE)

/// Rzuca użytkownika na wskazane pole
/obj/item/umbral_tendrils/proc/tendril_jump(mob/living/user, turf/open/target)
	if(!darkspawn.has_psi(10))
		to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 10 Psi, żeby skoczyć!</span>")
		return
	if(!(target in view(7, user)))
		to_chat(user, "<span class='warning'>Nie dosięgniesz tam albo to za daleko!</span>")
		return
	to_chat(user, "<span class='velvet'>Podciągasz się w stronę [target].</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.throw_at(target, 5, 3)
	darkspawn.use_psi(10)

/// Wyrzuca macki, które przewracają pierwszą trafioną istotę
/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, atom/target)
	if(isliving(target))
		var/mob/living/L = target
		if(!(L.mobility_flags & MOBILITY_STAND))
			to_chat(user, "<span class='warning'>[L] już leży!</span>")
			return
	user.visible_message("<span class='warning'>[user] odciąga [src] i wyrzuca je w stronę [target]!</span>", \
		"<span class='velvet'><b>opehhjaoo</b><br>Wyrzucasz macki w stronę [target]!</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	var/obj/item/projectile/umbral_tendrils/T = new(get_turf(user))
	T.preparePixelProjectile(target, user)
	T.twinned = !!twin
	T.firer = user
	T.fire()
	qdel(src)

/// Otwiera albo rozbija śluzę (prawy klik)
/obj/item/umbral_tendrils/proc/force_airlock(obj/machinery/door/airlock/airlock, mob/living/user)
	if(!airlock.density)
		return
	if(!airlock.locked && !airlock.welded)
		if(!airlock.hasPower()) // łom daje radę, to macki tym bardziej
			airlock.open(2)
			return
		if(!darkspawn.has_psi(15))
			to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 15 Psi, żeby siłą otworzyć śluzę!</span>")
			return
		user.visible_message("<span class='warning'>[user] zaczyna siłą otwierać [airlock]!</span>", "<span class='velvet'><b>ueahz</b><br>Zaczynasz siłą otwierać [airlock]...</span>")
		playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		if(!do_after(user, twin ? 5 SECONDS : 7.5 SECONDS, target = airlock))
			return
		if(!airlock.open(2) && airlock.density)
			to_chat(user, "<span class='warning'>Mimo starań [airlock] nie chce się otworzyć!</span>")
		darkspawn?.use_psi(15)
		return
	if(!darkspawn.has_psi(30))
		to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 30 Psi, żeby rozbić śluzę!</span>")
		return
	user.visible_message("<span class='boldwarning'>[user] zaczyna walić [src] w [airlock]!</span>", \
		"<span class='velvet italics'>Głośno zaczynasz rozbijać [airlock].</span>")
	var/datum/antagonist/darkspawn/our_darkspawn = darkspawn
	while(airlock.obj_integrity > airlock.max_integrity * 0.25)
		if(!do_after(user, twin ? rand(4, 6) : rand(8, 10), target = airlock))
			our_darkspawn.use_psi(30)
			qdel(src)
			return
		playsound(airlock, 'aquila/sound/darkspawn/pass_smash_door.ogg', 50, TRUE)
		airlock.take_damage(airlock.max_integrity / rand(8, 15))
		to_chat(user, "<span class='velvet bold'>klaj.</span>")
	airlock.ex_act(EXPLODE_DEVASTATE)
	user.visible_message("<span class='boldwarning'>[user] rozbija [airlock]!</span>", "<span class='velvet bold'>KLAJ.</span>")
	our_darkspawn.use_psi(30)
	qdel(src)

/obj/item/projectile/umbral_tendrils
	name = "umbral tendrils"
	icon_state = "cursehand0"
	hitsound = 'aquila/sound/darkspawn/pass_attack.ogg'
	layer = LARGE_MOB_LAYER
	damage = 0
	nodamage = TRUE
	speed = 1
	range = 5
	var/twinned = FALSE
	var/datum/beam/beam

/obj/item/projectile/umbral_tendrils/fire(setAngle)
	if(firer)
		beam = firer.Beam(src, icon_state = "curse0", time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/curse_arm)
	return ..()

/obj/item/projectile/umbral_tendrils/Destroy()
	QDEL_NULL(beam)
	return ..()

/obj/item/projectile/umbral_tendrils/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(blocked >= 100 || !isliving(target))
		return
	var/mob/living/L = target
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		R.toggle_headlamp(TRUE)
		R.visible_message("<span class='warning'>[name] [firer] uderzają w obudowę [R]!</span>", \
			"<span class='userdanger'>Wykryto silne uderzenie. Rekalibracja układów ruchu.</span>")
		R.playsound_local(R, 'sound/misc/interference.ogg', 25, FALSE)
		playsound(R, 'sound/effects/bang.ogg', 50, TRUE)
		R.Paralyze(4 SECONDS)
		R.adjustBruteLoss(10)
		return
	playsound(L, 'aquila/sound/darkspawn/pass_attack.ogg', 50, TRUE)
	if(!twinned)
		L.visible_message("<span class='warning'>Macki [firer] uderzają w [L], zbijając go z nóg!</span>", \
			"<span class='userdanger'>Coś zbija cię z nóg!</span>")
		L.Knockdown(6 SECONDS)
	else
		L.Immobilize(0.15 SECONDS) // żeby ruchem nie przerwać przyciągania
		L.throw_at(get_step_towards(firer, L), 7, 2)
		L.visible_message("<span class='warning'>Macki [firer] uderzają w [L] i ciągną go po ziemi!</span>", \
			"<span class='userdanger'>Nagle coś ciągnie cię po podłodze!</span>")
		L.Knockdown(8 SECONDS)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), L, 'aquila/sound/darkspawn/pass_attack.ogg', 50, TRUE), 1)
