// AQUILA - darkspawn: Pełzające cienie, iluzje i Potomek (port z Yogstation)

/mob/living/simple_animal/hostile/crawling_shadows
	name = "crawling shadows"
	real_name = "pełzające cienie"
	desc = "Bezkształtna masa nicości z przeszywającymi białymi oczami."
	icon = 'aquila/icons/mob/darkspawn/darkspawn.dmi'
	icon_state = "crawling_shadows"
	icon_living = "crawling_shadows"
	response_help = "niepokoi"
	response_disarm = "odpycha"
	response_harm = "macha na"
	speed = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB | PASSDOOR | PASSMACHINE
	maxHealth = 10
	health = 10
	melee_damage = 5
	attacktext = "napada"
	attack_sound = 'sound/magic/voidblink.ogg'
	speak_emote = list("szepcze")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	movement_type = FLYING
	pressure_resistance = INFINITY
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
	deathmessage = "drży, a jego postać gwałtownie się rozwiewa."
	deathsound = 'aquila/sound/darkspawn/devour_will_victim.ogg'
	stop_automated_movement = TRUE
	faction = list(ROLE_DARKSPAWN)
	/// Do upiornych dźwięków kroków
	var/move_count = 0
	/// Ciało darkspawna schowane w środku
	var/mob/living/darkspawn_mob
	var/returned = FALSE

/mob/living/simple_animal/hostile/crawling_shadows/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/darkspawn_light_eater)

/// Chowa ciało darkspawna do środka i przenosi umysł
/mob/living/simple_animal/hostile/crawling_shadows/proc/take_body()
	if(!darkspawn_mob?.mind)
		qdel(src)
		return
	darkspawn_mob.forceMove(src)
	darkspawn_mob.status_flags |= GODMODE
	darkspawn_mob.mind.transfer_to(src)
	update_light_speed()

/// Wraca do ciała darkspawna
/mob/living/simple_animal/hostile/crawling_shadows/proc/return_to_body()
	if(QDELETED(src))
		return
	if(!returned && darkspawn_mob && !QDELETED(darkspawn_mob))
		visible_message("<span class='warning'>[src] przybiera postać humanoidalną!</span>", "<span class='velvet'>Wracasz do swojej zwykłej postaci.</span>")
		playsound(src, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	release_body()
	qdel(src)

/// Wypuszcza ciało darkspawna i oddaje mu umysł
/mob/living/simple_animal/hostile/crawling_shadows/proc/release_body(damaged = FALSE)
	if(returned)
		return
	returned = TRUE
	if(!darkspawn_mob || QDELETED(darkspawn_mob))
		return
	darkspawn_mob.forceMove(get_turf(src))
	darkspawn_mob.status_flags &= ~GODMODE
	if(damaged) // obrażenia cieni wracają do ciała jako zmęczenie
		darkspawn_mob.adjustStaminaLoss(100)
	mind?.transfer_to(darkspawn_mob)

/mob/living/simple_animal/hostile/crawling_shadows/Destroy()
	release_body()
	darkspawn_mob = null
	return ..()

/mob/living/simple_animal/hostile/crawling_shadows/death(gibbed)
	release_body(TRUE)
	return ..()

/mob/living/simple_animal/hostile/crawling_shadows/Moved(atom/OldLoc, Dir)
	. = ..()
	update_light_speed()
	move_count++
	if(move_count >= 4)
		playsound(get_turf(src), pick('aquila/sound/darkspawn/crawling_shadows_walk_01.ogg', 'aquila/sound/darkspawn/crawling_shadows_walk_02.ogg', 'aquila/sound/darkspawn/crawling_shadows_walk_03.ogg'), 25, FALSE)
		move_count = 0

/// W ciemności szybszy i prawie niewidoczny, w świetle wolniejszy i widoczny
/mob/living/simple_animal/hostile/crawling_shadows/proc/update_light_speed()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/lums = T.get_lumcount()
	if(lums < DARKSPAWN_BRIGHT_LIGHT)
		set_varspeed(-1)
		alpha = max(alpha - ((DARKSPAWN_BRIGHT_LIGHT - lums) * 60), 0)
	else
		set_varspeed(0)
		alpha = min(alpha + (lums * 30), 255)

// Iluzje

/// Iluzja z Simulacrum
/mob/living/simple_animal/hostile/illusion/darkspawn
	desc = "Dziwnie migocze."
	maxHealth = 100
	health = 100
	pressure_resistance = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	speed = -1
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	attack_sound = 'sound/magic/voidblink.ogg'
	deathsound = 'aquila/sound/darkspawn/devour_will_victim.ogg'
	attacktext = "rozdziera"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	faction = list(ROLE_DARKSPAWN)

/mob/living/simple_animal/hostile/illusion/darkspawn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/darkspawn_light_eater)
	grant_language(/datum/language/darkspawn)

/mob/living/simple_animal/hostile/illusion/darkspawn/Life()
	. = ..()
	var/turf/T = get_turf(src)
	if(istype(T) && T.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		adjustHealth(-2)

/// Świadoma iluzja z Rozszczepienia jaźni
/mob/living/simple_animal/hostile/illusion/darkspawn/psyche

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/Copy_Parent(mob/living/original, life = 50, hp = 100, damage = 0, replicate = 0)
	. = ..()
	life_span = INFINITY // nie znika sama

/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/Login()
	. = ..()
	if(mind && !ispsyche(src))
		mind.add_antag_datum(/datum/antagonist/psyche)

// Potomek po Sakramencie

/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "cosmic progenitor"
	real_name = "kosmiczny potomek"
	desc = "..."
	icon = 'aquila/icons/mob/darkspawn/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health = 100000 // praktycznie nieśmiertelny, ale do zabicia
	maxHealth = 100000
	attacktext = "rozrywa"
	attack_sound = 'aquila/sound/darkspawn/progenitor_attack.ogg'
	friendly = "patrzy z góry na"
	speak_emote = list("ryczy")
	armour_penetration = 100
	melee_damage = 40
	obj_damage = INFINITY
	speed = 0
	pixel_x = -48
	pixel_y = -32
	base_pixel_x = -48
	base_pixel_y = -32
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	weather_immunities = list("lava", "ash")
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	movement_type = FLYING
	status_flags = NONE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	sight = SEE_MOBS | SEE_TURFS | SEE_OBJS
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	stop_automated_movement = TRUE
	faction = list(ROLE_DARKSPAWN)
	var/time_to_next_roar = 0
	var/roar_cooldown = 30 SECONDS
	/// Gracz widzi swój pełny sprite zamiast małego podglądu
	var/full_view = FALSE
	/// Losowe zdania przy ryku: majaczenia, poezja i biały szum
	var/list/roar_text = list(
		"Stoisz sparaliżowany w cieniu chłodu, który zstępuje z wysoka.",
		"Koniec czasów koniec czasów koniec czasów koniec czasów koniec czasów",
		"To w twoim umyśle, twoim umyśle? jego umyśle? czyim umyśle?",
		"Nogi odmawiają posłuszeństwa, gdy słyszysz krzyk nieznanego.",
		"Ledwie zajrzałeś w otchłań, a ona patrzy na ciebie z całą mocą.",
		"Nie mogę nie mogę nie mogę nie mogę nie mogę nie mogę nie mogę nie mogę",
		"Mózg zwraca się przeciw ciału, bo nic innego mu nie zostało.",
		"Nie masz siły się ruszyć, przygnieciony ciężarem swojego położenia.",
		"To tylko sen, na pewno, po prostu zasnąłem w pracy.",
		"AHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAH",
		"________________________________________________________________________________",
		"Wypuśćcie mnie. Wypuśćcie mnie. Wypuśćcie mnie. Wypuśćcie mnie. Wypuśćcie mnie.",
		"^$#%*^&($^%&($^^!#%#@~!$#@*)&)_*_*)&+(&+*@#$%!@#$!~@%&^%*^&)(&*_((_+*(!#$@!@!))",
		"Piękno końca cię zachwyca, ale tylko na chwilę.",
		"Znów żyć w błogiej niewiedzy, cóż to byłaby za ulga.",
		"Wrócili... kto?",
		"Nigdy nie odeszli. Niewidziani, prastarzy, pierwotni, bez końca, zawsze tu byli.",
		"Szczyt pychy: wierzyć, że ktoś nas tu zaprosił. Jesteśmy pasażerami na gapę.",
		"Kakofonia dźwięków napada na ciebie ze wszystkich stron.",
	)

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize(mapload, darkspawn_name, class_colour = COLOR_DARKSPAWN_PSI)
	. = ..()
	ADD_TRAIT(src, TRAIT_HOLY, "darkspawn_progenitor") // magia na niego nie działa
	AddComponent(/datum/component/darkspawn_light_eater)
	var/obj/item/radio/headset/silicon/ai/radio = new(src) // słyszy krzyki przez radio
	radio.wires.cut(WIRE_TX) // ale nie mówi przez nie
	var/datum/action/cooldown/spell/pointed/progenitor_curse/curse = new(src)
	curse.Grant(src)
	var/datum/action/innate/progenitor_view/view = new(src)
	view.Grant(src)
	// Ikony HUD-ów (np. znaczek antagonisty) dziedziczą przesunięcie wielkiego sprite'a, więc wracają nad kratkę moba
	for(var/hud_key in hud_list)
		var/image/hud_image = hud_list[hud_key]
		if(istype(hud_image))
			hud_image.pixel_x = -base_pixel_x
			hud_image.pixel_y = -base_pixel_y
	var/prefix = pick("Prastary", "Pustkowy", "Kosmiczny", "Cienisty", "Darkspawnowy", "Zasłonny")
	var/suffix = pick("Potomek", "Wzniesiony")
	if(rand(0, 10000) == 0)
		prefix = "Vxtrin"
	name = "[prefix] [suffix][darkspawn_name ? " [darkspawn_name]" : ""]"
	real_name = name
	alpha = 0
	animate(src, alpha = 255, time = 4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sound_to_playing_players), 'aquila/sound/darkspawn/sacrament_complete.ogg', 50), 4 SECONDS, TIMER_UNIQUE)
	time_to_next_roar = world.time + roar_cooldown // żeby ryk nie nakładał się na dźwięk przybycia

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'aquila/sound/darkspawn/pass_smash_door.ogg', 100, FALSE)
	return ..()

/// Gracz widzi siebie w małej wersji, żeby widzieć, gdzie jest
/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	. = ..()
	if(!full_view)
		show_small_self()
	time_to_next_roar = world.time + roar_cooldown

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/show_small_self()
	if(alternate_appearances?["smolgenitor"])
		return
	var/image/I = image(icon = 'aquila/icons/mob/darkspawn/smol_progenitor.dmi', icon_state = "smol_progenitor", loc = src)
	I.override = TRUE
	I.pixel_x = -base_pixel_x
	I.pixel_y = -base_pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)

/// Przełącza, czy gracz widzi siebie w małej wersji, czy jak wszyscy inni
/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/toggle_full_view()
	full_view = !full_view
	if(full_view)
		remove_alt_appearance("smolgenitor")
		to_chat(src, "<span class='velvet'>Widzisz siebie tak, jak widzą cię inni.</span>")
	else
		show_small_self()
		to_chat(src, "<span class='velvet'>Widzisz siebie w małej postaci.</span>")

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life()
	. = ..()
	if(time_to_next_roar + roar_cooldown <= world.time) // daje czas na ręczny ryk
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	. = ..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'aquila/sound/darkspawn/progenitor_roar.ogg', 70, TRUE)
	for(var/mob/M as anything in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'aquila/sound/darkspawn/progenitor_distant.ogg', 35, FALSE, falloff_exponent = 5)
		else if(isliving(M) && M != src && !is_team_darkspawn(M))
			var/mob/living/L = M
			to_chat(L, "<span class='boldannounce'>[pick(roar_text)]</span>")
			L.Immobilize(3 SECONDS)
	time_to_next_roar = world.time + roar_cooldown

/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act(severity, target)
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/gib(no_brain, no_organs, no_bodyparts)
	return

/// Przycisk: mały podgląd albo pełny sprite potomka
/datum/action/innate/progenitor_view
	name = "Pokaż pełną postać"
	desc = "Przełącza, czy widzisz siebie w małej postaci, czy tak jak wszyscy inni."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "panopticon"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"

/datum/action/innate/progenitor_view/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = owner
	if(!istype(progenitor))
		return FALSE
	progenitor.toggle_full_view()
	name = progenitor.full_view ? "Pokaż małą postać" : "Pokaż pełną postać"
	UpdateButtonIcon()
	return TRUE

/// Rozszarpanie umysłu: atak potomka
/datum/action/cooldown/spell/pointed/progenitor_curse
	name = "Rozszarpanie umysłu"
	desc = "Uderzasz potężną psioniczną nawałnicą w umysł celu."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "sacrament(old)"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	spell_requirements = NONE
	antimagic_flags = NONE
	cast_range = 10
	cooldown_time = 5 SECONDS

/datum/action/cooldown/spell/pointed/progenitor_curse/is_valid_target(atom/cast_on)
	if(!isliving(cast_on) || is_team_darkspawn(cast_on))
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/progenitor_curse/cast(atom/cast_on)
	. = ..()
	var/mob/living/target = cast_on
	var/zoinks = rand(1, 50) / 100 // to nawet nie jest moja ostateczna forma!
	owner.visible_message("<span class='warning'>Sigile [owner] rozbłyskują, gdy spogląda na [target]!</span>", "<span class='velvet'>Kierujesz [zoinks]% swojej psionicznej mocy w umysł [target]!</span>")
	target.apply_status_effect(/datum/status_effect/progenitor_curse)
