/mob/living/simple_animal/horror/Topic(href, href_list, hsrc)
	if(href_list["horror_use_chem"])
		locate(href_list["src"])
		if(!istype(src, /mob/living/simple_animal/horror))
			return

		var/topic_chem = href_list["horror_use_chem"]
		var/datum/horror_chem/C

		for(var/datum in typesof(/datum/horror_chem))
			var/datum/horror_chem/test = new datum()
			if(test.chemname == topic_chem)
				C = test
				break

		if(!istype(C, /datum/horror_chem))
			return

		if(!C || !victim || controlling || !src || stat)
			return

		if(!istype(C, /datum/horror_chem))
			return

		if(chemicals < C.chemuse)
			to_chat(src, "<span class='boldnotice'>Potrzebujesz [C.chemuse] zgromadzonych chemikaliów, by użyć tej substancji!</span>")
			return

		to_chat(src, "<span class='danger'>Wstrzykujesz [C.quantity] jednostek [C.chemname] ze swoich zbiorników do krwiobiegu [victim].</span>")
		victim.reagents.add_reagent(C.R, C.quantity)
		chemicals -= C.chemuse
		log_game("[src]/([src.ckey]) has injected [C.chemname] into their host [victim]/([victim.ckey])")

		src << output(chemicals, "ViewHorror\ref[src]Chems.browser:update_chemicals")

	..()

/datum/horror_chem
	var/chemname
	var/chem_desc = "To jest substancja chemiczna."
	var/datum/reagent/R
	var/chemuse = 30
	var/quantity = 10

/datum/horror_chem/epinephrine
	chemname = "epinephrine"
	R = /datum/reagent/medicine/epinephrine
	chem_desc = "Stabilizuje stan krytyczny i powoli leczy niedotlenienie."

/datum/horror_chem/mannitol
	chemname = "mannitol"
	R = /datum/reagent/medicine/mannitol
	chem_desc = "Leczy uszkodzenia mózgu."

/datum/horror_chem/bicaridine
	chemname = "bicaridine"
	R = /datum/reagent/medicine/bicaridine
	chem_desc = "Leczy obrażenia fizyczne."

/datum/horror_chem/kelotane
	chemname = "kelotane"
	R = /datum/reagent/medicine/kelotane
	chem_desc = "Leczy oparzenia."

/datum/horror_chem/charcoal
	chemname = "charcoal"
	R = /datum/reagent/medicine/charcoal
	chem_desc = "Powoli leczy zatrucia i stopniowo usuwa z organizmu inne substancje."

/datum/horror_chem/adrenaline
	chemname = "adrenaline"
	R = /datum/reagent/medicine/changelingadrenaline
	chemuse = 100
	chem_desc = "Pobudza mózg, pozwalając otrząsnąć się z ogłuszeń i regenerując wytrzymałość."

/datum/horror_chem/rezadone
	chemname = "rezadone"
	R = /datum/reagent/medicine/rezadone
	chemuse = 50
	chem_desc = "Leczy uszkodzenia komórkowe."

/datum/horror_chem/pen_acid
	chemname = "pentetic acid"
	R = /datum/reagent/medicine/pen_acid
	chemuse = 50
	chem_desc = "Mocno redukuje napromieniowanie i zatrucia, usuwając z organizmu inne substancje."

/datum/horror_chem/sal_acid
	chemname = "salicylic acid"
	R = /datum/reagent/medicine/sal_acid
	chem_desc = "Przyspiesza gojenie ciężkich stłuczeń. Szybko leczy poważne obrażenia fizyczne, a lżejsze powoli."

/datum/horror_chem/oxandrolone
	chemname = "oxandrolone"
	R = /datum/reagent/medicine/oxandrolone
	chem_desc = "Przyspiesza gojenie ciężkich oparzeń. Szybko leczy poważne oparzenia, a lżejsze powoli."
