/obj/item/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	implant_color = "r"
	uses = 4


/obj/item/implant/freedom/activate()
	. = ..()
	uses--
	to_chat(imp_in, "Czujesz ciche kliknięcie.")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
	if(!uses)
		qdel(src)


/obj/item/implant/freedom/get_data()
	var/dat = {"
<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Nadajnik wolności<BR><b>Żywotność:</b> optymalnie 5 użyć<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><HR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> wysyła specjalny zestaw sygnałów nadpisujących mechanizmy blokujące kajdanki<BR><b>Cechy specjalne:</b><BR><i>Neuroskan</i> - analizuje określone sygnały cienia w układzie nerwowym<BR><HR>Brak szczegółów implantu"}
	return dat


/obj/item/implanter/freedom
	name = "implanter (freedom)"
	imp_type = /obj/item/implant/freedom

/obj/item/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = "A glass case containing a freedom implant."
	imp_type = /obj/item/implant/freedom
