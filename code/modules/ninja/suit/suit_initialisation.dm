/obj/item/clothing/suit/space/space_ninja/proc/toggle_on_off()
	if(s_busy)
		to_chat(loc, "<span class='userdanger'>BŁĄD</span>: nie możesz teraz użyć tej funkcji.")
		return FALSE
	if(s_initialized)
		deinitialize()
	else
		ninitialize()
	. = TRUE

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize(delay = s_delay, mob/living/carbon/human/U = loc)
	if(!U.mind)
		return //Not sure how this could happen.
	s_busy = TRUE
	to_chat(U, "<span class='notice'>Inicjalizacja...</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_two), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_two(delay, mob/living/carbon/human/U)
	if(!lock_suit(U))//To lock the suit onto wearer.
		s_busy = FALSE
		return
	to_chat(U, "<span class='notice'>Zabezpieczanie zewnętrznego mechanizmu blokującego...\nSieć neuronowa nawiązana.</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_three), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_three(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Rozszerzanie interfejsu sieci neuronowej...\nMonitorowanie wzorca fal mózgowych...</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_four), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_four(delay, mob/living/carbon/human/U)
	if(U.stat == DEAD|| U.health <= 0)
		to_chat(U, "<span class='danger'><B>FÄAL ï¿½Rrï¿½R</B>: 344--93#ï¿½&&21 BRï¿½ï¿½N |/|/aVï¿½ PATT$RN <B>RED</B>\nA-A-aBï¿½rTï¿½NG...</span>")
		unlock_suit()
		s_busy = FALSE
		return
	lockIcons(U)//Check for icons.
	U.regenerate_icons()
	to_chat(U, "<span class='notice'>Łączenie interfejsu sieci neuronowej...\nWzorzec</span>\green <B>ZIELONY</B><span class='notice'>, kontynuowanie operacji.</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_five), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_five(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Stan urządzenia VOID-shift: <B>ONLINE</B>.\nStan urządzenia CLOAK-tech: <B>ONLINE</B>.</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_six), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_six(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Stan systemu głównego: <B>ONLINE</B>.\nStan systemu zapasowego: <B>ONLINE</B>.\nObecny zapas energii: <B>[display_energy(cell.charge)]</B>.</span>")
	addtimer(CALLBACK(src, PROC_REF(ninitialize_seven), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/ninitialize_seven(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Wszystkie systemy sprawne. Witaj w <B>SpiderOS</B>, [U.real_name].</span>")
	s_initialized = TRUE
	ntick()
	s_busy = FALSE



/obj/item/clothing/suit/space/space_ninja/proc/deinitialize(delay = s_delay)
	if(affecting==loc)
		var/mob/living/carbon/human/U = affecting
		if(alert("Czy na pewno chcesz zdjąć kombinezon? Zajmie to trochę czasu i odbierze wszystkie zdolności.",,"Yes","No")=="No")
			return
		s_busy = TRUE
		addtimer(CALLBACK(src, PROC_REF(deinitialize_two), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_two(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Deinicjalizacja...</span>")
	addtimer(CALLBACK(src, PROC_REF(deinitialize_three), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_three(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Wylogowywanie, [U.real_name]. Wyłączanie <B>SpiderOS</B>.</span>")
	addtimer(CALLBACK(src, PROC_REF(deinitialize_four), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_four(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Stan systemu głównego: <B>OFFLINE</B>.\nStan systemu zapasowego: <B>OFFLINE</B>.</span>")
	addtimer(CALLBACK(src, PROC_REF(deinitialize_five), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_five(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Stan urządzenia VOID-shift: <B>OFFLINE</B>.\nStan urządzenia CLOAK-tech: <B>OFFLINE</B>.</span>")
	cancel_stealth()//Shutdowns stealth.
	addtimer(CALLBACK(src, PROC_REF(deinitialize_six), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_six(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Odłączanie interfejsu sieci neuronowej...</span>\green<B>Sukces</B><span class='notice'>.</span>")
	addtimer(CALLBACK(src, PROC_REF(deinitialize_seven), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_seven(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Rozłączanie interfejsu sieci neuronowej...</span>\green<B>Sukces</B><span class='notice'>.</span>")
	addtimer(CALLBACK(src, PROC_REF(deinitialize_eight), delay, U), delay)

/obj/item/clothing/suit/space/space_ninja/proc/deinitialize_eight(delay, mob/living/carbon/human/U)
	to_chat(U, "<span class='notice'>Odbezpieczanie zewnętrznego mechanizmu blokującego...\nSieć neuronowa zlikwidowana.\nStan operacji: <B>ZAKOŃCZONO</B>.</span>")
	unlock_suit()
	U.regenerate_icons()
	s_initialized = FALSE
	s_busy = FALSE
