/obj/effect/proc_holder/spell/target_hive/hive_shock
	name = "Neural Shock"
	desc = "After a short charging time, we overload the mind of one of our vessels with psionic energy, rendering them unconscious for a short period of time. This power weakens over distance, but strengthens with hive size."
	action_icon_state = "shock"

	charge_max = 600

/obj/effect/proc_holder/spell/target_hive/hive_shock/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	to_chat(user, "<span class='notice'>Zaczynamy zwiększać przepustowość psioniczną między nami a naczyniem!</span>")
	if(do_after(user,30,0,user))
		if(target.mind.assigned_role in (GLOB.security_positions || GLOB.command_positions)) //Doesn't work on sec or command for balance reasons
			to_chat(user, "<span class='warning'>Podświadomie wyćwiczona reakcja ledwo chroni umysł [target.name].</span>")
			to_chat(target, "<span class='assimilator'>Uderzają w nas potężne ataki umysłowe, a nasze szkolenie ledwo pozwala je odeprzeć.</span>")
			return
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(user, "<span class='warning'>Potężna technologia chroni umysł [target.name].</span>")
			return
		if(!IS_HIVEHOST(target))
			var/power = 120-get_dist(user, target)
			switch(hive.hive_size)
				if(0 to 4)
				if(5 to 9)
					power *= 1.5
				if(10 to 14)
					power *= 2
				if(15 to 19)
					power *= 2.5
				else
					power *= 3
			if(power > 50 && user.get_virtual_z_level() == target.get_virtual_z_level())
				to_chat(user, "<span class='notice'>Na chwilę przeciążyliśmy naczynie!</span>")
				target.Jitter(round(power/10))
				target.Unconscious(power)
		else
			to_chat(user, "<span class='notice'>Naczynie było za daleko, by to zadziałało!</span>")
	else
		to_chat(user, "<span class='notice'>Nasza koncentracja została przerwana!</span>")
		revert_cast()
