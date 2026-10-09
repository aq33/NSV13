//ANTAG DATUMS
/datum/antagonist/horror
	name = "Pradawny horror"
	roundend_category = "pradawne horrory"
	antagpanel_category = "Horror"
	banning_key = ROLE_HORROR
	show_in_antagpanel = TRUE
	prevent_roundtype_conversion = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	var/datum/mind/summoner

/datum/antagonist/horror/on_gain()
	. = ..()
	give_objectives()
	if(ishorror(owner.current) && owner.current.mind)
		var/mob/living/simple_animal/horror/H = owner.current
		H.update_horror_hud()

/datum/antagonist/horror/antag_listing_name()
	. = ..()
	var/mob/living/simple_animal/horror/H = owner.current
	if(!istype(H) || !H.victim)
		return
	if(H.host_brain)
		return ..() + ", controlling [H.host_brain.real_name]"
	return ..() + ", inside [H.victim.real_name]"

/datum/antagonist/horror/proc/give_objectives()
	if(summoner)
		var/datum/objective/newobjective = new
		newobjective.explanation_text = "Służ swojemu przywoływaczowi, [summoner.name]."
		newobjective.owner = owner
		newobjective.completed = TRUE
		objectives += newobjective
	else
		//succ some souls
		var/datum/objective/horrorascend/ascend = new
		ascend.owner = owner
		ascend.hor = owner.current
		ascend.target_amount = rand(5, 8)
		objectives += ascend
		ascend.update_explanation_text()

		//looking for antagonist we can assist
		var/list/possible_targets = list()
		for(var/datum/mind/M in SSticker.minds)
			if(M.current && M.current.stat != DEAD)
				if(ishuman(M.current))
					if(M.special_role)
						possible_targets += M

		if(possible_targets.len)
			var/datum/mind/M = pick(possible_targets)
			var/datum/objective/protect/O = new
			O.owner = owner
			O.target = M
			O.explanation_text = "Chroń i wspieraj: [M.current.real_name] ([M.assigned_role])."
			objectives += O


	//don't die while you're at is
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/objective/horrorascend
	name = "pożeranie dusz"
	var/mob/living/simple_animal/horror/hor

/datum/objective/horrorascend/update_explanation_text()
	. = ..()
	explanation_text = "Pożryj [target_amount] dusz."

/datum/objective/horrorascend/check_completion()
	if(hor && hor.consumed_souls >= target_amount)
		return TRUE
	return FALSE


//SPAWNER
/obj/item/horrorspawner
	name = "podejrzany transporter dla zwierząt"
	desc = "W środku jest jakieś stworzenie. Widać wystające z niego macki."
	icon = 'icons/obj/pet_carrier.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "pet_carrier"
	icon_state = "pet_carrier_occupied"
	var/used = FALSE
	color = rgb(130, 105, 160)

/obj/item/horrorspawner/attack_self(mob/living/user)
	if(used)
		to_chat(user, "Transporter nie reaguje.")
		return
	used = TRUE
	to_chat(user, "Próbujesz obudzić stworzenie w środku...")
	sleep(5 SECONDS)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the eldritch horror in service of [user.real_name]?", ROLE_HORROR, null, 100)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/horror/H = new /mob/living/simple_animal/horror(get_turf(src))
		H.key = C.key
		H.mind.enslave_mind_to_creator(user)
		H.mind.memory += "Jesteś <span class='purple bold'>[H.real_name]</span>, pradawnym horrorem. Pożeraj dusze, by ewoluować.<br>"
		var/datum/antagonist/horror/S = new
		S.summoner = user.mind
		S.antag_memory += "<b>[user.mind]</b> zbudził cię z wiecznego snu. W podzięce pomóż mu w realizacji jego celów.<br>"
		H.mind.add_antag_datum(S)
		log_game("[key_name(user)] has summoned [key_name(H)], an eldritch horror.")
		to_chat(user, "<span class='bold'>[H.real_name]</span> budzi się, by ci służyć!")
		used = TRUE
		icon_state = "pet_carrier_open"
	else
		to_chat(user, "Stworzenie spogląda na ciebie jednym z oczu, po czym znów zapada w sen.")
		used = FALSE
		return

//Tentacle arm
/obj/item/horrortentacle
	name = "macka"
	desc = "Długi, oślizgły wyrostek przypominający rękę."
	icon = 'aquila/icons/obj/horror.dmi'
	icon_state = "horrortentacle"
	item_state = "tentacle"
	lefthand_file = 'aquila/icons/mob/inhands/antag/horror_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/antag/horror_righthand.dmi'
	resistance_flags = ACID_PROOF
	force = 17
	item_flags = ABSTRACT | DROPDEL
	reach = 2 // AQUILA - Yogs gives the 2 tile range through its weapon_stats REACH, which we don't have
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/horrortentacle/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/horrortentacle/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='velvet bold'>Zastosowania:</span>")
	to_chat(user, "<span class='velvet'><b>Wszystkie ataki działają do 2 pól.</b></span>")
	to_chat(user, "<span class='velvet'><b>Intencja pomocy:</b> zwykła funkcja ręki.</span>")
	to_chat(user, "<span class='velvet'><b>Intencja rozbrojenia:</b> smagnięcie macką, które rozbraja przeciwnika.</span>")
	to_chat(user, "<span class='velvet'><b>Intencja chwytu:</b> natychmiastowy agresywny chwyt przeciwnika. Możesz też nim rzucić!</span>")
	to_chat(user, "<span class='velvet'><b>Intencja ataku:</b> smagnięcie macką, które rani przeciwnika.</span>")
	to_chat(user, "<span class='velvet'>Służy też do podważania niezablokowanych śluz.</span>")

/obj/item/horrortentacle/attack(atom/target, mob/living/user)
	if(isliving(target))
		user.Beam(target, "purpletentacle", 'aquila/icons/effects/horror_beam.dmi', time=5)
		var/mob/living/L = target
		switch(user.a_intent)
			if(INTENT_HELP)
				L.attack_hand(user)
				return
			if(INTENT_GRAB)
				if(L != user)
					L.grabbedby(user)
					L.grippedby(user, instant = TRUE)
					L.Knockdown(30)
				return
			if(INTENT_DISARM)
				if(iscarbon(L))
					var/mob/living/carbon/C = L
					var/obj/item/I = C.get_active_held_item()
					if(I)
						if(C.dropItemToGround(I))
							playsound(loc, "sound/weapons/whipgrab.ogg", 30)
							target.visible_message("<span class='danger'>[user] wytrąca macką [I] z ręki [C]!</span>","<span class='userdanger'>Macka wytrąca ci [I] z ręki!</span>")
							return
						else
							to_chat(user, "<span class='danger'>Nie możesz wyrwać [I] z rąk [C]!</span>")
							return
					else
						C.attack_hand(user)
						return
	. = ..()

/obj/item/horrortentacle/afterattack(atom/target, mob/user, proximity)
	if(isliving(user.pulling) && user.pulling != target)
		var/mob/living/H = user.pulling
		user.visible_message("<span class='warning'>[user] rzuca [H] za pomocą [src]!</span>", "<span class='warning'>Rzucasz [H] za pomocą [src].</span>")
		H.throw_at(target, 8, 2)
		H.Knockdown(30)
		return
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if((A.id_scan_hacked() || A.allowed(user)) && A.hasPower()) // AQUILA - Yogs requiresID() is our id_scan_hacked() negated
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>Rygle śluzy nie pozwalają jej sforsować!</span>")
			return
		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] wciska [src] w śluzę i zaczyna ją podważać!</span>", "<span class='warning'>Zaczynasz siłą otwierać śluzę.</span>",
			"<span class='italics'>Słyszysz zgrzyt metalu.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
			if(!do_after(user, 10 SECONDS, target = A))
				return
		user.visible_message("<span class='warning'>[user] siłą otwiera śluzę za pomocą [src]!</span>", "<span class='warning'>Siłą otwierasz śluzę.</span>",
		"<span class='italics'>Słyszysz zgrzyt metalu.</span>")
		A.open(2)
		return
	. = ..()

/obj/item/horrortentacle/suicide_act(mob/user) //this will never be called, since horror stops suicide, but might as well if they get tentacle through other means
	user.visible_message("<span class='suicide'>[src] mocno owija się wokół [user], ściskając szyję! Wygląda na to, że [user] próbuje popełnić samobójstwo!</span>")
	return (OXYLOSS)

//Pinpointer
/atom/movable/screen/alert/status_effect/agent_pinpointer/horror
	name = "Lokalizator duszy"
	desc = "Znajdź duszę swojego celu."

/datum/status_effect/agent_pinpointer/horror
	id = "horror_pinpointer"
	minimum_range = 0
	range_fuzz_factor = 0
	tick_interval = 20
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/horror

/datum/status_effect/agent_pinpointer/horror/scan_for_target()
	return

//TRAPPED MIND - when horror takes control over your body, you become a mute trapped mind
/mob/living/captive_brain
	name = "mózg nosiciela"
	real_name = "mózg nosiciela"
	var/datum/action/innate/resist_control/R
	var/mob/living/simple_animal/horror/H

/mob/living/captive_brain/Initialize(mapload, gen=1)
	..()
	R = new
	R.Grant(src)

/mob/living/captive_brain/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>Nie możesz mówić IC (wyciszenie).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return
	if(ishorror(loc))
		message = sanitize(message)
		if(!message)
			return
		if(stat == 2)
			return say_dead(message)
		to_chat(src, "<span class='alien italics'>Szepczesz bezgłośnie: \"[message]\"</span>")
		to_chat(H.victim, "<span class='alien italics'>[src] szepcze: \"[message]\"</span>")
		for(var/M in GLOB.dead_mob_list)
			if(isobserver(M))
				var/rendered = "<span class='changeling'><i>[src] przekazuje: \"[message]\"</i></span>"
				var/link = FOLLOW_LINK(M, H.victim)
				to_chat(M, "[link] [rendered]")

/mob/living/captive_brain/emote(act, m_type = null, message = null, intentional = FALSE)
	return

/datum/action/innate/resist_control
	name = "Opieraj się kontroli"
	desc = "Spróbuj odzyskać kontrolę nad własnym mózgiem. Silny impuls nerwowy powinien wystarczyć."
	background_icon_state = "bg_ecult"
	icon_icon = 'aquila/icons/mob/actions/actions_horror.dmi'
	button_icon_state = "resist_control"

/datum/action/innate/resist_control/Activate()
	var/mob/living/captive_brain/B = owner
	if(B)
		B.try_resist()

/mob/living/captive_brain/resist()
	try_resist()

/mob/living/captive_brain/proc/try_resist()
	var/delay = rand(20 SECONDS,30 SECONDS)
	if(H.horrorupgrades["deep_control"])
		delay += rand(20 SECONDS,30 SECONDS)
	to_chat(src, "<span class='danger'>Zaczynasz uparcie opierać się kontroli pasożyta.</span>")
	to_chat(H.victim, "<span class='danger'>Czujesz, że uwięziony umysł [src] zaczyna opierać się twojej kontroli.</span>")
	addtimer(CALLBACK(src, PROC_REF(return_control)), delay)

/mob/living/captive_brain/proc/return_control()
	if(!H || !H.controlling)
		return
	to_chat(src, "<span class='userdanger'>Ogromnym wysiłkiem woli odzyskujesz kontrolę nad ciałem!</span>")
	to_chat(H.victim, "<span class='danger'>Czujesz, jak kontrola nad mózgiem nosiciela wymyka ci się z uścisku, więc wycofujesz trąbki, zanim dzikie impulsy nerwowe cię skrzywdzą.</span>")
	H.detatch()
