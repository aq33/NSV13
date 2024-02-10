/mob/verb/rsay_wrapper(message as text)
	set name = ".Rsay"
	set hidden = 1
	set instant = 1

	remove_typing_indicator()
	if(message)
		say_verb(";[message]")
