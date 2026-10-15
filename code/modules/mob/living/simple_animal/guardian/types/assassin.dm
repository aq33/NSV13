//Assassin
/mob/living/simple_animal/hostile/guardian/assassin
	melee_damage = 15
	attacktext = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	playstyle_string = "<span class='holoparasite'>Jako typ <b>assassin</b> zadajesz średnie obrażenia i nie masz odporności na obrażenia, ale możesz się ukryć, co znacznie zwiększa obrażenia twojego następnego ataku i sprawia, że ignoruje on pancerz. Ukrycie przerywa atak lub otrzymanie obrażeń.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Kosmicznego Ninję, zabójczego, niewidzialnego skrytobójcę.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano moduły zabójcy. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To karp-zabójca! Akurat gdy myślałeś, że można bezpiecznie wrócić do wody... co nie pomaga, bo jesteśmy w kosmosie.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się zdolna do ataków z ukrycia, zadających ogromne obrażenia.</span>"
	toggle_button_type = /atom/movable/screen/guardian/ToggleMode/Assassin
	var/toggle = FALSE
	var/stealthcooldown = 160
	var/atom/movable/screen/alert/canstealthalert
	var/atom/movable/screen/alert/instealthalert

/mob/living/simple_animal/hostile/guardian/assassin/Initialize(mapload)
	. = ..()
	stealthcooldown = 0

/mob/living/simple_animal/hostile/guardian/assassin/Life()
	. = ..()
	updatestealthalert()
	if(loc == summoner && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/get_stat_tab_status()
	var/list/tab_data = ..()
	if(stealthcooldown >= world.time)
		tab_data["Odnowienie kamuflażu"] = GENERATE_STAT_TEXT("[DisplayTimeText(stealthcooldown - world.time)]")

/mob/living/simple_animal/hostile/guardian/assassin/AttackingTarget()
	. = ..()
	if(.)
		if(toggle && (isliving(target) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille)))
			ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		ToggleMode(1)

/mob/living/simple_animal/hostile/guardian/assassin/Recall()
	if(..() && toggle)
		ToggleMode(0)

/mob/living/simple_animal/hostile/guardian/assassin/ToggleMode(forced = 0)
	if(toggle)
		melee_damage = initial(melee_damage)
		armour_penetration = initial(armour_penetration)
		obj_damage = initial(obj_damage)
		environment_smash = initial(environment_smash)
		alpha = initial(alpha)
		if(!forced)
			to_chat(src, "<span class='danger'><B>Wychodzisz z ukrycia.</span></B>")
		else
			visible_message("<span class='danger'>[src] nagle się pojawia!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forced out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(src.loc == summoner)
			to_chat(src, "<span class='danger'><B>Musisz się zmaterializować, by się ukryć!</span></B>")
			return
		melee_damage = 50
		armour_penetration = 100
		obj_damage = 0
		environment_smash = ENVIRONMENT_SMASH_NONE
		new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
		alpha = 15
		if(!forced)
			to_chat(src, "<span class='danger'><B>Ukrywasz się, wzmacniając swój następny atak.</span></B>")
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		to_chat(src, "<span class='danger'><B>Nie możesz jeszcze się ukryć, zaczekaj jeszcze [DisplayTimeText(stealthcooldown - world.time)]!</span></B>")

/mob/living/simple_animal/hostile/guardian/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = throw_alert("instealth", /atom/movable/screen/alert/instealth)
				clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = throw_alert("canstealth", /atom/movable/screen/alert/canstealth)
				clear_alert("instealth")
				instealthalert = null
	else
		clear_alert("instealth")
		instealthalert = null
		clear_alert("canstealth")
		canstealthalert = null
