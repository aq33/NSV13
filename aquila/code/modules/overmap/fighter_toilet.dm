// Pokładowa toaleta myśliwców: przycisk z sedesem dla załogi małych jednostek (bez górniczych i kapsuł ratunkowych)
/obj/structure/overmap/small_craft
	/// Czy jednostka ma pokładowy system odprowadzania nieczystości
	var/has_toilet = TRUE
	/// Przyciski toalety wydane załodze, mob -> akcja
	var/list/toilet_actions

/obj/structure/overmap/small_craft/escapepod
	has_toilet = FALSE

/obj/structure/overmap/small_craft/transport/sabre/mining
	has_toilet = FALSE

/obj/structure/overmap/small_craft/start_piloting(mob/living/carbon/user, position)
	. = ..()
	if(!. || !has_toilet || LAZYACCESS(toilet_actions, user))
		return
	var/datum/action/innate/fighter_toilet/toilet = new(src)
	toilet.Grant(user)
	LAZYSET(toilet_actions, user, toilet)

/obj/structure/overmap/small_craft/stop_piloting(mob/living/M, eject_mob=TRUE, force=FALSE)
	. = ..()
	if(!.)
		return
	var/datum/action/innate/fighter_toilet/toilet = LAZYACCESS(toilet_actions, M)
	if(toilet)
		LAZYREMOVE(toilet_actions, M)
		qdel(toilet)

/obj/structure/overmap/small_craft/Destroy()
	for(var/mob/user as anything in toilet_actions)
		qdel(toilet_actions[user])
	toilet_actions = null
	return ..()

/datum/action/innate/fighter_toilet
	name = "Skorzystaj z pokładowej toalety"
	desc = "Pokładowy system odprowadzania nieczystości. Pilot też człowiek."
	icon_icon = 'icons/obj/watercloset.dmi'
	button_icon_state = "toilet00"
	check_flags = AB_CHECK_CONSCIOUS
	var/in_use = FALSE

/datum/action/innate/fighter_toilet/Activate()
	var/mob/living/user = owner
	if(!istype(user) || in_use)
		return
	if(!CONFIG_GET(flag/shitting_enabled))
		to_chat(user, "<span class='warning'>Wypróżnianie się zostało wyłączone w konfiguracji serwera.</span>")
		return
	if(user.defecation <= DEFECATION_VERY)
		to_chat(user, "<span class='notice'>Nie potrzebujesz skorzystać z toalety.</span>")
		return
	in_use = TRUE
	to_chat(user, "<span class='notice'>Podpinasz się do pokładowego systemu odprowadzania nieczystości...</span>")
	if(do_after(user, 3 SECONDS, target = user))
		user.set_defecation(DEFECATION_NONE)
		playsound(get_turf(user), 'aquila/sound/misc/toilet_flush.ogg', 50, vary = FALSE)
		to_chat(user, "<span class='notice'><i>Ale ulga...</i> Nieczystości zostają wystrzelone w przestrzeń kosmiczną.</span>")
		var/datum/reagent/consumable/castor_oil/oil = user.reagents?.get_reagent(/datum/reagent/consumable/castor_oil)
		oil?.purge(user)
	in_use = FALSE
