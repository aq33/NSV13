/datum/mood_event/moth_drink_blood
	description = "<span class='nicegreen'>Właśnie tego było mi trzeba!</span>\n"
	mood_change = 3
	timeout = 7 MINUTES

/datum/mood_event/tailpull
	description = "<span class='warning'>AUĆ! Przestań ciągnąć mnie za ogon! To boli!\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/watersprayed
	description = "<span class='warning'>Nienawidzę, jak ktoś pryska na mnie wodą!</span>\n"
	mood_change = -1
	timeout = 30 SECONDS

/datum/mood_event/watersplashed
	//splash gets a larger debuff
	description = "<span class='boldwarning'>Nienawidzę, jak ktoś chlapie na mnie wodą!</span>\n"
	mood_change = -2
	timeout = 30 SECONDS

/datum/mood_event/stuck_in_pool
	description = "<span class='boldwarning'>UTKNĄŁEM W BASENIE!</span>\n"
	mood_change = -5 //felinids really hate water

/datum/mood_event/was_stuck_in_pool
	description = "<span class='warning'>Utknąłem w basenie, myślałem, że nigdy się nie wydostanę.</span>\n"
	mood_change = -2 //felinids really hate water
	timeout = 4 MINUTES

/datum/mood_event/hate_shower
	description = "<span class='boldwarning'><i>NIENAWIDZĘ</i> pryszniców!</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/torphug
	description = "<span class='nicegreen'>Bardzo tego potrzebowałem..</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/drink_navy_coffee
	description = "<span class='nicegreen'><b>TO BYŁO KURWA PYSZNE, CHODŹMY ROZJEBAĆ KILKA OKRĘTÓW SYNDYKATU, MARYNARKA NA ZAWSZE, JUHUUUU!!</b></span>\n"
	mood_change = 3
	timeout = 7 MINUTES

/datum/mood_event/drink_navy_coffee/add_effects(list/faction)
	if(FACTION_SYNDICATE in faction)
		description = "<span class='nicegreen'><b>TO BYŁO KURWA PYSZNE, CHODŹMY ROZJEBAĆ KILKA OKRĘTÓW NANOTRASEN, MARYNARKA NA ZAWSZE, JUHUUUU!!</b></span>\n"


/datum/mood_event/cheers
	description = "<span class='nicegreen'>Na zdrowie! ¡Salud! Kanpai! Prost! Skål! Santé! Sláinte! Saúde!</span>\n"
	mood_change = 3
	timeout = 30 SECONDS

/datum/mood_event/lizard_shivers
	description = "<span class='warning'>Trzęsę się.. Muszę znaleźć miejsce, gdzie mogę wygrzać się w słońcu!</span>\n" //Evolved mental response, even if not entirely true here.
	mood_change = -2

/datum/mood_event/comfy_lizard_temperature
	description = "<span class='nicegreen'>Jest mi miło i ciepło! Brakowało mi tego uczucia..</span>\n" //These ships run at 20°C by default, which is.. not very nice for something coldblooded.
	mood_change = 2 //This is really hard to hit and maintain so I felt like at least a +2 would be appropriate.
