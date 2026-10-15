/datum/objective/devil

/datum/objective/devil/soulquantity
	explanation_text = "You shouldn't see this text.  Error:DEVIL1"
	target_amount = 4

/datum/objective/devil/soulquantity/New()
	target_amount = pick(6,7,8)
	update_explanation_text()

/datum/objective/devil/soulquantity/update_explanation_text()
	explanation_text = "Kup co najmniej [target_amount] dusz i utrzymaj nad nimi kontrolę."

/datum/objective/devil/soulquantity/check_completion()
	var/count = 0
	var/datum/antagonist/devil/devilDatum = owner.has_antag_datum(/datum/antagonist/devil)
	var/list/souls = devilDatum.soulsOwned
	for(var/S in souls) //Just a sanity check.
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			count++
	return (count >= target_amount) || ..()



/datum/objective/devil/soulquality
	explanation_text = "You shouldn't see this text.  Error:DEVIL2"
	var/contractType
	var/contractName

/datum/objective/devil/soulquality/New()
	contractType = pick(CONTRACT_POWER, CONTRACT_WEALTH, CONTRACT_PRESTIGE, CONTRACT_MAGIC, CONTRACT_REVIVE, CONTRACT_KNOWLEDGE, CONTRACT_PLEASURE/*, CONTRACT_UNWILLING*/) // AQ EDIT - add CONTRACT_PLEASURE
	target_amount = pick(1,2)
	switch(contractType)
		if(CONTRACT_POWER)
			contractName = "na władzę"
		if(CONTRACT_WEALTH)
			contractName = "na bogactwo"
		if(CONTRACT_PRESTIGE)
			contractName = "na prestiż"
		if(CONTRACT_MAGIC)
			contractName = "na magię"
		if(CONTRACT_REVIVE)
			contractName = "na wskrzeszenie"
		if(CONTRACT_KNOWLEDGE)
			contractName = "na wiedzę"
		if(CONTRACT_PLEASURE) // AQ EDIT
			contractName = "na przyjemności"
	update_explanation_text()

/datum/objective/devil/soulquality/update_explanation_text()
	explanation_text = "Spraw, by śmiertelnicy podpisali co najmniej [target_amount] kontraktów [contractName]."

/datum/objective/devil/soulquality/check_completion()
	var/count = 0
	var/datum/antagonist/devil/devilDatum = owner.has_antag_datum(/datum/antagonist/devil)
	var/list/souls = devilDatum.soulsOwned
	for(var/S in souls)
		var/datum/mind/L = S
		if(!L.owns_soul() && L.damnation_type == contractType)
			count++
	return (count >= target_amount) || ..()



/datum/objective/devil/sintouch
	explanation_text = "You shouldn't see this text.  Error:DEVIL3"

/datum/objective/devil/sintouch/New()
	target_amount = pick(4,5)
	explanation_text = "Spraw, by co najmniej [target_amount] śmiertelników zostało naznaczonych grzechem."

/datum/objective/devil/sintouch/check_completion()
	var/list/touched = get_antag_minds(/datum/antagonist/sintouched)
	return (touched.len >= target_amount) || ..()


/datum/objective/devil/buy_target
	explanation_text = "You shouldn't see this text.  Error:DEVIL4"

/datum/objective/devil/buy_target/update_explanation_text()
	if(target)
		explanation_text = "Kup i zatrzymaj duszę [target.name] ([target.assigned_role])."
	else
		explanation_text = "Cel dowolny."

/datum/objective/devil/buy_target/check_completion()
	return (target.soulOwner == owner) || ..()


/datum/objective/devil/outsell
	explanation_text = "You shouldn't see this text.  Error:DEVIL5"

/datum/objective/devil/outsell/New()

/datum/objective/devil/outsell/update_explanation_text()
	var/datum/antagonist/devil/opponent = target.has_antag_datum(/datum/antagonist/devil)
	explanation_text = "Kup i utrzymaj kontrolę nad większą liczbą dusz niż [opponent.truename], znany śmiertelnikom jako [target.name] ([target.assigned_role])."

/datum/objective/devil/outsell/check_completion()
	var/selfcount = 0
	var/datum/antagonist/devil/devilDatum = owner.has_antag_datum(/datum/antagonist/devil)
	var/list/souls = devilDatum.soulsOwned
	for(var/S in souls)
		var/datum/mind/L = S
		if(L.soulOwner == owner)
			selfcount++
	var/targetcount = 0
	devilDatum = target.has_antag_datum(/datum/antagonist/devil)
	souls = devilDatum.soulsOwned
	for(var/S in souls)
		var/datum/mind/L = S
		if(L.soulOwner == target)
			targetcount++
	return (selfcount > targetcount) || ..()
