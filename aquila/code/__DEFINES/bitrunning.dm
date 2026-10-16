// Bitrunning, port z tg (code/__DEFINES/bitrunning.dm + signals_bitrunning.dm)

#define BITRUNNER_COST_NONE 0
#define BITRUNNER_COST_LOW 1
#define BITRUNNER_COST_MEDIUM 2
#define BITRUNNER_COST_HIGH 3
#define BITRUNNER_COST_EXTREME 20

#define BITRUNNING_GRADE_NONE "None"
#define BITRUNNING_GRADE_D "D"
#define BITRUNNING_GRADE_C "C"
#define BITRUNNING_GRADE_B "B"
#define BITRUNNING_GRADE_A "A"
#define BITRUNNING_GRADE_S "S"

/// Yay you did it
#define BITRUNNER_REWARD_MIN 1
/// You faced some decent odds
#define BITRUNNER_REWARD_LOW 3
/// One of your teammates might've died
#define BITRUNNER_REWARD_MEDIUM 4
/// Heroic effort
#define BITRUNNER_REWARD_HIGH 5
/// For the priciest domains, free loot basically
#define BITRUNNER_REWARD_EXTREME 6

/// Blue in ui. Basically the only threat is rogue ghosts roles
#define BITRUNNER_DIFFICULTY_NONE 0
/// Yellow. Mobs are kinda dumb and largely avoidable
#define BITRUNNER_DIFFICULTY_LOW 1
/// Orange. Mobs will shoot at you or are pretty aggressive
#define BITRUNNER_DIFFICULTY_MEDIUM 2
/// Red with skull. I am trying to kill bitrunners.
#define BITRUNNER_DIFFICULTY_HIGH 3

/// Camera network bitrunner bodycams are on
#define BITRUNNER_CAMERA_NET "bitrunner"

/// Domain forbids external sources from loading items onto avatars
#define DOMAIN_FORBIDS_ITEMS (1<<0)
/// Domain forbids external sources from loading abilities onto avatars
#define DOMAIN_FORBIDS_ABILITIES (1<<1)
/// Block nohit bonus from applying
#define DOMAIN_NO_NOHIT_BONUS (1<<2)
/// Test domain, don't let it be loaded normally
#define DOMAIN_TEST_ONLY (1<<3)
/// AQUILA: domain needs ghost candidates or is otherwise unsuitable for the exile loop
#define DOMAIN_NO_EXILE (1<<4)

/// Combination flag for blocking anything from being loaded onto avatars by external sources
#define DOMAIN_FORBIDS_ALL (DOMAIN_FORBIDS_ITEMS|DOMAIN_FORBIDS_ABILITIES)

/// Something failed to load
#define BITRUNNER_GEAR_LOAD_FAILED (1<<0)
/// The domain restrictions blocked something from loading
#define BITRUNNER_GEAR_LOAD_BLOCKED (1<<1)

/// Money symbol for bitrunning points
#define MONEY_BITRUNNING_SYMBOL "np"

/// Order console categories
#define CATEGORY_BITRUNNING_FLAIR "Różne"
#define CATEGORY_BITRUNNING_TECH "Technika"
#define CATEGORY_BEPIS "BEPIS"

// Area mapping flags (tg area_flags_mapping)
/// This is a virtual/bitrunning area
#define VIRTUAL_AREA (1<<0)
/// Virtual entities can't enter it
#define VIRTUAL_SAFE_AREA (1<<1)

// Alerts
#define ALERT_BITRUNNER_CROWBAR "bitrunning_crowbar"
#define ALERT_BITRUNNER_COMPLETED "bitrunning_complete"
#define ALERT_BITRUNNER_INTEGRITY "bitrunning_integrity"
#define ALERT_BITRUNNER_SHUTDOWN "bitrunning_shutdown"
#define ALERT_BITRUNNER_RESET "bitrunning_reset"
#define ALERT_BITRUNNER_THREAT "bitrunning_threat"
#define ALERT_BITRUNNER_BREACH "bitrunning_breach"
#define ALERT_BITRUNNER_GLITCH "bitrunning_glitch"

// Roles
#define ROLE_GLITCH "Bitrunning Malfunction"
#define ROLE_CYBER_POLICE "Cyber Police"
#define ROLE_CYBER_TAC "Cyber Tac"
#define ROLE_NETGUARDIAN "NetGuardian Prime"
#define POLL_IGNORE_GLITCH "bitrunning_glitch"

// Traits
/// Mob is an avatar/temporary body, its real mind owner is somewhere else
#define TRAIT_TEMPORARY_BODY "temporary_body"
/// The mind of this body is temporarily somewhere else (bitrunning)
#define TRAIT_MIND_TEMPORARILY_GONE "temporary_mind_gone"
/// Mind can't be swapped
#define TRAIT_NO_MINDSWAP "no_mindswap"
/// AQUILA: mob is a digital exile, forever bound to the loop
#define TRAIT_DIGITAL_EXILE "digital_exile"

// Signals
/// from /atom/movable/screen/alert/bitrunning/qserver_domain_complete
#define COMSIG_BITRUNNER_ALERT_SEVER "bitrunner_alert_sever"
/// from /obj/machinery/netpod/sever_connection()
#define COMSIG_BITRUNNER_NETPOD_SEVER "bitrunner_netpod_sever"
/// from /obj/machinery/netpod/default_pry_open() : (mob/living/intruder)
#define COMSIG_BITRUNNER_CROWBAR_ALERT "bitrunner_crowbar"
/// from /obj/machinery/netpod/on_damage_taken()
#define COMSIG_BITRUNNER_NETPOD_INTEGRITY "bitrunner_netpod_damage"
/// from /obj/machinery/netpod/open_machine()
#define COMSIG_BITRUNNER_NETPOD_OPENED "bitrunner_netpod_opened"
/// from /obj/machinery/quantum_server/on_goal_turf_entered(): (atom/entered, reward_points)
#define COMSIG_BITRUNNER_DOMAIN_COMPLETE "bitrunner_complete"
/// from /obj/machinery/quantum_server/generate_loot()
#define COMSIG_BITRUNNER_CACHE_SEVER "bitrunner_cache_sever"
/// from /obj/machinery/quantum_server/sever_connection()
#define COMSIG_BITRUNNER_QSRV_SEVER "bitrunner_qserver_sever"
/// from /obj/machinery/quantum_server/shutdown() : (mob/living)
#define COMSIG_BITRUNNER_SHUTDOWN_ALERT "bitrunner_shutdown"
/// from /obj/machinery/quantum_server/notify_threat()
#define COMSIG_BITRUNNER_THREAT_CREATED "bitrunner_threat"
/// from /obj/machinery/quantum_server/scrub_vdom()
#define COMSIG_BITRUNNER_DOMAIN_SCRUBBED "bitrunner_domain_scrubbed"
/// from /obj/machienry/quantum_server/station_spawn()
#define COMSIG_BITRUNNER_STATION_SPAWN "bitrunner_station_spawn"
/// from /obj/machinery/quantum_server/stock_gear(): (mob/living/carbon/human/avatar, domain_flags)
#define COMSIG_BITRUNNER_STOCKING_GEAR "bitrunner_stocking_gear"
/// from /obj/structure/hololadder/disconnect()
#define COMSIG_BITRUNNER_LADDER_SEVER "bitrunner_ladder_sever"
/// from /obj/effect/mob_spawn/human/virtual_domain/proc/artificial_spawn() : (mob/living/runner)
#define COMSIG_BITRUNNER_SPAWNED "bitrunner_spawned"
/// from /obj/effect/landmark/bitrunning/mob_segment/proc/spawn_mobs() : (list/mob/living)
#define COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED "bitrunner_mob_segment_spawned"
/// from /datum/lazy_template/proc/lazy_load() : (list/created_atoms)
#define COMSIG_LAZY_TEMPLATE_LOADED "lazy_template_loaded"
/// AQUILA: from /obj/effect/mob_spawn/human/virtual_domain/create() : (mob/living/spawned)
#define COMSIG_GHOSTROLE_SPAWNED "ghostrole_spawned"
/// AQUILA: from /obj/machinery/quantum_server/RefreshParts()
#define COMSIG_QSERVER_PARTS_REFRESHED "qserver_parts_refreshed"
/// AQUILA: from /obj/machinery/byteforge/on_set_is_operational()
#define COMSIG_BYTEFORGE_POWER_LOST "byteforge_power_lost"
#define COMSIG_BYTEFORGE_POWER_RESTORED "byteforge_power_restored"

/// Trait source
#define BITRUNNING_TRAIT "bitrunning"
