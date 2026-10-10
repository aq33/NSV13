/datum/emote/silicon
	mob_type_allowed_typecache = list(/mob/living/silicon, /mob/living/simple_animal/hostile/mining_drone)
	emote_type = EMOTE_AUDIBLE

/datum/emote/silicon/boop
	key = "boop"
	key_third_person = "boops"
	message = "robi bup."

/datum/emote/silicon/buzz
	key = "buzz"
	key_third_person = "buzzes"
	message = "brzęczy."
	message_param = "brzęczy na %t."
	sound = 'sound/machines/buzz-sigh.ogg'

/datum/emote/silicon/buzz2
	key = "buzz2"
	message = "brzęczy dwukrotnie."
	sound = 'sound/machines/buzz-two.ogg'

/datum/emote/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "dzwoni."
	sound = 'sound/machines/chime.ogg'

/datum/emote/silicon/honk
	key = "honk"
	key_third_person = "honks"
	message = "trąbi."
	vary = TRUE
	sound = 'sound/items/bikehorn.ogg'

/datum/emote/silicon/ping
	key = "ping"
	key_third_person = "pings"
	message = "brzdęka."
	message_param = "brzdęka na %t."
	sound = 'sound/machines/ping.ogg'

/datum/emote/silicon/chime
	key = "chime"
	key_third_person = "chimes"
	message = "dzwoni."
	sound = 'sound/machines/chime.ogg'

/datum/emote/silicon/sad
	key = "sad"
	message = "gra na smutnym puzonie..."
	sound = 'sound/misc/sadtrombone.ogg'

/datum/emote/silicon/warn
	key = "warn"
	message = "włącza głośny alarm!"
	sound = 'aquila/sound/machines/winerror.ogg' //AQUILA EDIT
