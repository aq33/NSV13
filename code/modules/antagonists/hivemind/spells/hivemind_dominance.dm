/obj/effect/proc_holder/spell/self/hive_dominance
	name = "One Mind"
	desc = "Our true power... finally within reach."
	panel = "Hivemind Abilities"
	charge_type = "charges"
	charge_max = 1
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "assim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_dominance/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	hive.glow = mutable_appearance('icons/effects/hivemind.dmi', "awoken", -BODY_BEHIND_LAYER)
	for(var/datum/antagonist/hivevessel/vessel in hive.avessels)
		var/mob/living/carbon/C = vessel.owner?.current
		C.Jitter(15)
		C.Unconscious(150)
		to_chat(C, "<span class='boldwarning'>Coś jest nie tak...</span>")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='boldwarning'>...twoje wspomnienia stają się mgliste.</span>"), 45)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='boldwarning'>Próbujesz sobie przypomnieć, kim jesteś...</span>"), 90)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='assimilator'>Nie ma ciebie...</span>"), 110)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='bigassimilator'>...jesteśmy tylko my.</span>"), 130)
		addtimer(CALLBACK(C, TYPE_PROC_REF(/atom, add_overlay), hive.glow), 150)

	for(var/datum/antagonist/hivemind/enemy in GLOB.hivehosts)
		if(enemy.owner)
			enemy.owner.RemoveSpell(new/obj/effect/proc_holder/spell/self/hive_dominance)
			var/mob/living/carbon/C = enemy.owner?.current
			if(!(enemy.hiveID == hive.hiveID))
				to_chat(C, "<span class='boldwarning'>Coś jest nie tak...</span>")
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='boldwarning'>...nowa obecność.</span>"), 45)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='boldwarning'>Jest przytłaczająca...</span>"), 90)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='assimilator'>To niemożliwe!</span>"), 110)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), C, "<span class='bigassimilator'>Uciekaj, biegnij!</span>"), 130)
	sound_to_playing_players('sound/effects/one_mind.ogg')
	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, add_overlay), hive.glow), 150)
	addtimer(CALLBACK(hive, TYPE_PROC_REF(/datum/antagonist/hivemind, dominance)), 150)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(send_to_playing_players), "<span class='bigassimilator'>JEDEN UMYSŁ POWSTAJE</span>"), 150)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sound_to_playing_players), 'sound/effects/magic.ogg'), 150)
