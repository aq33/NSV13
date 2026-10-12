#define HEART_RESPAWN_THRESHHOLD 40
#define HEART_SPECIAL_SHADOWIFY 2

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = SPECIES_SHADOWPERSON
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	species_traits = list(NOBLOOD,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NOBREATH)
	inherent_factions = list("faithless")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	mutanteyes = /obj/item/organ/eyes/night_vision
	species_language_holder = /datum/language_holder/shadowpeople

	species_chest = /obj/item/bodypart/chest/shadow
	species_head = /obj/item/bodypart/head/shadow
	species_l_arm = /obj/item/bodypart/l_arm/shadow
	species_r_arm = /obj/item/bodypart/r_arm/shadow
	species_l_leg = /obj/item/bodypart/l_leg/shadow
	species_r_leg = /obj/item/bodypart/r_leg/shadow


/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()

		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			H.take_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
		else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
			H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)

/datum/species/shadow/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/shadow/nightmare
	name = "Nightmare"
	id = "nightmare"
	burnmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES,NOFLASH)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOHUNGER)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare
	mutant_organs = list(/obj/item/organ/heart/nightmare)
	mutant_brain = /obj/item/organ/brain/nightmare

	var/info_text = "Jesteś <span class='danger'>Koszmarem</span>. Zdolność <span class='warning'>chodzenia w cieniu</span> pozwala ci po aktywacji poruszać się bez ograniczeń w ciemności. Twój <span class='warning'>pożeracz światła</span> niszczy każde źródło światła, które zaatakujesz, i każde światło trzymane przez żywą istotę. Na ciemnym polu automatycznie unikasz ostrzału i ataków wręcz. Po śmierci w końcu odrodzisz się, jeśli zostaniesz w ciemności."

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))

/datum/species/shadow/nightmare/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message("<span class='danger'>[H] tańczy w cieniach, unikając [P]!</span>")
			playsound(T, "bullet_miss", 75, 1)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE

//Organs

/obj/item/organ/brain/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon_state = "brain-x-d"
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/shadowwalk

/obj/item/organ/brain/nightmare/Insert(mob/living/carbon/M, special = 0)
	..()
	if(M.dna.species.id != "nightmare")
		M.set_species(/datum/species/shadow/nightmare)
		visible_message("<span class='warning'>[M] miota się, gdy [src] zapuszcza korzenie w jego ciele!</span>")
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/SW = new
	M.AddSpell(SW)
	shadowwalk = SW


/obj/item/organ/brain/nightmare/Remove(mob/living/carbon/M, special = 0)
	if(shadowwalk)
		M.RemoveSpell(shadowwalk)
	..()


/obj/item/organ/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = "#1C1C1C"
	var/respawn_progress = 0
	var/obj/item/light_eater/blade
	decay_factor = 0


/obj/item/organ/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] podnosi [src] do ust i wgryza się w to zębami!</span>", \
						 "<span class='danger'>[src] jest w twoich dłoniach nienaturalnie zimne. Podnosisz to do ust i pożerasz!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)


	user.visible_message("<span class='warning'>Z ręki [user] tryska krew, gdy ta zmienia się w broń!</span>", \
						 "<span class='userdanger'>Lodowata krew płynie ci w żyłach, gdy twoja ręka się przekształca!</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/nightmare/Insert(mob/living/carbon/M, special = 0)
	..()
	if(special != HEART_SPECIAL_SHADOWIFY)
		blade = new/obj/item/light_eater
		M.put_in_hands(blade)

/obj/item/organ/heart/nightmare/Remove(mob/living/carbon/M, special = 0)
	respawn_progress = 0
	if(blade && special != HEART_SPECIAL_SHADOWIFY)
		M.visible_message("<span class='warning'>[blade] się rozpada!</span>")
		QDEL_NULL(blade)
	..()

/obj/item/organ/heart/nightmare/Stop()
	return 0

/obj/item/organ/heart/nightmare/update_icon()
	return //always beating visually

/obj/item/organ/heart/nightmare/on_death()
	if(!owner)
		return
	var/turf/T = get_turf(owner)
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			respawn_progress++
			playsound(owner,'sound/effects/singlebeat.ogg',40,1)
	if(respawn_progress >= HEART_RESPAWN_THRESHHOLD)
		owner.revive(full_heal = TRUE)
		if(!(owner.dna.species.id == "shadow" || owner.dna.species.id == "nightmare"))
			var/mob/living/carbon/old_owner = owner
			Remove(owner, HEART_SPECIAL_SHADOWIFY)
			old_owner.set_species(/datum/species/shadow)
			Insert(old_owner, HEART_SPECIAL_SHADOWIFY)
			to_chat(owner, "<span class='userdanger'>Czujesz, jak cienie wnikają w twoją skórę i wskakują w środek klatki piersiowej! Żyjesz!</span>")
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))
		owner.visible_message("<span class='warning'>[owner] chwiejnie staje na nogi!</span>")
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, 1)
		respawn_progress = 0

//Weapon

/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP

/obj/item/light_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, INNATE_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)

/obj/item/light_eater/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	AM.lighteater_act(src)

/atom/movable/lighteater_act(obj/item/light_eater/light_eater)
	..()
	for(var/datum/component/overlay_lighting/light_source in affected_dynamic_lights)
		if(light_source.parent != src)
			var/atom/A = light_source.parent
			A.lighteater_act(light_eater)

/mob/living/lighteater_act(obj/item/light_eater/light_eater)
	..()
	if(on_fire)
		ExtinguishMob()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	if(pulling)
		pulling.lighteater_act(light_eater)

/mob/living/carbon/human/lighteater_act(obj/item/light_eater/light_eater)
	..()
	if(isethereal(src))
		emp_act(EMP_LIGHT)

/mob/living/silicon/robot/lighteater_act(obj/item/light_eater/light_eater)
	..()
	if(lamp_enabled)
		smash_headlamp()

/obj/structure/bonfire/lighteater_act(obj/item/light_eater/light_eater)
	if(burning)
		extinguish()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	..()

/obj/structure/glowshroom/lighteater_act(obj/item/light_eater/light_eater)
	..()
	if (light_power > 0)
		acid_act()

/obj/item/lighteater_act(obj/item/light_eater/light_eater)
	..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message("<span class='danger'>[light_eater] dezintegruje [src]!</span>")
	burn()
	playsound(src, 'sound/items/welder.ogg', 50, 1)


/obj/item/modular_computer/tablet/lighteater_act(obj/item/light_eater/light_eater)
	if(light_range && light_power > 0 && light_on)
		// Only the queen of Beetania can save our IDs from this infernal nightmare
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		card_slot2.try_eject()
		card_slot.try_eject()
	..()

/obj/item/clothing/head/helmet/space/plasmaman/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!lamp_functional)
		return
	if(helmet_on)
		smash_headlamp()
	..()

/turf/open/floor/light/lighteater_act(obj/item/light_eater/light_eater)
	. = ..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message("<span class='danger'>[light_eater] dezintegruje żarówkę [src]!</span>")
	break_tile()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

#undef HEART_SPECIAL_SHADOWIFY
#undef HEART_RESPAWN_THRESHHOLD
