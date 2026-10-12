/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 *		Employment Contract Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unnecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo))
				I.forceMove(src)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/filingcabinet/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper) || istype(P, /obj/item/folder) || istype(P, /obj/item/photo) || istype(P, /obj/item/documents))
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>Wkładasz [P] do [src].</span>")
		icon_state = "[initial(icon_state)]-open"
		sleep(5)
		icon_state = initial(icon_state)
		updateUsrDialog()
	else if(P.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>Zaczynasz [anchored ? "odkręcać" : "przykręcać"] [src].</span>")
		if(P.use_tool(src, user, 20, volume=50))
			to_chat(user, "<span class='notice'>[anchored ? "Odkręcasz" : "Przykręcasz"] [src].</span>")
			anchored = !anchored
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>Nie możesz włożyć [P] do [src]!</span>")
	else
		return ..()


/obj/structure/filingcabinet/ui_interact(mob/user)
	. = ..()
	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>[src] jest pusty.</span>")
		return

	var/dat = "<center><table>"
	var/i
	for(i=contents.len, i>=1, i--)
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='byond://?src=[REF(src)];retrieve=[REF(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse(HTML_SKELETON_TITLE(name, dat), "window=filingcabinet;size=350x300")

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.forceMove(loc)
			if(prob(25))
				step_rand(I)
			to_chat(user, "<span class='notice'>Wyciągasz na chybił trafił [I] z [src].</span>")
			return
	to_chat(user, "<span class='notice'>Nic nie znajdujesz w [src].</span>")

/obj/structure/filingcabinet/Topic(href, href_list)
	if(!usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
		return
	if(href_list["retrieve"])
		usr << browse(null, "window=filingcabinet") // Close the menu

		var/obj/item/P = locate(href_list["retrieve"]) in src //contents[retrieveindex]
		if(istype(P) && in_range(src, usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			icon_state = "[initial(icon_state)]-open"
			addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 5)


/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = 1

/obj/structure/filingcabinet/security/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/S = find_record("name", G.fields["name"], GLOB.data_core.security)
			if(!S)
				continue
			var/obj/item/paper/sec_record_paper = new /obj/item/paper(src)
			var/sec_record_text = "<CENTER><B>Kartoteka ochrony</B></CENTER><BR>"
			sec_record_text += "Imię: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nPłeć: [G.fields["gender"]]<BR>\nWiek: [G.fields["age"]]<BR>\nOdcisk palca: [G.fields["fingerprint"]]<BR>\nStan fizyczny: [G.fields["p_stat"]]<BR>\nStan psychiczny: [G.fields["m_stat"]]<BR>"
			sec_record_text += "<BR>\n<CENTER><B>Dane ochrony</B></CENTER><BR>\nStatus kryminalny: [S.fields["criminal"]]<BR>\n<BR>\nPrzestępstwa: [S.fields["crim"]]<BR>\nSzczegóły: [S.fields["crim_d"]]<BR>\n<BR>\nWażne uwagi:<BR>\n\t[S.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Komentarze/dziennik</B></CENTER><BR>"
			var/counter = 1
			while(S.fields["com_[counter]"])
				sec_record_text += "[S.fields["com_[counter]"]]<BR>"
				counter++
			sec_record_text += "</TT>"
			sec_record_paper.name = "paper - '[G.fields["name"]]'"
			sec_record_paper.add_raw_text(sec_record_text)
			sec_record_paper.update_appearance()
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand()
	populate()
	. = ..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/virgin = 1

/obj/structure/filingcabinet/medical/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/M = find_record("name", G.fields["name"], GLOB.data_core.medical)
			if(!M)
				continue
			var/obj/item/paper/med_record_paper = new /obj/item/paper(src)
			var/med_record_text = "<CENTER><B>Kartoteka medyczna</B></CENTER><BR>"
			med_record_text += "Imię: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nPłeć: [G.fields["gender"]]<BR>\nWiek: [G.fields["age"]]<BR>\nOdcisk palca: [G.fields["fingerprint"]]<BR>\nStan fizyczny: [G.fields["p_stat"]]<BR>\nStan psychiczny: [G.fields["m_stat"]]<BR>"
			med_record_text += "<BR>\n<CENTER><B>Dane medyczne</B></CENTER><BR>\nGrupa krwi: [M.fields["blood_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nDrobne niepełnosprawności: [M.fields["mi_dis"]]<BR>\nSzczegóły: [M.fields["mi_dis_d"]]<BR>\n<BR>\nPoważne niepełnosprawności: [M.fields["ma_dis"]]<BR>\nSzczegóły: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAlergie: [M.fields["alg"]]<BR>\nSzczegóły: [M.fields["alg_d"]]<BR>\n<BR>\nObecne choroby: [M.fields["cdi"]] (informacje o poszczególnych chorobach w sekcji dziennika/komentarzy)<BR>\nSzczegóły: [M.fields["cdi_d"]]<BR>\n<BR>\nWażne uwagi:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Komentarze/dziennik</B></CENTER><BR>"
			var/counter = 1
			while(M.fields["com_[counter]"])
				med_record_text += "[M.fields["com_[counter]"]]<BR>"
				counter++
			med_record_text += "</TT>"
			med_record_paper.add_raw_text(med_record_text)
			med_record_paper.name = "paper - '[G.fields["name"]]'"
			med_record_paper.update_appearance()
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/filingcabinet/medical/attack_hand()
	populate()
	. = ..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	..()

/*
 * Employment contract Cabinets
 */

GLOBAL_LIST_EMPTY(employmentCabinets)

/obj/structure/filingcabinet/employment
	var/cooldown = 0
	icon_state = "employmentcabinet"
	var/virgin = 1

/obj/structure/filingcabinet/employment/Initialize(mapload)
	. = ..()
	GLOB.employmentCabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employmentCabinets -= src
	return ..()

/obj/structure/filingcabinet/employment/proc/fillCurrent()
	//This proc fills the cabinet with the current crew.
	for(var/record in GLOB.data_core.locked)
		var/datum/data/record/G = record
		if(!G)
			continue
		var/datum/mind/M = G.fields["mindref"]
		if(M && ishuman(M.current))
			addFile(M.current)


/obj/structure/filingcabinet/employment/proc/addFile(mob/living/carbon/human/employee)
	new /obj/item/paper/contract/employment(src, employee)

/obj/structure/filingcabinet/employment/interact(mob/user)
	if(!cooldown)
		if(virgin)
			fillCurrent()
			virgin = 0
		cooldown = 1
		sleep(100) // prevents the devil from just instantly emptying the cabinet, ensuring an easy win.
		cooldown = 0
	else
		to_chat(user, "<span class='warning'>[src] się zacięła, daj jej kilka sekund.</span>")
	..()

//NSV13
/obj/structure/filingcabinet/documents
    name = "classified filing cabinet"

/obj/structure/filingcabinet/documents/Initialize(mapload)
    . = ..()
    new /obj/item/documents/nanotrasen(src)
