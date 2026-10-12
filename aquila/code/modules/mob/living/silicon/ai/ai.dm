/mob/living/silicon/ai
	var/obj/item/ai_hijack_device/hijacking
	var/mutable_appearance/hijack_overlay
	var/hijack_start = 0

/mob/living/silicon/ai/attack_hand(mob/user)
	if(hijacking)
		user.visible_message(span_danger("[user] próbuje odłączyć płytkę drukowaną od [src]"), span_notice("Coś jest podłączone do portów [src]! Próbujesz to odłączyć..."))
		if (do_after(user,100,target = src))
			hijacking.forceMove(loc)
			hijacking = null
			hijack_start = 0
			update_icons()
			to_chat(src, span_bolddanger("Odłączono nieznane urządzenie. Potwierdzono bezpieczeństwo systemów."))
		else
			to_chat(user, span_notice("Nie udaje ci się usunąć urządzenia."))
		return
	return ..()

/mob/living/silicon/ai/update_icons()
	..()
	cut_overlays()
	if(hijacking)
		if(!hijack_overlay)
			hijack_overlay = mutable_appearance('aquila/icons/obj/module.dmi', "ai_hijack_overlay")
			hijack_overlay.layer = layer+0.1
			hijack_overlay.pixel_x = 8
		add_overlay(hijack_overlay)
		icon_state = "ai-static"
	else if(!hijacking && hijack_overlay)
		QDEL_NULL(hijack_overlay)


/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(istype(card) && interaction == AI_TRANS_TO_CARD && hijacking)
		hijacking.forceMove(get_turf(card))
		hijacking.visible_message(span_warning("[hijacking] odpada od [AI], gdy zostaje przeniesiona do [card]!"))
		hijacking = null
		hijack_start = 0
		to_chat(src, span_bolddanger("Odłączono nieznane urządzenie. Potwierdzono bezpieczeństwo systemów."))

