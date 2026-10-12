/datum/action/changeling/fleshmend
	name = "Fleshmend"
	desc = "Our flesh rapidly regenerates, rapidly healing brute wounds and shortness of breath as well as slowly healing burns and genetic damage. Costs 25 chemicals."
	helptext = "Nie działa, gdy płoniemy. Nie odtwarza kończyn ani utraconej krwi. Działa w stanie nieprzytomności."
	button_icon_state = "fleshmend"
	chemical_cost = 25
	dna_cost = 2
	req_stat = UNCONSCIOUS

//Starts healing you every second for 10 seconds.
//Can be used whilst unconscious.
/datum/action/changeling/fleshmend/sting_action(mob/living/user)
	if(user.has_status_effect(STATUS_EFFECT_FLESHMEND))
		to_chat(user, "<span class='warning'>Już regenerujemy tkanki!</span>")
		return
	..()
	to_chat(user, "<span class='notice'>Zaczynamy się szybko leczyć.</span>")
	user.apply_status_effect(STATUS_EFFECT_FLESHMEND)
	return TRUE

//Check buffs.dm for the fleshmend status effect code
