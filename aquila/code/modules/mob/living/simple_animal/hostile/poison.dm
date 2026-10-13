// AQUILA - podstawa jadowitych mobów (pszczoły, wężo-kończyna). Do tej pory siedziała w giant_spider.dm,
// które zastąpiły pająki z tg (aquila/code/modules/mob/living/simple_animal/hostile/spider/).

/mob/living/simple_animal/hostile/poison
	mobchatspan = "researchdirector"
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin

/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)
