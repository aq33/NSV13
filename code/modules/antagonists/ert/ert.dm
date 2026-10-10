//Both ERT and DS are handled by the same datums since they mostly differ in equipment in objective.
/datum/team/ert
	name = "Emergency Response Team"
	var/datum/objective/mission //main mission
	var/ert_frequency

/datum/team/ert/New(starting_members)
	. = ..()
	ert_frequency = get_free_team_frequency("cent")

/datum/antagonist/ert
	name = "Oficer szybkiego reagowania"
	var/datum/team/ert/ert_team
	var/leader = FALSE
	var/datum/outfit/outfit = /datum/outfit/ert/security
	var/datum/outfit/plasmaman_outfit = /datum/outfit/plasmaman/ert
	var/role = JOB_NAME_SECURITYOFFICER
	var/list/name_source
	var/random_names = TRUE
	can_elimination_hijack = ELIMINATION_PREVENT
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	count_against_dynamic_roll_chance = FALSE
	banning_key = ROLE_ERT

/datum/antagonist/ert/on_gain()
	if(random_names)
		update_name()
	forge_objectives()
	equipERT()
	owner.store_memory("Wspólna częstotliwość radiolatarni twojej drużyny to [ert_team.ert_frequency].")
	. = ..()

/datum/antagonist/ert/get_team()
	return ert_team

/datum/antagonist/ert/New()
	. = ..()
	name_source = GLOB.last_names_male

/datum/antagonist/ert/proc/update_name()
	owner.current.fully_replace_character_name(owner.current.real_name,"[role] [pick(name_source)]")

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	name_source = GLOB.commando_names

/datum/antagonist/ert/clown/New()
	. = ..()
	name_source = GLOB.clown_names

/datum/antagonist/ert/deathsquad/apply_innate_effects(mob/living/mob_override)
	ADD_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

/datum/antagonist/ert/deathsquad/remove_innate_effects(mob/living/mob_override)
	REMOVE_TRAIT(owner, TRAIT_DISK_VERIFIER, DEATHSQUAD_TRAIT)

/datum/antagonist/ert/security // kinda handled by the base template but here for completion

/datum/antagonist/ert/security/red
	outfit = /datum/outfit/ert/security/alert

/datum/antagonist/ert/engineer
	role = "Engineer"
	outfit = /datum/outfit/ert/engineer

/datum/antagonist/ert/engineer/red
	outfit = /datum/outfit/ert/engineer/alert

/datum/antagonist/ert/medic
	role = JOB_CENTCOM_MEDICAL_DOCTOR
	outfit = /datum/outfit/ert/medic

/datum/antagonist/ert/medic/red
	outfit = /datum/outfit/ert/medic/alert

/datum/antagonist/ert/commander
	role = "Commander"
	outfit = /datum/outfit/ert/commander

/datum/antagonist/ert/commander/red
	outfit = /datum/outfit/ert/commander/alert

/datum/antagonist/ert/deathsquad
	name = "Żołnierz szwadronu śmierci"
	outfit = /datum/outfit/death_commando
	role = "Trooper"
	plasmaman_outfit = /datum/outfit/plasmaman/death_commando

/datum/antagonist/ert/medic/inquisitor
	outfit = /datum/outfit/ert/medic/inquisitor

/datum/antagonist/ert/medic/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/security/inquisitor
	outfit = /datum/outfit/ert/security/inquisitor

/datum/antagonist/ert/security/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/chaplain
	role = JOB_NAME_CHAPLAIN
	outfit = /datum/outfit/ert/chaplain

/datum/antagonist/ert/chaplain/inquisitor
	outfit = /datum/outfit/ert/chaplain/inquisitor

/datum/antagonist/ert/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/commander/inquisitor
	outfit = /datum/outfit/ert/commander/inquisitor

/datum/antagonist/ert/commander/inquisitor/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/antagonist/ert/janitor
	role = JOB_NAME_JANITOR
	outfit = /datum/outfit/ert/janitor

/datum/antagonist/ert/janitor/heavy
	role = "Woźny do zadań specjalnych"
	outfit = /datum/outfit/ert/janitor/heavy

/datum/antagonist/ert/kudzu
	role = "Pogromca chwastów"
	outfit = /datum/outfit/ert/kudzu

/datum/antagonist/ert/deathsquad/leader
	name = "Oficer szwadronu śmierci"
	outfit = /datum/outfit/death_commando/officer
	role = "Officer"

/datum/antagonist/ert/intern
	name = "Stażysta Centrali"
	outfit = /datum/outfit/centcom_intern
	random_names = FALSE
	role = "Intern"
	plasmaman_outfit = /datum/outfit/plasmaman/intern

/datum/antagonist/ert/intern/leader
	name = "Starszy stażysta Centrali"
	outfit = /datum/outfit/centcom_intern/leader
	role = "Starszy stażysta"

/datum/antagonist/ert/doomguy
	name = "Juggernaut"
	outfit = /datum/outfit/death_commando/doomguy
	random_names = FALSE
	role = "Juggernaut"

/datum/antagonist/ert/clown
	name = "Komediowy oficer reagowania"
	outfit = /datum/outfit/centcom_clown
	role = "Prankster"
	plasmaman_outfit = /datum/outfit/plasmaman/honk

/datum/antagonist/ert/clown/honk
	name = "Żołnierz oddziału HONK"
	outfit = /datum/outfit/centcom_clown/honk_squad
	role = "HONKER"
	plasmaman_outfit = /datum/outfit/plasmaman/honk_squad

/datum/antagonist/ert/create_team(datum/team/ert/new_team)
	if(istype(new_team))
		ert_team = new_team

/datum/antagonist/ert/proc/forge_objectives()
	if(ert_team)
		objectives |= ert_team.objectives

/datum/antagonist/ert/proc/equipERT()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	if(isplasmaman(H))
		H.equipOutfit(plasmaman_outfit)
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
	H.equipOutfit(outfit)
	//Set the suits frequency
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(I)
		var/datum/component/tracking_beacon/beacon = I.GetComponent(/datum/component/tracking_beacon)
		if(beacon)
			beacon.set_frequency(ert_team.ert_frequency)


/datum/antagonist/ert/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>Twoja rola: [name].</font></B>")

	var/missiondesc = "Wydział Ochrony Nanotrasen wysyła twój oddział na misję na [station_name()]."
	if(leader) //If Squad Leader
		missiondesc += " Prowadź oddział tak, by misja została wykonana. Wejdź na prom, gdy drużyna będzie gotowa."
	else
		missiondesc += " Wykonuj rozkazy dowódcy oddziału."

		missiondesc += " W miarę możliwości unikaj ofiar wśród cywili."

	missiondesc += "<BR><B>Twoja misja</B>: [ert_team.mission.explanation_text]"
	missiondesc += "<BR><b>Wspólna częstotliwość namierzania</b>: <i>[ert_team.ert_frequency]</i>"

	to_chat(owner,missiondesc)

/datum/antagonist/ert/deathsquad/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>Twoja rola: [name].</font></B>")

	var/missiondesc = "Wydział Ochrony Nanotrasen wysyła twój oddział na misję na [station_name()]."
	if(leader) //If Squad Leader
		missiondesc += " Prowadź oddział tak, by misja została wykonana. Wejdź na prom, gdy drużyna będzie gotowa."
	else
		missiondesc += " Wykonuj rozkazy dowódcy oddziału."

	missiondesc += "<BR><B>Twoja misja</B>: [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/doomguy/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>Jesteś Juggernautem, najnowszym z biologicznie ulepszonych superżołnierzy Nanotrasen.</font></B>")

	var/missiondesc = "Jeden z najwyższych rangą urzędników Nanotrasen wysyła cię na misję na [station_name()]."
	if(leader) //If Squad Leader
		missiondesc += " Sprawdź sprzęt i towarzyszy (jeśli ich masz) i wejdź na prom tranzytowy, gdy będziesz gotowy."
	else
		missiondesc += " Rozrywaj i rozdzieraj."

	missiondesc += "<BR><B>Twoja misja</B>: [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)

/datum/antagonist/ert/clown/greet()
	if(!ert_team)
		return

	to_chat(owner, "<B><font size=3 color=red>Twoja rola: [name].</font></B>")

	var/missiondesc = "Wydział Komedii Nanotrasen wysyła twój oddział na misję na [station_name()]."
	if(leader) //If Squad Leader
		missiondesc += " Jesteś tu najgorszym klaunem. Dlatego udało ci się na tyle długo nie przewracać admirała, że dostałeś dowództwo. Powodzenia, honk!"
	else
		missiondesc += " Wykonuj rozkazy dowódcy oddziału albo je ignoruj, jeśli tak będzie zabawniej."

		missiondesc += " Przewróć na skórce jak najwięcej cywili."

	missiondesc += "<BR><B>Twoja misja</B>: [ert_team.mission.explanation_text]"
	to_chat(owner,missiondesc)
