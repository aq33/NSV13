/// Hard reset of tgui windows for a client, i can't believe nobody added this. It fixes a rare bug with disappearing tgui windows and forcing you to restart the client to fix it
/client/verb/fixtgui()
//	set name = "Kill TGUI"
//	set desc = "Fixes TGUI by forcing all existing windows to close"
	set name = "Zabij TGUI"
	set category = "OOC"
	set desc = "Naprawia TGUI poprzez wymuszenie zamknięcia wszystkich okienek w kliencie Dreamseeker"

	if(!mob)
		return

	for(var/datum/tgui/ui in mob.tgui_open_uis)
		if(!QDELETED(ui))
			ui.close()

//	to_chat(mob, "<span class='warning'>All tgUI windows have been forcefully closed. Please try re-opening them.</span>")
	to_chat(mob, "<span class='warning'>Wszystkie okienka TGUI zostały zamknięte.</span>")
