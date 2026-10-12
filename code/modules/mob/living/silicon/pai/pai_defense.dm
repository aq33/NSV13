
/mob/living/silicon/pai/blob_act(obj/structure/blob/B)
	return FALSE

/mob/living/silicon/pai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	take_holo_damage(50/severity)
	Paralyze(400/severity)
	silent = max(30/severity, silent)
	if(holoform)
		fold_in(force = TRUE)
	//Need more effects that aren't instadeath or permanent law corruption.

/mob/living/silicon/pai/ex_act(severity, target)
	take_holo_damage(severity * 50)
	switch(severity)
		if(1)	//RIP
			qdel(card)
			qdel(src)
		if(2)
			fold_in(force = 1)
			Paralyze(400)
		if(3)
			fold_in(force = 1)
			Paralyze(200)

/mob/living/silicon/pai/attack_hand(mob/living/carbon/human/user)
	switch(user.a_intent)
		if("help")
			visible_message("<span class='notice'>[user] delikatnie klepie [src] po głowie, wywołując nieprzyjemne brzęczenie jej pola holograficznego.</span>")
		if("disarm")
			visible_message("<span class='notice'>[user] pstryka [src] w nosek!</span>")
		if("harm")
			user.do_attack_animation(src)
			if (user.name == master)
				visible_message("<span class='notice'>Reagując na dotyk właściciela, [src] wyłącza emiter holoobudowy, szybko tracąc spójność.</span>")
				addtimer(CALLBACK(src, PROC_REF(fold_into_hand), user), 10)
			else
				visible_message("<span class='danger'>[user] depcze [src]!</span>")
				take_holo_damage(2)

/mob/living/silicon/pai/proc/fold_into_hand(mob/user)
	fold_in()
	if(user.put_in_hands(card))
		user.visible_message("<span class='notice'>[user] szybko podnosi kartę swojego pAI.</span>")

/mob/living/silicon/pai/bullet_act(obj/item/projectile/Proj)
	if(Proj.stun)
		fold_in(force = TRUE)
		src.visible_message("<span class='warning'>Naładowany elektrycznie pocisk zakłóca holomatrycę [src], zmuszając ją do złożenia się!</span>")
	. = ..(Proj)

/mob/living/silicon/pai/stripPanelUnequip(obj/item/what, mob/who, where) //prevents stripping
	to_chat(src, "<span class='warning'>Twoja holoobudowa drga i mocno się zniekształca, gdy próbujesz wejść w interakcję z obiektem, więc przestajesz, zanim pole zawiedzie.</span>")

/mob/living/silicon/pai/stripPanelEquip(obj/item/what, mob/who, where) //prevents stripping
	to_chat(src, "<span class='warning'>Twoja holoobudowa drga i mocno się zniekształca, gdy próbujesz wejść w interakcję z obiektem, więc przestajesz, zanim pole zawiedzie.</span>")

/mob/living/silicon/pai/IgniteMob(var/mob/living/silicon/pai/P)
	return FALSE //No we're not flammable

/mob/living/silicon/pai/proc/take_holo_damage(amount)
	emitterhealth = CLAMP((emitterhealth - amount), -50, emittermaxhealth)
	if(emitterhealth < 0)
		fold_in(force = TRUE)
	to_chat(src, "<span class='userdanger'>Uderzenie osłabia twoją holoobudowę!</span>")
	return amount

/mob/living/silicon/pai/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	return take_holo_damage(amount)

/mob/living/silicon/pai/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/pai/adjustStaminaLoss(amount, updating_health, forced = FALSE)
	if(forced)
		take_holo_damage(amount)
	else
		take_holo_damage(amount * 0.25)

/mob/living/silicon/pai/getBruteLoss()
	return emittermaxhealth - emitterhealth

/mob/living/silicon/pai/getFireLoss()
	return emittermaxhealth - emitterhealth

/mob/living/silicon/pai/getToxLoss()
	return FALSE

/mob/living/silicon/pai/getOxyLoss()
	return FALSE

/mob/living/silicon/pai/getCloneLoss()
	return FALSE

/mob/living/silicon/pai/getStaminaLoss()
	return FALSE

/mob/living/silicon/pai/setCloneLoss()
	return FALSE

/mob/living/silicon/pai/setStaminaLoss(amount, updating_health = TRUE)
	return FALSE

/mob/living/silicon/pai/setToxLoss()
	return FALSE

/mob/living/silicon/pai/setOxyLoss()
	return FALSE
