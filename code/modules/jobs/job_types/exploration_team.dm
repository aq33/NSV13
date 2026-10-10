/datum/job/exploration_crew
	title = JOB_NAME_EXPLORATIONCREW
	flag = EXPLORATION_CREW
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "dyrektor badań"
	minimal_player_age = 3
	exp_requirements = 900
	exp_type = EXP_TYPE_CREW
	selection_color = "#ffeeff"

	outfit = /datum/outfit/job/exploration_crew

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE, ACCESS_XENOBIOLOGY)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_EXPLORATION
	departments = DEPARTMENT_BITFLAG_SCIENCE
	rpg_title = "Sailor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/exploration_crew
	)
	biohazard = 20//who knows what you'll find out there that could have nasties on it...

/datum/job/exploration_crew/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	if(outfit_override)
		return ..()
	if(visualsOnly || latejoin)
		return ..()
	var/static/exploration_job_id = 0
	exploration_job_id ++
	switch(exploration_job_id)
		//Scientist is most important due to scanner
		if(1)
			to_chat(H, "<span class='notice big'>Jesteś <span class'sciradio'>naukowcem</span> zespołu eksploracyjnego!</span>")
			to_chat(H, "<span class='notice'>Skanuj nieodkryte stworzenia, by zdobywać punkty badań odkryć!</span>")
			outfit_override = /datum/outfit/job/exploration_crew/scientist
		if(2)
			to_chat(H, "<span class='notice big'>Jesteś <span class'medradio'>lekarzem</span> zespołu eksploracyjnego!</span>")
			to_chat(H, "<span class='notice'>Dbaj o zdrowie zespołu, odnajdując i lecząc rannych członków.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/medic
		if(3)
			to_chat(H, "<span class='notice big'>Jesteś <span class'engradio'>inżynierem</span> zespołu eksploracyjnego!</span>")
			to_chat(H, "<span class='notice'>Twórz punkty wejścia za pomocą materiałów wybuchowych i dbaj o kadłub swojego statku.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/engineer
	. = ..(H, visualsOnly, announce, latejoin, outfit_override, preference_source)

/datum/outfit/job/exploration_crew
	name = JOB_NAME_EXPLORATIONCREW
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew
	belt = /obj/item/modular_computer/tablet/pda/exploration_crew
	ears = /obj/item/radio/headset/headset_exploration
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black
	uniform = /obj/item/clothing/under/rank/cargo/exploration
	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,\
		/obj/item/stack/marker_beacon/thirty=1)
	l_pocket = /obj/item/gps/mining/exploration
	r_pocket = /obj/item/gun/energy/e_gun/mini/exploration

	backpack = /obj/item/storage/backpack/explorer
	satchel = /obj/item/storage/backpack/satchel/explorer
	duffelbag = /obj/item/storage/backpack/duffelbag

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration_crew/engineer
	name = "Exploration Crew (Engineer)"

	belt = /obj/item/storage/belt/utility/full
	r_pocket = /obj/item/modular_computer/tablet/pda/exploration_crew

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/gun/energy/e_gun/mini/exploration=1,
		/obj/item/grenade/exploration=3,				//Breaching charges for entering ruins
		/obj/item/exploration_detonator=1,				//Detonator for the breaching charges.
		/obj/item/discovery_scanner=1
	)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering

/datum/outfit/job/exploration_crew/scientist
	name = "Exploration Crew (Scientist)"

	glasses = /obj/item/clothing/glasses/science

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/discovery_scanner=1,
		/obj/item/sbeacondrop/exploration=1,			//Spawns in a bluespace beacon
		/obj/item/research_disk_pinpointer=1			//Locates research disks
	)

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

/datum/outfit/job/exploration_crew/medic
	name = "Exploration Crew (Medical Doctor)"

	backpack_contents = list(
		/obj/item/kitchen/knife/combat/survival=1,
		/obj/item/stack/marker_beacon/thirty=1,
		/obj/item/storage/firstaid/medical=1,
		/obj/item/pinpointer/crew=1,
		/obj/item/sensor_device=1,
		/obj/item/roller=1,
		/obj/item/discovery_scanner=1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

/datum/outfit/job/exploration_crew/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath
