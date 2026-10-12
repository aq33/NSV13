/datum/action/changeling/teratoma
	name = "Birth Teratoma"
	desc = "Our form divides, creating an egg that will soon hatch into a living tumor, fixated on causing mayhem"
	helptext = "Guz nie będzie lojalny wobec nas ani naszej sprawy. Kosztuje dwa wchłonięcia."
	button_icon_state = "spread_infestation"
	chemical_cost = 60
	dna_cost = 2
	req_absorbs = 3

//Reskinned monkey - teratoma, will burst out of the host, with the objective to cause chaos.
/datum/action/changeling/teratoma/sting_action(mob/user)
	..()
	if(create_teratoma(user))
		var/mob/living/U = user
		playsound(user.loc, 'sound/effects/blobattack.ogg', 50, 1)
		U.spawn_gibs()
		user.visible_message("<span class='danger'>Z klatki piersiowej [user] wyrywa się coś okropnego!</span>", \
								"<span class='danger'>Z twojej klatki piersiowej wyrywa się żywa teratoma!</span>", \
								"<span class='hear'>Słyszysz rozdzieranie ciała!</span>", COMBAT_MESSAGE_RANGE)
	return FALSE		//create_teratoma() handles the chemicals anyway so there is no reason to take them again

/datum/action/changeling/teratoma/proc/create_teratoma(mob/user)
	var/datum/antagonist/changeling/c = user.mind.has_antag_datum(/datum/antagonist/changeling)
	c.chem_charges -= chemical_cost				//I'm taking your chemicals hostage!
	var/turf/A = get_turf(user)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Chcesz zagrać jako żywa teratoma?", ROLE_TERATOMA, null, 7.5 SECONDS) //players must answer rapidly
	if(!LAZYLEN(candidates)) //if we got at least one candidate, they're teratoma now
		to_chat(usr, "<span class='warning'>Nie udaje ci się stworzyć guza. Może spróbuj później?</span>")
		c.chem_charges += chemical_cost				//If it fails we want to refund the chemicals
		return FALSE
	var/mob/living/carbon/monkey/tumor/T = new /mob/living/carbon/monkey/tumor(A)
	var/mob/dead/observer/C = pick(candidates)
	T.key = C.key
	var/datum/antagonist/teratoma/D = new
	T.mind.add_antag_datum(D)
	to_chat(T, "<span class='notice'>Wyrywasz się z klatki piersiowej [user]!</span>")
	SEND_SOUND(T, sound('sound/effects/blobattack.ogg'))
	return TRUE
