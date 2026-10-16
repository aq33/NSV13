// Starożytny syntezator dźwięku z BeeStation (usunięty w Bee#3576, tu wraca jako przedmiot za admin item token).
// Odtwarza dowolny wgrany plik dźwiękowy, bez listy i bez zmiany wysokości.

/obj/item/soundsynth/ancient
	name = "ancient sound synthesizer"
	desc = "A device that is able to create sounds. This one is an ancient relic and has no restrictions."
	shiftpitch = 0
	volume = 100
	sound_list = list()

/obj/item/soundsynth/examine(mob/user)
	. = ..()
	. += "<span class='info'>Alt+Click, żeby zmienić dźwięk.</span>"

/obj/item/soundsynth/ancient/examine(mob/user)
	. = ..()
	. += "<span class='info'>Ctrl+Click, żeby zmienić głośność.</span>"

/obj/item/soundsynth/ancient/pick_sound(S as sound|null)
	set category = "Object"
	set name = "Select Sound Playback"
	var/mob/user = usr
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(isnull(S))
		S = input(usr, "Wgraj plik dźwiękowy:", "Starożytny syntezator") as null|sound
	if(!S || !user.canUseTopic(src, BE_CLOSE))
		return
	selected_sound = S
	to_chat(usr, "<span class='notice'>Odtwarzany dźwięk ustawiony na: [S]!</span>")
	message_admins("[ADMIN_LOOKUPFLW(usr)] wgrał do starożytnego syntezatora dźwięk [S].")
	log_game("[key_name(usr)] loaded sound [S] into an ancient sound synthesizer")

/obj/item/soundsynth/ancient/CtrlClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return ..()
	var/new_volume = input(user, "Jaka głośność (1-100)?", "Starożytny syntezator", volume) as null|num
	if(isnull(new_volume))
		return
	volume = clamp(round(new_volume), 1, 100)

/obj/item/soundsynth/ancient/attack_self(mob/user)
	if(spam_flag + 2 SECONDS < world.timeofday)
		playsound(src, selected_sound, volume, FALSE, 0)
		spam_flag = world.timeofday
