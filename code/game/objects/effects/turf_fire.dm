// Ported from Yogstation (yogstation13/Yogstation#19738), originally from Shiptest (shiptest-ss13/Shiptest#872)

#define TURF_FIRE_TEMP_BASE (T0C+650)
#define TURF_FIRE_POWER_LOSS_ON_LOW_TEMP 7
#define TURF_FIRE_TEMP_INCREMENT_PER_POWER 3
#define TURF_FIRE_VOLUME 150
#define TURF_FIRE_MAX_POWER 50
#define TURF_FIRE_SPREAD_RATE 0.5
#define TURF_FIRE_MINIMUM_PRESSURE 50

#define TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL 12000
#define TURF_FIRE_BURN_RATE_BASE 0.15
#define TURF_FIRE_BURN_RATE_PER_POWER 0.03
#define TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER 0.75
#define TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED 1
#define TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE 6

#define TURF_FIRE_STATE_SMALL 1
#define TURF_FIRE_STATE_MEDIUM 2
#define TURF_FIRE_STATE_LARGE 3

/obj/effect/abstract/turf_fire
	icon = 'icons/effects/turf_fire.dmi'
	icon_state = "red_small"
	layer = GASFIRE_LAYER
	anchored = TRUE
	move_resist = INFINITY
	light_range = 1.5
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/turf/open/open_turf
	/// How much power have we got. This is treated like fuel, be it flamethrower fuel or any random thing you could come up with
	var/fire_power = 20
	/// Is it magical, if it is then it wont interact with atmos, and it will not loose power by itself. Mainly for adminbus events or mapping
	var/magical = FALSE
	/// Visual state of the fire. Kept track to not do too many updates.
	var/current_fire_state
	/// the list of allowed colors, if fire_color doesn't match, we store the color in hex_color instead and we color the fire based on hex instead
	var/list/allowed_colors = list("red", "blue", "green", "white")
	/// If we are using a custom hex color, which color are we using?
	var/hex_color
	/// If false, it does not interact with atmos.
	var/interact_with_atmos = TRUE
	/// Color prefix of the icon states, "[base_icon_state]_small" etc
	var/base_icon_state = "red"

///All the subtypes are for adminbussery and or mapping
/obj/effect/abstract/turf_fire/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/small
	fire_power = 10

/obj/effect/abstract/turf_fire/small/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/inferno
	fire_power = 30

/obj/effect/abstract/turf_fire/inferno/magical
	magical = TRUE
	interact_with_atmos = FALSE

/obj/effect/abstract/turf_fire/Initialize(mapload, power, fire_color)
	. = ..()
	if(!isopenturf(loc))
		return INITIALIZE_HINT_QDEL
	open_turf = loc
	if(isgroundlessturf(open_turf))
		return INITIALIZE_HINT_QDEL
	if(open_turf.turf_fire)
		return INITIALIZE_HINT_QDEL
	open_turf.turf_fire = src
	RegisterSignal(open_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	START_PROCESSING(SSturf_fire, src)
	if(power)
		fire_power = min(TURF_FIRE_MAX_POWER, power)
	if(!fire_color)
		base_icon_state = "red"
	else if(fire_color in allowed_colors)
		base_icon_state = fire_color
	else
		hex_color = fire_color
		color = fire_color
		base_icon_state = "greyscale"
	UpdateFireState()
	alpha = 160 // be slightly transparent

/obj/effect/abstract/turf_fire/Destroy()
	if(open_turf)
		if(open_turf.turf_fire == src)
			open_turf.turf_fire = null
		UnregisterSignal(open_turf, COMSIG_ATOM_ENTERED)
		open_turf = null
	STOP_PROCESSING(SSturf_fire, src)
	return ..()

/obj/effect/abstract/turf_fire/proc/process_waste()
	if(open_turf.planetary_atmos)
		return TRUE
	var/datum/gas_mixture/air = open_turf.air
	if(!air)
		return FALSE
	var/oxy = air.get_moles(GAS_O2)
	if(oxy < TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED)
		return FALSE
	var/thermal_energy = air.return_temperature() * air.heat_capacity()
	var/burn_rate = TURF_FIRE_BURN_RATE_BASE + fire_power * TURF_FIRE_BURN_RATE_PER_POWER
	if(burn_rate > oxy)
		burn_rate = oxy

	air.adjust_moles(GAS_O2, -burn_rate)
	air.adjust_moles(GAS_CO2, burn_rate * TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER)

	var/new_heat_capacity = air.heat_capacity()
	if(new_heat_capacity)
		air.set_temperature((thermal_energy + (burn_rate * TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL)) / new_heat_capacity)
	return TRUE

/// Fires can't burn well in a near-vacuum
/obj/effect/abstract/turf_fire/proc/fire_pressure_check()
	var/datum/gas_mixture/environment = open_turf.return_air()
	if(!istype(environment))
		return
	if(environment.return_pressure() <= TURF_FIRE_MINIMUM_PRESSURE)
		fire_power -= TURF_FIRE_POWER_LOSS_ON_LOW_TEMP

/obj/effect/abstract/turf_fire/process(delta_time)
	if(open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead and lets not loose power
		return
	for(var/obj/structure/window/window in open_turf)
		if(window.fulltile)
			qdel(src)
			return
	if(interact_with_atmos)
		if(!process_waste())
			qdel(src)
			return
	if(!magical)
		fire_power += open_turf.flammability
		var/temperature = open_turf.air.return_temperature()
		if(temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			fire_power -= TURF_FIRE_POWER_LOSS_ON_LOW_TEMP * ((FIRE_MINIMUM_TEMPERATURE_TO_EXIST - temperature) / FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		fire_power--
		fire_pressure_check()
		if(fire_power <= 0)
			qdel(src)
			return
	var/fire_temp = TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power)
	open_turf.hotspot_expose(fire_temp, TURF_FIRE_VOLUME)
	for(var/atom/movable/burning_atom as anything in open_turf)
		if(burning_atom == src)
			continue
		burning_atom.temperature_expose(open_turf.air, fire_temp, TURF_FIRE_VOLUME)
		burning_atom.fire_act(fire_temp, TURF_FIRE_VOLUME)
	if(QDELETED(src))
		return
	for(var/turf/open/T in open_turf.GetAtmosAdjacentTurfs())
		if(prob(T.flammability * fire_power * TURF_FIRE_SPREAD_RATE))
			T.IgniteTurf(fire_power * TURF_FIRE_SPREAD_RATE)
	if(!magical)
		if(prob(fire_power))
			open_turf.burn_tile()
		if(prob(TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE))
			playsound(open_turf, 'sound/effects/comfyfire.ogg', 40, TRUE)
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(arrived == src || open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead
		return
	arrived.fire_act(TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power), TURF_FIRE_VOLUME)

/obj/effect/abstract/turf_fire/extinguish()
	qdel(src)

/obj/effect/abstract/turf_fire/fire_act(exposed_temperature, exposed_volume)
	return

/obj/effect/abstract/turf_fire/proc/AddPower(power)
	fire_power = min(TURF_FIRE_MAX_POWER, fire_power + power)
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/UpdateFireState()
	var/new_state
	switch(fire_power)
		if(-INFINITY to 10)
			new_state = TURF_FIRE_STATE_SMALL
		if(10 to 25)
			new_state = TURF_FIRE_STATE_MEDIUM
		if(25 to INFINITY)
			new_state = TURF_FIRE_STATE_LARGE

	if(new_state == current_fire_state)
		return
	current_fire_state = new_state

	switch(base_icon_state) //switches light color depending on the flame color
		if("greyscale")
			light_color = hex_color
		if("red")
			light_color = LIGHT_COLOR_FIRE
		if("blue")
			light_color = LIGHT_COLOR_CYAN
		if("green")
			light_color = LIGHT_COLOR_GREEN
		else
			light_color = COLOR_SILVER

	switch(current_fire_state)
		if(TURF_FIRE_STATE_SMALL)
			icon_state = "[base_icon_state]_small"
			set_light(1.5, l_color = light_color)
		if(TURF_FIRE_STATE_MEDIUM)
			icon_state = "[base_icon_state]_medium"
			set_light(2.5, l_color = light_color)
		if(TURF_FIRE_STATE_LARGE)
			icon_state = "[base_icon_state]_big"
			set_light(3, l_color = light_color)

#undef TURF_FIRE_TEMP_BASE
#undef TURF_FIRE_POWER_LOSS_ON_LOW_TEMP
#undef TURF_FIRE_TEMP_INCREMENT_PER_POWER
#undef TURF_FIRE_VOLUME
#undef TURF_FIRE_MAX_POWER
#undef TURF_FIRE_SPREAD_RATE
#undef TURF_FIRE_MINIMUM_PRESSURE

#undef TURF_FIRE_ENERGY_PER_BURNED_OXY_MOL
#undef TURF_FIRE_BURN_RATE_BASE
#undef TURF_FIRE_BURN_RATE_PER_POWER
#undef TURF_FIRE_BURN_CARBON_DIOXIDE_MULTIPLIER
#undef TURF_FIRE_BURN_MINIMUM_OXYGEN_REQUIRED
#undef TURF_FIRE_BURN_PLAY_SOUND_EFFECT_CHANCE

#undef TURF_FIRE_STATE_SMALL
#undef TURF_FIRE_STATE_MEDIUM
#undef TURF_FIRE_STATE_LARGE
