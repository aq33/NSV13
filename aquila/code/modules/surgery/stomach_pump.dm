// AQUILA - port of the BeeStation stomach pump surgery (code/modules/surgery/stomachpump.dm)

/datum/surgery/stomach_pump
	name = "płukanie żołądka"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/stomach_pump,
		/datum/surgery_step/close
	)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/datum/surgery/stomach_pump/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_STOMACH))
		return FALSE
	return ..()

//Working the stomach by hand in such a way that you induce vomiting.
/datum/surgery_step/stomach_pump
	name = "przepłucz żołądek (ręka)"
	accept_hand = TRUE
	repeatable = TRUE
	time = 20
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/stomach_pump/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("Zaczynasz uciskać żołądek [target]..."),
		span_notice("[user] zaczyna uciskać żołądek [target]."),
		span_notice("[user] zaczyna uciskać klatkę piersiową [target]."))

/datum/surgery_step/stomach_pump/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		display_results(user, target, span_notice("Zmuszasz [target] do wymiotów, oczyszczając żołądek z części substancji!"),
			span_notice("[user] zmusza [target] do wymiotów, oczyszczając żołądek z części substancji!"),
			span_notice("[user] zmusza [target] do wymiotów!"))
		target.vomit(20, stun = TRUE)
		target.reagents?.remove_all(target.reagents.total_volume * 0.67) //higher purge ratio than regular vomiting
	return ..()

/datum/surgery_step/stomach_pump/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		display_results(user, target, span_warning("Partaczysz i obijasz klatkę piersiową [target]!"),
			span_warning("[user] partaczy i obija klatkę piersiową [target]!"),
			span_warning("[user] partaczy!"))
		target.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		target.adjustBruteLoss(5)
