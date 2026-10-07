// AQUILA - łańcuchy Markowa (port z HippieStation, używane przez gremliny do "pisania" ogłoszeń z podsłuchanych rozmów)
// Uses the _char text procs so Polish letters are not cut in half

#define MAXIMUM_MARKOV_LENGTH 25000

/// Generates up to `length` characters of text that statistically resembles `text`, looking `order` characters back
/proc/markov_chain(text, order = 4, length = 250)
	if(!text || order < 1 || order > 20 || length < 1 || length > MAXIMUM_MARKOV_LENGTH)
		return

	var/list/table = markov_table(text, order)
	return markov_text(length, table, order)

/proc/markov_table(text, look_forward = 4)
	if(!text)
		return
	var/list/table = list()
	var/text_length = length_char(text)

	for(var/i in 1 to text_length)
		var/char = copytext_char(text, i, look_forward + i)
		if(!table[char])
			table[char] = list()

	for(var/i in 1 to text_length - look_forward)
		var/char_index = copytext_char(text, i, look_forward + i)
		var/char_count = copytext_char(text, i + look_forward, (look_forward * 2) + i)
		var/list/followers = table[char_index]
		followers[char_count] += 1

	return table

/proc/markov_text(length = 250, list/table, look_forward = 4)
	if(!length(table))
		return
	var/char = pick(table)
	var/output = char

	for(var/i in 0 to (length / look_forward))
		var/newchar = markov_weighted_char(table[char])
		if(newchar)
			char = newchar
			output += "[newchar]"
		else
			char = pick(table)

	return output

/proc/markov_weighted_char(list/array)
	if(!length(array))
		return

	var/total = 0
	for(var/i in array)
		total += array[i]
	var/r = rand(1, total)
	for(var/i in array)
		var/weight = array[i]
		if(r <= weight)
			return i
		r -= weight

#undef MAXIMUM_MARKOV_LENGTH
