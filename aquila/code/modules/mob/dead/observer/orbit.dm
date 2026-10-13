// Port BeeStation #9034: ikony HUD antagonistów obok nazw w panelu Orbit.
// U nas ikony antagów leżą w icons/mob/hud.dmi razem z ikonami zawodów, w prawym górnym rogu 8x8.
/datum/asset/spritesheet/antag_hud
	name = "antag-hud"

/datum/asset/spritesheet/antag_hud/register()
	var/icon/I = icon('icons/mob/hud.dmi')
	// Get the antag hud part
	I.Crop(24, 24, 32, 32)
	// Scale it up
	I.Scale(16, 16)
	InsertAll("antag-hud", I)
	..()
