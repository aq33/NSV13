// Przedmioty samouczka: zachowują się jak zwykłe, ale dają znać skryptowi albo nie sięgają poza pokój

/// Latarka, która po włączeniu daje znać skryptowi (zwykła nie woła ..() w attack_self)
/obj/item/flashlight/tutorial

/obj/item/flashlight/tutorial/attack_self(mob/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, user)

/// Słuchawki samouczka: kanały jak u Munitions, ale nic nie wychodzi poza pokój samouczka
/obj/item/radio/headset/munitions/tutorial
	name = "słuchawki treningowe"
	desc = "Słuchawki do ćwiczeń. Kanały działają jak prawdziwe, ale nikt poza tobą ich nie słyszy."

/obj/item/radio/headset/munitions/tutorial/talk_into_impl(atom/movable/M, message, channel, list/spans, datum/language/language, list/message_mods)
	if(!on || !M || !message)
		return
	var/channel_name = channel || RADIO_CHANNEL_COMMON
	if(channel == MODE_DEPARTMENT)
		channel_name = length(channels) ? channels[1] : RADIO_CHANNEL_COMMON
	else if(channel && !(channel in channels))
		to_chat(M, "<span class='warning'>Twoje słuchawki nie mają kanału [channel].</span>")
		return
	to_chat(M, "<span class='radio'>\[[channel_name]\] (ćwiczenia) <b>[M]</b>: [message]</span>")

/// Słuchawki samouczka mają ten kanał (albo to kanał działu, :h)
/obj/item/radio/headset/munitions/tutorial/proc/has_tutorial_channel(channel)
	return channel == MODE_DEPARTMENT || (channel in channels)

/// Autoinjektor, który po wstrzyknięciu daje znać skryptowi: (mob/user, mob/living/target)
/obj/item/reagent_containers/hypospray/medipen/tutorial

/obj/item/reagent_containers/hypospray/medipen/tutorial/inject(mob/living/M, mob/user)
	. = ..()
	if(.)
		SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, user, M)


/// Pager składu do ćwiczeń: zamiast kanału składu pokazuje rozkazy, które ustawia skrypt
/obj/item/squad_pager/tutorial
	name = "pager składu (ćwiczenia)"
	/// Wiadomości od dowódcy składu, od najstarszej
	var/list/tutorial_messages = list()

/obj/item/squad_pager/tutorial/attack_self(mob/user)
	if(!length(tutorial_messages))
		to_chat(user, "<span class='notice'>Brak nowych wiadomości.</span>")
	for(var/message in tutorial_messages)
		to_chat(user, "<span class='sciradio'><b>\[Able\] Dowódca składu:</b> [message]</span>")
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, user)

/// Nowa wiadomość na pagerze, z sygnałem dźwiękowym
/obj/item/squad_pager/tutorial/proc/add_tutorial_message(message)
	tutorial_messages += message
	playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)
	var/mob/holder = loc
	if(istype(holder))
		to_chat(holder, "<span class='notice'>[src] piszczy: nowa wiadomość.</span>")

/// Vendor składu do ćwiczeń: wydaje zestawy bez przydziału do składu i bez wypożyczania
/obj/machinery/squad_vendor/tutorial
	req_one_access = null

/obj/machinery/squad_vendor/tutorial/ui_data(mob/user)
	var/list/data = list()
	data["user_name"] = user ? user.name : "Ćwiczenia"
	data["already_loaned"] = FALSE
	var/list/kits = list()
	for(var/datum/squad_loadout/loadout in loadouts)
		if(loadout.leader_only)
			continue
		kits += list(list("name" = loadout.name, "desc" = loadout.desc, "id" = "\ref[loadout]"))
	data["kits"] = kits
	return data

/obj/machinery/squad_vendor/tutorial/ui_act(action, params)
	if(action != "vend")
		return FALSE
	var/datum/squad_loadout/loadout = locate(params["item_id"]) in loadouts
	if(!loadout || !isliving(usr))
		return FALSE
	var/obj/item/storage/box/squad_kit/box = new(get_turf(src))
	for(var/path in loadout.items)
		if(ispath(path, /obj/item/clothing/under)) // mundur gracz już ma
			continue
		new path(box)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, usr, box)
	return TRUE

/// Cel na strzelnicy: zatrzymuje pociski, nie rozpada się i daje znać skryptowi o trafieniu
/obj/item/target/tutorial
	anchored = TRUE
	density = TRUE
	hp = 100000

/obj/item/target/tutorial/bullet_act(obj/item/projectile/P)
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, P.firer)
	return ..()

/obj/item/target/tutorial/attack_hand(mob/user)
	return // nie zdejmuje się go ze stojaka

/// Działo Gaussa do ćwiczeń: krzesło i stojak stoją w tym samym pokoju (bez piętra niżej), bez statku na overmapie
/obj/machinery/ship_weapon/gauss_gun/tutorial
	/// Gdzie zjeżdża stojak z amunicją
	var/turf/rack_turf
	/// Gdzie zjeżdża krzesło strzelca
	var/turf/chair_turf

/obj/machinery/ship_weapon/gauss_gun/tutorial/get_ship()
	return // nie ma statku, a zwykłe działo co chwilę zgłaszałoby to adminom

/// Łączy działo z krzesłem i miejscem na stojak w pokoju samouczka
/obj/machinery/ship_weapon/gauss_gun/tutorial/proc/link_tutorial(obj/structure/chair/fancy/gauss/chair, turf/rack_spot)
	chair_turf = get_turf(chair)
	add_chair(chair)
	chair.gun = src
	rack_turf = rack_spot
	lower_rack()

/obj/machinery/ship_weapon/gauss_gun/tutorial/lower_rack()
	set waitfor = FALSE
	if(!ammo_rack || !rack_turf)
		return
	ammo_rack.loading = FALSE
	playsound(rack_turf, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	ammo_rack.forceMove(rack_turf)
	ammo_rack.pixel_y = 60
	animate(ammo_rack, pixel_y = 0, time = 4 SECONDS)
	sleep(4 SECONDS)
	if(QDELETED(ammo_rack))
		return
	ammo_rack.visible_message("<span class='notice'>[ammo_rack] clunks into place!</span>")
	playsound(ammo_rack, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, null, "rack_lowered")

/obj/machinery/ship_weapon/gauss_gun/tutorial/lower_chair()
	if(!gunner_chair || gunner_chair.loc != src || !chair_turf)
		return FALSE
	gunner_chair.forceMove(chair_turf)
	var/mob/living/M = gunner
	M.forceMove(chair_turf)
	gunner_chair.buckle_mob(M)
	playsound(chair_turf, 'nsv13/sound/effects/ship/freespace2/crane_2.wav', 100, FALSE)
	gunner_chair.locked = FALSE
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, M, "gunner_left")

/obj/machinery/ship_weapon/gauss_gun/tutorial/set_gunner(mob/user)
	user.forceMove(src)
	gunner = user
	ui_interact(user)
	grant_gunner_actions(user)
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, user, "gunner")

/obj/machinery/ship_weapon/gauss_gun/tutorial/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(action != "camera") // kamera daje znać sama, z show_view()
		SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, usr, action)

/obj/machinery/ship_weapon/gauss_gun/tutorial/show_view(mob/user)
	if(user != gunner)
		return
	to_chat(user, "<span class='notice'>Kamera działa nie ma czego pokazać: samouczek nie jest statkiem w kosmosie.</span>")
	SEND_SIGNAL(src, COMSIG_TUTORIAL_ITEM_USED, user, "camera")

/// Drzwi samouczka: zaryglowane, dopóki gracz nie wykona bieżącego kroku
/obj/machinery/door/airlock/public/glass/tutorial
	name = "drzwi ćwiczeniowe"
	desc = "Otworzą się, gdy wykonasz bieżące polecenie samouczka."
	locked = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
