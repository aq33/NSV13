//Thing that you stick on the floor
/obj/item/clockwork/trap_placer
	name = "trap"
	desc = "don't trust it"
	icon = 'icons/obj/clockwork_objects.dmi'
	w_class = WEIGHT_CLASS_HUGE
	var/result_path = /obj/structure/destructible/clockwork/trap

/obj/item/clockwork/trap_placer/attack_self(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	for(var/obj/structure/destructible/clockwork/trap/T in get_turf(src))
		if(istype(T, type))
			to_chat(user, "<span class='warning'>To miejsce jest zajęte!</span>")
			return
	to_chat(user, "<span class='brass'>Stawiasz [src]. Użyj <b>mechanicznej płyty</b>, żeby połączyć to z innymi pułapkami.</span>")
	var/obj/new_obj = new result_path(get_turf(src))
	new_obj.setDir(user.dir)
	qdel(src)

//Thing you stick on the wall
/obj/item/wallframe/clocktrap
	name = "Clockwork trap item"
	desc = "It's a... wait what?"
	icon = 'icons/obj/clockwork_objects.dmi'
	pixel_shift = -24
	w_class = WEIGHT_CLASS_HUGE
	result_path = /obj/structure/destructible/clockwork/trap

/obj/item/wallframe/clocktrap/examine(mob/user)
	. = ..()
	if(is_servant_of_ratvar(user))
		. += "<span class='brass'>Wygląda na to, że można to powiesić na ścianie.</span>"

//Wall item (either spawned by a wallframe or directly)
/obj/structure/destructible/clockwork/trap
	name = "Clockwork trap item"
	desc = "monkey noises"
	icon = 'icons/obj/clockwork_objects.dmi'
	density = FALSE
	layer = LOW_OBJ_LAYER
	break_message = "<span class='warning'>Misterne urządzenie się rozpada.</span>"
	var/unwrench_path = /obj/item/wallframe/clocktrap
	var/component_datum = /datum/component/clockwork_trap

/obj/structure/destructible/clockwork/trap/Initialize(mapload)
	. = ..()
	AddComponent(component_datum)

/obj/structure/destructible/clockwork/trap/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, "<span class='warning'>Zaczynasz odkręcać [src]...</span>")
	if(do_after(user, 50, target=src))
		to_chat(user, "<span class='warning'>Odczepiasz [src], usuwając wszystkie powiązane połączenia.</span>")
		new unwrench_path(get_turf(src))
		qdel(src)

//Component
/datum/component/clockwork_trap
	var/list/outputs
	var/sends_input = FALSE
	var/takes_input = FALSE

/datum/component/clockwork_trap/Initialize()
	. = ..()
	outputs = list()

	RegisterSignal(parent, COMSIG_CLOCKWORK_SIGNAL_RECEIVED, PROC_REF(trigger))
	RegisterSignal(parent, COMSIG_ATOM_EMINENCE_ACT, PROC_REF(trigger))	//The eminence can trigger traps too
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(clicked))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(OnAttackBy))

/datum/component/clockwork_trap/proc/add_input(datum/component/clockwork_trap/input)
	outputs |= input.parent

/datum/component/clockwork_trap/proc/add_output(datum/component/clockwork_trap/output)
	output.outputs |= parent

/datum/component/clockwork_trap/proc/trigger()
	SIGNAL_HANDLER

	return TRUE

/datum/component/clockwork_trap/proc/clicked(mob/user)
	SIGNAL_HANDLER

	return

/datum/component/clockwork_trap/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER

	if(is_servant_of_ratvar(user))
		if(istype(I, /obj/item/clockwork/clockwork_slab))
			var/obj/item/clockwork/clockwork_slab/slab = I
			if(slab.buffer)
				if(takes_input)
					to_chat(user, "<span class='brass'>Łączysz [slab.buffer.parent] z [parent].</span>")
					add_output(slab.buffer)
					slab.buffer = null
				else
					to_chat(user, "<span class='brass'>To urządzenie nie przyjmuje sygnału wejściowego.</span>")
			else
				if(sends_input)
					to_chat(user, "<span class='brass'>Przygotowujesz się do połączenia [parent] z innymi urządzeniami.</span>")
					slab.buffer = src
				else
					to_chat(user, "<span class='brass'>To urządzenie niczego nie wysyła.</span>")

/datum/component/clockwork_trap/proc/trigger_connected()
	for(var/obj/O in outputs)
		SEND_SIGNAL(O, COMSIG_CLOCKWORK_SIGNAL_RECEIVED)
