// AQUILA - balistyka
// Każda broń prochowa ma ukrytą sygnaturę gwintu lufy, która trafia na łuskę i pocisk przy strzale.
// Pocisk może utknąć w ciele jako fragment (bez wpływu na walkę, wyjmuje się go chirurgią usuwania ciał obcych)
// albo zostać zdeformowany na podłodze pod ścianą. Skaner detektywa odczytuje sygnaturę.
// Broń ma też widoczny numer seryjny, który można spiłować śrubokrętem (PPM, 6 s, głośno).
// Obcięcie lufy zmienia sygnaturę.

GLOBAL_LIST_EMPTY(used_ballistic_ids)
GLOBAL_LIST_EMPTY(used_gun_serials)

/// Losuje unikalną sygnaturę gwintu w postaci XXXX-XXXX (bez mylących znaków 0/O i 1/I)
/proc/generate_ballistic_id()
	var/static/alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var/id
	do
		id = ""
		for(var/i in 1 to 8)
			if(i == 5)
				id += "-"
			var/n = rand(1, length(alphabet))
			id += copytext(alphabet, n, n + 1)
	while(GLOB.used_ballistic_ids[id])
	GLOB.used_ballistic_ids[id] = TRUE
	return id

/// Losuje unikalny numer seryjny: prefiks producenta i 7 cyfr
/proc/generate_gun_serial(prefix = "NT")
	var/serial
	do
		var/digits = ""
		for(var/i in 1 to 7)
			digits += "[rand(0, 9)]"
		serial = "[prefix]-[digits]"
	while(GLOB.used_gun_serials[serial])
	GLOB.used_gun_serials[serial] = TRUE
	return serial

// Broń

/obj/item/gun/ballistic
	/// Czy broń dostaje sygnaturę gwintu i numer seryjny
	var/has_ballistic_id = TRUE
	/// Ukryta sygnatura gwintu lufy, odczytywana skanerem
	var/ballistic_id
	/// Prefiks producenta w numerze seryjnym
	var/serial_prefix = "NT"
	/// Widoczny numer seryjny
	var/serial_number
	/// Czy numer seryjny spiłowano
	var/serial_filed = FALSE

/obj/item/gun/ballistic/automatic/toy
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/shotgun/toy
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/bow
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/automatic/laser
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/rocketlauncher
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/revolver/grenadelauncher
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/revolver/mime
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/rifle/boltaction/enchanted
	has_ballistic_id = FALSE
/obj/item/gun/ballistic/tazer
	has_ballistic_id = FALSE

/obj/item/gun/ballistic/Initialize(mapload)
	. = ..()
	if(has_ballistic_id)
		ballistic_id = generate_ballistic_id()
		if(serial_prefix)
			serial_number = generate_gun_serial(serial_prefix)

/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	if(serial_number && get_dist(user, src) <= 1)
		if(serial_filed)
			. += "<span class='warning'>Numer seryjny został spiłowany.</span>"
		else
			. += "Numer seryjny: <b>[serial_number]</b>."

/obj/item/gun/ballistic/sawoff(mob/user)
	. = ..()
	if(. && ballistic_id)
		ballistic_id = generate_ballistic_id() // skrócona lufa, nowe rysy na pociskach

/obj/item/gun/ballistic/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(. || !serial_number)
		return
	if(serial_filed)
		to_chat(user, "<span class='warning'>Numer seryjny [src] jest już spiłowany.</span>")
		return TRUE
	user.visible_message("<span class='warning'>[user] zaczyna zgrzytliwie spiłowywać numer seryjny z [src]!</span>",
		"<span class='notice'>Zaczynasz spiłowywać numer seryjny z [src]...</span>",
		"<span class='hear'>Słyszysz głośne zgrzytanie metalu o metal.</span>")
	playsound(src, 'sound/items/screwdriver2.ogg', 75, TRUE)
	if(!tool.use_tool(src, user, SERIAL_FILE_TIME, volume = 75))
		return TRUE
	if(serial_filed)
		return TRUE
	serial_filed = TRUE
	user.visible_message("<span class='warning'>[user] spiłowuje numer seryjny z [src].</span>",
		"<span class='notice'>Spiłowujesz numer seryjny z [src].</span>")
	return TRUE

// Łuska i pocisk

/obj/item/ammo_casing
	/// Sygnatura broni, z której wystrzelono ten nabój
	var/ballistic_id

/obj/item/projectile
	/// Sygnatura broni, z której wystrzelono pocisk
	var/ballistic_id
	/// Kaliber pocisku, przepisywany z łuski
	var/ballistic_caliber

/obj/item/ammo_casing/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	. = ..()
	if(!leaves_residue || !BB || !istype(fired_from, /obj/item/gun/ballistic))
		return
	var/obj/item/gun/ballistic/G = fired_from
	if(!G.ballistic_id)
		return
	ballistic_id = G.ballistic_id
	BB.ballistic_id = G.ballistic_id
	BB.ballistic_caliber = caliber

/obj/item/projectile/bullet/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(!ballistic_id || nodamage || damage_type != BRUTE || damage < 5)
		return
	if(ishuman(target))
		if(. == BULLET_ACT_BLOCK || blocked >= 100 || !prob(BULLET_FRAGMENT_LODGE_CHANCE))
			return
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/BP = H.get_bodypart(H.check_limb_hit(def_zone))
		if(!BP)
			BP = H.get_bodypart(BODY_ZONE_CHEST)
		if(BP)
			new /obj/item/bullet_fragment(BP, ballistic_id, ballistic_caliber)
	else if(isclosedturf(target) || (isobj(target) && target.density))
		if(prob(BULLET_FRAGMENT_WALL_CHANCE))
			drop_bullet_fragment(target)

/obj/item/projectile/bullet/on_range()
	if(ballistic_id && !nodamage && prob(BULLET_FRAGMENT_RANGE_CHANCE))
		var/turf/T = get_turf(src)
		if(T && !T.density && !isspaceturf(T))
			new /obj/item/bullet_fragment(T, ballistic_id, ballistic_caliber)
	return ..()

/// Zostawia zdeformowaną kulę na wolnym kafelku przed trafioną ścianą lub obiektem
/obj/item/projectile/bullet/proc/drop_bullet_fragment(atom/target)
	var/turf/target_turf = get_turf(target)
	var/turf/T = get_turf(src)
	if(!T || T == target_turf || T.density)
		T = target_turf && starting ? get_step(target_turf, get_dir(target_turf, starting)) : null
	if(!T || T.density || isspaceturf(T))
		return
	new /obj/item/bullet_fragment(T, ballistic_id, ballistic_caliber)

// Fragment pocisku

/obj/item/bullet_fragment
	name = "zdeformowany pocisk"
	desc = "Spłaszczony kawałek metalu, który kiedyś był pociskiem. Na jego boku wciąż widać rysy po gwincie lufy."
	icon = 'icons/obj/shards.dmi'
	icon_state = "tiny"
	color = "#A08A5C"
	w_class = WEIGHT_CLASS_TINY
	/// Sygnatura broni, z której wystrzelono pocisk
	var/ballistic_id
	/// Kaliber pocisku
	var/caliber

/obj/item/bullet_fragment/Initialize(mapload, new_ballistic_id, new_caliber)
	. = ..()
	ballistic_id = new_ballistic_id
	caliber = new_caliber
	if(caliber)
		name = "zdeformowany pocisk ([caliber])"
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)
