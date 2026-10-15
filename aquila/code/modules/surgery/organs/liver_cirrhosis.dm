// Marskość wątroby: mocny alkohol albo duża ilość alkoholu uszkadzają wątrobę mimo limitu upicia,
// a długie picie zostawia trwałe zwłóknienie, którego nie da się wyleczyć inaczej niż przeszczepem wątroby.

/// Alcohol tolerance of a normal organic liver (ALCOHOL_RATE), used to scale damage for cybernetic livers
#define CIRRHOSIS_BASE_TOLERANCE 0.005
/// Drinks at least this strong count as hard liquor
#define CIRRHOSIS_STRONG_BOOZEPWR 65
/// Units of alcohol in the body above which drinking counts as heavy
#define CIRRHOSIS_HEAVY_VOLUME 30
/// Cirrhosis level at which the liver is scarred enough to stop healing fully
#define CIRRHOSIS_COMPENSATED 30
/// Cirrhosis level with symptoms and faster damage from alcohol
#define CIRRHOSIS_DECOMPENSATED 60
#define CIRRHOSIS_MAX 100

/obj/item/organ/liver
	/// Permanent scarring from alcohol, 0 to CIRRHOSIS_MAX. Only a new liver gets rid of it.
	var/cirrhosis = 0

/obj/item/organ/liver/on_life()
	. = ..()
	var/mob/living/carbon/drinker = owner
	if(!istype(drinker) || HAS_TRAIT(drinker, TRAIT_NOMETABOLISM))
		return
	handle_cirrhosis(drinker)
	// A failing liver doesn't process alcohol, so it takes no new alcohol damage
	if((organ_flags & ORGAN_FAILING) || alcohol_tolerance <= 0)
		return
	handle_alcohol_abuse(drinker)

/// Extra liver damage from hard liquor and from drinking a lot at once
/obj/item/organ/liver/proc/handle_alcohol_abuse(mob/living/carbon/drinker)
	var/total_alcohol = 0
	var/abuse_damage = 0
	for(var/datum/reagent/consumable/ethanol/booze in drinker.reagents.reagent_list)
		total_alcohol += booze.volume
		if(booze.boozepwr >= CIRRHOSIS_STRONG_BOOZEPWR)
			abuse_damage += 0.05 * ((booze.boozepwr - 55) / 10) * sqrt(booze.volume)
	if(total_alcohol > CIRRHOSIS_HEAVY_VOLUME)
		abuse_damage += 0.01 * (total_alcohol - CIRRHOSIS_HEAVY_VOLUME)
	if(abuse_damage <= 0)
		return
	if(HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		abuse_damage *= 0.7
	if(HAS_TRAIT(drinker, TRAIT_LIGHT_DRINKER))
		abuse_damage *= 1.5
	abuse_damage *= alcohol_tolerance / CIRRHOSIS_BASE_TOLERANCE
	if(cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		abuse_damage *= 1.5
	applyOrganDamage(abuse_damage)
	// Scarring builds up faster in a liver that is already damaged
	var/old_cirrhosis = cirrhosis
	cirrhosis = min(cirrhosis + abuse_damage * (0.2 + 0.8 * damage / maxHealth), CIRRHOSIS_MAX)
	if(old_cirrhosis < CIRRHOSIS_COMPENSATED && cirrhosis >= CIRRHOSIS_COMPENSATED)
		to_chat(drinker, "<span class='warning'>Czujesz ciężar i ucisk pod prawymi żebrami.</span>")
	else if(old_cirrhosis < CIRRHOSIS_DECOMPENSATED && cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		to_chat(drinker, "<span class='danger'>Brzuch ci puchnie, a skóra swędzi nie do wytrzymania. Coś jest bardzo nie tak z twoją wątrobą.</span>")

/// Scarred tissue doesn't heal back and a badly scarred liver makes its owner sick
/obj/item/organ/liver/proc/handle_cirrhosis(mob/living/carbon/drinker)
	if(cirrhosis < CIRRHOSIS_COMPENSATED)
		return
	var/scar_floor = min(cirrhosis * 0.5, maxHealth - 1)
	if(damage < scar_floor)
		damage = scar_floor
	if(cirrhosis < CIRRHOSIS_DECOMPENSATED)
		return
	if(prob(2))
		to_chat(drinker, "<span class='warning'>[pick("Mdli cię.", "Swędzi cię całe ciało.", "Czujesz tępy ból pod prawymi żebrami.", "Brzuch masz napięty i obolały.")]</span>")
	if(prob(1))
		drinker.vomit(10)

/obj/item/organ/liver/examine(mob/user)
	. = ..()
	if(cirrhosis >= CIRRHOSIS_DECOMPENSATED)
		. += "<span class='warning'>Jest twarda, pomarszczona i pokryta guzkami - zaawansowana marskość.</span>"
	else if(cirrhosis >= CIRRHOSIS_COMPENSATED)
		. += "<span class='notice'>Jest bledsza niż powinna i wyczuwalnie zwłókniała.</span>"

/// Health analyzer line about cirrhosis, or null
/mob/living/carbon/proc/cirrhosis_scan_text()
	var/obj/item/organ/liver/liver = getorganslot(ORGAN_SLOT_LIVER)
	if(!istype(liver) || liver.cirrhosis < CIRRHOSIS_COMPENSATED)
		return
	var/stage = liver.cirrhosis >= CIRRHOSIS_DECOMPENSATED ? "niewyrównana" : "wyrównana"
	return "\t<span class='alert'>Wykryto marskość wątroby ([stage], [round(liver.cirrhosis)]% zwłóknienia). Zalecane postępowanie: <b>abstynencja i przeszczep wątroby</b>.</span>"

#undef CIRRHOSIS_BASE_TOLERANCE
#undef CIRRHOSIS_STRONG_BOOZEPWR
#undef CIRRHOSIS_HEAVY_VOLUME
#undef CIRRHOSIS_COMPENSATED
#undef CIRRHOSIS_DECOMPENSATED
#undef CIRRHOSIS_MAX
