// AQUILA - health analyzer window, port of PowerfulBacon-2/AuriStation#15 (HealthAnalyzer.tsx) on our damage model.
// The body outline shows how alive the patient is, injuries are grouped per limb, charts show the pulse, oxygen,
// blood and total damage. Auri's pain, consciousness and injury trees don't exist here, so the data comes from
// plain damage, our wounds, bleeding, organs, traumas and diseases.
// Health mode on carbons opens the window; chemical mode, simple mobs and clumsy users keep the old chat scan.

/obj/item/healthanalyzer
	/// The mob shown in the window
	var/datum/weakref/ui_target

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	if(scanmode != 0 || !iscarbon(M) || HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB))
		return ..()
	flick("[icon_state]-scan", src)
	playsound(src, 'sound/effects/fastbeep.ogg', 10)
	user.visible_message("<span class='notice'>[user] analizuje funkcje życiowe [M].</span>", \
		"<span class='notice'>Analizujesz funkcje życiowe [M].</span>")
	ui_target = WEAKREF(M)
	ui_interact(user)
	add_fingerprint(user)

/obj/item/healthanalyzer/ui_state(mob/user)
	return new /datum/ui_state/hands_state/health_analyzer(src)

/obj/item/healthanalyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HealthAnalyzer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/healthanalyzer/ui_data(mob/user)
	var/mob/living/carbon/target = ui_target?.resolve()
	if(!istype(target))
		return list("target" = null)
	return get_health_analyzer_data(user, target, advanced)

/obj/item/healthanalyzer/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/target = ui_target?.resolve()
	if(action == "print_chat" && istype(target))
		healthscan(usr, target, advanced = advanced)
		return TRUE

/proc/aq_injury(name, heal_text, damage = null, severity = 2)
	var/list/injury = list("name" = name, "heal_text" = heal_text, "severity" = severity)
	if(!isnull(damage))
		injury["damage"] = damage
	return injury

/proc/get_health_analyzer_data(mob/user, mob/living/carbon/target, advanced)
	var/list/data = list()
	var/fake_dead = HAS_TRAIT(target, TRAIT_FAKEDEATH)
	var/dead = target.stat == DEAD || fake_dead
	data["target"] = target.name
	data["is_dead"] = dead
	data["consciousness"] = dead ? -1 : clamp((target.health - HEALTH_THRESHOLD_DEAD) / (target.maxHealth - HEALTH_THRESHOLD_DEAD), 0, 1)
	var/total_damage = target.getBruteLoss() + target.getFireLoss() + target.getToxLoss() + target.getOxyLoss() + target.getCloneLoss()
	data["damage"] = clamp(total_damage / target.maxHealth * 100, 0, 200)
	var/obj/item/organ/heart/heart = target.getorganslot(ORGAN_SLOT_HEART)
	var/circulation = 0
	if(!dead && heart?.beating && !(heart.organ_flags & ORGAN_FAILING))
		circulation = clamp(target.blood_volume / BLOOD_VOLUME_NORMAL, 0, 1.1) * (1 - 0.5 * heart.damage / heart.maxHealth)
	if(!dead && HAS_TRAIT(target, TRAIT_NO_BLOOD))
		circulation = 1
	data["circulation"] = circulation
	data["oxygenation"] = dead ? 0 : clamp(1 - target.getOxyLoss() / 100, 0, 1)
	data["blood_volume"] = target.blood_volume
	data["blood_type"] = target.dna?.blood_type
	data["body_temperature"] = "[round(target.bodytemperature - T0C, 0.1)] °C"
	data["species"] = ishuman(target) ? target.dna.species.name : null

	var/list/reagents = list()
	for(var/datum/reagent/reagent as anything in target.reagents?.reagent_list)
		reagents += list(list("name" = reagent.name, "colour" = reagent.color, "volume" = round(reagent.volume, 0.1)))
	data["reagents"] = reagents
	data["surgeries"] = advanced ? target.get_surgery_progress() : null

	// Whole body
	var/list/body = list()
	if(dead)
		if(target.is_defib_possible())
			body += list(aq_injury("Zgon", "Defibrylacja"))
		else
			body += list(aq_injury("Zgon, nie do defibrylacji", "Napraw serce i mózg, potem defibrylacja; albo klonowanie"))
	else if(heart && !heart.beating)
		body += list(aq_injury("Zatrzymanie akcji serca", "Defibrylacja"))
	if(target.is_bleeding())
		body += list(aq_injury("Krwawienie", "Gaza, uciskanie, kauteryzacja", target.get_bleed_rate_string()))
	else if(target.is_bandaged())
		body += list(aq_injury("Opatrzone krwawienie", "Goi się samo", null, 1))
	if(target.blood_volume < BLOOD_VOLUME_SAFE && !HAS_TRAIT(target, TRAIT_NO_BLOOD))
		body += list(aq_injury("Niski poziom krwi", "Transfuzja, sól fizjologiczna, żelazo", round(target.blood_volume / BLOOD_VOLUME_NORMAL * 100)))
	if(target.getToxLoss())
		body += list(aq_injury("Toksyny", "Węgiel aktywowany, antytoksyny", round(target.getToxLoss(), 0.1)))
	if(target.getOxyLoss())
		body += list(aq_injury("Niedotlenienie", "Tlen, salbutamol, dexalin", round(target.getOxyLoss(), 0.1)))
	if(target.getCloneLoss())
		body += list(aq_injury("Uszkodzenia komórkowe", "Kriokomora, synthflesh", round(target.getCloneLoss(), 0.1)))
	if(advanced && target.radiation)
		body += list(aq_injury("Napromieniowanie", "Pentetic acid, potas jodowy", target.radiation))
	if(HAS_TRAIT(target, TRAIT_HUSK))
		body += list(aq_injury("Wysuszone ciało (husk)", "Synthflesh, leczenie oparzeń"))
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.bodytemperature >= BODYTEMP_HEAT_DAMAGE_LIMIT)
			body += list(aq_injury("Przegrzanie", "Chłodzenie"))
		else if(human_target.bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT)
			body += list(aq_injury("Wychłodzenie", "Ogrzanie"))
	if(!target.getorganslot(ORGAN_SLOT_BRAIN))
		body += list(aq_injury("Brak mózgu", "Przeszczep mózgu"))
	if(advanced && target.has_horror_inside())
		body += list(aq_injury("Pasożyt w okolicy czaszki", "Operacja manipulacji organami głowy"))
	if(advanced && target.hallucinating())
		body += list(aq_injury("Halucynacje", "Haloperidol, odpoczynek"))
	var/obj/item/organ/liver/liver = target.getorganslot(ORGAN_SLOT_LIVER)
	if(istype(liver) && target.cirrhosis_scan_text())
		body += list(aq_injury("Marskość wątroby", "Abstynencja i przeszczep wątroby", "[round(liver.cirrhosis)]%"))
	for(var/datum/brain_trauma/trauma as anything in target.get_traumas())
		var/cure = "Nieznane"
		switch(trauma.resilience)
			if(TRAUMA_RESILIENCE_BASIC)
				cure = "Mannitol, odpoczynek"
			if(TRAUMA_RESILIENCE_SURGERY)
				cure = "Operacja mózgu"
			if(TRAUMA_RESILIENCE_LOBOTOMY)
				cure = "Lobotomia"
		body += list(aq_injury(capitalize(trauma.scan_desc), cure))
	for(var/datum/disease/disease as anything in target.diseases)
		if(disease.visibility_flags & HIDDEN_SCANNER)
			continue
		body += list(aq_injury(disease.name, disease.cure_text || "Nieznane", "[disease.stage]/[disease.max_stages]"))

	var/list/injuries = list("body" = body)
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/list/part = list()
		var/obj/item/bodypart/limb = target.get_bodypart(zone)
		if(!limb)
			part += list(aq_injury("Brak kończyny", "Przyszycie kończyny albo proteza"))
		else
			if(limb.brute_dam)
				part += list(aq_injury("Obrażenia fizyczne", "Nici, bicaridine, styptic", round(limb.brute_dam, 0.1)))
			if(limb.burn_dam)
				part += list(aq_injury("Oparzenia", "Siatka, kelotane, silver sulfadiazine", round(limb.burn_dam, 0.1)))
			for(var/datum/wound/wound as anything in limb.wounds)
				part += list(aq_injury(wound.name, wound.treat_text, null, wound.treated ? 1 : 2))
			for(var/obj/item/embedded as anything in limb.embedded_objects)
				part += list(aq_injury("Tkwi w ciele: [embedded.name]", "Wyciągnij ręką albo hemostatem"))
			for(var/obj/item/bullet_fragment/fragment in limb)
				part += list(aq_injury("Pocisk w ciele", "Operacja usuwania ciał obcych"))
		for(var/obj/item/organ/organ as anything in target.internal_organs)
			if(organ.zone != zone || !organ.damage)
				continue
			var/failing = organ.organ_flags & ORGAN_FAILING
			part += list(aq_injury("[capitalize(organ.name)] [failing ? "niewydolny" : "uszkodzony"]", "Operacja, leki na narząd", advanced ? round(organ.damage) : null, failing ? 2 : 1))
		injuries[zone] = part
	data["injuries"] = injuries
	return data

/// The window keeps updating only next to the patient and closes when they are far away (AuriStation#15)
/datum/ui_state/hands_state/health_analyzer
	var/obj/item/healthanalyzer/source

/datum/ui_state/hands_state/health_analyzer/New(obj/item/healthanalyzer/source)
	. = ..()
	src.source = source

/datum/ui_state/hands_state/health_analyzer/can_use_topic(src_object, mob/user)
	. = ..()
	if(. <= UI_CLOSE)
		return UI_CLOSE
	var/mob/living/target = source.ui_target?.resolve()
	if(isnull(target) || get_dist(user, target) > 3)
		return UI_CLOSE
	if(!user.Adjacent(target))
		. = min(., UI_DISABLED)
