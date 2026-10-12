#define CLOCKDRONE	"drone_clock"

GLOBAL_LIST_INIT(cogscarabs, list())

//====Cogscarab====

/mob/living/simple_animal/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device, filled with twisting cogs and mechanical parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 30
	maxHealth = 30
	faction = list("neutral", "silicon", "turret", "ratvar")
	default_storage = /obj/item/storage/belt/utility/servant/drone
	visualAppearence = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = "<span class='brass'>Jesteś zębatkoskarabeuszem, misterną maszyną, której Rat'var dał świadomość.<br>\
		Po długim i niszczycielskim konflikcie Reebe opustoszało; ty i inne zębatkoskarabeusze powołano do istnienia, by odbudować Reebe na obraz Rat'vara.<br>\
		Buduj umocnienia, pułapki i kuźnie, bo otwarcie Arki wymaga niewyobrażalnej ilości energii, która z pewnością przyciągnie uwagę samolubnych form życia dbających tylko o własne przetrwanie.</span>"
	laws = "Rat'var obdarzył cię darem świadomości.<br>\
		Nie wiążą cię żadne prawa, rób wszystko, co trzeba, by służyć Rat'varowi!"
	chat_color = LIGHT_COLOR_CLOCKWORK
	mobchatspan = "brassmobsay"
	initial_language_holder = /datum/language_holder/clockmob
	discovery_points = 2000

//No you can't go wielding guns like that.
/mob/living/simple_animal/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	GLOB.cogscarabs += src
	add_actionspeed_modifier(/datum/actionspeed_modifier/cogscarab)

/mob/living/simple_animal/drone/cogscarab/death(gibbed)
	GLOB.cogscarabs -= src
	. = ..()

/mob/living/simple_animal/drone/cogscarab/Life(seconds, times_fired)
	if(!is_reebe(z) && !GLOB.ratvar_risen)
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(src, T, FALSE)
	. = ..()

/mob/living/simple_animal/drone/cogscarab/force_hit_projectile(obj/item/projectile/projectile)
	if(isliving(projectile.fired_from) && is_servant_of_ratvar(projectile.fired_from))
		return FALSE
	return TRUE

//====Shell====

/obj/effect/mob_spawn/drone/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon_state = "drone_clock_hat"
	mob_name = "cogscarab"
	mob_type = /mob/living/simple_animal/drone/cogscarab
	short_desc = "Jesteś zębatkoskarabeuszem!"
	flavour_text = "Jesteś zębatkoskarabeuszem, małym budowniczym konstruktem Ratvara. Jesteś słaby i nie możesz opuścić Reebe, \
	ale masz zestaw szybkich narzędzi i fabrykator replik, który wytwarza mosiądz do budowy. Współpracuj ze sługami Ratvara, \
	by budować i utrzymywać umocnienia w Mieście Zębatek."

/obj/effect/mob_spawn/drone/cogscarab/attack_ghost(mob/user)
	if(is_banned_from(user.ckey, ROLE_SERVANT_OF_RATVAR) || QDELETED(src) || QDELETED(user))
		return
	if(!SSticker.mode)
		to_chat(user, "Nie możesz zostać zębatkoskarabeuszem przed rozpoczęciem gry.")
		return
	var/be_drone = alert("Zostać zębatkoskarabeuszem? (Uwaga: nie będzie można cię już sklonować!)",,"Yes","No")
	if(be_drone != "Yes" || QDELETED(src) || !isobserver(user))
		return
	var/mob/living/simple_animal/drone/D = new mob_type(get_turf(loc))
	if(!D.default_hatmask && seasonal_hats && possible_seasonal_hats.len)
		var/hat_type = pick(possible_seasonal_hats)
		var/obj/item/new_hat = new hat_type(D)
		D.equip_to_slot_or_del(new_hat, ITEM_SLOT_HEAD)
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	add_servant_of_ratvar(D, silent=TRUE)
	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	qdel(src)
