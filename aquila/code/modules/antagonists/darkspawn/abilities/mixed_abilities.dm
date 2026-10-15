// AQUILA - darkspawn: zdolności dostępne dla kilku klas (port z Yogstation)

// Wtargnięcie w cień: ukrycie się w cieniu kogoś innego

/datum/action/cooldown/spell/touch/umbral_trespass
	name = "Wtargnięcie w cień"
	desc = "Wtapiasz się w cień celu i niewidocznie za nim podążasz. Działa tylko w świetle; wyrzuca cię ciemność albo wzięcie czegoś do ręki. Kosztuje 30 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "umbral_trespass"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_CASTABLE_WHILE_PHASED
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 30)
	cooldown_time = 10 SECONDS
	hand_path = /obj/item/melee/spell_hand/darkspawn
	/// Efekt ukrycia, gdy trwa
	var/datum/status_effect/darkspawn_tagalong/tagalong

/datum/action/cooldown/spell/touch/umbral_trespass/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/// W cieniu kogoś wciśnięcie przycisku wychodzi z cienia zamiast dawać dłoń
/datum/action/cooldown/spell/touch/umbral_trespass/Trigger(trigger_flags, atom/target)
	if(!QDELETED(tagalong))
		QDEL_NULL(tagalong)
		return TRUE
	return ..()

/datum/action/cooldown/spell/touch/umbral_trespass/cast_on_hand_hit(obj/item/melee/spell_hand/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	var/turf/T = get_turf(target)
	if(T?.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		to_chat(caster, "<span class='warning'>Tu jest za ciemno, żeby wtopić się w cień [target].</span>")
		return FALSE
	caster.temporarilyRemoveItemFromInventory(hand, TRUE) // inaczej trzymana dłoń od razu by wyrzuciła
	tagalong = caster.apply_status_effect(/datum/status_effect/darkspawn_tagalong, target)
	caster.balloon_alert(caster, "Iahz")
	to_chat(caster, "<span class='velvet'>Wślizgujesz się w cień [target]. Potrwa to pięć minut, dopóki tego nie przerwiesz albo nie wyrzuci cię ciemność.</span>")
	caster.forceMove(target)
	return TRUE

// Lodowe żyły: mrozi krew wszystkich w pobliżu

/datum/action/cooldown/spell/aoe/icyveins
	name = "Lodowe żyły"
	desc = "W jednej chwili mrozi krew ludzi w pobliżu, spowalniając ich i gwałtownie wychładzając."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "icy_veins"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	sound = 'sound/effects/ghost2.ogg'
	aoe_radius = 3
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 60)
	cooldown_time = 45 SECONDS

/datum/action/cooldown/spell/aoe/icyveins/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Syn'thra")
	to_chat(owner, "<span class='velvet'>Zamrażasz powietrze wokół.</span>")
	if(isliving(owner))
		var/mob/living/target = owner
		target.ExtinguishMob()

/datum/action/cooldown/spell/aoe/icyveins/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!isliving(target) || !can_see(user, target))
		return
	var/mob/living/victim = target
	if(is_team_darkspawn(victim))
		return
	to_chat(victim, "<span class='userdanger'>Ogarnia cię fala przeraźliwie zimnego powietrza!</span>")
	victim.apply_damage(10, BURN)
	if(victim.reagents)
		victim.reagents.add_reagent(/datum/reagent/consumable/frostoil, 10)
		victim.reagents.add_reagent(/datum/reagent/shadowfrost, 10)

// Pełzające cienie: przemiana w cienistą istotę

/datum/action/cooldown/spell/crawling_shadows
	name = "Pełzające cienie"
	desc = "Przybierasz cienistą postać, która przechodzi przez szyby wentylacyjne i szpary w drzwiach. Powrót jest darmowy."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "crawling_shadows"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 55)
	cooldown_time = 1 SECONDS // żeby nie kliknąć dwa razy przez przypadek
	sound = 'aquila/sound/darkspawn/devour_will_end.ogg'

/datum/action/cooldown/spell/crawling_shadows/can_cast_spell(feedback = TRUE)
	if(!owner)
		return FALSE
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = owner
	bypass_cost = istype(shadows) // powrót jest darmowy
	if(istype(shadows) && (shadows.movement_type & VENTCRAWLING))
		if(feedback)
			to_chat(owner, "<span class='warning'>Tu jest za ciasno, żeby wrócić do zwykłej postaci.</span>")
		return FALSE
	if(isliving(owner))
		var/mob/living/L = owner
		if(L.has_status_effect(/datum/status_effect/darkspawn_tagalong))
			return FALSE
	return ..()

/datum/action/cooldown/spell/crawling_shadows/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = owner
	if(istype(shadows))
		owner.balloon_alert(owner, "...Voz")
		shadows.return_to_body()
		return
	if(!ishuman(owner) || !isturf(owner.loc))
		return
	owner.balloon_alert(owner, "Zov...")
	var/mob/living/carbon/human/body = owner
	shadows = new(get_turf(body))
	shadows.darkspawn_mob = body
	body.visible_message("<span class='warning'>[body] rozpływa się w pełzającą masę cieni!</span>", "<span class='velvet'>Przybierasz postać pełzających cieni.</span>")
	shadows.take_body()

// Simulacrum: iluzja, która przez chwilę walczy za ciebie

/datum/action/cooldown/spell/simulacrum
	name = "Simulacrum"
	desc = "Tworzy iluzję łudząco do ciebie podobną. Przez 10 sekund walczy za ciebie z wrogami w pobliżu. Kosztuje 40 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "simulacrum"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 40)
	/// Jak długo żyje iluzja
	var/duration = 10 SECONDS

/datum/action/cooldown/spell/simulacrum/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/L = owner
	L.balloon_alert(L, "Zkxa'ya")
	L.visible_message("<span class='warning'>Od cienia [L] odrywa się druga postać!</span>", "<span class='velvet'>Tworzysz iluzję samego siebie.</span>")
	playsound(L, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	var/mob/living/simple_animal/hostile/illusion/darkspawn/M = new(get_turf(L))
	M.Copy_Parent(L, duration, 100, 10)
	M.move_to_delay = L.movement_delay()

// Rozszczepienie jaźni: odłamek umysłu z graczem-duchem

/datum/action/cooldown/spell/fray_self
	name = "Rozszczepienie jaźni"
	desc = "Próbujesz oderwać kawałek swojej psyche w świadomą kopię samego siebie, która żyje, dopóki ktoś jej nie zniszczy. Kosztuje 100 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "fray_self"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	cooldown_time = 3 MINUTES
	var/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/dude
	/// Życie kopii
	var/health = 100
	/// Obrażenia ciosów kopii
	var/damage = 10
	/// Czy właśnie szuka ducha
	var/searching = FALSE

/datum/action/cooldown/spell/fray_self/can_cast_spell(feedback = TRUE)
	if(dude)
		if(feedback)
			to_chat(owner, "<span class='velvet'>Odłamek twojej psyche jeszcze do ciebie nie wrócił.</span>")
		return FALSE
	if(searching)
		return FALSE
	return ..()

/datum/action/cooldown/spell/fray_self/cast(atom/cast_on)
	. = ..()
	if(dude || searching || !isliving(owner))
		return
	INVOKE_ASYNC(src, PROC_REF(fray))

/datum/action/cooldown/spell/fray_self/proc/fray()
	var/mob/living/caster = owner
	to_chat(caster, "<span class='velvet'>Próbujesz oderwać kawałek swojej psyche.</span>")
	searching = TRUE
	var/list/consenting_candidates = pollGhostCandidates("Czy chcesz zagrać odłamkiem psyche [caster]?", ROLE_DARKSPAWN, /datum/role_preference/antagonist/darkspawn, 10 SECONDS)
	searching = FALSE
	if(!length(consenting_candidates) || QDELETED(caster))
		to_chat(caster, "<span class='danger'>Nie udaje ci się oderwać kawałka psyche.</span>")
		reset_spell_cooldown()
		return
	var/mob/dead/observer/chosen_ghost = pick(consenting_candidates)
	caster.balloon_alert(caster, "Zkxa'yaera Hohef'era!")
	caster.visible_message("<span class='warning'>Od cienia [caster] odrywa się druga postać!</span>", "<span class='velvet'>Odłamek twojej psyche tworzy sobie ciało.</span>")
	playsound(caster, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	dude = new(get_turf(caster))
	RegisterSignal(dude, COMSIG_PARENT_QDELETING, PROC_REF(rejoin))
	RegisterSignal(dude, COMSIG_MOB_DEATH, PROC_REF(rejoin))
	dude.Copy_Parent(caster, INFINITY, health, damage)
	dude.key = chosen_ghost.key
	dude.name = caster.name
	dude.real_name = caster.real_name
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
	darkspawn?.block_psi(30 SECONDS, type)

/// Odłamek zginął, można stworzyć nowy
/datum/action/cooldown/spell/fray_self/proc/rejoin()
	SIGNAL_HANDLER
	if(!dude)
		return
	UnregisterSignal(dude, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	if(owner)
		to_chat(owner, "<span class='velvet'>Czujesz, jak twoja psyche znów staje się jednością.</span>")
	if(!QDELETED(dude))
		QDEL_IN(dude, 0)
	dude = null
