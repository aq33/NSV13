/obj/item/disk/surgery/brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "The disk provides instructions on how to impress an order on a brain, making it the primary objective of the patient."
	surgeries = list(/datum/surgery/advanced/brainwashing)

/datum/surgery/advanced/brainwashing
	name = "Brainwashing"
	desc = "A surgical procedure which directly implants a directive into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/brainwash,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/advanced/brainwashing/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash
	name = "brainwash"
	implements = list(TOOL_HEMOSTAT = 85, TOOL_WIRECUTTER = 50, /obj/item/stack/package_wrap = 35, /obj/item/stack/cable_coil = 15)
	time = 200
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	var/objective

/datum/surgery_step/brainwash/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = stripped_input(user, "Wybierz cel, który chcesz wdrukować w mózg ofiary.", "Brainwashing", null, MAX_MESSAGE_LEN)
	if(!objective)
		return -1
	display_results(user, target, "<span class='notice'>Zaczynasz prać mózg [target]...</span>",
		"[user] zaczyna naprawiać mózg [target].",
		"[user] zaczyna operację mózgu [target].")

/datum/surgery_step/brainwash/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!target.mind)
		to_chat(user, "<span class='warning'>[target] nie reaguje na pranie mózgu, jakby nie miał umysłu...</span>")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>Słyszysz ciche brzęczenie urządzenia w mózgu [target], a pranie mózgu zostaje wymazane.</span>")
		return FALSE
	display_results(user, target, "<span class='notice'>Udaje ci się wyprać mózg [target].</span>",
		"[user] naprawia mózg [target]!",
		"[user] kończy operację mózgu [target].")
	to_chat(target, "<span class='userdanger'>Twój umysł wypełnia nowy przymus... czujesz, że musisz go słuchać!</span>")
	brainwash(target, objective)
	message_admins("[ADMIN_LOOKUPFLW(user)] surgically brainwashed [ADMIN_LOOKUPFLW(target)] with the objective '[objective]'.")
	log_game("[key_name(user)] surgically brainwashed [key_name(target)] with the objective '[objective]'.")
	return TRUE

/datum/surgery_step/brainwash/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>Partaczysz, obijając tkankę mózgową!</span>",
			"<span class='warning'>[user] partaczy, uszkadzając mózg!</span>",
			"[user] kończy operację mózgu [target].")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
	else
		user.visible_message("<span class='warning'>[user] nagle zauważa, że mózgu, nad którym pracował, już tam nie ma.", "<span class='warning'>Nagle zauważasz, że mózgu, nad którym pracowałeś, już tam nie ma.</span>")
	return FALSE
