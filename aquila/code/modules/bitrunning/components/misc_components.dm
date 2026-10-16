#define BASE_HEAL 4

/// Leczy osobę w netpodzie i trzyma ją w stazie
/datum/component/netpod_healing

/datum/component/netpod_healing/Initialize(obj/machinery/netpod/pod)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(pod, list(COMSIG_MACHINERY_BROKEN, COMSIG_PARENT_QDELETING, COMSIG_BITRUNNER_NETPOD_OPENED), PROC_REF(on_remove))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_remove))

	var/mob/living/carbon/player = parent
	player.apply_status_effect(STATUS_EFFECT_STASIS, -1, TRUE)

	START_PROCESSING(SSmachines, src)

/datum/component/netpod_healing/Destroy(force)
	STOP_PROCESSING(SSmachines, src)

	var/mob/living/carbon/player = parent
	player?.remove_status_effect(STATUS_EFFECT_STASIS)

	return ..()

/datum/component/netpod_healing/process(delta_time)
	var/mob/living/carbon/owner = parent
	if(isnull(owner))
		qdel(src)
		return

	owner.adjustBruteLoss(-BASE_HEAL * delta_time, FALSE)
	owner.adjustFireLoss(-BASE_HEAL * delta_time, FALSE)
	owner.adjustToxLoss(-BASE_HEAL * delta_time, FALSE, TRUE)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume + BASE_HEAL * delta_time, BLOOD_VOLUME_NORMAL)
	owner.updatehealth()

/// Deletes itself when the machine was opened
/datum/component/netpod_healing/proc/on_remove()
	SIGNAL_HANDLER

	qdel(src)

#undef BASE_HEAL


/// Handles all special considerations for "virtual entities" such as bitrunning ghost roles or digital anomaly antagonists.
/datum/component/virtual_entity
	/// The cooldown for balloon alerts, so the player isn't spammed while trying to enter a restricted area.
	COOLDOWN_DECLARE(OOB_cooldown)

/datum/component/virtual_entity/Initialize(obj/machinery/quantum_server)
	if(quantum_server.obj_flags & EMAGGED)
		jailbreak_mobs()

	if(quantum_server.obj_flags & EMAGGED)
		return
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_parent_pre_move))
	RegisterSignal(quantum_server, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emagged))


/// Self-destructs the component, allowing free-roam by all entities with this restriction.
/datum/component/virtual_entity/proc/jailbreak_mobs()
	to_chat(parent, span_boldwarning("Przez chwilę przechodzi cię dreszcz i ogarnia jasność, jakiej nigdy wcześniej nie czułeś."))
	to_chat(parent, span_notice("Możesz pójść <i>dokądkolwiek</i>, zrobić <i>cokolwiek</i>! Możesz od razu opuścić tę symulację!"))
	to_chat(parent, span_danger("Uważaj jednak: splątanie kwantowe zakłóci poprzednie życia."))
	to_chat(parent, span_notice("Masz tylko jedną szansę, żeby się wyrwać, i nie ma odwrotu."))


/// Remove any restrictions AFTER the mob has spawned
/datum/component/virtual_entity/proc/on_emagged(datum/source)
	SIGNAL_HANDLER

	jailbreak_mobs()
	qdel(src)


/// Prevents entry to a certain area if it has flags preventing virtual entities from entering.
/datum/component/virtual_entity/proc/on_parent_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER

	var/area/location_area = get_area(new_location)
	if(!location_area)
		return

	if(location_area.virtual_area_flags & VIRTUAL_SAFE_AREA)
		if(COOLDOWN_FINISHED(src, OOB_cooldown))
			source.balloon_alert(source, "poza obszarem!")
			COOLDOWN_START(src, OOB_cooldown, 2 SECONDS)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE


/// Glitch, który przedostał się na stację
/datum/component/glitch
	/// Ref of the spawning forge
	var/datum/weakref/forge_ref

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server, obj/machinery/byteforge/forge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	var/health_boost = 0

	if(forge)
		RegisterSignal(forge, COMSIG_BYTEFORGE_POWER_RESTORED, PROC_REF(on_forge_power_restored))
		RegisterSignal(forge, list(COMSIG_MACHINERY_BROKEN, COMSIG_BYTEFORGE_POWER_LOST), PROC_REF(on_forge_broken))
		forge_ref = WEAKREF(forge)
		server.remove_threat(owner) // so the server doesn't dust us
		health_boost = ROUND_UP(server.threat * 0.2)

	owner.faction = list(ROLE_GLITCH)

	owner.maxHealth = clamp(owner.maxHealth + health_boost, 200, 500)
	owner.fully_heal()
	owner.create_digital_aura()

/datum/component/glitch/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)

/// We don't want digital entities just lingering around as corpses.
/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("Czujesz dziwne mrowienie..."))

	var/obj/machinery/byteforge/forge = forge_ref?.resolve()
	forge?.setup_particles()

	animate(owner, alpha = 0, time = 3 SECONDS)
	QDEL_IN(owner, 3 SECONDS)

/// If the forge breaks, we take a massive slowdown
/datum/component/glitch/proc/on_forge_broken(datum/source)
	SIGNAL_HANDLER

	var/mob/living/player = parent
	var/atom/movable/screen/alert/bitrunning/alert = player.throw_alert(ALERT_BITRUNNER_GLITCH, /atom/movable/screen/alert/bitrunning, new_master = source)
	if(alert)
		alert.name = "Źródło zniszczone"
		alert.desc = "Nasz byteforge został zniszczony."

	if(!iscarbon(parent)) // Too powerful!
		return

	player.add_movespeed_modifier("glitch_slowdown", TRUE, 100, override = TRUE, multiplicative_slowdown = 1.5)
	to_chat(player, span_danger("Twoje ciało staje się ociężałe..."))

/// Power restored
/datum/component/glitch/proc/on_forge_power_restored(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/byteforge/forge = source
	forge.setup_particles(angry = TRUE)

	if(!iscarbon(parent))
		return

	var/mob/living/player = parent
	player.clear_alert(ALERT_BITRUNNER_GLITCH)
	player.remove_movespeed_modifier("glitch_slowdown")



/// Makes a mob friendly with most NPC factions
/datum/component/npc_friendly
	/// The list of factions to add to the player
	var/static/list/npc_factions = list(
		"boss",
		"carp",
		"hivebot",
		"hostile",
		"mimic",
		"pirate",
		"spiders",
		"stickman",
		ROLE_ALIEN,
		ROLE_GLITCH,
		"Syndicate",
	)
	/// List of factions previously held by the player
	var/list/previous_factions

/datum/component/npc_friendly/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/player = parent

	previous_factions = player.faction.Copy()
	player.faction |= npc_factions

/datum/component/npc_friendly/Destroy(force)
	var/mob/living/player = parent
	if(!QDELETED(player))
		player.faction = previous_factions
	return ..()


/**
 * Ciało tymczasowe (tg /datum/component/temporary_body).
 * Gdy to ciało umrze albo zniknie, gracz wraca do poprzedniego ciała.
 */
/datum/component/temporary_body
	/// Umysł, który wróci do starego ciała
	var/datum/weakref/old_mind_ref
	/// Stare ciało
	var/datum/weakref/old_body_ref
	/// Czy wracać po śmierci tymczasowego ciała
	var/return_on_death = FALSE

/datum/component/temporary_body/Initialize(datum/mind/old_mind, mob/living/old_body, return_on_death = FALSE)
	if(!isliving(parent) || isnull(old_mind))
		return COMPONENT_INCOMPATIBLE

	old_mind_ref = WEAKREF(old_mind)
	if(isliving(old_body))
		old_body_ref = WEAKREF(old_body)
		ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	src.return_on_death = return_on_death
	ADD_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_destroy))
	if(return_on_death)
		RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_parent_destroy))

/datum/component/temporary_body/Destroy(force)
	var/mob/living/old_body = old_body_ref?.resolve()
	if(old_body)
		REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))
	if(!QDELETED(parent))
		REMOVE_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	return ..()

/datum/component/temporary_body/proc/on_parent_destroy()
	SIGNAL_HANDLER

	var/datum/mind/old_mind = old_mind_ref?.resolve()
	var/mob/living/old_body = old_body_ref?.resolve()
	var/mob/living/living_parent = parent

	if(living_parent.key)
		var/mob/dead/observer/ghost = living_parent.ghostize(FALSE)
		if(istype(ghost) && old_mind && old_body && !QDELETED(old_body))
			ghost.mind = old_mind
			old_mind.current = old_body
			ghost.can_reenter_corpse = TRUE
			if(old_body.stat != DEAD)
				old_mind.transfer_to(old_body, TRUE)

	qdel(src)


/**
 * Kamera noszona przez moba (tg simple_bodycam). Ustawia wbudowaną kamerę na danej sieci.
 */
/datum/component/simple_bodycam
	/// The camera itself
	var/obj/machinery/camera/bodycam
	/// Kiedy ostatnio aktualizowaliśmy sieć kamer
	var/last_update = 0

/datum/component/simple_bodycam/Initialize(camera_name = "kamera osobista", c_tag = "Kamera", network = "ss13")
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	bodycam = new(parent)
	bodycam.name = camera_name
	bodycam.c_tag = c_tag
	bodycam.network = list(network)
	bodycam.internal_light = FALSE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/simple_bodycam/Destroy(force)
	QDEL_NULL(bodycam)
	return ..()

/datum/component/simple_bodycam/proc/on_moved(datum/source)
	SIGNAL_HANDLER

	if(world.time < last_update + 1 SECONDS)
		return
	last_update = world.time
	GLOB.cameranet.updatePortableCamera(bodycam)
