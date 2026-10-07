// AQUILA - Butt Pain: a gluteal anomaly makes everyone's butt fall off, one after another over half a minute.
// The butts fly off in a short arc and can be put back with organ surgery.

/// Spread of the butts falling off after the event starts
#define BUTT_LOSS_SPREAD (30 SECONDS)

/datum/round_event_control/aquila_butt_loss
	name = "Butt Pain"
	typepath = /datum/round_event/aquila_butt_loss
	weight = 10
	max_occurrences = 1
	min_players = 5
	earliest_start = 15 MINUTES

/datum/round_event/aquila_butt_loss
	announceWhen = 1
	startWhen = 5

/datum/round_event/aquila_butt_loss/announce(fake)
	priority_announce("Wykryto anomalię grawitacyjno-pośladkową. Załoga może odczuwać silny ból dupska. \
		Prosimy zachować spokój i nie siadać na niczym ostrym.", "Alarm: Anomalia pośladkowa", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_butt_loss/start()
	var/victims = 0
	for(var/mob/living/carbon/human/victim in GLOB.alive_mob_list)
		if(!is_station_level(victim.z) || !victim.getorganslot(ORGAN_SLOT_BUTT))
			continue
		victims++
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_butt_loss_drop), victim), rand(0, BUTT_LOSS_SPREAD))
	log_game("Butt Pain event is taking the butts of [victims] people.")

/// Tears the butt off someone and sends it flying, if they still have one
/proc/aquila_butt_loss_drop(mob/living/carbon/human/victim)
	if(QDELETED(victim) || victim.stat == DEAD)
		return
	var/obj/item/organ/butt/butt = victim.getorganslot(ORGAN_SLOT_BUTT)
	if(!butt)
		return
	butt.blow_off(victim)
	playsound(victim, butt.fart_sound, 50, TRUE, 5)
	victim.visible_message("<span class='danger'>Pupa [victim] odpada z głośnym plaśnięciem!</span>", "<span class='userdanger'>Czujesz przeszywający ból dupska... i twoja pupa odpada!</span>")
	victim.emote("scream")
	var/turf/landing = get_ranged_target_turf(victim, pick(GLOB.alldirs), rand(1, 3))
	butt.throw_at(landing, 3, 2)

#undef BUTT_LOSS_SPREAD
