// AQUILA - polskie przedmioty i bielizna (aq33/NSV13#304) do odblokowania za metawalutę

/// Nazwa wzoru bielizny -> id przedmiotu z loadoutu, który ją odblokowuje
GLOBAL_LIST_EMPTY(loadout_locked_accessories)

/// Polskie wzory bielizny trzeba kupić w loadoucie, zanim da się je wybrać
/proc/is_accessory_unlocked(name, client/C)
	var/gear_id = GLOB.loadout_locked_accessories[name]
	if(!gear_id)
		return TRUE
	return C?.prefs && (gear_id in C.prefs.purchased_gear)

/// Kopia listy wzorów bielizny bez tych, których gracz nie odblokował
/proc/unlocked_accessories(list/accessories, client/C)
	. = list()
	for(var/name in accessories)
		if(is_accessory_unlocked(name, C))
			.[name] = accessories[name]

/datum/character_save/proc/remove_locked_accessories(client/C)
	if(!is_accessory_unlocked(underwear, C))
		underwear = "Nude"
	if(!is_accessory_unlocked(undershirt, C))
		undershirt = "Nude"
	if(!is_accessory_unlocked(socks, C))
		socks = "Nude"

// Przedmioty

/datum/gear/misc/reklamowka_biedronka
	display_name = "reklamówka z Biedronki"
	path = /obj/item/storage/commercial/reklamowka_biedronka
	cost = 500

/datum/gear/misc/reklamowka_lidl
	display_name = "reklamówka z Lidla"
	path = /obj/item/storage/commercial/reklamowka_lidl
	cost = 500

/datum/gear/footwear/aq_sandals
	display_name = "sandały z białymi skarpetkami"
	path = /obj/item/clothing/shoes/aquila/aq_sandals

// Bielizna - nie daje przedmiotu, tylko odblokowuje wzór w ustawieniach postaci

/datum/gear/aquila_accessory
	subtype_path = /datum/gear/aquila_accessory
	sort_category = "Polska bielizna"
	description = "Odblokowuje wzór do wyboru w wyglądzie postaci i w komodzie."
	cost = 1000
	/// Odblokowywany wzór bielizny
	var/datum/sprite_accessory/accessory

/datum/gear/aquila_accessory/New()
	..()
	GLOB.loadout_locked_accessories[initial(accessory.name)] = id

/datum/gear/aquila_accessory/boxers_1
	display_name = "Polskie Bokserki (wariant 1)"
	accessory = /datum/sprite_accessory/underwear/aq_boxers_1

/datum/gear/aquila_accessory/boxers_2
	display_name = "Polskie Bokserki (wariant 2)"
	accessory = /datum/sprite_accessory/underwear/aq_boxers_2

/datum/gear/aquila_accessory/boxers_3
	display_name = "Polskie Bokserki (wariant 3)"
	accessory = /datum/sprite_accessory/underwear/aq_boxers_3

/datum/gear/aquila_accessory/mankini_pl
	display_name = "Polskie Mankini"
	accessory = /datum/sprite_accessory/underwear/aq_mankini_pl

/datum/gear/aquila_accessory/shirt_white
	display_name = "Koszulka (biała)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_white

/datum/gear/aquila_accessory/shirt_polska
	display_name = "Koszulka (flaga) (Polska)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_polska

/datum/gear/aquila_accessory/shirt_black
	display_name = "Koszulka (flaga) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_black

/datum/gear/aquila_accessory/shirt_flag_mini_black
	display_name = "Koszulka (flaga mini) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_flag_mini_black

/datum/gear/aquila_accessory/shirt_jp100
	display_name = "Koszulka (Jan Paweł) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_jp100

/datum/gear/aquila_accessory/shirt_pl_red
	display_name = "Koszulka (PL) (czerwona)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_pl_red

/datum/gear/aquila_accessory/shirt_pl_white
	display_name = "Koszulka (PL) (biała)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_pl_white

/datum/gear/aquila_accessory/shirt_pw
	display_name = "Koszulka (PW) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_pw

/datum/gear/aquila_accessory/shirt_ilovepl
	display_name = "Koszulka (I Love PL) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_ilovepl

/datum/gear/aquila_accessory/shirt_monako
	display_name = "Koszulka (flaga) (Monako)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_monako

/datum/gear/aquila_accessory/shirt_orzel
	display_name = "Koszulka (orzeł) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_orzel

/datum/gear/aquila_accessory/shirt_pl_mini_white
	display_name = "Koszulka (PL mini) (biała)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_pl_mini_white

/datum/gear/aquila_accessory/shirt_pas_black
	display_name = "Koszulka (flaga pasek) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_pas_black

/datum/gear/aquila_accessory/shirt_otua_black
	display_name = "Koszulka (OTUA) (czarna)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_otua_black

/datum/gear/aquila_accessory/shirt_otua_white
	display_name = "Koszulka (OTUA) (biała)"
	accessory = /datum/sprite_accessory/undershirt/aq_shirt_otua_white

/datum/gear/aquila_accessory/codersocks_pl
	display_name = "Zakolanówki (Biało-Czerwone)"
	accessory = /datum/sprite_accessory/socks/aq_codersocks_pl
