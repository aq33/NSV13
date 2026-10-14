// AQUILA - darkspawn: zdolności zwiadowcy (port z Yogstation)

// Pożeracz światła: wrodzone ostrze zwiadowcy

/datum/action/cooldown/spell/toggle/light_eater
	name = "Pożeracz światła"
	desc = "Zamieniasz rękę w ostrze wszystkopochłaniającego cienia."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "light_eater"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE

/datum/action/cooldown/spell/toggle/light_eater/process()
	if(owner)
		active = owner.is_holding_item_of_type(/obj/item/light_eater)
	return ..()

/datum/action/cooldown/spell/toggle/light_eater/can_cast_spell(feedback = TRUE)
	if(owner && !active && !length(owner.get_empty_held_indexes()))
		if(feedback)
			to_chat(owner, "<span class='warning'>Potrzebujesz wolnej ręki!</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/light_eater/Enable()
	owner.balloon_alert(owner, "Akna")
	owner.visible_message("<span class='warning'>Ręka [owner] wykręca się w ostrze!</span>", "<span class='velvet'>Zamieniasz rękę w ostrze.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
	var/obj/item/light_eater/armblade = new(owner)
	armblade.force = 18
	armblade.armour_penetration = 0
	if(!owner.put_in_hands(armblade))
		qdel(armblade)
		active = FALSE

/datum/action/cooldown/spell/toggle/light_eater/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message("<span class='warning'>Ostrze [owner] wraca do postaci ręki!</span>", "<span class='velvet'>Rozpraszasz ostrze.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_dispel.ogg', 50, TRUE)
	for(var/obj/item/light_eater/blade in owner)
		qdel(blade)

// Miotacz cieni: łuk strzelający strzałami z ciemności

/datum/action/cooldown/spell/toggle/shadow_caster
	name = "Miotacz cieni"
	desc = "Zamieniasz rękę w łuk, który strzela strzałami z czystej ciemności."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "shadow_caster"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE

/datum/action/cooldown/spell/toggle/shadow_caster/process()
	if(owner)
		active = owner.is_holding_item_of_type(/obj/item/gun/ballistic/bow/shadow_caster)
	return ..()

/datum/action/cooldown/spell/toggle/shadow_caster/can_cast_spell(feedback = TRUE)
	if(owner && !active && !length(owner.get_empty_held_indexes()))
		if(feedback)
			to_chat(owner, "<span class='warning'>Potrzebujesz wolnej ręki!</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/shadow_caster/Enable()
	owner.balloon_alert(owner, "Crxkna")
	owner.visible_message("<span class='warning'>Ręka [owner] wykręca się w łuk!</span>", "<span class='velvet'>Zamieniasz rękę w łuk.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
	var/obj/item/gun/ballistic/bow/shadow_caster/bow = new(owner)
	if(!owner.put_in_hands(bow))
		qdel(bow)
		active = FALSE

/datum/action/cooldown/spell/toggle/shadow_caster/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message("<span class='warning'>Łuk [owner] wraca do postaci ręki!</span>", "<span class='velvet'>Rozpraszasz łuk.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_dispel.ogg', 50, TRUE)
	for(var/obj/item/gun/ballistic/bow/shadow_caster/bow in owner)
		qdel(bow)

// Oślepiające miazmaty: chmura czarnego dymu

/datum/action/cooldown/spell/darkness_smoke
	name = "Oślepiające miazmaty"
	desc = "Wypluwasz chmurę dymu, która oślepia wrogów i chroni przed światłem."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "blinding_miasma"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	sound = 'sound/effects/bamf.ogg'
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 35)
	cooldown_time = 45 SECONDS
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	/// Rozmiar chmury
	var/range = 4

/datum/action/cooldown/spell/darkness_smoke/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Hwlok'krotho")
	owner.visible_message("<span class='warning'>[owner] pochyla się i wyrzuca z siebie chmurę czarnego dymu!</span>", "<span class='velvet'>Wypuszczasz wielką chmurę oślepiającego dymu.</span>")
	var/datum/reagents/smoke_reagents = new(50)
	smoke_reagents.my_atom = owner
	smoke_reagents.add_reagent(/datum/reagent/darkspawn_darkness_smoke, 50)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(smoke_reagents, range, get_turf(owner), silent = TRUE)
	smoke.start()
	qdel(smoke_reagents)

// Pułapki psi

/datum/action/cooldown/spell/pointed/darkspawn_build/trap
	name = "Pułapka psi"
	desc = "Splata cienie w pułapkę."
	button_icon_state = "psi_trap_damage"
	language_final = "DEBUGIFY"

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .
	if(locate(/obj/structure/trap/darkspawn) in get_turf(cast_on))
		owner.balloon_alert(owner, "tu już jest pułapka")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/damage
	name = "Pułapka psi (rany)"
	desc = "Splata cienie w pułapkę, która rani każdego wroga, który na nią wejdzie."
	button_icon_state = "psi_trap_damage"
	object_type = /obj/structure/trap/darkspawn/damage
	language_final = "ksha"

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/legcuff
	name = "Pułapka psi (unieruchomienie)"
	desc = "Splata cienie w pułapkę, która chwyta nogi każdego wroga, który na nią wejdzie."
	button_icon_state = "psi_trap_bear"
	object_type = /obj/structure/trap/darkspawn/legcuff
	language_final = "xcrak"

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/nausea
	name = "Pułapka psi (mdłości)"
	desc = "Splata cienie w pułapkę, po której każdy wróg dostaje mdłości."
	button_icon_state = "psi_trap_nausea"
	object_type = /obj/structure/trap/darkspawn/nausea
	language_final = "guhxo"

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/teleport
	name = "Pułapka psi (teleport)"
	desc = "Splata cienie w pułapkę, która przenosi każdego wroga w losowe miejsce na stacji."
	button_icon_state = "psi_trap_teleport"
	object_type = /obj/structure/trap/darkspawn/teleport
	language_final = "hwkwo"

// Wędrówka przez pustkę

/datum/action/cooldown/spell/void_jaunt
	name = "Wędrówka przez pustkę"
	desc = "Na chwilę przechodzisz przez zasłonę, niewidoczny dla śmiertelnych oczu i odporny na światło."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "void_jaunt"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 70)
	cooldown_time = 90 SECONDS
	sound = 'sound/effects/bamf.ogg'
	/// Jak długo trwa wędrówka
	var/jaunt_duration = 5 SECONDS

/datum/action/cooldown/spell/void_jaunt/can_cast_spell(feedback = TRUE)
	if(owner && !isturf(owner.loc))
		return FALSE
	return ..()

/datum/action/cooldown/spell/void_jaunt/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Vxklu'wop sla'txhaka")
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_jaunt), owner, jaunt_duration, 'aquila/sound/darkspawn/devour_will_form.ogg')

/// Wspólny jaunt darkspawna: niewidzialna podróż przez ściany na określony czas
/proc/darkspawn_jaunt(mob/living/target, duration, exit_sound)
	if(!isturf(target.loc))
		return
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/phased_mob/spell_jaunt/holder = new(mobloc)
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(mobloc, target.dir)
	target.ExtinguishMob()
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.ignore_slowdown(JAUNT_TRAIT)
	sleep(duration)
	target.unignore_slowdown(JAUNT_TRAIT)
	if(QDELETED(target) || target.loc != holder)
		qdel(holder)
		return
	mobloc = get_turf(holder)
	holder.reappearing = TRUE
	if(exit_sound)
		playsound(mobloc, exit_sound, 50, TRUE)
	new /obj/effect/temp_visual/dir_setting/ninja(mobloc, holder.dir)
	target.setDir(holder.dir)
	qdel(holder)
	if(QDELETED(target))
		return
	target.reset_perspective()
	if(mobloc.density)
		for(var/direction in GLOB.alldirs)
			var/turf/T = get_step(mobloc, direction)
			if(T && target.Move(T))
				break

// Skok przez pustkę: krótki teleport w wskazane miejsce

/datum/action/cooldown/spell/pointed/void_jump
	name = "Skok przez pustkę"
	desc = "Krótki teleport we wskazane miejsce."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "shadow_jump"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	sound = 'sound/magic/voidblink.ogg'
	antimagic_flags = NONE
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 20)
	cooldown_time = 20 SECONDS
	cast_range = 7
	aim_assist = FALSE
	active_msg = "Przygotowujesz się do kroku przez pustkę."
	deactive_msg = "Rozluźniasz umysł."
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/void_jump/is_valid_target(atom/cast_on)
	var/turf/destination = get_turf(cast_on)
	if(!destination || destination.density || is_blocked_turf(destination, TRUE) || isspaceturf(destination))
		owner.balloon_alert(owner, "tam się nie da!")
		return FALSE
	if(!(destination in view(cast_range, owner)))
		owner.balloon_alert(owner, "nie widzisz tego miejsca!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/void_jump/cast(atom/cast_on)
	. = ..()
	var/turf/destination = get_turf(cast_on)
	var/turf/start = get_turf(owner)
	owner.balloon_alert(owner, "Vxklu'wop")
	start.Beam(destination, icon_state = "curse0", time = 1 SECONDS)
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(start, owner.dir)
	do_teleport(owner, destination, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	new /obj/effect/temp_visual/dir_setting/ninja(destination, owner.dir)

// Wieczna zmarzlina: zamraża podłogę wokół

/datum/action/cooldown/spell/aoe/permafrost
	name = "Wieczna zmarzlina"
	desc = "Wysysasz ciepło z otoczenia, w jednej chwili zamrażając podłogę."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "permafrost"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 65)
	cooldown_time = 60 SECONDS
	sound = 'aquila/sound/darkspawn/veil_mind_scream.ogg'
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/permafrost/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Syn'thxklp")
	if(isliving(owner))
		var/mob/living/target = owner
		target.ExtinguishMob()

/datum/action/cooldown/spell/aoe/permafrost/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isopenturf(victim))
		return
	var/turf/open/target = victim
	target.MakeSlippery(TURF_WET_PERMAFROST, 10 SECONDS)

