/obj/effect/proc_holder/spell/target_hive/hive_compell
	name = "Compell"
	desc = "We forcefully insert a directive into a vessels mind for a limited time, they'll obey anything short of suicide."
	action_icon_state = "empower"

	charge_max = 10 MINUTES

/obj/effect/proc_holder/spell/target_hive/hive_compell/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	var/directive = stripped_input(user, "Jaki cel chcesz dać temu naczyniu?", "Cel")

	if(target.mind && target.client && target.stat != DEAD)
		if((!HAS_TRAIT(target, TRAIT_MINDSHIELD)) && !istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			if(!IS_HIVEHOST(target) && !IS_WOKEVESSEL(target))
				target.hive_weak_awaken(directive)
				to_chat(user, "<span class='warning'>Przełamujemy tę słabą psychikę!</span>")
				success = TRUE
			else
				to_chat(user, "<span class='warning'>Złożone bariery umysłowe chronią umysł [target.name].</span>")
		else
			to_chat(user, "<span class='warning'>Potężna technologia chroni umysł [target.name].</span>")
	else
		to_chat(user, "<span class='notice'>Nie wykrywamy w tym ciele aktywności neuronowej.</span>")
	if(!success)
		revert_cast()
