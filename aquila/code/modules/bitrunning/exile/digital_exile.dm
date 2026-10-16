/**
 * # Cyfrowe wygnanie
 *
 * Nowa forma wygnania przez gateway. Osoba z implantem wygnania, która trafi do netpoda,
 * zostaje na zawsze przeniesiona do Pętli - stałej kryjówki w świecie cyfrowym.
 * Ciało znika (rzeczy trafiają do depozytu przy netpodzie), a wygnaniec może bez końca
 * robić misje na własnym serwerze Pętli. Nagrody z jego misji trafiają na statek.
 * Nie da się wrócić: drabiny i alerty odsyłają tylko do Pętli, a śmierć kończy się odrodzeniem w Pętli.
 */

#define DIGITAL_EXILE_COUNTDOWN (10 SECONDS)
#define DIGITAL_EXILE_RESPAWN_TIME (15 SECONDS)

/// Wszyscy cyfrowi wygnańcy (umysły)
GLOBAL_LIST_EMPTY(digital_exiles)

/// Netpod jest w trakcie procedury wygnania (nie da się z niego wyjść)
/obj/machinery/netpod/var/exiling = FALSE
/// Ktoś z ochrony przerwał procedurę kartą
/obj/machinery/netpod/var/exile_aborted = FALSE

/// Czy osoba w netpodzie ma zostać wygnana
/obj/machinery/netpod/proc/is_digital_exile_candidate(mob/living/carbon/human/neo)
	if(!ishuman(neo) || neo.stat == DEAD || isnull(neo.mind))
		return FALSE
	if(HAS_TRAIT(neo, TRAIT_DIGITAL_EXILE) || HAS_TRAIT(neo, TRAIT_TEMPORARY_BODY))
		return FALSE
	for(var/obj/item/implant/exile/implant in neo.implants)
		if(istype(implant, /obj/item/implant/exile/hotel))
			continue
		return TRUE
	return FALSE

/// Odliczanie, blokada kapsuły i samo wygnanie
/obj/machinery/netpod/proc/try_digital_exile(mob/living/carbon/human/neo)
	if(exiling)
		return
	exiling = TRUE
	exile_aborted = FALSE
	update_appearance()

	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	visible_message(span_danger("[src] zatrzaskuje się i zaczyna głośno buczeć! Na ekranie miga: PROCEDURA CYFROWEGO WYGNANIA."))
	to_chat(neo, span_userdanger("Twój implant wygnania został wykryty. Za [DisplayTimeText(DIGITAL_EXILE_COUNTDOWN)] twoja świadomość zostanie na zawsze przeniesiona do Pętli. Nie ma od tego odwrotu."))
	log_game("[key_name(neo)] started digital exile in [src] at [AREACOORD(src)].")
	message_admins("[ADMIN_LOOKUPFLW(neo)] rozpoczyna cyfrowe wygnanie w netpodzie [ADMIN_VERBOSEJMP(src)].")

	var/time_left = DIGITAL_EXILE_COUNTDOWN
	while(time_left > 0)
		sleep(1 SECONDS)
		time_left -= 1 SECONDS
		if(QDELETED(src) || QDELETED(neo) || occupant != neo || state_open || !is_operational || neo.stat == DEAD || exile_aborted)
			exiling = FALSE
			update_appearance()
			visible_message(span_notice("[src] przerywa procedurę wygnania."))
			return
		if(time_left == 5 SECONDS)
			playsound(src, 'sound/machines/terminal_processing.ogg', 60, TRUE)
			balloon_alert_to_viewers("5...")

	perform_digital_exile(neo)
	exiling = FALSE
	update_appearance()

/// Właściwe wygnanie: awatar w Pętli, depozyt rzeczy, ciało znika
/obj/machinery/netpod/proc/perform_digital_exile(mob/living/carbon/human/neo)
	var/datum/exile_loop/loop = SSbitrunning.get_exile_loop()
	if(isnull(loop))
		balloon_alert_to_viewers("błąd Pętli!")
		open_machine()
		return FALSE

	var/datum/mind/exile_mind = neo.mind
	var/mob/living/carbon/human/avatar = loop.create_exile_avatar(neo)
	if(isnull(avatar))
		balloon_alert_to_viewers("błąd Pętli!")
		open_machine()
		return FALSE

	// Depozyt rzeczy wygnańca przy netpodzie
	var/obj/item/storage/backpack/duffelbag/exile_deposit/deposit = new(get_turf(src))
	deposit.name = "depozyt wygnańca: [neo.real_name]"
	for(var/obj/item/implant/implant in neo.implants)
		qdel(implant)
	for(var/obj/item/item in neo.get_equipped_items(TRUE) + neo.held_items)
		if(QDELETED(item))
			continue
		neo.transferItemToLoc(item, deposit, TRUE)

	// Rekordy: zostaje ślad w manifeście
	for(var/datum/data/record/general_record in GLOB.data_core.general)
		if(general_record.fields["name"] == neo.real_name)
			general_record.fields["rank"] = "Wygnany (cyfrowo)"
	if(exile_mind.assigned_role)
		SSjob.FreeRole(exile_mind.assigned_role)

	exile_mind.transfer_to(avatar, TRUE)
	exile_mind.assigned_role = "Wygnaniec"
	GLOB.digital_exiles |= exile_mind
	avatar.AddComponent(/datum/component/digital_exile, exile_mind)

	playsound(src, 'sound/magic/blink.ogg', 60, TRUE)
	do_sparks(5, TRUE, src)
	visible_message(span_danger("Ciało w [src] rozpada się na strumień danych. Kapsuła spuszcza płyn."))
	bitrunning_announce("Procedura cyfrowego wygnania zakończona: [neo.real_name] przebywa teraz w Pętli.", RADIO_CHANNEL_SECURITY)
	log_game("[key_name(avatar)] was digitally exiled to the loop.")
	message_admins("[ADMIN_LOOKUPFLW(avatar)] został cyfrowo wygnany do Pętli.")

	occupant = null
	qdel(neo)
	open_machine()
	return TRUE

/// Ochrona może przerwać wygnanie, przykładając kartę z dostępem do brygu
/obj/machinery/netpod/attackby(obj/item/tool, mob/living/user, params)
	if(exiling && tool.GetID())
		var/obj/item/card/id/card = tool.GetID()
		if(!(ACCESS_BRIG in card.access))
			balloon_alert(user, "brak uprawnień!")
			return TRUE
		exile_aborted = TRUE
		balloon_alert_to_viewers("wygnanie przerwane")
		log_game("[key_name(user)] aborted a digital exile at [AREACOORD(src)].")
		return TRUE
	return ..()

/obj/machinery/netpod/update_overlays()
	. = ..()
	if(exiling)
		. += mutable_appearance('aquila/icons/effects/bitrunning.dmi', "glitch")


/obj/item/storage/backpack/duffelbag/exile_deposit
	name = "depozyt wygnańca"
	desc = "Torba z rzeczami osoby, która została cyfrowo wygnana."

/obj/item/storage/backpack/duffelbag/exile_deposit/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 40
	STR.max_combined_w_class = 200
	STR.max_w_class = WEIGHT_CLASS_HUGE


/**
 * Komponent wygnańca. Pilnuje, żeby nie dało się wrócić, i odradza po śmierci.
 */
/datum/component/digital_exile
	/// Umysł wygnańca
	var/datum/weakref/mind_ref
	/// Trwa odradzanie
	var/respawning = FALSE

/datum/component/digital_exile/Initialize(datum/mind/exile_mind)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	mind_ref = WEAKREF(exile_mind)

/datum/component/digital_exile/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_DIGITAL_EXILE, REF(src))
	ADD_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, list(COMSIG_BITRUNNER_LADDER_SEVER, COMSIG_BITRUNNER_ALERT_SEVER, COMSIG_BITRUNNER_CACHE_SEVER), PROC_REF(on_exit_attempt))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_deleted))

/datum/component/digital_exile/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_DIGITAL_EXILE, REF(src))
	REMOVE_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH, COMSIG_BITRUNNER_LADDER_SEVER, COMSIG_BITRUNNER_ALERT_SEVER, COMSIG_BITRUNNER_CACHE_SEVER, COMSIG_PARENT_QDELETING))

/// Drabina, alert albo skrzynia: zamiast wyjścia - powrót do Pętli
/datum/component/digital_exile/proc/on_exit_attempt(datum/source)
	SIGNAL_HANDLER

	var/mob/living/exile = parent
	to_chat(exile, span_warning("Nie masz ciała, do którego mógłbyś wrócić. Strumień danych odsyła cię do Pętli."))
	INVOKE_ASYNC(src, PROC_REF(return_to_loop))

/// Przenosi wygnańca z powrotem do Pętli
/datum/component/digital_exile/proc/return_to_loop()
	var/mob/living/exile = parent
	var/datum/exile_loop/loop = SSbitrunning.get_exile_loop()
	var/turf/destination = loop?.get_spawn_turf()
	if(!destination || QDELETED(exile))
		return
	exile.clear_alert(ALERT_BITRUNNER_COMPLETED)
	playsound(exile, 'sound/magic/blink.ogg', 40, TRUE)
	exile.forceMove(destination)
	if(ishuman(exile) && !istype(exile.get_item_by_slot(ITEM_SLOT_ICLOTHING), /obj/item/clothing/under/rank/prisoner))
		apply_exile_outfit(exile, /datum/outfit/digital_exile)
	playsound(destination, 'sound/magic/blink.ogg', 40, TRUE)

/datum/component/digital_exile/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	if(respawning)
		return
	respawning = TRUE
	var/mob/living/exile = parent
	to_chat(exile, span_userdanger("Twój awatar się rozpada... ale Pętla cię nie wypuści. Za chwilę obudzisz się w niej znowu."))
	addtimer(CALLBACK(src, PROC_REF(respawn)), DIGITAL_EXILE_RESPAWN_TIME)

/datum/component/digital_exile/proc/on_deleted(datum/source)
	SIGNAL_HANDLER

	if(respawning)
		return
	respawning = TRUE
	// Ciało znika (np. czyszczenie domeny) - odradzamy od razu
	INVOKE_ASYNC(src, PROC_REF(respawn), TRUE)

/// Tworzy nowego awatara w Pętli i przenosi tam umysł
/datum/component/digital_exile/proc/respawn(deleted = FALSE)
	var/datum/mind/exile_mind = mind_ref?.resolve()
	var/mob/living/carbon/human/old_avatar = parent
	if(isnull(exile_mind))
		qdel(src)
		return

	var/datum/exile_loop/loop = SSbitrunning.get_exile_loop()
	var/mob/living/carbon/human/new_avatar = loop?.create_exile_avatar(old_avatar)
	if(isnull(new_avatar))
		qdel(src)
		return

	// Umysł mógł wyjść z ciała jako duch - wracamy go do nowego awatara
	var/mob/current = exile_mind.current
	exile_mind.transfer_to(new_avatar, TRUE)
	if(isobserver(current) && current.key)
		new_avatar.key = current.key
	exile_mind.assigned_role = "Wygnaniec"
	new_avatar.AddComponent(/datum/component/digital_exile, exile_mind)
	to_chat(new_avatar, span_notice("Budzisz się znowu w Pętli. Nic się nie zmieniło."))

	if(!deleted && !QDELETED(old_avatar))
		old_avatar.dust(TRUE, TRUE)
	qdel(src)

#undef DIGITAL_EXILE_COUNTDOWN
#undef DIGITAL_EXILE_RESPAWN_TIME
