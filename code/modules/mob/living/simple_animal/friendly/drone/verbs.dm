
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	to_chat(src, "<b>Prawa dronów</b>")
	to_chat(src, laws)

/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Poziom alarmu","Ping drona",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>PING DRONA: [name]: alarm o priorytecie [alert_s] w [A.name]!</span>"
		alert_drones(msg)
