/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/afterattack(atom/target, mob/user, prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/H = target
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>[src] nie zadziała na martwych!</span>")
		return
	if(!do_mob(user, H, 50))
		to_chat(user, "<span class='notice'>Musisz stać w bezruchu, by nałożyć [src]!")
		return
	if(H != user)
		user.visible_message("<span class='notice'>[user] rozgniata [src] nad [H], a mleczna maź szybko regeneruje wszystkie jego obrażenia!</span>",
			"<span class='notice'>Ściskasz [src], a on pęka nad [H], a mleczna maź regeneruje jego obrażenia.</span>")
	else
		user.visible_message("<span class='notice'>[user] rozgniata [src] nad sobą, a mleczna maź szybko regeneruje wszystkie jego obrażenia!</span>",
			"<span class='notice'>Ściskasz [src], a on pęka ci w dłoni, oblewając cię mleczną mazią, która szybko regeneruje twoje obrażenia!</span>")
	core_effect_before(H, user)
	H.heal_overall_damage(50, 50, 50)
	H.adjustToxLoss(-50, forced = TRUE)
	core_effect(H, user)
	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	qdel(src)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.
	effect_desc = "Leczy cel i nic więcej."

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>[src] kipi!</span>")
	for(var/turf/open/turf in RANGE_TURFS(1,target))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

/obj/item/slimecross/regenerative/purple
	colour = "purple"
	effect_desc = "W pełni leczy cel i wstrzykuje mu trochę galarety regeneracyjnej."

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)

/obj/item/slimecross/regenerative/blue
	colour = "blue"
	effect_desc = "Leczy cel i moczy podłogę."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message("<span class='warning'>Mleczna maź z ekstraktu rozlewa się po całej podłodze!</span>")

/obj/item/slimecross/regenerative/metal
	colour = "metal"
	effect_desc = "Leczy cel i zamyka go w szafce."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>Mleczna maź twardnieje i zmienia kształt, zamykając [target] w środku!</span>")
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"
	effect_desc = "Leczy cel i w pełni ładuje jeden z jego przedmiotów."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, "<span class='notice'>Czujesz dziwny impuls elektryczny, a jeden z twoich elektrycznych przedmiotów został naładowany.</span>")

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"
	effect_desc = "Leczy cel i daje mu fioletowe ubranie, jeśli jest nagi."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message("<span class='notice'>Mleczna maź krzepnie w ubranie!</span>")

/obj/item/slimecross/regenerative/darkblue
	colour = "dark blue"
	effect_desc = "Leczy cel i czyni jego ubranie ognioodpornym."

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		fireproof(C)
	if(H.get_item_by_slot(ITEM_SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message("<span class='notice'>Część ubrania [target] pokrywa się mazią i robi się niebieska!</span>")

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = "silver"
	effect_desc = "Leczy cel i sprawia, że jego brzuch jest okrągły i pełny."

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	to_chat(target, "<span class='notice'>Czujesz się syty.</span>")

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	effect_desc = "Leczy cel i teleportuje go tam, gdzie powstał ten rdzeń."
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>[src] znika w deszczu iskier!</span>","<span class='danger'>Mleczna maź teleportuje cię w miejsce, które pamięta!</span>")
	do_teleport(target, T, effectin = new /datum/effect_system/spark_spread, effectout = new /datum/effect_system/spark_spread, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = "sepia"
	effect_desc = "Leczy cel i zatrzymuje czas."

/obj/item/slimecross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, "<span class=notice>Próbujesz zapomnieć, jak się czujesz.</span>")
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"
	effect_desc = "Leczy cel i tworzy drugi rdzeń regeneracyjny bez specjalnych efektów."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, "<span class='notice'>Część mlecznej mazi krzepnie ci w dłoni!</span>")

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"
	effect_desc = "Leczy i losowo barwi cel."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>Mleczna maź pokrywająca [target] zmienia jego kolor!</span>")
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"
	effect_desc = "Leczy cel i wstrzykuje mu trochę efedryny."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>Czujesz się... <i>szybszy.</i></span>")
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = "green"
	effect_desc = "Leczy cel i zmienia gatunek lub kolor szlama albo galaretowatej osoby."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message("<span class='warning'>[target] nagle zmienia kolor!</span>")
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()
	if(isjellyperson(target))
		target.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly,5)


/obj/item/slimecross/regenerative/pink
	colour = "pink"
	effect_desc = "Leczy cel i wstrzykuje mu trochę krokodilu."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>Czujesz się spokojniej.</span>")
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"
	effect_desc = "Leczy cel i wytwarza losową monetę."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, 1)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = "oil"
	effect_desc = "Leczy cel i oślepia błyskiem wszystkich w zasięgu wzroku."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, 1)
	for(var/mob/living/L in viewers(7, user))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = "black"
	effect_desc = "Leczy cel i tworzy jego duplikat, który wkrótce potem pada martwy."

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, "<span class='notice'>Mleczna maź spływa z twojej skóry, tworząc niedoskonałą kopię ciebie.</span>")
	if(iscarbon(target))
		var/mob/living/carbon/T = target
		var/mob/living/carbon/D = dummy
		T.dna.transfer_identity(D)
		D.updateappearance(mutcolor_update=1)
		D.real_name = T.real_name
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.adjustOxyLoss(200)
	//Force death just in case
	dummy.death()

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"
	effect_desc = "Leczy cel, a także użytkownika."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.heal_overall_damage(50, 50, 50)
	U.adjustToxLoss(-50, forced = TRUE)
	to_chat(U, "<span class='notice'>Trochę mlecznej mazi pryska także na ciebie!</span>")

/obj/item/slimecross/regenerative/adamantine
	colour = "adamantine"
	effect_desc = "Leczy cel i wzmacnia jego pancerz."

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.apply_status_effect(STATUS_EFFECT_SLIMESKIN)

/obj/item/slimecross/regenerative/rainbow
	colour = "rainbow"
	effect_desc = "Leczy cel i tymczasowo czyni go nieśmiertelnym, ale pacyfistą."

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.apply_status_effect(STATUS_EFFECT_RAINBOWPROTECTION)
