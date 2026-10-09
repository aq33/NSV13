/**
 * Animacja chodu: ręce i nogi ruszają się przy każdym kroku, niezależnie od stroju.
 *
 * Mob rysuje się tylko do bufora (render_target z "*"), a pięć fragmentów w jego vis_contents
 * pokazuje ten obraz przycięty maskami alfa: tułów, dwie ręce i dwie nogi. Ubranie i nakładki
 * są więc cięte razem z ciałem. Przedmioty w dłoniach są kopiowane na osobne fragmenty ("hand_1" lewa,
 * "hand_2" prawa) i pokazywane w całości, ruszając się razem ze swoją ręką.
 * Maski są kierunkowe (aquila/icons/mob/walk_masks.dmi) i dziedziczą kierunek moba po stronie klienta.
 * "arm_a"/"leg_a" to strona lewa na ekranie przy widoku z przodu i z tyłu; w widoku z boku
 * "arm_a" to ręka bliżej patrzącego, a "leg_a" i "leg_b" pokazują obie nogi w pełnej szerokości.
 * Z boku "leg_b" jest widoczna tylko w trakcie kroku, żeby w spoczynku nogi nie były rysowane podwójnie.
 * Z boku "arm_b" jest pusta: dalsza dłoń, która w sprite'ach wystaje 1 px przed brzuch, jest wycięta na stałe.
 */
/datum/component/walk_animation
	/// Bufor, do którego rysuje się mob
	var/body_target
	/// render_target moba sprzed podpięcia komponentu (blokada emisji)
	var/old_render_target
	/// Nazwa maski -> fragment ciała, który ją pokazuje
	var/list/limbs = list()
	/// Obiekty masek, rysowane tylko do własnych buforów
	var/list/masks = list()
	/// Blokada emisji dla nowego bufora; stara czyta render_target, który tu podmieniamy
	var/atom/movable/emissive_blocker/em_block
	/// Która para ręka/noga rusza się przy tym kroku
	var/phase = FALSE

/datum/component/walk_animation/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = parent

	body_target = "*walk_body[REF(H)]"
	old_render_target = H.render_target
	H.render_target = body_target

	em_block = new(null, body_target)
	H.vis_contents += em_block

	// Nogi pod tułowiem (wysuwana z boku nad tylną), ręce nad nim
	add_limb(H, "leg_a", FLOAT_LAYER - 0.2)
	add_limb(H, "leg_b", FLOAT_LAYER - 0.15)
	add_limb(H, "torso_cut", FLOAT_LAYER - 0.1, MASK_INVERSE)
	add_limb(H, "arm_a", FLOAT_LAYER - 0.05)
	add_limb(H, "arm_b", FLOAT_LAYER - 0.05)
	// Przedmioty w dłoniach nad wszystkim, jak HANDS_LAYER
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = new
		limbs["hand_[index]"] = held
		H.vis_contents += held
	update_side_leg(H.dir)
	detach_held_items()

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(H, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))

/datum/component/walk_animation/Destroy()
	var/mob/living/carbon/human/H = parent
	if(H)
		UnregisterSignal(H, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
		if(H.render_target == body_target)
			H.render_target = old_render_target
		H.vis_contents -= em_block
		for(var/state in limbs)
			H.vis_contents -= limbs[state]
		for(var/state in masks)
			H.vis_contents -= masks[state]
		// Wyłączenie w trakcie gry: przedmioty w dłoniach są ukryte buforem, więc budujemy je od nowa
		if(!QDELETED(H))
			H.update_inv_hands()
	QDEL_NULL(em_block)
	QDEL_LIST_ASSOC_VAL(limbs)
	QDEL_LIST_ASSOC_VAL(masks)
	return ..()

/datum/component/walk_animation/proc/add_limb(mob/living/carbon/human/H, state, layer, mask_flags)
	var/obj/effect/overlay/walk_mask/mask = new
	mask.icon_state = state
	mask.render_target = "*walk_[state][REF(H)]"
	masks[state] = mask
	H.vis_contents += mask

	var/obj/effect/overlay/walk_limb/limb = new
	limb.layer = layer
	limb.render_source = body_target
	limb.add_filter("walk_mask", 1, alpha_mask_filter(render_source = mask.render_target, flags = mask_flags))
	limbs[state] = limb
	H.vis_contents += limb

/// Przenosi przedmioty z dłoni 1 i 2 na fragmenty "hand_1"/"hand_2", żeby maski ich nie cięły.
/// Fragment dostaje kopię nakładki i dziedziczy kierunek moba, więc sprite obraca się z postacią.
/// Oryginał zostaje w mobie, ukryty buforem z "*", żeby getFlatIcon (zdjęcia) dalej widział przedmiot.
/// Wołane po każdym update_inv_hands().
/datum/component/walk_animation/proc/detach_held_items()
	if(QDELING(src)) // update_inv_hands() z Destroy() ma zostawić zwykłe nakładki
		return
	var/mob/living/carbon/human/H = parent
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = limbs["hand_[index]"]
		held.cut_overlays()
	var/list/hand_overlays = H.overlays_standing[HANDS_LAYER]
	if(!length(hand_overlays))
		return
	H.remove_overlay(HANDS_LAYER)
	// update_inv_hands() buduje listę w kolejności held_items, pomijając puste dłonie
	var/overlay_index = 0
	for(var/obj/item/I in H.held_items)
		overlay_index++
		if(overlay_index > length(hand_overlays))
			break
		var/hand_index = H.get_held_index_of_item(I)
		var/mutable_appearance/hand_overlay = hand_overlays[overlay_index]
		if(hand_index > 2 || !istype(hand_overlay))
			continue
		var/obj/effect/overlay/walk_held/held = limbs["hand_[hand_index]"]
		held.add_overlay(new /mutable_appearance(hand_overlay))
		hand_overlay.render_target = "*walk_hand[hand_index][REF(H)]"
	H.overlays_standing[HANDS_LAYER] = hand_overlays
	H.apply_overlay(HANDS_LAYER)

/datum/component/walk_animation/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(forced || !isturf(old_loc) || get_dist(old_loc, source) != 1)
		return
	if(source.buckled || source.lying || source.throwing || !(source.mobility_flags & MOBILITY_STAND))
		return
	if(source.movement_type & (FLYING|FLOATING|VENTCRAWLING) || !source.has_gravity())
		return
	if(source.GetComponent(/datum/component/waddling)) // buty klauna i inne podskakiwanie mają własną animację
		return

	// Czas jednego kroku w decysekundach, odtworzony z glide_size (odwrotność DELAY_TO_GLIDE_SIZE).
	var/half_step = (world.icon_size / max(source.glide_size, 1)) * world.tick_lag / 2
	phase = !phase
	update_side_leg(source.dir)

	if(source.dir & (EAST|WEST))
		// Z boku: tylna noga cofa się, a pełna kopia nóg wysuwa się w przód.
		// Ręka wisi przy samych plecach, więc wychyla się tylko w przód (co drugi krok), żeby nie wystawać za obrys.
		// Dalsza dłoń jest ukryta za ciałem; przedmiot w niej cofa się o 1 px, gdy bliższa ręka idzie w przód.
		var/forward = (source.dir & EAST) ? 1 : -1
		swing("leg_a", -forward, 0, half_step)
		var/obj/effect/overlay/walk_limb/front_leg = limbs["leg_b"]
		animate(front_leg, alpha = 255, time = 0)
		animate(pixel_w = forward, time = half_step, easing = SINE_EASING | EASE_OUT)
		animate(pixel_w = 0, time = half_step, easing = SINE_EASING | EASE_IN)
		animate(alpha = 0, time = 0)
		if(phase)
			swing_arm("arm_a", forward, 0, half_step)
			swing(held_item_of("arm_b", source.dir), -forward, 0, half_step)
	else
		// Z przodu i z tyłu: unosi się jedna noga i ręka po przeciwnej stronie
		swing(phase ? "leg_a" : "leg_b", 0, 1, half_step)
		swing_arm(phase ? "arm_b" : "arm_a", 0, 1, half_step)

/datum/component/walk_animation/proc/on_dir_change(mob/living/carbon/human/source, old_dir, new_dir)
	SIGNAL_HANDLER

	update_side_leg(new_dir)

/// Z boku maska "leg_b" pokrywa się z "leg_a", więc w spoczynku ta noga jest ukryta; z przodu i z tyłu zawsze widoczna.
/datum/component/walk_animation/proc/update_side_leg(new_dir)
	var/obj/effect/overlay/walk_limb/leg = limbs["leg_b"]
	var/target_alpha = (new_dir & (EAST|WEST)) ? 0 : 255
	if(leg.alpha != target_alpha)
		animate(leg, alpha = target_alpha, pixel_w = 0, pixel_z = 0, time = 0)

/// Fragment z przedmiotem z dłoni, która w danym widoku należy do ręki "arm_a" lub "arm_b".
/// Prawa dłoń to "arm_a" przy widoku z przodu (lewa strona ekranu) i na wschód (ręka bliżej patrzącego).
/datum/component/walk_animation/proc/held_item_of(arm, facing)
	var/right_is_a = (facing & (EAST|WEST)) ? (facing & EAST) : (facing & SOUTH)
	return ((arm == "arm_a") == !!right_is_a) ? "hand_2" : "hand_1"

/// Rusza ręką razem z trzymanym w niej przedmiotem.
/datum/component/walk_animation/proc/swing_arm(arm, x, y, half_step)
	var/mob/living/carbon/human/H = parent
	swing(arm, x, y, half_step)
	swing(held_item_of(arm, H.dir), x, y, half_step)

/// Przesuwa fragment o (x, y) pikseli i wraca na miejsce w czasie jednego kroku.
/datum/component/walk_animation/proc/swing(state, x, y, half_step)
	var/obj/effect/overlay/limb = limbs[state]
	animate(limb, pixel_w = x, pixel_z = y, time = half_step, easing = SINE_EASING | EASE_OUT)
	animate(pixel_w = 0, pixel_z = 0, time = half_step, easing = SINE_EASING | EASE_IN)

/// Fragment ciała: obraz moba z bufora przycięty maską.
/// Bufor zawiera już kolor, przezroczystość i obrót moba, więc nie dziedziczymy ich drugi raz.
/obj/effect/overlay/walk_limb
	name = ""
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE | TILE_BOUND
	vis_flags = VIS_INHERIT_ID

/// Przedmiot z jednej dłoni jako kopia nakładki, bez przycinania.
/// Dziedziczy kierunek, kolor, przezroczystość i obrót moba, tak jak zwykła nakładka.
/obj/effect/overlay/walk_held
	name = ""
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = KEEP_APART | PIXEL_SCALE | TILE_BOUND
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_DIR

/// Maska fragmentu ciała. Niewidoczna, rysuje się tylko do własnego bufora.
/obj/effect/overlay/walk_mask
	name = ""
	icon = 'aquila/icons/mob/walk_masks.dmi'
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	vis_flags = VIS_INHERIT_DIR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
