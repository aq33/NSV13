/* This file was unticked before so I just commented this out
/obj/item/toy/plush/random
	name = "\improper Random Plush"
	icon_state = "debug"
	desc = "Oh no! What have you done! (if you see this, contact an upper being as soon as possible)."

/obj/item/toy/plush/random/Initialize()
	var/plush_type = pick(subtypesof(/obj/item/toy/plush/) - /obj/item/toy/plush/random/)
	new plush_type(loc)
	return INITIALIZE_HINT_QDEL
*/
/obj/item/toy/plush/hfighter
	name = "heavy fighter plush"
	desc = "Uroczy pluszak w kształcie ciężkiego myśliwca Su-410 Scimitar."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "heavyfighter"
	attack_verb = list("bombarduje", "trąca", "taranuje", "torpeduje")
	squeak_override = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg'=1)

/obj/item/toy/plush/lfighter
	name = "light fighter plush"
	desc = "Uroczy pluszak w kształcie lekkiego myśliwca Su-818 Rapier."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "lightfighter"
	attack_verb = list("trąca", "taranuje", "ostrzeliwuje rakietą")
	squeak_override = list('nsv13/sound/effects/fighters/autocannon.ogg'=1)

/obj/item/toy/plush/lfighter/synlfighter
	name = "Syndicate light fighter plush"
	desc = "An adorable stuffed toy shaped like a Su-818 Rapier light fighter with Syndicate livery."
	icon_state = "synlightfighter"

/obj/item/toy/plush/transport
	name = "utility craft plush"
	desc = "Uroczy pluszak w kształcie statku użytkowego Su-437 Sabre."
	icon = 'nsv13/icons/obj/custom_plushes.dmi'
	icon_state = "transport"
	attack_verb = list("trąca", "taranuje")
	squeak_override = list('nsv13/sound/effects/fighters/warmup.ogg'=1)

/obj/item/toy/plush/transport/mining
	name = "mining craft plush"
	desc = "Uroczy pluszak w kształcie statku górniczego Su-437 Sabre."
	icon_state = "mining"
