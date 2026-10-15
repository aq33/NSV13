/datum/component/enchantment/penetration
	max_level = 5

/datum/component/enchantment/penetration/apply_effect(obj/item/target)
	examine_description = "Pobłogosławiono go darem przebijania pancerza - z łatwością przecina cele."
	target.armour_penetration = 15 * level
