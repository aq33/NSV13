/datum/emote/brain
	mob_type_allowed_typecache = list(/mob/living/brain)
	mob_type_blacklist_typecache = list()
	emote_type = EMOTE_AUDIBLE

/datum/emote/brain/can_run_emote(mob/user, status_check = TRUE, intentional)
	. = ..()
	var/mob/living/brain/B = user
	if(!istype(B) || (!(B.container && istype(B.container, /obj/item/mmi))))
		return FALSE

/datum/emote/brain/alarm
	key = "alarm"
	message = "włącza alarm."

/datum/emote/brain/alert
	key = "alert"
	message = "wydaje niespokojny dźwięk."

/datum/emote/brain/flash
	key = "flash"
	message = "mruga światełkami."
	emote_type = EMOTE_VISIBLE

/datum/emote/brain/notice
	key = "notice"
	message = "wydaje głośny ton."

/datum/emote/brain/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "gwiżdże."
