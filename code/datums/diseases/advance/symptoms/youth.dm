/*
//////////////////////////////////////
Eternal Youth

	Moderate stealth boost.
	Increases resistance tremendously.
	Increases stage speed tremendously.
	Reduces transmission tremendously.
	Critical Level.

BONUS
	Gives you immortality and eternal youth!!!
	Can be used to buff your virus

//////////////////////////////////////
*/

/datum/symptom/youth

	name = "Eternal Youth"
	desc = "Wirus łączy się symbiotycznie z komórkami ciała nosiciela, zapobiegając starzeniu i je odwracając. W zamian wirus staje się odporniejszy, szybciej się rozprzestrzenia i trudniej go wykryć, choć bez nosiciela rozwija się gorzej."
	stealth = 3
	resistance = 4
	stage_speed = 4
	transmission = -4
	level = 5
	base_message_chance = 100
	symptom_delay_min = 25
	symptom_delay_max = 50
	prefixes = list("Eternal ")
	bodies = list("Immortal", "Elixir")

/datum/symptom/youth/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(A.stage)
			if(1)
				if(H.age > 41)
					H.age = 41
					to_chat(H, "<span class='notice'>Od lat nie miałeś tyle energii!</span>")
			if(2)
				if(H.age > 36)
					H.age = 36
					to_chat(H, "<span class='notice'>Nagle masz dobry humor.</span>")
			if(3)
				if(H.age > 31)
					H.age = 31
					to_chat(H, "<span class='notice'>Czujesz się gibszy.</span>")
			if(4)
				if(H.age > 26)
					H.age = 26
					to_chat(H, "<span class='notice'>Czujesz się odnowiony.</span>")
			if(5)
				if(H.age > 21)
					H.age = 21
					to_chat(H, "<span class='notice'>Czujesz, że mógłbyś stawić czoła całemu światu!</span>")
