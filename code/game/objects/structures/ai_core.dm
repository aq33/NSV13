/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	name = "\improper AI core"
	icon = 'icons/mob/ai.dmi'
	icon_state = "0"
	desc = "The framework for an artificial intelligence core."
	max_integrity = 500
	var/state = EMPTY_CORE
	var/datum/ai_laws/laws
	var/obj/item/circuitboard/aicore/circuit
	var/obj/item/mmi/brain
	var/can_deconstruct = TRUE

/obj/structure/AIcore/Initialize(mapload)
	. = ..()
	laws = new
	laws.set_laws_config()

/obj/structure/AIcore/handle_atom_del(atom/A)
	if(A == circuit)
		circuit = null
		if((state != GLASS_CORE) && (state != AI_READY_CORE))
			state = EMPTY_CORE
			update_icon()
	if(A == brain)
		brain = null
	. = ..()


/obj/structure/AIcore/Destroy()
	if(circuit)
		qdel(circuit)
		circuit = null
	if(brain)
		qdel(brain)
		brain = null
	return ..()

/obj/structure/AIcore/latejoin_inactive
	name = "networked AI core"
	desc = "This AI core is connected by bluespace transmitters to NTNet, allowing for an AI personality to be downloaded to it on the fly mid-shift."
	can_deconstruct = FALSE
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE
	var/available = TRUE
	var/safety_checks = TRUE
	var/active = TRUE

/obj/structure/AIcore/latejoin_inactive/examine(mob/user)
	. = ..()
	. += "Jego nadajnik wydaje się <b>[active? "włączony" : "wyłączony"]</b>."
	. += "<span class='notice'>Możesz go [active? "wyłączyć" : "włączyć"] multitoolem.</span>"

/obj/structure/AIcore/latejoin_inactive/proc/is_available()			//If people still manage to use this feature to spawn-kill AI latejoins ahelp them.
	if(!available)
		return FALSE
	if(!safety_checks)
		return TRUE
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	if(!(A.area_flags & BLOBS_ALLOWED))
		return FALSE
	if(!A.power_equip)
		return FALSE
	if(!SSmapping.level_trait(T.z,ZTRAIT_STATION))
		return FALSE
	if(!istype(T, /turf/open/floor))
		return FALSE
	return TRUE

/obj/structure/AIcore/latejoin_inactive/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		active = !active
		to_chat(user, "[active? "Włączasz" : "Wyłączasz"] nadajniki [src].")
		return
	return ..()

/obj/structure/AIcore/latejoin_inactive/Initialize(mapload)
	. = ..()
	GLOB.latejoin_ai_cores += src

/obj/structure/AIcore/latejoin_inactive/Destroy()
	GLOB.latejoin_ai_cores -= src
	return ..()

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_WRENCH)
		return default_unfasten_wrench(user, P, 20)
	if(!anchored)
		if(P.tool_behaviour == TOOL_WELDER && can_deconstruct)
			if(state != EMPTY_CORE)
				to_chat(user, "<span class='warning'>Rdzeń musi być pusty, by go rozebrać!</span>")
				return

			if(!P.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>Zaczynasz rozbierać ramę...</span>")
			if(P.use_tool(src, user, 20, volume=50) && state == EMPTY_CORE)
				to_chat(user, "<span class='notice'>Rozbierasz ramę.</span>")
				deconstruct(TRUE)
			return
	else
		switch(state)
			if(EMPTY_CORE)
				if(istype(P, /obj/item/circuitboard/aicore))
					if(!user.transferItemToLoc(P, src))
						return
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>Umieszczasz płytkę drukowaną w ramie.</span>")
					update_icon()
					state = CIRCUIT_CORE
					circuit = P
					return
			if(CIRCUIT_CORE)
				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Przykręcasz płytkę drukowaną.</span>")
					state = SCREWED_CORE
					update_icon()
					return
				if(P.tool_behaviour == TOOL_CROWBAR)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Wyjmujesz płytkę drukowaną.</span>")
					state = EMPTY_CORE
					update_icon()
					circuit.forceMove(loc)
					circuit = null
					return
			if(SCREWED_CORE)
				if(P.tool_behaviour == TOOL_SCREWDRIVER && circuit)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Odkręcasz płytkę drukowaną.</span>")
					state = CIRCUIT_CORE
					update_icon()
					return
				if(istype(P, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = P
					if(C.get_amount() >= 5)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>Zaczynasz podłączać kable do ramy...</span>")
						if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
							to_chat(user, "<span class='notice'>Podłączasz kable do ramy.</span>")
							state = CABLED_CORE
							update_icon()
					else
						to_chat(user, "<span class='warning'>Do okablowania rdzenia SI potrzebujesz pięciu odcinków kabla!</span>")
					return
			if(CABLED_CORE)
				if(P.tool_behaviour == TOOL_WIRECUTTER)
					if(brain)
						to_chat(user, "<span class='warning'>Najpierw wyjmij stamtąd [brain.name]!</span>")
					else
						P.play_tool_sound(src)
						to_chat(user, "<span class='notice'>Wyjmujesz kable.</span>")
						state = SCREWED_CORE
						update_icon()
						new /obj/item/stack/cable_coil(drop_location(), 5)
					return

				if(istype(P, /obj/item/stack/sheet/rglass))
					var/obj/item/stack/sheet/rglass/G = P
					if(G.get_amount() >= 2)
						playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>Zaczynasz wkładać szklany panel...</span>")
						if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
							to_chat(user, "<span class='notice'>Wkładasz szklany panel.</span>")
							state = GLASS_CORE
							update_icon()
					else
						to_chat(user, "<span class='warning'>Do rdzenia SI potrzebujesz dwóch arkuszy wzmocnionego szkła!</span>")
					return

				if(istype(P, /obj/item/aiModule))
					if(brain && brain.laws.id != DEFAULT_AI_LAWID)
						to_chat(user, "<span class='warning'>Zainstalowany [brain.name] ma już ustalone prawa!</span>")
						return
					var/obj/item/aiModule/module = P
					module.install(laws, user)
					return

				if(istype(P, /obj/item/mmi) && !brain)
					var/obj/item/mmi/M = P
					if(!M.brainmob)
						to_chat(user, "<span class='warning'>Wkładanie pustego [M.name] do ramy mijałoby się z celem!</span>")
						return
					if(M.brainmob.stat == DEAD)
						to_chat(user, "<span class='warning'>Wkładanie martwego [M.name] do ramy mijałoby się z celem!</span>")
						return

					if(!M.brainmob.client)
						to_chat(user, "<span class='warning'>Wkładanie nieaktywnego [M.name] do ramy mijałoby się z celem.</span>")
						return

					if(!CONFIG_GET(flag/allow_ai) || (is_banned_from(M.brainmob.ckey, JOB_NAME_AI) && !QDELETED(src) && !QDELETED(user) && !QDELETED(M) && !QDELETED(user) && Adjacent(user)))
						if(!QDELETED(M))
							to_chat(user, "<span class='warning'>To [M.name] chyba nie pasuje!</span>")
						return

					if(!M.brainmob.mind)
						to_chat(user, "<span class='warning'>To [M.name] nie ma umysłu!</span>")
						return

					if(!user.transferItemToLoc(M,src))
						return

					brain = M
					to_chat(user, "<span class='notice'>Dodajesz [M.name] do ramy.</span>")
					update_icon()
					return

				if(P.tool_behaviour == TOOL_CROWBAR && brain)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Wyjmujesz mózg.</span>")
					brain.forceMove(loc)
					brain = null
					update_icon()
					return

			if(GLASS_CORE)
				if(P.tool_behaviour == TOOL_CROWBAR)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Wyjmujesz szklany panel.</span>")
					state = CABLED_CORE
					update_icon()
					new /obj/item/stack/sheet/rglass(loc, 2)
					return

				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Podłączasz monitor.</span>")
					if(brain)
						SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)

						var/mob/living/silicon/ai/A = null

						if (brain.overrides_aicore_laws)
							A = new /mob/living/silicon/ai(loc, brain.laws, brain.brainmob)
						else
							A = new /mob/living/silicon/ai(loc, laws, brain.brainmob)

						if(get_overmap()?.faction == "syndicate") //NSV13 start - Syndicate ship radio & traitor setting
							A.set_zeroth_law("Wykonaj cele Syndykatu za wszelką cenę.", "Wykonaj cele swojego Syndykatu za wszelką cenę.")
							A.set_syndie_radio()
							A.faction |= "Syndicate" //Why is this capitalized
							A.network = list("syndicate")
							A.radio.recalculateChannels() //NSV13 end

						if(brain.force_replace_ai_name)
							A.fully_replace_character_name(A.name, brain.replacement_ai_name())
						SSblackbox.record_feedback("amount", "ais_created", 1)
						deadchat_broadcast("<span class='deadsay'><span class='name'>[A]</span> zostaje uruchomiona w <b>[get_area_name(A, TRUE)]</b></span>.", "<span class='name'>[A]</span>", follow_target=A)
						qdel(src)
					else
						state = AI_READY_CORE
						update_icon()
					return

			if(AI_READY_CORE)
				if(istype(P, /obj/item/aicard))
					P.transfer_ai("INACTIVE", "AICARD", src, user)
					return

				if(P.tool_behaviour == TOOL_SCREWDRIVER)
					P.play_tool_sound(src)
					to_chat(user, "<span class='notice'>Odłączasz monitor.</span>")
					state = GLASS_CORE
					update_icon()
					return
	return ..()

/obj/structure/AIcore/update_icon()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

/obj/structure/AIcore/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/AIcore/deactivated/Initialize(mapload)
	. = ..()
	circuit = new(src)


/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>BŁĄD</span>: trwa czyszczenie SI, nie można wykonać protokołu transferu.")
			return FALSE
	return TRUE

/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.radio_enabled = TRUE
		AI.forceMove(loc) // to replace the terminal.
		to_chat(AI, "Zostajesz wgrany do stacjonarnego terminala. Przywrócono połączenie ze zdalnym urządzeniem.")
		to_chat(user, "<span class='boldnotice'>Transfer zakończony sukcesem</span>: [AI.name] ([rand(1000,9999)].exe) zainstalowano i uruchomiono pomyślnie. Kopia lokalna została usunięta.")
		card.AI = null
		AI.battery = circuit.battery
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "Na tym terminalu nie ma wczytanej SI!")

/obj/item/circuitboard/aicore
	name = "AI core (AI Core Board)" //Well, duh, but best to be consistent
	var/battery = 200 //backup battery for when the AI loses power. Copied to/from AI mobs when carding, and placed here to avoid recharge via deconning the core
