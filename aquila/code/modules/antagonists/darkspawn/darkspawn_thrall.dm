// AQUILA - thralle darkspawnów i guz cienia (port z Yogstation)

/// Guz cienia w głowie, jeśli jest
/proc/get_shadow_tumor(mob/living/source)
	if(!iscarbon(source))
		return
	var/mob/living/carbon/C = source
	var/obj/item/organ/tumor = C.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(istype(tumor, /obj/item/organ/shadowtumor))
		return tumor

/datum/antagonist/thrall
	name = "Thrall darkspawnów"
	roundend_category = "thralle"
	antagpanel_category = "Darkspawn"
	banning_key = ROLE_DARKSPAWN
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	/// Zdolności thralla
	var/list/abilities = list(/datum/action/cooldown/spell/toggle/nightvision, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye/thrall)
	var/datum/team/darkspawn/team
	var/mutable_appearance/thrall_sigils

/datum/antagonist/thrall/get_team()
	return team

/datum/antagonist/thrall/on_gain()
	owner.special_role = "thrall"
	message_admins("[key_name_admin(owner.current)] was thralled by a darkspawn!")
	log_game("[key_name(owner.current)] was thralled by a darkspawn!")
	team = get_darkspawn_team()
	team.add_thrall(owner)
	var/datum/objective/thrall_serve/objective = new
	objective.owner = owner
	objectives += objective
	return ..()

/datum/antagonist/thrall/on_removal()
	message_admins("[key_name_admin(owner.current)] was dethralled!")
	log_game("[key_name(owner.current)] was dethralled!")
	team?.remove_thrall(owner)
	if(owner.special_role == "thrall")
		owner.special_role = null
	var/mob/living/M = owner.current
	if(M)
		if(issilicon(M))
			M.audible_message("<span class='notice'>[M] wydaje krótki pisk, a potem niskie piknięcie.</span>")
			to_chat(M, "<span class='userdanger'>Zostałeś zamieniony w [iscyborg(M) ? "cyborga" : "SI"]! Nie jesteś już thrallem! Choć się starasz, nie pamiętasz niczego ze swojej służby...</span>")
		else
			M.visible_message("<span class='big'>[M] wygląda, jakby znów był panem własnego umysłu!</span>")
			to_chat(M, "<span class='userdanger'>Przenikliwe białe światło zalewa twoje oczy. Twój umysł znów należy do ciebie! Choć się starasz, nie pamiętasz niczego o darkspawnach ani o czasie pod ich władzą...</span>")
	return ..()

/datum/antagonist/thrall/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	add_antag_hud(ANTAG_HUD_SHADOW, "thrall", current_mob)
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(thrall_life))
	current_mob.grant_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction |= ROLE_DARKSPAWN
	if(ishuman(current_mob))
		thrall_sigils = mutable_appearance('aquila/icons/mob/darkspawn/darkspawn.dmi', "veil_sigils", -UNIFORM_LAYER)
		thrall_sigils.color = COLOR_DARKSPAWN_PSI
		current_mob.add_overlay(thrall_sigils)
	for(var/spell in abilities)
		if(locate(spell) in current_mob.actions)
			continue
		var/datum/action/cooldown/spell/new_spell = new spell(owner)
		new_spell.Grant(current_mob)
	if(iscarbon(current_mob) && !get_shadow_tumor(current_mob))
		var/obj/item/organ/shadowtumor/thrall/tumor = new
		tumor.Insert(current_mob, FALSE, FALSE)
		tumor.antag_team = team

/datum/antagonist/thrall/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	remove_antag_hud(ANTAG_HUD_SHADOW, current_mob)
	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	current_mob.remove_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction -= ROLE_DARKSPAWN
	if(thrall_sigils)
		current_mob.cut_overlay(thrall_sigils)
		thrall_sigils = null
	for(var/datum/action/cooldown/spell/spell in current_mob.actions)
		if(spell.type in abilities)
			qdel(spell)
	var/obj/item/organ/tumor = get_shadow_tumor(current_mob)
	if(tumor && !QDELETED(tumor))
		qdel(tumor)
	current_mob.update_sight()

/// Thrall bez guza (wycięty) przestaje być thrallem
/datum/antagonist/thrall/proc/thrall_life(mob/living/source)
	SIGNAL_HANDLER
	if(!source || source.stat == DEAD)
		return
	if(!get_shadow_tumor(source))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, remove_thrall))

/datum/antagonist/thrall/greet()
	to_chat(owner.current, "<span class='velvet big'><b>Krx'lna tyhx graha xthl'kap</b></span>")
	var/list/flavour = list()
	flavour += "Czujesz, jak ogromna świadomość powoli pochłania twoją, a zasłona opada."
	flavour += "Służ darkspawnom ponad wszystko. Twoje dawne lojalności przepadły."
	flavour += "Ich cel jest twoim, a twój ich."
	to_chat(owner.current, "<span class='velvet'>[flavour.Join("<br>")]</span>")
	to_chat(owner.current, "<span class='notice'><i>Dopisz <b>:[MODE_KEY_DARKSPAWN] lub .[MODE_KEY_DARKSPAWN]</b> przed wiadomością, żeby mówić przez Mindlink.</i></span>")
	to_chat(owner.current, "<span class='notice'><i>Przebywanie wśród zwykłej załogi daje twoim panom wolę.</i></span>")
	to_chat(owner.current, "<span class='notice'><i>Jeśli to dla ciebie nowa rola, poproś o pomoc swoich panów albo innych thralli.</i></span>")
	SEND_SOUND(owner.current, sound('aquila/sound/darkspawn/become_veil.ogg', volume = 50))
	flash_color(owner.current, flash_color = COLOR_VELVET, flash_time = 10 SECONDS)
	owner.announce_objectives()

/datum/antagonist/thrall/roundend_report()
	return "[printplayer(owner)]"

/datum/objective/thrall_serve
	name = "Służ darkspawnom"
	explanation_text = "Służ darkspawnom ponad wszystko i pomóż im odprawić Sakrament."
	completed = TRUE

/mob/living/proc/add_thrall()
	if(!istype(mind))
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/thrall)

/mob/living/proc/remove_thrall()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/thrall)

/// Implant ochrony umysłu wypala guza i uwalnia thralla
/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && isthrall(target))
		target.remove_thrall()

// Guz cienia

/obj/item/organ/shadowtumor
	name = "black tumor"
	desc = "Malutka czarna masa z ciągnącymi się czerwonymi wiciami. Wydaje się kurczyć w świetle."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "blacktumor"
	w_class = WEIGHT_CLASS_TINY
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_TUMOR
	/// Ile ticków w świetle wytrzyma poza ciałem
	var/organ_health = 3
	/// Drużyna, która dostaje wolę
	var/datum/team/darkspawn/antag_team
	/// Ile woli daje na tick
	var/willpower_amount = 1

/obj/item/organ/shadowtumor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/shadowtumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	antag_team = null
	return ..()

/obj/item/organ/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > DARKSPAWN_DIM_LIGHT && organ_health > 0) // ginie w świetle
			organ_health--
		else if(light_count < DARKSPAWN_DIM_LIGHT && organ_health < 3) // leczy się w ciemności
			organ_health = min(organ_health + 1, 3)
		if(organ_health <= 0)
			visible_message("<span class='warning'>[src] zapada się w sobie!</span>")
			qdel(src)
			return
	else
		organ_health = min(organ_health + 0.5, 3)
	if(owner && owner.stat != DEAD && antag_team)
		antag_team.willpower_progress(willpower_amount)

/obj/item/organ/shadowtumor/on_find(mob/living/finder)
	. = ..()
	finder.visible_message("<span class='danger'>[finder] otwiera czaszkę [owner], odsłaniając pulsującą czarną masę z czerwonymi wiciami wczepionymi w mózg.</span>")

/// Guz thralla: daje więcej woli, bo na thralla wydano wolę
/obj/item/organ/shadowtumor/thrall
	willpower_amount = 2
	COOLDOWN_DECLARE(resist_cooldown)
	/// Odnowienie odepchnięcia przy próbie wycięcia
	var/cooldown_length = 15 SECONDS

/obj/item/organ/shadowtumor/thrall/process()
	if(owner && !isthrall(owner))
		qdel(src)
		return
	return ..()

/// Przytomny thrall odpycha wszystkich wokół, gdy ktoś próbuje wyciąć mu guza
/obj/item/organ/shadowtumor/thrall/proc/resist(mob/living/carbon/M)
	if(QDELETED(src) || M.stat != CONSCIOUS || !isthrall(M))
		return FALSE
	if(!COOLDOWN_FINISHED(src, resist_cooldown))
		return FALSE
	COOLDOWN_START(src, resist_cooldown, cooldown_length)
	playsound(M, 'sound/effects/tendril_destroyed.ogg', 80, TRUE)
	to_chat(M, "<span class='velvet big'><b><i>NIE TAK!</i></b></span>")
	M.visible_message("<span class='danger'>[M] nagle zrywa się i odrzuca wszystkich wokół!</span>")
	M.set_resting(FALSE)
	M.SetAllImmobility(0)
	for(var/mob/living/user in range(2, get_turf(M)))
		if(user == M || is_team_darkspawn(user))
			continue
		var/turf/target = get_ranged_target_turf(user, get_dir(M, user))
		user.throw_at(target, 2, 2, M)
		user.Knockdown(issilicon(user) ? 8 SECONDS : 4 SECONDS)
		user.adjustBruteLoss(20)
	return TRUE

// Psyche: kawałek umysłu darkspawna w postaci iluzji z graczem

/datum/antagonist/psyche
	name = "Psyche darkspawna"
	roundend_category = "thralle"
	antagpanel_category = "Darkspawn"
	banning_key = ROLE_DARKSPAWN
	show_in_antagpanel = FALSE

/datum/antagonist/psyche/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	add_antag_hud(ANTAG_HUD_SHADOW, "thrall", current_mob)
	current_mob.grant_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction |= ROLE_DARKSPAWN

/datum/antagonist/psyche/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return
	remove_antag_hud(ANTAG_HUD_SHADOW, current_mob)
	current_mob.remove_language(/datum/language/darkspawn, TRUE, TRUE, LANGUAGE_MIND)
	current_mob.faction -= ROLE_DARKSPAWN

/datum/antagonist/psyche/greet()
	to_chat(owner.current, "<span class='velvet bold'>Jesteś odłamkiem umysłu darkspawna. Walcz u jego boku, dopóki twoja postać się nie rozpadnie.</span>")
	to_chat(owner.current, "<span class='notice'><i>Dopisz <b>:[MODE_KEY_DARKSPAWN]</b> przed wiadomością, żeby mówić przez Mindlink.</i></span>")
