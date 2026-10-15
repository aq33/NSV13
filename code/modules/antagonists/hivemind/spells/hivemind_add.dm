/obj/effect/proc_holder/spell/targeted/hive_add
	name = "Assimilate Vessel"
	desc = "We silently add an unsuspecting target to the hive."
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	selection_type = "view"
	action_icon_state = "add"
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 1
	var/ignore_mindshield = FALSE

/obj/effect/proc_holder/spell/targeted/hive_add/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE

	if(HAS_TRAIT(target, TRAIT_HIVE_BURNT))
		to_chat(user, "<span class='notice'>Ten umysł został wyeksploatowany do cna i nie ma już żadnej wartości.</span>")
		revert_cast()
		return
	if(!target.mind || !target.client || target.stat == DEAD)
		to_chat(user, "<span class='notice'>Nie wykrywamy w tym ciele aktywności neuronowej.</span>")
		revert_cast()
		return

	if((HAS_TRAIT(target, TRAIT_MINDSHIELD) && !ignore_mindshield) || istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
		to_chat(user, "<span class='warning'>Potężna technologia chroni umysł [target.name].</span>")
		revert_cast()
		return

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD) && ignore_mindshield)
		to_chat(user, "<span class='notice'>Siłą przebijamy się przez bariery umysłowe [target.name] i zaczynamy łączyć nasze umysły!</span>")
	else
		to_chat(user, "<span class='notice'>Zaczynamy łączyć nasz umysł z [target.name]!</span>")

	if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && (user in viewers(range, target)))
		if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && (user in viewers(range, target)))
			if((!HAS_TRAIT(target, TRAIT_MINDSHIELD) || ignore_mindshield) && (user in viewers(range, target)))
				to_chat(user, "<span class='notice'>[target.name] dołącza do Roju!</span>")
				success = TRUE
				hive.add_to_hive(target)
				if(ignore_mindshield)
					to_chat(user, "<span class='warning'>Wysiłek wzmocnionej asymilacji na chwilę nas wyczerpuje.</span>")
					user.Immobilize(50)
					SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
			else
				to_chat(user, "<span class='notice'>Nie udaje nam się połączyć z [target.name].</span>")
		else
			to_chat(user, "<span class='notice'>Nie udaje nam się połączyć z [target.name].</span>")
	else
		to_chat(user, "<span class='notice'>Nie udaje nam się połączyć z [target.name].</span>")

	if(!success)
		revert_cast()
