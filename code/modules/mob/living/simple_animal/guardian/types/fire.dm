//Fire
/mob/living/simple_animal/hostile/guardian/fire
	a_intent = INTENT_HELP
	melee_damage = 7
	attack_sound = 'sound/items/welder.ogg'
	attacktext = "podpala"
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	range = 7
	playstyle_string = "<span class='holoparasite'>Jako typ <b>chaos</b> masz tylko niewielką odporność na obrażenia, ale podpalasz każdego wroga, na którego wpadniesz. Ponadto twoje ataki wręcz sprawiają, że ludzie widzą wszystkich wokół jako ciebie.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Czarodzieja, zwiastuna nieskończonego chaosu!</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Moduły kontroli tłumu aktywne. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! O BOŻE, WSZYSTKO PŁONIE. Oprócz ciebie i rybki.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się generować mnóstwo energii, przez co wszystko oprócz właściciela płonie na popiół.</span>"

/mob/living/simple_animal/hostile/guardian/fire/Initialize(mapload, theme)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/hostile/guardian/fire/Life()
	. = ..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	. = ..()
	if(. && ishuman(target) && target != summoner)
		new /datum/hallucination/delusion(target,TRUE,"custom",200,0, icon_state,icon)

/mob/living/simple_animal/hostile/guardian/fire/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(atom/movable/AM)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(!hasmatchingsummoner(M) && M != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()
