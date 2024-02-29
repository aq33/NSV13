#define CHALLENGE_TELECRYSTALS (80 + LERP(0, 200, CLAMP01((GLOB.player_list.len-20)/20))) // AQ EDIT - min of 80 + more depending on player count, like 20 per player above 20 up to 280 at 40 players
#define CHALLENGE_TIME_LIMIT 5 MINUTES
#define CHALLENGE_MIN_PLAYERS 50
#define CHALLENGE_SHUTTLE_DELAY 35 MINUTES	//35 minutes, giving nukies at least 20 minutes to enact their assault.

/obj/item/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE
	var/uplink_type = /obj/item/uplink/nuclear

/obj/item/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Skonsultuj się ze swoją drużyną zanim zadeklarujecie wojnę na [station_name()]].", "Declare war?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Yes")
		//to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	var/war_declaration = "[user.real_name] zadeklarowa[user.gender == MALE ? "ł" : "ła"] [user.p_jego()] zamiar całkowitego zniszczenia [station_name()] przy użyciu ładunku nuklearnego, oraz rzuca wyzwanie załodze, aby spróbować [user.p_je()] powstrzymać."

	declaring_war = TRUE
	var/custom_threat = alert(user, "Czy chcesz zmienić tekst deklaracji?", "Customize?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = stripped_input(user, "Podaj nowy tekst deklaracji", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	declare_war(user, war_declaration)

/obj/item/nuclear_challenge/proc/declare_war(mob/user, war_declaration)
	priority_announce(war_declaration, "Deklaracja Wojny", 'sound/machines/alarm.ogg',  has_important_message = TRUE)

	play_soundtrack_music(/datum/soundtrack_song/bee/future_perception)

	if(user)
		to_chat(user, "You've attracted the attention of powerful forces within the syndicate. A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	for(var/V in GLOB.syndicate_shuttle_boards)
		var/obj/item/circuitboard/computer/syndicate_shuttle/board = V
		board.challenge = TRUE

	GLOB.shuttle_docking_jammed = TRUE

	var/list/orphans = list()
	var/list/uplinks = list()

	for (var/datum/mind/M in get_antag_minds(/datum/antagonist/nukeop))
		if (iscyborg(M.current))
			continue
		M.current.client?.give_award(/datum/award/achievement/misc/warops, M.current)
		var/datum/component/uplink/uplink = M.find_syndicate_uplink()
		if (!uplink)
			orphans += M.current
			continue
		uplinks += uplink


	var/tc_to_distribute = CHALLENGE_TELECRYSTALS
	var/tc_per_nukie = round(tc_to_distribute / (length(orphans)+length(uplinks)))

	for (var/datum/component/uplink/uplink in uplinks)
		uplink.telecrystals += tc_per_nukie
		tc_to_distribute -= tc_per_nukie


	for (var/mob/living/L in orphans)
		var/TC = new /obj/item/stack/telecrystal(L.drop_location(), tc_per_nukie)
		to_chat(L, "<span class='warning'>Your uplink could not be found so your share of the team's bonus telecrystals has been bluespaced to your [L.put_in_hands(TC) ? "hands" : "feet"].</span>")
		tc_to_distribute -= tc_per_nukie

	if (tc_to_distribute > 0) // What shall we do with the remainder...
		for (var/mob/living/simple_animal/hostile/carp/cayenne/C in GLOB.mob_living_list)
			if (C.stat != DEAD)
				var/obj/item/stack/telecrystal/TC = new(C.drop_location(), tc_to_distribute)
				TC.throw_at(get_step(C, C.dir), 3, 3)
				C.visible_message("<span class='notice'>[C] coughs up a half-digested telecrystal</span>","<span class='usernotice'>You cough up a half-digested telecrystal!</span>")
				break

	CONFIG_SET(number/shuttle_refuel_delay, max(CONFIG_GET(number/shuttle_refuel_delay), CHALLENGE_SHUTTLE_DELAY))
	SSblackbox.record_feedback("amount", "nuclear_challenge_mode", 1)

	qdel(src)

/obj/item/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "Jesteś w trakcie deklarowania wojny! Zdecyduj się.")
		return FALSE
	/* AQ EDIT - if you have nukies, they can do war.
	if(GLOB.player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, "The enemy crew is too small to be worth declaring war on.")
		return FALSE
	*/
	if(!user.onSyndieBase())
		to_chat(user, "Musisz być w twojej bazie by tego użyć.")
		return FALSE
	/* AQ EDIT - at any time, any day. Well, they can't
	// go station-side until they declare war, so...
	if(world.time-SSticker.round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand.")
		return FALSE
	*/
	for(var/V in GLOB.syndicate_shuttle_boards)
		var/obj/item/circuitboard/computer/syndicate_shuttle/board = V
		if(board.moved)
			to_chat(user, "Infiltrator się przemieścił! Straciłeś prawo do deklaracji wojny.")
			return FALSE
	return TRUE

/obj/item/nuclear_challenge/clownops
	uplink_type = /obj/item/uplink/clownop

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_MIN_PLAYERS
#undef CHALLENGE_SHUTTLE_DELAY
