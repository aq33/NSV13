// AQUILA - materiały notowane na giełdzie (port z tgstation)
// Ceny bazowe to dotychczasowe ceny eksportu za arkusz (code/modules/cargo/exports/materials.dm i sheets.dm).

/datum/material
	/// Czy materiał jest notowany na giełdzie
	var/tradable = FALSE
	/// Bazowa podaż na giełdzie (w arkuszach)
	var/tradable_base_quantity = 0
	/// Bazowa cena za arkusz na giełdzie
	var/market_value = 0
	/// Najniższa cena za arkusz; null = połowa ceny bazowej
	var/market_minimum_override = null

/datum/material/iron
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	market_value = 5
	market_minimum_override = 1

/datum/material/glass
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_COMMON
	market_value = 5
	market_minimum_override = 1

/datum/material/silver
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	market_value = 50

/datum/material/gold
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	market_value = 125

/datum/material/diamond
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	market_value = 500

/datum/material/uranium
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_RARE
	market_value = 100

/datum/material/titanium
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_UNCOMMON
	market_value = 125

/datum/material/bluespace
	tradable = TRUE
	tradable_base_quantity = MATERIAL_QUANTITY_EXOTIC
	market_value = 300

/// Cena rynkowa materiału (za arkusz) albo null, gdy nie jest notowany
/proc/get_market_price(datum/material/mat)
	if(!ispath(mat))
		mat = mat?.type
	if(!mat)
		return null
	return SSstock_market.materials_prices[mat]

/datum/export
	/// Materiał z giełdy, po którego cenie liczy się ten eksport (cena za sztukę z get_amount)
	var/datum/material/market_material

/datum/export/material/New()
	. = ..()
	var/datum/material/mat_type = material_id
	if(ispath(mat_type, /datum/material) && initial(mat_type.tradable))
		market_material = mat_type

// plastytan liczy tylko tytan, ale kosztuje jak plazma z tytanem - zostaje po starej cenie
/datum/export/material/plastitanium/New()
	. = ..()
	market_material = null

// kryształy bluespace sprzedają się jako stos, nie przez /datum/export/material
/datum/export/stack/bscrystal
	market_material = /datum/material/bluespace

/// Eksport po cenie z giełdy: bez elastyczności, za to każda sprzedaż obniża cenę i zwiększa podaż
/datum/export/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	if(!market_material)
		return ..()
	var/price = get_market_price(market_material)
	if(isnull(price))
		return ..()
	return round(price * get_amount(O))

/datum/export/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO, apply_elastic = TRUE)
	if(!market_material || isnull(get_market_price(market_material)))
		return ..()
	. = ..(O, report, dry_run, allowed_categories, FALSE)
	if(!. || dry_run)
		return
	var/sheets = get_amount(O)
	if(sheets <= 0)
		return
	market_sale(market_material, sheets)

/// Sprzedaż arkuszy na rynek: im mniej materiału na rynku, tym mocniej spada cena
/proc/market_sale(datum/material/mat, sheets)
	var/price = SSstock_market.materials_prices[mat]
	var/quantity = SSstock_market.materials_quantity[mat]
	if(isnull(price))
		return
	SSstock_market.adjust_material_price(mat, -price * (sheets / (sheets + quantity)))
	SSstock_market.adjust_material_quantity(mat, sheets)
