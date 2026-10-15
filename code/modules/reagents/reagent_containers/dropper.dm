/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	worn_icon_state = "pen"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	reagent_flags = TRANSPARENT

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[target] jest pełny.</span>")
			return

		if(!target.is_injectable(user))
			to_chat(user, "<span class='warning'>Nie możesz przelać odczynników do [target]!</span>")
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = victim.is_eyes_covered()

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)

					reagents.reaction(safe_thing, TOUCH, fraction)
					trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this, transfered_by = user)

					target.visible_message("<span class='danger'>[user] próbuje wkroplić coś [target] do oczu, ale mu się nie udaje!</span>", \
											"<span class='userdanger'>[user] próbuje wkroplić ci coś do oczu, ale mu się nie udaje!</span>")

					to_chat(user, "<span class='notice'>Przelewasz [trans] j. roztworu.</span>")
					update_icon()
					return
			else if(isalien(target)) //hiss-hiss has no eyes!
				to_chat(target, "<span class='danger'>[target] chyba nie ma oczu!</span>")
				return

			target.visible_message("<span class='danger'>[user] wkrapla coś [target] do oczu!</span>", \
									"<span class='userdanger'>[user] wkrapla ci coś do oczu!</span>")

			reagents.reaction(target, TOUCH, fraction)
			var/mob/M = target
			var/R
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"

			log_combat(user, M, "squirted", R)

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Przelewasz [trans] j. roztworu.</span>")
		update_icon()

	else

		if(!target.is_drawable(user, FALSE)) //No drawing from mobs here
			to_chat(user, "<span class='notice'>Nie możesz bezpośrednio pobrać odczynników z [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] jest pusty!</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)

		to_chat(user, "<span class='notice'>Napełniasz [src] [trans] j. roztworu.</span>")

		update_icon()

/obj/item/reagent_containers/dropper/update_icon()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "dropper")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	. = ..(TRUE)
