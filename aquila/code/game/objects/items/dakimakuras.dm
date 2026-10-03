// AQUILA - aq33/NSV13#269, dakimakuras
// Starts blank. Using it in hand picks a print and a name, after that using it in hand hugs, kisses, gropes or humps it depending on intent.

/obj/item/dakimakura
	name = "dakimakura"
	desc = "A large pillow depicting someone in a compromising position. Featuring as many dimensions as you."
	icon = 'aquila/icons/obj/dakis.dmi'
	icon_state = "daki_base"
	lefthand_file = 'aquila/icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/items_righthand.dmi'
	item_state = "daki"
	slot_flags = null
	w_class = WEIGHT_CLASS_BULKY
	/// The name given to the print, null until one is chosen
	var/custom_name

/// Every print, each has a "daki_<name>" icon state
/obj/item/dakimakura/proc/body_choices()
	var/static/list/choices = list(
		"Aitler",
		"Callie",
		"Catgirl",
		"Casca",
		"Centorea",
		"Chaika",
		"Coder",
		"Drone",
		"Elisabeth",
		"Fillia",
		"Foxy Granpa",
		"Haruko",
		"Holo",
		"Hotsauce",
		"Ian",
		"Jolyne",
		"Killer Queen",
		"Kurisu",
		"Marie",
		"Mero",
		"Miia",
		"Mugi",
		"Nar'Sie",
		"Papi",
		"Patchouli",
		"Pearl",
		"Plutia",
		"Rei",
		"Reisen",
		"Naga",
		"Squid",
		"Squiggly",
		"Sue Bowchief",
		"Suu",
		"Tomoko",
		"Toriel",
		"Umaru",
		"Yaranaika",
		"Yoko",
		"Kane",
		"TEG",
	)
	return choices

/obj/item/dakimakura/attack_self(mob/living/user)
	if(!custom_name)
		var/body_choice = tgui_input_list(user, "Pick a body.", "Dakimakura", body_choices())
		if(!body_choice || QDELETED(src) || !user.is_holding(src))
			return
		set_body(body_choice)
		var/new_name = stripped_input(user, "What's her name?", "Dakimakura", "", MAX_NAME_LEN)
		if(!new_name || QDELETED(src) || !user.is_holding(src))
			return
		if(CHAT_FILTER_CHECK(new_name))
			to_chat(user, "<span class='warning'>That name is not allowed.</span>")
			return
		set_custom_name(new_name)
		return
	switch(user.a_intent)
		if(INTENT_HELP)
			user.visible_message("<span class='notice'>[user] hugs the [name].</span>")
			playsound(loc, "rustle", 50, TRUE, -5)
		if(INTENT_DISARM)
			user.visible_message("<span class='notice'>[user] kisses the [name].</span>")
			playsound(loc, 'aquila/sound/voice/kiss.ogg', 50, TRUE, -5)
		if(INTENT_GRAB)
			user.visible_message("<span class='warning'>[user] gropes the [name]!</span>")
			playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)
		if(INTENT_HARM)
			user.visible_message("<span class='danger'>[user] violently humps the [name]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, TRUE)

/obj/item/dakimakura/proc/set_body(body_choice)
	if(!(body_choice in body_choices()))
		return FALSE
	icon_state = "daki_[body_choice]"
	return TRUE

/obj/item/dakimakura/proc/set_custom_name(new_name)
	custom_name = new_name
	renamedByPlayer = TRUE
	name = "[custom_name] [initial(name)]"
	desc = "A large pillow depicting [custom_name] in a compromising position. Featuring as many dimensions as you."
