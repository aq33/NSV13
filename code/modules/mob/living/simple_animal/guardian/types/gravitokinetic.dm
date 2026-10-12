//gravitokinetic
/mob/living/simple_animal/hostile/guardian/gravitokinetic
	melee_damage = 15
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = "<span class='holoparasite'>Jako typ <b>gravitokinetic</b> możesz alt-kliknięciem wzmocnić grawitację na podłożu, a twoje ciosy nakładają ten efekt na cel.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Osobliwość, anomalną siłę grozy.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano moduły grawitokinetyczne. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To grawitokinetyczny karp! Rozumiesz już powagę sytuacji?</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się niezwykle ciężka i zdolna przekazywać ten ciężar innym.</span>"
	var/list/gravito_targets = list()
	var/gravity_power_range = 10 //how close the stand must stay to the target to keep the heavy gravity
	var/datum/callback/distance_check

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Initialize(mapload)
	. = ..()
	distance_check = CALLBACK(src, PROC_REF(__distance_check))

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AttackingTarget()
	. = ..()
	if(isliving(target) && target != src)
		to_chat(src, "<span class='danger'><B>Twój cios nakłada na [target] potężną grawitację!</span></B>")
		add_gravity(target, 2)
		to_chat(target, "<span class='userdanger'>Wszystko wydaje się bardzo ciężkie!</span>")

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AltClickOn(atom/A)
	if(isopenturf(A) && is_deployed() && stat != DEAD && in_range(src, A) && !incapacitated())
		var/turf/T = A
		if(isspaceturf(T))
			to_chat(src, "<span class='warning'>Nie możesz dodać grawitacji w kosmosie!</span>")
			return
		visible_message("<span class='danger'>[src] uderza pięścią w [T]!</span>", "<span class='notice'>Zmieniasz grawitację na [T].</span>")
		do_attack_animation(T)
		add_gravity(T, 4)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Recall(forced)
	. = ..()
	to_chat(src, "<span class='danger'><B>Uwalniasz swoje moce grawitokinetyczne!</span></B>")
		for(var/i in gravito_targets)
		remove_gravity(i)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Moved(oldLoc, dir)
	. = ..()
	for(var/i in gravito_targets)
		if(get_dist(src, i) > gravity_power_range)
			remove_gravity(i)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/add_gravity(atom/A, new_gravity = 2)
    A.AddElement(/datum/element/forced_gravity, new_gravity)
	gravito_targets[A] = new_gravity
	RegisterSignal(A, COMSIG_MOVABLE_MOVED, PROC_REF(__distance_check))
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/remove_gravity(atom/target)
	if(isnull(gravito_targets[target]))
		return
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/forced_gravity, gravito_targets[target])
	gravito_targets -= target

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/__distance_check(atom/movable/AM, OldLoc, Dir, Forced)
	SIGNAL_HANDLER

	if(get_dist(src, AM) > gravity_power_range)
		remove_gravity(AM)
