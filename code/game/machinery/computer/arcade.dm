GLOBAL_LIST_INIT(arcade_prize_pool, list(
		/obj/item/storage/box/snappops = 2,
		/obj/item/toy/talking/AI = 2,
		/obj/item/toy/talking/codex_gigas = 2,
		/obj/item/clothing/under/syndicate/tacticool = 2,
		/obj/item/toy/sword = 2,
		/obj/item/toy/gun = 2,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 2,
		/obj/item/storage/box/fakesyndiesuit = 2,
		/obj/item/storage/crayons = 2,
		/obj/item/toy/spinningtoy = 2,
		/obj/item/toy/prize/ripley = 1,
		/obj/item/toy/prize/fireripley = 1,
		/obj/item/toy/prize/deathripley = 1,
		/obj/item/toy/prize/gygax = 1,
		/obj/item/toy/prize/durand = 1,
		/obj/item/toy/prize/honk = 1,
		/obj/item/toy/prize/marauder = 1,
		/obj/item/toy/prize/seraph = 1,
		/obj/item/toy/prize/mauler = 1,
		/obj/item/toy/prize/odysseus = 1,
		/obj/item/toy/prize/phazon = 1,
		/obj/item/toy/prize/reticence = 1,
		/obj/item/toy/cards/deck = 2,
		/obj/item/toy/nuke = 2,
		/obj/item/toy/minimeteor = 2,
		/obj/item/toy/redbutton = 2,
		/obj/item/toy/talking/owl = 2,
		/obj/item/toy/talking/griffin = 2,
		/obj/item/coin/antagtoken = 2,
		/obj/item/stack/tile/fakespace/loaded = 2,
		/obj/item/stack/tile/fakepit/loaded = 2,
		/obj/item/stack/tile/eighties/loaded = 2,
		/obj/item/toy/toy_xeno = 2,
		/obj/item/storage/box/actionfigure = 1,
		/obj/item/restraints/handcuffs/fake = 2,
		/obj/item/grenade/chem_grenade/glitter/pink = 1,
		/obj/item/grenade/chem_grenade/glitter/blue = 1,
		/obj/item/grenade/chem_grenade/glitter/white = 1,
		/obj/item/toy/eightball = 2,
		/obj/item/toy/windupToolbox = 2,
		/obj/item/toy/clockwork_watch = 2,
		/obj/item/toy/toy_dagger = 2,
		/obj/item/toy/cog = 2,
		/obj/item/toy/batong = 1,
		/obj/item/toy/replica_fabricator = 1,
		/obj/item/extendohand/acme = 1,
		/obj/item/hot_potato/harmless/toy = 1,
		/obj/item/card/emagfake = 1,
		/obj/item/disk/nuclear/fake/obvious = 1,
		/obj/item/clothing/shoes/wheelys = 2,
		/obj/item/clothing/shoes/kindleKicks = 2,
		/obj/item/toy/plush/moth/random = 2,
		/obj/item/toy/plush/flushed = 2,
		/obj/item/toy/plush/gondola = 2,
		/obj/item/toy/plush/rouny = 2,
		/obj/item/storage/box/heretic_asshole = 1,
		/obj/item/toy/eldrich_book = 1,
		/obj/item/storage/belt/military/snack = 2,
		/obj/item/choice_beacon/pet/cat = 1,
		/obj/item/choice_beacon/pet/mouse = 1,
		/obj/item/choice_beacon/pet/corgi = 1,
		/obj/item/choice_beacon/pet/hamster = 1,
		/obj/item/choice_beacon/pet/pug = 1,
		/obj/item/choice_beacon/pet/pingu = 1,
		/obj/item/choice_beacon/pet/clown = 1,
		/obj/item/toy/allaccess = 1))

/obj/machinery/computer/arcade
	name = "random arcade"
	desc = "random arcade machine"
	icon_state = "arcade"
	icon_keyboard = "no_keyboard"
	icon_screen = "invaders"
	clockwork = TRUE //it'd look weird
	broken_overlay_emissive = TRUE
	var/list/prize_override
	var/prizeselect = /obj/item/coin/arcade_token
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize(mapload)
	. = ..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/list/gameodds = list(/obj/item/circuitboard/computer/arcade/battle = 49,
							/obj/item/circuitboard/computer/arcade/orion_trail = 49,
							/obj/item/circuitboard/computer/arcade/amputation = 2)
		var/thegame = pickweight(gameodds)
		var/obj/item/circuitboard/CB = new thegame()
		new CB.build_path(loc, CB)
		return INITIALIZE_HINT_QDEL
	Reset()

/obj/machinery/computer/arcade/proc/prizevend(mob/user)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "arcade", /datum/mood_event/arcade)
	var/atom/movable/the_prize
	if(prob(0.0001)) //1 in a million
		the_prize = new /obj/item/gun/energy/pulse/prize(drop_location())
		user.client.give_award(/datum/award/achievement/misc/pulse, user)
	else
		the_prize = new prizeselect(drop_location())

	visible_message("<span class='notice'>[src] dispenses [the_prize]!</span>", "<span class='notice'>Słyszysz dzwonek i łupnięcie.</span>")

/obj/machinery/computer/arcade/proc/redeem(mob/user)
	var/redeemselect = pickweight(length(prize_override) ? prize_override : GLOB.arcade_prize_pool)

	var/atom/movable/the_prize = new redeemselect(drop_location())
	visible_message("<span class='notice'>[src] dispenses [the_prize]!</span>", "<span class='notice'>Słyszysz dzwonek i łupnięcie.</span>")

/obj/machinery/computer/arcade/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/coin/arcade_token) || istype(W, /obj/item/coin/bananium))
		to_chat(user, "<span class='notice'>Wkładasz [W] do [src].")
		redeem(user)
		qdel(W)
		return

/obj/machinery/computer/arcade/emp_act(severity)
	. = ..()
	var/override = FALSE
	if(prize_override)
		override = TRUE

	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return

	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		if(override)
			empprize = pickweight(prize_override)
		else
			empprize = pickweight(GLOB.arcade_prize_pool)
		new empprize(loc)
	explosion(loc, -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)


// ** BATTLE ** //


/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/battle
	var/enemy_name = "Space Villain"
	var/temp = "Zwycięzcy nie biorą kosmicznych narkotyków" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = FALSE
	var/blocked = FALSE //Player cannot attack/heal while set
	var/turtle = 0

/obj/machinery/computer/arcade/battle/Reset()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ", "Ban ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn", "Bloopers")

	enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	name = (name_action + name_part1 + name_part2)

/obj/machinery/computer/arcade/battle/ui_interact(mob/user)
	. = ..()
	var/dat = "<a href='byond://?src=[REF(src)];close=1'>Close</a>"
	dat += "<center><h4>[enemy_name]</h4></center>"

	dat += "<br><center><h3>[temp]</h3></center>"
	dat += "<br><center>Zdrowie: [player_hp] | Magia: [player_mp] | Zdrowie wroga: [enemy_hp]</center>"

	if (gameover)
		dat += "<center><b><a href='byond://?src=[REF(src)];newgame=1'>Nowa gra</a>"
	else
		dat += "<center><b><a href='byond://?src=[REF(src)];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=[REF(src)];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=[REF(src)];charge=1'>Odnów moc</a>"

	dat += "</b></center>"
	var/datum/browser/popup = new(user, "arcade", "Space Villain 2000")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/arcade/battle/Topic(href, href_list)
	if(..())
		return

	if (!blocked && !gameover)
		if (href_list["attack"])
			blocked = TRUE
			var/attackamt = rand(2,6)
			temp = "Atakujesz, zadając [attackamt] obrażeń!"
			playsound(loc, 'sound/arcade/hit.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			enemy_hp -= attackamt
			arcade_action(usr)

		else if (href_list["heal"])
			blocked = TRUE
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			temp = "Używasz [pointamt] magii, by wyleczyć [healamt] obrażeń!"
			playsound(loc, 'sound/arcade/heal.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			updateUsrDialog()
			turtle++

			sleep(10)
			player_mp -= pointamt
			player_hp += healamt
			blocked = TRUE
			updateUsrDialog()
			arcade_action(usr)

		else if (href_list["charge"])
			blocked = TRUE
			var/chargeamt = rand(4,7)
			temp = "Odzyskujesz [chargeamt] punktów"
			playsound(loc, 'sound/arcade/mana.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			player_mp += chargeamt
			if(turtle > 0)
				turtle--

			updateUsrDialog()
			sleep(10)
			arcade_action(usr)

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "Nowa runda"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = FALSE
		turtle = 0

		if(obj_flags & EMAGGED)
			Reset()
			obj_flags &= ~EMAGGED

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/arcade/battle/proc/arcade_action(mob/user)
	if ((enemy_mp <= 0) || (enemy_hp <= 0))
		if(!gameover)
			gameover = TRUE
			temp = "[enemy_name] pada! Radujcie się!"
			playsound(loc, 'sound/arcade/win.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)

			if(obj_flags & EMAGGED)
				new /obj/effect/spawner/newbomb/timer/syndicate(loc)
				new /obj/item/clothing/head/collectable/petehat(loc)
				message_admins("[ADMIN_LOOKUPFLW(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				Reset()
				obj_flags &= ~EMAGGED
			else
				prizevend(user)
			SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("win", (obj_flags & EMAGGED ? "emagged":"normal")))


	else if ((obj_flags & EMAGGED) && (turtle >= 4))
		var/boomamt = rand(5,10)
		temp = "[enemy_name] rzuca bombę, która zadaje ci [boomamt] obrażeń!"
		playsound(loc, 'sound/arcade/boom.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
		player_hp -= boomamt

	else if ((enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		temp = "[enemy_name] kradnie ci [stealamt] mocy!"
		playsound(loc, 'sound/arcade/steal.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
		player_mp -= stealamt
		updateUsrDialog()

		if (player_mp <= 0)
			gameover = TRUE
			sleep(10)
			temp = "Zostajesz wyssany! KONIEC GRY"
			playsound(loc, 'sound/arcade/lose.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			if(obj_flags & EMAGGED)
				usr.gib()
			SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("loss", "mana", (obj_flags & EMAGGED ? "emagged":"normal")))

	else if ((enemy_hp <= 10) && (enemy_mp > 4))
		temp = "[enemy_name] leczy się o 4 punkty zdrowia!"
		playsound(loc, 'sound/arcade/heal.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
		enemy_hp += 4
		enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		temp = "[enemy_name] atakuje, zadając [attackamt] obrażeń!"
		playsound(loc, 'sound/arcade/hit.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
		player_hp -= attackamt

	if ((player_mp <= 0) || (player_hp <= 0))
		gameover = TRUE
		temp = "Zostajesz zmiażdżony! KONIEC GRY"
		playsound(loc, 'sound/arcade/lose.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
		if(obj_flags & EMAGGED)
			usr.gib()
		SSblackbox.record_feedback("nested tally", "arcade_results", 1, list("loss", "hp", (obj_flags & EMAGGED ? "emagged":"normal")))

	blocked = FALSE
	return


/obj/machinery/computer/arcade/battle/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='warning'>Z głośników automatu zaczyna płynąć hipnotyzujący rytm rumby!</span>")
	temp = "Jeśli zginiesz w grze, zginiesz naprawdę!"
	player_hp = 30
	player_mp = 10
	enemy_hp = 45
	enemy_mp = 20
	gameover = FALSE
	blocked = FALSE

	obj_flags |= EMAGGED

	enemy_name = "Cuban Pete"
	name = "Outbomb Cuban Pete"


	updateUsrDialog()



// *** THE ORION TRAIL ** //

/obj/item/gamer_pamphlet
	name = "pamphlet - \'Violent Video Games and You\'"
	desc = "A pamphlet encouraging the reader to maintain a balanced lifestyle and take care of their mental health, while still enjoying video games in a healthy way. You probably don't need this..."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pamphlet"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY


#define ORION_TRAIL_WINTURN		9

//Orion Trail Events
#define ORION_TRAIL_RAIDERS		"Raiders"
#define ORION_TRAIL_FLUX		"Interstellar Flux"
#define ORION_TRAIL_ILLNESS		"Illness"
#define ORION_TRAIL_BREAKDOWN	"Breakdown"
#define ORION_TRAIL_LING		"Changelings?"
#define ORION_TRAIL_LING_ATTACK "Changeling Ambush"
#define ORION_TRAIL_MALFUNCTION	"Malfunction"
#define ORION_TRAIL_COLLISION	"Collision"
#define ORION_TRAIL_SPACEPORT	"Spaceport"
#define ORION_TRAIL_BLACKHOLE	"BlackHole"
#define ORION_TRAIL_OLDSHIP		"Old Ship"
#define ORION_TRAIL_SEARCH		"Old Ship Search"

#define ORION_STATUS_START		1
#define ORION_STATUS_NORMAL		2
#define ORION_STATUS_GAMEOVER	3
#define ORION_STATUS_MARKET		4

/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/orion_trail
	var/busy = FALSE //prevent clickspam that allowed people to ~speedrun~ the game.
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/alive = 4
	var/eventdat = null
	var/event = null
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/events = list(ORION_TRAIL_RAIDERS		= 3,
						   ORION_TRAIL_FLUX			= 1,
						   ORION_TRAIL_ILLNESS		= 3,
						   ORION_TRAIL_BREAKDOWN	= 2,
						   ORION_TRAIL_LING			= 3,
						   ORION_TRAIL_MALFUNCTION	= 2,
						   ORION_TRAIL_COLLISION	= 1,
						   ORION_TRAIL_SPACEPORT	= 2,
						   ORION_TRAIL_OLDSHIP		= 2
						   )
	var/list/stops = list()
	var/list/stopblurbs = list()
	var/lings_aboard = 0
	var/spaceport_raided = 0
	var/spaceport_freebie = 0
	var/last_spaceport_action = ""
	var/gameStatus = ORION_STATUS_START
	var/canContinueEvent = 0

	var/obj/item/radio/Radio
	var/static/list/gamers = list()
	var/killed_crew = 0


/obj/machinery/computer/arcade/orion_trail/Initialize(mapload)
	. = ..()
	Radio = new /obj/item/radio(src)
	Radio.listening = 0

/obj/machinery/computer/arcade/orion_trail/kobayashi
	name = "Kobayashi Maru control computer"
	desc = "A test for cadets"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_boxp"
	events = list("Raiders" = 3, "Interstellar Flux" = 1, "Illness" = 3, "Breakdown" = 2, "Malfunction" = 2, "Collision" = 1, "Spaceport" = 2)
	prize_override = list(/obj/item/paper/fluff/holodeck/trek_diploma = 1)
	settlers = list("Kirk","Worf","Gene")

/obj/machinery/computer/arcade/orion_trail/Reset()
	// Sets up the main trail
	stops = list("Pluto","Asteroid Belt","Proxima Centauri","Dead Space","Rigel Prime","Tau Ceti Beta","Black Hole","Space Outpost Beta-9","Orion Prime")
	stopblurbs = list(
		"Pluton, od dawna zajęty przez czujniki i skanery dalekiego zasięgu, stoi gotów, by badać - i wciąż bada - najdalsze zakątki galaktyki.",
		"Na skraju Układu Słonecznego leży zdradliwy pas asteroid. Wielu zostało zmiażdżonych przez zabłąkane asteroidy i błędne decyzje.",
		"Najbliższy Słońcu układ gwiezdny dawno temu przypominał o granicach podróży podświetlnych, a dziś jest słabo zaludnioną przystanią dla poszukiwaczy przygód i handlarzy.",
		"Ten obszar kosmosu jest wyjątkowo ubogi w materię. Wiadomo, że takie rozrzedzone kieszenie istnieją, ale jego ogrom zdumiewa.",
		"Rigel Prime, centrum układu Rigel, płonie gorąco, skąpiąc swoje planety w cieple i promieniowaniu.",
		"Tau Ceti Beta stało się niedawno punktem przystankowym dla kolonistów zmierzających na Oriona. W pobliżu jest wiele statków i prowizorycznych stacji.",
		"Czujniki wskazują, że pole grawitacyjne czarnej dziury wpływa na obszar, przez który mieliśmy lecieć. Możemy oczywiście lecieć dalej, ryzykując, że pochłonie nas jej grawitacja, albo zmienić kurs i ją ominąć, co potrwa dłużej.",
		"Docierasz w zasięg pierwszej konstrukcji zbudowanej przez człowieka w tym obszarze kosmosu. Nie zbudowali jej podróżnicy z Układu Słonecznego, lecz koloniści z Oriona. Stoi jako pomnik ich sukcesu.",
		"Dotarłeś na Oriona! Gratulacje! Twoja załoga jest jedną z niewielu, które założyły nowy przyczółek ludzkości!"
		)

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	settlers = list()
	for(var/i = 1; i <= 3; i++)
		add_crewmember()
	add_crewmember("[usr]")
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	gameStatus = ORION_STATUS_NORMAL
	lings_aboard = 0
	killed_crew = 0

	//spaceport junk
	spaceport_raided = 0
	spaceport_freebie = 0
	last_spaceport_action = ""

/obj/machinery/computer/arcade/orion_trail/proc/report_player(mob/gamer)
	if(gamers[gamer] == -2)
		return // enough harassing them

	if(gamers[gamer] == -1)
		say("OSTRZEŻENIE: wykryto dalsze zachowania aspołeczne. Wydawanie literatury samopomocowej.")
		new /obj/item/gamer_pamphlet(get_turf(src))
		gamers[gamer]--
		return

	if(!(gamer in gamers))
		gamers[gamer] = 0

	gamers[gamer]++ // How many times the player has 'prestiged' (massacred their crew)

	if(gamers[gamer] > 2 && prob(20 * gamers[gamer]))

		Radio.set_frequency(FREQ_SECURITY)
		Radio.talk_into(src, "ALARM OCHRONY: członek załogi [gamer] wykazuje skłonności aspołeczne w [get_area(src)]. Proszę uważać na agresywne zachowania.", FREQ_SECURITY)

		Radio.set_frequency(FREQ_MEDICAL)
		Radio.talk_into(src, "ALARM PSYCHOLOGICZNY: członek załogi [gamer] wykazuje skłonności aspołeczne w [get_area(src)]. Prosimy o umówienie oceny psychologicznej.", FREQ_MEDICAL)

		gamers[gamer] = -1

		if(!isnull(GLOB.data_core.general))
			for(var/datum/data/record/R in GLOB.data_core.general)
				if(R.fields["name"] == gamer.name)
					R.fields["m_stat"] = "*Unstable*"
					return


/obj/machinery/computer/arcade/orion_trail/ui_interact(mob/user)
	. = ..()
	if(fuel <= 0 || food <=0 || settlers.len == 0)
		gameStatus = ORION_STATUS_GAMEOVER
		event = null
	var/dat = ""
	if(gameStatus == ORION_STATUS_GAMEOVER)
		dat = "<center><h1>Koniec gry</h1></center>"
		dat += "Jak wielu przed tobą, twoja załoga nigdy nie dotarła na Oriona, zagubiona w kosmosie. <br><b>Na zawsze</b>."
		if(!settlers.len)
			dat += "<br>Cała twoja załoga zginęła, a twój statek dołącza do floty statków widm zaśmiecających galaktykę."
		else
			if(food <= 0)
				dat += "<br>Skończyło ci się jedzenie i umarłeś z głodu."
				if(obj_flags & EMAGGED)
					user.set_nutrition(0) //yeah you pretty hongry
					to_chat(user, "<span class='userdanger'>Twoje ciało natychmiast kurczy się jak u kogoś, kto nie jadł od miesięcy. Rozdzierające skurcze powalają cię na podłogę.</span>")
			if(fuel <= 0)
				dat += "<br>Skończyło ci się paliwo i powoli dryfujesz w stronę gwiazdy."
				if(obj_flags & EMAGGED)
					var/mob/living/M = user
					M.adjust_fire_stacks(5)
					M.IgniteMob() //flew into a star, so you're on fire
					to_chat(user, "<span class='userdanger'>Czujesz, jak z automatu bije ogromna fala gorąca. Twoja skóra staje w płomieniach.</span>")

		if(obj_flags & EMAGGED)
			to_chat(user, "<span class='userdanger'>Nigdy nie dotrzesz na Oriona...</span>")
			user.death()
			obj_flags &= ~EMAGGED //removes the emagged status after you lose
			gameStatus = ORION_STATUS_START
			name = "The Orion Trail"
			desc = "Learn how our ancestors got to Orion, and have fun in the process!"

		dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];menu=1'>Niech spoczywają w pokoju</a></P>"
	else if(event)
		dat = eventdat
	else if(gameStatus == ORION_STATUS_NORMAL)
		var/title = stops[turns]
		var/subtext = stopblurbs[turns]
		dat = "<center><h1>[title]</h1></center>"
		dat += "[subtext]"
		dat += "<h3><b>Crew:</b></h3>"
		dat += english_list(settlers)
		dat += "<br><b>Jedzenie: </b>[food] | <b>Paliwo: </b>[fuel]"
		dat += "<br><b>Części silnika: </b>[engine] | <b>Płyty kadłuba: </b>[hull] | <b>Elektronika: </b>[electronics]"
		if(turns == 7)
			dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];pastblack=1'>Omiń</a> <a href='byond://?src=[REF(src)];blackhole=1'>Leć dalej</a></P>"
		else
			dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];continue=1'>Continue</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];killcrew=1'>Kill a Crewmember</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
	else
		dat = "<center><h2>The Orion Trail</h2></center>"
		dat += "<br><center><h3>Przeżyj podróż swoich przodków!</h3></center><br><br>"
		dat += "<center><b><a href='byond://?src=[REF(src)];newgame=1'>Nowa gra</a></b></center>"
		dat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
	var/datum/browser/popup = new(user, "arcade", "The Orion Trail",400,700)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/arcade/orion_trail/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	if(busy)
		return
	busy = TRUE

	if (href_list["continue"]) //Continue your travels
		if(gameStatus == ORION_STATUS_NORMAL && !event && turns != 7)
			if(turns >= ORION_TRAIL_WINTURN)
				win(usr)
			else
				food -= (alive+lings_aboard)*2
				fuel -= 5
				if(turns == 2 && prob(30))
					event = ORION_TRAIL_COLLISION
					event()
				else if(prob(75))
					event = pickweight(events)
					if(lings_aboard)
						if(event == ORION_TRAIL_LING || prob(55))
							event = ORION_TRAIL_LING_ATTACK
					event()
				turns += 1
			if(obj_flags & EMAGGED)
				var/mob/living/carbon/M = usr //for some vars
				switch(event)
					if(ORION_TRAIL_RAIDERS)
						if(prob(50))
							to_chat(usr, "<span class='userdanger'>Słyszysz okrzyki bojowe. Tupot butów na zimnym metalu. Krzyki agonii. Świst uchodzącego powietrza. Czy ty wariujesz?</span>")
							M.hallucination += 30
						else
							to_chat(usr, "<span class='userdanger'>Coś uderza cię od tyłu! Boli jak diabli i przypomina tępą broń, ale nic tam nie ma...</span>")
							M.take_bodypart_damage(30)
							playsound(loc, 'sound/weapons/genhit2.ogg', 100, 1)
					if(ORION_TRAIL_ILLNESS)
						var/severity = rand(1,3) //pray to RNGesus. PRAY, PIGS
						if(severity == 1)
							to_chat(M, "<span class='userdanger'>Nagle robi ci się lekko niedobrze.</span>" )
						if(severity == 2)
							to_chat(usr, "<span class='userdanger'>Nagle robi ci się bardzo niedobrze i zginasz się wpół, dopóki nie przejdzie.</span>")
							M.Stun(60)
						if(severity >= 3) //you didn't pray hard enough
							to_chat(M, "<span class='warning'>Ogarnia cię przytłaczająca fala mdłości. Zginasz się wpół, a zawartość żołądka szykuje się do spektakularnego wyjścia.</span>")
							M.Stun(100)
							sleep(30)
							M.vomit(10, distance = 5)
					if(ORION_TRAIL_FLUX)
						if(prob(75))
							M.Paralyze(60)
							say("Nagły, potężny podmuch wiatru rzuca [M] na podłogę!")
							M.take_bodypart_damage(25)
							playsound(loc, 'sound/weapons/genhit.ogg', 100, 1)
						else
							to_chat(M, "<span class='userdanger'>Obok ciebie przechodzi gwałtowna wichura, a ty ledwo utrzymujesz się na nogach!</span>")
					if(ORION_TRAIL_COLLISION) //by far the most damaging event
						if(prob(90))
							playsound(loc, 'sound/effects/bang.ogg', 100, 1)
							for(var/turf/open/floor/F in RANGE_TURFS(1, src))
								F.ScrapeAway()
							say("Coś uderza w podłogę wokół [src], odsłaniając ją na kosmos!")
							if(hull)
								sleep(10)
								say("Wokół [src] nagle pojawia się nowa podłoga. Co do diabła?")
								playsound(loc, 'sound/weapons/genhit.ogg', 100, 1)
								for(var/turf/open/space/T in RANGE_TURFS(1, src))
									T.PlaceOnTop(/turf/open/floor/plating)
						else
							say("Coś uderza w podłogę wokół [src] - na szczęście nie przebija się!")
							playsound(loc, 'sound/effects/bang.ogg', 50, 1)
					if(ORION_TRAIL_MALFUNCTION)
						playsound(loc, 'sound/effects/empulse.ogg', 50, 1)
						visible_message("<span class='danger'>[src] działa wadliwie, losując statystyki w grze!</span>")
						var/oldfood = food
						var/oldfuel = fuel
						food = rand(10,80) / rand(1,2)
						fuel = rand(10,60) / rand(1,2)
						if(electronics)
							sleep(10)
							if(oldfuel > fuel && oldfood > food)
								audible_message("<span class='danger'>[src] wydaje w jakiś sposób uspokajający dzwonek.</span>")
							else if(oldfuel < fuel || oldfood < food)
								audible_message("<span class='danger'>[src] wydaje w jakiś sposób złowieszczy dzwonek.</span>")
							food = oldfood
							fuel = oldfuel
							playsound(loc, 'sound/machines/chime.ogg', 50, 1)

	else if(href_list["newgame"]) //Reset everything
		if(gameStatus == ORION_STATUS_START)
			newgame()
	else if(href_list["menu"]) //back to the main menu
		if(gameStatus == ORION_STATUS_GAMEOVER)
			gameStatus = ORION_STATUS_START
			event = null
			food = 80
			fuel = 60
			settlers = list("Harry","Larry","Bob")
	else if(href_list["search"]) //search old ship
		if(event == ORION_TRAIL_OLDSHIP)
			event = ORION_TRAIL_SEARCH
			event()
	else if(href_list["slow"]) //slow down
		if(event == ORION_TRAIL_FLUX)
			food -= (alive+lings_aboard)*2
			fuel -= 5
		event = null
	else if(href_list["pastblack"]) //slow down
		if(turns == 7)
			food -= ((alive+lings_aboard)*2)*3
			fuel -= 15
			turns += 1
			event = null
	else if(href_list["useengine"]) //use parts
		if(event == ORION_TRAIL_BREAKDOWN)
			engine = max(0, --engine)
			event = null
	else if(href_list["useelec"]) //use parts
		if(event == ORION_TRAIL_MALFUNCTION)
			electronics = max(0, --electronics)
			event = null
	else if(href_list["usehull"]) //use parts
		if(event == ORION_TRAIL_COLLISION)
			hull = max(0, --hull)
			event = null
	else if(href_list["wait"]) //wait 3 days
		if(event == ORION_TRAIL_BREAKDOWN || event == ORION_TRAIL_MALFUNCTION || event == ORION_TRAIL_COLLISION)
			food -= ((alive+lings_aboard)*2)*3
			event = null
	else if(href_list["keepspeed"]) //keep speed
		if(event == ORION_TRAIL_FLUX)
			if(prob(75))
				event = "Breakdown"
				event()
			else
				event = null
	else if(href_list["blackhole"]) //keep speed past a black hole
		if(turns == 7)
			if(prob(75))
				event = ORION_TRAIL_BLACKHOLE
				event()
				if(obj_flags & EMAGGED)
					playsound(loc, 'sound/effects/supermatter.ogg', 100, 1)
					say("Przed [src] nagle pojawia się miniaturowa czarna dziura, pożerając [usr] żywcem!")
					if(isliving(usr))
						var/mob/living/L = usr
						L.Stun(200, ignore_canstun = TRUE) //you can't run :^)
					var/S = new /obj/anomaly/singularity/academy(usr.loc)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, say), "[S] znika równie nagle, jak się pojawiła."), 50)
					QDEL_IN(S, 50)
			else
				event = null
				turns += 1
	else if(href_list["holedeath"])
		if(event == ORION_TRAIL_BLACKHOLE)
			gameStatus = ORION_STATUS_GAMEOVER
			event = null
	else if(href_list["eventclose"]) //end an event
		if(canContinueEvent)
			event = null

	else if(href_list["killcrew"]) //shoot a crewmember
		if(gameStatus == ORION_STATUS_NORMAL || event == ORION_TRAIL_LING)
			var/sheriff = remove_crewmember() //I shot the sheriff
			playsound(loc,'sound/weapons/gunshot.ogg', 100, 1)
			killed_crew++

			if(settlers.len == 0 || alive == 0)
				say("Ostatni członek załogi, [sheriff], zastrzelił się. KONIEC GRY!")
				if(obj_flags & EMAGGED)
					usr.death(0)
					obj_flags &= EMAGGED
				gameStatus = ORION_STATUS_GAMEOVER
				event = null


				if(killed_crew >= 4)
					report_player(usr)

			else if(obj_flags & EMAGGED)
				if(usr.name == sheriff)
					say("Załoga statku postanowiła zabić [usr.name]!")
					usr.death(0)

			if(event == ORION_TRAIL_LING) //only ends the ORION_TRAIL_LING event, since you can do this action in multiple places
				event = null
				killed_crew-- // the kill was valid

	//Spaceport specific interactions
	//they get a header because most of them don't reset event (because it's a shop, you leave when you want to)
	//they also call event() again, to regen the eventdata, which is kind of odd but necessary
	else if(href_list["buycrew"]) //buy a crewmember
		if(gameStatus == ORION_STATUS_MARKET)
			if(!spaceport_raided && food >= 10 && fuel >= 10)
				var/bought = add_crewmember()
				last_spaceport_action = "Zatrudniasz nowego członka załogi: [bought]."
				fuel -= 10
				food -= 10
				event()
				killed_crew-- // I mean not really but you know

	else if(href_list["sellcrew"]) //sell a crewmember
		if(gameStatus == ORION_STATUS_MARKET)
			if(!spaceport_raided && settlers.len > 1)
				var/sold = remove_crewmember()
				last_spaceport_action = "Sprzedajesz członka załogi: [sold]!"
				fuel += 7
				food += 7
				event()

	else if(href_list["leave_spaceport"])
		if(gameStatus == ORION_STATUS_MARKET)
			event = null
			gameStatus = ORION_STATUS_NORMAL
			spaceport_raided = 0
			spaceport_freebie = 0
			last_spaceport_action = ""

	else if(href_list["raid_spaceport"])
		if(gameStatus == ORION_STATUS_MARKET)
			if(!spaceport_raided)
				var/success = min(15 * alive,100) //default crew (4) have a 60% chance
				spaceport_raided = 1

				var/FU = 0
				var/FO = 0
				if(prob(success))
					FU = rand(5,15)
					FO = rand(5,15)
					last_spaceport_action = "Udaje ci się złupić port kosmiczny! Zyskujesz [FU] paliwa i [FO] jedzenia! (+[FU]FU,+[FO]FO)"
				else
					FU = rand(-5,-15)
					FO = rand(-5,-15)
					last_spaceport_action = "Nie udaje ci się złupić portu kosmicznego! W ucieczce tracisz [FU*-1] paliwa i [FO*-1] jedzenia! ([FU]FU,[FO]FO)"

					//your chance of lose a crewmember is 1/2 your chance of success
					//this makes higher % failures hurt more, don't get cocky space cowboy!
					if(prob(success*5))
						var/lost_crew = remove_crewmember()
						last_spaceport_action = "Nie udaje ci się złupić portu kosmicznego! W ucieczce tracisz [FU*-1] paliwa i [FO*-1] jedzenia, ORAZ [lost_crew]! ([FU]FI,[FO]FO,-Załoga)"
						if(obj_flags & EMAGGED)
							say("IJOIJO! IJOIJO! Ochrona portu kosmicznego w drodze!")
							playsound(src, 'sound/items/weeoo1.ogg', 100, FALSE)
							for(var/i, i<=3, i++)
								var/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion/O = new/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion(get_turf(src))
								O.target = usr


				fuel += FU
				food += FO
				event()

	else if(href_list["buyparts"])
		if(gameStatus == ORION_STATUS_MARKET)
			if(!spaceport_raided && fuel > 5)
				switch(text2num(href_list["buyparts"]))
					if(1) //Engine Parts
						engine++
						last_spaceport_action = "Kupiono części silnika"
					if(2) //Hull Plates
						hull++
						last_spaceport_action = "Kupiono płyty kadłuba"
					if(3) //Spare Electronics
						electronics++
						last_spaceport_action = "Kupiono zapasową elektronikę"
				fuel -= 5 //they all cost 5
				event()

	else if(href_list["trade"])
		if(gameStatus == ORION_STATUS_MARKET)
			if(!spaceport_raided)
				switch(text2num(href_list["trade"]))
					if(1) //Fuel
						if(fuel > 5)
							fuel -= 5
							food += 5
							last_spaceport_action = "Wymieniono paliwo na jedzenie"
							event()
					if(2) //Food
						if(food > 5)
							fuel += 5
							food -= 5
							last_spaceport_action = "Wymieniono jedzenie na paliwo"
							event()

	add_fingerprint(usr)
	updateUsrDialog()
	busy = FALSE
	return


/obj/machinery/computer/arcade/orion_trail/proc/event()
	eventdat = "<center><h1>[event]</h1></center>"
	canContinueEvent = 0
	switch(event)
		if(ORION_TRAIL_RAIDERS)
			eventdat += "Najeźdźcy weszli na pokład twojego statku!"
			if(prob(50))
				var/sfood = rand(1,10)
				var/sfuel = rand(1,10)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>Ukradli [sfood] <b>jedzenia</b> i [sfuel] <b>paliwa</b>."
			else if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] próbował się bronić, ale zginął."
			else
				eventdat += "<br>Na szczęście bez trudu ich odparliście."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			canContinueEvent = 1

		if(ORION_TRAIL_FLUX)
			eventdat += "Ten obszar kosmosu jest bardzo turbulentny. <br>Jeśli zwolnimy, możemy uniknąć dalszych uszkodzeń, ale jeśli utrzymamy prędkość, nie zmarnujemy zapasów."
			eventdat += "<br>Co robisz?"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];slow=1'>Zwolnij</a> <a href='byond://?src=[REF(src)];keepspeed=1'>Leć dalej</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"

		if(ORION_TRAIL_OLDSHIP)
			eventdat += "<br>Twoja załoga zauważa stary statek dryfujący w kosmosie. Mogą tam być zapasy, ale wygląda na dość niebezpieczny."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];search=1'>Przeszukaj go</a><a href='byond://?src=[REF(src)];eventclose=1'>Zostaw go</a></P><P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Zamknij</a></P>"
			canContinueEvent = 1

		if(ORION_TRAIL_SEARCH)
			switch(rand(100))
				if(0 to 15)
					var/rescued = add_crewmember()
					var/oldfood = rand(1,7)
					var/oldfuel = rand(4,10)
					food += oldfood
					fuel += oldfuel
					eventdat += "<br>Przeszukując go, znajdujesz trochę zapasów i żywą osobę!"
					eventdat += "<br>Z porzuconego statku uratowano: [rescued]!"
					eventdat += "<br>Znajdujesz [oldfood] <b>jedzenia</b> i [oldfuel] <b>paliwa</b>."
				if(15 to 35)
					var/lfuel = rand(4,7)
					var/deadname = remove_crewmember()
					fuel -= lfuel
					eventdat += "<br>[deadname] zaginął głęboko we wraku, a twój statek stracił [lfuel] <b>paliwa</b> na manewrowanie do porzuconego statku."
				if(35 to 65)
					var/oldfood = rand(5,11)
					food += oldfood
					engine++
					eventdat += "<br>Znajdujesz we wraku [oldfood] <b>jedzenia</b> i trochę części."
				else
					eventdat += "<br>Przeszukując wrak, nie znajdujesz niczego przydatnego."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			canContinueEvent = 1

		if(ORION_TRAIL_ILLNESS)
			eventdat += "Ktoś zaraził się śmiertelną chorobą!"
			var/deadname = remove_crewmember()
			eventdat += "<br>[deadname] umiera na chorobę."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			canContinueEvent = 1

		if(ORION_TRAIL_BREAKDOWN)
			eventdat += "O nie! Silnik się zepsuł!"
			eventdat += "<br>Możesz go naprawić częścią silnika albo naprawiać go przez 3 dni."
			if(engine >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];useengine=1'>Użyj części</a><a href='byond://?src=[REF(src)];wait=1'>Czekaj</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"

		if(ORION_TRAIL_MALFUNCTION)
			eventdat += "Systemy statku działają wadliwie!"
			eventdat += "<br>Możesz wymienić zepsutą elektronikę na zapasową albo przez 3 dni szukać usterki w SI."
			if(electronics >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];useelec=1'>Użyj części</a><a href='byond://?src=[REF(src)];wait=1'>Czekaj</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"

		if(ORION_TRAIL_COLLISION)
			eventdat += "Coś nas uderzyło! Wygląda na to, że kadłub jest uszkodzony."
			if(prob(25))
				var/sfood = rand(5,15)
				var/sfuel = rand(5,15)
				food -= sfood
				fuel -= sfuel
				eventdat += "<br>[sfood] <b>jedzenia</b> i [sfuel] <b>paliwa</b> wyleciało w kosmos."
			if(prob(10))
				var/deadname = remove_crewmember()
				eventdat += "<br>[deadname] ginie w wyniku gwałtownej dekompresji."
			eventdat += "<br>Możesz naprawić uszkodzenia płytami kadłuba albo przez następne 3 dni spawać złom."
			if(hull >= 1)
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];usehull=1'>Użyj części</a><a href='byond://?src=[REF(src)];wait=1'>Czekaj</a></P>"
			else
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];wait=1'>Wait</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"

		if(ORION_TRAIL_BLACKHOLE)
			eventdat += "Zostajesz wciągnięty w czarną dziurę."
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];holedeath=1'>Oh...</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			settlers = list()

		if(ORION_TRAIL_LING)
			eventdat += "Dziwne doniesienia ostrzegają przed zmiennokształtnymi infiltrującymi załogi w drodze na Oriona..."
			if(settlers.len <= 2)
				eventdat += "<br>Szanse twojej załogi na dotarcie na Oriona są tak marne, że zmiennokształtni pewnie omijają twój statek..."
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Continue</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
				if(prob(10)) // "likely", I didn't say it was guaranteed!
					lings_aboard = min(++lings_aboard,2)
			else
				if(lings_aboard) //less likely to stack lings
					if(prob(20))
						lings_aboard = min(++lings_aboard,2)
				else if(prob(70))
					lings_aboard = min(++lings_aboard,2)

				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];killcrew=1'>Kill a Crewmember</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Zaryzykuj</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			canContinueEvent = 1

		if(ORION_TRAIL_LING_ATTACK)
			if(lings_aboard <= 0) //shouldn't trigger, but hey.
				eventdat += "Haha, nabrałem cię, na pokładzie nie ma zmiennokształtnych!"
				eventdat += "<br>(Zgłoś to koderowi :S)"
			else
				var/ling1 = remove_crewmember()
				var/ling2 = ""
				if(lings_aboard >= 2)
					ling2 = remove_crewmember()

				eventdat += "Zmiennokształtni wśród twojej załogi nagle wyskakują z ukrycia i atakują!"
				if(ling2)
					eventdat += "<br>Ramiona [ling1] i [ling2] wykręcają się i wykrzywiają w groteskowe ostrza!"
				else
					eventdat += "<br>Ramię [ling1] wykręca się i wykrzywia w groteskowe ostrze!"

				var/chance2attack = alive*20
				if(prob(chance2attack))
					var/chancetokill = 30*lings_aboard-(5*alive) //eg: 30*2-(10) = 50%, 2 lings, 2 crew is 50% chance
					if(prob(chancetokill))
						var/deadguy = remove_crewmember()
						var/murder_text = pick("[ling2 ? "Zmiennokształtni powalają" : "Zmiennokształtny powala"] [deadguy] i [ling2 ? "wypruwają" : "wypruwa"] mu wnętrzności w fontannie krwi!", \
						"[ling2 ? pick(ling1, ling2) : ling1] osacza [deadguy] i przebija go na wylot przez brzuch!", \
						"[ling2 ? pick(ling1, ling2) : ling1] ścina [deadguy] głowę jednym zamachem!")
						eventdat += "<br>[murder_text]"
					else
						eventdat += "<br><br><b>Dzielnie odpierasz [ling2 ? "zmiennokształtnych":"zmiennokształtnego"]!</b>"
						if(ling2)
							food += 30
							lings_aboard = max(0,lings_aboard-2)
						else
							food += 15
							lings_aboard = max(0,--lings_aboard)
						eventdat += "<br><i>Cóż, to całkiem dobre jedzenie...</i><br>Kroisz [ling2 ? "zmiennokształtnych" : "zmiennokształtnego"] na mięso, zyskując <b>[ling2 ? "30" : "15"]</b> jedzenia!"
				else
					eventdat += "<br><br>[pick("Wyczuwając niekorzystne szanse", "Po nieudanym ataku", "Nagle tracąc odwagę")], [ling2 ? "zmiennokształtni znikają":"zmiennokształtny znika"] w kosmosie przez śluzy! Jesteś bezpieczny... na razie."
					if(ling2)
						lings_aboard = max(0,lings_aboard-2)
					else
						lings_aboard = max(0,--lings_aboard)

			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];eventclose=1'>Continue</a></P>"
			eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			canContinueEvent = 1


		if(ORION_TRAIL_SPACEPORT)
			gameStatus = ORION_STATUS_MARKET
			if(spaceport_raided)
				eventdat += "Port kosmiczny jest w stanie najwyższej gotowości! Po nieudanym napadzie lokalne władze zakazały ci dokowania."
				if(last_spaceport_action)
					eventdat += "<br><b>Ostatnia akcja w porcie:</b> [last_spaceport_action]"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];leave_spaceport=1'>Opuść port kosmiczny</a></P>"
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];close=1'>Close</a></P>"
			else
				eventdat += "Twój skok do sektora trafia na port kosmiczny - co za szczęście!"
				eventdat += "<br>Ten port kosmiczny to dom podróżników, którzy nie dotarli na Oriona, ale znaleźli inny dom..."
				eventdat += "<br>Warunki handlu: FU = paliwo, FO = jedzenie"
				if(last_spaceport_action)
					eventdat += "<br><b>Ostatnia akcja:</b> [last_spaceport_action]"
				eventdat += "<h3><b>Crew:</b></h3>"
				eventdat += english_list(settlers)
				eventdat += "<br><b>Jedzenie: </b>[food] | <b>Paliwo: </b>[fuel]"
				eventdat += "<br><b>Części silnika: </b>[engine] | <b>Płyty kadłuba: </b>[hull] | <b>Elektronika: </b>[electronics]"


				//If your crew is pathetic you can get freebies (provided you haven't already gotten one from this port)
				if(!spaceport_freebie && (fuel < 20 || food < 20))
					spaceport_freebie++
					var/FU = 10
					var/FO = 10
					var/freecrew = 0
					if(prob(30))
						FU = 25
						FO = 25

					if(prob(10))
						add_crewmember()
						freecrew++

					eventdat += "<br>Handlarze z portu litują się nad tobą i hojnie dają ci trochę darmowych zapasów! (+[FU]FU, +[FO]FO)"
					if(freecrew)
						eventdat += "<br>Zyskujesz też nowego członka załogi!"

					fuel += FU
					food += FO

				//CREW INTERACTIONS
				eventdat += "<P ALIGN=Right>Zarządzanie załogą:</P>"

				//Buy crew
				if(food >= 10 && fuel >= 10)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buycrew=1'>Zatrudnij nowego członka załogi (-10FU, -10FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie stać cię na nowego członka załogi.</P>"

				//Sell crew
				if(settlers.len > 1)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];sellcrew=1'>Sprzedaj członka załogi za paliwo i jedzenie (+7FU, +7FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie masz innej załogi do sprzedania.</P>"

				//BUY/SELL STUFF
				eventdat += "<P ALIGN=Right>Części zapasowe:</P>"

				//Engine parts
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=1'>Kup części silnika (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie stać cię na części silnika.</a>"

				//Hull plates
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=2'>Kup płyty kadłuba (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie stać cię na płyty kadłuba.</a>"

				//Electronics
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];buyparts=3'>Kup zapasową elektronikę (-5FU)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie stać cię na zapasową elektronikę.</a>"

				//Trade
				if(fuel > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];trade=1'>Wymień paliwo na jedzenie (-5FU,+5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie masz 5FU na wymianę.</P"

				if(food > 5)
					eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];trade=2'>Wymień jedzenie na paliwo (+5FU,-5FO)</a></P>"
				else
					eventdat += "<P ALIGN=Right>Nie masz 5FO na wymianę.</P"

				//Raid the spaceport
				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];raid_spaceport=1'>!! Złup port kosmiczny !!</a></P>"

				eventdat += "<P ALIGN=Right><a href='byond://?src=[REF(src)];leave_spaceport=1'>Opuść port kosmiczny</a></P>"


//Add Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/add_crewmember(var/specific = "")
	var/newcrew = ""
	if(specific)
		newcrew = specific
	else
		if(prob(50))
			newcrew = pick(GLOB.first_names_male)
		else
			newcrew = pick(GLOB.first_names_female)
	if(newcrew)
		settlers += newcrew
		alive++
	return newcrew


//Remove Random/Specific crewmember
/obj/machinery/computer/arcade/orion_trail/proc/remove_crewmember(var/specific = "", var/dont_remove = "")
	var/list/safe2remove = settlers
	var/removed = ""
	if(dont_remove)
		safe2remove -= dont_remove
	if(specific && specific != dont_remove)
		safe2remove = list(specific)
	else
		removed = pick(safe2remove)

	if(removed)
		if(lings_aboard && prob(40*lings_aboard)) //if there are 2 lings you're twice as likely to get one, obviously
			lings_aboard = max(0,--lings_aboard)
		settlers -= removed
		alive--
	return removed


/obj/machinery/computer/arcade/orion_trail/proc/win(mob/user)
	gameStatus = ORION_STATUS_START
	say("Gratulacje, dotarłeś na Oriona!")
	if(obj_flags & EMAGGED)
		prizeselect = /obj/item/orion_ship
		prizevend(user)
		prizeselect = /obj/item/coin/arcade_token
		message_admins("[ADMIN_LOOKUPFLW(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend(user)
	obj_flags &= ~EMAGGED
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>Nadpisujesz menu kodów i przechodzisz do kodu #[rand(1, 50)]: tryb realizmu.</span>")
	name = "The Orion Trail: Realism Edition"
	desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
	newgame()
	obj_flags |= EMAGGED

/obj/machinery/computer/arcade/orion_trail/Destroy()
	QDEL_NULL(Radio)
	. = ..()

/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion
	name = "spaceport security"
	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
	faction = list("orion")
	loot = list()
	del_on_death = TRUE

/obj/item/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = WEIGHT_CLASS_SMALL
	var/active = 0 //if the ship is on

/obj/item/orion_ship/examine(mob/user)
	. = ..()
	if(!(in_range(user, src)))
		return
	if(!active)
		. += "<span class='notice'>Na spodzie jest mały przełącznik. Jest przestawiony w dół.</span>"
	else
		. += "<span class='notice'>Na spodzie jest mały przełącznik. Jest przestawiony w górę.</span>"

/obj/item/orion_ship/attack_self(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
	if(active)
		return

	log_bomber(usr, "primed an explosive", src, "for detonation")

	to_chat(user, "<span class='warning'>Przestawiasz przełącznik na spodzie [src].</span>")
	active = 1
	visible_message("<span class='notice'>[src] cicho pika i budzi się do życia!</span>")
	playsound(loc, 'sound/machines/defib_SaftyOn.ogg', 25, 1)
	say("Tu statek o ID #[rand(1,1000)] do Zarządu Portu Orion. Podchodzimy do lądowania, odbiór.")
	sleep(20)
	visible_message("<span class='warning'>[src] zaczyna wibrować...</span>")
	say("Eee, Port? Mamy jakieś problemy z reaktorem, możecie rzucić okiem? Odbiór.")
	sleep(30)
	say("O Boże! Kod Osiem! KOD OSIEM! ZARAZ WYB-")
	playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, 1)
	sleep(3.6)
	visible_message("<span class='userdanger'>[src] explodes!</span>")
	explosion(loc, 2,4,8, flame_range = 16)
	qdel(src)

// ** AMPUTATION ** //

/obj/machinery/computer/arcade/amputation
	name = "Mediborg's Amputation Adventure"
	desc = "A picture of a blood-soaked medical cyborg flashes on the screen. The mediborg has a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	icon_state = "arcade"
	circuit = /obj/item/circuitboard/computer/arcade/amputation

/obj/machinery/computer/arcade/amputation/attack_hand(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/c_user = user
	if(obj_flags & EMAGGED)
		if(!c_user.get_bodypart(BODY_ZONE_L_ARM) && !c_user.get_bodypart(BODY_ZONE_R_ARM))
			return
		to_chat(c_user, "<span class='warning'>Przysuwasz rękę do maszyny i zaczynasz się wahać, gdy ze środka wysuwa się mocno zakrwawiona gilotyna...</span>")
		if(do_after(c_user, 50, target = src))
			to_chat(c_user, "<span class='userdanger'>Z maszyny wystrzeliwują robotyczne ramiona, odcinają ci wszystkie kończyny i je wciągają!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			for(var/X in c_user.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						BP.dismember()
						qdel(BP)
			playsound(loc, 'sound/arcade/win.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			for(var/i=1 to rand(20, 30))
				prizevend(user)
		else
			to_chat(c_user, "<span class='notice'>(Rozsądnie) postanawiasz nie wkładać ręki do maszyny.</span>")
	else
		if(!c_user.get_bodypart(BODY_ZONE_L_ARM) && !c_user.get_bodypart(BODY_ZONE_R_ARM))
			return
		to_chat(c_user, "<span class='warning'>Przysuwasz rękę do maszyny i zaczynasz się wahać, gdy ze środka wysuwa się zakrwawiona gilotyna...</span>")
		if(do_after(c_user, 50, target = src))
			to_chat(c_user, "<span class='userdanger'>Gilotyna spada na twoją rękę, a maszyna ją wciąga!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			var/which_hand = BODY_ZONE_L_ARM
			if(!(c_user.active_hand_index % 2))
				which_hand = BODY_ZONE_R_ARM
			var/obj/item/bodypart/chopchop = c_user.get_bodypart(which_hand)
			chopchop.dismember()
			qdel(chopchop)
			playsound(loc, 'sound/arcade/win.ogg', 50, 1, extrarange = -3, falloff_exponent = 10)
			for(var/i=1 to rand(3, 5))
				prizevend(user)
		else
			to_chat(c_user, "<span class='notice'>(Rozsądnie) postanawiasz nie wkładać ręki do maszyny.</span>")


/obj/machinery/computer/arcade/amputation/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>Nadpisujesz systemy bezpieczeństwa automatu.</span>")
	name = "Mediborg's Amputation Adventure: Deluxe Edition"
	desc = "A picture of a blood-soaked medical cyborg flashes on the screen. The mediborg has glowing red eyes, and a speech bubble that says, \"Put your hand in the machine if you aren't a <b>coward!</b>\""
	obj_flags |= EMAGGED

#undef ORION_TRAIL_WINTURN
#undef ORION_TRAIL_RAIDERS
#undef ORION_TRAIL_FLUX
#undef ORION_TRAIL_ILLNESS
#undef ORION_TRAIL_BREAKDOWN
#undef ORION_TRAIL_LING
#undef ORION_TRAIL_LING_ATTACK
#undef ORION_TRAIL_MALFUNCTION
#undef ORION_TRAIL_COLLISION
#undef ORION_TRAIL_SPACEPORT
#undef ORION_TRAIL_BLACKHOLE
#undef ORION_TRAIL_OLDSHIP
#undef ORION_TRAIL_SEARCH

#undef ORION_STATUS_START
#undef ORION_STATUS_NORMAL
#undef ORION_STATUS_GAMEOVER
#undef ORION_STATUS_MARKET
