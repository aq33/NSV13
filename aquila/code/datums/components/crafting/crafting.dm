/// Crafting sound while the do_after runs. Checked first, so a recipe missing parts stays silent.
/datum/component/personal_crafting/construct_item(atom/a, datum/crafting_recipe/R)
	if(ismob(a) && R.time)
		var/list/contents = get_surroundings(a, R.blacklist)
		if(check_contents(a, R, contents) && check_tools(a, R, contents))
			playsound(a, 'aquila/sound/effects/craft.ogg', 40, TRUE, -3)
	return ..()
