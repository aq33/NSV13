//Beam
/obj/effect/ebeam/chain
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/mob/living/simple_animal/hostile/guardian/beam
	melee_damage = 7
	attacktext = "razi prądem"
	melee_damage_type = BURN
	attack_sound = 'sound/machines/defib_zap.ogg'
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	range = 7
	playstyle_string = "<span class='holoparasite'>Jako typ <b>lightning</b> atakami zakładasz na cele łańcuchy błyskawic i masz łańcuch błyskawic połączony z przywoływaczem. Łańcuchy razią prądem każdego w pobliżu.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Teslę, porażające, zabójcze źródło mocy.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Moduły błyskawic aktywne. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To karp-błyskawica! Wszystkich innych kopie prąd.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się wywoływać wokół siebie mnóstwo uderzeń piorunów.</span>"
	var/datum/beam/summonerchain
	var/list/enemychains = list()
	var/successfulshocks = 0

/mob/living/simple_animal/hostile/guardian/beam/AttackingTarget()
	. = ..()
	if(. && isliving(target) && target != src && target != summoner)
		cleardeletedchains()
		for(var/chain in enemychains)
			var/datum/beam/B = chain
			if(B.target == target)
				return //oh this guy already HAS a chain, let's not chain again
		if(enemychains.len > 2)
			var/datum/beam/C = pick(enemychains)
			qdel(C)
			enemychains -= C
		enemychains += Beam(target, "lightning[rand(1,12)]", time=70, maxdistance=7, beam_type=/obj/effect/ebeam/chain)

/mob/living/simple_animal/hostile/guardian/beam/Destroy()
	removechains()
	return ..()

/mob/living/simple_animal/hostile/guardian/beam/Manifest()
	. = ..()
	if(.)
		if(summoner)
			summonerchain = Beam(summoner, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		while(loc != summoner)
			if(successfulshocks > 5)
				successfulshocks = 0
			if(shockallchains())
				successfulshocks++
			sleep(3)

/mob/living/simple_animal/hostile/guardian/beam/Recall()
	. = ..()
	if(.)
		removechains()

/mob/living/simple_animal/hostile/guardian/beam/proc/cleardeletedchains()
	if(summonerchain && QDELETED(summonerchain))
		summonerchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/mob/living/simple_animal/hostile/guardian/beam/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(summoner)
		if(!summonerchain)
			summonerchain = Beam(summoner, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(summonerchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/mob/living/simple_animal/hostile/guardian/beam/proc/removechains()
	if(summonerchain)
		qdel(summonerchain)
		summonerchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			qdel(chain)
		enemychains = list()

/mob/living/simple_animal/hostile/guardian/beam/proc/chainshock(datum/beam/B)
	. = 0
	var/list/turfs = list()
	for(var/E in B.elements)
		var/obj/effect/ebeam/chainpart = E
		if(chainpart && chainpart.x && chainpart.y && chainpart.z)
			var/turf/T = get_turf_pixel(chainpart)
			turfs |= T
			if(T != get_turf(B.origin) && T != get_turf(B.target))
				for(var/turf/TU in circlerange(T, 1))
					turfs |= TU
	for(var/turf in turfs)
		var/turf/T = turf
		for(var/mob/living/L in T)
			if(L.stat != DEAD && L != src && L != summoner)
				if(hasmatchingsummoner(L)) //if the summoner matches don't hurt them
					continue
				if(successfulshocks > 4)
					if(iscarbon(L))
						var/mob/living/carbon/C = L
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							H.electrocution_animation(20)
						C.jitteriness += 1000
						C.do_jitter_animation(jitteriness)
						C.stuttering += 1
						addtimer(CALLBACK(src, PROC_REF(lower_jitter), C), 20)
					L.visible_message(
						"<span class='danger'>Łańcuch błyskawic razi [L]!</span>", \
						"<span class='userdanger'>Razi cię łańcuch błyskawic!</span>", \
						"<span class='italics'>Słyszysz głośny trzask elektryczny.</span>" \
					)
				L.adjustFireLoss(1.2) //adds up very rapidly
				. = 1

/mob/living/simple_animal/hostile/guardian/beam/proc/lower_jitter(mob/living/carbon/C)
	if(!C)
		return
	C.jitteriness = max(C.jitteriness - 990, 10) //adjust the jitter to 10 at most after 2 seconds
