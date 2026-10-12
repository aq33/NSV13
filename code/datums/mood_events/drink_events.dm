/datum/mood_event/drunk
	mood_change = 3
	description = "<span class='nicegreen'>Po drinku czy dwóch wszystko wydaje się lepsze.</span>\n"

/datum/mood_event/quality_bad
	description = "<span class='warning'>Ten drink był zupełnie niedobry.</span>\n"
	mood_change = -2
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = "<span class='nicegreen'>Ten drink był całkiem niezły.</span>\n"
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "<span class='nicegreen'>Ten drink był całkiem dobry.</span>\n"
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "<span class='nicegreen'>Ten drink był świetny!</span>\n"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "<span class='nicegreen'>Ten drink był niesamowity!</span>\n"
	mood_change = 8
	timeout = 7 MINUTES
