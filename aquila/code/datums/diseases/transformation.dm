/datum/disease/transformation/jungle_fever
	name = "Jungle Fever"
	cure_text = "Śmierć."
	cures = list(/datum/reagent/medicine/adminordrazine)
	spread_text = "Ugryzienia małp"
	spread_flags = DISEASE_SPREAD_SPECIAL
	viable_mobtypes = list(/mob/living/carbon/monkey, /mob/living/carbon/human)
	permeability_mod = 1
	cure_chance = 1
	disease_flags = CAN_CARRY|CAN_RESIST
	desc = "Monkeys with this disease will bite humans, causing humans to mutate into a monkey."
	danger = DISEASE_BIOHAZARD
	stage_prob = 4
	visibility_flags = 0
	agent = "Kongey Vibrion M-909"
	new_form = null
	bantype = ROLE_MONKEY


	stage1	= list()
	stage2	= list()
	stage3	= list()
	stage4	= list("<span class='warning'>Bolą cię plecy.</span>", "<span class='warning'>Oddychasz przez usta.</span>",
					"<span class='warning'>Masz ochotę na banany.</span>", "<span class='warning'>Twój umysł wydaje się zamglony.</span>")
	stage5	= list("<span class='warning'>Masz ochotę pomałpować.</span>")

/datum/disease/transformation/jungle_fever/proc/init_monkey(var/mob/living/carbon/monkey/M)
	M.ai_controller = new /datum/ai_controller/monkey/angry(M)
	M.ventcrawler = VENTCRAWLER_ALWAYS

/datum/disease/transformation/jungle_fever/after_add()
	if(ismonkey(affected_mob))
		init_monkey(affected_mob)
	if(!affected_mob.mind && ismonkey(affected_mob))
		var/list/candidates = pollGhostCandidates("Do you want to play as an infected monkey?", ROLE_MONKEY, /datum/role_preference/antagonist/monkey, 15 SECONDS, POLL_IGNORE_MONKEY)

		if(QDELETED(src))
			return

		if(candidates.len > 0)
			var/mob/dead/observer/ghost = pick(candidates)
			affected_mob.key = ghost.key
			affected_mob.sync_mind()
			add_monkey(affected_mob.mind)

/datum/disease/transformation/jungle_fever/do_disease_transformation(mob/living/carbon/affected_mob)
	if(affected_mob.mind && !is_monkey(affected_mob.mind))
		add_monkey(affected_mob.mind)
	if(affected_mob && ishuman(affected_mob))
		if((is_monkey_leader(affected_mob.mind) || prob(4)))
			affected_mob.junglegorillize()
		else
			var/mob/living/carbon/monkey/M = affected_mob.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPVIRUS | TR_KEEPSE)
			var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			H.add_hud_to(M)
			init_monkey(M)

/datum/disease/transformation/jungle_fever/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Swędzi cię [pick("plecy", "ręka", "noga", "łokieć", "głowa")].</span>")
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>Czujesz kłujący ból w głowie.</span>")
				affected_mob.confused += 10
		if(4)
			if(prob(3))
				affected_mob.say(pick("Iiik, uk uk!", "Iii-iiik!", "Iiii!", "Ungh, ungh."), forced = "gorączka dżungli")

/datum/disease/transformation/jungle_fever/cure()
	remove_monkey(affected_mob.mind)
	..()

/datum/disease/transformation/jungle_fever/monkeymode
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CAN_CARRY //no vaccines! no cure!

/datum/disease/transformation/jungle_fever/monkeymode/after_add()
	if(affected_mob && !is_monkey_leader(affected_mob.mind))
		visibility_flags = NONE
