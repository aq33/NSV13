// Port z BeeStation: zasoby JSON i mapa ikon (icon_ref_map) dla komponentu DmIcon w TGUI.
// Okna z Bee (menu języków, automaty, crafting) pokazują ikony z plików .dmi po ich ref, a nie przez arkusze sprite'ów.

/// An asset that is one generated JSON file
/datum/asset/json
	_abstract = /datum/asset/json
	/// The filename, will be suffixed with ".json"
	var/name

/datum/asset/json/send(client)
	. = ..()
	if(!.)
		return
	return SSassets.transport.send_assets(client, "[name].json")

/datum/asset/json/get_url_mappings()
	return list(
		"[name].json" = SSassets.transport.get_asset_url("[name].json"),
	)

/datum/asset/json/register()
	var/filename = "data/[name].json"
	fdel(filename)
	rustg_file_write(json_encode(generate()), filename)
	SSassets.transport.register_asset("[name].json", fcopy_rsc(filename))
	fdel(filename)

/// Returns the data that will be JSON encoded
/datum/asset/json/proc/generate()
	CRASH("generate() not implemented for [type]!")

/// Maps .dmi paths to their resource refs, read by DmIcon in TGUI
/datum/asset/json/icon_ref_map
	name = "icon_ref_map"

/datum/asset/json/icon_ref_map/generate()
	var/list/data = list() //"icons/obj/drinks.dmi" => "[0xc000020]"
	var/value = 0
	while(TRUE)
		value += 1
		var/ref = "\[0xc[num2text(value, 6, 16)]\]"
		var/mystery_meat = locate(ref)
		if(isicon(mystery_meat))
			if(!isfile(mystery_meat)) // Ignore the runtime icons for now
				continue
			var/path = get_icon_dmi_path(mystery_meat)
			if(path)
				data[path] = ref
		else if(mystery_meat)
			continue // Some other non-icon resource, ogg/json/whatever
		else // Out of resources
			break
	return data
