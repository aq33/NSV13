//Ethereal Disco Grenade for Ethereal traitors
//Does not affect ethereals.
//Some basic code pieces taken from flashbang, spawner grenade and ethereal disco ball for functionality (basically a combination of the 3).

//////////////////////
// Primary grenade  //
//////////////////////

/obj/item/grenade/discogrenade
	name = "Ethereal Disco Grenade"
	desc = "An unethical micro-party that will make all non-Ethereal beings dance to its beat!"
	icon_state = "disco"
	item_state = "disco"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/list/messages = list("Świetna impreza!", "Juhuuu!!!", "Impreza!", "Patrzcie, jak tańczę!", "Hej, zatańczysz ze mną?")
	var/list/message_social_anxiety = list("Chcę do domu...", "Gdzie są toalety?", "Nie lubię tej piosenki.")

/obj/item/grenade/discogrenade/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	var/current_turf = get_turf(src)
	if(!current_turf)
		return

	playsound(current_turf, 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)

	new /obj/structure/etherealball(current_turf)

	for(var/i in 1 to 6)
		new /obj/item/grenade/discogrenade/subgrenade(current_turf, TRUE)

	qdel(src)

//////////////////////
//   Sub grenades   //
//////////////////////

/obj/item/grenade/discogrenade/subgrenade
	name = "Micro Disco"
	desc = "A massive disco contained in a tiny package!"
	icon_state = "disco"
	item_state = "disco"
	var/spawn_new = TRUE
	var/timerID
	var/lightcolor
	var/range = 5
	var/power = 3

/obj/item/grenade/discogrenade/subgrenade/Initialize(mapload, duplicate = FALSE)
	. = ..()
	active = TRUE
	spawn_new = duplicate
	icon_state = initial(icon_state) + "_active"
	var/launch_distance = rand(2, 6)
	for(var/i in 1 to launch_distance)
		step_away(src, loc)
	addtimer(CALLBACK(src, PROC_REF(prime)), rand(10, 60))
	randomiseLightColor()

/obj/item/grenade/discogrenade/subgrenade/prime(mob/living/lanced_by)
	if(dud_flags)
		active = FALSE
		update_icon()
		return FALSE
	update_mob()
	var/current_turf = get_turf(src)
	if(!current_turf)
		return

	playsound(current_turf, 'sound/weapons/flashbang.ogg', 30, TRUE, 8, 0.9)
	playsound(current_turf, pick('sound/instruments/accordion/Dn2.mid', 'sound/instruments/bikehorn/Cn3.ogg', 'sound/instruments/piano/Dn7.ogg', 'sound/instruments/violin/Cn3.mid'), 100, TRUE, 8, 0.9)

	if(spawn_new)
		for(var/i in 1 to 3)
			new /obj/item/grenade/discogrenade/subgrenade(current_turf)

	//Create the lights
	new /obj/effect/dummy/lighting_obj (current_turf, 4, 1, rand_hex_color(), 10)

	for(var/mob/living/carbon/human/M in hearers(4, src))
		forcedance(get_turf(M), M)
	qdel(src)

/obj/item/grenade/discogrenade/subgrenade/proc/randomiseLightColor()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	lightcolor = random_color()
	set_light(range, power, lightcolor)
	add_atom_colour("#[lightcolor]", FIXED_COLOUR_PRIORITY)
	update_icon()
	timerID = addtimer(CALLBACK(src, PROC_REF(randomiseLightColor)), 2, TIMER_STOPPABLE)

/obj/item/grenade/discogrenade/subgrenade/proc/forcedance(turf/T , mob/living/carbon/human/M)
	if(!T)
		return
	if(M.stat != CONSCIOUS)	//Only conscious people can dance
		return
	if(!M || isethereal(M))	//Non humans and non etherals can't dance
		return

	var/distance = max(0,get_dist(get_turf(src),T))
	if(distance > 2.5)
		return

	if(M.has_quirk(/datum/quirk/social_anxiety))
		M.say(pick(message_social_anxiety))
		if(rand(3) && M.get_ear_protection() == 0)
			M.drop_all_held_items()
			M.show_message("<span class='warning'>Zatykasz uszy, muzyka jest dla ciebie za głośna.</span>", 2)
		return

	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		M.show_message("<span class='warning'>Opierasz się wewnętrznej potrzebie, by zaprezentować swoje najlepsze ruchy.</span>", 2)
		M.set_drugginess(5)
		return
	if(istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
		to_chat(M, "<span class = 'userdanger'>TE ŚWIECĄCE W CIEMNOŚCI ŻARÓWKI NANOTRASEN NIE ZEPSUJĄ MNIE SWOJĄ AGENDĄ!</span>")
		M.emote("scream")
		return

	M.set_drugginess(10)
	M.show_message("<span class='warning'>Czujesz silny rytm, a twoje mięśnie drgają w niekontrolowany sposób. Zaczynasz tańczyć i nie możesz się ruszyć!</span>", 2)
	M.Immobilize(30)

	//Special actions
	switch(rand(0, 6))
		if(0)
			M.Knockdown(4)
			M.show_message("<span class='warning'>[pick("Mylisz", "Psujesz")] kroki i się potykasz!</span>", 2)
		if(1 to 3)
			M.emote("spin")
		if(3 to 4)
			M.emote("flip")
		if(5)
			M.say(pick(messages))
		if(6)
			M.emote("dance")
