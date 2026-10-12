//==================================//
// !      Sigil of Vitality ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_vitality
	name = "Vitality Matrix"
	desc = "Summons a vitality matrix, which drains the life force of non servants, and can be used to heal or revive servants. Requires 2 invokers."
	tip = "Leczy i wskrzesza martwych sług, wysysając zdrowie z niesług."
	button_icon_state = "Sigil of Vitality"
	power_cost = 300
	invokation_time = 50
	invokation_text = list("Me życie w twoich rękach.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/vitality
	cogs_required = 2
	invokers_required = 2
	category = SPELLTYPE_SERVITUDE

//==========Vitality=========
/obj/structure/destructible/clockwork/sigil/vitality
	name = "vitality matrix"
	desc = "A twisting, confusing artifact that drains the unenlightended on contact."
	clockwork_desc = "Piękny artefakt wysysający życie z heretyków umieszczonych na nim."
	icon_state = "sigilvitality"
	effect_stand_time = 20
	idle_color = "#5e87c4"
	invokation_color = "#83cbe7"
	pulse_color = "#c761d4"
	fail_color = "#525a80"
	looping = TRUE

/obj/structure/destructible/clockwork/sigil/vitality/can_affect(mob/living/M)
	if(is_servant_of_ratvar(M))
		return TRUE
	if(M.stat == DEAD)
		return FALSE
	var/amc = M.anti_magic_check(magic=FALSE,holy=TRUE)
	if(amc)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_NODEATH))
		return FALSE
	if(issilicon(M))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/vitality/apply_effects(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		if(M.stat == DEAD)
			var/damage_healed = 20 + ((M.maxHealth - M.health) * 0.6)
			if(GLOB.clockcult_vitality >= damage_healed)
				GLOB.clockcult_vitality -= damage_healed
				M.revive(TRUE, TRUE)
				if(M.mind)
					M.mind.grab_ghost(TRUE)
				else
					var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako [M.name], nieaktywny kultysta zegara?", ROLE_SERVANT_OF_RATVAR, /datum/role_preference/antagonist/clock_cultist, 7.5 SECONDS, M)
					if(LAZYLEN(candidates))
						var/mob/dead/observer/C = pick(candidates)
						message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(M)]) to replace an AFK player.")
						M.key = C.key
			else
				visible_message("<span class='neovgre'>[src] nie zdołał wskrzesić [M]!</span>")
			return
		var/healing_performed = CLAMP(M.maxHealth - M.health, 0, 5)	//5 Vitality to heal 5 of all damage types at once
		if(GLOB.clockcult_vitality >= healing_performed * 0.3)
			GLOB.clockcult_vitality -= healing_performed * 0.3
			//Do healing
			M.adjustBruteLoss(-5, FALSE)
			M.adjustFireLoss(-5, FALSE)
			M.adjustOxyLoss(-5, FALSE)
			M.adjustToxLoss(-5, FALSE, TRUE)
			M.adjustCloneLoss(-5)
		else
			visible_message("<span class='neovgre'>[src] nie zdołał uleczyć [M]!</span>", "<span class='neovgre'>Za mało witalności, by uleczyć twoje rany!</span>")
	else
		if(M.anti_magic_check(magic=FALSE,holy=TRUE))
			return
		if(is_convertable_to_clockcult(M) && !GLOB.gateway_opening)
			visible_message("<span class='neovgre'>[src] odmawia wyssania witalności [M] - ten umysł ma wielki potencjał!</span>")
			return
		M.Paralyze(10)
		var/before_cloneloss = M.getCloneLoss()
		M.adjustCloneLoss(20, TRUE, TRUE)
		var/after_cloneloss = M.getCloneLoss()
		if(before_cloneloss == after_cloneloss)
			visible_message("<span class='neovgre'>[src] nie zdołał wyssać ducha [M]!</span>")
			return
		playsound(loc, 'sound/magic/clockwork/ratvar_attack.ogg', 40)
		if(M.stat == DEAD && length(GLOB.servant_spawns))
			M.become_husk()
			M.death()
			playsound(loc, 'sound/magic/exit_blood.ogg', 60)
			to_chat(M, "<span class='neovgre'>Ostatek twojego życia zostaje wyssany...</span>")
			hierophant_message("[src] wysysa witalność z [M]!", null, "<span class='inathneq'>")
			var/mob/cogger = new /mob/living/simple_animal/drone/cogscarab(get_turf(M))
			cogger.key = M.key
			if(!cogger.grab_ghost(TRUE))
				//Replace the mob with a shell
				qdel(cogger)
				new /obj/effect/mob_spawn/drone/cogscarab(get_turf(M))
			add_servant_of_ratvar(cogger, silent=TRUE)
			return
		if(M.client)
			M.visible_message("<span class='neovgre'>[M] słabnie, a z ciała ucieka kolor.</span>", "<span class='neovgre'>Czujesz, jak słabnie twoja dusza...</span>")
			GLOB.clockcult_vitality += 30
		GLOB.clockcult_vitality += 10
