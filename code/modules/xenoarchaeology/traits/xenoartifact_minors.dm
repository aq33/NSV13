//Minor traits - Use the to define aspects of the artifact without any immediate interaction
//============
// Looped, increases charge towards 100
//============
/datum/xenoartifact_trait/minor/looped
	desc = "Looped"
	label_desc = "Zapętlony: artefakt zasila sam siebie i wzmacnia własny ładunek."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/looped/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>[item.name] pokazuje odczyt oporu [X.charge_req*0.1].</span>")
		return TRUE
	return ..()

/datum/xenoartifact_trait/minor/looped/activate(obj/item/xenoartifact/X)
	X.charge = ((100-X.charge)*0.2)+X.charge //This should generally cut off around 100

//============
// Capacitive, gives the artifact extra uses before it starts cooldown
//============
/datum/xenoartifact_trait/minor/capacitive
	desc = "Capacitive"
	label_desc = "Pojemnościowy: struktura artefaktu pozwala mu przechowywać dodatkowe ładunki."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/charges //Extra uses, not total
	var/saved_cooldown //This may be considered messy but it's a more practical approach that avoids making an edgecase

/datum/xenoartifact_trait/minor/capacitive/on_init(obj/item/xenoartifact/X)
	charges = pick(0, 1, 2) //Extra charges, not total

/datum/xenoartifact_trait/minor/capacitive/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>Po dotknięciu [X.name] jeżą ci się włosy na karku.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/capacitive/activate(obj/item/xenoartifact/X)
	if(!(saved_cooldown) && X.cooldown)
		saved_cooldown = X.cooldown //Avoid doing this on init beacause malfunctions can change it in the future
	if(charges)
		charges -= 1
		X.cooldown = -1000 SECONDS //This is better than making a unique interaction in xenoartifact.dm
		return
	charges = pick(0, 1, 2)
	playsound(get_turf(X), 'sound/machines/capacitor_charge.ogg', 50, TRUE)
	X.cooldown = saved_cooldown
	saved_cooldown = null

/datum/xenoartifact_trait/minor/capacitive/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='info'>[item.name] pokazuje odczyt przeładowania [charges/3].</span>")
		return TRUE
	return ..()

//============
// Dense, makes the artifact mimic a structure
//============
/datum/xenoartifact_trait/minor/dense //Rather large, quite gigantic, particularly big
	desc = "Dense"
	label_desc = "Gęsty: artefakt jest gęsty i trudno go podnieść, ale konstrukcja ma nieco wyższe tempo reakcji."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/light, /datum/xenoartifact_trait/minor/heavy, /datum/xenoartifact_trait/minor/blocking, /datum/xenoartifact_trait/minor/anchor, /datum/xenoartifact_trait/minor/slippery)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/dense/on_init(obj/item/xenoartifact/X)
	X.density = TRUE
	X.interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	X.interaction_flags_item = INTERACT_ATOM_ATTACK_HAND
	X.charge_req += 20

//============
// Sharp, makes the artifact do extra damage and slice type
//============
/datum/xenoartifact_trait/minor/sharp
	desc = "Sharp"
	label_desc = "Ostry: artefakt jest zakończony cienkim szpicem. Idealny do przebijania balonów."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/sharp/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>[X.name] wydaje się ostry.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sharp/on_init(obj/item/xenoartifact/X)
	X.sharpness = IS_SHARP_ACCURATE
	X.force = X.charge_req*0.12
	X.attack_verb = list("rozłupuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	X.attack_weight = 2
	X.armour_penetration = 5

//============
// Cooler, reduces cooldown times
//============
/datum/xenoartifact_trait/minor/cooler
	desc = "Frosted"
	label_desc = "Oszroniony: artefakt ma wyjątkową właściwość aktywnego chłodzenia się. Wydaje się to też skracać czas między użyciami."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/cooler/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='notice'>[X.name] wydaje się zimny.</span>")
	return TRUE

/datum/xenoartifact_trait/minor/cooler/on_init(obj/item/xenoartifact/X)
	X.cooldown = 4 SECONDS //Might revisit the value.

/datum/xenoartifact_trait/minor/cooler/activate(obj/item/xenoartifact/X)
	X.charge -= 10

//============
// Sentient, allows a ghost to control the artifact
//============
/datum/xenoartifact_trait/minor/sentient
	label_name = "Sentient"
	label_desc = "Świadomy: artefakt wydaje się żywy, wpływając na wydarzenia wokół siebie. Artefakt chce wrócić do swojego pana..."
	//Slightly increase weight - muh arpee serber
	weight = 55
	///he who lives inside
	var/mob/living/simple_animal/shade/man
	///His doorbell
	var/obj/effect/mob_spawn/sentient_artifact/S

/datum/xenoartifact_trait/minor/sentient/on_touch(obj/item/xenoartifact/X, mob/user)
	to_chat(user, "<span class='warning'>[X.name] szepcze do ciebie...</span>")
	return TRUE

/datum/xenoartifact_trait/minor/sentient/on_init(obj/item/xenoartifact/X)
	addtimer(CALLBACK(src, PROC_REF(get_canidate), X), 5 SECONDS)
	RegisterSignal(X, COMSIG_PARENT_EXAMINE, PROC_REF(handle_ghost), TRUE)

//Proc used to give access to ghosts when original player leaves
/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && man && !man?.key && (alert(M, "Czy na pewno chcesz przejąć kontrolę nad [man]?", "Przejmij kontrolę nad [man]", "Yes", "No") == "Yes"))
		man.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate(obj/item/xenoartifact/X, mob/M)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Chcesz zagrać jako złośliwa siła w [X.name]?", ROLE_SENTIENT_XENOARTIFACT, null, 8 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		setup_sentience(X, C.ckey)
		return
	S = new(get_turf(X), X)
	S.density = FALSE

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(obj/item/xenoartifact/X, ckey)
	if(!(SSzclear.get_free_z_level()))
		playsound(get_turf(X), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	man = new(get_turf(X))
	man.name = pick(GLOB.xenoa_artifact_names)
	man.real_name = "[man.name] - [X]"
	man.key = ckey
	man.status_flags |= GODMODE
	log_game("[key_name_admin(man)] took control of the sentient [X]. [X] located at [AREACOORD(X)]")
	man.forceMove(X)
	man.anchored = TRUE
	var/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/xeno_senitent_action(,X)
	man.AddSpell(P)
	//show little guy his traits
	to_chat(man, "<span class='notice'>Twoje cechy: \n</span>")
	for(var/datum/xenoartifact_trait/T in X.traits)
		to_chat(man, "<span class='notice'>[(T.desc || T.label_name)]\n</span>")
	if(man.key)
		playsound(get_turf(X), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	qdel(S)

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action //Lets sentience target goober
	name = "Activate"
	desc = "Select a target to activate your traits on."
	range = 1
	charge_max = 0 SECONDS
	clothes_req = 0
	include_user = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_spell"
	var/obj/item/xenoartifact/xeno

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/Initialize(mapload, var/obj/item/xenoartifact/Z)
	. = ..()
	xeno = Z
	range = Z.max_range+1

/obj/effect/proc_holder/spell/targeted/xeno_senitent_action/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!xeno)
		return
	for(var/atom/M in targets)
		xeno.true_target += xeno.process_target(M)
		xeno.default_activate(xeno.charge_req+10)
		charge_max = xeno.cooldown+xeno.cooldownmod

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	. = ..()
	QDEL_NULL(man) //Kill the inner person. Otherwise invisible runs around
	QDEL_NULL(S)

/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "Jesteś złośliwą świadomością, która opętała starożytny obcy artefakt."
	flavour_text = "Wróć do swojego pana..."
	use_cooldown = TRUE
	banType = ROLE_SENTIENT_XENOARTIFACT
	invisibility = 101
	var/obj/item/xenoartifact/artifact

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, var/obj/item/xenoartifact/Z)
	if(!Z)
		qdel(src)
		return FALSE
	artifact = Z
	return ..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey, name)
	var/datum/xenoartifact_trait/minor/sentient/S = artifact.get_trait(/datum/xenoartifact_trait/minor/sentient)
	S.setup_sentience(artifact, ckey)

//============
// Delicate, makes the artifact have limited uses
//============
/datum/xenoartifact_trait/minor/delicate
	desc = "Fragile"
	label_desc = "Kruchy: artefakt jest kiepsko wykonany. Ciągłe używanie go zniszczy."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/delicate/on_init(obj/item/xenoartifact/X)
	X.max_integrity = pick(200, 300, 500, 800, 1000)
	X.obj_integrity = X.max_integrity
	X.alpha = X.alpha * 0.55

/datum/xenoartifact_trait/minor/delicate/activate(obj/item/xenoartifact/X, atom/user)
	if(X.obj_integrity > 0)
		X.obj_integrity -= 100
		X.visible_message("<span class='danger'>[X.name] pęka!</span>", "<span class='danger'>[X.name] pęka!</span>")
	else
		X.visible_message("<span class='danger'>[X.name] się roztrzaskuje!</span>", "<span class='danger'>[X.name] się roztrzaskuje!</span>")
		var/obj/effect/decal/cleanable/ash/A = new(get_turf(X))
		A.color = X.material
		playsound(get_turf(X), 'sound/effects/glassbr1.ogg', 50, TRUE)
		qdel(X)

//============
// Aura, adds everything in the vicinity to the target list
//============
/datum/xenoartifact_trait/minor/aura
	desc = "Expansive"
	label_desc = "Rozległy: powierzchnia artefaktu sięga ku każdemu stworzeniu w pomieszczeniu. Nawet ku pustej przestrzeni za tobą..."
	blacklist_traits = list(/datum/xenoartifact_trait/major/timestop, /datum/xenoartifact_trait/minor/long)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/aura/on_init(obj/item/xenoartifact/X)
	X.max_range += 2

/datum/xenoartifact_trait/minor/aura/activate(obj/item/xenoartifact/X)
	for(var/atom/M in oview(min(X.max_range, 5), get_turf(X.loc)))
		if(X.true_target.len >= XENOA_MAX_TARGETS)
			return
		var/obj/item/I = M
		if(istype(M, /mob/living))
			X.true_target |= X.process_target(M)
		else if(istype(I) && !(I.anchored))
			X.true_target |= X.process_target(I)

//============
// Long, makes the artifact ranged, allows effects to select targets from afar
//============
/datum/xenoartifact_trait/minor/long
	desc = "Scoped"
	label_desc = "Lunetowy: artefakt ma niemal powiększający efekt. Pewnie dałoby się nim namierzyć kogoś z bardzo daleka."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/aura)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/long/on_init(obj/item/xenoartifact/X)
	X.max_range += 18

//============
// Wearable, allows artifact to be worn like a glove.
//============
/datum/xenoartifact_trait/minor/wearable
	desc = "Shaped"
	label_desc = "Ukształtowany: artefakt jest mały i ukształtowany. Wygląda, jakby pasował komuś na palec."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT

/datum/xenoartifact_trait/minor/wearable/on_init(obj/item/xenoartifact/X)
	X.slot_flags = ITEM_SLOT_GLOVES

/datum/xenoartifact_trait/minor/wearable/activate(obj/item/xenoartifact/X, atom/user)
	X.true_target |= list(user)

//============
// Allows artifact to act like a shield
//============
/datum/xenoartifact_trait/minor/blocking
	desc = "Shielded"
	label_desc = "Osłaniający: skład artefaktu dobrze nadaje się do blokowania ataków. Dobrze byłoby zabrać go na arenę."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/blocking/on_init(obj/item/xenoartifact/X)
	X.block_level = pick(1, 2, 3, 4)
	X.block_upgrade_walk = 1
	X.block_power = 25 * pick(0.8, 1, 1.3, 1.5)

//============
// Light, allows artifact to be thrown far
//============
/datum/xenoartifact_trait/minor/light
	desc = "Light"
	label_desc = "Lekki: artefakt jest wykonany z lekkiego materiału. Można nim rzucić dość daleko."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/heavy)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/light/on_init(obj/item/xenoartifact/X)
	X.throw_range = 8

//============
// Heavy, artifact cannot be throwwn far
//============
/datum/xenoartifact_trait/minor/heavy
	desc = "Heavy"
	label_desc = "Ciężki: artefakt jest wykonany z ciężkiego materiału. Nie da się nim rzucić zbyt daleko."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/light)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/heavy/on_init(obj/item/xenoartifact/X)
	X.throw_range = 1

//============
// Signalsend, activating the artifact sends a set signal
//============
/datum/xenoartifact_trait/minor/signalsend
	label_name = "Signaler"
	label_desc = "Sygnalizujący: artefakt wysyła sygnał przy każdej aktywacji."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/signalsend/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='info'>The [item.name] displays an outputting signal code of [X.code], and frequency [X.frequency].</span>")
		return TRUE
	return ..()

/datum/xenoartifact_trait/minor/signalsend/on_init(obj/item/xenoartifact/X)
	X.code = rand(1, 100)
	X.frequency = FREQ_SIGNALER
	X.set_frequency(X.frequency)

/datum/xenoartifact_trait/minor/signalsend/activate(obj/item/xenoartifact/X)
	var/datum/signal/signal = new(list("code" = X.code))
	X.send_signal(signal)
	log_game("[X] sent signal code [X.code] on frequency [X.frequency] at [world.time]. [X] located at [AREACOORD(X)]")

//============
// Anchor, the artifact can be anchored, anchors when activated
//============
/datum/xenoartifact_trait/minor/anchor
	desc = "Anchored"
	label_desc = "Kotwiczący: przy każdej aktywacji artefakt przywiera do podłogi z ciężarem słońca. Jakimś cudem cięższy od ciebie."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/wearable, /datum/xenoartifact_trait/minor/haunted)
	flags = BLUESPACE_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/minor/anchor/activate(obj/item/xenoartifact/X, atom/target, atom/user)
	if(isliving(X.loc))
		var/mob/living/holder = X.loc
		holder.dropItemToGround(X)
	X.visible_message("<span class='danger'>[X.name] przywiera do podłogi!</span>")
	X.setAnchored(TRUE)
	X.density = TRUE

/datum/xenoartifact_trait/minor/anchor/on_item(obj/item/xenoartifact/X, atom/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='info'>[X.anchored ? "Odkotwiczasz" : "Kotwiczysz"] [X.name] do [get_turf(X)].</span>")
		if(isliving(X.loc))
			var/mob/living/holder = X.loc
			holder.dropItemToGround(X)
		X.setAnchored(!X.anchored)
		if(!X.get_trait(/datum/xenoartifact_trait/minor/dense))
			X.density = !X.density
		return TRUE
	return ..()

//============
// Slippery, the artifact is slippery. Honk
//============
/datum/xenoartifact_trait/minor/slippery
	desc = "Slippery"
	label_desc = "Śliski: powierzchnia artefaktu jest wiecznie śliska. Popularny wśród naukowo-klaunowych grup."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	var/datum/component/slippery/slipper

/datum/xenoartifact_trait/minor/slippery/on_init(obj/item/xenoartifact/X)
	slipper = X.AddComponent(/datum/component/slippery, 80)

/datum/xenoartifact_trait/minor/slippery/Destroy(force, ...)
	QDEL_NULL(slipper)
	return ..()

//============
// haunted, the artifact can be controlled by deadchat, works well with sentient
//============
/datum/xenoartifact_trait/minor/haunted
	label_name = "Haunted"
	label_desc = "Nawiedzony: artefakt zdaje się oddziaływać z przestrzenną regresją bluespace, przez co przedmiot wydaje się nawiedzony."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/anchor, /datum/xenoartifact_trait/minor/wearable)
	flags = BLUESPACE_TRAIT
	weight = 15
	var/datum/component/deadchat_control/controller

/datum/xenoartifact_trait/minor/haunted/on_init(obj/item/xenoartifact/X)
	controller = X._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(src, PROC_REF(haunted_step), X, NORTH),
			 "down" = CALLBACK(src, PROC_REF(haunted_step), X, SOUTH),
			 "left" = CALLBACK(src, PROC_REF(haunted_step), X, WEST),
			 "right" = CALLBACK(src, PROC_REF(haunted_step), X, EAST),
			 "activate" = CALLBACK(src, PROC_REF(activate_parent), X)), 10 SECONDS))

/datum/xenoartifact_trait/minor/haunted/proc/haunted_step(obj/item/xenoartifact/ref, dir)
	if(isliving(ref.loc)) //Make any mobs drop this before it moves
		var/mob/living/M = ref.loc
		M.dropItemToGround(ref)
	playsound(get_turf(ref), 'sound/effects/magic.ogg', 50, TRUE)
	step(ref, dir)

///Used for ghost command
/datum/xenoartifact_trait/minor/haunted/proc/activate_parent(obj/item/xenoartifact/ref)
	//Get a target to style on
	ref.true_target = ref.get_target_in_proximity(min(ref.max_range+1, 5))
	if(ref.true_target.len)
		ref.check_charge(ref.true_target[1])

/datum/xenoartifact_trait/minor/haunted/on_item(obj/item/xenoartifact/X, atom/user, atom/item)
	if(istype(item, /obj/item/storage/book/bible))
		to_chat(user, "<span class='warning'>[X.name] dudni w zetknięciu z [item].</span>")
		return TRUE
	return ..()

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	QDEL_NULL(controller)
	return ..()

//============
// Delay, delays the activation. Credit to EvilDragon#4532
//============
/datum/xenoartifact_trait/minor/delay
	label_name = "Delayed"
	label_desc = "Opóźniony: skład artefaktu sprawia, że aktywacje są opóźnione."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	weight = 25

/datum/xenoartifact_trait/minor/delay/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message("<span class='danger'>[X] zatrzymuje się i zaczyna głęboko buczeć.", "[X] zatrzymuje się i zaczyna głęboko buczeć.</span>")
	playsound(get_turf(X), 'sound/effects/seedling_chargeup.ogg', 50, TRUE)
	sleep(3 SECONDS)

//============
// Blink, the artifact dissapears for a short duration after use
//============
/datum/xenoartifact_trait/minor/blink
	label_name = "Desynced"
	label_desc = "Rozsynchronizowany: artefakt regularnie wypada z istnienia i do niego wraca."
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT
	///Where your eyes don't go
	var/obj/effect/confiscate

/datum/xenoartifact_trait/minor/blink/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup)
	X.visible_message("<span class='warning'>[X] prześlizguje się między wymiarami!</span>")
	confiscate = new(get_turf(X))
	X.forceMove(confiscate)
	addtimer(CALLBACK(src, PROC_REF(comeback), X), X.charge*0.20 SECONDS)

/datum/xenoartifact_trait/minor/blink/proc/comeback(obj/item/xenoartifact/X)
	X.visible_message("<span class='warning'>[X] prześlizguje się między wymiarami!</span>")
	X.forceMove(get_turf(confiscate))
	QDEL_NULL(confiscate)

/datum/xenoartifact_trait/minor/blink/Destroy(force, ...)
	. = ..()
	if(!isnull(confiscate))
		comeback()
