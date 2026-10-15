/datum/surgery/advanced/bioware/vein_threading
	name = "Vein Threading"
	desc = "A surgical procedure which severely reduces the amount of blood lost in case of injury."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/thread_veins,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_CIRCULATION
	self_operable = TRUE

/datum/surgery_step/thread_veins
	name = "thread veins"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/thread_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz przeplatać układ krwionośny [target].</span>",
		"[user] zaczyna przeplatać układ krwionośny [target].",
		"[user] zaczyna manipulować układem krwionośnym [target].")

/datum/surgery_step/thread_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Przeplatasz układ krwionośny [target] w odporną siatkę!</span>",
		"[user] przeplata układ krwionośny [target] w odporną siatkę!",
		"[user] kończy manipulować układem krwionośnym [target].")
	new /datum/bioware/threaded_veins(target)
	return TRUE

/datum/bioware/threaded_veins
	name = "Threaded Veins"
	desc = "The circulatory system is woven into a mesh, severely reducing the amount of blood lost from wounds."
	mod_type = BIOWARE_CIRCULATION

/datum/bioware/threaded_veins/on_gain()
	..()
	owner.physiology.bleed_mod *= 0.25

/datum/bioware/threaded_veins/on_lose()
	..()
	owner.physiology.bleed_mod *= 4

