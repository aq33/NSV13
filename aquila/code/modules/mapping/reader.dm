/datum/parsed_map/proc/copy()
	var/datum/parsed_map/copy = new()
	copy.original_path = original_path
	copy.key_len = key_len
	copy.grid_models = grid_models
	copy.gridSets = gridSets
	copy.modelCache = modelCache
	copy.parsed_bounds = parsed_bounds
	copy.turf_blacklist = list()
	return copy
