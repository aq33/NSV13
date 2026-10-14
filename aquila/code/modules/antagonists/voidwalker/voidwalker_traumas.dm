// AQUILA - klątwa pustki dla porwanych (tg: voidwalker_traumas.dm, banned_from_space, texture_bodypart_overlay)

/// Klątwa: kosmiczna skóra, pacyfizm, zakaz wejścia w kosmos, wymioty mgławicą
/datum/brain_trauma/voided
	name = "Voided"
	desc = "Pacjent poznał sekrety kosmosu w zamian za klątwę, która go spętała."
	scan_desc = "kosmiczny wzorzec neuronalny"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_LOBOTOMY
	random_gain = FALSE
	clonable = FALSE
	/// Kolor kosmicznej skóry
	var/space_color = COLOR_WHITE
	/// Cechy na czas klątwy
	var/list/traits_to_apply = list(TRAIT_PACIFISM)
	/// Czy kosmos odrzuca właściciela
	var/ban_from_space = TRUE
	/// Szansa na kolorową skórę zamiast białej
	var/coloring_chance = 50
	/// Kolory kosmicznej skóry
	var/static/list/space_colors = list("#00ccff","#b12bff","#ff7f3a","#ff1c55","#ff7597","#28ff94","#0fcfff","#ff8b4c","#ffc425","#2dff96","#1770ff","#ff3f31","#ffba3b")
	/// Szansa na wymioty mgławicą przy każdym ticku
	var/vomit_frequency = 2
	/// Jesteśmy trochę ze szkła
	var/brute_mod = 1.1
	/// Ostatnie pola, które nie były kosmosem, żeby było gdzie odesłać
	var/list/safe_tiles = list()

/datum/brain_trauma/voided/on_gain()
	. = ..()
	if(prob(coloring_chance))
		space_color = pick(space_colors)
	for(var/trait in traits_to_apply)
		ADD_TRAIT(owner, trait, TRAUMA_TRAIT)
	if(ban_from_space)
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_if_space))
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.physiology.brute_mod *= brute_mod
		// twoja bielizna należy do nas
		human.underwear = "Nude"
		human.undershirt = "Nude"
		human.socks = "Nude"
		human.update_body()
	texture_limbs(space_color)

/datum/brain_trauma/voided/on_lose(silent)
	for(var/trait in traits_to_apply)
		REMOVE_TRAIT(owner, trait, TRAUMA_TRAIT)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.physiology.brute_mod /= brute_mod
	texture_limbs(null)
	return ..()

/datum/brain_trauma/voided/on_life()
	. = ..()
	if(vomit_frequency && prob(vomit_frequency) && owner.stat == CONSCIOUS)
		nebula_vomit()

/// Wymioty, z których wędrowiec może się wynurzyć i porywać
/datum/brain_trauma/voided/proc/nebula_vomit()
	var/turf/T = get_turf(owner)
	if(!isopenturf(T) || isspaceturf(T))
		return
	owner.visible_message("<span class='danger'>[owner] wymiotuje mgławicą!</span>", "<span class='userdanger'>Wymiotujesz gwiazdami!</span>")
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	owner.Paralyze(1.5 SECONDS)
	owner.Knockdown(9 SECONDS)
	new /obj/effect/decal/cleanable/vomit/nebula(T)

/// Kosmiczna tekstura na wszystkich kończynach (także przyszytych później), null ją zdejmuje
/datum/brain_trauma/voided/proc/texture_limbs(color)
	owner.void_skin_color = color
	owner.update_body_parts()

/// Kosmos nas nie chce: z powrotem na ostatnie bezpieczne pole
/datum/brain_trauma/voided/proc/check_if_space(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	var/turf/new_turf = owner.loc
	if(!isturf(new_turf))
		return
	if(!isspaceturf(new_turf))
		safe_tiles += new_turf
		if(length(safe_tiles) > 4)
			safe_tiles.Cut(1, 2)
		return
	var/turf/destination
	while(length(safe_tiles) && !destination)
		var/turf/candidate = safe_tiles[1]
		safe_tiles.Cut(1, 2)
		if(!isspaceturf(candidate))
			destination = candidate
	if(!destination)
		destination = get_random_station_turf()
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, forceMove), destination)
	to_chat(owner, "<span class='warning'>Pustka cię odrzuca!</span>")

/// Pozytywna wersja: odporność na próżnię i powolne przechodzenie przez szkło, bez wymiotów i zakazu kosmosu
/datum/brain_trauma/voided/stable
	scan_desc = "stabilny kosmiczny wzorzec neuronalny"
	traits_to_apply = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD)
	ban_from_space = FALSE
	vomit_frequency = 0
	/// Ile trwa przeciśnięcie się przez szkło
	var/pass_time = 2 SECONDS
	/// Czy właśnie przeciskamy się przez szkło
	var/passing = FALSE

/datum/brain_trauma/voided/stable/on_gain()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_BUMP, PROC_REF(bumped))

/datum/brain_trauma/voided/stable/on_lose(silent)
	UnregisterSignal(owner, COMSIG_MOVABLE_BUMP)
	return ..()

/datum/brain_trauma/voided/stable/proc/bumped(mob/living/source, atom/bumpee)
	SIGNAL_HANDLER
	if(!istype(bumpee, /obj/structure/window) || passing)
		return
	INVOKE_ASYNC(src, PROC_REF(phase_through_glass), bumpee)

/datum/brain_trauma/voided/stable/proc/phase_through_glass(atom/bumpee)
	var/turf/target = get_turf(bumpee)
	for(var/obj/structure/grille/grille in target)
		if(voidwalker_grille_shocked(grille))
			grille.balloon_alert(owner, "pod prądem!")
			return
	passing = TRUE
	var/success = do_after(owner, pass_time, FALSE, bumpee)
	passing = FALSE
	if(!success || QDELETED(owner))
		return
	var/old_flags = owner.pass_flags
	owner.pass_flags |= PASSGLASS | PASSGRILLE
	step(owner, get_dir(owner, target))
	owner.pass_flags = old_flags

///
/// Kosmiczna tekstura kończyn (tg: /datum/bodypart_texture/spacey)
///

/mob/living/carbon
	/// Kolor kosmicznej skóry od klątwy pustki, null gdy jej nie ma
	var/void_skin_color

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	var/void_texture_color = owner?.void_skin_color
	if(!void_texture_color || is_husked)
		return
	var/static/icon/space_texture = icon('aquila/icons/mob/voidwalker_texture.dmi', "spacey")
	for(var/image/limb_image in .)
		if(limb_image.layer != -BODYPARTS_LAYER && limb_image.layer != -aux_layer)
			continue
		limb_image.color = void_texture_color
		limb_image.filters += filter(type = "layer", icon = space_texture, blend_mode = BLEND_INSET_OVERLAY)

/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(void_skin_color)
		. += "-void[void_skin_color]"

///
/// Mgławicowe wymiociny
///

/obj/effect/decal/cleanable/vomit/nebula
	name = "nebula vomit"
	desc = "O rety, jakie... piękne."
	icon = 'aquila/icons/effects/voidwalker_vomit.dmi'
	icon_state = "vomitnebula_1"
	random_icon_states = list("vomitnebula_1", "vomitnebula_2", "vomitnebula_3", "vomitnebula_4")

/obj/effect/decal/cleanable/vomit/nebula/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	add_overlay(emissive_appearance(icon, icon_state, alpha = alpha))
	GLOB.nebula_vomits += src

/obj/effect/decal/cleanable/vomit/nebula/Destroy()
	GLOB.nebula_vomits -= src
	return ..()

///
/// Wędrowiec nie daje umrzeć temu, kogo właśnie męczy
///

/datum/status_effect/void_chomped
	id = "void_chomped"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/void_chomped/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NODEATH, id)

/datum/status_effect/void_chomped/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NODEATH, id)
	return ..()
