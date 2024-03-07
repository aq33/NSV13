/datum/map_template
	var/maps_loading = 0

/datum/map_template/proc/load_tut(turf/T, centered = FALSE, init_atmos = TRUE, finalize = TRUE, ...)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/border = block(locate(max(T.x, 1), max(T.y, 1),  T.z),
							locate(min(T.x+width, world.maxx), min(T.y+height, world.maxy), T.z))
	for(var/L in border)
		var/turf/turf_to_disable = L
		turf_to_disable.ImmediateDisableAdjacency()

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	maps_loading ++
	var/datum/parsed_map/parsed = cached_map ? cached_map.copy() : new(file(mappath))
	cached_map = parsed

	var/list/turf_blacklist = list()
	update_blacklist(T, turf_blacklist)

	UNSETEMPTY(turf_blacklist)
	parsed.turf_blacklist = turf_blacklist
	var/datum/async_map_generator/map_place/map_placer = new(parsed, T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=should_place_on_top)
	map_placer.on_completion(CALLBACK(src, PROC_REF(on_placement_completed)))
	var/list/generation_arguments =  list(T, init_atmos, parsed, finalize)
	if (length(args) > 4)
		generation_arguments += args.Copy(5)
	map_placer.generate(arglist(generation_arguments))
	return map_placer

/datum/map_template/proc/on_placement_completed(datum/async_map_generator/map_gen, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, ...)
	var/list/bounds = parsed.bounds
	if(!bounds)
		maps_loading --
		if (!maps_loading)
			cached_map = keep_cached_map ? parsed : null
		message_admins("NO PARSED BOUNDS!")
		return

	require_area_resort()

	//If this is a superfunction call, we don't want to initialize atoms here, let the subfunction handle that
	if(finalize)
		maps_loading --
		if (!maps_loading)
			cached_map = keep_cached_map ? parsed : null
		//initialize things that are normally initialized after map load
		initTemplateBounds(bounds, init_atmos)
		log_game("[name] loaded at [T.x],[T.y],[T.z]")

	return bounds
