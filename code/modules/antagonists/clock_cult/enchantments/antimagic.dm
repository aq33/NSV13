/datum/component/enchantment/anti_magic
	max_level = 1

/datum/component/enchantment/anti_magic/apply_effect(obj/item/target)
	examine_description = "Pobłogosławiono go darem ochrony przed magią - żadna magia nie działa na jego właściciela."
	target.AddComponent(/datum/component/anti_magic, TRUE, TRUE)
