/atom/movable/screen/alert/bitrunning
	name = "Generic Bitrunning Alert"
	icon_state = "template"
	timeout = 10 SECONDS

/atom/movable/screen/alert/bitrunning/qserver_domain_complete
	name = "Domena ukończona"
	desc = "Domena została ukończona. Kliknij, żeby wyjść."
	timeout = 20 SECONDS

/atom/movable/screen/alert/bitrunning/qserver_domain_complete/Click(location, control, params)
	if(usr != owner)
		return
	var/mob/living/living_owner = owner
	if(!isliving(living_owner))
		return

	if(tgui_alert(living_owner, "Rozłączyć się bezpiecznie?", "Wiadomość serwera", list("Wyjdź", "Zostań"), 10 SECONDS) == "Wyjdź")
		SEND_SIGNAL(living_owner, COMSIG_BITRUNNER_ALERT_SEVER)
