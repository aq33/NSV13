/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = TRUE

	var/d_state = INTACT
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	explosion_block = 2
	rad_insulation = RAD_HEAVY_INSULATION
	FASTDMM_PROP(\
		pipe_astar_cost = 50 \
	)

/turf/closed/wall/r_wall/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return "<span class='notice'>Zewnętrzna <b>krata</b> jest nienaruszona.</span>"
		if(SUPPORT_LINES)
			return "<span class='notice'>Zewnętrzna <i>krata</i> została przecięta, a linie wsporcze są <b>przykręcone</b> do zewnętrznej osłony.</span>"
		if(COVER)
			return "<span class='notice'>Linie wsporcze zostały <i>odkręcone</i>, a metalowa osłona jest mocno <b>przyspawana</b> na miejscu.</span>"
		if(CUT_COVER)
			return "<span class='notice'>Metalowa osłona została <i>przecięta</i> i jest <b>luźno połączona</b> z dźwigarem.</span>"
		if(ANCHOR_BOLTS)
			return "<span class='notice'>Zewnętrzna osłona została <i>wyważona</i>, a śruby kotwiące pręty wsporcze są <b>dokręcone</b>.</span>"
		if(SUPPORT_RODS)
			return "<span class='notice'>Śruby kotwiące pręty wsporcze zostały <i>poluzowane</i>, ale nadal są mocno <b>przyspawane</b> do dźwigara.</span>"
		if(SHEATH)
			return "<span class='notice'>Pręty wsporcze zostały <i>przecięte</i>, a zewnętrzna powłoka jest <b>luźno połączona</b> z dźwigarem.</span>"

/turf/closed/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/iron(src, 2)

/turf/closed/wall/r_wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!M.environment_smash)
		return
	if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		to_chat(M, "<span class='warning'>Ta ściana jest o wiele za mocna, byś mógł ją zniszczyć.</span>")

/turf/closed/wall/r_wall/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

/turf/closed/wall/r_wall/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = SUPPORT_LINES
				update_icon()
				balloon_alert(user, "Przecinasz zewnętrzną kratę.")
				return TRUE

		if(SUPPORT_LINES)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "Zaczynasz odkręcać linie wsporcze...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_LINES)
						return TRUE
					d_state = COVER
					update_icon()
					balloon_alert(user, "Odkręcasz linie wsporcze.")
				return TRUE

			else if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = INTACT
				update_icon()
				balloon_alert(user, "Naprawiasz zewnętrzną kratę.")
				return TRUE

		if(COVER)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "Zaczynasz przecinać metalową osłonę...")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					balloon_alert(user, "Zdejmujesz metalową osłonę.")
				return TRUE

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "Zaczynasz przykręcać linie wsporcze...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = SUPPORT_LINES
					update_icon()
					balloon_alert(user, "Przykręcasz linie wsporcze.")
				return TRUE

		if(CUT_COVER)
			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "Z trudem wyważasz osłonę...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					balloon_alert(user, "Wyważasz osłonę.")
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "Zaczynasz przyspawywać metalową osłonę z powrotem do ramy...")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = COVER
					update_icon()
					balloon_alert(user, "Przyspawujesz metalową osłonę do ramy.")
				return TRUE

		if(ANCHOR_BOLTS)
			if(W.tool_behaviour == TOOL_WRENCH)
				balloon_alert(user, "Zaczynasz luzować śruby kotwiące pręty wsporcze do ramy...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					balloon_alert(user, "Wykręcasz śruby.")
				return TRUE

			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "Zaczynasz wciskać osłonę z powrotem na miejsce...")
				if(W.use_tool(src, user, 20, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					balloon_alert(user, "Wciskasz metalową osłonę z powrotem na miejsce.")
				return TRUE

		if(SUPPORT_RODS)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "Zaczynasz przecinać pręty wsporcze...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = SHEATH
					update_icon()
					balloon_alert(user, "Przecinasz pręty wsporcze.")
				return TRUE

			if(W.tool_behaviour == TOOL_WRENCH)
				balloon_alert(user, "Zaczynasz dokręcać śruby mocujące pręty wsporcze...")
				W.play_tool_sound(src, 100)
				if(W.use_tool(src, user, 40))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					balloon_alert(user, "Dokręcasz śruby.")
				return TRUE

		if(SHEATH)
			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "Zaczynasz wyważać zewnętrzną powłokę...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					balloon_alert(user, "Wyważasz zewnętrzną powłokę.")
					dismantle_wall()
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "Zaczynasz zespawywać pręty wsporcze z powrotem...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					balloon_alert(user, "Zespawujesz pręty wsporcze z powrotem.")
				return TRUE
	return FALSE

/turf/closed/wall/r_wall/update_icon()
	. = ..()
	if(!legacy_smooth) //NSV13 - legacy smooth support
		if(d_state != INTACT)
			smooth = SMOOTH_FALSE
			clear_smooth_overlays()
		else
			smooth = SMOOTH_TRUE
			queue_smooth_neighbors(src)
			queue_smooth(src)

/turf/closed/wall/r_wall/update_icon_state()
	if(d_state != INTACT)
		icon_state = "r_wall-[d_state]"
	else
		icon_state = "r_wall"
	return ..()

/turf/closed/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/r_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/closed/wall/r_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/closed/wall/r_wall/rust_heretic_act()
	if(prob(50))
		return
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return TRUE
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	return ..()

/turf/closed/wall/r_wall/syndicate
	name = "hull"
	desc = "The armored hull of an ominous looking ship."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "map-shuttle"
	color = null // NSV13 - Fixes missing atom_color runtimes
	explosion_block = 20
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	legacy_smooth = FALSE //NSV13 - this one is normal
	canSmoothWith = list(/turf/closed/wall/r_wall/syndicate, /turf/closed/wall/mineral/plastitanium, /obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock, /obj/structure/window/plastitanium, /obj/structure/shuttle/engine, /obj/structure/falsewall/plastitanium)

/turf/closed/wall/r_wall/syndicate/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/turf/closed/wall/r_wall/syndicate/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "map-shuttle_nd"

/turf/closed/wall/r_wall/syndicate/nosmooth
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE

/turf/closed/wall/r_wall/syndicate/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)


