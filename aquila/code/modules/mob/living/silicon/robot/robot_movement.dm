/mob/living/silicon/robot
	/// Tiles walked, a servo whirs every second step
	var/servo_steps = 0

/mob/living/silicon/robot/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(Forced || stat == DEAD || buckled || throwing || (movement_type & (FLYING | FLOATING)) || !isturf(loc) || !has_gravity())
		return
	if(++servo_steps % 2)
		return
	playsound(src, "robot_step", 20, TRUE, -4)
