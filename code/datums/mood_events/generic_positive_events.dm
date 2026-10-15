/datum/mood_event/hug
	description = "<span class='nicegreen'>Przytulasy są miłe.</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/betterhug
	description = "<span class='nicegreen'>Ktoś był dla mnie bardzo miły.</span>\n"
	mood_change = 3
	timeout = 4 MINUTES

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] był dla mnie bardzo miły.</span>\n"

/datum/mood_event/besthug
	description = "<span class='nicegreen'>Przebywanie z kimś jest wspaniałe, sprawia, że jestem taki szczęśliwy!</span>\n"
	mood_change = 5
	timeout = 4 MINUTES

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "<span class='nicegreen'>Przebywanie z [friend.name] jest wspaniałe, sprawia, że jestem taki szczęśliwy!</span>\n"

/datum/mood_event/headpat
	description = "<span class='nicegreen'>Głaskanie po głowie jest cudowne!</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/arcade
	description = "<span class='nicegreen'>Przeszedłem grę na automacie!</span>\n"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/blessing
	description = "<span class='nicegreen'>Zostałem pobłogosławiony.</span>\n"
	mood_change = 3
	timeout = 8 MINUTES

/datum/mood_event/book_nerd
	description = "<span class='nicegreen'>Niedawno przeczytałem książkę.</span>\n"
	mood_change = 1
	timeout = 5 MINUTES

/datum/mood_event/exercise
	description = "<span class='nicegreen'>Ćwiczenia uwalniają endorfiny!</span>\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal
	description = "<span class='nicegreen'>Zwierzęta są urocze! Nie mogę przestać ich głaskać!</span>\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal/add_effects(mob/animal)
	description = "<span class='nicegreen'>[animal.name] jest uroczy! Nie mogę przestać go głaskać!</span>\n"

/datum/mood_event/animal_play
	description = "<span class='nicegreen'>Ojej, świetnie się bawi!</span>\n"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/animal_play/add_effects(mob/animal)
	description = "<span class='nicegreen'>Ojej, [animal.name] świetnie się bawi!</span>\n"

/datum/mood_event/honk
	description = "<span class='nicegreen'>Może klauni wcale nie są tacy źli. Honk!</span>\n"
	mood_change = 2
	timeout = 4 MINUTES

/datum/mood_event/perform_cpr
	description = "<span class='nicegreen'>Uratowanie komuś życia to dobre uczucie.</span>\n"
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/oblivious
	description = "<span class='nicegreen'>Co za piękny dzień.</span>\n"
	mood_change = 3

/datum/mood_event/jolly
	description = "<span class='nicegreen'>Bez szczególnego powodu jestem szczęśliwy.</span>\n"
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "<span class='nicegreen'>Mam cel i osiągnę go, choćby nie wiem co!</span>\n" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 4
	hidden = TRUE

/datum/mood_event/badass_antag
	description = "Jestem zajebistym twardzielem i wszyscy wokół o tym wiedzą. Tylko na nich spójrz; trzęsą się na samą myśl, że jestem w pobliżu."
	mood_change = 7
	hidden = TRUE
	special_screen_obj = "badass_sun"
	special_screen_replace = FALSE

/datum/mood_event/creeping
	description = "<span class='greentext'>Głosy wypuściły mój umysł ze swoich szponów! Znów czuję się wolny!</span>\n" //creeps get it when they are around their obsession
	mood_change = 18
	timeout = 3 SECONDS
	hidden = TRUE

/datum/mood_event/revolution
	description = "<span class='nicegreen'>NIECH ŻYJE REWOLUCJA!</span>\n"
	mood_change = 3
	hidden = TRUE

/datum/mood_event/cult
	description = "<span class='nicegreen'>Ujrzałem prawdę, chwała wszechmocnemu!</span>\n"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/determined
	description = "<span class='nicegreen'>Jestem zdeterminowany, by chronić moich przyjaciół.</span>\n"
	mood_change = 2
	hidden = TRUE

/datum/mood_event/heretics
	description = "<span class='nicegreen'>IM WYŻEJ SIĘ WZNOSZĘ, TYM WIĘCEJ WIDZĘ.</span>\n"
	mood_change = 10 //maybe being a cultist isn't that bad after all
	hidden = TRUE

/datum/mood_event/hivehost
	description = "<span class='nicegreen'>Nasza psychika się rozszerza, nasze wpływy rosną.</span>\n"
	mood_change = 5
	hidden = TRUE

/datum/mood_event/hiveawakened
	description = "<span class='nicegreen'>W końcu objawiono nam prawdziwy cel!</span>\n"
	mood_change =  2
	hidden = TRUE

/datum/mood_event/family_heirloom
	description = "<span class='nicegreen'>Moja rodzinna pamiątka jest bezpieczna przy mnie.</span>\n"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "<span class='nicegreen'>W tej muzyce jest coś kojącego.</span>\n"
	mood_change = 3
	timeout = 60 SECONDS

/datum/mood_event/chemical_euphoria
	description = "<span class='nicegreen'>He... hehehe... hehe...</span>\n"
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "<span class='nicegreen'>Śmiech to naprawdę najlepsze lekarstwo! Czy na pewno?</span>\n"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "<span class='nicegreen'>*WHEEZE*</span>\n"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/religiously_comforted
	description = "<span class='nicegreen'>Obecność osoby duchownej dodaje mi otuchy.</span>\n"
	mood_change = 3

/datum/mood_event/clownshoes
	description = "<span class='nicegreen'>Te buty to dziedzictwo klauna, nigdy nie chcę ich zdejmować!</span>\n"
	mood_change = 5

/datum/mood_event/sacrifice_good
	description ="<span class='nicegreen'>Bogowie są zadowoleni z tej ofiary!</span>\n"
	mood_change = 5
	timeout = 3 MINUTES

/datum/mood_event/artok
	description = "<span class='nicegreen'>Miło widzieć, że ludzie tworzą tu sztukę.</span>\n"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/artgood
	description = "<span class='nicegreen'>Co za skłaniające do myślenia dzieło. Zapamiętam je na długo.</span>\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/artgreat
	description = "<span class='nicegreen'>To dzieło sztuki było tak wspaniałe, że uwierzyłem w dobro ludzkości. To wiele mówi w takim miejscu.</span>\n"
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/bottle_flip
	description = "<span class='nicegreen'>Satysfakcjonujące było, jak ta butelka tak wylądowała.</span>\n"
	mood_change = 2
	timeout = 3 MINUTES

/datum/mood_event/hope_lavaland
	description = "<span class='nicegreen'>Co za osobliwy emblemat. Napawa mnie nadzieją na przyszłość.</span>\n"
	mood_change = 5

/datum/mood_event/holy_consumption
	description = "Doprawdy, to było jedzenie godne bogów!"
	mood_change = 1 // 1 + 5 from it being liked food makes it as good as jolly
	timeout = 3 MINUTES

/datum/mood_event/nanite_happiness
	description = "<span class='nicegreen robot'>+++++++WZMOCNIENIE SZCZĘŚCIA+++++++</span>\n"
	mood_change = 7

/datum/mood_event/nanite_happiness/add_effects(message)
	description = "<span class='nicegreen robot'>+++++++[message]+++++++</span>\n"

/datum/mood_event/poppy_pin
	description = "<span class='nicegreen'>Z dumą okazuję pamięć o wielu, którzy zginęli, bym mógł być wolny.</span>\n"
	mood_change = 1

/datum/mood_event/funny_prank
	description = "<span class='nicegreen'>To był zabawny psikus, klaunie!</span>\n"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0

/datum/mood_event/area/add_effects(list/param)
	mood_change = param[1]
	description = param[2]

/datum/mood_event/sec_black_gloves
	description = "<span class='nicegreen'>Wyglądam dobrze w czarnych rękawiczkach.</span>\n"
	mood_change = 1

/datum/mood_event/assistant_insulated_gloves
	description = "<span class='nicegreen'>W końcu mam w rękach dobrą parę rękawiczek!</span>\n"
	mood_change = 1

/datum/mood_event/aquarium_positive
	description = "<span class='nicegreen'>Oglądanie ryb w akwarium uspokaja.</span>\n"
	mood_change = 3
	timeout = 1.5 MINUTES

/datum/mood_event/toxoplasmosis
	description = "<span class='nicegreen'>Naprawdę lubię przebywać z kotami!</span>\n"
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/feline_mania
	description = "<span class='nicegreen'>JESTEM TAKI UROCZY, O MATKO!</span>\n"
	mood_change = 5

/datum/mood_event/brain_tumor_mannitol
	description = "<span class='nicegreen'>Mannitol uspokaja mój mózg.</span>\n"
	mood_change = 0
	timeout = 30 SECONDS

/datum/mood_event/brain_tumor_mannitol/New(mob/M, param)
	timeout = rand(30,60) SECONDS // makes the timing unreliable on your mood
	..()
