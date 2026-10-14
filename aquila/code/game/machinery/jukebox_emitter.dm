// AQUILA EDIT - miejsce w świecie, z którego słychać muzykę jukeboxa (sam jukebox, amp stack, głośnik nukies).
// Liczy, jak głośno, z jakim echem i jak przytłumioną muzykę słyszy dany gracz.

/datum/music_emitter
	/// Obiekt, z którego leci dźwięk
	var/atom/parent
	/// Promień (w kratkach) okręgu, w którym słychać muzykę
	var/range = 20
	/// Do tej odległości muzyka gra pełną głośnością, dalej cichnie
	var/full_range = 3
	/// O ile kratek "dalej" jest pokład nad/pod źródłem
	var/deck_penalty = 4
	/// Mnożnik wygłuszenia przez ściany, okna i drzwi (np. słabszy głośnik słabiej je przebija)
	var/wall_multiplier = 1
	/// Mnożnik echa z odległości (głośniki nagłośnienia są blisko słuchacza - mało echa)
	var/echo_strength = 1
	/// Pamięć wygłuszenia przeszkód: turf słuchacza -> suma (odświeżana co sekundę)
	var/list/dampening_cache = list()
	var/dampening_cache_time = 0
	var/turf/dampening_cache_from

/datum/music_emitter/New(atom/parent, range = 20, full_range = 3, deck_penalty = 4, wall_multiplier = 1, echo_strength = 1)
	src.parent = parent
	src.range = range
	src.full_range = full_range
	src.deck_penalty = deck_penalty
	src.wall_multiplier = wall_multiplier
	src.echo_strength = echo_strength

/datum/music_emitter/Destroy(force, ...)
	parent = null
	dampening_cache = null
	dampening_cache_from = null
	return ..()

/// Jak daleko gracz jest w strefie wyciszania: 0 = przy źródle (pełna głośność), 1 = na krawędzi okręgu.
/// null gdy gracz nic nie słyszy (poza okręgiem, niepołączony z-level, wyłączone instrumenty, głuchy).
/// Pokład tuż nad/pod źródłem też słyszy, ale jakby był dalej o deck_penalty kratek.
/datum/music_emitter/proc/hearing_fraction(mob/M)
	if(!M?.client || !(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS) || !M.can_hear())
		return null
	var/turf/T = get_turf(M)
	var/turf/our_turf = get_turf(parent)
	if(!T || !our_turf)
		return null
	var/distance = sqrt((T.x - our_turf.x) ** 2 + (T.y - our_turf.y) ** 2)
	if(T.z != our_turf.z)
		if(!is_adjacent_deck(T))
			return null
		distance += deck_penalty
	if(distance > range)
		return null
	return clamp((distance - full_range) / (range - full_range), 0, 1)

/// Czy turf leży na pokładzie bezpośrednio nad albo pod źródłem (połączone z-levele)
/datum/music_emitter/proc/is_adjacent_deck(turf/T)
	var/turf/our_turf = get_turf(parent)
	var/turf/other = our_turf?.above()
	if(other && other.z == T.z)
		return TRUE
	other = our_turf?.below()
	return other && other.z == T.z

/// Mnożnik głośności 0-1: okrąg o promieniu range, cichnie płynnie (krzywa cosinusowa, bez skoków na początku i końcu).
/datum/music_emitter/proc/hearing_gain(mob/M)
	var/fraction = hearing_fraction(M)
	if(isnull(fraction))
		return 0
	return (1 + cos(180 * fraction)) / 2

/// Ilość echa 0-1: brak przy źródle, rośnie z odległością.
/datum/music_emitter/proc/echo_amount(mob/M)
	var/fraction = hearing_fraction(M)
	if(isnull(fraction))
		return 0
	return clamp((fraction - 0.1) / 0.6, 0, 1) * echo_strength

/// Przytłumienie 0-1 (jak zza ściany): pełne na innym pokładzie, na tym samym - suma wygłuszenia przeszkód po drodze.
/datum/music_emitter/proc/muffle_amount(mob/M)
	var/turf/T = get_turf(M)
	var/turf/our_turf = get_turf(parent)
	if(!T || !our_turf)
		return 0
	if(T.z != our_turf.z)
		return 1
	return min(1, obstacle_dampening(T) * wall_multiplier)

/// Suma sound_dampening ścian, okien i zamkniętych drzwi na linii źródło -> turf (wynik trzymany 1 s na turf, żeby otwarcie drzwi było słychać od razu).
/datum/music_emitter/proc/obstacle_dampening(turf/T)
	var/turf/our_turf = get_turf(parent)
	if(dampening_cache_time + 1 SECONDS < world.time || dampening_cache_from != our_turf)
		dampening_cache = list()
		dampening_cache_time = world.time
		dampening_cache_from = our_turf
	if(!isnull(dampening_cache[T]))
		return dampening_cache[T]
	var/total = 0
	for(var/turf/line_turf as anything in getline(our_turf, T))
		if(line_turf == our_turf)
			continue
		total += line_turf.get_sound_dampening()
		for(var/obj/O in line_turf)
			if(O.sound_dampening)
				total += O.get_sound_dampening()
		if(total >= 1)
			break
	dampening_cache[T] = total
	return total
