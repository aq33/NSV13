/mob/living/carbon/human/adjust_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING)) // i ain't got shit
		return FALSE
	return ..()

/mob/living/carbon/human/set_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING))
		return FALSE
	return ..()

/mob/living/carbon/human/adjust_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/living/carbon/human/set_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	update_walk_animation()

/mob/living/carbon/human/Login()
	. = ..()
	update_walk_animation()

/// Włącza lub wyłącza animację chodu według preferencji gracza. Postacie bez gracza ją mają.
/mob/living/carbon/human/proc/update_walk_animation()
	if(istype(src, /mob/living/carbon/human/dummy)) // podgląd postaci kopiuje appearance manekina, a z nim ukryty render_target
		return
	var/datum/component/walk_animation/walk_animation = GetComponent(/datum/component/walk_animation)
	if(client?.prefs && (client.prefs.toggles2 & PREFTOGGLE_2_DISABLE_WALK_ANIMATION))
		qdel(walk_animation)
	else if(!walk_animation)
		AddComponent(/datum/component/walk_animation)

/mob/living/carbon/human/update_inv_hands()
	. = ..()
	var/datum/component/walk_animation/walk_animation = GetComponent(/datum/component/walk_animation)
	walk_animation?.detach_held_items()

// The "Polak" belly is only shown when naked, so redraw the body when clothes change
/mob/living/carbon/human/update_inv_w_uniform()
	. = ..()
	if(dna?.features["body_size"] == "Polak")
		update_body()

/mob/living/carbon/human/update_inv_wear_suit()
	. = ..()
	if(dna?.features["body_size"] == "Polak")
		update_body()
