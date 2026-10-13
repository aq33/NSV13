// AQUILA - gaszenie świateł przez demona cieni (port z ParadiseSS13).
// W odróżnieniu od lighteater_act niczego nie niszczy: światło gaśnie i można je włączyć ponownie.
// force = TRUE (cień-hak) wypala flary i rozpuszcza świecące ekstrakty slime'ów.

/// Gasi światło atomu. Typy bez nadpisania nic nie robią.
/atom/proc/extinguish_light(force = FALSE)
	return

/// Czy atom ma teraz włączone światło
/atom/proc/is_emitting_light()
	return light_range && light_power > 0 && light_on

/mob/living/extinguish_light(force = FALSE)
	for(var/atom/movable/A as anything in GetAllContents())
		if(A != src && A.is_emitting_light())
			A.extinguish_light(force)

/mob/living/silicon/robot/extinguish_light(force = FALSE)
	if(lamp_enabled)
		toggle_headlamp(TRUE)
	return ..()

/obj/item/flashlight/extinguish_light(force = FALSE)
	if(!on)
		return
	on = FALSE
	update_brightness()
	for(var/datum/action/A as anything in actions)
		A.UpdateButtonIcon()
	if(isobj(loc)) // latarka w broni albo hełmie
		loc.update_icon()

/obj/item/flashlight/flare/extinguish_light(force = FALSE)
	if(!on)
		return
	if(force)
		fuel = 0
		turn_off()
		icon_state = "[initial(icon_state)]-empty"
		visible_message("<span class='danger'>[src] gwałtownie się wypala!</span>")
	else
		visible_message("<span class='danger'>[src] lekko przygasa, ale rozprasza cienie wokół siebie.</span>")

/obj/item/flashlight/slime/extinguish_light(force = FALSE)
	if(force)
		visible_message("<span class='danger'>[src] usycha.</span>")
		qdel(src)
	else
		visible_message("<span class='danger'>[src] lekko przygasa, ale rozprasza cienie wokół siebie.</span>")

/obj/item/modular_computer/extinguish_light(force = FALSE)
	if(has_light && light_on)
		toggle_flashlight()

/obj/item/clothing/head/hardhat/extinguish_light(force = FALSE)
	if(on)
		toggle_helmet_light()

/obj/item/clothing/head/helmet/space/hardsuit/extinguish_light(force = FALSE)
	if(!on)
		return
	on = FALSE
	icon_state = "[basestate][on]-[hardsuit_type]"
	set_light_on(FALSE)
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()
	for(var/datum/action/A as anything in actions)
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/extinguish_light(force = FALSE)
	if(!helmet_on)
		return
	helmet_on = FALSE
	set_light_on(FALSE)
	update_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_head()
		update_button_icons(M)

/obj/item/lighter/extinguish_light(force = FALSE)
	if(!lit)
		return
	set_lit(FALSE)
	update_icon()
	visible_message("<span class='danger'>Płomień [src] gaśnie.</span>")

/obj/item/candle/extinguish_light(force = FALSE)
	if(put_out_candle())
		visible_message("<span class='danger'>Płomień [src] gaśnie.</span>")

/obj/item/clothing/mask/cigarette/extinguish_light(force = FALSE)
	if(lit)
		extinguish()

/obj/item/weldingtool/extinguish_light(force = FALSE)
	if(!welding)
		return
	switched_off()
	visible_message("<span class='danger'>Cienie otaczają [src] i duszą jego płomień.</span>")

/obj/structure/glowshroom/extinguish_light(force = FALSE)
	if(force)
		visible_message("<span class='danger'>[src] usycha.</span>")
		qdel(src)
	else
		visible_message("<span class='danger'>[src] lekko przygasa, ale rozprasza cienie wokół siebie.</span>")

/obj/mecha/extinguish_light(force = FALSE)
	if(!lights)
		return
	lights = FALSE
	set_light_on(FALSE)
	lights_action?.button_icon_state = "mech_lights_off"
	lights_action?.UpdateButtonIcon()
	visible_message("<span class='danger'>Światła [src] gasną.</span>")

/turf/open/floor/light/extinguish_light(force = FALSE)
	if(!on)
		return
	on = FALSE
	update_icon()
	visible_message("<span class='danger'>[src] gaśnie.</span>")

// Lampy ścienne gasną na 5 minut i w tym czasie nie mają też zasilania awaryjnego

/obj/machinery/light
	/// Zgaszona przez demona cieni, nie świeci do czasu restore_extinguished_light()
	var/shadow_extinguished = FALSE

/obj/machinery/light/extinguish_light(force = FALSE)
	if(status != LIGHT_OK)
		return
	var/was_dark = shadow_extinguished
	shadow_extinguished = TRUE
	addtimer(CALLBACK(src, PROC_REF(restore_extinguished_light)), 5 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(was_dark)
		return
	visible_message("<span class='danger'>[src] migocze i gaśnie.</span>")
	seton(FALSE)

/obj/machinery/light/proc/restore_extinguished_light()
	shadow_extinguished = FALSE
	if(status == LIGHT_OK && has_power())
		visible_message("<span class='notice'>[src] znów się rozjarza.</span>")
	seton(has_power())

// power_change() woła seton() z pominięciem has_power()
/obj/machinery/light/seton(s)
	if(shadow_extinguished)
		s = FALSE
	return ..(s)

/obj/machinery/light/has_power()
	if(shadow_extinguished)
		return FALSE
	return ..()

/obj/machinery/light/has_emergency_power(pwr)
	if(shadow_extinguished)
		return FALSE
	return ..()

/obj/machinery/light/flicker(amount = rand(10, 20))
	set waitfor = FALSE
	if(shadow_extinguished)
		return
	return ..()

/obj/machinery/light/fix()
	shadow_extinguished = FALSE
	return ..()
