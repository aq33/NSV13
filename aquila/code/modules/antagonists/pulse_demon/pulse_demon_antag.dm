// AQUILA - demon impulsu: antagonista, cele, serce i tworzenie z ducha (port z ParadiseSS13)

/datum/antagonist/pulse_demon
	name = "Demon impulsu"
	roundend_category = "demony impulsu"
	antagpanel_category = "Demon impulsu"
	banning_key = ROLE_PULSE_DEMON
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

/datum/antagonist/pulse_demon/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/pulse_demon/greet()
	var/list/greeting = list()
	greeting += "<span class='big bold'>Jesteś demonem impulsu!</span>"
	greeting += "<b>Jesteś prądem, który żyje w kablach statku.</b> Widzisz wszystkie kable na swoim poziomie, nawet przez ściany."
	greeting += "<b>1. Prąd to życie.</b> Ruszasz się tylko po kablach. Dopóki w kablu, APC albo SMES-ie, w którym siedzisz, jest prąd, leczysz się. Bez prądu tracisz zdrowie (panel Status, „Zasilanie”)."
	greeting += "<b>2. Przejmuj APC.</b> Wejdź po kablu na pole z APC, a wskoczysz do środka i zaczniesz je przejmować (20 s). W APC wysysasz z ogniwa energię na zdolności."
	greeting += "<b>3. Steruj pomieszczeniem.</b> Siedząc w przejętym APC, klikasz maszyny w jego pomieszczeniu jak SI: drzwi (Shift/Ctrl/Alt+klik), konsole, kamery, holopad, radio, boty, cyborgi w stacji ładującej. Kliknięcie przejętego APC zawsze zabiera cię z powrotem."
	greeting += "<b>4. Kupuj zdolności.</b> Każde przejęte APC to punkt do wydania. <b>Alt+klik na przycisku zdolności</b> kupuje ją albo ulepsza. Przycisk „Menu ulepszeń” daje ulepszenia ciała (Alt+klik pokazuje opisy)."
	greeting += "<b>5. Uważaj na EMP i jony</b>: tylko one robią ci poważną krzywdę. Mówić możesz tylko przez radio, holopad albo przejętego cyborga, a „Demoniczny szept” sięga do umysłu każdego w zasięgu wzroku."
	to_chat(owner.current, greeting.Join("<br>"))
	owner.announce_objectives()

/datum/antagonist/pulse_demon/proc/forge_objectives()
	for(var/objective_type in list(/datum/objective/pulse_demon/infest, /datum/objective/pulse_demon/drain, /datum/objective/pulse_demon/tamper))
		var/datum/objective/objective = new objective_type
		objective.owner = owner
		objectives += objective
		log_objective(owner, objective.explanation_text)

/datum/objective/pulse_demon

/// Żywe demony impulsu właścicieli celu
/datum/objective/pulse_demon/proc/get_demons()
	. = list()
	for(var/datum/mind/M as anything in get_owners())
		if(istype(M.current, /mob/living/simple_animal/pulse_demon) && !QDELETED(M.current))
			. += M.current

/datum/objective/pulse_demon/infest
	name = "Przejmij APC"
	/// Ile APC trzeba przejąć: 15, 20 albo 25
	var/amount = 0

/datum/objective/pulse_demon/infest/New()
	amount = rand(3, 5) * 5
	explanation_text = "Przejmij [amount] APC."
	return ..()

/datum/objective/pulse_demon/infest/check_completion()
	var/hijacked = 0
	for(var/mob/living/simple_animal/pulse_demon/demon as anything in get_demons())
		hijacked += length(demon.hijacked_apcs)
	return hijacked >= amount || ..()

/datum/objective/pulse_demon/drain
	name = "Wyssij prąd"
	/// Ile energii trzeba wyssać, od 500 kJ do 5 MJ
	var/amount = 0

/datum/objective/pulse_demon/drain/New()
	amount = rand(1, 10) * 500000
	explanation_text = "Wyssij łącznie [display_joules(amount)] energii."
	return ..()

/datum/objective/pulse_demon/drain/check_completion()
	var/drained = 0
	for(var/mob/living/simple_animal/pulse_demon/demon as anything in get_demons())
		drained += demon.charge_drained
	return drained >= amount || ..()

/// Wystarczy przetrwać z co najmniej jednym przejętym APC
/datum/objective/pulse_demon/tamper
	name = "Psuj maszyny"
	explanation_text = "Siej zamęt wśród maszyn w pomieszczeniach z przejętymi APC i broń się przed każdym, kto spróbuje cię powstrzymać."

/datum/objective/pulse_demon/tamper/check_completion()
	var/list/demons = get_demons()
	if(!length(demons))
		return ..()
	for(var/mob/living/simple_animal/pulse_demon/demon as anything in demons)
		if(!length(demon.hijacked_apcs) || !demon.mind?.active || demon.stat == DEAD)
			return ..()
	return TRUE

// Wieczny rozrusznik - łup z demona. Zjedzony daje odporność na prąd i ładuje ogniwa przy sobie.

/obj/item/organ/heart/pulse_demon
	name = "perpetual pacemaker"
	desc = "It still beats furiously, thousands of bright lights shine within it."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = COLOR_YELLOW
	decay_factor = 0
	light_color = "#bbbb00"

/obj/item/organ/heart/pulse_demon/Initialize(mapload)
	. = ..()
	set_light(13, 2)

/obj/item/organ/heart/pulse_demon/update_icon()
	return // zawsze bije

/obj/item/organ/heart/pulse_demon/Stop()
	return FALSE

/obj/item/organ/heart/pulse_demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] podnosi [src] do ust i wgryza się w to zębami!</span>", \
						"<span class='danger'>Ogarnia cię nienaturalny głód. Podnosisz [src] do ust i pożerasz!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/pulse_demon/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	ADD_TRAIT(M, TRAIT_SHOCKIMMUNE, REF(src))
	set_light(3, 2)
	to_chat(M, "<span class='userdanger'>Czujesz, jak przez twoje żyły płynie prąd... elektryczność nie może ci już zaszkodzić!</span>")

/obj/item/organ/heart/pulse_demon/Remove(mob/living/carbon/M, special = 0)
	REMOVE_TRAIT(M, TRAIT_SHOCKIMMUNE, REF(src))
	set_light(13, 2)
	return ..()

/obj/item/organ/heart/pulse_demon/on_life()
	. = ..()
	if(!owner)
		return
	for(var/obj/item/stock_parts/cell/cell_to_charge in owner.GetAllContents())
		var/newcharge = min(0.05 * cell_to_charge.maxcharge + cell_to_charge.charge, cell_to_charge.maxcharge)
		if(cell_to_charge.charge < newcharge)
			cell_to_charge.charge = newcharge
			if(isobj(cell_to_charge.loc))
				var/obj/cell_location = cell_to_charge.loc
				cell_location.update_icon() // wskaźniki naładowania itp.
			cell_to_charge.update_icon()

// Tworzenie z ducha

/// Kable z prądem na odsłoniętej podłodze w maintenance na statku, a gdy takich brak, dowolne kable z prądem na statku
/proc/pulse_demon_spawn_locations()
	. = list()
	var/list/fallback = list()
	for(var/datum/powernet/P as anything in SSmachines.powernets)
		if(P.avail < PULSEDEMON_REQUIRED_POWER)
			continue // sieć bez prądu się nie nadaje
		for(var/obj/structure/cable/C as anything in P.cables)
			if(!is_station_level(C.z))
				continue
			var/turf/open/floor/F = C.loc
			if(!istype(F))
				continue
			if(!F.intact && istype(get_area(F), /area/maintenance))
				. |= F
			else if(!length(.))
				fallback |= F
	if(!length(.))
		return fallback

/// Tworzy demona na danym polu i daje mu gracza
/proc/create_pulse_demon(key, turf/spawn_loc, give_antag = TRUE)
	var/mob/living/simple_animal/pulse_demon/demon = new(spawn_loc)
	var/datum/mind/player_mind = new /datum/mind(key)
	player_mind.active = TRUE
	player_mind.transfer_to(demon)
	player_mind.assigned_role = ROLE_PULSE_DEMON
	player_mind.special_role = ROLE_PULSE_DEMON
	if(give_antag)
		player_mind.add_antag_datum(/datum/antagonist/pulse_demon)
	return demon
