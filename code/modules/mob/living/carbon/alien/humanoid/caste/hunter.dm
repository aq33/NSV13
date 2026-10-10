/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 200
	health = 200
	icon_state = "alienh"
	var/atom/movable/screen/leap_icon

/mob/living/carbon/alien/humanoid/hunter/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/small
	return ..()

//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = TRUE)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on" : "off"]"
	update_icons()
	if(message)
		to_chat(src, "<span class='noticealien'>Będziesz teraz [leap_on_click ? "skakać na" : "ciąć"] wrogów!</span>")

/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		return ..()

#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/A)
	if((mobility_flags & (MOBILITY_MOVE | MOBILITY_STAND)) != (MOBILITY_MOVE | MOBILITY_STAND) || leaping)
		return

	if(!(COOLDOWN_FINISHED(src, pounce_cooldown)))
		to_chat(src, "<span class='alertalien'>Jesteś zbyt zmęczony, żeby teraz skoczyć!</span>")
		return

	if(!has_gravity() || !A.has_gravity())
		to_chat(src, "<span class='alertalien'>Skakanie bez grawitacji jest niebezpieczne!</span>")
		//It's also extremely buggy visually, so it's balance+bugfix
		return

	leaping = TRUE
	weather_immunities += "lava"
	update_icons()
	throw_at(A, MAX_ALIEN_LEAP_DIST, 1, src, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end)))

#undef MAX_ALIEN_LEAP_DIST

/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	weather_immunities -= "lava"
	update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()

	COOLDOWN_START(src, pounce_cooldown, 30)
	if(hit_atom)
		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			var/blocked = FALSE
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				if(H.check_shields(src, 0, "the [name]", attack_type = LEAP_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.visible_message("<span class ='danger'>[src] rzuca się na [L]!</span>", "<span class ='userdanger'>[src] rzuca się na ciebie!</span>")
				L.Paralyze(100)
				sleep(2)//Runtime prevention (infinite bump() calls on hulks)
				step_towards(src, L)
			else
				Paralyze(40, 1, 1)

			toggle_leap(FALSE)
		else if(hit_atom.density && !hit_atom.CanPass(src))
			visible_message("<span class ='danger'>[src] wpada z impetem na [hit_atom]!</span>", "<span class ='alertalien'>[src] wpada z impetem na [hit_atom]!</span>")
			Paralyze(40, 1, 1)

		if(leaping)
			leaping = FALSE
			update_icons()
			update_mobility()

/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	return ..()
