

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U, params)
	if(U!=affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/reagent_containers/glass))//If it's a glass beaker.
		if(I.reagents.has_reagent(/datum/reagent/uranium/radium, a_transfer) && a_boost < a_maxamount)
			I.reagents.remove_reagent(/datum/reagent/uranium/radium, a_transfer)
			a_boost++;
			to_chat(U, "<span class='notice'>Pozostałe dopalacze adrenaliny: [a_boost].</span>")
			return
		if(I.reagents.has_reagent(/datum/reagent/smoke_powder, a_transfer) && s_bombs < s_maxamount)
			I.reagents.remove_reagent(/datum/reagent/smoke_powder, a_transfer)
			s_bombs++;
			to_chat(U, "<span class='notice'>Pozostałe bomby dymne: [s_bombs].</span>")
			return


	else if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/CELL = I
		if(CELL.maxcharge > cell.maxcharge && n_gloves && n_gloves.candrain)
			to_chat(U, "<span class='notice'>Wykryto wyższą maksymalną pojemność.\nUlepszanie...</span>")
			if (n_gloves?.candrain && do_after(U,s_delay, target = src))
				U.transferItemToLoc(CELL, src)
				CELL.charge = min(CELL.charge+cell.charge, CELL.maxcharge)
				var/obj/item/stock_parts/cell/old_cell = cell
				old_cell.charge = 0
				U.put_in_hands(old_cell)
				old_cell.add_fingerprint(U)
				old_cell.corrupt()
				old_cell.update_icon()
				cell = CELL
				to_chat(U, "<span class='notice'>Ulepszanie zakończone. Maksymalna pojemność: <b>[round(cell.maxcharge/100)]</b>%</span>")
			else
				to_chat(U, "<span class='danger'>Procedura przerwana. Protokół zakończony.</span>")
		return

	else if(istype(I, /obj/item/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
		var/obj/item/disk/tech_disk/TD = I
		var/has_research = 0
		if(has_research)//If it has something on it.
			to_chat(U, "Wykryto dane badawcze, przetwarzanie...")
			if(do_after(U,s_delay, target = src))
				TD.stored_research.copy_research_to(stored_research)
				to_chat(U, "<span class='notice'>Dane przeanalizowane i zaktualizowane. Dysk wyczyszczony.</span>")
			else
				to_chat(U, "<span class='userdanger'>BŁĄD</span>: procedura przerwana. Proces zakończony.")
		else
			to_chat(U, "<span class='notice'>Nie wykryto danych badawczych.</span>")
		return
	return ..()
