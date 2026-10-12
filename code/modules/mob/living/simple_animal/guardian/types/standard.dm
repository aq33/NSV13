//Standard
/mob/living/simple_animal/hostile/guardian/punch
	melee_damage = 20
	obj_damage = 80
	next_move_modifier = 0.8 //attacks 20% faster
	environment_smash = ENVIRONMENT_SMASH_WALLS
	playstyle_string = "<span class='holoparasite'>Jako typ <b>standard</b> nie masz specjalnych zdolności, ale masz wysoką odporność na obrażenia i potężny atak zdolny przebijać ściany.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Asystenta, bezimiennego i przeciętnego, ale nigdy nie do zlekceważenia.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano standardowe moduły bojowe. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! Jest strasznie nudny i standardowy. Lepiej poboksuj trochę ściany, żeby rozładować napięcie.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się mieć ogromną siłę i zwiększoną zwinność.</span>"
	var/battlecry = "AT"

/mob/living/simple_animal/hostile/guardian/punch/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch people."
	var/input = stripped_input(src,"Jaki ma być twój okrzyk bojowy? Maksymalnie 6 znaków.", ,"", 7)
	if(input)
		if(CHAT_FILTER_CHECK(input))
			to_chat(src, "<span class='warning'>Twój okrzyk bojowy nie może zawierać zakazanych słów! Przeczytaj jeszcze raz zasady serwera.</span>")
			return
		else
			battlecry = input




/mob/living/simple_animal/hostile/guardian/punch/AttackingTarget()
	. = ..()
	if(isliving(target))
		say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!", ignore_spam = TRUE)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
