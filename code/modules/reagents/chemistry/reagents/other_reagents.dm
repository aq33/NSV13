/datum/reagent/blood
	data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	color = "#C80000" // rgb: 200, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 5 //fast rate so it disappears fast.
	taste_description = "żelazo"
	taste_mult = 1.3
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Na pewno to sok pomidorowy?"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/blood/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method == INGEST && ismoth(L) && !HAS_TRAIT(L, TRAIT_AGEUSIA))//NSSV13 - Moths occasionally enjoy a sip of blood
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/moth_drink_blood)

	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if(data["donor"] == /mob/living/simple_animal/mouse && L) // NSV13 - Lizards do not get rat viruses
				if(islizard(L))
					continue

				if(istype(L, /mob/living/carbon))
					var/mob/living/carbon/C = L
					if(iscatperson(C))
						continue
			// NSV13 end species check

			if((method == TOUCH || method == VAPOR) && (D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				L.ContactContractDisease(D)
			else //ingest, patch or inject
				L.ForceContractDisease(D)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.get_blood_id() == /datum/reagent/blood && (method == INJECT || (method == INGEST && HAS_TRAIT(C, TRAIT_DRINKSBLOOD))))
			if(!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type)))
				C.reagents.add_reagent(/datum/reagent/toxin, reac_volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)


/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_DNA"] != mix_data["blood_DNA"])
			data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning if the DNA sample doesn't match.
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				if(AD.mutable)
					to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				if(AD.mutable)
					to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(istype(D, /datum/disease/advance))
						var/datum/disease/advance/A = D
						if(!A.mutable)
							preserve += A
					else
						preserve += D
				data["viruses"] = preserve
	return 1

/datum/reagent/blood/proc/get_diseases()
	. = list()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing
			. += D

/datum/reagent/blood/reaction_turf(turf/T, reac_volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/B = locate() in T //find some blood here
	if(!B)
		B = new(T)
	if(data["blood_DNA"])
		B.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/liquidgibs
	name = "Liquid gibs"
	color = "#FF9966"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	description = "Nawet nie chcesz myśleć, co tu jest."
	taste_description = "obrzydliwe żelazo"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	chem_flags = NONE
	taste_description = "szlam"

/datum/reagent/vaccine/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(islist(data) && (method == INGEST || method == INJECT))
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		L.disease_resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/corgium
	name = "Corgium"
	description = "Radośnie wyglądający płyn, który czujesz się zmuszony wypić, jeśli chcesz lepszego życia."
	color = "#ecca7f"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "przysmaki dla psów"
	var/mob/living/simple_animal/pet/dog/corgi/new_corgi

/datum/reagent/corgium/on_mob_metabolize(mob/living/L)
	. = ..()
	var/obj/shapeshift_holder/H = locate() in L
	if(H)
		to_chat(L, "<span class='warning'>Już jesteś skorgifikowany!</span>")
		return
	ADD_TRAIT(L, TRAIT_MUTE, CORGIUM_TRAIT)
	new_corgi = new(L.loc)
	//hat check
	var/mob/living/carbon/C = L
	if(istype(C))
		var/obj/item/hat = C.get_item_by_slot(ITEM_SLOT_HEAD)
		if(hat?.dog_fashion)
			new_corgi.place_on_head(hat,null,FALSE)
	H = new(new_corgi,src,L)

/datum/reagent/corgium/on_mob_life(mob/living/carbon/M)
	. = ..()
	//If our corgi died :(
	if(new_corgi.stat)
		holder.remove_all_type(type)
		addtimer(CALLBACK(src, PROC_REF(restore), M), 2 SECONDS)

/datum/reagent/corgium/on_mob_end_metabolize(mob/living/L)
	. = ..()
	restore(L)

/datum/reagent/corgium/proc/restore(mob/living/L)
	ADD_TRAIT(L, TRAIT_MUTE, CORGIUM_TRAIT)
	var/obj/shapeshift_holder/H = locate() in L
	if(!H)
		return
	H.restore()

/datum/reagent/water
	name = "Water"
	description = "Wszechobecna substancja chemiczna złożona z wodoru i tlenu."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL // because we want to give it to oozelings
	taste_description = "woda"
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of water"
	glass_desc = "Ojciec wszelkiego orzeźwienia."
	shot_glass_icon_state = "shotglassclear"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/water/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOTHIRST))
			H.adjust_hydration(15 * REAGENTS_METABOLISM)

/*
 *	Water reaction to turf
 */

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
	if(!istype(T))
		return
	var/CT = cooling_temperature

	if(reac_volume >= 5)
		T.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))

	for(var/mob/living/simple_animal/slime/M in T)
		M.apply_water()

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !isspaceturf(T))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.set_temperature(max(min(G.return_temperature()-(CT*1000),G.return_temperature()/CT),TCMB))
			G.react(src)
			qdel(hotspot)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - reac_volume*50, 0)

/*
 *	Water reaction to an object
 */

/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	O.extinguish()
	O.acid_level = 0
	// Monkey cube
	if(istype(O, /obj/item/food/monkeycube))
		var/obj/item/food/monkeycube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/HH = O
		new /obj/item/stack/sheet/wetleather(get_turf(HH), HH.amount)
		qdel(HH)

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M))
		return
	if(isoozeling(M))
		M.blood_volume = max(M.blood_volume - 30, 0)
		to_chat(M, "<span class='warning'>Woda sprawia, że się rozpuszczasz!</span>")
		return
	var/mob/living/carbon/human/H = M //NSV felinids can be sprayed by water
	if(istype(H) && iscatperson(H) && (method == TOUCH || method == VAPOR))
		if(M.fire_stacks < 0) //if we're on fire, don't apply the negative mood
			M.Immobilize(1) //startles the felinid
			if (method == TOUCH)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "watersplashed", /datum/mood_event/watersplashed)
			if (method == VAPOR)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "watersprayed", /datum/mood_event/watersprayed) //End of NSV code
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	..()

/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Woda pobłogosławiona przez jakieś bóstwo."
	color = "#E0E8EF" // rgb: 224, 232, 239
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	glass_icon_state  = "glass_clear"
	glass_name = "glass of holy water"
	glass_desc = "Szklanka wody święconej."
	self_consuming = TRUE //divine intervention won't be limited by the lack of a liver

/datum/reagent/water/holywater/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_HOLY, type)

/datum/reagent/water/holywater/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_HOLY, type)
	if(HAS_TRAIT_FROM(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
		REMOVE_TRAIT(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		to_chat(L, "<span class='notice'>Poprawia ci się humor, bo wiesz, że wszystko będzie dobrze.</span>")
	..()

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	if(!data)
		data = list("misc" = 1)
	data["misc"]++
	M.jitteriness = min(M.jitteriness+4,10)
	if(iscultist(M))
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			to_chat(M, "<span class='cultlarge'>Twoje krwawe obrzędy słabną, gdy woda święcona przeczyszcza twoje ciało!</span>")
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				qdel(BS)
	if(data["misc"] >= 25)		// 10 units, 45 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering+4, 10)
		M.Dizzy(5)
		if(is_servant_of_ratvar(M) && prob(20))
			M.say(text2ratvar(pick("Proszę, nie zostawiaj mnie...", "Rat'varze, co się stało?", "Przyjaciele, gdzie jesteście?", "Sieć hierofanta właśnie zgasła, jest tam ktoś?", "Światło gaśnie...", "Nie... To niemożliwe...")), forced = "woda święcona")
			if(prob(40))
				if(!HAS_TRAIT_FROM(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
					to_chat(M, "<span class='large_brass'>Czujesz, jak światło gaśnie, a świat wokół ciebie się rozpada...</span>")
					ADD_TRAIT(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		if(iscultist(M) && prob(20))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "woda święcona")
			if(prob(10))
				M.visible_message("<span class='danger'>[M] dostaje napadu drgawek!</span>", "<span class='userdanger'>Dostajesz napadu drgawek!</span>")
				M.Unconscious(120)
				to_chat(M, "<span class='cultlarge'>[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")].</span>")
	if(data["misc"] >= 60)	// 30 units, 135 seconds
		if(iscultist(M) || is_servant_of_ratvar(M))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
			if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M.mind)
			M.jitteriness = 0
			M.stuttering = 0
			holder.remove_reagent(type, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			return
	if(ishuman(M) && is_vampire(M) && prob(80)) // Yogs Start
		var/datum/antagonist/vampire/V = M.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V.get_ability(/datum/vampire_passive/full))
			switch(data)
				if(1 to 4)
					to_chat(M, "<span class='warning'>Coś skwierczy w twoich żyłach!</span>")
					M.adjustFireLoss(0.5)
				if(5 to 12)
					to_chat(M, "<span class='danger'>Czujesz w sobie intensywne pieczenie!</span>")
					M.adjustFireLoss(1)
				if(13 to INFINITY)
					M.visible_message("<span class='danger'>[M] nagle staje w płomieniach!<span>", "<span class='userdanger'>Nagle stajesz w świętym ogniu!</span>")
					M.adjust_fire_stacks(3)
					M.IgniteMob()            //Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					M.adjustFireLoss(3)        //Hence the other damages... ain't I a bastard? // Yogs End
	holder.remove_reagent(type, 0.4)	//fixed consumption to prevent balancing going out of whack

/datum/reagent/water/holywater/reaction_turf(turf/T, reac_volume)
	..()
	if(!istype(T))
		return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	description = "Coś, co nie powinno istnieć na tym planie egzystencji."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "cierpienie"

/datum/reagent/fuel/unholywater/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent(type,reac_volume/4)
		return
	return ..()

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/M)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-10, 0)
		M.adjustToxLoss(-2, 0)
		M.adjustOxyLoss(-2, 0)
		M.adjustBruteLoss(-2, 0)
		M.adjustFireLoss(-2, 0)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3
	else  // Will deal about 90 damage when 50 units are thrown
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, 0)
		M.adjustFireLoss(2, 0)
		M.adjustOxyLoss(2, 0)
		M.adjustBruteLoss(2, 0)
	holder.remove_reagent(type, 1)
	return TRUE

/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	description = "TWOJE CIAŁO! PŁONIE!"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "pieczenie"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/M)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly available fire suits make you immune to being on fire
	M.adjustToxLoss(1, 0)
	M.adjustFireLoss(1, 0)		//Hence the other damages... ain't I a bastard?
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 150)
	holder.remove_reagent(type, 1)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Powoli leczy wszystkie rodzaje obrażeń. Ma dość wysoki próg przedawkowania. Świeci tajemniczą mocą."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 150

/datum/reagent/lube
	name = "Space Lube"
	description = "Smar to substancja wprowadzana między dwie poruszające się powierzchnie, by zmniejszyć tarcie i zużycie. He, he."
	color = "#009CA8" // rgb: 0, 156, 168
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "wiśnia" // by popular demand
	var/lube_kind = TURF_WET_LUBE ///What kind of slipperiness gets added to turfs.

/datum/reagent/lube/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	if(reac_volume >= 1)
		T.MakeSlippery(lube_kind, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

///Stronger kind of lube. Applies TURF_WET_SUPERLUBE.
/datum/reagent/lube/superlube
	name = "Super Duper Lube"
	description = "Ten \[UTAJNIONO\] został zakazany po incydencie na \[DANE USUNIĘTE\]."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	lube_kind = TURF_WET_SUPERLUBE


/datum/reagent/spraytan
	name = "Spray Tan"
	description = "Substancja nakładana na skórę, by ją przyciemnić."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "kwaśne pomarańcze"

/datum/reagent/spraytan/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(N.dna.species.id == SPECIES_HUMAN)
				switch(N.skin_tone)
					if("african1")
						N.skin_tone = "african2"
					if("indian")
						N.skin_tone = "african1"
					if("arab")
						N.skin_tone = "indian"
					if("asian2")
						N.skin_tone = "arab"
					if("asian1")
						N.skin_tone = "asian2"
					if("mediterranean")
						N.skin_tone = "african1"
					if("latino")
						N.skin_tone = "mediterranean"
					if("caucasian3")
						N.skin_tone = "mediterranean"
					if("caucasian2")
						N.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						N.skin_tone = "caucasian2"
					if ("albino")
						N.skin_tone = "caucasian1"

			if(MUTCOLORS in N.dna.species.species_traits) //take current alien color and darken it slightly
				var/newcolor = ""
				var/string = N.dna.features["mcolor"]
				var/len = length(string)
				var/char = ""
				var/ascii = 0
				for(var/i=1, i<=len, i += length(char))
					char = string[i]
					ascii = text2ascii(char)
					switch(ascii)
						if(48)
							newcolor += "0"
						if(49 to 57)
							newcolor += ascii2text(ascii-1)	//numbers 1 to 9
						if(97)
							newcolor += "9"
						if(98 to 102)
							newcolor += ascii2text(ascii-1)	//letters b to f lowercase
						if(65)
							newcolor += "9"
						if(66 to 70)
							newcolor += ascii2text(ascii+31)	//letters B to F - translates to lowercase
						else
							break
				if(ReadHSV(newcolor)[3] >= ReadHSV("#7F7F7F")[3])
					N.dna.features["mcolor"] = newcolor
			N.regenerate_icons()



		if(method == INGEST)
			if(show_message)
				to_chat(M, "<span class='notice'>To smakowało okropnie.</span>")
	..()

/datum/reagent/spraytan/overdose_start(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		N.hair_style = "Spiky"
		N.facial_hair_style = "Shaved"
		N.facial_hair_color = "000"
		N.hair_color = "000"
		if(!(HAIR in N.dna.species.species_traits)) //No hair? No problem!
			N.dna.species.species_traits += HAIR
		if(N.dna.species.use_skintones)
			N.skin_tone = "orange"
		else if(MUTCOLORS in N.dna.species.species_traits) //Aliens with custom colors simply get turned orange
			N.dna.features["mcolor"] = "f80"
		N.regenerate_icons()
	..()

/datum/reagent/spraytan/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		if(prob(7))
			if(N.w_uniform)
				M.visible_message(pick("<b>Kołnierz [M]</b> bez ostrzeżenia staje na sztorc.</span>", "<b>[M]</b> napina ramiona."))
			else
				M.visible_message("<b>[M]</b> napina ramiona.")
		if(prob(10))
			M.say(pick("Było TAK zajebiście.", "Jesteś wszystkim, co złe na świecie.", "Jakie sporty uprawiasz, poza walenie konia do rysunków nagich Japończyków?", "Nie bądź obcy. Po prostu daj mi z siebie wszystko.", "Mam na imię John i nienawidzę was wszystkich."), forced = /datum/reagent/spraytan)

#define MUT_MSG_IMMEDIATE 1
#define MUT_MSG_EXTENDED 2
#define MUT_MSG_ABOUT2TURN 3

/datum/reagent/mutationtoxin
	name = "Stable Mutation Toxin"
	description = "Uczłowieczająca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	metabolization_rate = 0.2 //metabolizes to prevent micro-dosage. about 4u is necessary to transform
	taste_description = "szlam"
	var/race = /datum/species/human
	process_flags = ORGANIC | SYNTHETIC
	var/list/mutationtexts = list( "You don't feel very well." = MUT_MSG_IMMEDIATE,
									"Your skin feels a bit abnormal." = MUT_MSG_IMMEDIATE,
									"Your limbs begin to take on a different shape." = MUT_MSG_EXTENDED,
									"Your appendages begin morphing." = MUT_MSG_EXTENDED,
									"You feel as though you're about to change at any moment!" = MUT_MSG_ABOUT2TURN)
	var/cycles_to_turn = 20 //the current_cycle threshold / iterations needed before one can transform

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/H)
	. = TRUE
	if(!istype(H))
		return
	if(!(H.dna?.species) || !(H.mob_biotypes & MOB_ORGANIC))
		return

	if(prob(10))
		var/list/pick_ur_fav = list()
		var/filter = NONE
		if(current_cycle <= (cycles_to_turn*0.3))
			filter = MUT_MSG_IMMEDIATE
		else if(current_cycle <= (cycles_to_turn*0.8))
			filter = MUT_MSG_EXTENDED
		else
			filter = MUT_MSG_ABOUT2TURN

		for(var/i in mutationtexts)
			if(mutationtexts[i] == filter)
				pick_ur_fav += i
		to_chat(H, "<span class='warning'>[pick(pick_ur_fav)]</span>")

	if(current_cycle >= cycles_to_turn)
		var/datum/species/species_type = pick(race) //this worked with the old code, somehow, and it works here...
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		to_chat(H, "<span class='warning'>Stajesz się: [lowertext(initial(species_type.name))]!</span>")
		return
	..()

/datum/reagent/mutationtoxin/classic //The one from plasma on green slimes
	name = "Mutation Toxin"
	description = "Wypaczająca toksyna."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/jelly/slime

/datum/reagent/mutationtoxin/unstable
	name = "Unstable Mutation Toxin"
	description = "W większości bezpieczna toksyna mutująca."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = list(/datum/species/jelly/slime,
						/datum/species/human,
						/datum/species/human/felinid,
						/datum/species/lizard,
						/datum/species/fly,
						/datum/species/moth,
						/datum/species/apid,
						/datum/species/pod,
						/datum/species/jelly,
						/datum/species/abductor,
						/datum/species/skeleton)

/datum/reagent/mutationtoxin/felinid
	name = "Felinid Mutation Toxin"
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/human/felinid
	taste_description = "coś niezbyt dobrego, miau"

/datum/reagent/mutationtoxin/lizard
	name = "Lizard Mutation Toxin"
	description = "Jaszczurząca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/lizard
	taste_description = "smoczy oddech, ale nie tak fajny"

/datum/reagent/mutationtoxin/fly
	name = "Fly Mutation Toxin"
	description = "Uowadniająca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/fly
	taste_description = "śmieci"

/datum/reagent/mutationtoxin/moth
	name = "Moth Mutation Toxin"
	description = "Świecąca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/moth
	taste_description = "ubrania"

/datum/reagent/mutationtoxin/apid
	name = "Apid Mutation Toxin"
	description = "Słodko pachnąca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/apid
	taste_description = "miód"

/datum/reagent/mutationtoxin/pod
	name = "Podperson Mutation Toxin"
	description = "Uroślinniająca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/pod
	taste_description = "kwiaty"

/datum/reagent/mutationtoxin/jelly
	name = "Imperfect Mutation Toxin"
	description = "Galaretująca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/jelly
	taste_description = "galaretka babci"

/datum/reagent/mutationtoxin/jelly/on_mob_life(mob/living/carbon/human/H)
	if(isjellyperson(H))
		to_chat(H, "<span class='warning'>Twoja galareta się przesuwa i zmienia kształt, zamieniając cię w inny podgatunek!</span>")
		var/species_type = pick(subtypesof(/datum/species/jelly))
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		return TRUE
	if(current_cycle >= cycles_to_turn) //overwrite since we want subtypes of jelly
		var/datum/species/species_type = pick(subtypesof(race))
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		to_chat(H, "<span class='warning'>Stajesz się: [initial(species_type.name)]!</span>")
		return TRUE
	return ..()

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "Kryształowa toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/golem/random
	taste_description = "kamienie"

/datum/reagent/mutationtoxin/abductor
	name = "Abductor Mutation Toxin"
	description = "Obca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/abductor
	taste_description = "coś nie z tego świata... nie, wszechświata!"
/datum/reagent/mutationtoxin/ethereal
	name = "Ethereal Mutation Toxin"
	description = "Pozytywnie elektryczna toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/ethereal
	taste_description = "szok"

/datum/reagent/mutationtoxin/oozeling
	name = "Oozeling Mutation Toxin"
	description = "Sącząca się toksyna"
	color = "#611e80" //RGB: 97, 30, 128
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/oozeling
	taste_description = "paląca maź"

//BLACKLISTED RACES
/datum/reagent/mutationtoxin/skeleton
	name = "Skeleton Mutation Toxin"
	description = "Przerażająca toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/skeleton
	taste_description = "mleko... i to dużo"

/datum/reagent/mutationtoxin/zombie
	name = "Zombie Mutation Toxin"
	description = "Nieumarła toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/zombie //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "móóóz... nic szczególnego"

/datum/reagent/mutationtoxin/goofzombie
	name = "Zombie Mutation Toxin"
	description = "Nieumarła toksyna... tak jakby..."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/human/krokodil_addict //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "krokodil"


/datum/reagent/mutationtoxin/ash
	name = "Ash Mutation Toxin"
	description = "Popielna toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/lizard/ashwalker
	taste_description = "dzikość"


//DANGEROUS RACES
/datum/reagent/mutationtoxin/shadow
	name = "Shadow Mutation Toxin"
	description = "Mroczna toksyna."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/shadow
	taste_description = "noc"

/datum/reagent/mutationtoxin/plasma
	name = "Plasma Mutation Toxin"
	description = "Toksyna na bazie plazmy."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/plasmaman
	taste_description = "plazma"

#undef MUT_MSG_IMMEDIATE
#undef MUT_MSG_EXTENDED
#undef MUT_MSG_ABOUT2TURN

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "Ta toksyna błyskawicznie zmienia DNA ludzi. Powszechnie używana przez szpiegów i zabójców Syndykatu, którzy potrzebują awaryjnej zmiany tożsamości."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	metabolization_rate = INFINITY
	taste_description = "szlam"

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H)
	..()
	if (!istype(H))
		return
	to_chat(H, "<span class='warning'><b>Zaciskasz zęby z bólu, gdy twoje ciało gwałtownie mutuje!</b></span>")
	H.visible_message("<b>[H]</b> nagle się przemienia!")
	randomize_human(H)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "Zaawansowana wypaczająca toksyna wytwarzana przez szlamy."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "szlam"

/datum/reagent/aslimetoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != TOUCH)
		L.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "Zaawansowana wypaczająca toksyna wytwarzana przez coś okropnego."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "rozkład"

/datum/reagent/gluttonytoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	L.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "Związek chemiczny pobudzający u ludzi skoncentrowaną produkcję neuroprzekaźnika serotoniny."
	color = "#202040" // rgb: 20, 20, 40
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "gorycz"

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	description = "Bezbarwny, bezwonny gaz. Rośnie na drzewach, ale wciąż jest dość cenny."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0 // oderless and tasteless


/datum/reagent/oxygen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/oxygen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "Bardzo ciągliwy metal. Rzeczy z miedzi nie są zbyt trwałe, ale nadaje się nieźle na przewody elektryczne."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"


/datum/reagent/copper/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = O
		reac_volume = min(reac_volume, M.amount)
		new/obj/item/stack/tile/bronze(get_turf(M), reac_volume)
		M.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "Bezbarwny, bezwonny, pozbawiony smaku gaz. Prosty gaz duszący, który potrafi po cichu wypierać niezbędny tlen."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/nitrogen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/nitrogen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "Bezbarwny, bezwonny, niemetaliczny, pozbawiony smaku, łatwopalny gaz dwuatomowy."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/potassium
	name = "Potassium"
	description = "Miękkie, niskotopliwe ciało stałe, które łatwo przeciąć nożem. Gwałtownie reaguje z wodą."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "słodycz"


/datum/reagent/mercury
	name = "Mercury"
	description = "Dziwny metal, który w temperaturze pokojowej jest cieczą. Neurodegeneracyjny i bardzo szkodliwy dla umysłu."
	color = "#484848" // rgb: 72, 72, 72A
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because brain damage is fun
	taste_mult = 0 // apparently tasteless.

/datum/reagent/mercury/lead_acetate
	name = "Lead Acetate"
	description = "Słodka substancja neurotoksyczna. Sekret rzymskiego słodkiego wina."
	color = "#AAAAAA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because brain damage is fun
	taste_description = "słodycz"
	taste_mult = 3

/datum/reagent/mercury/on_mob_life(mob/living/carbon/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	description = "Chorobliwie żółte ciało stałe, znane głównie z paskudnego zapachu. W biochemii jest o wiele bardziej przydatne, niż wygląda."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "zgniłe jaja"

/datum/reagent/carbon
	name = "Carbon"
	description = "Kruche czarne ciało stałe, które choć fizycznie niezbyt ekscytujące, stanowi podstawę całego znanego życia. Całkiem ważna rzecz."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "kwaśna kreda"

/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "Bladożółty gaz znany jako utleniacz. Choć tworzy wiele nieszkodliwych cząsteczek, w postaci pierwiastkowej jest daleki od nieszkodliwego."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "chlor"

/datum/reagent/chlorine/on_mob_life(mob/living/carbon/M)
	M.take_bodypart_damage(1*REM, 0, 0, 0)
	. = 1
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	description = "Komicznie reaktywny pierwiastek. Wszechświat w najmniejszym stopniu nie chce, by istniał w tej postaci."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "kwas"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1*REM, 0)
	. = 1
	..()

/datum/reagent/sodium
	name = "Sodium"
	description = "Miękki srebrzysty metal, który łatwo przeciąć nożem. To jeszcze nie sól, więc nie posypuj nim frytek."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "słony metal"

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "Rdzawoczerwony proszek, który łatwo się zapala. Choć występuje w wielu kolorach, ogólna zasada jest zawsze ta sama."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "ocet"

/datum/reagent/lithium
	name = "Lithium"
	description = "Srebrzysty metal, słynący z wyjątkowo niskiej gęstości. Jest aż za skuteczny w uspokajaniu się."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because it is fun
	taste_description = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/carbon/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !isspaceturf(M.loc) && isturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/glycerol
	name = "Glycerol"
	description = "Glicerol to prosty związek z grupy polioli. Ma słodki smak i niską toksyczność."
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "słodycz"

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	description = "Odkaża rany przed operacją."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "gorycz"

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.speed_modifier = max(0.2, S.speed_modifier)
			// +20% surgery speed on each step, useful while operating in less-than-perfect conditions
	..()

/datum/reagent/iron
	name = "Iron"
	description = "Czyste żelazo to metal."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_BASIC_ELEMENT
	reagent_state = SOLID
	taste_description = "żelazo"


/datum/reagent/iron/on_mob_life(mob/living/carbon/C)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.5
	..()

/datum/reagent/iron/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_IRON)) //If the target is weak to cold iron, then poison them.
		if(holder && holder.chem_temp < 100) // COLD iron.
			M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/gold
	name = "Gold"
	description = "Złoto to gęsty, miękki, błyszczący metal, najbardziej plastyczny i ciągliwy ze znanych metali."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "drogi metal"

/datum/reagent/silver
	name = "Silver"
	description = "Miękki, biały, lśniący metal przejściowy o najwyższej przewodności elektrycznej spośród pierwiastków i najwyższej przewodności cieplnej spośród metali."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "drogi, ale rozsądny metal"

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_SILVER))
		M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/uranium
	name ="Uranium"
	description = "Srebrzystobiały metaliczny pierwiastek z grupy aktynowców, słabo radioaktywny."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "wnętrze reaktora"
	var/irradiation_level = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/uranium/on_mob_life(mob/living/carbon/M)
	M.apply_effect(irradiation_level/M.metabolism_efficiency,EFFECT_IRRADIATE,0)
	..()

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			if(!QDELETED(GG))
				GG.reagents.add_reagent(type, reac_volume)

/datum/reagent/uranium/radium
	name = "Radium"
	description = "Rad to metal ziem alkalicznych. Jest skrajnie radioaktywny."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "kolor niebieski i żal"
	irradiation_level = 2*REM
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "Pył z mikroskopijnych kryształów bluespace o lekkich właściwościach zakrzywiających przestrzeń."
	reagent_state = SOLID
	color = "#0000CC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "syczący błękit"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/bluespace/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		do_teleport(M, get_turf(M), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //4 tiles per crystal
	..()

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/M)
	if(current_cycle > 10 && prob(15))
		to_chat(M, "<span class='warning'>Czujesz się niestabilnie...</span>")
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 30)
	..()

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/aluminium
	name = "Aluminium"
	description = "Srebrzystobiały, ciągliwy pierwiastek z grupy borowców."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"


/datum/reagent/silicon
	name = "Silicon"
	description = "Czterowartościowy półmetal; krzem jest mniej reaktywny niż jego chemiczny odpowiednik, węgiel."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/fuel
	name = "Welding Fuel"
	description = "Potrzebne do spawarek. Łatwopalne."
	color = "#660000" // rgb: 102, 0, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "obrzydliwy metal"
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Jeśli nie jesteś narzędziem przemysłowym, to raczej nie nadaje się do spożycia."
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	description = "Związek do czyszczenia. Teraz z 50% więcej podchlorynu sodu! Nie nadaje się do spożycia. W razie połknięcia natychmiast skontaktuj się z ośrodkiem toksykologicznym"
	color = "#A5F0EE" // rgb: 165, 240, 238
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "kwaśność"
	reagent_weight = 0.6 //so it sprays further
	var/toxic = FALSE //turn to true if someone drinks this, so it won't poison people who are simply getting sprayed down

/datum/reagent/space_cleaner/on_mob_life(mob/living/carbon/M)
	if(toxic)//don't drink space cleaner, dumbass
		M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1)
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		SEND_SIGNAL(T, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.adjust_hygiene((30 * reac_volume) / (3 + reac_volume)) //NSV13 - kept hygiene
				if(H.lip_style)
					H.lip_style = null
					H.update_body()
			for(var/obj/item/I in C.held_items)
				SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			if(C.wear_mask)
				if(SEND_SIGNAL(C.wear_mask, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
					C.update_inv_wear_mask()
			if(ishuman(M))
				var/mob/living/carbon/human/H = C
				if(H.head)
					if(SEND_SIGNAL(H.head, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_head()
				if(H.wear_suit)
					if(SEND_SIGNAL(H.wear_suit, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					if(SEND_SIGNAL(H.w_uniform, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_w_uniform()
				if(H.shoes)
					if(SEND_SIGNAL(H.shoes, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_shoes()
				H.wash_cream()
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else if(method == INGEST || method == INJECT) //why the fuck did you drink space cleaner you fucking buffoon
		toxic = TRUE

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "Silny, kwaśny środek czyszczący sprzedawany przez Waffle Co. Działa na materię organiczną, nie naruszając innych przedmiotów."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "kwas"

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(3.33)
	M.adjustFireLoss(3.33)
	M.adjustToxLoss(3.33)
	..()

/datum/reagent/space_cleaner/ez_clean/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	..()
	if((method == TOUCH || method == VAPOR) && !issilicon(M))
		M.adjustBruteLoss(1.5)
		M.adjustFireLoss(1.5)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Kryptobiolina powoduje dezorientację i zawroty głowy."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "kwaśność"

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/M)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezen to narkotyk upośledzający sprawność przez spowolnienie wyższych funkcji komórek mózgowych."
	color = "#C8A5DC" // rgb: 200, 165, 220A
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "drętwienie"

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	..()

/datum/reagent/nanomachines
	name = "Nanomachines"
	description = "Mikroskopijne roboty budowlane."
	color = "#535E66" // rgb: 83, 94, 102
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "breja"

/datum/reagent/nanomachines/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Mikroby o zupełnie obcej budowie komórkowej."
	color = "#535E66" // rgb: 83, 94, 102
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "breja"

/datum/reagent/xenomicrobes/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/xeno(), FALSE, TRUE)

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	description = "Aktywne zarodniki grzybów."
	color = "#92D17D" // rgb: 146, 209, 125
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "szlam"


/datum/reagent/fungalspores/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/snail
	name = "Agent-S"
	description = "Czynnik wirusologiczny zarażający gastrolozą."
	color = "#003300" // rgb(0, 51, 0)
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "maź"

/datum/reagent/snail/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/gastrolosis(), FALSE, TRUE)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	description = "Perfluorowany kwas sulfonowy, który po zmieszaniu z wodą tworzy pianę."
	color = "#9E6B38" // rgb: 158, 107, 56
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	description = "Środek, który po zmieszaniu z lekkim metalem i silnym kwasem daje metaliczną pianę."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/smart_foaming_agent //Smart foaming agent. Functions similarly to metal foam, but conforms to walls.
	name = "Smart foaming agent"
	description = "Środek, który po zmieszaniu z lekkim metalem i silnym kwasem daje metaliczną pianę dopasowującą się do granic obszaru."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/ammonia
	name = "Ammonia"
	description = "Żrąca substancja powszechnie używana w nawozach i domowych środkach czystości."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	chem_flags = NONE
	taste_description = "zaprawa"

/datum/reagent/diethylamine
	name = "Diethylamine"
	description = "Amina drugorzędowa, lekko żrąca."
	color = "#604030" // rgb: 96, 64, 48
	chem_flags = NONE
	taste_description = "żelazo"

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	reagent_state = GAS
	description = "Gaz powszechnie powstający przy spalaniu paliw węglowych. Twoje płuca ciągle go wytwarzają."
	color = "#B0B0B0" // rgb : 192, 192, 192
	chem_flags = NONE
	taste_description = "coś niepoznawalnego"

/datum/reagent/carbondioxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")

/datum/reagent/carbondioxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")
	return

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	description = "Silny utleniacz używany jako paliwo rakietowe i jako środek znieczulający podczas operacji."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	chem_flags = NONE
	taste_description = "słodycz"

/datum/reagent/nitrous_oxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		M.drowsyness += max(round(reac_volume, 1), 2)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/M)
	M.drowsyness += 2
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - 10, 0)
	if(prob(20))
		M.losebreath += 2
		M.confused = min(M.confused + 2, 5)
	..()

/datum/reagent/stimulum
	name = "Stimulum"
	description = "Niestabilny eksperymentalny gaz, który znacznie zwiększa energię wdychających, ale powoduje też niedotlenienie."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because stimulum/nitryl are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "#E1A116"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "kwaśność"
	///stores whether or not the mob has been warned that they are having difficulty breathing.
	var/warned = FALSE

/datum/reagent/stimulum/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	L.visible_message("<span class='warning'>Masz wrażenie, że nic cię nie powstrzyma!</span>")

/datum/reagent/stimulum/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	L.visible_message("<span class='warning'>Czujesz, jak twój krótki haj mija</span>")
	..()

/datum/reagent/stimulum/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(-2*REM, 0)
	if(M.losebreath <= 10)
		M.losebreath += min(current_cycle*0.05, 2) // gradually builds up suffocation, will not be noticable for several ticks but effects will linger afterwards
	if(M.losebreath > 2 && !warned)
		M.visible_message("<span class='danger'>Masz wrażenie, że nie możesz oddychać!</span>")
		warned = TRUE
	..()

/datum/reagent/nitryl
	name = "Nitryl"
	description = "Wysoce reaktywny gaz, po którym czujesz się szybszy."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because stimulum/nitryl are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "#90560B"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "pieczenie"

/datum/reagent/nitryl/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/nitryl/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/////////////////////////Colorful Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents

/datum/reagent/colorful_reagent/powder
	name = "Mundane Powder" //the name's a bit similar to the name of colorful reagent, but hey, they're practically the same chem anyway
	var/colorname = "none"
	description = "Proszek do barwienia rzeczy."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "tył klasy"

/datum/reagent/colorful_reagent/powder/New()
	if(colorname == "none")
		description = "Dość zwyczajnie wyglądający proszek. Nie wygląda na to, by cokolwiek nim zabarwić."
	else if(colorname == "invisible")
		description = "Niewidzialny proszek. Niestety, skoro jest niewidzialny, raczej niczego nim nie zabarwisz."
	else
		description = "Proszek ([colorname]) do barwienia rzeczy na kolor: [colorname]."

/datum/reagent/colorful_reagent/powder/red
	name = "Red Powder"
	colorname = "red"
	color = "#DA0000" // red
	random_color_list = list("#FC7474")

/datum/reagent/colorful_reagent/powder/orange
	name = "Orange Powder"
	colorname = "orange"
	color = "#FF9300" // orange
	random_color_list = list("#FF9300")

/datum/reagent/colorful_reagent/powder/yellow
	name = "Yellow Powder"
	colorname = "yellow"
	color = "#FFF200" // yellow
	random_color_list = list("#FFF200")

/datum/reagent/colorful_reagent/powder/green
	name = "Green Powder"
	colorname = "green"
	color = "#A8E61D" // green
	random_color_list = list("#A8E61D")

/datum/reagent/colorful_reagent/powder/blue
	name = "Blue Powder"
	colorname = "blue"
	color = "#00B7EF" // blue
	random_color_list = list("#00B7EF")

/datum/reagent/colorful_reagent/powder/purple
	name = "Purple Powder"
	colorname = "purple"
	color = "#DA00FF" // purple
	random_color_list = list("#BD8FC4")

/datum/reagent/colorful_reagent/powder/invisible
	name = "Invisible Powder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list(null)	//because using the powder color turns things invisible

/datum/reagent/colorful_reagent/powder/black
	name = "Black Powder"
	colorname = "black"
	color = "#1C1C1C" // not quite black
	random_color_list = list("#404040")

/datum/reagent/colorful_reagent/powder/white
	name = "White Powder"
	colorname = "white"
	color = "#FFFFFF" // white
	random_color_list = list("#FFFFFF") //doesn't actually change appearance at all

 /* used by crayons, can't color living things but still used for stuff like food recipes */

/datum/reagent/colorful_reagent/powder/red/crayon
	name = "Red Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/orange/crayon
	name = "Orange Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/yellow/crayon
	name = "Yellow Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/green/crayon
	name = "Green Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/blue/crayon
	name = "Blue Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/purple/crayon
	name = "Purple Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

//datum/reagent/colorful_reagent/powder/invisible/crayon

/datum/reagent/colorful_reagent/powder/black/crayon
	name = "Black Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/white/crayon
	name = "White Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	description = "Jakaś pożywka. Nie da się stwierdzić, co to jest. Lepiej to zgłoś, razem z tym, jak to zdobyłeś."
	color = "#000000" // RBG: 0, 0, 0
	chem_flags = CHEMICAL_NOT_DEFINED // this shouldn't exist
	var/tox_prob = 0
	taste_description = "nawóz"

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM, 0)
		. = 1
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	description = "Tani i niezwykle powszechny rodzaj nawozu."
	color = "#376400" // RBG: 50, 100, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 10

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Niestabilny nawóz, przez który rośliny mutują częściej niż zwykle."
	color = "#1A1E4D" // RBG: 26, 30, 77
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 25

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Bardzo silny nawóz, który zapobiega mutacjom roślin."
	color = "#9D9D00" // RBG: 157, 157, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 15







// GOON OTHERS



/datum/reagent/oil
	name = "Oil"
	description = "Pali się małym, dymiącym ogniem, używany głównie do pozyskiwania popiołu."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "olej"
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Niepalna plazma zamknięta w postaci ciekłej, która nie może się zapalić ani przejść w stan gazowy czy stały."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "gorycz"
	taste_mult = 1.5
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C)
	C.adjustPlasma(10)
	..()

/datum/reagent/iodine
	name = "Iodine"
	description = "Powszechnie dodawany do soli kuchennej jako składnik odżywczy. Sam w sobie smakuje o wiele mniej przyjemnie."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"


/datum/reagent/carpet
	name = "Carpet"
	description = "Dla tych, którzy potrzebują bardziej kreatywnego sposobu na rozwinięcie czerwonego dywanu."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_GOAL_BARTENDER_SERVING // this is lame one to put random. at least good as bartender flavor.
	taste_description = "dywan" // Your tounge feels furry.

/datum/reagent/carpet/reaction_turf(turf/T, reac_volume)
	if(isplatingturf(T) || istype(T, /turf/open/floor/plasteel))
		var/turf/open/floor/F = T
		F.PlaceOnTop(/turf/open/floor/carpet, flags = CHANGETURF_INHERIT_AIR)
	..()

/datum/reagent/bromine
	name = "Bromine"
	description = "Brązowawy, wysoce reaktywny płyn. Przydatny do zatrzymywania wolnych rodników, ale nie jest przeznaczony do spożycia przez ludzi."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "chemikalia"

/datum/reagent/phenol
	name = "Phenol"
	description = "Aromatyczny pierścień węglowy z grupą hydroksylową. Przydatny prekursor niektórych leków, ale sam nie ma właściwości leczniczych."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "kwas"

/datum/reagent/ash
	name = "Ash"
	description = "Podobno z tego powstają feniksy, ale nigdy tego nie widziałeś."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "popiół"

/datum/reagent/acetone
	name = "Acetone"
	description = "Śliski płyn o właściwościach rakotwórczych. Ma mnóstwo przyziemnych zastosowań w codziennym życiu."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "kwas"

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Dokładnie spróbuj tęczy."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "tęcze"
	var/can_colour_mobs = TRUE


/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/M)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Ma dużą szansę sprawić, że będziesz wyglądać jak szalony naukowiec."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	var/list/potential_colors = list("#0ad","#a0f","#f73","#d14","#d14","#0b5","#0ad","#f73","#fc2","#084","#05e","#d22","#fa0") // fucking hair code
	taste_description = "kwaśność"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_color = pick(potential_colors)
			H.facial_hair_color = pick(potential_colors)
			H.update_hair()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	description = "Rozwiązanie problemu łysienia na całym świecie."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "kwaśność"

/datum/reagent/barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hair_styles_list)
			H.hair_style = picked_hair
			H.facial_hair_style = picked_beard
			H.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "Skoncentrowane rozwiązanie problemu łysienia na całym świecie."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "kwaśność"

/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Beard (Very Long)"
			H.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "Dość nieszkodliwa substancja, która może zwiększyć moc różnych gatunków roślin."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "chłodna sól"


/datum/reagent/lye
	name = "Lye"
	description = "Znany też jako wodorotlenek sodu. Jako zawód robienie tego jest dość rozczarowujące."
	reagent_state = LIQUID
	chem_flags = NONE
	color = "#FFFFD6" // very very light yellow
	taste_description = "kwas"


/datum/reagent/drying_agent
	name = "Drying agent"
	description = "Środek osuszający. Można nim suszyć rzeczy."
	reagent_state = LIQUID
	color = "#A70FFF"
	chem_flags = NONE
	taste_description = "suchość"


/datum/reagent/drying_agent/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.MakeDry(ALL, TRUE, reac_volume * 5 SECONDS)		//50 deciseconds per unit

/datum/reagent/drying_agent/reaction_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)

// Virology virus food chems.

/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "Mutagenic Agar"
	color = "#A3C00F" // rgb: 163,192,15
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "kwaśność"

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "Sucrose Agar"
	color = "#41B0C0" // rgb: 65,176,192
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "słodycz"

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "Virus Rations"
	color = "#D18AA5" // rgb: 209,138,165
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "gorycz"

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "Virus Plasma"
	color = "#A69DA9" // rgb: 166,157,169
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "gorycz"
	taste_mult = 1.5

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "Weakened Virus Plasma"
	color = "#CEC3C6" // rgb: 206,195,198
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "gorycz"
	taste_mult = 1.5

/datum/reagent/uranium/uraniumvirusfood
	name = "Decaying Uranium Gel"
	color = "#67ADBA" // rgb: 103,173,186
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "wnętrze reaktora"

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "Unstable Uranium Gel"
	color = "#2FF2CB" // rgb: 47,242,203
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "wnętrze reaktora"

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "Stable Uranium Gel"
	color = "#04506C" // rgb: 4,80,108
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "wnętrze reaktora"

/datum/reagent/consumable/laughter/laughtervirusfood
	name = "Anomolous Virus Food"
	color = "#ffa6ff" //rgb: 255,166,255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "zły pomysł"

/datum/reagent/consumable/virus_food/advvirusfood
	name = "Highly Unstable Virus Food"
	color = "#ffffff" //rgb: 255,255,255 ITS PURE WHITE CMON
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "SKRAJNIE zły pomysł"

/datum/reagent/consumable/virus_food/viralbase
	name = "Experimental Viral Base"
	description = "Niedawno odkryta przez najlepszych naukowców Nanotrasen po latach badań; po wystawieniu na uran ta substancja może posłużyć jako baza dla niezwykle rzadkich i niezwykle niebezpiecznych wirusów."
	color = "#fff0da"
	chem_flags = CHEMICAL_NOT_SYNTH
	taste_description = "łzy naukowców"

// Bee chemicals

/datum/reagent/royal_bee_jelly
	name = "Royal Bee Jelly"
	description = "Królewskie mleczko pszczele; wstrzyknięte kosmicznej królowej pszczół sprawia, że dzieli się ona na dwie pszczoły."
	color = "#00ff80"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "dziwny miód"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "królewskie mleczko pszczele")
	..()

//Misc reagents

/datum/reagent/romerol
	name = "Romerol"
	// the REAL zombie powder
	description = "Romerol to wysoce eksperymentalny środek bioterrorystyczny, który wytrawia w istocie szarej uśpione guzki. Guzki aktywują się dopiero po śmierci nosiciela, gdy struktury wtórne się uaktywniają i przejmują kontrolę nad jego ciałem."
	color = "#123524" // RGB (18, 53, 36)
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN // romerol zombie outbreak from a maint pill? how can this go not fun.
	metabolization_rate = INFINITY
	taste_description = "mózg"

/datum/reagent/romerol/reaction_mob(mob/living/carbon/human/H, method=TOUCH, reac_volume)
	// Silently add the zombie infection organ to be activated upon death
	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(H)
	..()

/datum/reagent/magillitis
	name = "Magillitis"
	description = "Eksperymentalne serum wywołujące szybki wzrost mięśni u człowiekowatych. Skutki uboczne mogą obejmować nadmierne owłosienie, napady agresji i niekończące się zamiłowanie do bananów."
	reagent_state = LIQUID
	color = "#00f041"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/M)
	..()
	if((ismonkey(M) || ishuman(M)) && current_cycle >= 10)
		M.gorillize()

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "Komercyjna substancja stworzona, by pomagać starszym panom w sypialni."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	var/current_size = RESIZE_DEFAULT_SIZE
	taste_description = "gorycz" // apparently what viagra tastes like

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25*RESIZE_DEFAULT_SIZE
		if(20 to 49)
			newsize = 1.5*RESIZE_DEFAULT_SIZE
		if(50 to 99)
			newsize = 2*RESIZE_DEFAULT_SIZE
		if(100 to 199)
			newsize = 2.5*RESIZE_DEFAULT_SIZE
		if(200 to INFINITY)
			newsize = 3.5*RESIZE_DEFAULT_SIZE

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

/datum/reagent/plastic_polymers
	name = "Plastic Polymers"
	description = "Ropopochodne składniki plastiku."
	color = "#f7eded"
	chem_flags = NONE
	taste_description = "plastik"

/datum/reagent/glitter
	name = "Generic Glitter"
	description = "Jeśli widzisz ten opis, skontaktuj się z koderem."
	color = "#FFFFFF" //pure white
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	taste_description = "plastik"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter

/datum/reagent/glitter/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	new glitter_type(T)

/datum/reagent/glitter/pink
	name = "Pink Glitter"
	description = "Różowe brokaty, które dostają się wszędzie."
	color = "#ff8080" //A light pink color
	glitter_type = /obj/effect/decal/cleanable/glitter/pink

/datum/reagent/glitter/white
	name = "White Glitter"
	description = "Białe brokaty, które dostają się wszędzie."
	glitter_type = /obj/effect/decal/cleanable/glitter/white

/datum/reagent/glitter/blue
	name = "Blue Glitter"
	description = "Niebieskie brokaty, które dostają się wszędzie."
	color = "#4040FF" //A blueish color
	glitter_type = /obj/effect/decal/cleanable/glitter/blue

/datum/reagent/pax
	name = "Pax"
	description = "Bezbarwny płyn, który tłumi u przyjmujących agresywne popędy."
	color = "#AAAAAA55"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "woda"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/pax/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/pax/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/bz_metabolites
	name = "BZ metabolites"
	description = "Nieszkodliwy metabolit gazu BZ."
	color = "#FAFF00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // botany can't spam this. lings will have this disaster from scrub or maint pill.
	taste_description = "cierpki cynamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM

/datum/reagent/bz_metabolites/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
	return ..()

/datum/reagent/pax/peaceborg
	name = "Synthpax"
	description = "Bezbarwny płyn, który tłumi u przyjmujących agresywne popędy. Tańszy w syntezie niż zwykły Pax, ale szybciej przestaje działać."
	chem_flags = NONE
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/peaceborg
	chem_flags = CHEMICAL_NOT_DEFINED

/datum/reagent/peaceborg/confuse
	name = "Dizzying Solution"
	description = "Wytrąca cel z równowagi i przyprawia o zawroty głowy."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "zawroty głowy"

/datum/reagent/peaceborg/confuse/on_mob_life(mob/living/carbon/M)
	if(M.confused < 6)
		M.confused = CLAMP(M.confused + 3, 0, 5)
	if(M.dizziness < 6)
		M.dizziness = CLAMP(M.dizziness + 3, 0, 5)
	if(prob(20))
		to_chat(M, "Czujesz się zdezorientowany.")
	..()

/datum/reagent/peaceborg/inabizine
	name = "Inabizine"
	description = "Wywołuje rozluźnienie mięśni, przez co trudno trzymać przedmioty i stać."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "relaks"

/datum/reagent/peaceborg/inabizine/on_mob_life(mob/living/carbon/M)
	if(prob(33))
		M.Stun(20, 0)
		M.blur_eyes(5)
	if(prob(33))
		M.Knockdown(2 SECONDS)
	if(prob(20))
		to_chat(M, "Twoje mięśnie się rozluźniają...")
	..()

/datum/reagent/peaceborg/tire
	name = "Tiring Solution"
	description = "Bardzo łagodna toksyna wytrzymałości, która męczy cel. Całkowicie nieszkodliwa."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "zmęczenie"

/datum/reagent/peaceborg/tire/on_mob_life(mob/living/carbon/M)
	var/healthcomp = (100 - M.health)	//DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	if(M.getStaminaLoss() < (45 - healthcomp))	//At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		M.adjustStaminaLoss(10)
	if(prob(30))
		to_chat(M, "Powinieneś usiąść i odpocząć...")
	..()

/datum/reagent/tranquility
	name = "Tranquility"
	description = "Wysoce mutagenny płyn nieznanego pochodzenia."
	color = "#9A6750" //RGB: 154, 103, 80
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "wewnętrzny spokój"

/datum/reagent/tranquility/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)

/datum/reagent/liquidadamantine
	name = "Liquid Adamantine"
	description = "Upłynniony legendarny, życiodajny metal."
	color = "#10cca6" //RGB: 16, 204, 166
	chem_flags = CHEMICAL_NOT_SYNTH
	taste_description = "życiodajny metal"

/datum/reagent/spider_extract
	name = "Spider Extract"
	description = "Wysoce specjalistyczny wyciąg z sektora Australicus, używany do tworzenia pajęczych matek."
	color = "#ED2939"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "do góry nogami"

// unholy water, but for heretics.
// why couldn't they have both just used the same reagent?
// who knows.
// maybe nar'sie is considered to be too "mainstream" of a god to worship in the heretic community.
/datum/reagent/eldritch
	name = "Eldritch Essence"
	description = "Dziwny płyn, który przeczy prawom fizyki. Dodaje energii i leczy tych, którzy widzą poza tę kruchą rzeczywistość, ale jest niesamowicie szkodliwy dla ludzi o zamkniętych umysłach. Metabolizuje się bardzo szybko."
	taste_description = "Ag'hsj'saje'sh"
	color = "#1f8016"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //1u/tick

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/M)
	if(IS_HERETIC(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-10, FALSE)
		M.adjustToxLoss(-2, FALSE)
		M.adjustOxyLoss(-2, FALSE)
		M.adjustBruteLoss(-2, FALSE)
		M.adjustFireLoss(-2, FALSE)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, FALSE)
		M.adjustFireLoss(2, FALSE)
		M.adjustOxyLoss(2, FALSE)
		M.adjustBruteLoss(2, FALSE)
	..()
	return TRUE

/datum/reagent/consumable/ratlight
	name = "Ratvarian Light"
	description = "Specjalna mikstura, podobno pobłogosławiona przez pradawnego boga. Sprawia, że pijący świeci dosłownym oświeceniem."
	color = "#B5A642"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "oświecenie"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	var/datum/language_holder/prev_language

/datum/reagent/consumable/ratlight/reaction_mob(mob/living/M)
	M.set_light(2)
	..()

/datum/reagent/consumable/ratlight/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		playsound(M, "scripture_tier_up", 50, 1)
	..()

/datum/reagent/consumable/ratlight/on_mob_metabolize(mob/living/L)
	L.add_blocked_language(subtypesof(/datum/language/) - /datum/language/ratvar, LANGUAGE_REAGENT)
	L.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_REAGENT)
	..()

/datum/reagent/consumable/ratlight/on_mob_end_metabolize(mob/living/L)
	L.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_REAGENT)
	L.remove_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_REAGENT)
	L.set_light(-1)

	..()

/datum/reagent/helgrasp
	name = "Helgrasp"
	description = "Uważa się, że ta rzadka i zakazana mikstura przybliża cię do uścisku nordyckiej bogini Hel."
	metabolization_rate = 1*REM //This is fast
	//Compensates for delta_time lag by spawning multiple hands at the end
	var/lag_remainder = 0
	//Keeps track of the hand timer so we can cleanup on removal
	var/list/timer_ids

//Warns you about the impending hands
/datum/reagent/helgrasp/on_mob_add(mob/living/L, amount)
	to_chat(L, "<span class='hierophant'>Słyszysz śmiech, gdy przed tobą materializują się złowrogie dłonie, chętne, by ściągnąć cię do piekła...! Uważaj!</span>")
	playsound(L.loc, 'sound/misc/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready
	. = ..()

//Sends hands after you for your hubris
/*
How it works:
Standard delta_time for a reagent is 2s - and volume consumption is equal to the volume * delta_time.
In this chem, I want to consume 0.5u for 1 hand created (since 1*REM is 0.5) so on a single tick I create a hand and set up a callback for another one in 1s from now. But since delta time can vary, I want to be able to create more hands for when the delay is longer.
Initally I round delta_time to the nearest whole number, and take the part that I am rounding down from (i.e. the decimal numbers) and keep track of them. If the decimilised numbers go over 1, then the number is reduced down and an extra hand is created that tick.
Then I attempt to calculate the how many hands to created based off the current delta_time, since I can't know the delay to the next one it assumes the next will be in 2s.
I take the 2s interval period and divide it by the number of hands I want to make (i.e. the current delta_time) and I keep track of how many hands I'm creating (since I always create one on a tick, then I start at 1 hand). For each hand I then use this time value multiplied by the number of hands. Since we're spawning one now, and it checks to see if hands is less than, but not less than or equal to, delta_time, no hands will be created on the next expected tick.
Basically, we fill the time between now and 2s from now with hands based off the current lag.
*/
/datum/reagent/helgrasp/on_mob_life(mob/living/carbon/owner, delta_time = 2, times_fired)
	spawn_hands(owner)
	lag_remainder += delta_time - FLOOR(delta_time, 1)
	delta_time = FLOOR(delta_time, 1)
	if(lag_remainder >= 1)
		delta_time += 1
		lag_remainder -= 1
	var/hands = 1
	var/time = 2 / delta_time
	while(hands < delta_time) //we already made a hand now so start from 1
		LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), owner), (time*hands) SECONDS, TIMER_STOPPABLE)) //keep track of all the timers we set up
		hands += time
	return ..()

/datum/reagent/helgrasp/proc/spawn_hands(mob/living/carbon/owner)
	if(!owner && iscarbon(holder.my_atom))//Catch timer
		owner = holder.my_atom
	//Adapted from the end of the curse - but lasts a short time
	var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 8)//Larger range so you have more time to dodge
	if(!spawn_turf)
		return
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/item/projectile/curse_hand/hel/hand = new (spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	if(QDELETED(hand)) //safety check if above fails - above has a stack trace if it does fail
		return
	hand.fire()

//At the end, we clear up any loose hanging timers just in case and spawn any remaining lag_remaining hands all at once.
/datum/reagent/helgrasp/on_mob_delete(mob/living/owner)
	var/hands = 0
	while(lag_remainder > hands)
		spawn_hands(owner)
		hands++
	for(var/id in timer_ids) // So that we can be certain that all timers are deleted at the end.
		deltimer(id)
	timer_ids.Cut()
	return ..()

/datum/reagent/helgrasp/heretic
	name = "Grasp of the Mansus"
	description = "Dłoń Mansusa jest na twojej szyi."
	metabolization_rate = 1 * REM

/datum/reagent/ants
	name = "Ants"
	description = "Próbka zaginionej rasy kosmicznych mrówek (formicidae bastardium tyrannus), słynących z niszczenia w chuj wszystkiego, co napotkają."
	reagent_state = SOLID
	color = "#993333"
	taste_mult = 1.3
	taste_description = "maleńkie nóżki przebierające w dół gardła."
	metabolization_rate = 5 * REAGENTS_METABOLISM //1u per second
	glass_name = "glass of ants"
	glass_desc = "Do dna...?"
	/// How much damage the ants are going to be doing (rises with each tick the ants are in someone's body)
	var/ant_damage = 0
	/// Tells the debuff how many ants we are being covered with.
	var/amount_left = 0
	/// List of possible common statements to scream when eating ants
	var/static/list/ant_screams = list(
		"SĄ POD MOJĄ SKÓRĄ!!",
		"WYJMIJCIE JE ZE MNIE!!",
		"O CHOLERA, ONE PALĄ!!",
		"MÓJ BOŻE, SĄ WE MNIE!!",
		"WYJMIJCIE JE!!"
		)

/datum/reagent/ants/on_mob_life(mob/living/carbon/victim, delta_time)
	ant_damage++
	if(ant_damage < 5) // Makes ant food a little more appetizing, since you won't be screaming as much.
		return ..()
	if(DT_PROB(5, delta_time))
		if(DT_PROB(5, delta_time)) //Super rare statement
			victim.say("AAA NIE, TYLKO NIE MRÓWKI! TYLKO NIE MRÓWKI! AAAAAA SĄ W MOICH OCZACH! MOICH OCZACH! AAAA!!", forced = /datum/reagent/ants)
		else
			victim.say(pick(ant_screams), forced = /datum/reagent/ants)
	if(DT_PROB(15, delta_time))
		victim.emote("scream")
	if(DT_PROB(2, delta_time)) // Stuns, but purges ants.
		victim.vomit(rand(5,10), FALSE, TRUE, 1, TRUE, FALSE)
	return ..()

/datum/reagent/ants/on_mob_end_metabolize(mob/living/living_anthill)
	ant_damage = 0
	to_chat(living_anthill, "<span class='notice'>Masz wrażenie, że ostatnie mrówki opuściły twój organizm.</span>")
	return ..()

/datum/reagent/ants/reaction_mob(mob/living/exposed_mob, method=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob) || method == INGEST || method == INJECT) //NSV13 - the original "(method == INGEST||INJECT)" was always true
		return
	if(method == PATCH || method == TOUCH || method == VAPOR)
		amount_left = round(reac_volume,0.1)
		exposed_mob.apply_status_effect(STATUS_EFFECT_ANTS, amount_left)

/datum/reagent/ants/reaction_obj(obj/exposed_obj, reac_volume)
	. = ..()
	var/turf/open/my_turf = exposed_obj.loc // No dumping ants on an object in a storage slot
	if(!istype(my_turf)) //Are we actually in an open turf?
		return
	var/static/list/accepted_types = typecacheof(list(/obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/disposalpipe))
	if(!accepted_types[exposed_obj.type]) // Bypasses pipes, vents, and cables to let people create ant mounds on top easily.
		return
	reaction_turf(my_turf, reac_volume)

/datum/reagent/ants/reaction_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf) || isspaceturf(exposed_turf)) // Is the turf valid
		return
	if((reac_volume <= 10)) // Makes sure people don't duplicate ants.
		return

	var/obj/effect/decal/cleanable/ants/pests = locate() in exposed_turf.contents
	if(!pests)
		pests = new(exposed_turf)
	var/spilled_ants = (round(reac_volume,1) - 5) // To account for ant decals giving 3-5 ants on initialize.
	pests.reagents.add_reagent(/datum/reagent/ants, spilled_ants)
	pests.update_ant_damage()
