// AQUILA - klasy darkspawna i sklep Psi Web (port z Yogstation)

/// Klasa darkspawna. Komponent na umyśle, trzyma kupione zdolności.
/datum/component/darkspawn_class
	dupe_type = /datum/component/darkspawn_class // jedna klasa naraz
	var/name = "Debug class"
	/// Krótki opis
	var/description = "Klasa testowa."
	/// Dłuższy opis w oknie wyboru klasy
	var/long_description = "Tej klasy nie powinno być widać."
	/// Flaga klasy, decyduje, co można kupić w Psi Web
	var/specialization_flag = NONE
	var/datum/mind/owner
	var/choosable = TRUE
	/// Zdolności dawane od razu
	var/list/datum/psi_web/starting_abilities = list()
	/// Kupione zdolności (instancje)
	var/list/datum/psi_web/learned_abilities = list()
	/// Kolor oczu i sigili
	var/class_color = COLOR_SILVER
	var/icon_file = 'aquila/icons/mob/darkspawn/darkspawn.dmi'
	var/eye_icon = "eyes"
	var/class_icon = "classless"
	/// Mob, któremu teraz dorysowaliśmy oczy i sigile
	var/mob/living/overlay_mob
	var/list/applied_overlays

/datum/component/darkspawn_class/Initialize()
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	if(!owner.has_antag_datum(/datum/antagonist/darkspawn))
		return COMPONENT_INCOMPATIBLE

/datum/component/darkspawn_class/Destroy()
	remove_owner_overlay()
	owner = null
	return ..()

/datum/component/darkspawn_class/RegisterWithParent()
	RegisterSignal(parent, COMSIG_DARKSPAWN_PURCHASE_POWER, PROC_REF(gain_power))
	RegisterSignal(parent, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transfer))
	for(var/datum/psi_web/power as anything in starting_abilities)
		gain_power(power_typepath = power)
	update_owner_overlay()

/datum/component/darkspawn_class/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_DARKSPAWN_PURCHASE_POWER, COMSIG_MIND_TRANSFER_TO))
	remove_owner_overlay()
	for(var/datum/psi_web/power as anything in learned_abilities)
		lose_power(power, TRUE) // przy zdjęciu klasy zwraca wolę

/datum/component/darkspawn_class/proc/on_mind_transfer(datum/mind/source, mob/old_current, mob/new_current)
	SIGNAL_HANDLER
	update_owner_overlay()

// Oczy i sigile

/datum/component/darkspawn_class/proc/remove_owner_overlay()
	if(overlay_mob && LAZYLEN(applied_overlays))
		overlay_mob.cut_overlay(applied_overlays)
	applied_overlays = null
	overlay_mob = null

/// Dorysowuje świecące oczy i sigile klasy, ale tylko na prawdziwej postaci darkspawna
/datum/component/darkspawn_class/proc/update_owner_overlay()
	remove_owner_overlay()
	var/mob/living/carbon/human/body = owner?.current
	if(!ishuman(body) || !istype(body.dna?.species, /datum/species/darkspawn))
		return
	var/mutable_appearance/eyes = mutable_appearance(icon_file, eye_icon, -BODY_FRONT_LAYER)
	eyes.color = class_color
	var/mutable_appearance/class_sigil = mutable_appearance(icon_file, class_icon, -BODY_FRONT_LAYER)
	class_sigil.color = class_color
	applied_overlays = list(eyes, class_sigil, emissive_appearance(icon_file, eye_icon, -BODY_FRONT_LAYER), emissive_appearance(icon_file, class_icon, -BODY_FRONT_LAYER))
	overlay_mob = body
	body.add_overlay(applied_overlays)

// Zdolności

/datum/component/darkspawn_class/proc/get_purchasable_abilities()
	var/list/datum/psi_web/available_abilities = list()
	for(var/datum/psi_web/ability as anything in subtypesof(/datum/psi_web))
		if(!initial(ability.willpower_cost)) // darmowe są tylko dawane z klasą
			continue
		if(!(initial(ability.shadow_flags) & specialization_flag))
			continue
		if(!initial(ability.infinite) && (locate(ability) in learned_abilities))
			continue
		available_abilities += ability
	return available_abilities

/datum/component/darkspawn_class/proc/gain_power(atom/source, datum/psi_web/power_typepath, silent = FALSE)
	SIGNAL_HANDLER
	if(!ispath(power_typepath, /datum/psi_web))
		CRASH("[owner] tried to gain [power_typepath] which is not a valid darkspawn ability")
	if(!(initial(power_typepath.shadow_flags) & specialization_flag))
		return
	if(!initial(power_typepath.infinite) && (locate(power_typepath) in learned_abilities))
		return
	var/datum/psi_web/new_power = new power_typepath()
	if(new_power.on_purchase(owner, silent))
		learned_abilities += new_power
	else
		qdel(new_power)

/datum/component/darkspawn_class/proc/lose_power(datum/psi_web/power, refund = FALSE)
	if(!(power in learned_abilities))
		CRASH("[owner] tried to lose [power] which they haven't learned")
	learned_abilities -= power
	power.remove(refund)
	qdel(power)

/// Oddaje wszystkie zdolności na nowe ciało (np. po odtworzeniu ciała)
/datum/component/darkspawn_class/proc/refresh_powers()
	for(var/datum/psi_web/power as anything in learned_abilities.Copy())
		var/power_type = power.type
		lose_power(power, TRUE)
		gain_power(power_typepath = power_type, silent = TRUE)
	update_owner_overlay()

// Klasy

/datum/component/darkspawn_class/classless
	name = "Wyzuty"
	description = "Jeszcze nie ujrzałeś grozy."
	long_description = "Pewnie dasz radę samą maczugą i przepaską."
	class_color = COLOR_SILVER
	starting_abilities = list(/datum/psi_web/innate_darkspawn)
	choosable = FALSE

/datum/component/darkspawn_class/fighter
	name = "Wojownik"
	description = "Niepowstrzymana ściana ciemności."
	long_description = "Bezpośrednie zagrożenie dla załogi. Prosta i brudna robota. Przyjmuje mniej obrażeń i szybciej się leczy."
	specialization_flag = DARKSPAWN_FIGHTER
	class_color = COLOR_RED
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/fighter)
	class_icon = "fighter_sigils"

/datum/component/darkspawn_class/scout
	name = "Zwiadowca"
	description = "Porusza cieniami w nienaturalny sposób."
	long_description = "Odstrasza załogę od ciemności, będąc wszędzie naraz. Świetnie ucieka."
	specialization_flag = DARKSPAWN_SCOUT
	class_color = COLOR_YELLOW
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/scout)
	class_icon = "scout_sigils"

/datum/component/darkspawn_class/warlock
	name = "Czarnoksiężnik"
	description = "Psioniczna dominacja."
	long_description = "Rzuca zaklęcia, zniewala umysły i wspiera sojuszników z drugiego końca stacji. Dość złożona klasa."
	specialization_flag = DARKSPAWN_WARLOCK
	class_color = COLOR_STRONG_VIOLET
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/warlock)
	class_icon = "warlock_sigils"

/datum/component/darkspawn_class/admin
	name = "Admeme"
	description = "Potrafi wszystko."
	long_description = "No, to masz przechlapane, kolego."
	specialization_flag = ALL_DARKSPAWN_CLASSES
	class_color = "#00FF00"
	choosable = FALSE
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/fighter, /datum/psi_web/scout, /datum/psi_web/warlock)
	eye_icon = "admeme_eyes"
	class_icon = "admeme_sigils"

// Psi Web

/// Coś do kupienia w Psi Web: zdolność albo ulepszenie
/datum/psi_web
	var/name = "Podstawowa wiedza"
	var/desc = "Podstawy zakazanych sztuk."
	/// Ozdobny opis
	var/lore_description = ""
	/// Ikona w oknie
	var/icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	var/icon_state = null
	/// Koszt w woli
	var/willpower_cost = 0
	/// Które klasy mogą to kupić
	var/shadow_flags = NONE
	/// Zdolności dawane przy kupnie
	var/list/datum/action/learned_abilities = list()
	/// Zakładka sklepu
	var/menu_tab
	var/datum/mind/owner
	/// Ciało darkspawna przy kupnie
	var/mob/living/carbon/human/shadowhuman
	var/datum/antagonist/darkspawn/darkspawn
	/// Czy można kupować wiele razy (stopniowe ulepszenia)
	var/infinite = FALSE
	/// Czy już cofnięte (zwrócone)
	var/removed = FALSE

/datum/psi_web/proc/on_purchase(datum/mind/user, silent = FALSE)
	if(!istype(user))
		return FALSE
	owner = user
	if(!ishuman(owner.current))
		to_chat(owner.current, "<span class='warning'>Badać Psi Web możesz tylko w ludzkim ciele.</span>")
		return FALSE
	shadowhuman = owner.current
	darkspawn = owner.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn)
		CRASH("[owner] tried to gain a psi_web datum despite not being a darkspawn")
	if(darkspawn.willpower < willpower_cost)
		return FALSE

	darkspawn.willpower -= willpower_cost
	if(willpower_cost && !silent)
		to_chat(owner.current, "<span class='velvet'>Odblokowujesz: <b>[name]</b>.</span>")
	on_gain()
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = new ability(owner)
			action.Grant(shadowhuman)
	return TRUE

/// Po udanym kupnie
/datum/psi_web/proc/on_gain()
	return

/// Przy cofnięciu
/datum/psi_web/proc/on_loss()
	return

/datum/psi_web/proc/remove(refund = FALSE)
	if(removed)
		return
	removed = TRUE
	for(var/ability in learned_abilities)
		if(!ispath(ability, /datum/action) || !owner?.current)
			continue
		var/datum/action/action = locate(ability) in owner.current.actions
		if(action)
			qdel(action)
	if(darkspawn)
		on_loss()
		if(refund)
			darkspawn.willpower += willpower_cost

/datum/psi_web/Destroy(force, ...)
	remove()
	owner = null
	shadowhuman = null
	darkspawn = null
	return ..()

// Zdolności dawane z klasą

/datum/psi_web/innate_darkspawn
	name = "Zdolności darkspawna"
	desc = "Podstawowe zdolności każdego darkspawna."
	shadow_flags = ALL_DARKSPAWN_CLASSES
	learned_abilities = list(/datum/action/cooldown/spell/sacrament, /datum/action/cooldown/spell/touch/devour_will)

/datum/psi_web/fighter
	name = "Zdolności wojownika"
	desc = "Wrodzone zdolności wojownika."
	shadow_flags = DARKSPAWN_FIGHTER
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_tendril)

/datum/psi_web/fighter/on_gain()
	darkspawn.brute_mod *= 0.7
	darkspawn.dark_healing += 2 // walczą najwięcej, więc leczą się trochę szybciej

/datum/psi_web/fighter/on_loss()
	darkspawn.brute_mod /= 0.7
	darkspawn.dark_healing -= 2

/datum/psi_web/scout
	name = "Zdolności zwiadowcy"
	desc = "Wrodzone zdolności zwiadowcy."
	shadow_flags = DARKSPAWN_SCOUT
	learned_abilities = list(/datum/action/cooldown/spell/toggle/light_eater)

/datum/psi_web/scout/on_gain()
	shadowhuman.AddComponent(/datum/component/darkspawn_shadow_walk)

/datum/psi_web/scout/on_loss()
	qdel(shadowhuman?.GetComponent(/datum/component/darkspawn_shadow_walk))

/datum/psi_web/warlock
	name = "Zdolności czarnoksiężnika"
	desc = "Wrodzone zdolności czarnoksiężnika."
	shadow_flags = DARKSPAWN_WARLOCK
	learned_abilities = list(/datum/action/cooldown/spell/touch/thrall_mind, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_cam, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye, /datum/action/cooldown/spell/toggle/dark_staff)

/datum/psi_web/warlock/on_gain()
	darkspawn.psi_cap *= 2
	darkspawn.psi_per_second *= 2
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls += 3

/datum/psi_web/warlock/on_loss()
	darkspawn.psi_cap /= 2
	darkspawn.psi_per_second /= 2
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls -= 3

/// Ulepszenie istniejącej zdolności przez sygnał z flagą
/datum/psi_web/ability_upgrade
	name = "Ulepszenie zdolności"
	desc = "Tego nie powinno być widać."
	var/flag_to_add

/datum/psi_web/ability_upgrade/on_gain()
	if(flag_to_add)
		SEND_SIGNAL(owner, COMSIG_DARKSPAWN_UPGRADE_ABILITY, flag_to_add)

/datum/psi_web/ability_upgrade/on_loss()
	if(flag_to_add)
		SEND_SIGNAL(owner, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, flag_to_add)
