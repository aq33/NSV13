/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = NO_POWER_USE
	density = TRUE

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user)
	. = ..()
	if(.)
		return
	if(charges <= 0)
		to_chat(user, "Spełniacz Życzeń milczy.")
		return

	else if(!ishuman(user))
		to_chat(user, "Czujesz mroczne poruszenie wewnątrz Spełniacza Życzeń, coś, czego zupełnie nie chcesz. Twój instynkt jest lepszy niż u kogokolwiek.")
		return

	else if(is_special_character(user))
		to_chat(user, "Nawet dla serca tak mrocznego jak twoje jest jasne, że nic dobrego z tego nie wyjdzie. Coś instynktownie każe ci się cofnąć.")

	else if (!insisting)
		to_chat(user, "Twój pierwszy dotyk sprawia, że Spełniacz Życzeń się porusza i cię słucha. Na pewno chcesz to zrobić?")
		insisting++

	else
		to_chat(user, "Mówisz.  [pick("Chcę, żeby stacja zniknęła","Ludzkość jest zepsuta, rodzaj ludzki musi zostać zniszczony","Chcę być bogaty", "Chcę rządzić światem","Chcę nieśmiertelności.")].  Spełniacz Życzeń odpowiada.")
		to_chat(user, "Przez chwilę huczy ci w głowie, po czym wzrok się rozjaśnia. Jesteś awatarem Spełniacza Życzeń, a twoja moc jest NIEOGRANICZONA! I wszystko to należy do ciebie. Musisz dopilnować, by nikt ci jej nie odebrał. Najpierw nikt nie może się dowiedzieć.")

		charges--
		insisting = 0

		user.mind.add_antag_datum(/datum/antagonist/wishgranter)

		to_chat(user, "Masz bardzo złe przeczucia.")

	return
