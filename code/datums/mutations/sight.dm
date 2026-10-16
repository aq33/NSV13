//Nearsightedness restricts your vision by several tiles.
/datum/mutation/nearsight
	name = "Near Sightness"
	desc = "The holder of this mutation has poor eyesight."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>Słabo widzisz.</span>"

/datum/mutation/nearsight/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.become_nearsighted(GENETIC_MUTATION)

/datum/mutation/nearsight/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.cure_nearsighted(GENETIC_MUTATION)


//Blind makes you blind. Who knew?
/datum/mutation/blind
	name = "Blindness"
	desc = "Renders the subject completely blind."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Nic nie widzisz.</span>"

/datum/mutation/blind/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.become_blind(GENETIC_MUTATION)

/datum/mutation/blind/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.cure_blind(GENETIC_MUTATION)


/datum/mutation/thermal
	name = "Thermal Vision"
	desc = "The user of this genome can visually percieve the unique human thermal signature."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = "<span class='notice'>Widzisz, jak z twojej skóry unosi się ciepło...</span>"
	instability = 25
	locked = TRUE
	var/visionflag = TRAIT_THERMAL_VISION

/datum/mutation/thermal/on_acquiring(mob/living/carbon/owner)
	if(..())
		return

	ADD_TRAIT(owner, visionflag, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/thermal/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, visionflag, GENETIC_MUTATION)
	owner.update_sight()

//X-ray Vision lets you see through walls.
/datum/mutation/thermal/x_ray
	name = "X Ray Vision"
	desc = "A strange genome that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	text_gain_indication = "<span class='notice'>Ściany nagle znikają!</span>"
	instability = 35
	locked = TRUE
	visionflag = TRAIT_XRAY_VISION

//Laser Eyes lets you shoot lasers from your eyes!
/datum/mutation/laser_eyes
	name = "Laser Eyes"
	desc = "Reflects concentrated light back from the eyes."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Czujesz narastający ucisk za oczami.</span>"
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD

/datum/mutation/laser_eyes/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER))

/datum/mutation/laser_eyes/get_visual_indicator()
	return visual_indicators[type][1]

// AQ EDIT START - sygnatura zgodna z RangedAttack (dostawało parametry kliknięcia zamiast celu), strzał rani oczy
/datum/mutation/laser_eyes/on_ranged_attack(atom/target, modifiers)
	if(!owner.combat_mode || owner.next_move > world.time)
		return
	owner.LaserEyes(target, modifiers)
	var/obj/item/organ/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	eyes?.applyOrganDamage(1)
// AQ EDIT END
