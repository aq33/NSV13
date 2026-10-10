/datum/objective/abductee
	completed = 1

/datum/objective/abductee/random

/datum/objective/abductee/random/New()
	explanation_text = pick(world.file2list("strings/abductee_objectives.txt"))

/datum/objective/abductee/steal
	explanation_text = "Ukradnij wszystkie"

/datum/objective/abductee/steal/New()
	var/target = pick(list("zwierzęta","lampy","małpy","owoce","buty","kostki mydła", "bronie", "komputery", "organy"))
	explanation_text+=" [target]."

/datum/objective/abductee/paint
	explanation_text = "Statek jest okropny. Musisz go całego pomalować"

/datum/objective/abductee/paint/New()
	var/color = pick(list("na czerwono", "na niebiesko", "na zielono", "na żółto", "na pomarańczowo", "na fioletowo", "na czarno", "w tęczę", "krwią"))
	explanation_text+= " [color]!"

/datum/objective/abductee/speech
	explanation_text = "Twój mózg jest zepsuty... możesz porozumiewać się tylko"

/datum/objective/abductee/speech/New()
	var/style = pick(list("pantomimą", "rymem", "haiku", "rozbudowanymi metaforami", "zagadkami", "skrajnie dosłownymi określeniami", "efektami dźwiękowymi", "wojskowym żargonem", "zdaniami z trzech słów"))
	explanation_text+= " [style]."

/datum/objective/abductee/capture
	explanation_text = "Schwytaj"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjob.occupations.Copy()
	for(var/X in jobs)
		var/datum/job/J = X
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " osobę na stanowisku: [target.title]."
	else
		explanation_text += " kogokolwiek."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(GLOB.dead_mob_list)
	if(D)
		explanation_text = "Wiesz, że [D] nie żyje. Zorganizuj seans spirytystyczny, by wezwać tę osobę z krainy duchów."

/datum/objective/abductee/forbiddennumber

/datum/objective/abductee/forbiddennumber/New()
	var/number = rand(2,10)
	explanation_text = "Ignoruj wszystko, co występuje w grupach po [number] - to nie istnieje."
