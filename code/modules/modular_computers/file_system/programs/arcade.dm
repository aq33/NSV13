/datum/computer_file/program/arcade
	filename = "arcade"
	filedesc = "Mikroautomat Nanotrasen"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "arcade"
	extended_desc = "Port klasycznej gry „Outbomb Cuban Pete”, przerobiony na tablety, z ekscytującą grafiką i mrożącą krew w żyłach fabułą."
	requires_ntnet = FALSE
	network_destination = "sieć gier"
	size = 6
	tgui_id = "NtosArcade"
	program_icon = "gamepad"



	///Returns TRUE if the game is being played.
	var/game_active = TRUE
	///This disables buttom actions from having any impact if TRUE. Resets to FALSE when the player is allowed to make an action again.
	var/pause_state = FALSE
	var/boss_hp = 45
	var/boss_mp = 15
	var/player_hp = 30
	var/player_mp = 10
	var/ticket_count = 0
	///Shows what text is shown on the app, usually showing the log of combat actions taken by the player.
	var/heads_up = "Nanotrasen mówi: zwycięzcy przynoszą nam pieniądze."
	var/boss_name = "Sługa Kubańskiego Pete'a"
	///Determines which boss image to use on the UI.
	var/boss_id = 1

/datum/computer_file/program/arcade/proc/game_check(mob/user)
	sleep(5)
	if(boss_hp <= 0)
		heads_up = "Zmiażdżyłeś [boss_name]! Raduj się!"
		playsound(computer.loc, 'sound/arcade/win.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
		game_active = FALSE
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_icon()
		ticket_count += 1
		sleep(10)
	else if(player_hp <= 0 || player_mp <= 0)
		heads_up = "Zostałeś pokonany... jak stacja to przetrwa?"
		playsound(computer.loc, 'sound/arcade/lose.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
		game_active = FALSE
		program_icon_state = "arcade_off"
		if(istype(computer))
			computer.update_icon()
		sleep(10)

/datum/computer_file/program/arcade/proc/enemy_check(mob/user)
	var/boss_attackamt = 0 //Spam protection from boss attacks as well.
	var/boss_mpamt = 0
	var/bossheal = 0
	if(pause_state == TRUE)
		boss_attackamt = rand(3,6)
		boss_mpamt = rand (2,4)
		bossheal = rand (4,6)
	if(game_active == FALSE)
		return
	if (boss_mp <= 5)
		heads_up = "Skradziono ci many: [boss_mpamt]!"
		playsound(computer.loc, 'sound/arcade/steal.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
		player_mp -= boss_mpamt
		boss_mp += boss_mpamt
	else if(boss_mp > 5 && boss_hp <12)
		heads_up = "[boss_name] leczy się o [bossheal] pkt zdrowia!"
		playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
		boss_hp += bossheal
		boss_mp -= boss_mpamt
	else
		heads_up = "[boss_name] atakuje cię, zadając [boss_attackamt] obrażeń!"
		playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
		player_hp -= boss_attackamt

	pause_state = FALSE
	game_check()

/datum/computer_file/program/arcade/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/arcade),
	)

/datum/computer_file/program/arcade/ui_data(mob/user)
	var/list/data = list()
	data["Hitpoints"] = boss_hp
	data["PlayerHitpoints"] = player_hp
	data["PlayerMP"] = player_mp
	data["TicketCount"] = ticket_count
	data["GameActive"] = game_active
	data["PauseState"] = pause_state
	data["Status"] = heads_up
	data["BossID"] = SSassets.transport.get_asset_url("boss[boss_id].gif")
	return data

/datum/computer_file/program/arcade/ui_act(action, list/params)
	if(..())
		return TRUE

	// TODO: Has no supports for "skills" (tg skill leveling mechanics)
	switch(action)
		if("Attack")
			var/attackamt = 0 //Spam prevention.
			if(pause_state == FALSE)
				attackamt = rand(2, 6)
			pause_state = TRUE
			heads_up = "Atakujesz, zadając [attackamt] obrażeń."
			playsound(computer.loc, 'sound/arcade/hit.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
			boss_hp -= attackamt
			sleep(10)
			game_check()
			enemy_check()
			return TRUE
		if("Heal")
			var/healamt = 0 //More Spam Prevention.
			var/healcost = 0
			if(pause_state == FALSE)
				healamt = rand(6, 8)
				healcost = rand(1, 3)
			pause_state = TRUE
			heads_up = "Leczysz się o [healamt] pkt."
			playsound(computer.loc, 'sound/arcade/heal.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
			player_hp += healamt
			player_mp -= healcost
			sleep(10)
			game_check()
			enemy_check()
			return TRUE
		if("Recharge_Power")
			var/rechargeamt = 0 //As above.
			if(pause_state == FALSE)
				rechargeamt = rand(4, 7)
			pause_state = TRUE
			heads_up = "Odzyskujesz many: [rechargeamt]."
			playsound(computer.loc, 'sound/arcade/mana.ogg', 50, TRUE, extrarange = -3, falloff_exponent = 10)
			player_mp += rechargeamt
			sleep(10)
			game_check()
			enemy_check()
			return TRUE
		if("Start_Game")
			game_active = TRUE
			boss_hp = 45
			player_hp = 30
			player_mp = 10
			heads_up = "Stajesz przed [boss_name]! Przygotuj się do walki!"
			program_icon_state = "arcade"
			boss_id = rand(1,6)
			pause_state = FALSE
			if(istype(computer))
				computer.update_icon()
