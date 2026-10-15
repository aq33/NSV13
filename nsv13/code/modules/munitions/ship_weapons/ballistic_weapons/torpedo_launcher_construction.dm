#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_PLACED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_WIRED 6				// 2 pieces of wire
#define BS_ELECTRONICS_LOOSE 7	// Firing electronics
#define BS_ELECTRONICS_SECURE 8
#define BS_DOOR_PLACED 9		// 2 nanocarbon glass
#define BS_DOOR_BOLTED 10
// Then screw it shut

/obj/structure/ship_weapon/torpedo_launcher_assembly
	name = "\improper M4-B Torpedo tube mount"
	desc = "An incomplete assembly for an M4-B ship mounted torpedo launcher."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "torpedo_launcher_platform"
	bound_height = 32
	bound_width = 96
	pixel_y = -72
	pixel_x = -32
	anchored = TRUE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED

	// Material costs so we can rebalance them easily
	var/num_cables = 2
	var/num_sheets_door = 2
	var/num_sheets_barrel = 4
	var/num_sheets_frame = 4
	var/output_path = /obj/machinery/ship_weapon/torpedo_launcher

/obj/structure/ship_weapon/torpedo_launcher_assembly/setDir()
	. = ..()
	switch(dir)
		if(NORTH)
			output_path = text2path("[initial(output_path)]/north")
			pixel_x = -16
			pixel_y = -32
			bound_height = 96
			bound_width = 32
			bound_x = 0
			bound_y = 0
		if(SOUTH)
			output_path = text2path("[initial(output_path)]/south")
			pixel_x = -16
			pixel_y = -64
			bound_height = 96
			bound_width = 32
			bound_x = 0
			bound_y = -64
		if(EAST)
			output_path = text2path("[initial(output_path)]/east")
			pixel_y = -72
			pixel_x = -32
			bound_height = 32
			bound_width = 96
			bound_x = 0
			bound_y = 0
		if(WEST)
			output_path = text2path("[initial(output_path)]/west")
			pixel_x = -64
			pixel_y = -72
			bound_height = 32
			bound_width = 96
			bound_x = -64
			bound_y = 0

/obj/structure/ship_weapon/torpedo_launcher_assembly/examine(mob/user)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			. += "Jest <i>odkręcony</i> od podłogi i można go <b>rozciąć</b>."
		if(BS_MOUNT_BOLTED)
			. += "Jest <b>przykręcony</b> i można go <i>przyspawać</i> do podłogi."
		if(BS_MOUNT_WELDED)
			. += "Jest <b>przyspawany</b> do podłogi i gotowy na <i>nanowęglową</i> lufę."
		if(BS_BARREL_PLACED)
			. += "<i>Śruby</i> lufy są luźne. Można ją <b>wyważyć</b>."
		if(BS_BARREL_BOLTED)
			. += "Lufa jest <b>przykręcona</b>. Zespół jest <i>nieokablowany</i>.</i>."
		if(BS_WIRED)
			. += "Zespół jest <b>okablowany</b>, ale nie ma <i>elektroniki strzelniczej</i>."
		if(BS_ELECTRONICS_LOOSE)
			. += "Elektronika strzelnicza leży luźno w ramie. Można ją <b>wyważyć</b> albo <i>przykręcić</i>."
		if(BS_ELECTRONICS_SECURE)
			. += "Elektronika strzelnicza jest <b>przykręcona</b>. Wyrzutni brakuje <i>nanowęglowych drzwiczek</i>."
		if(BS_DOOR_PLACED)
			. += "Nanowęglowe drzwiczki są luźne. Można je <b>wyważyć</b> albo <i>przykręcić</i>."
		if(BS_DOOR_BOLTED)
			. += "Drzwiczki są <b>przykręcone</b>, a właz serwisowy jest <i>odkręcony</i>."

// We just took apart a torp tube, put us at the end of the construction sequence
/obj/structure/ship_weapon/torpedo_launcher_assembly/proc/set_final_state()
	state = BS_DOOR_BOLTED

/obj/structure/ship_weapon/torpedo_launcher_assembly/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/stack/sheet/nanocarbon_glass))
		if(state == BS_MOUNT_WELDED)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < num_sheets_barrel)
				to_chat(user, "<span class='warning'>Do budowy wyrzutni potrzebujesz czterech arkuszy [S]!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < num_sheets_barrel) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>Do budowy wyrzutni potrzebujesz czterech arkuszy [S]!</span>")
				return
			S.use(num_sheets_barrel)
			to_chat(user, "<span class='notice'>Formujesz nanowęglową wyrzutnię torped.</span>")
			state = BS_BARREL_PLACED
			return TRUE

		else if(state == BS_ELECTRONICS_SECURE)
			var/obj/item/stack/sheet/nanocarbon_glass/S = W
			if(S.get_amount() < num_sheets_door)
				to_chat(user, "<span class='warning'>Do budowy drzwiczek potrzebujesz dwóch arkuszy [S]!</span>")
				return
			if(!do_after(user, 2 SECONDS, target=src))
				return
			if(S.get_amount() < num_sheets_door) // Check whether they used too much while standing here...
				to_chat(user, "<span class='warning'>Do budowy drzwiczek potrzebujesz dwóch arkuszy [S]!</span>")
				return
			S.use(num_sheets_door)
			to_chat(user, "<span class='notice'>Dodajesz drzwiczki do [src].</span>")
			state = BS_DOOR_PLACED
			return TRUE

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_BARREL_BOLTED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>Do okablowania wyrzutni potrzebujesz dwóch kawałków [S]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>Do okablowania wyrzutni potrzebujesz dwóch kawałków [S]!</span>")
			return
		S.use(num_cables)
		to_chat(user, "<span class='notice'>Okablowujesz wyrzutnię torped.</span>")
		state = BS_WIRED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/firing_electronics)) && (state == BS_WIRED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Dodaj elektroniczny mechanizm spustowy.</span>")
		state = BS_ELECTRONICS_LOOSE
		return TRUE

	return ..()

/obj/structure/ship_weapon/torpedo_launcher_assembly/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/ship_weapon/torpedo_launcher_assembly/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Przykręcasz elektronikę strzelniczą.</span>")
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_ELECTRONICS_SECURE)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Odkręcasz elektronikę strzelniczą.</span>")
				state = BS_ELECTRONICS_LOOSE
				return TRUE

		if(BS_DOOR_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Kończysz wyrzutnię torped.</span>")
				var/obj/machinery/ship_weapon/TL = new output_path(loc)
				TL.dir = dir
				TL.setAnchored(anchored)
				TL.on_construction()
				for(var/obj/O in TL.component_parts)
					qdel(O)
					stoplag()
				transfer_fingerprints_to(TL)
				TL.component_parts = list()
				for(var/obj/O in src)
					O.moveToNullspace()
					TL.component_parts += O
					stoplag()
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/wrench_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Przykręcasz [src] do podłogi.</span>")
				anchored = TRUE
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Mocujesz lufę.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_BARREL_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Odkręcasz lufę.</span>")
				state = BS_BARREL_PLACED
				return TRUE

		if(BS_MOUNT_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Odkręcasz [src] od podłogi.</span>")
				state = BS_MOUNT_UNBOLTED
				return TRUE

		if(BS_DOOR_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Przykręcasz drzwiczki do ramy.</span>")
				state = BS_DOOR_BOLTED
				return TRUE

		if(BS_DOOR_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Odkręcasz drzwiczki od ramy.</span>")
				state = BS_DOOR_PLACED
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/welder_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_BOLTED)
			if(anchored && tool.use_tool(src, user, 2 SECONDS, 2, 100))
				to_chat(user, "<span class='notice'>Przyspawujesz [src] do podłogi.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

		if(BS_MOUNT_WELDED)
			if(tool.use_tool(src, user, 2 SECONDS, 2, 100))
				to_chat(user, "<span class='notice'>Odspawujesz [src] od podłogi.</span>")
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, 2, 100))
				to_chat(user, "<span class='notice'>Rozcinasz ramę.</span>")
				new/obj/item/stack/sheet/plasteel(loc, num_sheets_frame)
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/crowbar_act(mob/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_DOOR_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Wyważasz drzwiczki z [src].</span>")
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_door)
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in contents)
				F.forceMove(loc)
				to_chat(user, "<span class='notice'>Wyważasz elektronikę strzelniczą z [src].</span>")
				state = BS_WIRED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
				to_chat(user, "<span class='notice'>Wyważasz nanowęglową lufę z [src].</span>")
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_barrel)
				state = BS_MOUNT_WELDED
				return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == BS_WIRED)
		if(tool.use_tool(src, user, 2 SECONDS, 0, 100))
			new /obj/item/stack/cable_coil(loc, num_cables)
			to_chat(user, "<span class='notice'>Wycinasz przewody z ramy.</span>")
			state = BS_BARREL_BOLTED
			return TRUE

/obj/structure/ship_weapon/torpedo_launcher_assembly/cargo
	name = "\improper M4-C Cargo Torpedo tube mount"
	desc = "An incomplete assembly for an M4-C ship mounted cargo torpedo launcher."
	color = "#f5d1b0"

	output_path = /obj/machinery/ship_weapon/torpedo_launcher/cargo

#undef BS_MOUNT_UNBOLTED
#undef BS_MOUNT_BOLTED
#undef BS_MOUNT_WELDED
#undef BS_BARREL_PLACED
#undef BS_BARREL_BOLTED
#undef BS_WIRED
#undef BS_ELECTRONICS_LOOSE
#undef BS_ELECTRONICS_SECURE
#undef BS_DOOR_PLACED
#undef BS_DOOR_BOLTED
