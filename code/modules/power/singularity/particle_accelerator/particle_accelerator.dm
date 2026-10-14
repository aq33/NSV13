/*Composed of 7 parts :

 3 Particle Emitters
 1 Power Box
 1 Fuel Chamber
 1 End Cap
 1 Control computer

 Setup map

   |EC|
 CC|FC|
   |PB|
 PE|PE|PE

*/
#define PA_CONSTRUCTION_UNSECURED  0
#define PA_CONSTRUCTION_UNWIRED    1
#define PA_CONSTRUCTION_PANEL_OPEN 2
#define PA_CONSTRUCTION_COMPLETE   3

/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 80, "stamina" = 0, "bleed" = 0)

	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference = null
	var/powered = 0
	var/strength = null

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += "Wygląda na to, że nie jest przymocowany do podłogi."
		if(PA_CONSTRUCTION_UNWIRED)
			. += "Brakuje mu kilku kabli."
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += "Panel jest otwarty."

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = 0
		master = null
	return ..()

/obj/structure/particle_accelerator/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)


/obj/structure/particle_accelerator/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(W.tool_behaviour == TOOL_WRENCH && !isinspace())
				W.play_tool_sound(src, 75)
				anchored = TRUE
				user.visible_message("[user.name] mocuje [name] do podłogi.", \
					"Dokręcasz zewnętrzne śruby.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
		if(PA_CONSTRUCTION_UNWIRED)
			if(W.tool_behaviour == TOOL_WRENCH)
				W.play_tool_sound(src, 75)
				anchored = FALSE
				user.visible_message("[user.name] odczepia [name] od podłogi.", \
					"Odkręcasz zewnętrzne śruby.")
				construction_state = PA_CONSTRUCTION_UNSECURED
				did_something = TRUE
			else if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = W
				if(CC.use(1))
					user.visible_message("[user.name] podłącza przewody do [name].", \
						"Podłączasz trochę przewodów.")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(W.tool_behaviour == TOOL_WIRECUTTER)//TODO:Shock user if its on?
				user.visible_message("[user.name] wyjmuje trochę przewodów z [name].", \
					"Wyjmujesz trochę przewodów.")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] zamyka panel dostępu [name].", \
					"Zamykasz panel dostępu.")
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("[user.name] otwiera panel dostępu [name].", \
					"Otwierasz panel dostępu.")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		user.changeNext_move(CLICK_CD_MELEE)
		update_state()
		update_icon()
		return

	return ..()


/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron (loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move()
	. = ..()
	if(master?.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_ENGINES)


/obj/structure/particle_accelerator/update_icon()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED,PA_CONSTRUCTION_UNWIRED)
			icon_state="[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state="[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O.dir == dir)
		master = O
		return 1
	return 0

///////////
// PARTS //
///////////


/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where Alpha particles are generated from \[REDACTED\]."
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus the Alpha particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"
