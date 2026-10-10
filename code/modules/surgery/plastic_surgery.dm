/datum/surgery/plastic_surgery
	name = "plastic surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/reshape_face, /datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_HEAD)

//reshape_face
/datum/surgery_step/reshape_face
	name = "reshape face"
	implements = list(TOOL_SCALPEL = 100, /obj/item/kitchen/knife = 50, TOOL_WIRECUTTER = 35)
	time = 64

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] zaczyna zmieniać wygląd [target].", "<span class='notice'>Zaczynasz zmieniać wygląd [target]...</span>")
	display_results(user, target, "<span class='notice'>Zaczynasz zmieniać wygląd [target]...</span>",
		"[user] zaczyna zmieniać wygląd [target].",
		"[user] zaczyna nacinać twarz [target].")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(HAS_TRAIT_FROM(target, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(user, target, "<span class='notice'>Pomyślnie przywracasz wygląd [target].</span>",
			"[user] pomyślnie przywraca wygląd [target]!",
			"[user] kończy operację twarzy [target].")
	else
		var/list/names = list()
		if(!isabductor(user))
			for(var/i in 1 to 10)
				names += target.dna.species.random_name(target.gender, TRUE)
		else
			for(var/_i in 1 to 9)
				names += "Subject [target.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
			names += target.dna.species.random_name(target.gender, TRUE) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = input(user, "Wybierz nowe imię.", "Chirurgia plastyczna") as null|anything in names
		if(!chosen_name)
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name	//something about how the code handles names required that I use this instead of target.real_name
		display_results(user, target, "<span class='notice'>Całkowicie zmieniasz wygląd [oldname], teraz to [newname].</span>",
			"[user] całkowicie zmienia wygląd [oldname], teraz to [newname]!",
			"[user] kończy operację twarzy [target].")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_ID()
	return TRUE

/datum/surgery_step/reshape_face/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>Partaczysz, oszpecając [target]!</span>",
		"[user] partaczy, oszpecając [target]!",
		"[user] kończy operację twarzy [target].")
	ADD_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
	return FALSE
