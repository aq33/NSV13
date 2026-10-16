// AQUILA - port tgstation/tgstation#88252 (Toolbox Mastery): klikając czymś skrzynką z narzędziami wybierasz z radiala narzędzie,
// które ląduje w drugiej ręce, zostaje użyte na celu i wraca do skrzynki

/obj/item/storage/toolbox
	/// Ile użyć narzędzia ze skrzynki właśnie trwa
	var/current_interactions = 0

/// Na te rzeczy skrzynkę się odkłada albo wkłada, więc nie otwieramy na nich radiala
/obj/item/storage/toolbox/proc/is_toolbox_drop_target(atom/target)
	var/static/list/drop_targets = typecacheof(list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/machinery/disposal,
	))
	if(is_type_in_typecache(target, drop_targets))
		return TRUE
	return !!target.GetComponent(/datum/component/storage)

// U nas pre_attack zwraca TRUE, żeby atak szedł dalej (patrz melee_attack_chain)
/obj/item/storage/toolbox/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(!. || !isliving(user) || user.a_intent == INTENT_HARM)
		return
	if(!user.has_hand_for_held_index(user.get_inactive_hand_index()) || is_toolbox_drop_target(target))
		return

	var/obj/item/held_tool = user.get_inactive_held_item()
	if(current_interactions)
		if(!istype(held_tool))
			return
		INVOKE_ASYNC(src, PROC_REF(use_tool_on), target, user, params, held_tool)
		return FALSE

	var/list/item_radial = list()
	for(var/obj/item/tool in contents)
		if(is_type_in_typecache(tool, GLOB.tool_items))
			item_radial[tool] = tool.appearance

	if(!length(item_radial))
		return

	if(held_tool)
		balloon_alert(user, "zajęte ręce!")
		return FALSE

	playsound(user, 'sound/items/handling/toolbox_pickup.ogg', 50, TRUE)
	var/obj/item/picked_item = show_radial_menu(user, target, item_radial, require_near = TRUE, tooltips = TRUE)
	if(!picked_item || picked_item.loc != src || user.get_active_held_item() != src || user.get_inactive_held_item())
		return FALSE

	if(!user.put_in_inactive_hand(picked_item))
		return FALSE

	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	storage?.animate_parent()
	if(istype(picked_item, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_item
		if(!welder.welding)
			welder.attack_self(user)

	INVOKE_ASYNC(src, PROC_REF(use_tool_on), target, user, params, picked_item)
	return FALSE

/obj/item/storage/toolbox/proc/use_tool_on(atom/target, mob/living/user, params, obj/item/picked_tool)
	current_interactions += 1
	picked_tool.melee_attack_chain(user, target, params)
	current_interactions -= 1

	if(QDELETED(picked_tool) || picked_tool.loc != user || QDELETED(src) || loc != user)
		current_interactions = 0
		return

	if(current_interactions)
		return

	if(istype(picked_tool, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = picked_tool
		if(welder.welding)
			welder.attack_self(user)

	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, picked_tool, user, TRUE)

/// Startowa skrzynka klauna: kilka losowych zabawek z puli nagród automatów
/obj/item/storage/toolbox/clown_toys
	name = "toolbox of toys"
	desc = "Zielona skrzynka wypchana zabawkami. Robust i śmieszna zarazem."
	icon_state = "green"
	item_state = "artistic_toolbox"
	material_flags = MATERIAL_NO_COLOR
	w_class = WEIGHT_CLASS_NORMAL // mieści się w plecaku klauna
	/// Ile zabawek wkładamy
	var/toy_count = 5

/obj/item/storage/toolbox/clown_toys/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 20
	STR.max_items = 8

/obj/item/storage/toolbox/clown_toys/PopulateContents()
	var/list/toys = list()
	for(var/prize in GLOB.arcade_prize_pool)
		if(ispath(prize, /obj/item/toy))
			toys[prize] = GLOB.arcade_prize_pool[prize]
	for(var/i in 1 to toy_count)
		var/toy_type = pickweight(toys)
		new toy_type(src)

/datum/outfit/job/clown/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	backpack_contents[/obj/item/storage/toolbox/clown_toys] = 1
