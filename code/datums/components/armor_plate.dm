/datum/component/armor_plate
	var/amount = 0
	var/maxamount = 3
	var/upgrade_item = /obj/item/stack/sheet/animalhide/goliath_hide
	var/datum/armor/added_armor = list("melee" = 10)
	var/upgrade_name

/datum/component/armor_plate/Initialize(_maxamount,obj/item/_upgrade_item,datum/armor/_added_armor)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(applyplate))
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, PROC_REF(dropplates))

	if(_maxamount)
		maxamount = _maxamount
	if(_upgrade_item)
		upgrade_item = _upgrade_item
	if(_added_armor)
		if(islist(_added_armor))
			added_armor = getArmor(arglist(_added_armor))
		else if (istype(_added_armor, /datum/armor))
			added_armor = _added_armor
		else
			stack_trace("Invalid type [_added_armor.type] passed as _armor_item argument to armorplate component")
	else
		added_armor = getArmor(arglist(added_armor))
	var/obj/item/typecast = upgrade_item
	upgrade_name = initial(typecast.name)

/datum/component/armor_plate/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	//upgrade_item could also be typecast here instead
	if(ismecha(parent))
		if(amount)
			if(amount < maxamount)
				examine_list += "<span class='notice'>Jego pancerz jest wzmocniony: [amount] × [upgrade_name].</span>"
			else
				examine_list += "<span class='notice'>Nosi przerażający pancerz złożony w całości z [upgrade_name] - jego pilot musi być doświadczonym łowcą potworów.</span>"
		else
			examine_list += "<span class='notice'>Ma punkty mocowania do przypięcia skór potworów dla dodatkowej ochrony.</span>"
	else
		if(amount)
			examine_list += "<span class='notice'>Wzmocniono go: [amount]/[maxamount] × [upgrade_name].</span>"
		else
			examine_list += "<span class='notice'>Można go wzmocnić maksymalnie: [maxamount] × [upgrade_name].</span>"

/datum/component/armor_plate/proc/applyplate(datum/source, obj/item/I, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(I,upgrade_item))
		return
	if(amount >= maxamount)
		to_chat(user, "<span class='warning'>Nie możesz bardziej ulepszyć [parent]!</span>")
		return

	if(istype(I,/obj/item/stack))
		I.use(1)
	else
		if(length(I.contents))
			to_chat(user, "<span class='warning'>[I] nie może zostać użyty do opancerzenia, gdy coś jest w środku!</span>")
			return
		qdel(I)

	var/obj/O = parent
	amount++
	O.armor = O.armor.attachArmor(added_armor)

	if(ismecha(O))
		var/obj/mecha/R = O
		R.update_icon()
		to_chat(user, "<span class='info'>Wzmacniasz [R], poprawiając jego odporność na obrażenia wręcz, od pocisków i laserów.</span>")
	else
		to_chat(user, "<span class='info'>Wzmacniasz [O], poprawiając jego odporność na ataki wręcz.</span>")


/datum/component/armor_plate/proc/dropplates(datum/source, force)
	SIGNAL_HANDLER

	if(ismecha(parent)) //items didn't drop the plates before and it causes erroneous behavior for the time being with collapsible helmets
		for(var/i in 1 to amount)
			new upgrade_item(get_turf(parent))
