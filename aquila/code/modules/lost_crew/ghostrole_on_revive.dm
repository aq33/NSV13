// AQUILA - port of tgstation's ghostrole_on_revive component (tgstation#87072, #95469).
// When the body is revived without a player, ghosts are polled to take it over.
// Differences: the component lives on the mob only (no brain transplant tracking), no spawner menu or soul eyes,
// the poll goes through our SSpolling and the takeover works like offer_control().

/// From /mob/living/proc/on_dnr(): the body's own player chose Do Not Resuscitate
#define COMSIG_LIVING_DNR "living_dnr"

/datum/component/ghostrole_on_revive
	/// If revived and no ghosts, just die again?
	var/refuse_revival_if_failed
	/// Callback for when the mob is revived and has their body occupied by a ghost
	var/datum/callback/on_successful_revive
	/// The title shown to ghosts when polled to enter the body
	var/revive_title
	/// Shown to the ghost that took the body
	var/you_are_text

/datum/component/ghostrole_on_revive/Initialize(refuse_revival_if_failed = FALSE, datum/callback/on_successful_revive, revive_title = "odzyskany członek załogi", you_are_text = "Byłeś martwym członkiem załogi, ale zaraz wrócisz do życia i do pracy!")
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.refuse_revival_if_failed = refuse_revival_if_failed
	src.on_successful_revive = on_successful_revive
	src.revive_title = revive_title
	src.you_are_text = you_are_text

/datum/component/ghostrole_on_revive/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	var/mob/living/living_parent = parent
	living_parent.med_hud_set_status()

/datum/component/ghostrole_on_revive/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_REVIVE, COMSIG_PARENT_EXAMINE))
	var/mob/living/living_parent = parent
	living_parent.med_hud_set_status()

/datum/component/ghostrole_on_revive/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		examine_list += "<span class='deadsay'>Po ożywieniu w tym ciele może zamieszkać inna dusza.</span>"

/datum/component/ghostrole_on_revive/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	if(source.client)
		return
	INVOKE_ASYNC(src, PROC_REF(poll_ghosts), source)

/datum/component/ghostrole_on_revive/proc/poll_ghosts(mob/living/reviving)
	var/datum/poll_config/config = new()
	config.question = "Czy chcesz zagrać jako [revive_title] ([reviving.real_name])?"
	config.poll_time = 15 SECONDS
	config.alert_pic = reviving
	config.jump_target = reviving
	config.role_name_text = revive_title
	var/mob/dead/observer/chosen_one = SSpolling.poll_ghosts_for_target(config, reviving)
	if(islist(chosen_one))
		var/list/chosen_list = chosen_one
		chosen_one = length(chosen_list) ? pick(chosen_list) : null

	if(QDELETED(reviving))
		return
	if(isobserver(chosen_one) && chosen_one.client && reviving.stat != DEAD)
		message_admins("[key_name_admin(chosen_one)] has taken control of the revived body of [ADMIN_LOOKUPFLW(reviving)]")
		reviving.ghostize(FALSE)
		reviving.key = chosen_one.key
		to_chat(reviving, "<span class='boldnotice'>[you_are_text]</span>")
		on_successful_revive?.Invoke(reviving)
		qdel(src)
	else if(refuse_revival_if_failed && reviving.stat != DEAD)
		reviving.death()
		reviving.visible_message("<span class='deadsay'>Dusza [reviving] nie zdołała wrócić!</span>")

/// The DNR choice of the body's own player, for Thanatorenasia
/mob/living/proc/on_dnr()
	SEND_SIGNAL(src, COMSIG_LIVING_DNR)

/// Bodies a ghost may take over are never DNR for the defibrillator
/mob/living/carbon/has_dnr()
	if(GetComponent(/datum/component/ghostrole_on_revive))
		return FALSE
	return ..()


/// Thanatorenasia (tgstation#95469): after choosing DNR your body may be revived with another player in it.
/datum/quirk/death_dnr_poll
	name = "Tanatorenazja"
	desc = "Jeśli po śmierci wybierzesz „Do Not Resuscitate”, po ożywieniu twoje ciało może przejąć inny duch, z nową osobowością i bez wspomnień."
	icon = "bolt"
	value = 0
	medical_record_text = "Pacjent cierpi na tanatorenazję: po śmierci i reanimacji może utracić pamięć albo zmienić osobowość."

/datum/quirk/death_dnr_poll/add()
	RegisterSignal(quirk_holder, COMSIG_LIVING_DNR, PROC_REF(on_dnr))

/datum/quirk/death_dnr_poll/remove()
	UnregisterSignal(quirk_holder, COMSIG_LIVING_DNR)

/datum/quirk/death_dnr_poll/proc/on_dnr(mob/living/source)
	SIGNAL_HANDLER
	source.AddComponent(/datum/component/ghostrole_on_revive, \
		refuse_revival_if_failed = FALSE, \
		revive_title = "członek załogi z tanatorenazją", \
		you_are_text = "Byłeś martwym członkiem załogi z tanatorenazją. Nie pamiętasz, kim byłeś ani co się stało, pamiętasz tylko swoje imię i to, że tu pracujesz. Wracaj do pracy!")
