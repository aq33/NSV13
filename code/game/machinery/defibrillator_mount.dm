//Holds defibs and recharges them from the powernet
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Holds and recharges defibrillators. You can grab the paddles if one is mounted."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	power_channel = AREA_USAGE_EQUIP
	req_one_access = list(ACCESS_MEDICAL, ACCESS_HEADS, ACCESS_SECURITY) //used to control clamps
	processing_flags = NONE
	layer = ABOVE_WINDOW_LAYER
	var/obj/item/defibrillator/defib //this mount's defibrillator
	var/clamps_locked = FALSE //if true, and a defib is loaded, it can't be removed without unlocking the clamps

/obj/machinery/defibrillator_mount/loaded/Initialize(mapload) //loaded subtype for mapping use
	. = ..()
	defib = new/obj/item/defibrillator/loaded(src)
	update_icon()

/obj/machinery/defibrillator_mount/Destroy()
	if(defib)
		QDEL_NULL(defib)
		end_processing()
	. = ..()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += "<span class='notice'>Podłączony jest defibrylator. Alt-kliknij, by go wyjąć.</span>"
		if(GLOB.security_level >= SEC_LEVEL_RED)
			. += "<span class='notice'>Z powodu sytuacji zagrożenia zaciski blokujące można przełączyć dowolną kartą ID.</span>"
		else
			. += "<span class='notice'>Zaciski blokujące można [clamps_locked ? "zwolnić" : "zablokować"], przeciągając kartę ID z dostępem.</span>"

/obj/machinery/defibrillator_mount/process()
	if(defib?.cell && defib.cell.charge < defib.cell.maxcharge && is_operational)
		use_power(200)
		defib.cell.give(180) //90% efficiency, a bit worse than the cell charger's 100%
		update_icon()

/obj/machinery/defibrillator_mount/update_icon()
	cut_overlays()
	if(defib)
		add_overlay("defib")
		if(defib.powered)
			add_overlay(defib.safety ? "online" : "emagged")
			var/ratio = defib.cell.charge / defib.cell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			add_overlay("charge[ratio]")
		if(clamps_locked)
			add_overlay("clamps")

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/user)
	if(!defib)
		to_chat(user, "<span class='warning'>Nie ma załadowanego defibrylatora!</span>")
		return
	if(defib.paddles.loc != defib)
		to_chat(user, "<span class='warning'>[defib.paddles.loc == user ? "You are already" : "Someone else is"] holding [defib]'s paddles!</span>")
		return
	user.put_in_hands(defib.paddles)

/obj/machinery/defibrillator_mount/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/defibrillator))
		if(defib)
			to_chat(user, "<span class='warning'>W [src] już jest defibrylator!</span>")
			return
		if(HAS_TRAIT(I, TRAIT_NODROP) || !user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] przykleił się do twojej ręki!</span>")
			return
		user.visible_message("<span class='notice'>[user] podłącza [I] do [src]!</span>", \
		"<span class='notice'>Wciskasz [I] w uchwyt, a on zatrzaskuje się na miejscu.</span>")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		defib = I
		begin_processing()
		update_icon()
		return
	else if(defib && I == defib.paddles)
		defib.paddles.snap_back()
		return
	var/obj/item/card/id = I.GetID()
	if(id)
		if(check_access(id) || GLOB.security_level >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				to_chat(user, "<span class='warning'>Nie możesz zablokować zacisków na defibrylatorze, którego nie ma.</span>")
				return
			clamps_locked = !clamps_locked
			to_chat(user, "<span class='notice'>Zaciski [clamps_locked ? "zablokowane" : "zwolnione"].</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>Niewystarczający dostęp.</span>")
		return
	..()

/obj/machinery/defibrillator_mount/multitool_act(mob/living/user, obj/item/multitool)
	if(!defib)
		to_chat(user, "<span class='warning'>Nie ma defibrylatora do zablokowania!</span>")
		return TRUE
	if(!clamps_locked)
		to_chat(user, "<span class='warning'>Zaciski [src] są zwolnione!</span>")
		return TRUE
	user.visible_message("<span class='notice'>[user] wciska [multitool] w gniazdo ID [src]...</span>", \
	"<span class='notice'>Zaczynasz nadpisywać zaciski [src]...</span>")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	if(!do_after(user, 100, target = src) || !clamps_locked)
		return
	user.visible_message("<span class='notice'>[user] wysyła impuls [multitool], a zaciski [src] się podnoszą.</span>", \
	"<span class='notice'>Nadpisujesz zaciski blokujące [src]!</span>")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	clamps_locked = FALSE
	update_icon()
	return TRUE

/obj/machinery/defibrillator_mount/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!defib)
		to_chat(user, "<span class='warning'>Trudno wyjąć defibrylator z uchwytu, w którym go nie ma.</span>")
		return
	if(clamps_locked)
		to_chat(user, "<span class='warning'>Próbujesz wyciągnąć [defib], ale zaciski uchwytu są mocno zablokowane!</span>")
		return
	if(!user.put_in_hands(defib))
		to_chat(user, "<span class='warning'>Potrzebujesz wolnej ręki!</span>")
		return
	user.visible_message("<span class='notice'>[user] odłącza [defib] od [src].</span>", \
	"<span class='notice'>Wysuwasz [defib] z [src] i odłączasz kable ładujące.</span>")
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	// Make sure processing ends before the defib is nulled
	end_processing()
	defib = null
	update_icon()

//wallframe, for attaching the mounts easily
/obj/item/wallframe/defib_mount
	name = "unhooked defibrillator mount"
	desc = "A frame for a defibrillator mount. It can't be removed once it's placed."
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/machinery/defibrillator_mount
	pixel_shift = -28
