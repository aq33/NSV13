GLOBAL_VAR_INIT(next_button_push, 0)

/obj/item/service
	name = "big red button"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/service/manifest
	desc = "Adds the name of whoever pressed it to the crew manifest. Cannot be changed or undone after the fact!"

/obj/item/service/manifest/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/ID = H.wear_id?.GetID()
		if(!ID)
			to_chat(user, span_notice("Musisz nosić swoją kartę, żeby prawidłowo podrobić manifest! Spróbuj ponownie."))
			return
		var/record_name = ID.registered_name || H.name
		var/assignment = ID.assignment || "Unassigned"
		if(alert(user, "Na pewno chcesz, żeby twój wpis w manifeście załogi brzmiał: [record_name], [assignment]?", "", "Yes", "No") != "Yes")
			return
		var/list/all_jobs = (GLOB.command_positions + GLOB.engineering_positions + GLOB.medical_positions + GLOB.science_positions + GLOB.supply_positions + GLOB.civilian_positions + GLOB.security_positions)
		if(!(assignment in all_jobs) && (alert(user, "Na pewno chcesz mieć stanowisko '[assignment]'? To nie jest standardowe stanowisko i może dziwnie wyglądać w manifeście!", "", "Yes", "No") != "Yes"))
			return
		if(QDELETED(src) || !user.is_holding(src))
			return
		GLOB.data_core.manifest_inject(H, H.client, force = TRUE, record_name = record_name, assignment_override = assignment)
		to_chat(user, span_notice("Dodano do manifestu."))
		log_game("[key_name(user)] spoofed a crew manifest entry as [record_name], [assignment].")
		do_sparks(2, FALSE, src)
		qdel(src)

/obj/item/service/ion
	desc = "Announces a fake ion storm."

/obj/item/service/ion/attack_self(mob/user)
	if(GLOB.next_button_push > world.time)
		return
	priority_announce("W pobliżu statku wykryto burzę jonową. Sprawdźcie, czy sprzęt sterowany przez SI działa poprawnie.", "Alarm - anomalia", 'sound/ai/default/ionstorm.ogg')
	message_admins("[key_name_admin(user)] made a fake ion storm announcement!")
	log_game("[key_name_admin(user)] made a fake ion storm announcement!")
	do_sparks(2, FALSE, src)
	GLOB.next_button_push = world.time+10
	qdel(src)

/obj/item/service/meteor
	desc = "Announces a fake meteor storm."

/obj/item/service/meteor/attack_self(mob/user)
	if(GLOB.next_button_push > world.time)
		return
	priority_announce("Wykryto meteory na kursie kolizyjnym ze statkiem.", "Alarm meteorytowy", 'sound/ai/default/meteors.ogg')
	message_admins("[key_name_admin(user)] made a fake meteor storm announcement!")
	log_game("[key_name_admin(user)] made a fake meteor storm announcement!")
	do_sparks(2, FALSE, src)
	GLOB.next_button_push = world.time+10
	qdel(src)

/obj/item/service/rodgod
	desc = "Announces a fake immovable rod."

/obj/item/service/rodgod/attack_self(mob/user)
	if(GLOB.next_button_push > world.time)
		return
	priority_announce("Co to, kurwa, było?!", "Alarm ogólny")
	message_admins("[key_name_admin(user)] made a fake immovable rod announcement!")
	log_game("[key_name_admin(user)] made a fake immovable rod announcement!")
	do_sparks(2, FALSE, src)
	GLOB.next_button_push = world.time+10
	qdel(src)
