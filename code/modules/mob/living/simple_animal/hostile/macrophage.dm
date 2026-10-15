/mob/living/simple_animal/hostile/macrophage
	name = "Germ"
	desc = "A giant virus!"
	icon_state = "macrovirus_small"
	speak_emote = list("bulgocze")
	emote_hear = list("bulgocze")
	melee_damage = 1
	attacktext = "przebija"
	response_help  = "przegania"
	response_disarm = "odgania"
	response_harm   = "zgniata"
	maxHealth = 6
	health = 6
	spacewalk = TRUE
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = TRUE
	var/aggressive = FALSE
	var/datum/disease/basedisease = null
	var/list/infections = list()
	discovery_points = 2000

/mob/living/simple_animal/hostile/macrophage/CanAttack(atom/the_target)
	. = ..()
	if(!.)
		return FALSE
	var/alreadyinfected = FALSE
	if(isliving(the_target))
		var/mob/living/M = the_target
		for(var/datum/disease/D in M.diseases)
			if(D.GetDiseaseID() == basedisease.GetDiseaseID())
				if(aggressive)
					if(D.stage >= 4)
						alreadyinfected = TRUE
				else
					alreadyinfected = TRUE
	if(alreadyinfected)
		return FALSE

/mob/living/simple_animal/hostile/macrophage/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(scan)
		E.scan(src, infections, user)
	else
		if(E.create_culture(basedisease, user))
			dust()
			user.visible_message("<span class='danger'>[user] dźga [src] za pomocą [E], wsysając go!</span>", \
	 				 "<span class='danger'>Dźgasz [src] sondą [E], niszcząc go!</span>")
	return TRUE

/mob/living/simple_animal/hostile/macrophage/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/M = target
		if(M.can_inject(src))
			for(var/datum/disease/D in infections)
				if(M.ForceContractDisease(D)) //we already check spread type in the macrophage creation proc
					to_chat(src, "<span class ='notice'>Zarażasz [M] chorobą [D]!</span>")
		else if(aggressive)
			M.visible_message("<span class='danger'>[src] zaczyna przebijać się przez ochronę [M]!</span>", \
	 				 "<span class='danger'>[src] zaczyna przebijać się przez twoją ochronę!</span>")
			if(do_mob(src, M, 15))
				for(var/datum/disease/D in infections)
					if(M.ForceContractDisease(D))
						to_chat(src, "<span class ='notice'>Zarażasz [M] chorobą [D]!</span>")
				to_chat(M, "<span class ='userdanger'>[src] przebija twoją ochronę i czujesz ostre ukłucie!</span>")

/mob/living/simple_animal/hostile/macrophage/proc/shrivel()
	visible_message("<span class='danger'>[src] kurczy się i umiera!</span>")
	dust()

/mob/living/simple_animal/hostile/macrophage/aggro
	name = "Giant Germ"
	desc = "An incredibly huge virus!"
	icon_state = "macrovirus_large"
	melee_damage = 5
	maxHealth = 12
	health = 12
	pass_flags = PASSTABLE | PASSGRILLE
	density = TRUE
	aggressive = TRUE

/mob/living/simple_animal/hostile/macrophage/aggro/vector

/mob/living/simple_animal/hostile/macrophage/aggro/vector/Initialize(mapload)
	.=..()
	var/datum/disease/advance/random/macrophage/D = new
	health += D.resistance
	maxHealth += D.resistance
	melee_damage += max(0, D.resistance)
	infections += D
	basedisease = D

