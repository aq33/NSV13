/datum/mood_event/handcuffed
	description = "<span class='warning'>Chyba moje wybryki w końcu mnie dopadły.</span>\n"
	mood_change = -1

/datum/mood_event/broken_vow //Used for when mimes break their vow of silence
  description = "<span class='boldwarning'>Okryłem swoje imię hańbą i zdradziłem braci mimów, łamiąc nasz święty ślub...</span>\n"
  mood_change = -8

/datum/mood_event/on_fire
	description = "<span class='boldwarning'>PŁONĘ!!!</span>\n"
	mood_change = -12

/datum/mood_event/suffocation
	description = "<span class='boldwarning'>CAN'T... BREATHE...</span>\n"
	mood_change = -12

/datum/mood_event/burnt_thumb
	description = "<span class='warning'>Nie powinienem bawić się zapalniczkami...</span>\n"
	mood_change = -1
	timeout = 2 MINUTES

/datum/mood_event/cold
	description = "<span class='warning'>Jest tu zdecydowanie za zimno.</span>\n"
	mood_change = -5

/datum/mood_event/hot
	description = "<span class='warning'>Robi się tu gorąco.</span>\n"
	mood_change = -5

/datum/mood_event/creampie
	description = "<span class='warning'>Dostałem kremem. Smakuje jak ciasto.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/slipped
	description = "<span class='warning'>Poślizgnąłem się. Następnym razem muszę bardziej uważać...</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eye_stab
	description = "<span class='boldwarning'>Kiedyś byłem poszukiwaczem przygód, tak jak ty, ale potem dostałem śrubokrętem w oko.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/delam //SM delamination
	description = "<span class='boldwarning'>Ci cholerni inżynierowie nic nie potrafią zrobić dobrze...</span>\n"
	mood_change = -2
	timeout = 4 MINUTES

/datum/mood_event/depression
	description = "<span class='warning'>Bez szczególnego powodu jest mi smutno.</span>\n"
	mood_change = -12
	timeout = 2 MINUTES

/datum/mood_event/anxiety
	description = "<span class='warning'>Boję się przy tych wszystkich ludziach..</span>\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/anxiety_mute
	description = "<span class='boldwarning'>Nie mogę się odezwać, nie przy wszystkich!</span>\n"
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/anxiety_dumb
	description = "<span class='boldwarning'>O Boże, zrobiłem z siebie głupka.</span>\n"
	mood_change = -10
	timeout = 2 MINUTES

/datum/mood_event/shameful_suicide //suicide_acts that return SHAME, like sord
  description = "<span class='boldwarning'>Nie mogę nawet z tym wszystkim skończyć!</span>\n"
  mood_change = -15
  timeout = 60 SECONDS

/datum/mood_event/dismembered
  description = "<span class='boldwarning'>AAA! UŻYWAŁEM TEJ KOŃCZYNY!</span>\n"
  mood_change = -10
  timeout = 8 MINUTES

/datum/mood_event/tased
	description = "<span class='warning'>W słowie „paralizator” nie ma „z”. Jest w zapale.</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/embedded
	description = "<span class='boldwarning'>Wyciągnijcie to!</span>\n"
	mood_change = -7

/datum/mood_event/table
	description = "<span class='warning'>Ktoś rzucił mnie na stół!</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/table/add_effects()
	var/datum/component/L = owner //owner is lying about its type, its component/mood while pretending to be mob. You must cast it to use it properly
	var/mob/living/T = L.parent
	if(ishuman(T))
		var/mob/living/carbon/human/H = T
		if(iscatperson(H) || (istype(H.getorganslot(ORGAN_SLOT_EARS), /obj/item/organ/ears/cat) && istype(H.getorganslot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/cat)))
			var/obj/item/organ/tail/tail = H.getorganslot(ORGAN_SLOT_TAIL)
			if(tail)
				tail.set_wagging(H, TRUE)
				addtimer(CALLBACK(tail, TYPE_PROC_REF(/obj/item/organ/tail, set_wagging), H, FALSE), 3 SECONDS)
			description =  "<span class='nicegreen'>Chcą się bawić na stole!</span>\n"
			mood_change = 2



/datum/mood_event/table_headsmash
	description = "<span class='warning'>Moja pieprzona głowa, to bolało...</span>"
	mood_change = -3
	timeout = 3 MINUTES

/datum/mood_event/brain_damage
  mood_change = -3

/datum/mood_event/brain_damage/add_effects()
  var/damage_message = pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")
  description = "<span class='warning'>Hyy, dyy... [damage_message]</span>\n"

/datum/mood_event/hulk //Entire duration of having the hulk mutation
  description = "<span class='warning'>HULK MIAŻDŻYĆ!</span>\n"
  mood_change = -4

/datum/mood_event/epilepsy //Only when the mutation causes a seizure
  description = "<span class='warning'>Trzeba było zwrócić uwagę na ostrzeżenie o epilepsji.</span>\n"
  mood_change = -3
  timeout = 5 MINUTES

/datum/mood_event/nyctophobia
	description = "<span class='warning'>Ale tu ciemno...</span>\n"
	mood_change = -3

/datum/mood_event/family_heirloom_missing
	description = "<span class='warning'>Brakuje mi mojej rodzinnej pamiątki...</span>\n"
	mood_change = -4

/datum/mood_event/healsbadman
	description = "<span class='warning'>Czuję się o wiele lepiej, ale to było obrzydliwe.</span>\n" //when you read the latest felinid removal PR and realize you're really not that much of a degenerate
	mood_change = -4
	timeout = 2 MINUTES

/datum/mood_event/jittery
	description = "<span class='warning'>Jestem zdenerwowany i spięty, nie mogę ustać w miejscu!!</span>\n"
	mood_change = -2

/datum/mood_event/vomit
	description = "<span class='warning'>Właśnie zwymiotowałem. Fuj.</span>\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/vomitself
	description = "<span class='warning'>Właśnie zwymiotowałem na siebie. To obrzydliwe.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/painful_medicine
	description = "<span class='warning'>Lekarstwo może mi pomaga, ale teraz piecze jak diabli.</span>\n"
	mood_change = -5
	timeout = 60 SECONDS

/datum/mood_event/spooked
	description = "<span class='warning'>Ten grzechot kości... wciąż mnie prześladuje.</span>\n"
	mood_change = -4
	timeout = 4 MINUTES

/datum/mood_event/loud_gong
	description = "<span class='warning'>Ten głośny gong naprawdę zabolał mnie w uszy!</span>\n"
	mood_change = -3
	timeout = 2 MINUTES

/datum/mood_event/notcreeping
	description = "<span class='warning'>Głosy nie są zadowolone i boleśnie wykręcają moje myśli, bym wrócił do zadania.</span>\n"
	mood_change = -6
	timeout = 30
	hidden = TRUE

/datum/mood_event/notcreepingsevere//not hidden since it's so severe
	description = "<span class='boldwarning'>ONE POTRZEBUUUUUJĄ OBSESJIIIIII!!</span>\n"
	mood_change = -30
	timeout = 30

/datum/mood_event/notcreepingsevere/add_effects(name)
	var/list/unstable = list(name)
	for(var/i in 1 to rand(3,5))
		unstable += copytext_char(name, -1)
	var/unhinged = uppertext(unstable.Join(""))//example Tinea Luxor > TINEA LUXORRRR (with randomness in how long that slur is)
	description = "<span class='boldwarning'>ONE POTRZEBUUUUUJĄ: [unhinged]!!</span>\n"

/datum/mood_event/sapped
	description = "<span class='boldwarning'>Pochłania mnie jakiś niewytłumaczalny smutek...</span>\n"
	mood_change = -15
	timeout = 90 SECONDS

/datum/mood_event/back_pain
	description = "<span class='boldwarning'>Torby nigdy dobrze nie leżą mi na plecach, boli jak diabli!</span>\n"
	mood_change = -15

/datum/mood_event/sad_empath
	description = "<span class='warning'>Ktoś wydaje się zmartwiony...</span>\n"
	mood_change = -2
	timeout = 60 SECONDS

/datum/mood_event/sad_empath/add_effects(mob/sadtarget)
	description = "<span class='warning'>[sadtarget.name] wydaje się zmartwiony...</span>\n"

/datum/mood_event/sacrifice_bad
	description ="<span class='warning'>Te przeklęte dzikusy!</span>\n"
	mood_change = -5
	timeout = 2 MINUTES

/datum/mood_event/artbad
	description = "<span class='warning'>Z tyłka wyprodukowałem lepszą sztukę niż to.</span>\n"
	mood_change = -2
	timeout = 1200

/datum/mood_event/gates_of_mansus
	description = "<span class='boldwarning'>ŻYCIE W PRZEDSTAWIENIU JEST GORSZE NIŻ ŚMIERĆ</span>\n"
	mood_change = -25
	timeout = 4 MINUTES

//These are unused so far but I want to remember them to use them later
/datum/mood_event/cloned_corpse
	description = "<span class='boldwarning'>Niedawno widziałem własne zwłoki...</span>\n"
	mood_change = -6

/datum/mood_event/surgery
	description = "<span class='boldwarning'>ON MNIE KROI!!</span>\n"
	mood_change = -8

/datum/mood_event/nanite_sadness
	description = "<span class='warning robot'>+++++++TŁUMIENIE SZCZĘŚCIA+++++++</span>\n"
	mood_change = -7

/datum/mood_event/nanite_sadness/add_effects(message)
	description = "<span class='warning robot'>+++++++[message]+++++++</span>\n"

/datum/mood_event/sec_insulated_gloves
	description = "<span class='warning'>Wyglądam jak asystent...</span>\n"
	mood_change = -1

/datum/mood_event/burnt_wings
	description = "<span class='boldwarning'>MOJE CENNE SKRZYDŁA!!</span>\n"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/aquarium_negative
	description = "<span class='warning'>Wszystkie ryby zdechły...</span>\n"
	mood_change = -3
	timeout = 1.5 MINUTES

/datum/mood_event/feline_dysmorphia
	description = "<span class='boldwarning'>Jestem taki brzydki. Chciałbym być ładniejszy!</span>\n"
	mood_change = -10

/datum/mood_event/nervous
	description = "<span class='warning'>Jestem spięty... Muszę się ogarnąć.</span>\n"
	mood_change = -3
	timeout = 30 SECONDS

/datum/mood_event/paranoid
	description = "<span class='boldwarning'>Nie jestem bezpieczny! Nikomu nie mogę ufać!</span>\n"
	mood_change = -6
	timeout = 30 SECONDS
