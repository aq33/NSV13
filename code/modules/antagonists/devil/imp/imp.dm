//////////////////The Monster

/mob/living/simple_animal/imp
	name = "imp"
	real_name = "imp"
	unique_name = TRUE
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("rechocze")
	emote_hear = list("rechocze","skrzeczy")
	response_help  = "rozmyśla się i nie dotyka"
	response_disarm = "macha rękami na"
	response_harm   = "uderza"
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attacktext = "dziko rozszarpuje"
	maxHealth = 200
	health = 200
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/boost = 0
	bloodcrawl = BLOODCRAWL_EAT
	var/list/consumed_mobs = list()
	var/playstyle_string = "<span class='big bold'>Jesteś impem,</span><B> psotnym stworzeniem z piekła. Zajmujesz najniższy szczebel piekielnej hierarchii. Choć nie musisz pomagać, może pomagając diabłowi wyższej rangi, zdobędziesz awans. Nie jesteś jednak w stanie celowo skrzywdzić innego diabła.</B>"
	mobchatspan = "cultmobsay"
	discovery_points = 10000

/mob/living/simple_animal/imp/Initialize(mapload)
	..()
	boost = world.time + 30

/mob/living/simple_animal/imp/Life()
	..()
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/imp/death()
	..(1)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] wrzeszczy w agonii, sublimując w siarkowy dym.</span>")
	ghostize()
	qdel(src)


/datum/antagonist/imp
	name = "Chochlik"
	antagpanel_category = "Devil"
	show_in_roundend = FALSE
	banning_key = ROLE_DEVIL

/datum/antagonist/imp/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/imp/proc/give_objectives()
	var/datum/objective/newobjective = new
	newobjective.explanation_text = "Spróbuj awansować na wyższą rangę diabelską."
	newobjective.owner = owner
	objectives += newobjective
	log_objective(owner, newobjective.explanation_text)
