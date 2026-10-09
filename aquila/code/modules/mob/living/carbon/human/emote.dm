/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/human/C = user
	var/turf/T = get_turf(user)
	var/obj/item/organ/butt/B = C.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		to_chat(user, "<span class='warning'>You don't have a butt!</span>")
		return FALSE

	if(HAS_TRAIT(user, TRAIT_MEGAFART) && HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
		to_chat(user, "<span class = 'userdanger'>You have a very bad feeling about this!</span>")
		if(do_mob(user, user, 3.5 SECONDS))
			explosion(T, -1, 0, 0, 0, 0, flame_range = 2)
			C.Knockdown(2 SECONDS)
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			C.apply_damage(15, BRUTE, BODY_ZONE_CHEST)

	else if(HAS_TRAIT(user, TRAIT_MEGAFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
		if(do_mob(user, user, 2.5 SECONDS))
			for(var/mob/M in urange(3, user))
				if(!M.stat)
					shake_camera(M, 1, 1)
			goonchem_vortex(T, 1, 2)
			C.Knockdown(1 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			//why are we still here? just to suffer?

	else if(HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] hunches down and grits [user.p_their()] teeth!</span>","<span class = 'warning'>You hunch down and grit your teeth. Stand still!</span>")
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

// Łzy na twarzy po *cry (port Yogstation#15690)

/// The time it takes for the crying visual to be removed
#define CRY_DURATION 12.8 SECONDS

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user)) // Give them a visual crying effect if they're human
		var/mob/living/carbon/human/human_user = user
		ADD_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

		// Use a timer to remove the effect after the defined duration has passed
		var/list/key_emotes = GLOB.emote_list["cry"]
		for(var/datum/emote/living/carbon/human/cry/human_emote in key_emotes)
			// The existing timer restarts if it is already running
			addtimer(CALLBACK(human_emote, PROC_REF(end_visual), human_user), CRY_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/emote/living/carbon/human/cry/proc/end_visual(mob/living/carbon/human/human_user)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

#undef CRY_DURATION

// Oryginał przepisuje rysowanie oczu na /obj/item/organ/eyes/proc/generate_body_overlay().
// U nas oczy rysuje dalej core, a łzy dochodzą jednym hookiem w species.dm i update_icons.dm.

#define OFFSET_X 1
#define OFFSET_Y 2

/// Returns the tears overlays for this human's face, or an empty list if they are not crying or have no eyes
/mob/living/carbon/human/proc/get_tears_overlays()
	. = list()
	if(!HAS_TRAIT(src, TRAIT_CRYING) || !getorganslot(ORGAN_SLOT_EYES))
		return
	var/mutable_appearance/tears_overlay = mutable_appearance('aquila/icons/mob/tears.dmi', "tears", -BODY_ADJ_LAYER)
	tears_overlay.color = COLOR_DARK_CYAN
	if(OFFSET_FACE in dna?.species.offset_features)
		var/offset = dna.species.offset_features[OFFSET_FACE]
		tears_overlay.pixel_x += offset[OFFSET_X]
		tears_overlay.pixel_y += offset[OFFSET_Y]
	. += tears_overlay

#undef OFFSET_X
#undef OFFSET_Y
