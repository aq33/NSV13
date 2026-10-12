//Charger
/mob/living/simple_animal/hostile/guardian/charger
	melee_damage = 15
	ranged = 1 //technically
	ranged_message = "charges"
	ranged_cooldown_time = 40
	speed = -1
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	playstyle_string = "<span class='holoparasite'>Jako typ <b>charger</b> zadajesz średnie obrażenia, masz średnią odporność na obrażenia, poruszasz się bardzo szybko i możesz szarżować na wskazane miejsce, raniąc każdy trafiony cel i zmuszając go do upuszczenia trzymanych przedmiotów.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Łowcę, obcego mistrza błyskawicznego szturmu.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano moduły szarży. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To karp-szarżownik, który lubi wbiegać w ludzi. Tylko że nie ma nóg...</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się mieć pierwotne zmysły i błyskawicznie atakuje wrogów.</span>"
	var/charging = 0
	var/atom/movable/screen/alert/chargealert

/mob/living/simple_animal/hostile/guardian/charger/Life()
	. = ..()
	if(ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = throw_alert("charge", /atom/movable/screen/alert/cancharge)
	else
		clear_alert("charge")
		chargealert = null

/mob/living/simple_animal/hostile/guardian/charger/OpenFire(atom/A)
	if(!charging)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		ranged_cooldown = world.time + ranged_cooldown_time
		clear_alert("charge")
		chargealert = null
		Shoot(A)

/mob/living/simple_animal/hostile/guardian/charger/Shoot(atom/targeted_atom)
	charging = 1
	throw_at(targeted_atom, range, 1, src, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(charging_end)))

/mob/living/simple_animal/hostile/guardian/charger/proc/charging_end()
	charging = 0

/mob/living/simple_animal/hostile/guardian/charger/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
	. = ..()

/mob/living/simple_animal/hostile/guardian/charger/snapback()
	if(!charging)
		..()

/mob/living/simple_animal/hostile/guardian/charger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!charging)
		return ..()

	else if(hit_atom)
		if(isliving(hit_atom) && hit_atom != summoner)
			var/mob/living/L = hit_atom
			var/blocked = FALSE
			if(hasmatchingsummoner(hit_atom)) //if the summoner matches don't hurt them
				blocked = TRUE
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				if(H.check_shields(src, 90, "[name]", attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[src] wpada z impetem na [L]!</span>", "<span class='userdanger'>[src] wpada na ciebie z impetem!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(src, 2, 3)

		charging = 0

