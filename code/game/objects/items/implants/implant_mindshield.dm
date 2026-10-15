/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."
	activated = 0

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant zarządzania pracownikami Nanotrasen<BR><b>Żywotność:</b> dziesięć lat.<BR><b>Ważne uwagi:</b> osoby z tym urządzeniem są znacznie bardziej odporne na pranie mózgu.<BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera małą kapsułę nanobotów chroniących funkcje umysłowe nosiciela przed manipulacją.<BR><b>Cechy specjalne:</b> zapobiega większości form prania mózgu i je leczy.<BR><b>Trwałość:</b> implant działa, dopóki nanoboty są w krwiobiegu."}
	return dat


/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		if(!target.mind)
			ADD_TRAIT(target, TRAIT_MINDSHIELD, "implant")
			target.sec_hud_set_implants()
			return TRUE

		if(target.mind.has_antag_datum(/datum/antagonist/brainwashed))
			target.mind.remove_antag_datum(/datum/antagonist/brainwashed)

		if(target.mind.has_antag_datum(/datum/antagonist/rev/head) || target.mind.unconvertable)
			if(!silent)
				target.visible_message("<span class='warning'>[target] wydaje się opierać implantowi!</span>", "<span class='warning'>Czujesz, że coś zakłóca twoje warunkowanie umysłowe, ale się opierasz!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE

		var/datum/antagonist/hivemind/hiv= target.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(hiv)
			var/timer = round(rand(1800,3000))
			addtimer(CALLBACK(hiv, TYPE_PROC_REF(/datum/antagonist/hivemind, handle_implant)), timer, TIMER_STOPPABLE)
			hiv.handle_implant()

		if(is_hivemember(target))
			for(var/datum/antagonist/hivemind/hive in GLOB.antagonists)
				if(hive.hivemembers.Find(target.mind))
					var/mob/living/carbon/C = hive.owner.current
					if(C?.mind)
						to_chat(C, "<span class='assimilator'>Wykrywamy skok energii psionicznej z odległego naczynia, zanim zniknęło z roju. Cokolwiek się stało, jest duża szansa, że teraz na nas polują.</span>")
			if(IS_WOKEVESSEL(target))
				target.mind.remove_antag_datum(/datum/antagonist/hivevessel)
				target.visible_message("<span class='deconversion_message'>Myśli [target] wydają się rozjaśniać!</span>", null, null, null, target)
				ADD_TRAIT(target, TRAIT_HIVE_BURNT, HIVEMIND_TRAIT)
			to_chat(target, "<span class='assimilator'>W twoim umyśle rozbrzmiewa nadprzyrodzone zawodzenie, gdy w końcu zostajesz uwolniony. W głębi duszy czujesz pozostałą obecność tych, którzy cię zniewolili... a oni czują twoją!</span>")
			remove_hivemember(target)

		var/datum/antagonist/rev/rev = target.mind.has_antag_datum(/datum/antagonist/rev)
		if(rev)
			rev.remove_revolutionary(FALSE, user)
		if(!silent)
			if(target.mind in SSticker.mode.cult)
				to_chat(target, "<span class='warning'>Czujesz, że coś zakłóca twoje warunkowanie umysłowe, ale się opierasz!</span>")
			else
				to_chat(target, "<span class='notice'>Czujesz spokój i bezpieczeństwo. Jesteś teraz chroniony przed praniem mózgu.</span>")
		ADD_TRAIT(target, TRAIT_MINDSHIELD, "implant")
		target.sec_hud_set_implants()
		return TRUE
	return FALSE

/obj/item/implant/mindshield/removed(mob/target, silent = FALSE, special = 0)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			REMOVE_TRAIT(L, TRAIT_MINDSHIELD, "implant")
			L.sec_hud_set_implants()
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Twój umysł nagle wydaje się strasznie bezbronny. Nie jesteś już chroniony przed praniem mózgu.</span>")
		return 1
	return 0

/obj/item/implanter/mindshield
	name = "implanter (mindshield)"
	imp_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "implant case - 'Mindshield'"
	desc = "A glass case containing a mindshield implant."
	imp_type = /obj/item/implant/mindshield
