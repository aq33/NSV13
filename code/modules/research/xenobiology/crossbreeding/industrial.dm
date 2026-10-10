/*
Industrial extracts:
	Slowly consume plasma, produce items with it.
*/
/obj/item/slimecross/industrial
	name = "industrial extract"
	desc = "A gel-like, sturdy extract, fond of plasma and industry."
	effect = "industrial"
	icon_state = "industrial_still"
	var/plasmarequired = 2 //Units of plasma required to be consumed to produce item.
	var/itempath = /obj/item //The item produced by the extract.
	var/plasmaabsorbed = 0 //Units of plasma aborbed by the extract already. Absorbs at a rate of 2u/obj tick.
	var/itemamount = 1 //How many items to spawn

/obj/item/slimecross/industrial/examine(mob/user)
	. = ..()
	. += "Pod zewnętrzną powłoką unosi się obecnie [plasmaabsorbed] z [plasmarequired] jednostek plazmy."

/obj/item/slimecross/industrial/proc/do_after_spawn(obj/item/spawned)
	return

/obj/item/slimecross/industrial/Initialize(mapload)
	. = ..()
	create_reagents(100, INJECTABLE | DRAWABLE)
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/industrial/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/slimecross/industrial/process()
	var/IsWorking = FALSE
	if(reagents.has_reagent(/datum/reagent/toxin/plasma,amount = 2) && plasmarequired > 1) //Can absorb as much as 2
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/plasma,2)
		plasmaabsorbed += 2
	else if(reagents.has_reagent(/datum/reagent/toxin/plasma,amount = 1)) //Can absorb as little as 1
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/plasma,1)
		plasmaabsorbed += 1

	if(plasmaabsorbed >= plasmarequired)
		playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
		plasmaabsorbed -= plasmarequired
		for(var/i = 0, i < itemamount, i++)
			do_after_spawn(new itempath(get_turf(src)))
	else if(IsWorking)
		playsound(src, 'sound/effects/bubbles.ogg', 5, 1)
	if(IsWorking)
		icon_state = "industrial"
	else
		icon_state = "industrial_still"

/obj/item/slimecross/industrial/grey
	colour = "grey"
	effect_desc = "Wytwarza kostki małpie."
	itempath = /obj/item/food/monkeycube
	itemamount = 5

/obj/item/slimecross/industrial/orange
	colour = "orange"
	effect_desc = "Wytwarza szlamowe zapalniczki zippo."
	plasmarequired = 6
	itempath = /obj/item/lighter/slime

/obj/item/slimecross/industrial/purple
	colour = "purple"
	effect_desc = "Wytwarza autoiniektory z galaretą regeneracyjną."
	plasmarequired = 5
	itempath = /obj/item/slimecrossbeaker/autoinjector/regenpack

/obj/item/slimecross/industrial/blue
	colour = "blue"
	effect_desc = "Wytwarza pełne gaśnice."
	plasmarequired = 10
	itempath = /obj/item/extinguisher

/obj/item/slimecross/industrial/metal
	colour = "metal"
	effect_desc = "Wytwarza arkusze metalu."
	plasmarequired = 3
	itempath = /obj/item/stack/sheet/iron/ten

/obj/item/slimecross/industrial/yellow
	colour = "yellow"
	effect_desc = "Wytwarza ogniwa o wysokiej pojemności, które po wytworzeniu nie są w pełni naładowane."
	plasmarequired = 5
	itempath = /obj/item/stock_parts/cell/high

/obj/item/slimecross/industrial/yellow/do_after_spawn(obj/item/spawned)
	var/obj/item/stock_parts/cell/high/C = spawned
	if(istype(C))
		C.charge = rand(0,C.maxcharge/2)

/obj/item/slimecross/industrial/darkpurple
	colour = "dark purple"
	effect_desc = "Wytwarza plazmę... z plazmy."
	plasmarequired = 10
	itempath = /obj/item/stack/sheet/mineral/plasma

/obj/item/slimecross/industrial/darkblue
	colour = "dark blue"
	effect_desc = "Wytwarza jednorazowe mikstury ognioodporności."
	plasmarequired = 6
	itempath = /obj/item/slimepotion/fireproof

/obj/item/slimecross/industrial/darkblue/do_after_spawn(obj/item/spawned)
	var/obj/item/slimepotion/fireproof/potion = spawned
	if(istype(potion))
		potion.uses = 1

/obj/item/slimecross/industrial/silver
	colour = "silver"
	effect_desc = "Wytwarza losowe jedzenie i napoje."
	plasmarequired = 1
	//Item picked below.

/obj/item/slimecross/industrial/silver/process()
	itempath = pick(list(get_random_food(), get_random_drink()))
	..()

/obj/item/slimecross/industrial/bluespace
	colour = "bluespace"
	effect_desc = "Wytwarza syntetyczne kryształy bluespace."
	plasmarequired = 7
	itempath = /obj/item/stack/ore/bluespace_crystal/artificial

/obj/item/slimecross/industrial/sepia
	colour = "sepia"
	effect_desc = "Wytwarza aparaty."
	plasmarequired = 2
	itempath = /obj/item/camera

/obj/item/slimecross/industrial/cerulean
	colour = "cerulean"
	effect_desc = "Wytwarza zwykłe wzmacniacze ekstraktów szlamu."
	plasmarequired = 5
	itempath = /obj/item/slimepotion/enhancer

/obj/item/slimecross/industrial/pyrite
	colour = "pyrite"
	effect_desc = "Wytwarza puszki farby w sprayu."
	plasmarequired = 2
	itempath = /obj/item/toy/crayon/spraycan

/obj/item/slimecross/industrial/red
	colour = "red"
	effect_desc = "Wytwarza kule krwi."
	plasmarequired = 5
	itempath = /obj/item/slimecrossbeaker/bloodpack

/obj/item/slimecross/industrial/green
	colour = "green"
	effect_desc = "Wytwarza autoiniektory z galaretą szlamu tylko do własnego użytku."
	plasmarequired = 7
	itempath = /obj/item/slimecrossbeaker/autoinjector/slimejelly

/obj/item/slimecross/industrial/pink
	colour = "pink"
	effect_desc = "Wytwarza autoiniektory z syntpaksem i kosmicznymi narkotykami."
	plasmarequired = 6
	itempath = /obj/item/slimecrossbeaker/autoinjector/peaceandlove

/obj/item/slimecross/industrial/gold
	colour = "gold"
	effect_desc = "Wytwarza losowe monety."
	plasmarequired = 10

/obj/item/slimecross/industrial/gold/process()
	itempath = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	..()

/obj/item/slimecross/industrial/oil
	colour = "oil"
	effect_desc = "Wytwarza IED."
	plasmarequired = 4
	itempath = /obj/item/grenade/iedcasing

/obj/item/slimecross/industrial/black //What does this have to do with black slimes? No clue! Fun, though
	colour = "black"
	effect_desc = "Wytwarza regenerujące papierosy marki szlam."
	plasmarequired = 6
	itempath = /obj/item/storage/fancy/cigarettes/cigpack_xeno

/obj/item/slimecross/industrial/lightpink
	colour = "light pink"
	effect_desc = "Wytwarza pudełka w kształcie serca z cukierkami w środku."
	plasmarequired = 3
	itempath = /obj/item/storage/fancy/heart_box

/obj/item/slimecross/industrial/adamantine
	colour = "adamantine"
	effect_desc = "Wytwarza arkusze adamantu."
	plasmarequired = 10
	itempath = /obj/item/stack/sheet/mineral/adamantine

/obj/item/slimecross/industrial/rainbow
	colour = "rainbow"
	effect_desc = "Wytwarza losowe ekstrakty szlamu."
	plasmarequired = 5
	//Item picked below.

/obj/item/slimecross/industrial/rainbow/process()
	itempath = pick(subtypesof(/obj/item/slime_extract))
	..()
