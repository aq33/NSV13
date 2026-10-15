// Drobne typy potrzebne mapom domen przeniesionym z tg (tools/bitrunning/convert_domains.py).

/// Podłoga stale pokryta smarem (tg /turf/open/indestructible/permalube) - zagadki ślizgowe na Planecie Klaunów
/turf/open/indestructible/permalube
	icon_state = "darkfull"

/turf/open/indestructible/permalube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wet_floor, TURF_WET_LUBE, INFINITY, 0, INFINITY, TRUE)
