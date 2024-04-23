/obj/effect/proc_holder/spell/targeted/shapeshift/demon //emergency get out of jail card.
	name = "Lesser Demon Form"
	desc = "Take on your true demon form. This form is strong but very obvious, and especially weak to holy influence. \
	Also, note that damage taken in this form can transform into your normal body. Heal by attacking living creatures before transforming back if gravely wounded!"
	invocation = "COWER, MORTALS!!"
	shapeshift_type = /mob/living/simple_animal/lesserdemon
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "daemontransform"
	action_background_icon_state = "bg_demon"

/mob/living/simple_animal/lesserdemon
	name = "demon"
	real_name = "demon"
	desc = "A large, menacing creature covered in armored red scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'aquila/icons/mob/mob.dmi'
	icon_state = "lesserdaemon"
	icon_living = "lesserdaemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 0.33
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	deathmessage = "wails in anger and fear as it collapses in defeat!"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 24
	//melee_damage_lower = 24
	//melee_damage_upper = 24
	//wound_bonus = -15 Jak sie woundy przeportuje to zostawiam wrazie co
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	loot = (/obj/effect/decal/cleanable/blood)
	del_on_death = TRUE

/mob/living/simple_animal/lesserdemon/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/nullrod))
		visible_message("<span class='warning'[src] screams in unholy pain from the blow!</span>", \
						"<span class='cult'As \the [W] hits you, you feel holy power blast through your form, tearing it apart!</span>")
		adjustBruteLoss(22) //22 extra damage from the nullrod while in your true form. On average this means 40 damage is taken now.

/mob/living/simple_animal/lesserdemon/UnarmedAttack(mob/living/L, proximity)//10 hp healed from landing a hit.
	if(isliving(L))
		if(L.stat != DEAD && !L.anti_magic_check(TRUE, TRUE)) //demons do not gain succor from the dead or holy
			adjustHealth(-maxHealth * 0.05)
	return ..()

/mob/living/simple_animal/lesserdemon/Life()
	. = ..()
	if(!.)
		return
	if(istype(get_area(src), /area/chapel)) //being a non-carbon will not save you!
		if(src.stat != DEAD) //being dead, however, will save you
			src.visible_message("<span class='warning'[src] begins to melt apart!</span>", "<span class='danger'Your very soul melts from the holy room!</span>", "You hear sizzling.")
			adjustHealth(20) //20 damage every ~2 seconds. About 20 seconds for a full HP demon to melt apart in the chapel.

/obj/effect/proc_holder/spell/targeted/touch/torment
	name = "Cierpienie"
	desc = "Ból i agonia przechodzi przez twoje palce"
	invocation = "COWER, MORTALS!!"
	action_icon = 'icons/obj/items_and_weapons.dmi'
	action_icon_state = "disintegrate"
	action_background_icon_state = "bg_demon"
	clothes_req = FALSE
	school = "transmutation"
	charge_max = 300
	cooldown_min = 200
	hand_path = /obj/item/melee/touch_attack/torment
	sound = 'sound/magic/fleshtostone.ogg'



/obj/item/melee/touch_attack/torment
	name = "Vindictive Hand"
	desc = "An utterly scornful mass of hateful energy, ready to strike."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	catchphrase = "Cierp"
	on_use_sound = 'sound/magic/disintegrate.ogg'




/obj/item/melee/touch_attack/torment/afterattack(mob/living/target, mob/living/carbon/user)
	if(target.anti_magic_check())
		to_chat(user, span_warning("[target] resists your torment!"))
		to_chat(target, span_warning("A hideous feeling of agony dances around your mind before being suddenly dispelled."))
		..()
		return TRUE
	playsound(user, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	target.blur_eyes(15) //huge array of relatively minor effects.
	target.Jitter(5 SECONDS)
	//target.confuse
	target.adjust_disgust(40)
	//target.hall
	target.Immobilize(3 SECONDS)
	target.Stun(1 SECONDS)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
	target.visible_message(span_danger("[target] cringes in pain as they hold their head for a second!"))
	target.emote("scream")
	to_chat(target, span_warning("You feel an explosion of pain erupt in your mind!"))
	qdel(src)
	var/datum/hallucination/H = pick(GLOB.hallucination_list)
	H = new H(target)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/demon
	clothes_req = FALSE
	jaunt_in_type = /obj/effect/temp_visual/demon
	jaunt_out_type = /obj/effect/temp_visual/demon/out


/obj/effect/temp_visual/demon
	name = "???"
	icon = 'aquila/icons/mob/mob.dmi'
	icon_state = "jaunt_in"
	duration = 12

/obj/effect/temp_visual/demon/out
	icon_state = "jaunt_out"
	duration = 5
