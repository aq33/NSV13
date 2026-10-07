/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/human/C = user
	var/turf/T = get_turf(user)
	var/obj/item/organ/butt/B = C.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		to_chat(user, "<span class='warning'>Nie masz tyłka!</span>")
		return FALSE

	if(HAS_TRAIT(user, TRAIT_MEGAFART) && HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		to_chat(user, "<span class = 'userdanger'>Masz co do tego bardzo złe przeczucia!</span>")
		if(do_mob(user, user, 3.5 SECONDS))
			explosion(T, -1, 0, 0, 0, 0, flame_range = 2)
			C.Knockdown(2 SECONDS)
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			C.apply_damage(15, BRUTE, BODY_ZONE_CHEST)

	else if(HAS_TRAIT(user, TRAIT_MEGAFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		if(do_mob(user, user, 2.5 SECONDS))
			for(var/mob/M in urange(3, user))
				if(!M.stat)
					shake_camera(M, 1, 1)
			goonchem_vortex(T, 1, 2)
			C.Knockdown(1 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			//why are we still here? just to suffer?

	else if(HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		if(do_mob(user, user, 1.5 SECONDS))
			if(istype(T, /turf/open))
				T.atmos_spawn_air("plasma=3")
			C.Knockdown(0.5 SECONDS)
			C.apply_damage(20, TOX)

	/*	jeśli ktoś ma pomysł jak to ładniej zakodować, to dajcie znać na discordzie (b4cku#1372).
		miałem do wyboru albo przepisać WSZYSTKIE checki na początku i na końcu zostawić ..(), które by wykonało słyszalną akcję i dźwięk
		albo sprawić żeby ..() wykonało checki na początku, a skutki wklepać ręcznie na koniec.*/

	B.fart(C) // AQ EDIT: butt port from Hippie

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	return 'aquila/sound/voice/human/cry.ogg'

/datum/emote/living/carbon/human/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "przechyla głowę na bok"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/wing/get_sound(mob/living/carbon/human/user)
	if(istype(user.getorganslot(ORGAN_SLOT_WINGS), /obj/item/organ/wings/moth))
		return 'aquila/sound/emotes/moth_flutter.ogg'
