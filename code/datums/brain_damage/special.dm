//Brain traumas that are rare and/or somewhat beneficial;
//they are the easiest to cure, which means that if you want
//to keep them, you can't cure your other traumas
/datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Patient occasionally and uncontrollably channels an eldritch god when speaking."
	scan_desc = "urojenie boskości"
	gain_text = "<span class='notice'>Czujesz w umyśle wyższą moc...</span>"
	lose_text = "<span class='warning'>Boska obecność opuszcza twoją głowę, już niezainteresowana.</span>"

/datum/brain_trauma/special/godwoken/on_life()
	..()
	if(prob(4))
		if(prob(33) && (owner.IsStun() || owner.IsParalyzed() || owner.IsUnconscious()))
			speak("unstun", TRUE)
		else if(prob(60) && owner.health <= owner.crit_threshold)
			speak("heal", TRUE)
		else if(prob(30) && owner.combat_mode)
			speak("aggressive")
		else
			speak("neutral", prob(25))

/datum/brain_trauma/special/godwoken/on_gain()
	ADD_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/godwoken/on_lose()
	REMOVE_TRAIT(owner, TRAIT_HOLY, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/godwoken/proc/speak(type, include_owner = FALSE)
	var/message
	switch(type)
		if("unstun")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_unstun")
		if("heal")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_heal")
		if("neutral")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")
		if("aggressive")
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_aggressive")
		else
			message = pick_list_replacements(BRAIN_DAMAGE_FILE, "god_neutral")

	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 5)
	voice_of_god(message, owner, list("colossus","yell"), 2.5, include_owner, FALSE)

/datum/brain_trauma/special/ghost_control
	name = "Spiritual Connection"
	desc = "Patient claims to receive impulses from the supernatural that they feel compelled to follow."
	scan_desc = "duchowy mimowolny skurcz mięśni"
	gain_text = "<span class='notice'>Słyszysz w głowie głosy mówiące o różnych kierunkach...</span>"
	lose_text = "<span class='warning'>Głosy w twojej głowie cichną.</span>"

/datum/brain_trauma/special/ghost_control/on_gain()
	owner._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), owner, NORTH),
			 "down" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), owner, SOUTH),
			 "left" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), owner, WEST),
			 "right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), owner, EAST)), 120))
	..()

/datum/brain_trauma/special/ghost_control/on_lose()
	var/datum/component/deadchat_control/D = owner.GetComponent(/datum/component/deadchat_control)
	if(D)
		D.RemoveComponent()
	..()


/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Patient can sense the bob and weave of bluespace around them, showing them passageways no one else can see."
	scan_desc = "dostrojenie do bluespace"
	gain_text = "<span class='notice'>Czujesz pulsowanie bluespace wokół siebie...</span>"
	lose_text = "<span class='warning'>Ciche pulsowanie bluespace cichnie.</span>"
	var/next_portal = 0

/datum/brain_trauma/special/bluespace_prophet/on_life()
	if(world.time > next_portal)
		next_portal = world.time + 100
		var/list/turf/possible_turfs = list()
		for(var/turf/T as() in RANGE_TURFS(8, owner))
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					possible_turfs += T

		if(!LAZYLEN(possible_turfs))
			return

		var/turf/first_turf = pick(possible_turfs)
		if(!first_turf)
			return

		possible_turfs -= (possible_turfs & RANGE_TURFS(3, first_turf))

		var/turf/second_turf = pick(possible_turfs)
		if(!second_turf)
			return

		var/obj/effect/hallucination/simple/bluespace_stream/first = new(first_turf, owner)
		var/obj/effect/hallucination/simple/bluespace_stream/second = new(second_turf, owner)

		first.linked_to = second
		second.linked_to = first
		first.seer = owner
		second.seer = owner

/obj/effect/hallucination/simple/bluespace_stream
	name = "bluespace stream"
	desc = "You see a hidden pathway through bluespace..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	var/obj/effect/hallucination/simple/bluespace_stream/linked_to
	var/mob/living/carbon/seer

/obj/effect/hallucination/simple/bluespace_stream/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 300)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/hallucination/simple/bluespace_stream/attack_hand(mob/user, list/modifiers)
	if(user != seer || !linked_to)
		return
	var/slip_in_message = pick("dziwnie przesuwa się w bok i znika", "wskakuje do niewidzialnego wymiaru",\
		"wystawia prosto jedną nogę, macha stopą i nagle znika", "zatrzymuje się, po czym znika z rzeczywistości", \
		"zostaje wciągnięty w niewidzialny wir i znika z oczu")
	var/slip_out_message = pick("bezgłośnie się pojawia", "wyskakuje znikąd","appears", "wychodzi z niewidzialnych drzwi",\
		"wysuwa się z fałdy czasoprzestrzeni")
	to_chat(user, "<span class='notice'>Próbujesz zestroić się z nurtem bluespace...</span>")
	if(do_after(user, 20, target = src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(src))
		new /obj/effect/temp_visual/bluespace_fissure(get_turf(linked_to))
		if(do_teleport(user, get_turf(linked_to), no_effects = TRUE))
			user.visible_message("<span class='warning'>[user] [slip_in_message].</span>", null, null, null, user)
			user.visible_message("<span class='warning'>[user] [slip_out_message].</span>", "<span class='notice'>...i znajdujesz drogę na drugą stronę.</span>")

/datum/brain_trauma/special/tenacity
	name = "Tenacity"
	desc = "Patient is psychologically unaffected by pain and injuries, and can remain standing far longer than a normal person."
	scan_desc = "urazowa neuropatia"
	gain_text = "<span class='warning'>Nagle przestajesz czuć ból.</span>"
	lose_text = "<span class='warning'>Uświadamiasz sobie, że znów czujesz ból.</span>"

/datum/brain_trauma/special/tenacity/on_gain()
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAUMA_TRAIT)
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/tenacity/on_lose()
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAUMA_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/special/death_whispers
	name = "Functional Cerebral Necrosis"
	desc = "Patient's brain is stuck in a functional near-death state, causing occasional moments of lucid hallucinations, which are often interpreted as the voices of the dead."
	scan_desc = "przewlekła martwica czynnościowa"
	gain_text = "<span class='warning'>Czujesz się martwy w środku.</span>"
	lose_text = "<span class='notice'>Znów czujesz, że żyjesz.</span>"
	var/active = FALSE

/datum/brain_trauma/special/death_whispers/on_life()
	..()
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/special/death_whispers/on_lose()
	if(active)
		cease_whispering()
	..()

/datum/brain_trauma/special/death_whispers/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(cease_whispering)), rand(50, 300))

/datum/brain_trauma/special/death_whispers/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = FALSE

/datum/brain_trauma/special/beepsky
	name = "Criminal"
	desc = "Patient seems to be a criminal."
	scan_desc = "umysł przestępczy"
	gain_text = "<span class='warning'>Sprawiedliwość po ciebie idzie.</span>"
	lose_text = "<span class='notice'>Twoje zbrodnie zostały ci odpuszczone.</span>"
	clonable = FALSE
	random_gain = FALSE
	var/obj/effect/hallucination/simple/securitron/beepsky

/datum/brain_trauma/special/beepsky/on_gain()
	create_securitron()
	..()

/datum/brain_trauma/special/beepsky/proc/create_securitron()
	var/turf/where = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	beepsky = new(where, owner)
	beepsky.victim = owner

/datum/brain_trauma/special/beepsky/on_lose()
	QDEL_NULL(beepsky)
	..()

/datum/brain_trauma/special/beepsky/on_life()
	if(QDELETED(beepsky) || !beepsky.loc || beepsky.z != owner.z)
		QDEL_NULL(beepsky)
		if(prob(30))
			create_securitron()
		else
			return
	if(get_dist(owner, beepsky) >= 10 && prob(20))
		QDEL_NULL(beepsky)
		create_securitron()
	if(owner.stat != CONSCIOUS)
		if(prob(20))
			owner.playsound_local(beepsky, 'aquila/sound/voice/beepsky/iamthelaw.ogg', 50) //AQUILA EDIT original was sound/voice/beepsky/iamthelaw.ogg
		return
	if(get_dist(owner, beepsky) <= 1)
		owner.playsound_local(owner, 'sound/weapons/egloves.ogg', 50)
		owner.visible_message("<span class='warning'>Ciałem [owner] wstrząsa, jakby poraził je prąd.</span>", "<span class='userdanger'>Czujesz pięść PRAWA.</span>")
		owner.take_bodypart_damage(0,0,rand(40, 70))
		QDEL_NULL(beepsky)
	if(prob(20) && get_dist(owner, beepsky) <= 8)
		owner.playsound_local(beepsky, 'aquila/sound/voice/beepsky/criminal.ogg', 40) //AQUILA EDIT original was sound/voice/beepsky/criminal.ogg
	..()

/obj/effect/hallucination/simple/securitron
	name = "Securitron"
	desc = "The LAW is coming."
	image_icon = 'icons/mob/aibots.dmi'
	image_state = "secbot-c"
	var/victim

/obj/effect/hallucination/simple/securitron/New()
	name = pick ( "officer Beepsky", "officer Johnson", "officer Pingsky")
	START_PROCESSING(SSfastprocess,src)
	..()

/obj/effect/hallucination/simple/securitron/process(delta_time)
	if(DT_PROB(60, delta_time))
		forceMove(get_step_towards(src, victim))
		if(DT_PROB(5, delta_time))
			to_chat(victim, "<span class='name'>[name]</span> wykrzykuje: \"<span class='robotic'>Alarm: wykroczenie poziomu 10!\"</span>")

/obj/effect/hallucination/simple/securitron/Destroy()
	victim = null
	STOP_PROCESSING(SSfastprocess,src)
	return ..()
