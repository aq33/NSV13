/obj/effect/mob_spawn/human/nsv13/syndicate_crew/
	name = "a syndicate soldier class stasis pod"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time. It has a name and Syndicate insignia on it."
	mob_name = "Syndicate Soldier"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	roundstart = FALSE
	death = FALSE
	flavour_text = "<b>Jesteś </b><span class='big bold'>żołnierzem Syndykatu</span><b>, członkiem załogi okrętu kosmicznego Syndykatu. Twoim celem jest za wszelką cenę chronić okręt i jego cenne zasoby, takie jak więźniowie czy dane nawigacyjne. Porażka nie zostanie zaakceptowana.</b>"
	assignedrole = "Syndicate Soldier"
	outfit = /datum/outfit/syndicate/sleeper/soldier

/obj/effect/mob_spawn/human/nsv13/syndicate_crew/pilot
	name = "a syndicate pilot class stasis pod"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time. It has as Officer's name and Syndicate insignia on it."
	mob_name = "Syndicate Pilot"
	flavour_text = "<b>Jesteś </b><span class='big bold'>pilotem Syndykatu</span><b>, członkiem załogi okrętu kosmicznego Syndykatu. Twoim celem jest latać i chronić mostek okrętu, na którym stacjonujesz. Nie pozwól, by dane nawigacyjne wpadły w ręce wroga.</b>"
	assignedrole = "Syndicate Pilot"
	outfit = /datum/outfit/syndicate/sleeper/pilot

/obj/effect/mob_spawn/human/nsv13/syndicate_crew/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/nsv13/syndicate_crew/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,random_unique_name(gender))

/obj/effect/mob_spawn/human/nsv13/syndicate_crew/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Członek załogi Syndykatu zaraz rozmrozi się z kriokomory w [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/human/nsv13/nt_prisoner/
	name = "a prisoner stasis pod"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time. It has a prisoner's identification number and a Nanotrasen insignia on it. It seems like it's been ashed around quite a bit."
	mob_name = "NT Prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	flavour_text = "<b>Jesteś </b><span class='big bold'>więźniem Syndykatu</span><b>. Jesteś pracownikiem Nanotrasen schwytanym przez Syndykat. Twoim celem jest uciec żywym z okrętu, na którym się znajdujesz. Miejmy nadzieję, że twoje intensywne szkolenie pomoże!</b><span class='big bold'><span class='danger'>TO NIE JEST ROLA ANTAGONISTY!</span></span>"
	assignedrole = "NT Prisoner"
	outfit = /datum/outfit/sleeper/prisoner

/obj/effect/mob_spawn/human/nsv13/nt_prisoner/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/nsv13/nt_prisoner/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,random_unique_name(gender))

/obj/effect/mob_spawn/human/nsv13/nt_prisoner/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Więzień NT zaraz rozmrozi się z kriokomory w [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_POSIBRAIN) //I don't know which POLL_IGNORE to use here
