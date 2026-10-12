//Hivemind monitoring and powers shop

/datum/psychic_plane
	var/name = "psychic plane"
	var/datum/antagonist/hivemind/hivehost

/datum/psychic_plane/New(my_hivehost)
	. = ..()
	hivehost = my_hivehost

/datum/psychic_plane/Destroy()
	hivehost = null
	. = ..()


/datum/psychic_plane/ui_state(mob/user)
	return GLOB.always_state

/datum/psychic_plane/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PsychicPlane", "Plan psychiczny")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/psychic_plane/ui_data(mob/user)
	var/list/data = list()

	data["hives"] = list()
	for(var/datum/antagonist/hivemind/hivehosts in GLOB.hivehosts)
		var/list/hive_data = list(
			hive = hivehosts.hiveID,
			size = hivehosts.hive_size,
			charges = hivehosts.searchcharge,
			avessel_number = hivehosts.avessels.len,
			integrations = hivehosts.size_mod/5,
			type = hivehosts.descriptor,
		)
		data["hives"] += list(hive_data)



	return data

/datum/psychic_plane/ui_act(action, params)
	if(..())
		return
	if(action == "track")
		var/hivetarget = params["hiveref"]
		var/mob/living/carbon/ourhive = hivehost.owner?.current
		if(hivetarget == hivehost.hiveID)
			to_chat(ourhive, "<span class='notice'>Nie możemy namierzać samych siebie!</span>")
			return
		if(hivehost.searchcharge <= 0)
			to_chat(ourhive, "<span class='notice'>Nie mamy ładunków namierzania!</span>")
			return
		hivehost.searchcharge -= 1
		if(!do_after(ourhive,5,0,ourhive))
			to_chat(ourhive, "<span class='notice'>Nasza koncentracja została przerwana!</span>")
		else
			for(var/datum/antagonist/hivemind/hivehosts in GLOB.hivehosts)
				if(hivehosts.hiveID == hivetarget)
					var/mob/living/carbon/enemy = hivehosts.owner?.current
					if(hivehosts.owner.current.stat == DEAD) //ourhive.get_virtual_z_level() != enemy.get_virtual_z_level() ||
						to_chat(ourhive, "<span class='notice'>Nie znaleźliśmy [hivehosts.hiveID]</span>")
					else
						var/dist = get_dist(ourhive.loc,enemy.loc)
						var/dir = get_dir(ourhive.loc,enemy.loc)
						switch(dist)
							if(0 to 7)
								to_chat(ourhive,"<span class='assimilator'>Ich obecność jest tuż obok, kierunek: [dir2text(dir)]!</span>")
							if(8 to 15)
								to_chat(ourhive,"<span class='notice'>Wyczuwamy ich obecność blisko, kierunek: [dir2text(dir)]!</span>")
							if(16 to 31)
								to_chat(ourhive,"<span class='notice'>Wyczuwamy ślady w pobliżu. Kierunek: [dir2text(dir)]!</span>")
							else
								to_chat(ourhive,"<span class='notice'>Wyczuwamy słabe iskry daleko stąd. Kierunek: [dir2text(dir)]!</span>")


/datum/action/innate/psychic_plane
	name = "Psychic Plane"
	icon_icon = 'icons/mob/actions/actions_hive.dmi'
	button_icon_state = "scan"
	background_icon_state = "bg_hive"
	var/datum/psychic_plane/psychic_plane

/datum/action/innate/psychic_plane/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/psychic_plane))
		psychic_plane = our_target
	else
		CRASH("psychic_plane action created with non plane")

/datum/action/innate/psychic_plane/Activate()
	psychic_plane.ui_interact(owner)
