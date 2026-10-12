/obj/effect/proc_holder/spell/target_hive/hive_shatter
	name = "Crush Protections"
	desc = "We destroy any Mindshield implants a vesssel might have, granting us further control over their mind."
	action_icon_state = "shatter"

	charge_max = 1800

/obj/effect/proc_holder/spell/target_hive/hive_shatter/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	if(target.mind?.assigned_role in GLOB.security_positions || CAPTAIN)
		to_chat(user, "<span class='warning'>Podświadomie wyćwiczona reakcja ledwo chroni umysł [target.name].</span>")
		to_chat(target, "<span class='assimilator'>Uderzają w nas potężne ataki umysłowe, a nasze szkolenie ledwo pozwala je odeprzeć.</span>")
		return
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		if(!do_after(user,200,0))
			for(var/obj/item/implant/mindshield/M in target.implants)
				to_chat(user, "<span class='notice'>Roztrzaskujemy ochronę tego umysłu!</span>")
				to_chat(target, "<span class='assimilator'>Czujesz ukłucie bólu przeszywające głowę!</span>")
				flash_color(target, flash_color="#800080", flash_time=10)
				qdel(M)

		else
			to_chat(user, "<span class='notice'>Nasza koncentracja została przerwana!</span>")
	else
		to_chat(user, "<span class='warning'>Umysł [target] nie ma żadnej ochrony.</span>")
	if(!success)
		revert_cast()
