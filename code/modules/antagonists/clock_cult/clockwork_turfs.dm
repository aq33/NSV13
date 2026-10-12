//=================================================
//Clockwork wall: Causes nearby tinkerer's caches to generate components.
//=================================================
#define COGWALL_DECON_TOOLS list(\
	TOOL_WELDER,\
	TOOL_SCREWDRIVER,\
	TOOL_CROWBAR,\
	TOOL_WRENCH\
)

#define COGWALL_START_DECON_MESSAGES list(\
	"Zaczynasz odspawać zewnętrzne poszycie.",\
	"Zaczynasz odkręcać właz serwisowy.",\
	"Zaczynasz podważać właz serwisowy.",\
	"Zaczynasz rozbierać ścianę."\
)

#define COGWALL_END_DECON_MESSAGES list(\
	"Odspawujesz zewnętrzne poszycie.",\
	"Wykręcasz śruby z włazu serwisowego.",\
	"Podważasz i otwierasz właz serwisowy.",\
	"Rozbierasz ścianę."\
)

#define COGWALL_START_RECON_MESSAGES list(\
	"Zaczynasz spawać z powrotem zewnętrzne poszycie.",\
	"Zaczynasz przykręcać właz serwisowy.",\
	"Zaczynasz wciskać właz serwisowy na miejsce."\
)

#define COGWALL_END_RECON_MESSAGES list(\
	"Spawasz z powrotem zewnętrzne poszycie.",\
	"Wkręcasz śruby we właz serwisowy.",\
	"Wciskasz właz serwisowy na miejsce."\
)

/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/tile/brass
	sheet_amount = 1
	girder_type = /obj/structure/destructible/clockwork/wall_gear
	baseturfs = /turf/open/floor/clockwork/reebe
	var/obj/effect/clockwork/overlay/wall/realappearence
	var/d_state = INTACT
	flags_1 = NOJAUNT_1

/turf/closed/wall/clockwork/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearence = new /obj/effect/clockwork/overlay/wall(src)
	realappearence.linked = src

/turf/closed/wall/clockwork/Destroy()
	if(realappearence)
		qdel(realappearence)
		realappearence = null
	return ..()

/turf/closed/wall/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/closed/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/closed/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/turf/closed/wall/clockwork/ratvar_act()
	return 0

/turf/closed/wall/clockwork/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
		ScrapeAway()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)
		ScrapeAway()

	for(var/obj/O in src) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)
		else
			O.forceMove(src)

/turf/closed/wall/clockwork/devastate_wall()
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/large(src)
	for(var/i in 1 to 2)
		new/obj/item/clockwork/alloy_shards/medium(src)
	for(var/i in 1 to 3)
		new/obj/item/clockwork/alloy_shards/small(src)

//No cheesing it
/turf/closed/wall/clockwork/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/turf/closed/wall/clockwork/attack_hulk(mob/user, does_attack_animation)
	if(prob(10))
		return ..()
	to_chat(user, "<span class='warning'>Lekko wgniatasz [src].</span>")
	return

//========Deconstruction Handled Here=======
/turf/closed/wall/clockwork/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return "<span class='notice'>Ściana wygląda na tyle słabo, że można <b>odspawać</b> mosiężne płyty.</span>"
		if(COG_COVER)
			return "<span class='notice'>Zewnętrzna osłona jest <i>odspawana</i>, widać wewnętrzną płytę przykręconą <b>śrubami</b>.</span>"
		if(COG_EXPOSED)
			return "<span class='notice'>Wewnętrzne poszycie jest <i>odkręcone</i>. Zewnętrzne poszycie łatwo <b>podważyć</b>.</span>"

/turf/closed/wall/clockwork/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

/turf/closed/wall/clockwork/try_decon(obj/item/I, mob/user, turf/T)
	if(I.tool_behaviour != TOOL_WELDER)
		return 0
	if(!I.tool_start_check(user, amount=0))
		return 0
	to_chat(user, "<span class='warning'>Zaczynasz rozspawywać [src].</span>")
	if(I.use_tool(src, user, 40, volume=100))
		if(!istype(src, /turf/closed/wall/clockwork) || d_state != INTACT)
			return 0
		to_chat(user, "<span class='warning'>Rozspawujesz [src]!</span>")
		dismantle_wall()
		return 1
	return

/turf/closed/wall/clockwork/mech_melee_attack(obj/mecha/M)
	return

/turf/closed/wall/clockwork/update_icon()
	. = ..()
	if(d_state == INTACT)
		realappearence.icon_state = "clockwork_wall"
		// Only re-smooth when the wall becomes smoothable again (repaired). NSV13 legacy wall smoothing calls
		// update_icon() itself, so re-queueing unconditionally made every clockwork wall smooth forever.
		if(!(smooth & SMOOTH_TRUE))
			smooth = SMOOTH_TRUE
			queue_smooth_neighbors(src)
			queue_smooth(src)
	else
		realappearence.icon_state = "clockwork_wall-[d_state]"
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	realappearence.update_icon()
	return

//=================================================
//Clockwork floor: Slowly heals toxin damage on nearby servants.
//=================================================
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon_state = "plating"
	baseturfs = /turf/open/floor/clockwork
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/dropped_brass
	var/uses_overlay = TRUE
	var/obj/effect/clockwork/overlay/floor/realappearence

/turf/open/floor/clockwork/Bless() //Who needs holy blessings when you have DADDY RATVAR? <- I did not write this, just saying
	return

/turf/open/floor/clockwork/Initialize(mapload)
	. = ..()
	if(uses_overlay)
		new /obj/effect/temp_visual/ratvar/floor(src)
		new /obj/effect/temp_visual/ratvar/beam(src)
		realappearence = new /obj/effect/clockwork/overlay/floor(src)
		realappearence.linked = src

/turf/open/floor/clockwork/Destroy()
	if(uses_overlay && realappearence)
		QDEL_NULL(realappearence)
	return ..()

/turf/open/floor/clockwork/ReplaceWithLattice()
	. = ..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/open/floor/clockwork/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/clockwork/crowbar_act(mob/living/user, obj/item/I)
	if(islist(baseturfs))
		if(type in baseturfs)
			return TRUE
	else if(baseturfs == type)
		return TRUE
	user.visible_message("<span class='notice'>[user] zaczyna powoli podważać [src]...</span>", "<span class='notice'>Zaczynasz mozolnie podważać [src]...</span>")
	if(I.use_tool(src, user, 70, volume=80))
		user.visible_message("<span class='notice'>[user] podważa [src]!</span>", "<span class='notice'>Podważasz [src]!</span>")
		make_plating()
	return TRUE

/turf/open/floor/clockwork/make_plating()
	if(!dropped_brass)
		new /obj/item/stack/tile/brass(src)
		dropped_brass = TRUE
	if(islist(baseturfs))
		if(type in baseturfs)
			return
	else if(baseturfs == type)
		return
	return ..()

/turf/open/floor/clockwork/narsie_act()
	..()
	if(istype(src, /turf/open/floor/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/turf/open/floor/clockwork/ratvar_act(force, ignore_mobs)
	return 0

/turf/open/floor/clockwork/ex_act(severity, target)
	return

/turf/open/floor/clockwork/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/turf/open/floor/clockwork/reebe
	name = "cogplate"
	desc = "Warm brass plating. You can feel it gently vibrating, as if machinery is on the other side."
	icon_state = "reebe"
	baseturfs = /turf/open/floor/clockwork/reebe
	uses_overlay = FALSE
	planetary_atmos = TRUE
	var/list/heal_people

/turf/open/floor/clockwork/reebe/Destroy()
	if(LAZYLEN(heal_people))
		STOP_PROCESSING(SSprocessing, src)
	. = ..()

/turf/open/floor/clockwork/reebe/Entered(atom/movable/A)
	. = ..()
	var/mob/living/M = A
	if(istype(M) && is_servant_of_ratvar(M))
		if(!LAZYLEN(heal_people))
			START_PROCESSING(SSprocessing, src)
		LAZYADD(heal_people, M)

/turf/open/floor/clockwork/reebe/Exited(atom/movable/A, atom/newloc)
	. = ..()
	if(A in heal_people)
		LAZYREMOVE(heal_people, A)
		if(!LAZYLEN(heal_people))
			STOP_PROCESSING(SSprocessing, src)

/turf/open/floor/clockwork/reebe/process(delta_time)
	for(var/mob/living/M in heal_people)
		M.adjustToxLoss(-1 * delta_time, forced=TRUE)

//=================================================
//Clockwork Lattice: It's a lattice for the ratvar
//=================================================

/obj/structure/lattice/clockwork
	name = "cog lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'

/obj/structure/lattice/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(is_reebe(z))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/clockwork/ratvar_act()
	if(ISODD(x+y))
		icon = 'icons/obj/smooth_structures/lattice_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

//=================================================
//Clockwork Catwalk: Ratvarians choice of catwalk
//=================================================

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
	canSmoothWith = list(/obj/structure/lattice,
	/turf/open/floor,
	/turf/closed/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(!mapload)
		new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
		new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)
	if(is_reebe(z))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	if(ISODD(x+y))
		icon = 'icons/obj/smooth_structures/catwalk_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

//=================================================
//Pinion airlocks: Clockwork doors that only let servants of Ratvar through.
//=================================================
/obj/machinery/door/airlock/clockwork
	name = "pinion airlock"
	desc = "A massive cogwheel set into two heavy slabs of brass. Contains tiny vents for allowing the flow of pressure."
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	overlays_file = 'icons/obj/doors/airlocks/clockwork/overlays.dmi'
	anim_parts = "left=-13,0;right=13,0"
	hackProof = TRUE
	aiControlDisabled = 1
	req_access = list(ACCESS_CLOCKCULT)
	use_power = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	damage_deflection = 30
	normal_integrity = 240
	air_tight = FALSE
	CanAtmosPass = ATMOS_PASS_YES
	var/construction_state = GEAR_SECURE //Pinion airlocks have custom deconstruction
	allow_repaint = FALSE

/obj/machinery/door/airlock/clockwork/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/door(loc)
	new /obj/effect/temp_visual/ratvar/beam/door(loc)

/obj/machinery/door/airlock/clockwork/Destroy()
	return ..()

/obj/machinery/door/airlock/clockwork/examine(mob/user)
	. = ..()
	var/gear_text = "Zębatka migocze i dziko się wykręca. Zgłoś to koderom."
	switch(construction_state)
		if(GEAR_SECURE)
			gear_text = "<span class='brass'>Zębatka jest mocno <b>przykręcona</b> do otaczającego ją mosiądzu.</span>"
		if(GEAR_LOOSE)
			gear_text = "<span class='alloy'>Zębatka jest <i>poluzowana</i>, ale wciąż <b>luźno połączona</b> z drzwiami!</span>"
	. += gear_text

/obj/machinery/door/airlock/clockwork/emp_act(severity)
	if(prob(80/severity))
		open()

/obj/machinery/door/airlock/clockwork/narsie_act()
	..()
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/obj/machinery/door/airlock/clockwork/ratvar_act()
	return 0

/obj/machinery/door/airlock/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(!attempt_construction(I, user))
		return ..()

/obj/machinery/door/airlock/clockwork/allowed(mob/M)
	if(is_servant_of_ratvar(M))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/clockwork/hasPower()
	return TRUE //yes we do have power

/obj/machinery/door/airlock/clockwork/obj_break(damage_flag)
	. = ..()
	if(!.) //not a clue if this will work out propely...
		return

/obj/machinery/door/airlock/clockwork/deconstruct(disassembled = TRUE)
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(disassembled)
			new/obj/item/stack/tile/brass(T, 4)
		else
			new/obj/item/clockwork/alloy_shards(T)
	qdel(src)

/obj/machinery/door/airlock/clockwork/proc/attempt_construction(obj/item/I, mob/living/user)
	if(!I || !user || !user.canUseTopic(src))
		return 0
	else if(I.tool_behaviour == TOOL_WRENCH)
		if(construction_state == GEAR_SECURE)
			user.visible_message("<span class='notice'>[user] zaczyna luzować zębatkę [src]...</span>", "<span class='notice'>Zaczynasz luzować zębatkę [src]...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_SECURE)
				return 1
			user.visible_message("<span class='notice'>[user] luzuje zębatkę [src]!</span>", "<span class='notice'>Zębatka [src] wyskakuje i luźno zwisa.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			construction_state = GEAR_LOOSE
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] zaczyna dokręcać zębatkę [src]...</span>", "<span class='notice'>Zaczynasz dokręcać zębatkę [src] na miejsce...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_LOOSE)
				return 1
			user.visible_message("<span class='notice'>[user] dokręca zębatkę [src]!</span>", "<span class='notice'>Mocno dokręcasz zębatkę [src] na miejscu.</span>")
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
			construction_state = GEAR_SECURE
		return 1
	else if(I.tool_behaviour == TOOL_CROWBAR)
		if(construction_state == GEAR_SECURE)
			to_chat(user, "<span class='warning'>Zębatka [src] jest zbyt mocno przykręcona! [I.name] nie sięga pod nią!</span>")
			return 1
		else if(construction_state == GEAR_LOOSE)
			user.visible_message("<span class='notice'>[user] zaczyna powoli zdejmować zębatkę [src]...</span>", "<span class='notice'>Powoli zaczynasz zdejmować zębatkę [src]...</span>")
			if(!I.use_tool(src, user, 75, volume=50) || construction_state != GEAR_LOOSE)
				return 1
			user.visible_message("<span class='notice'>[user] zdejmuje zębatkę [src], która się rozpada!</span>", \
			"<span class='notice'>Zdejmujesz zębatkę [src], która się rozpada!</span>")
			deconstruct(TRUE)
		return 1
	return 0

//No, you can't weld them shut.
/obj/machinery/door/airlock/clockwork/try_to_weld(obj/item/weldingtool/W, mob/user)
	return

/obj/machinery/door/airlock/clockwork/glass
	glass = TRUE
	opacity = 0

//=================================================
//Servant Blocker: Doesn't allow servants to pass
//=================================================
/obj/effect/clockwork/servant_blocker
	name = "Servant Blocker"
	desc = "You shall not pass."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "servant_blocker"
	anchored = TRUE

/obj/effect/clockwork/servant_blocker/CanPass(atom/movable/mover, turf/target)
	if(ismob(mover))
		var/mob/M = mover
		if(is_servant_of_ratvar(M))
			return FALSE
	for(var/mob/M in mover.contents)
		if(is_servant_of_ratvar(M))
			return FALSE
	return ..()

//=================================================
//Ratvar Grille: It's just a grille
//=================================================

/obj/structure/grille/ratvar
	icon_state = "ratvargrille"
	name = "cog grille"
	desc = "A strangely-shaped grille."
	broken_type = /obj/structure/grille/ratvar/broken

/obj/structure/grille/ratvar/Initialize(mapload)
	. = ..()
	if(broken)
		new /obj/effect/temp_visual/ratvar/grille/broken(get_turf(src))
	else
		new /obj/effect/temp_visual/ratvar/grille(get_turf(src))
		new /obj/effect/temp_visual/ratvar/beam/grille(get_turf(src))

/obj/structure/grille/ratvar/narsie_act()
	take_damage(rand(1, 3), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/obj/structure/grille/ratvar/ratvar_act()
	return

/obj/structure/grille/ratvar/broken
	icon_state = "brokenratvargrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_type = /obj/item/stack/tile/brass
	rods_amount = 1
	rods_broken = FALSE
	grille_type = /obj/structure/grille/ratvar
	broken_type = null

//=================================================
//Ratvar Window: A transparent window
//=================================================

/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	armor = list("melee" = 40, "bullet" = -20, "laser" = 0, "energy" = 0, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 100, "stamina" = 0)
	explosion_block = 2 //fancy AND hard to destroy. the most useful combination.
	decon_speed = 40
	glass_type = /obj/item/stack/tile/brass
	glass_amount = 1
	reinf = FALSE
	var/made_glow = FALSE

/obj/structure/window/reinforced/clockwork/spawnDebris(location)
	. = list()
	var/gearcount = fulltile ? 4 : 2
	for(var/i in 1 to gearcount)
		. += new /obj/item/clockwork/alloy_shards/medium/gear_bit(location)

/obj/structure/window/reinforced/clockwork/setDir(direct)
	if(!made_glow)
		var/obj/effect/E = new /obj/effect/temp_visual/ratvar/window/single(get_turf(src))
		E.setDir(direct)
		made_glow = TRUE
	..()

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(!QDELETED(src))
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/obj/structure/window/reinforced/clockwork/ratvar_act()
	return FALSE

/obj/structure/window/reinforced/clockwork/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window"
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 120
	level = 3
	glass_amount = 2

/obj/structure/window/reinforced/clockwork/spawnDebris(location)
	. = list()
	for(var/i in 1 to 4)
		. += new /obj/item/clockwork/alloy_shards/medium/gear_bit(location)

/obj/structure/window/reinforced/clockwork/Initialize(mapload, direct)
	made_glow = TRUE
	new /obj/effect/temp_visual/ratvar/window(get_turf(src))
	return ..()


/obj/structure/window/reinforced/clockwork/fulltile/unanchored
	anchored = FALSE
