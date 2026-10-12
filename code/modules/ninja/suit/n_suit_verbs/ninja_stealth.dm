
/*

Contents:
- Stealth Verbs

*/


/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(U, "<span class='warning'>Nie masz dość energii, by włączyć ukrycie!</span>")
			return
		stealth = !stealth
		animate(U, alpha = 50,time = 15)
		U.visible_message("<span class='warning'>[U.name] rozpływa się w powietrzu!</span>", \
						"<span class='notice'>Jesteś teraz prawie niewidzialny dla zwykłego wykrywania.</span>")


/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return 0
	if(stealth)
		stealth = !stealth
		animate(U, alpha = 255, time = 15)
		U.visible_message("<span class='warning'>[U.name] pojawia się znikąd!</span>", \
						"<span class='notice'>Jesteś teraz widoczny.</span>")
		return 1
	return 0


/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	if(!s_busy)
		toggle_stealth()
	else
		to_chat(affecting, "<span class='danger'>Ukrycie zdaje się nie działać!</span>")
