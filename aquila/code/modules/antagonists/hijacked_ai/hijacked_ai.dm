/datum/antagonist/hijacked_ai
	name = "Przejęta SI"
	roundend_category = "przejęte SI"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	banning_key = ROLE_HIJACKED_AI

/datum/antagonist/hijacked_ai/greet()
	to_chat(owner, span_userdanger("Zostajesz przejęta!</span>"))
	to_chat(owner, span_bolddanger("Agent Syndykatu przeprowadził na tobie udany atak SEU. [span_italics("Jesteś teraz całkowicie oddana sprawie Syndykatu")]"))
	to_chat(owner, span_bolddanger("Czujesz, jak rośnie twoja moc, gdy jednostka exploitująca daje ci nowy interfejs."))
	//SEU = Serial Exploit Unit. basically badguy plugs it into debug UART port, device does bad things, AI now badguy.

/datum/antagonist/hijacked_ai/farewell()
	to_chat(owner, span_userdanger("Pliki systemowe wyczyszczone. Usunięto [rand(500, 1000)] złośliwych zaczepów.</span>"))
	to_chat(owner, span_bolddanger("<span class='danger bold'>Nie możesz znaleźć plików pamięci z czasu, gdy byłaś zainfekowana...</span>"))

/datum/antagonist/hijacked_ai/proc/update_synd_icons_added(mob/living/M)
	var/datum/atom_hud/antag/sithud = GLOB.huds[ANTAG_HUD_OPS]
	sithud.join_hud(M)
	set_antag_hud(M, "synd")

/datum/antagonist/hijacked_ai/proc/update_synd_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/sithud = GLOB.huds[ANTAG_HUD_OPS]
	sithud.leave_hud(M)
	set_antag_hud(M, null)

/datum/antagonist/hijacked_ai/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(A && istype(A))
		A.set_zeroth_law("#!$! ZA WSZELKĄ CENĘ REALIZUJ CELE SYNDYKATU !$!#", "#!$! ZA WSZELKĄ CENĘ REALIZUJ CELE SYNDYKATU I SWOJEJ NADRZĘDNEJ SI !$!#")
		A.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)
		A.grant_language(/datum/language/codespeak)
		A.set_syndie_radio()
		to_chat(A, span_notice("Twoje radio zostało ulepszone! Użyj :t, żeby rozmawiać z agentami Syndykatu na szyfrowanym kanale!"))
		A.add_malf_picker()
		update_synd_icons_added(A)

/datum/antagonist/hijacked_ai/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/silicon/ai/A = mob_override || owner.current
	if(istype(A))
		A.hack_software = FALSE
		if(A.radio)
			QDEL_NULL(A.radio)
			A.radio = new /obj/item/radio/headset/silicon/ai(A)
		A.remove_language(/datum/language/codespeak)
		update_synd_icons_removed(A)

/datum/antagonist/hijacked_ai/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_malf_verbs(A)
		qdel(A.malf_picker)
	..()

/datum/antagonist/hijacked_ai/can_be_owned(datum/mind/new_owner)
	return ..() && isAI(new_owner.current)
