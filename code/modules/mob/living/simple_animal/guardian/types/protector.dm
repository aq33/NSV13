//Protector
/mob/living/simple_animal/hostile/guardian/protector
	melee_damage = 15
	range = 15 //worse for it due to how it leashes
	damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
	playstyle_string = "<span class='holoparasite'>Jako typ <b>protector</b> to twój przywoływacz jest przywiązany do ciebie, a nie odwrotnie. Masz dwa tryby: bojowy, w którym zadajesz i otrzymujesz średnie obrażenia, oraz ochronny, w którym prawie nie zadajesz ani nie otrzymujesz obrażeń, ale poruszasz się nieco wolniej.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Strażnika, niezłomnego obrońcę, który nigdy nie odstępuje swojego podopiecznego.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano moduły obrońcy. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! Chwila, nie... to on złowił ciebie! Rybak stał się rybką.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się niezwykle odporna na obrażenia i mieć szczególną więź z właścicielem.</span>"
	toggle_button_type = /atom/movable/screen/guardian/ToggleMode
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/protector/ex_act(severity)
	if(severity == 1)
		adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the summoner
	else
		..()
	if(QDELETED(src))
		return
	if(toggle)
		visible_message("<span class='danger'>Eksplozja ześlizguje się po tarczy energetycznej [src]!</span>")

/mob/living/simple_animal/hostile/guardian/protector/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && toggle)
		var/image/I = new('icons/effects/effects.dmi', src, "shield-flash", MOB_LAYER+0.01, dir = pick(GLOB.cardinals))
		if(guardiancolor)
			I.color = guardiancolor
		flick_overlay_view(I, src, 5)

/mob/living/simple_animal/hostile/guardian/protector/ToggleMode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		cut_overlays()
		melee_damage = initial(melee_damage)
		speed = initial(speed)
		damage_coeff = list(BRUTE = 0.4, BURN = 0.4, TOX = 0.4, CLONE = 0.4, STAMINA = 0, OXY = 0.4)
		to_chat(src, "<span class='danger'><B>Przełączasz się w tryb bojowy.</span></B>")
		toggle = FALSE
	else
		var/mutable_appearance/shield_overlay = mutable_appearance('icons/effects/effects.dmi', "shield-grey")
		if(guardiancolor)
			shield_overlay.color = guardiancolor
		add_overlay(shield_overlay)
		melee_damage = 2
		speed = 1
		damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		to_chat(src, "<span class='danger'><B>Przełączasz się w tryb ochronny.</span></B>")
		toggle = TRUE

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			if(istype(summoner.loc, /obj/effect))
				to_chat(src, "<span class='holoparasite'>Oddalasz się poza zasięg i zostajesz ściągnięty z powrotem! Możesz oddalić się od [summoner.real_name] najwyżej o [range] m!</span>")
				visible_message("<span class='danger'>[src] wraca do swojego użytkownika.</span>")
				Recall(TRUE)
			else
				to_chat(summoner, "<span class='holoparasite'>Oddalasz się poza zasięg i zostajesz ściągnięty z powrotem! Możesz oddalić się od <font color=\"[guardiancolor]\"><b>[real_name]</b></font> najwyżej o [range] m!</span>")
				summoner.visible_message("<span class='danger'>[summoner] wraca do swojego obrońcy.</span>")
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(summoner))
				summoner.forceMove(get_turf(src))
				new /obj/effect/temp_visual/guardian/phase(get_turf(summoner))
