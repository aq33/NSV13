/datum/martial_art/mushpunch
	name = "Mushroom Punch"
	id = MARTIALART_MUSHPUNCH

/datum/martial_art/mushpunch/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/atk_verb
	to_chat(A, "<span class='spider'>Zaczynasz brać zamach do ataku...</span>")
	if(!do_after(A, 25, target = D))
		to_chat(A, "<span class='spider'><b>Twój atak został przerwany!</b></span>")
		return TRUE //martial art code was a mistake
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	atk_verb = pick("uderza", "miażdży", "rozrywa", "łamie")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D] z nieludzką siłą, posyłając go w powietrze!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] cię z nieludzką siłą, posyłając cię w powietrze!</span>")
	D.apply_damage(rand(15,30), A.dna.species.attack_type)
	playsound(D, 'sound/effects/meteorimpact.ogg', 25, 1, -1)
	var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
	D.Paralyze(20)
	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Mushroom Punch)")
	return TRUE

/obj/item/mushpunch
	name = "odd mushroom"
	desc = "<I>Sapienza Ophioglossoides</I>:An odd mushroom from the flesh of a mushroom person. It has apparently retained some innate power of its owner, as it quivers with barely-contained POWER!"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "mycelium-angel"

/obj/item/mushpunch/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	var/message = "<span class='spider'>Pożerasz [src], a połączenie umiejętności i mocy grzyba wzmacnia twoje ciosy! Do wyprowadzenia tych potężnych ciosów potrzebujesz chwili na zamach.</span>"
	to_chat(user, message)
	var/datum/martial_art/mushpunch/mush = new(null)
	mush.teach(user)
	qdel(src)
	visible_message("<span class='warning'>[user] devours [src].</span>", \
					"<span class='notice'>Pożerasz [src].</span>")
