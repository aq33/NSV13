/datum/outfit/echolocator
	name = "Bitrunning Echolocator"
	glasses = /obj/item/clothing/glasses/blindfold
	ears = /obj/item/radio/headset
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/jacket/leather_trenchcoat
	id = /obj/item/card/id

/datum/outfit/echolocator/post_equip(mob/living/carbon/human/user, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	user.AddComponent(/datum/component/echolocation)


/datum/outfit/bitductor
	name = "Bitrunning Abductor"
	uniform = /obj/item/clothing/under/abductor
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots


/datum/outfit/beachbum_combat
	name = "Beachbum: Island Combat"
	id = /obj/item/card/id
	shoes = /obj/item/clothing/shoes/sandal
	uniform = /obj/item/clothing/under/pants/jeans
	/// Available ranged weapons
	var/list/ranged_weaps = list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/automatic/mini_uzi,
		/obj/item/gun/ballistic/automatic/pistol/deagle,
		/obj/item/gun/ballistic/rocketlauncher/unrestricted,
		/obj/item/gun/ballistic/automatic/ar,
	)
	/// Corresponding ammo
	var/list/corresponding_ammo = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/a762,
		/obj/item/ammo_box/magazine/uzim9mm,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/food/pizzaslice/meat, // more silly, less destructive
		/obj/item/ammo_box/magazine/m556,
	)

/datum/outfit/beachbum_combat/post_equip(mob/living/carbon/human/bum, visualsOnly)
	. = ..()
	if(visualsOnly)
		return

	var/choice = rand(1, length(ranged_weaps))
	var/weapon = ranged_weaps[choice]
	bum.put_in_active_hand(new weapon(bum.drop_location()))

	var/ammo = corresponding_ammo[choice]
	var/obj/item/ammo1 = new ammo(bum.drop_location())
	var/obj/item/ammo2 = new ammo(bum.drop_location())

	if(!bum.equip_to_slot_if_possible(ammo1, ITEM_SLOT_LPOCKET, disable_warning = TRUE))
		ammo1.forceMove(get_turf(bum))
	if(!bum.equip_to_slot_if_possible(ammo2, ITEM_SLOT_RPOCKET, disable_warning = TRUE))
		ammo2.forceMove(get_turf(bum))

	if(prob(50))
		bum.equip_to_slot_if_possible(new /obj/item/clothing/glasses/sunglasses(bum.drop_location()), ITEM_SLOT_EYES, disable_warning = TRUE)


/datum/round_event_control/bitrunning_glitch
	name = "Spawn Bitrunning Glitch"
	min_players = 1
	max_occurrences = 0
	typepath = /datum/round_event/ghost_role/bitrunning_glitch
	weight = 100
	/// List of servers on the station
	var/list/datum/weakref/active_servers = list()

/datum/round_event_control/bitrunning_glitch/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(!.)
		return .

	return validate_servers()

/// All servers currently running, has players in it, and map has valid mobs
/datum/round_event_control/bitrunning_glitch/proc/validate_servers()
	active_servers.Cut()
	for(var/obj/machinery/quantum_server/server in GLOB.machines)
		if(isnull(server.generated_domain))
			continue
		if(server.validate_mutation_candidates() && server.generated_domain.difficulty != BITRUNNER_DIFFICULTY_NONE)
			active_servers.Add(WEAKREF(server))

	return length(active_servers) > 0

/datum/round_event/ghost_role/bitrunning_glitch
	minimum_required = 1
	role_name = "Bitrunning Glitch"
	fakeable = FALSE
	/// Admin customization: What to spawn
	var/forced_role

/datum/round_event/ghost_role/bitrunning_glitch/spawn_role()
	var/datum/round_event_control/bitrunning_glitch/cyber_control = control
	if(!cyber_control.validate_servers())
		return WAITING_FOR_SOMETHING

	var/datum/weakref/server_ref = pick(cyber_control.active_servers)
	var/obj/machinery/quantum_server/unlucky_server = server_ref?.resolve()
	if(isnull(unlucky_server))
		return WAITING_FOR_SOMETHING

	cyber_control.active_servers.Cut()

	var/mob/spawned = unlucky_server.setup_glitch(forced_role)
	if(isnull(spawned))
		return WAITING_FOR_SOMETHING

	spawned_mobs += spawned

	return SUCCESSFUL_SPAWN
