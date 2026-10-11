// Port BeeStation #9655: zakładka pola w panelu statystyk grupuje takie same przedmioty ("(x5)")
// i oznacza wpisy tagiem, po którym panel z Bee je sortuje (najpierw ty, potem ludzie, moby, przedmioty...).

/// How many items per tile until we just completely give up?
#define MAX_ITEMS_TO_READ 500
/// How many unique entries should we show per-tile before giving up? (core #undefs its own copy)
#define MAX_ICONS_PER_TILE 50

/// Determine the priority of this item in the stat panel
#define STAT_PANEL_TAG(atom) ishuman(atom) \
	? "Human" \
	: ismob(atom) \
		? "Mob" \
		: isitem(atom) \
			? "Item" \
			: isstructure(atom) \
				? "Structure" \
				: ismachinery(atom) \
					? "Machinery" \
					: isturf(atom) \
						? "Turf" \
						: "Other"

/turf/proc/render_stat_information(client/client, list/tab_data)
	client.stat_update_mode = STAT_MEDIUM_UPDATE
	// Display the turf
	var/list/overrides = list()
	for(var/image/I in client.images)
		if(I.loc && I.loc.loc == src && I.override)
			overrides[I.loc] = I
	tab_data[REF(src)] = list(
		text = "[name]",
		tag = STAT_PANEL_TAG(src),
		type = STAT_ATOM
	)
	var/max_item_sanity = MAX_ITEMS_TO_READ
	var/icon_count_sanity = MAX_ICONS_PER_TILE
	var/list/atom_count = list()
	var/list/image_overrides = list()
	// Caching for A.IsObscured, "in" is faster than dictionary lookups for small lists
	var/list/checked_layers = list()
	var/list/obscured_layers = list()
	// Find items and group them by both name and count
	for(var/atom/A as anything in src)
		if(max_item_sanity-- < 0)
			break
		if(!A.mouse_opacity)
			continue
		if(A.invisibility > client.mob.see_invisible)
			continue
		if(A.layer in checked_layers)
			if(A.layer in obscured_layers)
				continue
		else
			checked_layers += A.layer
			if(A.IsObscured())
				obscured_layers += A.layer
		var/atom_name = A.name
		if(length(overrides) && overrides[A])
			var/image/override_image = overrides[A]
			atom_name = override_image.name
			image_overrides[A] = override_image
		var/list/item_group = atom_count["[A.type][atom_name]"]
		if(item_group)
			item_group += A
		else
			atom_count["[A.type][atom_name]"] = list(A)
			if(icon_count_sanity-- <= 0)
				break
	// Display the atoms
	for(var/group_key in atom_count)
		var/list/atom_items = atom_count[group_key]
		var/item_count = length(atom_items)
		var/atom/first_atom = atom_items[1]
		if(istype(first_atom, /obj/item/stack))
			item_count = 0
			for(var/obj/item/stack/stack_item as anything in atom_items)
				item_count += stack_item.amount
		var/atom_name = first_atom.name
		if(image_overrides[first_atom])
			var/image/override_image = image_overrides[first_atom]
			atom_name = override_image.name
		tab_data[REF(first_atom)] = list(
			text = "[atom_name][item_count > 1 ? " (x[item_count])" : ""]",
			tag = STAT_PANEL_TAG(first_atom),
			type = STAT_ATOM
		)
	// Display self
	tab_data[REF(client.mob)] = list(
		text = client.mob.name,
		tag = "You",
		type = STAT_ATOM
	)

#undef MAX_ITEMS_TO_READ
#undef MAX_ICONS_PER_TILE
#undef STAT_PANEL_TAG

// Port BeeStation #13727: czas do restartu w zakładce Status. Bee przepięło restart na timer,
// u nas Reboot() czeka dalej po staremu, więc tylko zapamiętujemy, kiedy ma nastąpić.
/datum/controller/subsystem/ticker
	/// world.time of the pending reboot, set by Reboot()
	var/reboot_at

/mob/proc/aquila_reboot_stat(list/tab_data)
	if(SSticker.delay_end && SSticker.ready_for_reboot)
		tab_data["Restart"] = GENERATE_STAT_TEXT("wstrzymany przez admina")
	else if(SSticker.reboot_at && SSticker.reboot_at > world.time)
		tab_data["Restart"] = GENERATE_STAT_TEXT(DisplayTimeText(SSticker.reboot_at - world.time, 1))
