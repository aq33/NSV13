/obj/item/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = 0

/obj/item/toy/xmas_cracker/attack(mob/target, mob/user)
	if( !cracked && ishuman(target) && (target.stat == CONSCIOUS) && !target.get_active_held_item() )
		target.visible_message("[user] i [target] rozrywają [src]! *pyk*", "<span class='notice'>Rozrywasz [src] razem z [target]! *pyk*</span>", "<span class='italics'>Słyszysz pyknięcie.</span>")
		var/obj/item/paper/joke_paper = new /obj/item/paper(user.loc)
		joke_paper.name = "[pick("awful","terrible","unfunny")] joke"
		joke_paper.add_raw_text(pick("Co powiedział jeden bałwan do drugiego?\n\n<i>„Czy to ja, czy tu czuć marchewkę?”</i>",
			"Czemu bałwan nie mógł znaleźć dziewczyny?\n\n<i>Bo był oziębły!</i>",
			"Gdzie kształcą się pomocnicy Mikołaja?\n\n<i>Nigdzie, są ELFabetami.</i>",
			"Co się stało z człowiekiem, który kradł kalendarze adwentowe?\n\n<i>Dostał 25 dni.</i>",
			"Co dopada Mikołaja, gdy utknie w kominie?\n\n<i>Klaus-trofobia.</i>",
			"Gdzie można znaleźć fasolkę chili?\n\n<i>Na biegunie północnym.</i>",
			"Co się dzieje, gdy zje się ozdoby choinkowe?\n\n<i>Łańcuchowa reakcja!</i>",
			"Co bałwany noszą na głowach?\n\n<i>Lodowe czapy!</i>",
			"Czemu Boże Narodzenie jest jak życie na SS13?\n\n<i>Ty odwalasz całą robotę, a grubas zgarnia całą zasługę.</i>",
			"Czemu Mikołaj nie ma dzieci?\n\n<i>Bo zawsze schodzi tylko przez komin.</i>"))
		joke_paper.update_appearance()
		new /obj/item/clothing/head/festive(target.loc)
		user.update_icons()
		cracked = 1
		icon_state = "cracker1"
		var/obj/item/toy/xmas_cracker/other_half = new /obj/item/toy/xmas_cracker(target)
		other_half.cracked = 1
		other_half.icon_state = "cracker2"
		target.put_in_active_hand(other_half)
		playsound(user, 'sound/effects/snap.ogg', 50, 1)
		return TRUE
	return ..()

/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags_inv = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)

/obj/item/clothing/head/festive/Initialize(mapload)
	//Merry christmas
	if(CHRISTMAS in SSevents.holidays)
		armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30, "stamina" = 30)
	else if(FESTIVE_SEASON in SSevents.holidays)
		armor = list("melee" = 20, "bullet" = 20, "laser" = 20,"energy" = 20, "bomb" = 20, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20, "stamina" = 20)
	return ..()

/obj/effect/spawner/xmastree
	name = "christmas tree spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	layer = FLY_LAYER

	var/festive_tree = /obj/structure/flora/tree/pine/xmas
	var/christmas_tree = /obj/structure/flora/tree/pine/xmas/presents

/obj/effect/spawner/xmastree/Initialize(mapload)
	..()
	if((CHRISTMAS in SSevents.holidays) && christmas_tree)
		new christmas_tree(get_turf(src))
	else if((FESTIVE_SEASON in SSevents.holidays) && festive_tree)
		new festive_tree(get_turf(src))

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/xmastree/rdrod
	name = "festivus pole spawner"
	festive_tree = /obj/structure/festivus
	christmas_tree = null

/datum/round_event_control/santa
	name = "Vist by Santa"
	holidayID = CHRISTMAS
	typepath = /datum/round_event/santa
	weight = 20
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/santa
	var/mob/living/carbon/human/santa //who is our santa?

/datum/round_event/santa/announce(fake)
	priority_announce("Mikołaj przybywa do miasta!", "Nieznana transmisja", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/santa/start()
	var/list/candidates = pollGhostCandidates("Mikołaj przybywa do miasta! Chcesz być Mikołajem?", poll_time = 15 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		santa = new /mob/living/carbon/human(pick(GLOB.blobstart))
		santa.key = C.key

		var/datum/antagonist/santa/A = new
		santa.mind.add_antag_datum(A)
