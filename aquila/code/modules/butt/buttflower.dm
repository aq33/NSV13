// Replica butt flower and fartium, ported from HippieStation13
// (code/modules/hydroponics/grown/buttflower.dm, code/modules/reagents/chemistry/reagents/drug_reagents.dm).

/obj/item/seeds/buttseed
	name = "pack of replica butt seeds"
	desc = "Replica butts...has science gone too far?"
	icon = 'aquila/icons/obj/buttflower.dmi'
	icon_state = "seed-butt"
	species = "butt"
	plantname = "Replica Butt Flower"
	product = /obj/item/food/grown/buttflower
	lifespan = 25
	endurance = 10
	maturation = 8
	production = 6
	yield = 1
	potency = 20
	growthstages = 3
	growing_icon = 'aquila/icons/obj/buttflower.dmi'
	icon_grow = "butt-grow"
	icon_dead = "butt-dead"
	icon_harvest = "butt-harvest"
	reagents_add = list(/datum/reagent/drug/fartium = 1)

/obj/item/food/grown/buttflower
	seed = /obj/item/seeds/buttseed
	name = "buttflower"
	desc = "Gives off a pungent aroma once it blooms."
	icon = 'aquila/icons/obj/buttflower.dmi'
	icon_state = "buttflower" //coder spriting ftw
	trash_type = /obj/item/organ/butt

/obj/machinery/vending/hydroseeds/Initialize(mapload)
	products[/obj/item/seeds/buttseed] = 2
	return ..()

/datum/reagent/drug/fartium
	name = "Fartium"
	description = "A chemical compound that promotes concentrated production of gas in your groin area."
	color = "#8A4B08" // rgb: 138, 75, 8
	taste_description = "farts"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 30
	addiction_threshold = 50

/// Fart if we have a butt, otherwise suffer for it
/datum/reagent/drug/fartium/proc/gas_up(mob/living/M, chance, toxdamage, pain_message)
	if(!ishuman(M) || !prob(chance))
		return
	var/mob/living/carbon/human/H = M
	if(H.getorganslot(ORGAN_SLOT_BUTT))
		H.emote("fart")
	else
		to_chat(H, "<span class='danger'>[pain_message]</span>")
		H.adjustToxLoss(toxdamage * REAGENTS_EFFECT_MULTIPLIER)

/datum/reagent/drug/fartium/on_mob_life(mob/living/carbon/M)
	gas_up(M, 7, 1, "Your stomach rumbles as pressure builds up inside of you.")
	return ..()

/datum/reagent/drug/fartium/overdose_process(mob/living/M)
	gas_up(M, 9, 2, "Your stomach hurts a bit as pressure builds up inside of you.")
	return ..()

/datum/reagent/drug/fartium/addiction_act_stage1(mob/living/M)
	gas_up(M, 11, 3, "Your stomach hurts as pressure builds up inside of you.")
	return ..()
