#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("bulgocze")
	emote_hear = list("bulgocze")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage = 20
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attacktext = "rzuca się na"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/food/meat/slab = 2)

	var/morphed = FALSE
	var/melee_damage_disguised = 5
	var/eat_while_disguised = FALSE
	var/atom/movable/form = null
	var/morph_time = 0
	var/static/list/blacklist_typecache = typecacheof(list(
	/atom/movable/screen,
	/obj/anomaly,
	/obj/eldritch/narsie,
	/mob/living/simple_animal/hostile/morph,
	/obj/effect,
	/mob/camera
	))
	var/atom/movable/throwatom = null

	var/playstyle_string = "<span class='big bold'>Jesteś morfem,</span></b> naukową abominacją stworzoną głównie z komórek zmiennokształtnego. \
							Możesz przybrać postać czegokolwiek w pobliżu, klikając to z Shiftem. Zauważą to pobliscy \
							obserwatorzy, a zrobić to możesz raz na pięć sekund. W przybranej postaci poruszasz się szybciej, ale zadajesz \
							mniej obrażeń. Do tego każdy w promieniu trzech pól, kto ci się przyjrzy, wyczuje niepokojącą nienaturalność. \
							Możesz zaatakować dowolny przedmiot lub martwą istotę, by ją pożreć - istoty przywracają zdrowie. \
							Wreszcie możesz wrócić do pierwotnej postaci, klikając siebie z Shiftem.</b>"

	mobchatspan = "blob"
	discovery_points = 2000
	var/datum/morph_stomach/morph_stomach
	var/datum/action/innate/morph_stomach/stomach_action

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	morph_stomach = new(src)
	stomach_action = new(morph_stomach)
	stomach_action.Grant(src)
	. = ..()

/mob/living/simple_animal/hostile/morph/Destroy()
	QDEL_NULL(morph_stomach)
	QDEL_NULL(stomach_action)
	. = ..()

/mob/living/simple_animal/hostile/morph/proc/RemoveContents(atom/movable/A, throwatom_required = FALSE)
	A.forceMove(loc)
	morph_stomach.favorites -= REF(A)
	if(throwatom == A && !throwatom_required)
		throwatom = null

/mob/living/simple_animal/hostile/morph/proc/AddContents(atom/movable/A)
	A.forceMove(src)

/mob/living/simple_animal/hostile/morph/ClickOn(atom/A)
	if(throwatom)
		RemoveContents(throwatom, TRUE)
		throwatom.safe_throw_at(A, throwatom.throw_range, throwatom.throw_speed, src, null, null, null, move_force)
		visible_message("<span class='warning'>[src] pluje [throwatom] w [A]!</span>")
		throwatom = null
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
		morph_stomach.ui_update()
	. = ..()


/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = form.examine(user)
		if(get_dist(user,src)<=3)
			. += "<span class='warning'>Coś tu nie wygląda tak, jak powinno...</span>"
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/med_hud_set_health()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/med_hud_set_status()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(morphed && !eat_while_disguised)
		to_chat(src, "<span class='warning'>Nie możesz niczego jeść, będąc w przebraniu!</span>")
		return FALSE
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] połyka [A] w całości!</span>")
		AddContents(A)
		morph_stomach.ui_update()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore(TRUE)
			return
		if(allowed(A))
			assume(A)
	else
		to_chat(src, "<span class='warning'>Twoja skóra kameleona wciąż się regeneruje!</span>")

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	morphed = TRUE
	form = target

	visible_message("<span class='warning'>[src] nagle się wykręca i zmienia kształt, stając się kopią [target]!</span>", \
					"<span class='notice'>Wykręcasz ciało i przybierasz postać [target].</span>")
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)	//fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x
	density = target.density

	if(isliving(target))
		var/mob/living/L = target
		mobchatspan = L.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	//Morphed is weaker
	melee_damage = melee_damage_disguised
	set_varspeed(0)

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/morph/proc/restore(var/intentional = FALSE)
	if(!morphed)
		if(intentional)
			to_chat(src, "<span class='warning'>Już masz swoją normalną postać!</span>")
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)

	visible_message("<span class='warning'>[src] nagle zapada się w sobie, rozpływając się w stertę zielonego mięsa!</span>", \
					"<span class='notice'>Wracasz do swojego normalnego ciała.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage = initial(melee_damage)
	set_varspeed(initial(speed))

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message("<span class='warning'>[src] wykręca się i rozpływa w stertę zielonego mięsa!</span>", \
						"<span class='userdanger'>Twoja skóra pęka! Twoje ciało się rozpada! Żadne przebranie nie odwróci śmier--</span>")
		restore()
	barf_contents()
	..()

/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		RemoveContents(AM)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))
	morph_stomach.ui_update()

/mob/living/simple_animal/hostile/morph/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(var/list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/A as() in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(morphed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(morphed && !melee_damage_disguised)
		to_chat(src, "<span class='warning'>Nie możesz atakować, będąc w przebraniu!</span>")
		return
	if(isliving(target)) //Eat living beings to store them for a snack, or other uses
		var/mob/living/L = target
		if(L.stat)
			if(L.stat == DEAD)
				eat(L)
			else if(do_after(src, 30, target = L)) //Don't Return after this, it's important that the morph can attack softcrit targets to bring them into hardcrit
				eat(L)
	else if(isitem(target)) //Eat items for later use
		var/obj/item/I = target
		if(!I.anchored)
			eat(I)
			return
	return ..()
//Ambush attack
/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/M)
	if(morphed)
		M.Knockdown(40)
		M.reagents.add_reagent(/datum/reagent/toxin/morphvenom, 7)
		to_chat(M, "<span class='userdanger'>[src] cię gryzie!</span>")
		visible_message("<span class='danger'>[src] brutalnie gryzie [M]!</span>",\
				"<span class='userdanger'>Napadasz z zasadzki na [M]!</span>", null, COMBAT_MESSAGE_RANGE)
		restore()
	else
		..()

//Spawn Event

/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/ghost_role/morph
	weight = 2
	max_occurrences = 1

/datum/round_event/ghost_role/morph
	minimum_required = 1
	role_name = "morphling"

/datum/round_event/ghost_role/morph/spawn_role()
	var/list/candidates = get_candidates(ROLE_MORPH, /datum/role_preference/midround_ghost/morph)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!length(GLOB.xeno_spawn)) // AQUILA EDIT - an empty list is not null
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Morph"
	player_mind.special_role = "Morph"
	player_mind.add_antag_datum(/datum/antagonist/morph)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a morph by an event.")
	log_game("[key_name(S)] was spawned as a morph by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
