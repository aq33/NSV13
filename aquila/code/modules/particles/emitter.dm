// Port systemu emiterów cząsteczek z Yogstation (code/modules/particles/byond_particles).
// Atom może mieć tylko jeden zestaw /particles, więc każdy efekt siedzi w osobnym
// /obj/emitter wyświetlanym przez vis_contents rodzica. Dzięki temu flara może mieć
// jednocześnie dym i iskry, a ognisko ogień, iskry i dym.

/atom/movable
	/// Aktywne emitery cząsteczek, klucz -> /obj/emitter
	var/list/particle_emitters

/obj/emitter
	appearance_flags = LONG_GLIDE | KEEP_APART | TILE_BOUND | PIXEL_SCALE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Atom, na którym wyświetlamy cząsteczki
	var/atom/movable/parent
	/// Klucz w parent.particle_emitters
	var/emitter_key
	/// Czy emiter wygasa (nie tworzy już nowych cząsteczek)
	var/fading = FALSE

/obj/emitter/Destroy(force)
	detach()
	particles = null
	return ..()

/obj/emitter/proc/attach(atom/movable/new_parent, key)
	parent = new_parent
	emitter_key = key
	parent.vis_contents += src
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

/obj/emitter/proc/detach()
	if(!parent)
		return
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	parent.vis_contents -= src
	if(LAZYACCESS(parent.particle_emitters, emitter_key) == src)
		LAZYREMOVE(parent.particle_emitters, emitter_key)
	parent = null

/obj/emitter/proc/on_parent_qdel(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Przestaje tworzyć cząsteczki i usuwa się, gdy istniejące wygasną.
/obj/emitter/proc/fade_out()
	if(fading)
		return
	fading = TRUE
	if(parent && LAZYACCESS(parent.particle_emitters, emitter_key) == src)
		LAZYREMOVE(parent.particle_emitters, emitter_key)
	if(!particles)
		qdel(src)
		return
	particles.spawning = 0
	var/time_left = isnum(particles.lifespan) ? particles.lifespan : 2 SECONDS
	QDEL_IN(src, time_left)

/**
 * Dodaje emiter cząsteczek pod podanym kluczem.
 * Jeśli pod kluczem jest już aktywny emiter tego samego typu, zostaje bez zmian.
 * priority (1-10) decyduje, który emiter jest rysowany wyżej.
 * lifespan > 0 sprawia, że emiter sam wygaśnie po tym czasie.
 */
/atom/movable/proc/add_emitter(emitter_type, key, priority = 10, lifespan)
	if(!key)
		CRASH("add_emitter called without a key")
	if(QDELETED(src))
		return
	var/obj/emitter/existing = LAZYACCESS(particle_emitters, key)
	if(existing)
		if(existing.type == emitter_type && !existing.fading)
			return existing
		qdel(existing)
	var/obj/emitter/new_emitter = new emitter_type()
	new_emitter.layer += clamp(priority, 1, 10) / 100
	new_emitter.attach(src, key)
	LAZYSET(particle_emitters, key, new_emitter)
	if(lifespan)
		addtimer(CALLBACK(new_emitter, TYPE_PROC_REF(/obj/emitter, fade_out)), lifespan)
	return new_emitter

/// Wygasza emiter spod klucza. instant = TRUE usuwa go natychmiast razem z cząsteczkami.
/atom/movable/proc/remove_emitter(key, instant = FALSE)
	var/obj/emitter/removed = LAZYACCESS(particle_emitters, key)
	if(!removed)
		return
	if(instant)
		qdel(removed)
	else
		removed.fade_out()
