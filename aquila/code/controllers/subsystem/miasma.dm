// AQUILA - Miasma, see aquila/code/modules/miasma/
/**
 * Polls everything that rots (corpses, gibs, corpse flowers) and releases their miasma.
 *
 * Replaces BeeStation's /datum/component/rot, which processed every source every second, built a
 * temporary gas mixture each time and then rebuilt the turf's atmos adjacency. Here sources are polled
 * every 10 seconds, emission is summed per turf, and the total goes straight into the turf's air.
 */
SUBSYSTEM_DEF(miasma)
	name = "Miasma"
	wait = 10 SECONDS
	flags = SS_BACKGROUND | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// Registered sources: atom => moles it can still emit
	var/list/sources = list()
	/// Sources left to poll in the current fire
	var/list/currentrun = list()
	/// Miasma to release in the current fire: turf => moles
	var/list/emissions = list()
	/// TRUE once the current fire has polled every source and is releasing [emissions]
	var/applying = FALSE

/datum/controller/subsystem/miasma/stat_entry(msg)
	msg = "S:[length(sources)]"
	return ..()

/// Starts polling `source`. A source that is already registered keeps its remaining budget.
/datum/controller/subsystem/miasma/proc/add_source(atom/source, budget = INFINITY)
	if(QDELETED(source) || sources[source])
		return
	sources[source] = budget
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(on_source_deleted))

/datum/controller/subsystem/miasma/proc/remove_source(atom/source)
	sources -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/controller/subsystem/miasma/proc/on_source_deleted(atom/source)
	SIGNAL_HANDLER
	remove_source(source)
	currentrun -= source

/datum/controller/subsystem/miasma/fire(resumed)
	if(!resumed)
		currentrun = sources.Copy()
		emissions.Cut()
		applying = FALSE

	if(!applying)
		var/seconds = wait * 0.1
		var/list/to_poll = currentrun
		while(length(to_poll))
			var/atom/source = to_poll[length(to_poll)]
			to_poll.len--
			var/moles = source.miasma_emission(seconds)
			if(isnull(moles))
				remove_source(source)
			else if(moles > 0)
				var/turf/open/T = get_turf(source)
				if(istype(T) && !isspaceturf(T))
					var/budget = sources[source]
					moles = min(moles, budget)
					emissions[T] += moles
					if(budget <= moles)
						remove_source(source)
					else
						sources[source] = budget - moles
			if(MC_TICK_CHECK)
				return
		applying = TRUE

	var/list/to_emit = emissions
	while(length(to_emit))
		var/turf/open/T = to_emit[length(to_emit)]
		var/moles = to_emit[T]
		to_emit.len--
		if(istype(T)) // ChangeTurf may have closed it since
			emit(T, moles)
		if(MC_TICK_CHECK)
			return

/// Adds miasma to a turf, up to [MIASMA_LOCAL_CAP_MOLES]
/datum/controller/subsystem/miasma/proc/emit(turf/open/T, moles)
	var/datum/gas_mixture/air = T.air
	if(!air)
		return
	var/current = air.get_moles(GAS_MIASMA)
	if(current >= MIASMA_LOCAL_CAP_MOLES || air.return_pressure() > WARNING_HIGH_PRESSURE - 10)
		return
	moles = min(moles, MIASMA_LOCAL_CAP_MOLES - current)
	air.adjust_moles_temp(GAS_MIASMA, moles, BODYTEMP_NORMAL)
	// Only redraw when this emission makes the cloud visible; auxmos handles the rest as the gas spreads
	var/visible = GLOB.gas_data.visibility[GAS_MIASMA]
	if(current < visible && current + moles >= visible)
		T.update_visuals()

/**
 * How much miasma this atom releases over `seconds`, if it is registered with SSmiasma.
 *
 * Return 0 to skip this poll, or null to unregister.
 */
/atom/proc/miasma_emission(seconds)
	return null
