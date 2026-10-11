/// Usunięcie moba, który tylko widzi alternatywny wygląd, nie może kasować samego wyglądu.
/// Bazowe unregister_mob() woła remove_from_hud() na usuwanym mobie, a basic/remove_from_hud() wtedy qdeluje
/// cały wygląd, więc np. zabicie myszy kwiatkiem w doniczce zdejmowało przebranie, choć kwiatek był dalej w rękach.
/datum/atom_hud/alternate_appearance/basic/unregister_mob(datum/source, force)
	SIGNAL_HANDLER

	if(source == target)
		return ..()
	remove_hud_from(source, TRUE)
