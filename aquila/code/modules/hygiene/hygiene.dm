// AQUILA - Hygiene, the parts of tgstation's 2019 hygiene NSV13 left out (removed upstream in tgstation#44843)

/// Called by set_hygiene() whenever the value actually changes
/mob/living/carbon/human/proc/on_hygiene_changed(old_hygiene)
	if((old_hygiene <= HYGIENE_LEVEL_DISGUSTING) != (hygiene <= HYGIENE_LEVEL_DISGUSTING))
		update_smell()
	// Stinking people slowly release miasma, polled by SSmiasma
	if(hygiene <= HYGIENE_LEVEL_DIRTY && old_hygiene > HYGIENE_LEVEL_DIRTY && stat != DEAD)
		SSmiasma.add_source(src)

/mob/living/carbon/human/miasma_emission(seconds)
	if(stat == DEAD)
		return ..()
	if(hygiene > HYGIENE_LEVEL_DIRTY || HAS_TRAIT(src, TRAIT_ALWAYS_CLEAN))
		return null
	// Zipped up in a body bag or a coffin, nothing gets out
	if(istype(loc, /obj/structure/closet/crate/coffin) || istype(loc, /obj/structure/closet/body_bag) || istype(loc, /obj/structure/bodycontainer))
		return 0
	return MIASMA_HYGIENE_MOLES * seconds

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(stat == DEAD || hygiene > HYGIENE_LEVEL_DIRTY || get_dist(user, src) > 2)
		return
	if(hygiene <= HYGIENE_LEVEL_DISGUSTING)
		. += "<span class='warning'><b>Od tej osoby bije okropny smród!</b></span>"
	else
		. += "<span class='warning'>Czuć od tej osoby nieprzyjemny zapach potu.</span>"

// Neat quirk (tgstation, removed in #44843 together with hygiene)
/datum/quirk/neat
	name = "Czyścioszek"
	desc = "Nie znosisz brudu. Kiedy śmierdzisz, humor psuje ci się bardziej niż innym, a świeżo umyty czujesz się świetnie."
	value = 0
	mob_trait = TRAIT_NEAT
	gain_text = "<span class='notice'>Czujesz, że musisz dbać o czystość.</span>"
	lose_text = "<span class='danger'>Już nie musisz być zawsze czysty.</span>"
	medical_record_text = "Czekając na badanie, pacjent posprzątał gabinet."
	mood_quirk = TRUE
	process = TRUE

/datum/quirk/neat/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(!istype(H))
		return
	switch(H.hygiene)
		if(0 to HYGIENE_LEVEL_DIRTY)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "neat", /datum/mood_event/neat_dirty)
		if(HYGIENE_LEVEL_DIRTY to HYGIENE_LEVEL_NORMAL)
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "neat")
		if(HYGIENE_LEVEL_NORMAL to HYGIENE_LEVEL_CLEAN)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "neat", /datum/mood_event/neat_clean)

/datum/quirk/neat/remove()
	if(quirk_holder)
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "neat")

/datum/mood_event/neat_dirty
	description = "<span class='warning'>Brzydzę się sobą. Muszę się natychmiast umyć!</span>\n"
	mood_change = -3

/datum/mood_event/neat_clean
	description = "<span class='nicegreen'>Pachnę świeżością, tak powinno być zawsze.</span>\n"
	mood_change = 2
