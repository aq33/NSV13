/datum/test_chamber_kit/pr_453
	name = "Bitrunning: Legion i LV-624"
	pr = "aq33/AquilaStation#453"
	description = "Pracownia z zestawu #452 (serwer ma 100 punktów). W konsoli wybierz Komnatę Ech: Legion ma się dzielić na mniejsze kopie, \
		a zaszyfrowana skrzynia wypaść dopiero po ostatniej, bez łupu z nekropolii. Potem LV-624: kolonia w dżungli z ksenomorfami, \
		meble mają stać na miejscu po załadowaniu (nic nie powinno latać), a za ukończenie z byteforge'a ma wylecieć pluszak."
	items = list(
		/obj/machinery/quantum_server = 1,
		/obj/machinery/computer/quantum_console = 1,
		/obj/machinery/netpod = 1,
		/obj/machinery/byteforge = 1,
		/obj/item/bitrunning_debug = 1,
	)

/datum/test_chamber_kit/pr_453/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/datum/test_chamber_kit/pr_452/base = new
	base.setup(spawned, turfs, center, user)
	qdel(base)
