/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proportions, we defeat common algorithms used to detect lifeforms on cameras."
	helptext = "Gdy używamy tej zdolności, kamery nie mogą nas śledzić, a SI nas nie widzi. Ludzie patrzący na nas uznają jednak, że jesteśmy... niepokojący."
	button_icon_state = "digital_camo"
	dna_cost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	..()
	if(active)
		to_chat(user, "<span class='notice'>Wracamy do normalnej postaci.</span>")
		user.RemoveElement(/datum/element/digital_camo)
	else
		to_chat(user, "<span class='notice'> Zniekształcamy swoją postać, by ukryć się przed SI.</span>")
		user.AddElement(/datum/element/digital_camo)
	active = !active
	return TRUE

/datum/action/changeling/digitalcamo/Remove(mob/user)
	user.RemoveElement(/datum/element/digital_camo)
	..()
