/datum/surgery/core_removal
	name = "core removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/extract_core)
	target_mobtypes = list(/mob/living/simple_animal/slime)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	lying_required = FALSE
	ignore_clothes = TRUE

/datum/surgery/core_removal/can_start(mob/user, mob/living/target)
	if(target.stat == DEAD)
		return 1
	return 0

//extract brain
/datum/surgery_step/extract_core
	name = "extract core"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100)
	time = 16

/datum/surgery_step/extract_core/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wydobywać rdzeń z [target]...</span>",
		"[user] zaczyna wydobywać rdzeń z [target].",
		"[user] zaczyna wydobywać rdzeń z [target].")

/datum/surgery_step/extract_core/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/slime/slime = target
	if(slime.cores > 0)
		slime.cores--
		display_results(user, target, "<span class='notice'>Pomyślnie wydobywasz rdzeń z [target]. Pozostało rdzeni: [slime.cores].</span>",
			"[user] pomyślnie wydobywa rdzeń z [target]!",
			"[user] pomyślnie wydobywa rdzeń z [target]!")

		var/obj/item/slime_extract/item = new slime.coretype(slime.loc)
		if(slime.transformeffects & SLIME_EFFECT_GOLD)
			item.sparkly = TRUE
		if(slime.cores <= 0)
			slime.icon_state = "[slime.colour] baby slime dead-nocore"
			return 1
		else
			return 0
	else
		to_chat(user, "<span class='warning'>W [target] nie zostały już żadne rdzenie!</span>")
		return 1
