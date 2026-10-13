/datum/guardian_ability/major/special/timestop
	name = "Time Stop"
	desc = "The guardian can stop time in a localized area."
	ui_icon = "clock"
	cost = 5
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/timestop/guardian

/*/datum/guardian_ability/major/special/timestop/Berserk()
	guardian.RemoveSpell(spell)
	spell = new /obj/effect/proc_holder/spell/aoe_turf/timestop/guardian/berserk
	guardian.AddSpell(spell)*/

/obj/effect/proc_holder/spell/aoe_turf/timestop/guardian
	invocation_type = "none"
	clothes_req = FALSE

/obj/effect/proc_holder/spell/aoe_turf/timestop/guardian/cast(list/targets, mob/user = usr)
	new /obj/effect/timestop(get_turf(user), timestop_range, timestop_duration, list(user))
