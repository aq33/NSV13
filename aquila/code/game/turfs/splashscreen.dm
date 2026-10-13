// Ekran tytułowy w wyższej rozdzielczości: obraz większy niż 480 px szerokości (np. logo Aquili 960x964)
// jest zmniejszany transformacją do rozmiaru zwykłego ekranu, więc przy powiększonej mapie zostaje ostry.

#define TITLE_SCREEN_WIDTH 480

/turf/closed/indestructible/splashscreen/Initialize(mapload)
	. = ..()
	fit_title_screen()

/// Skaluje obraz tytułowy tak, by zajmował tyle samo miejsca co obraz 480 px, z zachowaniem dolnego lewego rogu
/turf/closed/indestructible/splashscreen/proc/fit_title_screen()
	// icon bywa plikiem zasobu (SStitle), a Width() ma tylko /icon
	var/icon/title_icon = icon(icon)
	var/width = title_icon.Width()
	var/height = title_icon.Height()
	if(width <= TITLE_SCREEN_WIDTH)
		transform = null
		return
	var/scale = TITLE_SCREEN_WIDTH / width
	// Transformacja skaluje wokół środka obrazka, więc przesuwamy go z powrotem do lewego dolnego rogu
	var/matrix/fit = matrix()
	fit.Scale(scale)
	fit.Translate(-(width - width * scale) / 2, -(height - height * scale) / 2)
	transform = fit

/datum/controller/subsystem/title/Initialize()
	. = ..()
	splash_turf?.fit_title_screen()

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && var_name == NAMEOF(src, icon))
		splash_turf?.fit_title_screen()

#undef TITLE_SCREEN_WIDTH
