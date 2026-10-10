
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/tear_in_reality
	var/spawn_amt = 1
	var/activate_descriptor = "samej rzeczywistości"
	var/rend_desc = "Lepiej już uciekaj."
	var/spawn_fast = 0 //if 1, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message("<span class='boldannounce'>[src] brzęczy mocą, gdy [user] zadaje cios [activate_descriptor]!</span>")
	else
		to_chat(user, "<span class='danger'>Nieziemskie energie zasilające ostrze teraz uśpiły się.</span>")

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/simple_animal/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = 0

/obj/effect/rend/Initialize(mapload, var/spawn_type, var/spawn_amt, var/desc, var/spawn_fast)
	. = ..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)

/obj/effect/rend/process()
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		user.visible_message("<span class='danger'>[user] zamyka [src] za pomocą [I].</span>")
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_pull()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/simple_animal/cow
	spawn_amt = 20
	activate_descriptor = "samemu głodowi"
	rend_desc = "Rozbrzmiewa odgłosem dziesięciu tysięcy muczeń."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown
	spawn_amt = 10
	activate_descriptor = "samej depresji"
	rend_desc = "Łagodnie niesie się z niego nieskończony śmiech."
	icon_state = "clownrender"

/obj/item/veilrender/honkrender/honkhulkrender
	name = "superior honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus. This one gleams with a special light."
	spawn_type = /mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	spawn_amt = 5
	activate_descriptor = "samej depresji"
	rend_desc = "Łagodnie niesie się z niego radosne chrząkanie."
	icon_state = "clownrender"

#define TEAR_IN_REALITY_CONSUME_RANGE 3
#define TEAR_IN_REALITY_SINGULARITY_SIZE STAGE_FOUR

/// Tear in reality, spawned by the veil render
/obj/tear_in_reality
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	layer = MASSIVE_OBJ_LAYER
	light_range = 6
	appearance_flags = LONG_GLIDE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/tear_in_reality/Initialize(mapload)
	. = ..()
	AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = TEAR_IN_REALITY_CONSUME_RANGE, \
		notify_admins = FALSE, \
		roaming = FALSE, \
		singularity_size = TEAR_IN_REALITY_SINGULARITY_SIZE, \
	)

/obj/tear_in_reality/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/datum/component/mood/insaneinthemembrane = C.GetComponent(/datum/component/mood)
		if(insaneinthemembrane.sanity < 15)
			return //they've already seen it and are about to die, or are just too insane to care
		to_chat(C, "<span class='userdanger'>O BOŻE! NIC Z TEGO NIE JEST PRAWDZIWE! NIC Z TEGO NIE JEST PRAWDZIWEEEEEEEEEEEEEEEEEEEEEE!</span>")
		insaneinthemembrane.sanity = 0
		for(var/lore in typesof(/datum/brain_trauma/severe))
			C.gain_trauma(lore)
		addtimer(CALLBACK(src, PROC_REF(deranged), C), 100)

/obj/tear_in_reality/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(0, TRUE, TRUE, 3, TRUE)
	C.spew_organ(3, 2)
	C.death()

/obj/tear_in_reality/Bump(atom/A)
	if(ismovableatom(A))
		free(A)

/obj/tear_in_reality/Bumped(atom/movable/AM)
	free(AM)

/obj/tear_in_reality/proc/consume(atom/A)
	if(ismovableatom(A))
		free(A)

/obj/tear_in_reality/proc/free(atom/movable/A)
	if(!LAZYLEN(GLOB.destabliization_exits))
		if(ismob(A))
			to_chat(A, "<span class='warning'>Nie ma stąd wyjścia...</span>")
		return
	var/atom/return_thing = pick(GLOB.destabliization_exits)
	var/turf/T = get_turf(return_thing)
	if(!T)
		return
	A.forceMove(T)

#undef TEAR_IN_REALITY_CONSUME_RANGE
#undef TEAR_IN_REALITY_SINGULARITY_SIZE

/////////////////////////////////////////Scrying///////////////////

/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, merely holding it gives you vision and hearing beyond mortal means, and staring into it lets you see the entire universe."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

	var/mob/current_owner

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, "<span class='notice'>Twoja nieziemska wizja słabnie...</span>")

		REMOVE_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		REMOVE_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, "<span class='notice'>Widzisz... wszystko!</span>")

		ADD_TRAIT(current_owner, TRAIT_SIXTHSENSE, SCRYING_ORB)
		ADD_TRAIT(current_owner, TRAIT_XRAY_VISION, SCRYING_ORB)
		current_owner.update_sight()

/obj/item/scrying/attack_self(mob/user)
	visible_message("<span class='danger'>[user] wpatruje się w [src] szklistym wzrokiem.</span>")
	user.ghostize(TRUE)

/////////////////////////////////////////Necromantic Stone///////////////////

/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	var/unlimited = 0

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M))
		return ..()

	if(!istype(user) || !user.canUseTopic(M, BE_CLOSE))
		return

	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>Ten artefakt działa tylko na zmarłych!</span>")
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) //excludes new players
		if(ghost.mind && ghost.mind.current == M && ghost.client)  //the dead mobs list can contain clientless mobs
			ghost.reenter_corpse()
			break

	if(!M.mind || !M.client)
		to_chat(user, "<span class='warning'>Z tym ciałem nie jest związana żadna dusza...</span>")
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= 3 && !unlimited)
		to_chat(user, "<span class='warning'>Ten artefakt może kontrolować naraz tylko troje nieumarłych!</span>")
		return

	M.set_species(/datum/species/skeleton, icon_update=0)
	M.revive(full_heal = 1, admin_revive = 1)
	spooky_scaries |= M
	to_chat(M, "<span class='userdanger'>Ożywia cię </span><B>[user.real_name]!</B>")
	to_chat(M, "<span class='userdanger'>To teraz twój pan - pomagaj mu, nawet jeśli będzie cię to kosztować nowe życie!</span>")

	equip_roman_skeleton(M)
	
	log_combat(user, M, "used a necromantic stone to reanimate")

	desc = "A shard capable of resurrecting humans as skeleton thralls[unlimited ? "." : ", [spooky_scaries.len]/3 active thralls."]"

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	listclearnulls(spooky_scaries)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/obj/item/necromantic_stone/proc/equip_roman_skeleton(mob/living/carbon/human/H)
	for(var/obj/item/I in H)
		H.dropItemToGround(I)

	var/hat = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionnaire)
	H.equip_to_slot_or_del(new hat(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/roman(H), ITEM_SLOT_ICLOTHING)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/roman(H), ITEM_SLOT_FEET)
	H.put_in_hands(new /obj/item/shield/riot/roman(H), TRUE)
	H.put_in_hands(new /obj/item/claymore(H), TRUE)
	H.equip_to_slot_or_del(new /obj/item/spear(H), ITEM_SLOT_BACK)


/obj/item/voodoo
	name = "wicker doll"
	desc = "Something creepy about it."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "voodoo"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/mob/living/carbon/human/target = null
	var/list/mob/living/carbon/human/possible = list()
	var/obj/item/voodoo_link = null
	var/cooldown_time = 30 //3s
	var/cooldown = 0
	max_integrity = 10
	resistance_flags = FLAMMABLE

/obj/item/voodoo/attackby(obj/item/I, mob/user, params)
	if(target && cooldown < world.time)
		if(I.is_hot())
			to_chat(target, "<span class='userdanger'>Nagle robi ci się bardzo gorąco</span>")
			target.adjust_bodytemperature(50)
			GiveHint(target)
		else if(is_pointed(I))
			to_chat(target, "<span class='userdanger'>Czujesz kłujący ból: [parse_zone(user.zone_selected)]!</span>")
			target.Paralyze(40)
			GiveHint(target)
		else if(istype(I, /obj/item/bikehorn))
			to_chat(target, "<span class='userdanger'>HONK</span>")
			SEND_SOUND(target, 'sound/items/airhorn.ogg')
			target.adjustEarDamage(0,3)
			GiveHint(target)
		cooldown = world.time +cooldown_time
		return

	if(!voodoo_link)
		if(I.loc == user && istype(I) && I.w_class <= WEIGHT_CLASS_SMALL)
			if (user.transferItemToLoc(I,src))
				voodoo_link = I
				to_chat(user, "Przyczepiasz [I] do lalki.")
				update_targets()

/obj/item/voodoo/check_eye(mob/user)
	if(loc != user)
		user.reset_perspective(null)
		user.unset_machine()

/obj/item/voodoo/attack_self(mob/user)
	if(!target && possible.len)
		target = input(user, "Wybierz swoją ofiarę!", "Voodoo") as null|anything in sortNames(possible)
		return

	if(user.zone_selected == BODY_ZONE_CHEST)
		if(voodoo_link)
			target = null
			voodoo_link.forceMove(drop_location())
			to_chat(user, "<span class='notice'>Odczepiasz [voodoo_link] od lalki.</span>")
			voodoo_link = null
			update_targets()
			return

	if(target && cooldown < world.time)
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_MOUTH)
				var/wgw =  stripped_input(user, "Co ma powiedzieć ofiara?", "Voodoo")
				target.say(wgw, forced = "voodoo doll")
				log_game("[key_name(user)] made [key_name(target)] say [wgw] with a voodoo doll.")
			if(BODY_ZONE_PRECISE_EYES)
				user.set_machine(src)
				user.reset_perspective(target)
				spawn(100)
					user.reset_perspective(null)
					user.unset_machine()
			if(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
				to_chat(user, "<span class='notice'>Poruszasz nogami lalki.</span>")
				var/turf/T = get_step(target,pick(GLOB.cardinals))
				target.Move(T)
			if(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
				target.click_random_mob()
				GiveHint(target)
			if(BODY_ZONE_HEAD)
				to_chat(user, "<span class='notice'>Uderzasz lalkę ręką w głowę.</span>")
				target.Dizzy(10)
				to_chat(target, "<span class='warning'>Nagle czujesz, jakby ktoś uderzył cię młotkiem w głowę!</span>")
				GiveHint(target,user)
		cooldown = world.time + cooldown_time

/obj/item/voodoo/proc/update_targets()
	possible = list()
	if(!voodoo_link)
		return
	var/list/prints = voodoo_link.return_fingerprints()
	if(!length(prints))
		return FALSE
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(prints[rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)])
			possible |= H

/obj/item/voodoo/proc/GiveHint(mob/victim,force=0)
	if(prob(50) || force)
		var/way = dir2text(get_dir(victim,get_turf(src)))
		to_chat(victim, "<span class='notice'>Wyczuwasz mroczną obecność z kierunku: [way]</span>")
	if(prob(20) || force)
		var/area/A = get_area(src)
		to_chat(victim, "<span class='notice'>Wyczuwasz mroczną obecność od strony: [A.name]</span>")

/obj/item/voodoo/suicide_act(mob/living/carbon/user)
    user.visible_message("<span class='suicide'>[user] łączy lalkę voodoo z samym sobą i na niej siada, nieskończenie się miażdżąc! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
    user.gib()
    return(BRUTELOSS)

/obj/item/voodoo/fire_act(exposed_temperature, exposed_volume)
	if(target)
		target.adjust_fire_stacks(20)
		target.IgniteMob()
		GiveHint(target,1)
	return ..()

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

//Warp Whistle: Provides uncontrolled long distance teleportation.

/obj/item/warpwhistle
	name = "warp whistle"
	desc = "One toot on this whistle will send you to a far away land!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "whistle"
	var/on_cooldown = 0 //0: usable, 1: in use, 2: on cooldown
	var/mob/living/carbon/last_user

/obj/item/warpwhistle/proc/interrupted(mob/living/carbon/user)
	if(!user || QDELETED(src) || user.notransform)
		on_cooldown = FALSE
		return TRUE
	return FALSE

/obj/item/warpwhistle/proc/end_effect(mob/living/carbon/user)
	user.invisibility = initial(user.invisibility)
	user.status_flags &= ~GODMODE
	user.update_mobility()

/obj/item/warpwhistle/attack_self(mob/living/carbon/user)
	if(!istype(user) || on_cooldown)
		return
	on_cooldown = TRUE
	last_user = user
	var/turf/T = get_turf(user)
	playsound(T,'sound/magic/warpwhistle.ogg', 200, 1)
	user.mobility_flags &= ~MOBILITY_MOVE
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	if(interrupted(user))
		return
	user.invisibility = INVISIBILITY_MAXIMUM
	user.status_flags |= GODMODE
	sleep(20)
	if(interrupted(user))
		end_effect(user)
		return
	var/breakout = 0
	while(breakout < 50)
		var/turf/potential_T = find_safe_turf()
		if(T.get_virtual_z_level() != potential_T.get_virtual_z_level() || abs(get_dist_euclidian(potential_T,T)) > 50 - breakout)
			do_teleport(user, potential_T, channel = TELEPORT_CHANNEL_MAGIC)
			user.mobility_flags &= ~MOBILITY_MOVE
			T = potential_T
			break
		breakout += 1
	new /obj/effect/temp_visual/tornado(T)
	sleep(20)
	end_effect(user)
	if(interrupted(user))
		return
	on_cooldown = 2
	sleep(40)
	on_cooldown = 0

/obj/item/warpwhistle/Destroy()
	if(on_cooldown == 1 && last_user) //Flute got dunked somewhere in the teleport
		end_effect(last_user)
	return ..()

/obj/effect/temp_visual/tornado
	icon = 'icons/obj/wizard.dmi'
	icon_state = "tornado"
	name = "tornado"
	desc = "This thing sucks!"
	layer = FLY_LAYER
	randomdir = 0
	duration = 40
	pixel_x = 500

/obj/effect/temp_visual/tornado/Initialize(mapload)
	. = ..()
	animate(src, pixel_x = -500, time = 40)
