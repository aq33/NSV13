
GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians

#define GUARDIAN_HANDS_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("syczy")
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC)
	bubble_icon = "guardian"
	response_help  = "przenika przez"
	response_disarm = "macha rękami na"
	response_harm   = "uderza"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicbase"
	icon_living = "magicbase"
	icon_dead = "magicbase"
	speed = 0
	combat_mode = TRUE
	stop_automated_movement = 1
	movement_type = FLYING // Immunity to chasms and landmines, etc.
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "uderza"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	healable = FALSE //don't brusepack the guardian
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 15
	butcher_results = list(/obj/item/ectoplasm = 1)
	AIStatus = AI_OFF
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_on = FALSE
	hud_type = /datum/hud/guardian
	dextrous_hud_type = /datum/hud/dextrous/guardian //if we're set to dextrous, account for it.
	hardattacks = TRUE
	var/mutable_appearance/cooloverlay
	var/guardiancolor = "#ffffff"
	chat_color = "#ffffff"
	var/recolorentiresprite
	var/theme
	var/list/guardian_overlays[GUARDIAN_TOTAL_LAYERS]
	var/reset = 0 //if the summoner has reset the guardian already
	var/cooldown = 0
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/toggle_button_type = /atom/movable/screen/guardian/ToggleMode/Inactive //what sort of toggle button the hud uses
	var/playstyle_string = "<span class='holoparasite bold'>Jesteś standardowym Strażnikiem. Nie powinieneś istnieć!</span>"
	var/magic_fluff_string = "<span class='holoparasite'>Wyciągasz Kodera, symbol błędów i bugów. To nie powinno się zdarzyć! Zgłoś błąd!</span>"
	var/tech_fluff_string = "<span class='holoparasite'>SEKWENCJA STARTOWA ZAKOŃCZONA. WCZYTANO MODUŁ BŁĘDU. TO NIE POWINNO SIĘ ZDARZYĆ. Zgłoś błąd!</span>"
	var/carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP JAKIŚ STRASZNY BŁĄD WINNI SĄ KODERZY KARP KARP KARP</span>"
	var/hive_fluff_string = "<span class='holoparasite'>Masa wydaje się anomalią, nie powinna istnieć... Zgłoś błąd!</span>"

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, theme)
	GLOB.parasites += src
	updatetheme(theme)

	. = ..()

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/updatetheme(theme) //update the guardian's theme
	if(!theme)
		theme = pick("magic", "tech", "carp", "hive")
	switch(theme)//should make it easier to create new stand designs in the future if anyone likes that
		if("magic")
			name = "Guardian Spirit"
			real_name = "Guardian Spirit"
			bubble_icon = "guardian"
			icon_state = "magicbase"
			icon_living = "magicbase"
			icon_dead = "magicbase"
		if("tech")
			name = "Holoparasite"
			real_name = "Holoparasite"
			bubble_icon = "holo"
			icon_state = "techbase"
			icon_living = "techbase"
			icon_dead = "techbase"
		if("carp")
			name = "Holocarp"
			real_name = "Holocarp"
			bubble_icon = "holo"
			icon_state = "holocarp"
			icon_living = "holocarp"
			icon_dead = "holocarp"
			speak_emote = list("zgrzyta zębami")
			desc = "A mysterious fish that stands by its charge, ever vigilant."
			attack_sound = 'sound/weapons/bite.ogg'
			recolorentiresprite = TRUE
		if("hive")
			name = "Hivelord"
			real_name = "Hivelord"
			bubble_icon = "guardian"
			icon_state = "hivebase"
			icon_living = "hivebase"
			icon_dead = "hivebase"
			speak_emote = list("woła telepatycznie")
			desc = "A truly alien creature, it is a mass of unknown organic material, standing by its' owner's side."
			attack_sound = 'sound/weapons/pierce.ogg'
	if(!recolorentiresprite) //we want this to proc before stand logs in, so the overlay isn't gone for some reason
		cooloverlay = mutable_appearance(icon, theme)
		add_overlay(cooloverlay)

/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	..()
	if(mind)
		mind.name = "[real_name]"
	if(!summoner)
		to_chat(src, "<span class='holoparasite bold'>Z jakiegoś powodu nie masz przywoływacza. Natychmiast zgłoś ten błąd.</span>")
		return
	to_chat(src, "<span class='holoparasite'>Jesteś <b>[real_name]</b>, zobowiązany służyć [summoner.real_name].</span>")
	to_chat(src, "<span class='holoparasite'>Przyciskami na HUD-zie możesz się zmaterializować lub wrócić do swojego pana. Znajdziesz tam też przycisk do prywatnej rozmowy z nim.</span>")
	to_chat(src, "<span class='holoparasite'>Choć sam jesteś niezniszczalny, zginiesz, jeśli zginie [summoner.real_name], a część obrażeń, które otrzymasz, przejdzie na niego, bo żywisz się nim, by się utrzymać.</span>")
	to_chat(src, playstyle_string)
	guardiancustomize()

/mob/living/simple_animal/hostile/guardian/proc/guardiancustomize()
	guardianrecolor()
	guardianrename()

/mob/living/simple_animal/hostile/guardian/proc/guardianrecolor()
	guardiancolor = input(src,"Jaki chcesz mieć kolor?","Wybierz kolor","#ffffff") as color|null
	chat_color = guardiancolor
	if(!guardiancolor) //redo proc until we get a color
		to_chat(src, "<span class='warning'>Nieprawidłowy kolor, spróbuj ponownie.</span>")
		guardianrecolor()
		return
	if(!recolorentiresprite)
		cooloverlay.color = guardiancolor
		cut_overlay(cooloverlay) //we need to get our new color
		add_overlay(cooloverlay)
	else
		add_atom_colour(guardiancolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/guardian/proc/guardianrename()
	var/new_name = sanitize_name(reject_bad_text(stripped_input(src, "Jak chcesz się nazywać?", "Wybierz imię", real_name, MAX_NAME_LEN)))
	if(!new_name) //redo proc until we get a good name
		to_chat(src, "<span class='warning'>Nieprawidłowe imię, spróbuj ponownie.</span>")
		guardianrename()
		return
	visible_message("<span class='notice'>Twoje nowe imię, <span class='name'>[new_name]</span>, zakotwicza się w twoim umyśle.</span>")
	fully_replace_character_name(null, new_name)

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	. = ..()
	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if(!QDELETED(summoner))
		if(summoner.stat == DEAD)
			forceMove(summoner.loc)
			to_chat(src, "<span class='danger'>Twój przywoływacz nie żyje!</span>")
			visible_message("<span class='danger'><B>[src] umiera razem ze swoim użytkownikiem!</B></span>")
			summoner.visible_message("<span class='danger'><B>Ciało [summoner] zostaje całkowicie wyniszczone wysiłkiem podtrzymywania [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.dropItemToGround(W))
					qdel(W)
			summoner.dust()
			death(TRUE)
			qdel(src)
	else
		to_chat(src, "<span class='danger'>Twój przywoływacz nie żyje!</span>")
		visible_message("<span class='danger'><B>[src] umiera razem ze swoim użytkownikiem!</B></span>")
		death(TRUE)
		qdel(src)
	snapback()

/mob/living/simple_animal/hostile/guardian/get_stat_tab_status()
	var/list/tab_data = ..()
	if(summoner)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		tab_data["Zdrowie przywoływacza"] = GENERATE_STAT_TEXT("[resulthealth]%")
	if(cooldown >= world.time)
		tab_data["Odnowienie przywołania/odwołania"] = GENERATE_STAT_TEXT("[DisplayTimeText(cooldown - world.time)]")
	return tab_data

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	. = ..()
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "<span class='holoparasite'>Oddalasz się poza zasięg i zostajesz ściągnięty z powrotem! Możesz oddalić się od [summoner.real_name] najwyżej o [range] m!</span>")
			visible_message("<span class='danger'>[src] wraca do swojego użytkownika.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.loc)
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(!is_deployed())
		to_chat(src, "<span class='danger'><B>Musisz się zmaterializować, by atakować!</span></B>")
		return FALSE
	else
		return ..()

/mob/living/simple_animal/hostile/guardian/death()
	drop_all_held_items()
	..()
	if(summoner)
		to_chat(summoner, "<span class='danger'><B>Twój [name] jakoś zginął!</span></B>")
		summoner.death()

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>")

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	. = amount
	if(summoner)
		if(loc == summoner)
			return FALSE
		summoner.adjustBruteLoss(amount)
		if(amount > 0)
			to_chat(summoner, "<span class='danger'><B>Twój [name] jest atakowany! Otrzymujesz obrażenia!</span></B>")
			summoner.visible_message("<span class='danger'><B>Z [summoner] tryska krew, gdy [src] otrzymuje obrażenia!</B></span>")
			if(summoner.stat == UNCONSCIOUS)
				to_chat(summoner, "<span class='danger'><B>Twoje ciało w tym stanie nie wytrzymuje wysiłku podtrzymywania [src] i zaczyna się rozpadać!</span></B>")
				summoner.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner, "<span class='danger'><B>Twój [src] został wysadzony!</span></B>")
		summoner.gib()
	ghostize()
	qdel(src)

//HAND HANDLING

/mob/living/simple_animal/hostile/guardian/equip_to_slot(obj/item/I, slot)
	if(!slot)
		return FALSE
	if(!istype(I))
		return FALSE

	. = TRUE
	var/index = get_held_index_of_item(I)
	if(index)
		held_items[index] = null
		update_inv_hands()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.screen_loc = null // will get moved if inventory is visible
	I.forceMove(src)
	I.equipped(src, slot)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

/mob/living/simple_animal/hostile/guardian/proc/apply_overlay(cache_index)
	if((. = guardian_overlays[cache_index]))
		add_overlay(.)

/mob/living/simple_animal/hostile/guardian/proc/remove_overlay(cache_index)
	var/I = guardian_overlays[cache_index]
	if(I)
		cut_overlay(I)
		guardian_overlays[cache_index] = null

/mob/living/simple_animal/hostile/guardian/update_inv_hands()
	remove_overlay(GUARDIAN_HANDS_LAYER)
	var/list/hands_overlays = list()
	var/obj/item/l_hand = get_item_for_held_index(1)
	var/obj/item/r_hand = get_item_for_held_index(2)

	if(r_hand)
		hands_overlays += r_hand.build_worn_icon(default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand

	if(l_hand)
		hands_overlays +=  l_hand.build_worn_icon(default_layer = GUARDIAN_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand

	if(hands_overlays.len)
		guardian_overlays[GUARDIAN_HANDS_LAYER] = hands_overlays
	apply_overlay(GUARDIAN_HANDS_LAYER)

/mob/living/simple_animal/hostile/guardian/regenerate_icons()
	update_inv_hands()

//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest(forced)
	if(istype(summoner.loc, /obj/effect) || (cooldown > world.time && !forced))
		return FALSE
	if(loc == summoner)
		forceMove(summoner.loc)
		new /obj/effect/temp_visual/guardian/phase(loc)
		cooldown = world.time + 10
		reset_perspective()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return FALSE
	new /obj/effect/temp_visual/guardian/phase/out(loc)

	forceMove(summoner)
	cooldown = world.time + 10
	return TRUE

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	to_chat(src, "<span class='danger'><B>Nie masz innego trybu!</span></B>")


/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!light_on)
		to_chat(src, "<span class='notice'>Włączasz swoje światło.</span>")
		set_light_on(TRUE)
	else
		to_chat(src, "<span class='notice'>Wyłączasz swoje światło.</span>")
		set_light_on(FALSE)


/mob/living/simple_animal/hostile/guardian/verb/ShowType()
	set name = "Check Guardian Type"
	set category = "Guardian"
	set desc = "Check what type you are."
	to_chat(src, playstyle_string)

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if(summoner)
		var/input = stripped_input(src, "Wpisz wiadomość do swojego przywoływacza.", "Guardian", "")
		if(!input)
			return
		if(CHAT_FILTER_CHECK(input))
			to_chat(usr, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
			return
		input = treat_message_min(input)
		var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[guardiancolor]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

		to_chat(summoner, my_message)
		var/list/guardians = summoner.hasparasites()
		for(var/para in guardians)
			to_chat(para, my_message)
		for(var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [my_message]")

		src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Wpisz wiadomość do swojego strażnika.", "Message", "")
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return
	input = treat_message_min(input)
	var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasite bold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	to_chat(src, my_message)
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<font color=\"[G.guardiancolor]\"><b><i>[src]:</i></b></font> [preliminary_message]" )
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "[link] [my_message]")

	src.log_talk(input, LOG_SAY, tag="guardian")

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use per Guardian."

	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/P = para
		if(P.reset)
			guardians -= P //clear out guardians that are already reset
	if(guardians.len)
		var/mob/living/simple_animal/hostile/guardian/G = input(src, "Wybierz strażnika, którego chcesz zresetować", "Reset strażnika") as null|anything in sortNames(guardians)
		if(G)
			to_chat(src, "<span class='holoparasite'>Próbujesz zresetować osobowość <font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font>...</span>")
			var/list/mob/dead/observer/candidates = pollGhostCandidates("Chcesz zagrać jako [G.real_name] gracza [src.real_name]?", ROLE_HOLOPARASITE, null, 10 SECONDS)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				to_chat(G, "<span class='holoparasite'>Twój użytkownik cię zresetował, a twoje ciało przejął duch. Chyba nie był zadowolony z twojej pracy.</span>")
				to_chat(src, "<span class='holoparasite bold'>Twój <font color=\"[G.guardiancolor]\">[G.real_name]</font> został pomyślnie zresetowany.</span>")
				message_admins("[key_name_admin(C)] has taken control of ([ADMIN_LOOKUPFLW(G)])")
				G.ghostize(0)
				G.guardiancustomize() //give it a new color, to show it's a new person
				G.key = C.key
				G.reset = 1
				switch(G.theme)
					if("tech")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> jest teraz aktywny!</span>")
					if("magic")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> został przywołany!</span>")
					if("carp")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> został złowiony!</span>")
					if("hive")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> został stworzony z rdzenia!</span>")
				guardians -= G
				if(!guardians.len)
					remove_verb(/mob/living/proc/guardian_reset)
			else
				to_chat(src, "<span class='holoparasite'>Żaden duch nie chciał przejąć kontroli nad <font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font>. Na razie musisz z nim wytrzymać.</span>")
		else
			to_chat(src, "<span class='holoparasite'>Postanawiasz nie resetować [guardians.len > 1 ? "żadnego ze swoich strażników":"swojego strażnika"].</span>")
	else
		remove_verb(/mob/living/proc/guardian_reset)

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for(var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if(G.summoner == src)
			. += G

/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)


////////Creation

/obj/item/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "<span class='holoparasite'>Tasujesz talię...</span>"
	var/used_message = "<span class='holoparasite'>Wszystkie karty wydają się teraz puste.</span>"
	var/failure_message = "<span class='holoparasite bold'>...I wyciągasz kartę! To... pusta karta? Może spróbuj później.</span>"
	var/ling_failure = "<span class='holoparasite bold'>Talia nie chce odpowiadać istocie bez duszy, takiej jak ty.</span>"
	var/list/possible_guardians = list("Assassin", "Chaos", "Charger", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")
	var/random = TRUE
	var/allowmultiple = FALSE
	var/allowling = TRUE
	var/allowguardian = FALSE

/obj/item/guardiancreator/attack_self(mob/living/user)
	if(isguardian(user) && !allowguardian)
		to_chat(user, "<span class='holoparasite'>Łańcuchy ([mob_name]) są niedozwolone.</span>")
		return
	var/list/guardians = user.hasparasites()
	if(guardians.len && !allowmultiple)
		to_chat(user, "<span class='holoparasite'>Już masz: [mob_name]!</span>")
		return
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling) && !allowling)
		to_chat(user, "[ling_failure]")
		return
	if(used == TRUE)
		to_chat(user, "[used_message]")
		return
	used = TRUE
	to_chat(user, "[use_message]")
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Chcesz zagrać jako [mob_name] gracza [user.real_name]?", ROLE_HOLOPARASITE, null, 10 SECONDS)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		spawn_guardian(user, C.key)
	else
		to_chat(user, "[failure_message]")
		used = FALSE


/obj/item/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/guardiantype = "Standard"
	if(random)
		guardiantype = pick(possible_guardians)
	else
		guardiantype = input(user, "Wybierz rodzaj: [mob_name]", "[mob_name] Creation") as null|anything in sortList(possible_guardians)
		if(!guardiantype)
			to_chat(user, "[failure_message]" )
			used = FALSE
			return
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(guardiantype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

		if("Lightning")
			pickedtype = /mob/living/simple_animal/hostile/guardian/beam

		if("Protector")
			pickedtype = /mob/living/simple_animal/hostile/guardian/protector

		if("Charger")
			pickedtype = /mob/living/simple_animal/hostile/guardian/charger

		if("Assassin")
			pickedtype = /mob/living/simple_animal/hostile/guardian/assassin

		if("Dextrous")
			pickedtype = /mob/living/simple_animal/hostile/guardian/dextrous

		if("Gravitokinetic")
			pickedtype = /mob/living/simple_animal/hostile/guardian/gravitokinetic

		if("Toy")
			pickedtype = /mob/living/simple_animal/hostile/guardian/toy

	var/list/guardians = user.hasparasites()
	if(guardians.len && !allowmultiple)
		to_chat(user, "<span class='holoparasite'>Już masz: [mob_name]!</span>" )
		used = FALSE
		return
	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user, theme)
	G.name = mob_name
	G.summoner = user
	G.key = key
	G.mind.enslave_mind_to_creator(user)
	log_game("[key_name(user)] has summoned [key_name(G)], a [guardiantype] holoparasite.")
	switch(theme)
		if("tech")
			to_chat(user, "[G.tech_fluff_string]")
			to_chat(user, "<span class='holoparasite'><b>[G.real_name]</b> jest teraz aktywny!</span>")
		if("magic")
			to_chat(user, "[G.magic_fluff_string]")
			to_chat(user, "<span class='holoparasite'><b>[G.real_name]</b> został przywołany!</span>")
		if("carp")
			to_chat(user, "[G.carp_fluff_string]")
			to_chat(user, "<span class='holoparasite'><b>[G.real_name]</b> został złowiony!</span>")
		if("hive")
			to_chat(user, "[G.hive_fluff_string]")
			to_chat(user, "<span class='holoparasite'><b>[G.real_name]</b> został stworzony z rdzenia!</span>")
	user.add_verb(/mob/living/proc/guardian_comm)
	user.add_verb(/mob/living/proc/guardian_recall)
	user.add_verb(/mob/living/proc/guardian_reset)

/obj/item/guardiancreator/choose
	random = FALSE

/obj/item/guardiancreator/toy
	name = "funny tarot card"
	desc = "An enchanted deck tarot card. This one looks like it was printed as a joke."
	icon_state = "deck_clown_empty"
	possible_guardians = list("Toy")
	custom_premium_price = 10000

/obj/item/guardiancreator/choose/dextrous
	possible_guardians = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")

/obj/item/guardiancreator/choose/wizard
	possible_guardians = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Gravitokinetic")
	allowmultiple = TRUE

/obj/item/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "<span class='holoparasite'>Zaczynasz uruchamiać iniektor...</span>"
	used_message = "<span class='holoparasite'>Iniektor został już użyty.</span>"
	failure_message = "<span class='holoparasite bold'>...BŁĄD. PRZERWANO SEKWENCJĘ STARTOWĄ. NIE UDAŁO SIĘ ZAINICJALIZOWAĆ SI. SKONTAKTUJ SIĘ Z POMOCĄ TECHNICZNĄ LUB SPRÓBUJ PÓŹNIEJ.</span>"
	ling_failure = "<span class='holoparasite bold'>Holoparazyty cofają się z przerażeniem. Nie chcą mieć nic wspólnego z taką istotą jak ty.</span>"

/obj/item/guardiancreator/tech/choose/traitor
	possible_guardians = list("Assassin", "Chaos", "Charger", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")
	allowling = FALSE

/obj/item/guardiancreator/tech/choose
	random = FALSE

/obj/item/guardiancreator/tech/choose/dextrous
	possible_guardians = list("Assassin", "Chaos", "Charger", "Dextrous", "Explosive", "Lightning", "Protector", "Ranged", "Standard", "Support", "Gravitokinetic")

/obj/item/guardiancreator/tech/toy
	name = "plastic holoparasite injector"
	desc = "a cheap replica of a real holoparasite injector."
	icon_state = "clown_hypo"
	possible_guardians = list("Toy")

/obj/item/paper/guides/antag/guardian
	name = "Holoparasite Guide"
	default_raw_text = {"<b>Lista typów holoparazytów</b><br><br><b>Assassin (zabójca)</b>: zadaje średnie obrażenia i otrzymuje pełne, ale potrafi się ukryć, przez co jego następny atak zadaje ogromne obrażenia i ignoruje pancerz. Po ataku z ukrycia przez chwilę nie może wrócić do użytkownika.<br><br><b>Chaos</b>: podpala wrogów dotykiem i sprawia, że widzą wszystkich wokół jako parazyta. Automatycznie gasi użytkownika, jeśli ten zacznie się palić.<br><br><b>Charger (szarżownik)</b>: porusza się niezwykle szybko, zadaje średnie obrażenia i potrafi szarżować na cele, raniąc pierwszy trafiony i zmuszając go do upuszczenia trzymanych przedmiotów.<br><br><b>Explosive (wybuchowy)</b>: wysoka odporność na obrażenia i średnio silny atak, który może wybuchowo teleportować cele. Potrafi zamienić dowolny obiekt, nawet zbyt duży do podniesienia, w bombę raniącą następną osobę, która go dotknie. Obiekt wraca do normy po zadziałaniu pułapki lub po pewnym czasie.<br><br><b>Lightning (błyskawica)</b>: ataki zakładają na cele łańcuchy błyskawic. Ma łańcuch błyskawic połączony z użytkownikiem. Łańcuchy razią prądem wszystko w pobliżu, zadając ciągłe obrażenia.<br><br><b>Protector (obrońca)</b>: w przeciwieństwie do innych parazytów to ty teleportujesz się do niego, gdy jesteś poza zasięgiem. Ma dwa tryby: bojowy, w którym zadaje i otrzymuje średnie obrażenia, oraz ochronny, w którym prawie nie zadaje ani nie otrzymuje obrażeń, ale porusza się nieco wolniej.<br><br><b>Ranged (dystansowy)</b>: ma dwa tryby. Dystansowy – wystrzeliwuje ciągły strumień słabych pocisków ignorujących pancerz. Zwiadowczy – nie może atakować, ale przenika przez ściany i jest trudny do zauważenia. W obu trybach może zastawiać sidła obserwacyjne, które ostrzegają go, gdy ktoś przez nie przejdzie.<br><br><b>Standard (standardowy)</b>: niszczycielskie ataki w zwarciu i wysoka odporność na obrażenia. Potrafi przebijać się przez słabe ściany.<br><br><b>Gravitokinetic (grawitokinetyczny)</b>: ataki nakładają na cel miażdżącą grawitację. Może też celować w podłoże, by spowolnić nadchodzących wrogów, ale wpływa to także na użytkownika.<br>
 <br>
"}

/obj/item/paper/guides/antag/guardian/update_icon()
	return

/obj/item/paper/guides/antag/guardian/wizard
	name = "Guardian Guide"
	default_raw_text = {"<b>Lista typów strażników</b><br><br><b>Assassin (zabójca)</b>: zadaje średnie obrażenia i otrzymuje pełne, ale potrafi się ukryć, przez co jego następny atak zadaje ogromne obrażenia i ignoruje pancerz. Po ataku z ukrycia przez chwilę nie może wrócić do użytkownika.<br><br><b>Chaos</b>: podpala wrogów dotykiem i sprawia, że widzą wszystkich wokół jako strażnika. Automatycznie gasi użytkownika, jeśli ten zacznie się palić.<br><br><b>Charger (szarżownik)</b>: porusza się niezwykle szybko, zadaje średnie obrażenia i potrafi szarżować na cele, raniąc pierwszy trafiony i zmuszając go do upuszczenia trzymanych przedmiotów.<br><br><b>Dexterous (zręczny)</b>: zadaje niewielkie obrażenia, ale potrafi trzymać przedmioty i przechowywać w sobie jeden z nich. Po powrocie do użytkownika upuszcza przedmioty trzymane w rękach, ale zachowuje ten schowany.<br><br><b>Explosive (wybuchowy)</b>: wysoka odporność na obrażenia i średnio silny atak, który może wybuchowo teleportować cele. Potrafi zamienić dowolny obiekt, nawet zbyt duży do podniesienia, w bombę raniącą następną osobę, która go dotknie. Obiekt wraca do normy po zadziałaniu pułapki lub po pewnym czasie.<br><br><b>Lightning (błyskawica)</b>: ataki zakładają na cele łańcuchy błyskawic. Ma łańcuch błyskawic połączony z użytkownikiem. Łańcuchy razią prądem wszystko w pobliżu, zadając ciągłe obrażenia.<br><br><b>Protector (obrońca)</b>: w przeciwieństwie do innych parazytów to ty teleportujesz się do niego, gdy jesteś poza zasięgiem. Ma dwa tryby: bojowy, w którym zadaje i otrzymuje średnie obrażenia, oraz ochronny, w którym prawie nie zadaje ani nie otrzymuje obrażeń, ale porusza się nieco wolniej.<br><br><b>Ranged (dystansowy)</b>: ma dwa tryby. Dystansowy – wystrzeliwuje ciągły strumień słabych pocisków ignorujących pancerz. Zwiadowczy – nie może atakować, ale przenika przez ściany i jest trudny do zauważenia. W obu trybach może zastawiać sidła obserwacyjne, które ostrzegają go, gdy ktoś przez nie przejdzie.<br><br><b>Standard (standardowy)</b>: niszczycielskie ataki w zwarciu i wysoka odporność na obrażenia. Potrafi przebijać się przez słabe ściany.<br><br><b>Gravitokinetic (grawitokinetyczny)</b>: ataki nakładają na cel miażdżącą grawitację. Może też celować w podłoże, by spowolnić nadchodzących wrogów, ale wpływa to także na użytkownika.<br>
 <br>
"}


/obj/item/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/storage/box/syndie_kit/guardian/PopulateContents()
	new /obj/item/guardiancreator/tech/choose/traitor(src)
	new /obj/item/paper/guides/antag/guardian(src)

/obj/item/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fishfingers"
	theme = "carp"
	mob_name = "Holocarp"
	use_message = "<span class='holoparasite'>Wkładasz paluszki rybne do ust...</span>"
	used_message = "<span class='holoparasite'>Ktoś już ugryzł te paluszki rybne! Fuj.</span>"
	failure_message = "<span class='holoparasite bold'>Nie udało ci się złowić żadnych duchów karpi z wód Jeziora Karpiowego. Może ich nie ma, a może coś spieprzyłeś.</span>"
	ling_failure = "<span class='holoparasite bold'>Karp'sie nie ma nic przeciwko zmiennokształtnym, więc nie powinieneś widzieć tej wiadomości.</span>"
	allowmultiple = TRUE

/obj/item/guardiancreator/carp/choose
	random = FALSE

/obj/item/guardiancreator/carp/toy
	possible_guardians = list("Toy")

/obj/item/storage/box/syndie_kit/carpian
	name = "Holocarp fishstick kit"

/obj/item/storage/box/syndie_kit/carpian/PopulateContents()
	new /obj/item/guardiancreator/carp/choose(src)
	new /obj/item/paper/guides/antag/guardian(src)


/obj/item/guardiancreator/hive
	name = "mysterious core"
	desc = "All that remains of a hivelord. It has a mysterious aura around it..."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "roro core 2"
	theme = "hive"
	mob_name = "Hivelord"
	use_message = "<span class='holoparasite'>Przykładasz rdzeń do serca...</span>"
	used_message = "<span class='holoparasite'>Ten rdzeń chyba się rozłożył i już nie działa...</span>"
	failure_message = "<span class='holoparasite bold'>Nie udało ci się zebrać rdzeniem żadnej masy, spróbuj później.</span>"
	ling_failure = "<span class='holoparasite bold'>Nawet mroczne energie nie chcą zbliżać się do twojego okropnego ciała.</span>"

/obj/item/guardiancreator/hive/choose
	random = FALSE
