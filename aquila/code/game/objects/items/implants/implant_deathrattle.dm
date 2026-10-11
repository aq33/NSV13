/// A knell rings in the heads of everyone in the group when one of them dies (BeeStation #14755)
/datum/deathrattle_group/on_user_statchange(mob/living/owner, new_stat)
	. = ..()
	if(new_stat != DEAD)
		return
	// Everyone hears the same bell
	var/knell = pick('aquila/sound/items/knell/knell1.ogg', 'aquila/sound/items/knell/knell2.ogg', 'aquila/sound/items/knell/knell3.ogg', 'aquila/sound/items/knell/knell4.ogg')
	for(var/obj/item/implant/deathrattle/implant as anything in implants)
		var/mob/living/recipient = implant.imp_in
		if(!recipient || recipient == owner)
			continue
		recipient.playsound_local(get_turf(recipient), knell, 75, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
