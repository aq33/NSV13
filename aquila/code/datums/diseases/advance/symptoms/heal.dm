// AQUILA - healing symptom additions
// Symbiotic Regeneration: aq33/NSV13#236, port of yogstation13/Yogstation#21027
// Teratoma monkey: aq33/NSV13#240, restores what BeeStation/BeeStation-Hornet#7421 removed

/datum/symptom/heal/symbiotic
	name = "Symbiotic Regeneration"
	desc = "The virus forms a symbiotic relationship with vital organs in the host's body, accelerating the host's natural healing processes while resting."
	stealth = -3
	resistance = -1
	stage_speed = 2
	transmission = -4
	level = 3
	severity = -1
	prefixes = list("Symbiotic ")
	passive_message = "<span class='notice'>You feel calm.</span>"
	threshold_desc = "<b>Stage Speed 9:</b> Shorter delay until healing starts.<br>\
					  <b>Resistance 9:</b> Increased rate of healing."
	/// When did the host last move on their own?
	var/last_moved = 0
	/// How long the host has to stand still before healing starts
	var/heal_delay = 3 SECONDS

/datum/symptom/heal/symbiotic/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.stage_rate >= 9)
		heal_delay = 1 SECONDS
	if(A.resistance >= 9)
		power = 3
	RegisterSignal(A.affected_mob, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_move))
	return TRUE

/datum/symptom/heal/symbiotic/End(datum/disease/advance/A)
	if(A.affected_mob)
		UnregisterSignal(A.affected_mob, COMSIG_MOB_CLIENT_PRE_MOVE)
	return ..()

/datum/symptom/heal/symbiotic/proc/on_move(mob/living/mover, new_loc)
	SIGNAL_HANDLER
	last_moved = world.time

/datum/symptom/heal/symbiotic/CanHeal(datum/disease/advance/A)
	if(last_moved + heal_delay > world.time)
		return FALSE
	return power

/datum/symptom/heal/symbiotic/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	if(!M.getBruteLoss() && !M.getFireLoss() && !M.getToxLoss())
		return FALSE
	var/heal_amount = actual_power * 0.5
	M.heal_bodypart_damage(heal_amount, heal_amount, required_status = BODYTYPE_ORGANIC)
	M.adjustToxLoss(-heal_amount, forced = TRUE) // forced, or toxin-loving species would be poisoned instead
	return TRUE

/// At most one living tumor ghost alert per this much time, from any source
#define TERATOMA_GHOST_NOTIFY_COOLDOWN (150 SECONDS)

// Ghost role spawner. Comes from overclocked Pituitary Disruption loot, xenobiology deliveries, mail and the Living Tumor event (events/teratoma.dm). For ling teratomas see changeling/teratoma.dm
/obj/effect/mob_spawn/teratomamonkey //spawning these is one of the downsides of overclocking the symptom
	name = "fleshy mass"
	desc = "A writhing mass of flesh."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_spore_temp"
	density = FALSE
	anchored = FALSE

	antagonist_type = /datum/antagonist/teratoma/hugbox
	mob_type = /mob/living/carbon/monkey/tumor
	mob_name = "a living tumor"
	death = FALSE
	roundstart = FALSE
	use_cooldown = TRUE
	show_flavour = FALSE	//it's handled by antag datum
	short_desc = "You are a living tumor. By all accounts you should not exist."
	flavour_text = "Spread misery and chaos upon the station."
	important_info = "Avoid killing unprovoked, kill only in self defense!"
	banType = ROLE_TERATOMA // also covers players banned from all antagonist roles
	/// Shared by every fleshy mass, so a virology farm cannot flood the ghosts with alerts
	COOLDOWN_STATIC_DECLARE(ghost_notify_cooldown)
	/// Whether this spawner alerted the ghosts. During the cooldown it still works and shows up in the spawner menu, it just stays quiet
	var/ghosts_notified = FALSE

/obj/effect/mob_spawn/teratomamonkey/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A && COOLDOWN_FINISHED(src, ghost_notify_cooldown))
		COOLDOWN_START(src, ghost_notify_cooldown, TERATOMA_GHOST_NOTIFY_COOLDOWN)
		ghosts_notified = TRUE
		notify_ghosts("A living tumor has been born in [A.name].", 'sound/effects/splat.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/teratomamonkey/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>Ew. It would be a bad idea to touch this. It could probably be destroyed with the extreme heat of a welder.</span>")

/obj/effect/mob_spawn/teratomamonkey/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(!W.tool_start_check(user, amount = 0)) // an unlit welder has no extreme heat
			return
		user.visible_message("<span class='warning'>[user] destroys [src].</span>",
			"<span class='notice'>You hold the welder to [src] and it violently bursts!</span>",
			"<span class='italics'>You hear a gurgling noise.</span>")
		new /obj/effect/gibspawner/human(get_turf(src))
		qdel(src)
		return
	return ..()

// The tumor these spawners make is a side antagonist: a living one must not keep the round going or block a mode conversion
/datum/antagonist/teratoma/hugbox
	delay_roundend = FALSE
	prevent_roundtype_conversion = FALSE

// Overclocked Pituitary Disruption can drop a teratoma monkey again, as before BeeStation#7421
/obj/effect/spawner/lootdrop/teratoma/major/Initialize(mapload)
	if(type == /obj/effect/spawner/lootdrop/teratoma/major) // the clown subtype has its own loot
		loot[/obj/effect/mob_spawn/teratomamonkey] = 1
	return ..()

#undef TERATOMA_GHOST_NOTIFY_COOLDOWN
