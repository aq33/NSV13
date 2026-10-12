#define BLOOD_THRESHOLD 3 //How many souls are needed per stage.
#define TRUE_THRESHOLD 7
#define ARCH_THRESHOLD 12

#define BASIC_DEVIL 0
#define BLOOD_LIZARD 1
#define TRUE_DEVIL 2
#define ARCH_DEVIL 3

#define LOSS_PER_DEATH 2

#define SOULVALUE soulsOwned.len-reviveNumber

#define DEVILRESURRECTTIME 600

GLOBAL_LIST_EMPTY(allDevils)
GLOBAL_LIST_INIT(lawlorify, list (
		/*LORE = */list(
			OBLIGATION_FOOD = "Ten diabeł zawsze częstuje swoje ofiary jedzeniem, zanim je zarżnie.",
			OBLIGATION_FIDDLE = "Ten diabeł nigdy nie odmówi muzycznego wyzwania.",
			OBLIGATION_DANCEOFF = "Ten diabeł nigdy nie odmówi pojedynku tanecznego.",
			OBLIGATION_GREET = "Ten diabeł zdaje się rozmawiać tylko z ludźmi, których imię zna.",
			OBLIGATION_PRESENCEKNOWN = "Ten diabeł zdaje się nie potrafić atakować z ukrycia.",
			OBLIGATION_SAYNAME = "Po zabiciu kogoś zawsze wykrzykuje swoje imię.",
			OBLIGATION_ANNOUNCEKILL = "Ten diabeł zawsze głośno ogłasza swoje zabójstwa całemu światu.",
			OBLIGATION_ANSWERTONAME = "Ten diabeł zawsze odpowiada na swoje prawdziwe imię.",
			BANE_SILVER = "Srebro zdaje się poważnie ranić tego diabła.",
			BANE_SALT = "Rzucenie w tego diabła solą tymczasowo utrudni mu używanie piekielnych mocy.",
			BANE_LIGHT = "Jasne błyski zdezorientują diabła i pewnie sprawią, że ucieknie.",
			BANE_IRON = "Zimne żelazo będzie go powoli ranić, dopóki nie usunie go ze swojego organizmu.",
			BANE_WHITECLOTHES = "Noszenie czystych, białych ubrań pomoże odstraszyć tego diabła.",
			BANE_HARVEST = "Pokazanie owoców żniw zakłóci działanie diabła.",
			BANE_TOOLBOX = "To, co kryje w sobie środki tworzenia, kryje też środki zguby diabła.",
			BAN_HURTWOMAN = "Ten diabeł zdaje się wolić polować na mężczyzn.",
			BAN_CHAPEL = "Ten diabeł unika poświęconej ziemi.",
			BAN_HURTPRIEST = "Namaszczone duchowieństwo zdaje się być odporne na jego moce.",
			BAN_AVOIDWATER = "Diabeł zdaje się mieć jakąś awersję do wody, choć ta mu nie szkodzi.",
			BAN_STRIKEUNCONSCIOUS = "Ten diabeł interesuje się tylko tymi, którzy nie śpią.",
			BAN_HURTLIZARD = "Ten diabeł nie zaatakuje pierwszy jaszczuroczłeka.",
			BAN_HURTANIMAL = "Ten diabeł unika krzywdzenia zwierząt.",
			BANISH_WATER = "Aby wygnać diabła, musisz nasycić jego ciało wodą święconą.",
			BANISH_COFFIN = "Ten diabeł wróci do życia, jeśli jego szczątki nie zostaną złożone w trumnie.",
			BANISH_FORMALDYHIDE = "Aby wygnać diabła, musisz wstrzyknąć jego martwemu ciału płyn do balsamowania.",
			BANISH_RUNES = "Ten diabeł zmartwychwstanie po śmierci, chyba że jego szczątki będą na runie.",
			BANISH_CANDLES = "Duża liczba zapalonych świec w pobliżu uniemożliwi mu zmartwychwstanie.",
			BANISH_DESTRUCTION = "Aby zapobiec zmartwychwstaniu, jego zwłoki muszą zostać doszczętnie zniszczone.",
			BANISH_FUNERAL_GARB = "Ubrany w szaty pogrzebowe, ten diabeł nie będzie mógł zmartwychwstać. Jeśli ubrania nie pasują, połóż je delikatnie na zwłokach diabła."
		),
		/*LAW = */list(
			OBLIGATION_FOOD = "Jeśli nie działasz w samoobronie, zawsze musisz poczęstować ofiarę jedzeniem, zanim zrobisz jej krzywdę.",
			OBLIGATION_FIDDLE = "Jeśli nie grozi ci bezpośrednie niebezpieczeństwo, a ktoś wyzwie cię na pojedynek muzyczny, musisz go przyjąć. Nie musisz pojedynkować się dwa razy z tą samą osobą.",
			OBLIGATION_DANCEOFF = "Jeśli nie grozi ci bezpośrednie niebezpieczeństwo, a ktoś wyzwie cię na pojedynek taneczny, musisz go przyjąć. Nie musisz mierzyć się dwa razy z tą samą osobą.",
			OBLIGATION_GREET = "Zanim z kimś porozmawiasz, zawsze musisz przywitać go po nazwisku.",
			OBLIGATION_PRESENCEKNOWN = "Przed atakiem zawsze musisz ujawnić swoją obecność.",
			OBLIGATION_SAYNAME = "Po zabiciu kogoś zawsze musisz wypowiedzieć swoje prawdziwe imię.",
			OBLIGATION_ANNOUNCEKILL = "Po zabiciu kogoś musisz ogłosić swój czyn wszystkim w zasięgu słuchu, a jeśli to rozsądnie możliwe, przez radio.",
			OBLIGATION_ANSWERTONAME = "Jeśli nie jesteś atakowany, zawsze musisz odpowiadać na swoje prawdziwe imię.",
			BAN_HURTWOMAN = "Nigdy nie możesz skrzywdzić kobiety poza samoobroną.",
			BAN_CHAPEL = "Nigdy nie możesz próbować wejść do kaplicy.",
			BAN_HURTPRIEST = "Nigdy nie możesz zaatakować kapłana.",
			BAN_AVOIDWATER = "Nigdy nie możesz dobrowolnie dotknąć mokrej powierzchni.",
			BAN_STRIKEUNCONSCIOUS = "Nigdy nie możesz uderzyć nieprzytomnej osoby.",
			BAN_HURTLIZARD = "Nigdy nie możesz skrzywdzić jaszczuroczłeka poza samoobroną.",
			BAN_HURTANIMAL = "Nigdy nie możesz skrzywdzić nieświadomego stworzenia ani robota poza samoobroną.",
			BANE_SILVER = "Srebro we wszystkich swoich postaciach będzie twoją zgubą.",
			BANE_SALT = "Sól zakłóci twoje magiczne zdolności.",
			BANE_LIGHT = "Oślepiające światła na pewien czas uniemożliwią ci używanie mocy ofensywnych.",
			BANE_IRON = "Zimne kute żelazo będzie dla ciebie trucizną.",
			BANE_WHITECLOTHES = "Ci, którzy noszą nieskazitelnie białe szaty, zadadzą ci prawdziwe ciosy.",
			BANE_HARVEST = "Owoce żniw będą twoją zgubą.",
			BANE_TOOLBOX = "Skrzynki z narzędziami z jakiegoś powodu źle ci wróżą.",
			BANISH_WATER = "Jeśli twoje zwłoki zostaną wypełnione wodą święconą, nie będziesz mógł zmartwychwstać.",
			BANISH_COFFIN = "Jeśli twoje zwłoki będą w trumnie, nie będziesz mógł zmartwychwstać.",
			BANISH_FORMALDYHIDE = "Jeśli twoje zwłoki zostaną zabalsamowane, nie będziesz mógł zmartwychwstać.",
			BANISH_RUNES = "Jeśli twoje zwłoki zostaną umieszczone na runie, nie będziesz mógł zmartwychwstać.",
			BANISH_CANDLES = "Jeśli twoje zwłoki będą w pobliżu zapalonych świec, nie będziesz mógł zmartwychwstać.",
			BANISH_DESTRUCTION = "Jeśli twoje zwłoki zostaną zniszczone, nie będziesz mógł zmartwychwstać.",
			BANISH_FUNERAL_GARB = "Jeśli twoje zwłoki zostaną ubrane w szaty pogrzebowe, nie będziesz mógł zmartwychwstać."
		)
	))

//These are also used in the codex gigas, so let's declare them globally.
GLOBAL_LIST_INIT(devil_pre_title, list("Dark ", "Hellish ", "Fallen ", "Fiery ", "Sinful ", "Blood ", "Fluffy "))
GLOBAL_LIST_INIT(devil_title, list("Lord ", "Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept "))
GLOBAL_LIST_INIT(devil_syllable, list("hal", "ve", "odr", "neit", "ci", "quon", "mya", "folth", "wren", "geyr", "hil", "niet", "twou", "phi", "coa"))
GLOBAL_LIST_INIT(devil_suffix, list(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr."))
/datum/antagonist/devil
	name = "Diabeł"
	roundend_category = "diabły"
	antagpanel_category = "Devil"
	banning_key = ROLE_DEVIL
	//Don't delete upon mind destruction, otherwise soul re-selling will break.
	delete_on_mind_deletion = FALSE
	show_to_ghosts = TRUE
	var/obligation
	var/ban
	var/bane
	var/banish
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/reviveNumber = 0
	var/form = BASIC_DEVIL
	var/static/list/devil_spells = typecacheof(list(
		/obj/effect/proc_holder/spell/aimed/fireball/hellish,
		/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork,
		/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/greater,
		/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/ascended,
		/obj/effect/proc_holder/spell/targeted/infernal_jaunt,
		/obj/effect/proc_holder/spell/targeted/sintouch,
		/obj/effect/proc_holder/spell/targeted/sintouch/ascended,
		/obj/effect/proc_holder/spell/targeted/summon_contract,
		/obj/effect/proc_holder/spell/targeted/conjure_item/violin,
		/obj/effect/proc_holder/spell/targeted/summon_dancefloor))
	var/ascendable = FALSE

/datum/antagonist/devil/can_be_owned(datum/mind/new_owner)
	. = ..()
	return . && (ishuman(new_owner.current) || iscyborg(new_owner.current))

/datum/antagonist/devil/get_admin_commands()
	. = ..()
	.["Toggle ascendable"] = CALLBACK(src,PROC_REF(admin_toggle_ascendable))


/datum/antagonist/devil/proc/admin_toggle_ascendable(mob/admin)
	ascendable = !ascendable
	message_admins("[key_name_admin(admin)] set [key_name_admin(owner)] devil ascendable to [ascendable]")
	log_admin("[key_name_admin(admin)] set [key_name(owner)] devil ascendable to [ascendable])")

/datum/antagonist/devil/admin_add(datum/mind/new_owner,mob/admin)
	switch(alert(admin,"Czy diabeł powinien móc wstąpić na wyższy poziom",,"Yes","No","Cancel"))
		if("Yes")
			ascendable = TRUE
		if("No")
			ascendable = FALSE
		else
			return
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has devil'ed [key_name_admin(new_owner)]. [ascendable ? "(Ascendable)":""]")
	log_admin("[key_name(admin)] has devil'ed [key_name(new_owner)]. [ascendable ? "(Ascendable)":""]")

/datum/antagonist/devil/antag_listing_name()
	return ..() + "([truename])"

/proc/devilInfo(name)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]
	else
		var/datum/fakeDevil/devil = new /datum/fakeDevil(name)
		GLOB.allDevils[lowertext(name)] = devil
		return devil

/proc/randomDevilName()
	var/name = ""
	if(prob(65))
		if(prob(35))
			name = pick(GLOB.devil_pre_title)
		name += pick(GLOB.devil_title)
	var/probability = 100
	name += pick(GLOB.devil_syllable)
	while(prob(probability))
		name += pick(GLOB.devil_syllable)
		probability -= 20
	if(prob(40))
		name += pick(GLOB.devil_suffix)
	return name

/proc/randomdevilobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_FIDDLE, OBLIGATION_DANCEOFF, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/proc/randomdevilban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_STRIKEUNCONSCIOUS, BAN_HURTLIZARD, BAN_HURTANIMAL)

/proc/randomdevilbane()
	return pick(BANE_SALT, BANE_LIGHT, BANE_IRON, BANE_WHITECLOTHES, BANE_SILVER, BANE_HARVEST, BANE_TOOLBOX)

/proc/randomdevilbanish()
	return pick(BANISH_WATER, BANISH_COFFIN, BANISH_FORMALDYHIDE, BANISH_RUNES, BANISH_CANDLES, BANISH_DESTRUCTION, BANISH_FUNERAL_GARB)

/datum/antagonist/devil/proc/add_soul(datum/mind/soul)
	if(soulsOwned.Find(soul))
		return
	soulsOwned += soul
	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	to_chat(owner.current, "<span class='warning'>Czujesz się nasycony, otrzymawszy nową duszę.</span>")
	update_hud()
	switch(SOULVALUE)
		if(0)
			to_chat(owner.current, "<span class='warning'>Twoje piekielne moce zostały przywrócone.</span>")
			give_appropriate_spells()
		if(BLOOD_THRESHOLD)
			increase_blood_lizard()
		if(TRUE_THRESHOLD)
			increase_true_devil()
		if(ARCH_THRESHOLD)
			increase_arch_devil()

/datum/antagonist/devil/proc/remove_soul(datum/mind/soul)
	if(soulsOwned.Remove(soul))
		check_regression()
		to_chat(owner.current, "<span class='warning'>Czujesz, jakby jakaś dusza wymknęła ci się z rąk.</span>")
		update_hud()

/datum/antagonist/devil/proc/check_regression()
	if(form == ARCH_DEVIL)
		return //arch devil can't regress
	//Yes, fallthrough behavior is intended, so I can't use a switch statement.
	if(form == TRUE_DEVIL && SOULVALUE < TRUE_THRESHOLD)
		regress_blood_lizard()
	if(form == BLOOD_LIZARD && SOULVALUE < BLOOD_THRESHOLD)
		regress_humanoid()
	if(SOULVALUE < 0)
		give_appropriate_spells()
		to_chat(owner.current, "<span class='warning'>W ramach kary za twoje porażki odebrano ci wszystkie moce poza tworzeniem kontraktów.</span>")

/datum/antagonist/devil/proc/regress_humanoid()
	to_chat(owner.current, "<span class='warning'>Twoje moce słabną; doprowadź do podpisania kolejnych kontraktów, by odzyskać moc.</span>")
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(/datum/species/human, 1)
		H.regenerate_icons()
	give_appropriate_spells()
	if(istype(owner.current.loc, /obj/effect/dummy/phased_mob/slaughter))
		owner.current.forceMove(get_turf(owner.current))//Fixes dying while jaunted leaving you permajaunted.
	form = BASIC_DEVIL

/datum/antagonist/devil/proc/regress_blood_lizard()
	var/mob/living/carbon/true_devil/D = owner.current
	to_chat(D, "<span class='warning'>Twoje moce słabną; doprowadź do podpisania kolejnych kontraktów, by odzyskać moc.</span>")
	D.oldform.forceMove(D.drop_location())
	owner.transfer_to(D.oldform)
	give_appropriate_spells()
	qdel(D)
	form = BLOOD_LIZARD
	update_hud()


/datum/antagonist/devil/proc/increase_blood_lizard()
	to_chat(owner.current, "<span class='warning'>Czujesz, że twoja humanoidalna postać zaraz opadnie. Wkrótce zmienisz się w krwawego jaszczura.</span>")
	sleep(50)
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.set_species(/datum/species/lizard, 1)
		H.underwear = "Nude"
		H.undershirt = "Nude"
		H.socks = "Nude"
		H.dna.features["mcolor"] = "511" //A deep red
		H.regenerate_icons()
	else //Did the devil get hit by a staff of transmutation?
		owner.current.color = "#501010"
	give_appropriate_spells()
	form = BLOOD_LIZARD



/datum/antagonist/devil/proc/increase_true_devil()
	to_chat(owner.current, "<span class='warning'>Czujesz, że twoja obecna postać zaraz opadnie. Wkrótce zmienisz się w prawdziwego diabła.</span>")
	sleep(50)
	var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(owner.current.loc)
	A.faction |= "hell"
	owner.current.forceMove(A)
	A.oldform = owner.current
	owner.transfer_to(A)
	A.set_name()
	give_appropriate_spells()
	form = TRUE_DEVIL
	update_hud()

/datum/antagonist/devil/proc/increase_arch_devil()
	if(!ascendable)
		return
	var/mob/living/carbon/true_devil/D = owner.current
	to_chat(D, "<span class='warning'>Czujesz, że twoja postać zaraz wstąpi na wyższy poziom.</span>")
	sleep(50)
	if(!D)
		return
	D.visible_message("<span class='warning'>Ze skóry [D] zaczynają wyrastać kolce.</span>", \
		"<span class='warning'>Twoje ciało zaczyna tworzyć wokół ciebie osłonę.</span>")
	sleep(100)
	if(!D)
		return
	D.visible_message("<span class='warning'>Rogi na głowie [D] powoli rosną i się wydłużają.</span>", \
		"<span class='warning'>Twoje ciało dalej mutuje. Twoje zdolności telepatyczne rosną.</span>")
	sleep(90)
	if(!D)
		return
	D.visible_message("<span class='warning'>Ciało [D] zaczyna się gwałtownie rozciągać i wykrzywiać.</span>", \
		"<span class='warning'>Zaczynasz rozdzierać ostatnie bariery dzielące cię od najwyższej mocy.</span>")
	sleep(40)
	if(!D)
		return
	to_chat(D, "<i><b>Yes!</b></i>")
	sleep(10)
	if(!D)
		return
	to_chat(D, "<i><b><span class='big'>YES!!</span></b></i>")
	sleep(10)
	if(!D)
		return
	to_chat(D, "<i><b><span class='reallybig'>YE--</span></b></i>")
	sleep(1)
	if(!D)
		return
	send_to_playing_players("<font size=5><span class='danger'><b>\"LENISTWO, GNIEW, OBŻARSTWO, ACEDIA, ZAZDROŚĆ, CHCIWOŚĆ, PYCHA! OGNIE PIEKŁA, PRZEBUDŹCIE SIĘ!!\"</font></span>")
	sound_to_playing_players('sound/hallucinations/veryfar_noise.ogg')
	give_appropriate_spells()
	D.convert_to_archdevil()
	if(istype(D.loc, /obj/effect/dummy/phased_mob/slaughter/))
		D.forceMove(get_turf(D))//Fixes dying while jaunted leaving you permajaunted.
	var/area/A = get_area(owner.current)
	if(A)
		notify_ghosts("W [A.name] wstąpił arcydiabeł. Zwróć się do diabła, by otrzymać nową powłokę dla swojej duszy.", source = owner.current, action=NOTIFY_ATTACK)
	sleep(50)
	if(!SSticker.mode.devil_ascended)
		SSshuttle.emergency.request(null, set_coefficient = 0.3)
	SSticker.mode.devil_ascended++
	form = ARCH_DEVIL

/datum/antagonist/devil/proc/remove_spells()
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(is_type_in_typecache(S, devil_spells))
			owner.RemoveSpell(S)

/datum/antagonist/devil/proc/give_summon_contract()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_contract(null))
	if(obligation == OBLIGATION_FIDDLE)
		owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/violin(null))
	else if(obligation == OBLIGATION_DANCEOFF)
		owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_dancefloor(null))

/datum/antagonist/devil/proc/give_appropriate_spells()
	remove_spells()
	give_summon_contract()
	if(SOULVALUE >= ARCH_THRESHOLD && ascendable)
		give_arch_spells()
	else if(SOULVALUE >= TRUE_THRESHOLD)
		give_true_spells()
	else if(SOULVALUE >= BLOOD_THRESHOLD)
		give_blood_spells()
	else if(SOULVALUE >= 0)
		give_base_spells()

/datum/antagonist/devil/proc/give_base_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork(null))

/datum/antagonist/devil/proc/give_blood_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))

/datum/antagonist/devil/proc/give_true_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/greater(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch(null))

/datum/antagonist/devil/proc/give_arch_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/summon_pitchfork/ascended(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch/ascended(null))

/datum/antagonist/devil/proc/beginResurrectionCheck(mob/living/body)
	if(SOULVALUE>0)
		to_chat(owner.current, "<span class='userdanger'>Twoje ciało zostało uszkodzone do tego stopnia, że nie możesz już go używać. Kosztem części swojej mocy wkrótce wrócisz do życia. Pozostań w swoim ciele.</span>")
		sleep(DEVILRESURRECTTIME)
		if (!body ||  body.stat == DEAD)
			if(SOULVALUE>0)
				if(check_banishment(body))
					to_chat(owner.current, "<span class='userdanger'>Niestety śmiertelnicy dokończyli rytuał, który uniemożliwia ci zmartwychwstanie.</span>")
					return -1
				else
					to_chat(owner.current, "<span class='userdanger'>WE LIVE AGAIN!</span>")
					return hellish_resurrection(body)
			else
				to_chat(owner.current, "<span class='userdanger'>Niestety moc płynąca z twoich kontraktów wygasła. Nie masz już dość mocy, by zmartwychwstać.</span>")
				return -1
		else
			to_chat(owner.current, "<span class='danger'> Wygląda na to, że zmartwychwstałeś bez swoich piekielnych mocy.</span>")
	else
		to_chat(owner.current, "<span class='userdanger'>Twoje piekielne moce są zbyt słabe, by cię wskrzesić.</span>")

/datum/antagonist/devil/proc/check_banishment(mob/living/body)
	switch(banish)
		if(BANISH_WATER)
			if(iscarbon(body))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent(/datum/reagent/water/holywater)
			return 0
		if(BANISH_COFFIN)
			return (body && istype(body.loc, /obj/structure/closet/crate/coffin))
		if(BANISH_FORMALDYHIDE)
			if(iscarbon(body))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent(/datum/reagent/toxin/formaldehyde)
			return 0
		if(BANISH_RUNES)
			if(body)
				for(var/obj/effect/decal/cleanable/crayon/R in range(0,body))
					if (R.name == "rune")
						return 1
			return 0
		if(BANISH_CANDLES)
			if(body)
				var/count = 0
				for(var/obj/item/candle/C in range(1,body))
					count += C.lit
				if(count>=4)
					return 1
			return 0
		if(BANISH_DESTRUCTION)
			if(body)
				return 0
			return 1
		if(BANISH_FUNERAL_GARB)
			if(ishuman(body))
				var/mob/living/carbon/human/H = body
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/misc/burial))
					return 1
				return 0
			else
				for(var/obj/item/clothing/under/misc/burial/B in range(0,body))
					if(B.loc == get_turf(B)) //Make sure it's not in someone's inventory or something.
						return 1
				return 0

/datum/antagonist/devil/proc/hellish_resurrection(mob/living/body)
	message_admins("[key_name_admin(owner)] (true name is: [truename]) is resurrecting using hellish energy.</a>")
	if(SOULVALUE < ARCH_THRESHOLD || !ascendable) // once ascended, arch devils do not go down in power by any means.
		reviveNumber += LOSS_PER_DEATH
		update_hud()
	if(body)
		body.revive(TRUE, TRUE) //Adminrevive also recovers organs, preventing someone from resurrecting without a heart.
		if(istype(body.loc, /obj/effect/dummy/phased_mob/slaughter/))
			body.forceMove(get_turf(body))//Fixes dying while jaunted leaving you permajaunted.
		if(istype(body, /mob/living/carbon/true_devil))
			var/mob/living/carbon/true_devil/D = body
			if(D.oldform)
				D.oldform.revive(1,0) // Heal the old body too, so the devil doesn't resurrect, then immediately regress into a dead body.
		if(body.stat == DEAD)
			create_new_body()
	else
		create_new_body()
	check_regression()

/datum/antagonist/devil/proc/create_new_body()
	if(GLOB.blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(GLOB.blobstart))
		var/mob/currentMob = owner.current
		if(!currentMob)
			currentMob = owner.get_ghost()
			if(!currentMob)
				message_admins("[key_name_admin(owner)]'s devil resurrection failed due to client logoff.  Aborting.")
				return -1
		if(currentMob.mind != owner)
			message_admins("[key_name_admin(owner)]'s devil resurrection failed due to becoming a new mob.  Aborting.")
			return -1
		currentMob.change_mob_type( /mob/living/carbon/human, targetturf, null, 1)
		var/mob/living/carbon/human/H = owner.current
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/civilian/lawyer/black(H), ITEM_SLOT_ICLOTHING)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), ITEM_SLOT_FEET)
		H.equip_to_slot_or_del(new /obj/item/storage/briefcase(H), ITEM_SLOT_HANDS)
		H.equip_to_slot_or_del(new /obj/item/pen(H), ITEM_SLOT_LPOCKET)
		if(SOULVALUE >= BLOOD_THRESHOLD)
			H.set_species(/datum/species/lizard, 1)
			H.underwear = "Nude"
			H.undershirt = "Nude"
			H.socks = "Nude"
			H.dna.features["mcolor"] = "511"
			H.regenerate_icons()
			if(SOULVALUE >= TRUE_THRESHOLD) //Yes, BOTH this and the above if statement are to run if soulpower is high enough.
				var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(targetturf)
				A.faction |= "hell"
				H.forceMove(A)
				A.oldform = H
				owner.transfer_to(A, TRUE)
				A.set_name()
				if(SOULVALUE >= ARCH_THRESHOLD && ascendable)
					A.convert_to_archdevil()
	else
		CRASH("Unable to find a blobstart landmark for hellish resurrection")


/datum/antagonist/devil/proc/update_hud()
	if(iscarbon(owner.current))
		var/mob/living/C = owner.current
		if(C.hud_used?.devilsouldisplay)
			C.hud_used.devilsouldisplay.update_counter(SOULVALUE)

/datum/antagonist/devil/greet()
	to_chat(owner.current, "<span class='warning'><b>Przypominasz sobie swoją więź z piekłem. Jesteś [truename], agentem piekła, diabłem. I zostałeś zesłany na plan stworzenia nie bez powodu. W wyższym celu. Przekonaj załogę do grzechu i umocnij uścisk Piekła.</b></span>")
	to_chat(owner.current, "<span class='warning'><b>Jednak twoja piekielna postać nie jest pozbawiona słabości.</b></span>")
	to_chat(owner.current, "Nie możesz używać przemocy, by zmusić kogoś do sprzedania duszy.")
	to_chat(owner.current, "Nie możesz bezpośrednio i świadomie fizycznie krzywdzić diabła, poza sobą samym.")
	to_chat(owner.current, GLOB.lawlorify[LAW][bane])
	to_chat(owner.current, GLOB.lawlorify[LAW][ban])
	to_chat(owner.current, GLOB.lawlorify[LAW][obligation])
	to_chat(owner.current, GLOB.lawlorify[LAW][banish])
	to_chat(owner.current, "<span class='warning'>Pamiętaj, że załoga może zbadać twoje słabości, jeśli pozna twoje diabelskie imię.</span><br>")
	.=..()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Devil",
		"Przywołuj kontrakty, by kupować dusze załogi.\nNie możesz używać przemocy, by zmusić kogoś do sprzedania duszy.\nNie możesz bezpośrednio i świadomie fizycznie krzywdzić diabła, poza sobą samym.\n[GLOB.lawlorify[LAW][bane]]\n[GLOB.lawlorify[LAW][ban]]\n[GLOB.lawlorify[LAW][obligation]]\n[GLOB.lawlorify[LAW][banish]]")

/datum/antagonist/devil/on_gain()
	truename = randomDevilName()
	ban = randomdevilban()
	bane = randomdevilbane()
	obligation = randomdevilobligation()
	banish = randomdevilbanish()
	GLOB.allDevils[lowertext(truename)] = src

	antag_memory += "Twoje prawdziwe diabelskie imię to [truename]<br>[GLOB.lawlorify[LAW][ban]]<br>Nie możesz używać przemocy, by zmusić kogoś do sprzedania duszy.<br>Nie możesz bezpośrednio i świadomie fizycznie krzywdzić diabła, poza sobą samym.<br>[GLOB.lawlorify[LAW][bane]]<br>[GLOB.lawlorify[LAW][obligation]]<br>[GLOB.lawlorify[LAW][banish]]<br>"
	if(issilicon(owner.current))
		var/mob/living/silicon/robot_devil = owner.current
		var/laws = list("Nie możesz używać przemocy, by zmusić kogoś do sprzedania duszy.", "Nie możesz bezpośrednio i świadomie fizycznie krzywdzić diabła, poza sobą samym.", GLOB.lawlorify[LAW][ban], GLOB.lawlorify[LAW][obligation], "Wykonaj swoje cele za wszelką cenę.")
		robot_devil.set_law_sixsixsix(laws)
	sleep(10)
	handle_clown_mutation(owner.current, "Twoja piekielna natura pozwoliła ci przezwyciężyć klaunowatość.")
	.=..()

/datum/antagonist/devil/on_removal()
	to_chat(owner.current, "<span class='userdanger'>Twoja piekielna więź została zerwana! Nie jesteś już diabłem!</span>")
	handle_clown_mutation(owner.current, removing=FALSE)
	.=..()

/datum/antagonist/devil/apply_innate_effects(mob/living/mob_override)
	give_appropriate_spells()
	owner.current.grant_all_languages(TRUE, TRUE, TRUE, LANGUAGE_DEVIL)
	update_hud()
	.=..()

/datum/antagonist/devil/remove_innate_effects(mob/living/mob_override)
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(is_type_in_typecache(S, devil_spells))
			owner.RemoveSpell(S)
	owner.current.remove_all_languages(LANGUAGE_DEVIL)
	.=..()

/datum/antagonist/devil/proc/printdevilinfo()
	var/list/parts = list()
	parts += "Prawdziwe imię diabła to: [truename]"
	parts += "Zakazy diabła:"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][ban]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][bane]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][obligation]]"
	parts += "[GLOB.TAB][GLOB.lawlorify[LORE][banish]]"
	return parts.Join("<br>")

/datum/antagonist/devil/roundend_report()
	var/list/parts = list()
	parts += printplayer(owner)
	parts += printdevilinfo()
	parts += printobjectives(objectives)
	return parts.Join("<br>")

//A simple super light weight datum for the codex gigas.
/datum/fakeDevil
	var/truename
	var/bane
	var/obligation
	var/ban
	var/banish
	var/ascendable

/datum/fakeDevil/New(name = randomDevilName())
	truename = name
	bane = randomdevilbane()
	obligation = randomdevilobligation()
	ban = randomdevilban()
	banish = randomdevilbanish()
	ascendable = prob(25)
