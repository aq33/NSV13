//Snow Valley Areas//--

/area/awaymission/snowdin
	name = "Snowdin"
	icon_state = "awaycontent1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/awaymission/snowdin/outside
	name = "Snowdin Tundra Plains"
	icon_state = "awaycontent25"

/area/awaymission/snowdin/post
	name = "Snowdin Outpost"
	icon_state = "awaycontent2"
	requires_power = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowdin/post/medbay
	name = "Snowdin Outpost - Medbay"
	icon_state = "awaycontent3"

/area/awaymission/snowdin/post/secpost
	name = "Snowdin Outpost - Security Checkpoint"
	icon_state = "awaycontent4"

/area/awaymission/snowdin/post/hydro
	name = "Snowdin Outpost - Hydroponics"
	icon_state = "awaycontent5"

/area/awaymission/snowdin/post/messhall
	name = "Snowdin Outpost - Mess Hall"
	icon_state = "awaycontent6"

/area/awaymission/snowdin/post/gateway
	name = "Snowdin Outpost - Gateway"
	icon_state = "awaycontent7"

/area/awaymission/snowdin/post/dorm
	name = "Snowdin Outpost - Dorms"
	icon_state = "awaycontent8"

/area/awaymission/snowdin/post/kitchen
	name = "Snowdin Outpost - Kitchen"
	icon_state = "awaycontent9"

/area/awaymission/snowdin/post/engineering
	name = "Snowdin Outpost - Engineering"
	icon_state = "awaycontent10"

/area/awaymission/snowdin/post/custodials
	name = "Snowdin Outpost - Custodials"
	icon_state = "awaycontent11"

/area/awaymission/snowdin/post/research
	name = "Snowdin Outpost - Research Area"
	icon_state = "awaycontent12"

/area/awaymission/snowdin/post/garage
	name = "Snowdin Outpost - Garage"
	icon_state = "awaycontent13"

/area/awaymission/snowdin/post/minipost
	name = "Snowdin Outpost - Recon Post"
	icon_state = "awaycontent19"

/area/awaymission/snowdin/post/mining_main
	name = "Snowdin Outpost - Mining Post"
	icon_state = "awaycontent21"

/area/awaymission/snowdin/post/mining_main/mechbay
	name = "Snowdin Outpost - Mining Post Mechbay"
	icon_state = "awaycontent25"

/area/awaymission/snowdin/post/mining_main/robotics
	name = "Snowdin Outpost - Mining Post Robotics"
	icon_state = "awaycontent26"

/area/awaymission/snowdin/post/cavern1
	name = "Snowdin Outpost - Cavern Outpost 1"
	icon_state = "awaycontent27"

/area/awaymission/snowdin/post/cavern2
	name = "Snowdin Outpost - Cavern Outpost 2"
	icon_state = "awaycontent28"

/area/awaymission/snowdin/post/mining_dock
	name = "Snowdin Outpost - Underground Mine Post"
	icon_state = "awaycontent22"

/area/awaymission/snowdin/post/broken_shuttle
	name = "Snowdin Outpost - Broken Transit Shuttle"
	icon_state = "awaycontent20"
	requires_power = FALSE

/area/awaymission/snowdin/igloo
	name = "Snowdin Igloos"
	icon_state = "awaycontent14"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/snowdin/cave
	name = "Snowdin Caves"
	icon_state = "awaycontent15"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/snowdin/cave/cavern
	name = "Snowdin Depths"
	icon_state = "awaycontent23"

/area/awaymission/snowdin/cave/mountain
	name = "Snowdin Mountains"
	icon_state = "awaycontent24"


/area/awaymission/snowdin/base
	name = "Snowdin Main Base"
	icon_state = "awaycontent16"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = TRUE

/area/awaymission/snowdin/dungeon1
	name = "Snowdin Depths"
	icon_state = "awaycontent17"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowdin/sekret
	name = "Snowdin Operations"
	icon_state = "awaycontent18"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	requires_power = TRUE

/area/shuttle/snowdin/elevator1
	name = "Excavation Elevator"

/area/shuttle/snowdin/elevator2
	name = "Mining Elevator"

//liquid plasma!!!!!!//

/turf/open/floor/plasteel/dark/snowdin
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = 1
	initial_temperature = 180

/turf/open/lava/plasma
	name = "liquid plasma"
	desc = "A flowing stream of chilled liquid plasma. You probably shouldn't get in."
	icon_state = "liquidplasma"
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"
	baseturfs = /turf/open/lava/plasma
	slowdown = 2

	light_range = 3
	light_power = 0.75
	light_color = LIGHT_COLOR_PURPLE

/turf/open/lava/plasma/attackby(obj/item/I, mob/user, params)
	var/obj/item/reagent_containers/glass/C = I
	if(C.reagents.total_volume >= C.volume)
		to_chat(user, "<span class='danger'>[C] jest pełny.</span>")
		return
	C.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 10))
	user.visible_message("[user] nabiera trochę plazmy z [src] za pomocą [C].", "<span class='notice'>Nabierasz trochę plazmy z [src] za pomocą [C].</span>")

/turf/open/lava/plasma/burn_stuff(AM)
	. = 0

	if(is_safe())
		return FALSE

	var/thing_to_check = src
	if (AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(isobj(thing))
			var/obj/O = thing
			if((O.resistance_flags & (FREEZE_PROOF)) || O.throwing)
				continue

		else if (isliving(thing))
			. = 1
			var/mob/living/L = thing
			if(L.movement_type & FLYING)
				continue	//YOU'RE FLYING OVER IT
			if("snow" in L.weather_immunities)
				continue

			var/buckle_check = L.buckling
			if(!buckle_check)
				buckle_check = L.buckled
			if(isobj(buckle_check))
				var/obj/O = buckle_check
				if(O.resistance_flags & FREEZE_PROOF)
					continue

			else if(isliving(buckle_check))
				var/mob/living/live = buckle_check
				if("snow" in live.weather_immunities)
					continue

			L.adjustFireLoss(2)
			if(L)
				L.adjust_fire_stacks(20) //dipping into a stream of plasma would probably make you more flammable than usual
				L.adjust_bodytemperature(-rand(50,65)) //its cold, man
				if(ishuman(L))//are they a carbon?
					var/list/plasma_parts = list()//a list of the organic parts to be turned into plasma limbs
					var/list/robo_parts = list()//keep a reference of robotic parts so we know if we can turn them into a plasmaman
					var/mob/living/carbon/human/PP = L
					var/S = PP.dna.species
					if(istype(S, /datum/species/plasmaman) || istype(S, /datum/species/android)) //ignore plasmamen/robotic species
						continue

					for(var/BP in PP.bodyparts)
						var/obj/item/bodypart/NN = BP
						if(IS_ORGANIC_LIMB(NN) && NN.limb_id != "plasmaman") //getting every organic, non-plasmaman limb (augments/androids are immune to this)
							plasma_parts += NN
						if(!IS_ORGANIC_LIMB(NN))
							robo_parts += NN

					if(prob(35)) //checking if the delay is over & if the victim actually has any parts to nom
						PP.adjustToxLoss(15)
						PP.adjustFireLoss(25)
						if(plasma_parts.len)
							var/obj/item/bodypart/NB = pick(plasma_parts) //using the above-mentioned list to get a choice of limbs for dismember() to use
							PP.emote("scream")
							NB.limb_id = "plasmaman"//change the species_id of the limb to that of a plasmaman
							NB.no_update = TRUE
							NB.change_bodypart_status()
							PP.visible_message("<span class='warning'>[L] krzyczy z bólu, gdy [NB] topi mu się aż do kości!</span>", \
											  "<span class='userdanger'>Krzyczysz z bólu, gdy [NB] topi ci się aż do kości, zostawiając niesamowitą, plazmową poświatę tam, gdzie było ciało!</span>")
						if(!plasma_parts.len && !robo_parts.len) //a person with no potential organic limbs left AND no robotic limbs, time to turn them into a plasmaman
							PP.IgniteMob()
							PP.set_species(/datum/species/plasmaman)
							PP.visible_message("<span class='warning'>[L] wybucha jaskrawym fioletowym płomieniem, a z całego jego ciała zostaje szkielet!</span>", \
											  "<span class='userdanger'>Twoje zmysły drętwieją, gdy całe pozostałe ciało zmienia się w fioletową breję, spływa z ciebie i odsłania jedynie twoje kości, jaskrawo fioletowe!</span>")


/obj/vehicle/ridden/lavaboat/plasma
	name = "plasma boat"
	desc = "A boat used for traversing the streams of plasma without turning into an icecube."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	resistance_flags = FREEZE_PROOF
	can_buckle = TRUE
///////////	papers


/obj/item/paper/crumpled/ruins/snowdin/foreshadowing
	name = "scribbled note"
	default_raw_text = {"Coś tu poszło BARDZO nie tak. Jouslen w nocy mamrocze w swojej kajucie jakieś dziwne rzeczy i przy pracy zawsze wygląda na zmęczonego. Próbowałem z nim o tym pogadać, a on na mnie wybuchnął,
	 że mam pilnować własnego nosa. Zgłosiłem go oficerowi, powiedział, że się tym zajmie. Zostały nam tu jeszcze tylko 2 miesiące, zanim przeniosą nas do innego zadania, więc szybciej to nie zleci..."}

/obj/item/paper/crumpled/ruins/snowdin/misc1
	name = "Mission Prologue"
	default_raw_text = {"O kurwa, co za jazda! Te gnoje z Nanotrasen nawet nie wiedziały, co w nie trafiło! Cała piątka zrzuciła się prosto na kapitana, nawet nie zdążył krzyknąć! Weszliśmy i wyszliśmy z dyskiem w parę minut!
	Załoga nawet nie wiedziała, co się dzieje, dopóki nie odpalił alarm delta, a wtedy już nas nie było. Mamy skrzynkę do picia na drogę powrotną, żeby uczcić, kurewsko dobra robota!"}

/obj/item/paper/crumpled/ruins/snowdin/dontdeadopeninside
	name = "scribbled note"
	default_raw_text = {"Jeśli to czytasz: UCIEKAJ! Wydobycie tutaj odkopało coś, co kiedyś było uwięzione w warstwach lodu tej piekielnej dziury. Nadzorca i Jouslen zaginęli. Oficer
	 trzyma resztę z nas pod blokadą i przysięgam na Boga, że nocą ciągle słyszę dziwne dźwięki za ścianami. Połączenie przez bramę padło i bez dostaw z Centrali zostaliśmy
	 tu na śmierć. Od ekipy górniczej też nie mamy żadnych wieści, więc mogę tylko zakładać, że cokolwiek, kurwa, odkopali, dopadło najpierw ich, zanim przyjdzie po nas. Nie chcę tu umierać..."}

/obj/item/paper/fluff/awaymissions/snowdin/saw_usage
	name = "SAW Usage"
	default_raw_text = "WIDZIAŁEŚ IVAN, JAK TRZYMASZ PIŁA JAK PISTOLET, JESTEŚ SILNIEJSZY OD ODRZUTU ZE STRACHU, ŻE DOSTANIESZ W TWARZ!"

/obj/item/paper/fluff/awaymissions/snowdin/research_feed
	name = "Research Feed"
	default_raw_text = {"<i>Kartka pełna wykresów i innych szczegółowych informacji o aktywności sejsmicznej okolicy.</i>"}

//profile of each of the old crewmembers for the outpost

/obj/item/paper/fluff/awaymissions/snowdin/profile/overseer
	name = "Personnel Record AOP#01"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Caleb Reed<br><b>Wiek:</b>38<br><b>Płeć:</b>mężczyzna<br><b>Stanowisko na miejscu:</b>nadzorca placówki<br><br><center><b>Informacje</b></center><br><center>Caleb Reed prowadził kilka ekspedycji
	 na niezbadane planety w poszukiwaniu plazmy dla Nanotrasen, przeczesując wszystko od gorących sawann po mroźną Arktykę. Przebieg służby w miarę czysty, z jedynym incydentem: utratą dwóch badaczy podczas
	 ekspedycji <b>_______</b>, gdy niewłaściwe użycie materiałów wybuchowych do drążenia tuneli spowodowało zawał."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/sec1
	name = "Personnel Record AOP#02"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>James Reed<br><b>Wiek:</b>43<br><b>Płeć:</b>mężczyzna<br><b>Stanowisko na miejscu:</b>ochrona placówki<br><br><center><b>Informacje</b></center><br><center>James Reed należy
	 do sił ochrony Nanotrasen od ponad 20 lat, wstąpił w 22XX roku. Czysta kartoteka i niezachwiana lojalność wobec korporacji podczas licznych przydziałów w różnych miejscach czynią go cennym nabytkiem Nanotrasen,
	  gdy trzeba utrzymać spokój, stawiając na pierwszym miejscu prywatność Nanotrasen."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/hydro1
	name = "Personnel Record AOP#03"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Katherine Esterdeen<br><b>Wiek:</b>27<br><b>Płeć:</b>kobieta<br><b>Stanowisko na miejscu:</b>botaniczka placówki<br><br><center><b>Informacje</b></center><br><center>Katherine Esterdeen to świeża
	 absolwentka botaniki z doktoratem z ekologii. Z czystą kartoteką i chęcią do pracy wydaje się idealna do utrzymywania roślin pośrodku niczego."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/engi1
	name = "Personnel Record AOP#04"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Rachel Migro<br><b>Wiek:</b>35<br><b>Płeć:</b>kobieta<br><b>Stanowisko na miejscu:</b>inżynierka placówki<br><br><center><b>Informacje</b></center><br><center>Niedawno uzyskała certyfikat czeladnika na pełen etat; w ciągu ostatnich 5 lat Rachel
		przydzielano różne projekty budowlane. Kompetentna, bez wcześniejszych wykroczeń, nie powinna sprawiać kłopotów."}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research1
	name = "Personnel Record AOP#05"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Jacob Ullman<br><b>Wiek:</b>27<br><b>Płeć:</b>mężczyzna<br><b>Stanowisko na miejscu:</b>badacz placówki<br><br><center><b>Informacje</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research2
	name = "Personnel Record AOP#06"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Elizabeth Queef<br><b>Wiek:</b>28<br><b>Płeć:</b>kobieta<br><b>Stanowisko na miejscu:</b>badaczka placówki<br><br><center><b>Informacje</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/profile/research3
	name = "Personnel Record AOP#07"
	default_raw_text = {"<b><center>Akta personelu</b></center><br><br><b>Imię i nazwisko:</b>Jouslen McGee<br><b>Wiek:</b>38<br><b>Płeć:</b>mężczyzna<br><b>Stanowisko na miejscu:</b>badacz placówki<br><br><center><b>Informacje</b></center><br><center>"}

/obj/item/paper/fluff/awaymissions/snowdin/secnotice
	name = "Security Notice"
	default_raw_text = {"Przydzielono cię do tej arktycznej placówki, byś chronił mienie Nanotrasen i dbał o bezpieczeństwo kluczowych informacji, podczas gdy stacjonująca tu załoga przestrzega protokołu. Wybrany
		personel placówki przeszedł wstępną weryfikację i nie ma na koncie żadnych incydentów, ale na wypadek problemów dostajesz jedną celę i instrukcję skontaktowania się z Centralą w celu zlikwidowania
		winnego członka załogi."}

/obj/item/paper/fluff/awaymissions/snowdin/mining
	name = "Assignment Notice"
	default_raw_text = {"Ta zimna jak cholera planeta to współczesny odpowiednik trafienia na żyłę złota. Ogromne złoża plazmy i dosłownie strumienie plazmy płyną jaskiniami pod całym tym lodem, a my jesteśmy tu, żeby to wszystko wydobyć.\
	 Nanotrasen płaci od kilograma, więc do roboty, chłopaki!"}

/obj/item/paper/crumpled/ruins/snowdin/lootstructures
	name = "scribbled note"
	default_raw_text = {"W jaskini są porozrzucane jakieś ruiny, ich ściany wyglądają na zrobione z jakiejś supersprasowanej mieszanki lodu i śniegu. Te, które dotąd znaleźliśmy, już zabarykadowaliśmy,
	 bo ciągle słyszymy ze środka dziwne odgłosy. Zresztą jaki głupiec lekkomyślnie wbiegałby do starożytnych ruin pełnych potworów dla jakiegoś starego sprzętu?"}

/obj/item/paper/crumpled/ruins/snowdin/shovel
	name = "shoveling duties"
	default_raw_text = {"Śnieg zasypuje tu wszystko przez cały rok, a zimą jeszcze gorzej. Stała zmiana przy odśnieżaniu tego gówna sprzed śluz i utrzymywaniu ścieżek w miarę przejezdnych
	to dobry sposób, żeby nie utknąć w śniegu po kolana."}

//holo disk recording//--

/obj/item/disk/holodisk/snowdin/weregettingpaidright
	name = "Conversation #AOP#23"
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Jacob Ullman
	DELAY 10
	SAY Złapałeś już coś ciekawego na skanerach? Przez głębokie wiercenia za plazmą ciężko wyłapać cokolwiek poza bezużytecznym szumem.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY Nie. Od 2 tygodni karmię SI wynikami, żeby przesiała te śmieci, i nie widziałem nic niezwykłego, a przynajmniej niczego, czego szuka Nanotrasen.
	DELAY 45
	NAME Jacob Ullman
	DELAY 10
	SAY Tak myślałem. Nie wiem, co Nanotrasen spodziewa się tu znaleźć poza plazmą. Przynajmniej płacą nam za obijanie się przez parę miesięcy, kiedy SI odwala ciężką robotę.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY . . .
	DELAY 10
	SAY ...Płacą nam?
	DELAY 20
	NAME Jacob Ullman
	DELAY 10
	SAY ...Przecież nam płacą, prawda...?
	DELAY 15
	PRESET /datum/preset_holoimage/captain
	NAME Caleb Reed
	DELAY 10
	SAY Płacą doświadczeniem! To motto Nanotrasen!
	DELAY 30;"}

/obj/item/disk/holodisk/snowdin/welcometodie
	name = "Conversation #AOP#1"
	preset_image_type = /datum/preset_holoimage/corgi
	preset_record_text = {"
	NAME Friendly AI Unit
	DELAY 10
	SAY Dzień dobry! Witamy na Placówce Arktycznej *338-3**$$!
	DELAY 30
	SAY Wybrano cię spośród $)@! potencjalnych kandydatów na to stanowisko!
	DELAY 30
	SAY Nanotrasen z radością wita cię w jednej z wielu najnowocześniejszych placówek badawczych w sektorze $%@!!!
	DELAY 30
	SAY Dalsze informacje o przydziale znajdziesz w lokalnym posterunku ochrony! Bezpiecznego dnia!
	DELAY 20;"}

/obj/item/disk/holodisk/snowdin/overrun
	name = "Conversation #AOP#55"
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
	NAME James Reed
	DELAY 10
	SAY Jezu Chryste, co to jest??
	DELAY 30
	PRESET /datum/preset_holoimage/researcher
	NAME Elizabeth Queef
	DELAY 10
	SAY A skąd mam wiedzieć! Strzelaj w końcu!
	DELAY 30
	PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
	NAME James Reed
	DELAY 10
	SOUND sound/weapons/laser.ogg
	DELAY 10
	SOUND sound/weapons/laser.ogg
	DELAY 10
	SOUND sound/weapons/laser.ogg
	DELAY 10
	SOUND sound/weapons/laser.ogg
	DELAY 15
	SAY Idź! Zajmę to czymś, na południe stąd jest placówka z windą na powierzchnię.
	NAME Jacob Ullman
	PRESET /datum/preset_holoimage/researcher.
	DELAY 15
	Say I don't have to be told twice! Let's get the fuck out of here.
	DELAY 20;"}

/obj/item/disk/holodisk/snowdin/ripjacob
	name = "Conversation #AOP#62"
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Jacob Ullman
	DELAY 10
	SAY Wezwij windę. Nie mamy pojęcia, ile tych skurwieli tu jest, a ja wolałbym jak najszybciej zwiać z tej planety.
	DELAY 45
	NAME Elizabeth Queef
	DELAY 10
	SAY Nie musisz mi powtarzać, muszę tylko przeciągnąć kartę i...
	DELAY 15
	SOUND sound/effects/glassbr1.ogg
	DELAY 10
	SOUND sound/effects/glassbr2.ogg
	DELAY 15
	NAME Jacob Ullman
	DELAY 10
	SAY Co to KURWA było?
	DELAY 20
	SAY O KURWA, JEST ICH WIĘCEJ. WZYWAJ SZYBCIEJ, JEZU CHRYSTE.
	DELAY 20
	NAME Elizabeth Queef
	DELAY 10
	SAY NIE POGANIAJ MNIE, KURWA, DOBRA, JUŻ JEDZIE.
	DELAY 15
	SOUND sound/effects/huuu.ogg
	DELAY 5
	SOUND sound/effects/huuu.ogg
	DELAY 15
	SOUND sound/effects/woodhit.ogg
	DELAY 2
	SOUND sound/effects/bodyfall3.ogg
	DELAY 5
	SOUND sound/effects/meow1.ogg
	DELAY 15
	NAME Jacob Ullman
	DELAY 15
	SAY O KURWA, MA MNIE, JEZU CHRYYYyyyy-
	NAME Elizabeth Queef
	SAY AAAAAAAAAAAAAAAA PIERDOLĘ TO
	DELAY 15;"}

//lootspawners//--

/obj/effect/spawner/lootdrop/snowdin
	name = "why are you using this dummy"
	lootdoubles = 0
	lootcount = 1
	loot = list(/obj/item/bikehorn = 100)

/obj/effect/spawner/lootdrop/snowdin/dungeonlite
	name = "dungeon lite"
	loot = list(/obj/item/melee/classic_baton/police = 11,
				/obj/item/melee/classic_baton/police/telescopic = 12,
				/obj/item/book/granter/spell/smoke = 10,
				/obj/item/book/granter/spell/blind = 10,
				/obj/item/storage/firstaid/regular = 45,
				/obj/item/storage/firstaid/toxin = 35,
				/obj/item/storage/firstaid/brute = 27,
				/obj/item/storage/firstaid/fire = 27,
				/obj/item/storage/toolbox/syndicate = 12,
				/obj/item/grenade/plastic/c4 = 7,
				/obj/item/grenade/clusterbuster/smoke = 15,
				/obj/item/clothing/under/chameleon = 13,
				/obj/item/clothing/shoes/chameleon/noslip = 10,
				/obj/item/borg/upgrade/ddrill = 3,
				/obj/item/borg/upgrade/soh = 3)

/obj/effect/spawner/lootdrop/snowdin/dungeonmid
	name = "dungeon mid"
	loot = list(/obj/item/defibrillator/compact = 6,
				/obj/item/storage/firstaid/tactical = 35,
				/obj/item/shield/energy = 6,
				/obj/item/shield/riot/tele = 12,
				/obj/item/dnainjector/lasereyesmut = 7,
				/obj/item/gun/magic/wand/fireball/inert = 3,
				/obj/item/pneumatic_cannon = 15,
				/obj/item/melee/transforming/energy/sword = 7,
				/obj/item/book/granter/spell/knock = 15,
				/obj/item/book/granter/spell/summonitem = 20,
				/obj/item/book/granter/spell/forcewall = 17,
				/obj/item/storage/backpack/holding = 12,
				/obj/item/grenade/spawnergrenade/manhacks = 6,
				/obj/item/grenade/spawnergrenade/spesscarp = 7,
				/obj/item/grenade/clusterbuster/inferno = 3,
				/obj/item/stack/sheet/mineral/diamond{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/uranium{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/plasma{amount = 15} = 10,
				/obj/item/stack/sheet/mineral/gold{amount = 15} = 10,
				/obj/item/book/granter/spell/barnyard = 4,
				/obj/item/pickaxe/drill/diamonddrill = 6,
				/obj/item/borg/upgrade/vtec = 7,
				/obj/item/borg/upgrade/disablercooler = 7)


/obj/effect/spawner/lootdrop/snowdin/dungeonheavy
	name = "dungeon heavy"
	loot = list(/obj/item/singularityhammer = 25,
				/obj/item/mjollnir = 10,
				/obj/item/fireaxe = 25,
				/obj/item/organ/brain/alien = 17,
				/obj/item/dualsaber = 15,
				/obj/item/organ/heart/demon = 7,
				/obj/item/gun/ballistic/automatic/c20r/unrestricted = 16,
				/obj/item/gun/magic/wand/resurrection/inert = 15,
				/obj/item/gun/magic/wand/resurrection = 10,
				/obj/item/uplink/old = 2,
				/obj/item/book/granter/spell/charge = 12,
				/obj/item/grenade/clusterbuster/spawner_manhacks = 15,
				/obj/item/book/granter/spell/fireball = 10,
				/obj/item/pickaxe/drill/jackhammer = 30,
				/obj/item/borg/upgrade/syndicate = 13,
				/obj/item/borg/upgrade/selfrepair = 17)

/obj/effect/spawner/lootdrop/snowdin/dungeonmisc
	name = "dungeon misc"
	lootdoubles = 2
	lootcount = 1

	loot = list(/obj/item/stack/sheet/mineral/snow{amount = 25} = 10,
				/obj/item/toy/snowball = 15,
				/obj/item/shovel = 10,
				/obj/item/spear = 8,
				)

//special items//--

/obj/structure/barricade/wooden/snowed
	name = "crude plank barricade"
	desc = "This space is blocked off by a wooden barricade. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow"
	max_integrity = 125

/obj/item/clothing/under/syndicate/coldres
	name = "insulated tactical turtleneck"
	desc = "A nondescript and slightly suspicious-looking turtleneck with digital camouflage cargo pants. The interior has been padded with special insulation for both warmth and protection."
	armor = list("melee" = 20, "bullet" = 10, "laser" = 0,"energy" = 5, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 25, "acid" = 25, "stamina" = 30, "bleed" = 10)
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/combat/coldres
	name = "insulated combat boots"
	desc = "High speed, low drag combat boots, now with an added layer of insulation."
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

/obj/item/gun/magic/wand/resurrection/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/obj/effect/mob_spawn/human/syndicatesoldier/coldres
	name = "Syndicate Snow Operative"
	outfit = /datum/outfit/snowsyndie/corpse

/datum/outfit/snowsyndie/corpse
	name = "Syndicate Snow Operative Corpse"
	implants = null

/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive
	name = "sleeper"
	mob_name = "Operator Syndykatu ze śniegów"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	faction = FACTION_SYNDICATE
	outfit = /datum/outfit/snowsyndie
	short_desc = "Jesteś operatorem Syndykatu, niedawno wybudzonym z kriostazy w podziemnym posterunku."
	flavour_text = "Jesteś operatorem Syndykatu, niedawno wybudzonym z kriostazy w podziemnym posterunku. Monitoruj łączność Nanotrasen i zapisuj informacje. Wszystkich intruzów należy szybko zlikwidować, by żadne zebrane informacje nie zostały skradzione ani utracone. Staraj się nie oddalać zbytnio od posterunku, bo jaskinie mogą być śmiertelnie niebezpieczne nawet dla wyszkolonego operatora takiego jak ty."
	use_cooldown = TRUE

/datum/outfit/snowsyndie
	name = "Syndicate Snow Operative"
	uniform = /obj/item/clothing/under/syndicate/coldres
	shoes = /obj/item/clothing/shoes/combat/coldres
	ears = /obj/item/radio/headset/syndicate/alt
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	id = /obj/item/card/id/syndicate
	implants = list(/obj/item/implant/exile)


/obj/effect/mob_spawn/human/syndicatesoldier/coldres/alive/female
	mob_gender = FEMALE

//mobs//--

//ice spiders moved to giant_spiders.dm

//objs//--

/obj/structure/flora/rock/icy
	name = "icy rock"
	color = rgb(204,233,235)

/obj/structure/flora/rock/pile/icy
	name = "icey rocks"
	color = rgb(204,233,235)

//decals//--
/obj/effect/turf_decal/snowdin_station_sign
	icon_state = "AOP1"

/obj/effect/turf_decal/snowdin_station_sign/two
	icon_state = "AOP2"

/obj/effect/turf_decal/snowdin_station_sign/three
	icon_state = "AOP3"

/obj/effect/turf_decal/snowdin_station_sign/four
	icon_state = "AOP4"

/obj/effect/turf_decal/snowdin_station_sign/five
	icon_state = "AOP5"

/obj/effect/turf_decal/snowdin_station_sign/six
	icon_state = "AOP6"

/obj/effect/turf_decal/snowdin_station_sign/seven
	icon_state = "AOP7"

/obj/effect/turf_decal/snowdin_station_sign/up
	icon_state = "AOPU1"

/obj/effect/turf_decal/snowdin_station_sign/up/two
	icon_state = "AOPU2"

/obj/effect/turf_decal/snowdin_station_sign/up/three
	icon_state = "AOPU3"

/obj/effect/turf_decal/snowdin_station_sign/up/four
	icon_state = "AOPU4"

/obj/effect/turf_decal/snowdin_station_sign/up/five
	icon_state = "AOPU5"

/obj/effect/turf_decal/snowdin_station_sign/up/six
	icon_state = "AOPU6"

/obj/effect/turf_decal/snowdin_station_sign/up/seven
	icon_state = "AOPU7"
