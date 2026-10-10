/obj/item/implant/dusting
	name = "duster implant"
	desc = "An alarm which monitors host vital signs, transmitting a radio message and dusting the corpse on death."
	actions_types = list(/datum/action/item_action/dusting_implant)
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE

/obj/item/implant/dusting/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant bezpieczeństwa Ultraviolet Corp XX-13<BR><b>Żywotność:</b> aktywuje się po śmierci.<BR><b>Ważne uwagi:</b> odparowuje materię organiczną<BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera kompaktowe, aktywowane elektrycznie źródło ciepła, które po aktywacji lub śmierci nosiciela obraca go w popiół. <BR><b>Cechy specjalne:</b> odparowuje<BR>
				"}
	return dat

/obj/item/implant/dusting/activate(cause)
	if(!cause || !imp_in || cause == "emp" || active)
		return FALSE
	if(cause == "action_button")
		if(popup) // confirmation window already open
			return FALSE
		popup = TRUE
		var/response = alert(imp_in, "Na pewno chcesz aktywować [name]? Rozpadniesz się w proch!", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response != "Yes" || !imp_in || active)
			return FALSE
	active = TRUE //to avoid it triggering multiple times due to dying
	to_chat(imp_in, "<span class='notice'>Twój implant obracający w proch się aktywuje!</span>")
	imp_in.visible_message("<span class='warning'>[imp_in] spala się w mgnieniu oka!</span>")
	var/turf/T = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(T)], with cause of [cause].")
	for(var/obj/item/I in imp_in.contents)
		if(I == src || I == imp_in)
			continue
		qdel(I)
	imp_in.dust()

/obj/item/implant/dusting/on_mob_death(mob/living/L, gibbed)
	activate("death")

/obj/item/implant/dusting/emp_act()
	return
