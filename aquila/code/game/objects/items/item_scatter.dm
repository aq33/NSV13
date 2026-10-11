// Port Yogstation#12789 "Fancier Throws and Bullet Ejection" (z Citadel#7997).
// Rzucone przedmioty, łuski, odłamki szkła i rozbite butelki lądują obrócone i przesunięte,
// zamiast układać się równo na środku kafla. Obrót znika, gdy przedmiot zejdzie z podłogi.

/obj/item
	/// Obrót nadany przez throw_scatter(); cofany, gdy przedmiot opuści podłogę
	var/scatter_angle = 0
	/// Pomija jeden rozrzut po rzucie (szklanka barmana postawiona na stole)
	var/skip_next_scatter = FALSE

/// Obraca przedmiot o `angle` i przesuwa o najwyżej `offset` pikseli. Działa tylko na podłodze.
/obj/item/proc/throw_scatter(angle = rand(-170, 170), offset = 12)
	if((item_flags & NO_PIXEL_RANDOM_DROP) || !isturf(loc))
		return
	throw_scatter_rotate(angle)
	pixel_x = base_pixel_x + rand(-offset, offset)
	pixel_y = base_pixel_y + rand(-offset, offset)

/obj/item/proc/throw_scatter_rotate(angle)
	if(!angle || !isturf(loc))
		return
	var/matrix/M = matrix(transform)
	M.Turn(angle)
	transform = M
	scatter_angle += angle
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_throw_scattered_moved), override = TRUE)

/obj/item/proc/on_throw_scattered_moved(datum/source)
	SIGNAL_HANDLER
	if(!isturf(loc))
		throw_unscatter()

/// Cofa tylko nasz obrót, więc nie psuje innych zmian transform (np. skalowania)
/obj/item/proc/throw_unscatter()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	if(!scatter_angle)
		return
	var/matrix/M = matrix(transform)
	M.Turn(-scatter_angle)
	transform = M
	scatter_angle = 0

/obj/item/after_throw(datum/callback/callback)
	. = ..()
	if(skip_next_scatter)
		skip_next_scatter = FALSE
		return
	if(!QDELETED(src))
		throw_scatter(pick(-90, 0, 90, 180))

/obj/item/ammo_casing/bounce_away(still_warm = FALSE, bounce_delay = 3)
	. = ..()
	throw_scatter()

/obj/item/shard/Initialize(mapload)
	. = ..()
	throw_scatter_rotate(rand(-170, 170))
