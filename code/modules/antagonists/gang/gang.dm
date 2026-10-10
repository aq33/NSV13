/datum/antagonist/gang
	name = "Gangster"
	roundend_category = "gangsterzy"
	can_coexist_with_others = FALSE
	banning_key = ROLE_GANG
	antagpanel_category = "Gang"
	var/hud_type = "gangster"
	var/message_name = "Gangster"
	var/datum/team/gang/gang

/datum/antagonist/gang/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_gang_icons_added(M)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_gang_icons_removed(M)

/datum/antagonist/gang/get_team()
	return gang

/datum/antagonist/gang/greet()
	gang.greet_gangster(owner)
	owner.current.client?.tgui_panel?.give_antagonist_popup("Gangster",
		"Rządzisz na ulicach - pomóż swojemu gangowi przejąć stację.")

/datum/antagonist/gang/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] wygląda, jakby właśnie przypomniał sobie, komu naprawdę jest wierny!</span>", null, null, null, owner.current)
		to_chat(owner, "<span class='userdanger'>Nie jesteś już gangsterem!</span>")

/datum/antagonist/gang/on_gain()
	if(!gang)
		create_team()
	..()
	handle_clown_mutation(owner.current, "Dzięki szkoleniu przezwyciężasz swoją klaunią naturę i możesz używać broni, nie raniąc samego siebie.")
	add_to_gang()

/datum/antagonist/gang/on_removal()
	handle_clown_mutation(owner.current, removing=FALSE)
	remove_from_gang()
	..()

/datum/antagonist/gang/create_team(team)
	if(!gang) // add_antag_datum calls create_team, so we need to avoid generating two gangs in that case
		if(team)
			gang = team
			return
		var/datum/team/gang/gangteam = pick_n_take(GLOB.possible_gangs)
		if(gangteam)
			gang = new gangteam

/datum/antagonist/gang/proc/equip_gang() // Bosses get equipped with their tools
	return

/datum/antagonist/gang/proc/update_gang_icons_added(mob/living/M)
	var/datum/atom_hud/antag/gang/ganghud = GLOB.huds[gang.hud_entry_num]
	if(!ganghud)
		ganghud = new/datum/atom_hud/antag/gang()
		gang.hud_entry_num = GLOB.huds.len+1 // this is the index the gang hud will be added at
		GLOB.huds += ganghud
	ganghud.color = gang.color
	ganghud.join_hud(M)
	set_antag_hud(M,hud_type)

/datum/antagonist/gang/proc/update_gang_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/gang/ganghud = GLOB.huds[gang.hud_entry_num]
	if(ganghud)
		ganghud.leave_hud(M)
		set_antag_hud(M, null)

/datum/antagonist/gang/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	var/mob/living/carbon/human/H = candidate
	if(!istype(H)) //Can't nonhumans
		return FALSE
	return TRUE

/datum/antagonist/gang/proc/promote() // Bump up to boss
	var/datum/team/gang/old_gang = gang
	var/datum/mind/old_owner = owner
	owner.remove_antag_datum(/datum/antagonist/gang)
	var/datum/antagonist/gang/boss/lieutenant/new_boss = new
	new_boss.silent = TRUE
	old_owner.add_antag_datum(new_boss,old_gang)
	new_boss.silent = FALSE
	log_game("[key_name(old_owner)] has been promoted to Lieutenant in the [old_gang.name] Gang")
	to_chat(old_owner, "<FONT size=3 color=red><B>Awansujesz na porucznika!</B></FONT>")


// Admin commands
/datum/antagonist/gang/get_admin_commands()
	. = ..()
	.["Promote"] = CALLBACK(src,PROC_REF(admin_promote))
	.["Set Influence"] = CALLBACK(src, PROC_REF(admin_adjust_influence))

/datum/antagonist/gang/admin_add(datum/mind/new_owner,mob/admin)
	var/new_or_existing = input(admin, "Which gang do you want to be assigned to the user?", "Gangs") as null|anything in list("New","Existing")
	if(isnull(new_or_existing))
		return
	else if(new_or_existing == "New")
		var/newgang = input(admin, "Select a gang, or select random to pick a random one.", "New gang") as null|anything in GLOB.possible_gangs + "Random"
		if(isnull(newgang))
			return
		else if(newgang == "Random")
			var/datum/team/gang/G = pick_n_take(GLOB.possible_gangs)
			gang = new G
		else
			GLOB.possible_gangs -= newgang
			gang = new newgang
	else
		if(!GLOB.gangs.len) // no gangs exist
			to_chat(admin, "<span class='danger'>No gangs exist, please create a new one instead.</span>")
			return
		var/existinggang = input(admin, "Select a gang, or select random to pick a random one.", "Existing gang") as null|anything in GLOB.gangs + "Random"
		if(isnull(existinggang))
			return
		else if(existinggang == "Random")
			gang = pick(GLOB.gangs)
		else
			gang = existinggang
	..()
	return TRUE

/datum/antagonist/gang/proc/admin_promote(mob/admin)
	message_admins("[key_name_admin(admin)] has promoted [owner] to gang boss.")
	log_admin("[key_name(admin)] has promoted [owner] to boss.")
	promote()

/datum/antagonist/gang/proc/admin_adjust_influence()
	var/inf = input("Influence for [gang.name]","Gang influence", gang.influence) as null | num
	if(!isnull(inf))
		gang.influence = inf
		message_admins("[key_name_admin(usr)] changed [gang.name]'s influence to [inf].")
		log_admin("[key_name(usr)] changed [gang.name]'s influence to [inf].")

/datum/antagonist/gang/proc/add_to_gang()
	gang.add_member(owner)
	owner.current.log_message("<font color='red'>Has been converted to the [gang.name] gang!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/gang/proc/remove_from_gang()
	gang.remove_member(owner)
	owner.current.log_message("<font color='red'>Has been deconverted from the [gang.name] gang!</font>", INDIVIDUAL_ATTACK_LOG)

// Boss type. Those can use gang tools to buy items for their gang, in particular the Dominator, used to win the gamemode, along with more gang tools to promote fellow gangsters to boss status.
/datum/antagonist/gang/boss
	name = "Szef gangu"
	hud_type = "gang_boss"
	message_name = "Leader"

/datum/antagonist/gang/boss/on_gain()
	..()
	if(gang)
		gang.leaders += owner

/datum/antagonist/gang/boss/on_removal()
	if(gang)
		gang.leaders -= owner
	..()

/datum/antagonist/gang/boss/antag_listing_name()
	return ..() + "(Boss)"

/datum/antagonist/gang/boss/equip_gang(gangtool = TRUE, pen = TRUE, spraycan = TRUE, hud = TRUE) // usually has to be called separately
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET,
		"hands" = ITEM_SLOT_HANDS
	)

	if(gangtool)
		var/obj/item/device/gangtool/G = new()
		var/where = H.equip_in_one_of_slots(G, slots)
		if (!where)
			to_chat(H, "Twoi dobroczyńcy z Syndykatu niestety nie zdołali zdobyć dla ciebie Gangtoola.")
		else
			G.register_device(H)
			to_chat(H, "<b>Gangtool</b> (miejsce: [where]) pozwoli ci kupować broń i sprzęt, wysyłać wiadomości do gangu i odwoływać prom ewakuacyjny z dowolnego miejsca na stacji.")
			to_chat(H, "Jako szef gangu możesz też awansować członków na <b>poruczników</b>. W przeciwieństwie do zwykłych gangsterów porucznicy nie mogą zostać odwróceni i potrafią używać długopisów werbunkowych i gangtooli.")

	if(pen)
		var/obj/item/pen/gang/T = new()
		var/where2 = H.equip_in_one_of_slots(T, slots)
		if (!where2)
			to_chat(H, "Twoi dobroczyńcy z Syndykatu niestety nie zdołali zdobyć dla ciebie długopisu werbunkowego na start.")
		else
			to_chat(H, "<b>Długopis werbunkowy</b> (miejsce: [where2]) pomoże ci rozkręcić gang. Dźgaj nim niczego niepodejrzewających członków załogi, żeby ich zwerbować.")

	if(spraycan)
		var/obj/item/toy/crayon/spraycan/gang/SC = new(null,gang)
		var/where3 = H.equip_in_one_of_slots(SC, slots)
		if (!where3)
			to_chat(H, "Twoi dobroczyńcy z Syndykatu niestety nie zdołali zdobyć dla ciebie farby do oznaczania terenu na start.")
		else
			to_chat(H, "<b>Farbą do oznaczania terenu</b> (miejsce: [where3]) możesz zajmować obszary stacji dla gangu. Im więcej terenu kontroluje gang, tym więcej wpływów zdobywasz. Mogą jej używać wszyscy gangsterzy, więc rozdawaj ją, żeby szybciej rosły wpływy.")

	if(hud)
		var/obj/item/clothing/glasses/hud/security/chameleon/C = new(null,gang)
		var/where4 = H.equip_in_one_of_slots(C, slots)
		if (!where4)
			to_chat(H, "Twoi dobroczyńcy z Syndykatu niestety nie zdołali zdobyć dla ciebie kameleonowego HUD-a ochrony.")
		else
			to_chat(H, "<b>Kameleonowy HUD ochrony</b> (miejsce: [where4]) pokaże ci, kto ma implant ochrony umysłu i nie da się go zwerbować.")

// Admin commands for bosses
/datum/antagonist/gang/boss/admin_add(datum/mind/new_owner,mob/admin)
	if(!new_owner.has_antag_datum(parent_type))
		..()
		to_chat(new_owner.current, "<span class='userdanger'>Należysz teraz do przywództwa gangu [gang.name]!</span>")
		return
	promote()
	message_admins("[key_name_admin(admin)] has made [new_owner.current] a boss of the [gang.name] gang.")
	log_admin("[key_name(admin)] has made [new_owner.current] a boss of the [gang.name] gang.")
	to_chat(new_owner.current, "<span class='userdanger'>Należysz teraz do przywództwa gangu [gang.name]!</span>")

/datum/antagonist/gang/boss/get_admin_commands()
	. = ..()
	. -= "Promote"
	.["Take gangtool"] = CALLBACK(src,PROC_REF(admin_take_gangtool))
	.["Give gangtool"] = CALLBACK(src,PROC_REF(admin_give_gangtool))
	.["Demote"] = CALLBACK(src,PROC_REF(admin_demote))

/datum/antagonist/gang/boss/proc/demote()
	var/old_gang = gang
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/gang/boss)
	var/datum/antagonist/gang/new_gangster = new /datum/antagonist/gang()
	new_gangster.silent = TRUE
	old_owner.add_antag_datum(new_gangster,old_gang)
	new_gangster.silent = FALSE
	log_game("[key_name(old_owner)] has been demoted to Gangster in the [gang.name] Gang")
	to_chat(old_owner, "<span class='userdanger'>Gang zawiódł się na twoich cechach przywódczych! Jesteś teraz zwykłym gangsterem!</span>")

/datum/antagonist/gang/boss/proc/admin_take_gangtool(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/device/gangtool/gangtool = locate() in L
	if (!gangtool)
		to_chat(admin, "<span class='danger'>Deleting gangtool failed!</span>")
		return
	qdel(gangtool)

/datum/antagonist/gang/boss/proc/admin_give_gangtool(mob/admin)
	equip_gang(TRUE, FALSE, FALSE, FALSE)

/datum/antagonist/gang/boss/proc/admin_demote(datum/mind/target,mob/user)
	message_admins("[key_name_admin(user)] has demoted [owner.current] from gang boss.")
	log_admin("[key_name(user)] has demoted [owner.current] from gang boss.")
	admin_take_gangtool(user)
	demote()


/datum/antagonist/gang/boss/lieutenant
	name = "Porucznik gangu"
	message_name = "Lieutenant"

#define INFLUENCE_SWAG 2
#define INFLUENCE_TERRITORY 0
#define INFLUENCE_BASE 20

#define MAXIMUM_RECALLS 1
#define INFLUENCE_INTERVAL 1800
// Gang team datum. This handles the gang itself.
/datum/team/gang
	name = "Gang"
	member_name = "gangster"
	var/hud_entry_num
	var/list/leaders = list() // bosses
	var/max_leaders = MAX_LEADERS_GANG
	var/list/territories = list() // territories owned by the gang.
	var/list/lost_territories = list() // territories lost by the gang.
	var/list/new_territories = list() // territories captured by the gang.
	var/list/gangtools = list()
	var/color
	var/winner = FALSE //winner winner chicken dinner
	var/influence = 0 // influence of the gang, based on how many territories they own. Can be used to buy weapons and tools from a gang uplink.
	var/victory_points = 0 // influence earned throughout the round, used at eotg to calculate most efficient gang
	var/next_point_time
	var/recalls = MAXIMUM_RECALLS // Once this reaches 0, this gang cannot force recall the shuttle with their gangtool anymore
	var/obj/item/clothing/head/hat
	var/obj/item/clothing/under/outfit
	var/obj/item/clothing/suit/suit

/datum/team/gang/New(starting_members)
	. = ..()
	GLOB.gangs += src
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/groveboss in starting_members)
				leaders += groveboss
				var/datum/antagonist/gang/boss/gb = new
				groveboss.add_antag_datum(gb, src)
				gb.equip_gang()

		else
			var/datum/mind/CJ = starting_members
			if(istype(CJ))
				leaders += CJ
				var/datum/antagonist/gang/boss/bossdatum = new
				CJ.add_antag_datum(bossdatum, src)
				bossdatum.equip_gang()
	next_point_time = world.time + INFLUENCE_INTERVAL
	addtimer(CALLBACK(src, PROC_REF(handle_territories)), INFLUENCE_INTERVAL)

/datum/team/gang/Destroy()
	GLOB.gangs -= src
	..()

/datum/team/gang/roundend_report()
	var/list/report = list()
	report += "<span class='header'>[name]:</span>"
	if(winner)
		report += "<span class='greentext'>Gang [name] odniósł sukces!</span>"
	else
		report += "<span class='redtext'>Gang [name] poniósł porażkę!</span>"

	report += "Szefowie gangu [name]:"
	report += printplayerlist(leaders)
	report += "Członkowie gangu [name]:"
	report += printplayerlist(members-leaders)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/gang/proc/greet_gangster(datum/mind/gangster)//THIS NEEDS REVISION
	to_chat(gangster, "<FONT size=3 color=red><B>Jesteś teraz członkiem gangu [name]!</B></FONT>")
	to_chat(gangster, "<font color='red'>Pomóż szefom przejąć stację, zajmując teren <b>specjalnymi farbami</b>, które mogą dać tylko oni. Po prostu maluj w niezajętych miejscach stacji.</font>")
	to_chat(gangster, "<font color='red'>Twoim celem jest przejęcie jak największego terenu i poszerzenie wpływów gangu.</font>")
	to_chat(gangster, "<font color='red'>Kumpli rozpoznasz po <b>dużej, jasnej <font color='[color]'>ikonie</font> \[G\]</b>.</font>")
	gangster.store_memory("Jesteś członkiem gangu [name]!")

/datum/team/gang/proc/handle_territories()	//influence is counted here
	next_point_time = world.time + INFLUENCE_INTERVAL
	if(!leaders.len)
		return
	var/added_names = ""
	var/lost_names = ""

	//Re-add territories that were reclaimed, so if they got tagged over, they can still earn income if they tag it back before the next status report
	var/list/reclaimed_territories = new_territories & lost_territories
	territories |= reclaimed_territories
	new_territories -= reclaimed_territories
	lost_territories -= reclaimed_territories

	//Process lost territories
	for(var/area in lost_territories)
		if(lost_names != "")
			lost_names += ", "
		lost_names += "[lost_territories[area]]"
		territories -= area

	//Calculate and report influence growth

	//Process new territories
	for(var/area in new_territories)
		if(added_names != "")
			added_names += ", "
		added_names += "[new_territories[area]]"
		territories += area

	//Report territory changes
	var/message = "<b>Raport stanu gangu [src]:</b>.<BR>*---------*<BR>"
	message += "<b>[new_territories.len] nowe tereny:</b><br><i>[added_names]</i><br>"
	message += "<b>[lost_territories.len] utracone tereny:</b><br><i>[lost_names]</i><br>"
	//Clear the lists
	new_territories = list()
	lost_territories = list()
	var/total_territories = total_claimable_territories()
	var/control = round((territories.len/total_territories)*100, 1)
	var/uniformed = count_gang_swag()
	message += "Twój gang kontroluje teraz <b>[control]%</b> stacji.<BR>*---------*<BR>"

	var/new_influence = update_influence()
	influence =	min(999,influence+new_influence)
	victory_points += new_influence
	if(new_influence > 0)
		message += "Wpływy gangu wzrosły o [new_influence] za obronę [territories.len] terenów i [uniformed] szpanu.<BR>"
	message += "Twój gang ma teraz <b>[influence] wpływów</b>.<BR>"

	message_gangtools(message)
	addtimer(CALLBACK(src, PROC_REF(handle_territories)), INFLUENCE_INTERVAL)


/datum/team/gang/proc/total_claimable_territories()
	var/list/valid_territories = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION)) //First, collect all area types on the station zlevel
		for(var/ar in SSmapping.areas_in_z["[z]"])
			var/area/A = ar
			if(!(A.type in valid_territories) && A.area_flags & VALID_TERRITORY)
				valid_territories |= A.type
	return valid_territories.len

/datum/team/gang/proc/update_influence()
	return min(999,influence + INFLUENCE_BASE + (count_gang_swag()) + LAZYLEN(territories) * INFLUENCE_TERRITORY)

/datum/team/gang/proc/count_gang_swag()
	//Count swag on gangsters
	var/swag = 0
	for(var/datum/mind/gangmind in members)
		if(ishuman(gangmind.current))
			swag+=check_gangster_swag(gangmind.current)
	return swag

/datum/team/gang/proc/check_gangster_swag(var/mob/living/carbon/human/gangster)
	//Gangster must be alive and on station
	var/swag = 1
	if((gangster.stat == DEAD) || !(is_station_level(gangster.z)))
		return FALSE
	if (gangster.w_uniform?.type == outfit)
		swag *= INFLUENCE_SWAG
	if (gangster.wear_suit?.type == suit)
		swag *= INFLUENCE_SWAG
	if (gangster.head?.type == hat)
		swag *= INFLUENCE_SWAG
	return swag

/datum/team/gang/proc/adjust_influence(value)
	influence = max(0, influence + value)

/datum/team/gang/proc/message_gangtools(message)
	if(!gangtools.len || !message)
		return
	for(var/i in gangtools)
		var/obj/item/device/gangtool/tool = i
		var/mob/living/mob = get(tool.loc, /mob/living)
		if(mob && mob.mind && mob.stat == CONSCIOUS)
			var/datum/antagonist/gang/gangster = mob.mind.has_antag_datum(/datum/antagonist/gang)
			if(gangster.gang == src)
				to_chat(mob, "<span class='warning'>[icon2html(tool, mob)] [message]</span>")
				playsound(mob.loc, 'sound/machines/twobeep.ogg', 50, 1)
			return

#undef MAXIMUM_RECALLS
#undef INFLUENCE_INTERVAL
#undef INFLUENCE_SWAG
#undef INFLUENCE_TERRITORY
#undef INFLUENCE_BASE
