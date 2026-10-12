#define BS_MOUNT_UNBOLTED 1		// 4 sheets of plasteel
#define BS_MOUNT_BOLTED 2
#define BS_MOUNT_WELDED 3
#define BS_BARREL_PLACED 4		// 4 nanocarbon glass
#define BS_BARREL_BOLTED 5
#define BS_RAILS_PLACED 6		// 2 rails
#define BS_RAILS_BOLTED 7
#define BS_CAPACITORS_PLACED 8	// 2 _added
#define BS_CAPACITORS_SECURED 9
#define BS_WIRED 10				// 4 pieces of wire
#define BS_WIRES_SOLDERED 11
#define BS_ELECTRONICS_LOOSE 12	// Firing electronics
#define BS_ELECTRONICS_SECURE 13
#define BS_CASING_ADDED 14		// 2 sheets of plasteel
// Final step - insert loading tray

/obj/structure/ship_weapon/railgun_assembly
	name = "\improper NT-STC4 Ship railgun mount"
	desc = "An incomplete assembly for an NT-STC4 ship mounted railgun chamber."
	icon = 'nsv13/icons/obj/railgun.dmi'
	icon_state = "railgun_platform"
	bound_width = 128
	bound_height = 64
	pixel_y = -64
	anchored = TRUE
	density = TRUE

	var/state = BS_MOUNT_UNBOLTED
	var/capacitors_added = 0
	var/rails_added = 0

	// Material costs so we can rebalance them easily
	var/num_rails = 2
	var/num_capacitors = 4
	var/num_sheets_frame = 4
	var/num_sheets_casing = 2
	var/num_sheets_insulation = 4
	var/num_cables = 4

/obj/structure/ship_weapon/railgun_assembly/Initialize(mapload)
	..()
	if(!contents)
		contents = list()

/obj/structure/ship_weapon/railgun_assembly/examine(mob/user)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			. += "Jest <i>odkręcony</i> od podłogi i można go <b>rozciąć</b>."
		if(BS_MOUNT_BOLTED)
			. += "Jest <b>przykręcony</b> i można go <i>przyspawać</i> do podłogi."
		if(BS_MOUNT_WELDED)
			. += "Jest <b>przyspawany</b> do podłogi i ma puste gniazda na <i>izolację nanowęglową</i> wzdłuż lufy."
		if(BS_BARREL_PLACED)
			. += "<i>Śruby</i> izolacji nanowęglowej są luźne. Można ją <b>wyważyć</b>."
		if(BS_BARREL_BOLTED)
			var/rails_left = num_rails - rails_added
			. += "Izolacja nanowęglowa jest <b>przykręcona</b> do lufy, a jest miejsce na szyny: <i>[rails_left]</i>."
		if(BS_RAILS_PLACED)
			. += "Szyny przewodzące leżą luźno w ramie. Można je <b>wyważyć</b> albo <i>przykręcić</i>."
		if(BS_RAILS_BOLTED)
			var/capacitors_left = num_capacitors - capacitors_added
			. += "Szyny są <b>przykręcone</b>. Jest miejsce na kondensatory: <i>[capacitors_left]</i>."
		if(BS_CAPACITORS_PLACED)
			. += "Kondensatory są na miejscu. <i>Wkręty</i> są luźne, a kondensatory można <b>wyjąć</b> ręką."
		if(BS_CAPACITORS_SECURED)
			. += "Kondensatory są <b>przykręcone</b>, ale brakuje im <i>okablowania</i>."
		if(BS_WIRED)
			. += "Kondensatory są <b>połączone przewodami</b> z szynami i można je <i>przylutować</i>."
		if(BS_WIRES_SOLDERED)
			. += "Kondensatory są <b>przylutowane</b> do szyn, a brakuje <i>elektroniki strzelniczej</i>."
		if(BS_ELECTRONICS_LOOSE)
			. += "Elektronika strzelnicza leży luźno w ramie. Można ją <b>wyważyć</b> albo <i>przykręcić</i>."
		if(BS_ELECTRONICS_SECURE)
			. += "Elektronika strzelnicza jest <b>przykręcona</b>. Działu szynowemu brakuje <i>metalowej obudowy</i>."
		if(BS_CASING_ADDED)
			. += "Metalową obudowę można <b>odciąć</b>. Brakuje <i>tacy ładowniczej</i>."

// We just took apart a railgun, put us at the end of the construction sequence
/obj/structure/ship_weapon/railgun_assembly/proc/set_final_state()
	state = BS_CASING_ADDED

/obj/structure/ship_weapon/railgun_assembly/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/sheet/nanocarbon_glass) && state == BS_MOUNT_WELDED)
		var/obj/item/stack/sheet/nanocarbon_glass/S = W
		if(S.get_amount() < num_sheets_insulation)
			to_chat(user, "<span class='warning'>Do zaizolowania działa szynowego potrzebujesz czterech arkuszy [S]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_sheets_insulation) // Check whether they used too much while standing here...
			to_chat(user, "<span class='warning'>Do zaizolowania działa szynowego potrzebujesz czterech arkuszy [S]!</span>")
			return
		S.use(num_sheets_insulation)
		to_chat(user, "<span class='notice'>Wykładasz ramę izolującym szkłem nanowęglowym.</span>")
		state = BS_BARREL_PLACED
		return TRUE

	else if(istype(W, /obj/item/ship_weapon/parts/railgun_rail))
		if(state == BS_BARREL_BOLTED)
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.forceMove(src)
			rails_added++
			to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
			if(rails_added >= num_rails)
				state = BS_RAILS_PLACED
			return TRUE

	else if((istype(W, /obj/item/stock_parts/capacitor)) && (state == BS_RAILS_BOLTED))
		W.forceMove(src)
		capacitors_added++
		to_chat(user, "<span class='notice'>Dodajesz [W] do [src].</span>")
		if(capacitors_added >= num_capacitors)
			state = BS_CAPACITORS_PLACED
		return TRUE

	else if(istype(W, /obj/item/stack/cable_coil) && (state == BS_CAPACITORS_SECURED))
		var/obj/item/stack/cable_coil/S = W
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>Do okablowania działa szynowego potrzebujesz czterech kawałków [S]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_cables)
			to_chat(user, "<span class='warning'>Do okablowania działa szynowego potrzebujesz czterech kawałków [S]!</span>")
			return
		S.use(num_cables)
		to_chat(user, "<span class='notice'>Podłączasz zasilanie do szyn.</span>")
		state = BS_WIRED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/firing_electronics)) && (state == BS_WIRES_SOLDERED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Dodaj elektroniczny mechanizm spustowy.</span>")
		state = BS_ELECTRONICS_LOOSE
		return TRUE

	else if((istype(W, /obj/item/stack/sheet/plasteel)) && (state == BS_ELECTRONICS_SECURE))
		var/obj/item/stack/sheet/plasteel/S = W
		if(S.get_amount() < num_sheets_casing)
			to_chat(user, "<span class='warning'>Do dokończenia [src] potrzebujesz czterech arkuszy [S]!</span>")
			return
		if(!do_after(user, 2 SECONDS, target=src))
			return
		if(S.get_amount() < num_sheets_casing)
			to_chat(user, "<span class='warning'>Do dokończenia [src] potrzebujesz czterech arkuszy [S]!</span>")
			return
		S.use(num_sheets_casing)
		to_chat(user, "<span class='notice'>Dodajesz zewnętrzną obudowę do zespołu.</span>")
		state = BS_CASING_ADDED
		return TRUE

	else if((istype(W, /obj/item/ship_weapon/parts/loading_tray)) && (state == BS_CASING_ADDED))
		if(!do_after(user, 2 SECONDS, target=src))
			return
		W.forceMove(src)
		to_chat(user, "<span class='notice'>Wsuwasz tacę ładowniczą na miejsce.</span>")
		var/obj/machinery/ship_weapon/railgun/RG = new(loc)
		RG.dir = dir
		RG.setAnchored(anchored)
		RG.on_construction()
		for(var/obj/O in RG.component_parts)
			qdel(O)
			stoplag()
		transfer_fingerprints_to(RG)
		RG.component_parts = list()
		for(var/obj/O in src)
			O.moveToNullspace()
			RG.component_parts += O
			stoplag()
		qdel(src)
		return TRUE

	..()

/obj/structure/ship_weapon/railgun_assembly/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/ship_weapon/railgun_assembly/attack_hand(mob/user)
	. = ..()
	if(state == BS_CAPACITORS_PLACED)
		if(!do_after(user, 2 SECONDS, target=src))
			return
		to_chat(user, "<span class='notice'>Wyjmujesz kondensatory.</span>")
		var/obj/item/stock_parts/capacitor/C = (locate(/obj/item/stock_parts/capacitor) in src)
		while(C)
			C.forceMove(loc)
			C = (locate(/obj/item/stock_parts/capacitor) in src)
			stoplag()
		state = BS_RAILS_BOLTED
		return TRUE

/obj/structure/ship_weapon/railgun_assembly/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz [src] do podłogi.</span>")
				anchored = TRUE
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Mocujesz zaizolowaną lufę.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_RAILS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz szyny przewodzące do ramy.</span>")
				state = BS_RAILS_BOLTED
				return TRUE

		if(BS_RAILS_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz szyny od ramy.</span>")
				state = BS_RAILS_PLACED
				return TRUE

		if(BS_BARREL_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz izolację nanowęglową od lufy.</span>")
				state = BS_BARREL_PLACED
				return TRUE

		if(BS_MOUNT_BOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz [src] od podłogi.</span>")
				state = BS_MOUNT_UNBOLTED
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_MOUNT_BOLTED)
			if(anchored && tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Przyspawujesz [src] do podłogi.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

		if(BS_WIRED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Lutujesz okablowanie.</span>")
				state = BS_WIRES_SOLDERED
				return TRUE

		if(BS_CASING_ADDED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Odcinasz zewnętrzną obudowę.</span>")
				new/obj/item/stack/sheet/plasteel(loc, num_sheets_casing)
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_WIRES_SOLDERED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Wylutowujesz przewody.</span>")
				state = BS_WIRED
				return TRUE

		if(BS_MOUNT_WELDED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Odspawujesz [src] od podłogi.</span>")
				state = BS_MOUNT_BOLTED
				return TRUE

		if(BS_MOUNT_UNBOLTED)
			if(tool.use_tool(src, user, 2 SECONDS, amount=2, volume=100))
				to_chat(user, "<span class='notice'>Rozcinasz ramę.</span>")
				new/obj/item/stack/sheet/plasteel(loc, num_sheets_frame)
				qdel(src)
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/firing_electronics/F = (locate(/obj/item/ship_weapon/parts/firing_electronics) in src)
				if(F)
					F.forceMove(loc)
				to_chat(user, "<span class='notice'>Wyważasz elektronikę strzelniczą.</span>")
				state = BS_WIRES_SOLDERED
				return TRUE

		if(BS_RAILS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				var/obj/item/ship_weapon/parts/railgun_rail/R = (locate(/obj/item/ship_weapon/parts/railgun_rail) in src)
				while(R)
					R.forceMove(loc)
					R = (locate(/obj/item/ship_weapon/parts/railgun_rail) in src)
					stoplag()
				to_chat(user, "<span class='notice'>Wyważasz szyny.</span>")
				state = BS_BARREL_BOLTED
				return TRUE

		if(BS_BARREL_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				new/obj/item/stack/sheet/nanocarbon_glass(loc, num_sheets_insulation)
				to_chat(user, "<span class='notice'>Wyważasz szkło nanowęglowe.</span>")
				state = BS_MOUNT_WELDED
				return TRUE

/obj/structure/ship_weapon/railgun_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(state == BS_WIRED)
		if(tool.use_tool(src, user, 2 SECONDS, volume=100))
			new/obj/item/stack/cable_coil(loc, num_cables)
			to_chat(user, "<span class='notice'>Wycinasz przewody z ramy.</span>")
			state = BS_CAPACITORS_SECURED
			return TRUE

/obj/structure/ship_weapon/railgun_assembly/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	switch(state)
		if(BS_CAPACITORS_PLACED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz kondensatory.</span>")
				state = BS_CAPACITORS_SECURED
				return TRUE

		if(BS_ELECTRONICS_LOOSE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Przykręcasz elektronikę strzelniczą.</span>")
				state = BS_ELECTRONICS_SECURE
				return TRUE

		if(BS_ELECTRONICS_SECURE)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz elektronikę strzelniczą.</span>")
				state = BS_ELECTRONICS_LOOSE
				return TRUE

		if(BS_CAPACITORS_SECURED)
			if(tool.use_tool(src, user, 2 SECONDS, volume=100))
				to_chat(user, "<span class='notice'>Odkręcasz kondensatory.</span>")
				state = BS_CAPACITORS_PLACED
				return TRUE

#undef BS_MOUNT_UNBOLTED
#undef BS_MOUNT_BOLTED
#undef BS_MOUNT_WELDED
#undef BS_BARREL_PLACED
#undef BS_BARREL_BOLTED
#undef BS_RAILS_PLACED
#undef BS_RAILS_BOLTED
#undef BS_CAPACITORS_PLACED
#undef BS_CAPACITORS_SECURED
#undef BS_WIRED
#undef BS_WIRES_SOLDERED
#undef BS_ELECTRONICS_LOOSE
#undef BS_ELECTRONICS_SECURE
#undef BS_CASING_ADDED
