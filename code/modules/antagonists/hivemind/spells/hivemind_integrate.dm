/obj/effect/proc_holder/spell/targeted/hive_integrate
	name = "Integrate"
	desc = "Allows us to syphon the psionic energy from a Host within our grasp."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "reclaim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_integrate/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/human/target = user.pulling
	if(!target)
		to_chat(user, "<span class='warning'>Musimy trzymać istotę, żeby ją zintegrować!</span>")
		hivehost.isintegrating = FALSE
		revert_cast()
		return
	if(!IS_HIVEHOST(target))
		to_chat(user, "<span class='warning'>Ten umysł jest dla nas bezwartościowy!</span>")
		revert_cast()
		return
	if(hivehost.isintegrating)
		to_chat(user, "<span class='warning'>Już integrujemy umysł!</span>")
		revert_cast()
		return
	if(user.grab_state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>Musimy mocniej chwycić, żeby zintegrować ten umysł!</span>")
		revert_cast()
		return
	hivehost.isintegrating = TRUE

	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>Ten lśniący umysł jest w zasięgu. Musimy się nie ruszać...</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] kładzie dłonie na głowie [target]!</span>", "<span class='notice'>Kładziemy dłonie na skroniach.</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] zdaje się tracić przytomność</span>", "<span class='notice'>Zaczynamy rozbijać umysł [target].</span>")
				to_chat(target, "<span class='userdanger'>Twoja świadomość zaczyna się chwiać!</span>")

		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Integracja [target] została przerwana!</span>")
			hivehost.isintegrating = FALSE
			return
	to_chat(target, "<span class='userdanger'>Twój umysł zostaje roztrzaskany!</span>")
	hivehost.isintegrating = FALSE
	var/datum/antagonist/hivemind/enemy = target.mind.has_antag_datum(/datum/antagonist/hivemind)
	enemy.destroy_hive() //Just in case
	target.gib()
	hivehost.size_mod += 5
	hivehost.avessel_limit += 1
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>Odzyskaliśmy dary, które marnowały słabsze umysły, i coraz lepiej rozumiemy nasze zdolności psioniczne.</span>")
	to_chat(user,"<span class='assimilator'>Dzięki tej nowej sile możemy przebudzić dodatkowe naczynie...</span>")
	hivehost.check_powers()
