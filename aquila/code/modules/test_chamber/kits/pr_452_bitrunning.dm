/datum/test_chamber_kit/pr_452
	name = "Bitrunning z tg"
	pr = "aq33/AquilaStation#452"
	description = "Pracownia w pigułce: serwer kwantowy z konsolą obok (100 punktów z dysku debug), netpod, byteforge i sklep NexaCache (dostajesz 3000 np na konto). \
		Załaduj domenę w konsoli, wejdź do netpoda (przeciągnij się na niego), zanieś skrzynię do miejsca wysyłki w kryjówce: nagroda ma wylecieć z byteforge'a. \
		Sprawdź drabinę i rozłączenie łomem. Cyfrowe wygnanie: wszczep drugiemu człowiekowi implant wygnania i wsadź go do netpoda - po 10 s ma trafić do Pętli, \
		a przy netpodzie ma zostać depozyt z jego rzeczami. W Pętli: terminal ładuje domeny za darmo, brama wpuszcza, drabina odsyła z powrotem."
	items = list(
		/obj/machinery/quantum_server = 1,
		/obj/machinery/computer/quantum_console = 1,
		/obj/machinery/netpod = 1,
		/obj/machinery/byteforge = 1,
		/obj/machinery/computer/order_console/bitrunning = 1,
		/mob/living/carbon/human = 2,
		/obj/item/implanter/exile = 1,
		/obj/item/disk/bitrunning/ability/tier2 = 1,
		/obj/item/disk/bitrunning/gimmick/dungeon = 1,
		/obj/item/bitrunning_debug = 1,
	)

/datum/test_chamber_kit/pr_452/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/machinery/quantum_server/server = locate() in spawned
	var/obj/machinery/computer/quantum_console/console = locate() in spawned
	var/obj/machinery/netpod/pod = locate() in spawned
	var/obj/machinery/byteforge/forge = locate() in spawned
	if(!server)
		return
	server.points = 100
	// konsola musi stać obok serwera, netpod i byteforge najwyżej 4 pola dalej
	for(var/direction in GLOB.cardinals)
		var/turf/open/next = get_step(server, direction)
		if(istype(next) && !is_blocked_turf(next, TRUE))
			console?.forceMove(next)
			break
	for(var/obj/machinery/machine as anything in list(pod, forge))
		if(machine && get_dist(machine, server) > 4)
			machine.forceMove(get_step(get_step(server, SOUTH), SOUTH))
	pod?.find_server()
	console?.find_server()
	var/mob/living/carbon/human/admin_body = user
	if(!istype(admin_body))
		return
	var/datum/bank_account/account = admin_body.get_bank_account()
	if(account)
		account.bitrunning_points += 3000
