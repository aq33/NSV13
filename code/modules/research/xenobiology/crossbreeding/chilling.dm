/*
Chilling extracts:
	Have a unique, primarily defensive effect when
	filled with 10u plasma and activated in-hand.
*/
/obj/item/slimecross/chilling
	name = "chilling extract"
	desc = "It's cold to the touch, as if frozen solid."
	effect = "chilling"
	icon_state = "chilling"

/obj/item/slimecross/chilling/Initialize(mapload)
	. = ..()
	create_reagents(10, INJECTABLE | DRAWABLE)

/obj/item/slimecross/chilling/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, "<span class='warning'>Aby się aktywować, ten ekstrakt musi być pełen plazmy!</span>")
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, "<span class='notice'>Ściskasz ekstrakt, a on wchłania plazmę!</span>")
	playsound(src, 'sound/effects/bubbles.ogg', 50, 1)
	playsound(src, 'sound/effects/glassbr1.ogg', 50, 1)
	do_effect(user)

/obj/item/slimecross/chilling/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/chilling/grey
	colour = "grey"
	effect_desc = "Tworzy kilka szlamowych kostek barierowych. Po użyciu tworzą szlamowe barykady."

/obj/item/slimecross/chilling/grey/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] wytwarza kilka małych, szarych kostek.</span>")
	for(var/i in 1 to 3)
		new /obj/item/barriercube(get_turf(user))
	..()

/obj/item/slimecross/chilling/orange
	colour = "orange"
	effect_desc = "Tworzy pierścień ognia jedno pole od użytkownika."

/obj/item/slimecross/chilling/orange/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] pęka i wypuszcza strumień gorąca!</span>")
	for(var/turf/open/T in (RANGE_TURFS(2, user)-RANGE_TURFS(1, user)))
		if(!locate(/obj/effect/hotspot) in T)
			new /obj/effect/hotspot(T)
	..()

/obj/item/slimecross/chilling/purple
	colour = "purple"
	effect_desc = "Wstrzykuje wszystkim w okolicy trochę regenerującej galarety."

/obj/item/slimecross/chilling/purple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] nie może działać na tak dużym obszarze.</span>")
		return
	user.visible_message("<span class='notice'>[src] pęka, a pomieszczenie na chwilę wypełnia lecznicza aura.</span>")
	for(var/mob/living/carbon/C in A)
		C.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)
	..()

/obj/item/slimecross/chilling/blue
	colour = "blue"
	effect_desc = "Tworzy rebreather – maskę bez butli."

/obj/item/slimecross/chilling/blue/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] pęka i wylewa płynną maź, która zmienia się w maskę!</span>")
	new /obj/item/clothing/mask/nobreath(get_turf(user))
	..()

/obj/item/slimecross/chilling/metal
	colour = "metal"
	effect_desc = "Tymczasowo otacza użytkownika niezniszczalnymi ścianami."

/obj/item/slimecross/chilling/metal/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] topi się jak rtęć i otacza [user] ścianą!</span>")
	for(var/turf/T as() in (RANGE_TURFS(2, user)-get_turf(user)))
		new /obj/effect/forcefield/slimewall(T)
	..()

/obj/item/slimecross/chilling/yellow
	colour = "yellow"
	effect_desc = "Ładuje APC pomieszczenia o 50%."

/obj/item/slimecross/chilling/yellow/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	user.visible_message("<span class='notice'>[src] pęka, a powietrze na chwilę wydaje się naelektryzowane.</span>")
	for(var/obj/machinery/power/apc/C in A)
		if(C.cell)
			C.cell.charge = min(C.cell.charge + C.cell.maxcharge/2, C.cell.maxcharge)
	..()

/obj/item/slimecross/chilling/darkpurple
	colour = "dark purple"
	effect_desc = "Usuwa cały gaz plazmowy w okolicy."

/obj/item/slimecross/chilling/darkpurple/do_effect(mob/user)
	var/area/A = get_area(get_turf(user))
	if(A.outdoors)
		to_chat(user, "<span class='warning'>[src] nie może działać na tak dużym obszarze.</span>")
		return
	var/filtered = FALSE
	for(var/turf/open/T in A)
		var/datum/gas_mixture/G = T.air
		if(istype(G))
			G.set_moles(GAS_PLASMA, 0)
			G.set_moles(GAS_CONSTRICTED_PLASMA, 0) //NSV13
			filtered = TRUE
	if(filtered)
		user.visible_message("<span class='notice'>Po [src] rozchodzą się pęknięcia i część powietrza zostaje wessana!</span>")
	else
		user.visible_message("<span class='notice'>[src] pęka, ale nic się nie dzieje.</span>")
	..()

/obj/item/slimecross/chilling/darkblue
	colour = "dark blue"
	effect_desc = "Zamyka użytkownika w ochronnym bloku lodu."

/obj/item/slimecross/chilling/darkblue/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='notice'>[src] zamraża całe ciało [user]!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/frozenstasis)
	..()

/obj/item/slimecross/chilling/silver
	colour = "silver"
	effect_desc = "Tworzy kilka racji żywnościowych."

/obj/item/slimecross/chilling/silver/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] kruszy się w lodowy proszek, zostawiając kilka awaryjnych zapasów jedzenia!</span>")
	var/amount = rand(5, 10)
	for(var/i in 1 to amount)
		new /obj/item/food/rationpack(get_turf(user))
	..()

/obj/item/slimecross/chilling/bluespace
	colour = "bluespace"
	effect_desc = "Dotknięcie kogoś tym ekstraktem dodaje go do listy; po aktywacji teleportuje wszystkich z tej listy do użytkownika."
	var/list/allies = list()
	var/active = FALSE

/obj/item/slimecross/chilling/bluespace/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target) || active)
		return
	if(target in allies)
		allies -= target
		to_chat(user, "<span class='notice'>Rozłączasz [src] z [target].</span>")
	else
		allies |= target
		to_chat(user, "<span class='notice'>Łączysz [src] z [target].</span>")
	return

/obj/item/slimecross/chilling/bluespace/do_effect(mob/user)
	if(allies.len <= 0)
		to_chat(user, "<span class='warning'>[src] nie jest z nikim połączony!</span>")
		return
	to_chat(user, "<span class='notice'>Czujesz, jak [src] pulsuje, zaczynając gromadzić energię bluespace...</span>")
	active = TRUE
	for(var/mob/living/M in allies)
		var/datum/status_effect/slimerecall/S = M.apply_status_effect(/datum/status_effect/slimerecall)
		S.target = user
	if(do_after(user, 100, target=src))
		to_chat(user, "<span class='notice'>[src] roztrzaskuje się, rozrywając rzeczywistość i wyrywając połączone osoby z pustki!</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			M.remove_status_effect(S)
	else
		to_chat(user, "<span class='warning'>[src] gaśnie, rozpływając się w nicość, gdy energia zanika.</span>")
		for(var/mob/living/M in allies)
			var/datum/status_effect/slimerecall/S = M.has_status_effect(/datum/status_effect/slimerecall)
			if(istype(S))
				S.interrupted = TRUE
				M.remove_status_effect(S)
	..()

/obj/item/slimecross/chilling/sepia
	colour = "sepia"
	effect_desc = "Dotknięcie kogoś tym ekstraktem dodaje go do listy lub z niej usuwa. Aktywacja zatrzymuje czas na 30 sekund, a wszyscy z listy są na to odporni, z wyjątkiem użytkownika."
	var/list/allies = list()

/obj/item/slimecross/chilling/sepia/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isliving(target))
		return
	if(target in allies)
		allies -= target
		to_chat(user, "<span class='notice'>Rozłączasz [src] z [target].</span>")
	else
		allies |= target
		to_chat(user, "<span class='notice'>Łączysz [src] z [target].</span>")
	return

/obj/item/slimecross/chilling/sepia/do_effect(mob/user)
	user.visible_message("<span class='warning'>[src] roztrzaskuje się, zamrażając sam czas!</span>")
	allies -= user //support class
	new /obj/effect/timestop(get_turf(user), 2, 300, allies)
	..()

/obj/item/slimecross/chilling/cerulean
	colour = "cerulean"
	effect_desc = "Tworzy kruchą kopię użytkownika, którą on kontroluje."

/obj/item/slimecross/chilling/cerulean/do_effect(mob/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[src] trzeszczy i przemienia się w klona [user]!</span>")
		var/mob/living/M = user
		M.apply_status_effect(/datum/status_effect/slime_clone)
	..()

/obj/item/slimecross/chilling/pyrite
	colour = "pyrite"
	effect_desc = "Tworzy pryzmatyczne okulary, które pozwalają noszącemu umieszczać kolorowe kryształy światła."

/obj/item/slimecross/chilling/pyrite/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] krystalizuje się w parę okularów!</span>")
	new /obj/item/clothing/glasses/prism_glasses(get_turf(user))
	..()

/obj/item/slimecross/chilling/red
	colour = "red"
	effect_desc = "Uspokaja wszystkie szlamy w twojej okolicy."

/obj/item/slimecross/chilling/red/do_effect(mob/user)
	var/slimesfound = FALSE
	for(var/mob/living/simple_animal/slime/S in hearers(7, get_turf(user)))
		slimesfound = TRUE
		S.docile = TRUE
	if(slimesfound)
		user.visible_message("<span class='notice'>[src] wydaje kojący dźwięk, roztrzaskując się, a pobliskie szlamy wydają się spokojne.</span>")
	else
		user.visible_message("<span class='notice'>[src] wydaje kojący dźwięk, roztrzaskując się, ale nic się nie dzieje...</span>")
	..()

/obj/item/slimecross/chilling/green
	colour = "green"
	effect_desc = "Tworzy kościany pistolet w ręce, w której go użyto; strzela krwią."

/obj/item/slimecross/chilling/green/do_effect(mob/user)
	var/which_hand = "l_hand"
	if(!(user.active_hand_index % 2))
		which_hand = "r_hand"
	var/mob/living/L = user
	if(!istype(user))
		return
	var/obj/item/held = L.get_active_held_item() //This should be itself, but just in case...
	L.dropItemToGround(held)
	var/obj/item/gun/magic/bloodchill/gun = new(user)
	if(!L.put_in_hands(gun))
		qdel(gun)
		user.visible_message("<span class='warning'>[src] błyskawicznie zamraża rękę [user], a ciało okropnie pęka!</span>")
	else
		user.visible_message("<span class='danger'>[src] schładza i odłamuje przód kości na ręce [user], zostawiając dziwną strukturę przypominającą pistolet!</span>")
	user.emote("scream")
	L.apply_damage(30,BURN,which_hand)
	..()

/obj/item/slimecross/chilling/pink
	colour = "pink"
	effect_desc = "Tworzy szlamowego szczeniaka corgi."

/obj/item/slimecross/chilling/pink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] pęka jak jajko, a ze środka wytacza się uroczy szczeniak!</span>")
	new /mob/living/simple_animal/pet/dog/corgi/puppy/slime(get_turf(user))
	..()

/obj/item/slimecross/chilling/gold
	colour = "gold"
	effect_desc = "Wytwarza złote urządzenie do chwytania"

/obj/item/slimecross/chilling/gold/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] wydziela złote światło, topiąc się i przekształcając w urządzenie przypominające jajo!</span>")
	new /obj/item/capturedevice(get_turf(user))
	..()

/obj/item/slimecross/chilling/oil
	colour = "oil"
	effect_desc = "Tworzy bezużyteczny flash."

/obj/item/slimecross/chilling/oil/do_effect(mob/user)
	user.visible_message("<span class='danger'>[src] zaczyna trząść się ze stłumioną siłą!</span>")
	addtimer(CALLBACK(src, PROC_REF(boom)), 50)

/obj/item/slimecross/chilling/oil/proc/boom()
	explosion(get_turf(src), -1, -1, 10, 0) //Large radius, but mostly light damage, and no flash.
	qdel(src)

/obj/item/slimecross/chilling/black
	colour = "black"
	effect_desc = "Przemienia użytkownika w losowy typ golema."

/obj/item/slimecross/chilling/black/do_effect(mob/user)
	if(ishuman(user))
		user.visible_message("<span class='notice'>[src] krystalizuje się na skórze [user], zmieniając się w metaliczne łuski!</span>")
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/golem/random)
	..()

/obj/item/slimecross/chilling/lightpink
	colour = "light pink"
	effect_desc = "Tworzy Pąk Bohaterki – specjalny kwiat, który uspokaja tego, kto nosi go na głowie. Bez pomocy nie da się go zdjąć."

/obj/item/slimecross/chilling/lightpink/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] rozkwita w piękny kwiat!</span>")
	new /obj/item/clothing/head/peaceflower(get_turf(user))
	..()

/obj/item/slimecross/chilling/adamantine
	colour = "adamantine"
	effect_desc = "Zestala się w adamantową zbroję."

/obj/item/slimecross/chilling/adamantine/do_effect(mob/user)
	user.visible_message("<span class='notice'>[src] trzeszczy i pęka, zmieniając się w ciężką zbroję!</span>")
	new /obj/item/clothing/suit/armor/heavy/adamantine(get_turf(user))
	..()

/obj/item/slimecross/chilling/rainbow
	colour = "rainbow"
	effect_desc = "Tworzy nieprzekraczalną ścianę w każdych drzwiach w okolicy."

/obj/item/slimecross/chilling/rainbow/do_effect(mob/user)
	var/area/area = get_area(user)
	if(area.outdoors)
		to_chat(user, "<span class='warning'>[src] nie może działać na tak dużym obszarze.</span>")
		return
	user.visible_message("<span class='warning'>[src] odbija mnóstwo olśniewających kolorów i światła, a energia pędzi do pobliskich drzwi!</span>")
	for(var/obj/machinery/door/airlock/door in area)
		new /obj/effect/forcefield/slimewall/rainbow(door.loc)
	return ..()
