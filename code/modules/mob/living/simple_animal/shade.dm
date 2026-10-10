/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	mob_biotypes = list(MOB_SPIRIT)
	maxHealth = 40
	health = 40
	spacewalk = TRUE
	healable = 0
	speak_emote = list("syczy")
	emote_hear = list("zawodzi.","skrzeczy.")
	response_help  = "przekłada rękę przez"
	response_disarm = "macha rękami na"
	response_harm   = "uderza"
	speak_chance = 1
	melee_damage = 5
	attacktext = "metafizycznie uderza"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement = 1
	status_flags = 0
	faction = list("cult")
	status_flags = CANPUSH
	movement_type = FLYING
	loot = list(/obj/item/ectoplasm)
	del_on_death = TRUE
	initial_language_holder = /datum/language_holder/construct
	chat_color = "#FF6262"
	mobchatspan = "cultmobsay"
	discovery_points = 1000

/mob/living/simple_animal/shade/death()
	deathmessage = "wydaje z siebie zadowolone westchnienie, gdy jego forma się rozplata."
	..()

/mob/living/simple_animal/shade/canSuicide()
	if(istype(loc, /obj/item/soulstone)) //do not suicide inside the soulstone
		return 0
	return ..()

/mob/living/simple_animal/shade/attack_animal(mob/living/simple_animal/M)
	if(isconstruct(M))
		var/mob/living/simple_animal/hostile/construct/C = M
		if(!C.can_repair_constructs)
			return
		if(health < maxHealth)
			adjustHealth(-25)
			Beam(M,icon_state="sendbeam",time=4)
			M.visible_message("<span class='danger'>[M] leczy <b>[src]</b>.</span>", \
					   "<span class='cult'>Leczysz <b>[src]</b>, zostawiając <b>[src]</b> z <b>[health]/[maxHealth]</b> zdrowia.</span>")
		else
			to_chat(M, "<span class='cult'>Nie możesz uleczyć <b>[src]</b>, bo nie jest ranny!</span>")
	else if(src != M)
		return ..()

/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user, params)  //Marker -Agouri
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
	else
		. = ..()
