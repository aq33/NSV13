/obj/effect/proc_holder/spell/targeted/hive_thrall
	name = "Awaken Vessel"
	desc = "We awaken one of our vessels, permanently turning them into an extension of our will, we can only sustain two awakened vessels increasing with integrations."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "chaos"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_thrall/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if((hivehost.avessels.len >= hivehost.avessel_limit) && !hivehost.dominant)
		to_chat(user, "<span class='notice'>Nie utrzymamy kolejnego przebudzonego naczynia!</span>")
		return
	var/mob/living/carbon/human/target = user.pulling
	if(!target)
		to_chat(user, "<span class='warning'>Musimy trzymać istotę, żeby ją przebudzić!</span>")
		hivehost.isintegrating = FALSE
		revert_cast()
		return
	if(!is_hivemember(target))
		to_chat(user, "<span class='warning'>Tylko naczynie można przebudzić!</span>")
		revert_cast()
		return
	if(hivehost.isintegrating)
		to_chat(user, "<span class='warning'>Już przebudzamy naczynie!</span>")
		revert_cast()
		return
	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>Musimy mocniej chwycić, żeby przebudzić ten umysł!</span>")
		revert_cast()
		return
	if(IS_HIVEHOST(target) || IS_WOKEVESSEL(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>Złożone bariery umysłowe chronią umysł [target.name].</span>")
		revert_cast()
		return
	hivehost.isintegrating = TRUE

	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>Sięgamy do umysłu naczynia. Musimy się nie ruszać...</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] kładzie dłonie na głowie [target]!</span>", "<span class='notice'>Kładziemy dłonie na skroniach</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] zaczyna wyglądać na spanikowanego!</span>", "<span class='notice'>Zaczynamy zastępować świadomość [target] naszą własną.</span>")
				to_chat(target, "<span class='userdanger'>Twoja świadomość zaczyna się chwiać!</span>")

		if(!do_mob(user, target, 20))
			to_chat(user, "<span class='warning'>Przebudzenie [target] zostało przerwane!</span>")
			hivehost.isintegrating = FALSE
			return
	hivehost.isintegrating = FALSE
	var/datum/antagonist/hivevessel/V = new /datum/antagonist/hivevessel()
	hivehost.avessels += target.mind
	V.master = hivehost
	V.hiveID = hivehost.hiveID
	target.mind.add_antag_datum(V)
	var/O = "Słuchaj i chroń swojego nosiciela roju, [user]"
	var/datum/objective/brainwashing/objective = new(O)
	V.objectives += objective
	log_objective(V, objective.explanation_text)
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>To naczynie jest teraz przedłużeniem naszej woli.</span>")
	if(hivehost.dominant)
		target.add_overlay(hivehost.glow)
