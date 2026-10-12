/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = TRUE
	anchored = TRUE

/obj/structure/dresser/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>Zaczynasz [anchored ? "odkręcać" : "przykręcać"] [src].</span>")
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>[anchored ? "Odkręcasz" : "Przykręcasz"] [src].</span>")
			setAnchored(!anchored)
	else
		return ..()

/obj/structure/dresser/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
	qdel(src)

/obj/structure/dresser/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.dna && H.dna.species && (NO_UNDERWEAR in H.dna.species.species_traits))
			to_chat(user, "<span class='warning'>Nie możesz nosić bielizny.</span>")
			return

		var/choice = input(user, "Bielizna, podkoszulek czy skarpetki?", "Changing") as null|anything in list("Underwear","Underwear Color","Undershirt","Socks")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				var/new_undies = input(user, "Wybierz bieliznę", "Changing")  as null|anything in unlocked_accessories(GLOB.underwear_list, user.client) // AQ EDIT
				if(new_undies)
					H.underwear = new_undies
			if("Underwear Color")
				var/new_underwear_color = input(H, "Wybierz kolor bielizny", "Underwear Color","#"+H.underwear_color) as color|null
				if(new_underwear_color)
					H.underwear_color = sanitize_hexcolor(new_underwear_color)
			if("Undershirt")
				var/new_undershirt = input(user, "Wybierz podkoszulek", "Changing") as null|anything in unlocked_accessories(GLOB.undershirt_list, user.client) // AQ EDIT
				if(new_undershirt)
					H.undershirt = new_undershirt
			if("Socks")
				var/new_socks = input(user, "Wybierz skarpetki", "Changing") as null|anything in unlocked_accessories(GLOB.socks_list, user.client) // AQ EDIT
				if(new_socks)
					H.socks= new_socks

		add_fingerprint(H)
		H.update_body()
