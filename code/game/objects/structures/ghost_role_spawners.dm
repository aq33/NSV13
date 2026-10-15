//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	short_desc = "Jesteś świadomym ekosystemem, przykładem mistrzostwa nad życiem, jakie posiadali twoi twórcy."
	flavour_text = "Twoi panowie, życzliwi, jakimi byli, stworzyli niezliczone skarbce nasion i rozesłali je po całym wszechświecie na każdą planetę, jaką zdołali zbadać. Jesteś w jednym z takich skarbców. Twoim celem jest uprawiać i szerzyć życie wszędzie, gdzie się da, czekając na kontakt ze strony twórców. Szacowany czas ostatniego kontaktu: rozmieszczenie, 5000 tysiącleci temu."
	assignedrole = "Lifebringer"
	use_cooldown = TRUE
	banType = ROLE_LIFEBRINGER

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout","Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper")
	new_spawn.fully_replace_character_name(null,plant_name)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude" //You're a plant, partner
		H.update_body()

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.

/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	short_desc = "Jesteś popielnym wędrowcem. Twoje plemię czci Nekropolię."
	flavour_text = "Pustkowia to święta ziemia, a jej potwory to błogosławiona zdobycz. Widziałeś w oddali światła... zwiastują one przybycie obcych, którzy chcą rozerwać Nekropolię i jej domenę. Świeże ofiary dla twojego gniazda."
	assignedrole = "Ash Walker"
	var/datum/team/ashwalkers/team
	use_cooldown = TRUE
	banType = ROLE_ASHWALKER

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	to_chat(new_spawn, "<b>Zaciągaj zwłoki ludzi i bestii do swojego gniazda. Pochłonie je, tworząc więcej twoich pobratymców. Nie zostawiaj gniazda bez ochrony, broń go za cenę życia. Chwała Nekropolii!</b>")

	new_spawn.mind.add_antag_datum(/datum/antagonist/ashwalker, team)

	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude"
		H.update_body()
		H.fully_replace_character_name(null, H.dna.species.random_name(gender))

/obj/effect/mob_spawn/human/ash_walker/Initialize(mapload, datum/team/ashwalkers/ashteam)
	. = ..()
	var/area/A = get_area(src)
	team = ashteam
	if(A)
		notify_ghosts("W [A.name] jajo popielnego wędrowcy jest gotowe do wyklucia.", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

/datum/outfit/ashwalker
	name ="Ashwalker"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	short_desc = "Jesteś Wolnym Golemem. Twoja rodzina czci Wyzwoliciela."
	flavour_text = "W swej nieskończonej i boskiej mądrości uwolnił twój klan, by przemierzał gwiazdy, jednym oświadczeniem: \"No idźcie, róbcie, co chcecie.\" Choć jesteś związany z tym, kto cię stworzył, w twojej społeczności zwyczajowo powtarza się te same słowa nowo narodzonym golemom, by żaden golem nigdy więcej nie był zmuszany do służby."
	banType = ROLE_FREE_GOLEM

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("W [A.name] ukończono powłokę golema ([initial(species.prefix)]).", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(has_owner && creator)
		short_desc = "Jesteś golemem."
		flavour_text = "Poruszasz się powoli, ale jesteś wysoce odporny na ciepło i zimno oraz na tępe urazy. Nie możesz nosić ubrań, ale wciąż możesz używać większości narzędzi."
		important_info = "Służ [creator] i pomagaj mu w osiągnięciu jego celów za wszelką cenę."
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "Buduj powłoki golemów w autolatarce i karm je oczyszczonymi arkuszami minerałów, by ożywić! Zasadniczo jesteście pokojową grupą, chyba że ktoś was sprowokuje.")
	else
		new_spawn.mind.store_memory("<b>Służ [owner.real_name], swojemu twórcy.</b>")
		new_spawn.mind.enslave_mind_to_creator(owner)
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		H.set_cloned_appearance()
		if(!name)
			if(has_owner)
				H.fully_replace_character_name(null, "[initial(X.prefix)] Golem ([rand(1,999)])")
			else
				H.fully_replace_character_name(null, H.dna.species.random_name())
		else
			H.fully_replace_character_name(null, name)
	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/transfer_choice = alert("Przenieść swoją duszę do [src]? (Uwaga: twoje stare ciało umrze!)",,"Yes","No")
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(user)] golem-swapped into [src]")
		user.visible_message("<span class='notice'>Słabe światło opuszcza [user], przenika do [src] i go ożywia!</span>","<span class='notice'>Zostawiasz swoje stare ciało i przenosisz się do [src]!</span>")
		show_flavour = FALSE
		create(ckey = user.ckey,name = user.real_name)
		user.death()
		return

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"
	use_cooldown = FALSE


/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine
	use_cooldown = TRUE	//Only the roundstart free golems are
	banType = ROLE_FREE_GOLEM

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	mob_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "Utknąłeś na tej bezbożnej planecie-więzieniu dłużej, niż sięgasz pamięcią."
	flavour_text = "Każdego dnia ledwo wiążesz koniec z końcem, a między okropnymi warunkami w prowizorycznym schronieniu, wrogimi stworzeniami i popielnymi smokami nurkującymi z bezchmurnego nieba marzysz tylko o miękkiej trawie pod stopami i świeżym powietrzu Ziemi. Te myśli rozwiewa kolejne wspomnienie tego, jak się tu znalazłeś... "
	assignedrole = "Hermit"
	use_cooldown = TRUE
	banType = ROLE_HERMIT

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "byłeś asystentem [pick("handlarza bronią", "szkutnika", "kierownika doków")] na małej stacji handlowej kilka sektorów stąd. Zaatakowali najeźdźcy, a gdy dotarłeś do zatoki ewakuacyjnej, została tylko jedna kapsuła. Wziąłeś ją i odleciałeś sam, a tłum przerażonych twarzy przy drzwiach śluzy, gdy silniki twojej kapsuły ożyły i posłały cię do tego piekła, na zawsze wrył ci się w pamięć.</b>"
			outfit.uniform = /obj/item/clothing/under/misc/assistantformal
		if(2)
			flavour_text += "jesteś wygnańcem z Tiger Cooperative. Ich technologiczny fanatyzm sprawił, że zacząłeś kwestionować moc i wierzenia Egzolitów, a oni uznali cię za heretyka i poddali godzinom straszliwych tortur. Byłeś kilka godzin od egzekucji, gdy wysoko postawiony przyjaciel z Kooperatywy zdołał załatwić ci kapsułę, zakodował jej współrzędne docelowe i ją wystrzelił. Obudziłeś się ze stazy po wylądowaniu i od tamtej pory przeżywasz - ledwo."
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
			outfit.back = /obj/item/storage/backpack
		if(3)
			flavour_text += "byłeś lekarzem na jednej ze stacji kosmicznych Nanotrasen, ale porzuciłeś tyranię tej przeklętej korporacji i wszystko, co sobą reprezentowała. Z metaforycznego piekła trafiłeś do dosłownego, a mimo to tęsknisz za recyklingowanym powietrzem i ciepłymi podłogami tego, co zostawiłeś... ale i tak wolisz być tu niż tam."
			outfit.uniform = /obj/item/clothing/under/rank/medical/doctor
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
			outfit.shoes = /obj/item/clothing/shoes/sneakers/black
		if(4)
			flavour_text += "przyjaciele zawsze żartowali, że \"brakuje ci piątej klepki\", jak to <i>uprzejmie</i> ujmowali. Wygląda na to, że mieli rację, gdy podczas wycieczki po jednym z najnowocześniejszych ośrodków badawczych Nanotrasen siedziałeś sam w kapsule ratunkowej i zobaczyłeś czerwony przycisk. Był duży i błyszczący, i przyciągnął twój wzrok. Nacisnąłeś go i po przerażająco szybkiej, wielodniowej podróży wylądowałeś tutaj. Od tamtej pory zdążyłeś zmądrzeć i myślisz, że twoim dawnym przyjaciołom nie byłoby teraz do śmiechu."

/obj/effect/mob_spawn/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

//Broken rejuvenation pod: Spawns in animal hospitals in lavaland. Ghosts become disoriented interns and are advised to search for help.
/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken, and its occupant is comatose."
	mob_name = "a translocated vet"
	flavour_text = "Co...? Gdzie jesteś? Czemu służy to miejsce? To wciąż szpital dla zwierząt - powinieneś wiedzieć, jesteś tu stażystą od tygodni - ale ty tylko przykładałeś opatrunki na stłuczenia. Czemu to miejsce jest pełne zaawansowanego sprzętu medycznego? I co to za krzyki? Świat na zewnątrz jest wyludniony - dręczony ogniem i siarką. Ale złożyłeś przysięgę. Musisz ratować tych ludzi! Może nie masz fikuśnej maszyny do klonowania jak prawdziwy szpital, ale na pewno da się jakoś uratować tych ludzi narzędziami, które masz. Prawda?"
	assignedrole = "Translocated Vet"
	banType = ROLE_TRANSLOCATED_VET

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

//Prisoner containment sleeper: Spawns in crashed prison ships in lavaland. Ghosts become escaped prisoners and are advised to find a way out of the mess they've gotten themselves into.
/obj/effect/mob_spawn/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	mob_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	roundstart = FALSE
	death = FALSE
	short_desc = "Jesteś więźniem skazanym na ciężkie roboty w jednym z obozów pracy Nanotrasen, ale wygląda na to, że los ma wobec ciebie inne plany."
	flavour_text = "Dobrze. Wygląda na to, że twój statek się rozbił. Pamiętasz, że skazano cię za "
	assignedrole = "Escaped Prisoner"
	use_cooldown = TRUE
	banType = ROLE_LAVALAND_ESCAPED_PRISONER

/obj/effect/mob_spawn/human/prisoner_transport/special(mob/living/L)
	L.fully_replace_character_name(null,"NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/obj/effect/mob_spawn/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "zaniedbanie obowiązków", "kidnapping", "rażącą niekompetencję", "wielką kradzież", "współpracę z Syndykatem", \
	"kult zakazanego bóstwa", "relacje międzygatunkowe", "mutiny")
	flavour_text += "[pick(crimes)]. Ale niezależnie od tego, wygląda na to, że twoja zbrodnia nie ma teraz znaczenia. Nie wiesz, gdzie jesteś, ale wiesz, że to miejsce chce cię zabić, a ty nie zamierzasz zmarnować tej okazji. Znajdź sposób, by wydostać się z tego bałaganu i wrócić tam, gdzie twoje miejsce - do [pick("domu", "mieszkania", "statku", "stacji")]."

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


/obj/effect/mob_spawn/human/prisoner_transport/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	objectives = "Obsługuj odwiedzających gości razem z resztą personelu. Nie opuszczaj przydzielonego hotelu i zawsze pamiętaj: klient ma zawsze rację!"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	short_desc = "Jesteś członkiem personelu najwyższej klasy hotelu kosmicznego!"
	flavour_text = "Jesteś członkiem personelu najwyższej klasy hotelu kosmicznego! Obsługuj gości i uważaj, żeby kierownik cię nie zwolnił."
	important_info = "NIE opuszczaj hotelu"
	assignedrole = "Hotel Staff"
	use_cooldown = TRUE
	banType = ROLE_HOTEL_STAFF

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/exile/hotel)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	short_desc = "Jesteś strażnikiem pokoju."
	flavour_text = "Przydzielono cię do tego hotelu, byś chronił interesy firmy i utrzymywał spokój między gośćmi a personelem."
	important_info = "NIE opuszczaj hotelu, bo to podstawa do rozwiązania umowy."
	objectives = "Nie opuszczaj przydzielonego hotelu. Staraj się utrzymać spokój między personelem a gośćmi; jeśli to możliwe, zdecydowanie zaleca się nieśmiercionośne środki."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()

/obj/effect/mob_spawn/human/demonic_friend
	name = "Essence of friendship"
	desc = "Oh boy! Oh boy! A friend!"
	mob_name = "Demonic friend"
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	outfit = /datum/outfit/demonic_friend
	death = FALSE
	roundstart = FALSE
	random = TRUE
	id_job = "SuperFriend"
	id_access = "assistant"
	var/obj/effect/proc_holder/spell/targeted/summon_friend/spell
	var/datum/mind/owner
	assignedrole = "SuperFriend"
	banType = ROLE_DEMONIC_FRIEND

/obj/effect/mob_spawn/human/demonic_friend/Initialize(mapload, datum/mind/owner_mind, obj/effect/proc_holder/spell/targeted/summon_friend/summoning_spell)
	. = ..()
	owner = owner_mind
	if(!owner)
		return INITIALIZE_HINT_QDEL
	flavour_text = "Dostajesz wytchnienie od wieczności męki, by być przyjacielem [owner.name] przez jego krótkie śmiertelne życie."
	important_info = "Pamiętaj, że jeśli nie spełnisz oczekiwań [owner.name], może jedną myślą odesłać cię z powrotem do piekła. Śmierć [owner.name] również odeśle cię do piekła."
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("W [A.name] ukończono powłokę przyjaźni.", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)
	objectives = "Bądź przyjacielem [owner.name] i utrzymuj go przy życiu, żeby nie odesłano cię z powrotem do piekła."
	spell = summoning_spell


/obj/effect/mob_spawn/human/demonic_friend/special(mob/living/L)
	if(!QDELETED(owner.current) && owner.current.stat != DEAD)
		L.fully_replace_character_name(null,"[owner.name]'s best friend")
		soullink(/datum/soullink/oneway, owner.current, L)
		spell.friend = L
		spell.charge_counter = spell.charge_max
		L.mind.hasSoul = FALSE
		var/mob/living/carbon/human/H = L
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = worn.GetID()
		id.registered_name = L.real_name
		id.update_label()
	else
		to_chat(L, "<span class='userdanger'>Twój właściciel już nie żyje! Wkrótce zginiesz.</span>")
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob, dust), 150)) //Give em a few seconds as a mercy.

/datum/outfit/demonic_friend
	name = "Demonic Friend"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield) //No revolutionaries, he's MY friend.
	id = /obj/item/card/id


//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "Jesteś funkcjonariuszem ochrony pracującym dla Nanotrasen, stacjonującym na najnowocześniejszej stacji badawczej."
	flavour_text = "Mgliście pamiętasz, jak wbiegłeś do kapsuły kriogenicznej przed nadciągającą burzą radiacyjną. Ostatnie, co pamiętasz, to jak Sztuczny Program stacji mówi ci, że będziesz spał tylko osiem godzin. Gdy otwierasz oczy, wszystko wydaje się zardzewiałe i zniszczone, a wychodząc z kapsuły, czujesz narastający niepokój w żołądku. Działaj zespołowo z innymi ocalałymi i nie porzucaj ich."
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/assembly/flash/handheld
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldsec/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "Jesteś inżynierem pracującym dla Nanotrasen, stacjonującym na najnowocześniejszej stacji badawczej."
	flavour_text = "Mgliście pamiętasz, jak wbiegłeś do kapsuły kriogenicznej przed nadciągającą burzą radiacyjną. Ostatnie, co pamiętasz, to jak Sztuczny Program stacji mówi ci, że będziesz spał tylko osiem godzin. Gdy otwierasz oczy, wszystko wydaje się zardzewiałe i zniszczone, a wychodząc z kapsuły, czujesz narastający niepokój w żołądku. Działaj zespołowo z innymi ocalałymi i nie porzucaj ich."
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldeng/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "Jesteś naukowcem pracującym dla Nanotrasen, stacjonującym na najnowocześniejszej stacji badawczej."
	flavour_text = "<span class='big bold'> Mgliście pamiętasz, jak wbiegłeś do kapsuły kriogenicznej przed nadciągającą burzą radiacyjną. Ostatnie, co pamiętasz, to jak Sztuczny Program stacji mówi ci, że będziesz spał tylko osiem godzin. Gdy otwierasz oczy, wszystko wydaje się zardzewiałe i zniszczone, a wychodząc z kapsuły, czujesz narastający niepokój w żołądku. Działaj zespołowo z innymi ocalałymi i nie porzucaj ich."
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldsci/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate/space
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "Jesteś kosmicznym piratem."
	flavour_text = "Stacja odmówiła zapłaty za waszą ochronę. Chroń statek, wysysaj kredyty ze stacji i napadnij na nią po jeszcze więcej łupów."
	assignedrole = "Space Pirate"
	is_antagonist = TRUE
	var/rank = "Mate"

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"


/obj/effect/mob_spawn/human/gamer
	name = "gamer sleeper"
	desc = "A humming cryo pod."
	mob_name = "a gamer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "Jesteś osobą, która po prostu chce się dobrze bawić z przyjaciółmi."
	flavour_text = "Jak się tu znalazłem? Co to za miejsce? Ostatnie, co pamiętam, to szukanie miejsca do wynajęcia, żeby pograć ze znajomymi. Próba wyjścia po prostu ściąga mnie tu z powrotem, lepiej zostać i bronić Skarbca Przekąsek - jeśli stracimy pudełko z pizzą, pewnie umrzemy z głodu. Skoro zapasy jedzenia są nieograniczone, a ja świetnie się bawię, równie dobrze mogę zostać i się bawić."
	important_info = "Nie porzucaj przyjaciół i broń Skarbca Przekąsek, możesz zapraszać gości do wspólnej gry."
	outfit = /datum/outfit/hotelstaff
	assignedrole = "Gamer"

/obj/effect/mob_spawn/human/gamer/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()
