// Port BeeStation/BeeStation-Hornet#11938: podpowiedzi kontekstowe dla obiektów.
// Teksty po polsku i dopasowane do naszego zachowania. Różnice względem Bee:
// - zamiast trybu walki i prawego przycisku (BeeStation#11899) są nasze intencje, Alt-klik i tryby przedmiotów;
// - stany ramy komputera według naszego buildandrepair.dm (liczby zamiast FRAME_COMPUTER_STATE_*);
// - pominięte typy, których u nas nie ma (holoparasite, mentorhelp, nowy APC i nowy alarm powietrza).

// =====================================================
// Proste podpowiedzi „kliknij ręką” (cache bez wywoływania add_context_self)
// =====================================================
SCREENTIP_ATTACK_HAND(/obj/machinery/airlock_sensor, "Użyj")
SCREENTIP_ATTACK_HAND(/obj/machinery/aug_manipulator, "Użyj")
SCREENTIP_ATTACK_HAND(/obj/machinery/clonepod, "Obejrzyj")
SCREENTIP_ATTACK_HAND(/obj/machinery/computer/arcade/amputation, "Użyj")
SCREENTIP_ATTACK_HAND(/obj/machinery/computer/camera_advanced, "Użyj")
SCREENTIP_ATTACK_HAND(/obj/machinery/defibrillator_mount, "Weź łopatki")
SCREENTIP_ATTACK_HAND(/obj/machinery/dish_drive, "Wyjmij")
SCREENTIP_ATTACK_HAND(/obj/machinery/ecto_sniffer, "Przełącz")
SCREENTIP_ATTACK_HAND(/obj/machinery/firealarm, "Naciśnij")
// W Bee makro miało literówkę (/obj/machinery/attack_hand)
SCREENTIP_ATTACK_HAND(/obj/machinery/harvester, "Otwórz lub zamknij")
SCREENTIP_ATTACK_HAND(/obj/machinery/wish_granter, "Użyj")

// =====================================================
// Maszyny
// =====================================================
/obj/machinery/add_context_self(datum/screentip_context/context, mob/user)
	if (machine_stat & BROKEN)
		return

	context.add_left_click_tool_action("[panel_open ? "Zamknij" : "Otwórz"] panel serwisowy", TOOL_SCREWDRIVER)
	if (panel_open && circuit)
		context.add_left_click_tool_action("Majstruj przy kablach", TOOL_MULTITOOL)
		context.add_left_click_tool_action("Przetnij kable", TOOL_WIRECUTTER)

	if(can_be_unfasten_wrench() || !anchored)
		context.add_left_click_tool_action("[anchored ? "Odkręć od podłogi" : "Przykręć do podłogi"]", TOOL_WRENCH)

/// Rury i urządzenia atmosferyczne nie mają panelu serwisowego jak zwykłe maszyny
/obj/machinery/atmospherics/add_context_self(datum/screentip_context/context, mob/user)
	return

/obj/machinery/button/add_context_self(datum/screentip_context/context, mob/user)
	if (length(req_access) || length(req_one_access) || req_access_txt != "0" || req_one_access_txt != "0")
		context.add_access_context("Wymagany dostęp", allowed(user))
	if (context.accept_silicons())
		if (!panel_open)
			context.add_attack_hand_action("Aktywuj")
		return
	if (panel_open)
		if(device || board)
			context.add_attack_hand_action("Wyjmij elektronikę")
		else
			context.add_attack_hand_action("Zmień wygląd")
	else
		context.add_attack_hand_action("Naciśnij")
	context.add_left_click_item_action("Zhakuj", /obj/item/card/emag)

/obj/machinery/cell_charger/add_context_self(datum/screentip_context/context, mob/user)
	if (charging)
		context.add_attack_hand_action("Wyjmij ogniwo")
	if (!panel_open)
		context.add_left_click_item_action("Naładuj", /obj/item/stock_parts/cell)
	if (!charging)
		context.add_generic_deconstruction_actions(src)
		context.add_generic_unfasten_actions(src, TRUE)

/obj/machinery/computer/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_attack_hand_action("Użyj")
	if(circuit && !(flags_1 & NODECONSTRUCT_1))
		context.add_left_click_tool_action("Rozmontuj", TOOL_SCREWDRIVER)

/obj/machinery/igniter/add_context_self(datum/screentip_context/context, mob/user)
	context.add_generic_deconstruction_actions(src)
	if (!panel_open)
		context.add_attack_hand_action("[on ? "Wyłącz" : "Włącz"]")

/obj/machinery/iv_drip/add_context_self(datum/screentip_context/context, mob/user)
	if (attached)
		context.add_attack_hand_action("Odłącz od: [attached.name]")
	else if (beaker)
		context.add_attack_hand_action("Wyjmij pojemnik")
	else
		context.add_attack_hand_action("Zmień tryb")

/obj/machinery/launchpad/briefcase/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_attack_hand_action("Podnieś")
	context.add_left_click_item_action("Połącz", /obj/item/launchpad_remote)

/obj/machinery/pdapainter/add_context_self(datum/screentip_context/context, mob/user)
	if(storedpda || storedid)
		context.add_attack_hand_action("Pomaluj")
		context.add_alt_click_action("Wyjmij")
	else
		context.add_left_click_item_action("Włóż", /obj/item/modular_computer/tablet/pda)
		context.add_left_click_item_action("Włóż", /obj/item/card/id)
	if (machine_stat & BROKEN)
		context.add_left_click_tool_action("Napraw", TOOL_WELDER)
	context.add_generic_unfasten_actions(src)

/obj/machinery/airalarm/add_context_self(datum/screentip_context/context, mob/user)
	context.add_alt_click_action("Zablokuj lub odblokuj")
	switch(buildstage)
		if(2)
			context.add_left_click_tool_action("[panel_open ? "Zamknij" : "Otwórz"] panel", TOOL_SCREWDRIVER)
			if(panel_open)
				context.add_left_click_tool_action("Przetnij kable", TOOL_WIRECUTTER)
		if(1)
			context.add_left_click_tool_action("Wyjmij elektronikę", TOOL_CROWBAR)
			context.add_left_click_item_action("Podłącz kable", /obj/item/stack/cable_coil)
		if(0)
			context.add_left_click_tool_action("Zdejmij ze ściany", TOOL_WRENCH)

/obj/machinery/power/apc/add_context_self(datum/screentip_context/context, mob/user)
	context.add_alt_click_action("Zablokuj lub odblokuj panel")
	if (context.accept_silicons())
		context.add_ctrl_click_action("Przełącz zasilanie")

// Drzwi
/obj/machinery/door/airlock/add_context_self(datum/screentip_context/context, mob/user)
	if (machine_stat & BROKEN)
		return

	if (context.accept_silicons())
		context.add_left_click_action("Panel sterowania", "Zablokowane", canAIControl(user))
		context.add_shift_click_action("Otwórz", (lights && locked) ? "Zaryglowane" : null, (!lights || !locked) && canAIControl(user))
		context.add_ctrl_click_action("[locked ? "Podnieś" : "Opuść"] rygle", "Zablokowane", canAIControl(user))
		context.add_alt_click_action("[secondsElectrified ? "Wyłącz" : "Włącz"] prąd", "Zablokowane", canAIControl(user))
		context.add_ctrl_shift_click_action("[emergency ? "Wyłącz" : "Włącz"] dostęp awaryjny", "Zablokowane", canAIControl(user))
	else
		context.add_left_click_action("Otwórz", (lights && locked) ? "Zaryglowane" : null, (!lights || !locked))

	if(!isliving(user))
		return

	context.add_left_click_tool_action("[panel_open ? "Zamknij" : "Otwórz"] panel serwisowy", TOOL_SCREWDRIVER)
	if (panel_open)
		// AIRLOCK_SECURITY_IRON, _PLASTEEL_I i _PLASTEEL_O (zdefiniowane i odefiniowane w airlock.dm)
		if (security_level in list(1, 3, 5))
			context.add_left_click_tool_action("Przetnij osłonę", TOOL_WELDER)
		context.add_left_click_tool_action("Majstruj przy kablach", TOOL_MULTITOOL)
		context.add_left_click_tool_action("Przetnij kable", TOOL_WIRECUTTER)
	if (!hasPower())
		context.add_left_click_tool_action("Podważ", TOOL_CROWBAR)
		return

	context.add_left_click_tool_action("Zaspawaj lub napraw", TOOL_WELDER)

	if (length(req_access) || length(req_one_access) || req_access_txt != "0" || req_one_access_txt != "0")
		context.add_access_context("Wymagany dostęp", allowed(user))

/obj/machinery/door/firedoor/add_context_self(datum/screentip_context/context, mob/user)
	if (welded)
		if (!boltslocked)
			context.add_left_click_tool_action("Odkręć", TOOL_WRENCH)
			context.add_left_click_tool_action("Napraw rygle", TOOL_SCREWDRIVER)
		else
			context.add_left_click_tool_action("Rozmontuj", TOOL_SCREWDRIVER)
		context.add_left_click_tool_action("Rozspawaj", TOOL_WELDER)
	else
		if (density)
			context.add_left_click_tool_action("Podważ", TOOL_CROWBAR)
		else
			context.add_left_click_tool_action("Zamknij", TOOL_CROWBAR)
		context.add_left_click_tool_action("Zaspawaj", TOOL_WELDER)

// Atmosfera
/obj/machinery/atmospherics/components/binary/pump/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalne ciśnienie")

/obj/machinery/atmospherics/components/binary/passive_gate/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalne ciśnienie")

/obj/machinery/atmospherics/components/binary/pressure_valve/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalne ciśnienie")

/obj/machinery/atmospherics/components/binary/volume_pump/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalny przepływ")

/obj/machinery/atmospherics/components/binary/temperature_gate/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalna temperatura")

/obj/machinery/atmospherics/components/binary/temperature_pump/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalny transfer ciepła")

/obj/machinery/atmospherics/components/trinary/filter/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalny przepływ")

/obj/machinery/atmospherics/components/unary/outlet_injector/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Maksymalny przepływ")

/obj/machinery/atmospherics/components/unary/thermomachine/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("Skrajna temperatura")

/obj/machinery/atmospherics/components/unary/cryo_cell/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("[on ? "Wyłącz" : "Włącz"]")
	context.add_alt_click_action("[state_open ? "Zamknij" : "Otwórz"] drzwi")

// =====================================================
// Konstrukcje
// =====================================================
/obj/structure/frame/computer/add_context_self(datum/screentip_context/context, mob/user)
	switch(state)
		if(0)
			context.add_left_click_tool_action("Przykręć", TOOL_WRENCH)
			context.add_left_click_tool_action("Rozspawaj ramę", TOOL_WELDER)
		if(1)
			context.add_left_click_tool_action("Odkręć", TOOL_WRENCH)
			if(circuit)
				context.add_left_click_tool_action("Wyjmij płytkę", TOOL_CROWBAR)
				context.add_left_click_tool_action("Zamocuj płytkę", TOOL_SCREWDRIVER)
			else
				context.add_left_click_item_action("Włóż płytkę", /obj/item/circuitboard/computer)
		if(2)
			context.add_left_click_tool_action("Odmocuj płytkę", TOOL_SCREWDRIVER)
			context.add_left_click_item_action("Podłącz kable", /obj/item/stack/cable_coil)
		if(3)
			context.add_left_click_tool_action("Wytnij kable", TOOL_WIRECUTTER)
			context.add_left_click_item_action("Włóż szybę", /obj/item/stack/sheet/glass)
		if(4)
			context.add_left_click_tool_action("Wyjmij szybę", TOOL_CROWBAR)
			context.add_left_click_tool_action("Dokończ", TOOL_SCREWDRIVER)

/obj/structure/closet/add_context_self(datum/screentip_context/context, mob/user)
	if(secure && !broken && !opened)
		context.add_alt_click_action("[locked ? "Odblokuj" : "Zablokuj"]")
	if(!welded)
		context.add_left_click_action("[opened ? "Zamknij" : "Otwórz"]")

	if(opened)
		context.add_left_click_tool_action("Rozmontuj", TOOL_WELDER)
	else
		if(!welded && can_weld_shut)
			context.add_left_click_tool_action("Zaspawaj", TOOL_WELDER)
		else if(welded)
			context.add_left_click_tool_action("Rozspawaj", TOOL_WELDER)

	if(anchorable)
		context.add_left_click_tool_action("[anchored ? "Odkręć" : "Przykręć"]", TOOL_WRENCH)

/obj/structure/table_frame/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_left_click_tool_action("Rozmontuj", TOOL_WRENCH)
	context.add_left_click_item_action("Dokończ stół", /obj/item/stack)

/turf/closed/wall/r_wall/add_context_self(datum/screentip_context/context, mob/user)
	switch (d_state)
		if (INTACT)
			context.add_left_click_tool_action("Rozbieraj", TOOL_WIRECUTTER)
		if (SUPPORT_LINES)
			context.add_left_click_tool_action("Rozbieraj", TOOL_SCREWDRIVER)
			context.add_left_click_tool_action("Składaj", TOOL_WIRECUTTER)
		if (COVER)
			context.add_left_click_tool_action("Rozbieraj", TOOL_WELDER)
			context.add_left_click_tool_action("Składaj", TOOL_SCREWDRIVER)
		if (CUT_COVER)
			context.add_left_click_tool_action("Rozbieraj", TOOL_CROWBAR)
			context.add_left_click_tool_action("Składaj", TOOL_WELDER)
		if (ANCHOR_BOLTS)
			context.add_left_click_tool_action("Rozbieraj", TOOL_WRENCH)
			context.add_left_click_tool_action("Składaj", TOOL_SCREWDRIVER)
		if (SUPPORT_RODS)
			context.add_left_click_tool_action("Rozbieraj", TOOL_WELDER)
			context.add_left_click_tool_action("Składaj", TOOL_WRENCH)
		if (SHEATH)
			context.add_left_click_tool_action("Rozbieraj", TOOL_CROWBAR)
			context.add_left_click_tool_action("Składaj", TOOL_WELDER)

/obj/structure/blob/add_context_self(datum/screentip_context/context, mob/user)
	if (!isovermind(user))
		return

	if(istype(src, /obj/structure/blob/normal))
		context.add_ctrl_click_action("Stwórz silnego bloba")

	if(istype(src, /obj/structure/blob/shield) && !istype(src, /obj/structure/blob/shield/reflective))
		context.add_ctrl_click_action("Stwórz odbijającego bloba")

	if(point_return >= 0)
		context.add_alt_click_action("Usuń bloba")

/obj/effect/hallucination/simple/bluespace_stream/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_attack_hand_action("Teleportuj się")

// =====================================================
// Przedmioty
// =====================================================
/obj/item/stack/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_attack_self_action("Tworzenie z materiału")
	context.add_alt_click_action("Podziel stos")

/obj/item/stack/rods/add_context_self(datum/screentip_context/context, mob/user)
	..()
	context.add_left_click_tool_action("Przetop na arkusz", TOOL_WELDER)

/obj/item/clothing/under/add_context_self(datum/screentip_context/context, mob/user)
	if(istype(context.held_item, /obj/item/clothing/accessory) && !attached_accessory)
		var/obj/item/clothing/accessory/accessory = context.held_item
		if(accessory.can_attach_accessory(src, user))
			context.add_left_click_action("Przypnij dodatek")

	if(has_sensor == BROKEN_SENSORS)
		context.add_left_click_item_action("Napraw czujniki", /obj/item/stack/cable_coil)

	if(attached_accessory)
		context.add_alt_click_action("Odepnij dodatek")
	else if(can_adjust)
		context.add_alt_click_action(adjusted == ALT_STYLE ? "Noś normalnie" : "Noś luźno")

/obj/item/reagent_containers/syringe/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	if(!target.reagents && !isliving(target))
		return
	context.add_left_click_action("Wstrzyknij")
	context.add_right_click_action("Pobierz")

/obj/item/healthanalyzer/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	if (!isliving(target))
		return
	context.add_left_click_action(scanmode ? "Zbadaj chemikalia" : "Zbadaj zdrowie")
	context.add_attack_self_action("Przełącz tryb skanowania")

// =====================================================
// Mobki
// =====================================================
/// Jak w Bee: tryb walki i prawy przycisk; w starym trybie intencji podpowiedź zależy od wybranej intencji
/mob/living/carbon/add_context_self(datum/screentip_context/context, mob/user)
	if (!isnull(context.held_item) || !ishuman(user))
		return

	if(user.uses_legacy_intents())
		switch(user.a_intent)
			if(INTENT_HARM)
				context.add_left_click_action("Atakuj")
			if(INTENT_GRAB)
				context.add_left_click_action("Chwyć")
			if(INTENT_DISARM)
				if (user != src)
					context.add_left_click_action("Popchnij lub rozbrój")
			if(INTENT_HELP)
				add_help_context(context, user)
		return

	if(user.combat_mode)
		context.add_left_click_action("Atakuj")
	else
		add_help_context(context, user)
	if (user != src)
		context.add_right_click_action("Popchnij lub rozbrój")
		context.add_ctrl_click_action("Chwyć")

/mob/living/carbon/proc/add_help_context(datum/screentip_context/context, mob/user)
	if (user == src)
		context.add_left_click_action("Sprawdź obrażenia")
	else if ((health < 0 || HAS_TRAIT(src, TRAIT_FAKEDEATH)) && !(mobility_flags & MOBILITY_STAND))
		context.add_left_click_action("Reanimuj (CPR)")
	else if (!(mobility_flags & MOBILITY_STAND))
		context.add_left_click_action("Potrząśnij")
	else
		switch(user.zone_selected)
			if(BODY_ZONE_HEAD)
				context.add_left_click_action("Pogłaszcz po głowie")
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				context.add_left_click_action("Uściśnij dłoń")
			else
				context.add_left_click_action("Przytul")

/// W Bee przez sygnał z kontrolera AI psa; u nas pies jest prostym mobem, więc bezpośrednio
/mob/living/simple_animal/pet/dog/add_context_self(datum/screentip_context/context, mob/user)
	if (!isnull(context.held_item) || !ishuman(user))
		return
	context.add_left_click_action(user.combat_mode ? "Uderz" : "Pogłaszcz")

// =====================================================
// Elementy
// =====================================================
/// Podpowiedź narzędzia dla jedzenia, które da się pokroić lub rozwałkować
/datum/element/processable/proc/on_requesting_context_from_item(datum/source, datum/screentip_context/context, mob/user)
	SIGNAL_HANDLER
	// Plasterek pizzy ma w Bee i u nas liczbę zamiast typu wyniku (w tg: /obj/item/stack/sheet/pizza)
	if(!ispath(result_atom_type))
		return
	context.add_left_click_tool_action("[screentip_verb]: [initial(result_atom_type.name)]", tool_behaviour)
