/obj/item/reagent_containers/hypospray/bloody_eye
	name = "\improper bloody eye spray"
	desc = "This vial of Bloody Eye is equipped with a spray nozzle and a handy measuring ring to make sure the spray cone is just the right size."
	icon = 'nsv13/icons/obj/nsv13_syringe.dmi'
	icon_state = "bloody"
	amount_per_transfer_from_this = 30
	volume = 30
	possible_transfer_amounts = list(30)
	resistance_flags = ACID_PROOF
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	list_reagents = list(/datum/reagent/drug/bloody_eye = 30)

/datum/reagent/drug/bloody_eye
	name = "Bloody Eye"
	description = "Silny narkotyk pochodzący z Syndykatu. Wytwarzany, by dawać użytkownikowi niesamowicie ekscytujący haj, zwykle wprawiając go w stan psychozy wywołanej wściekłością. Zwiększa siłę fizyczną i pozwala ignorować skutki stanu krytycznego."
	reagent_state = LIQUID
	color = "#D92323"
	overdose_threshold = 5
	addiction_threshold = 5
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/bloody_eye/on_mob_metabolize(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/bloody_eye)

//You won't go down unless you get killed with excess damage.

/datum/reagent/drug/bloody_eye/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.remove_status_effect(/datum/status_effect/bloody_eye)

/datum/reagent/drug/bloody_eye/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(prob(5))
		var/high_message = pick("Widzisz czerwień.", "Masz ochotę komuś wyrwać gardło.", "Masz wrażenie, że nic nie mogłoby cię zabić.")
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustStun(-40, FALSE)
	M.AdjustKnockdown(-40, FALSE)
	M.AdjustUnconscious(-40, FALSE)
	M.AdjustParalyzed(-40, FALSE)
	M.AdjustImmobilized(-40, FALSE)
	M.adjustStaminaLoss(-30, 0)
	M.Jitter(2)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25)
	if(prob(5))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "laugh"))
	return TRUE

/datum/reagent/drug/bloody_eye/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>WSZYSTKO JEST CZERWONE!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/bloody_eye/overdose_process(mob/living/M)
	. = ..()
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i in 1 to 2)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "laugh"))
	if(prob(33))
		M.visible_message("<span class='danger'>Oczy [M] są krwistoczerwone!</span>")
		M.drop_all_held_items()
	M.adjustToxLoss(0.25, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.1, 0.15, 0.2, 0.25))
	return TRUE

/datum/reagent/drug/bloody_eye/addiction_act_stage1(mob/living/M)
	. = ..()
	M.Jitter(20)
	if(prob(20))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "laugh"))

/datum/reagent/drug/bloody_eye/addiction_act_stage2(mob/living/M)
	. = ..()
	M.Jitter(50)
	M.Dizzy(5)
	if(prob(30))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "laugh"))

/datum/reagent/drug/bloody_eye/addiction_act_stage3(mob/living/M)
	. = ..()
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 4, i++)
			moveRange(M, pick(GLOB.cardinals))
	M.Jitter(100)
	M.Dizzy(10)
	if(prob(40))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "gasp"))

/datum/reagent/drug/bloody_eye/addiction_act_stage4(mob/living/carbon/human/M)
	. = ..()
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 6, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(150)
	M.Dizzy(15)
	M.adjustToxLoss(0.25, 0)
	if(prob(50))
		INVOKE_ASYNC(M, TYPE_PROC_REF(/mob, emote), pick("scream", "laugh"))
	return TRUE

/obj/item/reagent_containers/hypospray/bloody_eye/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return
	if(!iscarbon(M))
		return

	var/list/injected = list()
	for(var/datum/reagent/R as() in reagents.reagent_list)
		injected += R.name
	var/contained = english_list(injected)
	log_combat(user, M, "attempted to spray", src, "([contained])")

	if(reagents.total_volume && !M.is_eyes_covered())
		to_chat(M, "<span class='warning'>Twoje oko pokrywa drobna czerwona mgiełka!</span>")
		to_chat(user, "<span class='notice'>Pryskasz [src] w oko [M].</span>")
		playsound(loc, 'sound/items/hypospray.ogg', 50, 1)

		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)

			to_chat(user, "<span class='notice'>Rozpylono [trans] j. W [src] pozostało [reagents.total_volume] j.</span>")


			log_combat(user, M, "sprayed", src, "([contained])")
	else
		to_chat(M, "<span class='warning'>Najpierw musisz odsłonić oczy!</span>")

/datum/uplink_item/dangerous/bloody_eye
	 name = "Bloody Eye Spray"
	 desc = "Spray into your eye or someone else's to go into a bloody thirsty rage. Don't expect to live after using it."
	 item = /obj/item/reagent_containers/hypospray/bloody_eye
	 cost = 10

/datum/status_effect/bloody_eye
	id = "bloody_eye"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 1
	examine_text = "<span class='warning'>Jego oczy są krwistoczerwone!</span>"
	alert_type = null

/datum/status_effect/bloody_eye/tick()
	owner.a_intent_change(INTENT_HARM)
	owner.overlay_fullscreen("brute" , /atom/movable/screen/fullscreen/brute, 5)
	if(owner.changeNext_move(!CLICK_CD_RAPID))
		owner.changeNext_move(CLICK_CD_RAPID)
	playsound(owner, 'sound/effects/heart_beat.ogg', 25, 1)
	owner.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))

/datum/status_effect/bloody_eye/on_apply()
	to_chat(owner, "<span class='warning'>KILLKILLKILL</span>")
	ADD_TRAIT(owner,TRAIT_DISCOORDINATED,type) // AQ EDIT (TRAIT_MONKEYLIKE -> TRAIT DISCOORDINATED)
	ADD_TRAIT(owner,TRAIT_NOCRITDAMAGE,type)
	ADD_TRAIT(owner,TRAIT_NOSOFTCRIT,type)
	ADD_TRAIT(owner,TRAIT_NOHARDCRIT,type)
	ADD_TRAIT(owner,TRAIT_NOBLOCK,type)
	ADD_TRAIT(owner,TRAIT_STUNIMMUNE,type)
	ADD_TRAIT(owner,TRAIT_SLEEPIMMUNE,type)
	ADD_TRAIT(owner,TRAIT_IGNOREDAMAGESLOWDOWN,type)
	ADD_TRAIT(owner,TRAIT_NOSTAMCRIT,type)
	ADD_TRAIT(owner,TRAIT_NOLIMBDISABLE,type)
	return TRUE


/datum/status_effect/bloody_eye/on_remove()
	to_chat(owner, "<span class='warning'>Do zobaczenia, kosmiczny kowboju...</span>")
	owner.clear_fullscreen("brute")
	owner.adjustOxyLoss(25,0)
	owner.remove_movespeed_modifier(type)
	REMOVE_TRAIT(owner,TRAIT_DISCOORDINATED,type) // AQ EDIT (TRAIT_MONKEYLIKE -> TRAIT DISCOORDINATED)
	REMOVE_TRAIT(owner,TRAIT_NOCRITDAMAGE,type)
	REMOVE_TRAIT(owner,TRAIT_NOSOFTCRIT,type)
	REMOVE_TRAIT(owner,TRAIT_NOHARDCRIT,type)
	REMOVE_TRAIT(owner,TRAIT_NOBLOCK,type)
	REMOVE_TRAIT(owner,TRAIT_STUNIMMUNE,type)
	REMOVE_TRAIT(owner,TRAIT_SLEEPIMMUNE,type)
	REMOVE_TRAIT(owner,TRAIT_IGNOREDAMAGESLOWDOWN,type)
	REMOVE_TRAIT(owner,TRAIT_NOSTAMCRIT,type)
	REMOVE_TRAIT(owner,TRAIT_NOLIMBDISABLE,type)

