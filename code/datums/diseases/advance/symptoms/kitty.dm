/datum/symptom/toxoplasmosis //my take on the adminbus disease added a year ago. I wanted to make it an actual symptom instead of a simple idea, and i dont want it to call set_species()
	name = "Toxoplasmosis Sapiens" 
	desc = "Pasożytniczy objaw, przez który humanoidalny nosiciel czuje się nieco szczęśliwszy przy kotach i kotoludziach."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = 1
	level = -1
	severity = -1
	symptom_delay_min = 40
	symptom_delay_max = 60
	prefixes = list("Feline ", "Anime ")
	suffixes = list(" Madness", " Mania") //However, I want this virus to be a bit grimmer than the funny uwu cat disease
	var/mania = FALSE 
	var/uwu = FALSE
	var/dnacounter = 0
	threshold_desc = "<b>Transmisja 4:</b> objaw mutuje ośrodek mowy w mózgu nosiciela, przez co mówi on irytującym dialektem. Znany z doprowadzania nosicieli do samobójstwa.<br><b>Ukrycie 4:</b> nosicieli ogarnia dysmorficzna mania, przez którą gloryfikują ideę stania się bardziej kocimi. Może powodować irracjonalne zachowanie, a w skrajnych przypadkach poważną przebudowę ciała."

/datum/symptom/toxoplasmosis/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4)
		severity += 3
	if(A.transmission >= 4)
		severity += 2

/datum/symptom/toxoplasmosis/Start(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4)
		mania = TRUE
	if(A.transmission >= 4)
		uwu = TRUE
		RegisterSignal(A.affected_mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/toxoplasmosis/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(!ishuman(A.affected_mob))
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(A.stage >= 4)
		if(uwu && prob(40))
			M.say(pick("", "", "", ";", ".h")+pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- miau", "mrrrr", "Miau- Nya") + pick("!", "!!", "~!!", "!~", "~", "", "", ""), forced = "toxoplasmosis")
		if(mania)
			var/obj/item/organ/ears/cat/ears = M.getorgan(/obj/item/organ/ears/cat)
			var/obj/item/organ/tail/tail = M.getorgan(/obj/item/organ/tail)
			if(tail && !istype(tail, /obj/item/organ/tail/cat))
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_dysmorphia)
				M.adjustOrganLoss(ORGAN_SLOT_TAIL, 30, 200)
				M.visible_message("<span class='hypnophrase'>Ten ogon jest obrzydliwy! Musisz się go pozbyć!</span>", "<span class='warning'>[M] zajadle szarpie własny ogon!</span>")
				if(tail.organ_flags & ORGAN_FAILING)
					M.visible_message("<span class='hypnophrase'>W końcu udaje ci się wyrwać sobie ogon!</span>", "<span class='warning'>[M] wyrywa sobie ogon!</span>")
					tail.Remove(M)
					tail.forceMove(get_turf(M))
					M.add_splatter_floor(get_turf(M))
					M.apply_damage(5, BRUTE)
					M.emote("laugh")
					playsound(M, 'sound/misc/desecration-01.ogg', 50, 1)
			else if(!ears || !tail)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_dysmorphia)
				if(dnacounter >= 5)
					if(!tail)
						var/obj/item/organ/tail/cat/cattail = new()
						cattail.Insert(M, drop_if_replaced = FALSE)
						M.visible_message("<span class='warning'>Z odgłosem mielonego mięsa i przestawianych kości z ciała [M] wyrasta groteskowy ogon.</span>", "<span class='hypnophrase'>Z twojej miednicy samoistnie wyrasta ogon! Jest taki słodki!</span>")
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
					else
						var/obj/item/organ/ears/cat/catears = new()
						catears.Insert(M, drop_if_replaced = FALSE)
						M.visible_message( "<span class='warning'>Uszy [M] na chwilę chowają się w czaszce, po czym ciało się wykrzywia, a z głowy wyrasta para obrzydliwych kocich uszu.</span>", "<span class='hypnophrase'>Twoje uszy przekształcają się w <b>PRZEUROCZĄ</b> parę kocich uszu!</span>")
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
					dnacounter -= 5
				else if(M.stat)
					var/mob/living/cat = findcat(M, !ears, !tail)
					if(cat)
						M.visible_message("<span class='warning'>[M] odchyla się, wpatrując się w [cat] z maniakalnym błyskiem w oczach.</span>", "<span class='hypnophrase'>Szykujesz się, by rzucić się na [cat]!</span>")
						addtimer(CALLBACK(src, PROC_REF(Pounce), cat, M), 20)
			else
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_mania)
		else if(findcat(M))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/toxoplasmosis)

/datum/symptom/toxoplasmosis/proc/Pounce(mob/living/cat, mob/living/carbon/human/H)
	if(istype(cat, /mob/living/simple_animal/pet/cat))
		H.throw_at(cat, get_dist(cat, H), 2)
		if(get_dist(cat, H) > 1)
			return
		to_chat(H, "<span class='hypnophrase'>Głaszczesz [cat]!</span>")
		cat.visible_message("<span class='warning'>[H] brutalnie chwyta [cat]!</span>", "<span class='userdanger'>[H] brutalnie chwyta cię za kark!</span>")
		H.emote("laugh")
		cat.apply_damage(5, BRUTE)
		dnacounter += 2 //real cats are purer, scarcer, and all around better
	else if(H.throw_at(cat, 7, 2))
		if(get_dist(cat, H) > 1)
			return
		if(ishuman(cat))
			var/mob/living/carbon/human/target = cat
			var/obj/item/organ/ears/cat/targetears = target.getorgan(/obj/item/organ/ears/cat)
			var/obj/item/organ/tail/cat/targettail = target.getorgan(/obj/item/organ/tail/cat)
			if(!H.getorgan(/obj/item/organ/tail/cat) && targettail)
				target.adjustOrganLoss(ORGAN_SLOT_TAIL, 20, 200)
				dnacounter += 1
				if(targettail.organ_flags & ORGAN_FAILING)
					to_chat(target, "<span class='userdanger'>[H] wyrywa ci ogon!</span>")
					H.emote("laugh")
					H.visible_message("<span class='warning'>[H] wyrywa ogon [target]!</span>", "<span class='hypnophrase'>Masz ogon [target]!</span>")
					targettail.Remove(target)
					targettail.forceMove(get_turf(target))
					target.emote("scream")
					target.add_splatter_floor(get_turf(target))
					target.apply_damage(5, BRUTE)
					H.put_in_hands(targettail)
					dnacounter += 1
					playsound(target, 'sound/misc/desecration-01.ogg', 50, 1)
				else
					H.visible_message("<span class='warning'>[H] ciągnie [target] za ogon!</span>", "<span class='hypnophrase'>Trącasz łapką ogon [target]!</span>")
					to_chat(target, "<span class='userdanger'>[H] ciągnie cię za ogon!</span>")
					H.emote("laugh")
			else if(!H.getorgan(/obj/item/organ/ears/cat) && targetears)
				target.adjustOrganLoss(ORGAN_SLOT_EARS, 20, 200)
				dnacounter += 1
				if(targetears.organ_flags & ORGAN_FAILING)
					to_chat(target, "<span class='userdanger'>[H] wyrywa ci uszy!</span>")
					H.emote("laugh")
					H.visible_message("<span class='warning'>[H] wyrywa uszy [target] z czaszki!</span>", "<span class='hypnophrase'>Masz uszy [target]!</span>")
					targetears.Remove(target)
					targetears.forceMove(get_turf(target))
					target.emote("scream")
					target.add_splatter_floor(get_turf(target))
					target.apply_damage(5, BRUTE)
					H.put_in_hands(targetears)
					playsound(target, 'sound/misc/desecration-01.ogg', 50, 1)
				else
					H.visible_message("<span class='warning'>[H] szarpie [target] za uszy!</span>", "<span class='hypnophrase'>Drapiesz [target] za uszami!</span>")
					to_chat(target, "<span class='userdanger'>[H] szarpie cię za uszy!</span>")
					H.emote("laugh")
			target.apply_damage(rand(1, 10), BRUTE)

/datum/symptom/toxoplasmosis/End(datum/disease/advance/A)
	. = ..()
	if(uwu)
		UnregisterSignal(A.affected_mob, COMSIG_MOB_SAY)
	SEND_SIGNAL(A.affected_mob, COMSIG_CLEAR_MOOD_EVENT, "toxoplasmosis")

/datum/symptom/toxoplasmosis/proc/findcat(mob/living/carbon/human/M, requiresears = TRUE, requirestail = TRUE) //return a cat, or someone with cat ears and a tail
	for(var/mob/living/L in oviewers(7, M))
		if(L.stat)
			continue
		if(istype(L, /mob/living/simple_animal/pet/cat))
			return L
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/ears = H.getorgan(/obj/item/organ/ears/cat)
			var/tail = H.getorgan(/obj/item/organ/tail/cat)
			if((ears && requiresears) || (tail && requirestail))
				return H


/datum/symptom/toxoplasmosis/proc/handle_speech(datum/source, list/speech_args) //taken straight from storm's original felinid virus
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings("owo_talk.json", "wowds")
		var/list/owo_sounds = strings("owo_talk.json", "sounds")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		for(var/key in owo_sounds)
			var/value = owo_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(3))
			message += pick(" Nya!"," Miau!"," OwO!!", " Nya-nya!", " Nyaaa~")
	speech_args[SPEECH_MESSAGE] = trim(message)

