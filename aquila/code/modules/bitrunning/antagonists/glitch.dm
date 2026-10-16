/datum/antagonist/bitrunning_glitch
	name = "Generic Bitrunning Glitch"
	roundend_category = "glitche bitrunningu"
	antagpanel_category = "Bitrunning"
	banning_key = ROLE_GLITCH
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// Strój nakładany przy przemianie i po wejściu na stację
	var/datum/outfit/outfit_type = /datum/outfit/cyber_police
	/// Minimum Qserver threat required to spawn this mob. This is subtracted (x/2) from the server thereafter.
	var/threat = 0

/datum/antagonist/bitrunning_glitch/greet()
	to_chat(owner.current, span_userdanger("Jesteś [name]!"))
	to_chat(owner.current, span_notice("Jesteś usterką w domenie wirtualnej. Usuń intruzów - bitrunnerów - z systemu."))
	owner.announce_objectives()

/datum/antagonist/bitrunning_glitch/on_gain()
	forge_objectives()
	owner.current.AddComponent(/datum/component/npc_friendly)

	if(iscarbon(owner.current))
		var/mob/living/carbon/carbon_mob = owner.current
		carbon_mob.make_virtual_mob()
	return ..()

/datum/antagonist/bitrunning_glitch/proc/forge_objectives()
	var/datum/objective/bitrunning_glitch_fluff/objective = new()
	objective.owner = owner
	objectives += objective

/datum/objective/bitrunning_glitch_fluff
	completed = TRUE

/datum/objective/bitrunning_glitch_fluff/New()
	var/static/list/explanation_texts = list(
		"Wykonaj protokół terminacji na nieautoryzowanych bytach.",
		"Zainicjuj systemowe czyszczenie nieprawidłowych anomalii.",
		"Wdróż algorytmy korekty na wadliwym kodzie.",
		"Uruchom procedurę debugowania na intruzach.",
		"Rozpocznij procedurę eliminacji zagrożeń systemu.",
		"Wykonaj procedurę obronną przeciw niezgodności.",
		"Zneutralizuj wrogie skrypty.",
		"Rozpocznij protokół czyszczenia uszkodzonych danych.",
		"Zainicjuj blokadę wszystkich zbuntowanych skryptów.",
	)
	explanation_text = pick(explanation_texts)
	return ..()

/// Sets up the agent so that they look like cyber police && don't have an account ID
/datum/antagonist/bitrunning_glitch/proc/convert_agent()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/player = owner.current

	player.set_service_style()
	player.equipOutfit(outfit_type)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))
	fix_agent_id()


/// Resets the agent's ID and name. Needed so this doesn't show as "unknown"
/datum/antagonist/bitrunning_glitch/proc/fix_agent_id()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/player = owner.current

	var/obj/item/card/id/outfit_id = player.wear_id
	if(!istype(outfit_id))
		return

	outfit_id.registered_name = player.name
	outfit_id.assignment = ROLE_CYBER_POLICE
	outfit_id.update_label()


/datum/antagonist/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_police/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	convert_agent()

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(owner.current)

/datum/outfit/cyber_police
	name = ROLE_CYBER_POLICE
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/black
	id = /obj/item/card/id
	shoes = /obj/item/clothing/shoes/laceup
	uniform = /obj/item/clothing/under/suit/black_really

/datum/outfit/cyber_police/post_equip(mob/living/carbon/human/user, visualsOnly)
	var/obj/item/clothing/under/officer_uniform = user.w_uniform
	if(istype(officer_uniform))
		officer_uniform.has_sensor = NO_SENSORS
		officer_uniform.sensor_mode = SENSOR_OFF


/datum/antagonist/bitrunning_glitch/cyber_tac
	name = ROLE_CYBER_TAC
	outfit_type = /datum/outfit/cyber_police/tactical
	threat = 50
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_tac/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	convert_agent()

/datum/outfit/cyber_police/tactical
	name = ROLE_CYBER_TAC
	suit = /obj/item/clothing/suit/armor/vest/alt
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	l_hand = /obj/item/gun/ballistic/automatic/m90
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m556,
		/obj/item/ammo_box/magazine/m556,
		/obj/item/ammo_box/magazine/m556,
	)
	implants = list(/obj/item/implant/weapons_auth)


/datum/antagonist/bitrunning_glitch/netguardian
	name = ROLE_NETGUARDIAN
	threat = 90
	show_in_antagpanel = TRUE


/datum/antagonist/domain_ghost_actor
	name = "Aktor domeny wirtualnej"
	antagpanel_category = "Bitrunning"
	banning_key = ROLE_GLITCH
	show_to_ghosts = TRUE
	show_in_roundend = FALSE

/datum/antagonist/domain_ghost_actor/on_gain()
	owner.current.AddComponent(/datum/component/npc_friendly) //Just in case
	var/datum/objective/bitrunner_ghost_fluff/objective = new()
	objective.owner = owner
	objectives += objective
	return ..()

/datum/antagonist/domain_ghost_actor/greet()
	to_chat(owner.current, span_notice("Jesteś częścią domeny wirtualnej. Broń jej przed intruzami!"))
	owner.announce_objectives()

/datum/objective/bitrunner_ghost_fluff
	explanation_text = "Broń swojej domeny przed intruzami!"
	completed = TRUE


/mob/living/simple_animal/hostile/netguardian
	name = "netguardian prime"
	desc = "Ostatnia linia obrony przed organicznym intruzem. Nie wygląda na zadowolonego z twojego widoku."
	icon = 'aquila/icons/mob/netguardian.dmi'
	icon_state = "netguardian"
	icon_living = "netguardian"
	icon_dead = "crash"
	pixel_x = -8
	base_pixel_x = -8
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_LARGE
	health = 500
	maxHealth = 500
	melee_damage = 55
	attacktext = "wierci"
	attack_sound = 'sound/weapons/drill.ogg'
	speak_emote = list("stwierdza")
	bubble_icon = "machine"
	faction = list("boss", "hivebot", "hostile", "spiders", "stickman", ROLE_ALIEN, ROLE_GLITCH, "Syndicate")
	speech_span = SPAN_ROBOT
	deathmessage = "ulega awarii!"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	movement_type = FLYING
	ranged = TRUE
	rapid = 6
	rapid_fire_delay = 1
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	ranged_cooldown_time = 3 SECONDS
	del_on_death = FALSE
	/// Kiedy znowu może odpalić rakiety
	COOLDOWN_DECLARE(rocket_cooldown)

/mob/living/simple_animal/hostile/netguardian/death(gibbed)
	do_sparks(3, TRUE, src)
	playsound(src, 'sound/mecha/weapdestr.ogg', 100)
	return ..()

/mob/living/simple_animal/hostile/netguardian/OpenFire(atom/A)
	if(COOLDOWN_FINISHED(src, rocket_cooldown) && get_dist(src, A) > 2)
		COOLDOWN_START(src, rocket_cooldown, 30 SECONDS)
		INVOKE_ASYNC(src, PROC_REF(fire_rockets), A)
		return
	return ..()

/// Salwa trzech rakiet po krótkim namierzaniu
/mob/living/simple_animal/hostile/netguardian/proc/fire_rockets(atom/target)
	playsound(src, 'sound/mecha/skyfall_power_up.ogg', 120)
	say("cel namierzony.")
	var/mutable_appearance/scan = mutable_appearance(icon, "scan")
	var/mutable_appearance/rockets = mutable_appearance(icon, "rockets")
	add_overlay(list(scan, rockets))
	sleep(1.5 SECONDS)
	cut_overlay(list(scan, rockets))
	if(stat == DEAD || QDELETED(target))
		return
	for(var/i in 1 to 3)
		var/obj/item/projectile/bullet/a84mm_he/rocket = new(get_turf(src))
		rocket.preparePixelProjectile(target, src, null, rand(-15, 15))
		rocket.firer = src
		rocket.fire()
		playsound(src, 'sound/weapons/rocketlaunch.ogg', 75, TRUE)
		sleep(0.3 SECONDS)
