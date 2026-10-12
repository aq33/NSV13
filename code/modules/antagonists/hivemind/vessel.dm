

/datum/antagonist/hivevessel
	name = "Przebudzone naczynie"
	banning_key = ROLE_HIVE_VESSEL
	roundend_category = "przebudzone naczynia"
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	var/hiveID = "Hivemind"
	var/datum/antagonist/hivemind/master
	var/special_role = ROLE_HIVE_VESSEL
	var/mutable_appearance/glow
	var/obj/effect/proc_holder/spell/targeted/touch/hive_fist/fist = new
	show_in_roundend = FALSE


/mob/living/proc/hive_weak_awaken(directive)
	var/mob/living/user = src
	if(!mind)
		return
	if(!HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='assimilator'>Obce energie wdzierają się w twoje myśli!</span>")
		flash_color(user, flash_color="#800080", flash_time=10)
		brainwash(user, directive)
		to_chat(user, "<span class='assimilator'>Cząstka twojej podświadomości trzyma się mocno - nawet na rozkaz nie byłbyś w stanie się zabić!</span>")
		user.overlay_fullscreen("hive_mc", /atom/movable/screen/fullscreen/hive_mc)
		addtimer(CALLBACK(user, PROC_REF(hive_weak_clear), user.mind), 1800, TIMER_STOPPABLE)

/mob/living/proc/hive_weak_clear()
	if(!mind)
		return
	var/mob/living/user = mind.current
	to_chat(user, "<span class='assimilator'>Nasza podświadomość odpiera najeźdźcze siły, nasza wola znów należy do nas!</span>")
	flash_color(user, flash_color="#800080", flash_time=10)
	user.clear_fullscreen("hive_mc")
	mind.remove_antag_datum(/datum/antagonist/brainwashed)

/datum/antagonist/hivevessel/on_gain()
	owner.special_role = ROLE_HIVE_VESSEL
	owner.AddSpell(fist)
	..()

/datum/antagonist/hivevessel/on_removal()
	owner.RemoveSpell(fist)
	if(master)
		to_chat(master.owner, "<span class='assimilator'>Cząstka naszej świadomości się odrywa, straciliśmy przebudzone naczynie!</span>")
	if(owner?.current && glow)
		owner.current.cut_overlay(glow)
	owner.special_role = null
	master.avessels -= owner
	master = null
	..()

/datum/antagonist/hivevessel/apply_innate_effects()
	handle_clown_mutation(owner.current, "Nowe moce pozwalają nam przezwyciężyć klaunią naturę i bezkarnie używać broni.")
	master.update_hivemind_hud(owner.current)

/datum/antagonist/hivevessel/remove_innate_effects()
	handle_clown_mutation(owner.current, removing=FALSE)
	master.update_hivemind_hud_removed(owner.current)

/datum/antagonist/hivevessel/greet()
	to_chat(owner, "<span class='assimilator'>Twój umysł nagle się otwiera, gdy widzisz szczyt ewolucji...</span>")
	to_chat(owner, "<big><span class='warning'><b>Wykonuj rozkazy swojego nosiciela, bez względu na wszystko!</b></span></big>")

/datum/antagonist/hivevessel/farewell()
	to_chat(owner, "<span class='assimilator'>Twój umysł znów się zamyka...</span>")
	to_chat(owner, "<big><span class='warning'><b>Czujesz, jak ciężar celów znika! Nie musisz już ich słuchać.</b></span></big>")

