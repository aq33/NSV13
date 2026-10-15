/// Recollects water for sinks, toilets and showers
/obj/item/stock_parts/water_recycler
	name = "water recycler"
	desc = "A chemical reclamation component, which serves to re-accumulate and filter water over time."
	icon = 'aquila/icons/obj/plumbing/plumbing_items.dmi'
	icon_state = "water_recycler"
	custom_materials = list(/datum/material/plastic = 200, /datum/material/iron = 50)

/datum/design/water_recycler
	name = "Water Recycler"
	desc = "A device that slowly reclaims water for sinks, toilets and showers."
	id = "water_recycler"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/plastic = 200, /datum/material/iron = 50)
	build_path = /obj/item/stock_parts/water_recycler
	category = list("initial", "Stock Parts", "Misc")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/plumbing_rcd_service
	name = "Service Plumbing Constructor"
	id = "plumbing_rcd_service"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 75000, /datum/material/glass = 37500, /datum/material/plastic = 1000)
	build_path = /obj/item/construction/plumbing/service
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/techweb_node/base/New() // plumbing designs, appended so upstream changes to this node's designs still apply
	. = ..()
	design_ids |= list("water_recycler", "plumbing_rcd_service")

// Plumbed tanks: the water sources for station sinks, toilets and showers
/obj/structure/reagent_dispensers/plumbed
	name = "stationary water tank"
	desc = "A stationary, plumbed, water tank."
	icon = 'aquila/icons/obj/plumbing/plumbing_items.dmi'
	icon_state = "water_stationary"

/obj/structure/reagent_dispensers/plumbed/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Wydaje płyn do rur przez złącze z przodu. Można go odkręcić <b>kluczem</b>.</span>"
	. += "<span class='notice'>Zawiera [round(reagents.total_volume)]/[reagents.maximum_volume] j. <b>Prawym klikiem</b> pojemnikiem dolejesz do niego jego zawartość.</span>"

/// Pouring a container back in, so the station's water supply can be topped up by hand
/obj/structure/reagent_dispensers/plumbed/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/reagent_containers))
		return ..()
	if(!weapon.reagents?.total_volume)
		balloon_alert(user, "pojemnik jest pusty!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(reagents.holder_full())
		balloon_alert(user, "zbiornik jest pełny!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/poured = weapon.reagents.trans_to(src, weapon.reagents.total_volume, transfered_by = user)
	playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	user.visible_message("<span class='notice'>[user] dolewa zawartość [weapon] do [src].</span>", 		"<span class='notice'>Dolewasz [round(poured, 0.1)] j. z [weapon] do [src].</span>")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/reagent_dispensers/plumbed/storage
	name = "stationary storage tank"
	icon_state = "tank_stationary"

/obj/structure/reagent_dispensers/plumbed/storage/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/mutable_appearance/tank_color = mutable_appearance(icon, "tank_chem_overlay")
	tank_color.color = mix_color_from_reagents(reagents.reagent_list)
	. += tank_color

/obj/structure/reagent_dispensers/plumbed/storage/on_reagent_change(changetype)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/reagent_dispensers/plumbed/fuel
	name = "stationary fuel tank"
	desc = "A stationary, plumbed, fuel tank."
	icon_state = "fuel_stationary"
	reagent_id = /datum/reagent/fuel

// Plunger layer mode from tg: click plumbing machines to move them to another duct layer
/obj/item/plunger
	/// Icon state used while in layer mode
	var/layer_mode_sprite = "plunger_layer"
	/// Are we changing the duct layer of what we click instead of plunging it
	var/layer_mode = FALSE
	/// The layer we move machines to
	var/target_layer = DUCT_LAYER_DEFAULT

/obj/item/plunger/reinforced
	layer_mode_sprite = "reinforced_plunger_layer"

/obj/item/plunger/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Użyj w dłoni, żeby przełączyć tryb zmiany warstwy rur[layer_mode ? " (obecnie: [GLOB.plumbing_layer_names["[target_layer]"]])" : ""].</span>"

/obj/item/plunger/attack_self(mob/user)
	. = ..()
	layer_mode = !layer_mode
	if(!layer_mode)
		icon = initial(icon)
		icon_state = initial(icon_state)
		to_chat(user, "<span class='notice'>Przełączasz [src] na zwykłe przepychanie.</span>")
		return

	var/new_layer = tgui_input_list(user, "Na którą warstwę przestawiać maszyny?", "Warstwa", GLOB.plumbing_layers, GLOB.plumbing_layer_names["[target_layer]"])
	if(isnull(new_layer) || !user.is_holding(src))
		layer_mode = FALSE
		return
	target_layer = GLOB.plumbing_layers[new_layer]
	icon = 'aquila/icons/obj/plumbing/plumbing_items.dmi'
	icon_state = layer_mode_sprite
	to_chat(user, "<span class='notice'>Klikaj maszyny, żeby przestawić je na warstwę: [new_layer].</span>")

/obj/item/plunger/attack_obj(obj/O, mob/living/user)
	if(!layer_mode)
		return ..()
	if(!(locate(/datum/component/plumbing) in O.GetComponents(/datum/component/plumbing)))
		return ..()
	if(O.anchored)
		to_chat(user, "<span class='warning'>Najpierw odkręć [O].</span>")
		return TRUE
	SEND_SIGNAL(O, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, user, target_layer)
	to_chat(user, "<span class='notice'>Przestawiasz [O] na warstwę: [GLOB.plumbing_layer_names["[target_layer]"]].</span>")
	return TRUE
