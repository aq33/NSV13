
/datum/mind/proc/try_give_equipment_fallback()
	if(!uplink_exists && !(locate(/datum/action/special_equipment_fallback) in current.actions))
		var/datum/action/special_equipment_fallback/fallback = new(src)
		fallback.Grant(current)
	.=..()
/datum/mind/proc/AddSpell(obj/effect/proc_holder/spell/S)
	S.on_gain(current)
	.=..()

/datum/mind/proc/RemoveSpell(obj/effect/proc_holder/spell/spell)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(istype(S, spell))
			spell_list -= S
			S.on_lose(current)
			qdel(S)
	.=..()

/datum/mind/proc/transfer_mindbound_actions(mob/living/new_character)
	for(var/X in spell_list)
		var/obj/effect/proc_holder/spell/S = X
		S.action.Grant(new_character)
		S.on_gain(new_character)

