// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - aq33/NSV13#304 (polskie sprity i obiekty): every ported type has its sprites, and the interactions that come with it work
/datum/unit_test/polish_content

/datum/unit_test/polish_content/Run()
	var/fail = check_icons()
	if(fail)
		return Fail(fail)
	fail = check_accessories()
	if(fail)
		return Fail(fail)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Krzyże i godła: zawieszenie na ścianie i zdjęcie zwraca ten sam przedmiot
	var/list/wall_decor = list(
		/obj/item/wallframe/kszysz/kszysz_drewniany = /obj/structure/aquila_wall_decor/kszysz,
		/obj/item/wallframe/kszysz/kszysz_zloty = /obj/structure/aquila_wall_decor/kszysz/zloty,
		/obj/item/wallframe/godlo/godlo_drewniane = /obj/structure/aquila_wall_decor/godlo,
		/obj/item/wallframe/godlo/godlo_czarne = /obj/structure/aquila_wall_decor/godlo/czarne,
	)
	var/turf/wall_side = locate(user.x, user.y + 1, user.z)
	for(var/frame_type in wall_decor)
		var/structure_type = wall_decor[frame_type]
		var/obj/item/wallframe/frame = allocate(frame_type)
		frame.attach(wall_side, user)
		TEST_ASSERT(QDELETED(frame), "[frame_type] was not used up when attached")
		var/obj/structure/aquila_wall_decor/decor = locate(structure_type) in get_turf(user)
		TEST_ASSERT(decor, "[frame_type] did not create [structure_type]")
		TEST_ASSERT_EQUAL(decor.type, structure_type, "Wrong structure from [frame_type]")
		TEST_ASSERT_EQUAL(decor.pixel_y, 28, "[structure_type] was not shifted onto the north wall")
		decor.attack_hand(user)
		TEST_ASSERT(QDELETED(decor), "[structure_type] stayed on the wall after being taken down")
		var/obj/item/held = user.get_active_held_item()
		TEST_ASSERT(held, "Taking down [structure_type] gave nothing")
		TEST_ASSERT_EQUAL(held.type, frame_type, "Taking down [structure_type] gave the wrong item")
		qdel(held)

	var/obj/item/wallframe/kszysz/kszysz_drewniany/wooden = allocate(/obj/item/wallframe/kszysz/kszysz_drewniany)
	TEST_ASSERT(!length(wooden.materials), "Wooden cross still carries the wallframe iron")

	// Reklamówki to działający storage
	for(var/bag_type in list(/obj/item/storage/commercial/reklamowka_biedronka, /obj/item/storage/commercial/reklamowka_lidl))
		var/obj/item/storage/bag = allocate(bag_type)
		var/obj/item/coin = allocate(/obj/item/coin/iron)
		TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, coin, null, TRUE, FALSE), "[bag_type] refused a coin")
		TEST_ASSERT_EQUAL(coin.loc, bag, "[bag_type] did not store the coin")

	// Sandały zakładają się na stopy
	var/obj/item/clothing/shoes/aquila/aq_sandals/sandals = allocate(/obj/item/clothing/shoes/aquila/aq_sandals)
	TEST_ASSERT(user.equip_to_slot_if_possible(sandals, ITEM_SLOT_FEET, disable_warning = TRUE), "Sandals could not be worn")
	TEST_ASSERT_EQUAL(user.shoes, sandals, "Sandals are not in the feet slot")

	// Bielizna rysuje się z pliku Aquili, bez barwienia
	user.underwear = "Polskie Bokserki (wariant 1)"
	user.undershirt = "Koszulka (flaga) (Polska)"
	user.socks = "Zakolanówki (Biało-Czerwone)"
	user.underwear_color = "000"
	user.update_body()
	var/list/found = list()
	for(var/mutable_appearance/overlay in user.overlays_standing[BODY_LAYER])
		if(overlay.icon == 'aquila/icons/mob/clothing/underwear.dmi')
			found[overlay.icon_state] = overlay.color
	TEST_ASSERT("aq_boxers_1" in found, "Polish underwear overlay missing")
	TEST_ASSERT(isnull(found["aq_boxers_1"]), "Polish underwear got tinted with [found["aq_boxers_1"]]")
	TEST_ASSERT("aq_shirt_polska" in found, "Polish undershirt overlay missing")
	TEST_ASSERT("aq_codersocks_pl" in found, "Polish socks overlay missing")

	// Moby: martwe i ożywione mają poprawne sprite'y
	for(var/mob_type in list(/mob/living/simple_animal/hostile/kurwinoxy, /mob/living/simple_animal/hostile/kurwinoxy/czerwony, /mob/living/simple_animal/hostile/clowiekmaupa))
		var/mob/living/simple_animal/hostile/mob = allocate(mob_type)
		mob.death()
		TEST_ASSERT_EQUAL(mob.icon_state, mob.icon_dead, "[mob_type] dead sprite")
		mob.revive(full_heal = TRUE, admin_revive = TRUE)
		TEST_ASSERT_EQUAL(mob.icon_state, mob.icon_living, "[mob_type] revived sprite")
		TEST_ASSERT_EQUAL(mob.stat, CONSCIOUS, "[mob_type] did not revive")

	// Kapitan Bomba: strój z adminowego wyboru wyposażenia
	var/mob/living/carbon/human/bomba = allocate(/mob/living/carbon/human)
	bomba.equipOutfit(/datum/outfit/kapitanbomba)
	TEST_ASSERT(istype(bomba.head, /obj/item/clothing/head/helmet/space/kapitanbomba), "Kapitan Bomba outfit has no helmet")
	TEST_ASSERT(istype(bomba.wear_suit, /obj/item/clothing/suit/kapitanbomba), "Kapitan Bomba outfit has no suit")
	TEST_ASSERT(istype(bomba.shoes, /obj/item/clothing/shoes/aquila/kapitanbomba), "Kapitan Bomba outfit has no boots")
	var/obj/item/gun/ballistic/automatic/l6_saw/blaster/blaster = locate() in bomba.held_items
	TEST_ASSERT(blaster, "Kapitan Bomba outfit has no blaster")
	TEST_ASSERT(istype(blaster.magazine, /obj/item/ammo_box/magazine/peacekeeper/lethal/blaster), "Blaster spawned without its magazine")
	TEST_ASSERT_EQUAL(blaster.get_ammo(), 99, "Blaster ammo (magazine + chambered)")
	TEST_ASSERT_EQUAL(bomba.real_name, "Tytus Bomba", "Kapitan Bomba name")
	var/obj/item/card/id/bomba_id = bomba.wear_id
	TEST_ASSERT_EQUAL(bomba_id?.assignment, "Kapitan Bomba", "Kapitan Bomba ID assignment")
	blaster.AltClick(bomba)
	TEST_ASSERT(blaster.cover_open, "Blaster cover did not open")
	blaster.AltClick(bomba)
	TEST_ASSERT(!blaster.cover_open, "Blaster cover did not close")
	// Upstream: usuwanie człowieka z implantem storage zadaje obrażenia już usuniętej klatce piersiowej, więc wyjmujemy implanty przed sprzątaniem
	for(var/obj/item/implant/implant as anything in bomba.implants)
		implant.removed(bomba, TRUE, TRUE)
		qdel(implant)

	// Maluch mieści pięć osób
	var/obj/vehicle/sealed/car/maluch/maluch = allocate(/obj/vehicle/sealed/car/maluch)
	TEST_ASSERT_EQUAL(maluch.max_occupants, 5, "Maluch capacity")

	// Źródła: ClothesMate, cargo, stos drewna, crafting
	var/obj/machinery/vending/clothing/clothesmate = allocate(/obj/machinery/vending/clothing)
	var/sandals_stocked = FALSE
	for(var/datum/data/vending_product/record in clothesmate.product_records)
		if(record.product_path == /obj/item/clothing/shoes/aquila/aq_sandals)
			sandals_stocked = record.amount
	TEST_ASSERT_EQUAL(sandals_stocked, 4, "ClothesMate sandal stock")

	var/datum/supply_pack/misc/maluch/pack = new
	TEST_ASSERT(/obj/vehicle/sealed/car/maluch in pack.contains, "Maluch supply pack has no car")
	qdel(pack)

	var/wood_cross = FALSE
	var/big_cross = FALSE
	for(var/datum/stack_recipe/recipe in GLOB.wood_recipes)
		if(recipe.result_type == /obj/item/wallframe/kszysz/kszysz_drewniany)
			wood_cross = TRUE
		if(recipe.result_type == /obj/structure/kitchenspike/crucifix)
			big_cross = TRUE
	TEST_ASSERT(wood_cross, "Wooden cross missing from wood recipes")
	TEST_ASSERT(big_cross, "Crucifix missing from wood recipes")

	var/list/wanted_recipes = list(/datum/crafting_recipe/polski_sztandar, /datum/crafting_recipe/kszysz_drewniany, /datum/crafting_recipe/kszysz_zloty, /datum/crafting_recipe/godlo_drewniane, /datum/crafting_recipe/godlo_czarne)
	for(var/datum/crafting_recipe/recipe in GLOB.crafting_recipes)
		wanted_recipes -= recipe.type
	TEST_ASSERT(!length(wanted_recipes), "Crafting recipes not registered: [english_list(wanted_recipes)]")

/// Returns a failure message if a ported type points at an icon_state that is not in its file
/datum/unit_test/polish_content/proc/check_icons()
	var/list/types = list(
		/obj/item/banner/polski_sztandar,
		/obj/item/banner/polski_sztandar/mundane,
		/obj/item/wallframe/kszysz/kszysz_drewniany,
		/obj/item/wallframe/kszysz/kszysz_zloty,
		/obj/item/wallframe/godlo/godlo_drewniane,
		/obj/item/wallframe/godlo/godlo_czarne,
		/obj/structure/aquila_wall_decor/kszysz,
		/obj/structure/aquila_wall_decor/kszysz/zloty,
		/obj/structure/aquila_wall_decor/godlo,
		/obj/structure/aquila_wall_decor/godlo/czarne,
		/obj/item/storage/commercial/reklamowka_biedronka,
		/obj/item/storage/commercial/reklamowka_lidl,
		/obj/item/clothing/shoes/aquila/aq_sandals,
		/obj/vehicle/sealed/car/maluch,
		/mob/living/simple_animal/hostile/kurwinoxy,
		/mob/living/simple_animal/hostile/kurwinoxy/czerwony,
		/mob/living/simple_animal/hostile/clowiekmaupa,
		/obj/structure/sign/directions/plaque/science,
		/obj/structure/sign/directions/plaque/engineering,
		/obj/structure/sign/directions/plaque/security,
		/obj/structure/sign/directions/plaque/medical,
		/obj/structure/sign/directions/plaque/evac,
		/obj/structure/sign/directions/plaque/supply,
		/obj/structure/sign/directions/plaque/command,
		/obj/structure/sign/directions/plaque/munitions,
		/obj/item/clothing/head/helmet/space/kapitanbomba,
		/obj/item/clothing/suit/kapitanbomba,
		/obj/item/clothing/shoes/aquila/kapitanbomba,
		/obj/item/gun/ballistic/automatic/l6_saw/blaster,
		/obj/item/ammo_box/magazine/peacekeeper/lethal/blaster,
	)
	// L6 zawsze dokłada nakładkę pokrywy z pliku broni
	for(var/door in list("l6_door_open", "l6_door_closed"))
		if(!icon_exists('aquila/icons/obj/items/guns.dmi', door))
			return "Blaster icon has no [door] overlay"
	types += typesof(/obj/structure/sign/flag)
	types += typesof(/obj/structure/sign/flag_wide)
	types += typesof(/obj/effect/turf_decal/szachownica)

	for(var/atom/path as anything in types)
		var/icon_file = initial(path.icon)
		var/state = initial(path.icon_state)
		if(!icon_exists(icon_file, state))
			return "[path] has no icon_state \"[state]\" in [icon_file]"
		if(ispath(path, /obj/item))
			var/obj/item/item_path = path
			var/held_state = initial(item_path.item_state) || state
			// Buty i magazynki nie mają sprite'ów w dłoni w całej grze, a wallframe'y dzielą wspólny sprite skrzynki
			if(!ispath(path, /obj/item/clothing/shoes) && !ispath(path, /obj/item/ammo_box))
				if(!icon_exists(initial(item_path.lefthand_file), held_state))
					return "[path] has no left inhand \"[held_state]\" in [initial(item_path.lefthand_file)]"
				if(!icon_exists(initial(item_path.righthand_file), held_state))
					return "[path] has no right inhand \"[held_state]\" in [initial(item_path.righthand_file)]"
			if(ispath(path, /obj/item/clothing))
				var/worn_state = initial(item_path.worn_icon_state) || state
				if(!icon_exists(initial(item_path.worn_icon), worn_state))
					return "[path] has no worn state \"[worn_state]\" in [initial(item_path.worn_icon)]"
		if(ispath(path, /mob/living/simple_animal))
			var/mob/living/simple_animal/animal = path
			if(!icon_exists(icon_file, initial(animal.icon_living)))
				return "[path] has no icon_living \"[initial(animal.icon_living)]\""
			if(!icon_exists(icon_file, initial(animal.icon_dead)))
				return "[path] has no icon_dead \"[initial(animal.icon_dead)]\""
		if(ispath(path, /obj/structure/aquila_wall_decor))
			var/obj/structure/aquila_wall_decor/decor = path
			var/obj/item/wallframe/frame = initial(decor.item_path)
			if(!ispath(frame, /obj/item/wallframe))
				return "[path] has no item to give back"
			if(initial(frame.result_path) != path)
				return "[path] gives back [frame], which builds [initial(frame.result_path)]"

/// Returns a failure message if a Polish sprite accessory is missing, tinted, or points at a missing state
/datum/unit_test/polish_content/proc/check_accessories()
	var/list/accessory_lists = list(GLOB.underwear_list, GLOB.undershirt_list, GLOB.socks_list)
	var/count = 0
	for(var/list/accessory_list in accessory_lists)
		for(var/name in accessory_list)
			var/datum/sprite_accessory/accessory = accessory_list[name]
			if(!accessory || !findtext(accessory.icon_state, "aq_", 1, 4))
				continue
			count++
			if(accessory.icon != 'aquila/icons/mob/clothing/underwear.dmi')
				return "[accessory.type] uses [accessory.icon]"
			if(!icon_exists(accessory.icon, accessory.icon_state))
				return "[accessory.type] has no icon_state \"[accessory.icon_state]\""
			if(istype(accessory, /datum/sprite_accessory/underwear))
				var/datum/sprite_accessory/underwear/underwear = accessory
				if(!underwear.use_static)
					return "[accessory.type] would be tinted by underwear colour"
	if(count != 20)
		return "Expected 20 Polish sprite accessories, found [count]"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
