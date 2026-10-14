/datum/test_chamber_kit/pr_000
	name = "Nowe asteroidy górnicze"
	pr = "aq33/AquilaStation#000"
	description = "Wybierz mapę z puli magnesu: ładuje się w osobnym miejscu z losowym rdzeniem rudy, a ty lądujesz na niej z kombinezonem i wiertłem. \
		Nowe mapy to asteroid21-30 i mining31-52. Sprawdź wygląd, czy rdzeń rudy jest w skale, moby, łupy i billboardy (mining48, mining50)."

/datum/test_chamber_kit/pr_000/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user)
		return
	var/list/maps = list()
	for(var/folder in list("asteroids", "ruins"))
		var/path = "_maps/map_files/Mining/nsv13/[folder]/"
		for(var/file in flist(path))
			maps["[folder]/[file]"] = "[path][file]"
	var/choice = tgui_input_list(user, "Którą mapę załadować?", "Asteroidy", sortList(maps))
	if(!choice)
		return
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(41, 41)
	if(!reservation)
		to_chat(user, "<span class='warning'>Nie udało się zarezerwować miejsca na mapę.</span>")
		return
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/list/core = pick(
		list(/turf/closed/mineral/iron, /turf/closed/mineral/titanium),
		list(/turf/closed/mineral/copper, /turf/closed/mineral/silver, /turf/closed/mineral/gold, /turf/closed/mineral/plasma),
		list(/turf/closed/mineral/diamond, /turf/closed/mineral/uranium, /turf/closed/mineral/bscrystal))
	var/datum/map_template/asteroid/template = new(maps[choice], null, FALSE, core)
	template.load(bottom_left, FALSE, TRUE)

	// Lądujemy na wolnym, nie-kosmicznym polu najbliżej środka mapy
	var/turf/middle = locate(bottom_left.x + 20, bottom_left.y + 20, bottom_left.z)
	var/turf/landing
	for(var/turf/T as anything in template.get_affected_turfs(bottom_left, FALSE))
		if(!isopenturf(T) || isspaceturf(T) || T.density)
			continue
		if(!landing || get_dist(T, middle) < get_dist(landing, middle))
			landing = T
	landing ||= bottom_left
	new /obj/item/clothing/suit/space/hardsuit/mining(landing)
	new /obj/item/tank/internals/oxygen(landing)
	new /obj/item/clothing/mask/gas/explorer(landing)
	new /obj/item/pickaxe/drill/diamonddrill(landing)
	new /obj/item/t_scanner/adv_mining_scanner(landing)
	user.forceMove(landing)
	to_chat(user, "<span class='notice'>Załadowano [choice]. Wrócisz czasownikiem komory testowej.</span>")
