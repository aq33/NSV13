//Used by engineering cyborgs in place of generic circuits.
/obj/item/electroadaptive_pseudocircuit
	name = "electroadaptive pseudocircuit"
	desc = "An all-in-one circuit imprinter, designer, synthesizer, outfitter, creator, and chef. It can be used in place of any generic circuit board during construction."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris"
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron = 50, /datum/material/glass = 300)
	var/recharging = FALSE
	var/obj/item/electronics/airlock/electronics = null
	var/circuits = 5 //How many circuits the pseudocircuit has left
	var/static/recycleable_circuits = typecacheof(list(/obj/item/electronics/firelock, /obj/item/electronics/airalarm, /obj/item/electronics/firealarm, \
	/obj/item/electronics/apc, /obj/item/electronics/advanced_airlock_controller, /obj/item/electronics/airlock))//A typecache of circuits consumable for material

/obj/item/electroadaptive_pseudocircuit/Initialize(mapload)
	. = ..()
	maptext = MAPTEXT("[circuits]")
	electronics = new/obj/item/electronics/airlock(src)
	electronics.holder = src

/obj/item/electroadaptive_pseudocircuit/examine(mob/user)
	. = ..()
	if(iscyborg(user))
		. += "<span class='notice'>Ma materiał na <b>[circuits]</b> obwodów. Użyj pseudoobwodu na istniejących obwodach, by zyskać materiał.</span>\n"+\
		"<span class='notice'>Zastępuje elektronikę <b>alarmów pożarowych/powietrza</b>, <b>grodzi przeciwpożarowych</b> i <b>APC</b>.</span>\n"+\
		"<span class='notice'>Można go też użyć na APC bez ogniwa, by <b>wytworzyć ogniwo o małej pojemności</b> kosztem dużej ilości energii.</span>"

/obj/item/electroadaptive_pseudocircuit/proc/adapt_circuit(mob/living/silicon/robot/R, circuit_cost = 0)
	if(QDELETED(R) || !istype(R))
		return
	if(!R.cell)
		to_chat(R, "<span class='warning'>Do tego potrzebujesz zainstalowanego ogniwa zasilającego.</span>")
		return
	if(!R.cell.use(circuit_cost))
		to_chat(R, "<span class='warning'>Brakuje ci energii (potrzebujesz [display_energy(circuit_cost)]).</span>")
		return
	if(recharging)
		to_chat(R, "<span class='warning'>[src] musi się najpierw naładować.</span>")
		return
	if(!circuits)
		to_chat(R, "<span class='warning'>Potrzebujesz więcej materiału. Użyj [src] na istniejących prostych obwodach, by je rozłożyć.</span>")
		return
	playsound(R, 'sound/items/rped.ogg', 50, TRUE)
	recharging = TRUE
	circuits--
	maptext = MAPTEXT("[circuits]")
	icon_state = "[initial(icon_state)]_recharging"
	var/recharge_time = min(600, circuit_cost * 5)  //40W of cost for one fabrication = 20 seconds of recharge time; this is to prevent spamming
	addtimer(CALLBACK(src, PROC_REF(recharge)), recharge_time)
	return TRUE //The actual circuit magic itself is done on a per-object basis

/obj/item/electroadaptive_pseudocircuit/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!is_type_in_typecache(target, recycleable_circuits))
		return
	circuits++
	maptext = MAPTEXT("[circuits]")
	user.visible_message("<span class='notice'>Użytkownik rozkłada [target] za pomocą [src].</span>", \
	"<span class='notice'>Przetwarzasz [target] w [src]. Ma teraz materiał na <b>[circuits]</b> obwodów.</span>")
	playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(target)

/obj/item/electroadaptive_pseudocircuit/proc/recharge()
	playsound(src, 'sound/machines/chime.ogg', 25, TRUE)
	recharging = FALSE
	icon_state = initial(icon_state)

/obj/item/electroadaptive_pseudocircuit/attack_self(mob/user)
	. = ..()
	electronics.ui_interact(user)

/obj/item/electroadaptive_pseudocircuit/Destroy()
	QDEL_NULL(electronics)
	. = ..()
