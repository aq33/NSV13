/datum/mutation/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Czujesz, jak przez twoje dłonie przepływa moc.</span>"
	text_lose_indication = "<span class='notice'>Energia w twoich dłoniach słabnie.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "Kierujesz elektryczność do dłoni."
	dropmessage = "Pozwalasz, by elektryczność z twojej dłoni się rozwiała."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	user.Beam(target, icon_state="lightning[rand(1,12)]", time=5, maxdistance = 32)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE, FALSE))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 15
			C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] razi cię prądem!</span>")
			use_charge(user)
			return ..()
		else
			user.visible_message("<span class='warning'>[user] nie udaje się porazić [target]!</span>")
			use_charge(user)
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, FALSE, FALSE, FALSE, FALSE)
		L.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='userdanger'>[user] razi cię prądem!</span>")
		use_charge(user)
		return ..()
	else
		to_chat(user,"<span class='warning'>Elektryczność chyba nie działa na [target]...</span>")
		use_charge(user)
		return ..()
