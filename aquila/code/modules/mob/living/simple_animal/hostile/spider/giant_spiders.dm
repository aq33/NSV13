// AQUILA - pająki olbrzymie (tg: giant_spiders.dm)

/**
 * # Pająk olbrzymi
 *
 * Powstaje z eventu, botaniki albo ksenobiologii. Podstawowy typ to strażnik:
 * wolny, ale wytrzymały i mocno gryzie. Każdy pająk snuje sieci.
 */
/mob/living/simple_animal/hostile/spider/giant
	name = "pająk olbrzymi"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma głęboko czerwone oczy."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speed = 5
	maxHealth = 125
	health = 125
	obj_damage = 30
	melee_damage = 22
	gold_core_spawnable = HOSTILE_SPAWN
	bite_pierces_thick = TRUE

/**
 * ### Pająk zasadzkowy
 * Wolniejszy i silniejszy, potrafi wtopić się w sieć i czaić na ofiarę.
 */
/mob/living/simple_animal/hostile/spider/giant/ambush
	name = "pająk zasadzkowy"
	desc = "Włochaty i biały, aż ciarki przechodzą. Ten ma iskrzące różowe oczy."
	icon_state = "ambush"
	icon_living = "ambush"
	icon_dead = "ambush_dead"
	gender = FEMALE
	maxHealth = 125
	health = 125
	obj_damage = 45
	melee_damage = 27
	speed = 5
	player_speed_modifier = -3.1
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_SLOW
	menu_description = "Wolny pająk z ponadprzeciętnym zdrowiem i obrażeniami, potrafi wtopić się w otoczenie."
	innate_actions = list(/datum/action/cooldown/spider/sneak)

/**
 * ### Pająk strażnik
 * Odpowiednik dawnego pająka olbrzymiego. Wytrzymały, potrafi zrzucić pajęczą kukłę.
 */
/mob/living/simple_animal/hostile/spider/giant/guard
	name = "pająk strażnik"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma głęboko czerwone oczy."
	gender = FEMALE
	maxHealth = 160
	health = 160
	melee_damage = 22
	obj_damage = 45
	speed = 5
	player_speed_modifier = -4
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	menu_description = "Wytrzymały i silny, potrafi zrzucić pajęczą kukłę dla osłony."
	innate_actions = list(/datum/action/cooldown/spider/web_effigy)

/**
 * ### Pająk łowca
 * Szybszy, wstrzykuje toksynę, ale ma mniej zdrowia i słabiej gryzie.
 */
/mob/living/simple_animal/hostile/spider/giant/hunter
	name = "pająk łowca"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma iskrzące fioletowe oczy."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 80
	health = 80
	melee_damage = 17
	poison_per_bite = 5
	speed = 3
	player_speed_modifier = -3.1
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_FAST
	menu_description = "Szybki pająk wstrzykujący toksynę, ale z mniejszym zdrowiem i obrażeniami."

/**
 * ### Pająk zwiadowca
 * Szybki, widzi istoty przez ściany i przekazuje meldunki gniazdu. Wchodzi do wentylacji.
 */
/mob/living/simple_animal/hostile/spider/giant/scout
	name = "pająk zwiadowca"
	desc = "Włochaty i niebieskoczarny, aż ciarki przechodzą. Ten ma iskrzące niebieskie oczy."
	icon_state = "scout"
	icon_living = "scout"
	icon_dead = "scout_dead"
	maxHealth = 65
	health = 65
	obj_damage = 10
	melee_damage = 7
	poison_per_bite = 10
	poison_type = /datum/reagent/peaceborg/confuse
	speed = 2.8
	player_speed_modifier = -3.1
	sight = SEE_SELF | SEE_MOBS
	ventcrawler = VENTCRAWLER_ALWAYS
	menu_description = "Szybki pająk, który widzi wrogów przez ściany, wysyła meldunki do gniazda i chodzi wentylacją."
	innate_actions = list(/datum/action/cooldown/spider/command/communication)

/**
 * ### Pająk pielęgniarz
 * Wsparcie: snuje sieci cztery razy szybciej i opatruje rany innych pająków (sam siebie nie wyleczy).
 */
/mob/living/simple_animal/hostile/spider/giant/nurse
	name = "pająk pielęgniarz"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma jaskrawozielone oczy."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8, /obj/item/food/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage = 7
	speed = 4
	player_speed_modifier = -3.1
	web_speed = 0.25
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	heal_others_amount = 10
	heal_others_time = 2.5 SECONDS
	menu_description = "Pająk o przeciętnej szybkości, który leczy inne pająki (bez trybu walki kliknij rannego) i bardzo szybko snuje sieci. Słabo gryzie i ma mało zdrowia."

/mob/living/simple_animal/hostile/spider/giant/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/**
 * ### Pająk splątujący
 * Wsparcie: szybko snuje sieci i ma cały arsenał pułapek. Sam leczy swoje rany.
 */
/mob/living/simple_animal/hostile/spider/giant/tangle
	name = "pająk splątujący"
	desc = "Włochaty i brązowy, aż ciarki przechodzą. Ten ma przygaszone brązowe oczy."
	icon_state = "tangle"
	icon_living = "tangle"
	icon_dead = "tangle_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8, /obj/item/food/spidereggs = 4)
	maxHealth = 55
	health = 55
	melee_damage = 1
	poison_per_bite = 2.5
	poison_type = /datum/reagent/toxin/acid
	obj_damage = 40
	web_speed = 0.25
	speed = 4
	player_speed_modifier = -3.1
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	menu_description = "Pająk o przeciętnej szybkości z samoleczeniem i wieloma rodzajami sieci do umacniania gniazda. Prawie nie zadaje obrażeń i ma mało zdrowia."
	innate_actions = list(
		/datum/action/cooldown/spider/lay_web/solid_web,
		/datum/action/cooldown/spider/lay_web/sticky_web,
		/datum/action/cooldown/spider/lay_web/web_passage,
		/datum/action/cooldown/spider/lay_web/web_spikes,
	)

/mob/living/simple_animal/hostile/spider/giant/tangle/Initialize(mapload)
	. = ..()
	mend_action = new(src, 15, 3 SECONDS)
	mend_action.Grant(src)

/**
 * ### Pająk czołg
 * Stworzony do przyjmowania ciosów. Leczy się sam i snuje lustrzane ekrany.
 */
/mob/living/simple_animal/hostile/spider/giant/tank
	name = "pająk czołg"
	desc = "Włochaty i fioletowy z białym wierzchem, aż ciarki przechodzą. Ten ma jasnożółte oczy."
	icon_state = "tank"
	icon_living = "tank"
	icon_dead = "tank_dead"
	maxHealth = 500
	health = 500
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage = 5
	obj_damage = 15
	speed = 5
	player_speed_modifier = -4
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_BELOW_AVERAGE
	menu_description = "Niezwykle wytrzymały, ale prawie nie zadaje obrażeń. Leczy się sam i snuje lustrzane ekrany."
	innate_actions = list(
		/datum/action/cooldown/spider/lay_web/web_reflector,
		/datum/action/cooldown/spider/lay_web/web_passage,
	)

/mob/living/simple_animal/hostile/spider/giant/tank/Initialize(mapload)
	. = ..()
	mend_action = new(src, 50, 5 SECONDS)
	mend_action.Grant(src)

/**
 * ### Pająk wyłamywacz
 * Specjalista od wdzierania się na statek: rozrywa ściany i kończyny, ostrzega gniazdo.
 */
/mob/living/simple_animal/hostile/spider/giant/breacher
	name = "pająk wyłamywacz"
	desc = "Włochaty i jasnobrązowy z ciemnobrązowymi i czerwonymi znaczeniami, aż ciarki przechodzą. Ten ma jaskrawoczerwone oczy."
	icon_state = "breacher"
	icon_living = "breacher"
	icon_dead = "breacher_dead"
	maxHealth = 120
	health = 120
	melee_damage = 7
	unsuitable_atmos_damage = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 75
	maxbodytemp = 700
	obj_damage = 60
	web_speed = 0.25
	speed = 5
	player_speed_modifier = -4
	sight = SEE_TURFS
	limb_destroyer = TRUE
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_BELOW_AVERAGE
	menu_description = "Rozrywa ściany i kończyny, wytrzymuje próżnię i ostrzega gniazdo."
	innate_actions = list(
		/datum/action/cooldown/spider/lay_web/solid_web,
		/datum/action/cooldown/spider/command/warning,
	)
	/// Ile trwa rozerwanie zwykłej ściany
	var/tear_time = 2 SECONDS

/// Rozrywanie ścian (tg: /datum/element/wall_tearer). Kończyny odgryza wbudowane limb_destroyer.
/mob/living/simple_animal/hostile/spider/giant/breacher/AttackingTarget()
	if(istype(target, /turf/closed/wall) && !istype(target, /turf/closed/indestructible))
		if(busy)
			balloon_alert(src, "zajęty!")
			return FALSE
		INVOKE_ASYNC(src, PROC_REF(tear_wall), target)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/spider/giant/breacher/proc/tear_wall(turf/closed/wall/wall)
	var/rip_time = istype(wall, /turf/closed/wall/r_wall) ? tear_time * 2 : tear_time
	visible_message(span_warning("[src] zaczyna rozrywać [wall]!"))
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	busy = TRUE
	var/success = do_after(src, rip_time, target = wall)
	busy = FALSE
	if(!success || !istype(wall) || QDELETED(src))
		return
	do_attack_animation(wall)
	playsound(wall, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	wall.dismantle_wall(TRUE)

/**
 * ### Tarantula
 * Czysta siła i wytrzymałość. Bardzo wolna poza siecią, ale potrafi szarżować.
 */
/mob/living/simple_animal/hostile/spider/giant/tarantula
	name = "tarantula"
	desc = "Włochata i czarna, aż ciarki przechodzą. Ta ma otchłannie czerwone oczy."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 400
	health = 400
	melee_damage = 37
	obj_damage = 100
	speed = 6
	player_speed_modifier = -5.5
	mob_size = MOB_SIZE_LARGE
	status_flags = NONE
	gold_core_spawnable = NO_SPAWN
	web_speed = 0.7
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_SLOW
	menu_description = "Ogromne zdrowie i obrażenia, ale bardzo wolna poza siecią. Po krótkim przygotowaniu szarżuje na cel."
	innate_actions = list(
		/datum/action/cooldown/spider/lay_web/solid_web,
		/datum/action/cooldown/spider/lay_web/web_passage,
	)
	/// Szarża, trzymana osobno, bo używa jej też prawy przycisk myszy
	var/datum/action/cooldown/spider/charge/charge

/mob/living/simple_animal/hostile/spider/giant/tarantula/Initialize(mapload)
	. = ..()
	charge = new(src)
	charge.Grant(src)

/mob/living/simple_animal/hostile/spider/giant/tarantula/Destroy()
	QDEL_NULL(charge)
	return ..()

/// Szarża po kliknięciu prawym przyciskiem na odległość
/mob/living/simple_animal/hostile/spider/giant/tarantula/ranged_secondary_attack(atom/atom_target, modifiers)
	if(charge?.IsAvailable() && !busy)
		charge.Activate(atom_target)

/**
 * ### Pająk żmija
 * Szybkość i jad. Wstrzykuje zabójczą toksynę, porusza się błyskawicznie, ale ma mało zdrowia.
 */
/mob/living/simple_animal/hostile/spider/giant/viper
	name = "pająk żmija"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma musujące fioletowe oczy."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 55
	health = 55
	melee_damage = 5
	poison_per_bite = 5
	poison_type = /datum/reagent/toxin/hunterspider/viper
	speed = 2
	player_speed_modifier = -2.5
	gold_core_spawnable = NO_SPAWN
	menu_description = "Zabójca o niezrównanej szybkości i bardzo groźnym jadzie, ale z małym zdrowiem i obrażeniami. Dobija osłabionych."
	innate_actions = list(/datum/action/cooldown/spider/defensive_mode)
	/// Poniżej jakiego procentu zdrowia ofiary zadajemy dodatkowe obrażenia
	var/bonus_damage_percentage = 20
	/// Ile dodatkowych obrażeń
	var/bonus_damage_amount = 15

/// Dobijanie osłabionych (tg: /datum/element/bonus_damage)
/mob/living/simple_animal/hostile/spider/giant/viper/AttackingTarget()
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/victim = target
	if(victim.stat == DEAD || !victim.maxHealth)
		return
	if((victim.health / victim.maxHealth) * 100 <= bonus_damage_percentage)
		victim.adjustBruteLoss(bonus_damage_amount)

/**
 * ### Pająk matka
 *
 * Serce pajęczej hordy i jedyna droga, by się rozrosła. Słabo walczy, ale w każdej chwili
 * składa jaja zwykłych pająków. Po wyssaniu ludzi składa jaja rzadkich pająków, w tym kolejnych matek.
 * Wydaje rozkazy wszystkim pająkom i ustala je swoim dzieciom.
 */
/mob/living/simple_animal/hostile/spider/giant/midwife
	name = "pająk matka"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma migotliwie zielone oczy. Może też chować gdzieś prawdziwy nóż."
	gender = FEMALE
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 250
	health = 250
	melee_damage = 12
	speed = 4
	player_speed_modifier = -3.1
	gold_core_spawnable = NO_SPAWN
	web_speed = 0.5
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	menu_description = "Królewski pająk od rozmnażania i dowodzenia, słabo gryzie."
	innate_actions = list(
		/datum/action/cooldown/spider/command,
		/datum/action/cooldown/spider/lay_eggs,
		/datum/action/cooldown/spider/lay_eggs/abnormal,
		/datum/action/cooldown/spider/lay_eggs/enriched,
		/datum/action/cooldown/spider/lay_web/solid_web,
		/datum/action/cooldown/spider/lay_web/sticky_web,
		/datum/action/cooldown/spider/lay_web/web_passage,
		/datum/action/cooldown/spider/lay_web/web_spikes,
		/datum/action/cooldown/spider/set_spider_directive,
		/datum/action/cooldown/spider/wrap,
	)

/**
 * ### Pająki lodowe
 * Odporne na temperaturę. Używane na mapach śnieżnych.
 */
/mob/living/simple_animal/hostile/spider/giant/ice
	name = "lodowy pająk olbrzymi"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN
	menu_description = "Wszechstronny lodowy pająk do walki na pierwszej linii. Odporny na temperaturę."

/mob/living/simple_animal/hostile/spider/giant/nurse/ice
	name = "lodowy pająk olbrzymi"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	menu_description = "Lodowy pająk wsparcia, który leczy pobratymców i szybko snuje sieci. Odporny na temperaturę."

/mob/living/simple_animal/hostile/spider/giant/hunter/ice
	name = "lodowy pająk olbrzymi"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)
	gold_core_spawnable = NO_SPAWN
	menu_description = "Szybki lodowy pająk wstrzykujący olej mrozu. Odporny na temperaturę."

/**
 * ### Wychudzone pająki
 * Słabsze wersje do opuszczonych miejsc, nie rozbijają otoczenia.
 */
/mob/living/simple_animal/hostile/spider/giant/hunter/scrawny
	name = "wychudzony pająk"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma iskrzące fioletowe oczy i wygląda nienaturalnie chudo i krucho."
	health = 60
	maxHealth = 60
	melee_damage = 7
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/spider/giant/tarantula/scrawny
	name = "wychudzona tarantula"
	desc = "Włochata i czarna, aż ciarki przechodzą. Ta ma otchłannie czerwone oczy i wygląda nienaturalnie chudo i krucho."
	health = 150
	maxHealth = 150
	melee_damage = 22
	environment_smash = ENVIRONMENT_SMASH_NONE

/mob/living/simple_animal/hostile/spider/giant/nurse/scrawny
	name = "wychudzony pająk pielęgniarz"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma jaskrawozielone oczy i wygląda nienaturalnie chudo i krucho."
	health = 30
	maxHealth = 30
	environment_smash = ENVIRONMENT_SMASH_NONE

/**
 * ### Pająk wodny
 * Forma pająka dla czarodzieja: szybkość i jad żmii, więcej zdrowia, chodzi wentylacją.
 */
/mob/living/simple_animal/hostile/spider/giant/viper/wizard
	name = "pająk wodny"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma musujące pomarańczowe oczy."
	icon_state = "water"
	icon_living = "water"
	icon_dead = "water_dead"
	web_speed = 0.4
	maxHealth = 80
	health = 80
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	ventcrawler = VENTCRAWLER_ALWAYS
	menu_description = "Silniejszy zabójca: niezrównana szybkość, sporo zdrowia i bardzo groźny jad, ale słabo gryzie. Chodzi wentylacją."
	innate_actions = list(
		/datum/action/cooldown/spider/defensive_mode,
		/datum/action/cooldown/spider/lay_web/sticky_web,
		/datum/action/cooldown/spider/lay_web/web_spikes,
	)
