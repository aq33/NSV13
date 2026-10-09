// AQUILA - Eldritch Horror, port of Yogstation#13033 with the later horror fixes
// (#13234, #13610, #14314, #14511, #15488, #15490, #15641, #15917, #16548, #19032, #20439, #20936, #21326, #19619, #22996)

/mob/living/simple_animal/horror
	name = "pradawny horror"
	desc = "Twoje oczy ledwo pojmują, na co patrzą."
	icon = 'aquila/icons/mob/horror.dmi'
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	icon_gib = "horror_gib"
	health = 50
	maxHealth = 50
	melee_damage = 10 // AQUILA - our simple mobs have one melee_damage, Yogs had melee_damage_lower/upper = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	stop_automated_movement = TRUE
	attacktext = "gryzie"
	speak_emote = list("bulgocze")
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("neutral","silicon","creature","heretics","abomination")
	ventcrawler = VENTCRAWLER_ALWAYS
	initial_language_holder = /datum/language_holder/universal
	hud_type = /datum/hud/chemical_counter

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0.5

	var/playstyle_string = "<span class='bold big'>Jesteś pradawnym horrorem,</span><b> wiecznie mutującym pasożytniczym plugastwem. Szukaj ludzkich dusz do pożarcia. \
							Wpełzaj ludziom do głów i wysysaj z nich esencję. Wykorzystuj ją, by mutować i zdobywać nowe moce i zdolności. \
							Działasz na chemikaliach, które gromadzą się, gdy przebywasz w czyjejś głowie. Poza nosicielem jesteś słaby, graj ostrożnie. \
							Możesz atakować śluzy, by się przez nie przecisnąć. </b><span class='danger'>Alt+klik na kimś, by go zarazić.</span>"

	var/mob/living/carbon/victim
	var/datum/mind/target
	var/mob/living/captive_brain/host_brain
	var/available_points = 4
	var/consumed_souls = 0

	//An associative list (associated by ability typepaths) containing the abilities the horror has
	var/list/horrorabilities = list()
	//same (associated by their ID), but for permanent upgrades
	var/list/horrorupgrades = list()
	//list storing what items we have to un-glue when stopping mind control
	var/list/clothing = list()

	var/bonding = FALSE
	var/controlling = FALSE
	var/chemicals = 10
	var/chem_regen_rate = 2
	var/used_freeze
	var/used_target
	var/horror_chems = list(/datum/horror_chem/epinephrine,/datum/horror_chem/mannitol,/datum/horror_chem/bicaridine,/datum/horror_chem/kelotane,/datum/horror_chem/charcoal)

	var/leaving = FALSE
	var/hiding = FALSE
	var/invisible = FALSE
	var/datum/action/innate/horror/talk_to_horror/talk_to_horror_action = new

/mob/living/simple_animal/horror/Initialize(mapload, gen=1)
	..()
	real_name = "[pick(GLOB.horror_names)]"

	//default abilities
	add_ability(/datum/action/innate/horror/mutate)
	add_ability(/datum/action/innate/horror/seek_soul)
	add_ability(/datum/action/innate/horror/consume_soul)
	add_ability(/datum/action/innate/horror/talk_to_host)
	add_ability(/datum/action/innate/horror/freeze_victim)
	add_ability(/datum/action/innate/horror/toggle_hide)
	add_ability(/datum/action/innate/horror/talk_to_brain)
	add_ability(/datum/action/innate/horror/take_control)
	add_ability(/datum/action/innate/horror/leave_body)
	add_ability(/datum/action/innate/horror/make_chems)
	add_ability(/datum/action/innate/horror/scan_host)
	add_ability(/datum/action/innate/horror/give_back_control)
	RefreshAbilities()

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	hud.add_hud_to(src)
	update_horror_hud()


/mob/living/simple_animal/horror/Destroy()
	host_brain = null
	victim = null
	return ..()

//Yogs -- slightly fancier examine
/mob/living/simple_animal/horror/examine(mob/user) // Return a more... positive description when the examiner is themselves an eldritch horror.
	if(user == src) // Hey, that's me!
		return list("[icon2html(src, user)] To [src.real_name], [initial(src.name)].","Jestem taki piękny!")
	else if(ishorror(user))
		return list("[get_examine_string(user, TRUE)].","Cóż za przystojny łobuz.")
	else
		return ..()
//Yogs end

/mob/living/simple_animal/horror/AltClickOn(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C || QDELETED(src) || !Adjacent(C) || victim || !can_use_ability())
			return
		if(victim)
			to_chat(src, "<span class='warning'>Już jesteś w nosicielu.</span>")
			return

		to_chat(src, "<span class='warning'>Wpełzasz mackami na [C] i zaczynasz badać kanał słuchowy...</span>")

		if(!do_mob(src, C, 3 SECONDS))
			to_chat(src, "<span class='warning'>[C] się odsuwa, a ty spadasz na ziemię.</span>")
			return

		if(!C || QDELETED(src))
			return
		if(C.has_horror_inside())
			to_chat(src, "<span class='warning'>[C] jest już zarażony!</span>")
			return
		Infect(C)
		return
	return ..()

/mob/living/simple_animal/horror/proc/has_chemicals(amt)
	return chemicals >= amt

/mob/living/simple_animal/horror/proc/use_chemicals(amt)
	if(!has_chemicals(amt))
		return FALSE
	chemicals -= amt
	update_horror_hud()
	return TRUE

/mob/living/simple_animal/horror/proc/regenerate_chemicals(amt)
	chemicals += amt
	chemicals = min(250, chemicals)
	update_horror_hud()

/mob/living/simple_animal/horror/proc/update_horror_hud()
	if(!src || !hud_used)
		return
	var/datum/hud/chemical_counter/H = hud_used
	var/atom/movable/screen/counter = H.chemical_counter
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#7264FF'>[chemicals]</font></div>"

/mob/living/simple_animal/horror/proc/can_use_ability()
	if(stat != CONSCIOUS)
		to_chat(src, "Nie możesz tego zrobić w obecnym stanie.")
		return FALSE
	return TRUE

/// AQUILA - our do_after() has no stayStill, and it fails as soon as the host walks. This keeps the bar on the host but only breaks when we leave it.
/mob/living/simple_animal/horror/proc/do_after_in_host(delay, datum/callback/extra_checks)
	var/mob/living/carbon/host = victim
	if(!host)
		return FALSE
	var/datum/progressbar/progbar = new(src, delay, host)
	var/starttime = world.time
	var/endtime = world.time + delay
	. = TRUE
	while(world.time < endtime)
		stoplag(1)
		progbar.update(world.time - starttime)
		if(QDELETED(src) || QDELETED(host) || stat || victim != host || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break
	qdel(progbar)

/mob/living/simple_animal/horror/proc/SearchTarget()
	if(target)
		if(world.time - used_target < 3 MINUTES)
			to_chat(src, "<span class='warning'>Nie możesz jeszcze ponownie użyć tej zdolności.</span>")
			return
		if(alert("Masz już cel ([target.name]). Czy chcesz go zmienić?","Zmienić cel?","Tak","Nie") != "Tak")
			return

	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.hasSoul && (mind.enslaved_to != M.current))
					possible_targets[M] = M

	var/list/selected_targets = list()
	var/list/icons = list()
	while(selected_targets.len != 4)
		if(possible_targets.len <= 0)
			break
		var/datum/mind/M = pick(possible_targets)
		selected_targets[M] = M
		possible_targets -= M

		var/mob/living/carbon/human/H = M.current
		icons[M] = H

	used_target = world.time

	var/entry_name = show_radial_menu(src, (victim ? src.loc : src), icons, tooltips = TRUE)
	target = selected_targets[entry_name]

	//you didn't select your target? let me do that for you, my friend
	if(selected_targets.len > 0 && !target)
		target = pick(selected_targets)

	if(target)
		to_chat(src, "<span class='warning'>Złapałeś trop. Idź i pożryj duszę [target.current.real_name] ([target.assigned_role])!</span>")
		apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
		for(var/datum/status_effect/agent_pinpointer/horror/status in status_effects)
			status.scan_target = target.current
	else
		//refund cooldown
		used_target = 0
		to_chat(src, "<span class='warning'>Nie udało się wybrać celu!</span>")

/mob/living/simple_animal/horror/proc/ConsumeSoul()
	if(!can_use_ability())
		return

	if(!victim.mind.hasSoul)
		to_chat(src, "Ten nosiciel nie ma duszy!")
		return

	if(victim == mind.enslaved_to)
		to_chat(src, "<span class='userdanger'>Nie, jeszcze nie... Wciąż go potrzebujemy...</span>")
		return

	if(victim.mind != target)
		to_chat(src, "To nie jest dusza twojego celu, nie możesz jej pożreć!")
		return

	to_chat(src, "Zaczynasz pożerać duszę [victim.name]!")
	if(do_after_in_host(30 SECONDS))
		consume()

/mob/living/simple_animal/horror/proc/consume()
	if(!can_use_ability() || !victim || !victim.mind.hasSoul || victim.mind != target)
		return
	consumed_souls++
	available_points++
	to_chat(src, "<span class='userdanger'>Udało ci się pożreć duszę [victim.name]!</span>")
	to_chat(victim, "<span class='userdanger'>Nagle czujesz się słaby i pusty w środku...</span>")
	victim.health -= 20
	victim.maxHealth -= 20
	victim.mind.hasSoul = FALSE
	target = null
	remove_status_effect(/datum/status_effect/agent_pinpointer/horror)
	playsound(src, 'sound/effects/curseattack.ogg', 150)
	playsound(src, 'sound/effects/ghost.ogg', 50)

/mob/living/simple_animal/horror/proc/Communicate()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, "Nie masz nosiciela, z którym mógłbyś rozmawiać!")
		return

	var/input = stripped_input(src, "Wpisz wiadomość dla nosiciela.", "Horror", null)
	if(!input)
		return

	if(src && !QDELETED(src) && !QDELETED(victim))
		if(victim)
			to_chat(victim, "<span class='changeling'><i>[real_name] bełkocze:</i> [input]</span>")
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					var/rendered = "<span class='changeling'><i>Komunikacja horroru od <b>[real_name]</b> : [input]</i></span>"
					var/link = FOLLOW_LINK(M, src)
					to_chat(M, "[link] [rendered]")
		to_chat(src, "<span class='changeling'><i>[real_name] bełkocze:</i> [input]</span>")
		add_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Grant(victim)

/mob/living/proc/horror_comm()
	set name = "Converse with Horror"
	set category = "Horror"
	set desc = "Communicate mentally with the thing in your head."

	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B)
		var/input = stripped_input(src, "Wpisz wiadomość dla horroru.", "Wiadomość", "")
		if(!input)
			return

		to_chat(B, "<span class='changeling'><i>[real_name] mówi:</i> [input]</span>")

		for(var/M in GLOB.dead_mob_list)
			if(isobserver(M))
				var/rendered = "<span class='changeling'><i>Komunikacja horroru od <b>[real_name]</b> : [input]</i></span>"
				var/link = FOLLOW_LINK(M, src)
				to_chat(M, "[link] [rendered]")
		to_chat(src, "<span class='changeling'><i>[real_name] mówi:</i> [input]</span>")

/mob/living/proc/trapped_mind_comm()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Wpisz wiadomość dla uwięzionego umysłu.", "Wiadomość", null)
	if(!input)
		return

	to_chat(CB, "<span class='changeling'><i>[B.real_name] mówi:</i> [input]</span>")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			var/rendered = "<span class='changeling'><i>Komunikacja horroru od <b>[B.real_name]</b> : [input]</i></span>"
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	to_chat(src, "<span class='changeling'><i>[B.real_name] mówi:</i> [input]</span>")

/mob/living/simple_animal/horror/Life()
	..()
	if(has_upgrade("regen"))
		heal_overall_damage(5)

	if(invisible) //don't regenerate chemicals when invisible
		if(use_chemicals(5))
			alpha = max(alpha - 100, 1)
		else
			to_chat(src, "<span class='warning'>Skończyły ci się chemikalia potrzebne do utrzymania niewidzialności.</span>")
			invisible = FALSE
			Update_Invisibility_Button()
	else
		if(has_upgrade("nohost_regen"))
			regenerate_chemicals(chem_regen_rate)
		else if(victim)
			if(victim.stat == DEAD)
				regenerate_chemicals(1)
			else
				regenerate_chemicals(chem_regen_rate)
	alpha = min(255, alpha + 50)

	if(victim)
		if(stat != DEAD && victim.stat != DEAD)
			heal_overall_damage(1)

/mob/living/simple_animal/horror/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(victim)
		to_chat(src, "<span class='warning'>Nie możesz mówić na głos, będąc w nosicielu!</span>")
		return
	return ..()

/mob/living/simple_animal/horror/emote(act, m_type = null, message = null, intentional = FALSE)
	if(victim)
		to_chat(src, "<span class='warning'>Nie możesz wykonywać emotek, będąc w nosicielu!</span>")
		return
	return ..()

/mob/living/simple_animal/horror/UnarmedAttack(atom/A)
	if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/door = A
		if(door.welded)
			to_chat(src, "<span class='danger'>Drzwi są zaspawane!</span>")
			return
		visible_message("<span class='warning'>[src] wsuwa macki w śluzę i zaczyna ją podważać!</span>", "<span class='warning'>Zaczynasz przeciskać się przez śluzę.</span>")
		playsound(A, 'sound/misc/splort.ogg', 50, 1)
		if(do_after(src, 5 SECONDS, target = A))
			if(door.welded)
				to_chat(src, "<span class='danger'>Drzwi są zaspawane!</span>")
				return
			visible_message("<span class='warning'>[src] przeciska się przez śluzę!</span>", "<span class='warning'>Przeciskasz się przez śluzę.</span>")
			forceMove(get_turf(A))
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
			return

	if(isliving(A))
		if(victim || A == src.mind.enslaved_to)
			healthscan(usr, A)
			chemscan(usr, A)
		else
			alpha = 255
			if(hiding)
				var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/toggle_hide)
				H.Activate()
			if(invisible)
				var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/chameleon)
				H.Activate()
			Update_Invisibility_Button()
			var/removeBonus = FALSE
			if(iscyborg(A))
				if(has_upgrade("dmg_up"))
					removeBonus = TRUE
					melee_damage += 7.5 // AQUILA - Yogs adds 5 to the lower and 10 to the upper roll, 7.5 is the same on average
			..()
			if(removeBonus)
				melee_damage -= 7.5

/mob/living/simple_animal/horror/ex_act()
	if(victim)
		return

	..()

/mob/living/simple_animal/horror/proc/Infect(mob/living/carbon/C)
	if(!C)
		return
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		to_chat(src, "<span class='warning'>[C] nie ma głowy!</span>")
		return
	var/hasbrain = locate(/obj/item/organ/brain) in C.internal_organs

	if(!hasbrain)
		to_chat(src, "<span class='warning'>[C] nie ma mózgu!</span>")
		return

	if(C.has_horror_inside())
		to_chat(src, "<span class='warning'>[C] jest już zarażony!</span>")
		return

	//can only infect non-ssd alive people / corpses with ghosts attached / current target
	if((C.stat == DEAD || !C.key) && (C.stat != DEAD || !C.get_ghost()) && (!target || C != target.current))
		to_chat(src, "<span class='warning'>Umysł [C] nie reaguje. Spróbuj z kimś innym!</span>")
		return

	if(hiding)
		var/datum/action/innate/horror/H = has_ability(/datum/action/innate/horror/toggle_hide)
		H.Activate()
	invisible = FALSE
	Update_Invisibility_Button()

	victim = C
	victim.visible_message("<span class='warning'>[src] wchodzi do głowy [victim]!</span>", "<span class='notice'>Coś wchodzi do twojej głowy!</span>")
	forceMove(victim)
	RefreshAbilities()
	log_game("[src]/([src.ckey]) has infested [victim]/([victim.ckey]")

/mob/living/simple_animal/horror/proc/secrete_chemicals()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, "<span class='warning'>Nie jesteś w ciele nosiciela.</span>")
		return

	var/content = "<p>Chemikalia: <span id='chemicals'>[chemicals]</span></p>"
	content += "<table>"

	for(var/path in subtypesof(/datum/horror_chem))
		var/datum/horror_chem/chem = path
		if(path in horror_chems)
			content += "<tr><td><a class='chem-select' href='byond://?_src_=\ref[src];src=\ref[src];horror_use_chem=[initial(chem.chemname)]'>[initial(chem.chemname)] ([initial(chem.chemuse)])</a><p>[initial(chem.chem_desc)]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	var/datum/asset/jquery = get_asset_datum(/datum/asset/simple/jquery) // AQUILA - the window's update_chemicals() needs jquery on the client
	jquery.send(usr)
	usr << browse(html, "window=ViewHorror\ref[src]Chems;size=600x800")

/mob/living/simple_animal/horror/proc/scan_host()
	if(!can_use_ability())
		return
	if(!victim)
		to_chat(src, "<span class='warning'>Nie jesteś w ciele nosiciela.</span>")
		return
	healthscan(usr, victim)
	chemscan(usr, victim)

/mob/living/simple_animal/horror/proc/hide()
	if(victim)
		to_chat(src, "<span class='warning'>Nie możesz tego zrobić, będąc w nosicielu.</span>")
		return

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = LATTICE_LAYER
		visible_message("<span class='name'>[src] przypada do ziemi!</span>", \
						"<span class='noticealien'>Ukrywasz się.</span>")
		hiding = TRUE
	else
		layer = MOB_LAYER
		visible_message("[src] powoli wychyla się z ziemi...", \
					"<span class='noticealien'>Przestajesz się ukrywać.</span>")
		hiding = FALSE

/mob/living/simple_animal/horror/proc/go_invisible()
	if(victim)
		to_chat(src, "<span class='warning'>Nie możesz tego zrobić, będąc w nosicielu.</span>")
		return

	if(!can_use_ability())
		return

	if(!has_chemicals(10))
		to_chat(src, "<span class='warning'>Masz za mało chemikaliów.</span>")
		return

	if(!invisible)
		to_chat(src, "<span class='noticealien'>Skupiasz się, by twoja kameleonowa skóra wtopiła się w otoczenie.</span>")
		invisible = TRUE
	else
		to_chat(src, "<span class='noticealien'>Przestajesz się maskować.</span>")
		invisible = FALSE

/mob/living/simple_animal/horror/proc/freeze_victim()
	if(world.time - used_freeze < 150)
		to_chat(src, "<span class='warning'>Nie możesz jeszcze ponownie użyć tej zdolności.</span>")
		return

	if(victim)
		to_chat(src, "<span class='warning'>Nie możesz tego zrobić z wnętrza nosiciela.</span>")
		return

	if(!can_use_ability())
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(!choices.len)
		return

	if(QDELETED(src) || stat != CONSCIOUS || victim || (world.time - used_freeze < 150))
		return

	layer = MOB_LAYER
	for (var/mob/living/carbon/M in range(1, src))
		if(!M || !Adjacent(M))
			return
		if(has_upgrade("paralysis"))
			playsound(loc, "sound/effects/sparks4.ogg", 30, 1, -1)
			M.Stun(50)
			M.SetSleeping(50)  //knocked out cold
			M.Knockdown(70)
			M.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, 1)
		else
			to_chat(M, "<span class='userdanger'>Czujesz, jak coś owija ci się wokół nogi i ciągnie w dół!</span>")
			playsound(loc, "sound/weapons/whipgrab.ogg", 30, 1, -1)
			M.Immobilize(50)
			M.Knockdown(70)
	used_freeze = world.time

/mob/living/simple_animal/horror/proc/is_leaving()
	return leaving

/mob/living/simple_animal/horror/proc/release_victim()
	if(!victim)
		to_chat(src, "<span class='danger'>Nie jesteś w ciele nosiciela.</span>")
		return

	if(!can_use_ability())
		return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='danger'>Rezygnujesz z opuszczenia nosiciela.</span>")
		return

	to_chat(src, "<span class='danger'>Zaczynasz odłączać się od synaps [victim] i wypychać się w stronę ucha.</span>")

	if(victim.stat != DEAD && !has_upgrade("invisible_exit"))
		to_chat(victim, "<span class='userdanger'>W twojej czaszce, tuż za uchem, zaczyna narastać dziwny, nieprzyjemny ucisk...</span>")

	leaving = TRUE
	if(do_after_in_host(10 SECONDS, CALLBACK(src, PROC_REF(is_leaving))))
		release_host()

/mob/living/simple_animal/horror/proc/release_host()
	if(!victim || QDELETED(victim) || QDELETED(src) || controlling)
		return

	if(!can_use_ability())
		return
	else
		to_chat(src, "<span class='danger'>Wyślizgujesz się z ucha [victim] i plaskasz na ziemię.</span>")
	if(victim.mind)
		if(!has_upgrade("invisible_exit"))
			to_chat(victim, "<span class='danger'>Coś oślizgłego wypełza ci z ucha i plaska na ziemię!</span>")

	leaving = FALSE

	leave_victim()

/mob/living/simple_animal/horror/proc/leave_victim()
	if(!victim)
		return

	if(controlling)
		detatch()

	forceMove(get_turf(victim))

	reset_perspective()
	unset_machine()

	victim.reset_perspective()
	victim.unset_machine()

	var/mob/living/V = victim
	remove_verb(V, /mob/living/proc/horror_comm)
	talk_to_horror_action.Remove(victim)

	for(var/obj/item/horrortentacle/T in victim)
		victim.visible_message("<span class='warning'>Macka [victim] zmienia się z powrotem w rękę!</span>", "<span class='notice'>Twoja macka znika!</span>")
		playsound(victim, 'sound/effects/blobattack.ogg', 30, 1)
		qdel(T)
	victim = null

	RefreshAbilities()


/mob/living/simple_animal/horror/proc/jumpstart()
	if(!victim)
		to_chat(src, "<span class='warning'>Potrzebujesz nosiciela, by tego użyć.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat != DEAD)
		to_chat(src, "<span class='warning'>Twój nosiciel już żyje!</span>")
		return

	if(!has_chemicals(250))
		to_chat(src, "<span class='warning'>Potrzebujesz 250 chemikaliów, by tego użyć!</span>")
		return

	if(HAS_TRAIT_FROM(victim, TRAIT_BADDNA, CHANGELING_DRAIN))
		to_chat(src, "<span class='warning'>DNA nosiciela jest całkowicie zniszczone! Nie możesz go wskrzesić.</span>")
		return

	if(victim.stat == DEAD)
		playsound(src, 'sound/machines/defib_charge.ogg', 50, 1, -1)
		sleep(1 SECONDS)
		victim.tod = null
		victim.setToxLoss(0)
		victim.setOxyLoss(0)
		victim.setCloneLoss(0)
		victim.SetUnconscious(0)
		victim.SetStun(0)
		victim.SetKnockdown(0)
		victim.radiation = 0
		victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
		victim.reagents.clear_reagents()
		if(HAS_TRAIT_FROM(victim, TRAIT_HUSK, BURN))
			victim.cure_husk(BURN)
		for(var/organ in victim.internal_organs)
			var/obj/item/organ/O = organ
			O.setOrganDamage(0)
		victim.restore_blood()
		victim.remove_all_embedded_objects()
		victim.revive()
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		to_chat(src, "<span class='notice'>Wysyłasz impuls energii do nosiciela i przywracasz go do życia!</span>")
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		victim.adjustOxyLoss(30)
		to_chat(victim, "<span class='userdanger'>Zrywasz się, łapczywie łapiąc powietrze!</span>")
		victim.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, 1)
		playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)


/mob/living/simple_animal/horror/proc/view_memory()
	if(!victim)
		to_chat(src, "<span class='warning'>Potrzebujesz nosiciela, by tego użyć.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='warning'>Mózg nosiciela nie reaguje. Nosiciel nie żyje!</span>")
		return

	if(prob(20))
		to_chat(victim, "<span class='danger'>Nagle czujesz, jakby ktoś grzebał ci we wspomnieniach...</span>")//chance to alert the victim

	if(victim.mind)
		var/datum/mind/suckedbrain = victim.mind
		to_chat(src, "<span class='boldnotice'>Przeglądasz wspomnienia [victim]...[suckedbrain.memory]</span>")
		for(var/A in suckedbrain.antag_datums)
			var/datum/antagonist/antag_types = A
			var/list/all_objectives = antag_types.objectives.Copy()
			if(antag_types.antag_memory)
				to_chat(src, "<span class='notice'>[antag_types.antag_memory]</span>")
			if(LAZYLEN(all_objectives))
				to_chat(src, "<span class='boldnotice'>Cele:</span>")
				var/obj_count = 1
				for(var/O in all_objectives)
					var/datum/objective/objective = O
					to_chat(src, "<span class='notice'>Cel #[obj_count++]: [objective.explanation_text]</span>")
					var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
					if(other_owners.len)
						for(var/mind in other_owners)
							var/datum/mind/M = mind
							to_chat(src, "<span class='notice'>Wspólnik: [M.name]</span>")

		var/list/recent_speech = list()
		var/list/say_log = list()
		var/log_source = victim.logging
		for(var/log_type in log_source)
			var/nlog_type = text2num(log_type)
			if(nlog_type & LOG_SAY)
				var/list/reversed = log_source[log_type]
				if(islist(reversed))
					say_log = reverseRange(reversed.Copy())
					break
		if(LAZYLEN(say_log))
			for(var/spoken_memory in say_log)
				if(recent_speech.len >= 5)//up to 5 random lines of speech, favoring more recent speech
					break
				if(prob(50))
					recent_speech[spoken_memory] = say_log[spoken_memory]
		if(recent_speech.len)
			to_chat(src, "<span class='boldnotice'>Wyłapujesz dryfujące wspomnienia dawnych rozmów...</span>")
			for(var/spoken_memory in recent_speech)
				to_chat(src, "<span class='notice'>[recent_speech[spoken_memory]]</span>")
		var/mob/living/carbon/human/H = victim
		var/datum/dna/the_dna = H.has_dna()
		if(the_dna)
			to_chat(src, "<span class='boldnotice'>Odkrywasz prawdziwą tożsamość nosiciela: [the_dna.real_name].</span>")

/mob/living/simple_animal/horror/proc/is_bonding()
	return bonding

/mob/living/simple_animal/horror/proc/bond_brain()
	if(!victim)
		to_chat(src, "<span class='warning'>Nie jesteś w ciele nosiciela.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='notice'>Mózg tego nosiciela jest zbyt martwy, by go kontrolować.</span>")
		return

	if(victim.has_trauma_type(/datum/brain_trauma/severe/split_personality))
		to_chat(src, "<span class='notice'>Rozszczepione płaty mózgu tego nosiciela są zbyt złożone, byś mógł go kontrolować.</span>")
		return

	if(bonding)
		bonding = FALSE
		to_chat(src, "<span class='danger'>Przestajesz próbować przejąć kontrolę nad nosicielem.</span>")
		return

	to_chat(src, "<span class='danger'>Zaczynasz delikatnie dostrajać połączenie z mózgiem nosiciela...</span>")

	if(QDELETED(src) || QDELETED(victim))
		return

	bonding = TRUE

	var/delay = 20 SECONDS
	if(has_upgrade("fast_control"))
		delay -= 12 SECONDS
	if(do_after_in_host(delay, CALLBACK(src, PROC_REF(is_bonding))))
		assume_control()

/mob/living/simple_animal/horror/proc/assume_control()
	if(!victim || !src || controlling || victim.stat == DEAD)
		return
	if(is_servant_of_ratvar(victim) || iscultist(victim))
		to_chat(src, "<span class='warning'>Umysł [victim] blokuje jakaś nieznana siła!</span>")
		bonding = FALSE
		return
	if(HAS_TRAIT(victim, TRAIT_MINDSHIELD))
		to_chat(src, "<span class='warning'>Umysł [victim] jest osłonięty przed twoim wpływem!</span>")
		bonding = FALSE
		return
	else
		RegisterSignal(victim, COMSIG_MOB_APPLY_DAMGE, PROC_REF(hit_detatch))
		log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with eldritch powers.")
		to_chat(src, "<span class='warning'>Wbijasz trąbki głęboko w korę mózgu nosiciela i łączysz się bezpośrednio z jego układem nerwowym.</span>")
		to_chat(victim, "<span class='userdanger'>Czujesz dziwne przesunięcie za oczami, gdy obca świadomość wypiera twoją.</span>")

		clothing = victim.get_equipped_items()
		for(var/obj/item/I in clothing)
			ADD_TRAIT(I, TRAIT_NODROP, HORROR_TRAIT)

		qdel(host_brain)
		host_brain = new(src)
		host_brain.H = src
		host_brain.name = "Uwięziony umysł [victim.real_name]"
		victim.mind.transfer_to(host_brain)
		if(victim.key)
			host_brain.key = victim.key

		to_chat(host_brain, "Jesteś uwięziony we własnym umyśle. Czujesz, że musi istnieć sposób, by się oprzeć!")

		mind.transfer_to(victim)

		bonding = FALSE
		controlling = TRUE

		remove_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Remove(victim)
		GrantControlActions()

		victim.med_hud_set_status()
		if(target)
			victim.apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
			for(var/datum/status_effect/agent_pinpointer/horror/status in victim.status_effects)
				status.scan_target = target.current

/mob/living/carbon/proc/release_control()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B && B.host_brain)
		to_chat(src, "<span class='danger'>Wycofujesz trąbki i oddajesz kontrolę: [B.host_brain]</span>")
		B.detatch()

//Check for brain worms in head.
/mob/proc/has_horror_inside()
	for(var/I in contents)
		if(ishorror(I))
			return I


/mob/living/simple_animal/horror/proc/hit_detatch()
	if(victim.health <= 75)
		detatch()
		to_chat(src, "<span class='warning'>Mózg [victim] wyczuł zagrożenie i w pośpiechu przejął kontrolę.</span>")
		to_chat(victim, "<span class='danger'>Twoje ciało jest atakowane, więc twój mózg odruchowo i natychmiast przejmuje kontrolę!</span>")

/mob/living/simple_animal/horror/proc/detatch()
	if(!victim || !controlling)
		return

	controlling = FALSE
	UnregisterSignal(victim, COMSIG_MOB_APPLY_DAMGE)
	add_verb(victim, /mob/living/proc/horror_comm)
	RemoveControlActions()
	RefreshAbilities()
	talk_to_horror_action.Grant(victim)

	for(var/obj/item/I in clothing)
		REMOVE_TRAIT(I, TRAIT_NODROP, HORROR_TRAIT)
	clothing = list()

	victim.med_hud_set_status()
	victim.remove_status_effect(/datum/status_effect/agent_pinpointer/horror)

	victim.mind.transfer_to(src)
	if(host_brain)
		host_brain.mind.transfer_to(victim)
		if(host_brain.key)
			victim.key = host_brain.key

	log_game("[src]/([src.ckey]) released control of [victim]/([victim.ckey]")
	qdel(host_brain)

/mob/living/simple_animal/horror/proc/Update_Invisibility_Button()
	var/datum/action/innate/horror/action = has_ability(/datum/action/innate/horror/chameleon)
	if(action)
		action.button_icon_state = "horror_sneak_[invisible ? "true" : "false"]"
		action.UpdateButtonIcon()

/mob/living/simple_animal/horror/proc/GrantHorrorActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("horror" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveHorrorActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("horror" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantInfestActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("infest" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveInfestActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("infest" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantControlActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("control" in ability.category)
			ability.Grant(victim)

/mob/living/simple_animal/horror/proc/RemoveControlActions()
	for(var/datum/action/innate/horror/ability in horrorabilities)
		if("control" in ability.category)
			ability.Remove(victim)

/mob/living/simple_animal/horror/proc/RefreshAbilities() //control abilities technically don't belong to horror
	if(victim)
		RemoveHorrorActions()
		GrantInfestActions()
	else
		RemoveInfestActions()
		GrantHorrorActions()
