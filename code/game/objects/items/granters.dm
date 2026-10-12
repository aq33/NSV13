
///books that teach things (intrinsic actions like bar flinging, spells like fireball or smoke, or martial arts)///

/obj/item/book/granter
	due_date = 0 // Game time in deciseconds
	unique = 1   // 0  Normal book, 1  Should not be treated as normal book, unable to be copied, unable to be modified
	var/list/remarks = list() //things to read about while learning.
	var/pages_to_mastery = 3 //Essentially controls how long a mob must keep the book in his hand to actually successfully learn
	var/reading = FALSE //sanity
	var/oneuse = TRUE //default this is true, but admins can var this to 0 if we wanna all have a pass around of the rod form book
	var/used = FALSE //only really matters if oneuse but it might be nice to know if someone's used it for admin investigations perhaps

/obj/item/book/granter/proc/turn_page(mob/user)
	playsound(user, pick('sound/effects/pageturn1.ogg','sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'), 30, 1)
	if(do_after(user,50, user))
		if(remarks.len)
			to_chat(user, "<span class='notice'>[pick(remarks)]</span>")
		else
			to_chat(user, "<span class='notice'>Czytasz dalej...</span>")
		return TRUE
	return FALSE

/obj/item/book/granter/proc/recoil(mob/user) //nothing so some books can just return

/obj/item/book/granter/proc/already_known(mob/user)
	return FALSE

/obj/item/book/granter/proc/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>Zaczynasz czytać [name]...</span>")

/obj/item/book/granter/proc/on_reading_stopped(mob/user)
	to_chat(user, "<span class='notice'>Przestajesz czytać...</span>")

/obj/item/book/granter/proc/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>Kończysz czytać [name]!</span>")

/obj/item/book/granter/proc/onlearned(mob/user)
	used = TRUE


/obj/item/book/granter/attack_self(mob/user)
	if(reading)
		to_chat(user, "<span class='warning'>Już to czytasz!</span>")
		return FALSE
	if(!user.can_read(src))
		return FALSE
	if(already_known(user))
		return FALSE
	if(used)
		if(oneuse)
			recoil(user)
		return FALSE
	on_reading_start(user)
	reading = TRUE
	for(var/i=1, i<=pages_to_mastery, i++)
		if(!turn_page(user))
			on_reading_stopped()
			reading = FALSE
			return
	if(do_after(user,50, user))
		on_reading_finished(user)
	reading = FALSE
	return TRUE

///ACTION BUTTONS///

/obj/item/book/granter/action
	var/granted_action
	var/actionname = "łapanie robaków" //might not seem needed but this makes it so you can safely name action buttons toggle this or that without it fucking up the granter, also caps

/obj/item/book/granter/action/already_known(mob/user)
	if(!granted_action)
		return TRUE
	for(var/datum/action/A in user.actions)
		if(A.type == granted_action)
			to_chat(user, "<span class='notice'>Już wiesz wszystko o tym: [actionname].</span>")
			return TRUE
	return FALSE

/obj/item/book/granter/action/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>Zaczynasz czytać o tym: [actionname]...</span>")

/obj/item/book/granter/action/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>Czujesz, że dobrze opanowujesz: [actionname]!</span>")
	var/datum/action/G = new granted_action
	G.Grant(user)
	onlearned(user)

/obj/item/book/granter/action/origami
	granted_action = /datum/action/innate/origami
	name = "The Art of Origami"
	desc = "A meticulously in-depth manual explaining the art of paper folding."
	icon_state = "origamibook"
	actionname = "origami"
	oneuse = TRUE
	remarks = list("Stabilność lotu bez napędu...", "Symetria zdaje się odgrywać dość dużą rolę...", "Uwzględnianie wiatru bocznego... serio?", "Współczynniki oporu różnych rodzajów papieru...", "Stosunek ciągu do masy?", "Dodatni kąt wzniosu?", "Środek ciężkości przed środkiem siły nośnej...")

/datum/action/innate/origami
	name = "Origami Folding"
	desc = "Toggles your ability to catch robust paper airplanes."
	button_icon_state = "origami_off"
	check_flags = NONE

/datum/action/innate/origami/Activate()
	to_chat(owner, "<span class='notice'>Teraz będziesz łapać papierowe samolociki.</span>")
	button_icon_state = "origami_on"
	active = TRUE
	UpdateButtonIcon()

/datum/action/innate/origami/Deactivate()
	to_chat(owner, "<span class='notice'>Już nie będziesz łapać papierowych samolocików.</span>")
	button_icon_state = "origami_off"
	active = FALSE
	UpdateButtonIcon()

///SPELLS///

/obj/item/book/granter/spell
	var/spell
	var/spellname = "przywołanie robaków"

/obj/item/book/granter/spell/already_known(mob/user)
	if(!spell)
		return TRUE
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == spell)
			if(user.mind)
				if(iswizard(user))
					to_chat(user,"<span class='notice'>Znasz to zaklęcie o wiele lepiej, niż może cię nauczyć ten marny poradnik.</span>")
				else
					to_chat(user,"<span class='notice'>Już to czytałeś.</span>")
			return TRUE
	return FALSE

/obj/item/book/granter/spell/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>Zaczynasz czytać o rzucaniu zaklęcia [spellname]...</span>")

/obj/item/book/granter/spell/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>Czujesz, że masz dość doświadczenia, by rzucić [spellname]!</span>")
	var/obj/effect/proc_holder/spell/S = new spell
	user.mind.AddSpell(S)
	user.log_message("learned the spell [spellname] ([S])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/spell/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] świeci czarnym światłem!</span>")

/obj/item/book/granter/spell/onlearned(mob/user)
	..()
	if(oneuse)
		user.visible_message("<span class='caution'>[src] na chwilę ciemnieje!</span>")

/obj/item/book/granter/spell/fireball
	spell = /obj/effect/proc_holder/spell/aimed/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."
	remarks = list("Celuj... CELUJ, GŁUPCZE!", "Samo podpalenie nie wystarczy...", "Uwzględnianie wiatru bocznego... serio?", "Chyba właśnie poparzyłem sobie rękę...", "Po co ta głupia poza? To tylko ruch dłoni...", "OMEE... ONI... Ech...", "Jaka jest różnica między kulą ognia a pyroblastem...")

/obj/item/book/granter/spell/fireball/recoil(mob/user)
	..()
	explosion(user.loc, 1, 0, 2, 3, FALSE, FALSE, 2, magic = TRUE)
	qdel(src)

/obj/item/book/granter/spell/sacredflame
	spell = /obj/effect/proc_holder/spell/targeted/sacred_flame
	spellname = "święty płomień"
	icon_state ="booksacredflame"
	desc = "Become one with the flames that burn within... and invite others to do so as well."
	remarks = list("Cóż, to jeden ze sposobów, by powstrzymać napastnika...", "Będę potrzebował dobrego sprzętu, żeby nie spłonąć na śmierć...", "Mieć pod ręką gaśnicę, jasne...", "Chyba właśnie poparzyłem sobie rękę...", "Przyłożyć płomień bezpośrednio do klatki piersiowej, by porządnie zapłonęło...", "Bez bólu nie ma efektów...", "Jedność z płomieniem...")

/obj/item/book/granter/spell/smoke
	spell = /obj/effect/proc_holder/spell/targeted/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."
	remarks = list("Bomba dymna! He...", "Bomba dymna też by się sprawdziła...", "Chwila, w chemii jest maszyna, która robi to samo?", "Ta książka okropnie śmierdzi...", "Po co te wszystkie żarty o zielsku? Po prostu powiedz, jak to rzucić...", "Wiatr zrujnuje całe zaklęcie, dobrze, że jesteśmy w kosmosie... Prawda?", "A więc tak robi to klan pająka...")

/obj/item/book/granter/spell/smoke/lesser //Chaplain smoke book
	spell = /obj/effect/proc_holder/spell/targeted/smoke/lesser

/obj/item/book/granter/spell/smoke/recoil(mob/user)
	..()
	to_chat(user,"<span class='caution'>Burczy ci w brzuchu...</span>")
	if(user.nutrition)
		user.set_nutrition(200)
		if(user.nutrition <= 0)
			user.set_nutrition(0)

/obj/item/book/granter/spell/blind
	spell = /obj/effect/proc_holder/spell/targeted/blind
	spellname = "blind"
	icon_state ="bookblind"
	desc = "This book looks blurry, no matter how you look at it."
	remarks = list("No nie nauczę się niczego, jak nie mogę tego cholerstwa przeczytać!", "Po co używać ciemnej czcionki na ciemnym tle...", "Ach, nic nie wid- Och, wszystko dobrze...", "Nie widzę własnej ręki...!", "Mrugam ręcznie, niech cię szlag, książko...", "Nie mogę przeczytać tej strony, ale jakimś cudem czuję, że czegoś się z niej nauczyłem...", "Hej, kto zgasił światło?")

/obj/item/book/granter/spell/blind/recoil(mob/user)
	..()
	to_chat(user,"<span class='warning'>Ślepniesz!</span>")
	user.blind_eyes(10)

/obj/item/book/granter/spell/mindswap
	spell = /obj/effect/proc_holder/spell/targeted/mind_transfer
	spellname = "mindswap"
	icon_state ="bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap //Used in used book recoils to store an identity for mindswaps
	remarks = list("Jeśli zamienisz się umysłem z myszą, po powrocie będzie bezbronna...", "Chwila, gdzie ja jestem...?", "Od tej książki strasznie boli mnie głowa...", "Ta strona jest pusta, ale czuję, jak w głowie pojawiają mi się słowa...", "GYNU... GYRO... Ech...", "Głosy w mojej głowie muszą przestać, próbuję tu czytać...", "Chyba nikt się nie ucieszy, kiedy rzucę to zaklęcie...")

/obj/item/book/granter/spell/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","barnyard","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/book/granter/spell/mindswap/recoil(mob/user)
	..()
	if(stored_swap in GLOB.dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user,"<span class='warning'>Przez chwilę czujesz, że nawet nie wiesz już, kim jesteś.</span>")
		return
	if(stored_swap == user)
		to_chat(user,"<span class='notice'>Wpatrujesz się jeszcze trochę w książkę, ale chyba nie ma tu już niczego do nauczenia...</span>")
		return
	var/obj/effect/proc_holder/spell/targeted/mind_transfer/swapper = new
	if(swapper.cast(list(stored_swap), user, TRUE, TRUE))
		to_chat(user,"<span class='warning'>Nagle jesteś gdzie indziej... i kimś innym?!</span>")
		to_chat(stored_swap,"<span class='warning'>Nagle znów wpatrujesz się w [src]... gdzie jesteś, kim jesteś?!</span>")
	else
		user.visible_message("<span class='warning'>[src] lekko syczy i przestaje świecić!</span>") //if the mind_transfer failed to transfer mobs, likely due to the target being catatonic.

	stored_swap = null

/obj/item/book/granter/spell/forcewall
	spell = /obj/effect/proc_holder/spell/targeted/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."
	remarks = list("Mogę przechodzić przez ściany! Super.", "Czemu tu tyle nawiązań do mimów...?", "Na korytarzu narobiłoby to sporo zamieszania...", "Zaskakująco silna magia jak na stworzenie ściany, przez którą nikt nie przejdzie...", "Po co ta głupia poza? To tylko ruch dłoni...", "Czemu te strony tak ciężko się przewraca, czy to w ogóle papier?", "Nie mogę się rus- Och, wszystko dobrze...")

/obj/item/book/granter/spell/forcewall/recoil(mob/living/user)
	..()
	to_chat(user,"<span class='warning'>Nagle czujesz się bardzo solidnie!</span>")
	user.Stun(40, ignore_canstun = TRUE)
	user.petrify(60)

/obj/item/book/granter/spell/knock
	spell = /obj/effect/proc_holder/spell/aoe_turf/knock
	spellname = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."
	remarks = list("Sezamie, otwórz się!", "A więc TO jest magiczne hasło!", "Zwolnij, książko. Jeszcze nie skończyłem tej strony...", "Ta książka nie przestaje się ruszać!", "Chyba to szkodzi grzbietowi książki...", "Nie mogę przejść do następnej strony, przykleiła się d- Dobra, sama się przewróciła.", "No tak, laska drzwi robi to samo. Kto by pomyślał...")

/obj/item/book/granter/spell/knock/recoil(mob/living/user)
	..()
	to_chat(user,"<span class='warning'>Przewracasz się!</span>")
	user.Paralyze(40)

/obj/item/book/granter/spell/barnyard
	spell = /obj/effect/proc_holder/spell/targeted/barnyardcurse
	spellname = "barnyard"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."
	remarks = list("Muuuuuuuu!","Muu!","Muuuu!", "NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!", "Chrum!", "Kwiiiiiiii!", "Chrum chrum!", "Iii!!", "Iiii!!", "REEE!!", "REEEEE!!")

/obj/item/book/granter/spell/barnyard/recoil(mob/living/carbon/user)
	if(ishuman(user))
		to_chat(user,"<font size='15' color='red'><b>KONIK POWSTAŁ</b></font>")
		var/obj/item/clothing/magichead = new /obj/item/clothing/mask/horsehead/cursed(user.drop_location())
		if(!user.dropItemToGround(user.wear_mask))
			qdel(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, ITEM_SLOT_MASK, TRUE, TRUE)
		qdel(src)
	else
		to_chat(user,"<span class='notice'>Mówię ci: iiihaaa</span>") //It still lives here

/obj/item/book/granter/spell/charge
	spell = /obj/effect/proc_holder/spell/targeted/charge
	spellname = "charge"
	icon_state ="bookcharge"
	desc = "This book is made of 100% postconsumer wizard."
	remarks = list("Czuję, że ŻYJĘ!", "CZUJĘ SMAK MANY!", "What a RUSH!", "PRZELATUJĘ przez te strony!", "TEN GENIUSZ TO ROBI!", "Ta książka jest PEŁNA AKCJI!", "ZROBIŁ TO", "JAZDAAAAAAAAAAA")

/obj/item/book/granter/spell/charge/recoil(mob/user)
	..()
	to_chat(user,"<span class='warning'>[src] nagle robi się bardzo ciepły!</span>")
	empulse(src, 1, 1, magic=TRUE)

/obj/item/book/granter/spell/summonitem
	spell = /obj/effect/proc_holder/spell/targeted/summonitem
	spellname = "natychmiastowe przywołanie"
	icon_state ="booksummons"
	desc = "This book is bright and garish, very hard to miss."
	remarks = list("Nie mogę oderwać wzroku od książki!", "Słowa zdają się skakać po stronie...", "Muszę się skupić tylko na jednym przedmiocie...", "Rzucając zaklęcie, trzeba go mocno trzymać...", "Zwolnij, książko. Jeszcze nie skończyłem tej strony...", "Brzmi świetnie w połączeniu z innymi magicznymi artefaktami...", "Iluzjoniści muszą to uwielbiać.")

/obj/item/book/granter/spell/summonitem/recoil(mob/user)
	..()
	to_chat(user,"<span class='warning'>[src] nagle znika!</span>")
	qdel(src)

/obj/item/book/granter/spell/random
	icon_state = "random_book"

/obj/item/book/granter/spell/random/Initialize(mapload)
	. = ..()
	var/static/banned_spells = list(/obj/item/book/granter/spell/mimery_blockade, /obj/item/book/granter/spell/mimery_guns)
	var/real_type = pick(subtypesof(/obj/item/book/granter/spell) - banned_spells)
	new real_type(loc)
	return INITIALIZE_HINT_QDEL

///MARTIAL ARTS///

/obj/item/book/granter/martial
	var/martial
	var/martialname = "bug jitsu"
	var/greet = "Czujesz, że opanowujesz sztukę psucia kodu. Dobra robota, palancie."


/obj/item/book/granter/martial/already_known(mob/user)
	if(!martial)
		return TRUE
	var/datum/martial_art/MA = martial
	if(user.mind.has_martialart(initial(MA.id)))
		to_chat(user,"<span class='warning'>Już znasz tę sztukę walki: [martialname]!</span>")
		return TRUE
	return FALSE

/obj/item/book/granter/martial/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>Zaczynasz czytać o sztuce walki: [martialname]...</span>")

/obj/item/book/granter/martial/on_reading_finished(mob/user)
	to_chat(user, "[greet]")
	var/datum/martial_art/MA = new martial
	MA.teach(user)
	user.log_message("learned the martial art [martialname] ([MA])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/martial/cqc
	martial = /datum/martial_art/cqc
	name = "old manual"
	martialname = "walka w zwarciu"
	desc = "A small, black manual. There are drawn instructions of tactical hand-to-hand combat."
	greet = "<span class='boldannounce'>Opanowujesz podstawy CQC.</span>"
	icon_state = "cqcmanual"
	remarks = list("Kopnięcie... Rzut...", "Dźwignia... Kopnięcie...", "Uderzaj w brzuch, szyję i plecy, by zadać krytyczne obrażenia...", "Rzut... Dźwignia...", "Pewnie dałoby się to połączyć z innymi sztukami walki!", "Słowa, które zabijają...", "Ostatnia i ostateczna chwila należy do ciebie...")

/obj/item/book/granter/martial/cqc/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		to_chat(user, "<span class='warning'>[src] złowieszczo pika...</span>")

/obj/item/book/granter/martial/cqc/recoil(mob/living/carbon/user)
	to_chat(user, "<span class='warning'>[src] explodes!</span>")
	playsound(src,'sound/effects/explosion1.ogg',40,1)
	user.flash_act(1, 1)
	user.adjustBruteLoss(6)
	user.adjustFireLoss(6)
	qdel(src)

/obj/item/book/granter/martial/carp
	martial = /datum/martial_art/the_sleeping_carp
	name = "mysterious scroll"
	martialname = "śpiący karp"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>Poznajesz starożytną sztukę walki Śpiącego Karpia! Twoja walka wręcz staje się znacznie skuteczniejsza i potrafisz odbijać wszelkie wymierzone w ciebie pociski. Nie możesz jednak używać broni dystansowej. Więcej o swojej nowej sztuce dowiesz się z czasownika Recall Teachings w zakładce Sleeping Carp.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("Muszę dowieść mistrzom śpiącego karpia, że jestem godzien...", "Postawa to wszystko...", "Skup się... a w kilka sekund obezwładnisz każdego wroga...", "Muszę przebijać pancerz, by zadawać maksymalne obrażenia...", "Chyba nie da się tego połączyć z innymi sztukami walki...", "Najpierw ich złap, żeby nie oddali...", "Muszę dowieść, że jestem godzien tej mocy...")

/obj/item/book/granter/martial/carp/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/book/granter/martial/tribal_claw
	martial = /datum/martial_art/tribal_claw
	name = "old scroll"
	martialname = "plemienny pazur"
	desc = "A scroll filled with ancient draconic markings."
	greet = "<span class='sciradio'>Poznajesz starożytną sztukę walki Plemiennego Pazura! Potrafisz teraz o wiele lepiej używać w walce ogona i pazurów. Dostępne kombinacje sprawdzisz czasownikiem Recall Teachings w zakładce Tribal Claw</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("Muszę dowieść mistrzom klanu Knoises, że jestem godzien...", "Użyj ogona, by zaskoczyć każdego wroga...", "Twoje ostre pazury mogą ich zdezorientować...", "Chyba nie da się tego połączyć z innymi sztukami walki...", "Uga buga...")

/obj/item/book/granter/martial/tribal_claw/onlearned(mob/living/carbon/user)
	..()
	if(!oneuse)
		return
	desc = "It's completely blank."
	name = "empty scroll"
	icon_state = "blankscroll"

/obj/item/book/granter/martial/tribal_claw/already_known(mob/user)
	if(islizard(user))
		return FALSE
	else
		to_chat(user, "<span class='warning'>Próbujesz przeczytać zwój, ale nic z niego nie rozumiesz.</span>")
		return TRUE

/obj/item/book/granter/martial/plasma_fist
	martial = /datum/martial_art/plasma_fist
	name = "frayed scroll"
	martialname = "plazmowa pięść"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	greet = "<span class='boldannounce'>Poznajesz starożytną sztukę walki Plazmowej Pięści. Twoje kombinacje są niezwykle trudne do wykonania, ale obejmują jedne z najbardziej śmiercionośnych ciosów, jakie widziano, w tym plazmową pięść, która po udanym wykonaniu sprawia, że przeciwnik gwałtownie eksploduje.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	remarks = list("Równowaga...", "Siła...", "Kontrola...", "Mistrzostwo...", "Czujność...", "Umiejętność...")

/obj/item/book/granter/martial/plasma_fist/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/book/granter/martial/karate
	martial = /datum/martial_art/karate
	name = "dusty scroll"
	martialname = "karate"
	desc = "A dusty scroll filled with martial lessons. There seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>Poznajesz starożytną sztukę walki Karate! Twoja walka wręcz staje się skuteczniejsza, ale kombinacje wymagają umiejętności. Więcej o swojej nowej sztuce dowiesz się z czasownika Recall Teachings w zakładce Karate.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("Muszę dowieść mistrzom Karate, że jestem godzien...", "Unieruchom im nogi, żeby nie uciekli...", "Uderzaj w punkty nacisku, by oszołomić wrogów...", "Nadepnij na głowę, by zadać maksymalne obrażenia...", "Chyba nie da się tego połączyć z innymi sztukami walki...", "Pozbaw ich tchu kolanem z wyskoku...", "Muszę ćwiczyć, by w pełni pojąć te nauki...")

/obj/item/book/granter/martial/karate/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

// I did not include mushpunch's grant, it is not a book and the item does it just fine.

//Crafting Recipe books

/obj/item/book/granter/crafting_recipe
	var/list/crafting_recipe_types = list()

/obj/item/book/granter/crafting_recipe/on_reading_finished(mob/user)
	. = ..()
	if(!user.mind)
		return
	for(var/crafting_recipe_type in crafting_recipe_types)
		var/datum/crafting_recipe/R = crafting_recipe_type
		user.mind.teach_crafting_recipe(crafting_recipe_type)
		to_chat(user,"<span class='notice'>Uczysz się robić [initial(R.name)].</span>")

/obj/item/book/granter/crafting_recipe/cooking_sweets_101
	name = "Cooking Desserts 101"
	desc = "A cook book that teaches you some more of the newest desserts. AI approved, and a best seller on Honkplanet."
	crafting_recipe_types = list(
		/datum/crafting_recipe/food/mimetart,
		/datum/crafting_recipe/food/berrytart,
		/datum/crafting_recipe/food/cocoalavatart,
		/datum/crafting_recipe/food/clowncake,
		/datum/crafting_recipe/food/vanillacake
	)
	icon_state = "cooking_learing_sweets"
	oneuse = FALSE
	remarks = list("A więc tak robi się lukier!", "Owoce na wierzchu? Jakie proste...", "Hm, przekładanie ciasta wydaje się trudniejsze...", "Ta książka pachnie cukierkami", "Tę stronę musiał zrobić klaun albo zapomniano sprawdzić pisownię przed drukiem...", "Chwila, da się ugotować szlam tak, żeby był bezpieczny?")
