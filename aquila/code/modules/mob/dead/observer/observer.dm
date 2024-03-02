//szczury
/mob/dead/observer/proc/possess_mouse_verb()
	set category = "Ghost"
	set name = "Possess a mouse"
	set desc = "Possess a mouse to haunt the station.... and their food!"

	var/list/possessible = list()

	for(var/mob/living/simple_animal/mouse/M in GLOB.alive_mob_list)
		if(M.stat != CONSCIOUS) continue
		if(M.key) continue
		if(M in GLOB.player_list) continue
		if(M.mind) continue
		if(!is_station_level(M.z)) continue

		possessible += M

	if(!possessible.len)
		to_chat(src, "<span class='warning'>There are currently no mice able to be possessed!</span>")
		return FALSE

	var/mob/living/simple_animal/mouse/M = pick(possessible)

	possess_mouse(M)


/mob/dead/observer/proc/possess_mouse(mob/living/simple_animal/mouse/M)
	if(!M)
		return FALSE

	if(!SSticker.HasRoundStarted())
		to_chat(usr, "<span class='warning'>The round hasn't started yet!</span>")
		return FALSE

	if(is_banned_from(key, ROLE_SENTIENCE))
		to_chat(src, "<span class='warning'>You are job banned!</span>")
		return FALSE

	if(alert("Are you sure you want to become a mouse? (Warning, you can no longer be cloned!)",,"Yes","No") != "Yes")
		return FALSE

	if(M.key || (M.stat != CONSCIOUS) || (M in GLOB.player_list) || M.mind || QDELETED(src) || QDELETED(M))
		to_chat(src, "<span class='warning'>This mouse is unable to be controlled, please try again!")
		return FALSE

	log_game("[key_name(src)] has became a mouse")

	M.key = key
	M.faction = list("neutral")
	M.chew_probability = 0 //so they cant pull off a big brain play by ghosting somewhere or idk
	M.layer = BELOW_OPEN_DOOR_LAYER //ENGAGE ADVANCED HIDING BRAIN FUNCTIONS
	M.language_holder = new /datum/language_holder/mouse(M)
	M.pass_flags |= PASSDOOR
	M.sentience_act()
	M.maxHealth = 15
	M.health = M.maxHealth

	to_chat(M , "<span class='warning'>You are now possessing a mouse. \
				You do not remember your previous life. You can eat trash and \
				food on the floor to gain health and help create new mice. Mouse traps will hurt your fragile body \
				and so will any kind of weapons. You can control click food and trash items in order to eat them. Get. That. Cheese.")
	return TRUE

