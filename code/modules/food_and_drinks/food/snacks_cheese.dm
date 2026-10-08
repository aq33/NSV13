///////////////////////////////////////////CHEESE////////////////////////////////////////////
// Our cheese varieties (ser, #202) on top of newfood /obj/item/food/cheese.
// Every wheel slices into its own wedge through slice_type (see cheese.dm).

//cheesemix
/obj/item/food/cheesemix
	name = "cheese mix"
	icon_state = "cheesemix"
	icon = 'icons/obj/food/cheese.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter milk" = 1)
	desc = "Cheese mix, ready to be heated."
	foodtypes = DAIRY

/obj/item/food/cheesemix_heated
	name = "heated cheese mix"
	icon_state = "cheesemix_heated"
	icon = 'icons/obj/food/cheese.dmi'
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter cheese" = 1)
	desc = "Heated cheese mix, you can see curds floating."
	foodtypes = DAIRY

//american cheese
/obj/item/food/cheese/wheel/american
	name = "american cheese block"
	desc = "A block of american plastic cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "american_block"
	slice_type = /obj/item/food/cheese/wedge/american
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("plastic" = 1)

/obj/item/food/cheese/wedge/american
	name = "american cheese slice"
	desc = "A slice of american plastic cheese. Nothing could be more fake."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "american_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("plastic" = 1)

//blue
/obj/item/food/cheese/wheel/blue
	name = "blue cheese wheel"
	desc = "A big wheel of blue cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "blue_wheel"
	slice_type = /obj/item/food/cheese/wedge/blue
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("mold" = 1)

/obj/item/food/cheesemix/blue
	name = "blue cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/blue

/obj/item/food/cheesemix_heated/blue
	name = "heated blue cheese mix"

/obj/item/food/cheese/wedge/blue
	name = "blue cheese wedge"
	desc = "A wedge of blue cheese. The mold stands out sharply against the white creamy cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "blue_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("mold" = 1)

//brie
/obj/item/food/cheese/wheel/brie
	name = "brie wheel"
	desc = "A big wheel of brie."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "brie_wheel"
	slice_type = /obj/item/food/cheese/wedge/brie
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 15)
	tastes = list("creamy mold" = 1)

/obj/item/food/cheesemix/brie
	name = "brie mix"
	microwaved_type = /obj/item/food/cheesemix_heated/brie

/obj/item/food/cheesemix_heated/brie
	name = "heated brie mix"

/obj/item/food/cheese/wedge/brie
	name = "brie wedge"
	desc = "A wedge of brie. Perfect with a cracker."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "brie_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("creamy mold" = 1)

//cheddar
/obj/item/food/cheese/wheel/cheddar
	name = "cheddar wheel"
	desc = "A big wheel of delicious cheddar."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "cheesewheel"
	slice_type = /obj/item/food/cheese/wedge/cheddar
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cheddar" = 1)

/obj/item/food/cheese/wheel/cheddar/welder_act(mob/living/user, obj/item/W)
	if(W.use_tool(src, user, 0, volume=40))
		var/obj/item/stack/sheet/cheese/NR = new (user.loc, 5)
		to_chat(user, "<span class='notice'>You shape [src] into a sturdier looking cheese with [W].")
		for(var/obj/item/stack/sheet/cheese/R in user.loc)
			if(R == NR)
				continue
			if(R.amount >= R.max_amount)
				continue
		qdel(src)
	return TRUE

/obj/item/food/cheesemix/cheddar
	name = "cheddar mix"
	microwaved_type = /obj/item/food/cheesemix_heated/cheddar

/obj/item/food/cheesemix_heated/cheddar
	name = "heated cheddar mix"

/obj/item/food/cheese/wedge/cheddar
	name = "cheddar wedge"
	desc = "A wedge of delicious cheddar. The cheese wheel it was cut from can't have gone far."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "cheesewheel_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cheddar" = 1)

//feta
/obj/item/food/cheese/wheel/feta
	name = "feta cheese block"
	desc = "A big block of feta cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "feta_block"
	slice_type = /obj/item/food/cheese/wedge/feta
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("sheep" = 1)

/obj/item/food/cheesemix/feta
	name = "feta cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/feta

/obj/item/food/cheesemix_heated/feta
	name = "heated feta cheese mix"

/obj/item/food/cheese/wedge/feta
	name = "feta cheese slice"
	desc = "A slice of feta cheese. It crumbles easily in your hands."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "feta_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("sheep" = 1)

//goat
/obj/item/food/cheese/wheel/goat
	name = "goat cheese wheel"
	desc = "A big wheel of goat cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "goat_wheel"
	slice_type = /obj/item/food/cheese/wedge/goat
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("goat" = 1)

/obj/item/food/cheesemix/goat
	name = "goat cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/goat

/obj/item/food/cheesemix_heated/goat
	name = "heated goat cheese mix"

/obj/item/food/cheese/wedge/goat
	name = "goat cheese wedge"
	desc = "A wedge of goat cheese. The aroma of goat is strong."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "goat_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("goat" = 1)

//halloumi
/obj/item/food/cheese/wheel/halloumi
	name = "halloumi cheese block"
	desc = "A big block of halloumi cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "halloumi_block"
	slice_type = /obj/item/food/cheese/wedge/halloumi
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("meat" = 1)

/obj/item/food/cheesemix/halloumi
	name = "halloumi cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/halloumi

/obj/item/food/cheesemix_heated/halloumi
	name = "heated halloumi cheese mix"

/obj/item/food/cheese/wedge/halloumi
	name = "halloumi cheese slice"
	desc = "A slice of halloumi cheese. A meat substitute for vegitarians."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "halloumi_slice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 1)

//mozzarella
/obj/item/food/cheese/wheel/mozzarella
	name = "mozzarella cheese ball"
	desc = "A big ball of mozzarella cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "mozzarella_ball"
	slice_type = /obj/item/food/cheese/wedge/mozzarella
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("cream" = 1)

/obj/item/food/cheesemix/mozzarella
	name = "mozzarella cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/mozzarella

/obj/item/food/cheesemix_heated/mozzarella
	name = "heated mozzarella cheese mix"

/obj/item/food/cheese/wedge/mozzarella
	name = "mozzarella cheese piece"
	desc = "A piece of mozzarella cheese. It needs to be on a pizza ASAP."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "mozzarella_piece"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("cream" = 1)

//parmesan
/obj/item/food/cheese/wheel/parmesan
	name = "parmesan cheese wheel"
	desc = "A big wheel of parmesan cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "parmesan_wheel"
	bite_consumption = 5
	max_volume = 200
	slice_type = /obj/item/food/cheese/wedge/parmesan
	food_reagents = list(/datum/reagent/consumable/nutriment = 100, /datum/reagent/consumable/nutriment/vitamin = 30, /datum/reagent/consumable/parmesan_delight = 20)
	tastes = list("salt" = 1, "magnificence" = 1, "italy" = 1)

/obj/item/food/cheese/preparmesan
	name = "unmatured parmesan cheese wheel"
	desc = "A big wheel of unmature parmesan cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "preparmesan_wheel"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bitter salt" = 1)

/obj/item/food/cheese/preparmesan/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(ageCheese)), 20 MINUTES)

/obj/item/food/cheese/preparmesan/proc/ageCheese()
	new /obj/item/food/cheese/wheel/parmesan(loc)
	qdel(src)

/obj/item/food/cheesemix/parmesan
	name = "parmesan cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/parmesan

/obj/item/food/cheesemix_heated/parmesan
	name = "heated parmesan cheese mix"

/obj/item/food/cheese/wedge/parmesan
	name = "parmesan cheese wedge"
	desc = "A wedge of parmesan cheese. You feel incredibly artisnal holding this."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "parmesan_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/parmesan_delight = 4)
	tastes = list("salt" = 1, "magnificence" = 1, "italy" = 1)

//swiss
/obj/item/food/cheese/wheel/swiss
	name = "swiss cheese wheel"
	desc = "A big wheel of swiss cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "swiss_wheel"
	slice_type = /obj/item/food/cheese/wedge/swiss
	food_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 10)
	tastes = list("holes" = 1)

/obj/item/food/cheesemix/swiss
	name = "swiss cheese mix"
	microwaved_type = /obj/item/food/cheesemix_heated/swiss

/obj/item/food/cheesemix_heated/swiss
	name = "heated swiss cheese mix"

/obj/item/food/cheese/wedge/swiss
	name = "swiss cheese wedge"
	desc = "A wedge of swiss cheese. The holes echo 'eat me' back to you."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "swiss_wedge"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("holes" = 1)

//bug cheese
/obj/item/food/cheese/wheel/bug
	name = "bug cheese ball"
	desc = "A big ball of gutlunch \"honey\", with a similar consistency to cheese."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "bug_ball"
	foodtypes = SUGAR | MEAT //honey made by a carnivorous scavenging bug
	slice_type = /obj/item/food/cheese/wedge/bug
	food_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("a rather large serving of sugar" = 1, "meat" = 1)

/obj/item/food/cheese/wedge/bug
	name = "bug cheese piece"
	desc = "A piece of gutlunch \"honey\"."
	icon = 'icons/obj/food/cheese.dmi'
	icon_state = "bug_piece"
	foodtypes = SUGAR | MEAT
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("a rather large serving of sugar" = 1, "meat" = 1)

//Regal rat cheese
/obj/item/food/royalcheese
	name = "royal cheese"
	desc = "Ascend the throne. Consume the wheel. Feel the POWER."
	icon_state = "royalcheese"
	food_reagents = list(/datum/reagent/consumable/nutriment = 15, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/gold = 20, /datum/reagent/toxin/mutagen = 5)
	w_class = WEIGHT_CLASS_BULKY
	tastes = list("cheese" = 4, "royalty" = 1)
	foodtypes = DAIRY
