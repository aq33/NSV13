/// Returns a string with reserved characters and spaces after the first and last letters removed
/// Like trim(), but very slightly faster. worth it for niche usecases
/proc/trim_reduced(text)
	var/starting_coord = 1
	var/text_len = length(text)
	for (var/i in 1 to text_len)
		if (text2ascii(text, i) > 32)
			starting_coord = i
			break

	for (var/i = text_len, i >= starting_coord, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, starting_coord, i + 1)

	if(starting_coord > 1)
		return copytext(text, starting_coord)
	return ""
