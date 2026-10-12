// Sidepaths for knowledge between Rust and Ash.

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a Flask of Eldritch Essence. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "To stary przepis. Wyszeptała mi go Sowa. \
		Stworzony przez Kapłana - Płyn, który jednocześnie był i go nie ma."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/spell/ash_passage,
		)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	desc = "Allows you to transmute wirecutters, a pool of vomit, a heart, \
		and an item containing fingerprints to cast a curse of plague \
		on one of the fingerprints' owners for two minutes. While cursed, \
		the victim will repeatedly vomit while their organs will take constant damage."
	gain_text = "Ludzkie ciało jest tymczasowe. Ich słabości nie da się powstrzymać, jak żelaza poddającego się rdzy. Pokaż im wszystkim."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/spell/area_conversion,
	)
	required_atoms = list(
		/obj/item/wirecutters = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/organ/heart = 1,
	)
	duration = 2 MINUTES
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/carbon/human/chosen_mob)
	to_chat(chosen_mob, "<span class='danger'>Czujesz się bardzo chory.</span>")
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/carbon/human/chosen_mob)
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)
	to_chat(chosen_mob, "<span class='notice'>Zaczynasz czuć się lepiej.</span>")

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an area-of-effect targeted spell \
		that causes heavy bleeding and blood loss to anyone afflicted."
	gain_text = "Na początku nie rozumiałem tych narzędzi wojny, ale Kapłan \
		kazał mi mimo to ich używać. Wkrótce, jak mówił, poznam je dobrze."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/entropic_plume,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1
	route = HERETIC_PATH_SIDE
