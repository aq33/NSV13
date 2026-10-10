//==================================//
// !      Tinkerer's Cache     ! //
//==================================//
/datum/clockcult/scripture/create_structure/tinkerers_cache
	name = "Tinkerer's Cache"
	desc = "Creates a tinkerer's cache, a powerful forge capable of crafting elite equipment."
	tip = "Skrzynia pozwala tworzyć potężniejszy sprzęt (z czasem odnowienia)."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	invokation_time = 50
	invokation_text = list("Guide my hand and we shall create greatness.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

//===============
//Tinkerer's Cache Structure
//===============

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache
	name = "tinkerer's cache"
	desc = "A bronze store filled with parts and components."
	clockwork_desc = "Brązowy magazyn pełen części i komponentów. Można w nim wykuwać potężne ratvariańskie przedmioty."
	default_icon_state = "tinkerers_cache"
	anchored = TRUE
	break_message = "<span class='warning'>Skrzynia majsterkowicza topi się w stertę mosiądzu.</span>"
	var/cooldowntime = 0

/obj/structure/destructible/clockwork/gear_base/tinkerers_cache/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>Próbujesz włożyć rękę do [src], ale prawie się parzysz!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='brass'>Najpierw przymocuj [src] do podłogi.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='brass'>[src] wciąż się rozgrzewa, będzie gotowy za [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/choice = alert(user,"Zaczynasz składać komponenty w kuźni.",,"Robes of Divinity","Shrouding Cloak","Wraith Spectacles")
	var/list/pickedtype = list()
	switch(choice)
		if("Robes of Divinity")
			pickedtype += /obj/item/clothing/suit/clockwork/speed
		if("Shrouding Cloak")
			pickedtype += /obj/item/clothing/suit/clockwork/cloak
		if("Wraith Spectacles")
			pickedtype += /obj/item/clothing/glasses/clockwork/wraith_spectacles
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && is_servant_of_ratvar(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, "<span class='brass'>Tworzysz niemal doskonały przedmiot: [choice], a [src] się wypala.</span>")

