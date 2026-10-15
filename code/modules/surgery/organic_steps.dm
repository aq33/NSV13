
//make incision
/datum/surgery_step/incise
	name = "make incision"
	implements = list(TOOL_SCALPEL = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	time = 16
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz nacinać [strefa_pl(target_zone, TRUE)] [target]...</span>",
		"[user] zaczyna nacinać [strefa_pl(target_zone, TRUE)] [target].",
		"[user] zaczyna nacinać [strefa_pl(target_zone, TRUE)] [target].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if ishuman(target)
		var/mob/living/carbon/human/H = target
		if (!((NOBLOOD in H.dna.species.species_traits) || HAS_TRAIT(H, TRAIT_NO_BLOOD)))
			display_results(user, target, "<span class='notice'>Wokół nacięcia ([strefa_pl(target_zone)]) [H] zbiera się krew.</span>",
				"Wokół nacięcia ([strefa_pl(target_zone)]) [H] zbiera się krew.",
				"")
			H.add_bleeding(BLEED_CUT)
	return TRUE

/datum/surgery_step/incise/nobleed //silly friendly!

/datum/surgery_step/incise/nobleed/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz <i>ostrożnie</i> nacinać [strefa_pl(target_zone, TRUE)] [target]...</span>",
		"[user] zaczyna <i>ostrożnie</i> nacinać [strefa_pl(target_zone, TRUE)] [target].",
		"[user] zaczyna <i>ostrożnie</i> nacinać [strefa_pl(target_zone, TRUE)] [target].")

/datum/surgery_step/incise/nobleed/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return TRUE

//clamp bleeders
/datum/surgery_step/clamp_bleeders
	name = "clamp bleeders"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/package_wrap = 35, /obj/item/stack/cable_coil = 15)
	time = 24
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz zaciskać krwawiące naczynia ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna zaciskać krwawiące naczynia ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna zaciskać krwawiące naczynia ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(20,0)
	return ..()


//retract skin
/datum/surgery_step/retract_skin
	name = "retract skin"
	implements = list(TOOL_RETRACTOR = 100, TOOL_SCREWDRIVER = 45, TOOL_WIRECUTTER = 35)
	time = 24
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz odciągać skórę ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna odciągać skórę ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna odciągać skórę ([strefa_pl(target_zone)]) [target].")



//close incision
/datum/surgery_step/close
	name = "mend incision"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 24
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz zamykać nacięcie ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna zamykać nacięcie ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna zamykać nacięcie ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.is_hot()

	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(45,0)
	target.cauterise_wounds()
	return ..()



//saw bone
/datum/surgery_step/saw
	name = "saw bone"
	implements = list(TOOL_SAW = 100,/obj/item/melee/arm_blade = 75,
	/obj/item/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	time = 54
	preop_sound = list(
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/surgery/scalpel1.ogg',
		/obj/item/kitchen/knife/butcher = 'sound/surgery/scalpel1.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz przepiłowywać kość ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna przepiłowywać kość ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna przepiłowywać kość ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(50, BRUTE, "[target_zone]")
	display_results(user, target, "<span class='notice'>Otwierasz piłą [strefa_pl(target_zone, TRUE)] [target].</span>",
		"[user] saws [target]'s [parse_zone(target_zone)] open!",
		"[user] saws [target]'s [parse_zone(target_zone)] open!")
	return 1

//drill bone
/datum/surgery_step/drill
	name = "drill bone"
	implements = list(TOOL_DRILL = 100, /obj/item/powertool/hand_drill = 80, /obj/item/pickaxe/drill = 60, TOOL_SCREWDRIVER = 20)
	time = 30

/datum/surgery_step/drill/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/powertool/hand_drill))
		var/obj/item/powertool/hand_drill = tool
		if(hand_drill.tool_behaviour != TOOL_SCREWDRIVER)
			return FALSE
	return TRUE

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wiercić w kości ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna wiercić w kości ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna wiercić w kości ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Nawiercasz [strefa_pl(target_zone, TRUE)] [target].</span>",
		"[user] nawierca [strefa_pl(target_zone, TRUE)] [target]!",
		"[user] nawierca [strefa_pl(target_zone, TRUE)] [target]!")
	return 1
