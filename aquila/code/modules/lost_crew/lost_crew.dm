// AQUILA - Recovered Crew (tgstation#87072, #87491 and fixes #88345, #92423, #92756).
// Medical orders a body bag with a long-dead crewmember. Fixed up and revived, the body is taken over by a ghost,
// gets a job and an ID like a late joiner, and the medical budget is paid once they stay alive for 3 minutes.
// Simplified from tg: our own short list of causes of death (no wound, heretic or bodypart overlay code),
// the job outfit is equipped on revival instead of a mind lockbox, no "dangerous brain removal" element.

GLOBAL_DATUM_INIT(lost_crew_manager, /datum/lost_crew_manager, new)

/datum/lost_crew_manager
	/// How many credits we reward the medical budget on a successful revive
	var/credits_on_success = 3000
	/// How long after successful revival we check to see if they're still alive, and give rewards
	var/success_check_time = 3 MINUTES
	/// Jobs a recovered crewmember can get
	var/list/possible_jobs = list(
		JOB_NAME_ASSISTANT = 4,
		JOB_NAME_STATIONENGINEER = 1,
		JOB_NAME_MEDICALDOCTOR = 1,
		JOB_NAME_SCIENTIST = 1,
		JOB_NAME_CARGOTECHNICIAN = 1,
		JOB_NAME_MUNITIONSTECHNICIAN = 1,
		JOB_NAME_COOK = 1,
		JOB_NAME_JANITOR = 1,
	)

/// Creates a dead human with a random appearance, job and cause of death
/datum/lost_crew_manager/proc/create_lost_crew(atom/location, revivable = TRUE)
	var/mob/living/carbon/human/new_body = new(location)
	randomize_human(new_body)
	new_body.death()
	new_body.mind_initialize()

	var/job = pickweight(possible_jobs)
	var/list/death_lore = list("Nazywam się [new_body.real_name]. Pracowałem(-am) na tym statku jako: [job].")
	var/datum/lost_crew_cause/cause = pick(subtypesof(/datum/lost_crew_cause))
	cause = new cause()
	cause.apply(new_body)
	death_lore += cause.lore
	qdel(cause)

	// Some time has passed since then
	for(var/obj/item/organ/organ as anything in new_body.internal_organs)
		if(organ.decay_factor && prob(60))
			organ.applyOrganDamage(organ.maxHealth * rand(10, 50) / 100)
	if(prob(25))
		var/list/limbs = list()
		for(var/obj/item/bodypart/limb as anything in new_body.bodyparts)
			if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
				limbs += limb
		var/obj/item/bodypart/lost_limb = pick(limbs)
		lost_limb.drop_limb()
		death_lore += "Chyba straciłem(-am) też kończynę: [lost_limb.name]."
		qdel(lost_limb)

	new_body.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 5)
	if(revivable)
		new_body.AddComponent(/datum/component/ghostrole_on_revive, \
			refuse_revival_if_failed = TRUE, \
			on_successful_revive = CALLBACK(src, PROC_REF(on_successful_revive), job, death_lore))
	return new_body

/// Give the new player a job, an ID, a bank account and their death lore, then check if they survive
/datum/lost_crew_manager/proc/on_successful_revive(job, list/death_lore, mob/living/carbon/human/owner)
	if(!istype(owner))
		return
	SSjob.EquipRank(owner, job, TRUE)
	GLOB.data_core.manifest_inject(owner)
	owner.mind?.special_role = "Recovered Crew"
	for(var/i in 1 to length(death_lore))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), owner, "<span class='boldnotice'>[death_lore[i]]</span>"), 10 SECONDS + 2 SECONDS * i)
	addtimer(CALLBACK(src, PROC_REF(award_success), owner.mind), success_check_time)

/// Tell medbay how it went and put some money into their budget
/datum/lost_crew_manager/proc/award_success(datum/mind/revived_mind)
	if(!revived_mind?.current)
		return
	var/alive = revived_mind.current.stat != DEAD
	var/message = alive ? "Czujniki potwierdzają, że [revived_mind.name] przeżył(a) reanimację. Gratulacje, na konto medycyny przelano [credits_on_success] kr." \
		: "Czujniki wskazują, że [revived_mind.name] nie żyje. Prosimy powiadomić rodzinę o waszej porażce."
	if(alive)
		var/datum/bank_account/medical_budget = SSeconomy.get_dep_account(ACCOUNT_MED)
		medical_budget?.adjust_money(credits_on_success)
	if(length(GLOB.announcement_systems))
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.radio.talk_into(announcer, message, RADIO_CHANNEL_MEDICAL)

/// One way the crewmember died. Keeps the body revivable for a medbay that does its job.
/datum/lost_crew_cause
	/// What the revived player remembers
	var/lore = "Nie pamiętam, jak zginąłem(-am)."

/datum/lost_crew_cause/proc/apply(mob/living/carbon/human/body)
	return

/datum/lost_crew_cause/proc/hurt(mob/living/carbon/human/body, brute = 0, burn = 0, tox = 0, oxy = 0)
	var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/i in 1 to 4)
		body.apply_damage(brute / 4, BRUTE, pick(zones))
		body.apply_damage(burn / 4, BURN, pick(zones))
	body.adjustToxLoss(tox)
	body.adjustOxyLoss(oxy)

/datum/lost_crew_cause/melee
	lore = "Ktoś mnie napadł. Pamiętam tylko kolejne ciosy."

/datum/lost_crew_cause/melee/apply(mob/living/carbon/human/body)
	hurt(body, brute = rand(80, 160))

/datum/lost_crew_cause/bullet
	lore = "Zastrzelono mnie podczas abordażu."

/datum/lost_crew_cause/bullet/apply(mob/living/carbon/human/body)
	hurt(body, brute = rand(70, 140), burn = rand(0, 20))

/datum/lost_crew_cause/laser
	lore = "Trafił mnie laser. Pamiętam zapach przypalonego mięsa."

/datum/lost_crew_cause/laser/apply(mob/living/carbon/human/body)
	hurt(body, burn = rand(80, 150))

/datum/lost_crew_cause/explosion
	lore = "Pamiętam tylko błysk i huk eksplozji."

/datum/lost_crew_cause/explosion/apply(mob/living/carbon/human/body)
	hurt(body, brute = rand(50, 100), burn = rand(30, 70))

/datum/lost_crew_cause/plasmafire
	lore = "Wszędzie był ogień, nie mogłem(-am) uciec."

/datum/lost_crew_cause/plasmafire/apply(mob/living/carbon/human/body)
	hurt(body, burn = rand(100, 170), oxy = rand(20, 60))

/datum/lost_crew_cause/spaced
	lore = "Śluza otworzyła się, kiedy stałem(-am) obok. Pamiętam ciszę i zimno."

/datum/lost_crew_cause/spaced/apply(mob/living/carbon/human/body)
	hurt(body, brute = rand(20, 50), burn = rand(30, 60), oxy = rand(80, 150))

/datum/lost_crew_cause/poison
	lore = "Ktoś mnie otruł. Zrobiło mi się słabo po posiłku."

/datum/lost_crew_cause/poison/apply(mob/living/carbon/human/body)
	hurt(body, tox = rand(90, 160))
	var/obj/item/organ/liver/liver = body.getorganslot(ORGAN_SLOT_LIVER)
	liver?.applyOrganDamage(liver.maxHealth * 0.6)

/// A body bag for long-dead crew, delivered by cargo
/obj/structure/closet/body_bag/lost_crew
	name = "worek na zwłoki długoterminowe"
	desc = "Plastikowy worek do długotrwałego przechowywania i transportu zwłok."

/// Filled with one body. Its brain is laced with formaldehyde, so it keeps on the way.
/obj/structure/closet/body_bag/lost_crew/with_body

/obj/structure/closet/body_bag/lost_crew/with_body/PopulateContents()
	. = ..()
	GLOB.lost_crew_manager.create_lost_crew(src)
	var/obj/item/paper/paper = new(src)
	paper.name = "karta przyjęcia zwłok"
	paper.add_raw_text("Zwłoki członka załogi odzyskane przez Nanotrasen. Po skutecznej reanimacji i trzech minutach przeżycia dział medyczny otrzyma premię. Zwłoki zabezpieczono formaldehydem.")

/datum/supply_pack/medical/lost_crew
	name = "Odzyskana załoga"
	desc = "Zwłoki członka załogi odzyskane z wraku, w worku na zwłoki. Ożyw go, a dział medyczny dostanie premię, gdy przeżyje 3 minuty."
	cost = 2000
	access_budget = ACCESS_MEDICAL
	contains = list(/obj/structure/closet/body_bag/lost_crew/with_body)
	crate_name = "skrzynia z odzyskaną załogą"
	crate_type = /obj/structure/closet/crate/medical
