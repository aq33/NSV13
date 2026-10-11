/obj/structure/janitorialcart/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!Forced && isturf(loc) && has_gravity())
		playsound(src, 'aquila/sound/effects/janicart_roll.ogg', 40, TRUE, -3)
