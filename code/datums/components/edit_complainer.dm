// This is just a bit of fun while making an example for global signal
/datum/component/edit_complainer
	var/list/say_lines

/datum/component/edit_complainer/Initialize(list/text)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/static/list/default_lines = list(
		"Rozrzutność Centrali strzępi kolejną nić.",
		"Kolejne szarpnięcie za osnowę.",
		"Kto wie, kiedy te naprężenia w końcu roztrzaskają formę?",
		"Nawet teraz przez szczeliny przebija światło.",
		"Centrala znów nagina wiedzę poza swoje uprawnienia.",
		"W mansusie panuje niepewna atmosfera.",
		)
	say_lines = text || default_lines

	RegisterSignal(SSdcs, COMSIG_GLOB_VAR_EDIT, PROC_REF(var_edit_react))

/datum/component/edit_complainer/proc/var_edit_react(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/atom/movable/master = parent
	master.say(pick(say_lines))
