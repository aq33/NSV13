/obj/effect/mob_spawn/human/virtual_domain
	name = "wirtualny spawner"
	outfit = /datum/outfit/virtual_pirate
	mob_name = "byt domeny wirtualnej"
	short_desc = "Nie powinieneś tego widzieć, zgłoś to koderowi!"
	flavour_text = "Naprawdę NIE powinno cię tu być."
	important_info = "Bitrunning to przestępstwo, a bitrunnerzy są twoim głównym zagrożeniem."
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	assignedrole = ROLE_GLITCH
	banType = ROLE_GLITCH
	///Does this bit-entity get an antag datum with the goal of hunting bitrunners? TRUE by default
	var/antag = TRUE
	/// Ostatnio stworzony mob (create() z Bee nic nie zwraca)
	var/mob/living/last_spawned
	/// Umysł i ciało ducha, który właśnie wchodzi (żeby po śmierci wrócił do starego ciała)
	var/datum/mind/incoming_mind
	var/mob/living/incoming_body

/obj/effect/mob_spawn/human/virtual_domain/create(ckey, name)
	var/mob/dead/observer/ghost = ckey ? get_mob_by_ckey(ckey) : null
	incoming_mind = ghost?.mind
	incoming_body = incoming_mind?.current
	last_spawned = null
	..()
	incoming_mind = null
	incoming_body = null
	return last_spawned

/obj/effect/mob_spawn/human/virtual_domain/special(mob/living/spawned_mob, name)
	. = ..()
	last_spawned = spawned_mob
	if(incoming_mind) // Preserves any previous bodies before making the switch
		spawned_mob.AddComponent(/datum/component/temporary_body, incoming_mind, incoming_body, TRUE)

	if(antag && spawned_mob.mind)
		spawned_mob.mind.add_antag_datum(/datum/antagonist/domain_ghost_actor)
		spawned_mob.mind.assigned_role = ROLE_GLITCH

	SEND_SIGNAL(src, COMSIG_GHOSTROLE_SPAWNED, spawned_mob)

/// Simulates a ghost role spawn without calling special(), ie a bitrunner spawn instead of a ghost.
/obj/effect/mob_spawn/human/virtual_domain/proc/artificial_spawn(mob/living/runner)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SPAWNED, runner)

//Beach Bums (Friendly)
/obj/effect/mob_spawn/human/virtual_domain/beach
	mob_name = "wirtualny plażowicz"
	name = "spawner wirtualnego plażowicza"
	short_desc = "Jesteś, no, totalnie wirtualną symulacją ziomka, ziom."
	flavour_text = "Przyjechałeś tu na wiosenną przerwę, poderwać jakieś odlotowe e-laski, kumasz?"
	important_info = "Nie masz nic przeciwko bitrunnerom. Właściwie nawet nie wiesz, że jesteś w symulacji."
	outfit = /datum/outfit/beachbum
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	antag = FALSE
	assignedrole = "Wirtualny plażowicz"

/obj/effect/mob_spawn/human/virtual_domain/beach/lifeguard
	name = "spawner wirtualnej ratowniczki"
	short_desc = "Jesteś energiczną wirtualną ratowniczką!"
	flavour_text = "Pilnujesz, żeby nikt się nie zlagował i nie został zjedzony przez malware."
	mob_gender = FEMALE

/obj/effect/mob_spawn/human/virtual_domain/beach/bartender
	name = "spawner wirtualnego barmana"
	short_desc = "Jesteś wirtualnym barmanem na plaży!"
	flavour_text = "Twoja praca to podawać wirtualne drinki i pomagać ziomkom w symulacjach upojenia."
	outfit = /datum/outfit/spacebartender

//Skeleton Pirates
/obj/effect/mob_spawn/human/virtual_domain/pirate
	name = "wirtualne szczątki pirata"
	desc = "Jakieś nieruchome kości. Wyglądają, jakby w każdej chwili mogły ożyć!"
	density = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "wirtualny pirat-szkielet"
	short_desc = "Jesteś wirtualnym piratem. Arrr!"
	flavour_text = "LĄDOWY SZCZUR poluje na twój łup. Powstrzymaj go!"
	mob_species = /datum/species/skeleton

/obj/effect/mob_spawn/human/virtual_domain/pirate/special(mob/living/spawned_mob, name)
	. = ..()
	spawned_mob.fully_replace_character_name(spawned_mob.real_name, "[pick(strings(PIRATE_NAMES_FILE, "beginnings"))][pick(strings(PIRATE_NAMES_FILE, "endings"))]")

/datum/outfit/virtual_pirate
	name = "Virtual Pirate"
	id = /obj/item/card/id
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/pirate
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana
	shoes = /obj/item/clothing/shoes/jackboots

//Syndicate
/obj/effect/mob_spawn/human/virtual_domain/syndie
	name = "wirtualny uśpiacz Syndykatu"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	mob_name = "wirtualny agent Syndykatu"
	short_desc = "Jesteś wirtualnym agentem Syndykatu."
	flavour_text = "Wyją alarmy! Ktoś nas abordażuje!"
	outfit = /datum/outfit/virtual_syndicate

/datum/outfit/virtual_syndicate
	name = "Virtual Syndie"
	id = /obj/item/card/id/syndicate
	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/virtual_syndicate/post_equip(mob/living/carbon/human/user, visualsOnly)
	user.faction |= "Syndicate"

/obj/effect/mob_spawn/human/virtual_domain/islander
	name = "wyspiarz"
	outfit = /datum/outfit/beachbum_combat
	mob_name = "bojowy plażowicz"
	short_desc = "Jesteś wirtualnym wyspiarzem."
	flavour_text = "Nie pozwól nikomu zepsuć twojego idyllicznego urlopu. Współpracuj z innymi... albo nie!"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	uses = -1
	permanent = TRUE
