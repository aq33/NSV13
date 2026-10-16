/// Punkty bitrunningu na koncie (tg bank_account.bitrunning_points)
/datum/bank_account/var/bitrunning_points = 0

/obj/machinery/computer/order_console/bitrunning
	name = "konsola zamówień bitrunnerów"
	desc = "NexaCache(tm)! Sprzęt wątpliwej autentyczności dla cyfrowych śmiałków."
	icon = 'aquila/icons/obj/machines/bitrunning.dmi'
	icon_state = "vendor"
	icon_keyboard = null
	icon_screen = null
	circuit = /obj/item/circuitboard/computer/order_console/bitrunning
	cooldown_time = 10 SECONDS
	cargo_cost_multiplier = 0.65
	express_cost_multiplier = 1
	purchase_tooltip = "Zakupy przylecą promem zaopatrzenia i miejmy nadzieję, że magazynierzy je dostarczą. 35% taniej niż ekspres."
	express_tooltip = "Wysyła zakupy od razu."
	credit_type = MONEY_BITRUNNING_SYMBOL
	order_categories = list(
		CATEGORY_BITRUNNING_FLAIR,
		CATEGORY_BITRUNNING_TECH,
		CATEGORY_BEPIS,
	)
	blackbox_key = "bitrunning"
	announcement_line = "Bitrunner zamówił sprzęt, który przyleci promem zaopatrzenia! Dopilnujcie, żeby jak najszybciej do niego trafił!"

/obj/machinery/computer/order_console/bitrunning/update_overlays()
	..()
	return list() // ekran jest w samym icon_state, bez nakładek konsoli

/obj/machinery/computer/order_console/bitrunning/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "_off"]"
	return ..()

/obj/machinery/computer/order_console/bitrunning/subtract_points(final_cost, obj/item/card/id/card)
	if(final_cost <= card.registered_account.bitrunning_points)
		card.registered_account.bitrunning_points -= final_cost
		return TRUE
	return FALSE

/obj/machinery/computer/order_console/bitrunning/retrieve_points(obj/item/card/id/id_card)
	return round(id_card.registered_account?.bitrunning_points)

/obj/machinery/computer/order_console/bitrunning/order_groceries(mob/living/purchaser, obj/item/card/id/card, list/groceries)
	var/list/things_to_order = list()
	for(var/datum/orderable_item/item as anything in groceries)
		for(var/i in 1 to groceries[item])
			things_to_order += item.purchase_path

	var/datum/supply_pack/order_console/pack = new(purchaser, things_to_order, ACCESS_BIT_DEN)
	pack.crate_name = "skrzynia z zamówieniem bitrunnera"

	var/datum/supply_order/new_order = new(pack, purchaser, "Sklep bitrunnerów", purchaser.ckey, "", null)
	say("Dziękujemy za zakup! Przyleci najbliższym promem zaopatrzenia!")
	radio_announce(announcement_line)
	SSshuttle.shoppinglist += new_order

/// Ogłoszenie na kanale zaopatrzenia
/obj/machinery/computer/order_console/proc/radio_announce(message)
	if(!message)
		return
	bitrunning_announce(message, radio_channel)

/obj/machinery/computer/order_console/bitrunning/ui_act(action, list/params)
	. = ..()
	if(!.)
		flick("vendor_off", src)


/datum/orderable_item/bepis
	category_index = CATEGORY_BEPIS

/datum/orderable_item/bepis/survival_pen
	purchase_path = /obj/item/reagent_containers/hypospray/medipen/survival
	cost_per_order = 150

/datum/orderable_item/bepis/sleeper
	purchase_path = /obj/item/circuitboard/machine/sleeper
	cost_per_order = 750
	desc = "Wycofana płytka uśpiacza. Przyda się po ciężkiej sesji."

/datum/orderable_item/bitrunning_flair
	category_index = CATEGORY_BITRUNNING_FLAIR

/datum/orderable_item/bitrunning_flair/cornchips
	purchase_path = /obj/item/food/cornchips
	cost_per_order = 100

/datum/orderable_item/bitrunning_flair/mountain_wind
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	cost_per_order = 100

/datum/orderable_item/bitrunning_flair/pwr_game
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/pwr_game
	cost_per_order = 200

/datum/orderable_item/bitrunning_flair/grey_bull
	purchase_path = /obj/item/reagent_containers/food/drinks/soda_cans/grey_bull
	cost_per_order = 200

/datum/orderable_item/bitrunning_flair/medkit
	purchase_path = /obj/item/storage/firstaid/brute
	desc = "Nie bij się tak, to tylko gra!"
	cost_per_order = 500

/datum/orderable_item/bitrunning_flair/medkit_fire
	purchase_path = /obj/item/storage/firstaid/fire
	desc = "Świetna po gorących sesjach."
	cost_per_order = 500

/datum/orderable_item/bitrunning_flair/oval_sunglasses
	purchase_path = /obj/item/clothing/glasses/sunglasses/oval
	cost_per_order = 1000

/datum/orderable_item/bitrunning_flair/trenchcoat
	purchase_path = /obj/item/clothing/suit/jacket/leather_trenchcoat
	cost_per_order = 1000

/datum/orderable_item/bitrunning_flair/jackboots
	purchase_path = /obj/item/clothing/shoes/jackboots
	cost_per_order = 1000

/datum/orderable_item/bitrunning_flair/figure
	purchase_path = /obj/item/toy/figure/bitrunner
	cost_per_order = 300

/datum/orderable_item/bitrunning_tech
	category_index = CATEGORY_BITRUNNING_TECH

/datum/orderable_item/bitrunning_tech/item_tier1
	cost_per_order = 750
	purchase_path = /obj/item/disk/bitrunning/item/tier1
	desc = "Program pozwala wziąć medyczny miotacz wiązki, ładunek C4 albo pudełko z nieskończoną pizzą."

/datum/orderable_item/bitrunning_tech/item_tier2
	cost_per_order = 1250
	purchase_path = /obj/item/disk/bitrunning/item/tier2
	desc = "Program pozwala wziąć medipen przetrwania, pistolet albo kamizelkę kuloodporną."

/datum/orderable_item/bitrunning_tech/item_tier3
	cost_per_order = 2000
	purchase_path = /obj/item/disk/bitrunning/item/tier3
	desc = "Program pozwala wziąć zaawansowaną broń energetyczną, podwójny miecz energetyczny albo minibombę."

/datum/orderable_item/bitrunning_tech/ability_tier1
	cost_per_order = 750
	purchase_path = /obj/item/disk/bitrunning/ability/tier1
	desc = "Program pozwala rzucać Przywołanie sera albo Słabsze leczenie."

/datum/orderable_item/bitrunning_tech/ability_tier2
	cost_per_order = 1500
	purchase_path = /obj/item/disk/bitrunning/ability/tier2
	desc = "Program pozwala rzucać Kulę ognia, Błyskawicę albo Ścianę mocy."

/datum/orderable_item/bitrunning_tech/ability_tier3
	cost_per_order = 2500
	purchase_path = /obj/item/disk/bitrunning/ability/tier3
	desc = "Program pozwala zmienić się w popielnego smoka albo niedźwiedzia polarnego."

/datum/orderable_item/bitrunning_tech/gimmick_sports
	cost_per_order = 750
	purchase_path = /obj/item/disk/bitrunning/gimmick/sports
	desc = "Program pozwala wziąć sportowy zestaw tematyczny."

/datum/orderable_item/bitrunning_tech/gimmick_dungeon_crawling
	cost_per_order = 1250
	purchase_path = /obj/item/disk/bitrunning/gimmick/dungeon
	desc = "Program pozwala wziąć zestaw do łażenia po lochach."

/datum/orderable_item/bitrunning_tech/pka_mod
	purchase_path = /obj/item/disk/bitrunning/item/pka_mods
	cost_per_order = 750
	desc = "Program pozwala wziąć moduły do kinetycznego akceleratora. Akcelerator nie jest w zestawie."

/datum/orderable_item/bitrunning_tech/pka_mod/premium
	purchase_path = /obj/item/disk/bitrunning/item/pka_mods/premium
	cost_per_order = 1600
	desc = "Program pozwala wziąć mocniejsze moduły do kinetycznego akceleratora. Akcelerator nie jest w zestawie."

/datum/orderable_item/bitrunning_tech/pkc_mod
	purchase_path = /obj/item/disk/bitrunning/item/pkc_mods
	cost_per_order = 750
	desc = "Program pozwala wziąć trofea do kinetycznego miażdżyciela. Miażdżyciel nie jest w zestawie."

/datum/orderable_item/bitrunning_tech/pkc_mod/premium
	purchase_path = /obj/item/disk/bitrunning/item/pkc_mods/premium
	cost_per_order = 1600
	desc = "Program pozwala wziąć mocniejsze trofea do kinetycznego miażdżyciela. Miażdżyciel nie jest w zestawie."
