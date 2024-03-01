/obj/effect/proc_holder/spell/targeted/inflict_handler
	var/amt_firestacks = 0
	var/ignites = FALSE

/obj/effect/proc_holder/spell/targeted/inflict_handler/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		target.adjust_fire_stacks(amt_firestacks)
		if(ignites)
			target.IgniteMob()
	.=..()
