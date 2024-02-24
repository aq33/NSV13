/// Returns the indice in filters of the given filter name.
/// If it is not found, returns null.
/atom/proc/get_filter_index(name)
	return filter_data?.Find(name)
