/obj/structure/speaking_tile
	name = "strange tile"
	desc = "A weird tile that beckons you towards it. Maybe it can help you get out of this mess..."
	verb_say = "intonuje"
	icon = 'icons/obj/structures.dmi'
	icon_state = "speaking_tile"
	layer = 5
	resistance_flags = INDESTRUCTIBLE
	var/speaking = FALSE
	var/times_spoken_to = 0
	var/list/shenanigans = list()

/obj/structure/speaking_tile/Initialize(mapload)
	. = ..()
	var/json_file = file("data/npc_saves/Poly.json")
	if(!fexists(json_file))
		return
	var/list/json = json_decode(rustg_file_read(json_file))
	shenanigans = json["phrases"]

/obj/structure/speaking_tile/interact(mob/user)
	if(!isliving(user) || speaking)
		return
	speaking = TRUE

	switch(times_spoken_to)
		if(0)
			SpeakPeace(list("Witaj w pokoju obsługi błędów.","Coś się nieźle zepsuło, skoro tu trafiłeś.","Pewnie powinieneś powiedzieć adminowi, co robiłeś, albo zgłosić błąd."))
			for(var/obj/structure/signpost/salvation/S in orange(7))
				S.invisibility = 0
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(1, S.loc)
				smoke.start()
				break
		if(1)
			SpeakPeace(list("Wejdź po tej drabinie.","Odeśle cię z powrotem na stację.","Mam nadzieję, że nigdy więcej nie będziesz musiał oglądać tego miejsca."))
		if(2)
			SpeakPeace(list("Ciekawi cię, co się stało?","Jakimś cudem twoja cielesna forma została wysłana do nullspace razem z tobą.","Na szczęście ten pokój istnieje, by uratować cię przed tym okropnym losem."))
		if(3)
			SpeakPeace(list("Więc tak, nie ma za co.","Tak w ogóle, nie masz nic do roboty?","Nie ma sensu siedzieć tu w nieskończoność."))
		if(4)
			SpeakPeace(list("Pochlebia mi, że tak bardzo zależy ci na tym pokoju.","Ale nie wypada stać tu całą zmianę i sprawdzać, co powiem.","Postaram się być bardziej nudny, żebyś sobie poszedł."))
		if(5 to 8)
			SpeakPeace(list("..."))
		if(9)
			SpeakPeace(list("Dobra, może to już <b>zbyt</b> nudne.", "Nie mogę jednak bez końca ręcznie pisać tych kwestii.", "Trudno to wyjaśnić, ale struktura kodu, której używam, jest dość okropna."))
		if(10)
			SpeakPeace(list("O, mam pomysł!", "Zlećmy tę niekończącą się gadaninę Poly!", "Wtedy będziesz mógł tego słuchać bez znudzenia!"))
			if(isnull(shenanigans) || !shenanigans.len)
				shenanigans = list("Tyle że brakuje pliku Poly...")
		if(11 to 14, 16 to 50, 52 to 99, 103 to 107, 109 to 203, 205 to 249, 252 to 665, 667 to 999, 1001 to 5642)
			SpeakPeace(list(pick(shenanigans),pick(shenanigans),pick(shenanigans)))
			if(times_spoken_to % 10 == 0)
				SpeakPeace(list("Tak przy okazji, rozmawiałeś ze mną już [times_spoken_to] razy."))
		if(15)
			SpeakPeace(list("Widzisz? Czy to nie jest fajne?","Teraz możesz to klikać godzinami bez znudzenia.","W każdym razie zostawiam cię z tym."))
		if(51)
			SpeakPeace(list("Tutaj zabawa nigdy się nie kończy.", "Pliki tekstowe Poly przechowują do 500 wypowiedzi.", "Ale pewnie słyszałeś już kilka powtórek."))
		if(100)
			SpeakPeace(list("I to jest równa setka.", "Niezła harówka, chyba.", "Pewnie słyszałeś już mnóstwo powtórek."))
		if(101)
			SpeakPeace(list("Mam nadzieję, że łapiesz nawiązanie, które przedstawia ten pokój.", "A także bardziej niejasne metanawiązanie, które przedstawia ta rozmowa.", "To ma warstwy."))
		if(102)
			SpeakPeace(list("Mam wielką ochotę ciągnąć to w nieskończoność.","Technicznie to łatwiejsze niż to, co robię.","Tak tylko mówię."))
		if(108)
			SpeakPeace(list("Ale masz mój szacunek za takie oddanie temu żartowi.", "Więc wiesz co, wyznaczymy sobie cel.", "250 to twoja ostatnia misja."))
		if(204)
			SpeakPeace(list("Zauważyłeś, że przy 200 nie było specjalnej wiadomości?", "Powolna automatyzacja czegoś, co kiedyś było znaczącymi kamieniami milowymi?","To wszystko część żartu."))
		if(250)
			SpeakPeace(list("Gratulacje.", "Według moich bardzo luźnych obliczeń zmarnowałeś na to już spory kawałek rundy.", "Ale zobaczyłeś ten mem do samego końca, a to samo w sobie jest przeżyciem, prawda?"))
		if(251)
			SpeakPeace(list("W każdym razie, proszę.", "Nie mogę dać ci niczego, co wpłynęłoby na przebieg rundy.","Ale na to przynajmniej zasłużyłeś."))
			var/obj/item/reagent_containers/food/drinks/trophy/silver_cup/the_ride = new(get_turf(user))
			the_ride.name = "Overextending The Joke: Second Place"
			the_ride.desc = "There's a point where this needed to stop, and we've clearly passed it."
		if(252)
			SpeakPeace(list("Wiesz, co to znaczy, prawda?", "Oczywiście, że to nie koniec!", "Pytanie brzmi teraz: czy bardziej imponujące jest brnąć dalej do nieznanego końca, czy mieć dość zdrowego rozsądku, by przestać tutaj?"))
		if(666)
			SpeakPeace(list("Ciemności w twoim sercu nie wypełnią proste frazesy.","Teraz nie przestaniesz, jesteś w tym do końca.", "Czy dotrzesz do mety, zanim skończy się runda?"))
		if(1000)
			SpeakPeace(list("Koniec istnieje gdzieś poza znaczącymi kamieniami milowymi.", "Do tego czasu nie będzie już żadnych wiadomości.", "Brzydzisz mnie."))
		if(5643)
			user.client.give_award(/datum/award/achievement/misc/time_waste, user)
			var/obj/item/reagent_containers/food/drinks/trophy/gold_cup/never_ends = new(get_turf(user))
			never_ends.name = "Overextending The Joke: First Place"
			never_ends.desc = "And so we are left alone with our regrets."
		else
			y += 2
	speaking = FALSE
	times_spoken_to++

/obj/structure/speaking_tile/attackby(obj/item/W, mob/user, params)
	return interact(user)

/obj/structure/speaking_tile/attack_paw(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_hulk(mob/user, does_attack_animation = 0)
	return interact(user)

/obj/structure/speaking_tile/attack_larva(mob/user, list/modifiers)
	return interact(user)

/obj/structure/speaking_tile/attack_ai(mob/user)
	return interact(user)

/obj/structure/speaking_tile/attack_slime(mob/user, list/modifiers)
	return interact(user)

/obj/structure/speaking_tile/attack_animal(mob/user)
	return interact(user)

/obj/structure/speaking_tile/proc/SpeakPeace(list/statements)
	for(var/i in 1 to statements.len)
		say("<span class='deadsay'>[statements[i]]</span>")
		if(i != statements.len)
			sleep(30)

/obj/item/rupee
	name = "weird crystal"
	desc = "Your excitement boils away as you realize it's just colored glass. Why would someone hoard these things?"
	icon = 'icons/obj/economy.dmi'
	icon_state = "rupee"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/glass = 500)

/obj/item/rupee/Initialize(mapload)
	. = ..()
	var/newcolor = color2hex(pick(10;"green", 5;"blue", 3;"red", 1;"purple"))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/rupee/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!ismob(AM))
		return
	INVOKE_ASYNC(src, PROC_REF(put_in_crossers_hands), AM)

/obj/item/rupee/proc/put_in_crossers_hands(mob/crosser)
	if(crosser.put_in_hands(src))
		if(src != crosser.get_active_held_item())
			crosser.swap_hand()

/obj/item/rupee/equipped(mob/user, slot)
	playsound(get_turf(loc), 'sound/misc/server-ready.ogg', 50, 1, -1)
	..()

/obj/effect/landmark/error
	name = "error"
	icon_state = "error_room"
