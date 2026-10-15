#define STATE_WRENCHED 1
#define STATE_WELDED 2
#define STATE_WIRED 3
#define STATE_FINISHED 4

/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "cameracase"
	materials = list(/datum/material/iron=400, /datum/material/glass=250)
	result_path = /obj/structure/camera_assembly

/obj/structure/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera_assembly"
	max_integrity = 150
	//	Motion, EMP-Proof, X-ray
	var/malf_xray_firmware_active //used to keep from revealing malf AI upgrades for user facing isXRay() checks when they use Upgrade Camera Network ability
								//will be false if the camera is upgraded with the proper parts.
	var/malf_xray_firmware_present //so the malf upgrade is restored when the normal upgrade part is removed.
	var/obj/item/stack/sheet/mineral/plasma/emp_module
	var/malf_emp_firmware_active //used to keep from revealing malf AI upgrades for user facing isEmp() checks after they use Upgrade Camera Network ability
								//will be false if the camera is upgraded with the proper parts.
	var/malf_emp_firmware_present //so the malf upgrade is restored when the normal upgrade part is removed.
	var/obj/item/assembly/prox_sensor/proxy_module
	var/state = STATE_WRENCHED

/obj/structure/camera_assembly/examine(mob/user)
	. = ..()
	//upgrade messages
	var/has_upgrades
	if(emp_module)
		. += "Ma zainstalowane ekranowanie przed zakłóceniami elektromagnetycznymi."
		has_upgrades = TRUE
	else if(state == STATE_WIRED)
		. += "<span class='info'>Można ją osłonić przed zakłóceniami elektromagnetycznymi odrobiną <b>plazmy</b>.</span>"
	if(proxy_module)
		. += "Ma zainstalowany czujnik zbliżeniowy."
		has_upgrades = TRUE
	else if(state == STATE_WIRED)
		. += "<span class='info'>Można ją ulepszyć <b>czujnikiem zbliżeniowym</b>.</span>"

	//construction states
	switch(state)
		if(STATE_WRENCHED)
			. += "<span class='info'>Możesz ją przymocować <b>spawarką</b> albo zdjąć <b>kluczem</b>.</span>"
		if(STATE_WELDED)
			. += "<span class='info'>Możesz dodać do niej <b>przewody</b> albo <b>odspawać</b> ją od ściany.</span>"
		if(STATE_WIRED)
			if(has_upgrades)
				. += "<span class='info'>Zawarte ulepszenia możesz wyjąć <b>łomem</b>.</span>"
			. += "<span class='info'>Możesz ją dokończyć <b>śrubokrętem</b> albo <b>odłączyć przewody</b>, by zacząć demontaż.</span>"
		if(STATE_FINISHED)
			. += "<span class='boldwarning'>Nie powinieneś tego widzieć, powiedz koderowi!</span>"

/obj/structure/camera_assembly/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)

/obj/structure/camera_assembly/handle_atom_del(atom/A)
	if(A == emp_module)
		emp_module = null
		if(malf_emp_firmware_present)
			malf_emp_firmware_active = malf_emp_firmware_present //re-enable firmware based upgrades after the part is removed.
		if(istype(loc, /obj/machinery/camera))
			var/obj/machinery/camera/contained_camera = loc
			contained_camera.removeEmpProof(malf_emp_firmware_present) //make sure we don't remove MALF upgrades

	else if(A == proxy_module)
		emp_module = null
		if(istype(loc, /obj/machinery/camera))
			var/obj/machinery/camera/contained_camera = loc
			contained_camera.removeMotion()

	return ..()


/obj/structure/camera_assembly/Destroy()
	QDEL_NULL(emp_module)
	QDEL_NULL(proxy_module)
	return ..()

/obj/structure/camera_assembly/proc/drop_upgrade(obj/item/I)
	I.forceMove(drop_location())

	if(I == emp_module)
		emp_module = null
		if(malf_emp_firmware_present)
			malf_emp_firmware_active = malf_emp_firmware_present //re-enable firmware based upgrades after the part is removed.

	else if(I == proxy_module)
		proxy_module = null


/obj/structure/camera_assembly/attackby(obj/item/W, mob/living/user, params)
	switch(state)
		if(STATE_WRENCHED)
			if(W.tool_behaviour == TOOL_WELDER)
				if(weld(W, user))
					to_chat(user, "<span class='notice'>Mocno przyspawujesz [src] na miejscu.</span>")
					setAnchored(TRUE)
					state = STATE_WELDED
				return

		if(STATE_WELDED)
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					to_chat(user, "<span class='notice'>Podłączasz przewody do [src].</span>")
					state = STATE_WIRED
				else
					to_chat(user, "<span class='warning'>Do okablowania kamery potrzebujesz dwóch odcinków kabla!</span>")
					return
				return

			else if(W.tool_behaviour == TOOL_WELDER)

				if(weld(W, user))
					to_chat(user, "<span class='notice'>Odspawujesz [src] od miejsca.</span>")
					state = STATE_WRENCHED
					setAnchored(TRUE)
				return

		if(STATE_WIRED)	// Upgrades!
			if(istype(W, /obj/item/stack/sheet/mineral/plasma)) //emp upgrade
				if(emp_module)
					to_chat(user, "<span class='warning'>[src] już zawiera [emp_module]!</span>")
					return
				if(!W.use_tool(src, user, 0, amount=1)) //only use one sheet, otherwise the whole stack will be consumed.
					return
				emp_module = new(src)
				if(malf_xray_firmware_active)
					malf_xray_firmware_active = FALSE //flavor reason: MALF AI Upgrade Camera Network ability's firmware is incompatible with the new part
														//real reason: make it a normal upgrade so the finished camera's icons and examine texts are restored.
				to_chat(user, "<span class='notice'>Podłączasz [W] do wewnętrznych obwodów [src].</span>")
				return

			else if(istype(W, /obj/item/assembly/prox_sensor)) //motion sensing upgrade
				if(proxy_module)
					to_chat(user, "<span class='warning'>[src] już zawiera [proxy_module]!</span>")
					return
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>Podłączasz [W] do wewnętrznych obwodów [src].</span>")
				proxy_module = W
				return

	return ..()

/obj/structure/camera_assembly/crowbar_act(mob/user, obj/item/tool)
	if(state != STATE_WIRED)
		return FALSE
	var/list/droppable_parts = list()
	if(emp_module)
		droppable_parts += emp_module
	if(proxy_module)
		droppable_parts += proxy_module
	if(!droppable_parts.len)
		return
	var/obj/item/choice = input(user, "Wybierz część do wyjęcia:", src) as null|obj in sortNames(droppable_parts)
	if(!choice || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	to_chat(user, "<span class='notice'>Wyjmujesz [choice] z [src].</span>")
	drop_upgrade(choice)
	tool.play_tool_sound(src)
	return TRUE

/obj/structure/camera_assembly/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(.)
		return TRUE
	if(state != STATE_WIRED)
		return FALSE

	tool.play_tool_sound(src)
	var/input = stripped_input(user, "Do których sieci chcesz podłączyć tę kamerę? Oddziel sieci przecinkami. Bez spacji!\nNa przykład: SS13,Security,Secret ", "Ustaw sieć", "SS13")
	if(!input)
		to_chat(user, "<span class='warning'>Nie podano danych, rozłącz się i spróbuj ponownie!</span>")
		return
	var/list/tempnetwork = splittext(input, ",")
	if(tempnetwork.len < 1)
		to_chat(user, "<span class='warning'>Nie znaleziono sieci, rozłącz się i spróbuj ponownie!</span>")
		return
	for(var/i in tempnetwork)
		tempnetwork -= i
		tempnetwork += lowertext(i)
	state = STATE_FINISHED
	var/obj/machinery/camera/C = new(loc, src)
	forceMove(C)
	C.setDir(src.dir)

	C.network = tempnetwork
	var/area/A = get_area(src)
	C.c_tag = "[A.name] ([rand(1, 999)])"
	return TRUE

/obj/structure/camera_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != STATE_WIRED)
		return FALSE

	new /obj/item/stack/cable_coil(drop_location(), 2)
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>Odcinasz przewody od obwodów.</span>")
	state = STATE_WELDED
	return TRUE

/obj/structure/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != STATE_WRENCHED)
		return FALSE
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>Zdejmujesz [src] z miejsca.</span>")
	new /obj/item/wallframe/camera(drop_location())
	//drop upgrades
	if(emp_module)
		drop_upgrade(emp_module)
	if(proxy_module)
		drop_upgrade(proxy_module)

	qdel(src)
	return TRUE

/obj/structure/camera_assembly/proc/weld(obj/item/weldingtool/W, mob/living/user)
	if(!W.tool_start_check(user, amount=3))
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz spawać [src]...</span>")
	if(W.use_tool(src, user, 20, amount=3, volume = 50))
		return TRUE
	return FALSE

/obj/structure/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc)
	qdel(src)


#undef STATE_WRENCHED
#undef STATE_WELDED
#undef STATE_WIRED
#undef STATE_FINISHED
