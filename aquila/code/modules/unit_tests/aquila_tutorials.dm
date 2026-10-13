// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - samouczek: lekcje mają dane do menu, ich pokoje się wczytują i znikają po końcu, a postać w samouczku nie liczy się do dynamic
/datum/unit_test/aquila_tutorials

/datum/unit_test/aquila_tutorials/Run()
	var/datum/tutorial/base = /datum/tutorial
	var/list/ids = list()
	var/list/lessons = list()
	for(var/datum/tutorial/path as anything in subtypesof(/datum/tutorial))
		if(initial(path.parent_path) == path)
			continue
		lessons += path
		TEST_ASSERT(initial(path.name) != initial(base.name), "[path] has no name")
		TEST_ASSERT(initial(path.tutorial_id) != initial(base.tutorial_id), "[path] has no tutorial_id")
		TEST_ASSERT(initial(path.desc), "[path] has no desc")
		TEST_ASSERT(initial(path.icon), "[path] has no menu icon")
		TEST_ASSERT(!(initial(path.tutorial_id) in ids), "[path] reuses the tutorial_id [initial(path.tutorial_id)]")
		ids += initial(path.tutorial_id)
	TEST_ASSERT(length(lessons), "There are no tutorial lessons")
	for(var/datum/tutorial/path as anything in lessons)
		var/required = initial(path.required_tutorial)
		TEST_ASSERT(!required || (required in ids), "[path] requires the missing lesson [required]")

	// Każdy pokój się wczytuje, ma landmark rogu w obszarze samouczka i znika po skasowaniu lekcji
	for(var/datum/tutorial/path as anything in lessons)
		var/datum/tutorial/lesson = new path
		TEST_ASSERT(lesson.setup_room(), "[path] did not load its room")
		var/turf/corner = lesson.bottom_left_corner
		TEST_ASSERT(istype(corner.loc, /area/aquila_tutorial), "[path] room corner is not in the tutorial area")
		TEST_ASSERT(!(locate(/obj/effect/landmark/tutorial_bottom_left) in corner), "[path] left its corner landmark behind")
		lesson.init_map()
		qdel(lesson)
		TEST_ASSERT(corner.flags_1 & UNUSED_RESERVATION_TURF_1, "[path] room was not released")
		TEST_ASSERT(!istype(corner.loc, /area/aquila_tutorial), "[path] room is still there after the lesson ended")

	// Menu: wszystkie lekcje, pierwsza odblokowana
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/datum/tutorial_menu/menu = new
	var/list/data = menu.ui_static_data(viewer)
	TEST_ASSERT(length(data["tutorials"]) == length(lessons), "The menu lists [length(data["tutorials"])] of [length(lessons)] lessons")
	var/list/first = data["tutorials"][1]
	TEST_ASSERT(first["id"] == "aquila_basic_1", "The first lesson in the menu is [first["id"]]")
	TEST_ASSERT(!first["locked"], "The first lesson is locked")
	// Wszystkie lekcje są dostępne od razu
	for(var/list/entry as anything in data["tutorials"])
		TEST_ASSERT(!entry["locked"], "The lesson [entry["id"]] is locked for a new player")
	qdel(menu)

	// Klawisze z preferencji: nazwa akcji = klawisz
	var/datum/tutorial/aquila/basic/binds = new
	binds.player_bind_dict = list("swap_hands" = list("X"))
	TEST_ASSERT(binds.retrieve_bind("swap_hands") == "X", "retrieve_bind does not return the bound key")
	TEST_ASSERT(binds.retrieve_bind("not_a_bind") == "(brak klawisza)", "retrieve_bind does not handle unbound actions")
	qdel(binds)

	// Postać w samouczku nie trafia do żywych graczy dynamic
	if(SSticker.mode)
		var/mob/living/carbon/human/student = allocate(/mob/living/carbon/human)
		ADD_TRAIT(student, TRAIT_IN_TUTORIAL, TRAIT_SOURCE_TUTORIAL)
		student.add_to_current_living_players()
		TEST_ASSERT(!(student in SSticker.mode.current_players[CURRENT_LIVING_PLAYERS]), "A tutorial mob counts as a living player")

	walk_basic_lesson()
	if(!succeeded)
		return
	walk_survival_lesson()
	if(!succeeded)
		return
	walk_gq_lesson()

#define STEP_ASSERT(step) TEST_ASSERT(lesson.current_step == step, "[lesson.type] is at step [lesson.current_step], expected [step]")

/// Przechodzi skrypt lekcji Podstawy bez klienta: każdy krok musi przejść do następnego po akcji gracza
/datum/unit_test/aquila_tutorials/proc/walk_basic_lesson()
	var/datum/tutorial/aquila/basic/lesson = new
	TEST_ASSERT(lesson.setup_room(), "The basic lesson room did not load")
	lesson.init_map()
	var/mob/living/carbon/human/student = new(lesson.bottom_left_corner)
	student.equipOutfit(lesson.outfit)
	lesson.tutorial_mob = student

	var/obj/structure/chair/chair = lesson.tracking_atoms[/obj/structure/chair]
	student.forceMove(chair.loc)
	chair.buckle_mob(student, TRUE)
	TEST_ASSERT(student.buckled == chair, "The student is not buckled to the chair")
	var/obj/machinery/door/airlock/cabin_door = lesson.gates["cabin"]
	TEST_ASSERT(cabin_door?.locked, "The cabin door is not bolted at the start")
	lesson.require_unbuckle()
	STEP_ASSERT("unbuckle")
	chair.unbuckle_mob(student)
	STEP_ASSERT("swap_hands")

	student.swap_hand()
	STEP_ASSERT("flashlight")
	var/obj/item/flashlight/tutorial/flashlight = lesson.tracking_atoms[/obj/item/flashlight/tutorial]
	TEST_ASSERT(istype(flashlight?.loc, /obj/structure/closet), "The flashlight is not in the closet")
	student.put_in_hands(flashlight)
	flashlight.attack_self(student)
	STEP_ASSERT("corridor")

	var/turf/corridor_spot = lesson.loc_from_corner(3, 4)
	TEST_ASSERT(locate(/obj/effect/tutorial_marker) in corridor_spot, "The corridor target has no floor marker")
	student.forceMove(corridor_spot)
	STEP_ASSERT("throw")
	TEST_ASSERT(!cabin_door.locked, "The cabin door is still bolted after its step")
	var/obj/machinery/door/airlock/hall_door = lesson.gates["hall"]
	TEST_ASSERT(hall_door?.locked, "The hall door opened too early")
	TEST_ASSERT(!(locate(/obj/effect/tutorial_marker) in corridor_spot), "The corridor marker stayed after the step")
	var/obj/item/trash/can/can = lesson.tracking_atoms[/obj/item/trash/can]
	var/obj/structure/closet/crate/bin/bin = lesson.tracking_atoms[/obj/structure/closet/crate/bin]
	// Lądowanie obok kosza po rzucie w podłogę się nie liczy
	can.forceMove(get_step(bin, SOUTH))
	var/datum/thrownthing/floor_throw = new(can, get_step(bin, SOUTH), SOUTH, 5, 1, student)
	SEND_SIGNAL(can, COMSIG_MOVABLE_THROW_LANDED, floor_throw)
	qdel(floor_throw)
	STEP_ASSERT("throw")
	// Puszka rzucona w kosz, która wylądowała tuż obok, się liczy
	var/datum/thrownthing/bin_throw = new(can, bin, SOUTH, 5, 1, student)
	SEND_SIGNAL(can, COMSIG_MOVABLE_THROW_LANDED, bin_throw)
	qdel(bin_throw)
	STEP_ASSERT("pull")

	var/obj/structure/closet/crate/crate = lesson.tracking_atoms[/obj/structure/closet/crate]
	crate.forceMove(lesson.loc_from_corner(9, 6))
	STEP_ASSERT("walk")
	TEST_ASSERT(!hall_door.locked, "The hall door is still bolted after the pull step")
	var/turf/open/wet = lesson.loc_from_corner(5, 4)
	TEST_ASSERT(wet.GetComponent(/datum/component/slippery), "The corridor is not slippery")

	student.toggle_move_intent()
	STEP_ASSERT("hall")
	student.forceMove(lesson.loc_from_corner(5, 1))
	STEP_ASSERT("run")
	student.toggle_move_intent()
	STEP_ASSERT("rest")

	student.set_resting(TRUE)
	STEP_ASSERT("stand_up")
	student.set_resting(FALSE)
	STEP_ASSERT("backpack")

	var/obj/item/storage/box/survival/box = locate() in student.back
	TEST_ASSERT(box, "No survival box in the backpack")
	box.forceMove(student.loc)
	student.put_in_hands(box)
	STEP_ASSERT("internals")
	student.update_internals_hud_icon(1)
	STEP_ASSERT("internals_done")
	// Mokra podłoga nie może zniknąć sama (komponent z czasem 0 kasował się w następnym ticku)
	sleep(world.tick_lag * 2)
	TEST_ASSERT(wet.GetComponent(/datum/component/slippery), "The corridor dried up during the lesson")

	lesson.require_combat()
	STEP_ASSERT("help")
	var/mob/living/carbon/human/dummy = lesson.tracking_atoms[/mob/living/carbon/human]
	TEST_ASSERT(dummy?.status_flags & GODMODE, "The training dummy can be hurt")
	student.a_intent = INTENT_HARM
	SEND_SIGNAL(student, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, dummy)
	STEP_ASSERT("help")
	student.a_intent = INTENT_HELP
	SEND_SIGNAL(student, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, dummy)
	STEP_ASSERT("harm")
	SEND_SIGNAL(student, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, dummy)
	STEP_ASSERT("harm")
	student.a_intent = INTENT_HARM
	SEND_SIGNAL(student, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, dummy)
	STEP_ASSERT("harm_done")

	lesson.require_say()
	STEP_ASSERT("say")
	SEND_SIGNAL(student, COMSIG_MOB_SAY)
	STEP_ASSERT("radio_common")
	var/obj/item/radio/headset/headset = student.get_item_by_slot(ITEM_SLOT_EARS)
	headset.talk_into(student, "test", null)
	STEP_ASSERT("radio_department")
	headset.talk_into(student, "test", null)
	STEP_ASSERT("radio_department")
	headset.talk_into(student, "test", RADIO_CHANNEL_ENGINEERING)
	STEP_ASSERT("radio_department")
	headset.talk_into(student, "test", RADIO_CHANNEL_MUNITIONS)
	STEP_ASSERT("finished")
	TEST_ASSERT(lesson.completion_marked, "The finished basic lesson is not marked as completed")

	qdel(lesson)

/// Przechodzi skrypt lekcji Przetrwanie bez klienta
/datum/unit_test/aquila_tutorials/proc/walk_survival_lesson()
	var/datum/tutorial/aquila/survival/lesson = new
	TEST_ASSERT(lesson.setup_room(), "The survival lesson room did not load")
	lesson.init_map()
	var/mob/living/carbon/human/student = new(lesson.loc_from_corner(1, 2))
	student.equipOutfit(lesson.outfit)
	lesson.tutorial_mob = student

	var/mob/living/carbon/human/patient = lesson.tracking_atoms[/mob/living/carbon/human]
	TEST_ASSERT(patient && patient.stat != CONSCIOUS && patient.stat != DEAD, "The patient is not in critical condition")
	var/obj/item/reagent_containers/hypospray/medipen/tutorial/medipen = lesson.tracking_atoms[/obj/item/reagent_containers/hypospray/medipen/tutorial]
	TEST_ASSERT(medipen?.loc == patient && patient.l_store == medipen, "The medipen is not in the patient's pocket")

	// Skafander, hełm, maska i butla z pudełka przetrwania
	var/obj/item/storage/box/survival/box = locate() in student.back
	TEST_ASSERT(box, "No survival box in the backpack")
	var/obj/item/clothing/suit/space/skinsuit/suit = locate() in box
	var/obj/item/clothing/head/helmet/space/skinsuit/helmet = locate() in box
	var/obj/item/clothing/mask/breath/mask = locate() in box
	var/obj/item/tank/internals/tank = locate() in box
	TEST_ASSERT(suit && helmet && mask && tank, "The survival box is missing the skinsuit, helmet, mask or tank")

	lesson.start_decompression()
	STEP_ASSERT("decompression")
	TEST_ASSERT(lesson.draining, "The room is not losing air")
	mask.forceMove(student.loc)
	TEST_ASSERT(student.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK, disable_warning = TRUE), "Could not put on the mask")
	tank.forceMove(student.loc)
	TEST_ASSERT(student.equip_to_slot_if_possible(tank, ITEM_SLOT_LPOCKET, disable_warning = TRUE), "Could not pocket the tank")
	student.internal = tank
	student.update_internals_hud_icon(1)
	// Same internale nie wystarczą, potrzebny jest jeszcze skafander i hełm
	STEP_ASSERT("decompression")
	helmet.forceMove(student.loc)
	TEST_ASSERT(student.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, disable_warning = TRUE, bypass_equip_delay_self = TRUE), "Could not put on the helmet")
	STEP_ASSERT("decompression")
	suit.forceMove(student.loc)
	TEST_ASSERT(!student.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "A rolled skinsuit could be worn")
	suit.attack_self(student)
	TEST_ASSERT(student.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE, bypass_equip_delay_self = TRUE), "Could not put on the unrolled skinsuit")
	STEP_ASSERT("protected")
	lesson.restore_air()
	var/turf/open/floor = lesson.loc_from_corner(1, 2)
	TEST_ASSERT(floor.return_air().return_pressure() > 90, "The air was not restored")

	lesson.require_strip()
	STEP_ASSERT("strip")
	patient.dropItemToGround(medipen)
	STEP_ASSERT("epinephrine")
	// Wstrzyknięcie sobie daje nowy autoinjektor i nie zalicza kroku
	medipen.inject(student, student)
	STEP_ASSERT("epinephrine")
	var/obj/item/reagent_containers/hypospray/medipen/tutorial/new_medipen = lesson.tracking_atoms[/obj/item/reagent_containers/hypospray/medipen/tutorial]
	TEST_ASSERT(new_medipen && new_medipen != medipen, "No new medipen after the wasted one")
	new_medipen.inject(patient, student)
	STEP_ASSERT("carry")
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/medicine/epinephrine), "The patient got no epinephrine")

	student.forceMove(patient.loc)
	student.buckle_mob(patient, TRUE, FALSE, 90, 1, 0)
	STEP_ASSERT("bed")
	var/obj/structure/bed/bed = lesson.tracking_atoms[/obj/structure/bed]
	student.unbuckle_mob(patient)
	STEP_ASSERT("carry")
	student.forceMove(bed.loc)
	patient.forceMove(bed.loc)
	student.buckle_mob(patient, TRUE, FALSE, 90, 1, 0)
	STEP_ASSERT("bed")
	student.unbuckle_mob(patient)
	STEP_ASSERT("finished")
	TEST_ASSERT(lesson.completion_marked, "The finished survival lesson is not marked as completed")

	qdel(lesson)

/// Przechodzi skrypt lekcji Alarm bojowy bez klienta (stany działa ustawiane wprost, żeby nie czekać na animacje)
/datum/unit_test/aquila_tutorials/proc/walk_gq_lesson()
	var/datum/tutorial/aquila/general_quarters/lesson = new
	TEST_ASSERT(lesson.setup_room(), "The general quarters lesson room did not load")
	lesson.init_map()
	var/mob/living/carbon/human/student = new(lesson.bottom_left_corner)
	student.equipOutfit(lesson.outfit)
	lesson.tutorial_mob = student

	var/obj/machinery/ship_weapon/gauss_gun/tutorial/gun = lesson.tracking_atoms[/obj/machinery/ship_weapon/gauss_gun/tutorial]
	var/obj/structure/chair/fancy/gauss/chair = lesson.tracking_atoms[/obj/structure/chair/fancy/gauss]
	TEST_ASSERT(gun.gunner_chair == chair && chair.gun == gun, "The gauss gun is not linked to its chair")
	TEST_ASSERT(get_turf(gun.ammo_rack) == lesson.loc_from_corner(9, 5), "The gauss rack is not at its spot")
	TEST_ASSERT(!gun.linked, "The tutorial gauss gun is linked to a ship")

	var/obj/structure/bed/bed = lesson.tracking_atoms[/obj/structure/bed]
	student.forceMove(bed.loc)
	bed.buckle_mob(student, TRUE)
	lesson.start_general_quarters()
	STEP_ASSERT("gq")
	bed.unbuckle_mob(student)
	STEP_ASSERT("pager")
	var/obj/item/squad_pager/tutorial/pager = lesson.tracking_atoms[/obj/item/squad_pager/tutorial]
	pager.attack_self(student)
	STEP_ASSERT("squads")

	lesson.require_vendor()
	STEP_ASSERT("vendor")
	var/obj/machinery/squad_vendor/tutorial/vendor = lesson.tracking_atoms[/obj/machinery/squad_vendor/tutorial]
	var/list/kits = vendor.ui_data(student)["kits"]
	TEST_ASSERT(length(kits), "The tutorial squad vendor offers no kits")
	usr = student
	vendor.ui_act("vend", list("item_id" = kits[1]["id"]))
	usr = null
	STEP_ASSERT("equip")
	var/obj/item/storage/box/squad_kit/kit = locate() in vendor.loc
	TEST_ASSERT(kit, "The vendor did not drop a kit")
	var/obj/item/clothing/suit/ship/squad/vest = locate() in kit
	var/obj/item/clothing/head/helmet/ship/squad/helmet = locate() in kit
	TEST_ASSERT(vest && helmet && (locate(/obj/item/gun) in kit), "The kit is missing the vest, helmet or gun")
	vest.forceMove(student.loc)
	helmet.forceMove(student.loc)
	student.equip_to_slot_if_possible(vest, ITEM_SLOT_OCLOTHING, disable_warning = TRUE, bypass_equip_delay_self = TRUE)
	STEP_ASSERT("equip")
	student.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, disable_warning = TRUE, bypass_equip_delay_self = TRUE)
	STEP_ASSERT("shooting")

	for(var/obj/item/target/tutorial/target as anything in lesson.targets_left.Copy())
		SEND_SIGNAL(target, COMSIG_TUTORIAL_ITEM_USED, student)
	TEST_ASSERT(!length(lesson.targets_left), "Hit targets are still counted as left")

	lesson.require_rack_hand()
	STEP_ASSERT("rack_hand")
	var/obj/item/ship_weapon/ammunition/gauss/round = lesson.tracking_atoms[/obj/item/ship_weapon/ammunition/gauss]
	gun.ammo_rack.load(round)
	STEP_ASSERT("rack_crate")
	var/obj/structure/closet/crate/crate = lesson.tracking_atoms[/obj/structure/closet/crate]
	for(var/obj/item/ship_weapon/ammunition/gauss/crate_round in crate)
		gun.ammo_rack.load(crate_round)
	STEP_ASSERT("chair")

	gun.set_gunner(student)
	STEP_ASSERT("gun_load")
	gun.state = STATE_LOADED
	SEND_SIGNAL(gun, COMSIG_TUTORIAL_ITEM_USED, student, "load")
	STEP_ASSERT("gun_feed")
	gun.state = STATE_FED
	SEND_SIGNAL(gun, COMSIG_TUTORIAL_ITEM_USED, student, "toggle_load")
	STEP_ASSERT("gun_chamber")
	gun.state = STATE_CHAMBERED
	SEND_SIGNAL(gun, COMSIG_TUTORIAL_ITEM_USED, student, "chamber")
	STEP_ASSERT("gun_arm")
	gun.safety = FALSE
	SEND_SIGNAL(gun, COMSIG_TUTORIAL_ITEM_USED, student, "toggle_safety")
	STEP_ASSERT("gun_camera")
	// Kamera to przycisk akcji po lewej, a strzelec dostał też przycisk wyjścia
	var/datum/action/gauss_gunner/camera/camera_action = locate() in student.actions
	TEST_ASSERT(camera_action && (locate(/datum/action/gauss_gunner/exit) in student.actions), "The gunner has no camera or exit button")
	camera_action.Trigger()
	STEP_ASSERT("gun_fire")
	lesson.require_exit()
	STEP_ASSERT("gun_exit")
	gun.gunner_chair.forceMove(gun)
	var/datum/action/gauss_gunner/exit/exit_action = locate() in student.actions
	exit_action.Trigger()
	STEP_ASSERT("finished")
	TEST_ASSERT(!(locate(/datum/action/gauss_gunner) in student.actions), "The gunner buttons stayed after leaving the gun")
	TEST_ASSERT(get_turf(student) == lesson.loc_from_corner(9, 6), "The gunner did not come down to the chair spot")
	TEST_ASSERT(lesson.completion_marked, "The finished general quarters lesson is not marked as completed")

	qdel(lesson)

#undef STEP_ASSERT
#undef TEST_ASSERT
