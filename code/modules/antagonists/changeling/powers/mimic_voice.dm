/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	button_icon_state = "mimic_voice"
	helptext = "Zmienia twój głos na głos osoby o podanym imieniu."
	chemical_cost = 0
	dna_cost = 1
	req_human = 1

// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(user, "<span class='notice'>Przywracamy gruczoły głosowe do pierwotnego położenia.</span>")
		return

	var/mimic_voice = sanitize_name(stripped_input(user, "Wpisz imię, którego głos chcesz naśladować.", "Naśladowanie głosu", null, MAX_NAME_LEN))
	if(!mimic_voice)
		return
	..()
	changeling.mimicing = mimic_voice
	to_chat(user, "<span class='notice'>Kształtujemy gruczoły, by przybrać głos <b>[mimic_voice]</b>. Dopóki to trwa, chemikalia regenerują się wolniej.</span>")
	to_chat(user, "<span class='notice'>Użyj tej mocy ponownie, by wrócić do pierwotnego głosu i normalnej produkcji chemikaliów.</span>")
	return TRUE
