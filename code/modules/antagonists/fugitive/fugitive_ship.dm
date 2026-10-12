//works similar to the experiment machine (experiment.dm) except it just holds more and more prisoners

/obj/machinery/fugitive_capture
	name = "bluespace capture machine"
	desc = "Much, MUCH bigger on the inside to transport prisoners safely."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //ha ha no getting out!!

/obj/machinery/fugitive_capture/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Dodaj więźnia, przeciągając go do maszyny.</span>")

/obj/machinery/fugitive_capture/MouseDrop_T(mob/target, mob/user)
	var/mob/living/fugitive_hunter = user
	if(!isliving(fugitive_hunter))
		return
	if(fugitive_hunter.stat || (!(fugitive_hunter.mobility_flags & MOBILITY_STAND) || !(fugitive_hunter.mobility_flags & MOBILITY_UI)) || !Adjacent(fugitive_hunter) || !target.Adjacent(fugitive_hunter) || !ishuman(target))
		return
	var/mob/living/carbon/human/fugitive = target
	var/datum/antagonist/fugitive/fug_antag = fugitive.mind.has_antag_datum(/datum/antagonist/fugitive)
	if(!fug_antag)
		to_chat(fugitive_hunter, "<span class='warning'>To nie jest poszukiwany zbieg!</span>")
		return
	if(do_after(fugitive_hunter, 50, target = fugitive))
		add_prisoner(fugitive, fug_antag)

/obj/machinery/fugitive_capture/proc/add_prisoner(mob/living/carbon/human/fugitive, datum/antagonist/fugitive/antag)
	fugitive.forceMove(src)
	antag.is_captured = TRUE
	to_chat(fugitive, "<span class='userdanger'>Zostajesz wrzucony w ogromną pustkę bluespace, a gdy spadasz coraz głębiej w niebyt, maleńkie wejście do rzeczywistości kurczy się, aż w końcu znika ci z oczu. Nie udało ci się uniknąć schwytania.</span>")
	fugitive.ghostize(TRUE) //so they cannot suicide, round end stuff.

/obj/machinery/computer/shuttle_flight/hunter
	name = "shuttle console"
	shuttleId = "huntership"
	possible_destinations = "huntership_home;huntership_custom;whiteship_home;syndicate_nw"
	req_access = list(ACCESS_HUNTERS)

/obj/structure/closet/crate/eva
	name = "EVA crate"

/obj/structure/closet/crate/eva/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/space/eva(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath(src)
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/oxygen(src)
