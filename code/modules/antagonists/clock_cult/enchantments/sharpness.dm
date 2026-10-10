/datum/component/enchantment/sharpness
	max_level = 5

/datum/component/enchantment/sharpness/apply_effect(obj/item/target)
	examine_description = "Pobłogosławiono go darem ostrości."
	target.force += 2 * level
