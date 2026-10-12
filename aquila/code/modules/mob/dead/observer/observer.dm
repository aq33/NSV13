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
		to_chat(src, "<span class='warning'>Obecnie nie ma myszy, które można opętać!</span>")
		return FALSE

	var/mob/living/simple_animal/mouse/M = pick(possessible)

	possess_mouse(M)


/mob/dead/observer/proc/possess_mouse(mob/living/simple_animal/mouse/M)
	if(!M)
		return FALSE

	if(!SSticker.HasRoundStarted())
		to_chat(usr, "<span class='warning'>Runda jeszcze się nie zaczęła!</span>")
		return FALSE

	if(is_banned_from(key, ROLE_SENTIENCE))
		to_chat(src, "<span class='warning'>Masz bana na to stanowisko!</span>")
		return FALSE

	if(alert("Na pewno chcesz zostać myszą? (Uwaga: nie będzie można cię sklonować!)",,"Yes","No") != "Yes")
		return FALSE

	if(M.key || (M.stat != CONSCIOUS) || (M in GLOB.player_list) || M.mind || QDELETED(src) || QDELETED(M))
		to_chat(src, "<span class='warning'>Nie da się sterować tą myszą, spróbuj ponownie!")
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

	to_chat(M , "<span class='warning'>Opętujesz teraz mysz. Nie pamiętasz swojego poprzedniego życia. Możesz jeść śmieci i jedzenie z podłogi, by odzyskiwać zdrowie i pomagać tworzyć nowe myszy. Pułapki na myszy zranią twoje kruche ciało, podobnie jak każda broń. Ctrl-kliknij jedzenie i śmieci, by je zjeść. Zdobądź. Ten. Ser.")
	return TRUE


// Port BeeStation/BeeStation-Hornet#12449: wyjście z widoku obserwowanej postaci.
// Komenda jest dostępna tylko w trakcie obserwacji, bo wtedy HUD ducha jest ukryty.
/mob/dead/observer/Initialize(mapload)
	. = ..()
	remove_verb(/mob/dead/observer/verb/cancel_camera_ghosts)

/mob/dead/observer/verb/cancel_camera_ghosts()
	set name = "Cancel Camera View"
	set category = "Ghost"
	reset_perspective(null)
	remove_verb(/mob/dead/observer/verb/cancel_camera_ghosts)

/mob/dead/observer/observe()
	..()
	if(observetarget)
		add_verb(/mob/dead/observer/verb/cancel_camera_ghosts)
