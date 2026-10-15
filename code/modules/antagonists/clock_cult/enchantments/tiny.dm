/datum/component/enchantment/tiny
	max_level = 1

/datum/component/enchantment/tiny/apply_effect(obj/item/target)
	examine_description = "Został pobłogosławiony i zakrzywia rzeczywistość w malutką przestrzeń wokół siebie."
	target.w_class = WEIGHT_CLASS_TINY
