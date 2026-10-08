/obj/item/food/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bite_consumption = 12
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2
	)
	tastes = list("the jungle" = 1, "bananas" = 1)
	foodtypes = MEAT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	var/faction
	var/spawned_mob = /mob/living/carbon/monkey

/obj/item/food/monkeycube/proc/Expand()
	if(GLOB.total_cube_monkeys >= CONFIG_GET(number/max_cube_monkeys))
		visible_message("<span class='warning'>[src] refuses to expand!</span>")
		return
	var/mob/spammer = get_mob_by_ckey(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location(), TRUE, spammer)
	if(faction)
		bananas.faction = faction
	if (!QDELETED(bananas))
		visible_message("<span class='notice'>[src] expands!</span>")
		bananas.log_message("Spawned via [src] at [AREACOORD(src)], Last attached mob: [key_name(spammer)].", LOG_ATTACK)
	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message("<span class='notice'>[src] fails to expand!</span>")
	qdel(src)

/obj/item/food/monkeycube/syndicate
	faction = list("neutral", FACTION_SYNDICATE)

/obj/item/food/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Co. brand gorilla cube. Now with extra molecules!"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15
	)
	tastes = list("the jungle" = 1, "bananas" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/gorilla

/obj/item/food/monkeycube/sheep
	name = "sheep cube"
	desc = "A Farm Town brand sheep cube."
	bite_consumption = 15
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("fluff" = 1, "the farm" = 1)
	spawned_mob = /mob/living/simple_animal/sheep

/obj/item/food/monkeycube/cow
	name = "cow cube"
	desc = "A Farm Town brand cow cube."
	bite_consumption = 18
	food_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("milk" = 1, "the farm" = 1)
	spawned_mob = /mob/living/simple_animal/cow

/obj/item/food/monkeycube/goat
	name = "goat cube"
	desc = "A Farm Town brand goat cube."
	bite_consumption = 18
	food_reagents = list(/datum/reagent/consumable/nutriment = 5)
	tastes = list("milk" = 1, "the farm" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/retaliate/goat
