/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/obscure_name

	var/obscured = check_obscured_slots()
	var/skipface = ((wear_mask?.flags_inv & HIDEFACE) || (head?.flags_inv & HIDEFACE))

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE

	var/apparent_species
	//NSV13 - add rank to name
	var/display_name = ""
	if(CONFIG_GET(flag/show_ranks))
		display_name += "[compose_rank(src)]"
	display_name += name
	if(dna?.species && !skipface)
		apparent_species = ", <span class='[species_examine_font()]'>\an [dna.species.name]</span>" //NSV13 - species name is colored depending on special conditions.
	. = list("<span class='info'>To jest <EM>[!obscure_name ? display_name : "Nieznajomy"][apparent_species]</EM>!")

	//uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !(w_uniform.item_flags & EXAMINE_SKIP))
		//accessory
		var/accessory_msg
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			if(U.attached_accessory)
				accessory_msg += " z [icon2html(U.attached_accessory, user)] [U.attached_accessory]"

		. += "Ma na sobie [w_uniform.get_examine_string(user)][accessory_msg]."
	//head
	if(head && !(head.item_flags & EXAMINE_SKIP))
		. += "Na głowie ma [head.get_examine_string(user)]."
	//suit/armor
	if(wear_suit && !(wear_suit.item_flags & EXAMINE_SKIP))
		. += "Nosi [wear_suit.get_examine_string(user)]."
		//suit/armor storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !(s_store.item_flags & EXAMINE_SKIP))
			. += "Na [wear_suit.name] nosi [s_store.get_examine_string(user)]."
	//back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		. += "Na plecach ma [back.get_examine_string(user)]."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT) && !(I.item_flags & EXAMINE_SKIP))
			. += "W ręce ([get_held_index_name(get_held_index_of_item(I))]) trzyma [I.get_examine_string(user)]."

	var/datum/component/forensics/FR = GetComponent(/datum/component/forensics)
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		. += "Na dłoniach ma [gloves.get_examine_string(user)]."
	else if(FR && length(FR.blood_DNA))
		var/hand_number = get_num_arms(FALSE)
		if(hand_number)
			. += "<span class='warning'>Ma [hand_number > 1 ? "zakrwawione dłonie" : "zakrwawioną dłoń"]!</span>"

	//belt
	if(belt && !(belt.item_flags & EXAMINE_SKIP))
		. += "W pasie ma [belt.get_examine_string(user)]."

	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET) && !(shoes.item_flags & EXAMINE_SKIP))
		. += "Na stopach ma [shoes.get_examine_string(user)]."

	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK) && !(wear_mask.item_flags & EXAMINE_SKIP))
		. += "Na twarzy ma [wear_mask.get_examine_string(user)]."

	if(wear_neck && !(obscured & ITEM_SLOT_NECK) && !(wear_neck.item_flags & EXAMINE_SKIP))
		. += "Na szyi ma [wear_neck.get_examine_string(user)]."

	//eyes
	if(!(obscured & ITEM_SLOT_EYES))
		if(glasses && !(glasses.item_flags & EXAMINE_SKIP))
			. += "Oczy zasłania mu [glasses.get_examine_string(user)]."
		else if(eye_color == BLOODCULT_EYE && iscultist(src) && HAS_TRAIT(src, CULT_EYES))
			. += "<span class='warning'><B>Oczy jarzą mu się nienaturalną czerwienią!</B></span>"

	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		. += "Na uszach ma [ears.get_examine_string(user)]."

	//ID
	if(wear_id && !(wear_id.item_flags & EXAMINE_SKIP))
		. += "Nosi [wear_id.get_examine_string(user)]."

	//Status effects
	. += status_effect_examines()

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			. += "<span class='warning'><B>Gwałtownie się wije w drgawkach!</B></span>"
		if(200 to 300)
			. += "<span class='warning'>Jest skrajnie roztrzęsiony.</span>"
		if(100 to 200)
			. += "<span class='warning'>Ledwo zauważalnie drga.</span>"

	var/appears_dead = FALSE
	var/just_sleeping = FALSE
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = TRUE

		if(isliving(user) && HAS_TRAIT(user, TRAIT_NAIVE))
			just_sleeping = TRUE

		if(!just_sleeping)
			if(suiciding)
				. += "<span class='warning'>Wygląda na to, że popełnił samobójstwo... nie ma nadziei na powrót do zdrowia.</span>"
			if(ishellbound())
				. += "<span class='warning'>Wygląda, jakby wyrwano mu duszę z ciała. Wskrzeszenie jest niemożliwe.</span>"
			. += ""
			if(soul_departed())
				. += "<span class='deadsay'>Leży bezwładnie i nie reaguje; nie ma oznak życia, a dusza odeszła...</span>"
			else if(!client && key)
				. += "<span class='deadsay'>Leży bezwładnie i nie reaguje; nie ma oznak życia, a dusza wydaje się daleka, może wkrótce wróci...</span>"
			else
				. += "<span class='deadsay'>Leży bezwładnie i nie reaguje; nie ma oznak życia...</span>"

	if(get_bodypart(BODY_ZONE_HEAD) && !getorgan(/obj/item/organ/brain))
		. += "<span class='deadsay'>Wygląda na to, że brakuje mu mózgu.</span>"

	var/temp = getBruteLoss() //no need to calculate each of these twice

	var/list/msg = list("<span class='warning'>")
	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()

	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.disabled)
			disabled += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>Do kończyny ([BP.name]) przylega [icon2html(I, user)] [I]!</B>\n"
			else
				msg += "<B>W kończynie ([BP.name]) tkwi [icon2html(I, user)] [I]!</B>\n"

	for(var/X in disabled)
		var/obj/item/bodypart/BP = X
		var/damage_text
		if(!(BP.get_damage(include_stamina = FALSE) >= BP.max_damage)) //Stamina is disabling the limb
			damage_text = "bezwładna i martwa"
		else
			damage_text = (BP.brute_dam >= BP.burn_dam) ? BP.heavy_brute_msg : BP.heavy_burn_msg
		msg += "<B>Kończyna ([BP.name]): [damage_text]!</B>\n"

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>Brakuje kończyny: [parse_zone(t)]!</B><span class='warning'>\n"
			continue
		if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG)
			r_limbs_missing++

		msg += "<B>Brakuje kończyny: [parse_zone(t)]!</B>\n"

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "Wygląda już w porządku.\n"
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		msg += "Naprawdę trzyma się lewej strony.\n"
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		msg += "Nie wydaje się być w pełni sobą.\n"

	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.limb_id != (dna.species.examine_limb_id ? dna.species.examine_limb_id : dna.species.id))
			msg += "<span class='info'>Ma kończynę: [BP.name].</span>\n"

	var/list/harm_descriptors = dna?.species.get_harm_descriptors()
	var/brute_msg = harm_descriptors?["brute"]
	var/burn_msg = harm_descriptors?["burn"]
	var/bleed_msg = harm_descriptors?["bleed"]

	brute_msg = brute_msg ? brute_msg : "siniaki"
	burn_msg = burn_msg ? burn_msg : "oparzenia"
	bleed_msg = bleed_msg ? bleed_msg : "krwawi"

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if(temp < 25)
				msg += "Ma drobne [brute_msg].\n"
			else if(temp < 50)
				msg += "Ma <b>średnie</b> [brute_msg]!\n"
			else
				msg += "<B>Ma poważne [brute_msg]!</B>\n"

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				msg += "Ma drobne [burn_msg].\n"
			else if (temp < 50)
				msg += "Ma <b>średnie</b> [burn_msg]!\n"
			else
				msg += "<B>Ma poważne [burn_msg]!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "Ma drobne uszkodzenia komórkowe.\n"
			else if(temp < 50)
				msg += "Ma <b>średnie</b> uszkodzenia komórkowe!\n"
			else
				msg += "<b>Ma poważne uszkodzenia komórkowe!</b>\n"


	if(fire_stacks > 0)
		msg += "Jest pokryty czymś łatwopalnym.\n"
	if(fire_stacks < 0)
		msg += "Wygląda na trochę przemoczonego.\n"


	if(pulledby?.grab_state)
		msg += "Trzyma go mocny chwyt [pulledby].\n"

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		msg += "Jest poważnie niedożywiony.\n"
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			msg += "Jest pulchny i wygląda apetycznie - jak tłusta mała świnka. Smakowita świnka.\n"
		else
			msg += "Jest dość pulchny.\n"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			msg += "Wygląda na trochę zniesmaczonego.\n"
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			msg += "Wygląda na mocno zniesmaczonego.\n"
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			msg += "Wygląda na skrajnie zdegustowanego.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE)
		msg += "Ma bladą skórę.\n"

	if(bleedsuppress)
		msg += "Jest czymś obandażowany.\n"
	else if(bleed_rate)
		if(reagents.has_reagent(/datum/reagent/toxin/heparin, needs_metabolizing = TRUE))
			msg += "<b>Niepowstrzymanie [bleed_msg]!</b>\n"
		else
			msg += "<B>[capitalize(bleed_msg)]!</B>\n"

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		msg += "Emanuje delikatną niebieską poświatą!\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[stun_absorption[i]["examine_message"]]\n"

	if(just_sleeping)
		msg += "Nie reaguje na nic wokół i wydaje się spać.\n"

	if(drunkenness && !skipface && !appears_dead) //Drunkenness
		switch(drunkenness)
			if(11 to 21)
				msg += "Jest lekko zarumieniony.\n"
			if(21.01 to 41) //.01s are used in case drunkenness ends up to be a small decimal
				msg += "Jest zarumieniony.\n"
			if(41.01 to 51)
				msg += "Jest mocno zarumieniony, a z ust czuć mu alkohol.\n"
			if(51.01 to 61)
				msg += "Jest bardzo zarumieniony, rusza się nerwowo, a z ust cuchnie mu alkoholem.\n"
			if(61.01 to 91)
				msg += "Wygląda na kompletnie pijanego.\n"
			if(91.01 to INFINITY)
				msg += "Jest kompletnie zalany i się ślini.\n"

	if(ismob(user))
		if(HAS_TRAIT(user, TRAIT_EMPATH) && !appears_dead && (src != user))
			if (a_intent != INTENT_HELP)
				msg += "Wydaje się czujny.\n"
			if (getOxyLoss() >= 10)
				msg += "Wydaje się zdyszany.\n"
			if (getToxLoss() >= 10)
				msg += "Wygląda na chorowitego.\n"
			var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
			if(mood.sanity <= SANITY_DISTURBED)
				msg += "Wydaje się zaniepokojony.\n"
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "empath", /datum/mood_event/sad_empath, src)
			if (HAS_TRAIT(src, TRAIT_BLIND))
				msg += "Wydaje się patrzeć w pustkę.\n"
			if (HAS_TRAIT(src, TRAIT_DEAF))
				msg += "Wydaje się nie reagować na dźwięki.\n"

	msg += "</span>"

	if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
		msg += "Otacza go święta aura.\n"
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "religious_comfort", /datum/mood_event/religiously_comforted)

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "Nie reaguje na nic wokół i wydaje się spać.\n"
		else
			if(HAS_TRAIT(src, TRAIT_DUMB))
				msg += "Ma głupi wyraz twarzy.\n"
			if(InCritical())
				msg += "Ledwo jest przytomny.\n"
		if(getorgan(/obj/item/organ/brain))
			if(ai_controller?.ai_status == AI_STATUS_ON || isknpc(src)) //NSV13 added KNPCs
				msg += "<span class='deadsay'>Nie wydaje się być sobą.</span>\n"
			else if(!key)
				msg += "<span class='deadsay'>Jest w całkowitej katatonii. Stres życia w głębokim kosmosie musiał go przerosnąć. Powrót do zdrowia jest mało prawdopodobny.</span>\n"
			else if(!client)
				msg += "Ma pusty, nieobecny wzrok i zupełnie na nic nie reaguje. Może wkrótce się ocknie.\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			. += "<span class='warning'>Jest skrępowany kablem!</span>"
		else
			. += "<span class='warning'>Ma założone kajdanki: [handcuffed]!</span>"

	//legcuffed?
	if(legcuffed)
		. += "<span class='warning'>Ma skute nogi: [legcuffed]!</span>"

	if (length(msg))
		. += "<span class='warning'>[msg.Join("")]</span>"

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/traitstring = get_trait_string()

	var/perpname = get_face_name(get_id_name(""))
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
		if(R)
			. += "<span class='deptradio'>Rank:</span> [R.fields["rank"]]\n<a href='byond://?src=[REF(src)];hud=1;photo_front=1'>\[Front photo\]</a><a href='byond://?src=[REF(src)];hud=1;photo_side=1'>\[Side photo\]</a>"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/list/cyberimp_detect = list()
			for(var/obj/item/organ/cyberimp/CI in internal_organs)
				if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
					cyberimp_detect += CI.name
			if(length(cyberimp_detect))
				. += "Wykryte modyfikacje cybernetyczne: [english_list(cyberimp_detect)]"
			if(R)
				var/health_r = R.fields["p_stat"]
				. += "<a href='byond://?src=[REF(src)];hud=m;p_stat=1'>\[[health_r]\]</a>"
				health_r = R.fields["m_stat"]
				. += "<a href='byond://?src=[REF(src)];hud=m;m_stat=1'>\[[health_r]\]</a>"
			R = find_record("name", perpname, GLOB.data_core.medical)
			if(R)
				. += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1'>\[Medical evaluation\]</a><br>"
			if(traitstring)
				. += "<span class='info'>Wykryte cechy fizjologiczne:\n[traitstring]"
			//NSV13 - Roleplaying Records - Start
			. += "<a href='byond://?src=[REF(src)];hud=m;medrecords=1'>\[View medical records\]</a>"
			. += "<a href='byond://?src=[REF(src)];hud=m;genrecords=1'>\[View general records\]</a>"
			//NSV13 - Roleplaying Records - End

		if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			if(!user.stat && user != src)
			//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
				var/criminal = "None"

				R = find_record("name", perpname, GLOB.data_core.security)
				if(R)
					criminal = R.fields["criminal"]

				. += "<span class='deptradio'>Status karny:</span> <a href='byond://?src=[REF(src)];hud=s;status=1'>\[[criminal]\]</a>"
				. += jointext(list("<span class='deptradio'>Akta ochrony:</span> <a href='byond://?src=[REF(src)];hud=s;viewsec=1'>\[Pokaż akta ochrony\]</a>", //NSV13 - Roleplaying Records
					"<a href='byond://?src=[REF(src)];hud=s;add_citation=1'>\[Add citation\]</a>",
					"<a href='byond://?src=[REF(src)];hud=s;add_crime=1'>\[Add crime\]</a>",
					"<a href='byond://?src=[REF(src)];hud=s;view_comment=1'>\[View comment log\]</a>",
					"<a href='byond://?src=[REF(src)];hud=s;add_comment=1'>\[Add comment\]</a>"), "")

				. += jointext(list("<span class='deptradio'>Akta ogólne:</span> <a href='byond://?src=[REF(src)];hud=s;genrecords=1'>\[Pokaż akta ogólne\]</a>"), "") //NSV13 - Roleplaying Records
	else if(isobserver(user) && traitstring)
		. += "<span class='info'><b>Traits:</b> [traitstring]</span>"

	//NSV13 - Roleplaying Records - Start
	if(!skipface)
		var/line = "<span class='notice'><a href='byond://?src=[REF(src)];lookup_info=open_examine_panel'>Przyjrzyj się uważniej...</a></span>"

		if(line)
			. += line

	//NSV13 - Roleplaying Records - End

	//AQ EDIT snip snip
	if(gender_ambiguous) //jajoskręt
		if (gender == MALE)
			. += "Jest w nim coś dziwnie kobiecego.\n"
		else
			. += "Jest w niej coś dziwnie męskiego.\n"


/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			var/new_text = replacetext(E.examine_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()

/mob/living/proc/soul_departed()
	return getorgan(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE)
