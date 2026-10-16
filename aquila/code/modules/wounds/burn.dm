// AQUILA - burn wounds: dead skin gets infected unless the burn is dressed with mesh or ointment

/datum/wound/burn
	wound_type = WOUND_BURN
	/// 0-100, past INFECTION_TOXIC it poisons the victim
	var/infection = 0
	/// Infection gained per second while undressed
	var/infection_rate = 0.4
	/// Toxin damage per second once infected
	var/toxin_rate = 0.2

#define INFECTION_TOXIC 50

/datum/wound/burn/wound_effects(delta_time)
	if(treated)
		infection = max(0, infection - delta_time)
		return
	if(victim.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		infection = max(0, infection - delta_time)
		return
	var/old_infection = infection
	infection = min(100, infection + infection_rate * delta_time)
	if(old_infection < INFECTION_TOXIC && infection >= INFECTION_TOXIC)
		to_chat(victim, "<span class='userdanger'>Oparzenie ([limb.name]) ropieje i cuchnie, czujesz gorączkę!</span>")
	if(infection >= INFECTION_TOXIC)
		victim.adjustToxLoss(toxin_rate * delta_time)

/datum/wound/burn/get_scan_text()
	. = ..()
	if(infection >= INFECTION_TOXIC)
		. += " <b>Zakażenie!</b>"
	else if(infection > 10)
		. += " Początki zakażenia."

/datum/wound/burn/can_treat_with(obj/item/item)
	return !treated && (istype(item, /obj/item/stack/medical/mesh) || istype(item, /obj/item/stack/medical/ointment))

/datum/wound/burn/treat(obj/item/stack/medical/dressing, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna opatrywać oparzenie ([limb.name]) [victim].</span>", "<span class='notice'>Zaczynasz opatrywać oparzenie ([limb.name])[self ? "" : " [victim]"].</span>")
	if(!do_mob(user, victim, self ? 5 SECONDS : 2 SECONDS))
		return FALSE
	if(QDELETED(src) || treated || !dressing.use(1))
		return FALSE
	treated = TRUE
	if(istype(dressing, /obj/item/stack/medical/mesh/advanced))
		heal_time = max(heal_time, 2 MINUTES)
	user.visible_message("<span class='green'>[user] opatruje oparzenie ([limb.name]) [victim].</span>", "<span class='green'>Opatrujesz oparzenie ([limb.name]).</span>")
	return TRUE

/datum/wound/burn/second_degree
	name = "Oparzenie drugiego stopnia"
	desc = "Skóra pokrywa ci się pęcherzami"
	examine_desc = "poparzoną skórę w pęcherzach"
	treat_text = "Opatrz siatką albo maścią, spaceacillin hamuje zakażenie."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 80
	heal_time = 2 MINUTES

/datum/wound/burn/third_degree
	name = "Oparzenie trzeciego stopnia"
	desc = "Skóra zwęgla ci się do mięsa"
	examine_desc = "zwęgloną skórę"
	treat_text = "Opatrz siatką, by zatrzymać zakażenie, potem operacja usunięcia martwej tkanki. Zaawansowana siatka goi samodzielnie."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 140
	infection_rate = 1
	toxin_rate = 0.5

#undef INFECTION_TOXIC
