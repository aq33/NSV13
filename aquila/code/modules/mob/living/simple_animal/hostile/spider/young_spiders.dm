// AQUILA - młode pająki (tg: young_spider.dm, young_spider_subtypes.dm)

/**
 * # Młody pająk
 *
 * Stadium pośrednie między pajączkiem a pająkiem olbrzymim.
 * Oddaje tylko wtedy, gdy ktoś go zaatakuje, i ucieka, gdy jest ranny.
 */
/mob/living/simple_animal/hostile/spider/growing/young
	name = "młody pająk"
	desc = "Włochaty i czarny, aż ciarki przechodzą. Ten ma głęboko czerwone oczy."
	icon_state = "young_guard"
	icon_living = "young_guard"
	icon_dead = "young_guard_dead"
	butcher_results = list(/obj/item/food/meat/slab/spider = 1)
	speed = 1
	maxHealth = 60
	health = 60
	obj_damage = 10
	melee_damage = 10
	player_speed_modifier = -1
	retaliate_only = TRUE
	flee_health_ratio = 0.5
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_FAST

/mob/living/simple_animal/hostile/spider/growing/young/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return // za słabe

/mob/living/simple_animal/hostile/spider/growing/young/guard
	grow_as = /mob/living/simple_animal/hostile/spider/giant/guard
	name = "młody pająk strażnik"
	desc = "Włochaty i brązowy, wygląda na bezbronnego. Ten ma iskrzące czerwone oczy."
	maxHealth = 70
	health = 70
	melee_damage = 12
	speed = 0.7
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE

/mob/living/simple_animal/hostile/spider/growing/young/ambush
	grow_as = /mob/living/simple_animal/hostile/spider/giant/ambush
	name = "młody pająk zasadzkowy"
	desc = "Włochaty i biały, wygląda na bezbronnego. Ten ma iskrzące różowe oczy."
	icon_state = "young_ambush"
	icon_living = "young_ambush"
	icon_dead = "young_ambush_dead"
	maxHealth = 55
	health = 55
	melee_damage = 15
	speed = 1
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_SLOW
	innate_actions = list(/datum/action/cooldown/spider/sneak)

/mob/living/simple_animal/hostile/spider/growing/young/scout
	grow_as = /mob/living/simple_animal/hostile/spider/giant/scout
	name = "młody pająk zwiadowca"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące niebieskie oczy."
	icon_state = "young_scout"
	icon_living = "young_scout"
	icon_dead = "young_scout_dead"
	maxHealth = 35
	health = 35
	melee_damage = 3
	speed = 0.5
	poison_per_bite = 4
	poison_type = /datum/reagent/peaceborg/confuse
	sight = SEE_SELF | SEE_MOBS
	ventcrawler = VENTCRAWLER_ALWAYS

/mob/living/simple_animal/hostile/spider/growing/young/hunter
	grow_as = /mob/living/simple_animal/hostile/spider/giant/hunter
	name = "młody pająk łowca"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące fioletowe oczy."
	icon_state = "young_hunter"
	icon_living = "young_hunter"
	icon_dead = "young_hunter_dead"
	maxHealth = 45
	health = 45
	melee_damage = 10
	speed = 0.5
	poison_per_bite = 2

/mob/living/simple_animal/hostile/spider/growing/young/nurse
	grow_as = /mob/living/simple_animal/hostile/spider/giant/nurse
	name = "młody pająk pielęgniarz"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące zielone oczy."
	icon_state = "young_nurse"
	icon_living = "young_nurse"
	icon_dead = "young_nurse_dead"
	maxHealth = 25
	health = 25
	melee_damage = 3
	speed = 0.7
	web_speed = 0.5
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE
	heal_others_amount = 15
	heal_others_time = 2.5 SECONDS

/mob/living/simple_animal/hostile/spider/growing/young/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/spider/growing/young/tangle
	grow_as = /mob/living/simple_animal/hostile/spider/giant/tangle
	name = "młody pająk splątujący"
	desc = "Włochaty i brązowy, wygląda na bezbronnego. Ten ma przygaszone brązowe oczy."
	icon_state = "young_tangle"
	icon_living = "young_tangle"
	icon_dead = "young_tangle_dead"
	maxHealth = 30
	health = 30
	melee_damage = 1
	speed = 0.7
	web_speed = 0.25
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	poison_per_bite = 2
	poison_type = /datum/reagent/toxin/acid
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE

/mob/living/simple_animal/hostile/spider/growing/young/tangle/Initialize(mapload)
	. = ..()
	mend_action = new(src, 10, 3 SECONDS)
	mend_action.Grant(src)

/mob/living/simple_animal/hostile/spider/growing/young/tank
	grow_as = /mob/living/simple_animal/hostile/spider/giant/tank
	name = "młody pająk czołg"
	desc = "Włochaty i fioletowy, wygląda na bezbronnego. Ten ma przygaszone żółte oczy."
	icon_state = "young_tank"
	icon_living = "young_tank"
	icon_dead = "young_dead"
	maxHealth = 50
	health = 50
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage = 12
	speed = 1
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_BELOW_AVERAGE

/mob/living/simple_animal/hostile/spider/growing/young/tank/Initialize(mapload)
	. = ..()
	mend_action = new(src, 5, 2 SECONDS)
	mend_action.Grant(src)

/mob/living/simple_animal/hostile/spider/growing/young/breacher
	grow_as = /mob/living/simple_animal/hostile/spider/giant/breacher
	name = "młody pająk wyłamywacz"
	desc = "Włochaty i beżowy, wygląda na bezbronnego. Ten ma przygaszone czerwone oczy."
	icon_state = "young_breacher"
	icon_living = "young_breacher"
	icon_dead = "young_breacher_dead"
	maxHealth = 60
	health = 60
	melee_damage = 7
	speed = 1
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_BELOW_AVERAGE

/mob/living/simple_animal/hostile/spider/growing/young/midwife
	grow_as = /mob/living/simple_animal/hostile/spider/giant/midwife
	name = "młoda pająk matka"
	desc = "Włochata i czarna, wygląda na bezbronną. Ta ma migotliwie zielone oczy. Może też chować gdzieś prawdziwy nóż."
	icon_state = "young_midwife"
	icon_living = "young_midwife"
	icon_dead = "young_midwife_dead"
	gender = FEMALE
	maxHealth = 100
	health = 100
	melee_damage = 7
	speed = 0.7
	web_speed = 0.5
	web_type = /datum/action/cooldown/spider/lay_web/sealer
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_AVERAGE

/mob/living/simple_animal/hostile/spider/growing/young/viper
	grow_as = /mob/living/simple_animal/hostile/spider/giant/viper
	name = "młody pająk żmija"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące purpurowe oczy."
	icon_state = "young_viper"
	icon_living = "young_viper"
	icon_dead = "young_viper_dead"
	maxHealth = 30
	health = 30
	melee_damage = 5
	speed = 0.2
	poison_type = /datum/reagent/toxin/hunterspider/viper
	poison_per_bite = 2

/mob/living/simple_animal/hostile/spider/growing/young/tarantula
	grow_as = /mob/living/simple_animal/hostile/spider/giant/tarantula
	name = "młoda tarantula"
	desc = "Włochata i czarna, wygląda na bezbronną. Ta ma otchłannie czerwone oczy."
	icon_state = "young_tarantula"
	icon_living = "young_tarantula"
	icon_dead = "young_tarantula_dead"
	maxHealth = 150
	health = 150
	melee_damage = 22
	speed = 1
	obj_damage = 40
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_SLOW
