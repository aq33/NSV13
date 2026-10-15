//Toy
/mob/living/simple_animal/hostile/guardian/toy
	melee_damage = 0
	obj_damage = 0
	next_move_modifier = 0.1 //attacks 90% faster
	playstyle_string = "<span class='holoparasite'>Jako typ <b>toy</b> jesteś pod każdym względem całkowicie bezużyteczny i stanowisz wyłącznie obciążenie dla właściciela. Ale wyglądasz świetnie!</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Klauna, nieznośnie irytujące i bezużyteczne obciążenie.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Standardowe moduły bojowe zablokowane. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! Jest słaby i bezużyteczny. Mogę prosić o zwrot pieniędzy?</span>"
	var/battlecry = "HONK"
	discovery_points = 0

/mob/living/simple_animal/hostile/guardian/toy/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you limply slap people."
	var/input = stripped_input(src,"Jaki ma być twój okrzyk bojowy? Maksymalnie 6 znaków.", ,"", 7)
	if(input)
		if(CHAT_FILTER_CHECK(input))
			to_chat(src, "<span class='warning'>Twój okrzyk bojowy nie może zawierać zakazanych słów! Przeczytaj jeszcze raz zasady serwera.</span>")
			return
		else
			battlecry = input



/mob/living/simple_animal/hostile/guardian/toy/AttackingTarget()
	. = ..()
	if(isliving(target))
		say("[battlecry]!!", ignore_spam = TRUE)
		playsound(loc, src.attack_sound, 50, 1, 1)
