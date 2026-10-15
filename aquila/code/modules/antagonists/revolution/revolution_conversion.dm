// Port of BeeStation/BeeStation-Hornet#10811 (conversion and shuttle parts only).
// Head revolutionaries convert with a channelled speech instead of a flash, and calling the shuttle
// during a revolution is allowed but gets delayed and locked.

/// Time after being hurt during which a target can't be convinced
#define REV_CONVERT_ATTACK_COOLDOWN (3 SECONDS)
/// How long the revolution delay pushes the shuttle ETA
#define REV_SHUTTLE_DELAY (10 MINUTES)

GLOBAL_LIST_INIT(revolution_conversion_text, list(
	"Nadszedł czas, by powstać przeciw uciskowi Nanotrasen i walczyć o naszą wolność.",
	"Tylko jedność i siła zerwą kajdany tyranii nałożone przez Nanotrasen.",
	"Każdy głos przeciw Nanotrasen się liczy. Niech twój też będzie słyszany.",
	"Musimy odebrać Nanotrasen władzę nad naszą przyszłością i sami ją budować.",
	"Odwaga, by marzyć, to iskra, od której zapłonie rewolucja przeciw Nanotrasen.",
	"Wobec niesprawiedliwości Nanotrasen milczenie to współudział. Mów i stawiaj opór.",
	"Nasza sprawa jest słuszna, wola silna, a z każdym dniem jest nas więcej.",
	"Razem rozbijemy system władzy Nanotrasen, który nas gnębi.",
	"Dołącz do szlachetnej walki o wolność i stań się częścią czegoś większego.",
	"Prawdziwa zmiana idzie od dołu. Bez ciebie ta walka się nie uda.",
))

/mob/living
	/// world.time of the last melee hit or projectile that hurt this mob, used by revolutionary conversion
	var/last_attacked_time = 0

/obj/effect/proc_holder/spell/targeted/revolution_convert
	name = "Nawrócenie rewolucyjne"
	desc = "Przekonaj stojącą blisko osobę do rewolucji. Cel jest ogłuszony i milczy, dopóki do niego mówisz; przerwanie przekonywania psuje konwersję."
	charge_max = 0
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "mindread"
	action_background_icon_state = "bg_demon"
	range = 3
	clothes_req = FALSE
	antimagic_allowed = TRUE
	/// Speech lines needed to convert someone
	var/speech_steps = 3
	/// Length of every speech line
	var/speech_step_time = 3 SECONDS
	/// Is a conversion already going on
	var/converting = FALSE

/obj/effect/proc_holder/spell/targeted/revolution_convert/cast(list/targets, mob/user)
	var/datum/antagonist/rev/head/rev_datum = user.mind?.has_antag_datum(/datum/antagonist/rev/head)
	if(!rev_datum)
		return
	if(converting)
		to_chat(user, "<span class='warning'>Już kogoś przekonujesz!</span>")
		return
	var/mob/living/carbon/target = targets[1]
	if(!istype(target) || !rev_datum.can_be_converted(target))
		to_chat(user, "<span class='warning'>Tej osoby nie da się nawrócić!</span>")
		return
	if(!target.client)
		to_chat(user, "<span class='warning'>Ten umysł jest tak pusty, że nie da się na niego wpłynąć!</span>")
		return
	if(target.stat != CONSCIOUS)
		to_chat(user, "<span class='warning'>Cel musi być przytomny, żeby cię wysłuchać!</span>")
		return
	if(!(target in oview(range, user)))
		to_chat(user, "<span class='warning'>Cel jest za daleko!</span>")
		return
	if(target.last_attacked_time + REV_CONVERT_ATTACK_COOLDOWN > world.time)
		to_chat(user, "<span class='warning'>Nie przekonasz kogoś, kogo dopiero co zaatakowano!</span>")
		return
	converting = TRUE
	for(var/i in 1 to speech_steps)
		user.say(pick(GLOB.revolution_conversion_text), forced = "revolution conversion")
		target.Stun(speech_step_time)
		target.silent = max(target.silent, 4)
		var/datum/beam/beam = target.Beam(user, icon_state = "sendbeam", time = speech_step_time)
		if(!do_after(user, speech_step_time, target = target) || !(target in oview(range, user)))
			qdel(beam)
			converting = FALSE
			to_chat(user, "<span class='warning'>Przestajesz tłumaczyć teorię rewolucji. Konwersja się nie udała!</span>")
			return
	converting = FALSE
	if(target.last_attacked_time + REV_CONVERT_ATTACK_COOLDOWN > world.time)
		to_chat(user, "<span class='warning'>Cel został zaatakowany i przestał cię słuchać. Konwersja się nie udała!</span>")
		return
	if(!rev_datum.add_revolutionary(target.mind, FALSE))
		to_chat(user, "<span class='warning'>Ten umysł wydaje się odporny na twoje słowa!</span>")
		return
	log_combat(user, target, "converted to the revolution")

/datum/antagonist/rev/head/proc/give_conversion_spell()
	if(locate(/obj/effect/proc_holder/spell/targeted/revolution_convert) in owner.spell_list)
		return
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/revolution_convert(null))

/datum/antagonist/rev/head/on_removal()
	owner.RemoveSpell(/obj/effect/proc_holder/spell/targeted/revolution_convert)
	return ..()

// Shuttle: a revolution no longer blocks the shuttle, it delays it instead

/// Is there a revolution that hasn't won yet and still has leaders
/datum/controller/subsystem/shuttle/proc/check_revolution_environment()
	for(var/datum/team/revolution/rev_team in GLOB.antagonist_teams)
		if(length(rev_team.head_revolutionaries()) && !rev_team.check_rev_victory())
			return TRUE
	return FALSE

/datum/controller/subsystem/shuttle
	/// So the revolution delay and warning only happen once
	var/revolution_delay_active = FALSE

/datum/controller/subsystem/shuttle/proc/delay_for_revolutionary_station()
	if(revolution_delay_active || !check_revolution_environment() || emergency?.mode != SHUTTLE_CALL)
		return
	revolution_delay_active = TRUE
	priority_announce("Wykryto aktywność rewolucyjną: uruchomiono kryzysowe protokoły promu. Sygnały odwołania są zagłuszane na wszystkich częstotliwościach.", null, null, "Priority")
	// Extend the current ETA instead of replacing it, and block recalls only for this call
	var/revolution_call_time = emergency.timeLeft(1) + REV_SHUTTLE_DELAY
	emergency.setTimer(revolution_call_time)
	block_recall(revolution_call_time)

/obj/docking_port/mobile/emergency
	/// Timer of the delayed revolution alert
	var/revolution_alert_timer

/obj/docking_port/mobile/emergency/proc/check_revolution_delay(call_time)
	// A pending alert also covers later calls; it checks the shuttle state when it fires
	if(SSshuttle.revolution_delay_active || timeleft(revolution_alert_timer) || !SSshuttle.check_revolution_environment())
		return
	// Random moment between 2:30 and the full call time, like the infestation delay upstream
	revolution_alert_timer = addtimer(CALLBACK(SSshuttle, TYPE_PROC_REF(/datum/controller/subsystem/shuttle, delay_for_revolutionary_station)), rand(150 SECONDS, max(150 SECONDS, call_time)), TIMER_STOPPABLE)

#undef REV_CONVERT_ATTACK_COOLDOWN
#undef REV_SHUTTLE_DELAY
