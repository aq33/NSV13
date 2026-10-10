/* For employment contracts and infernal contracts */

/obj/item/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = FALSE
	var/datum/mind/target
	item_flags = NOBLUDGEON

/obj/item/paper/contract/proc/update_text()
	return

/obj/item/paper/contract/update_icon()
	return


/obj/item/paper/contract/employment
	icon_state = "paper_words"

/obj/item/paper/contract/employment/New(atom/loc, mob/living/nOwner)
	. = ..()
	if(!nOwner || !nOwner.mind)
		qdel(src)
		return -1
	target = nOwner.mind
	update_text()


/obj/item/paper/contract/employment/update_text()
	name = "paper- [target] employment contract"
	add_raw_text("<center>Warunki zatrudnienia</center><BR><BR><BR><BR>Niniejsza Umowa zostaje zawarta z dniem złożenia ostatniego podpisu poniżej, pomiędzy [target] (zwanym dalej NIEWOLNIKIEM) a Nanotrasen (zwanym dalej wszechobecnym i pomocnym strażnikiem ludzkości).<BR>ZWAŻYWSZY, ŻE:<BR>NIEWOLNIK jest urodzonym człowiekiem lub humanoidem, posiadającym umiejętności, którymi może wspomóc wszechobecnego i pomocnego strażnika ludzkości, i szuka zatrudnienia u wszechobecnego i pomocnego strażnika ludzkości.<BR>ZWAŻYWSZY, ŻE wszechobecny i pomocny strażnik ludzkości zgadza się sporadycznie wypłacać NIEWOLNIKOWI wynagrodzenie w zamian za dożywotnią służbę.<BR>W ZWIĄZKU Z TYM, w zamian za wzajemne zobowiązania zawarte w niniejszej umowie oraz inne istotne i wartościowe świadczenia, strony zgodnie ustalają, co następuje:<BR>W zamian za marne wynagrodzenie NIEWOLNIK zgadza się pracować dla wszechobecnego i pomocnego strażnika ludzkości przez resztę swojego obecnego i przyszłych żyć.<BR>Ponadto NIEWOLNIK zgadza się przenieść własność swojej duszy na dział lojalności wszechobecnego i pomocnego strażnika ludzkości.<BR>Jeśli przeniesienie duszy nie będzie możliwe, zostanie ustanowiony zastaw.<BR>Podpisano,<BR><i>[target]</i>")


/obj/item/paper/contract/employment/attack(mob/living/M, mob/living/carbon/human/user)
	var/deconvert = FALSE
	if(M.mind == target && !M.owns_soul())
		if(user.mind && (user.mind.assigned_role == JOB_NAME_LAWYER))
			deconvert = TRUE
		else if (user.mind && (user.mind.assigned_role ==JOB_NAME_HEADOFPERSONNEL) || (user.mind.assigned_role == JOB_CENTCOM_COMMANDER))
			deconvert = prob (25) // the HoP doesn't have AS much legal training
		else
			deconvert = prob (5)
	if(deconvert)
		M.visible_message("<span class='notice'>[user] przypomina [M], że dusza [M] została już kupiona przez Nanotrasen!</span>")
		to_chat(M, "<span class='boldnotice'>Czujesz, że twoja dusza wróciła do swojego prawowitego właściciela, Nanotrasen.</span>")
		M.return_soul()
	else
		M.visible_message("<span class='danger'>[user] wali [M] [src] po głowie!</span>", \
			"<span class='userdanger'>[user] wali [M] [src] po głowie!</span>")
	return ..()


/obj/item/paper/contract/infernal
	var/contractType = 0
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/mind/owner
	var/datum/antagonist/devil/devil_datum
	icon_state = "paper_onfire"

/obj/item/paper/contract/infernal/power
	name = "paper- contract for infernal power"
	contractType = CONTRACT_POWER

/obj/item/paper/contract/infernal/wealth
	name = "paper- contract for unlimited wealth"
	contractType = CONTRACT_WEALTH

/obj/item/paper/contract/infernal/prestige
	name = "paper- contract for prestige"
	contractType = CONTRACT_PRESTIGE

/obj/item/paper/contract/infernal/magic
	name = "paper- contract for magical power"
	contractType = CONTRACT_MAGIC

/obj/item/paper/contract/infernal/revive
	name = "paper- contract of resurrection"
	contractType = CONTRACT_REVIVE
	var/cooldown = FALSE

/obj/item/paper/contract/infernal/knowledge
	name = "paper- contract for knowledge"
	contractType = CONTRACT_KNOWLEDGE

/obj/item/paper/contract/infernal/friend
	name = "paper- contract for a friend"
	contractType = CONTRACT_FRIEND

/obj/item/paper/contract/infernal/unwilling
	name = "paper- infernal contract"
	contractType = CONTRACT_UNWILLING

/obj/item/paper/contract/infernal/Initialize(mapload, mob/living/nTarget, datum/mind/nOwner)
	. = ..()
	if(!istype(nOwner))
		return INITIALIZE_HINT_QDEL
	owner = nOwner
	devil_datum = owner.has_antag_datum(/datum/antagonist/devil)
	target = nTarget
	update_text()

/obj/item/paper/contract/infernal/suicide_act(mob/user)
	if(signed && (user == target.current) && istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say("O WIELKIE PIEKŁO! ŻĄDAM, BYŚ NATYCHMIAST ODEBRAŁO SWOJĄ NALEŻNOŚĆ!", forced = "infernal contract suicide")
		H.visible_message("<span class='suicide'>[H] unosi kontrakt na swoją duszę i natychmiast staje w płomieniach. Wygląda na to, że próbuje popełnić samobójstwo!</span>")
		H.adjust_fire_stacks(20)
		H.IgniteMob()
		return(FIRELOSS)
	else
		..()

/obj/item/paper/contract/infernal/update_text()
	default_raw_text = "Tego nie powinno być widać. Błąd DEVIL:6"

/obj/item/paper/contract/infernal/power/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na piekielną moc</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za moc i siłę fizyczną. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/wealth/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na nieograniczone bogactwo</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za kieszeń, w której nigdy nie zabraknie cennych zasobów. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/prestige/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na prestiż</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za prestiż i szacunek wśród moich równych. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/magic/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na magię</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za tajemne zdolności przekraczające zwykłe ludzkie możliwości. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/revive/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na wskrzeszenie</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za wskrzeszenie i wyleczenie wszystkich obrażeń. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/knowledge/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na wiedzę</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za bezgraniczną wiedzę. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/friend/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na przyjaciela</B></center><BR><BR><BR>Ja, [target], będąc przy zdrowych zmysłach, niniejszym dobrowolnie oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename], w zamian za przyjaciela. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/unwilling/update_text(signature = "____________", blood = 0)
	default_raw_text = "<center><B>Kontrakt na niewolnika</B></center><BR><BR><BR>Ja, [target], niniejszym oddaję swoją duszę piekłom za pośrednictwem piekielnego agenta [devil_datum.truename]. Rozumiem, że po mojej śmierci moja dusza trafi do piekieł, a mojego ciała nie będzie można wskrzesić, sklonować ani w żaden inny sposób przywrócić do życia. Rozumiem też, że uniemożliwi to użycie mojego mózgu w MMI.<BR><BR><BR>Podpisano, "
	if(blood)
		default_raw_text += "<font face=\"Nyala\" color=#600A0A size=6><i>[signature]</i></font>"
	else
		default_raw_text += "<i>[signature]</i>"

/obj/item/paper/contract/infernal/attackby(obj/item/P, mob/living/carbon/human/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		attempt_signature(user)
	else if(istype(P, /obj/item/stamp))
		to_chat(user, "<span class='notice'>Przykładasz gumową pieczątkę do kartki, ale tusz zapala się, gdy ją odrywasz.</span>")
	else if(P.is_hot())
		user.visible_message("<span class='danger'>[user] zbliża [P] do [src], ale [src] się nie zapala!</span>", "<span class='danger'>[src] nie chce się zapalić!</span>")
	else
		return ..()

/obj/item/paper/contract/infernal/attack(mob/M, mob/living/user)
	add_fingerprint(user)
	if(M == user && target == M.mind && M.mind.soulOwner != owner && attempt_signature(user, 1))
		user.visible_message("<span class='danger'>[user] nacina sobie nadgarstek [src] i wypisuje krwią swoje imię.</span>", "<span class='danger'>Nacinasz sobie nadgarstek i wypisujesz krwią swoje imię.</span>")
		user.blood_volume = max(user.blood_volume - 100, 0)
	else
		return ..()

/obj/item/paper/contract/infernal/proc/attempt_signature(mob/living/carbon/human/user, blood = 0)
	if(!user.IsAdvancedToolUser() || !user.is_literate())
		to_chat(user, "<span class='notice'>Nie umiesz czytać ani pisać.</span>")
		return 0
	if(user.mind != target)
		to_chat(user, "<span class='notice'>Twój podpis po prostu zsuwa się z kartki; wygląda na to, że ten kontrakt nie jest dla ciebie do podpisania.</span>")
		return 0
	if(user.mind.soulOwner == owner)
		to_chat(user, "<span class='notice'>Ten diabeł już posiada twoją duszę, nie możesz sprzedać mu jej ponownie.</span>")
		return 0
	if(signed)
		to_chat(user, "<span class='notice'>Ten kontrakt został już podpisany. Nie można go podpisać ponownie.</span>")
		return 0
	if(!user.mind.hasSoul)
		to_chat(user, "<span class='notice'>Nie posiadasz duszy.</span>")
		return 0
	if(HAS_TRAIT(user, TRAIT_DUMB))
		to_chat(user, "<span class='notice'>Szybko wpisujesz na kontrakcie „twoje imię”.</span>")
		signIncorrectly()
		return 0
	if (contractType == CONTRACT_REVIVE)
		to_chat(user, "<span class='notice'>Już żyjesz, ten kontrakt nic by nie dał.</span>")
		return 0
	else
		to_chat(user, "<span class='notice'>Szybko wpisujesz swoje imię na kontrakcie.</span>")
		if(fulfillContract(target.current, blood)<=0)
			to_chat(user, "<span class='notice'>Ale nie wydaje się to mieć żadnego skutku; może nawet samo Piekło nie może spełnić tej prośby?</span>")
		return 1



/obj/item/paper/contract/infernal/revive/attack(mob/M, mob/living/user)
	if (target == M.mind && M.stat == DEAD && M.mind.soulOwner == M.mind)
		if (cooldown)
			to_chat(user, "<span class='notice'>Daj [M] szansę przemyśleć kontrakt, nie poganiaj.</span>")
			return 0
		cooldown = TRUE
		var/mob/living/carbon/human/H = M
		var/mob/dead/observer/ghost = H.get_ghost()
		var/response = "No"
		if(ghost)
			ghost.notify_cloning("A devil has offered you revival, at the cost of your soul.",'sound/effects/genetics.ogg', H)
			response = tgalert(ghost, "Diabeł oferuje ci kolejną szansę na życie w zamian za twoją duszę; czy przyjmujesz?", "Piekielne wskrzeszenie", "Yes", "No", "Never for this round", 0, 200)
			if(!ghost)
				return		//handle logouts that happen whilst the alert is waiting for a response.
		else
			response = tgalert(target.current, "Diabeł oferuje ci kolejną szansę na życie w zamian za twoją duszę; czy przyjmujesz?", "Piekielne wskrzeszenie", "Yes", "No", "Never for this round", 0, 200)
		if(response == "Yes")
			H.revive(1,0)
			log_combat(user, H, "infernally revived via contract")
			user.visible_message("<span class='notice'>W nagłym rozbłysku [H] znów staje na nogi.</span>")
			H.fakefire()
			fulfillContract(H, 1)//Revival contracts are always signed in blood
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, fakefireextinguish)), 5, TIMER_UNIQUE)
		addtimer(CALLBACK(src, "resetcooldown"), 300, TIMER_UNIQUE)
	else
		..()

/obj/item/paper/contract/infernal/revive/proc/resetcooldown()
	cooldown = FALSE


/obj/item/paper/contract/infernal/proc/fulfillContract(mob/living/carbon/human/user = target.current, blood = FALSE)
	signed = TRUE
	if(user.mind.soulOwner != user.mind) //They already sold their soul to someone else?
		var/datum/antagonist/devil/ownerDevilInfo = user.mind.soulOwner.has_antag_datum(/datum/antagonist/devil)
		ownerDevilInfo.remove_soul(user.mind) //Then they lose their claim.
	user.mind.soulOwner = owner
	user.sethellbound()
	user.mind.damnation_type = contractType
	var/datum/antagonist/devil/devilInfo = owner.has_antag_datum(/datum/antagonist/devil)
	devilInfo.add_soul(user.mind)
	update_text(user.real_name, blood)
	to_chat(user, "<span class='notice'>Ogarnia cię głęboka pustka, gdy tracisz własność swojej duszy.</span>")
	to_chat(user, "<span class='boldnotice'>To NIE czyni cię antagonistą, jeśli wcześniej nim nie byłeś.</span>")
	return TRUE

/obj/item/paper/contract/infernal/proc/signIncorrectly(mob/living/carbon/human/user = target.current, blood = FALSE)
	signed = 1
	update_text("twoje imię", blood)

/obj/item/paper/contract/infernal/power/fulfillContract(mob/living/carbon/human/user = target.current, blood = FALSE)
	if(!user.has_dna())
		return -1
	user.dna.add_mutation(HULK)
	var/obj/item/organ/regenerative_core/organ = new /obj/item/organ/regenerative_core
	organ.Insert(user)
	return ..()

/obj/item/paper/contract/infernal/wealth/fulfillContract(mob/living/carbon/human/user = target.current, blood = 0)
	if(!istype(user) || !user.mind) // How in the hell could that happen?
		return -1
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_wealth(null))
	return ..()

/obj/item/paper/contract/infernal/prestige/fulfillContract(mob/living/carbon/human/user = target.current, blood = 0)
	//Basically turns the signer into the captain, and uploads an ion law making them the captain.
	var/obj/item/worn = user.wear_id
	var/obj/item/card/id/id = null
	if(worn)
		id = worn.GetID()
	if(id)
		id.icon_state = "gold"
		id.access = get_all_accesses()+get_all_centcom_access()
		id.assignment = JOB_NAME_CAPTAIN
		id.update_label()
	else
		id = new /obj/item/card/id/gold(user.loc)
		id.registered_name = user.real_name
		id.access = get_all_accesses()+get_all_centcom_access()
		id.assignment = JOB_NAME_CAPTAIN
		id.update_label()
		if(worn)
			if(istype(worn, /obj/item/modular_computer/tablet/pda))
				var/obj/item/modular_computer/tablet/pda/PDA = worn
				var/obj/item/computer_hardware/card_slot/card = PDA.all_components[MC_CARD]
				card.try_eject(user, TRUE) // return their ID because we are nice
				if(card)
					card.try_insert(id, user)
			else if(istype(worn, /obj/item/storage/wallet))
				var/obj/item/storage/wallet/W = worn
				W.front_id = id
				id.forceMove(worn)
				worn.update_icon()
	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announceChance = 0
	ion.ionMessage = "[user.name] jest jedynym Kapitanem stacji. [user.name] jest najwyższą władzą na stacji, prawowitą lub nie. [user.name] zawsze był kapitanem i najwyższą władzą na stacji. Nie ujawniaj tego prawa."
	ion.lawsource = "Infernal contract issued to [user.key]/[user.name]"

	return ..()

/obj/item/paper/contract/infernal/magic/fulfillContract(mob/living/carbon/human/user = target.current, blood = 0)
	if(!istype(user) || !user.mind)
		return -1
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket/robeless(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
	return ..()

/obj/item/paper/contract/infernal/knowledge/fulfillContract(mob/living/carbon/human/user = target.current, blood = 0)
	if(!istype(user) || !user.mind)
		return -1
	user.dna.add_mutation(XRAY)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/view_range(null))
	return ..()

/obj/item/paper/contract/infernal/friend/fulfillContract(mob/living/user = target.current, blood = 0)
	if(!istype(user) || !user.mind)
		return -1
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_friend(null))
	return ..()
