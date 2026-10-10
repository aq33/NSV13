/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Costs 15 chemicals."
	helptext = "Natychmiast usuwa kajdany z nóg i parzy każdego, kto nas trzyma. Po chwili niszczy kajdanki i szafki."
	button_icon_state = "biodegrade"
	chemical_cost = 15
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	. = FALSE

	if(!user.restrained() && isopenturf(user.loc) && !user.legcuffed && !user.pulledby)
		to_chat(user, "<span class='warning'>Już jesteśmy wolni!</span>")
		return

	if(user.legcuffed)
		qdel(user.legcuffed)
		. = TRUE

	if(user.pulledby)
		var/mob/living/target = user.pulledby
		to_chat(user, "<span class='changeling'>Wydzielamy z porów kwaśny roztwór na [user.pulledby].</span>")
		to_chat(target, "<span class='userdanger'>Na twoją dłoń wylewa się piekąca grudka kwasu!</span>")
		target.Paralyze(20)
		target.apply_damage(5, BURN, pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		target.emote("scream")
		target.stop_pulling()
		. = TRUE

	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(istype(O))
			to_chat(user, "<span class='warning'>Wymiotujemy kwaśnym szlamem na nasze więzy!</span>")
			addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), user, O), 30)
			. = TRUE

	if(user.wear_suit && user.wear_suit.breakouttime)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(istype(S))
			to_chat(user, "<span class='warning'>Wymiotujemy kwaśnym szlamem na nasz kaftan bezpieczeństwa!</span>")
			addtimer(CALLBACK(src, PROC_REF(dissolve_straightjacket), user, S), 30)
			. = TRUE


	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/C = user.loc
		if(istype(C))
			C.visible_message("<span class='warning'>Zawiasy [C] nagle zaczynają się topić i spływać!</span>")
			to_chat(user, "<span class='warning'>Wymiotujemy kwaśną mazią na wnętrze [C]!</span>")
			addtimer(CALLBACK(src, PROC_REF(open_closet), user, C), 70)
			. = TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon))
		var/obj/structure/spider/cocoon/C = user.loc
		if(istype(C))
			C.visible_message("<span class='warning'>[src] porusza się i zaczyna rozpadać!</span>")
			to_chat(user, "<span class='warning'>Wydzielamy przez skórę kwaśne enzymy i zaczynamy rozpuszczać nasz kokon...</span>")
			addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, C), 25) //Very short because it's just webs
			. = TRUE
	..()

/datum/action/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.visible_message("<span class='warning'>[O] rozpuszcza się w kałużę skwierczącej mazi.</span>")
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/S)
	if(S && user.wear_suit == S)
		user.visible_message("<span class='warning'>[S] rozpuszcza się w kałużę skwierczącej mazi.</span>")
		new /obj/effect/decal/cleanable/greenglow(S.drop_location())
		qdel(S)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message("<span class='warning'>Drzwi [C] pękają i się otwierają!</span>")
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, "<span class='warning'>Otwieramy pojemnik, który nas więził!</span>")

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/C)
	if(C && user.loc == C)
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, "<span class='warning'>Rozpuszczamy kokon!</span>")
