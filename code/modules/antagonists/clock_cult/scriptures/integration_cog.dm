//==================================//
// !       Integration Cog       ! //
//==================================//

/datum/clockcult/scripture/integration_cog
	name = "Integration Cog"
	desc = "Fabricates an integration cog, which can be inserted into APCs to draw power and unlock scriptures."
	tip = "Instaluj zębatki integracyjne w APC, by zasilać kult i odblokowywać nowe pisma."
	button_icon_state = "Integration Cog"
	power_cost = 0
	invokation_time = 10
	invokation_text = list("Tick tock Eng'Ine...")
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/integration_cog/invoke_success()
	var/obj/item/clockwork/integration_cog/IC = new()
	if(invoker.put_in_hands(IC, TRUE))
		to_chat(invoker, "<span class='brass'>Przywołujesz zębatkę integracyjną!</span>")
		playsound(src, 'sound/machines/click.ogg', 50)
	else
		to_chat(invoker, "<span class='brass'>Musisz mieć wolną nieaktywną rękę, żeby przywołać zębatkę integracyjną!</span>")
		return FALSE
