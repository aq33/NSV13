//ABILITIES

/datum/action/innate/horror
	background_icon_state = "bg_ecult"
	icon_icon = 'aquila/icons/mob/actions/actions_horror.dmi'
	var/blacklisted = FALSE //If the ability can't be mutated
	var/soul_price = 0 //How much souls the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/chemical_cost = 0 //How much chemicals the ability costs to use
	var/mob/living/simple_animal/horror/B //Horror holding the ability
	var/category  //category for when the ability is active, "horror" is for creature, "infest" is during infestation, "controlling" is when a horror is controlling a body

/datum/action/innate/horror/IsAvailable()
	if(!B)
		return
	if(!B.has_chemicals(chemical_cost))
		return
	. = ..()

/datum/action/innate/horror/mutate
	name = "Mutacja"
	desc = "Wykorzystaj pożarte dusze, by zmutować swoje zdolności."
	button_icon_state = "mutate"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/mutate/Activate()
	to_chat(usr, "<span class='velvet bold'>Skupiasz się na mutowaniu swojego ciała...</span>")
	B.ui_interact(usr)
	return TRUE

/datum/action/innate/horror/seek_soul
	name = "Szukaj duszy"
	desc = "Wyszukaj duszę na tyle słabą, byś mógł ją pożreć."
	button_icon_state = "seek_soul"
	blacklisted = TRUE
	category = list("horror","infest")

/datum/action/innate/horror/seek_soul/Activate()
	B.SearchTarget()

/datum/action/innate/horror/consume_soul
	name = "Pożryj duszę"
	desc = "Pożryj duszę swojego celu."
	button_icon_state = "consume_soul"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/consume_soul/Activate()
	B.ConsumeSoul()

/datum/action/innate/horror/talk_to_host
	name = "Rozmawiaj z nosicielem"
	desc = "Wyślij nosicielowi bezgłośną wiadomość."
	button_icon_state = "talk_to_host"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/talk_to_host/Activate()
	B.Communicate()

/datum/action/innate/horror/toggle_hide
	name = "Ukrywanie"
	desc = "Stań się niewidoczny dla zwykłego oka. Włączane i wyłączane."
	button_icon_state = "horror_hiding_false"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/toggle_hide/Activate()
	B.hide()
	button_icon_state = "horror_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/horror/talk_to_horror
	name = "Rozmawiaj z horrorem"
	desc = "Porozumiewaj się telepatycznie ze swoim horrorem."
	button_icon_state = "talk_to_horror"
	blacklisted = TRUE
	var/mob/living/O

/datum/action/innate/horror/talk_to_horror/IsAvailable()
	if(owner.stat == DEAD)
		return
	return TRUE

/datum/action/innate/horror/talk_to_horror/Activate()
	var/mob/living/O = owner
	O.horror_comm()

/datum/action/innate/horror/talk_to_brain
	name = "Rozmawiaj z uwięzionym umysłem"
	desc = "Porozumiewaj się telepatycznie z uwięzionym umysłem nosiciela."
	button_icon_state = "talk_to_trapped_mind"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/talk_to_brain/Activate()
	B.victim.trapped_mind_comm()

/datum/action/innate/horror/take_control
	name = "Przejmij kontrolę"
	desc = "Połącz się w pełni z mózgiem nosiciela."
	button_icon_state = "horror_brain"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/take_control/Activate()
	B.bond_brain()

/datum/action/innate/horror/give_back_control
	name = "Oddaj kontrolę"
	desc = "Oddaj kontrolę nad ciałem nosiciela."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/give_back_control/Activate()
	B.victim.release_control()

/datum/action/innate/horror/leave_body
	name = "Opuść nosiciela"
	desc = "Wypełznij z nosiciela."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/leave_body/Activate()
	B.release_victim()

/datum/action/innate/horror/make_chems
	name = "Wydziel chemikalia"
	desc = "Wstrzyknij chemikalia do krwiobiegu nosiciela."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "minidispenser"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/make_chems/Activate()
	B.secrete_chemicals()

/datum/action/innate/horror/scan_host
	name = "Skan nosiciela"
	desc = "Zbadaj ciało nosiciela i substancje w jego organizmie."
	icon_icon = 'icons/obj/device.dmi'
	button_icon_state = "health"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/scan_host/Activate()
	B.scan_host()

/datum/action/innate/horror/freeze_victim
	name = "Podcięcie ofiary"
	desc = "Podetnij ofiarę macką, ogłuszając ją na krótki czas."
	button_icon_state = "trip"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/freeze_victim/Activate()
	B.freeze_victim()
	UpdateButtonIcon()
	addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon)), 150)

/datum/action/innate/horror/freeze_victim/IsAvailable()
	if(world.time - B.used_freeze < 150)
		return FALSE
	else
		return ..()

//non-default abilities, can be mutated

/datum/action/innate/horror/tentacle
	name = "Wyhoduj mackę"
	desc = "Zmienia rękę nosiciela w mackę. Aktywacja kosztuje 50 chemikaliów."
	button_icon_state = "tentacle"
	chemical_cost = 50
	category = list("infest", "control")
	soul_price = 2

/datum/action/innate/horror/tentacle/IsAvailable()
	if(!active && !B.has_chemicals(chemical_cost))
		return
	return ..()

/datum/action/innate/horror/tentacle/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/horror/tentacle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/horror/tentacle/process()
	..()
	active = locate(/obj/item/horrortentacle) in B.victim
	UpdateButtonIcon()


/datum/action/innate/horror/tentacle/Activate()
	B.use_chemicals(50)
	B.victim.visible_message("<span class='warning'>Ręka [B.victim] wykręca się w macki!</span>", "<span class='notice'>Twoja ręka zmienia się w ogromną mackę. Obejrzyj ją, by poznać jej zastosowania.</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>Zmieniasz rękę [B.victim] w mackę!</span>")
	var/obj/item/horrortentacle/T = new
	B.victim.put_in_hands(T)
	return TRUE

/datum/action/innate/horror/tentacle/Deactivate()
	B.victim.visible_message("<span class='warning'>Macka [B.victim] zmienia się z powrotem w rękę!</span>", "<span class='notice'>Twoja macka znika!</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>Zmieniasz mackę [B.victim] z powrotem w rękę.</span>")
	for(var/obj/item/horrortentacle/T in B.victim)
		qdel(T)
	return TRUE

/datum/action/innate/horror/transfer_host
	name = "Przejdź do innego nosiciela"
	desc = "Przejdź bezpośrednio do innego nosiciela. Chwycenie go przyspiesza ten proces."
	button_icon_state = "transfer_host"
	category = list("infest", "control")
	soul_price = 1
	var/transferring = FALSE

/datum/action/innate/horror/transfer_host/proc/is_transferring(mob/living/carbon/C)
	return transferring && C.Adjacent(B.victim)

/datum/action/innate/horror/transfer_host/Activate()
	if(transferring)
		transferring = FALSE
		to_chat(src, "<span class='warning'>Rezygnujesz z opuszczenia nosiciela.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in range(1,B.victim))
		if(C!=B.victim && C.Adjacent(B.victim))
			choices += C

	if(!choices.len)
		return
	var/mob/living/carbon/C = choices.len > 1 ? input(owner,"Kogo chcesz zarazić?") in null|choices : choices[1]
	if(!C || !B)
		return
	if(!C.Adjacent(B.victim))
		return
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		to_chat(owner, "<span class='warning'>[C] nie ma głowy!</span>")
		return
	var/hasbrain = FALSE
	for(var/obj/item/organ/brain/X in C.internal_organs)
		hasbrain = TRUE
		break
	if(!hasbrain)
		to_chat(owner, "<span class='warning'>[C] nie ma mózgu!</span>")
		return
	if((!C.key || !C.mind) && C != B.target.current)
		to_chat(owner, "<span class='warning'>Umysł [C] nie reaguje. Spróbuj z kimś innym!</span>")
		return
	if(C.has_horror_inside())
		to_chat(owner, "<span class='warning'>[C] jest już zarażony!</span>")
		return

	to_chat(owner, "<span class='warning'>Odsuwasz macki od [B.victim] i zaczynasz przechodzić do [C]...</span>")
	var/delay = 30 SECONDS
	var/silent
	if(B.victim.pulling != C)
		silent = TRUE
	else
		switch(B.victim.grab_state)
			if(GRAB_PASSIVE)
				delay = 20 SECONDS
			if(GRAB_AGGRESSIVE)
				delay = 10 SECONDS
			if(GRAB_NECK)
				delay = 5 SECONDS
			else
				delay = 3 SECONDS

	transferring = TRUE
	if(!do_after(B.victim, delay, target = C, extra_checks = CALLBACK(src, PROC_REF(is_transferring), C)))
		to_chat(owner, "<span class='warning'>[C] się odsuwa i przejście zostaje przerwane!</span>")
		transferring = FALSE
		return
	transferring = FALSE
	if(!C || !B || !C.Adjacent(B.victim))
		return
	B.leave_victim()
	B.Infect(C)
	if(!silent)
		to_chat(C, "<span class='warning'>Coś oślizgłego wpełza ci do ucha!</span>")
		playsound(B, 'sound/effects/blobattack.ogg', 30, 1)

/datum/action/innate/horror/jumpstart_host
	name = "Wskrześ nosiciela"
	desc = "Przywróć nosiciela do życia."
	button_icon_state = "revive"
	category = list("infest")
	soul_price = 2

/datum/action/innate/horror/jumpstart_host/Activate()
	B.jumpstart()

/datum/action/innate/horror/view_memory
	name = "Przejrzyj wspomnienia"
	desc = "Odczytaj świeże wspomnienia nosiciela, w którym jesteś."
	button_icon_state = "view_memory"
	category = list("infest")
	soul_price = 1

/datum/action/innate/horror/view_memory/Activate()
	B.view_memory()

/datum/action/innate/horror/chameleon
	name = "Kameleonowa skóra"
	desc = "Dopasuj kolor skóry do otoczenia. Kosztuje 5 chemikaliów na tick i wstrzymuje ich regenerację. Atak całkowicie przerywa niewidzialność."
	button_icon_state = "horror_sneak_false"
	category = list("horror")
	soul_price = 1

/datum/action/innate/horror/chameleon/Activate()
	B.go_invisible()
	button_icon_state = "horror_sneak_[B.invisible ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/horror/lube_spill
	name = "Rozlanie smaru"
	desc = "Wirujesz i rozchlapujesz wokół siebie śliski smar. Aktywacja kosztuje 50 chemikaliów."
	button_icon_state = "lube_spill"
	chemical_cost = 50
	category = list("horror")
	soul_price = 2
	var/cooldown = 0

/datum/action/innate/horror/lube_spill/IsAvailable()
	if(cooldown > world.time || !B.has_chemicals(chemical_cost) || !B.can_use_ability())
		return
	return ..()

/datum/action/innate/horror/lube_spill/Activate()
	B.use_chemicals(chemical_cost)
	cooldown = world.time + 10 SECONDS
	UpdateButtonIcon()
	addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon)), 10 SECONDS)
	B.visible_message("<span class='warning'>[B] wiruje i rozrzuca wokół jakąś substancję!</span>", "<span class='notice'>Rozchlapujesz wokół siebie oleistą substancję!</span>")
	flick("horror_spin", B)
	playsound(B, 'sound/effects/blobattack.ogg', 25, 1)
	for(var/turf/open/t in range(1, B))
		if(prob(60) && B.Adjacent(t))
			t.MakeSlippery(TURF_WET_LUBE, 50)
	return TRUE

//UPGRADES
/datum/horror_upgrade
	var/name = "horror upgrade"
	var/desc = "This is an upgrade."
	var/id
	var/soul_price = 0 //How much souls an upgrade costs to buy
	var/mob/living/simple_animal/horror/B //Horror holding the upgrades

/datum/horror_upgrade/proc/unlock()
	if(!B)
		return
	apply_effects()
	qdel(src)
	return TRUE

/datum/horror_upgrade/New(owner)
	..()
	B = owner

/datum/horror_upgrade/proc/apply_effects()
	return

//Upgrades the knockdown ability
/datum/horror_upgrade/paralysis
	name = "Naelektryzowana macka"
	id = "paralysis"
	desc = "Wzmacnia zdolność podcinania ładunkiem elektrycznym, który pozbawia ofiarę przytomności."
	soul_price = 3

/datum/horror_upgrade/paralysis/apply_effects()
	var/datum/action/innate/horror/A = B.has_ability(/datum/action/innate/horror/freeze_victim)
	if(A)
		A.name = "Sparaliżuj ofiarę"
		A.desc = "Porażasz ofiarę naelektryzowaną macką."
		A.button_icon_state = "paralyze"
		B.update_action_buttons()

//Increases chemical regeneration rate by 2
/datum/horror_upgrade/chemical_regen
	name = "Wydajne gruczoły chemiczne"
	id = "chem_regen"
	desc = "Twoje gruczoły chemiczne pracują wydajniej. Zwiększa regenerację chemikaliów."
	soul_price = 2

/datum/horror_upgrade/chemical_regen/apply_effects()
	B.chem_regen_rate += 3

//Lets horror regenerate chemicals outside of a host
/datum/horror_upgrade/nohost_regen
	name = "Niezależne gruczoły chemiczne"
	id = "nohost_regen"
	desc = "Twoje gruczoły chemiczne stają się mniej pasożytnicze i regenerują chemikalia samodzielnie, bez nosiciela."
	soul_price = 2

//Lets horror regenerate health
/datum/horror_upgrade/regen
	name = "Regenerująca skóra"
	id = "regen"
	desc = "Twoja skóra przystosowuje się do obrażeń i powoli sama się regeneruje, z czasem lecząc rany."
	soul_price = 1

//Doubles horror's health pool
/datum/horror_upgrade/hp_up
	name = "Skóra nosorożca"  //Horror can....roll?
	id = "hp_up"
	desc = "Twoja skóra twardnieje jak skała, mocno zwiększając maksymalne zdrowie i szanse na przeżycie poza nosicielem."
	soul_price = 2

/datum/horror_upgrade/hp_up/apply_effects()
	B.health = round(min(B.maxHealth,B.health * 2))
	B.maxHealth = round(B.maxHealth * 2)

//Increases melee damage to 15 with increased effect on cyborgs
/datum/horror_upgrade/dmg_up
	name = "Ząbkowane zęby"
	id = "dmg_up"
	desc = "Twoje zęby stają się ząbkowane i zadają dodatkowe obrażenia. Efekt jest silniejszy przeciw cyborgom."
	soul_price = 2

/datum/horror_upgrade/dmg_up/apply_effects()
	B.attacktext = "miażdży"
	B.attack_sound = 'sound/weapons/pierce_slow.ogg' //chunky
	B.melee_damage += 5

//Expands the reagent selection horror can make
/datum/horror_upgrade/upgraded_chems
	name = "Zaawansowana synteza odczynników"
	id = "upgraded_chems"
	desc = "Pozwala syntetyzować w nosicielu adrenalinę, salicylic acid, oxandrolone, pentetic acid i rezadone."
	soul_price = 2

/datum/horror_upgrade/upgraded_chems/apply_effects()
	B.horror_chems += list(/datum/horror_chem/adrenaline,/datum/horror_chem/sal_acid,/datum/horror_chem/oxandrolone,/datum/horror_chem/pen_acid,/datum/horror_chem/rezadone)

//faster mind control
/datum/horror_upgrade/fast_control
	name = "Precyzyjne trąbki"
	id = "fast_control"
	desc = "Twoje trąbki stają się precyzyjniejsze, dzięki czemu wyraźnie szybciej przejmujesz kontrolę nad mózgiem nosiciela."
	soul_price = 2

//makes it longer for host to snap out of mind control
/datum/horror_upgrade/deep_control
	name = "Izolowane trąbki"
	id = "deep_control"
	desc = "Twoje trąbki zyskują izolację chroniącą przed impulsami nerwowymi. Nosicielowi trudniej odzyskać kontrolę nad ciałem."
	soul_price = 2
