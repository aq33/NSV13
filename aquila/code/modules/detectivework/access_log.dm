// AQUILA - logi dostępu (LogProbe z SS14).
// Drzwi i zamykane szafki pamiętają ostatnie udane użycia wymagające dostępu.
// Odczytuje je program NTOS "Czytnik logów dostępu" (logprobe.dm).

/// Ile wpisów pamięta jeden czytnik ID. Najstarszy wypada.
#define AQ_ACCESS_LOG_MAX 20

/// Lista wpisów: każdy to list("time" = "hh:mm:ss", "name" = "Imię (Stanowisko)", "action" = "...")
/obj/var/list/aq_access_records

/// Czy ten obiekt w ogóle prowadzi log dostępu.
/obj/proc/aq_has_access_log()
	return FALSE

/// Czy log jest właśnie wyłączony (np. przecięty przewód ID-scan).
/obj/proc/aq_access_log_disabled()
	return FALSE

/// Czy czytnik został uszkodzony emagiem. Uszkodzony czytnik traci cały log.
/obj/proc/aq_access_log_wiped()
	return (obj_flags & EMAGGED)

/// Kto użył dostępu, w formie do logu.
/proc/aq_access_log_identity(mob/user)
	if(issilicon(user))
		return "[user.name] (jednostka syntetyczna)"
	var/obj/item/card/id/card = user?.get_idcard(TRUE)
	if(!istype(card) || !card.registered_name)
		return "Nieznane ID"
	return "[card.registered_name] ([card.assignment || "brak stanowiska"])"

/// Dopisuje wpis do logu (FIFO, limit AQ_ACCESS_LOG_MAX).
/obj/proc/aq_log_access(mob/user, action)
	if(!user || !aq_has_access_log() || aq_access_log_disabled())
		return
	if(aq_access_log_wiped())
		aq_access_records = null
		return
	if(isobserver(user) || IsAdminGhost(user))
		return
	LAZYADD(aq_access_records, list(list(
		"time" = station_time_timestamp(),
		"name" = aq_access_log_identity(user),
		"action" = action,
	)))
	while(length(aq_access_records) > AQ_ACCESS_LOG_MAX)
		aq_access_records.Cut(1, 2)

/// Zwraca kopię logu od najnowszego wpisu. Uszkodzony emagiem czytnik przy odczycie jest pusty.
/obj/proc/aq_read_access_log()
	if(aq_access_log_wiped())
		aq_access_records = null
	var/list/out = list()
	for(var/i = length(aq_access_records), i >= 1, i--)
		var/list/entry = aq_access_records[i]
		out += list(entry.Copy())
	return out

// ---- Drzwi ----

/obj/machinery/door/aq_has_access_log()
	return TRUE

/obj/machinery/door/aq_access_log_disabled()
	return id_scan_hacked()

// activate_door_base() to wspólna ścieżka bumpopen() i kliknięcia w drzwi.
// Logujemy tylko otwarcie drzwi, które naprawdę wymagają dostępu.
/obj/machinery/door/activate_door_base(mob/user, can_close_door)
	var/was_closed = density
	. = ..()
	if(!. || !was_closed || !user)
		return
	if(emergency || unrestricted_side(user) || check_access(null))
		return
	aq_log_access(user, "otwarcie")

// Drzwi okienne (windoor) otwierają się przy wejściu własnym bumpopen(), bez activate_door_base().
/obj/machinery/door/window/bumpopen(mob/user)
	var/will_open = !operating && density && !id_scan_hacked() && allowed(user)
	. = ..()
	if(!will_open || emergency || unrestricted_side(user) || check_access(null))
		return
	aq_log_access(user, "otwarcie")

// ---- Zamykane szafki ----

/obj/structure/closet/aq_has_access_log()
	return secure

/obj/structure/closet/aq_access_log_wiped()
	return broken || ..()

/obj/structure/closet/togglelock(mob/living/user, silent)
	var/was_locked = locked
	. = ..()
	if(!secure || broken || locked == was_locked || check_access(null))
		return
	aq_log_access(user, locked ? "zamknięcie zamka" : "otwarcie zamka")

#undef AQ_ACCESS_LOG_MAX
