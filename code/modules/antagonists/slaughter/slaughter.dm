//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "demon rzezi"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("bulgocze")
	emote_hear = list("zawodzi","skrzeczy")
	response_help  = "rozmyśla się i nie dotyka"
	response_disarm = "macha rękami na"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "dziko rozszarpuje"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage = 30
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	bloodcrawl = BLOODCRAWL_EAT
	hardattacks = TRUE
	var/playstyle_string = "<span class='big bold'>Jesteś demonem rzezi,</span><B> straszliwą istotą z innego świata. Masz jedno pragnienie: zabijać.  \
							Przy kałużach krwi możesz użyć zdolności \"Krwawy Pełz\", by przez nie podróżować, pojawiając się i znikając ze statku, kiedy chcesz. \
							Jeśli wejdziesz do kałuży, ciągnąc martwą lub nieprzytomną istotę, wciągniesz ją ze sobą i będziesz mógł się nią pożywić, odzyskując zdrowie. \
							Po wyjściu z kałuży krwi poruszasz się szybko, ale materialny świat wkrótce wysysa z ciebie siły i spowalnia. </B>"

	mobchatspan = "cultmobsay"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart/demon)
	del_on_death = TRUE
	deathmessage = "krzyczy z wściekłości, rozpadając się w kałużę wnętrzności!"
	discovery_points = 3000

/mob/living/simple_animal/slaughter/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/phased_mob/slaughter))
		bloodspell.phased = TRUE

/obj/effect/decal/cleanable/blood/innards
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	random_icon_states = null

/mob/living/simple_animal/slaughter/phasein()
	. = ..()
	add_movespeed_modifier(MOVESPEED_ID_SLAUGHTER, update=TRUE, priority=100, multiplicative_slowdown=-1)
	addtimer(CALLBACK(src, PROC_REF(remove_movespeed_modifier), MOVESPEED_ID_SLAUGHTER, TRUE), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)


//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/heart/demon/update_icon()
	return //always beating visually

/obj/item/organ/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] podnosi [src] do ust i wgryza się w to zębami!</span>", \
						 "<span class='danger'>Ogarnia cię nienaturalny głód. Podnosisz [src] do ust i pożerasz!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == /obj/effect/proc_holder/spell/bloodcrawl)
			to_chat(user, "<span class='warning'>...i nie czujesz żadnej różnicy.</span>")
			qdel(src)
			return
	user.visible_message("<span class='warning'>Oczy [user] rozbłyskują głęboką czerwienią!</span>", \
						 "<span class='userdanger'>Czujesz, jak w twoje ciało wsiąka dziwna moc... wchłaniasz zdolność demona do podróży przez krew!</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/heart/demon/Insert(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/heart/demon/Remove(mob/living/carbon/M, special = 0)
	..()
	if(M.mind)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)

/obj/item/organ/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "demon śmiechu"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("chichocze","chichocze","podśmiewa się")
	emote_hear = list("rechocze","śmieje się")
	response_help  = "hugs"
	attacktext = "dziko łaskocze"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	deathsound = 'sound/misc/sadtrombone.ogg'

	icon_state = "honkmon"
	icon_living = "honkmon"
	deathmessage = "znika, a wszyscy jego przyjaciele zostają uwolnieni z jego \
		więzienia uścisków."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	// Keep the people we hug!
	var/list/consumed_mobs = list()

	playstyle_string = "<span class='big bold'>Jesteś demonem \
	śmiechu,</span><B> cudowną istotą z innego świata. Masz jedno \
	pragnienie: <span class='clowntext'>przytulać i łaskotać.</span><BR>\
	Przy kałużach krwi możesz użyć zdolności \"Krwawy Pełz\", by przez \
	nie podróżować, pojawiając się i znikając ze statku, kiedy chcesz. \
	Jeśli wejdziesz do kałuży, ciągnąc martwą lub nieprzytomną istotę, \
	wciągniesz ją ze sobą i będziesz mógł ją przytulać, odzyskując zdrowie.<BR> \
	Po wyjściu z kałuży krwi poruszasz się szybko, ale materialny świat \
	wkrótce wysysa z ciebie siły i spowalnia.<BR>\
	Trochę smuci cię to, że ludzie zdają się umierać, gdy ich łaskoczesz, \
	ale nie martw się! Gdy zginiesz, wszyscy, których przytuliłeś, zostaną \
	uwolnieni i w pełni uleczeni, bo w końcu to tylko żart, \
	rodzeństwo!</B>"

/mob/living/simple_animal/slaughter/laughter/Destroy()
	release_friends()
	. = ..()

/mob/living/simple_animal/slaughter/laughter/ex_act(severity)
	switch(severity)
		if(1)
			death()
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/slaughter/laughter/proc/release_friends()
	if(!consumed_mobs)
		return

	for(var/mob/living/M in consumed_mobs)
		if(!M)
			continue
		var/turf/T = find_safe_turf()
		if(!T)
			T = get_turf(src)
		M.forceMove(T)
		if(M.revive(full_heal = TRUE, admin_revive = TRUE))
			M.grab_ghost(force = TRUE)
			playsound(T, feast_sound, 50, 1, -1)
			to_chat(M, "<span class='clowntext'>Opuszczasz ciepłe objęcia [src] i czujesz, że możesz zawojować świat.</span>")

/mob/living/simple_animal/slaughter/laughter/bloodcrawl_swallow(var/mob/living/victim)
	if(consumed_mobs)
		// Keep their corpse so rescue is possible
		consumed_mobs += victim
	else
		// Be safe and just eject the corpse
		victim.forceMove(get_turf(victim))
		victim.exit_blood_effect()
		victim.visible_message("[victim] spada z powietrza, cały we krwi, wyraźnie zdezorientowany. I martwy.")
