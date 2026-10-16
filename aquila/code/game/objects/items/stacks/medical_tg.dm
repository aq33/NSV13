// AQUILA - sutures and regenerative mesh from tgstation, replacing bruise packs and ointment in kits.
// They heal a little per use and keep going on their own until the limb is healed or the stack runs out.
// Gauze stays the item that stops bleeding.

/obj/item/stack/medical/suture
	name = "suture"
	singular_name = "suture"
	desc = "Basic sterile sutures used to seal up cuts and lacerations and stop bleeding."
	icon = 'aquila/icons/obj/medical/stack_medical.dmi'
	icon_state = "suture"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	item_state = "bandage"
	amount = 10
	max_amount = 10
	self_delay = 3 SECONDS
	heal_brute = 10
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)
	/// How long it takes on someone else
	var/other_delay = 1 SECONDS

/obj/item/stack/medical/suture/one
	amount = 1

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	singular_name = "medicated suture"
	icon_state = "suture_purp"
	desc = "A suture infused with drugs that speed up wound healing of the treated laceration."
	heal_brute = 15
	grind_results = list(/datum/reagent/medicine/styptic_powder = 2)

/obj/item/stack/medical/suture/medicated/one
	amount = 1

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	singular_name = "mesh piece"
	desc = "A bacteriostatic mesh used to dress burns."
	icon = 'aquila/icons/obj/medical/stack_medical.dmi'
	icon_state = "regen_mesh"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	item_state = "bandage"
	amount = 15
	max_amount = 15
	self_delay = 3 SECONDS
	heal_burn = 10
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)
	var/other_delay = 1 SECONDS

/obj/item/stack/medical/mesh/one
	amount = 1

/obj/item/stack/medical/mesh/advanced
	name = "advanced regenerative mesh"
	desc = "An advanced mesh made with aloe extracts and sterilizing chemicals, used to treat burns."
	icon_state = "aloe_mesh"
	heal_burn = 15
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = 2)

/obj/item/stack/medical/mesh/advanced/one
	amount = 1

/obj/item/stack/medical/suture/attack(mob/living/M, mob/user)
	if(!iscarbon(M))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(treat_repeatedly), M, user, other_delay)

/obj/item/stack/medical/mesh/attack(mob/living/M, mob/user)
	if(!iscarbon(M))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(treat_repeatedly), M, user, other_delay)

/// tgstation style treatment: one piece per cycle until the limb is healed or the stack is gone
/obj/item/stack/medical/proc/treat_repeatedly(mob/living/carbon/patient, mob/user, delay_other)
	if(patient in user.do_afters)
		return
	if(patient.stat == DEAD)
		to_chat(user, "<span class='danger'>[patient] nie żyje, nie możesz mu pomóc!</span>")
		return
	if(!patient.can_inject(user, TRUE))
		return
	var/obj/item/bodypart/affecting = patient.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		to_chat(user, "<span class='warning'>[patient] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "<span class='warning'>Lekarstwo nie zadziała na robotyczną kończynę!</span>")
		return
	var/first = TRUE
	while(amount > 0 && !QDELETED(affecting) && affecting.owner == patient)
		var/needs_brute = heal_brute && affecting.brute_dam > 0
		var/needs_burn = heal_burn && affecting.burn_dam > 0
		if(!needs_brute && !needs_burn)
			if(first)
				to_chat(user, "<span class='warning'>[src] nie pomoże na obrażenia tej części ciała.</span>")
			else
				affecting.balloon_alert(user, "wyleczone")
			return
		if(first)
			user.visible_message("<span class='notice'>[user] zaczyna opatrywać [patient] przy pomocy [src].</span>", "<span class='notice'>Zaczynasz opatrywać [patient == user ? "siebie" : patient] przy pomocy [src].</span>")
			first = FALSE
		if(!do_mob(user, patient, patient == user ? self_delay : delay_other))
			return
		if(heal_brute)
			playsound(user.loc, 'aquila/sound/effects/suture.ogg', 50, 1)
		if(affecting.heal_damage(heal_brute, heal_burn))
			patient.update_damage_overlays()
		if(!use(1))
			return
