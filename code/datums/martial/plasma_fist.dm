#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	id = MARTIALART_PLASMAFIST
	help_verb = /mob/living/carbon/human/proc/plasma_fist_help


/datum/martial_art/plasma_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,TORNADO_COMBO))
		streak = ""
		Tornado(A,D)
		return 1
	if(findtext(streak,THROWBACK_COMBO))
		streak = ""
		Throwback(A,D)
		return 1
	if(findtext(streak,PLASMA_COMBO))
		streak = ""
		Plasma(A,D)
		return 1
	return 0

/datum/martial_art/plasma_fist/proc/TornadoAnimate(mob/living/carbon/human/A)
	set waitfor = FALSE
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!A)
			break
		A.setDir(i)
		playsound(A.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
		sleep(1)

/datum/martial_art/plasma_fist/proc/Tornado(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.say("ZAMIATAJĄCE TORNADO!", forced="plasma fist")
	TornadoAnimate(A)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	R.cast(RANGE_TURFS(1,A))
	log_combat(A, D, "tornado sweeped(Plasma Fist)")
	return

/datum/martial_art/plasma_fist/proc/Throwback(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='danger'>[A] trafia [D] Ciosem Plazmy!</span>", \
								"<span class='userdanger'>[A] trafia cię Ciosem Plazmy!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
	D.throw_at(throw_target, 200, 4,A)
	A.say("HYAH!", forced="plasma fist")
	log_combat(A, D, "threw back (Plasma Fist)")
	return

/datum/martial_art/plasma_fist/proc/Plasma(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("PLAZMOWA PIĘŚĆ!", forced="plasma fist")
	D.visible_message("<span class='danger'>[A] trafia [D] TECHNIKĄ PLAZMOWEJ PIĘŚCI!</span>", \
								"<span class='userdanger'>[A] trafia cię TECHNIKĄ PLAZMOWEJ PIĘŚCI!</span>")
	D.gib()
	log_combat(A, D, "gibbed (Plasma Fist)")
	return

/datum/martial_art/plasma_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/plasma_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/mob/living/carbon/human/proc/plasma_fist_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Plasma Fist."
	set category = "Plasma Fist"

	to_chat(usr, "<b><i>Zaciskasz pięści i doznajesz przebłysku wiedzy...</i></b>")
	to_chat(usr, "<span class='notice'>Zamiatające tornado</span>: krzywda, krzywda, rozbrojenie. Odpycha cel i wszystkich wokół.")
	to_chat(usr, "<span class='notice'>Odrzut</span>: rozbrojenie, krzywda, rozbrojenie. Rzuca celem i rzuca w niego przedmiotem.")
	to_chat(usr, "<span class='notice'>Plazmowa pięść</span>: krzywda, rozbrojenie, rozbrojenie, rozbrojenie, krzywda. Wybija przeciwnikowi mózg i rozrywa jego ciało.")
