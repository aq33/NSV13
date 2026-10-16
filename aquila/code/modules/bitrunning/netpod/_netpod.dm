#define BASE_DISCONNECT_DAMAGE 40
#define SCANNING_TOGGLE_COOLDOWN 5

/obj/machinery/netpod
	name = "netpod"
	desc = "Łącze z siecią. Ma zestaw kabli, którymi podłączysz się do domeny wirtualnej."
	base_icon_state = "netpod"
	circuit = /obj/item/circuitboard/machine/netpod
	icon = 'aquila/icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod"
	max_integrity = 300
	state_open = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 500

	/// Whether we have an ongoing connection
	var/connected = FALSE
	/// A player selected outfit by clicking the netpod
	var/datum/outfit/netsuit = /datum/outfit/job/bitrunner
	/// Holds this to see if it needs to generate a new one
	var/datum/weakref/avatar_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// The amount of brain damage done from force disconnects
	var/disconnect_damage = BASE_DISCONNECT_DAMAGE
	/// Static list of outfits to select from
	var/list/cached_outfits = list()
	/// Whether bit avatars become visually similar to their bitrunner on first creation
	var/copy_body = FALSE
	/// The next time copy_body can be toggled
	var/scanning_can_toggle = 0


/obj/machinery/netpod/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/netpod/LateInitialize()
	. = ..()
	find_server()
	RegisterSignal(src, COMSIG_MACHINERY_BROKEN, PROC_REF(on_broken))
	update_appearance()


/obj/machinery/netpod/Destroy()
	if(occupant)
		sever_connection()
	cached_outfits.Cut()
	return ..()


/obj/machinery/netpod/examine(mob/user)
	. = ..()

	. += span_notice("Panel serwisowy można [panel_open ? "zamknąć" : "otworzyć"] <b>śrubokrętem</b>.")
	if(isnull(occupant))
		if(panel_open)
			. += span_notice("Można go rozebrać <b>łomem</b>.")
		else
			. += span_notice("Klapę można [state_open ? "zamknąć" : "otworzyć"] <b>łomem</b>.")

	if(isnull(server_ref?.resolve()))
		. += span_infoplain("Nie jest do niczego podłączony.")
		. += span_infoplain("Netpody muszą stać najwyżej 4 pola od serwera kwantowego.")
		return

	if(!isobserver(user))
		. += span_infoplain("Przeciągnij się do kapsuły, żeby nawiązać połączenie.")
		. += span_infoplain("Ma ograniczone funkcje reanimacyjne: pobyt w kapsule leczy część obrażeń.")
		. += span_infoplain("System bezpieczeństwa ostrzeże osobę w środku, gdy ktoś będzie przy kapsule majstrował.")
		if(copy_body)
			. += span_infoplain("Skanowanie jest włączone: nowy awatar będzie wyglądał jak osoba w kapsule.")
		. += span_infoplain("Alt+klik, żeby [copy_body ? "wyłączyć" : "włączyć"] skanowanie wyglądu.")

	if(isnull(occupant))
		. += span_infoplain("Jest pusty.")
		return

	. += span_infoplain("W środku jest [occupant].")

	if(isobserver(user))
		. += span_notice("Jako duch możesz kliknąć netpod, żeby przenieść się do awatara.")
		return

	. += span_notice("Można go podważyć łomem, ale zabezpieczenia ostrzegą osobę w środku.")


/obj/machinery/netpod/update_icon_state()
	if(!is_operational)
		icon_state = base_icon_state
		return ..()

	if(state_open)
		icon_state = base_icon_state + "_open_active"
		return ..()

	if(panel_open)
		icon_state = base_icon_state + "_panel"
		return ..()

	icon_state = base_icon_state + "_closed"
	if(occupant)
		icon_state += "_active"

	return ..()


/obj/machinery/netpod/MouseDrop_T(mob/living/target, mob/living/user)
	if(!istype(target) || !istype(user) || !iscarbon(target))
		return
	if(user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !isturf(user.loc) || target.buckled)
		return
	if(!is_operational || !state_open || occupant || panel_open)
		return
	if(target != user && !ishuman(user))
		return
	if(target != user)
		user.visible_message(span_warning("[user] zaczyna wkładać [target] do [src]."), span_notice("Zaczynasz wkładać [target] do [src]."))
		if(!do_after(user, 3 SECONDS, target = target) || occupant || !state_open)
			return

	close_machine(target)


/obj/machinery/netpod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!state_open && user == occupant)
		container_resist(user)
		return TRUE
	ui_interact(user)
	return TRUE


/obj/machinery/netpod/attack_ghost(mob/dead/observer/our_observer)
	var/atom/our_target = avatar_ref?.resolve()
	if(isnull(our_target))
		return ..()
	our_observer.ManualFollow(our_target)
	return TRUE


/// When the server is upgraded, drops brain damage a little
/obj/machinery/netpod/proc/on_server_upgraded(obj/machinery/quantum_server/source)
	SIGNAL_HANDLER

	disconnect_damage = BASE_DISCONNECT_DAMAGE * (1 - source.servo_bonus)

/obj/machinery/netpod/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(world.time < scanning_can_toggle)
		return
	copy_body = !copy_body
	scanning_can_toggle = world.time + SCANNING_TOGGLE_COOLDOWN
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert_to_viewers("skanowanie [copy_body ? "włączone" : "wyłączone"]")

#undef BASE_DISCONNECT_DAMAGE
#undef SCANNING_TOGGLE_COOLDOWN
