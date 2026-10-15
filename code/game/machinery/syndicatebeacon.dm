////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon0"

	anchored = FALSE
	density = TRUE
	layer = BELOW_MOB_LAYER //so people can't hide it and it's REALLY OBVIOUS
	verb_say = "stwierdza"
	var/cooldown = 0

	var/active = 0
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user)
			to_chat(user, "<span class='notice'>Podłączony przewód nie ma wystarczającego natężenia.</span>")
		return
	for(var/datum/component/singularity/singulo as() in GLOB.singularities)
		var/atom/singulo_atom = singulo.parent
		if(singulo_atom.get_virtual_z_level() == get_virtual_z_level())
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	if(user)
		to_chat(user, "<span class='notice'>Aktywujesz nadajnik.</span>")


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/datum/component/singularity/singulo as() in GLOB.singularities)
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	if(user)
		to_chat(user, "<span class='notice'>Dezaktywujesz nadajnik.</span>")


/obj/machinery/power/singularity_beacon/attack_ai(mob/user)
	return


/obj/machinery/power/singularity_beacon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, "<span class='warning'>Najpierw musisz przykręcić [src] do podłogi!</span>")

/obj/machinery/power/singularity_beacon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(active)
			to_chat(user, "<span class='warning'>Najpierw musisz dezaktywować [src]!</span>")
			return

		if(anchored)
			setAnchored(FALSE)
			to_chat(user, "<span class='notice'>Odkręcasz [src] od podłogi i odłączasz go od kabla.</span>")
			disconnect_from_network()
			return
		else
			if(!connect_to_network())
				to_chat(user, "<span class='warning'>[src] musi zostać umieszczony nad odsłoniętym, zasilanym węzłem kabla!</span>")
				return
			setAnchored(TRUE)
			to_chat(user, "<span class='notice'>Przykręcasz [src] do podłogi i podłączasz go do kabla.</span>")
			return
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		user.visible_message( \
			"[user] przez chwilę grzebie przy [src].", \
			"<span class='notice'>Śrubokręt nie pasuje do śrub [src]! Spróbuj klucza.</span>")
	else
		return ..()

/obj/machinery/power/singularity_beacon/Destroy()
	if(active)
		Deactivate()
	return ..()

//stealth direct power usage
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return

	if(surplus() >= 1500)
		add_load(1500)
		if(cooldown <= world.time)
			cooldown = world.time + 80
			for(var/datum/component/singularity/singulo_component as() in GLOB.singularities)
				var/atom/singulo = singulo_component.parent
				if(singulo.get_virtual_z_level() == get_virtual_z_level())
					say("[singulo] jest teraz [get_dist(src,singulo)] standardowych jednostek stąd, w kierunku: [dir2text(get_dir(src,singulo))]")
	else
		Deactivate()
		say("Wykryto za mało ładunku - wyłączanie")


/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"

// SINGULO BEACON SPAWNER
/obj/item/sbeacondrop
	name = "suspicious beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "A label on it reads: <i>Warning: Activating this device will send a special beacon to your location</i>."
	w_class = WEIGHT_CLASS_SMALL
	var/droptype = /obj/machinery/power/singularity_beacon/syndicate


/obj/item/sbeacondrop/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Namierzono.</span>")
		new droptype( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/sbeacondrop/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb

/obj/item/sbeacondrop/powersink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/item/powersink

/obj/item/sbeacondrop/clownbomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a silly explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb/badmin/clown

/obj/item/sbeacondrop/constructshell
	desc = "A label on it reads: <i>Warning: Activating this device will send a Nar'sian construct shell to your location</i>."
	droptype = /obj/structure/constructshell

/obj/item/sbeacondrop/semiautoturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a semi-auto turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/pod

/obj/item/sbeacondrop/heavylaserturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a heavy laser turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/energy/heavy

/obj/item/sbeacondrop/penetratorturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a penetrator turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/shuttle
