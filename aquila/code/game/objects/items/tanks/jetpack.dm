/// Thruster sound while an active jetpack moves
/obj/item/tank/jetpack/Moved(atom/OldLoc, Dir)
	. = ..()
	if(on)
		playsound(src, 'aquila/sound/vehicles/jetpack.ogg', 100, 1)
