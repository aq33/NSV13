//Healer
/mob/living/simple_animal/hostile/guardian/healer
	a_intent = INTENT_HARM
	friendly = "leczy"
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage = 15
	playstyle_string = "<span class='holoparasite'>Jako typ <b>support</b> możesz przełączyć swoje podstawowe ataki w tryb leczenia. Ponadto alt-kliknięcie sąsiedniego obiektu lub istoty po chwili przenosi go do twojego nadajnika bluespace.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Ordynatora, potężną siłę życia... i śmierci.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony karp wsparcia. To kleptokarp!</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Moduły wsparcia aktywne. Rój holoparazytów aktywny.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się mieć moce regeneracyjne, a przy tym jest silna.</span>"
	toggle_button_type = /atom/movable/screen/guardian/ToggleMode
	var/obj/structure/receiving_pad/beacon
	var/beacon_cooldown = 0
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/healer/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/get_stat_tab_status()
	var/list/tab_data = ..()
	if(beacon_cooldown >= world.time)
		tab_data["Odnowienie radiolatarni"] = GENERATE_STAT_TEXT("[DisplayTimeText(beacon_cooldown - world.time)]")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(is_deployed() && toggle && iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(-5)
		C.adjustFireLoss(-5)
		C.adjustOxyLoss(-5)
		C.adjustToxLoss(-5, FALSE, FALSE)
		var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(C))
		if(guardiancolor)
			H.color = guardiancolor
		if(C == summoner)
			update_health_hud()
			med_hud_set_health()
			med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			speed = 0
			damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
			melee_damage = 15
			to_chat(src, "<span class='danger'><B>Przełączasz się w tryb bojowy.</span></B>")
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			speed = 1
			damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			melee_damage = 0
			to_chat(src, "<span class='danger'><B>Przełączasz się w tryb leczenia.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>Musisz wrócić do użytkownika, by zmienić tryb!</span></B>")


/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."

	if(beacon_cooldown >= world.time)
		to_chat(src, "<span class='danger'><B>Twoja moc się odnawia. Między rozstawieniem nadajników musisz odczekać pięć minut.</span></B>")
		return

	var/turf/beacon_loc = get_turf(src.loc)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, src)

	to_chat(src, "<span class='danger'><B>Nadajnik rozstawiony! Możesz teraz przenosić do niego cele i obiekty, w tym swojego użytkownika, za pomocą Alt+kliknięcia.</span></B>")

	beacon_cooldown = world.time + 3000

/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A receiving zone for bluespace teleportations."
	icon_state = "light_on-w"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/receiving_pad/New(loc, mob/living/simple_animal/hostile/guardian/healer/G)
	. = ..()
	if(G.guardiancolor)
		add_atom_colour(G.guardiancolor, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message("[src] vanishes!")
	qdel(src)

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		to_chat(src, "<span class='danger'><B>Musisz się zmaterializować, by przenieść cel!</span></B>")
		return
	if(!beacon)
		to_chat(src, "<span class='danger'><B>Musisz mieć rozstawiony nadajnik, by przenosić rzeczy!</span></B>")
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='danger'><B>Musisz stać obok celu!</span></B>")
		return
	if(A.anchored)
		to_chat(src, "<span class='danger'><B>Cel nie może być zakotwiczony!</span></B>")
		return

	var/turf/T = get_turf(A)
	if(beacon.get_virtual_z_level() != T.get_virtual_z_level())
		to_chat(src, "<span class='danger'><B>Nadajnik jest za daleko, by się do niego przenieść!</span></B>")
		return

	to_chat(src, "<span class='danger'><B>Zaczynasz przenosić [A].</span></B>")
	A.visible_message("<span class='danger'>[A] zaczyna słabo świecić!</span>", \
	"<span class='userdanger'>Zaczynasz słabo świecić i czujesz się dziwnie nieważki!</span>")
	do_attack_animation(A)

	if(!do_mob(src, A, 60)) //now start the channel
		to_chat(src, "<span class='danger'><B>Musisz stać w miejscu!</span></B>")
		return

	new /obj/effect/temp_visual/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] znika w błysku światła!</span>", \
	"<span class='userdanger'>Błysk światła przesłania ci widok!</span>")
	do_teleport(A, beacon, 0, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(A))
