/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_off"
	w_class = WEIGHT_CLASS_NORMAL
	var/braintype = JOB_NAME_CYBORG
	var/obj/item/radio/radio = null //Let's give it a radio.
	var/mob/living/brain/brainmob = null //The current occupant.
	var/mob/living/silicon/robot = null //Appears unused.
	var/obj/mecha = null //This does not appear to be used outside of reference in mecha.dm.
	var/obj/item/organ/brain/brain = null //The actual brain
	var/datum/ai_laws/laws = new()
	var/force_replace_ai_name = FALSE
	var/overrides_aicore_laws = FALSE // Whether the laws on the MMI, if any, override possible pre-existing laws loaded on the AI core.

/obj/item/mmi/update_icon()
	if(!brain)
		icon_state = "mmi_off"
		return
	if(istype(brain, /obj/item/organ/brain/alien))
		icon_state = "mmi_brain_alien"
		braintype = "Xenoborg" //HISS....Beep.
	else
		icon_state = "mmi_brain"
		braintype = "Cyborg"
	if(brainmob && brainmob.stat != DEAD)
		add_overlay("mmi_alive")
	else
		add_overlay("mmi_dead")

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src) //Spawns a radio inside the MMI.
	radio.broadcasting = FALSE //researching radio mmis turned the robofabs into radios because this didnt start as 0.
	laws.set_laws_config()

/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/organ/brain)) //Time to stick a brain in it --NEO
		var/obj/item/organ/brain/newbrain = O
		if(brain)
			to_chat(user, "<span class='warning'>W MMI już jest mózg!</span>")
			return
		if(!newbrain.brainmob)
			to_chat(user, "<span class='warning'>Nie wiesz, skąd ten mózg pochodzi, ale jesteś pewien, że jest bezużyteczny!</span>")
			return

		if(!user.transferItemToLoc(O, src))
			return
		var/mob/living/brain/B = newbrain.brainmob
		if(!B.key)
			B.notify_ghost_cloning("Ktoś umieścił twój mózg w MMI!", source = src)
		user.visible_message("[user] wkłada [newbrain] do [src].", "<span class='notice'>Gdy wkładasz [newbrain], zapala się kontrolka [src].</span>")
		log_attack("[key_name(user)] inserted [newbrain] into \the [src] at [AREACOORD(src)].")

		SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, newbrain.brainmob)
		brainmob = newbrain.brainmob
		newbrain.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		var/fubar_brain = newbrain.brain_death && newbrain.suicided && brainmob.suiciding //brain is damaged beyond repair or from a suicider
		if(!fubar_brain && !(newbrain.organ_flags & ORGAN_FAILING)) // the brain organ hasn't been beaten to death, nor was from a suicider.
			brainmob.set_stat(CONSCIOUS) //we manually revive the brain mob
			brainmob.remove_from_dead_mob_list()
			brainmob.add_to_alive_mob_list()
		else if(!fubar_brain && newbrain.organ_flags & ORGAN_FAILING) // the brain is damaged, but not from a suicider
			to_chat(user, "<span class='warning'>Kontrolka [src] zmienia kolor na żółty, a alarm integralności mózgu cicho pika. Może warto sprawdzić, czy [newbrain] nie jest uszkodzony.</span>")
			playsound(src, "sound/machines/synth_no.ogg", 5, TRUE)
		else
			to_chat(user, "<span class='warning'>Kontrolka [src] zmienia kolor na czerwony, a alarm aktywności fal mózgowych cicho pika. Może warto ponownie sprawdzić [newbrain].</span>")
			playsound(src, "sound/weapons/smg_empty_alarm.ogg", 5, TRUE)

		brainmob.reset_perspective()
		brain = newbrain
		brain.organ_flags |= ORGAN_FROZEN

		name = "[initial(name)]: [brainmob.real_name]"
		update_icon()

		SSblackbox.record_feedback("amount", "mmis_filled", 1)

	else if(brainmob)
		O.attack(brainmob, user) //Oh noooeeeee
	else
		return ..()


/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.on = !radio.on
		to_chat(user, "<span class='notice'>[radio.on==1 ? "Włączasz" : "Wyłączasz"] system radiowy [src].</span>")
	else
		log_attack("[key_name(user)] ejected \the [brainmob] from \the [src] at [AREACOORD(src)].")
		eject_brain(user)
		update_icon()
		name = initial(name)
		to_chat(user, "<span class='notice'>Odblokowujesz i przewracasz [src], wylewając mózg na podłogę.</span>")

/obj/item/mmi/proc/eject_brain(mob/user)
	brainmob.container = null //Reset brainmob mmi var.
	brainmob.forceMove(brain) //Throw mob into brain.
	brainmob.set_stat(DEAD)
	brainmob.emp_damage = 0
	brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
	brainmob.remove_from_alive_mob_list() //Get outta here
	brainmob.add_to_dead_mob_list()
	brain.brainmob = brainmob //Set the brain to use the brainmob
	brainmob = null //Set mmi brainmob var to null
	if(user)
		user.put_in_hands(brain) //puts brain in the user's hand or otherwise drops it on the user's turf
	else
		brain.forceMove(get_turf(src))
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here


/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/brain/newbrain = H.getorgan(/obj/item/organ/brain)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"
	update_icon()
	return

/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, "<span class='warning'>Nie możesz tego zrobić, będąc obezwładnionym lub martwym!</span>")
	if(!radio.on)
		to_chat(brainmob, "<span class='warning'>Twoje radio jest wyłączone!</span>")
		return

	radio.listening = !radio.listening
	to_chat(brainmob, "<span class='notice'>Radio [radio.listening ? "odbiera teraz" : "nie odbiera już"] transmisji.</span>")

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/Destroy()
	if(iscyborg(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	if(brain)
		qdel(brain)
		brain = null
	if(mecha)
		mecha = null
	if(radio)
		qdel(radio)
		radio = null
	return ..()

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Jest tu przełącznik do [radio.on ? "wyłączenia" : "włączenia"] systemu radiowego.[brain ? " Obecnie zasłania go [brain]." : null]</span>"
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += "<span class='warning'>MMI wskazuje, że mózg w ogóle nie reaguje.</span>"

		else if(!B.client)
			. += "<span class='warning'>MMI wskazuje, że mózg jest obecnie nieaktywny; to może się zmienić.</span>"

		else
			. += "<span class='notice'>MMI wskazuje, że mózg jest aktywny.</span>"

/obj/item/mmi/relaymove(mob/user)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs and AIs created with it."
	overrides_aicore_laws = TRUE

/obj/item/mmi/syndie/Initialize(mapload)
	. = ..()
	laws = new /datum/ai_laws/syndicate_override()
	radio.on = FALSE
