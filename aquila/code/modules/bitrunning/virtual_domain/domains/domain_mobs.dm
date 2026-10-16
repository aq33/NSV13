// Moby i przedmioty z domen tg, których nie było u nas.
// tg robi z nich basic moby z dynamicznym ludzkim wyglądem; u nas ludzi grają KNPC (ai_boarder).

/// Fałszywa załoga z Heretyckich Łowów. Wartość ofiary zależy od stanowiska.
/mob/living/carbon/human/ai_boarder/fake_crew
	faction = list("vdom_fake_crew")
	outfit = /datum/outfit/job/assistant
	knpc_traits = KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC
	difficulty_override = TRUE
	taunts = list("Ochrona! Pomocy!", "Zostaw mnie!", "Co ty robisz?!")
	call_lines = list("Pomocy!", "Napad!")
	response_lines = list("Już idę!")
	/// Ile punktów daje ofiara na rytualnym kręgu
	var/sacrifice_value = 1

/mob/living/carbon/human/ai_boarder/fake_crew/md
	outfit = /datum/outfit/job/doctor

/mob/living/carbon/human/ai_boarder/fake_crew/sec
	outfit = /datum/outfit/job/security
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC
	sacrifice_value = 2

/mob/living/carbon/human/ai_boarder/fake_crew/engi
	outfit = /datum/outfit/job/engineer

/mob/living/carbon/human/ai_boarder/fake_crew/assistant
	outfit = /datum/outfit/job/assistant

/mob/living/carbon/human/ai_boarder/fake_crew/boss
	sacrifice_value = 3

/mob/living/carbon/human/ai_boarder/fake_crew/boss/cmo
	outfit = /datum/outfit/job/cmo

/mob/living/carbon/human/ai_boarder/fake_crew/boss/ce
	outfit = /datum/outfit/job/ce

/mob/living/carbon/human/ai_boarder/fake_crew/boss/hos
	outfit = /datum/outfit/job/hos
	knpc_traits = KNPC_IS_MARTIAL_ARTIST | KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC


/// Rewolucjonista z Meta Central
/mob/living/carbon/human/ai_boarder/revolutionary
	faction = list("revolution")
	outfit = list(
		/datum/outfit/virtual_revolutionary,
	)
	knpc_traits = KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC | KNPC_IS_DOOR_BASHER
	difficulty_override = TRUE
	taunts = list("PRECZ Z KORPORACJĄ!", "Prawa pracownicze!", "Viva la revolución!", "Zabierzcie mu pałkę!")
	call_lines = list("Ochrona tu jest!", "Do mnie, towarzysze!")
	response_lines = list("Idę, towarzyszu!")

/datum/outfit/virtual_revolutionary
	name = "Virtual Revolutionary"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/soft/red
	gloves = /obj/item/clothing/gloves/color/fyellow
	r_hand = /obj/item/melee/baseball_bat

/datum/outfit/virtual_revolutionary/pre_equip(mob/living/carbon/human/H, visualsOnly)
	if(prob(50))
		r_hand = /obj/item/kitchen/knife
	if(prob(30))
		suit = /obj/item/clothing/suit/armor/vest/old


/// Abduktorzy ze Statku Abduktorów
/mob/living/carbon/human/ai_boarder/abductor
	faction = list("abductor")
	outfit = /datum/outfit/virtual_abductor
	knpc_traits = KNPC_IS_DODGER | KNPC_IS_MERCIFUL | KNPC_IS_AREA_SPECIFIC
	difficulty_override = TRUE
	taunts = list("...", "!!!", "~~~")
	call_lines = list("...!")
	response_lines = list("...")

/mob/living/carbon/human/ai_boarder/abductor/Initialize(mapload)
	. = ..()
	set_species(/datum/species/abductor)

/mob/living/carbon/human/ai_boarder/abductor/melee
	outfit = /datum/outfit/virtual_abductor

/mob/living/carbon/human/ai_boarder/abductor/ranged
	outfit = /datum/outfit/virtual_abductor/ranged

/datum/outfit/virtual_abductor
	name = "Virtual Abductor"
	uniform = /obj/item/clothing/under/abductor
	suit = /obj/item/clothing/suit/armor/abductor/vest
	shoes = /obj/item/clothing/shoes/combat
	r_hand = /obj/item/melee/baton/loaded

/datum/outfit/virtual_abductor/ranged
	name = "Virtual Abductor (ranged)"
	r_hand = /obj/item/gun/energy/alien


/// Pluszak abduktora (nagroda za Statek Abduktorów)
/obj/item/toy/plush/abductor
	name = "pluszowy abduktor"
	desc = "Pluszak przedstawiający kosmitę-abduktora. Metka jest w nieczytelnym języku."
	icon = 'aquila/icons/obj/bitrunning_items.dmi'
	icon_state = "abductor"
	attack_verb = list("porywa", "bada")

/obj/item/toy/plush/abductor/agent
	name = "pluszowy agent abduktorów"
	desc = "Pluszak przedstawiający agenta abduktorów. Pałka jest przyszyta do ręki i chyba nie działa. Nie zostawałbym z nim sam na sam."
	icon_state = "abductor_agent"


/// Sarna z Polowania na Łąkach
/mob/living/simple_animal/deer
	name = "sarna"
	desc = "Łagodne, spokojne zwierzę leśne. Jak to się znalazło w kosmosie?"
	icon = 'aquila/icons/mob/bitrunning_mobs.dmi'
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("chrząka", "cicho chrząka")
	emote_see = list("strzyże uszami.", "skubie trawę.", "rozgląda się czujnie.")
	speak_chance = 1
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help = "głaszcze"
	response_disarm = "delikatnie odpycha"
	response_harm = "kopie"
	attacktext = "bodzie"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	melee_damage = 5
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/deer/Life()
	. = ..()
	if(stat != CONSCIOUS || buckled)
		return
	// płochliwa: ucieka od ludzi w pobliżu
	for(var/mob/living/carbon/human/threat in oview(4, src))
		if(threat.stat != CONSCIOUS)
			continue
		walk_away(src, threat, 7, 3)
		return


/// Gondole z Asteroidy Gondoli - pchają skrzynię z łupem
/mob/living/simple_animal/pet/gondola/virtual_domain
	health = 50
	maxHealth = 50
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_STRONG


/obj/item/stack/cable_coil/random/five
	amount = 5
