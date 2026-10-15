/*
 * Component for items that are used by cultists to conduct rituals.
 *
 * - Draws runes, including the rune to summon Nar'sie.
 * - Purges cultists of holy water on attack.
 * - (Un/re)anchors cult structures when hit.
 * - Instantly destroys cult girders on hit.
 */
/datum/component/cult_ritual_item
	/// Whether we are currently being used to draw a rune.
	var/drawing_a_rune = FALSE
	/// The message displayed when the parent is examined, if supplied.
	var/examine_message
	/// A list of turfs that we scribe runes at double speed on.
	var/list/turfs_that_boost_us
	/// A list of all shields surrounding us while drawing certain runes (Nar'sie).
	var/list/obj/structure/emergency_shield/sanguine/shields
	/// An item action associated with our parent, to quick-draw runes.
	var/datum/action/item_action/linked_action

/datum/component/cult_ritual_item/Initialize(
	examine_message,
	action = /datum/action/item_action/cult_dagger,
	turfs_that_boost_us = /turf/open/floor/engine/cult,
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.examine_message = examine_message

	if(islist(turfs_that_boost_us))
		src.turfs_that_boost_us = turfs_that_boost_us
	else if(ispath(turfs_that_boost_us))
		src.turfs_that_boost_us = list(turfs_that_boost_us)

	if(ispath(action))
		linked_action = new action(parent)

/datum/component/cult_ritual_item/Destroy(force, silent)
	cleanup_shields()
	if(linked_action)
		QDEL_NULL(linked_action)
	return ..()

/datum/component/cult_ritual_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(try_scribe_rune))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(try_purge_holywater))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(try_hit_object))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_EFFECT, PROC_REF(try_clear_rune))

	if(examine_message)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/cult_ritual_item/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_OBJ,
		COMSIG_ITEM_ATTACK_EFFECT,
		))
	if(examine_message)
		UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/*
 * Signal proc for [COMSIG_PARENT_EXAMINE].
 * Gives the examiner, if they're a cultist, our set examine message.
 * Usually, this will include various instructions on how to use the thing.
 */
/datum/component/cult_ritual_item/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!IS_CULTIST(examiner))
		return

	examine_text += examine_message

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_SELF].
 * Allows the user to begin scribing runes.
 */
/datum/component/cult_ritual_item/proc/try_scribe_rune(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	if(!can_scribe_rune(source, user))
		return

	if(drawing_a_rune)
		to_chat(user, "<span class='warning'>Już kreślisz runę.</span>")
		return

	INVOKE_ASYNC(src, PROC_REF(start_scribe_rune), source, user)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Signal proc for [COMSIG_ITEM_ATTACK].
 * Allows for a cultist (user) to hit another cultist (target)
 * to purge them of all holy water in their system, transforming it into unholy water.
 */
/datum/component/cult_ritual_item/proc/try_purge_holywater(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	if(!IS_CULTIST(user) || !IS_CULTIST(target))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN // No hurting other cultists.

	if(!target.reagents.get_reagent(/datum/reagent/water/holywater))
		return

	INVOKE_ASYNC(src, PROC_REF(do_purge_holywater), user)

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_OBJ].
 * Allows the ritual items to unanchor cult buildings or destroy rune girders.
 */
/datum/component/cult_ritual_item/proc/try_hit_object(datum/source, obj/structure/target, mob/cultist)
	SIGNAL_HANDLER

	if(!isliving(cultist) || !IS_CULTIST(cultist))
		return

	if(istype(target, /obj/structure/girder/cult))
		INVOKE_ASYNC(src, PROC_REF(do_destroy_girder), target, cultist)
		return COMPONENT_NO_AFTERATTACK

	if(istype(target, /obj/structure/destructible/cult))
		INVOKE_ASYNC(src, PROC_REF(do_unanchor_structure), target, cultist)
		return COMPONENT_NO_AFTERATTACK

/*
 * Signal proc for [COMSIG_ITEM_ATTACK_EFFECT].
 * Allows the ritual items to remove runes.
 */
/datum/component/cult_ritual_item/proc/try_clear_rune(datum/source, obj/effect/target, mob/living/cultist, params)
	SIGNAL_HANDLER

	if(!isliving(cultist) || !IS_CULTIST(cultist))
		return

	if(istype(target, /obj/effect/rune))
		INVOKE_ASYNC(src, PROC_REF(do_scrape_rune), target, cultist)
		return COMPONENT_NO_AFTERATTACK


/*
 * Actually go through and remove all holy water from [target] and convert it to unholy water.
 *
 * target - the target being hit, and having their holywater converted
 * cultist - the target doing the hitting, can be the same as target
 */
/datum/component/cult_ritual_item/proc/do_purge_holywater(mob/living/target, mob/living/cultist)
	// Allows cultists to be rescued from the clutches of ordained religion
	to_chat(cultist, "<span class='cult'>Usuwasz skazę z [target] za pomocą [parent].</span>")
	var/holy_to_unholy = target.reagents.get_reagent_amount(/datum/reagent/water/holywater)
	target.reagents.del_reagent(/datum/reagent/water/holywater)
	// For carbonss we also want to clear out the stomach of any holywater
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/organ/stomach/belly = carbon_target.getorganslot(ORGAN_SLOT_STOMACH)
		if(belly)
			holy_to_unholy += belly.reagents.get_reagent_amount(/datum/reagent/water/holywater)
			belly.reagents.del_reagent(/datum/reagent/water/holywater)
	target.reagents.add_reagent(/datum/reagent/fuel/unholywater, holy_to_unholy)
	log_combat(cultist, target, "smacked", parent, " removing the holy water from them")

/*
 * Destoys the target cult girder [cult_girder], acted upon by [cultist].
 *
 * cult_girder - the girder being destoyed
 * cultist - the mob doing the destroying
 */
/datum/component/cult_ritual_item/proc/do_destroy_girder(obj/structure/girder/cult/cult_girder, mob/living/cultist)
	playsound(cult_girder, 'sound/weapons/resonator_blast.ogg', 40, TRUE, ignore_walls = FALSE)
	cultist.visible_message(
		"<span class='warning'>[cultist] uderza [cult_girder] za pomocą [parent]!</span>",
		"<span class='notice'>Rozwalasz [cult_girder].</span>"
		)
	new /obj/item/stack/sheet/runed_metal(cult_girder.drop_location(), 1)
	qdel(cult_girder)

/*
 * Unanchors the target cult building.
 *
 * cult_structure - the structure being unanchored or reanchored.
 * cultist - the mob doing the unanchoring.
 */
/datum/component/cult_ritual_item/proc/do_unanchor_structure(obj/structure/cult_structure, mob/living/cultist)
	playsound(cult_structure, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
	cult_structure.anchored = !cult_structure.anchored
	to_chat(cultist, "<span class='notice'>[cult_structure.anchored ? "Przytwierdzasz":"Odczepiasz"] [cult_structure] [cult_structure.anchored ? "do":"od"] podłogi.</span>")

/*
 * Removes the targeted rune. If the rune is important, asks for confirmation and logs it.
 *
 * rune - the rune being deleted. Instance of a rune.
 * cultist - the mob deleting the rune
 */
/datum/component/cult_ritual_item/proc/do_scrape_rune(obj/effect/rune/rune, mob/living/cultist)
	if(rune.log_when_erased)
		var/confirm = alert(cultist, "Starcie runy [rune.cultist_name] może zaszkodzić twoim celom.", "Zacząć ścierać runę [rune.cultist_name]?", "Proceed", "Abort")
		if(confirm != "Proceed")
			return

		// Gee, good thing we made sure cultists can't input stall to grief their team and get banned anyway
		if(!can_scrape_rune(rune, cultist))
			return

	SEND_SOUND(cultist, 'sound/items/sheath.ogg')
	if(!do_after(cultist, rune.erase_time, target = rune))
		return

	if(!can_scrape_rune(rune, cultist))
		return

	if(rune.log_when_erased)
		log_game("[rune.cultist_name] rune erased by [key_name(cultist)] with [parent].")
		message_admins("[ADMIN_LOOKUPFLW(cultist)] erased a [rune.cultist_name] rune with [parent].")

	to_chat(cultist, "<span class='notice'>Ostrożnie ścierasz runę [lowertext(rune.cultist_name)].</span>")
	qdel(rune)

/*
 * Wraps the entire act of [proc/do_scribe_rune] to ensure it properly enables or disables [var/drawing_a_rune].
 *
 * tool - the parent, source of the signal - the item inscribing the rune, casted to item.
 * cultist - the mob scribing the rune
 */
/datum/component/cult_ritual_item/proc/start_scribe_rune(obj/item/tool, mob/living/cultist)
	drawing_a_rune = TRUE
	do_scribe_rune(tool, cultist)
	drawing_a_rune = FALSE

/*
 * Actually give the user input to begin scribing a rune.
 * Creates the new instance of the rune if successful.
 *
 * tool - the parent, source of the signal - the item inscribing the rune, casted to item.
 * cultist - the mob scribing the rune
 */
/datum/component/cult_ritual_item/proc/do_scribe_rune(obj/item/tool, mob/living/cultist)
	var/turf/our_turf = get_turf(cultist)
	var/obj/effect/rune/rune_to_scribe
	var/entered_rune_name
	var/chosen_keyword

	var/datum/antagonist/cult/user_antag = cultist.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	var/datum/team/cult/user_team = user_antag?.get_team()
	if(!user_antag || !user_team)
		stack_trace("[type] - [cultist] attempted to scribe a rune, but did not have an associated [user_antag ? "cult team":"cult antag datum"]!")
		return FALSE

	if(!LAZYLEN(GLOB.rune_types))
		to_chat(cultist, "<span class='cult'>Wygląda na to, że nie ma run do nakreślenia. Zgłoś to swojemu bogu!</span>")
		stack_trace("[type] - [cultist] attempted to scribe a rune, but the global rune list is empty!")
		return FALSE

	entered_rune_name = input(cultist, "Wybierz rytuał do nakreślenia.", "Znaki Mocy") as null|anything in GLOB.rune_types
	if(!entered_rune_name || !can_scribe_rune(tool, cultist))
		return FALSE

	rune_to_scribe = GLOB.rune_types[entered_rune_name]
	if(!ispath(rune_to_scribe))
		stack_trace("[type] - [cultist] attempted to scribe a rune, but did not find a path from the global rune list!")
		return FALSE

	if(initial(rune_to_scribe.req_keyword))
		chosen_keyword = stripped_input(cultist, "Wpisz słowo kluczowe nowej runy.", "Słowa Mocy")
		if(!chosen_keyword)
			drawing_a_rune = FALSE
			start_scribe_rune(tool, cultist)
			return FALSE

	our_turf = get_turf(cultist) //we may have moved. adjust as needed...

	if(!can_scribe_rune(tool, cultist))
		return FALSE

	if(ispath(rune_to_scribe, /obj/effect/rune/summon) && (!is_station_level(our_turf.z) || istype(get_area(cultist), /area/space)))
		to_chat(cultist, "<span class='cultitalic'>Zasłona nie jest tu dość słaba, by przywołać kultystę - musisz być na statku!</span>")
		return

	if(ispath(rune_to_scribe, /obj/effect/rune/apocalypse))
		if((world.time - SSticker.round_start_time) <= 6000)
			var/wait = 6000 - (world.time - SSticker.round_start_time)
			to_chat(cultist, "<span class='cultitalic'>Zasłona nie jest jeszcze dość słaba na tę runę - będzie dostępna za [DisplayTimeText(wait)].</span>")
			return
		if(!check_if_in_ritual_site(cultist, user_team, TRUE))
			return

	if(ispath(rune_to_scribe, /obj/effect/rune/narsie))
		if(!scribe_narsie_rune(cultist, user_team))
			return

	cultist.visible_message(
		"<span class='warning'>[cultist] [cultist.blood_volume ? "rozcina sobie rękę i zaczyna pisać własną krwią":"zaczyna szkicować dziwny wzór"]!</span>",
		"<span class='cult'>[cultist.blood_volume ? "Rozcinasz sobie rękę i z":"Z"]aczynasz kreślić znak Geometry.</span>"
		)

	if(cultist.blood_volume)
		cultist.apply_damage(initial(rune_to_scribe.scribe_damage), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // *cuts arm* *bone explodes* ever have one of those days?
		if (iscarbon(cultist))
			var/mob/living/carbon/carbon_cultist = cultist
			carbon_cultist.add_bleeding(BLEED_TINY)

	var/scribe_mod = initial(rune_to_scribe.scribe_delay)
	if(!initial(rune_to_scribe.no_scribe_boost) && (our_turf.type in turfs_that_boost_us))
		scribe_mod *= 0.5

	SEND_SOUND(cultist, sound('sound/weapons/slice.ogg', 0, 1, 10))
	if(!do_after(cultist, scribe_mod, target = get_turf(cultist)))
		cleanup_shields()
		return FALSE
	if(!can_scribe_rune(tool, cultist))
		cleanup_shields()
		return FALSE

	cultist.visible_message(
		"<span class='warning'>[cultist] kreśli dziwny krąg[cultist.blood_volume ? " własną krwią":""].</span>",
		"<span class='cult'>Kończysz kreślić tajemne znaki Geometry.</span>"
		)

	cleanup_shields()
	var/obj/effect/rune/made_rune = new rune_to_scribe(our_turf, chosen_keyword)
	made_rune.add_mob_blood(cultist)

	to_chat(cultist, "<span class='cult'>Runa [lowertext(made_rune.cultist_name)] [made_rune.cultist_desc]</span>")
	SSblackbox.record_feedback("tally", "cult_runes_scribed", 1, made_rune.cultist_name)

	return TRUE

/*
 * The process of scribing the nar'sie rune.
 *
 * cultist - the mob placing the rune
 * cult_team - the team of the mob placing the rune
 */
/datum/component/cult_ritual_item/proc/scribe_narsie_rune(mob/living/cultist, datum/team/cult/cult_team)
	var/datum/objective/eldergod/summon_objective = locate() in cult_team.objectives
	var/datum/objective/sacrifice/sac_objective = locate() in cult_team.objectives
	if(!check_if_in_ritual_site(cultist, cult_team))
		return FALSE
	if(sac_objective && !sac_objective.check_completion())
		to_chat(cultist, "<span class='warning'>Ofiara nie jest kompletna. Portalowi zabrakłoby mocy, by się otworzyć!</span>")
		return FALSE
	if(summon_objective.check_completion())
		to_chat(cultist, "<span class='cultlarge'>\"Już tu jestem. Nie ma potrzeby mnie teraz przywoływać.\"</span>")
		return FALSE
	var/confirm_final = alert(cultist, "To OSTATNI krok do przywołania Nar'Sie; to długi, bolesny rytuał, a załoga dowie się o twojej obecności.", "Jesteś gotowy na ostateczną bitwę?", "Moje życie dla Nar'Sie!", "No")
	if(confirm_final == "No" || !confirm_final)
		to_chat(cultist, "<span class='cult'>Postanawiasz lepiej się przygotować, zanim nakreślisz runę.</span>")
		return
	if(!check_if_in_ritual_site(cultist, cult_team))
		return FALSE
	priority_announce("[cultist.real_name] przywołuje do [get_area(cultist)] z nieznanego wymiaru wytwory pradawnego boga. Przerwijcie rytuał za wszelką cenę!","Wydział Spraw Wyższych Wymiarów Centrali", ANNOUNCER_SPANOMALIES)
	for(var/shielded_turf in spiral_range_turfs(1, cultist, 1))
		LAZYADD(shields, new /obj/structure/emergency_shield/sanguine(shielded_turf))

	return TRUE

/*
 * Helper to check if a rune can be scraped by a cultist.
 * Used in between inputs of [do_scrape_rune] for sanity checking.
 *
 * rune - the rune being deleted. Instance of a rune.
 * cultist - the mob deleting the rune
 */
/datum/component/cult_ritual_item/proc/can_scrape_rune(obj/effect/rune/rune, mob/living/cultist)
	if(!IS_CULTIST(cultist))
		return FALSE

	if(!cultist.is_holding(parent))
		return FALSE

	if(!rune.Adjacent(cultist))
		return FALSE

	if(cultist.incapacitated())
		return FALSE

	if(cultist.stat == DEAD)
		return FALSE

	return TRUE

/*
 * Helper to check if a rune can be scribed by a cultist.
 * Used in between inputs of [do_scribe_rune] for sanity checking.
 *
 * tool - the parent - the item being used to scribe the rune, casted to item
 * cultist - the mob making the rune
 */
/datum/component/cult_ritual_item/proc/can_scribe_rune(obj/item/tool, mob/living/cultist)
	if(!IS_CULTIST(cultist))
		to_chat(cultist, "<span class='warning'>[tool] pokrywają niezrozumiałe kształty i znaki.</span>")
		return FALSE

	if(QDELETED(tool) || !cultist.is_holding(tool))
		return FALSE

	if(cultist.incapacitated() || cultist.stat == DEAD)
		to_chat(cultist, "<span class='warning'>Nie możesz teraz kreślić runy.</span>")
		return FALSE

	if(!check_rune_turf(get_turf(cultist), cultist))
		return FALSE

	return TRUE

/*
 * Checks if a turf is valid for having a rune placed there.
 *
 * target - the turf being checked
 * cultist - the mob placing the rune
 */
/datum/component/cult_ritual_item/proc/check_rune_turf(turf/target, mob/living/cultist)
	if(isspaceturf(target))
		to_chat(cultist, "<span class='warning'>Nie możesz kreślić run w kosmosie!</span>")
		return FALSE

	if(locate(/obj/effect/rune) in target)
		to_chat(cultist, "<span class='cult'>Tu już jest runa.</span>")
		return FALSE

	var/area/our_area = get_area(target)
	if((!is_station_level(target.z) && !is_mining_level(target.z)) || (our_area && !(our_area.area_flags & BLOBS_ALLOWED)))
		to_chat(cultist, "<span class='warning'>Zasłona nie jest tu dość słaba.</span>")
		return FALSE

	return TRUE

/*
 * Helper to check a cultist is located in one of the ritual / summoning sites.
 *
 * cultist - the mob making the rune
 * cult_team - the team of the mob making the rune
 * fail_if_last_site - whether the check fails if it's the last site in the summoning list.
 */
/datum/component/cult_ritual_item/proc/check_if_in_ritual_site(mob/living/cultist, datum/team/cult/cult_team, fail_if_last_site = FALSE)
	var/datum/objective/eldergod/summon_objective = locate() in cult_team.objectives
	var/area/our_area = get_area(cultist)
	if(!summon_objective)
		to_chat(cultist, "<span class='warning'>Na tym statku nie ma miejsc rytuału, gdzie można nakreślić tę runę!</span>")
		return FALSE

	if(!(our_area in summon_objective.summon_spots))
		to_chat(cultist, "<span class='warning'>Zasłona nie jest tu dość słaba - runę można nakreślić tylko w miejscach: [english_list(summon_objective.summon_spots)]!</span>")
		return FALSE

	if(fail_if_last_site && summon_objective.summon_spots.len <= 1)
		to_chat(cultist, "<span class='warning'>Tutaj nie można nakreślić tej runy - miejsce rytuału musi zostać zachowane na ostateczne przywołanie!</span>")
		return FALSE

	return TRUE

/*
 * Removes all shields from the shields list.
 */
/datum/component/cult_ritual_item/proc/cleanup_shields()
	for(var/obj/structure/emergency_shield/sanguine/shield as anything in shields)
		LAZYREMOVE(shields, shield)
		if(!QDELETED(shield))
			qdel(shield)
