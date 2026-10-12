/datum/language/mouse
	name = "Mouse"
	desc = "A rather simple language spoken and understood by mice. It has been developed and shared by genetically advanced mice."
	speech_verb = "piszczy"
	ask_verb = "piszczy"
	exclaim_verb = "piszczy"
	key = "m"
	flags = NO_STUTTER | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD

/datum/language/mouse/scramble(input)
	. = "Squeak"
	. += (copytext(input, length(input)) == "?") ? "?" : "!"
