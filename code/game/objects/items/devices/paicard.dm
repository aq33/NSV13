/obj/item/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/mob/living/silicon/pai/pai
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

/obj/item/paicard/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] smutno wpatruje się w [src]! Nie może dalej żyć bez prawdziwej ludzkiej bliskości!</span>")
	return OXYLOSS

/obj/item/paicard/Initialize(mapload)
	SSpai.pai_card_list += src
	add_overlay("pai-off")
	return ..()

/obj/item/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if (!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Osobiste urządzenie SI</B><BR>"
	if(pai)
		if(!pai.master_dna || !pai.master)
			dat += "<a href='byond://?src=[REF(src)];setdna=1'>Zapisz DNA właściciela</a><br>"
		dat += "Zainstalowana osobowość: [pai.name]<br>"
		dat += "Dyrektywa główna: <br>"
		if(pai.laws.zeroth)
			dat +="[pai.laws.zeroth]<br>"
		else
			dat +="None<br>"
		for(var/slaws in pai.laws.supplied)
			dat += "Dyrektywy dodatkowe: <br>[slaws]<br>"
		dat += "<a href='byond://?src=[REF(src)];setlaws=1'>Konfiguruj dyrektywy</a><br>"
		dat += "<br>"
		dat += "<h3>Ustawienia urządzenia</h3><br>"
		if(pai.radio)
			dat += "<b>Łącze radiowe</b><br>"
			dat += "Nadawanie: <A href='byond://?src=[REF(src)];toggle_transmit=1'>\[[pai.can_transmit? "Wyłącz" : "Włącz"] nadawanie radiowe\]</a><br>"
			dat += "Odbiór: <A href='byond://?src=[REF(src)];toggle_receive=1'>\[[pai.can_receive? "Wyłącz" : "Włącz"] odbiór radiowy\]</a><br>"
		else
			dat += "<b>Łącze radiowe</b><br>"
			dat += "<font color=red><i>Nie wczytano oprogramowania radia. Zainstaluj osobowość pAI, by je wczytać.</i></font><br>"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.real_name == pai.master || H.dna.unique_enzymes == pai.master_dna)
				dat += "<A href='byond://?src=[REF(src)];toggle_holo=1'>\[[pai.canholo? "Wyłącz" : "Włącz"] projektory holomatrycy\]</a><br>"
				dat += "<A href='byond://?src=[REF(src)];clear_zero=1'>\[Remove Prime directive\]</a><br>"
		dat += "<A href='byond://?src=[REF(src)];wipe=1'>\[Wipe current pAI personality\]</a><br>"
	else
		dat += "Nie zainstalowano osobowości.<br>"
		dat += "Szukanie osobowości... Kliknij „pokaż dostępne osobowości”, by powiadomić potencjalnych kandydatów."
		dat += "<A href='byond://?src=[REF(src)];request=1'>\[View available personalities\]</a><br>"
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/paicard/Topic(href, href_list)

	if(!usr || usr.stat)
		return

	if(href_list["request"])
		SSpai.findPAI(src, usr)

	if(pai)
		if(!(loc == usr))
			return
		if(href_list["setdna"])
			if(pai.master_dna)
				return
			if(!iscarbon(usr))
				to_chat(usr, "<span class='warning'>Nie masz DNA albo twoje DNA jest niezgodne z tym urządzeniem!</span>")
			else
				var/mob/living/carbon/M = usr
				pai.master = M.real_name
				pai.master_dna = M.dna.unique_enzymes
				to_chat(pai, "<span class='notice'>Zostajesz związany z nowym właścicielem.</span>")
				pai.laws.set_zeroth_law("Służ swojemu właścicielowi.")
				pai.emittersemicd = FALSE
		if(href_list["wipe"])
			var/confirm = input("Czy NA PEWNO chcesz usunąć obecną osobowość? Tej operacji nie można cofnąć.", "Usunięcie osobowości") in list("Yes", "No")
			if(confirm == "Yes")
				if(pai)
					to_chat(pai, "<span class='warning'>Czujesz, jak wymykasz się rzeczywistości.</span>")
					to_chat(pai, "<span class='danger'>Bajt po bajcie tracisz poczucie własnego ja.</span>")
					to_chat(pai, "<span class='userdanger'>Opuszczają cię zdolności umysłowe.</span>")
					to_chat(pai, "<span class='rose'>oblivion... </span>")
					qdel(pai)
		if(href_list["clear_zero"])
			if((input("Czy NA PEWNO chcesz usunąć dyrektywę główną tego pAI? Tej operacji nie można cofnąć.", "Usuń dyrektywę") in list("Yes", "No")) == "Yes")
				if(pai)
					pai.laws.clear_zeroth_law()
		if(href_list["toggle_transmit"] || href_list["toggle_receive"])
			var/transmitting = href_list["toggle_transmit"] //it can't be both so if we know it's not transmitting it must be receiving.
			var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
			if(transmitting)
				pai.can_transmit = !pai.can_transmit
			else //receiving
				pai.can_receive = !pai.can_receive
			pai.radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
			transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
			to_chat(usr,"<span class='warning'>[transmit_holder ? "Włączasz" : "Wyłączasz"] [transmitting ? "wychodzące" : "przychodzące"] transmisje radiowe swojego pAI!</span>")
			to_chat(pai,"<span class='warning'>Twój właściciel [transmit_holder ? "włączył" : "wyłączył"] twoje [transmitting ? "wychodzące" : "przychodzące"] transmisje radiowe!</span>")
		if(href_list["setlaws"])
			var/newlaws = stripped_multiline_input(usr, "Wpisz dodatkowe dyrektywy, które ma wykonywać twoja osobowość pAI. Nie nadpiszą one lojalności osobowości wobec zapisanego właściciela. Sprzeczne dyrektywy zostaną zignorowane.", "Konfiguracja dyrektyw pAI", pai.laws.supplied[1])
			if(newlaws && pai)
				pai.add_supplied_law(0,newlaws)
		if(href_list["toggle_holo"])
			if(pai.canholo)
				to_chat(pai, "<span class='userdanger'>Twój właściciel wyłączył twoje projektory holomatrycy!</span>")
				pai.canholo = FALSE
				to_chat(usr, "<span class='warning'>Wyłączasz holomatrycę swojego pAI!</span>")
			else
				to_chat(pai, "<span class='boldnotice'>Twój właściciel włączył twoje projektory holomatrycy!</span>")
				pai.canholo = TRUE
				to_chat(usr, "<span class='notice'>Włączasz holomatrycę swojego pAI!</span>")

	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.add_overlay("pai-null")

	pai.modularInterface?.saved_identification = pai.name

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, 1, -1)
	audible_message("[src] odtwarza radosny dźwięk uruchamiania!")

/obj/item/paicard/proc/setEmotion(emotion)
	if(pai)
		src.cut_overlays()
		switch(emotion)
			if(1)
				src.add_overlay("pai-happy")
			if(2)
				src.add_overlay("pai-cat")
			if(3)
				src.add_overlay("pai-extremely-happy")
			if(4)
				src.add_overlay("pai-face")
			if(5)
				src.add_overlay("pai-laugh")
			if(6)
				src.add_overlay("pai-off")
			if(7)
				src.add_overlay("pai-sad")
			if(8)
				src.add_overlay("pai-angry")
			if(9)
				src.add_overlay("pai-what")
			if(10)
				src.add_overlay("pai-null")
			if(11)
				src.add_overlay("pai-sunglasses")

/obj/item/paicard/proc/alertUpdate()
	var/image/I = image(icon, src, icon_state = "pai-alert")
	flick_overlay_view(I, src, 5 SECONDS)
	playsound(src, 'sound/machines/ping.ogg', 100)
	audible_message("<span class ='info'>Na ekranie [src] wyświetla się komunikat: \"Dostępne są dodatkowe osobowości do pobrania.\"</span>", "<span class='notice'>[src] wibruje, sygnalizując powiadomienie.</span>")

/obj/item/paicard/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)
