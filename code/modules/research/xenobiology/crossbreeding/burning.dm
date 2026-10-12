/*
Burning extracts:
	Have a unique, primarily offensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/burning
	name = "burning extract"
	desc = "It's boiling over with barely-contained energy."
	effect = "burning"
	icon_state = "burning"

/obj/item/slimecross/burning/Initialize(mapload)
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/burning/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, "<span class='warning'>Aby się aktywować, ten ekstrakt musi być pełen plazmy!</span>")
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, "<span class='notice'>Ściskasz ekstrakt, a on wchłania plazmę!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/magic/fireball.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/burning/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/burning/grey
	colour = "grey"
	effect_desc = "Tworzy głodnego i szybkiego szlama, który będzie cię kochał na zawsze."

/obj/item/slimecross/burning/grey/do_effect(mob/user)
	var/mob/living/simple_animal/slime/S = new(get_turf(user),"grey")
	S.visible_message("<span class='danger'>Z [src] wyłania się młody szlam, łasi się do [user], po czym głodno bulgocze!</span>")
	S.set_friendship(user, 20) //Gas, gas, gas
	S.bodytemperature = T0C + 400 //We gonna step on the gas.
	S.set_nutrition(S.get_hunger_nutrition()) //Tonight, we fight!
	..()

/obj/item/slimecross/burning/orange
	colour = "orange"
	effect_desc = "Po aktywacji rozpyla wokół gaz pieprzowy."

/obj/item/slimecross/burning/orange/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] kipi żrącym gazem!</span>")
	var/datum/reagents/R = new/datum/reagents(100)
	R.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 100)

	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 7, get_turf(user))
	smoke.start()
	..()

/obj/item/slimecross/burning/purple
	colour = "purple"
	effect_desc = "Tworzy grudkę ożywczego żelu, który ma właściwości lecznicze i poprawia samopoczucie."

/obj/item/slimecross/burning/purple/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] wypełnia się bulgoczącym płynem!</span>")
	new /obj/item/slimecrossbeaker/autoinjector/slimestimulant(get_turf(user))
	..()

/obj/item/slimecross/burning/blue
	colour = "blue"
	effect_desc = "Zamraża podłogę wokół ciebie i schładza pobliskich ludzi."

/obj/item/slimecross/burning/blue/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] błyskawicznie zamraża okolicę!</span>")
	for(var/turf/open/T in view(3, get_turf(user)))
		T.MakeSlippery(TURF_WET_PERMAFROST, min_wet_time = 10, wet_time_to_add = 5)
	for(var/mob/living/carbon/M in ohearers(5, user))
		M.bodytemperature = BODYTEMP_COLD_DAMAGE_LIMIT + 10 //Not quite cold enough to hurt.
		to_chat(M, "<span class='danger'>Czujesz dreszcz na plecach, a podłoga wydaje się nieco śliska od szronu...</span>")
	..()

/obj/item/slimecross/burning/metal
	colour = "metal"
	effect_desc = "Natychmiast niszczy ściany wokół ciebie."

/obj/item/slimecross/burning/metal/do_effect(mob/user)
	for(var/turf/closed/wall/W in RANGE_TURFS(1,user))
		W.dismantle_wall(1)
		playsound(W, 'sound/effects/break_stone.ogg', 50, 1)
	user.visible_message("<span class='danger'>[src] gwałtownie pulsuje i roztrzaskuje otaczające go ściany!</span>")
	..()

/obj/item/slimecross/burning/yellow
	colour = "yellow"
	effect_desc = "Razi prądem ludzi w pobliżu."

/obj/item/slimecross/burning/yellow/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] eksploduje polem elektrycznym!</span>")
	playsound(get_turf(src), 'sound/weapons/zapbang.ogg', 50, 1)
	for(var/mob/living/M in ohearers(4,user))
		var/mob/living/carbon/C = M
		if(istype(C))
			C.electrocute_act(25,src)
		else
			M.adjustFireLoss(25)
		to_chat(M, "<span class='danger'>Czujesz ostry impuls elektryczny!</span>")
	..()

/obj/item/slimecross/burning/darkpurple
	colour = "dark purple"
	effect_desc = "Tworzy chmurę plazmy."

/obj/item/slimecross/burning/darkpurple/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] sublimuje w chmurę plazmy!</span>")
	var/turf/T = get_turf(user)
	T.atmos_spawn_air("plasma=60")
	..()

/obj/item/slimecross/burning/darkblue
	colour = "dark blue"
	effect_desc = "Wypuszcza podmuch chłodzącego dymu, jednocześnie wypełniając cię kriooksadonem."

/obj/item/slimecross/burning/darkblue/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] wypuszcza podmuch chłodzącego dymu!</span>")
	var/datum/reagents/R = new/datum/reagents(100)
	R.add_reagent(/datum/reagent/consumable/frostoil, 40)
	user.reagents.add_reagent(/datum/reagent/medicine/cryoxadone,10)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 7, get_turf(user))
	smoke.start()
	..()

/obj/item/slimecross/burning/silver
	colour = "silver"
	effect_desc = "Tworzy kilka kawałków jedzenia z dodatkiem galarety szlamu."

/obj/item/slimecross/burning/silver/do_effect(mob/user)
	var/amount = rand(3,6)
	var/list/turfs = list()
	for(var/turf/open/T in RANGE_TURFS(1,user))
		turfs += T
	for(var/i = 0, i < amount, i++)
		var/path = get_random_food()
		var/obj/item/O = new path(pick(turfs))
		O.reagents.add_reagent(/datum/reagent/toxin/slimejelly,5) //Oh god it burns
		if(prob(50))
			O.desc += " Dziwnie pachnie..."
	user.visible_message("<span class='danger'>[src] wytwarza kilka kawałków jedzenia!</span>")
	..()

/obj/item/slimecross/burning/bluespace
	colour = "bluespace"
	effect_desc = "Teleportuje każdego, kto stoi tuż obok ciebie."

/obj/item/slimecross/burning/bluespace/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] iskrzy i wypuszcza falę uderzeniową energii bluespace!</span>")
	for(var/mob/living/L in range(1, get_turf(user)))
		if(L != user)
			do_teleport(L, get_turf(L), 6, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //Somewhere between the effectiveness of fake and real BS crystal
			new /obj/effect/particle_effect/sparks(get_turf(L))
			playsound(get_turf(L), "sparks", 50, 1)
	..()

/obj/item/slimecross/burning/sepia
	colour = "sepia"
	effect_desc = "Zmienia się w specjalny aparat, który po użyciu cofa czas."

/obj/item/slimecross/burning/sepia/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] przybiera kształt aparatu!</span>")
	new /obj/item/camera/rewind(get_turf(user))
	..()

/obj/item/slimecross/burning/cerulean
	colour = "cerulean"
	effect_desc = "Wytwarza miksturę klonującą ekstrakty, która kopiuje ekstrakt wraz z jego dodatkowymi użyciami."

/obj/item/slimecross/burning/cerulean/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] produces a potion!</span>")
	new /obj/item/slimepotion/extract_cloner(get_turf(user))
	..()

/obj/item/slimecross/burning/pyrite
	colour = "pyrite"
	effect_desc = "Roztrzaskuje wszystkie światła w bieżącym pomieszczeniu."

/obj/item/slimecross/burning/pyrite/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] wypuszcza kolorową falę energii, która roztrzaskuje światła!</span>")
	var/area/A = get_area(user.loc)
	for(var/obj/machinery/light/L in A) //Shamelessly copied from the APC effect.
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()
	..()

/obj/item/slimecross/burning/red
	colour = "red"
	effect_desc = "Wprowadza pobliskie szlamy w szał; będą atakować nawet swoich przyjaciół."

/obj/item/slimecross/burning/red/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] na chwilę pulsuje mglistą czerwoną aurą, która owija się wokół [user]!</span>")
	for(var/mob/living/simple_animal/slime/S in hearers(7, get_turf(user)))
		if(user in S.Friends)
			var/friendliness = S.Friends[user]
			S.clear_friends()
			S.set_friendship(user, friendliness)
		else
			S.clear_friends()
		S.rabid = 1
		S.visible_message("<span class='danger'>[S] wpada w niebezpieczny szał!</span>")
	..()

/obj/item/slimecross/burning/green
	colour = "green"
	effect_desc = "Użytkownik dostaje tępe ostrze ramienne w ręce, w której go użyto."

/obj/item/slimecross/burning/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/melee/arm_blade/slime/blade = new(user)
	if(!L.put_in_hands(blade))
		qdel(blade)
		user.visible_message("<span class='warning'>[src] roztapia się na ręce [user], okropnie gotując ciało!</span>")
	else
		user.visible_message("<span class='danger'>[src] sublimuje ciało wokół ręki [user], przemieniając kość w makabryczne ostrze!</span>")
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/burning/pink
	colour = "pink"
	effect_desc = "Tworzy zlewkę syntpaksu."

/obj/item/slimecross/burning/pink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] kurczy się w małą, wypełnioną żelem kulkę!</span>")
	new /obj/item/slimecrossbeaker/pax(get_turf(user))
	..()

/obj/item/slimecross/burning/gold
	colour = "gold"
	effect_desc = "Tworzy bandę potworów przyjaznych użytkownikowi."

/obj/item/slimecross/burning/gold/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] gwałtownie się trzęsie i przywołuje armię dla [user]!</span>")
	for(var/i in 1 to 3) //Less than gold normally does, since it's safer and faster.
		var/mob/living/simple_animal/S = create_random_mob(get_turf(user), HOSTILE_SPAWN)
		S.faction |= "[REF(user)]"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(S, pick(NORTH,SOUTH,EAST,WEST))
	..()

/obj/item/slimecross/burning/oil
	colour = "oil"
	effect_desc = "Po kilku sekundach wywołuje eksplozję."

/obj/item/slimecross/burning/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] zaczyna trząść się z szybko narastającą siłą!</span>")
	addtimer(CALLBACK(src, PROC_REF(boom)), 50)

/obj/item/slimecross/burning/oil/proc/boom()
	explosion(get_turf(src), 2, 4, 4) //Same area as normal oils, but increased high-impact values by one each, then decreased light by 2.
	qdel(src)

/obj/item/slimecross/burning/black
	colour = "black"
	effect_desc = "Przemienia użytkownika w szlama. Może wrócić do swojej postaci, kiedy zechce, i nie traci żadnych przedmiotów."

/obj/item/slimecross/burning/black/do_effect(mob/user)
	var/mob/living/L = user
	if(!istype(L))
		return
	user.visible_message("<span class='danger'>[src] wchłania [user], przemieniając go w szlama!</span>")
	var/obj/effect/proc_holder/spell/targeted/shapeshift/slimeform/S = new()
	S.remove_on_restore = TRUE
	user.mind.AddSpell(S)
	S.cast(list(user),user)
	..()

/obj/item/slimecross/burning/lightpink
	colour = "light pink"
	effect_desc = "Pacyfikuje wszystkich w zasięgu wzroku."

/obj/item/slimecross/burning/lightpink/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] wydziela hipnotyzującą różową poświatę!</span>")
	for(var/mob/living/carbon/C in hearers(7, get_turf(user)))
		C.reagents.add_reagent(/datum/reagent/pax,5)
	..()

/obj/item/slimecross/burning/adamantine
	colour = "adamantine"
	effect_desc = "Tworzy potężną adamantową tarczę."

/obj/item/slimecross/burning/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] krystalizuje się w dużą tarczę!</span>")
	new /obj/item/shield/adamantineshield(get_turf(user))
	..()

/obj/item/slimecross/burning/rainbow
	colour = "rainbow"
	effect_desc = "Tworzy Tęczowy Nóż – nóż kuchenny zadający losowe rodzaje obrażeń."

/obj/item/slimecross/burning/rainbow/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] spłaszcza się w świecące tęczowe ostrze.</span>")
	new /obj/item/kitchen/knife/rainbowknife(get_turf(user))
	..()
