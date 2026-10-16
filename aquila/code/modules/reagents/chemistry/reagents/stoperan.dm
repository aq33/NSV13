// Stoperan - na 5 minut zatrzymuje przyrost potrzeby wypróżnienia.
// Przedawkowanie albo branie go bez przerwy zbyt długo kończy się eksplozją z zatkanych jelit.

/// Po tylu cyklach przedawkowania jelita nie wytrzymują
#define STOPERAN_OVERDOSE_CYCLES 8
/// Po tylu minutach ciągłego działania stoperanu jelita nie wytrzymują
#define STOPERAN_MAX_CONTINUOUS (20 MINUTES)
/// Od tego czasu ciągłego działania przychodzą ostrzeżenia
#define STOPERAN_WARN_CONTINUOUS (15 MINUTES)

/datum/reagent/medicine/stoperan
	name = "Stoperan"
	description = "Lek przeciwbiegunkowy. Na pięć minut wstrzymuje przyrost potrzeby wypróżnienia. Nie przedawkowywać i nie brać bez przerwy dłużej niż kwadrans."
	reagent_state = SOLID
	color = "#E8E4D8"
	taste_description = "kreda"
	overdose_threshold = 20
	/// Ile cykli trwa już przedawkowanie
	var/overdose_cycles = 0

/datum/reagent/medicine/stoperan/on_mob_metabolize(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/stoperan)

// Kolejna pigułka, gdy poprzednia jeszcze się wchłania, też odświeża czas
/datum/reagent/medicine/stoperan/on_merge(data, amount)
	. = ..()
	var/mob/living/L = holder?.my_atom
	if(metabolizing && istype(L))
		L.apply_status_effect(/datum/status_effect/stoperan)

/datum/reagent/medicine/stoperan/overdose_process(mob/living/M)
	. = ..()
	overdose_cycles++
	if(overdose_cycles >= STOPERAN_OVERDOSE_CYCLES)
		M.stoperan_burst()
		return
	M.adjustStaminaLoss(5, FALSE)
	if(prob(50))
		to_chat(M, "<span class='warning'>[pick("Brzuch wzdyma ci się jak balon!", "Coś w jelitach bulgocze pod ogromnym ciśnieniem.", "Czujesz, że zaraz pękniesz!", "Twój brzuch wydaje groźne dźwięki.")]</span>")
		M.emote(pick("groan", "moan", "fart"))

/datum/status_effect/stoperan
	id = "stoperan"
	duration = 5 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	tick_interval = 10 SECONDS
	/// Od kiedy jelita są zatrzymane bez przerwy
	var/started_at = 0

/datum/status_effect/stoperan/on_apply()
	to_chat(owner, "<span class='notice'>Czujesz, jak twoje jelita się uspokajają.</span>")
	started_at = world.time
	return TRUE

/datum/status_effect/stoperan/tick()
	var/elapsed = world.time - started_at
	if(elapsed >= STOPERAN_MAX_CONTINUOUS)
		owner.stoperan_burst()
		return
	if(elapsed >= STOPERAN_WARN_CONTINUOUS && prob(40))
		to_chat(owner, "<span class='warning'>[pick("Od dawna nic z ciebie nie wyszło. Brzuch jest twardy jak kamień.", "Jelita skręcają się boleśnie. Może czas odstawić stoperan?", "Czujesz rosnące ciśnienie w brzuchu.")]</span>")

/datum/status_effect/stoperan/on_remove()
	to_chat(owner, "<span class='notice'>Twoje jelita wracają do normalnej pracy.</span>")

/obj/item/reagent_containers/pill/stoperan
	name = "pigułka stoperanu"
	desc = "Na pięć minut wstrzymuje przyrost potrzeby wypróżnienia. Nieoceniona na długich wyprawach górniczych."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/stoperan = 5)
	rename_with_volume = TRUE

/// Zatkane stoperanem jelita w końcu puszczają. Wszystko naraz.
/mob/living/proc/stoperan_burst()
	var/turf/T = get_turf(src)
	visible_message("<span class='danger'>Brzuch [src] pęka z donośnym odgłosem wypróżnienia, a wszystko dookoła pokrywa brązowa breja!</span>", 		"<span class='userdanger'>Twoje zatkane jelita w końcu puszczają. Naraz.</span>")
	playsound(T, 'aquila/sound/creatures/fart.ogg', 100, TRUE, 5)
	playsound(T, 'sound/effects/splat.ogg', 100, TRUE)
	if(T)
		new /obj/effect/decal/cleanable/feces(T)
		for(var/turf/open/near in orange(1, T))
			if(prob(50))
				new /obj/effect/decal/cleanable/feces(near)
		for(var/mob/living/L in viewers(7, T))
			if(L != src)
				L.adjust_disgust(DISGUST_LEVEL_VERYGROSS)
	log_game("[key_name(src)] was gibbed by stoperan at [AREACOORD(T)]")
	gib()

#undef STOPERAN_OVERDOSE_CYCLES
#undef STOPERAN_MAX_CONTINUOUS
#undef STOPERAN_WARN_CONTINUOUS
