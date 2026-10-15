// Okno Orion Trail w TGUI (zamiast HTML z code/game/machinery/computer/arcade.dm).
// Gra zostaje ta sama: przyciski idą przez dawny Topic(), a zdarzenia z event() (HTML z linkami)
// są rozbierane na tekst i listę przycisków.

// Statusy gry jak w arcade.dm (tam są #undef na końcu pliku)
#define ORION_STATUS_START 1
#define ORION_STATUS_NORMAL 2
#define ORION_STATUS_GAMEOVER 3
#define ORION_STATUS_MARKET 4

/obj/machinery/computer/arcade/orion_trail/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		orion_check_gameover(user)
		ui = new(user, src, "OrionTrail", name)
		ui.open()

/// Koniec gry i jego skutki na zhakowanym automacie (wcześniej działo się to przy rysowaniu okna HTML)
/obj/machinery/computer/arcade/orion_trail/proc/orion_check_gameover(mob/user)
	if(gameStatus == ORION_STATUS_START)
		return
	if(gameStatus != ORION_STATUS_GAMEOVER && fuel > 0 && food > 0 && length(settlers))
		return
	gameStatus = ORION_STATUS_GAMEOVER
	event = null
	if(!(obj_flags & EMAGGED) || !isliving(user))
		return
	var/mob/living/gamer = user
	if(length(settlers))
		if(food <= 0)
			gamer.set_nutrition(0)
			to_chat(gamer, "<span class='userdanger'>Your body instantly contracts to that of one who has not eaten in months. Agonizing cramps seize you as you fall to the floor.</span>")
		if(fuel <= 0)
			gamer.adjust_fire_stacks(5)
			gamer.IgniteMob()
			to_chat(gamer, "<span class='userdanger'>You feel an immense wave of heat emanate from the arcade machine. Your skin bursts into flames.</span>")
	to_chat(gamer, "<span class='userdanger'>You're never going to make it to Orion...</span>")
	gamer.death()
	obj_flags &= ~EMAGGED
	gameStatus = ORION_STATUS_START
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

/obj/machinery/computer/arcade/orion_trail/ui_data(mob/user)
	var/list/data = list()
	data["status"] = gameStatus
	data["food"] = food
	data["fuel"] = fuel
	data["engine"] = engine
	data["hull"] = hull
	data["electronics"] = electronics
	data["settlers"] = settlers.Copy()
	data["turn"] = turns
	data["emagged"] = !!(obj_flags & EMAGGED)
	data["event"] = null
	if(gameStatus == ORION_STATUS_GAMEOVER)
		data["starved"] = food <= 0
		data["out_of_fuel"] = fuel <= 0
	else if(event && eventdat)
		data["event"] = orion_split_event(eventdat)
	else if(gameStatus == ORION_STATUS_NORMAL)
		data["stop"] = stops[turns]
		data["blurb"] = stopblurbs[turns]
		data["black_hole"] = turns == 7
	return data

/// Rozbiera HTML zdarzenia na tekst i przyciski (etykieta + parametr dawnego Topic())
/obj/machinery/computer/arcade/orion_trail/proc/orion_split_event(html)
	var/static/regex/link_regex = regex(@"<a href='byond://\?src=[^;']+;(\w+)=([^']*)'>(.*?)</a>", "gi")
	var/static/regex/empty_paragraph = regex(@"<P ALIGN=Right>\s*</P>", "gi")
	var/list/buttons = list()
	var/text = html
	while(link_regex.Find(html))
		var/key = link_regex.group[1]
		if(key == "close")
			continue
		buttons += list(list("key" = key, "value" = link_regex.group[2], "label" = strip_html_simple(link_regex.group[3])))
	text = link_regex.Replace(text, "")
	text = empty_paragraph.Replace(text, "")
	return list("text" = text, "buttons" = buttons)

/obj/machinery/computer/arcade/orion_trail/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "topic")
		return
	var/static/list/allowed_keys = list(
		"continue", "newgame", "menu", "search", "slow", "pastblack", "useengine", "useelec", "usehull",
		"wait", "keepspeed", "blackhole", "holedeath", "eventclose", "killcrew", "buycrew", "sellcrew",
		"leave_spaceport", "raid_spaceport", "buyparts", "trade",
	)
	var/key = params["key"]
	if(!(key in allowed_keys))
		return
	Topic(null, list("[key]" = params["value"] || "1"))
	orion_check_gameover(usr)
	return TRUE

#undef ORION_STATUS_START
#undef ORION_STATUS_NORMAL
#undef ORION_STATUS_GAMEOVER
#undef ORION_STATUS_MARKET
