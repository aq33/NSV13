
/mob
	var/bloody_hands = 0

/obj/item/clothing/gloves
	var/transfer_blood = 0


/obj/item/reagent_containers/glass/rag
	name = "damp rag"
	desc = "For cleaning up messes, you suppose."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/toy.dmi'
	icon_state = "rag"
	item_flags = NOBLUDGEON
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 5
	spillable = FALSE

/obj/item/reagent_containers/glass/rag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] dusi się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (OXYLOSS)

/obj/item/reagent_containers/glass/rag/afterattack(atom/A as obj|turf|area, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(iscarbon(A) && A.reagents && reagents.total_volume)
		var/mob/living/carbon/C = A
		var/reagentlist = pretty_string_from_reagent_list(reagents)
		var/log_object = "containing [reagentlist]"
		if(user.a_intent == INTENT_HARM && !C.is_mouth_covered())
			reagents.reaction(C, INGEST)
			reagents.trans_to(C, reagents.total_volume, transfered_by = user)
			C.visible_message("<span class='danger'>[user] przyciska [src] do twarzy [C]!</span>", "<span class='userdanger'>[user] przyciska ci [src] do twarzy!</span>", "<span class='italics'>Słyszysz szamotaninę i stłumione okrzyki zaskoczenia.</span>")
			log_combat(user, C, "smothered", src, log_object)
		else
			reagents.reaction(C, TOUCH)
			reagents.clear_reagents()
			C.visible_message("<span class='notice'>[user] dotyka [C] za pomocą [src].</span>")
			log_combat(user, C, "touched", src, log_object)

	else if(istype(A) && (src in user))
		user.visible_message("[user] zaczyna wycierać [A] za pomocą [src]!", "<span class='notice'>Zaczynasz wycierać [A] za pomocą [src]...</span>")
		if(do_after(user,30, target = A))
			user.visible_message("[user] kończy wycierać [A]!", "<span class='notice'>Kończysz wycierać [A].</span>")
			SEND_SIGNAL(A, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
			A.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			if(isclothing(A) && HAS_TRAIT(A, TRAIT_SPRAYPAINTED))
				var/obj/item/clothing/C = A
				var/mob/living/carbon/human/H = user
				C.flash_protect -= 1
				C.tint -= 2
				H.update_tint()
				REMOVE_TRAIT(A, TRAIT_SPRAYPAINTED, CRAYON_TRAIT)
