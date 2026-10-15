/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as removing shrapnel and restoring blood volume. Costs 10 chemicals."
	helptext = "Ostrzega pobliską załogę, jeśli odtwarzamy zewnętrzne kończyny. Można użyć w stanie nieprzytomności."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = 1
	req_stat = UNCONSCIOUS

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>Czujesz swędzenie, zarówno w środku, jak i \
		na zewnątrz, gdy twoje tkanki zrastają się raz za razem.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/list/missing = C.get_missing_limbs()
		if(missing.len)
			playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
			C.visible_message("<span class='warning'>Brakujące kończyny [user] \
				odrastają z głośnym, groteskowym dźwiękiem!</span>",
				"<span class='userdanger'>Twoje kończyny odrastają z \
				głośnym chrupnięciem, sprawiając ci ogromny ból!</span>",
				"<span class='italics'>Słyszysz rozrywanie \
				i darcie tkanki organicznej!</span>")
			C.emote("scream")
			C.regenerate_limbs(1)
		if(!user.getorganslot(ORGAN_SLOT_BRAIN))
			var/obj/item/organ/brain/B
			if(C.has_dna() && C.dna.species.mutant_brain)
				B = new C.dna.species.mutant_brain()
			else
				B = new()
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
			B.Insert(C)
		C.regenerate_organs()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
	return TRUE

/datum/action/changeling/limbsnake
	name = "Chimera"
	desc = "We turn our limbs into an autonomous snake. The poison of this creatures can paralyze attackers. Costs 15 chemicals."
	helptext = "Zmieniamy jedną z kończyn w samodzielną, wężopodobną istotę. Ten groteskowy widok może odstraszyć napastników, a istota wstrzyknie im obezwładniający jad."
	button_icon_state = "limbsnake"
	chemical_cost = 15
	dna_cost = 2
	req_human = TRUE
	req_stat = DEAD
	ignores_fakedeath = TRUE

/datum/action/changeling/limbsnake/sting_action(mob/user)
	..()
	var/mob/living/carbon/C = user
	var/list/parts = list()
	for(var/Zim in C.bodyparts)
		var/obj/item/bodypart/BP = Zim
		if(BP.body_part != HEAD && BP.body_part != CHEST && IS_ORGANIC_LIMB(BP))
			if(BP.dismemberable)
				parts += BP
	if(!LAZYLEN(parts))
		to_chat(user, "<span class='notice'>Nie mamy kończyn do odłączenia.</span>")
		return
	//limb related actions
	var/obj/item/bodypart/BP = pick(parts)
	for(var/obj/item/bodypart/Gir in parts)
		if(Gir.body_part == ARM_RIGHT || Gir.body_part == ARM_LEFT)	//arms first, so they can mitigate the damage with the Armblade ability too, and it's not entirely reliant on regenerate
			BP = Gir
	//text message
	C.visible_message("<span class='warning'>[BP] [user] odłącza się i przybiera postać węża!</span>",
			"<span class='userdanger'>Nasza kończyna ([BP]) zmienia się w przerażającego węża i rusza na napastników!</span>")
	BP.dismember()
	BP.Destroy()
	C.update_mobility()
	//Deploy limbsnake
	var/mob/living/snek = new /mob/living/simple_animal/hostile/poison/limbsnake(get_turf(user))
	//assign faction
	snek.faction |= "[REF(C)]"
	return TRUE

/mob/living/simple_animal/hostile/poison/limbsnake
	name = "limb snake"
	desc = "This is no snake at all! It looks like someone's limb grew fangs out of it's fingers and it's out to bite anyone!"
	icon_state = "snake"
	icon_living = "snake"
	del_on_death = TRUE
	speak_emote = list("bulgocze")
	health = 50
	maxHealth = 50
	melee_damage = 3
	attacktext = "gryzie"
	response_help  = "szturcha"
	response_disarm = "przegania"
	response_harm   = "nadeptuje na"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	chat_color = "#26F55A"
	mobchatspan = "chaplain"
	faction = list("hostile","creature")
	poison_per_bite = 4
	poison_type = /datum/reagent/toxin/staminatoxin
	discovery_points = 1000
