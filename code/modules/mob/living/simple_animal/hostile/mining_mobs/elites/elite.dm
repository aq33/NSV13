#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list("boss")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	obj_damage = 5
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station, we'll make sure they can smash minerals fine below.
	stat_attack = UNCONSCIOUS
	layer = LARGE_MOB_LAYER
	sentience_type = SENTIENCE_BOSS
	hud_type = /datum/hud/lavaland_elite
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/can_talk = FALSE
	var/obj/loot_drop = null
	discovery_points = 5000

//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.
/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/elite_remove = alert("Wrócić do guza?", "Zniknąć?", "Yes", "No")
			if(elite_remove != "Yes" || !src || QDELETED(src))
				return
			T.mychild = null
			T.activity = TUMOR_INACTIVE
			T.icon_state = "advanced_tumor"
			qdel(src)
			return FALSE
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled()

//Elites can't talk (normally)!
/mob/living/simple_animal/hostile/asteroid/elite/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(can_talk)
		. = ..()
		return TRUE
	return FALSE

/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent accross the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	icon_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = ""
	background_icon_state = "bg_default"
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		return ..()
	return FALSE

/datum/action/innate/elite_attack/Activate()
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	elite_owner.chosen_attack = chosen_attack_num
	to_chat(elite_owner, chosen_message)

/mob/living/simple_animal/hostile/asteroid/elite/update_health_hud()
	if(hud_used)
		var/severity = 0
		var/healthpercent = (health/maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				hud_used.healths.icon_state = "elite_health0"
			if(80 to 100)
				severity = 1
			if(60 to 80)
				severity = 2
			if(40 to 60)
				severity = 3
			if(20 to 40)
				severity = 4
			if(10 to 20)
				severity = 5
			if(1 to 20)
				severity = 6
			else
				severity = 7
		hud_used.healths.icon_state = "elite_health[severity]"
		if(severity > 0)
			overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

//The Pulsing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You feel compelled to reach out and touch it..."
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	base_pixel_x = -16
	light_color = LIGHT_COLOR_RED
	light_range = 3
	anchored = TRUE
	density = FALSE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
								/mob/living/simple_animal/hostile/asteroid/elite/pandora,
								/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
								/mob/living/simple_animal/hostile/asteroid/elite/herald)

/obj/structure/elite_tumor/attack_hand(mob/user)
	. = ..()
	if(ishuman(user))
		switch(activity)
			if(TUMOR_PASSIVE)
				activity = TUMOR_ACTIVE
				visible_message("<span class='boldwarning'>[src] drga, gdy twoja ręka wchodzi w jego zasięg.  Instynkt podpowiada ci, by się cofnąć.</span>")
				activator = user
				if(boosted)
					mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
					to_chat(mychild, "<b>Ktoś aktywował twój guz.  Wkrótce wrócisz do walki, przygotuj się!</b>")
				addtimer(CALLBACK(src, PROC_REF(return_elite)), 30)
				INVOKE_ASYNC(src, PROC_REF(arena_checks))
			if(TUMOR_INACTIVE)
				activity = TUMOR_ACTIVE
				var/mob/dead/observer/elitemind = null
				visible_message("<span class='boldwarning'>[src] zaczyna drgać.  Instynkt podpowiada ci, by się cofnąć.</span>")
				activator = user
				if(!boosted)
					addtimer(CALLBACK(src, PROC_REF(spawn_elite)), 30)
					return
				visible_message("<span class='boldwarning'>Coś w środku [src] się porusza...</span>")
				var/list/candidates = pollCandidatesForMob("Chcesz zagrać jako elita Lavalandu?", ROLE_LAVALAND_ELITE, null, 10 SECONDS, src)
				if(candidates.len)
					audible_message("<span class='boldwarning'>Odgłosy poruszania się przybierają na sile!</span>")
					elitemind = pick(candidates)
					elitemind.playsound_local(get_turf(elitemind), 'sound/effects/magic.ogg', 40, 0)
					to_chat(elitemind, "<b>Wybrano cię do gry jako Elita Lavalandu.\nZa kilka sekund zostaniesz przywołany na Lavaland jako potwór, by stoczyć walkę na śmierć i życie z tym, kto cię aktywował.\nAtaki przełączasz przyciskami w lewym górnym rogu HUD-u, a używasz ich, klikając cele lub pola, podobnie jak broni palnej.\nChoć przeciwnik może mieć przewagę dzięki potężnemu sprzętowi górniczemu, ty dysponujesz wielką mocą, zwykle zarezerwowaną dla mobów sterowanych przez SI.\nJeśli chcesz wygrać, musisz kreatywnie używać swoich mocy, by zapewnić sobie zabójstwo.  Zalecamy jak najszybciej wypróbować je wszystkie.\nJeśli wygrasz, otrzymasz dodatkowe informacje o tym, co robić dalej.  Powodzenia!</b>")
					addtimer(CALLBACK(src, PROC_REF(spawn_elite), elitemind), 100)
				else
					visible_message("<span class='boldwarning'>Odgłosy cichną i nic się nie wyłania.  Może spróbuj później.</span>")
					activity = TUMOR_INACTIVE
					activator = null

/obj/structure/elite_tumor/proc/spawn_elite(mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	visible_message("<span class='boldwarning'>[mychild] wyłania się z [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
		notify_ghosts("[mychild] został przebudzony w [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Przebudzono Elitę Lavalandu")
	icon_state = "tumor_popped"
	INVOKE_ASYNC(src, PROC_REF(arena_checks))

/obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message("<span class='boldwarning'>[mychild] wyłania się z [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2
		mychild.health = mychild.maxHealth
		notify_ghosts("[mychild] został wyzwany do walki w [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Wyzwano Elitę Lavalandu")

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Menacing Signal")
	START_PROCESSING(SSobj, src)

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	mychild = null
	activator = null
	return ..()

/obj/structure/elite_tumor/process(delta_time)
	if(isturf(loc))
		for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
			if(elitehere == mychild && activity == TUMOR_PASSIVE)
				mychild.adjustHealth(-mychild.maxHealth*0.025*delta_time)
				var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(mychild))
				H.color = "#FF0000"

/obj/structure/elite_tumor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/organ/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/regenerative_core/core = I
		if(!core.preserved)
			return
		visible_message("<span class='boldwarning'>Gdy [user] wrzuca rdzeń do [src], [src] zdaje się puchnąć.</span>")
		icon_state = "advanced_tumor"
		boosted = TRUE
		light_range = 6
		desc = "[desc]  This one seems to glow with a strong intensity."
		qdel(core)
		return TRUE

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, PROC_REF(fighters_check))  //Checks to see if our fighters died.
	INVOKE_ASYNC(src, PROC_REF(arena_trap))  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, PROC_REF(border_check))  //Checks to see if our fighters got out of the arena somehow.
	if(!QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(arena_checks)), 50)

/obj/structure/elite_tumor/proc/fighters_check()
	if(activator != null && activator.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(activator))
		onEliteWon()
	if(mychild != null && mychild.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(mychild))
		onEliteLoss()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/T = get_turf(src)
	if(loc == null)
		return
	for(var/t in RANGE_TURFS(12, T))
		if(get_dist(t, T) == 12)
			var/obj/effect/temp_visual/elite_tumor_wall/newwall
			newwall = new /obj/effect/temp_visual/elite_tumor_wall(t, src)
			newwall.activator = src.activator
			newwall.ourelite = src.mychild

/obj/structure/elite_tumor/proc/border_check()
	if(activator != null && get_dist(src, activator) >= 12)
		activator.forceMove(loc)
		visible_message("<span class='boldwarning'>[activator] nagle pojawia się ponownie nad [src]!</span>")
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= 12)
		mychild.forceMove(loc)
		visible_message("<span class='boldwarning'>[mychild] nagle pojawia się ponownie nad [src]!</span>")
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)

/obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message("<span class='boldwarning'>[src] zaczyna gwałtownie drgać, po czym zaczyna się rozpływać.</span>")
	visible_message("<span class='boldwarning'>Gdy [src] się zamyka, coś zostaje wypchnięte z dołu.</span>")
	var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
	if(!boosted)
		mychild = null
		activator = null
		qdel(src)
		return
	var/lootpick = rand(1, 2)
	if(lootpick == 1 && mychild.loot_drop != null)
		new mychild.loot_drop(lootbox)
	else
		new /obj/item/tumor_shard(lootbox)
	mychild = null
	activator = null
	qdel(src)

/obj/structure/elite_tumor/proc/onEliteWon()
	activity = TUMOR_PASSIVE
	activator = null
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		times_won++
		mychild.maxHealth = mychild.maxHealth * 0.5
		mychild.health = mychild.maxHealth
	if(times_won == 1)
		mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
		to_chat(mychild, "<span class='boldwarning'>Gdy z oczu aktywującego uchodzi życie, otaczające cię pole siłowe gaśnie, a ty czujesz, jak twoja moc słabnie.\nChoć to piekło jest twoim domem, masz wrażenie, że nie jesteś tu już mile widziany.\nBez żadnych wskazówek, sam decydujesz teraz o swoim celu.</span>")
		to_chat(mychild, "<b>Twoje maksymalne zdrowie zostało zmniejszone o połowę, ale możesz się teraz leczyć, stojąc na swoim guzie.  Uwaga: to twój jedyny sposób leczenia.\nPamiętaj, że jeśli ktoś wejdzie w interakcję z twoim guzem, zostaniesz tu ponownie przywołany do kolejnej walki.  W takim wypadku odzyskasz pełne maksymalne zdrowie.\nUważaj też na innych mieszkańców, raczej nie ucieszą się na twój widok!</b>")
		to_chat(mychild, "<span class='big bold'>Pamiętaj, że jesteś potworem z Lavalandu, więc nie jesteś sojusznikiem stacji.  Nie powinieneś współpracować ani być przyjazny wobec załogi stacji, chyba że w skrajnych okolicznościach!</span>")

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland.  Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers.  Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "screwdriver_head"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5

/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS || !E.key)
			user.visible_message("<span class='notice'>Wygląda na to, że nie da się teraz wskrzesić [E].  Może spróbuj później.</span>")
			return
		E.faction = list("neutral")
		E.revive(full_heal = TRUE, admin_revive = TRUE)
		user.visible_message("<span class='notice'>[user] dźga [E] za pomocą [src], wskrzeszając go.</span>")
		E.playsound_local(get_turf(E), 'sound/effects/magic.ogg', 40, 0)
		to_chat(E, "<span class='userdanger'>[user] cię wskrzesił.  Choć nie możesz z nim rozmawiać, masz wobec niego ogromny dług.  Pomagaj mu w osiąganiu jego celów bez względu na ryzyko.</span")
		to_chat(E, "<span class='big bold'>Pamiętaj, że teraz podzielasz lojalności [user].  Oczekuje się, że nie będziesz celowo sabotować jego frakcji, chyba że dostaniesz taki rozkaz!</span>")
		E.maxHealth = E.maxHealth * 0.5
		E.health = E.maxHealth
		E.desc = "[E.desc]  However, this one appears appears less wild in nature, and calmer around people."
		E.sentience_type = SENTIENCE_ORGANIC
		qdel(src)
	else
		to_chat(user, "<span class='info'>[src] działa tylko na zwłokach świadomej elity Lavalandu.</span>")

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "wall"
	duration = 50
	smooth = SMOOTH_TRUE
	layer = BELOW_MOB_LAYER
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_RED
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/ourelite = null

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	queue_smooth_neighbors(src)
	queue_smooth(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	queue_smooth_neighbors(src)
	activator = null
	ourelite = null
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover == ourelite || mover == activator)
		return FALSE
