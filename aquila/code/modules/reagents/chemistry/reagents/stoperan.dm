// Stoperan - na 5 minut zatrzymuje przyrost potrzeby wypróżnienia

/datum/reagent/medicine/stoperan
	name = "Stoperan"
	description = "Lek przeciwbiegunkowy. Na pięć minut wstrzymuje przyrost potrzeby wypróżnienia."
	reagent_state = SOLID
	color = "#E8E4D8"
	taste_description = "kreda"

/datum/reagent/medicine/stoperan/on_mob_metabolize(mob/living/L)
	. = ..()
	L.apply_status_effect(/datum/status_effect/stoperan)

// Kolejna pigułka, gdy poprzednia jeszcze się wchłania, też odświeża czas
/datum/reagent/medicine/stoperan/on_merge(data, amount)
	. = ..()
	var/mob/living/L = holder?.my_atom
	if(metabolizing && istype(L))
		L.apply_status_effect(/datum/status_effect/stoperan)

/datum/status_effect/stoperan
	id = "stoperan"
	duration = 5 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/stoperan/on_apply()
	to_chat(owner, "<span class='notice'>Czujesz, jak twoje jelita się uspokajają.</span>")
	return TRUE

/datum/status_effect/stoperan/on_remove()
	to_chat(owner, "<span class='notice'>Twoje jelita wracają do normalnej pracy.</span>")

/obj/item/reagent_containers/pill/stoperan
	name = "pigułka stoperanu"
	desc = "Na pięć minut wstrzymuje przyrost potrzeby wypróżnienia. Nieoceniona na długich wyprawach górniczych."
	icon_state = "pill_shape_capsule_white"
	list_reagents = list(/datum/reagent/medicine/stoperan = 5)
	rename_with_volume = TRUE
