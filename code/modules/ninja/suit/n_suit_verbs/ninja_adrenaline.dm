//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()

	if(!ninjacost(0,N_ADRENALINE))
		var/mob/living/carbon/human/H = affecting
		H.SetUnconscious(0)
		H.SetStun(0)
		H.SetKnockdown(0)
		H.SetImmobilized(0)
		H.SetParalyzed(0)
		H.adjustStaminaLoss(-75)
		H.stuttering = 0
		H.lying = 0
		H.update_mobility()
		H.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 5)
		H.say(pick("OSACZONY LIS JEST GROŹNIEJSZY OD SZAKALA!","RAŃ MNIE MOOOCNIEEEJ!","IMPRESSIVE!"), forced = "ninjaboost")
		a_boost--
		to_chat(H, "<span class='notice'>Pozostałe dopalacze adrenaliny: <B>[a_boost]</B>.</span>")
		s_coold = 6
		addtimer(CALLBACK(src, PROC_REF(ninjaboost_after)), 70)

/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost_after()
	var/mob/living/carbon/human/H = affecting
	H.reagents.add_reagent(/datum/reagent/uranium/radium, a_transfer)
	to_chat(H, "<span class='danger'>Zaczynasz odczuwać skutki uboczne zastrzyku.</span>")
