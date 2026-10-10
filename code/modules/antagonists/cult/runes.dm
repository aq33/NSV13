/// list of weakrefs to mobs OR minds that have been sacrificed
GLOBAL_LIST(sacrificed)
/// List of all teleport runes
GLOBAL_LIST(teleport_runes)
/// Assoc list of every rune that can be drawn by ritual daggers. [rune_name] = [typepath]
GLOBAL_LIST_INIT(rune_types, generate_cult_rune_types())
GLOBAL_LIST_EMPTY(wall_runes)

/// Returns an associated list of rune types. [rune.cultist_name] = [typepath]
/proc/generate_cult_rune_types()
	RETURN_TYPE(/list)

	var/list/runes = list()
	for(var/obj/effect/rune/rune as anything in subtypesof(/obj/effect/rune))
		if(!initial(rune.can_be_scribed))
			continue
		runes[initial(rune.cultist_name)] = rune // Uses the cultist name for displaying purposes

	return runes
/*

This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with a ritual dagger in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.


*/

/obj/effect/rune
	name = "rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	color = RUNE_COLOR_RED

	/// The name of the rune to cultists
	var/cultist_name = "Podstawowa"
	/// The description of the rune shown to cultists who examine it
	var/cultist_desc = "to podstawowa runa bez żadnej funkcji."
	/// This is said by cultists when the rune is invoked.
	var/invocation = "Aiy ele-mayo!"
	/// The amount of cultists required around the rune to invoke it.
	var/req_cultists = 1
	/// If we have a description override for required cultists to invoke
	var/req_cultists_text
	/// Used for some runes, this is for when you want a rune to not be usable when in use.
	var/rune_in_use = FALSE
	/// Used when you want to keep track of who erased the rune
	var/log_when_erased = FALSE
	/// Whether this rune can be scribed or if it's admin only / special spawned / whatever
	var/can_be_scribed = TRUE
	/// How long the rune takes to erase
	var/erase_time = 1.5 SECONDS
	/// How long the rune takes to create
	var/scribe_delay = 4 SECONDS
	/// If a rune cannot be speed boosted while scribing on certain turfs
	var/no_scribe_boost = FALSE
	/// Hhow much damage you take doing it
	var/scribe_damage = 0.1
	/// How much damage invokers take when invoking it
	var/invoke_damage = 0
	/// If constructs can invoke it
	var/construct_invoke = TRUE
	/// If the rune requires a keyword when scribed
	var/req_keyword = FALSE
	/// The actual keyword for the rune
	var/keyword

/obj/effect/rune/Initialize(mapload, set_keyword)
	. = ..()
	if(set_keyword)
		keyword = set_keyword
	var/image/I = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		. += "<b>Name:</b> [cultist_name]\n"+\
		"<b>Effects:</b> [capitalize(cultist_desc)]\n"+\
		"<b>Wymagani akolici:</b> [req_cultists_text ? "[req_cultists_text]":"[req_cultists]"]"
		if(req_keyword && keyword)
			. += "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Nie rozumiesz słów [src].</span>")
		return
	var/list/invokers = can_invoke(user)
	if(invokers.len >= req_cultists)
		invoke(invokers)
	else
		to_chat(user, "<span class='danger'>Potrzebujesz jeszcze [req_cultists - invokers.len] kultystów obok, by użyć runy w ten sposób.</span>")
		fail_invoke()

/obj/effect/rune/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/shade) || istype(M, /mob/living/simple_animal/hostile/construct))
		if(istype(M, /mob/living/simple_animal/hostile/construct/wraith/angelic) || istype(M, /mob/living/simple_animal/hostile/construct/armored/angelic) || istype(M, /mob/living/simple_animal/hostile/construct/builder/angelic))
			to_chat(M, "<span class='warning'>Oczyszczasz runę!</span>")
			qdel(src)
		else if(construct_invoke || !iscultist(M)) //if you're not a cult construct we want the normal fail message
			attack_hand(M)
		else
			to_chat(M, "<span class='warning'>Nie możesz aktywować runy!</span>")

/obj/effect/rune/proc/conceal() //for talisman of revealing/hiding
	visible_message("<span class='danger'>[src] blednie i znika.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes

/obj/effect/rune/proc/reveal() //for talisman of revealing/hiding
	invisibility = 0
	visible_message("<span class='danger'>Nagle pojawia się [src]!</span>")
	alpha = initial(alpha)

/*

There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.

*/

/obj/effect/rune/proc/can_invoke(var/mob/living/user=null)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	var/list/invokers = list() //people eligible to invoke the rune
	if(user)
		invokers += user
	if(req_cultists > 1 || istype(src, /obj/effect/rune/convert))
		var/obj/item/toy/plush/narplush/plushsie = locate() in range(1, src)
		if(plushsie?.is_invoker)
			invokers += plushsie
		for(var/mob/living/L in viewers(1, src))
			if(iscultist(L))
				if(L == user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if((HAS_TRAIT(H, TRAIT_MUTE)) || H.silent)
						continue
				if(L.stat)
					continue
				invokers += L
	return invokers

/obj/effect/rune/proc/invoke(var/list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	for(var/M in invokers)
		if(isliving(M))
			var/mob/living/L = M
			if(invocation)
				L.say(invocation, language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")
			if(invoke_damage)
				L.apply_damage(invoke_damage, BRUTE)
				to_chat(L, "<span class='cult italic'>[src] wysysa twoje siły!</span>")
		else if(istype(M, /obj/item/toy/plush/narplush))
			var/obj/item/toy/plush/narplush/P = M
			P.visible_message("<span class='cult italic'>[P] głośno piszczy!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/do_invoke_glow()
	set waitfor = FALSE
	animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
	sleep(5)
	animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)

/obj/effect/rune/proc/fail_invoke()
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>Znaki pulsują krótkim błyskiem czerwonego światła, po czym gasną.</span>")
	var/oldcolor = color
	color = rgb(255, 0, 0)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 5)

//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "Zniekształcona"
	cultist_desc = "to bezsensowna runa zapisana bełkotem. Nic dobrego nie wyniknie z jej aktywacji."
	invocation = "Ra'sha yoka!"
	invoke_damage = 30
	can_be_scribed = FALSE

/obj/effect/rune/malformed/Initialize(mapload, set_keyword)
	. = ..()
	icon_state = "[rand(1,7)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(var/list/invokers)
	..()
	qdel(src)

//Rite of Offering: Converts or sacrifices a target.
/obj/effect/rune/convert
	cultist_name = "Ofiary"
	cultist_desc = "oddaje niekultystę stojącego na niej Nar'Sie, nawracając go albo składając w ofierze."
	req_cultists_text = "2 do nawrócenia, 3 do ofiar z żywych i celów ofiarnych."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = RUNE_COLOR_OFFER
	req_cultists = 1
	rune_in_use = FALSE

/obj/effect/rune/convert/do_invoke_glow()
	return

/obj/effect/rune/convert/invoke(var/list/invokers)
	if(rune_in_use)
		return
	var/list/myriad_targets = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!iscultist(M))
			myriad_targets |= M
	if(!myriad_targets.len)
		fail_invoke()
		log_game("Offer rune failed - no eligible targets")
		return
	rune_in_use = TRUE
	visible_message("<span class='warning'>[src] pulsuje krwistą czerwienią!</span>")
	var/oldcolor = color
	color = RUNE_COLOR_DARKRED
	var/mob/living/L = pick(myriad_targets)

	var/mob/living/F = invokers[1]
	var/datum/antagonist/cult/C = F.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	var/datum/team/cult/Cult_team = C.cult_team
	var/is_convertable = is_convertable_to_cult(L,C.cult_team)
	if(L.stat != DEAD && (is_convertable))
		invocation = "Mah'weyh pleggh at e'ntrath!"
		..()
		if(is_convertable)
			do_convert(L, invokers)
	else
		invocation = "Barhah hra zar'garis!"
		..()
		do_sacrifice(L, invokers)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 5)
	Cult_team.check_size() // Triggers the eye glow or aura effects if the cult has grown large enough relative to the crew
	rune_in_use = FALSE

/obj/effect/rune/convert/proc/do_convert(mob/living/convertee, list/invokers)
	if(invokers.len < 2)
		for(var/M in invokers)
			to_chat(M, "<span class='danger'>Potrzebujesz co najmniej dwóch przywołujących, by nawrócić [convertee]!</span>")
		log_game("Offer rune failed - tried conversion with one invoker")
		return 0
	if(convertee.anti_magic_check(TRUE, TRUE, major = FALSE) || istype(convertee.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat)) //Not major because it can be spammed
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>Coś osłania umysł [convertee]!</span>")
		log_game("Offer rune failed - convertee had anti-magic")
		return 0
	var/brutedamage = convertee.getBruteLoss()
	var/burndamage = convertee.getFireLoss()
	if(brutedamage || burndamage)
		convertee.adjustBruteLoss(-(brutedamage * 0.75))
		convertee.adjustFireLoss(-(burndamage * 0.75))
	convertee.visible_message("<span class='warning'>[convertee] wije się z bólu, \
	[brutedamage || burndamage ? "choć jego rany goją się i zamykają" : "a znaki pod nim jarzą się krwistą czerwienią"]!</span>", \
 	"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	SSticker.mode.add_cultist(convertee.mind, 1)
	new /obj/item/melee/cultblade/dagger(get_turf(src))
	convertee.mind.special_role = ROLE_CULTIST
	to_chat(convertee, "<span class='cult italic'><b>Twoja krew pulsuje. Głowa ci pęka. Świat robi się czerwony. Nagle uświadamiasz sobie straszną, straszną prawdę. Zasłona rzeczywistości została zdarta \
	i zakorzenia się w tobie coś złego.</b></span>")
	to_chat(convertee, "<span class='cult italic'><b>Wspieraj swoich nowych towarzyszy w ich mrocznych sprawach. Twój cel jest ich celem, a ich - twoim. Ponad wszystko służysz Geometrze. Sprowadź ją z powrotem.\
	</b></span>")
	if(ishuman(convertee))
		var/mob/living/carbon/human/H = convertee
		H.uncuff()
		H.stuttering = 0
		H.cultslurring = 0
	return 1

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/sacrificial, list/invokers)
	var/mob/living/first_invoker = invokers[1]
	if(!first_invoker)
		return FALSE
	var/datum/antagonist/cult/C = first_invoker.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!C)
		return


	var/big_sac = FALSE
	if((((ishuman(sacrificial) || iscyborg(sacrificial)) && sacrificial.stat != DEAD) || C.cult_team.is_sacrifice_target(sacrificial.mind)) && invokers.len < 3)
		for(var/M in invokers)
			to_chat(M, "<span class='cult italic'>[sacrificial] jest zbyt mocno związany ze światem! Potrzebujesz trzech akolitów!</span>")
		log_game("Offer rune failed - not enough acolytes and target is living or sac target")
		return FALSE
	if(sacrificial.mind)
		LAZYADD(GLOB.sacrificed, WEAKREF(sacrificial.mind))
		for(var/datum/objective/sacrifice/sac_objective in C.cult_team.objectives)
			if(sac_objective.target == sacrificial.mind)
				sac_objective.sacced = TRUE
				sac_objective.update_explanation_text()
				big_sac = TRUE
	else
		LAZYADD(GLOB.sacrificed, WEAKREF(sacrificial))

	new /obj/effect/temp_visual/cult/sac(get_turf(src))
	for(var/M in invokers)
		if(big_sac)
			to_chat(M, "<span class='cultlarge'>\"Tak! Tego właśnie pragnę! Dobrze się spisaliście.\"</span>")
		else
			if(ishuman(sacrificial) || iscyborg(sacrificial))
				to_chat(M, "<span class='cultlarge'>\"Przyjmuję tę ofiarę.\"</span>")
			else
				to_chat(M, "<span class='cultlarge'>\"Przyjmuję tę marną ofiarę.\"</span>")

	var/obj/item/soulstone/stone = new /obj/item/soulstone(get_turf(src))
	if(sacrificial.mind && !sacrificial.suiciding)
		stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
		stone.transfer_soul("FORCE", sacrificial, usr)
		stone.invisibility = 0

	if(sacrificial)
		if(iscyborg(sacrificial))
			playsound(sacrificial, 'sound/magic/disable_tech.ogg', 100, 1)
			sacrificial.dust() //To prevent the MMI from remaining
		else
			playsound(sacrificial, 'sound/magic/disintegrate.ogg', 100, 1)
			sacrificial.gib()
	return TRUE



/obj/effect/rune/empower
	cultist_name = "Wzmocnienia"
	cultist_desc = "pozwala kultystom przygotowywać więcej magii krwi dużo mniejszym kosztem."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"
	color = RUNE_COLOR_TALISMAN
	construct_invoke = FALSE

/obj/effect/rune/empower/invoke(var/list/invokers)
	. = ..()
	var/mob/living/user = invokers[1] //the first invoker is always the user
	for(var/datum/action/innate/cult/blood_magic/BM in user.actions)
		BM.Activate()

/obj/effect/rune/teleport
	cultist_name = "Teleportacji"
	cultist_desc = "przenosi wszystko, co na niej stoi, do innej wybranej runy teleportacji."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "2"
	color = RUNE_COLOR_TELEPORT
	req_keyword = TRUE
	light_power = 4
	var/obj/effect/temp_visual/cult/portal/inner_portal //The portal "hint" for off-station teleportations
	var/obj/effect/temp_visual/cult/rune_spawn/rune2/outer_portal
	var/listkey


/obj/effect/rune/teleport/Initialize(mapload, set_keyword)
	. = ..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	LAZYADD(GLOB.teleport_runes, src)

/obj/effect/rune/teleport/Destroy()
	LAZYREMOVE(GLOB.teleport_runes, src)
	if(inner_portal)
		QDEL_NULL(inner_portal)
	if(outer_portal)
		QDEL_NULL(outer_portal)
	return ..()

/obj/effect/rune/teleport/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	for(var/obj/effect/rune/teleport/teleport_rune as anything in GLOB.teleport_runes)
		if(teleport_rune != src && !is_away_level(teleport_rune.z))
			potential_runes[avoid_assoc_duplicate_keys(teleport_rune.listkey, teleportnames)] = teleport_rune

	if(!potential_runes.len)
		to_chat(user, "<span class='warning'>Nie ma run, do których można się teleportować!</span>")
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	if(is_away_level(T.z))
		to_chat(user, "<span class='cult italic'>Nie jesteś we właściwym wymiarze!</span>")
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = input(user, "Wybierz runę, do której chcesz się teleportować.", "Runa docelowa") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || !actual_selected_rune)
		fail_invoke()
		return

	var/turf/target = get_turf(actual_selected_rune)
	if(is_blocked_turf(target, TRUE))
		to_chat(user, "<span class='warning'>Runa docelowa jest zablokowana. Próba teleportacji byłaby skrajnie nierozsądna.</span>")
		fail_invoke()
		return
	var/movedsomething = FALSE
	var/moveuserlater = FALSE
	var/movesuccess = FALSE
	for(var/atom/movable/A in T)
		if(istype(A, /obj/effect/dummy/phased_mob))
			continue
		if(ismob(A))
			if(!isliving(A)) //Let's not teleport ghosts and AI eyes.
				continue
			if(ishuman(A))
				new /obj/effect/temp_visual/dir_setting/cult/phase/out(T, A.dir)
				new /obj/effect/temp_visual/dir_setting/cult/phase(target, A.dir)
		if(A == user)
			moveuserlater = TRUE
			movedsomething = TRUE
			continue
		if(!A.anchored)
			movedsomething = TRUE
			if(do_teleport(A, target, channel = TELEPORT_CHANNEL_CULT))
				movesuccess = TRUE
	if(movedsomething)
		..()
		if(moveuserlater)
			if(do_teleport(user, target, channel = TELEPORT_CHANNEL_CULT))
				movesuccess = TRUE
		if(movesuccess)
			visible_message("<span class='warning'>Rozlega się ostry trzask wpadającego powietrza i wszystko na runie znika!</span>", null, "<i>Słyszysz ostry trzask.</i>")
			to_chat(user, "<span class='cult'>You[moveuserlater ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>")
		else
			to_chat(user, "<span class='cult'>You[moveuserlater ? "r vision blurs briefly, but nothing happens":"  try send everything above the rune away, but the teleportation fails"].</span>")
		if(is_mining_level(z) && !is_mining_level(target.z)) //No effect if you stay on lavaland
			actual_selected_rune.handle_portal("lava")
		else
			var/area/A = get_area(T)
			if(initial(A.name) == "Space")
				actual_selected_rune.handle_portal("space", T)
		if(movesuccess)
			target.visible_message("<span class='warning'>Rozlega się huk wypychanego powietrza i nad runą coś się pojawia!</span>", null, "<i>Słyszysz huk.</i>")
	else
		fail_invoke()

/obj/effect/rune/teleport/proc/handle_portal(portal_type, turf/origin)
	var/turf/T = get_turf(src)
	close_portal() // To avoid stacking descriptions/animations
	playsound(T, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 100, TRUE, 14)
	inner_portal = new /obj/effect/temp_visual/cult/portal(T)
	if(portal_type == "space")
		light_color = color
		desc += "<br><b>Rozdarcie w rzeczywistości odsłania czarną pustkę usianą punkcikami światła... coś niedawno teleportowało się tu z kosmosu.<br><u>Pustka zdaje się ciągnąć cię w kierunku: [dir2text(get_dir(T, origin))]!</u></b>"
	else
		inner_portal.icon_state = "lava"
		light_color = LIGHT_COLOR_FIRE
		desc += "<br><b>Rozdarcie w rzeczywistości odsłania rwącą rzekę lawy... coś niedawno teleportowało się tu z kopalni Lavalandu!</b>"
	outer_portal = new(T, 600, color)
	light_range = 4
	update_light()
	addtimer(CALLBACK(src, PROC_REF(close_portal)), 600, TIMER_UNIQUE)

/obj/effect/rune/teleport/proc/close_portal()
	QDEL_NULL(inner_portal)
	QDEL_NULL(outer_portal)
	desc = initial(desc)
	light_range = 0
	update_light()

//Ritual of Dimensional Rending: Calls forth the avatar of Nar'Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Nar'Sie"
	cultist_desc = "rozdziera bariery między wymiarami, przywołując Geometrę. Wymaga 9 przywołujących."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	scribe_delay = 500 //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	no_scribe_boost = TRUE
	var/used = FALSE

/obj/effect/rune/narsie/Initialize(mapload, set_keyword)
	. = ..()
	GLOB.poi_list |= src

/obj/effect/rune/narsie/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/effect/rune/narsie/conceal() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/invoke(var/list/invokers)
	if(used)
		return
	if(!is_station_level(z))
		return
	var/mob/living/user = invokers[1]
	var/datum/antagonist/cult/user_antag = user.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	var/datum/objective/eldergod/summon_objective = locate() in user_antag.cult_team.objectives
	var/area/place = get_area(src)
	if(!(place in summon_objective.summon_spots))
		to_chat(user, "<span class='cultlarge'>Geometrę można przywołać tylko tam, gdzie zasłona jest słaba - w miejscach: [english_list(summon_objective.summon_spots)]!</span>")
		return
	if(locate(/obj/eldritch/narsie) in GLOB.poi_list)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>Nar'Sie jest już na tym planie!</span>")
		log_game("Nar'Sie rune failed - already summoned")
		return
	//BEGIN THE SUMMONING
	used = TRUE
	..()
	sound_to_playing_players('sound/effects/dimensional_rend.ogg')
	var/turf/T = get_turf(src)
	sleep(40)
	if(src)
		color = RUNE_COLOR_RED
	if(GLOB.celestial_gateway)
		SEND_SOUND(world, 'sound/magic/clockwork/narsie_attack.ogg')
		to_chat(world, "<span class='ratvar'>Zasłonę między wymiarami trzyma zamkniętą potężne pole elektryczne.</span>")
		GLOB.narsie_breaching = TRUE
		GLOB.narsie_arrival = T
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
		gateway.open_gateway()
	else
		new /obj/eldritch/narsie(T) //Causes Nar'Sie to spawn even if the rune has been removed

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user)))
		user.visible_message("<span class='warning'>[user.name] zaczyna ścierać [src]...</span>", "<span class='notice'>Zaczynasz ścierać [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon Narsie rune erased by [key_name(user)] with [I.name]")
			message_admins("[ADMIN_LOOKUPFLW(user)] erased a Narsie rune with [I.name]")
			..()
	else
		if(istype(I, /obj/item/nullrod))	//Begone foul magiks. You cannot hinder me.
			log_game("Summon Narsie rune erased by [key_name(user)] using a null rod")
			message_admins("[ADMIN_LOOKUPFLW(user)] erased a Narsie rune with a null rod")
			..()

//Rite of Resurrection: Requires a dead or inactive cultist. When reviving the dead, you can only perform one revival for every sacrifice your cult has carried out.
/obj/effect/rune/raise_dead
	cultist_name = "Wskrzeszenia"
	cultist_desc = "wymaga martwego, bezmyślnego lub nieaktywnego kultysty na runie. Jeśli złożono dość ofiar, otrzyma on nowe życie."
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!" //Depends on the name of the user - see below
	icon_state = "1"
	color = RUNE_COLOR_MEDIUMRED
	var/static/revives_used = -SOULS_TO_REVIVE // Cultists get one "free" revive

/obj/effect/rune/raise_dead/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		var/revive_number = LAZYLEN(GLOB.sacrificed) - revives_used
		. += "<b>Pozostałe wskrzeszenia:</b> [revive_number]"

/obj/effect/rune/raise_dead/invoke(var/list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_revive
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	rune_in_use = TRUE
	for(var/mob/living/M in T.contents)
		if(iscultist(M) && (M.stat == DEAD || !M.client || M.client.is_afk()))
			potential_revive_mobs |= M
	if(!potential_revive_mobs.len)
		to_chat(user, "<span class='cult italic'>Na runie nie ma martwych kultystów!</span>")
		log_game("Raise Dead rune failed - no cultists to revive")
		fail_invoke()
		return
	if(potential_revive_mobs.len > 1)
		mob_to_revive = input(user, "Wybierz kultystę do wskrzeszenia.", "Kultysta do wskrzeszenia") as null|anything in potential_revive_mobs
	else
		mob_to_revive = potential_revive_mobs[1]
	if(QDELETED(src) || !validness_checks(mob_to_revive, user))
		fail_invoke()
		return
	if(user.name == "Herbert West")
		invocation = "Do życia, do życia ich przywracam!"
	else
		invocation = initial(invocation)
	..()
	if(mob_to_revive.stat == DEAD)
		var/diff = LAZYLEN(GLOB.sacrificed) - revives_used - SOULS_TO_REVIVE
		if(diff < 0)
			to_chat(user, "<span class='warning'>Twój kult musi złożyć jeszcze [abs(diff)] ofiar, zanim wskrzesi kolejnego kultystę!</span>")
			fail_invoke()
			return
		revives_used += SOULS_TO_REVIVE
		mob_to_revive.revive(1, 1) //This does remove traits and such, but the rune might actually see some use because of it!
		mob_to_revive.grab_ghost()
	if(!mob_to_revive.client || mob_to_revive.client.is_afk())
		set waitfor = FALSE
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako [mob_to_revive.name], nieaktywny kultysta krwi?", ROLE_CULTIST, /datum/role_preference/antagonist/blood_cultist, 7.5 SECONDS, mob_to_revive)
		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			to_chat(mob_to_revive.mind, "Przez twoją nieaktywność twoje ciało przejęła inna dusza! Napisz ahelp, jeśli chcesz je odzyskać.")
			message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(mob_to_revive)]) to replace an AFK player.")
			mob_to_revive.ghostize(FALSE)
			mob_to_revive.key = C.key
		else
			fail_invoke()
			return
	SEND_SOUND(mob_to_revive, 'sound/ambience/antag/bloodcult.ogg')
	to_chat(mob_to_revive, "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Powstań.\"</span>")
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] bierze ogromny wdech, a z oczu bije czerwone światło.</span>", \
								  "<span class='cultlarge'>Nagle budzisz się z pustki. Żyjesz!</span>")
	rune_in_use = FALSE

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user)
	var/turf/T = get_turf(src)
	if(QDELETED(user))
		return FALSE
	if(!Adjacent(user) || user.incapacitated())
		return FALSE
	if(QDELETED(target_mob))
		return FALSE
	if(!(target_mob in T.contents))
		to_chat(user, "<span class='cult italic'>Kultysta do wskrzeszenia został przeniesiony!</span>")
		log_game("Raise Dead rune failed - revival target moved")
		return FALSE
	return TRUE

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	rune_in_use = FALSE
	for(var/mob/living/M in hearers(1,src))
		if(iscultist(M) && M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")

//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Bariery"
	cultist_desc = "po aktywacji tworzy tymczasową niewidzialną ścianę blokującą przejście. Ponowna aktywacja to odwraca."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "4"
	color = RUNE_COLOR_DARKRED
	CanAtmosPass = ATMOS_PASS_DENSITY
	var/datum/timedevent/density_timer
	var/recharging = FALSE

/obj/effect/rune/wall/Initialize(mapload, set_keyword)
	. = ..()
	GLOB.wall_runes += src

/obj/effect/rune/wall/examine(mob/user)
	. = ..()
	if(density && iscultist(user))
		if(density_timer)
			. += "<span class='cultitalic'>Powietrze nad tą runą stwardniało w barierę, która utrzyma się jeszcze [DisplayTimeText(density_timer.timeToRun - world.time)].</span>"

/obj/effect/rune/wall/Destroy()
	GLOB.wall_runes -= src
	return ..()

/obj/effect/rune/wall/BlockThermalConductivity()
	return density

/obj/effect/rune/wall/invoke(var/list/invokers)
	if(recharging)
		return
	var/mob/living/user = invokers[1]
	..()
	density = !density
	update_state()
	if(density)
		spread_density()
	var/carbon_user = iscarbon(user)
	user.visible_message("<span class='warning'>[user] [carbon_user ? "places [user.p_their()] hands on":"stares intently at"] [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cult italic'>Przekazujesz [carbon_user ? "swoją życiową ":""]energię do [src], [density ? "chwilowo blokując" : "otwierając"] przejście.</span>")
	if(carbon_user)
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/obj/effect/rune/wall/proc/spread_density()
	for(var/R in GLOB.wall_runes)
		var/obj/effect/rune/wall/W = R
		if(W.get_virtual_z_level() == get_virtual_z_level() && get_dist(src, W) <= 2 && !W.density && !W.recharging)
			W.density = TRUE
			W.update_state()
			W.spread_density()
	density_timer = addtimer(CALLBACK(src, PROC_REF(lose_density)), 3000, TIMER_STOPPABLE)

/obj/effect/rune/wall/proc/lose_density()
	if(density)
		recharging = TRUE
		density = FALSE
		update_state()
		var/oldcolor = color
		add_atom_colour("#696969", FIXED_COLOUR_PRIORITY)
		animate(src, color = oldcolor, time = 50, easing = EASE_IN)
		addtimer(CALLBACK(src, PROC_REF(recharge)), 50)

/obj/effect/rune/wall/proc/recharge()
	recharging = FALSE
	add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

/obj/effect/rune/wall/proc/update_state()
	deltimer(density_timer)
	air_update_turf()
	if(density)
		var/mutable_appearance/shimmer = mutable_appearance('icons/effects/effects.dmi', "barriershimmer", ABOVE_MOB_LAYER)
		shimmer.appearance_flags |= RESET_COLOR
		shimmer.alpha = 60
		shimmer.color = "#701414"
		add_overlay(shimmer)
		add_atom_colour(RUNE_COLOR_RED, FIXED_COLOUR_PRIORITY)
	else
		cut_overlays()
		add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Przywołania kultysty"
	cultist_desc = "przywołuje na runę jednego kultystę. Wymaga 2 przywołujących."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	invoke_damage = 10
	icon_state = "3"
	color = RUNE_COLOR_SUMMON

/obj/effect/rune/summon/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()
	for(var/datum/mind/M in SSticker.mode.cult)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_summon = input(user, "Kogo chcesz wezwać do [src]?", "Wyznawcy Geometry") as null|anything in cultists
	var/held_in_place = FALSE
	if(iscarbon(cultist_to_summon))
		var/mob/living/carbon/C = cultist_to_summon
		if(C.handcuffed && cultist_to_summon.pulledby)
			held_in_place = TRUE
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		to_chat(user, "<span class='cult italic'>Potrzebujesz celu przywołania!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.stat == DEAD)
		to_chat(user, "<span class='cult italic'>[cultist_to_summon] nie żyje!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target died")
		return
	if(held_in_place)
		to_chat(user, "<span class='cult italic'>[cultist_to_summon] jest unieruchomiony!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target restrained")
		return
	if(!iscultist(cultist_to_summon))
		to_chat(user, "<span class='cult italic'>[cultist_to_summon] nie jest wyznawcą Geometry!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target was deconverted")
		return
	if(is_away_level(cultist_to_summon.z))
		to_chat(user, "<span class='cult italic'>[cultist_to_summon] nie jest w naszym wymiarze!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] nagle znika w błysku czerwonego światła!</span>", \
									  "<span class='cult italic'><b>Ogarniają cię przytłaczające zawroty głowy, gdy ciska tobą przez powietrze!</b></span>")
	..()
	if(do_teleport(cultist_to_summon, get_turf(src), no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT))
		visible_message("<span class='warning'>Nad [src] materializuje się mglisty kształt i zestala w [cultist_to_summon]!</span>")
		qdel(src)
	else
		visible_message("<span class='warning'>Powietrze nad [src] faluje, ale nic się nie pojawia.</span>")

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Wrzącej krwi"
	cultist_desc = "zagotowuje krew niewiernych, którzy ją widzą, szybko zadając ogromne obrażenia. Wymaga 3 przywołujących."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = RUNE_COLOR_BURNTORANGE
	light_color = LIGHT_COLOR_LAVA
	req_cultists = 3
	invoke_damage = 10
	construct_invoke = FALSE
	var/tick_damage = 25
	rune_in_use = FALSE

/obj/effect/rune/blood_boil/do_invoke_glow()
	return

/obj/effect/rune/blood_boil/invoke(var/list/invokers)
	if(rune_in_use)
		return
	..()
	rune_in_use = TRUE
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] rozjarza się jasnym pomarańczem!</span>")
	color = "#FC9B54"
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume)
			var/atom/I = L.anti_magic_check(magic=FALSE,holy=TRUE,major = FALSE)
			if(I)
				if(isitem(I))
					to_chat(L, "<span class='userdanger'>[I] nagle rozgrzewa się do czerwoności, po czym wraca do normy!</span>")
				continue
			to_chat(L, "<span class='cultlarge'>Krew wrze ci w żyłach!</span>")
	animate(src, color = "#FCB56D", time = 4)
	sleep(4)
	if(QDELETED(src))
		return
	do_area_burn(T, 0.5)
	animate(src, color = "#FFDF80", time = 5)
	sleep(5)
	if(QDELETED(src))
		return
	do_area_burn(T, 1)
	animate(src, color = "#FFFDF4", time = 6)
	sleep(6)
	if(QDELETED(src))
		return
	do_area_burn(T, 1.5)
	new /obj/effect/hotspot(T)
	qdel(src)

/obj/effect/rune/blood_boil/proc/do_area_burn(turf/T, multiplier)
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume)
			if(L.anti_magic_check(magic=FALSE,holy=TRUE,major = FALSE))
				continue
			L.take_overall_damage(tick_damage*multiplier, tick_damage*multiplier)

//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Krainy duchów"
	cultist_desc = "materializuje duchowego sługę Geometry i pozwala ci samemu wznieść się jako duch. Przywołujący nie może zejść z runy i otrzymuje obrażenia za każdego przywołanego ducha."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "7"
	invoke_damage = 10
	construct_invoke = FALSE
	color = RUNE_COLOR_DARKRED
	var/mob/living/affecting = null
	var/ghost_limit = 1
	var/ghosts = 0

/obj/effect/rune/manifest/Initialize(mapload)
	. = ..()


/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		to_chat(user, "<span class='cult italic'>Musisz stać na [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return list()
	if(user.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='cult italic'>Duchy nie mogą przywoływać kolejnych duchów!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user is a ghost")
		return list()
	return ..()

/obj/effect/rune/manifest/invoke(var/list/invokers)
	. = ..()
	var/mob/living/user = invokers[1]
	var/turf/T = get_turf(src)
	var/choice = alert(user,"You tear open a connection to the spirit realm...",,"Summon a Cult Ghost","Ascend as a Dark Spirit","Cancel")
	if(choice == "Summon a Cult Ghost")
		var/area/A = get_area(T)
		if(initial(A.name) == "Space" || is_mining_level(T.z))
			to_chat(user, "<span class='cultitalic'><b>Zasłona nie jest tu dość słaba, by materializować duchy - musisz być na statku!</b></span>")
			return
		if(ghosts >= ghost_limit)
			to_chat(user, "<span class='cultitalic'>Podtrzymujesz już zbyt wiele duchów, by przywołać kolejne!</span>")
			fail_invoke()
			log_game("Manifest rune failed - too many summoned ghosts")
			return list()
		notify_ghosts("Aktywowano runę materializacji w [get_area(src)].", 'sound/effects/ghost2.ogg', source = src, header = "Runa materializacji")
		var/list/ghosts_on_rune = list()
		for(var/mob/dead/observer/O in T)
			if(O.client && !is_banned_from(O.ckey, ROLE_CULTIST) && !QDELETED(src) && !QDELETED(O))
				ghosts_on_rune += O
		if(!ghosts_on_rune.len)
			to_chat(user, "<span class='cultitalic'>W pobliżu [src] nie ma duchów!</span>")
			fail_invoke()
			log_game("Manifest rune failed - no nearby ghosts")
			return list()
		var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
		var/mob/living/carbon/human/cult_ghost/new_human = new(T)
		new_human.real_name = ghost_to_spawn.real_name
		new_human.alpha = 150 //Makes them translucent
		new_human.equipOutfit(/datum/outfit/ghost_cultist) //give them armor
		new_human.apply_status_effect(STATUS_EFFECT_SUMMONEDGHOST) //ghosts can't summon more ghosts
		new_human.see_invisible = SEE_INVISIBLE_OBSERVER
		ghosts++
		playsound(src, 'sound/magic/exit_blood.ogg', 50, 1)
		visible_message("<span class='warning'>Nad [src] tworzy się chmura czerwonej mgły, a z niej wychodzi... [new_human.gender == FEMALE ? "kobieta":"mężczyzna"].</span>")
		to_chat(user, "<span class='cultitalic'>Twoja krew zaczyna spływać do [src]. Musisz pozostać na miejscu i przytomny, by podtrzymać postacie przywołanych. Będzie to boleć powoli, ale nieuchronnie...</span>")
		var/obj/structure/emergency_shield/invoker/N = new(T)
		new_human.key = ghost_to_spawn.key
		SSticker.mode.add_cultist(new_human.mind, 0)
		to_chat(new_human, "<span class='cultitalic'><b>Jesteś sługą Geometry. Kult Nar'Sie nadał ci półcielesną postać i masz mu służyć za wszelką cenę.</b></span>")

		while(!QDELETED(src) && !QDELETED(user) && !QDELETED(new_human) && (user in T))
			if(user.stat || new_human.InCritical())
				break
			user.apply_damage(0.1, BRUTE)
			sleep(1)

		qdel(N)
		ghosts--
		if(new_human)
			new_human.visible_message("<span class='warning'>[new_human] nagle rozpada się w kości i popiół.</span>", \
									  "<span class='cultlarge'>Twoja więź ze światem słabnie. Twoja postać się rozpada.</span>")
			for(var/obj/I in new_human)
				new_human.dropItemToGround(I, TRUE)
			new_human.dust()
	else if(choice == "Ascend as a Dark Spirit")
		affecting = user
		affecting.add_atom_colour(RUNE_COLOR_DARKRED, ADMIN_COLOUR_PRIORITY)
		affecting.visible_message("<span class='warning'>[affecting] zamiera jak posąg, jarząc się nieziemską czerwienią.</span>", \
						 "<span class='cult'>Widzisz, co leży poza. Wszystko zostaje odsłonięte. W tej postaci twój głos grzmi donośniej i możesz oznaczać cele dla całego kultu</span>")
		var/mob/dead/observer/G = affecting.ghostize(1)
		var/datum/action/innate/cult/comm/spirit/CM = new
		var/datum/action/innate/cult/ghostmark/GM = new
		G.name = "Dark Spirit of [G.name]"
		G.color = "red"
		CM.Grant(G)
		GM.Grant(G)
		while(!QDELETED(affecting))
			if(!(affecting in T))
				user.visible_message("<span class='warning'>Upiorna macka owija się wokół [affecting] i ściąga go z powrotem na runę!</span>")
				Beam(affecting, icon_state="drainbeam", time=2)
				affecting.forceMove(get_turf(src)) //NO ESCAPE :^)
			if(affecting.key)
				affecting.visible_message("<span class='warning'>[affecting] powoli się rozluźnia, a poświata wokół przygasa.</span>", \
									 "<span class='danger'>Wracasz do swojego fizycznego ciała. [src] przestaje cię trzymać.</span>")
				affecting.Paralyze(40)
				break
			if(affecting.health <= 10)
				to_chat(G, "<span class='cultitalic'>Twoje ciało nie jest już w stanie podtrzymać połączenia!</span>")
				break
			sleep(5)
		CM.Remove(G)
		GM.Remove(G)
		affecting.remove_atom_colour(ADMIN_COLOUR_PRIORITY, RUNE_COLOR_DARKRED)
		affecting.grab_ghost()
		affecting = null
		rune_in_use = FALSE

/mob/living/carbon/human/cult_ghost/spill_organs(no_brain, no_organs, no_bodyparts) //cult ghosts never drop a brain
	no_brain = TRUE
	. = ..()

/mob/living/carbon/human/cult_ghost/getorganszone(zone, subzones = 0)
	. = ..()
	for(var/obj/item/organ/brain/B in .) //they're not that smart, really
		. -= B


/obj/effect/rune/apocalypse
	cultist_name = "Apokalipsy"
	cultist_desc = "zwiastuje czasy ostateczne. Rośnie w siłę wraz z desperacją kultu - ale z ryzykiem... skutków ubocznych."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "apoc"
	pixel_x = -32
	pixel_y = -32
	color = RUNE_COLOR_DARKRED
	req_cultists = 3
	scribe_delay = 100

/obj/effect/rune/apocalypse/invoke(var/list/invokers)
	if(rune_in_use)
		return
	. = ..()
	var/area/place = get_area(src)
	var/mob/living/user = invokers[1]
	var/datum/antagonist/cult/user_antag = user.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	var/datum/objective/eldergod/summon_objective = locate() in user_antag.cult_team.objectives
	if(summon_objective.summon_spots.len <= 1)
		to_chat(user, "<span class='cultlarge'>Zostało tylko jedno miejsce rytuału - musi zostać zachowane na ostateczne przywołanie!</span>")
		return
	if(!(place in summon_objective.summon_spots))
		to_chat(user, "<span class='cultlarge'>Runa Apokalipsy usunie jedno z miejsc, gdzie można przywołać Nar'Sie. Można ją nakreślić tylko w miejscach: [english_list(summon_objective.summon_spots)]!</span>")
		return
	summon_objective.summon_spots -= place
	rune_in_use = TRUE
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading(T)
	var/intensity = 0
	for(var/mob/living/M in GLOB.player_list)
		if(iscultist(M))
			intensity++
	intensity = max(60, 360 - (360*(intensity/GLOB.player_list.len + 0.3)**2)) //significantly lower intensity for "winning" cults
	var/duration = intensity*10
	playsound(T, 'sound/magic/enter_blood.ogg', 100, 1)
	visible_message("<span class='warning'>Z runy wybucha kolosalna fala energii, która ją przy tym dezintegruje!</span>")
	for(var/mob/living/L in viewers(3, src))
		L.Paralyze(30)
	empulse(T, 0.42*(intensity), 1, holy=TRUE)
	var/list/images = list()
	var/zmatch = T.get_virtual_z_level()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	for(var/mob/living/M in GLOB.alive_mob_list)
		if(M.get_virtual_z_level() != zmatch)
			continue
		if(ishuman(M))
			if(!iscultist(M))
				AH.remove_hud_from(M)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(hudFix), M), duration)
			var/image/A = image('icons/mob/mob.dmi',M,"cultist", ABOVE_MOB_LAYER)
			A.override = 1
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/noncult, "human_apoc", A, NONE)
			addtimer(CALLBACK(M,TYPE_PROC_REF(/atom, remove_alt_appearance),"human_apoc",TRUE), duration)
			images += A
			SEND_SOUND(M, pick(sound('sound/ambience/antag/bloodcult.ogg'),sound('sound/spookoween/ghost_whisper.ogg'),sound('sound/spookoween/ghosty_wind.ogg')))
		else
			var/construct = pick("floater","artificer","behemoth")
			var/image/B = image('icons/mob/mob.dmi',M,construct, ABOVE_MOB_LAYER)
			B.override = 1
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/noncult, "mob_apoc", B, NONE)
			addtimer(CALLBACK(M,TYPE_PROC_REF(/atom, remove_alt_appearance),"mob_apoc",TRUE), duration)
			images += B
		if(!iscultist(M))
			if(M.client)
				var/image/C = image('icons/effects/cult_effects.dmi',M,"bloodsparkles", ABOVE_MOB_LAYER)
				add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cult, "cult_apoc", C, NONE)
				addtimer(CALLBACK(M,TYPE_PROC_REF(/atom, remove_alt_appearance),"cult_apoc",TRUE), duration)
				images += C
		else
			to_chat(M, "<span class='cultlarge'>W [place.name] aktywowano runę Apokalipsy - to miejsce nie nadaje się już do przywołania!</span>")
			SEND_SOUND(M, 'sound/effects/pope_entry.ogg')
	image_handler(images, duration)
	if(intensity>=285) // Based on the prior formula, this means the cult makes up <15% of current players
		var/outcome = rand(1,100)
		switch(outcome)
			if(1 to 10)
				var/datum/round_event_control/disease_outbreak/D = new()
				var/datum/round_event_control/mice_migration/M = new()
				D.runEvent()
				M.runEvent()
			if(11 to 19)
				var/datum/round_event_control/radiation_storm/RS = new()
				RS.runEvent()
			if(20) // AQ EDIT
				var/datum/round_event_control/shit_storm/SS = new()
				SS.runEvent()
			if(21 to 30)
				var/datum/round_event_control/brand_intelligence/BI = new()
				BI.runEvent()
			if(31 to 40)
				var/datum/round_event_control/immovable_rod/R = new()
				R.runEvent()
				R.runEvent()
				R.runEvent()
			if(41 to 50)
				var/datum/round_event_control/meteor_wave/MW = new()
				MW.runEvent()
			if(51 to 60)
				var/datum/round_event_control/spider_infestation/SI = new()
				SI.runEvent()
			if(61 to 70)
				var/datum/round_event_control/anomaly/anomaly_flux/AF
				var/datum/round_event_control/anomaly/anomaly_grav/AG
				var/datum/round_event_control/anomaly/anomaly_pyro/AP
				var/datum/round_event_control/anomaly/anomaly_vortex/AV
				AF.runEvent()
				AG.runEvent()
				AP.runEvent()
				AV.runEvent()
			if(71 to 80)
				var/datum/round_event_control/spacevine/SV = new()
				var/datum/round_event_control/grey_tide/GT = new()
				SV.runEvent()
				GT.runEvent()
			if(81 to 100)
				var/datum/round_event_control/portal_storm_narsie/N = new()
				N.runEvent()
	qdel(src)

/obj/effect/rune/apocalypse/proc/image_handler(var/list/images, duration)
	var/end = world.time + duration
	set waitfor = 0
	while(end>world.time)
		for(var/image/I in images)
			I.override = FALSE
			animate(I, alpha = 0, time = 25, flags = ANIMATION_PARALLEL)
		sleep(35)
		for(var/image/I in images)
			animate(I, alpha = 255, time = 25, flags = ANIMATION_PARALLEL)
		sleep(25)
		for(var/image/I in images)
			if(I.icon_state != "bloodsparkles")
				I.override = TRUE
		sleep(190)



/proc/hudFix(mob/living/carbon/human/target)
	if(!target || !target.client)
		return
	var/obj/O = target.get_item_by_slot(ITEM_SLOT_EYES)
	if(istype(O, /obj/item/clothing/glasses/hud/security))
		var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		AH.add_hud_to(target)
