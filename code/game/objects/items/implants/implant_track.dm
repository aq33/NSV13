/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = FALSE
	///for how many deciseconds after user death will the implant work?
	var/lifespan_postmortem = 6000
	///will people implanted with this act as teleporter beacons?
	var/allow_teleport = TRUE
	///The id of the timer that's qdeleting us
	var/timerid

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	var/lifespan = 3000 //how many deciseconds does the implant last?
	allow_teleport = FALSE

/obj/item/implant/tracking/c38/Initialize(mapload)
	. = ..()
	timerid = QDEL_IN(src, lifespan)

/obj/item/implant/tracking/c38/Destroy()
	deltimer(timerid)
	return ..()

/obj/item/implant/tracking/New()
	..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	. = ..()
	GLOB.tracked_implants -= src

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Nadajnik śledzący<BR><b>Żywotność:</b> 10 minut po śmierci nosiciela.<BR><b>Ważne uwagi:</b> implant działa też jako nadajnik teleportera.<BR><HR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> stale nadaje sygnał o niskiej mocy. Przydatny do śledzenia.<BR><b>Cechy specjalne:</b><BR><i>Neuroochrona</i> - specjalna powłoka pochłania nadmiar napięcia i w razie awarii niszczy chip, zapewniając bezpieczeństwo nosiciela. Implant stopi się i rozpadnie na bezpieczne biologicznie składniki.<BR><b>Trwałość:</b> gradient stwarza niewielkie ryzyko przeładowania i przepalenia obwodów. W efekcie neurotoksyny mogą wyrządzić ogromne szkody."}
	return dat
