/obj/item/implant/weapons_auth
	name = "firearms authentication implant"
	desc = "Lets you shoot your guns."
	icon_state = "auth"
	activated = 0

/obj/item/implant/weapons_auth/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant uwierzytelniania broni palnej<BR><b>Żywotność:</b> 4 godziny po śmierci nosiciela<BR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> umożliwia obsługę broni blokowanej implantem, zapobiegając wpadnięciu sprzętu w ręce wroga."}
	return dat


/obj/item/implant/adrenalin
	name = "adrenal implant"
	desc = "Removes all stuns."
	icon_state = "adrenal"
	uses = 3

/obj/item/implant/adrenalin/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant adrenaliny Cybersun Industries<BR><b>Żywotność:</b> pięć dni.<BR><b>Ważne uwagi:</b> <font color='red'>Nielegalny</font><BR><HR><b>Szczegóły implantu:</b> nosiciel może aktywować wstrzyknięcie koktajlu medycznego.<BR><b>Działanie:</b> usuwa ogłuszenia, zwiększa szybkość i lekko leczy.<BR><b>Trwałość:</b> implantu można użyć tylko trzy razy, zanim wyczerpią się zapasy."}
	return dat

/obj/item/implant/adrenalin/activate()
	. = ..()
	uses--
	to_chat(imp_in, "<span class='notice'>Czujesz nagły przypływ energii!</span>")
	imp_in.SetStun(0)
	imp_in.SetKnockdown(0)
	imp_in.SetUnconscious(0)
	imp_in.SetParalyzed(0)
	imp_in.SetImmobilized(0)
	imp_in.adjustStaminaLoss(-200)
	imp_in.set_resting(FALSE)
	imp_in.update_mobility()

	imp_in.reagents.add_reagent(/datum/reagent/medicine/synaptizine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/omnizine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 10)
	if(!uses)
		qdel(src)

/obj/item/implanter/adrenalin
	name = "implanter (adrenalin)"
	imp_type = /obj/item/implant/adrenalin


/obj/item/implant/emp
	name = "emp implant"
	desc = "Triggers an EMP."
	icon_state = "emp"
	uses = 3

/obj/item/implant/emp/activate()
	. = ..()
	uses--
	empulse(imp_in, 3, 5)
	if(!uses)
		qdel(src)

/obj/item/implanter/emp
	name = "implanter (EMP)"
	imp_type = /obj/item/implant/emp


//Health Tracker Implant

/obj/item/implant/health
	name = "health implant"
	activated = 0
	var/healthstring = ""
	var/list/raw_data = list()

/obj/item/implant/health/proc/sensehealth(get_list = FALSE)
	if (!imp_in)
		return "ERROR"
	else
		if(isliving(imp_in))
			var/mob/living/L = imp_in
			healthstring = "<small>Obrażenia od niedotlenienia => [round(L.getOxyLoss())]<br />Oparzenia => [round(L.getFireLoss())]<br />Obrażenia od toksyn => [round(L.getToxLoss())]<br />Urazy => [round(L.getBruteLoss())]</small>"
			raw_data = list() //Reset list
			raw_data["oxy"] = list("[round(L.getOxyLoss())]")		//Suffocation
			raw_data["burn"] = list("[round(L.getFireLoss())]")		//Burn
			raw_data["tox"] = list("[round(L.getToxLoss())]")		//Tox
			raw_data["brute"] = list("[round(L.getBruteLoss())]")	//Brute
		if(!healthstring)											//I have no idea who made it go this order but okay.
			healthstring = "ERROR"
		if(!length(raw_data))
			raw_data = list("ERROR")
		if(!get_list)
			return healthstring
		else
			return raw_data

/obj/item/implant/radio
	name = "internal radio implant"
	activated = TRUE
	var/obj/item/radio/radio
	var/radio_key
	var/subspace_transmission = FALSE
	var/radio_silent = TRUE
	icon = 'icons/obj/radio.dmi'
	icon_state = "walkietalkie"

/obj/item/implant/radio/activate()
	. = ..()
	// needs to be GLOB.deep_inventory_state otherwise it won't open
	radio.ui_interact(usr, state = GLOB.deep_inventory_state)

/obj/item/implant/radio/Initialize(mapload)
	. = ..()

	radio = new(src)
	// almost like an internal headset, but without the
	// "must be in ears to hear" restriction.
	radio.name = "internal radio"
	radio.subspace_transmission = subspace_transmission
	radio.canhear_range = -1
	radio.radio_silent = radio_silent
	if(radio_key)
		radio.keyslot = new radio_key
	radio.recalculateChannels()

/obj/item/implant/radio/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/item/implant/radio/mining
	radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/implant/radio/syndicate
	desc = "Are you there God? It's me, Syndicate Comms Agent."
	radio_key = /obj/item/encryptionkey/syndicate
	subspace_transmission = TRUE

/obj/item/implant/radio/slime
	name = "slime radio"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "adamantine_resonator"
	radio_key = /obj/item/encryptionkey/headset_sci
	subspace_transmission = TRUE

/obj/item/implant/radio/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant radia wewnętrznego<BR><b>Żywotność:</b> 24 godziny<BR><b>Szczegóły implantu:</b> pozwala korzystać z wewnętrznego radia, przydatne, jeśli nosiciel spodziewa się utraty sprzętu albo nie może nosić zwykłego radia."}
	return dat

/obj/item/implant/radio/syndicate/selfdestruct
	name = "hacked internal radio implant"

/obj/item/implant/radio/syndicate/selfdestruct/on_implanted(mob/living/user)
	if(!user.mind.has_antag_datum(/datum/antagonist/incursion))
		user.visible_message("<span class='warning'>[imp_in] zaczyna złowieszczo pikać!</span>", "<span class='userdanger'>Nagle ogarnia cię przerażenie. Implant jest uzbrojony do wybuchu!</span>")
		playsound(user, 'sound/items/timer.ogg', 30, 0)
		explosion(src,0,0,2,2, flame_range = 2)
		user.gib(1)
		qdel(src)

/obj/item/implanter/radio
	name = "implanter (internal radio)"
	imp_type = /obj/item/implant/radio

/obj/item/implanter/radio/syndicate
	name = "implanter (internal syndicate radio)"
	imp_type = /obj/item/implant/radio/syndicate

/obj/item/implanter/radio/syndicate/selfdestruct
	name = "implanter (modified internal syndicate radio)"
	imp_type = /obj/item/implant/radio/syndicate/selfdestruct
