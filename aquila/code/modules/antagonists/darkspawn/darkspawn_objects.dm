// AQUILA - darkspawn: przedmioty i obiekty (port z Yogstation)

// Macki cienia wojownika

/obj/item/umbral_tendrils
	name = "umbral tendrils"
	desc = "Masa pulsujących, chitynowych macek z odsłoniętym fioletowym ciałem."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "umbral_tendrils"
	item_state = "umbral_tendrils"
	lefthand_file = 'aquila/icons/mob/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/darkspawn/darkspawn_righthand.dmi'
	hitsound = 'aquila/sound/darkspawn/pass_attack.ogg'
	attack_verb = list("przebija", "chłoszcze", "rozdziera")
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP
	force = 25
	/// Druga macka przy Sigilach dwoistości
	var/obj/item/umbral_tendrils/twin
	/// Sigile rozszczepienia: macki tną też tych obok celu
	var/cleave = FALSE
	COOLDOWN_DECLARE(grab_cooldown)

/obj/item/umbral_tendrils/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	AddComponent(/datum/component/darkspawn_light_eater)
	for(var/obj/item/umbral_tendrils/other in loc)
		if(other != src)
			twin = other
			other.twin = src
			force *= 0.75
			other.force *= 0.75

/obj/item/umbral_tendrils/Destroy()
	var/obj/item/umbral_tendrils/old_twin = twin
	twin = null
	if(old_twin && !QDELETED(old_twin))
		old_twin.twin = null
		qdel(old_twin)
	return ..()

/obj/item/umbral_tendrils/examine(mob/user)
	. = ..()
	if(isobserver(user) || isdarkspawn(user))
		. += "<span class='velvet bold'>Zastosowania:</span>"
		. += "<span class='velvet'><b>Wyważanie śluz:</b> kliknij śluzę, żeby siłą ją otworzyć (15 Psi), a zaryglowaną albo zaspawaną rozbić (30 Psi).</span>"
		. += "<span class='velvet'><b>Rzut mackami:</b> prawy klik wydaje 30 Psi na pocisk lecący do pięciu pól, który przewraca[twin ? " i przyciąga" : ""] pierwszą trafioną istotę.</span>"
		. += "<span class='velvet'>Macki pożerają światło wszystkiego, w co uderzą.</span>"
		. += "<span class='velvet'>Prawym klikiem podważają też śluzy bez zasilania.</span>"
		if(cleave)
			. += "<span class='velvet'>Sigile rozszczepienia: macki tną też wrogów stojących obok celu.</span>"

/obj/item/umbral_tendrils/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(cleave)
		cleave_around(target, user)
	if(twin && !QDELETED(twin) && user.get_active_held_item() == src)
		addtimer(CALLBACK(src, PROC_REF(twin_attack), target, user), 0.2 SECONDS)

/obj/item/umbral_tendrils/proc/twin_attack(mob/living/target, mob/living/user)
	if(QDELETED(twin) || QDELETED(target) || !user.Adjacent(target))
		return
	twin.attack(target, user)

/// Cięcie łukiem: rani wrogów stojących obok celu po stronie rzucającego
/obj/item/umbral_tendrils/proc/cleave_around(mob/living/target, mob/living/user)
	for(var/mob/living/L in orange(1, user))
		if(L == target || L.stat == DEAD || is_team_darkspawn(L))
			continue
		if(get_dist(L, target) > 1)
			continue
		L.apply_damage(force * 0.5, BRUTE, user.zone_selected)
		L.visible_message("<span class='danger'>[user] przy okazji tnie [L] [src]!</span>", "<span class='userdanger'>[user] przy okazji tnie cię [src]!</span>")

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(twin && proximity_flag && !QDELETED(target) && (isstructure(target) || ismachinery(target)) && user.get_active_held_item() == src)
		target.attackby(twin, user)

/// Lewy klik na śluzie: wyważenie albo rozbicie
/obj/item/umbral_tendrils/pre_attack(atom/target, mob/living/user, params)
	if(istype(target, /obj/machinery/door/airlock) && isdarkspawn(user))
		var/obj/machinery/door/airlock/airlock = target
		if(airlock.density)
			INVOKE_ASYNC(src, PROC_REF(force_airlock), airlock, user)
			return FALSE
	return ..()

/// Prawy klik: podważenie śluzy bez zasilania albo rzut mackami
/obj/item/umbral_tendrils/pre_attack_secondary(atom/target, mob/living/user, params)
	if(!isdarkspawn(user))
		return ..()
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		if(airlock.density && !airlock.hasPower() && !airlock.locked && !airlock.welded)
			airlock.open(2)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	tendril_swing(user, target)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Wyrzuca macki, które przewracają pierwszą trafioną istotę
/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, atom/target)
	if(!COOLDOWN_FINISHED(src, grab_cooldown))
		return
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(!darkspawn || darkspawn.psi < 30)
		to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 30 Psi, żeby rzucić mackami!</span>")
		return
	if(isliving(target))
		var/mob/living/L = target
		if(!(L.mobility_flags & MOBILITY_STAND))
			to_chat(user, "<span class='warning'>[L] już leży!</span>")
			return
	darkspawn.spend_psi(30)
	COOLDOWN_START(src, grab_cooldown, 1 SECONDS) // żeby nie wydać przypadkiem całego Psi
	user.visible_message("<span class='warning'>[user] odciąga [src] i wyrzuca je w stronę [target]!</span>", \
		"<span class='velvet'><b>opehhjaoo</b><br>Wyrzucasz macki w stronę [target]!</span>")
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	var/obj/item/projectile/umbral_tendrils/T = new(get_turf(user))
	T.preparePixelProjectile(target, user)
	T.twinned = !!twin
	T.firer = user
	T.fire()

/// Otwiera albo rozbija śluzę
/obj/item/umbral_tendrils/proc/force_airlock(obj/machinery/door/airlock/airlock, mob/living/user)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	if(!darkspawn || !airlock.density)
		return
	if(!airlock.locked && !airlock.welded)
		if(!airlock.hasPower()) // łom daje radę, to macki tym bardziej
			airlock.open(2)
			return
		if(darkspawn.psi < 15)
			to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 15 Psi, żeby siłą otworzyć śluzę!</span>")
			return
		user.visible_message("<span class='warning'>[user] zaczyna siłą otwierać [airlock]!</span>", "<span class='velvet'><b>ueahz</b><br>Zaczynasz siłą otwierać [airlock]...</span>")
		playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		if(!do_after(user, twin ? 5 SECONDS : 7.5 SECONDS, target = airlock))
			return
		if(!airlock.open(2) && airlock.density)
			to_chat(user, "<span class='warning'>Mimo starań [airlock] nie chce się otworzyć!</span>")
			return
		darkspawn.spend_psi(15)
		return
	if(darkspawn.psi < 30)
		to_chat(user, "<span class='warning'>Potrzebujesz co najmniej 30 Psi, żeby rozbić śluzę!</span>")
		return
	user.visible_message("<span class='boldwarning'>[user] zaczyna walić [src] w [airlock]!</span>", \
		"<span class='velvet italics'>Głośno zaczynasz rozbijać [airlock].</span>")
	while(airlock.obj_integrity > airlock.max_integrity * 0.25)
		if(!do_after(user, twin ? rand(4, 6) : rand(8, 10), target = airlock))
			return
		playsound(airlock, 'aquila/sound/darkspawn/pass_smash_door.ogg', 50, TRUE)
		airlock.take_damage(airlock.max_integrity / rand(8, 15))
		to_chat(user, "<span class='velvet bold'>klaj.</span>")
	airlock.ex_act(EXPLODE_DEVASTATE)
	user.visible_message("<span class='boldwarning'>[user] rozbija [airlock]!</span>", "<span class='velvet bold'>KLAJ.</span>")
	darkspawn.spend_psi(30)

/obj/item/projectile/umbral_tendrils
	name = "umbral tendrils"
	icon_state = "cursehand0"
	hitsound = 'aquila/sound/darkspawn/pass_attack.ogg'
	layer = LARGE_MOB_LAYER
	damage = 0
	nodamage = TRUE
	speed = 1
	range = 5
	var/twinned = FALSE
	var/datum/beam/beam

/obj/item/projectile/umbral_tendrils/fire(setAngle)
	if(firer)
		beam = firer.Beam(src, icon_state = "curse0", time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/curse_arm)
	return ..()

/obj/item/projectile/umbral_tendrils/Destroy()
	QDEL_NULL(beam)
	return ..()

/obj/item/projectile/umbral_tendrils/prehit_pierce(atom/target)
	if(isliving(target) && is_team_darkspawn(target))
		return PROJECTILE_PIERCE_PHASE // sojuszników przelatuje
	return ..()

/obj/item/projectile/umbral_tendrils/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(blocked >= 100 || !isliving(target))
		return
	var/mob/living/L = target
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		R.visible_message("<span class='warning'>[name] [firer] uderzają w obudowę [R]!</span>", \
			"<span class='userdanger'>Wykryto silne uderzenie. Rekalibracja układów ruchu.</span>")
		R.playsound_local(R, 'sound/misc/interference.ogg', 25, FALSE)
		playsound(R, 'sound/effects/bang.ogg', 50, TRUE)
		R.Paralyze(4 SECONDS)
		R.adjustBruteLoss(10)
		return
	if(!iscarbon(L))
		return
	playsound(L, 'aquila/sound/darkspawn/pass_attack.ogg', 50, TRUE)
	L.Knockdown(6 SECONDS)
	if(!twinned)
		L.visible_message("<span class='warning'>Macki [firer] uderzają w [L], zbijając go z nóg!</span>", \
			"<span class='userdanger'>Coś zbija cię z nóg!</span>")
	else
		L.Immobilize(0.15 SECONDS) // żeby ruchem nie przerwać przyciągania
		L.throw_at(get_step_towards(firer, L), 7, 2)
		L.visible_message("<span class='warning'>Macki [firer] uderzają w [L] i ciągną go po ziemi!</span>", \
			"<span class='userdanger'>Nagle coś ciągnie cię po podłodze!</span>")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), L, 'aquila/sound/darkspawn/pass_attack.ogg', 50, TRUE), 1)

// Laska skupienia czarnoksiężnika

/obj/item/gun/magic/darkspawn
	name = "channeling staff"
	desc = "Laska z czystej ciemności."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "shadow_staff"
	item_state = "shadow_staff0"
	lefthand_file = 'aquila/icons/mob/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/darkspawn/darkspawn_righthand.dmi'
	fire_sound = 'sound/weapons/emitter2.ogg'
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	slot_flags = NONE
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = /obj/item/ammo_casing/magic/darkspawn
	max_charges = 1
	recharge_rate = 0
	pin = /obj/item/firing_pin
	/// Koszt strzału w Psi
	var/psi_cost = 40
	/// Ulepszenia (STAFF_UPGRADE_*)
	var/effect_flags = NONE

/obj/item/gun/magic/darkspawn/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/magic/darkspawn/examine(mob/user)
	. = ..()
	if(isobserver(user) || isdarkspawn(user))
		. += "<span class='velvet bold'>Zastosowania:</span>"
		. += "<span class='velvet'>Strzał kosztuje [get_psi_cost()] Psi. Pocisk zadaje 35 obrażeń wytrzymałości.</span>"
		if(effect_flags)
			. += "<span class='velvet'>Pocisk dodatkowo:</span>"
			if(effect_flags & STAFF_UPGRADE_HEAL)
				. += "<span class='velvet'>leczy trafionego sojusznika o 30 punktów.</span>"
			if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
				. += "<span class='velvet'>gasi płonącego sojusznika.</span>"
			if(effect_flags & STAFF_UPGRADE_CONFUSION)
				. += "<span class='velvet'>na 4 sekundy dezorientuje trafionego wroga.</span>"
			if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
				. += "<span class='velvet'>pożera światło wszystkiego, w co trafi.</span>"

/obj/item/gun/magic/darkspawn/proc/get_psi_cost()
	return (effect_flags & STAFF_UPGRADE_EFFICIENCY) ? psi_cost * 0.5 : psi_cost

/obj/item/gun/magic/darkspawn/can_shoot()
	var/mob/living/holder = loc
	if(isliving(holder))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(holder)
		if(!darkspawn || darkspawn.psi < get_psi_cost())
			return FALSE
	charges = max_charges // Psi zamiast ładunków
	return ..()

/obj/item/gun/magic/darkspawn/shoot_live_shot(mob/living/user, pointblank = FALSE, atom/pbtarget = null, message = TRUE)
	. = ..()
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	darkspawn?.spend_psi(get_psi_cost())
	charges = max_charges

/obj/item/gun/magic/darkspawn/process_chamber()
	. = ..()
	charges = max_charges

/obj/item/ammo_casing/magic/darkspawn
	projectile_type = /obj/item/projectile/magic/darkspawn
	firing_effect_type = null

/obj/item/ammo_casing/magic/darkspawn/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	var/obj/item/gun/magic/darkspawn/staff = loc
	if(istype(staff) && istype(BB, /obj/item/projectile/magic/darkspawn))
		var/obj/item/projectile/magic/darkspawn/P = BB
		P.effect_flags = staff.effect_flags

/obj/item/projectile/magic/darkspawn
	name = "bolt of nothingness"
	icon = 'aquila/icons/mob/darkspawn/darkspawn_projectiles.dmi'
	icon_state = "staff_blast"
	damage = 35
	damage_type = STAMINA
	nodamage = FALSE
	pass_flags = PASSTABLE | PASSMACHINE
	speed = 2
	/// Ulepszenia laski w chwili strzału
	var/effect_flags = NONE

/obj/item/projectile/magic/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/item/projectile/magic/darkspawn/prehit_pierce(atom/target)
	if(isliving(target) && is_team_darkspawn(target) && !(effect_flags & (STAFF_UPGRADE_HEAL | STAFF_UPGRADE_EXTINGUISH)))
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/magic/darkspawn/on_hit(atom/target, blocked = FALSE)
	if(isliving(target) && is_team_darkspawn(target))
		var/mob/living/M = target
		if(effect_flags & STAFF_UPGRADE_HEAL)
			M.adjustBruteLoss(-30)
			M.adjustFireLoss(-30)
			M.adjustToxLoss(-30)
			M.adjustStaminaLoss(-30)
		if(effect_flags & STAFF_UPGRADE_EXTINGUISH)
			M.ExtinguishMob()
		return BULLET_ACT_HIT // sojusznikom nie robi krzywdy
	. = ..()
	if(isliving(target) && (effect_flags & STAFF_UPGRADE_CONFUSION))
		var/mob/living/M = target
		M.confused = max(M.confused, 4)
	if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, lighteater_act), null)

// Miotacz cieni zwiadowcy

/obj/item/gun/ballistic/bow/shadow_caster
	name = "shadow caster"
	desc = "Łuk z litej ciemności. Wystrzeliwane z niego strzały zdają się wysysać światło z otoczenia."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "shadow_caster"
	item_state = "shadow_caster"
	lefthand_file = 'aquila/icons/mob/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/darkspawn/darkspawn_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	item_flags = ABSTRACT | DROPDEL
	pin = /obj/item/firing_pin
	/// Czas odnowienia strzały
	var/recharge_time = 2 SECONDS

/obj/item/gun/ballistic/bow/shadow_caster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/ballistic/bow/shadow_caster/update_icon()
	. = ..()
	icon_state = initial(icon_state)

/obj/item/gun/ballistic/bow/shadow_caster/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(recharge_arrow)), recharge_time)

/obj/item/gun/ballistic/bow/shadow_caster/attack_self(mob/living/user)
	if(chambered)
		chambered = null
		to_chat(user, "<span class='notice'>Rozpraszasz strzałę.</span>")
	else if(get_ammo())
		to_chat(user, "<span class='notice'>Napinasz cięciwę.</span>")
		playsound(src, 'sound/weapons/bowdraw.ogg', 75, FALSE)
		chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/shadow_caster/attackby(obj/item/I, mob/user, params)
	return

/obj/item/gun/ballistic/bow/shadow_caster/proc/recharge_arrow()
	if(QDELETED(src) || magazine.get_round(TRUE))
		return
	magazine.give_round(new /obj/item/ammo_casing/caseless/arrow/shadow)
	update_icon()

/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/caseless/arrow/shadow
	start_empty = FALSE

/obj/item/ammo_casing/caseless/arrow/shadow
	name = "shadow arrow"
	desc = "Zdaje się wysysać światło z otoczenia."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	projectile_type = /obj/item/projectile/bullet/shadow_arrow

/obj/item/projectile/bullet/shadow_arrow
	name = "shadow arrow"
	icon = 'aquila/icons/mob/darkspawn/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	damage = 25
	armour_penetration = 10
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = -1
	light_color = COLOR_VELVET

/obj/item/projectile/bullet/shadow_arrow/prehit_pierce(atom/target)
	if(isliving(target) && is_team_darkspawn(target))
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/bullet/shadow_arrow/on_hit(atom/target, blocked = FALSE)
	. = ..()
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, lighteater_act), null)

// Pułapki psi zwiadowcy

/obj/structure/trap/darkspawn
	name = "void rune"
	desc = "Dziwne, ulotne cienie splecione w niezwykłe symbole."
	max_integrity = 75
	time_between_triggers = 1 MINUTES
	sparks = FALSE
	checks_antimagic = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	/// Co pułapka robi (widzą to tylko darkspawni)
	var/examine_text

/obj/structure/trap/darkspawn/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/structure/trap/darkspawn/examine(mob/user)
	. = ..()
	if(examine_text && is_team_darkspawn(user))
		. += "<span class='velvet'>Runy oznaczają: [examine_text].</span>"

/obj/structure/trap/darkspawn/on_entered(datum/source, atom/movable/AM)
	if(isliving(AM) && is_team_darkspawn(AM))
		return
	if(istype(AM, /obj/item/projectile)) // przelatujący nad pułapką pocisk jej nie uruchamia
		return
	if(ismob(AM))
		var/mob/M = AM
		if(M.can_block_magic(MAGIC_RESISTANCE_MIND))
			return
	return ..()

/obj/structure/trap/darkspawn/nausea
	time_between_triggers = 15 SECONDS
	examine_text = "mdłości"

/obj/structure/trap/darkspawn/nausea/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE)
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 50, TRUE)

/obj/structure/trap/darkspawn/nausea/trap_effect(mob/living/L)
	L.adjust_disgust(30)
	L.confused = max(L.confused, 6)

/obj/structure/trap/darkspawn/teleport
	charges = 1
	examine_text = "przeniesienie"

/obj/structure/trap/darkspawn/teleport/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/phasein.ogg', 60, TRUE)

/obj/structure/trap/darkspawn/teleport/trap_effect(mob/living/L)
	var/turf/destination = get_safe_random_station_turfs()
	if(destination)
		L.forceMove(destination)
		playsound(destination, 'sound/effects/phasein.ogg', 60, TRUE)

/obj/structure/trap/darkspawn/damage
	max_integrity = 15
	time_between_triggers = 15 SECONDS
	examine_text = "rany"

/obj/structure/trap/darkspawn/damage/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/snap.ogg', 30, TRUE, -1)
	playsound(get_turf(src), 'sound/weapons/bladeslice.ogg', 60, TRUE, -1)

/obj/structure/trap/darkspawn/damage/trap_effect(mob/living/L)
	L.apply_damage(30, BRUTE)
	L.Knockdown(2 SECONDS)

/obj/structure/trap/darkspawn/legcuff
	charges = 1
	examine_text = "unieruchomienie"

/obj/structure/trap/darkspawn/legcuff/flare()
	. = ..()
	playsound(get_turf(src), 'sound/effects/snap.ogg', 50, TRUE)

/obj/structure/trap/darkspawn/legcuff/trap_effect(mob/living/L)
	var/obj/item/restraints/legcuffs/beartrap/dark/trap = new(get_turf(src))
	trap.spring_trap(null, L)

/// Ciemne sidła z pułapki unieruchamiającej
/obj/item/restraints/legcuffs/beartrap/dark
	name = "dark snare"
	icon = 'icons/obj/items_and_weapons.dmi'
	armed = TRUE
	icon_state = "e_snare"
	breakouttime = 3 SECONDS
	item_flags = DROPDEL
	flags_1 = NONE
	slowdown = 4
	anchored = TRUE
	trap_damage = 5

/obj/item/restraints/legcuffs/beartrap/dark/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/obj/item/restraints/legcuffs/beartrap/dark/update_icon()
	icon_state = initial(icon_state)

/obj/item/restraints/legcuffs/beartrap/dark/attack_hand(mob/user)
	spring_trap(null, user) // nie da się podnieść

/obj/item/restraints/legcuffs/beartrap/dark/spring_trap(datum/source, AM as mob|obj)
	if(isliving(AM) && is_team_darkspawn(AM))
		return
	return ..()

// Psioniczna bariera z Divulge i Sakramentu

/obj/structure/psionic_barrier
	name = "psionic barrier"
	desc = "Migoczące fioletowe drobiny tańczące w powietrzu. Nie da się przez nie przejść."
	max_integrity = 200
	icon = 'aquila/icons/mob/darkspawn/darkspawn_effects.dmi'
	icon_state = "purplesparkles"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	light_color = COLOR_VELVET
	light_power = 0.3
	light_range = 2

/obj/structure/psionic_barrier/Initialize(mapload, time = 50 SECONDS)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, time)

/obj/structure/psionic_barrier/Destroy()
	if(obj_integrity <= 0)
		visible_message("<span class='warning'>[src] znika w rozbłysku fioletowej energii!</span>")
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
		new /obj/effect/temp_visual/revenant/cracks(get_turf(src))
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/psionic_barrier/process()
	obj_integrity = min(max_integrity, obj_integrity + 1)

/obj/structure/psionic_barrier/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isliving(mover) && is_team_darkspawn(mover)) // sojusznicy przechodzą
		return TRUE

// Panopticon: ciemna kula do patrzenia oczami sojuszników

/obj/structure/darkspawn_panopticon
	name = "dark orb"
	desc = "Niepokojąca, wirująca masa ciemności. Kto w nią patrzy, zdaje się poznawać zakazaną wiedzę."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "panopticon"
	anchored = TRUE
	density = TRUE
	max_integrity = 200
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = -1
	light_color = COLOR_VELVET
	/// Kto teraz patrzy przez kulę
	var/mob/living/viewer
	/// Na kogo albo co patrzy
	var/atom/watched

/obj/structure/darkspawn_panopticon/Destroy()
	stop_viewing()
	return ..()

/obj/structure/darkspawn_panopticon/examine(mob/user)
	. = ..()
	if(is_team_darkspawn(user))
		. += "<span class='velvet'>Dotknij kuli, żeby patrzeć oczami sojusznika, thralla albo oka pustki.</span>"

/obj/structure/darkspawn_panopticon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!is_team_darkspawn(user))
		to_chat(user, "<span class='warning'>Wpatrujesz się w [src], ale widzisz tylko ciemność.</span>")
		return
	if(viewer)
		if(viewer == user)
			stop_viewing()
		else
			to_chat(user, "<span class='warning'>Ktoś już patrzy przez [src].</span>")
		return
	var/list/options = list()
	for(var/mob/living/ally as anything in GLOB.alive_mob_list)
		if(ally != user && is_team_darkspawn(ally) && ally.z)
			options["[ally.real_name] ([get_area_name(ally)])"] = ally
	for(var/obj/structure/darkspawn_void_eye/eye as anything in GLOB.darkspawn_void_eyes)
		options["Oko pustki ([get_area_name(eye)])"] = eye
	if(!length(options))
		to_chat(user, "<span class='warning'>Nie masz przez kogo patrzeć.</span>")
		return
	playsound(src, pick('aquila/sound/darkspawn/crawling_shadows_walk_01.ogg', 'aquila/sound/darkspawn/crawling_shadows_walk_02.ogg'), 25, FALSE)
	var/choice = tgui_input_list(user, "Czyimi oczami patrzeć?", "Panopticon", options)
	var/atom/target = options[choice]
	if(!target || QDELETED(target) || QDELETED(src) || !user.Adjacent(src) || viewer)
		return
	start_viewing(user, target)

/obj/structure/darkspawn_panopticon/proc/start_viewing(mob/living/user, atom/target)
	viewer = user
	watched = target
	user.reset_perspective(target)
	user.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
	user.clear_fullscreen("flash", 1)
	RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), PROC_REF(stop_viewing))
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(stop_viewing))
	to_chat(user, "<span class='velvet'>Patrzysz oczami [target]. Odejdź od kuli albo dotknij jej znów, żeby przestać.</span>")

/obj/structure/darkspawn_panopticon/proc/stop_viewing()
	SIGNAL_HANDLER
	if(viewer)
		UnregisterSignal(viewer, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
		viewer.reset_perspective()
		playsound(src, 'aquila/sound/darkspawn/crawling_shadows_walk_03.ogg', 35, FALSE)
	if(watched)
		UnregisterSignal(watched, COMSIG_PARENT_QDELETING)
	viewer = null
	watched = null

GLOBAL_LIST_EMPTY(darkspawn_void_eyes)

/// Oko pustki: unoszące się oko, przez które patrzy Panopticon
/obj/structure/darkspawn_void_eye
	name = "void eye"
	desc = "Unoszące się oko z ciemności. Zdaje się na ciebie patrzeć."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_items.dmi'
	icon_state = "camera"
	anchored = TRUE
	density = FALSE
	max_integrity = 20
	layer = ABOVE_MOB_LAYER

/obj/structure/darkspawn_void_eye/Initialize(mapload)
	. = ..()
	GLOB.darkspawn_void_eyes += src

/obj/structure/darkspawn_void_eye/Destroy()
	GLOB.darkspawn_void_eyes -= src
	return ..()

// Macki otchłani czarnoksiężnika

/obj/effect/temp_visual/goliath_tentacle/darkspawn
	name = "darkspawn tendril"
	desc = "Coś wyciąga się zza zasłony."
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = -1
	light_color = COLOR_VELVET

/obj/effect/temp_visual/goliath_tentacle/darkspawn/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	add_atom_colour(COLOR_VELVET, FIXED_COLOUR_PRIORITY)

/// Pierwsza macka wywołuje dziewięć kolejnych wokół
/obj/effect/temp_visual/goliath_tentacle/darkspawn/original/Initialize(mapload, mob/living/new_spawner)
	. = ..()
	var/list/turf/turfs = circlerangeturfs(get_turf(src), 2)
	for(var/i in 1 to 9)
		if(!LAZYLEN(turfs))
			break
		var/turf/T = pick_n_take(turfs)
		if(T.density)
			continue
		new /obj/effect/temp_visual/goliath_tentacle/darkspawn(T, spawner)

/obj/effect/temp_visual/goliath_tentacle/darkspawn/trip()
	var/latched = 0
	for(var/mob/living/L in loc)
		if(is_team_darkspawn(L) || L.stat == DEAD)
			continue
		visible_message("<span class='danger'>[src] chwyta [L]!</span>")
		if(!L.IsStun())
			L.Stun(8 SECONDS)
		else
			L.AdjustStun(2 SECONDS)
		latched = max(latched, L.AmountStun())
		L.adjustBruteLoss(rand(15, 25))
	if(!latched)
		retract()
	else
		deltimer(timerid)
		timerid = addtimer(CALLBACK(src, PROC_REF(retract)), latched, TIMER_STOPPABLE)

// Cienisty płomień na podłodze

/obj/effect/temp_visual/darkspawn/shadowflame
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = -1
	light_color = COLOR_VELVET
	color = COLOR_DARKSPAWN_PSI
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	duration = 10 SECONDS

/obj/effect/temp_visual/darkspawn/shadowflame/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/temp_visual/darkspawn/shadowflame/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/temp_visual/darkspawn/shadowflame/process(delta_time)
	for(var/mob/living/target_mob in get_turf(src))
		if(!is_team_darkspawn(target_mob))
			target_mob.apply_status_effect(/datum/status_effect/shadowflame)
