/datum/action/changeling/sting//parent path, not meant for users afaik
	name = "Tiny Prick"
	desc = "Stabby stabby"
	var/stealthy = FALSE

/datum/action/changeling/sting/Trigger()
	var/mob/user = owner
	if(!user || !user.mind)
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling)
		return
	if(!changeling.chosen_sting)
		set_sting(user)
	else
		unset_sting(user)
	return

/datum/action/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, "<span class='notice'>Przygotowujemy żądło. Kliknij cel z Altem albo środkowym przyciskiem myszy, żeby go użądlić.</span>")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = src

	user.hud_used.lingstingdisplay.icon = icon_icon
	user.hud_used.lingstingdisplay.icon_state = button_icon_state
	user.hud_used.lingstingdisplay.invisibility = 0

/datum/action/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, "<span class='warning'>Chowamy żądło, na razie nie możemy nikogo użądlić.</span>")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = null

	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/mob/living/carbon/proc/unset_sting()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling?.chosen_sting)
			changeling.chosen_sting.unset_sting(src)

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling.chosen_sting)
		to_chat(user, "Nie przygotowaliśmy jeszcze żądła!")
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!length(get_path_to(user, target, max_distance = changeling.sting_range, simulated_only = FALSE)))
		return
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling))
		sting_feedback(user, target)
		changeling.chem_charges -= chemical_cost
	return 1

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, "<span class='notice'>Ukradkiem żądlimy [target.name].</span>")
	if((target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling)) || !stealthy)
		to_chat(target, "<span class='warning'>Czujesz lekkie ukłucie!</span>")
	return 1


/datum/action/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform. Costs 50 chemicals."
	helptext = "Ofiara przemienia się podobnie jak zmiennokształtny. Nie ostrzega innych. Mutacje nie są przenoszone, a małpy stają się ludźmi."
	button_icon_state = "sting_transform"
	chemical_cost = 50
	dna_cost = 3
	var/datum/changelingprofile/selected_dna = null

/datum/action/changeling/sting/transformation/Trigger()
	var/mob/user = usr
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.chosen_sting)
		unset_sting(user)
		return
	selected_dna = changeling.select_dna("Wybierz docelowe DNA: ", "Docelowe DNA")
	if(!selected_dna)
		return
	if(NOTRANSSTING in selected_dna.dna.species.species_traits)
		to_chat(user, "<span class = 'notice'>To DNA nie jest zgodne z retrowirusem zmiennokształtnych!</span>")
		return
	..()

/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/living/carbon/target)
	if(!..())
		return
	if((HAS_TRAIT(target, TRAIT_HUSK)) || !iscarbon(target) || (NOTRANSSTING in target.dna.species.species_traits))
		to_chat(user, "<span class='warning'>Nasze żądło wydaje się nieskuteczne wobec tego DNA.</span>")
		return 0
	return 1

/datum/action/changeling/sting/transformation/sting_action(mob/user, mob/target)
	log_combat(user, target, "stung", "transformation sting", " new identity is '[selected_dna.dna.real_name]'")
	var/datum/dna/NewDNA = selected_dna.dna
	if(ismonkey(target))
		to_chat(user, "<span class='notice'>Nasze geny wołają, gdy żądlimy [target.name]!</span>")

	var/mob/living/carbon/C = target
	. = TRUE
	if(istype(C))
		C.real_name = NewDNA.real_name
		NewDNA.transfer_identity(C)
		if(ismonkey(C))
			C.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_DEFAULTMSG | TR_KEEPAI)
		C.updateappearance(mutcolor_update=1)


/datum/action/changeling/sting/false_armblade
	name = "False Armblade Sting"
	desc = "We silently sting a human, injecting a retrovirus that mutates their arm to temporarily appear as an armblade. Costs 20 chemicals."
	helptext = "Ofierze wyrasta ostrze z ręki jak u zmiennokształtnego, tyle że tępe i bezużyteczne."
	button_icon_state = "sting_armblade"
	chemical_cost = 20
	dna_cost = 1

/obj/item/melee/arm_blade/false
	desc = "A grotesque mass of flesh that used to be your arm. Although it looks dangerous at first, you can tell it's actually quite dull and useless."
	force = 5 //Basically as strong as a punch
	fake = TRUE

/datum/action/changeling/sting/false_armblade/can_sting(mob/user, mob/target)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		if((HAS_TRAIT(L, TRAIT_HUSK)) || !L.has_dna())
			to_chat(user, "<span class='warning'>Nasze żądło wydaje się nieskuteczne wobec tego DNA.</span>")
			return 0
	return 1

/datum/action/changeling/sting/false_armblade/sting_action(mob/user, mob/target)
	log_combat(user, target, "stung", object="false armblade sting")
	..()

	//Activate after 5 to 10 seconds
	addtimer(CALLBACK(src, PROC_REF(grow_fake), target), rand(5 SECONDS, 10 SECONDS))
	return TRUE

/datum/action/changeling/sting/false_armblade/proc/grow_fake(mob/target)
	var/obj/item/held = target.get_active_held_item()
	if(held && !target.dropItemToGround(held))
		return

	if(ismonkey(target))
		return

	var/obj/item/melee/arm_blade/false/blade = new(target,1)
	target.put_in_hands(blade)
	target.visible_message("<span class='warning'>Wokół ręki [target.name] formuje się groteskowe ostrze!</span>", "<span class='userdanger'>Twoja ręka wykręca się i mutuje, zmieniając się w potworną monstrualność!</span>", "<span class='italics'>Słyszysz rozrywanie i darcie tkanki organicznej!</span>")
	playsound(target, 'sound/effects/blobattack.ogg', 30, 1)

	addtimer(CALLBACK(src, PROC_REF(remove_fake), target, blade), 600)

/datum/action/changeling/sting/false_armblade/proc/remove_fake(mob/target, obj/item/melee/arm_blade/false/blade)
	playsound(target, 'sound/effects/blobattack.ogg', 30, 1)
	target.visible_message("<span class='warning'>Z obrzydliwym chrupnięciem \
	[target] zmienia [blade.name] z powrotem w rękę!</span>",
	"<span class='warning'>[blade] wraca do normalnej postaci.</span>",
	"<span class='italics'>Słyszysz rozrywanie i darcie tkanki organicznej!</span>")

	qdel(blade)
	target.update_inv_hands()

/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. Costs 25 chemicals."
	helptext = "Daje ci DNA celu, dzięki czemu możesz się w niego przemienić."
	button_icon_state = "sting_extract"
	chemical_cost = 25
	dna_cost = 0
	stealthy = TRUE

/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		return changeling.can_absorb_dna(target)

/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	log_combat(user, target, "stung", "extraction sting")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!(changeling.has_dna(target.dna)))
		changeling.add_new_profile(target)
	return TRUE

/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time. Costs 20 chemicals."
	helptext = "Ofiara nie zauważa użądlenia, dopóki nie spróbuje się odezwać i nie zdoła."
	button_icon_state = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	log_combat(user, target, "stung", "mute sting")
	target.silent += 30
	return TRUE

/datum/action/changeling/sting/blind
	name = "Blind Sting"
	desc = "We temporarily blind our victim. Costs 25 chemicals."
	helptext = "To żądło na krótko całkowicie oślepia cel i na długo zostawia mu rozmazany obraz."
	button_icon_state = "sting_blind"
	chemical_cost = 25
	dna_cost = 1

/datum/action/changeling/sting/blind/sting_action(mob/user, mob/living/carbon/target)
	log_combat(user, target, "stung", "blind sting")
	to_chat(target, "<span class='danger'>Oczy straszliwie cię pieką!</span>")
	target.become_nearsighted(EYE_DAMAGE)
	target.blind_eyes(20)
	target.blur_eyes(40)
	return TRUE

/datum/action/changeling/sting/LSD
	name = "Hallucination Sting"
	desc = "We cause mass terror to our victim."
	helptext = "Rozwijamy zdolność żądlenia celu silnym halucynogenem. Cel nie zauważa użądlenia, a efekt pojawia się po 30-60 sekundach."
	button_icon_state = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1
	stealthy = TRUE

/datum/action/changeling/sting/LSD/sting_action(mob/user, mob/living/carbon/target)
	log_combat(user, target, "stung", "LSD sting")
	addtimer(CALLBACK(src, PROC_REF(hallucination_time), target), rand(300,600))
	return TRUE

/datum/action/changeling/sting/LSD/proc/hallucination_time(mob/living/carbon/target)
	if(target)
		target.hallucination = max(90, target.hallucination)

/datum/action/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that freezes them from the inside. Costs 10 chemicals."
	helptext = "Ofiara nie dostaje ostrzeżenia, choć pewnie zorientuje się, że nagle zamarza."
	button_icon_state = "sting_cryo"
	chemical_cost = 10
	dna_cost = 2
	stealthy = TRUE

/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	log_combat(user, target, "stung", "cryo sting")
	if(target.reagents)
		target.reagents.add_reagent(/datum/reagent/consumable/frostoil, 20)
	return TRUE
