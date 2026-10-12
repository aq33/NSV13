/datum/action/changeling/lesserform
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser. We become a monkey. Costs 20 chemicals."
	helptext = "Przemiana mocno zmniejsza nasz rozmiar, dzięki czemu możemy wyślizgnąć się z kajdanek i wchodzić do wywietrzników."
	button_icon_state = "lesser_form"
	chemical_cost = 20
	dna_cost = 1
	req_human = 1

//Transform into a monkey.
/datum/action/changeling/lesserform/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform)
		return FALSE
	to_chat(user, "<span class='warning'>Nasze geny wołają!</span>")
	..()
	user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)
	return TRUE
