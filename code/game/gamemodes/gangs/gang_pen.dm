/*
 * Gang Boss Pens
 */
/obj/item/pen/gang
	var/cooldown
	var/last_used

/obj/item/pen/gang/Initialize(mapload)
	..()
	last_used = world.time

/obj/item/pen/gang/attack(mob/living/M, mob/user, stealth = TRUE)
	if(!istype(M))
		return
	if(!ishuman(M) || !ishuman(user) || M.stat == DEAD)
		return ..()
	var/datum/antagonist/gang/boss/L = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
	if(!L)
		return ..()
	if(!..())
		return
	if(cooldown)
		to_chat(user, "<span class='warning'>[src] potrzebuje więcej czasu na naładowanie, zanim znów go użyjesz.</span>")
		return
	if(!M.client || !M.mind)
		to_chat(user, "<span class='warning'>Gangster bez mózgu to bezużyteczny gangster!</span>")
		return
	var/datum/team/gang/gang = L.gang
	if(!add_gangster(user, gang, M.mind))
		return
	cooldown = TRUE
	icon_state = "pen_blink"
	var/cooldown_time = 600/gang.leaders.len
	addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown_time)

/obj/item/pen/gang/proc/cooldown()
	cooldown = FALSE
	icon_state = "pen"
	var/mob/M = loc
	if(istype(M))
		to_chat(M, "<span class='notice'>[icon2html(src, M)] [src][(loc == M)?(""):(" ([loc])")] cicho wibruje. Można go znów użyć.</span>")

/obj/item/pen/gang/proc/add_gangster(mob/user, datum/team/gang/gang, datum/mind/gangster_mind, check = TRUE) // Basically a wrapper to add_antag_datum.
	var/datum/antagonist/dudegang = gangster_mind.has_antag_datum(/datum/antagonist/gang)
	if(dudegang)
		if(dudegang == gang)
			to_chat(user, "<span class='danger'>Ten umysł jest już kontrolowany przez twój gang!</span>")
			return
		to_chat(user, "<span class='danger'>Ten umysł jest już kontrolowany przez kogoś innego!</span>")
		return
	if(check && HAS_TRAIT(gangster_mind.current, TRAIT_MINDSHIELD)) //Check to see if the potential gangster is implanted
		to_chat(user, "<span class='danger'>Ten umysł jest zbyt silny, by go kontrolować!</span>")
		return
	var/mob/living/carbon/human/H = gangster_mind.current // we are sure the dude's human cause it's checked in attack()
	if(istype(H.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
		to_chat(user, "<span class='danger'>Ten umysł wydaje się zbyt urojony, by odebrać fale kontroli umysłu!</span>")
		return
	H.silent = max(H.silent, 5)
	H.Knockdown(100)

	gangster_mind.add_antag_datum(/datum/antagonist/gang, gang)
	return TRUE
