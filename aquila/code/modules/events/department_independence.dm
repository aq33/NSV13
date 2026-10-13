// AQUILA - Department Independence: the union board of a random department calls a general strike over some grievance
// and the department proclaims an independent state. Its crew become separatists with a shared demand for Command.
// A random-event take on the old wizard "Departmental Uprising" (code/modules/events/wizard/departmentrevolt.dm).

/// Every department that can secede: its name, the jobs that belong to it, nation name prefixes and its own grievances
GLOBAL_LIST_INIT(aquila_independence_departments, list(
	list(
		"name" = "medyczny",
		"jobs" = list(JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_PARAMEDIC, JOB_NAME_CHEMIST, JOB_NAME_VIROLOGIST, JOB_NAME_GENETICIST, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_PSYCHIATRIST),
		"prefixes" = list("Lekar", "Medy", "Szpital", "Chemi", "Wiro", "Bandaż", "Strzykaw"),
		"reasons" = list(
			list("od tygodnia brakuje rękawiczek nitrylowych", "natychmiastowej dostawy rękawiczek"),
			list("dowództwo kazało leczyć klauna poza kolejką", "zniesienia przywilejów klauna w medbayu"),
			list("kriokomory są używane jako lodówki na piwo", "zwrotu kriokomór do celów medycznych"),
		),
	),
	list(
		"name" = "inżynieryjny",
		"jobs" = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN),
		"prefixes" = list("Spawal", "Atomo", "Kablo", "Ruro", "Silniko", "Izolo"),
		"reasons" = list(
			list("ktoś znowu ukradł wszystkie izolowane rękawice", "zwrotu izolowanych rękawic"),
			list("nikt nie zamyka drzwi do maszynowni", "zakazu wstępu do maszynowni dla osób postronnych"),
			list("mostek twierdzi, że reaktor \"jakoś sam działa\"", "publicznych przeprosin od mostka"),
		),
	),
	list(
		"name" = "naukowy",
		"jobs" = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST),
		"prefixes" = list("Nauko", "Robo", "Bada", "Labo", "Slime", "Toksy"),
		"reasons" = list(
			list("dowództwo obcięło budżet na badania", "przywrócenia budżetu na badania"),
			list("wprowadzono zakaz testowania bomb w godzinach pracy", "zniesienia zakazu testów bomb"),
			list("ktoś wypuścił wszystkie slime'y i zrzucił winę na naukowców", "oczyszczenia dobrego imienia nauki"),
		),
	),
	list(
		"name" = "zaopatrzenia",
		"jobs" = list(JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN, JOB_NAME_SHAFTMINER),
		"prefixes" = list("Skrzynio", "Paleto", "Kargo", "Górnio", "Magazy", "Paczko"),
		"reasons" = list(
			list("dowództwo nie zatwierdza zamówień na pizzę", "comiesięcznej dostawy pizzy"),
			list("górnicy od trzech zmian nie widzieli słońca", "dnia wolnego dla górników"),
			list("ktoś znowu ukradł wózek widłowy", "zwrotu wózka widłowego"),
		),
	),
	list(
		"name" = "usług",
		"jobs" = list(JOB_NAME_BARTENDER, JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_CURATOR, JOB_NAME_CHAPLAIN, JOB_NAME_CLOWN, JOB_NAME_MIME, JOB_NAME_BARBER, JOB_NAME_STAGEMAGICIAN),
		"prefixes" = list("Kuchnio", "Baro", "Klauno", "Mimo", "Zieleni", "Mopo", "Bibli"),
		"reasons" = list(
			list("napiwki trafiają do funduszu kapitańskiego", "zwrotu wszystkich napiwków"),
			list("załoga nie sprząta po sobie tac w mesie", "obowiązkowego odnoszenia tac"),
			list("kapitan nazwał kuchnię \"stołówką\"", "przeprosin i trzech gwiazdek Michelin"),
		),
	),
	list(
		"name" = "amunicji",
		"jobs" = list(JOB_NAME_MASTERATARMS, JOB_NAME_MUNITIONSTECHNICIAN, JOB_NAME_PILOT, JOB_NAME_AIRTRAFFICCONTROLLER),
		"prefixes" = list("Torpedo", "Amunicjo", "Pocisko", "Hangaro", "Piloto", "Działo"),
		"reasons" = list(
			list("zabroniono przerwy na papierosa przy dziale", "przywrócenia przerwy na papierosa"),
			list("piloci znowu lądują na pasie startowym bokiem", "nowego kursu lądowania dla pilotów"),
			list("mostek strzela z MAC-a bez uprzedzenia", "trzyminutowego uprzedzenia przed każdym strzałem"),
		),
	),
	list(
		"name" = "majtków",
		"jobs" = list(JOB_NAME_ASSISTANT),
		"prefixes" = list("Majtko", "Szaro", "Tunelo", "Asystento", "Kombinezo"),
		"reasons" = list(
			list("majtkowie nie mają dostępu do żadnych drzwi", "dostępu do wszystkich drzwi"),
			list("nikt nie chce nauczyć majtków żadnego zawodu", "darmowego szkolenia zawodowego"),
		),
	),
))

/// Grievances any department can strike over, as list(reason, demand)
GLOBAL_LIST_INIT(aquila_independence_common_reasons, list(
	list("dowództwo obcięło premie za nadgodziny", "przywrócenia premii za nadgodziny"),
	list("kapitan zjadł ostatnie pączki z pokoju socjalnego", "dostawy świeżych pączków"),
	list("ekspres do kawy jest zepsuty od trzech zmian", "nowego ekspresu do kawy"),
	list("Starszy Oficer kazał nosić krawaty na zmianie", "zniesienia obowiązku krawatów"),
	list("Nanotrasen wprowadziło formularz w trzech egzemplarzach na każdą przerwę", "zniesienia formularzy na przerwy"),
	list("pensje nie zostały wypłacone od dwóch cykli", "wypłaty zaległych pensji"),
	list("na stołówce znowu podano wyłącznie kremówki", "urozmaicenia jadłospisu"),
))

/datum/round_event_control/aquila_department_independence
	name = "Department Independence"
	typepath = /datum/round_event/aquila_department_independence
	weight = 10
	max_occurrences = 1
	min_players = 10
	earliest_start = 20 MINUTES

/datum/round_event/aquila_department_independence
	announceWhen = 1
	startWhen = 1
	fakeable = FALSE
	/// The department list from GLOB.aquila_independence_departments that secedes
	var/list/department
	/// Why the union board went on strike
	var/reason
	/// What the strikers demand from Command
	var/demand
	/// Name of the new state
	var/nation_name
	/// Minds of the department crew that will become separatists
	var/list/datum/mind/citizens = list()

/datum/round_event/aquila_department_independence/setup()
	var/list/candidates = list()
	for(var/list/possible_department in GLOB.aquila_independence_departments)
		var/list/members = get_department_members(possible_department["jobs"])
		if(length(members) >= 2)
			candidates[possible_department] = members
	if(!length(candidates)) // kill() from setup() does not stop the event, New() re-adds it, so announce() and start() check this too
		kill()
		return
	department = pick(candidates)
	citizens = candidates[department]
	var/list/grievance = pick(department["reasons"] + GLOB.aquila_independence_common_reasons)
	reason = grievance[1]
	demand = grievance[2]
	nation_name = "[prob(30) ? "Ludowa Republika " : ""][pick(department["prefixes"])][pick("stan", "landia", "wo", "nia", "ów", "ice", "polis")]"

/// Living, conscious crew on the ship with one of these jobs and no antagonist role yet
/datum/round_event/aquila_department_independence/proc/get_department_members(list/jobs)
	. = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !H.client || !H.mind || !is_station_level(H.z))
			continue
		if(!(H.mind.assigned_role in jobs) || length(H.mind.antag_datums))
			continue
		. += H.mind

/datum/round_event/aquila_department_independence/announce(fake)
	if(!department)
		return
	priority_announce("Zarząd związku zawodowego działu [department["name"]] ogłosił strajk generalny, ponieważ [reason]. \
		Strajkujący proklamowali niepodległe państwo [nation_name] i nie wrócą do pracy bez [demand]. \
		Dowództwo proszone jest o podjęcie negocjacji.", "Strajk generalny")

/datum/round_event/aquila_department_independence/start()
	if(!department)
		return kill()
	// Someone may have died, left or turned antagonist since setup(), so check the crew again
	var/list/still_here = get_department_members(department["jobs"])
	citizens &= still_here
	if(length(citizens) < 2)
		department = null // start() runs before announce() on the same tick, so this also skips the announcement
		return kill()
	var/datum/team/nation/nation = new
	nation.name = nation_name
	nation.member_name = "obywatel"
	var/datum/objective/aquila_independence/objective = new
	objective.team = nation
	objective.explanation_text = "Brońcie niepodległości [nation_name]. Nie wracajcie do pracy, dopóki dowództwo nie zgodzi się na żądanie: [demand]."
	nation.objectives += objective
	for(var/datum/mind/M as anything in citizens)
		var/datum/antagonist/separatist/aquila_striker/striker = new
		striker.reason = reason
		if(!M.add_antag_datum(striker, nation) || !M.current)
			continue
		M.current.log_message("joined the strike of [nation_name] ([department["name"]]).", LOG_ATTACK, color = "red")
	message_admins("Department Independence: [length(citizens)] crew of the [department["name"]] department formed [nation_name] over \"[reason]\".")
	log_game("Department Independence: [length(citizens)] crew of the [department["name"]] department formed [nation_name].")

/datum/antagonist/separatist/aquila_striker
	/// Why the union board called the strike, shown in the greeting
	var/reason

/datum/antagonist/separatist/aquila_striker/on_gain()
	if(nation)
		objectives |= nation.objectives
	return ..()

/datum/antagonist/separatist/aquila_striker/greet()
	to_chat(owner, "<span class='userdanger'>Zarząd twojego związku zawodowego ogłosił strajk generalny, ponieważ [reason]!</span>")
	to_chat(owner, "<B>Twój dział proklamował niepodległość. Jesteś obywatelem państwa [nation.name]! Razem z towarzyszami broń jego suwerenności i nie wracaj do pracy, dopóki dowództwo nie spełni żądań.</B>")
	owner.announce_objectives()

/// The strike holds as long as at least one citizen is still alive at round end
/datum/objective/aquila_independence
	name = "niepodległość działu"

/datum/objective/aquila_independence/check_completion()
	for(var/datum/mind/M as anything in team?.members)
		if(M.current && M.current.stat != DEAD)
			return TRUE
	return FALSE
