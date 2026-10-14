// AQUILA - darkspawn: zniewalanie umysłów i zdolności thralli (port z Yogstation)

// Zniewolenie umysłu

/datum/action/cooldown/spell/touch/thrall_mind
	name = "Zniewolenie umysłu"
	desc = "Za 1 punkt woli zniewalasz umysł celu.<br>Cel musi żyć i mieć ciemny paciorek z Pożarcia woli.<br>Działa też na martwych thralli, przywracając ich do życia.<br>Prawy klik na przycisku uwalnia thralla spod twojej władzy."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "veil_mind"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	hand_path = /obj/item/melee/spell_hand/darkspawn
	/// Ile woli kosztuje zniewolenie
	var/willpower_cost = 1

/datum/action/cooldown/spell/touch/thrall_mind/Trigger(trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		INVOKE_ASYNC(src, PROC_REF(release_thrall))
		return FALSE
	return ..()

/datum/action/cooldown/spell/touch/thrall_mind/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/thrall_mind/cast_on_hand_hit(obj/item/melee/spell_hand/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	var/datum/antagonist/darkspawn/master = isdarkspawn(caster)
	if(!master)
		return FALSE
	if(!target.mind && !target.ckey)
		to_chat(caster, "<span class='warning'>Ten umysł jest zbyt marny, żeby w ogóle wart był zniewolenia.</span>")
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BRAIN))
		to_chat(caster, "<span class='danger'>[target] nie ma mózgu, brakuje ci przewodnika, żeby nim władać.</span>")
		return FALSE
	if(isdarkspawn(target))
		to_chat(caster, "<span class='velvet'>Nigdy nie będziesz dość silny, żeby władać wolą innego darkspawna.</span>")
		return FALSE

	if(!isthrall(target))
		if(master.willpower < willpower_cost)
			to_chat(caster, "<span class='danger'>Masz za mało woli, żeby zniewolić [target].</span>")
			return FALSE
		if(!get_shadow_tumor(target))
			to_chat(caster, "<span class='danger'>[target] nie ma ciemnego paciorka, który mógłbyś wzmocnić.</span>")
			return FALSE

	caster.balloon_alert(caster, "Krx'lna tyhx graha...")
	to_chat(caster, "<span class='velvet'>Zaczynasz kierować psioniczną moc przez umysł [target].</span>")
	playsound(caster, 'aquila/sound/darkspawn/devour_will_victim.ogg', 50)
	if(!do_after(caster, 2 SECONDS, target = target))
		return FALSE

	if(!isthrall(target))
		var/list/flavour = list()
		flavour += "Twój umysł drętwieje. Myśli pustoszeją. Czujesz się zupełnie pusty."
		flavour += "Czyjaś świadomość ociera się o twoją. Śnisz."
		flavour += "O ogromnej, pustej Otchłani w głębi kosmosu."
		flavour += "Coś leży w tej Otchłani. Prastare. Niepojęte."
		flavour += "Patrzy na ciebie głodnymi oczami. Oczami pełnymi gwiazd."
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			flavour += "<span class='boldwarning'>Spojrzenie istoty pochłania wszechświat w czerni.</span>"
		to_chat(target, flavour.Join("<br>"))
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(caster, "<span class='warning'>[target] ma obcą maszynerię, która opiera się zniewoleniu. Spróbujemy ją zniszczyć.</span>")
			target.visible_message("<span class='warning'>[target] zdaje się opierać niewidzialnej sile!</span>")
			if(!do_after(caster, 8 SECONDS, target = target))
				to_chat(target, "<span class='userdanger'>Nie wolno pozwolić, żeby jej się udało.</span>")
				return FALSE
			for(var/obj/item/implant/mindshield/L in target)
				qdel(L)

	playsound(caster, 'aquila/sound/darkspawn/veil_mind_gasp.ogg', 25)
	if(!do_after(caster, 2 SECONDS, target = target))
		return FALSE
	playsound(caster, 'aquila/sound/darkspawn/veil_mind_scream.ogg', 100)

	if(isthrall(target))
		caster.balloon_alert(caster, "...tia")
		to_chat(caster, "<span class='velvet'>Przywracasz siły swojemu thrallowi, [target.real_name].</span>")
		target.revive(TRUE, TRUE)
		target.grab_ghost()
		return TRUE

	var/datum/team/darkspawn/team = master.get_team()
	if(team && LAZYLEN(team.thralls) >= team.max_thralls)
		to_chat(caster, "<span class='velvet'>Twoja moc nie zdoła zapanować nad <b>[target]</b>. Masz już tylu thralli, ilu możesz.</span>")
		return FALSE
	if(master.willpower < willpower_cost)
		to_chat(caster, "<span class='velvet'>Masz za mało woli, żeby zniewolić [target].</span>")
		return FALSE
	if(target.add_thrall())
		master.willpower -= willpower_cost
		caster.balloon_alert(caster, "...xthl'kap")
		to_chat(caster, "<span class='velvet'><b>[target.real_name]</b> zostaje thrallem!</span>")
		to_chat(caster, "<span class='velvet'>Thralle spełnią każdy twój rozkaz, a przebywając wśród zwykłej załogi, dają ci wolę.</span>")
	else
		to_chat(caster, "<span class='velvet'>Twoja moc nie zdoła zapanować nad <b>[target]</b>.</span>")
	return TRUE

/// Prawy klik: uwolnienie thralla
/datum/action/cooldown/spell/touch/thrall_mind/proc/release_thrall()
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	var/datum/team/darkspawn/team = dude?.get_team()
	if(!team)
		return
	if(!LAZYLEN(team.thralls))
		to_chat(owner, "<span class='warning'>Nie masz thralli do uwolnienia.</span>")
		return
	var/list/choices = list()
	for(var/datum/mind/thrall_mind as anything in team.thralls)
		choices[thrall_mind.name] = thrall_mind
	var/choice = tgui_input_list(owner, "Którego thralla uwolnić spod twojej władzy?", "Uwolnienie thralla", choices)
	var/datum/mind/unveiled = choices[choice]
	if(!unveiled?.current)
		return
	if(unveiled.current.remove_thrall())
		owner.balloon_alert(owner, "Fk'koht")
		to_chat(owner, "<span class='velvet'>Uwalniasz [unveiled] spod swojej władzy.</span>")

// Panopticon: ciemna kula do podglądania sojuszników i oczu pustki

/datum/action/cooldown/spell/pointed/darkspawn_build/thrall_cam
	name = "Panopticon"
	desc = "Stawiasz ciemną kulę, przez którą możesz patrzeć oczami sojuszników, thralli i postawionych oczu pustki."
	button_icon_state = "panopticon"
	cooldown_time = 1 MINUTES
	cast_time = 2 SECONDS
	object_type = /obj/structure/darkspawn_panopticon
	language_final = "kxmiv'ixnce"

// Oko pustki: unoszące się oko do podglądania przez Panopticon

/datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye
	name = "Oko pustki"
	desc = "Stawiasz unoszące się, czujne oko, przez które można patrzeć z Panopticonu."
	button_icon_state = "glare"
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 20)
	object_type = /obj/structure/darkspawn_void_eye
	language_final = "Ixnce"
	cast_time = 1 SECONDS

/datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye/thrall
	desc = "Stawiasz unoszące się, czujne oko, przez które twoi panowie mogą patrzeć."
	spell_requirements = NONE
	bypass_cost = TRUE // thralle nie mają Psi

// Wybuch umysłu: pocisk, który można wystrzelić też z umysłu sojusznika

/datum/action/cooldown/spell/pointed/mindblast
	name = "Wybuch umysłu"
	desc = "Skupiasz psioniczną energię w pocisk, który zadaje fizyczne obrażenia. Można go też wystrzelić z umysłu sojusznika."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "mind_blast"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	cast_range = INFINITY
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 40)
	cooldown_time = 5 SECONDS
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	sound = 'sound/weapons/resonator_blast.ogg'
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	aim_assist = FALSE
	/// Jak daleko od ciała może polecieć pocisk
	var/body_range = 9
	/// Z kogo wystrzelić pocisk
	var/mob/shoot_from

/datum/action/cooldown/spell/pointed/mindblast/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/mindblast/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	shoot_from = null
	if(get_dist(owner, cast_on) <= body_range && isturf(owner.loc))
		shoot_from = owner
	else
		var/closest_dude_dist = body_range
		for(var/mob/living/dude in range(body_range, cast_on))
			if(!is_team_darkspawn(dude) || !isturf(dude.loc))
				continue
			var/dist = get_dist(cast_on, dude)
			if(dist < closest_dude_dist) // zawsze najbliższy
				shoot_from = dude
				closest_dude_dist = dist
	if(!shoot_from)
		to_chat(owner, "<span class='warning'>W pobliżu nie ma nikogo, przez kogo mógłbyś przepuścić swoją moc.</span>")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/mindblast/cast(atom/cast_on)
	. = ..()
	if(!shoot_from)
		return
	var/obj/item/projectile/magic/mindblast/to_fire = new(get_turf(shoot_from))
	to_fire.firer = owner
	to_fire.fired_from = shoot_from
	to_fire.preparePixelProjectile(cast_on, shoot_from)
	to_fire.fire()
	owner.balloon_alert(owner, "Vyk'thunak")
	if(shoot_from != owner)
		playsound(get_turf(shoot_from), 'sound/weapons/resonator_blast.ogg', 50, TRUE)
	shoot_from = null

/obj/item/projectile/magic/mindblast
	name = "mindbolt"
	icon = 'aquila/icons/mob/darkspawn/darkspawn_projectiles.dmi'
	icon_state = "mind_blast"
	damage = 35
	armour_penetration = 100
	speed = 1
	damage_type = BRUTE
	nodamage = FALSE
	pass_flags = PASSTABLE | PASSMACHINE
	range = 10

/obj/item/projectile/magic/mindblast/prehit_pierce(atom/target)
	if(isliving(target) && is_team_darkspawn(target))
		return PROJECTILE_PIERCE_PHASE // sojuszników przelatuje
	return ..()

// Wsparcie thralli na odległość

/datum/action/cooldown/spell/pointed/thrallbuff
	name = "Wzmocnienie thralli"
	desc = "Wzmacnia wszystkich thralli w pobliżu wskazanego miejsca."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "speedboost_veils"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 50)
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	sound = 'sound/magic/staff_healing.ogg'
	cast_range = INFINITY
	aim_assist = FALSE
	/// Czy działa też na innych darkspawnów (Sigil jedności)
	var/darkspawns_too = FALSE
	var/language_output = "DEBUGIFY"
	/// Promień działania
	var/buff_range = 4
	/// Kolor obrysu na wzmocnionych
	var/outline_colour
	var/buff_duration = 1 SECONDS

/datum/action/cooldown/spell/pointed/thrallbuff/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/thrallbuff/before_cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	darkspawns_too = dude && HAS_TRAIT(dude, TRAIT_DARKSPAWN_BUFFALLIES)

/datum/action/cooldown/spell/pointed/thrallbuff/cast(atom/cast_on)
	. = ..()
	if(get_dist(cast_on, owner) > 7)
		playsound(get_turf(cast_on), sound, 50, TRUE)
	owner.balloon_alert(owner, "[language_output]")
	for(var/mob/living/carbon/target in range(buff_range, cast_on))
		if(target == owner || !is_team_darkspawn(target))
			continue
		if(!darkspawns_too && isdarkspawn(target))
			continue
		empower(target)
		if(outline_colour)
			add_outline(target)

/datum/action/cooldown/spell/pointed/thrallbuff/proc/add_outline(mob/living/carbon/target)
	target.add_filter(name, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 0, "size" = 1))
	var/filter = target.get_filter(name)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(remove_outline), target), buff_duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/action/cooldown/spell/pointed/thrallbuff/proc/remove_outline(mob/living/carbon/target)
	if(QDELETED(target))
		return
	animate(target.get_filter(name))
	target.remove_filter(name)

/datum/action/cooldown/spell/pointed/thrallbuff/proc/empower(mob/living/carbon/target)
	return

/datum/action/cooldown/spell/pointed/thrallbuff/heal
	name = "Regeneracja thralli"
	desc = "Leczy wszystkich thralli w obszarze 9x9 wokół wskazanego miejsca."
	button_icon_state = "heal_veils"
	language_output = "Plyn othra"
	var/heal_amount = 70

/datum/action/cooldown/spell/pointed/thrallbuff/heal/empower(mob/living/carbon/target)
	to_chat(target, "<span class='velvet'>Czujesz, jak rany się zasklepiają.</span>")
	var/healed = target.getBruteLoss() + target.getFireLoss() + target.getToxLoss() + target.getOxyLoss()
	target.adjustBruteLoss(-heal_amount)
	target.adjustFireLoss(-heal_amount)
	target.adjustToxLoss(-heal_amount)
	target.adjustOxyLoss(-heal_amount)
	target.adjustStaminaLoss(-heal_amount)
	if(healed)
		new /obj/effect/temp_visual/heal(get_turf(target), COLOR_GREEN)

/datum/action/cooldown/spell/pointed/thrallbuff/speed
	name = "Ożywienie thralli"
	desc = "Daje chwilowe przyspieszenie wszystkim thrallom w obszarze 9x9 wokół wskazanego miejsca."
	button_icon_state = "speedboost_veils"
	language_output = "Vyzthun"
	outline_colour = COLOR_YELLOW
	buff_duration = 15 SECONDS
	var/speed_strength = -0.7

/datum/action/cooldown/spell/pointed/thrallbuff/speed/empower(mob/living/carbon/target)
	to_chat(target, "<span class='velvet'>Czujesz się szybki.</span>")
	target.apply_status_effect(/datum/status_effect/darkspawn_speedboost, speed_strength, buff_duration)

// Olśnienie: ogromne wzmocnienie jednego sojusznika, także wskrzeszenie

/datum/action/cooldown/spell/pointed/elucidate
	name = "Olśnienie"
	desc = "Przepuszczasz przez sojusznika ogromną moc: mocno go leczy, zdejmuje wszystkie ogłuszenia i przyspiesza. Z bliska wskrzesza martwych sojuszników."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "elucidate"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	cooldown_time = 5 MINUTES
	sound = 'sound/magic/staff_healing.ogg'
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	invocation_type = INVOCATION_SHOUT
	invocation = "CKKREM!"

/datum/action/cooldown/spell/pointed/elucidate/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/carbon/target = cast_on
	if(!is_team_darkspawn(target))
		return FALSE
	if(target.stat == DEAD && get_dist(target, owner) > 2)
		to_chat(owner, "<span class='velvet'>Z tej odległości już mu nie pomożesz.</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/elucidate/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/target = cast_on
	target.grab_ghost()
	target.revive(TRUE)
	target.SetAllImmobility(0)
	target.set_resting(FALSE)
	target.apply_status_effect(/datum/status_effect/darkspawn_speedboost, -0.5, 15 SECONDS)
	target.visible_message("<span class='danger'>Ze skóry [target] wystrzelają smugi aksamitnego światła.</span>", "<span class='velvet'>Moc huczy w tobie jak szalejąca burza, pchając cię do absolutnych granic.</span>")
	target.uncuff()
	playsound(get_turf(target), 'aquila/sound/darkspawn/darkspawn_death.ogg', 80, TRUE)
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	darkspawn?.block_psi(1 MINUTES, type)

// Zdolności thralli

/datum/action/cooldown/spell/pointed/seize/lesser
	bypass_cost = TRUE // thralle nie mają Psi
	cooldown_time = 45 SECONDS
	stun_duration = 5 SECONDS

/datum/action/cooldown/spell/toggle/nightvision
	name = "Noktowizja"
	desc = "Pozwala widzieć w ciemności."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "glare"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_CASTABLE_AS_BRAIN

/datum/action/cooldown/spell/toggle/nightvision/Enable()
	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, type)
	owner.update_sight()

/datum/action/cooldown/spell/toggle/nightvision/Disable()
	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, type)
	owner.update_sight()
