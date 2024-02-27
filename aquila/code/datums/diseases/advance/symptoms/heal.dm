/datum/symptom/heal/symbiotic
	name = "Symbiotic Regeneration"
	desc = "The virus forms a symbiotic relationship with vital organs in the host's body, accelerating the host's natural healing processes while resting."
	stealth = -3
	resistance = -1
	stage_speed = 2
	transmittable = -4

	level = 3
	passive_message = span_notice("You feel calm.")

	/// When was the last time the affected mob moved?
	var/last_moved = 0
	/// How long do you need to stand still to start healing?
	var/heal_delay = 3 SECONDS

	compatible_biotypes = ALL_BIOTYPES // bungus
	threshold_descs = list(
		"Stage speed 9" = "Shorter delay until healing starts.",
		"Resistance 9" = "Increased rate of healing.",
	)

/datum/symptom/heal/symbiotic/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 5) //stronger healing
		heal_delay = 1 SECONDS
	if(A.totalResistance() >= 10) //no delay
		power = 3
	RegisterSignal(A.affected_mob, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(on_move))

/datum/symptom/heal/symbiotic/End(datum/disease/advance/A)
	UnregisterSignal(A.affected_mob, COMSIG_MOB_CLIENT_PRE_MOVE)
	return ..()

/datum/symptom/heal/symbiotic/proc/on_move(mob/living/mover, dir)
	last_moved = world.time

/datum/symptom/heal/symbiotic/CanHeal(datum/disease/advance/A)
	if(last_moved + heal_delay > world.time)
		return FALSE
	return power

/datum/symptom/heal/symbiotic/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	if(M.health == M.maxHealth)
		return
	if(last_moved + heal_delay > world.time)
		return

	if(M.getBruteLoss() || M.getFireLoss() || M.getToxLoss())
		var/heal_amount = actual_power * 0.5
		M.heal_bodypart_damage(heal_amount, heal_amount, required_status=((A.infectable_biotypes & MOB_ROBOTIC) ? BODYPART_ANY : BODYPART_ORGANIC))
		M.adjustToxLoss(-heal_amount)
		if(prob(1) && IS_ENGINEERING(M))
			M.adjust_wet_stacks(0.1) // there seems to be a danger of precipitation...
			to_chat(M, span_notice("You can smell rain."))
		return TRUE

	return FALSE // stop healing if there isn't any damage to heal
