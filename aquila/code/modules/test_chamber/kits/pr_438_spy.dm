/datum/test_chamber_kit/pr_438
	name = "PR 438: szpieg i czarny rynek"
	pr = "aq33/AquilaStation#438"
	description = "Robi z ciebie szpiega (trzeba być człowiekiem w komorze) z uplinkiem w długopisie. Długopis w ręce: lista zleceń. \
	Na liście jest dodatkowe zlecenie na mikrofalówkę z komory: kliknij ją długopisem PRAWYM przyciskiem, odczekaj skan i odbierz nagrodę. \
	Skradzione przedmioty (maszyny nie) mogą trafić na czarny rynek, kategoria Paserka. Uplink czarnego rynku działa z kartą ID z kontem: weź kartę z budżetem z zestawu. \
	LTSRBT stoi gotowe: otwórz je ręką, włóż przedmiot (np. pistolet na kapiszony), zamknij i kliknij prawym, żeby wystawić towar. Kupiony z dostawą LTSRBT towar pojawi się przy uplinku. Holochipem użytym na zamkniętym LTSRBT uzupełnisz rynek."
	items = list(
		/obj/item/pen = 1,
		/obj/machinery/microwave = 1,
		/obj/item/market_uplink/blackmarket = 1,
		/obj/item/card/id = 1,
		/obj/machinery/ltsrbt = 1,
		/obj/item/holochip = 1,
		/obj/item/toy/gun = 2,
	)

/datum/test_chamber_kit/pr_438/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/area/chamber_area = get_area(center)
	for(var/obj/item/card/id/card in spawned)
		card.name = "karta z budżetem (test)"
		card.registered_account = SSeconomy.get_dep_account(ACCOUNT_CIV)
	for(var/obj/item/holochip/chip in spawned)
		chip.credits = 2000
		chip.update_icon()

	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać szpiegiem. Przedmioty i tak leżą na arenie.</span>")
		return
	var/obj/item/pen/pen = locate() in spawned
	H.put_in_hands(pen)
	var/datum/antagonist/spy/spy = H.mind.has_antag_datum(/datum/antagonist/spy)
	if(!spy)
		spy = new
		spy.uplink_created = TRUE // the pen from the kit becomes the uplink below
		H.mind.add_antag_datum(spy)
	spy.create_spy_uplink(H, pen)

	var/datum/component/spy_uplink/uplink = pen.GetComponent(/datum/component/spy_uplink)
	var/datum/spy_bounty/test_chamber/bounty = new(uplink.handler)
	bounty.chamber_area = chamber_area
	uplink.handler.bounties[SPY_DIFFICULTY_EASY] += bounty

/// Bounty for anything in the test chamber, only made by the PR 438 kit
/datum/spy_bounty/test_chamber
	name = "Komora testowa: mikrofalówka"
	help = "Ukradnij mikrofalówkę z komory testowej."
	difficulty = SPY_DIFFICULTY_EASY
	weight = 0
	theft_time = 3 SECONDS
	black_market_prob = 100
	var/area/chamber_area

/datum/spy_bounty/test_chamber/init_bounty(datum/spy_bounty_handler/handler)
	return TRUE

/datum/spy_bounty/test_chamber/is_stealable(atom/movable/stealing)
	return istype(stealing, /obj/machinery/microwave) && get_area(stealing) == chamber_area
