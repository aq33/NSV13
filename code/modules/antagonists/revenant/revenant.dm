//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invisible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

#define INVISIBILITY_REVENANT 50

/mob/living/simple_animal/revenant
	name = "upiór"
	desc = "Złowrogi duch."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	var/icon_idle = "revenant_idle"
	var/icon_reveal = "revenant_revealed"
	var/icon_stun = "revenant_stun"
	var/icon_drain = "revenant_draining"
	var/stasis = FALSE
	mob_biotypes = list(MOB_SPIRIT)
	incorporeal_move = INCORPOREAL_MOVE_JAUNT
	invisibility = INVISIBILITY_REVENANT
	health = INFINITY //Revenants don't use health, they use essence instead
	maxHealth = INFINITY
	layer = GHOST_LAYER
	healable = FALSE
	spacewalk = TRUE
	sight = SEE_SELF
	throwforce = 0

	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	response_help   = "przenika przez"
	response_disarm = "przeczesuje"
	response_harm   = "uderza na wylot"
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) //I don't know how you'd apply those, but revenants no-sell them anyway.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	friendly = "dotyka"
	status_flags = 0
	wander = FALSE
	density = FALSE
	movement_type = FLYING
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = TRUE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/revenant

	mobchatspan = "revenminor"

	var/essence = 75 //The resource, and health, of revenants.
	var/essence_regen_cap = 75 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regenerating = TRUE //If the revenant regenerates essence or not
	var/essence_regen_amount = 5 //How much essence regenerates
	var/essence_accumulated = 0 //How much essence the revenant has stolen
	var/essence_excess = 0 //How much stolen essence avilable for unlocks
	var/revealed = FALSE //If the revenant can take damage from normal sources.
	var/unreveal_time = 0 //How long the revenant is revealed for, is about 2 seconds times this var.
	var/unstun_time = 0 //How long the revenant is stunned for, is about 2 seconds times this var.
	var/inhibited = FALSE //If the revenant's abilities are blocked by a chaplain's power.
	var/essence_drained = 0 //How much essence the revenant will drain from the corpse it's feasting on.
	var/draining = FALSE //If the revenant is draining someone.
	var/list/drained_mobs = list() //Cannot harvest the same mob twice
	var/perfectsouls = 0 //How many perfect, regen-cap increasing souls the revenant has. //TODO, add objective for getting a perfect soul(s?)
	var/generated_objectives_and_spells = FALSE
	discovery_points = 4000

/mob/living/simple_animal/revenant/Initialize(mapload)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/night_vision/revenant(null))
	AddSpell(new /obj/effect/proc_holder/spell/self/revenant_phase_shift(null))
	AddSpell(new /obj/effect/proc_holder/spell/targeted/telepathy/revenant(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/defile(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/overload(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/blight(null))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction(null))
	random_revenant_name()
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE)

/mob/living/simple_animal/revenant/Destroy()
	. = ..()

	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		qdel(beacon)

/mob/living/simple_animal/revenant/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	return FALSE

/mob/living/simple_animal/revenant/proc/random_revenant_name()
	var/built_name = ""
	built_name += pick(strings(REVENANT_NAME_FILE, "spirit_type"))
	built_name += " of "
	built_name += pick(strings(REVENANT_NAME_FILE, "adverb"))
	built_name += pick(strings(REVENANT_NAME_FILE, "theme"))
	name = built_name

/mob/living/simple_animal/revenant/Login()
	..()
	to_chat(src, "<span class='deadsay'><span class='big bold'>Jesteś upiorem.</span></span>")
	to_chat(src, "<b>Twojego dawniej zwyczajnego ducha nasyciły obce energie, czyniąc z niego upiora.</b>")
	to_chat(src, "<b>Nie jesteś martwy ani żywy, tylko gdzieś pomiędzy. Możesz w ograniczonym stopniu oddziaływać na oba światy.</b>")
	to_chat(src, "<b>Jesteś niezniszczalny i niewidzialny dla wszystkich poza innymi duchami. Większość zdolności cię ujawnia, czyniąc cię podatnym na ataki.</b>")
	to_chat(src, "<b>Aby istnieć, musisz wysysać esencję życiową z ludzi. Esencja to twój zasób i zdrowie zarazem - zasila wszystkie twoje zdolności.</b>")
	to_chat(src, "<b><i>Nie pamiętasz niczego z poprzednich żyć i nie zapamiętasz niczego z tego po swojej śmierci.</i></b>")
	to_chat(src, "<b>Więcej dowiesz się z <a href=\"https://tgstation13.org/wiki/Revenant\">artykułu na wiki</a>.</b>")
	if(!generated_objectives_and_spells)
		generated_objectives_and_spells = TRUE
		mind.assigned_role = ROLE_REVENANT
		mind.special_role = ROLE_REVENANT
		SEND_SOUND(src, sound('sound/effects/ghost.ogg'))
		mind.add_antag_datum(/datum/antagonist/revenant)

//Life, Stat, Hud Updates, and Say
/mob/living/simple_animal/revenant/Life()
	if(stasis)
		return
	if(revealed && essence <= 0)
		death()
	if(unreveal_time && world.time >= unreveal_time)
		unreveal_time = 0
		revealed = FALSE
		incorporeal_move = INCORPOREAL_MOVE_JAUNT
		invisibility = INVISIBILITY_REVENANT
		to_chat(src, "<span class='revenboldnotice'>Znów jesteś ukryty.</span>")
	if(unstun_time && world.time >= unstun_time)
		unstun_time = 0
		notransform = FALSE
		to_chat(src, "<span class='revenboldnotice'>Znów możesz się ruszać!</span>")
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence = min(essence_regen_cap, essence+essence_regen_amount)
		update_action_buttons_icon() //because we update something required by our spells in life, we need to update our buttons
	update_spooky_icon()
	update_health_hud()
	..()

/mob/living/simple_animal/revenant/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Obecna esencja"] = GENERATE_STAT_TEXT("[essence]/[essence_regen_cap]E")
	tab_data["Skradziona esencja"] = GENERATE_STAT_TEXT("[essence_accumulated]E")
	tab_data["Niewykorzystana skradziona esencja"] = GENERATE_STAT_TEXT("[essence_excess]E")
	tab_data["Skradzione doskonałe dusze"] = GENERATE_STAT_TEXT("[perfectsouls]")
	return tab_data

/mob/living/simple_animal/revenant/update_health_hud()
	if(hud_used)
		var/essencecolor = "#8F48C6"
		if(essence > essence_regen_cap)
			essencecolor = "#9A5ACB" //oh boy you've got a lot of essence
		else if(!essence)
			essencecolor = "#1D2953" //oh jeez you're dying
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[essencecolor]'>[essence]E</font></div>")

/mob/living/simple_animal/revenant/med_hud_set_health()
	return //we use no hud

/mob/living/simple_animal/revenant/med_hud_set_status()
	return //we use no hud

/mob/living/simple_animal/revenant/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, "<span class='warning'>Twoja wiadomość zawiera zakazane słowa.</span>")
		return
	message = treat_message_min(message)
	src.log_talk(message, LOG_SAY)
	var/rendered = "<span class='revennotice'><b>[src]</b> mówi: \"[message]\"</span>"
	for(var/mob/M in GLOB.mob_list)
		if(isrevenant(M))
			to_chat(M, rendered)
		else if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	return


//Immunities

/mob/living/simple_animal/revenant/ex_act(severity, target)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/bullet_act()
	if(!revealed || stasis)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/simple_animal/revenant/rad_act(amount)
	return

//damage, gibbing, and dying
/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/nullrod))
		visible_message("<span class='warning'>[src] gwałtownie się wzdryga!</span>", \
						"<span class='revendanger'>Gdy [W] przechodzi przez ciebie, czujesz, jak uchodzi z ciebie esencja!</span>")
		adjustBruteLoss(25) //hella effective
		inhibited = TRUE
		update_action_buttons_icon()
		addtimer(CALLBACK(src, PROC_REF(reset_inhibit)), 30)

/mob/living/simple_animal/revenant/proc/reset_inhibit()
	inhibited = FALSE
	update_action_buttons_icon()

/mob/living/simple_animal/revenant/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && !revealed)
		return FALSE
	. = amount
	essence = max(0, essence-amount)
	if(updating_health)
		update_health_hud()
	if(!essence)
		death()

/mob/living/simple_animal/revenant/dust(just_ash, drop_items, force)
	death()

/mob/living/simple_animal/revenant/gib()
	death()

/mob/living/simple_animal/revenant/death()
	if(!revealed || stasis) //Revenants cannot die if they aren't revealed //or are already dead
		return 0
	stasis = TRUE
	to_chat(src, "<span class='revendanger'>NIE! Nie... już za późno, czujesz, jak twoja esencja [pick("się rozpada", "odpływa")]...</span>")
	notransform = TRUE
	revealed = TRUE
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, 1)
	visible_message("<span class='warning'>[src] wydaje słabnący wrzask, a wokół rozpadającego się ciała wiruje fioletowa mgła!</span>")
	icon_state = "revenant_draining"
	for(var/i = alpha, i > 0, i -= 10)
		stoplag()
		alpha = i
	visible_message("<span class='danger'>Ciało [src] rozpada się w drobny stosik niebieskiego pyłu.</span>")
	var/reforming_essence = essence_regen_cap //retain the gained essence capacity
	var/obj/item/ectoplasm/revenant/R = new(get_turf(src))
	R.essence = max(reforming_essence - 15 * perfectsouls, 75) //minus any perfect souls
	R.old_key = client.key //If the essence reforms, the old revenant is put back in the body
	R.revenant = src
	invisibility = INVISIBILITY_ABSTRACT
	revealed = FALSE
	ghostize(FALSE)//Don't re-enter invisible corpse


//reveal, stun, icon updates, cast checks, and essence changing
/mob/living/simple_animal/revenant/proc/phase_shift()
	if(unreveal_time) //An ability has forced the revenant to be vulnerable and this should not override that
		to_chat(src, "<span class='revenwarning'>Nie możesz jeszcze stać się bezcielesny!</span>")
		return FALSE

	else if(revealed) //Okay, the revenant wasn't forced to be revealed, are they currently vulnerable
		revealed = FALSE
		incorporeal_move = INCORPOREAL_MOVE_JAUNT
		invisibility = INVISIBILITY_REVENANT


	else //Revenant isn't revealed, whether by force or their own will, so this means they are currently invisible
		revealed = TRUE
		incorporeal_move = FALSE
		invisibility = 0
	update_spooky_icon()
	return TRUE

/mob/living/simple_animal/revenant/proc/reveal(time)
	if(!src)
		return
	if(time <= 0)
		return
	revealed = TRUE
	invisibility = 0
	incorporeal_move = FALSE
	if(!unreveal_time)
		to_chat(src, "<span class='revendanger'>Zostajesz ujawniony!</span>")
		unreveal_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>Zostajesz ujawniony!</span>")
		unreveal_time = unreveal_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	notransform = TRUE
	if(!unstun_time)
		to_chat(src, "<span class='revendanger'>Nie możesz się ruszać!</span>")
		unstun_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>Nie możesz się ruszać!</span>")
		unstun_time = unstun_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/update_spooky_icon()
	if(revealed)
		if(notransform)
			if(draining)
				icon_state = icon_drain
			else
				icon_state = icon_stun
		else
			icon_state = icon_reveal
	else
		icon_state = icon_idle

/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(!src)
		return
	var/turf/T = get_turf(src)
	if(isclosedturf(T))
		to_chat(src, "<span class='revenwarning'>Nie możesz używać zdolności z wnętrza ściany.</span>")
		return FALSE
	for(var/obj/O in T)
		if(O.density && !O.CanPass(src, T))
			to_chat(src, "<span class='revenwarning'>Nie możesz używać zdolności wewnątrz litego obiektu.</span>")
			return FALSE
	if(inhibited)
		to_chat(src, "<span class='revenwarning'>Energia zerująca tłumi twoje moce!</span>")
		return FALSE
	if(!change_essence_amount(essence_cost, TRUE))
		to_chat(src, "<span class='revenwarning'>Brakuje ci esencji, by użyć tej zdolności.</span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/revenant/proc/unlock(essence_cost)
	if(essence_excess < essence_cost)
		return FALSE
	essence_excess -= essence_cost
	update_action_buttons_icon()
	return TRUE

/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = FALSE, source = null)
	if(!src)
		return
	if(essence + essence_amt < 0)
		return
	essence = max(0, essence+essence_amt)
	update_health_hud()
	if(essence_amt > 0)
		essence_accumulated = max(0, essence_accumulated+essence_amt)
		essence_excess = max(0, essence_excess+essence_amt)
	update_action_buttons_icon()
	if(!silent)
		if(essence_amt > 0)
			to_chat(src, "<span class='revennotice'>Zyskujesz [essence_amt]E[source ? " od [source]":""].</span>")
		else
			to_chat(src, "<span class='revenminor'>Tracisz [abs(essence_amt)]E[source ? " przez [source]":""].</span>")
	return 1

/mob/living/simple_animal/revenant/proc/death_reset()
	revealed = FALSE
	unreveal_time = 0
	notransform = 0
	unstun_time = 0
	inhibited = FALSE
	draining = FALSE
	incorporeal_move = INCORPOREAL_MOVE_JAUNT
	invisibility = INVISIBILITY_REVENANT
	alpha=255
	stasis = FALSE


//reforming
/obj/item/ectoplasm/revenant
	name = "lśniący osad"
	desc = "Kupka drobnego niebieskiego pyłu. Wokół niej wiją się cienkie smugi fioletowej mgły."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	var/essence = 75 //the maximum essence of the reforming revenant
	var/reforming = TRUE
	var/inert = FALSE
	var/old_key //key of the previous revenant, will have first pick on reform.
	var/mob/living/simple_animal/revenant/revenant

/obj/item/ectoplasm/revenant/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(try_reform)), 600)

/obj/item/ectoplasm/revenant/proc/scatter()
	qdel(src)

/obj/item/ectoplasm/revenant/proc/try_reform()
	if(reforming)
		reforming = FALSE
		reform()
	else
		inert = TRUE
		visible_message("<span class='warning'>[src] uspokaja się i wydaje się martwy.</span>")

/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message("<span class='notice'>[user] rozsypuje [src] na wszystkie strony.</span>", \
						 "<span class='notice'>Rozsypujesz [src] po okolicy. Drobiny powoli znikają.</span>")
	user.dropItemToGround(src)
	scatter()

/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(inert)
		return
	visible_message("<span class='notice'>Po uderzeniu [src] rozpada się na drobiny, które rozpływają się w nicość.</span>")
	scatter()

/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += "<span class='revennotice'>Wydaje się bezwładny.</span>"
	else if(reforming)
		. += "<span class='revenwarning'>Porusza się i zniekształca. Lepiej to zniszczyć.</span>"

/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || QDELETED(revenant) || inert)
		return
	var/key_of_revenant
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	forceMove(drop_location()) //In case it's in a backpack or someone's hand
	revenant.forceMove(loc)
	if(old_key)
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.client && M.client.key == old_key) //Only recreates the mob if the mob the client is in is dead
				key_of_revenant = old_key
				break
	if(!key_of_revenant)
		message_admins("The new revenant's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
		var/list/candidates = pollCandidatesForMob("Chcesz zostać [revenant.name] (odradzanie)?", ROLE_REVENANT, /datum/role_preference/midround_ghost/revenant, 7.5 SECONDS, revenant)
		if(!LAZYLEN(candidates))
			qdel(revenant)
			message_admins("No candidates were found for the new revenant. Oh well!")
			inert = TRUE
			visible_message("<span class='revenwarning'>[src] uspokaja się i wydaje się martwy.</span>")
			return
		var/mob/dead/observer/C = pick(candidates)
		key_of_revenant = C.key
		if(!key_of_revenant)
			qdel(revenant)
			message_admins("No ckey was found for the new revenant. Oh well!")
			inert = TRUE
			visible_message("<span class='revenwarning'>[src] uspokaja się i wydaje się martwy.</span>")
			return

	message_admins("[key_of_revenant] has been [old_key == key_of_revenant ? "re":""]made into a revenant by reforming ectoplasm.")
	log_game("[key_of_revenant] was [old_key == key_of_revenant ? "re":""]made as a revenant by reforming ectoplasm.")
	visible_message("<span class='revenboldnotice'>[src] nagle unosi się w powietrze, po czym znika.</span>")

	revenant.essence = essence
	revenant.essence_regen_cap = essence
	revenant.death_reset()
	revenant.key = key_of_revenant
	revenant = null
	qdel(src)

/obj/item/ectoplasm/revenant/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] wdycha [src]! Wygląda na to, że chce odwiedzić krainę cieni!</span>")
	scatter()
	return (OXYLOSS)

/obj/item/ectoplasm/revenant/Destroy()
	if(!QDELETED(revenant))
		qdel(revenant)
	..()

//objectives
/datum/objective/revenant
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(350,600)
	explanation_text = "Wchłoń od ludzi [targetAmount] punktów esencji."
	..()

/datum/objective/revenant/check_completion()
	if(!isrevenant(owner.current))
		return ..()
	var/mob/living/simple_animal/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return ..()
	var/essence_stolen = R.essence_accumulated
	if(essence_stolen < targetAmount)
		return ..()
	return TRUE

/datum/objective/revenantFluff

/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list("Wspieraj i zaostrzaj istniejące zagrożenia w krytycznych momentach.", \
									 "Unikaj zabijania na oczach innych.", \
									 "Wywołaj jak najwięcej chaosu i gniewu, nie dając się zabić.", \
									 "Uszkodź statek i doprowadź jak największą jego część do rdzy i bezużyteczności.", \
									 "Wyłącz i zepsuj jak najwięcej maszyn.", \
									 "Dopilnuj, by wszelka święta broń stała się bezużyteczna.", \
									 "Przeszkadzaj załodze, starając się nie dać zauważyć.", \
									 "Uprzykrz życie załodze, jak tylko się da.", \
									 "Uprzykrz życie klaunowi, jak tylko się da.", \
									 "Uprzykrz życie kapitanowi, jak tylko się da.", \
									 "W miarę możliwości uniemożliwiaj użycie broni energetycznej.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return TRUE
