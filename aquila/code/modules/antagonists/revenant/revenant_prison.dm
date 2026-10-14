// AQUILA - więzienie rewenanta w lustrze z tg (code/datums/components/revenant_prison.dm)
// Rozsypana ektoplazma ucieka do całego lustra w pobliżu, zamiast przepaść. Uwięziony rewenant mówi przez lustro,
// a rozbicie lustra go wypuszcza. Bardzo rzadko lustro jest nawiedzone od początku rundy i po rozbiciu wypuszcza nowego rewenanta.

/// Szansa (w procentach), że lustro na mapie jest nawiedzone od początku rundy
#define ROUNDSTART_CURSED_CHANCE 0.2

/obj/structure/mirror
	/// Czy w tym lustrze można uwięzić rewenanta
	var/cursable = TRUE

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	if(cursable && mapload && !broken && prob(ROUNDSTART_CURSED_CHANCE))
		AddComponent(/datum/component/revenant_prison, create_on_release = TRUE)

/// Całe lustro bez lokatora przyjmie rewenanta
/obj/structure/mirror/proc/can_hold_revenant()
	return cursable && !broken && !GetComponent(/datum/component/revenant_prison)

/obj/structure/mirror/obj_break(damage_flag, mapload)
	var/was_broken = broken
	. = ..()
	if(was_broken || !broken)
		return
	var/datum/component/revenant_prison/prison = GetComponent(/datum/component/revenant_prison)
	prison?.on_parent_break()

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	var/datum/component/revenant_prison/prison = GetComponent(/datum/component/revenant_prison)
	prison?.release_revenant("rozebranie [src]")
	return ..()

/// Rozsypana ektoplazma szuka lustra w pobliżu, zanim rewenant przepadnie
/obj/item/ectoplasm/revenant/scatter()
	if(reforming && !inert && !QDELETED(revenant))
		for(var/obj/structure/mirror/new_home in view(3, get_turf(src)))
			if(!new_home.can_hold_revenant())
				continue
			if(!new_home.AddComponent(/datum/component/revenant_prison, revenant, old_key, essence))
				continue
			new_home.visible_message("<span class='revenwarning'>Ponury jęk niesie się echem, gdy drobiny [src] osiadają na [new_home]!</span>")
			log_game("A revenant was trapped inside [new_home] at [AREACOORD(new_home)]")
			message_admins("A revenant was trapped inside [new_home] [ADMIN_JMP(new_home)]")
			revenant = null // nie usuwaj go razem z ektoplazmą
			break
	return ..()

/datum/component/revenant_prison
	/// Czy po uwolnieniu stworzyć nowego rewenanta (lustro nawiedzone od początku rundy)
	var/create_on_release = FALSE
	/// Uwięziony rewenant
	var/mob/living/simple_animal/revenant/revenant
	/// Klucz gracza, który nim grał przed śmiercią
	var/old_key
	/// Maksymalna esencja po odrodzeniu
	var/essence = 75
	/// Mowa przez lustro dla uwięzionego
	var/datum/action/mirror_talk/mirror_talk

/datum/component/revenant_prison/Initialize(mob/living/simple_animal/revenant/revenant, old_key, essence = 75, create_on_release = FALSE)
	if(!istype(parent, /obj/structure/mirror))
		return COMPONENT_INCOMPATIBLE
	if(create_on_release)
		src.create_on_release = TRUE
		return
	if(!istype(revenant))
		return COMPONENT_INCOMPATIBLE
	src.revenant = revenant
	src.old_key = old_key
	src.essence = essence
	revenant.forceMove(parent)
	// Uśpiony w lustrze: bez ruchu i bez mocy, dopóki ktoś go nie wypuści
	revenant.unstun_time = 0
	revenant.notransform = TRUE
	revenant.incorporeal_move = FALSE
	// Gracz wraca do rewenanta, jeśli dalej jest duchem, żeby mógł mówić przez lustro
	if(old_key && !revenant.client)
		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			if(ghost.client?.key == old_key)
				revenant.key = old_key
				to_chat(revenant, "<span class='revenbignotice'>Twoja esencja uciekła do [parent]. Jesteś uwięziony, dopóki ktoś go nie rozbije, ale możesz mówić przez lustro.</span>")
				break
	mirror_talk = new
	mirror_talk.Grant(revenant)

/datum/component/revenant_prison/Destroy(force, silent)
	QDEL_NULL(mirror_talk)
	if(revenant)
		if(revenant.client)
			revenant.ghostize(FALSE)
		QDEL_NULL(revenant)
	return ..()

/datum/component/revenant_prison/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_parent_examine))

/datum/component/revenant_prison/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/datum/component/revenant_prison/proc/on_parent_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='revenwarning'>Odbicie w nim drga i jest dziwnie zniekształcone.</span>"

/datum/component/revenant_prison/proc/on_parent_break()
	var/obj/source = parent
	source.visible_message("<span class='revenwarning'>Rewenant zanosi się chichotem, uciekając z [source]!</span>")
	playsound(source.loc, 'sound/effects/ghost2.ogg', 100, TRUE)
	release_revenant("rozbicie [source]")

/// Wypuszcza rewenanta (albo tworzy nowego) i usuwa komponent
/datum/component/revenant_prison/proc/release_revenant(cause)
	var/obj/old_home = parent
	var/turf/release_turf = get_turf(old_home)
	var/fresh = create_on_release
	if(fresh)
		revenant = new(release_turf)
	if(mirror_talk)
		mirror_talk.Remove(revenant)
		QDEL_NULL(mirror_talk)
	var/mob/living/simple_animal/revenant/our_guy = revenant
	revenant = null
	qdel(src)
	if(!our_guy)
		return FALSE
	our_guy.forceMove(release_turf)
	message_admins("[our_guy] [ADMIN_FLW(our_guy)] has been released from [old_home] [ADMIN_JMP(old_home)]. Cause: [cause]")
	log_game("[our_guy] was released from [old_home] at [AREACOORD(release_turf)]. Cause: [cause]")
	INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob/living/simple_animal/revenant, reform_from_prison), old_key, essence, fresh)
	return TRUE

/// Budzi rewenanta po wyjściu z lustra: stary gracz ma pierwszeństwo, potem ankieta dla duchów
/mob/living/simple_animal/revenant/proc/reform_from_prison(old_key, new_essence, fresh)
	if(!fresh)
		essence_regen_cap = new_essence
		essence = new_essence
		death_reset()
	if(client)
		log_game("[key_name(src)] was remade as a revenant after leaving a mirror.")
		return TRUE
	var/key_of_revenant
	if(old_key)
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.client?.key == old_key)
				key_of_revenant = old_key
				break
	if(!key_of_revenant)
		var/list/candidates = pollCandidatesForMob("Chcesz zostać [name] (uwolniony z lustra)?", ROLE_REVENANT, /datum/role_preference/midround_ghost/revenant, 7.5 SECONDS, src)
		if(QDELETED(src))
			return FALSE
		var/mob/dead/observer/chosen = LAZYLEN(candidates) ? pick(candidates) : null
		key_of_revenant = chosen?.key
	if(!key_of_revenant)
		message_admins("No candidates were found for the revenant released from a mirror.")
		visible_message("<span class='revenwarning'>Z powietrza wysypuje się niebieski pył i osiada na ziemi.</span>")
		var/obj/item/ectoplasm/revenant/dust = new(get_turf(src))
		dust.reforming = FALSE
		dust.inert = TRUE
		qdel(src)
		return FALSE
	key = key_of_revenant
	message_admins("[key_of_revenant] has been made into a revenant released from a mirror.")
	log_game("[key_of_revenant] was made into a revenant released from a mirror.")
	return TRUE

/// Uwięziony rewenant mówi do żywych przez lustro
/datum/action/mirror_talk
	name = "Mirror Talk"
	desc = "Communicate with the living world through your prison."
	icon_icon = 'aquila/icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "mirror_talk"
	background_icon_state = "bg_revenant"

/datum/action/mirror_talk/IsAvailable()
	return ..() && istype(owner?.loc, /obj/structure/mirror)

/datum/action/mirror_talk/Trigger()
	if(!..())
		return FALSE
	var/obj/structure/mirror/mirror = owner.loc
	var/message = stripped_input(owner, "Co chcesz powiedzieć?", "Mowa przez lustro", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(src) || QDELETED(owner) || !IsAvailable())
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		to_chat(owner, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return FALSE
	owner.log_message("\"[message]\" (mirror talk)", LOG_SAY)
	mirror.say(message, spans = list("revenwarning"))
	return TRUE

#undef ROUNDSTART_CURSED_CHANCE
