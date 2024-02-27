/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(is_sinfuldemon(user)) //this is probably a snowflake way of doing it but sure. Demons of Greed don't need to farm this.
		to_chat(user,"Reserve this foolish game for mortals.")
		return
	.=..()


/obj/structure/cursed_slot_machine/betterchance //doubled chance of winnning.
	win_prob = 10


/obj/effect/gluttony/Cross(atom/movable/mover, turf/target)
	if(ismob(mover))
		var/mob/M = mover
		if(is_sinfuldemon(M))
			return TRUE
	.=..()
