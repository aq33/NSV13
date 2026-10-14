// AQUILA - antagonista pająka i jady pająków (tg: antagonists/spiders/spiders.dm)

/datum/antagonist/spider
	name = "Pająk"
	roundend_category = "pająki"
	antagpanel_category = "Spider"
	banning_key = ROLE_ALIEN
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	delay_roundend = FALSE
	/// Rozkaz od matki
	var/directive

/datum/antagonist/spider/New(directive)
	. = ..()
	src.directive = directive

/datum/antagonist/spider/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/spider/greet()
	owner.announce_objectives()

/datum/antagonist/spider/proc/forge_objectives()
	var/datum/objective/spider/objective = new(directive)
	objective.owner = owner
	objectives += objective

/datum/objective/spider
	explanation_text = "Szerz plagę."

/datum/objective/spider/New(directive)
	..()
	if(directive)
		explanation_text = "Twoja królowa wydała rozkaz! Wypełnij go za wszelką cenę: [directive]"

/datum/objective/spider/check_completion()
	return owner.current && owner.current.stat != DEAD

/// Toksyna zwykłych pająków. Osłabia, ale sama nie dobija (tg: health_required = 40)
/datum/reagent/toxin/hunterspider
	name = "Spider Toxin"
	description = "Toksyna wytwarzana przez pająki, by osłabić ofiarę."
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	toxpwr = 1.5
	/// Poniżej tego zdrowia toksyna przestaje ranić
	var/health_required = 40

/datum/reagent/toxin/hunterspider/on_mob_life(mob/living/carbon/M)
	if(M.health <= health_required)
		var/old_toxpwr = toxpwr
		toxpwr = 0
		. = ..()
		toxpwr = old_toxpwr
		return
	return ..()

/// Jad pająka żmii: doprowadza ofiarę na skraj śmierci i wywołuje halucynacje
/datum/reagent/toxin/hunterspider/viper
	name = "Viper Spider Toxin"
	description = "Niezwykle toksyczna substancja rzadkiego pająka żmii. Doprowadza ofiarę na skraj śmierci i wywołuje halucynacje."
	toxpwr = 5
	health_required = 10

/datum/reagent/toxin/hunterspider/viper/on_mob_life(mob/living/carbon/M)
	M.hallucination += 5
	return ..()
