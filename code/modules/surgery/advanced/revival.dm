/datum/surgery/advanced/revival
	name = "Revival"
	desc = "An experimental surgical procedure which involves reconstruction and reactivation of the patient's brain even long after death. The body must still be able to sustain life."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/saw,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/revive,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery/advanced/revival/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	if(target.suiciding || target.ishellbound() || HAS_TRAIT(target, TRAIT_HUSK))
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/revive
	name = "shock body"
	implements = list(/obj/item/shockpaddles = 100, /obj/item/melee/baton = 75, /obj/item/gun/energy = 60)
	repeatable = TRUE
	time = 120
	success_sound = 'sound/magic/lightningbolt.ogg'
	failure_sound = 'sound/magic/lightningbolt.ogg'

/datum/surgery_step/revive/tool_check(mob/user, obj/item/tool)
	. = TRUE
	if(istype(tool, /obj/item/shockpaddles))
		var/obj/item/shockpaddles/S = tool
		if((S.req_defib && !S.defib.powered) || !ISWIELDED(S) || S.cooldown || S.busy)
			to_chat(user, "<span class='warning'>Musisz trzymać obie łopatki, a [S.defib] musi mieć zasilanie!</span>")
			return FALSE
	if(istype(tool, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = tool
		if(!B.turned_on)
			to_chat(user, "<span class='warning'>[B] musi być aktywny!</span>")
			return FALSE
	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = tool
		if(E.chambered && istype(E.chambered, /obj/item/ammo_casing/energy/electrode))
			return TRUE
		else
			to_chat(user, "<span class='warning'>Do tego potrzebujesz elektrody!</span>")
			return FALSE

/datum/surgery_step/revive/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Przygotowujesz się, by dać mózgowi [target] iskrę życia za pomocą [tool].</span>",
		"[user] przygotowuje się, by porazić mózg [target] za pomocą [tool].",
		"[user] przygotowuje się, by porazić mózg [target] za pomocą [tool].")
	target.notify_ghost_cloning("Ktoś próbuje porazić twój mózg!", source = target)

/datum/surgery_step/revive/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Pomyślnie porażasz mózg [target] za pomocą [tool]...</span>",
		"[user] wysyła potężny wstrząs do mózgu [target] za pomocą [tool]...",
		"[user] wysyła potężny wstrząs do mózgu [target] za pomocą [tool]...")
	playsound(get_turf(target), 'sound/magic/lightningbolt.ogg', 50, 1)
	target.grab_ghost()
	target.adjustOxyLoss(-50, 0)
	target.updatehealth()
	if(target.revive())
		target.visible_message("...[target] budzi się, żywy i przytomny!")
		target.emote("gasp")
		to_chat(target, "<span class='warning'><b>Zostajesz przywrócony do życia operacją ożywienia. Nie pamiętasz dokładnie, jak zginąłeś (ani kto cię zabił), ale możesz pamiętać pewne szczegóły, takie jak użyta broń czy miejsce śmierci.</b></span>") //NSV13
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199) //MAD SCIENCE
		return TRUE
	else
		target.visible_message("...dostaje drgawek, po czym nieruchomieje.")
		return FALSE

/datum/surgery_step/revive/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Porażasz mózg [target] za pomocą [tool], ale nie ma reakcji.</span>",
		"[user] wysyła potężny wstrząs do mózgu [target] za pomocą [tool], ale nie ma reakcji.",
		"[user] wysyła potężny wstrząs do mózgu [target] za pomocą [tool], ale nie ma reakcji.")
	playsound(get_turf(target), 'sound/magic/lightningbolt.ogg', 50, 1)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)
	return FALSE
