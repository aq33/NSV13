// Billboardy z tg (code/game/objects/structures/billboard.dm), potrzebne w ruinach górniczych.
/obj/structure/billboard
	name = "blank billboard"
	desc = "A blank billboard, with space for all kinds of advertising."
	icon = 'aquila/icons/obj/billboard.dmi'
	icon_state = "billboard_blank"
	layer = ABOVE_MOB_LAYER
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/billboard/donk_n_go
	name = "\improper Donk-n-Go billboard"
	desc = "A billboard advertising Donk-n-Go, Donk Co's ever-present and ever-unhealthy fast-food venture: GET IN, GET FED, GET GONE!"
	icon_state = "billboard_donk_n_go"

/obj/structure/billboard/space_cola
	name = "\improper Space Cola billboard"
	desc = "A billboard advertising Space Cola: Relax, have a Spoke."
	icon_state = "billboard_space_cola"

/obj/structure/billboard/nanotrasen
	name = "\improper Nanotrasen billboard"
	desc = "A billboard advertising Nanotrasen: A Better Tomorrow, Today."
	icon_state = "billboard_nanotrasen"

/obj/structure/billboard/nanotrasen/defaced
	name = "defaced Nanotrasen billboard"
	desc = "A billboard advertising Nanotrasen. Someone's sprayed a message onto it: Fuck Corpo Pigs."
	icon_state = "billboard_fuck_corps"

/obj/structure/billboard/azik
	name = "\improper Azik Interstellar billboard"
	desc = "A billboard advertising Azik Interstellar and their newest model: the Autocrat Solar Sailer. Azik Interstellar: Tiziran Refinement for Galactic Necessities."
	icon_state = "billboard_azik"

/obj/structure/billboard/twenty_four_seven
	name = "\improper 24-Seven billboard"
	desc = "A billboard advertising 24-Seven's new range of limited-edition Slushee flavours. 24-Seven: All Day, Every Day."
	icon_state = "billboard_twenty_four_seven"

/obj/structure/billboard/starway
	name = "\improper Starway Transit billboard"
	desc = "A billboard advertising Starway Transit's direct flight from New Moscow to New York: only 2000 credits for an economy class berth. Starway: Your Ticket to the Stars."
	icon_state = "billboard_starway"

/obj/effect/spawner/lootdrop/billboard
	name = "billboard spawner"
	icon = 'aquila/icons/obj/billboard.dmi'
	icon_state = "billboard_random"
	loot = list(
		/obj/structure/billboard/azik = 50,
		/obj/structure/billboard/donk_n_go = 50,
		/obj/structure/billboard/space_cola = 50,
		/obj/structure/billboard/twenty_four_seven = 30,
		/obj/structure/billboard/starway = 30,
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)
